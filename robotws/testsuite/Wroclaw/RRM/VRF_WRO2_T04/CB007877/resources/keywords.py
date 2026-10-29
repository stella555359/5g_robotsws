from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
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


def change_a1_measurment_configuration(action):
    distname = 'MRBTS-{}/NRBTS-{}/NRCELL-1'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'))
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=distname,
                                               parameter='a1MeasSCellAddEnabled',
                                               operation='update',
                                               value=action)


def verify_ho(pcap_file, phy_cell_id):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter='f1ap',
        )
        modification_required = filtered.find_next([pm('UEContextModificationResponse', name_line_pattern='empty')
                                                   .containing('reconfigurationWithSync')
                                                   .containing('physCellId', '*{}*'.format(phy_cell_id))])
        assert modification_required is not None, 'Handover was not triggered to physical cell' + phy_cell_id


def collect_A1_setup_from_SCF(nrcellId, parameter, listname=None, scf_path=None):
    distname = 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'), str(nrcellId))
    return fixture.webUI.get_parameter_value_from_scf(parameter_abbreviation=parameter,
                                                      path=scf_path,
                                                      parameter_dist_name=distname,
                                                      l_name=listname)


def verify_RRC_A1_event(message, filter, a1Threshold, a1hysteresis, a1TimeToTrigger, pcap_file):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    message_0 = filtered.find_next(pm('{}'.format(message), name_line_pattern='empty').containing('eventA1'))
    assert message_0 is not None, 'no A1 event'
    if filter == 'nr-rrc.eventA1_element':
        message_1 = filtered.find_one(
            pm('{}'.format(message), name_line_pattern='empty').containing('rsrp', '*{}*'.format(a1Threshold)))
        assert message_1 is not None, 'wrong rsrp threshold'
    else:
        message_1 = filtered.find_next(
            pm('{}'.format(message), name_line_pattern='empty').containing('rsrp', '*{}*'.format(a1Threshold)))
        assert message_1 is not None, 'wrong rsrp threshold'
    message_2 = filtered.find_next(pm('{}'.format(message), name_line_pattern='empty')
                                   .containing('hysteresis', '*{}*'.format(a1hysteresis)))
    assert message_2 is not None, 'wrong hysteresis'
    message_3 = filtered.find_all(pm('{}'.format(message), name_line_pattern='empty')
                                  .containing('timeToTrigger', '*{}*'.format(a1TimeToTrigger)))
    assert message_3 is not None, 'wrong timetotrigger'


def switch_scell_addition_method(nrcellId, nrrelation, operation='update', pname='covBasedA1',
                                 parameter='sCellAdditionMethod'):
    distname = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'), nrcellId, nrrelation)
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=distname,
                                               parameter=parameter,
                                               operation=operation,
                                               value=pname)


def change_parameter(action, nrcellId, parameter):
    distname = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRHOIF-1'.format(mrbts_id, nrbts_id, nrcellId)
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=distname,
                                               parameter=parameter, operation='update', value=action)
