import re
import os
import string


def strip_character_newline(string1):
    output = string1.strip(' \t\n\r')
    output = string1.rstrip(' \t\n\r')
    return output


SNAP_GNB = []


def get_file_name(logfile):
    f = open(logfile, 'r')
    for line in f:
        if "Snapshot_" in line:
            txt = line.split('/')
            snap_files_names = txt[6]
            snap_files_names = snap_files_names.rstrip()
            SNAP_GNB.append(snap_files_names)
    return SNAP_GNB
