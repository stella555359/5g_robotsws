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
        'SBTS23R1':
            {
                'qc_upgrade': 528318,
                'qc_site_reset': 528324,
                'qc_capacity_reset': 528330,
                'qc_ru_reset': 528328,
                'qc_cell_block_unblock': 528327,
                'qc_cell_lock_unlock': 528329,
            },
        'SBTS23R2':
            {
                'qc_upgrade': 504411,
                'qc_site_reset': 504408,
                'qc_capacity_reset': 504412,
                'qc_ru_reset': 504409,
                'qc_cell_block_unblock': 504413,
                'qc_cell_lock_unlock': 504410,
            },
        'SBTS23R3':
            {
                'qc_upgrade': 564432,
                'qc_site_reset': 564430,
                'qc_capacity_reset': 564429,
                'qc_ru_reset': 564442,
                'qc_cell_block_unblock': 564444,
                'qc_cell_lock_unlock': 564443,
            },
        'SBTS23R4':
            {
                'qc_upgrade': 630204,
                'qc_site_reset': 630205,
                'qc_capacity_reset': 630189,
                'qc_ru_reset': 630203,
                'qc_cell_block_unblock': 630206,
                'qc_cell_lock_unlock': 630202,
            },
        'SBTS24R1':
            {
                'qc_upgrade': 697686,
                'qc_site_reset': 697669,
                'qc_capacity_reset': 0,
                'qc_ru_reset': 0,
                'qc_cell_block_unblock': 0,
                'qc_cell_lock_unlock': 0,
            },
        'SBTS00':
            {
                'qc_upgrade': 458790,
                'qc_site_reset': 458789,
                'qc_capacity_reset': 458792,
                'qc_ru_reset': 458791,
                'qc_cell_block_unblock': 670442,
                'qc_cell_lock_unlock': 458793,
            }
    }

    return qc_id_mapping[release]


def get_proper_set_of_ids_4g(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS23R1':
            {
                'qc_upgrade': 564431,
                'qc_site_reset': 564439,
                'qc_capacity_reset': 564433,
                'qc_ru_reset': 564438,
                'qc_cell_block_unblock': 564437,
                'qc_cell_lock_unlock': 564436,
            },
        'SBTS23R2':
            {
                'qc_upgrade': 528618,
                'qc_site_reset': 528618,
                'qc_capacity_reset': 528620,
                'qc_ru_reset': 528619,
                'qc_cell_block_unblock': 528615,
                'qc_cell_lock_unlock': 528616,
            },
        'SBTS23R3':
            {
                'qc_upgrade': 564431,
                'qc_site_reset': 564439,
                'qc_capacity_reset': 564433,
                'qc_ru_reset': 564438,
                'qc_cell_block_unblock': 564437,
                'qc_cell_lock_unlock': 564436,
            },
        'SBTS23R4':
            {
                'qc_upgrade': 630199,
                'qc_site_reset': 630196,
                'qc_capacity_reset': 630207,
                'qc_ru_reset': 630201,
                'qc_cell_block_unblock': 630197,
                'qc_cell_lock_unlock': 630198,
            },
        'SBTS24R1':
            {
                'qc_upgrade': 697681,
                'qc_site_reset': 697683,
                'qc_capacity_reset': 0,
                'qc_ru_reset': 0,
                'qc_cell_block_unblock': 0,
                'qc_cell_lock_unlock': 0,
            },
        'SBTS00':
            {
                'qc_upgrade': 528626,
                'qc_site_reset': 528625,
                'qc_capacity_reset': 528628,
                'qc_ru_reset': 528627,
                'qc_cell_block_unblock': 528623,
                'qc_cell_lock_unlock': 528624,
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
    variables = {
        'NON_CM': {
            'single_ue_tput_dl': '100Mbits/sec',
            'single_ue_tput_ul': '33Mbits/sec',
            'min_single_ue_tput_dl': '90Mbits/sec',
            'min_single_ue_tput_ul': '30Mbits/sec',
            'endc_tput_dl': '205Mbits/sec',
            'min_endc_tput_dl_4G': '40000',
            'min_endc_tput_dl_5G': '100',
            'endc_tput_ul': '80Mbits/sec',
            'min_endc_tput_ul_4G': '13750',
            'min_endc_tput_ul_5G': '36',
            'multi_ue_tput_dl': '55Mbits/sec',
            'multi_ue_tput_ul': '17Mbits/sec',
            'min_multi_ue_tput_dl': '50Mbits/sec',
            'min_multi_ue_tput_ul': '15Mbits/sec',
            'max_segment_size': '400',
            'endc_ul_streams': '4',
            'endc_dl_streams': '4',
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
