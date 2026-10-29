from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog


CELL_PARAMETERS = {
    'CELL_n41': {'physCellId': '81', 'uplinkTxSwitchingCarrier': 'carrier2',
                 '0_uplinkTxSwitchingPeriodLocation-r16': 'False', 'TxOption': 'switchedUL',
                 'uplinkTxSwitching_2T': 'enabled'},
    'CELL_n71': {'physCellId': '50', '1_uplinkTxSwitchingPeriodLocation': 'True',
                 'uplinkTxSwitchingCarrier': 'carrier1', 'TxOption': 'switchedUL', 'uplinkTxSwitching_2T': 'enabled'},


    'PCELL_n71': {'physCellId': '50', 'maxRank': '2', '1_uplinkTxSwitchingPeriodLocation-r16': 'True',
                  'uplinkTxSwitchingCarrier': 'carrier1', 'TxOption': 'switchedUL',
                  'uplinkTxSwitching_2T': 'enabled'},

    'SCELL_n41': {'physCellId': '81', 'uplinkTxSwitchingCarrier': 'carrier2', 'maxRank': '2',
                  '0_uplinkTxSwitchingPeriodLocation-r16': 'False', 'TxOption': 'switchedUL',
                  'uplinkTxSwitching_2T': 'enabled'},

    'SCELL_n71_40': {'physCellId': '40', 'maxRank': '2', '1_uplinkTxSwitchingPeriodLocation-r16': 'True',
                     'uplinkTxSwitchingCarrier': 'carrier1', 'TxOption': 'switchedUL',
                     'uplinkTxSwitching_2T': 'enabled'},
}

FILTER_PCELL_TDD = "((f1ap.procedureCode == 7) && (nr-rrc.sCellToAddModList == 1) && (nr-rrc.physCellId == 81))"

FILTER_PCELL_FDD = "((f1ap.procedureCode == 7) && (nr-rrc.sCellToAddModList == 1) && (nr-rrc.physCellId == 50))"

FILTER_STEPWISE = "((f1ap.procedureCode == 7) && (nr-rrc.sCellToAddModList == 2))"


def _verify_messages(pcap_file, messages=None, shark_filter=None):
    finder = bip_finder(pcap_file, shark_filter)
    found_msgs = finder.find_all(messages, forget_matcher_on_hit=True)
    msgs_to_find = [m.tag for m in messages]
    blog(msgs_to_find)
    missing_msgs = set(msgs_to_find) - set(found_msgs.keys())
    assert len(found_msgs) == len(messages), \
        "At least one message is missing! Missing messages: {}".format(','.join(missing_msgs))
    return found_msgs


def bip_finder(pcap_file, shark_filter):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=shark_filter,
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
            shark_options=None
        )
    return finder


def verify_uplinkTxSwitching_for_pcell_in_rrc_messages(pcap_file):
    scells_msgs = [
        pm('UEContextModificationResponse', name_line_pattern='empty')
        .containing("spCellConfig")
        .containing('physCellId', '*{}*'.format(CELL_PARAMETERS['CELL_n41']['physCellId']))
        .containing("uplinkConfig")
        .containing('*uplinkTxSwitchingPeriodLocation-r16', '*{}*'
                    .format(CELL_PARAMETERS['CELL_n41']['0_uplinkTxSwitchingPeriodLocation-r16']))
        .containing('uplinkTxSwitchingCarrier-r16', '*{}*'
                    .format(CELL_PARAMETERS['CELL_n41']['uplinkTxSwitchingCarrier']))
        .containing('uplinkTxSwitchingOption-r16', '*{}*'.format(CELL_PARAMETERS['CELL_n41']['TxOption']))
        .containing('uplinkTxSwitching-2T-Mode-r17', '*{}*'
                    .format(CELL_PARAMETERS['CELL_n41']['uplinkTxSwitching_2T']))
        .containing("SCellConfig")
        .containing('physCellId', '*{}*'.format(CELL_PARAMETERS['CELL_n71']['physCellId']))
        .containing("uplinkConfig")
        .containing('*uplinkTxSwitchingPeriodLocation-r16', '*{}*'
                    .format(CELL_PARAMETERS['CELL_n71']['1_uplinkTxSwitchingPeriodLocation']))
        .containing('uplinkTxSwitchingCarrier-r16', '*{}*'
                    .format(CELL_PARAMETERS['CELL_n71']['uplinkTxSwitchingCarrier']))
        .containing('uplinkTxSwitchingOption-r16', '*{}*'.format(CELL_PARAMETERS['CELL_n71']['TxOption']))
        .containing('uplinkTxSwitching-2T-Mode-r17', '*{}*'
                    .format(CELL_PARAMETERS['CELL_n71']['uplinkTxSwitching_2T']))
    ]
    return _verify_messages(pcap_file, scells_msgs, shark_filter=FILTER_PCELL_TDD)


def verify_uplinkTxSwitching_for_FDD_pcell_in_rrc_messages(pcap_file):
    pcell_msgs = [
        pm('UEContextModificationResponse', name_line_pattern='empty')
        .containing("spCellConfig")
        .containing('physCellId', '*{}*'.format(CELL_PARAMETERS['PCELL_n71']['physCellId']))
        .containing("uplinkConfig")
        .containing('maxRank', '*{}*'
                    .format(CELL_PARAMETERS['PCELL_n71']['maxRank']))
        .containing('*uplinkTxSwitchingPeriodLocation-r16', '*{}*'
                    .format(CELL_PARAMETERS['PCELL_n71']['1_uplinkTxSwitchingPeriodLocation-r16']))
        .containing('uplinkTxSwitchingCarrier-r16', '*{}*'
                    .format(CELL_PARAMETERS['PCELL_n71']['uplinkTxSwitchingCarrier']))
        .containing('uplinkTxSwitchingOption-r16', '*{}*'.format(CELL_PARAMETERS['PCELL_n71']['TxOption']))
        .containing('uplinkTxSwitching-2T-Mode-r17', '*{}*'
                    .format(CELL_PARAMETERS['PCELL_n71']['uplinkTxSwitching_2T']))
    ]
    return _verify_messages(pcap_file, pcell_msgs, shark_filter=FILTER_PCELL_FDD)


def verify_uplinkTxSwitching_for_TDD_scell_in_rrc_messages(pcap_file):
    scell_msgs = [
        pm('UEContextModificationResponse', name_line_pattern='empty')
        .containing("SCellConfig")
        .containing('physCellId', '*{}*'.format(CELL_PARAMETERS['SCELL_n41']['physCellId']))
        .containing("uplinkConfig")
        .containing('*uplinkTxSwitchingPeriodLocation-r16', '*{}*'
                    .format(CELL_PARAMETERS['SCELL_n41']['0_uplinkTxSwitchingPeriodLocation-r16']))
        .containing('uplinkTxSwitchingCarrier-r16', '*{}*'
                    .format(CELL_PARAMETERS['SCELL_n41']['uplinkTxSwitchingCarrier']))
        .containing('maxRank', '*{}*'.format(CELL_PARAMETERS['SCELL_n41']['maxRank']))
        .containing('uplinkTxSwitchingOption-r16', '*{}*'.format(CELL_PARAMETERS['SCELL_n41']['TxOption']))
        .containing('uplinkTxSwitching-2T-Mode-r17', '*{}*'
                    .format(CELL_PARAMETERS['SCELL_n41']['uplinkTxSwitching_2T']))
    ]
    return _verify_messages(pcap_file, scell_msgs, shark_filter=FILTER_PCELL_FDD)


def verify_uplinkTxSwitching_for_FDD_stepwise_scell_in_rrc_messages(pcap_file):
    pcell_msgs = [
        pm('UEContextModificationResponse', name_line_pattern='empty')
        .containing("spCellConfig")
        .containing('physCellId', '*{}*'.format(CELL_PARAMETERS['SCELL_n71_40']['physCellId']))
        .containing("uplinkConfig")
        .containing('maxRank', '*{}*'
                    .format(CELL_PARAMETERS['SCELL_n71_40']['maxRank']))
        .containing('*uplinkTxSwitchingPeriodLocation-r16', '*{}*'
                    .format(CELL_PARAMETERS['SCELL_n71_40']['1_uplinkTxSwitchingPeriodLocation-r16']))
        .containing('uplinkTxSwitchingCarrier-r16', '*{}*'
                    .format(CELL_PARAMETERS['SCELL_n71_40']['uplinkTxSwitchingCarrier']))
        .containing('uplinkTxSwitchingOption-r16', '*{}*'.format(CELL_PARAMETERS['SCELL_n71_40']['TxOption']))
        .containing('uplinkTxSwitching-2T-Mode-r17', '*{}*'
                    .format(CELL_PARAMETERS['SCELL_n71_40']['uplinkTxSwitching_2T']))
    ]
    return _verify_messages(pcap_file, pcell_msgs, shark_filter=FILTER_STEPWISE)
