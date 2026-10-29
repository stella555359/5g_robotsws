import shutil
import simplejson
from robot.api import logger
import csv
import logging
from robot.libraries.BuiltIn import BuiltIn

ROBOT_LIBRARY_SCOPE = 'TEST'


def verify_proactive_scheduling(present=True):
    """
    Verify that 'ENTRYPROACTIVEPUSCH' value occurred in column ulFdSchedData.ulProGrantType.
    :param:
    -expected_number - expected number of lines with ENTRYPROACTIVEPUSCH in TTI.
    :return:
    """
    column = 'ulFdSchedData.ulProGrantType'
    tti_data = _create_list_from_tti_trace_csv()
    if 'ulFdSchedData.ulProGrantType' in tti_data[0]:
        cslistevent_column = _create_list_from_column(tti_data, column)
        number_of_proactive = cslistevent_column.count('NONSKIPPABLE')
        logging.info('Number of NONSKIPPABLE found in {}: {}'.format(column, number_of_proactive))
        if present:
            assert number_of_proactive > 0, \
                'There was {} lines with {} in column {}.'.format(number_of_proactive, "NONSKIPPABLE", column)
        else:
            number_of_proactive = cslistevent_column.count('DISABLED')
            logging.info('Number of DISABLED found in {}: {}'.format(column, number_of_proactive))
            assert number_of_proactive > 0, \
                ' There are no ulProGrantType information in TTI logs'


def verify_number_of_retransmissions(expected_number=0):
    """
    Verify that 'ENTRYPROACTIVEPUSCH' value occurred in column ulPreSchedData.csListEvent.
    :param:
    -expected_number - expected number of lines with ENTRYPROACTIVEPUSCH in TTI.
    :return:
    """
    tti_data = _create_list_from_tti_trace_csv()
    cslistevent_column = _create_list_from_column(tti_data, 'ulPreSchedData.csListEvent')
    number_of_msg3retx = cslistevent_column.count('ENTRYMSG3RETX')
    logging.info('Number of ENTRYMSG3RETX found in ulPreSchedData.csListEvent: {}'.format(number_of_msg3retx))
    assert number_of_msg3retx == expected_number, \
        'There was {} lines with {} in column {}, but should be {}.'.format(number_of_msg3retx, "ENTRYMSG3RETX",
                                                                            "csListEvent", expected_number)


def _create_list_from_tti_trace_csv():
    output_dir = BuiltIn().get_variable_value("${OUTPUTDIR}")
    test_name = BuiltIn().get_variable_value("${TEST NAME}")

    file_name = 'output_ul.csv'
    csv_path = str(output_dir) + '/' + str(test_name) + '/' + file_name

    try:
        tti_trace_ul = open(csv_path)
    except IOError:
        raise Exception("TTI Trace file {} not found".format(csv_path))
    csv_list = list(csv.reader(tti_trace_ul))
    return csv_list


def _create_list_from_column(tti_trace_list, column_name):
    sr_column_index = tti_trace_list[0].index(column_name)
    list_from_single_column = [row[sr_column_index] for row in tti_trace_list]
    return list_from_single_column


def verify_that_values_in_given_column_exceeds_expected(ue_crnti, directory, expected_value, column, eventName,
                                                        threshold=100):
    """
    Verify the ratio of lines with equal or greater values in the given column to all lines for that UE.
    :param:
    -ue_crnti - radio network temporary identifier,
    -directory - folder where TTI Traces were collected,
    -expected_value - the function will check ratio of lines with equal or greater values than that value to all lines,
    -column - name of column in which values will be checked,
    -eventName - name of event where name of the column may be found,
    -throshold - got ratio should be greater that that value.
    :return:
    """
    expected = expected_value
    percentage_acceptance_threshold = threshold
    ue_tti_traces = _get_ue_tti_traces(ue_crnti=ue_crnti, directory_name=directory)
    all_values = _get_all_values_for_given_column(ue_tti_traces, column, eventName)
    assert len(all_values) > 0, "tti traces not found"
    ratio = _get_ratio_of_values_not_lower_than_expected(expected, all_values)
    logging.info('{}% of lines with values equal or grater than {}'.format(ratio, expected))
    assert ratio > float(percentage_acceptance_threshold), \
        '{}% of lines exceeded expected value {} in column {}, ' \
        'should  be at least {}%.'.format(ratio, expected_value, column, threshold)


def verify_that_values_in_given_column_does_not_exceed_expected(ue_crnti, directory, expected_value, column, eventName,
                                                                threshold=100):
    """
    Verify the ratio of lines with lower values in the given column to all lines for that UE.
    :param:
    -ue_crnti - radio network temporary identifier,
    -directory - folder where TTI Traces were collected,
    -expected_value - the function will check ratio of lines with lower values than that value to all lines,
    -column - name of column in which values will be checked,
    -eventName - name of event where name of the column may be found,
    -threshold - got ratio should be greater that that value.
    :return:
    """
    expected = expected_value
    percentage_acceptance_threshold = threshold
    ue_tti_traces = _get_ue_tti_traces(ue_crnti=ue_crnti, directory_name=directory)
    all_values = _get_all_values_for_given_column(ue_tti_traces, column, eventName)
    assert len(all_values) > 0, "tti traces not found"
    ratio = _get_ratio_of_values_lower_than_expected(expected, all_values)
    logging.info('{}% of lines with values lower than {}'.format(ratio, expected))
    assert ratio == percentage_acceptance_threshold, \
        '{}% exceeded {} value in column {}'.format(ratio, expected_value, column)


def _get_ratio_of_values_not_lower_than_expected(expected_value, all_values):
    number_of_bigger_values = len(list(filter(lambda x: x >= expected_value, all_values)))
    ratio = round((float(number_of_bigger_values) / len(all_values)) * 100, 4)
    logger.info("For expected value={} ratio: {}".format(expected_value, ratio))
    return ratio


def _get_ratio_of_values_lower_than_expected(expected_value, all_values):
    number_of_lower_values = len(list(filter(lambda x: x < expected_value, all_values)))
    ratio = round((float(number_of_lower_values) / len(all_values)) * 100, 2)
    logger.info("For expected value={} ratio: {}".format(expected_value, ratio))
    return ratio


def _get_all_values_for_given_column(tti_traces, column, eventName):
    indexes = [event[eventName]['body'][column]
               for event in tti_traces['events']
               if eventName in event.keys()]
    logger.info("Values for column {}: {}".format(column, indexes))
    return indexes


def _filter_out_rows_for_ue(ue_crnti, tti_traces):
    print(type(tti_traces))
    ue_tti_traces = [event for event in tti_traces['events']
                     if 'eventHeader' in list(event.values())[0]['body']
                     and list(event.values())[0]['body']['eventHeader']['rnti'] == ue_crnti]
    return {"events": ue_tti_traces}


def _fix_json_and_decode(tti_json_path):
    _fix_nan_values_in_json(tti_json_path)
    with open(tti_json_path) as tti:
        tti_traces = simplejson.load(tti)
    return tti_traces


def _fix_nan_values_in_json(tti_json):
    with open(tti_json) as tti:
        with open('tmp', 'w') as tmp:
            tti_content = tti.read()
            corrected_tti_content = tti_content.replace(":-nan", ':\"-nan\"') \
                .replace(":nan", ':\"nan\"') \
                .replace("[nan", '[\"nan\"') \
                .replace("nan]", '\"nan\"]')
            tmp.write(corrected_tti_content)
    shutil.move('tmp', tti_json)


def _get_tti_json_path(directory):
    return "/".join([BuiltIn().get_variable_value("${OUTPUTDIR}"),
                     BuiltIn().get_variable_value("${TESTNAME}"),
                     "output.json"])


def _get_ue_tti_traces(ue_crnti, directory_name):
    tti_json_path = _get_tti_json_path(directory_name)
    all_tti_traces = _fix_json_and_decode(tti_json_path)
    ue_tti_traces = _filter_out_rows_for_ue(ue_crnti=ue_crnti, tti_traces=all_tti_traces)
    return ue_tti_traces
