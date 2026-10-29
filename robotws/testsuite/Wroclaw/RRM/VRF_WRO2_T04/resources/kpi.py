from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.kpi_counters import (
    PDSCH_INIT_TRANS_64QAM,
    PDSCH_INIT_TRANS_256QAM,
    PDSCH_SUCC_INIT_TRANS_64QAM,
    PDSCH_SUCC_INIT_TRANS_256QAM,
    PUSCH_INIT_TRANS_CP_OFDM_64QAM,
    PUSCH_INIT_TRANS_DFTs_OFDM_64QAM,
    PUSCH_INIT_TRANS_CP_OFDM_256QAM,
    PUSCH_SUCC_INIT_TRANS_CP_OFDM_64QAM,
    PUSCH_SUCC_INIT_TRANS_DFTs_OFDM_64QAM,
    PUSCH_SUCC_INIT_TRANS_CP_OFDM_256QAM,
)

scf = scf()

params = ["actDl256Qam", "actUl256Qam"]

downlink_counter_groups = [
    PDSCH_INIT_TRANS_64QAM,
    PDSCH_INIT_TRANS_256QAM,
    PDSCH_SUCC_INIT_TRANS_64QAM,
    PDSCH_SUCC_INIT_TRANS_256QAM,
]

uplink_counter_groups = [
    PUSCH_INIT_TRANS_CP_OFDM_64QAM,
    PUSCH_INIT_TRANS_DFTs_OFDM_64QAM,
    PUSCH_INIT_TRANS_CP_OFDM_256QAM,
    PUSCH_SUCC_INIT_TRANS_CP_OFDM_64QAM,
    PUSCH_SUCC_INIT_TRANS_DFTs_OFDM_64QAM,
    PUSCH_SUCC_INIT_TRANS_CP_OFDM_256QAM,
]

LOCALHOST = '127.0.0.1'


def validate_pm_counters_setting(pm_interval_no=1):
    scf_file = download_scf()
    dict = {}
    counter_interval_parameters = ["reportingIntervalPm", "miNrDlHarq", "miNrUlHarq"]
    logger.info("\nCounter settings in scf/webui:", also_console=True)
    for p in counter_interval_parameters:
        p_value = get_parameter_value_from_scf(path=scf_file, parameter_abbreviation=p)
        dict.update({p: p_value})
        logger.info(
            "  {} parameter is set to: {}".format(p, p_value), also_console=True
        )
    if not dict["reportingIntervalPm"] == dict["miNrDlHarq"] == dict["miNrUlHarq"]:
        logger.warn(
            "Intervals have set different values, see above. Please correct them in scf/webui"
        )
    else:
        logger.info(
            "Counters will be collected from last {}. time inerval(s) ({} minutes)".format(
                pm_interval_no, pm_interval_no * int(dict["reportingIntervalPm"][:-3])
            ),
            also_console=True,
        )


def download_scf(file_name="scf.xml", remote_host=LOCALHOST):
    local_dir_path = BuiltIn().get_variable_value("${OUTPUT DIR}") + "/"
    with AdminSession(remote_host) as admin:
        scf = admin.get_current_scf_file(
            local_dir_path=local_dir_path, file_name=file_name, timeout=30
        )
    return scf


def get_parameter_value_from_scf(
    parameter_abbreviation=None, path=None, parameter_dist_name=None
):
    if not path:
        path = download_scf()
    scf.load_scf(path)
    return scf.get_value_from_scf(
        dist_name=parameter_dist_name, p_name=parameter_abbreviation
    )


def get_modulation_scheme_settings_from_scf(path, cells_list):
    dict = {}
    for cell in cells_list:
        distname = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts_id, nrbts_id, cell)
        dict[cell] = {}
        for p in params:
            value = get_parameter_value_from_scf(
                path=path, parameter_abbreviation=p, parameter_dist_name=distname
            )
            dict[cell].update({p: value})
    return dict


def prepare_counters_ids(tput_direction):
    counter_ids = []
    if tput_direction.upper() == "DL":
        counters = downlink_counter_groups
    elif tput_direction.upper() == "UL":
        counters = uplink_counter_groups
    else:
        counters = downlink_counter_groups + uplink_counter_groups
    for id in counters:
        counter_ids += id
    return counter_ids


def calculate_kpi(counters_values, cells_ids, tput_direction, show_on_console):
    cells_list = prepare_cells_list(cells_ids)
    scf_file = download_scf()
    modulation_schme = get_modulation_scheme_settings_from_scf(scf_file, cells_list)
    bler = calculate_bler(counters_values, cells_list, tput_direction, show_on_console)
    mcs = calculate_mcs(
        counters_values, cells_list, tput_direction, modulation_schme, show_on_console
    )
    return bler, mcs


def calculate_bler(counters_values, cells_list, tput_direction, show_on_console):
    bler_dict = {}
    for cell in cells_list:
        bler_dict[cell] = {}
        logger.info(
            "\n 5G Initial BLER for cell ID: {}".format(cell),
            also_console=show_on_console,
        )
        if tput_direction.upper() == "DL" or tput_direction.upper() == "BOTH":
            try:
                dl_bler = round(
                    100
                    * (
                        sum(
                            counters_values,
                            PDSCH_INIT_TRANS_64QAM + PDSCH_INIT_TRANS_256QAM,
                            cell,
                        )
                        - sum(
                            counters_values,
                            PDSCH_SUCC_INIT_TRANS_64QAM + PDSCH_SUCC_INIT_TRANS_256QAM,
                            cell,
                        )
                    )
                    / sum(
                        counters_values,
                        PDSCH_INIT_TRANS_64QAM + PDSCH_INIT_TRANS_256QAM,
                        cell,
                    ),
                    2,
                )
            except ZeroDivisionError:
                dl_bler = "no tput"
            bler_dict[cell].update({"dl_bler": dl_bler})
            logger.info(
                "   DOWNLINK transmission in PDSCH, NR_5054a: {}".format(dl_bler),
                also_console=show_on_console,
            )
        if tput_direction.upper() == "UL" or tput_direction.upper() == "BOTH":
            try:
                ul_bler = round(
                    100
                    * (
                        sum(
                            counters_values,
                            PUSCH_INIT_TRANS_CP_OFDM_64QAM
                            + PUSCH_INIT_TRANS_DFTs_OFDM_64QAM
                            + PUSCH_INIT_TRANS_CP_OFDM_256QAM,
                            cell,
                        )
                        - sum(
                            counters_values,
                            PUSCH_SUCC_INIT_TRANS_CP_OFDM_64QAM
                            + PUSCH_SUCC_INIT_TRANS_DFTs_OFDM_64QAM
                            + PUSCH_SUCC_INIT_TRANS_CP_OFDM_256QAM,
                            cell,
                        )
                    )
                    / sum(
                        counters_values,
                        PUSCH_INIT_TRANS_CP_OFDM_64QAM
                        + PUSCH_INIT_TRANS_DFTs_OFDM_64QAM
                        + PUSCH_INIT_TRANS_CP_OFDM_256QAM,
                        cell,
                    ),
                    2,
                )
            except ZeroDivisionError:
                ul_bler = "no tput"
            bler_dict[cell].update({"ul_bler": ul_bler})
            logger.info(
                "   UPLINK transmission in PUSCH, NR_5056b: {}".format(ul_bler),
                also_console=show_on_console,
            )
    return bler_dict


def calculate_mcs(
    counters_values, cells_list, tput_direction, modulation_schme, show_on_console
):
    mcs_dict = {}
    for cell in cells_list:
        mcs_dict[cell] = {}
        logger.info(
            "\n 5G Average MCS for cell ID: {}".format(cell),
            also_console=show_on_console,
        )
        if tput_direction.upper() == "DL" or tput_direction.upper() == "BOTH":
            if modulation_schme[cell]["actDl256Qam"] == "True":
                try:
                    dl_mcs = round(
                        sum(
                            counters_values,
                            PDSCH_INIT_TRANS_256QAM,
                            cell,
                            is_mcs_numerator="yes",
                        )
                        / sum(
                            counters_values,
                            PDSCH_INIT_TRANS_256QAM,
                            cell,
                        ),
                        1,
                    )
                except ZeroDivisionError:
                    dl_mcs = "no tput"
                mcs_dict[cell].update({"dl_mcs": dl_mcs})
                logger.info(
                    "   DOWNLINK transmission in PDSCH with 256QAM table, NR_5068a: {}".format(
                        dl_mcs
                    ),
                    also_console=show_on_console,
                )
            else:
                try:
                    dl_mcs = round(
                        sum(
                            counters_values,
                            PDSCH_INIT_TRANS_64QAM,
                            cell,
                            is_mcs_numerator="yes",
                        )
                        / sum(
                            counters_values,
                            PDSCH_INIT_TRANS_64QAM,
                            cell,
                        ),
                        1,
                    )
                except ZeroDivisionError:
                    dl_mcs = "no tput"
                mcs_dict[cell].update({"dl_mcs": dl_mcs})
                logger.info(
                    "   DOWNLINK transmission in PDSCH with 64QAM table, NR_5067a: {}".format(
                        dl_mcs
                    ),
                    also_console=show_on_console,
                )
        if tput_direction.upper() == "UL" or tput_direction.upper() == "BOTH":
            if modulation_schme[cell]["actUl256Qam"] == "True":
                try:
                    ul_mcs = round(
                        sum(
                            counters_values,
                            PUSCH_INIT_TRANS_CP_OFDM_256QAM,
                            cell,
                            is_mcs_numerator="yes",
                        )
                        / sum(
                            counters_values,
                            PUSCH_INIT_TRANS_CP_OFDM_256QAM,
                            cell,
                        ),
                        1,
                    )
                except ZeroDivisionError:
                    ul_mcs = "no tput"
                mcs_dict[cell].update({"ul_mcs": ul_mcs})
                logger.info(
                    "   UPLINK transmission in PUSCH with 256QAM table, NR_5105a: {}".format(
                        ul_mcs
                    ),
                    also_console=show_on_console,
                )
            else:
                try:
                    ul_mcs = round(
                        (
                            sum(
                                counters_values,
                                PUSCH_INIT_TRANS_CP_OFDM_64QAM,
                                cell,
                                is_mcs_numerator="yes",
                            )
                            + sum(
                                counters_values,
                                PUSCH_INIT_TRANS_DFTs_OFDM_64QAM,
                                cell,
                                is_mcs_numerator="yes",
                            )
                        )
                        / (
                            sum(
                                counters_values,
                                PUSCH_INIT_TRANS_CP_OFDM_64QAM,
                                cell,
                            )
                            + sum(
                                counters_values,
                                PUSCH_INIT_TRANS_DFTs_OFDM_64QAM,
                                cell,
                            )
                        ),
                        1,
                    )
                except ZeroDivisionError:
                    ul_mcs = "no tput"
                mcs_dict[cell].update({"ul_mcs": ul_mcs})
                logger.info(
                    "   UPLINK transmission in PUSCH with 64QAM table, NR_5076b: {}".format(
                        ul_mcs
                    ),
                    also_console=show_on_console,
                )
    return mcs_dict


def sum(counters_values, counters, cell_id, is_mcs_numerator="no"):
    sum = 0
    i = 0
    for id in counters:
        if is_mcs_numerator == "yes":
            x = i
            i += 1
        else:
            x = 1
        value = x * counters_values[id][str(cell_id)]
        sum += value
    return float(sum)


def get_cell_id():
    with AdminSession(remote_host) as admin:
        cells_list = []
        cells_info = admin.get_cells_info()
        for i in range(len(cells_info)):
            cells_list.append(cells_info[i]["globalCellId"])
        return cells_list


def prepare_cells_list(cells_ids):
    if cells_ids == "ALL":
        cells_list = get_cell_id()
    else:
        cells_list = cells_ids.split(" ")
    return cells_list


def get_rsrp_real_value_vs_reported(reported_value):
    rsrp_reported_vs_real = {}
    first_real = -156
    for i in range(1, 128):
        rsrp_reported_vs_real.update({i: str(first_real)})
        first_real += 1
    return rsrp_reported_vs_real[reported_value]


def get_threshold(distname, parameter, scf_file):
    param_value = get_parameter_value_from_scf(
        path=scf_file, parameter_abbreviation=parameter, parameter_dist_name=distname)
    return get_rsrp_real_value_vs_reported(int(param_value))
