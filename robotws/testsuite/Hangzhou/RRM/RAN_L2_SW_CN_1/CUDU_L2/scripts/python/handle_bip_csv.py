# -*- coding: utf-8 -*-
import csv
import os


def split_column(row, column_name, new_columns):
    if column_name in row and row[column_name]:
        values = row[column_name].split(',')
        row[new_columns[0]], row[new_columns[1]] = (values + [''])[:2]
    else:
        row[new_columns[0]], row[new_columns[1]] = '', ''


def split_bip_csv(csv_filename):
    # Split the filename into name and extension
    name, extension = csv_filename.split(".")
    src_file = csv_filename
    dst_file = name + '_backup.csv'

    # Copy the source file to a backup file
    with open(src_file, 'r', newline='', encoding='utf-8') as src, open(dst_file, 'w', newline='',
                                                                        encoding='utf-8') as dst:
        dst.write(src.read())

    with open(dst_file, mode='r', newline='', encoding='utf-8') as infile, \
            open(csv_filename, mode='w', newline='', encoding='utf-8') as outfile:

        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames

        if '3gpp.sfn' not in fieldnames and '3gpp.slot' not in fieldnames:
            infile.seek(0)
            outfile.write(infile.read())
            print(f"Columns '3gpp.sfn' and '3gpp.slot' do not exist in the CSV file.")
            return

        if '3gpp.sfn' in fieldnames and '3gpp.slot' not in fieldnames:
            fieldnames = [col for col in fieldnames if col != '3gpp.sfn'] + ['3gpp.sfn', '3gpp.sfn_2']
        elif '3gpp.slot' in fieldnames and '3gpp.sfn' not in fieldnames:
            fieldnames = [col for col in fieldnames if col != '3gpp.slot'] + ['3gpp.slot', '3gpp.slot_2']
        else:
            fieldnames = [col for col in fieldnames if col not in ['3gpp.sfn', '3gpp.slot']] + ['3gpp.sfn',
                                                                                                '3gpp.sfn_2',
                                                                                                '3gpp.slot',
                                                                                                '3gpp.slot_2']

        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()

        for row in reader:

            if '3gpp.sfn' in fieldnames:
                split_column(row, '3gpp.sfn', ['3gpp.sfn', '3gpp.sfn_2'])
            if '3gpp.slot' in fieldnames:
                split_column(row, '3gpp.slot', ['3gpp.slot', '3gpp.slot_2'])

            writer.writerow(row)

# split_bip_csv('bip_check_pdsch.csv')
