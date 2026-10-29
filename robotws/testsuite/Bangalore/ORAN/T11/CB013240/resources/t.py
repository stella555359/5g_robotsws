import xml.etree.ElementTree as ET

# Parse the XML file
tree = ET.parse('/home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB013240/SCF/SavedSCF/CB013240_SCF.xml')
root = tree.getroot()

# Define the namespace
namespaces = {'ns': 'raml21.xsd'}
print("Namespaces:", namespaces)

# Find all items in the list with the specified namespace
items = root.findall(".//ns:list[@name='lbpsPeriodList']/ns:item", namespaces)
print("Items:", items)

# Print the content of each item
for item in items:
    print(ET.tostring(item, encoding='unicode'))
