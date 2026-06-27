import xml.etree.ElementTree as ET
import os

manifest_path = "android/app/src/main/AndroidManifest.xml"
if not os.path.exists(manifest_path):
    print("Android Manifest not found!")
    exit(1)

ET.register_namespace('android', 'http://schemas.android.com/apk/res/android')
tree = ET.parse(manifest_path)
root = tree.getroot()

# Find application element
application = root.find('application')
if application is None:
    print("Application tag not found in Manifest!")
    exit(1)

# FORCE the user-facing App Launcher name to be "Lekpad" instead of "balochi"
application.set('{http://schemas.android.com/apk/res/android}label', 'Lekpad')
print("Successfully forced Android Launcher app name to 'Lekpad'!")

# Check if service already exists to prevent duplicate insertion
service_exists = False
for child in application.findall('service'):
    name = child.get('{http://schemas.android.com/apk/res/android}name')
    if name == '.BalochiInputMethod':
        service_exists = True
        break

if not service_exists:
    # Create service element
    service = ET.SubElement(application, 'service')
    service.set('{http://schemas.android.com/apk/res/android}name', '.BalochiInputMethod')
    service.set('{http://schemas.android.com/apk/res/android}label', 'Lekpad Keyboard')
    service.set('{http://schemas.android.com/apk/res/android}permission', 'android.permission.BIND_INPUT_METHOD')
    service.set('{http://schemas.android.com/apk/res/android}exported', 'true')

    intent_filter = ET.SubElement(service, 'intent-filter')
    action = ET.SubElement(intent_filter, 'action')
    action.set('{http://schemas.android.com/apk/res/android}name', 'android.view.InputMethod')

    meta_data = ET.SubElement(service, 'meta-data')
    meta_data.set('{http://schemas.android.com/apk/res/android}name', 'android.view.im')
    meta_data.set('{http://schemas.android.com/apk/res/android}resource', '@xml/method')

    # Save the updated manifest back
    tree.write(manifest_path, encoding='utf-8', xml_declaration=True)
    print("Successfully injected BalochiInputMethod service into AndroidManifest.xml!")
else:
    tree.write(manifest_path, encoding='utf-8', xml_declaration=True)
    print("Service already exists, saving and exiting.")
