import os
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion

sum_counters_ul = [
    "M55319C06001",
    "M55319C06002",
    "M55319C06003",
    "M55319C06004",
    "M55319C06005",
    "M55319C06006",
    "M55319C06007",
    "M55319C06008",
    "M55319C06009",
    "M55319C06010",
    "M55319C06011",
    "M55319C06012",
    "M55319C06013",
    "M55319C06014",
    "M55319C06015",
    "M55319C06016",
    "M55319C06017",
    "M55319C06018",
    "M55319C06019",
    "M55319C06020"]
divide_counter_ul = "M55319C00001"
sum_counters_dl = [
    "M55319C02001",
    "M55319C02002",
    "M55319C02003",
    "M55319C02004",
    "M55319C02005",
    "M55319C02006",
    "M55319C02007",
    "M55319C02008",
    "M55319C02009",
    "M55319C02010",
    "M55319C02011",
    "M55319C02012",
    "M55319C02013",
    "M55319C02014",
    "M55319C02015",
    "M55319C02016",
    "M55319C02017",
    "M55319C02018",
    "M55319C02019",
    "M55319C02020"
]
divide_counter_dl = "M55319C00001"

default_parameters = {"actPrioritizeX2AfterInactivity": "false",
                      "actX2DuplicateTxNSA3x": "false",
                      "dlDataSplitBufferBuildUpThreshold": "5",
                      "dlDataSplitBufferBuildUpThresholdPrioritizeX2": "5",
                      "dlDataSplitGainThreshold": "1",
                      "dlDataSplitMode": "dlOverF1UX2U",
                      "inactivityThresholdForPrioritizeX2": "300",
                      "inactivityThresholdForRestartPrioritizeX2": "100",
                      # "inactPeriodX2PdcpDuplication": "",
                      "initialDLTrafficRouting": "initDLoverX2U",
                      "nsa3xBearerAllowed": "true",
                      "prioritizeX2Period": "500",
                      # "reTxPrioritizationType": "",
                      "ulDataPath": "ulOverLteNr_PrimaryPathOverNr",
                      # "ulDataPathForUlSplitNotCapableUe": "",
                      "dlPreferredPath": "F1-U",
                      "ulDataSplitThreshold": "b100"}

scf_parameters_oam = {
    "before_test": {
        "dlDataSplitMode": "dlOverF1UX2U",
        "ulDataPath": "ulOverLteNr_PrimaryPathOverNr",
        "ulDataSplitThreshold": "b100"
    },
    "after_test": {
        "dlDataSplitMode": "dlOverF1U",
        "ulDataPath": "ulOverNr",
        "ulDataSplitThreshold": "infinity"
    }
}

scf_parameters = {
    "before_test": {
        "DL Data Split Mode": "dlOverF1UX2U",
        "UL data path": "ulOverLteNr_PrimaryPathOverNr",
        "UL data split threshold": "b100"
    },
    "after_test": {
        "DL Data Split Mode": "dlOverF1U",
        "UL data path": "ulOverNr",
        "UL data split threshold": "infinity"
    }
}

counter_ul_enb_numerator = "M8012C225"
counter_ul_enb_divisor = "M8012C224"
counter_dl_enb_numerator = "M8012C221"
counter_dl_enb_divisor = "M8012C220"


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS24R1':
            {
                'qc_upgrade': 791924,
                'qc_site_reset': 791922,
                'qc_capacity_reset': 791929,
                'qc_ru_reset': 791928,
                'qc_cell_block_unblock': 791923,
                'qc_cell_lock_unlock': 791927,
                'qc_comm_online_change': 791925,
                'qc_comm_reset': 791926,
                'qc_comm_rat_reset': 791930,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_ST'
            },
        'SBTS24R2':
            {
                'qc_upgrade': 830788,
                'qc_site_reset': 830787,
                'qc_capacity_reset': 830786,
                'qc_ru_reset': 830785,
                'qc_cell_block_unblock': 830782,
                'qc_cell_lock_unlock': 830789,
                'qc_comm_online_change': 830781,
                'qc_comm_reset': 830780,
                'qc_comm_rat_reset': 830784,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_ST'
            },
        'SBTS24R3':
            {
                'qc_upgrade': 846066,
                'qc_site_reset': 846067,
                'qc_capacity_reset': 846072,
                'qc_ru_reset': 846068,
                'qc_cell_block_unblock': 846071,
                'qc_cell_lock_unlock': 846070,
                'qc_comm_online_change': 846073,
                'qc_comm_reset': 846074,
                'qc_comm_rat_reset': 846069,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_ST'
            },
        'SBTS00':
            {
                'qc_upgrade': 104232,
                'qc_site_reset': 104224,
                'qc_capacity_reset': 104226,
                'qc_ru_reset': 104230,
                'qc_cell_block_unblock': 104228,
                'qc_cell_lock_unlock': 104229,
                'qc_comm_online_change': 104225,
                'qc_comm_reset': 104227,
                'qc_comm_rat_reset': 104231,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_VRF'
            }
    }

    return qc_id_mapping[release]


def get_proper_set_of_ids_4g(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS24R1':
            {
                'qc_upgrade': 791924,
                'qc_site_reset': 791922,
                'qc_capacity_reset': 791929,
                'qc_ru_reset': 791928,
                'qc_cell_block_unblock': 791923,
                'qc_cell_lock_unlock': 791927,
                'qc_comm_online_change': 791925,
                'qc_comm_reset': 791926,
                'qc_comm_rat_reset': 791930,
            },
        'SBTS24R2':
            {
                'qc_upgrade': 830788,
                'qc_site_reset': 830787,
                'qc_capacity_reset': 830786,
                'qc_ru_reset': 830785,
                'qc_cell_block_unblock': 830782,
                'qc_cell_lock_unlock': 830789,
                'qc_comm_online_change': 830781,
                'qc_comm_reset': 830780,
                'qc_comm_rat_reset': 830784,
            },
        'SBTS24R3':
            {
                'qc_upgrade': 846066,
                'qc_site_reset': 846067,
                'qc_capacity_reset': 846072,
                'qc_ru_reset': 846068,
                'qc_cell_block_unblock': 846071,
                'qc_cell_lock_unlock': 846070,
                'qc_comm_online_change': 846073,
                'qc_comm_reset': 846074,
                'qc_comm_rat_reset': 846069,
            },
        'SBTS00':
            {
                'qc_upgrade': 528626,
                'qc_site_reset': 528625,
                'qc_capacity_reset': 528628,
                'qc_ru_reset': 528627,
                'qc_cell_block_unblock': 528623,
                'qc_cell_lock_unlock': 528624,
                'qc_comm_rat_reset': 673874,
            }
    }

    return qc_id_mapping[release]


def get_variables():
    if is_dry_run():
        return {}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

    if SbtsSwVersion(bts_build) >= SbtsSwVersion('SBTS23R1_ENB_0000_000000_000000'):
        default_parameters['dlNumOfCongOrGainDdds'] = 2

    tl_topology = BuiltIn().get_variable_value("${tl.tl_cloud_topology}")
    CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))
    variables = {
        'CLOUD_5G_CLASSICAL_QC_ASIML_ABIOB1B2B3_AWGUC': {
            'single_ue_tput_dl': '2000Mbits/sec',
            'single_ue_tput_ul': '250Mbits/sec',
            'min_single_ue_tput_dl': '1900Mbits/sec',
            'min_single_ue_tput_ul': '225Mbits/sec',
            'endc_tput_dl': '2400Mbits/sec',
            'min_endc_tput_dl_4G': '92000',
            'min_endc_tput_dl_5G': '1900',
            'endc_tput_ul': '300Mbits/sec',
            'min_endc_tput_ul_4G': '32000',
            'min_endc_tput_ul_5G': '215',
            'multi_ue_tput_dl': '1000Mbits/sec',
            'multi_ue_tput_ul': '125Mbits/sec',
            'min_multi_ue_tput_dl': '950Mbits/sec',
            'min_multi_ue_tput_ul': '115Mbits/sec',
            'max_segment_size': '1436',
            'endc_ul_streams': '2',
            'endc_dl_streams': '8',
            'MUMIN_CONFIG_FILE': os.path.join(CURDIR, 'mumin_T1SK049.yaml'),
            'DELTA_5G': os.path.join(CURDIR, 'delta_5G.json')
        },
        'CLOUD_5G_CLASSICAL_QC_ASIMR_ABIOB4B5B6_AWGUC': {
            'single_ue_tput_dl': '2000Mbits/sec',
            'single_ue_tput_ul': '250Mbits/sec',
            'min_single_ue_tput_dl': '1900Mbits/sec',
            'min_single_ue_tput_ul': '225Mbits/sec',
            'endc_tput_dl': '2400Mbits/sec',
            'min_endc_tput_dl_4G': '92000',
            'min_endc_tput_dl_5G': '1900',
            'endc_tput_ul': '300Mbits/sec',
            'min_endc_tput_ul_4G': '32000',
            'min_endc_tput_ul_5G': '215',
            'multi_ue_tput_dl': '1000Mbits/sec',
            'multi_ue_tput_ul': '125Mbits/sec',
            'min_multi_ue_tput_dl': '950Mbits/sec',
            'min_multi_ue_tput_ul': '115Mbits/sec',
            'max_segment_size': '1436',
            'endc_ul_streams': '2',
            'endc_dl_streams': '8',
            'MUMIN_CONFIG_FILE': os.path.join(CURDIR, 'mumin_T1SK225.yaml'),
            'DELTA_5G': os.path.join(CURDIR, 'delta_5G_T1SK225.json')
        }
    }
    variables[tl_topology]['sum_counters_ul'] = sum_counters_ul
    variables[tl_topology]['divide_counter_ul'] = divide_counter_ul
    variables[tl_topology]['sum_counters_dl'] = sum_counters_dl
    variables[tl_topology]['divide_counter_dl'] = divide_counter_dl
    variables[tl_topology]['default_parameters'] = default_parameters
    variables[tl_topology]['scf_parameters_oam'] = scf_parameters_oam
    variables[tl_topology]['scf_parameters'] = scf_parameters
    variables[tl_topology]['counter_ul_enb_numerator'] = counter_ul_enb_numerator
    variables[tl_topology]['counter_dl_enb_numerator'] = counter_dl_enb_numerator
    kpi_qc_ids = get_proper_set_of_ids(bts_build)
    kpi_qc_ids_4g = get_proper_set_of_ids_4g(bts_build)
    variables[tl_topology]['kpi_qc_ids'] = kpi_qc_ids
    variables[tl_topology]['kpi_qc_ids_4G'] = kpi_qc_ids_4g
    return variables[tl_topology]
