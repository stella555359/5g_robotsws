import xml.etree.cElementTree as ET
import logging


ns = "raml21.xsd"


def modify_vendor_file(filter_criteria, data_to_be_modified, path_to_reference_vendor_file,
                       path_to_modified_vendor_file, xml_path=None):
    logging.info("Start Vendor file modification")
    ET.register_namespace("", ns)
    tree = ET.parse(path_to_reference_vendor_file)
    print(xml_path)
    for item in tree.findall(xml_path):
        extracted_data_set = _generate_empty_extractor_data_set(filter_criteria)
        for sub_item in list(item):
            if None in list(extracted_data_set.values()):
                _extract_data_from_items(sub_item, extracted_data_set)
        else:
            if None in (extracted_data_set.values()):
                _extract_data_from_items(item, extracted_data_set)
        if (extracted_data_set == filter_criteria):
            logging.info("Match found for Data Set")
            for sub_item in list(item):
                _modify_data_set(sub_item, data_to_be_modified)
            else:
                if not (list(item)):
                    _modify_data_set(item, data_to_be_modified)

    tree.write(path_to_modified_vendor_file,
               encoding='UTF-8',
               xml_declaration=True)
    logging.info("End Vendor file modification")


def get_xml_path_for_list():
    """Generates xml path to locate the a particular list, by default it generates a path to bbL1SpPrbCapacity"""
    xml_path = ("{ns}cmData//"
                "{ns}managedObject[@class='NRBTS']//")
    return xml_path


def get_xml_path_with_given_list(listname="bbL1SpPrbCapacity"):
    """Generates xml path to locate by the given list"""
    xml_path = ("{ns}cmData//"
                "{ns}managedObject[@class='NRBTS']//"
                "{ns}list[@name='{list_name}']/".format(ns="{"+ns+"}", list_name=listname))
    return xml_path


def get_xml_path_for_xec():
    """Generates xml path to locate bbPoolMode"""
    xml_path = ("{ns}cmData//"
                "{ns}managedObject[@class='NRBTS']//"
                "{ns}p[@name='xEc']".format(ns="{"+ns+"}"))
    return xml_path


def _generate_empty_extractor_data_set(filter_criteria):
    """Private function, do not use"""
    extractor_data_set = {}
    for data in list(filter_criteria.keys()):
        extractor_data_set[data] = None
    return extractor_data_set


def _extract_data_from_items(item, required_data):
    """Private function, do not use"""
    item_name = item.get('name')
    item_text = item.text
    if item_name in list(required_data.keys()):
        required_data[item_name] = item_text


def _modify_data_set(item, data_to_be_modified):
    """Private function, do not use"""
    item_name = item.get('name')
    if item_name in list(data_to_be_modified.keys()):
        logging.info("Modified item %s from %s to %s" % (item_name, item.text, data_to_be_modified[item_name]))
        item.text = data_to_be_modified[item_name]
