"""
This module provides functionality to append/remove KPI data from an Excel file to an XML file.

Functions:
    modify_kpi_xml_per_excel(feat_specific_xlsx: str, ltepat_release_xml: str, xml_output_path: str,
                            filter_out_kpi: bool, pgm_kpi_file: str) -> None:
        Main function to append/remove KPI data from an Excel file to an XML file.

"""
import xml.etree.ElementTree as ET

import numpy as np
import pandas as pd


def _load_excel_file(excel_path):
    df = pd.read_excel(excel_path, sheet_name='TMO Magenta KPI details')
    return df


def _preprocess_excel_kpi_data(df):
    df = df.replace(np.nan, '', regex=True)
    df['ne'] = 'NRBTS'
    df['KPI class'] = 'TMO'
    df['name'] = df['KPI ID']
    return df


def _load_xml_file(xml_path):
    tree = ET.parse(xml_path)
    return tree.getroot(), tree


def _get_dict_for_xml(excel_row):
    mapping_dict = {
        'KPI ID': 'id',
        'ne': 'ne',
        'KPI class': 'level',
        'name': 'name',
        'Logical formula': 'lformula',
        'Summarisation formula': 'formula',
        'Internal information': 'nformula',
        'Unit': 'unit',
        'Description': 'desc'
    }
    xml_attrib = {}
    for excel_param_name, xml_param_name in mapping_dict.items():
        xml_attrib[xml_param_name] = excel_row[excel_param_name]
    return xml_attrib


def _postprocess_xml(new_kpi_entries):
    for index, kpi in enumerate(new_kpi_entries):
        for attrib in ['formula', 'desc', 'lformula']:
            new_kpi_entries[index][attrib] = (
                kpi[attrib].replace('SUM', '')
                .replace('Sum', '')
                .replace('sum', '')
                .replace(']', '')
                .replace('[', '')
                .replace('\n', ''))
    return new_kpi_entries


def append_excel_kpis_to_xml(excel_file_path, xml_file_path, target_path):
    """Appends the KPI data from an Excel file to an XML file.

    Args:
        excel_file_path (str): path to the excel file
        xml_file_path (str): path to the original xml file
        target_path (str, optional): Path to the generated output file, containing the data from the original xml and
                                     the excel file.
    """
    excel_df = _load_excel_file(excel_file_path)
    excel_df = _preprocess_excel_kpi_data(excel_df)
    xml_root, xml_tree = _load_xml_file(xml_file_path)
    new_kpi_entries: list = excel_df.apply(lambda row: _get_dict_for_xml(row), axis=1).to_list()
    new_kpi_entries = _postprocess_xml(new_kpi_entries)
    for entry in new_kpi_entries:
        ET.SubElement(xml_root, 'KPI', attrib=entry)
    xml_tree.write(target_path)


def remove_unwanted_kpi(allowed_kpi_list, xml_path):
    """Removes the KPI data from xml that are not present in allowed_kpi_list and writes it over the same xml

    Args:
        allowed_kpi_list (list): list of KPIs that shall not be removed.
        xml_path (str): path to the xml file
    """
    xml_root, xml_tree = _load_xml_file(xml_path)
    # Iterate over elements and remove those whose id is not in allowed_kpi_list
    for elem in xml_root.findall("KPI"):
        elem_id = elem.get("id")  # Get the id attribute
        if elem_id not in allowed_kpi_list:
            xml_root.remove(elem)
    # Save the modified XML
    xml_tree.write(xml_path)


def modify_kpi_xml_per_excel(feat_specific_xlsx, ltepat_release_xml, xml_output_path, filter_out_kpi=False,
                             pgm_kpi_file=None):
    """Appends/removes the KPI data from an Excel file to an XML file.

    Args:
        feat_specific_xlsx (str): path to the excel file -> comes from the CFAM author
        ltepat_release_xml (str): path to the original xml file -> comes with the LTEPAT installation folder
        xml_output_path (str): Path to the generated output file,  containing the data from
                                         - the original xml + excel file if filter_out_kpi = False
                                         - only the pgm_kpi_file if filter_out_kpi = true
        filter_out_kpi (bool, optional) : Filters out unwanted KPI and keeps only the KPIs from pgm_kpi_file
        pgm_kpi_file (str, optional): if filter_out_kpi=True, output will have the KPIs from pgm_kpi_file only
    """
    append_excel_kpis_to_xml(feat_specific_xlsx, ltepat_release_xml, xml_output_path)
    if filter_out_kpi:
        pgm_df = pd.read_csv(pgm_kpi_file)
        kpi_wish_list = pgm_df["KPI IDs"].to_list()
        remove_unwanted_kpi(kpi_wish_list, xml_output_path)
    print(f'Output XML: {xml_output_path}')


def _main():
    modify_kpi_xml_per_excel(r'/home/ute/DEVELOPMENT/ltepat_data/TMO_excel.xlsx',
                             r'/home/ute/DEVELOPMENT/ltepat_data/PMKPI_SBTS25R2_5G.xml',
                             xml_output_path='/home/ute/DEVELOPMENT/ltepat_data/filtered_kpi.xml',
                             filter_out_kpi=False,
                             pgm_kpi_file=r'/testsuite/Ulm/ET/CB013392/CB013392-E/configurations/'
                             r'cb013392_program_kpi_list.csv',
                             )


if __name__ == '__main__':
    _main()
