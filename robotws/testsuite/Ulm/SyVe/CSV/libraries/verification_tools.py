import logging
import csv
import json
import os
import re
import traceback
import pandas as pd
import warnings
import pprint

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# SyVe Specific Libraries:
from testsuite.Ulm.SyVe.CSV.libraries.common_tools import log_begin_end_func_name


# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]

rbi = BuiltIn()
df = None


@log_begin_end_func_name
def verify_sa_tput_pmcounters(pmc_csv_file, duration_seconds, expected_dl_mbps, expected_ul_mbps):
    is_kpi_5094_correct = False  # 5G SA PDCP SDU throughput in Downlink
    is_kpi_5095_correct = False  # 5G SA PDCP SDU throughput in Uplink
    try:
        separator = get_separator_for_csv_file(pmc_csv_file)
        df = pd.read_csv(pmc_csv_file, sep=separator, low_memory=False)
        # --- Check Point #1: -------------------------------------------------------------------------[120 characters]
        dl_vol_tx_sa = df[df['PI_ID'].str.startswith('M55319C120')].iloc[:, -3:-2].astype('int64').sum() * 8
        logging.info("dl_vol_tx_sa = %s" % dl_vol_tx_sa)
        logging.info("len(dl_vol_tx_sa) = %s" % len(dl_vol_tx_sa))
        dl_vol_tx_sa_int = dl_vol_tx_sa.tolist()[-1]
        logging.info("dl_vol_tx_sa_int = %s" % dl_vol_tx_sa_int)
        kpi_5094 = float(dl_vol_tx_sa_int) / float(duration_seconds) / 1000.0
        logging.info("kpi_5094 = %s Mbps" % kpi_5094)
        is_kpi_5094_correct = int(kpi_5094) >= int(expected_dl_mbps)
        # --- Check Point #2: -------------------------------------------------------------------------[120 characters]
        ul_vol_tx_sa = df[df['PI_ID'].str.startswith('M55319C160')].iloc[:, -3:-2].astype('int64').sum() * 8
        logging.info("ul_vol_tx_sa = %s" % ul_vol_tx_sa)
        logging.info("len(ul_vol_tx_sa) = %s" % len(ul_vol_tx_sa))
        ul_vol_tx_sa_int = ul_vol_tx_sa.tolist()[-1]
        logging.info("ul_vol_tx_sa_int = %s" % ul_vol_tx_sa_int)
        kpi_5095 = float(ul_vol_tx_sa_int) / float(duration_seconds) / 1000.0
        logging.info("kpi_5095 = %s Mbps" % kpi_5095)
        is_kpi_5095_correct = int(kpi_5095) >= int(expected_ul_mbps)
    # -------------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_SA_Tput", e)
    logging.info("is_kpi_5094_correct = %s" % is_kpi_5094_correct)
    logging.info("is_kpi_5095_correct = %s" % is_kpi_5095_correct)
    return (is_kpi_5094_correct and is_kpi_5095_correct)


@log_begin_end_func_name
def get_kpis_from_pmcounters(pmc_csv_filepath, kpi_json_file, list_of_kpi_ids_to_skip=[]):
    calculated_kpi_list = []
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        logging.info("script_dir = %s" % script_dir)
        with open(os.path.join(script_dir, kpi_json_file), 'r') as file:
            kpis_dict = json.load(file)
        for kpi_id, kpi_info in kpis_dict.items():
            if kpi_id not in list_of_kpi_ids_to_skip:
                kpi_units = kpi_info['units']
                kpi_name = kpi_info['name']
                kpi_formula = kpi_info['formula']
                calculated_kpi_list.append(calculate_kpi(pmc_csv_filepath, kpi_id, kpi_units, kpi_name, kpi_formula))
        # ---------------------------------------------------------------------------------------------[120 characters]
        log_dir = os.path.dirname(pmc_csv_filepath)
        logging.info("log_dir = %s" % log_dir)
        with open(os.path.join(log_dir, "kpis.csv"), mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerows(calculated_kpi_list)
        # ---------------------------------------------------------------------------------------------[120 characters]
        log_dir_splited = log_dir.split('/')
        logging.info("log_dir_splited = %s" % log_dir_splited)
        local_kpi_filepath = os.path.join("/mnt/etfiles/users/CSV/KPIs",
                                          "%s_%s_%s.csv" % (log_dir_splited[4].replace('7_15_UTESRAN', ''),
                                                            log_dir_splited[9].replace('pmc_', ''),
                                                            log_dir_splited[6]))
        logging.info("local_kpi_filepath = %s" % local_kpi_filepath)
        with open(local_kpi_filepath, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerows(calculated_kpi_list)
    except Exception as e:
        logException("get_kpis_from_pmcounters", e)
    return calculated_kpi_list


def calculate_kpi(pmc_csv_filepath, kpi_id, kpi_units, kpi_name, kpi_formula):
    kpi_output = "not calculated: not available or all zeros with devision"
    try:
        with warnings.catch_warnings():
            # NOTE: the line below is added to suppress all warnings that would be raised each time a division
            #       by zero happens, e.g. errors such as
            #        '<string>:1: RuntimeWarning: invalid value encountered in scalar divide'
            warnings.filterwarnings('ignore',
                                    r'(invalid value|divide by zero) encountered in scalar (divide|multiply)')
            used_pmcounters_list = re.findall(r'\b[A-Za-z_][A-Za-z0-9_]*\b', kpi_formula)
            variables = get_pmcounters_values(pmc_csv_filepath, used_pmcounters_list)
            result = float(eval(kpi_formula, {}, variables))
            kpi_output = [kpi_id, f"{result:.7f}", kpi_units, kpi_name]
    except Exception as e:
        kpi_output = [kpi_id, "-", kpi_units, kpi_name]
    return kpi_output


def get_pmcounters_values(pmc_csv_filepath, pmcounters_list, number_of_columns=1):
    global df
    pmcounters_dict = {}
    number_of_columns = int(number_of_columns)
    try:
        if not isinstance(df, pd.DataFrame):
            separator = get_separator_for_csv_file(pmc_csv_filepath)
            df = pd.read_csv(pmc_csv_filepath, sep=separator, low_memory=False)
            logging.info("df = %s" % df)
            cols_to_keep = [0] + list(range(-2-number_of_columns, -2))
            logging.info("cols_to_keep = %s" % cols_to_keep)
            df = df.iloc[:, cols_to_keep]
            logging.info("df (before NEW) = %s" % df)
            cols_to_sum = df.columns[1:].tolist()
            logging.info("cols_to_sum = %s" % cols_to_sum)
            for col in cols_to_sum:
                df[col] = pd.to_numeric(df[col], errors='coerce')
            row_sum = df[cols_to_sum].sum(axis=1, skipna=True)
            all_nan_mask = df[cols_to_sum].isna().all(axis=1)
            row_sum[all_nan_mask] = float('nan')
            df['sum'] = row_sum
            pi_id_column_name = df.columns[0]
            df = df[[pi_id_column_name, 'sum']].copy()
            logging.info("df (NEW) = %s" % df)
        for piid in pmcounters_list:
            pmc_value = (df.iloc[:, 0] == piid) * df.iloc[:, 1]
            pmcounters_dict[piid] = pmc_value.sum()
    except Exception as e:
        logException("get_pmcounters_values", e, with_warnings=False)
    return pmcounters_dict


def get_separator_for_csv_file(csv_filepath):
    try:
        with open(csv_filepath, 'r') as f:
            first_line = f.readline()
            logging.info("first_line = %s" % first_line)
            return "," if "," in first_line else ";"
    except FileNotFoundError:
        return None


@log_begin_end_func_name
def get_kpis_info_from_kpi_csv(pmc_csv_filepath, type_of_benchmark="throughput_dl"):
    kpi_str = ""
    type_of_benchmark = type_of_benchmark.lower()
    # -------------------------------------------------------------------------------------------------[120 characters]
    needed_kpis = {"throughput_dl": {"5054": {"info": "INIT_BLER"},  # Initial BLER in PDSCH
                                     "5055": {"info": "RE_BLER"},  # Residual BLER for PDSCH
                                     "5067": {"info": "AVG_MCS_64QAM"},  # Avg. MCS used for PDSCH with 64QAM table
                                     "5068": {"info": "AVG_MCS_256QAM"},  # Avg. MCS used for PDSCH with 256QAM table
                                     "6234": {"info": "Ratio_QPSK"},  # Ratio of PDUs using QPSK in DL
                                     "6235": {"info": "Ratio_16QAM"},  # Ratio of PDUs using 16QAM in DL
                                     "6236": {"info": "Ratio_64QAM"},  # Ratio of PDUs using 64QAM in DL
                                     "5058": {"info": "Ratio_256QAM"},  # Ratio of PDUs using 256QAM in DL
                                     "5114": {"info": "PRBs"},  # PRB utilization for PDSCH
                                     "5060": {"info": "AVG_CQI_64QAM"},  # Average wideband CQI, 64QAM table
                                     "5061": {"info": "AVG_CQI_256QAM"},  # Average wideband CQI, 256QAM table
                                     "5069": {"info": "RANK"}},  # Average Rank used in DL
                   "throughput_ul": {"5056": {"info": "INIT_BLER"},  # Initial BLER in PUSCH
                                     "5057": {"info": "RE_BLER"},  # Residual BLER in PUSCH
                                     "5076": {"info": "AVG_MCS_64QAM"},  # Avg. MCS used for PUSCH with 64QAM able
                                     "5105": {"info": "AVG_MCS_256QAM"},  # Avg. MCS used for PUSCH with 256QAM table
                                     "6237": {"info": "Ratio_QPSK"},  # Ratio of PDUs using QPSK in UL
                                     "6238": {"info": "Ratio_16QAM"},  # Ratio of PDUs using 16QAM in UL
                                     "6239": {"info": "Ratio_64QAM"},  # Ratio of PDUs using 64QAM in UL
                                     "5059": {"info": "Ratio_256QAM"},  # Ratio of PDUs using 256QAM in UL
                                     "9999": {"info": "Ratio_Rank1"},  # Ratio of PUSCH transmissions in Rank 1 (CSV)
                                     "9998": {"info": "Ratio_Rank2"},  # Ratio of PUSCH transmissions in Rank 2 (CSV)
                                     "5115": {"info": "PRBs"}},  # PRB utilization for PUSCH
                   "rtt": {"70": {"info": "Delay_DL"},  # Average PDCP SDU delay in DL
                           "71": {"info": "Delay_UL"},  # Average PDCP SDU delay in UL
                           "5050": {"info": "F1_RTT"}}}  # Average estimated F1 round trip delay between CU and MAC DU
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        log_dir = os.path.dirname(pmc_csv_filepath)
        logging.info("script_dir = %s" % log_dir)
        df = pd.read_csv(os.path.join(log_dir, "kpis.csv"), header=None)
        logging.info("df = %s" % df)
        for kpi_id in needed_kpis[type_of_benchmark].keys():
            filtered = df[df.iloc[:, 0].str.contains("NR_%s" % kpi_id, case=False, na=False)]
            if not filtered.empty and str(filtered.iloc[0, 1]) not in ['-', 'nan']:
                reported_value = filtered.iloc[0, 1]
                value_str = reported_value if reported_value in ['inf'] else str(int(float(reported_value)))
                needed_kpis[type_of_benchmark][kpi_id]["value"] = value_str
            else:
                needed_kpis[type_of_benchmark][kpi_id]["value"] = "-"
        kpi_dict = needed_kpis[type_of_benchmark]
        if type_of_benchmark == "throughput_dl":
            kpi_str = f"NR_5054b [{kpi_dict['5054']['info']}]: {kpi_dict['5054']['value']} % | " \
                      f"NR_5055c [{kpi_dict['5055']['info']}]: {kpi_dict['5055']['value']} % | " \
                      f"NR_5067a [{kpi_dict['5067']['info']}] (ratio NR_6236a): " \
                      f"{kpi_dict['5067']['value']} ({kpi_dict['6236']['value']} %) | " \
                      f"NR_5068a [{kpi_dict['5068']['info']}] (ratio NR_5058b): " \
                      f"{kpi_dict['5068']['value']} ({kpi_dict['5058']['value']} %) | " \
                      f"NR_5060b [{kpi_dict['5060']['info']}] (ratio NR_6236a): " \
                      f"{kpi_dict['5060']['value']} ({kpi_dict['6236']['value']} %) | " \
                      f"NR_5061b [{kpi_dict['5061']['info']}] (ratio NR_5058b): " \
                      f"{kpi_dict['5061']['value']} ({kpi_dict['5058']['value']} %) | " \
                      f"NR_5114b [{kpi_dict['5114']['info']}]: {kpi_dict['5114']['value']} | " \
                      f"NR_5069a [{kpi_dict['5069']['info']}]: {kpi_dict['5069']['value']}"
        elif type_of_benchmark == "throughput_ul":
            kpi_str = f"NR_5056d [{kpi_dict['5056']['info']}]: {kpi_dict['5056']['value']} % | " \
                      f"NR_5057e [{kpi_dict['5057']['info']}]: {kpi_dict['5057']['value']} % | " \
                      f"NR_5076b [{kpi_dict['5076']['info']}] (ratio NR_6239a): " \
                      f"{kpi_dict['5076']['value']} ({kpi_dict['6239']['value']} %) | " \
                      f"NR_5105a [{kpi_dict['5105']['info']}] (ratio NR_5059b): " \
                      f"{kpi_dict['5105']['value']} ({kpi_dict['5059']['value']} %) | " \
                      f"NR_9999 [{kpi_dict['9999']['info']}]: {kpi_dict['9999']['value']} % | " \
                      f"NR_9998 [{kpi_dict['9998']['info']}]: {kpi_dict['9998']['value']} % | " \
                      f"NR_5115a [{kpi_dict['5115']['info']}]: {kpi_dict['5115']['value']}"
        elif type_of_benchmark == "rtt":
            kpi_str = f"NR_70b [{kpi_dict['70']['info']}]: {kpi_dict['70']['value']} µs | " \
                      f"NR_71b [{kpi_dict['71']['info']}]: {kpi_dict['71']['value']} µs | " \
                      f"NR_5050b [{kpi_dict['5050']['info']}]: {kpi_dict['5050']['value']} ms"
    except Exception as e:
        logException("get_kpis_info_from_kpi_csv", e)
    return kpi_str


def logException(functionNameStr, e, with_warnings=True):
    if with_warnings:
        logging.warning("%s(): Exception = <%s>" % (functionNameStr, str(e)))
        logging.warning(traceback.format_exc())
