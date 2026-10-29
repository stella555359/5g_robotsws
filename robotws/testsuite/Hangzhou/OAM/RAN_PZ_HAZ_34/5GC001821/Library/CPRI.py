import re
import csv
import os
import logging


def get_cpri_link_final_status(cpri_report):
    cpri_lines = cpri_report.splitlines()
    cpri_result = {}
    for cpri_status in cpri_lines:
        bbmod_info = re.findall("BBMOD_\\w-(\\d+)/", cpri_status)
        if not bbmod_info:
            continue
        bbmod = bbmod_info[0]
        link_info = re.findall("link: (\\d+) with state: ([^\\s,^\\(]+)", cpri_status)
        link = link_info[0][0]
        state = link_info[0][1]
        if bbmod in cpri_result.keys():
            cpri_result[bbmod].update({link: state})
        else:
            cpri_result[bbmod] = {link: state}
    return cpri_result


def get_qc_ins_id(file_name, search_key, case_key):
    # location = os.path.split(os.path.abspath(__file__))[0]
    # file_name = os.path.join(location, "./%s_%s.csv" % (bbmod_type, link_type))
    with open(file_name, "r") as fp:
        ins_dict = csv.DictReader(fp)
        for key in ins_dict:
            logging.info(key)
            if key['\xef\xbb\xbfkey'] == search_key:
                return key[case_key]
    return "NA"
