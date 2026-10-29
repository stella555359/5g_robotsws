#! encoding=utf-8

import xml.etree.ElementTree as ET


def read_xml_file(file_path):
    tree = ET.parse(file_path)
    root_node = tree.getroot()
    return root_node


def get_element_value(file_path, xpath):
    tree = ET.parse(file_path)
    root_node = tree.getroot()
    return_value = None
    try:
        return_value = root_node.find(xpath).text
    except AttributeError as e:
        print("No such element: %s" % xpath)
        print(e)
    return return_value


# value = get_element_value(
#     "permanent.xml",
#     './/managedObject[@distName="moduleDetectedLocation"]/parameter[parameterName="ModuleSerialNumber2"]/value')
# print(value)
