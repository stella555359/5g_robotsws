import xml.etree.cElementTree as ET
import logging


ns = "raml21.xsd"


def modify_vendor_file(filter_criteria, data_to_be_modified, path_to_reference_vendor_file,
                       path_to_modified_vendor_file, xml_path=None):
    logging.info("Start Vendor file modification")
    ET.register_namespace("", ns)
    tree = ET.parse(path_to_reference_vendor_file)
    for item in tree.findall(xml_path):
        extracted_data_set = generate_empty_extractor_data_set(filter_criteria)
        for sub_item in item.getchildren() if hasattr(item, "getchildren") else list(item):
            if None in list(extracted_data_set.values()):
                extract_data_from_items(sub_item, extracted_data_set)
        else:
            if None in (extracted_data_set.values()):
                extract_data_from_items(item, extracted_data_set)
        if (extracted_data_set == filter_criteria):
            logging.info("Match found for Data Set")
            for sub_item in item.getchildren() if hasattr(item, "getchildren") else list(item):
                modify_data_set(sub_item, data_to_be_modified)
            else:
                if not (item.getchildren() if hasattr(item, "getchildren") else list(item)):
                    modify_data_set(item, data_to_be_modified)

    tree.write(path_to_modified_vendor_file,
               encoding='UTF-8',
               xml_declaration=True)
    logging.info("End Vendor file modification")


def generate_empty_extractor_data_set(filter_criteria):
    extractor_data_set = {}
    for data in list(filter_criteria.keys()):
        extractor_data_set[data] = None
    return extractor_data_set


def extract_data_from_items(item, required_data):
    item_name = item.get('name')
    item_text = item.text
    if item_name in list(required_data.keys()):
        required_data[item_name] = item_text


def modify_data_set(item, data_to_be_modified):
    item_name = item.get('name')
    if item_name in list(data_to_be_modified.keys()):
        logging.info("Modified item %s from %s to %s" % (item_name, item.text, data_to_be_modified[item_name]))
        item.text = data_to_be_modified[item_name]


def get_xml_path_for_list(listname="bbL1SpPrbCapacity"):
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


def get_xml_path_for_bbPoolMode():
    xml_path = ("{ns}cmData//"
                "{ns}managedObject[@class='NRBTS']//"
                "{ns}p[@name='bbPoolMode']".format(ns="{"+ns+"}"))
    return xml_path


def get_xml_path_for_bbPoolMinResource():
    xml_path = ("{ns}cmData//"
                "{ns}managedObject[@class='NRBTS']//"
                "{ns}p[@name='bbPoolMinResource']".format(ns="{"+ns+"}"))
    return xml_path


if __name__ == '__main__':
    filter_criteria = {"bbHwVariant": "ABIO", "confDuplexMode": "FDD", "csSize": "48"}
    # filter_criteria = {"bbPoolMode": "load-metric"}
    # data_to_be_modified = {"bbPoolMode": "round-robin"}
    data_to_be_modified = {"maxNumLayerPrbUlL1Sp": "1636",
                           "maxNumStreamPrbUlL1Sp": "818"}
    path_to_reference_vendor_file = '/mnt/etfiles/users/srjanard/DEVELOPMENT/robotws/xml/vendor_lte.xml'
    path_to_modified_vendor_file = '/mnt/etfiles/users/srjanard/DEVELOPMENT/robotws/xml/vendor_lte_modified.xml'
    # xml_path = get_xml_path_for_bbPoolMode()
    xml_path = get_xml_path_for_list(listname="bbL1SpPrbCapacity")
    modify_vendor_file(filter_criteria, data_to_be_modified, path_to_reference_vendor_file,
                       path_to_modified_vendor_file, xml_path=xml_path)
