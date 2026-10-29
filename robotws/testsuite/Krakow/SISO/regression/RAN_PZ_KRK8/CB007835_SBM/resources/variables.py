from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion

under_test_parameters = {
    "cell_params": {
        "path_template": "MRBTS-{}/NRBTS-{}/NRCELL-",
        "params": {
            "pMax": 190,
            "dlQam256PowerBackoffSub6": 14,
        },
    },
    "bts_params": {
        "path_template": "MRBTS-{}/NRBTS-{}",
        "params": {"nsaInactivityTimer": 241},
    },
}

after_test_parameters = {
    "cell_params": {
        "path_template": "MRBTS-{}/NRBTS-{}/NRCELL-",
        "params": {
            "pMax": 180,
            "dlQam256PowerBackoffSub6": 15,
        },
    },
    "bts_params": {
        "path_template": "MRBTS-{}/NRBTS-{}",
        "params": {"nsaInactivityTimer": 240},
    },
}


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        "SBTS23R1": {
            "qc_upgrade": None,
            "qc_site_reset": None,
            "qc_capacity_reset": None,
            "qc_ru_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_lock_unlock": None,
            "commissioning_online": None,
            "commissioning_rat": None,
            "commissioning_reset": None,
            "ru_lock_unlock": None,
        },
        "SBTS23R2": {
            "qc_upgrade": None,
            "qc_site_reset": None,
        },
        "SBTS23R3": {
            "qc_upgrade": None,
            "qc_site_reset": None,
        },
        "SBTS23R4": {
            "qc_upgrade": None,
            "qc_site_reset": None,
            "qc_capacity_reset": None,
            "qc_ru_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_lock_unlock": None,
            "commissioning_online": None,
            "commissioning_rat": None,
            "commissioning_reset": None,
            "ru_lock_unlock": None,
        },
        "SBTS24R1": {
            "qc_upgrade": 822293,
            "qc_site_reset": 822291,
            "qc_capacity_reset": None,
            "qc_ru_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_block_unblock_v2": None,
            "qc_cell_lock_unlock": None,
            "commissioning_online": None,
            "commissioning_rat": None,
            "commissioning_reset": None,
            "ru_lock_unlock": None,
        },
        "SBTS24R2": {
            "qc_upgrade": 822298,
            "qc_site_reset": 822297,
            "qc_capacity_reset": None,
            "qc_ru_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_block_unblock_v2": None,
            "qc_cell_lock_unlock": None,
            "commissioning_online": None,
            "commissioning_rat": None,
            "commissioning_reset": None,
            "ru_lock_unlock": None,
        },
        "SBTS24R3": {
            "qc_upgrade": 846545,
            "qc_site_reset": 846551,
            "qc_capacity_reset": 846552,
            "qc_ru_reset": 846550,
            "qc_cell_block_unblock": None,
            "qc_cell_block_unblock_v2": 846553,
            "qc_cell_lock_unlock": 846546,
            "commissioning_online": 846554,
            "commissioning_rat": 846549,
            "commissioning_reset": 846548,
            "ru_lock_unlock": None,
        },
        "SBTS25R1": {
            "qc_upgrade": 136029,
            "qc_site_reset": 236331,
            "qc_activation_reset": 191881,
            "qc_capacity_reset": 136028,
            "qc_ru_reset": 136030,
            "qc_cell_block_unblock": None,
            "qc_cell_block_unblock_v2": 136026,
            "qc_cell_lock_unlock": 136027,
            "commissioning_online": 136035,
            "commissioning_rat": 136032,
            "commissioning_reset": 136031,
            "ru_lock_unlock": None,
            "qc_upgrade_l3call": 136034,
        },
        "SBTS25R3": {
            "qc_upgrade": 229009,
            "qc_site_reset": 229008,
            "qc_activation_reset": 229010,
            "qc_capacity_reset": None,
            "qc_ru_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_block_unblock_v2": None,
            "qc_cell_lock_unlock": None,
            "commissioning_online": None,
            "commissioning_rat": None,
            "commissioning_reset": None,
            "ru_lock_unlock": None,
            "qc_upgrade_l3call": None,
        },
        "SBTS26R1": {
            "qc_upgrade": 254799,
            "qc_site_reset": 254793,
            "qc_activation_reset": 254797,
            "qc_capacity_reset": 254794,
            "qc_ru_reset": 254795,
            "qc_cell_block_unblock_v2": 254801,
            "qc_cell_lock_unlock": 254800,
            "commissioning_online": 254803,
            "commissioning_rat": 254802,
            "commissioning_reset": 254796,
            "ru_lock_unlock": None,
            "qc_upgrade_l3call": 254798,
        },
        "SBTS00": {
            "qc_upgrade": 217098,
            "qc_site_reset": 218390,
            "qc_activation_reset": 217097,
            "qc_capacity_reset": 217102,
            "qc_ru_reset": 217103,
            "qc_cell_block_unblock_v2": 217095,
            "qc_cell_lock_unlock": 217096,
            "commissioning_online": 217093,
            "commissioning_rat": 217094,
            "commissioning_reset": 217100,
            "ru_lock_unlock": None,
            "qc_upgrade_l3call": 217099,
        },
    }

    return qc_id_mapping[release]


def get_variables():
    if is_dry_run():
        return {}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

    tl_topology = BuiltIn().get_variable_value("${tl.tl_cloud_topology}")
    variables = {
        'CLOUD_5G_CLASSICAL_ASIBL_ABIOB1B2_ABILB3_4xAWEUA_ECPRI': {
            'single_ue_tput_dl': '2100Mbits/sec',
            'single_ue_tput_ul': '250Mbits/sec',
            'min_single_ue_tput_dl': '1900Mbits/sec',
            'min_single_ue_tput_ul': '215Mbits/sec',
            'endc_tput_dl': '4200Mbits/sec',
            'min_endc_tput_dl_4G': '92000',
            'min_endc_tput_dl_5G': '3700',
            'endc_tput_ul': '300Mbits/sec',
            'min_endc_tput_ul_4G': '32000',
            'min_endc_tput_ul_5G': '215',
            'multi_ue_tput_dl': '3000Mbits/sec',
            'multi_ue_tput_ul': '125Mbits/sec',
            'min_multi_ue_tput_dl': '2000Mbits/sec',
            'min_multi_ue_tput_ul': '115Mbits/sec',
            'max_segment_size': '1450',
            'endc_ul_streams': '2',
            'endc_dl_streams': '8',
        },
    }
    kpi_qc_ids = get_proper_set_of_ids(bts_build)
    variables[tl_topology]['kpi_qc_ids'] = kpi_qc_ids
    return variables[tl_topology]
