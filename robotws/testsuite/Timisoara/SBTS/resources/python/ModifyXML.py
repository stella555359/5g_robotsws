import xml.etree.ElementTree as ET


def modify_tag_value(xml_file, tag_name, new_value):
    try:
        # Parse the XML file
        tree = ET.parse(xml_file)
        root = tree.getroot()

        # Flag to check if the tag was found
        found = False

        # Iterate through all elements in the XML
        for elem in root.iter():
            # Check if the element has the 'name' attribute with the specified value
            if elem.get('name') == tag_name:
                elem.text = new_value
                found = True

        if found:
            # Build a new XML string without namespaces
            new_xml = ET.ElementTree(root)
            xml_string = ET.tostring(new_xml.getroot(), encoding='utf-8', method='xml').decode('utf-8')

            # Write the new XML back to the file, ensuring no namespace
            with open(xml_file, 'w', encoding='utf-8') as f:
                f.write(xml_string.replace('ns0:', '').replace('xmlns:ns0="http://example.com/ns"', ''))
            print(
                f"Tag with attribute 'name={tag_name}' was successfully updated."
            )
        else:
            print(
                f"Tag with attribute 'name={tag_name}' was not found in the XML file."
            )

    except FileNotFoundError:
        print(f"File '{xml_file}' was not found.")
    except ET.ParseError:
        print(f"File '{xml_file}' is not a valid XML file.")
