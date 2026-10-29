"""
This module helps to parse the basic_setup.cfg and to check for all ue_ids that
are configured with mode=nr. Those ue_ids can be later on used in the keyword calls
for "ue register" and "ue deregister".
"""
import os
import re


def get_ue_simulated_lines(filename):
    """This function opens the file filename and returns all lines, that start
    with the string 'set_ue simulated'

    :param str filename: The filename to open and read
    """

    with open(filename) as fp:
        for line in fp:
            if line.startswith("set_ue simulated"):
                yield line


def get_all_ue_ids(basic_setup="/opt/iphy/latest/basic_setup.cfg"):
    """This function reads the basic_setup.cfg and returns all configured ue ids,
    which have the attribut mode=nr set

    :param str basic_setup: The path to the basic_setup.cfg file
    """
    assert os.path.exists(basic_setup), "basic_setup.cfg not present!"

    ue_ids = []

    for set_ue_string in get_ue_simulated_lines(basic_setup):
        if set_ue_string.startswith("set_ue") and "mode=nr" in set_ue_string:
            ue_ids += re.findall(r" id=(\d+) ", set_ue_string)

    return ue_ids
