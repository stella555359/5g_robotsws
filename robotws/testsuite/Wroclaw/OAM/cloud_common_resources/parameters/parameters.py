from lxml import etree


def find_elements_with_value(path_to_scf, searched_value):
    tree = etree.parse(path_to_scf)
    root = tree.getroot()
    found_elements = root.xpath(f"//*[text()='{searched_value}']")
    dict_name_values = []
    for element in found_elements:
        parent = element.getparent()
        dict_name_values.append(parent.get('distName'))
    return dict_name_values
