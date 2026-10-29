import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm


d_bwp_prof_identifiers = {
    15: {5: 25, 10: 52, 15: 79, 20: 106, 25: 133, 30: 160, 40: 216, 50: 270},
    30: {5: 11, 10: 24, 15: 38, 20: 51, 25: 65, 30: 78, 40: 106, 50: 133, 60: 162,
         70: 189, 80: 217, 90: 245, 100: 273}
}


def load_logs_with_luashark(pcap_file_location, pcap_filter):
    tshark = TSharkCommandAssembler()
    output = tshark.with_attached_lua_scripts() \
        .with_filter(pcap_filter) \
        .with_pcap_file(pcap_file_location) \
        .build()
    return ''.join(output)


def activate_multiple_BWPs(value, abbreviation='actMultipleDedicatedBWPs'):
    distname = 'MRBTS-{}/NRBTS-{}'.format(
        fixture.get_robot_variable('${mrbts_id}'), fixture.get_robot_variable('${nrbts_id}'))
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name=distname,
                                               parameter=abbreviation,
                                               operation='update',
                                               value=value)


def check_CA(pcap_file, num_of_cells):
    ca_filter = 'nr-rrc.sCellToAddModList == ' + num_of_cells
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=ca_filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    scell = filtered.find_all_anew(pm('SCellConfig', name_line_pattern='empty'))
    assert scell, 'no SCell added'


def Verify_Pcell_dedicated_channel_bandwidth_for_NSA(pcap_file, PC_physCellId=None, PC_FreqBandIndicatorNR=None,
                                                     PC_carrierBandwidth=None, SC_physCellId=None,
                                                     SC_FreqBandIndicatorNR=None, SC_carrierBandwidth=None):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter='x2ap.SgNBAdditionRequestAcknowledge_element',
            ts_output_data_file_path=None,
            clean_up_tmp_file=False
        )
    Pcell_subtree = 'SgNBAdditionRequestAcknowledge'
    Scell_subtree = 'sCellToAddModList'
    Pcell_physceCellId = filtered.find_next(pm('{}'.format(Pcell_subtree), name_line_pattern='empty')
                                            .containing('{}'.format(PC_physCellId)))
    assert Pcell_physceCellId is not None, 'Wrong phycCellId for Pcell'
    Pcell_FreqBandIndicatorNR = filtered.find_one(pm('{}'.format(Pcell_subtree), name_line_pattern='empty')
                                                  .containing('FreqBandIndicatorNR', '*{}*'
                                                              .format(PC_FreqBandIndicatorNR)))
    assert Pcell_FreqBandIndicatorNR is not None, 'Wrong band for Pcell'
    Pcell_carrierBandwidth = filtered.find_one(pm('{}'.format(Pcell_subtree), name_line_pattern='empty')
                                               .containing('carrierBandwidth', '*{}*'.format(PC_carrierBandwidth)))
    assert Pcell_carrierBandwidth is not None, 'wrong carrier bandwidth for Pcell'

    Scell_physceCellId = filtered.find_next(pm('{}'.format(Scell_subtree), name_line_pattern='empty')
                                            .containing('{}'.format(SC_physCellId)))
    assert Scell_physceCellId is not None, 'Wrong phycCellId for Scell'
    Scell_FreqBandIndicatorNR = filtered.find_one(pm('{}'.format(Scell_subtree), name_line_pattern='empty')
                                                  .containing('FreqBandIndicatorNR', '*{}*'
                                                              .format(SC_FreqBandIndicatorNR)))
    assert Scell_FreqBandIndicatorNR is not None, 'Wrong band for Scell'
    Scell_carrierBandwidth = filtered.find_one(pm('{}'.format(Scell_subtree), name_line_pattern='empty')
                                               .containing('carrierBandwidth', '*{}*'.format(SC_carrierBandwidth)))
    assert Scell_carrierBandwidth is not None, 'wrong carrier bandwidth for Scell'


def verify_Pcell_dedicated_channel_bandwidth_for_SA(pcap_file, freqBand_nrofRBs=None, resource_mapping=None):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter='(f1ap.procedureCode == 7) && (nr-rrc.nrofRBs) && !(nr-rrc.scramblingID == 105)',
            ts_output_data_file_path=None,
            clean_up_tmp_file=False
        )
    nrofRBs_exp = filtered.find_one(pm('{}'.format('UEContextModificationResponse'), name_line_pattern='empty')
                                    .containing('nrofRBs', '*{}*'.format(freqBand_nrofRBs)))
    assert nrofRBs_exp is not None, 'Wrong number of Pcell resource blocks, expected: {}'.format(freqBand_nrofRBs)
    scramblingID_exp = filtered.find_one(pm('{}'.format('UEContextModificationResponse'), name_line_pattern='empty')
                                         .containing('scramblingID', '*{}*'.format(resource_mapping)))
    assert scramblingID_exp is not None, 'Wrong number of Pcell, expected Pcell ID: {}'.format(resource_mapping)
