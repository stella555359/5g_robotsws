"""
        Keywords Purpose:
            Keywords to read the content of laIniDelta event in the TTI Traces

        AUTHOR:
            Bella chen

"""

import os.path
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()


def read_lainidelta(tti_file):
    """
    Read the values of fieldq : id / event / update / iniDelta in tti trace event laIniDelta
        id : INI_DELTA_CQI or INI_DELTA_SINR
        event : UPDATE or SKIP
    It should assert if the tti_file is empty
    It should assert if the tti_file does not exist or cannot be opened
    :param tti_file: full path of the tti trace file to be inspected
    """
    assert os.path.exists(tti_file), 'The file {} does not exist'.format(tti_file)

    input_file = open(tti_file, "r")

    nb_event = 0

    for line in input_file:
        if ':' in line:
            head_data = line.strip().split(':')
            if head_data[0] == 'laIniDelta':
                title_values = head_data[1].strip().split(',')
                dico = {}
                offset_values = len(title_values) // 2
                for i in range(offset_values):
                    dico[title_values[i]] = title_values[offset_values + i]
                nb_event += 1

    input_file.close()

    assert nb_event > 0, 'No laIniDelta event has been detected in the tti trace file {}'.format(tti_file)

    rob.log('{} event has been detected in the file {}'.format(nb_event, tti_file), 'INFO')
    rob.log('Content of laIniDelta event : {}'.format(dico), 'INFO')

    return dico
