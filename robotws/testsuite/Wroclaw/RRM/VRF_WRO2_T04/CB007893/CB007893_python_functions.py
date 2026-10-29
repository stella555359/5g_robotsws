import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix


def change_a1_measurment_configuration(action, cell):
    distname = '{}/NRCELL-{}'.format(bts_prefix, cell)
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=distname,
                                               parameter='a1MeasSCellAddEnabled',
                                               operation='update',
                                               value=action)


def verify_a1(pcap_file):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter='x2ap.SgNBAdditionRequestAcknowledge_element', ts_output_data_file_path=None,
            clean_up_tmp_file=False
        )
    event_a1 = filtered.find_all(pm('eventA1', name_line_pattern='empty'))
    assert event_a1, 'no A1 event'


def verify_carier_aggregation(pcap_file, num_of_cells, phys_cells_id):
    ca_filter = 'x2ap.SgNBModificationRequired_element &&  nr-rrc.sCellToAddModList == ' + num_of_cells
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=ca_filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    scell = filtered.find_all(pm('SCellConfig', name_line_pattern='empty').containing('physCellId', phys_cells_id))
    assert scell, 'no SCell added'


def verify_measurment_report(pcap_file):
    meas_gap_filter = 'x2ap.SgNBModificationRequest_element'
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=meas_gap_filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    meas_gap = filtered.find_all(pm('measGapConfig: setup*', name_line_pattern='empty'))
    assert meas_gap, 'no measurment gap configured'
