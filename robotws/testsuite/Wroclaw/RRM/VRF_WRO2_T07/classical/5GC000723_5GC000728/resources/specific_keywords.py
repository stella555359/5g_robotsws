import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import message_to_tree
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import get_all_frames
from testsuite.Wroclaw.RRM.resources.log.log import blog
from datetime import datetime, timedelta
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi


scf_params_H_1 = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '100'}

scf_params_H_2 = {'cellBarred': 'notBarred', 'actSACallProcessingDU': 'false'}

scf_params_AF_2 = {'srbInactivityTimerSA': '200', 'drbInactivityTimerSA': '300'}

scf_params_AF_5 = {'srbInactivityTimerSA': '200', 'drbInactivityTimerSA': '300'}

scf_params_B_2 = {'srbInactivityTimerSA': '100', 'drbInactivityTimerSA': '300'}

scf_params_B_3 = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '240'}

scf_params_F_1 = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '100'}

scf_params_F_2 = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '100'}

scf_params_F_3 = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '100'}

scf_params_pm_counters = {'srbInactivityTimerSA': '60', 'drbInactivityTimerSA': '120'}

scf_params_E_2 = {'raContentionResolutionTmr': 'sf64', 'actSACallProcessingDU': 'true'}


@fixture.logged_keyword
def get_value_from_active_cell(counter_value):
    # sometimes input is iterable and sometimes its single number
    if isinstance(counter_value, tuple):
        # only one element(cell) should have non zero value
        counter_val = max(counter_value[0])
        counter_sum = sum(counter_value[0])
        assert counter_val == counter_sum
        return counter_val
    return counter_value


def get_cell_ids(pcap_file):
    pcap_file = pcap_file if pcap_file is not None else fixture.get_default_pcap_filepath()
    relevant_frames = get_all_frames(
        pcap_file=pcap_file,
        lua_attached=None,
        ts_filter='f1ap.F1AP_PDU == 0')
    cells = []
    for frame in relevant_frames:
        tree = message_to_tree(frame)
        nr_cells = tree.find('nRCellIdentity*').filter(['*GNBDUConfigurationUpdate*', 'nRCGI'])
        phys_cells = tree.find('physCellId*').filter('*GNBDUConfigurationUpdate*')
        for nr, phys in zip(nr_cells, phys_cells):
            nr_cell_id = int(nr['val'].split('[')[0].strip()[:-1], 16)
            if not any(cell['nr_identity'] == nr_cell_id for cell in cells):
                cell_info = {'nr_identity': nr_cell_id,
                             'physical_id': phys['val'].strip()}
                cells.append(cell_info)
    return cells


def get_time_from_pcap(pcap_path, index=0):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_path,
            lua=None,
            shark_filter='ngap.radioNetwork == 20',
            # ts_output_data_file_path=communication_pcap,
            # clean_up_tmp_file=True
            # clean_up_tmp_file=False
        )
        mesg_time_1 = finder.find_all(pm('UEContextReleaseRequest', name_line_pattern='empty'))
        assert mesg_time_1 is not None, 'Message ngap.UEContextReleaseRequest not found with cause user-inactivity'
        time = mesg_time_1[int(index)].find('Arrival Time')[0]['val']
        time = time.split(' ')[-2].split('.')[0]
        return time


def return_timedelta(time1, time2):
    dt_time1 = datetime.strptime(time1.strip(), '%X')
    dt_time2 = datetime.strptime(time2, '%X')
    diff = dt_time2 - dt_time1
    blog("Time diff: ", diff)
    return diff


def compare_timedelta_and_inactivity_timer_with_deviation(delta, timer, deviation):
    low_val = int(timer) - int(deviation)
    hi_val = int(timer) + int(deviation)
    low_val = timedelta(seconds=low_val)
    hi_val = timedelta(seconds=hi_val)
    assert hi_val >= delta >= low_val, '{} >= {} >= {}'.format(str(hi_val), str(delta), str(low_val))


def analyze_reattach_from_log_given_log(pcap_file):
    ts_filter = "f1ap.UEContextReleaseCommand_element or " \
                "f1ap.UEContextReleaseComplete_element or " \
                "ngap.UEContextReleaseCommand_element or " \
                "ngap.InitialUEMessage_element or " \
                "ngap.InitialContextSetupRequest_element or " \
                "ngap.InitialContextSetupResponse_element"

    with LogHelper() as lh:
        msgs = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=ts_filter,
            clean_up_tmp_file=True
        )
        check_next_msg_exists(msgs, 'UEContextReleaseCommand', 'ngap')
        check_next_msg_exists(msgs, 'UEContextReleaseCommand', 'f1ap')
        check_next_msg_exists(msgs, 'UEContextReleaseComplete', 'f1ap')

        check_next_msg_exists(msgs, 'InitialUEMessage', 'ngap')
        check_next_msg_exists(msgs, 'InitialContextSetupRequest', 'ngap')
        check_next_msg_exists(msgs, 'InitialContextSetupResponse', 'ngap')


def analyze_detach_from_log_given_log(pcap_file):
    ts_filter = "f1ap.UEContextReleaseCommand_element or " \
                "f1ap.UEContextReleaseComplete_element or " \
                "ngap.UEContextReleaseCommand_element"

    with LogHelper() as lh:
        msgs = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=ts_filter,
            clean_up_tmp_file=True
        )
        check_next_msg_exists(msgs, 'UEContextReleaseCommand', 'ngap')
        check_next_msg_exists(msgs, 'UEContextReleaseCommand', 'f1ap')
        check_next_msg_exists(msgs, 'UEContextReleaseComplete', 'f1ap')


def check_next_msg_exists(msgs, msg_name, protocol):
    assert msgs.find_next(
        pm(msg_name, name_line_pattern='empty')) is not None, \
        'Message {p}.{m} not found'.format(p=protocol, m=msg_name)


@fixture.logged_keyword
def verify_cellbarred_in_mib_information(l1l2_pcap, field_name='nr-rrc.cellBarred'):
    barringstatus_to_int = {'barred': 0, 'unbarred': 1}
    mib_barringstatus_to_str = {0: 'barred', 1: 'notBarred'}
    with AdminApi() as web_api:
        barringStatus = list(set([cell['status']['barringStatus'] for cell in web_api.get_cells_info()]))
        assert len(barringStatus) == 1, 'Cells have different barringStatus'
    output = TSharkCommandAssembler()\
        .with_pcap_file(l1l2_pcap)\
        .with_filter(field_name)\
        .inject_additional_parameters('-T fields -e {}'.format(field_name))\
        .build()
    output = remove_luashark_loading_from_output(output)
    assert len(output), "{} logs not found in {}.".format(field_name, l1l2_pcap)
    cell_barred = list(set(output))
    fixture.log_message(message="celBarred values = {}".format(cell_barred))
    assert len(cell_barred) == 1, "Not all callBarred values are as expected"
    assert int(cell_barred[0]) != int(barringstatus_to_int[barringStatus[0]]), fixture.assert_equal_msg.format(
        message="cellBarred values should be different",
        p1_name="Value from L1L2 log",
        p1_value="{}({})".format(int(cell_barred[0]), mib_barringstatus_to_str[int(cell_barred[0])]),
        p2_name="Value from WebEM",
        p2_value="{}({})".format(int(barringstatus_to_int[barringStatus[0]]), barringStatus[0]))
