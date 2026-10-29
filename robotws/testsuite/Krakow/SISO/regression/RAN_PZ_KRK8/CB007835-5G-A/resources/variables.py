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
            "qc_upgrade": 528309,
            "qc_site_reset": 528317,
            "qc_capacity_reset": 528316,
            "qc_ru_reset": 528313,
            "qc_cell_block_unblock": 528311,
            "qc_cell_lock_unlock": 528312,
            "commissioning_online": 528314,
            "commissioning_rat": 542490,
            "commissioning_reset": 528315,
            "ru_lock_unlock": 528310,
        },
        "SBTS23R2": {
            "qc_upgrade": 584830,
            "qc_site_reset": 584819,
        },
        "SBTS23R3": {
            "qc_upgrade": 624519,
            "qc_site_reset": 624518,
        },
        "SBTS23R4": {
            "qc_upgrade": 717196,
            "qc_site_reset": 717193,
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
            "qc_upgrade": 791668,
            "qc_site_reset": 791662,
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
            "qc_upgrade": 830474,
            "qc_site_reset": 830475,
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
            "qc_upgrade": 846468,
            "qc_site_reset": 846467,
            "qc_capacity_reset": 846475,
            "qc_ru_reset": 846470,
            "qc_cell_block_unblock_v2": 846472,
            "qc_cell_lock_unlock": 846474,
            "commissioning_online": 846476,
            "commissioning_rat": 846469,
            "commissioning_reset": 846471,
            "ru_lock_unlock": 846473,
        },
        "SBTS25R1": {
            "qc_upgrade": 88249,
            "qc_site_reset": 88251,
            "qc_capacity_reset": 88250,
            "qc_ru_reset": 88255,
            "qc_cell_block_unblock_v2": 88254,
            "qc_cell_lock_unlock": 88257,
            "commissioning_online": 88256,
            "commissioning_rat": 88252,
            "commissioning_reset": 88253,
            "ru_lock_unlock": 88258,
        },
        "SBTS25R2": {
            "qc_upgrade": 149458,
            "qc_upgrade_l3call": 149452,
            "qc_activation_reset": 149451,
            "qc_capacity_reset": 149459,
            "qc_ru_reset": 149461,
            "qc_cell_block_unblock_v2": 149465,
            "qc_cell_lock_unlock": 149467,
            "commissioning_online": 149463,
            "commissioning_rat": 149466,
            "commissioning_reset": 149462,
        },
        "SBTS25R3": {
            "qc_upgrade": 207988,
            "qc_upgrade_l3call": 207979,
            "qc_activation_reset": 208000,
            "qc_site_reset": 218398,
            "qc_capacity_reset": 207991,
            "qc_ru_reset": 207994,
            "qc_cell_block_unblock_v2": 207993,
            "qc_cell_lock_unlock": 207992,
            "commissioning_online": 207990,
            "commissioning_rat": 207996,
            "commissioning_reset": 207995,
        },
        "SBTS26R1": {
            "qc_upgrade": 254760,
            "qc_upgrade_l3call": 254737,
            "qc_activation_reset": 254761,
            "qc_site_reset": 254741,
            "qc_capacity_reset": 254753,
            "qc_ru_reset": 254751,
            "qc_cell_block_unblock_v2": 254756,
            "qc_cell_lock_unlock": 254752,
            "commissioning_online": 254757,
            "commissioning_rat": 254754,
            "commissioning_reset": 254755,
        },
        "SBTS26R2": {
            "qc_upgrade": 298663,
            "qc_upgrade_l3call": 298655,
            "qc_activation_reset": 298662,
            "qc_site_reset": 298661,
            "qc_capacity_reset": 298659,
            "qc_ru_reset": 298658,
            "qc_cell_block_unblock_v2": 298656,
            "qc_cell_lock_unlock": 298657,
            "commissioning_online": 298665,
            "commissioning_rat": 298660,
            "commissioning_reset": 298664,
        },
        "SBTS00": {
            "qc_upgrade": 243580,
            "qc_upgrade_l3call": 243581,
            "qc_activation_reset": 243583,
            "qc_site_reset": 243582,
            "qc_capacity_reset": 243590,
            "qc_ru_reset": 243592,
            "qc_cell_block_unblock_v2": 243591,
            "qc_cell_lock_unlock": 243594,
            "commissioning_online": 243595,
            "commissioning_rat": 243584,
            "commissioning_reset": 243593,
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
        'CLOUD_5G_CLASSICAL_ASIK_3xABIL_3xAEWB': {
            'single_ue_tput_dl': '4000Mbits/sec',
            'single_ue_tput_ul': '250Mbits/sec',
            'min_single_ue_tput_dl': '3700Mbits/sec',
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
