import os
import re
import csv
import sys


def get_row_as_defined_str(csv_filename, str1, str2):
    with open(csv_filename)as f:
        f_csv = csv.reader(f)
        row_list = []
        for row in f_csv:
            if row:
                if row[0].encode("utf-8").decode("utf8", "ignore").find(str1) >= 0:
                    row_list.append(row)
        if row_list:
            for line in row_list:
                line_combile = ''.join(line)
                if line_combile.find(str2) >= 0:
                    return line_combile
                    break
            raise Exception("file cannot find %s!" % str2)
        else:
            raise Exception("file cannot find %s!" % str1)
