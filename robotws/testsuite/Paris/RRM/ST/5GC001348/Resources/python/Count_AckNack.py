"""
        AUTHOR:
            Pape Diallo       pape.diallo@nokia.com

"""

import os.path
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()


def count_ackNack(tti_file):
    """
    Count the number of times each AckNack is reported by the UE thanks to tti trace event dlHarqRxDataArray
    It should assert if the tti_file is empty
    It should assert if the tti_file does not exist or cannot be opened
    :param tti_file: full path of the tti trace file to be inspected
    """
    # Assert if the file does not exist
    assert os.path.exists(tti_file), 'The file {} does not exist'.format(tti_file)

    # Open the TTI trace file
    try:
        input_file = open(tti_file, "r")
    except IOError:
        assert False, 'The file {} cannot be opened'.format(tti_file)

    # Initialise the count of AckNack reported to 0
    nb_event = 0
    ack_count = 0
    nack_count = 0
    nb_event = 0
    ack_count = 0

    # For each line of the TTI trace file
    for line in input_file:
        if ':' in line:
            head_data = line.strip().split(':')
            if head_data[0] == 'dlHarqRxDataArray':
                # If this is an event dlHarqRxDataArray, analyse the content of the line
                title_values = head_data[1].strip().split(',')
                # Increase the counter of events
                nb_event += 1
                # Increase ACK/NACK count on impair sfn with slot 19
                if int(title_values[570]) % 2 == 1:
                    if int(title_values[571]) == 19:
                        if title_values[576] == 'ACK':
                            ack_count += 1
                        else:
                            nack_count += 1
    # Close the output files
    input_file.close()

    # Assert if no dlFdSchedData event has been detected
    assert nb_event > 0, 'No dlHarqRxDataArray event has been detected in the tti trace file {}'.format(tti_file)

    # Accept 5% loss: num. nack / num. nack + num. ack
    loss = 1.0 * nack_count / (nack_count + ack_count)
    assert loss < 0.15, 'Failed: more than 15% NACK on impair sfn on slot 19'

    # Display the number of events and the results
    rob.log('{} events dlHarqRxDataArray have been detected in the file {}'.format(nb_event, tti_file), 'INFO')
    rob.log('Counters per CQI: {}'.format(nack_count), 'INFO')
    # return nack_count


def count_ackNack_V2(tti_file):
    """
    Count the number of times each AckNack is reported by the UE thanks to tti trace event dlHarqRxDataArray
    It should assert if the tti_file is empty
    It should assert if the tti_file does not exist or cannot be opened
    :param tti_file: full path of the tti trace file to be inspected
    """
    # Assert if the file does not exist
    assert os.path.exists(tti_file), 'The file {} does not exist'.format(tti_file)

    # Open the TTI trace file
    try:
        input_file = open(tti_file, "r")
    except IOError:
        assert False, 'The file {} cannot be opened'.format(tti_file)

    # Initialise the count of AckNack reported to 0
    nb_event = 0
    ack_count = 0
    nack_count = 0
    nb_event = 0
    ack_count = 0

    # For each line of the TTI trace file
    for line in input_file:
        if ':' in line:
            head_data = line.strip().split(':')
            if head_data[0] == 'dlFdSchedData':
                nb_event += 1
            if head_data[0] == 'dlHarqRxDataArray':
                # If this is an event dlHarqRxDataArray, analyse the content of the line
                title_values = head_data[1].strip().split(',')
                # Increase the counter of events
                # Increase ACK/NACK count on impair sfn with slot 19
                if int(title_values[570]) % 2 == 1:
                    if int(title_values[571]) == 19:
                        if title_values[576] == 'ACK':
                            ack_count += 1
                        else:
                            nack_count += 1
    # Close the output files
    input_file.close()

    rob.log('nb_event={}'.format(nb_event))

    # Assert if no dlFdSchedData event has been detected
    assert nb_event > 6756, 'No enough dlFdSchedData event has been detected in the tti trace file {}'.format(tti_file)
    assert ack_count > 0, 'Failed: no ACK on impair sfn on slot 19'
