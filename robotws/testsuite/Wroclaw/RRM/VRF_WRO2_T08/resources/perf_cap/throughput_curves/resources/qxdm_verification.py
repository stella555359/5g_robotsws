from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.qxdm_verification import \
    analyze_qxdm_log
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import \
    Averager
import re

names_table = {
    "rsrp": {
        "msg": "NR5G ML1 Searcher Measurement Database Update Ext",
        "param": "NR2NR Filtered Tx Beam RSRP L3",
        "index": 0,
    },
    "rsrq": {
        "msg": "NR5G ML1 Searcher Measurement Database Update Ext",
        "param": "NR2NR Filtered Tx Beam RSRQ L3",
        "index": 0,
    },
    "pathloss": {
        "msg": "NR5G LL1 FW MAC TX IU Power",
        "param": "Pathloss_1",
        "index": 0,
    },
    "mtpl": {
        "msg": "NR5G LL1 FW MAC TX IU Power",
        "param": "PHR MTPL_1",
        "index": 0,
    },
    "cqi": {
        "msg": "NR5G MAC CSF Report",
        "param": "WB CQI_1",
        "index": 0,
    },
    "dl_rank": {
        "msg": "NR5G MAC PDSCH Status",
        "param": "Num Layers",
        "index": 0,
    },
    "dl_bler": {
        "msg": "QTRACE_DL_NR_throughput",
        "param": "bler",
        "index": None,
    },
    "dl_mcs": {
        "msg": "QTRACE_DL_NR_throughput",
        "param": "avgmcs",
        "index": None,
    },
    "dl_prb": {
        "msg": "QTRACE_DL_NR_throughput",
        "param": "avgrb",
        "index": None,
    },
    "dl_tput": {
        "msg": "QTRACE_DL_NR_throughput",
        "param": "avgphy",
        "index": None,
        "multiplier": 0.001,
    },
    "ul_bler": {
        "msg": "QTRACE_UL_NR_throughput",
        "param": "bler",
        "index": None,
    },
    "ul_mcs": {
        "msg": "QTRACE_UL_NR_throughput",
        "param": "avgmcs",
        "index": None,
    },
    "ul_prb": {
        "msg": "QTRACE_UL_NR_throughput",
        "param": "avgprb",
        "index": None,
    },
    "ul_tput": {
        "msg": "QTRACE_UL_NR_throughput",
        "param": "avgphy",
        "index": None,
        "multiplier": 0.001,
    },
    "rx1_sinr": {
        "msg": "NR5G LL1 LOG SERVING SNR",
        "param": "RX[0]_SNR",
        "index": 0,
        "non_floats_process": lambda x: float("nan") if x == "NA" else float(x[:-3]),
    },
    "rx2_sinr": {
        "msg": "NR5G LL1 LOG SERVING SNR",
        "param": "RX[1]_SNR",
        "index": 0,
        "non_floats_process": lambda x: float("nan") if x == "NA" else float(x[:-3]),
    },
    "rx3_sinr": {
        "msg": "NR5G LL1 LOG SERVING SNR",
        "param": "RX[2]_SNR",
        "index": 0,
        "non_floats_process": lambda x: float("nan") if x == "NA" else float(x[:-3]),
    },
    "rx4_sinr": {
        "msg": "NR5G LL1 LOG SERVING SNR",
        "param": "RX[3]_SNR",
        "index": 0,
        "non_floats_process": lambda x: float("nan") if x == "NA" else float(x[:-3]),
    },
    "rssi": None,
    "sinr": None,
    "dl_ibler": None,
    "dl_ip_tput": {
        "msg": "QTRACE_DL_L2_throughput",
        "param": "ipaap",
        "index": None,
        "multiplier": 0.001,
    },
    "dl_pdcp_tput": {
        "msg": "QTRACE_DL_L2_throughput",
        "param": "pdcp",
        "index": None,
        "multiplier": 0.001,
    },
    "dl_rlc_tput": {
        "msg": "QTRACE_DL_L2_throughput",
        "param": "rlc",
        "index": None,
        "multiplier": 0.001,
    },
    "ul_ip_tput": {
        "msg": "QTRACE_UL_L2_throughput",
        "param": "[ipa",
        "index": None,
        "multiplier": 0.001,
    },

    "rx1_rsrp": None,
    "rx2_rsrp": None,
    "rx3_rsrp": None,
    "rx4_rsrp": None,
    "rx1_rssi": None,
    "rx2_rssi": None,
    "rx3_rssi": None,
    "rx4_rssi": None,
}


def get_stats_from_qxdm_log(qxdm_log: str, names: list[str]) -> Averager:
    """
    Analyze QXDM txt log and extract values specified in param_names using definitions from global names_table dict.
    :param str qxdm_log: Path to .txt file containing qxdm messages
    :param list[str] names: Parameters that are subject for analysis. Name should be a key from
                                  names_table with optional _$<value> suffix for getting count of concrete values
    :returns Averager: dict-like Averager object containing parameter statistics.
    """

    raw = analyze_qxdm_log(
        qxdm_log,
        [
            "QTrace Messages",
            "NR5G ML1 Searcher Measurement Database Update Ext",
            "NR5G MAC PDSCH Status",
            "NR5G MAC CSF Report",
            "NR5G LL1 FW MAC TX IU Power",
            "NR5G LL1 LOG SERVING SNR",
        ],
        [
            "avgphy",
            "bler",
            "avgmcs",
            "avgrb",
            "NR2NR Filtered Tx Beam RSRP L3",
            "NR2NR Filtered Tx Beam RSRQ L3",
            "WB CQI_1",
            "Num Layers",
            "Pathloss_1",
            "PHR MTPL_1",
            "RX[0]_SNR",
            "RX[1]_SNR",
            "RX[2]_SNR",
            "RX[3]_SNR",
            "ipaap",
            "pdcp",
            "rlc",
            "[ipa"
        ],
    )
    return convert_to_averager(raw, names)


def _get_specific_msg_name_lookup(param_names):
    lookup = {}
    for param in param_names:
        per_value = False
        if param not in names_table:
            if "_$" in param:
                param = re.split(r"_\$", param)[0]
                per_value = True
            else:
                raise KeyError(
                    f"Parameter {param} not recognised in tti parser. All params: {list(names_table.keys())}"
                )
        if names_table[param] is None:
            continue
        msg = names_table[param]["msg"]
        real_param_name = names_table[param]["param"]
        index = names_table[param]["index"]
        mult = names_table[param].get("multiplier", 1)
        nfp = names_table[param].get("non_floats_process", lambda x: x)
        if msg not in lookup:
            lookup[msg] = [
                {
                    "alias": param,
                    "param": real_param_name,
                    "index": index,
                    "multiplier": mult,
                    "non_floats_process": nfp,
                    "per_value": per_value,
                }
            ]
        else:
            lookup[msg].append(
                {
                    "alias": param,
                    "param": real_param_name,
                    "index": index,
                    "multiplier": mult,
                    "non_floats_process": nfp,
                    "per_value": per_value,
                }
            )
    return lookup


def convert_to_averager(raw_data, param_names):
    avg = Averager()
    msg_lookup = _get_specific_msg_name_lookup(param_names)
    for msg, params in raw_data.items():
        if msg in msg_lookup:
            for param_dict in msg_lookup[msg]:
                alias = param_dict["alias"]
                index = param_dict["index"]
                mult = param_dict["multiplier"]
                nfp = param_dict["non_floats_process"]
                per_value = param_dict["per_value"]
                if index is None:
                    data = params[param_dict["param"]]
                else:
                    data = params[param_dict["param"]][index]
                embedd_data_in_averager(data, avg, alias, mult, nfp, per_value)
    return avg


def embedd_data_in_averager(data, avg, alias, multi, nfp, per_data):
    if data['min'] > 9999999999:
        for non_float in data["values"]["non_floats"]:
            if non_float == 'count':
                continue
            value = nfp(non_float) * multi
            new_alias = f"{alias}_{value}" if per_data else alias
            avg.update({new_alias: value})
        return
    if data["count"] > 0:
        value = data["min"] * multi
        new_alias = f"{alias}_{value}" if per_data else alias
        avg.update({new_alias: float(value)})

    if data["count"] > 1:
        value = data["max"] * multi
        new_alias = f"{alias}_{value}" if per_data else alias
        avg.update({new_alias: float(value)})

    for _ in range(data["count"] - 2):
        value = data["avg"] * multi
        new_alias = f"{alias}_{value}" if per_data else alias
        avg.update({new_alias: float(value)})
