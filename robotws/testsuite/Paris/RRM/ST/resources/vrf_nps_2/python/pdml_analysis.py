#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
Helpful library to analyse PDML files
"""

import os
import csv
from lxml import etree as ET
import logging


def get_attribute_value(packet_element, attrib_name, attrib_value):
    try:
        return packet_element.xpath(f"//proto[@name='frame']/field[@name='{attrib_name}']/@{attrib_value}")[0]
    except Exception as e:
        logging.debug('Error occurred:', e)
    return None


def get_pcmd_value(packet_element, protocol_name, pcmd_name, attrib_value="show"):
    try:
        # Find the field element with the specified name
        pcmd_value = packet_element.xpath(
            f"//proto[@name='nsetapx']//field[@name='{protocol_name}']//field[@name='{pcmd_name}']/@{attrib_value}"
        )
        if pcmd_value:
            return pcmd_value[0]
    except Exception as e:
        logging.debug('Error occurred:', e)
    return None


def extract_data_from_pdml_to_csv(file_path, protocol_name, *pcmd_names):
    logging.info(f'extracting data from pdml file {file_path}')
    output_csvfile, extension = os.path.splitext(os.path.basename(file_path))
    output_csvfile = os.path.join(os.path.dirname(file_path), f"{protocol_name}_{output_csvfile}.csv")
    columns = ['frame', 'timestamp', *pcmd_names]
    context = ET.iterparse(file_path, events=('end',), tag='packet')
    with open(output_csvfile, 'w', newline='', encoding='utf-8') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter='\t')
        # Write the header row
        csvwriter.writerow(columns)  # Adjust columns as needed
        for event, packet_element in context:
            # Process the element
            framenum = get_attribute_value(packet_element, "frame.number", "show")
            timestamp = get_attribute_value(packet_element, "frame.time", "show")
            pcmd_values = [
                get_pcmd_value(packet_element, protocol_name, pcmd_name, "show") for pcmd_name in pcmd_names
            ]
            # Write the data to the CSV file
            csvwriter.writerow([framenum, timestamp, *pcmd_values])
            # Clear the element to free memory
            packet_element.clear()
            while packet_element.getprevious() is not None:
                del packet_element.getparent()[0]
            logging.info(f'extraction done succesffuly output file {output_csvfile}')


def filter_csv(filename, column_name, filter_expression="value and value != '0' and value != '0.0'"):
    """Filters a CSV file based on a column and a dynamic filter expression.

  Args:
    filename: The path to the CSV file.
    column_name: The name of the column to filter.
    filter_expression: A string representing the filter expression.
      - Should be a valid Python expression that evaluates to True or False.
      - The column value will be available as the variable `value`.
      - Example: "value != '0'" or "value != 0 and value != 0.0"

  Returns:
    A list of representing the filtered rows.
  """

    filtered_rows = []
    with open(filename, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter='\t')  # Specify tab delimiter
        for row in reader:
            value = row[column_name]
            if eval(filter_expression):  # Evaluate the filter expression
                filtered_rows.append(row[column_name])
    return filtered_rows


if __name__ == '__main__':
    """
    extract_data_from_pdml_to_csv(
        "/home/ute/Téléchargements/nsetapx_dlRbRlcMeasRecord_numOfRlcPduTx.pdml",
        'nsetapx.dlRbRlcMeasRecord',
        'nsetapx.numOfRlcPduTx',
        'nsetapx.numOfPrbsUsed', "nsetapx.timeOfUeSchedMimo", "nsetapx.sumOfMcsIndexes", "nsetapx.sumOfMacPduTxTime",
        "nsetapx.sumOfInitTxTime", "nsetapx.numOfInitTxSamples"
    )
    """
    filename = '/home/ute/projects/debug/traffic_data/pdmd_report.csv'
    for column_name in ['nsetapx.numOfPrbsUsed', 'nsetapx.timeOfUeSchedMimo', 'nsetapx.sumOfMcsIndexes',
                        'nsetapx.numOfInitTxSamples']:
        filtred_column = filter_csv(filename, column_name)
        print(column_name, len(filtred_column))
        print(filtred_column)
    for column_name in ['nsetapx.sumOfMacPduTxTime', 'nsetapx.sumOfInitTxTime']:
        filtred_column = filter_csv(filename, column_name,
                                    filter_expression="value and value != '00:00:00:00:00:00:00:00'")
        print(column_name, len(filtred_column))
        print(filtred_column)
