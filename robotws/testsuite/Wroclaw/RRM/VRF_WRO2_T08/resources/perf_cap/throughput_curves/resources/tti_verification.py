import re

from taf.analyzer.ttitrace_eventdecoder import TtitraceReader
from taf.converters.eventdecoder import eventdecoder

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import \
    Averager

_names_table = {
    "dl_pathloss": {"msg": "ulLaPhr", "param": "dlPathloss"},
    "ul_pathloss": {"msg": "ulLaPhr", "param": "ulPathloss"},
    "phr_scaled": {"msg": "ulLaPhr", "param": "rrmPhrScaled"},
    "phr": {"msg": "ulLaPhr", "param": "phr"},
    "ul_avg_sinr": {"msg": "ulAvgSinr", "param": "avgSinr"},
    "dl_tx_number": {"msg": "dlFdSchedData", "param": "txNumber"},
    "dl_proposed_mcs": {"msg": "dlFdSchedData", "param": "rrmDlProposedMcs"},
    "dl_used_mcs": {"msg": "dlFdSchedData", "param": "rrmDlUsedMcs"},
    "dl_prb": {"msg": "dlFdSchedData", "param": "numOfPrb"},
    "dl_rank": {"msg": "dlFdSchedData", "param": "numOfLayers"},
    "ul_tx_number": {"msg": "ulFdSchedData", "param": "txNumber"},
    "ul_proposed_mcs": {"msg": "ulFdSchedData", "param": "rrmUlProposedMcs"},
    "ul_used_mcs": {"msg": "ulFdSchedData", "param": "rrmUlUsedMcs"},
    "ul_prb": {"msg": "ulFdSchedData", "param": "numOfPrb"},
    "ul_rank": {"msg": "ulFdSchedData", "param": "numOfLayers"},
    "la_delta_sinr": {"msg": "ulLaDeltaSinr", "param": "rrmDeltaSinr"},
    "la_bler": {"msg": "ulLaDeltaSinr", "param": "bler"},
    "ul_bler": {"msg": "ulHarqRxData", "param": "crcResult"},
    "dl_bler": {"msg": "dlHarqRxDataArray", "param": "ackNack"},
    "pusch_delta_sinr": {"msg": "ulPuschReceiveRespPsData", "param": "rrmDeltaSinr"},
    "post_eq_rank1_sinr": {"msg": "ulPuschReceiveRespPsData", "param": "rrmUlPostEqRank1SinrPuschLT"},
    "post_eq_rank2_sinr": {"msg": "ulPuschReceiveRespPsData", "param": "rrmUlPostEqRank2SinrPuschLT"},
    "pmi_rank1_sinr": {"msg": "ulPuschReceiveRespPsData", "param": "ulPmiRank1Sinr"},
    "pmi_rank1_sinr_lt": {"msg": "ulPuschReceiveRespPsData", "param": "rrmUlPmiRank1SinrPuschLT"},
    "pmi_rank2_sinr_lt": {"msg": "ulPuschReceiveRespPsData", "param": "rrmUlPmiRank2SinrPuschLT"},
}


def analyze_tti(pcap_path: str, output_file_path: str, param_names: list[str]) -> Averager:
    """
    Analyze TTI and extract values specified in param_names using definitions from global names_table dict. TTI
    should be in pcap format which is converted to json for analysis.
    :param str pcap_path: Path to .pcap file containing TTI trace
    :param str output_file_path: Path to .json file which results from pcap conversion.
    :param list[str] param_names: Parameters that are subject for analysis. Name should be a key from
                                  names_table with optional _$<value> suffix for getting count of concrete values
    :returns Averager: dict-like Averager object containing parameter statistics.
    """
    msg_lookup = _get_specific_msg_name_lookup(param_names)
    avg = Averager()
    ed = eventdecoder()
    ed.create_eventdecoder_converter(
        name="converter", input_file_path=pcap_path, output_file_format="json", output_file_path=output_file_path
    )
    ed.convert(name="converter")
    with open(f"{output_file_path}.json", "rb") as file_obj:
        for event in TtitraceReader(file_obj=file_obj):
            if event.type in msg_lookup:
                for param_dict in msg_lookup[event.type]:
                    if param_dict["param"] in event.data:
                        _process_data(avg, event.data[param_dict["param"]], param_dict)
                    else:
                        if "nestedArray" in event.data:
                            for msg_data in event.data["nestedArray"]:
                                _process_data(avg, msg_data[param_dict["param"]], param_dict)
    return avg


def _process_data(avg, data, param_dict):
    alias = param_dict["alias"]
    if isinstance(data, str) and data.lower() == "nan":
        return
    if "l_rank" in alias:
        data = data[-1]
    if "l_bler" in alias:
        data = 100 if data.upper() in ("NOK", "NACK", "DTX") else 0
    if param_dict["per_value"]:
        alias = f"{alias}_{data}"
    data = float(data)
    avg.update({alias: data})


def _get_specific_msg_name_lookup(param_names):
    lookup = {}
    for param in param_names:
        per_value = False
        if param not in _names_table:
            if "_$" in param:
                param = re.split(r"_\$", param)[0]
                per_value = True
            else:
                raise KeyError(
                    f"Parameter {param} not recognised in tti parser. All params: {list(_names_table.keys())}"
                )
        msg = _names_table[param]["msg"]
        real_param_name = _names_table[param]["param"]
        if msg not in lookup:
            lookup[msg] = [{"alias": param, "param": real_param_name, "per_value": per_value}]
        else:
            lookup[msg].append({"alias": param, "param": real_param_name, "per_value": per_value})
    return lookup
