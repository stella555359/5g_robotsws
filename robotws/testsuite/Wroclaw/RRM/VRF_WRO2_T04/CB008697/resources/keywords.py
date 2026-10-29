from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
import re
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper


def verify_CA(pcap_file, num_of_cells):
    ca_filter = 'nr-rrc.sCellToAddModList == ' + num_of_cells
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=ca_filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    scell = filtered.find_all_anew(pm('SCellConfig', name_line_pattern='empty'))
    assert scell, 'no SCell added'


def switch_scell_addition_method(nrcellId, nrrelation, operation='update', pname='covBasedA1',
                                 parameter='sCellAdditionMethod'):
    distname = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'), nrcellId, nrrelation)
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=distname,
                                               parameter=parameter,
                                               operation=operation,
                                               value=pname)


def Add_paraeter_Scell_Addition_method_per_cell(nrcellId, nrrelation, operation='update'):
    param_A1meas_object = add_parameters_for_A1_meas()
    distname = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'), nrcellId, nrrelation)
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_object_recommissioning(dist_name=distname,
                                            parameter=param_A1meas_object,
                                            operation=operation,
                                            skip_parameter_relation_errors=False)


def Del_paraeter_Scell_Addition_method_per_cell(nrcellId, nrrelation, operation='update'):
    param_A1meas_object = dell_parameters_for_A1_meas()
    distname = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'), nrcellId, nrrelation)
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_object_recommissioning(dist_name=distname,
                                            parameter=param_A1meas_object,
                                            operation=operation,
                                            skip_parameter_relation_errors=False)


def add_parameters_for_A1_meas():
    return [
            {
                "parameterName": "sCellAdditionMethod",
                "operation": "update",
                "value": "covBasedA1"
            },
            {
                "parameterName": "sCellOperationalMode",
                "operation": "update",
                "value": "dlOnly"
            }
    ]


def dell_parameters_for_A1_meas():
    return [
            {
                "parameterName": "sCellAdditionMethod",
                "operation": "delete",
                "value": ""
            },
            {
                "parameterName": "sCellOperationalMode",
                "operation": "delete",
                "value": "dlOnly"
            }
    ]


def activate_Overheating_Assistance(value, abbreviation='actOverheatingAssistance'):
    distname = 'MRBTS-{}/NRBTS-{}'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'))
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=distname,
                                               parameter=abbreviation,
                                               operation='update',
                                               value=value)


def verify_OAI_in_nrrrc_messages(pcap_file, OAI=None, expected_CCsDL=None, expected_CCsUL=None,
                                 message='UEContextModificationRequest'):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter='f1ap || nr-rrc',
            ts_output_data_file_path=None,
            clean_up_tmp_file=False
        )
    message_OAI = filtered.find_next(pm('{}'.format(message), name_line_pattern='empty')
                                     .containing('{}'.format(OAI)))
    assert message_OAI is not None, 'there is no OAI information from UE'
    if expected_CCsDL is not None:
        message_CCsDL = filtered.find_one(pm('{}'.format(message), name_line_pattern='empty')
                                          .containing('reducedCCsDL-r16', '*{}*'.format(expected_CCsDL)))
        assert message_CCsDL is not None, 'There is no reducedCCs DL value'
        message_CCsUL = filtered.find_one(pm('{}'.format(message), name_line_pattern='empty')
                                          .containing('reducedCCsUL-r16', '*{}*'.format(expected_CCsUL)))
        assert message_CCsUL is not None, 'There is no reducedCCs UL value'


def verify_if_average_throughput_with_deviation_reached(deviation, expected_tput=None, average_tput=None):
    expected_tput = re.split('m|M', expected_tput)[0]
    average_tput = re.split('m|M', average_tput)[0]
    deviation_as_float = parse_deviation(deviation)
    min_threshold = int(expected_tput) - (int(expected_tput) * deviation_as_float)
    max_threshold = int(expected_tput) + (int(expected_tput) * deviation_as_float)
    print('After deviation value minimum expected tput: {} Mbits/s, and should be around maximum: {} Mbits/s'
          .format(min_threshold, max_threshold))
    assert int(min_threshold) < int(average_tput) and int(average_tput) < int(max_threshold), \
        'Average throughput for UE: not in expected range! ' \
        'Current tput: {} Mbits/s, with expected deviation MIN: {} Mbits/s and MAX {} Mbits/s'.format(average_tput,
                                                                                                      min_threshold,
                                                                                                      max_threshold)


def parse_deviation(unparsed_deviation):
    number = unparsed_deviation.rstrip('%')
    deviation = float(number) / 100.0
    return deviation
