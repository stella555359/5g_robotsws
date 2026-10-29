from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
import xml.etree.cElementTree as ET
import logging

ns = "raml21.xsd"


@logged_keyword
def modify_vendor_file(filter_criteria, data_to_be_modified, filepath, xml_path=None):
    logging.info("Start Vendor file modification")
    ET.register_namespace("", ns)
    tree = ET.parse(filepath)
    for item in tree.findall(xml_path):
        extracted_data_set = generate_empty_extractor_data_set(filter_criteria)
        for sub_item in list(item) if hasattr(item, "getchildren") else list(item):
            if None in list(extracted_data_set.values()):
                extract_data_from_items(sub_item, extracted_data_set)
        else:
            if None in (extracted_data_set.values()):
                extract_data_from_items(item, extracted_data_set)
        if extracted_data_set == filter_criteria:
            logging.info("Match found for Data Set")
            for sub_item in list(item) if hasattr(item, "getchildren") else list(item):
                modify_data_set(sub_item, data_to_be_modified)
            else:
                if not (list(item) if hasattr(item, "getchildren") else list(item)):
                    modify_data_set(item, data_to_be_modified)

    tree.write(filepath,
               encoding='UTF-8',
               xml_declaration=True)
    logging.info("End Vendor file modification")


@logged_keyword
def generate_empty_extractor_data_set(filter_criteria):
    extractor_data_set = {}
    for data in list(filter_criteria.keys()):
        extractor_data_set[data] = None
    return extractor_data_set


@logged_keyword
def extract_data_from_items(item, required_data):
    item_name = item.get('name')
    item_text = item.text
    if item_name in list(required_data.keys()):
        required_data[item_name] = item_text


@logged_keyword
def modify_data_set(item, data_to_be_modified):
    item_name = item.get('name')
    if item_name in list(data_to_be_modified.keys()):
        logging.info("Modified item %s from %s to %s" % (item_name, item.text, data_to_be_modified[item_name]))
        item.text = data_to_be_modified[item_name]
