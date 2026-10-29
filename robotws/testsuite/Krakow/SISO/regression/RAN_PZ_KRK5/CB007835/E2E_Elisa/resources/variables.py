import os
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


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
        'SBTS25R2':
            {
                'qc_upgrade': 149024,
                'qc_site_reset': 149026,
                'qc_activation_reset': 187181,
                'qc_capacity_reset': 149028,
                'qc_ru_reset': 149025,
                'qc_cell_block_unblock': 149032,
                'qc_cell_lock_unlock': 149031,
                'qc_comm_online_change': 149027,
                'qc_comm_reset': 149029,
                'qc_comm_rat_reset': 149030,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_VRF'
            },
        'SBTS25R3':
            {
                'qc_upgrade': 207544,
                'qc_site_reset': 207543,
                'qc_activation_reset': 207546,
                'qc_capacity_reset': 207547,
                'qc_ru_reset': 207548,
                'qc_cell_block_unblock': 207550,
                'qc_cell_lock_unlock': 207549,
                'qc_comm_online_change': 207552,
                'qc_comm_reset': 207551,
                'qc_comm_rat_reset': 207545,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_VRF'
            },
        'SBTS26R1':
            {
                'qc_upgrade': 254414,
                'qc_activation_reset': 254415,
                'qc_capacity_reset': 254419,
                'qc_ru_reset': 254420,
                'qc_cell_block_unblock': 254418,
                'qc_cell_lock_unlock': 254417,
                'qc_comm_online_change': 254422,
                'qc_comm_reset': 254421,
                'qc_comm_rat_reset': 254416,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_VRF'
            },
        'SBTS26R2':
            {
                'qc_upgrade': 298413,
                'qc_activation_reset': 298414,
                'qc_capacity_reset': 298418,
                'qc_ru_reset': 298417,
                'qc_cell_block_unblock': 298419,
                'qc_cell_lock_unlock': 298416,
                'qc_comm_online_change': 298420,
                'qc_comm_reset': 298421,
                'qc_comm_rat_reset': 298415,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_VRF'
            },
        'SBTS00':
            {
                'qc_upgrade': 231149,
                'qc_site_reset': 104224,
                'qc_activation_reset': 231151,
                'qc_capacity_reset': 231154,
                'qc_ru_reset': 231156,
                'qc_cell_block_unblock': 231153,
                'qc_cell_lock_unlock': 231152,
                'qc_comm_online_change': 231158,
                'qc_comm_reset': 231157,
                'qc_comm_rat_reset': 231150,
                "qc_domain": 'MN_RAN',
                "qc_project": 'RAN_VRF'
            }
    }
    return qc_id_mapping[release]


def get_variables():
    if is_dry_run():
        return {}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

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
    kpi_qc_ids = get_proper_set_of_ids(bts_build)
    variables[tl_topology]['kpi_qc_ids'] = kpi_qc_ids
    return variables[tl_topology]
