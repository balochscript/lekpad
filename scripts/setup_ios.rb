require 'xcodeproj'
require 'fileutils'

# 1. Open the generated Xcode project
project_path = 'ios/Runner.xcodeproj'
unless File.exist?(project_path)
  puts "Xcode project not found at #{project_path}"
  exit 1
end

project = Xcodeproj::Project.open(project_path)
main_group = project.main_group

# 2. Define extension settings
extension_name = 'LekpadExtension'
extension_dir = "ios/#{extension_name}"
FileUtils.mkdir_p(extension_dir)

# 3. Create Info.plist for the extension (Including UIAppFonts for local Amiri font loading!)
info_plist_content = <<~PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>Lekpad Keyboard</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>UIAppFonts</key>
	<array>
		<string>assets/fonts/Amiri-Regular.ttf</string>
		<string>assets/fonts/Amiri-Bold.ttf</string>
	</array>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionAttributes</key>
		<dict>
			<key>IsASCIICapable</key>
			<false/>
			<key>PrefersRightToLeft</key>
			<true/>
			<key>PrimaryLanguage</key>
			<string>bal</string>
			<key>RequestsOpenAccess</key>
			<true/>
		</dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.keyboard-service</string>
		<key>NSExtensionPrincipalClass</key>
		<string>$(PRODUCT_MODULE_NAME).KeyboardViewController</string>
	</dict>
</dict>
</plist>
PLIST

File.write("#{extension_dir}/Info.plist", info_plist_content)

# 4. Copy KeyboardViewController.swift into the extension directory
if File.exist?('ios/KeyboardViewController.swift')
  FileUtils.cp('ios/KeyboardViewController.swift', "#{extension_dir}/KeyboardViewController.swift")
  FileUtils.rm('ios/KeyboardViewController.swift') # Clean up root level file
end

# 5. Add a new target for the Keyboard Extension
extension_target = project.new_target(:app_extension, extension_name, :ios, '13.0')
extension_target.product_type = 'com.apple.product-type.app-extension'

# 6. Create file references in Xcode
group = main_group.find_subpath(extension_name, true)
group.path = extension_name # CRUCIAL: Map the Xcode group to its physical folder on disk (relative to project root 'ios/')

swift_file_ref = group.new_file("KeyboardViewController.swift") 
plist_file_ref = group.new_file("Info.plist") 

# 7. Add Swift file to compilation sources
extension_target.add_file_references([swift_file_ref])

# 8. Configure build settings for the Extension Target (Fixed path relative to Xcode's ios/ root directory)
extension_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = "#{extension_name}/Info.plist" # FIXED: Relative to Xcode root directory
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "bc.lekpad.balochi.#{extension_name}" # Synced package name
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['SWIFT_VERSION'] = '5.0'
end

# 9. Link extension to the main target as a dependency
main_target = project.targets.find { |t| t.name == 'Runner' }
if main_target
  main_target.add_dependency(extension_target)
  
  # Ensure the extension is embedded in the main app build phase
  embed_extensions_phase = main_target.copy_files_build_phases.find { |p| p.name == 'Embed App Extensions' }
  unless embed_extensions_phase
    embed_extensions_phase = main_target.new_copy_files_build_phase('Embed App Extensions')
    embed_extensions_phase.symbol_dst_subfolder_spec = :plug_ins
  end
  embed_extensions_phase.add_file_reference(extension_target.product_reference)

  # CRUCIAL: Reorder build phases to put "Embed App Extensions" at the VERY END!
  # This breaks the circular dependency cycle in Xcode's new build system.
  build_phases = main_target.build_phases
  build_phases.delete(embed_extensions_phase)
  build_phases.push(embed_extensions_phase) # Force it to execute after thinning, compiling, and Info.plist processing!
end

# 10. Save Xcode project changes
project.save
puts "Successfully configured iOS App Extension for Lekpad with standard pathings and cycle-free phases!"
