

import xml.etree.ElementTree as etree

from testsuite.Ulm.ET.L2.libraries import vendor_file_modifier


def modify_vendor_file_wrapper(filter_criteria, data_to_be_modified, path_to_reference_vendor_file,
                               path_to_modified_vendor_file, xml_path=None):
    vendor_file_modifier.modify_vendor_file(filter_criteria, data_to_be_modified, path_to_reference_vendor_file,
                                            path_to_modified_vendor_file, xml_path=xml_path)


def get_xml_path(p_name, path_class='NRBTS'):
    xml_path = ("{ns}cmData//"
                "{ns}managedObject[@class='{path_class}']//"
                "{ns}p[@name='{p_name}']".format(
                    ns="{"+get_ns()+"}",
                    path_class=path_class,
                    p_name=p_name)
                )
    return xml_path


def get_clean_xml_path(xml_path):
    return xml_path.replace(
        "{}".format("{"+get_ns()+"}"), ''
    ).replace(
        "='", '/'
    ).replace(
        "[@", '/'
    ).replace(
        "]", '/'
    ).replace(
        "'", '/'
    ).replace(
        '//', '/'
    ).replace(
        '//', '/'
    )


def get_ns():
    return vendor_file_modifier.ns


def get_xml_value(xml, xml_path):
    values = []
    tree = etree.parse(xml)
    root = tree.findall(xml_path)
    for items in root:
        values.append(str(items.text))
    return values
