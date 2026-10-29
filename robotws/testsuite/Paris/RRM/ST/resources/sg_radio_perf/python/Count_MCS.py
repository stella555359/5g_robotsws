"""
        Keywords Purpose:
            Keywords to count the MCS used in the TTI Traces
        AUTHOR:
            Yves Gorjux       yves.gorjux@nokia.com
        HISTORY:
            30-Jan-2020:    This version offers a new keyword that is able to look for UL or DL MCS.
                            The previous keyword count_mcs_dl is still supported.

"""

import os.path
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()


def count_mcs(tti_file, direction):
    """
    Count the number of times each MCS is used thanks to tti trace event dlFdSchedData or ulFdSchedData
    it should assert if the direction is not equal to 'UL' or 'DL'
    It should assert if the tti_file is empty
    It should assert if the tti_file does not exist or cannot be opened
    :param tti_file: full path of the tti trace file to be inspected
    :param direction: DL or UL
    """
    # Assert if the file does not exist
    assert os.path.exists(tti_file), 'The file {} does not exist'.format(tti_file)
    # Assert if there is an error in the direction
    assert direction in ('UL', 'DL'), 'Direction shall be "UL" ot "DL". {} is unexpected'.format(direction)

    input_file = open(tti_file, "r")

    # Initialise fields to use:
    if direction == 'DL':
        field_event = 'dlFdSchedData'
        field_1st_trans = 'txNumber'
        field_mcs = 'rrmDlUsedMcs'
    elif direction == 'UL':
        field_event = 'ulFdSchedData'
        field_1st_trans = 'txNumber'
        field_mcs = 'rrmUlUsedMcs'

    # Initialise the count of MCS used to 0
    nb_event = 0
    nb_first = 0
    mcs_count = 29 * [0]

    # For each line of the TTI trace file
    for line in input_file:
        if ':' in line:
            head_data = line.strip().split(':')
            if head_data[0] == field_event:
                # If this is an event dlFdSchedData, analyse the content of the line
                title_values = head_data[1].strip().split(',')
                dico = {}
                offset_values = len(title_values) // 2
                for i in range(offset_values):
                    dico[title_values[i]] = title_values[offset_values + i]
                # Increase the counter of events
                nb_event += 1
                # Check if this record is related to a first transmission
                if int(dico[field_1st_trans]) == 1:
                    nb_first += 1
                    mcs_count[int(dico[field_mcs])] += 1

    # Close the output files
    input_file.close()

    # Assert if no dlFdSchedData event has been detected
    assert nb_event > 0, 'No {} event has been detected in the tti trace file {}'.format(field_event, tti_file)

    # Display the number of events and the results
    rob.log('{} events have been detected in the file {}'.format(nb_event, tti_file), 'INFO')
    rob.log('{} first transmission have been detected in the file {}'.format(nb_first, tti_file), 'INFO')
    rob.log('Counters per MCS: {}'.format(mcs_count), 'INFO')

    return mcs_count


def count_mcs_dl(tti_file):
    return count_mcs(tti_file, 'DL')
