import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import message_to_tree
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import \
    get_frames_containing_string, split_output_into_frames, get_tshark_output


def add_list_parameters_without_name_to_delta(self, dist_name, list_name, delta, *parameters):
    self.admin.append_parameter_update_to_delta(dist_name, parameter=list_name,
                                                value=[parameters],
                                                delta_id=delta)
    return


current_lua = True


def filter_pcap(pcap_file, filter='x2ap.SgNBAdditionRequestAcknowledge_element'):
    return message_to_tree(
        split_output_into_frames(
            get_tshark_output(
                pcap_file,
                ts_filter=filter
            )
        )[0]
    )


def verify_lack_of_object_in_addition_request_ack(pcap_file, object_name):
    output = filter_pcap(pcap_file) if object_name == 'eventA2' else filter_pcap(pcap_file, filter=False)
    found = get_frames_containing_string(str(object_name), output)
    assert found == []


def verify_a2_event_values(pcap_file, threshold, hysteresis, time_to_trigger):
    """
    :param pcap_file: path to pcap
    :param threshold: dict of threshold_type: threshold_value [dB]
    :param hysteresis: dict of threshold_type: hysteresis_value [dB]
    :param time_to_trigger: dict of time_to_trigger_type: time_to_trigger_value [ms]
    """
    assert ('rsrp' or 'rsrq' in threshold.keys()) and \
           ('rsrp' or 'rsrq' in hysteresis.keys()) and \
           ('rsrp' or 'rsrq' in time_to_trigger.keys()), 'Wrong dictionaries have been input'
    output = filter_pcap(pcap_file).find('eventA2')
    fixture.log_message(message=output)
    methods = []
    for key in threshold:
        methods.append(key)
    methods.sort()
    ind = 0
    for key in methods:
        threshold_value = output[ind]['val']('a2-Threshold: *')[str(key)]
        fixture.log_message(message='threshold: ' + threshold_value
                                    + '(should be: ' + str(threshold[key]) + ')')
        hysteresis_value = output[ind]['val']['hysteresis']
        fixture.log_message(message='hysteresis: ' + hysteresis_value
                                    + '(should be: ' + str(hysteresis[key]) + ')')
        time_to_trigger_value = output[ind]['val']('timeToTrigger')
        fixture.log_message(message='Time To Trigger: ' + time_to_trigger_value
                                    + '(should be: ' + str(time_to_trigger[key]) + ')')
        assert (str(threshold[key]) in str(threshold_value)) and \
               (str(hysteresis[key]) in str(hysteresis_value)) and \
               (str(time_to_trigger[key]) in str(time_to_trigger_value)), 'Some of the parameters\' values are ' \
                                                                          'not as expected'
        ind = ind + 1


def find_sgnbrelease_cause_in_pcap(pcap_file, event_nr='eventA2'):
    event_number = str('eventId: ' + event_nr + '*')
    fixture.log_message(message='event number:' + event_number)
    meas_report = filter_pcap(pcap_file, filter='nr-rrc.measurementReport_element').find('measId')
    meas_id = meas_report[0]['val']
    fixture.log_message(message='meas_id:' + meas_id)
    events_list = filter_pcap(pcap_file, filter='x2ap.SgNBAdditionRequestAcknowledge_element')\
        .find('reportConfigToAddModList*')
    events = events_list[0]['val'].find('reportConfigId')
    fixture.log_message(message='events:' + str(events))
    for x in [item for item in events if item['val'] == meas_id]:
        fixture.log_message(message='event id:' + str(x['val']))
        return True
    raise AssertionError("The triggered event Id wasn't" + event_nr)


def find_rrc_transfer(pcap_file, should_it_be_there=True):
    if should_it_be_there:
        rrc_transfer = filter_pcap(pcap_file, filter='nr-rrc.measurementReport_element').find('RRCTransfer')
        assert rrc_transfer
    else:
        output = get_tshark_output(pcap_file)
        frames = split_output_into_frames(output)
        assert 'RRCTransfer' not in frames


def verify_successful_handover(pcap_file, syslog_dir, phy_cell_id):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter='nr-rrc.rrcReconfiguration_element or nr-rrc.RRCReconfigurationComplete_element',
        )
        modification_required = filtered.find_next(pm('SgNBModificationRequired',
                                                      name_line_pattern='empty')
                                                   .containing('physCellId', phy_cell_id))
        assert modification_required is not None, 'Handover was not triggered to physical cell' + phy_cell_id
        modification_confirm = filtered.find_next(pm('SgNBModificationConfirm', name_line_pattern='empty'))
        assert modification_confirm is not None, 'Handover procedure could not be completed'
        messages_to_check = ['UeContextSetup done for intra-DU handover', 'Update UE context after intra-DU handover']
        for syslog in syslog_dir:
            with open(syslog, 'r') as log:
                log_read = log.read()
                if any(message in log_read for message in messages_to_check):
                    return
        raise AssertionError("No message fond in syslog")


def verify_nrrel_in_scf(scf_path, cell):
    with open(scf_path) as scf:
        return 'NRCELL-{}/NRREL'.format(cell) in scf.read()


def check_if_counters_increased(final_cts, cell_id, expected_value=1):
    """Method verifies that particular pm counters increased by 1 for the chosen cell"""
    for counter_id in final_cts:
        assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
            counter_id + "counter did not increment by 1"
