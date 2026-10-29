from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS24R3':
            {
                'qc_upgrade': 864626,
                'qc_site_reset': 864625,
                'qc_capacity_reset': 864632,
                'qc_ru_reset': 864631,
                'qc_cell_block_unblock': 864629,
                'qc_cell_lock_unlock': 864630,
                'qc_delta_nr_rat_reset': 864643,
                'qc_delta_online': 864642,
                'qc_delta_reset': 864641,
                'qc_activ_reset': 868851,
            },
        'SBTS25R1':
            {
                'qc_upgrade': 87479,
                'qc_site_reset': 87482,
            },
        'SBTS25R2':
            {
                'qc_upgrade': 225439,
                'qc_site_reset': 225431,
                # 'qc_capacity_reset': 148725,
                # 'qc_ru_reset': 148727,
                # 'qc_cell_block_unblock': 148721,
                # 'qc_cell_lock_unlock': 148729,
                # 'qc_delta_nr_rat_reset': 148724,
                # 'qc_delta_lte_rat_reset': 148733,
                # 'qc_delta_online': 148726,
                # 'qc_delta_reset': 148723,
                'qc_activ_reset': 225447,
            },
        'SBTS25R3':
            {
                'qc_upgrade': 207395,
                'qc_site_reset': 217183,
                'qc_activ_reset': 207399,
            },
        'SBTS26R1':
            {
                'qc_upgrade': 255147,
                'qc_site_reset': 255153,
                'qc_activ_reset': 255162,
                'qc_capacity_reset': 255152,
                'qc_ru_reset': 255145,
                'qc_cell_block_unblock': 255150,
                'qc_cell_lock_unlock': 255149,
                'qc_delta_nr_rat_reset': 255154,
                'qc_delta_online': 255151,
                'qc_delta_reset': 255146,
            },
        'SBTS00':
            {
                'qc_upgrade': 50459,
                'qc_site_reset': 217041,
                'qc_capacity_reset': 40947,
                'qc_ru_reset': 40948,
                'qc_cell_block_unblock': 40935,
                'qc_cell_lock_unlock': 40944,
                'qc_delta_nr_rat_reset': 40937,
                'qc_delta_online': 40934,
                'qc_delta_reset': 40933,
                'qc_activ_reset': 184858,
            }
    }

    return qc_id_mapping[release]


def get_proper_set_of_ids_4g(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS24R3':
            {
                'qc_upgrade': 845775,
                'qc_site_reset': 845779,
                'qc_capacity_reset': 845774,
                'qc_ru_reset': 845776,
                'qc_cell_block_unblock': 845778,
                'qc_cell_lock_unlock': 845777,
                'qc_delta_lte_rat_reset': 845772,
                'qc_delta_online': 845767,
                'qc_delta_reset': 845768,
            },
        'SBTS25R1':
            {
                'qc_upgrade': 87481,
                'qc_site_reset': 87480,
            },
        'SBTS25R2':
            {
                'qc_upgrade': 225449,
                'qc_site_reset': 225450,
            },
        'SBTS25R3':
            {
                'qc_upgrade': 207393,
                'qc_site_reset': 235371,
            },
        'SBTS26R1':
            {
                'qc_upgrade': 255148,
                'qc_site_reset': 255164,
                'qc_capacity_reset': 255160,
                'qc_ru_reset': 255159,
                'qc_cell_block_unblock': 255158,
                'qc_cell_lock_unlock': 255161,
                'qc_delta_lte_rat_reset': 255155,
                'qc_delta_online': 255157,
                'qc_delta_reset': 255156,
                'qc_activ_reset': 255162,
            },
        'SBTS00':
            {
                'qc_upgrade': 40939,
                'qc_site_reset': 222148,
                'qc_capacity_reset': 40938,
                'qc_ru_reset': 40940,
                'qc_cell_block_unblock': 40942,
                'qc_cell_lock_unlock': 40941,
                'qc_delta_lte_rat_reset': 40936,
                'qc_delta_online': 40931,
                'qc_delta_reset': 40932,
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
    variables = {
        'NON_CM': {
            # 'single_ue_tput_dl': '4000Mbits/sec',
            # 'single_ue_tput_ul': '250Mbits/sec',
            # 'min_single_ue_tput_dl': '3700Mbits/sec',
            # 'min_single_ue_tput_ul': '215Mbits/sec',
            # 'endc_tput_dl': '4200Mbits/sec',
            # 'min_endc_tput_dl_4G': '92000',
            # 'min_endc_tput_dl_5G': '3700',
            # 'endc_tput_ul': '300Mbits/sec',
            # 'min_endc_tput_ul_4G': '32000',
            # 'min_endc_tput_ul_5G': '215',
            # 'multi_ue_tput_dl': '3000Mbits/sec',
            # 'multi_ue_tput_ul': '125Mbits/sec',
            # 'min_multi_ue_tput_dl': '2000Mbits/sec',
            # 'min_multi_ue_tput_ul': '115Mbits/sec',
            # 'max_segment_size': '1450',
            # 'endc_ul_streams': '2',
            # 'endc_dl_streams': '8',
        },
        'CLOUD_7_7_T04SK137': {
            # 'single_ue_tput_dl': '4000Mbits/sec',
            # 'single_ue_tput_ul': '250Mbits/sec',
            # 'min_single_ue_tput_dl': '3700Mbits/sec',
            # 'min_single_ue_tput_ul': '215Mbits/sec',
            # 'endc_tput_dl': '4200Mbits/sec',
            # 'min_endc_tput_dl_4G': '92000',
            # 'min_endc_tput_dl_5G': '3700',
            # 'endc_tput_ul': '300Mbits/sec',
            # 'min_endc_tput_ul_4G': '32000',
            # 'min_endc_tput_ul_5G': '215',
            # 'multi_ue_tput_dl': '3000Mbits/sec',
            # 'multi_ue_tput_ul': '125Mbits/sec',
            # 'min_multi_ue_tput_dl': '2000Mbits/sec',
            # 'min_multi_ue_tput_ul': '115Mbits/sec',
            # 'max_segment_size': '1450',
            # 'endc_ul_streams': '2',
            # 'endc_dl_streams': '8',
        },
        'CLOUD_7_7_T01PY002': {
            # 'single_ue_tput_dl': '4000Mbits/sec',
            # 'single_ue_tput_ul': '250Mbits/sec',
            # 'min_single_ue_tput_dl': '3700Mbits/sec',
            # 'min_single_ue_tput_ul': '215Mbits/sec',
            # 'endc_tput_dl': '4200Mbits/sec',
            # 'min_endc_tput_dl_4G': '92000',
            # 'min_endc_tput_dl_5G': '3700',
            # 'endc_tput_ul': '300Mbits/sec',
            # 'min_endc_tput_ul_4G': '32000',
            # 'min_endc_tput_ul_5G': '215',
            # 'multi_ue_tput_dl': '3000Mbits/sec',
            # 'multi_ue_tput_ul': '125Mbits/sec',
            # 'min_multi_ue_tput_dl': '2000Mbits/sec',
            # 'min_multi_ue_tput_ul': '115Mbits/sec',
            # 'max_segment_size': '1450',
            # 'endc_ul_streams': '2',
            # 'endc_dl_streams': '8',
        }
    }
    kpi_qc_ids = get_proper_set_of_ids(bts_build)
    kpi_qc_ids_4g = get_proper_set_of_ids_4g(bts_build)
    variables[tl_topology]['kpi_qc_ids'] = kpi_qc_ids
    variables[tl_topology]['kpi_qc_ids_4g'] = kpi_qc_ids_4g
    BuiltIn().log_to_console(variables[tl_topology])
    return variables[tl_topology]
