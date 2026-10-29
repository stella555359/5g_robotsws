"""
        Keywords Purpose:
            Keywords to count the DL MCS used in the TTI Traces in DL cases

        AUTHOR:
            Yves Gorjux       yves.gorjux@nokia.com

"""

import os.path
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()


def count_cqi(tti_file):
    """
    Count the number of times each CQI is reported by the UE thanks to tti trace event dlLaAverageCqi
    It should assert if the tti_file is empty
    It should assert if the tti_file does not exist or cannot be opened
    :param tti_file: full path of the tti trace file to be inspected
    """
    # Assert if the file does not exist
    assert os.path.exists(tti_file), 'The file {} does not exist'.format(tti_file)

    input_file = open(tti_file, "r")

    # Initialise the count of CQI reported to 0
    nb_event = 0
    cqi_count = 16 * [0]

    # For each line of the TTI trace file
    for line in input_file:
        if ':' in line:
            head_data = line.strip().split(':')
            if head_data[0] == 'dlLaAverageCqi':
                # If this is an event dlLaAverageCqi, analyse the content of the line
                title_values = head_data[1].strip().split(',')
                dico = {}
                offset_values = len(title_values) // 2
                for i in range(offset_values):
                    dico[title_values[i]] = title_values[offset_values + i]
                # rob.log('{}'.format(dico), 'DEBUG')
                # Increase the counter of events
                nb_event += 1
                # Increase the count of the CQI
                cqi_count[int(dico['rrmInstCqi'])] += 1

    # Close the output files
    input_file.close()

    # Assert if no dlFdSchedData event has been detected
    assert nb_event > 0, 'No dlLaAverageCqi event has been detected in the tti trace file {}'.format(tti_file)

    # Display the number of events and the results
    rob.log('{} events dlLaAverageCqi have been detected in the file {}'.format(nb_event, tti_file), 'INFO')
    rob.log('Counters per CQI: {}'.format(cqi_count), 'INFO')

    return cqi_count
