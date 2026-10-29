
import argparse
import logging
import json
import pathlib
import re
from collections import defaultdict
import prettytable

import pandas as pd

from testsuite.Ulm.resources.Common.python import pmcounters
from testsuite.Ulm.ET.Performance_Test.resources.python import scripts

logger = logging.getLogger(__name__)

PIID_DICTIONARY = {
    # Throughput
    "M55326C00501": "PDCP SDU user DL data volume per PLMN-ID for SA user - SA_DL_TPUT_COUNTER",
    "M55326C00502": "PDCP SDU user UL data volume per PLMN-ID for SA user - SA_UL_TPUT_COUNTER",

    # TTI
    "M55308C17001": "Accumulated number of scheduled (FDM and MU-MIMO) UEs on PDSCH per slot",
    "M55308C18001": "Accumulated number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot",
    "M55308C17002": "Maximum number of scheduled (FDM and MU-MIMO) UEs on PDSCH per slot",
    "M55308C18002": "Maximum number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot",

    # Beamforming
    "M55305C01001": "UL_SERV_BEAM_ID_BEAM_00",
    "M55305C01002": "UL_SERV_BEAM_ID_BEAM_01",
    "M55305C00001": "DL_SERV_BEAM_ID_BEAM_00",
    "M55305C00002": "DL_SERV_BEAM_ID_BEAM_01",
}

ACTFLOWCONTROLLBALANCE_COUNTERS = {
    "M55308C02000": "Accumulated number of UEs with DL DRB data buffered",
    "M55308C02002": "Accumulated number of UEs with UL DRB data buffered",
    "M55328C00006": "DL PDCP SDU delay per slice per PLMN"
}

ALL_PIID_DICTIONARY = defaultdict(lambda: "TBA")
ALL_PIID_DICTIONARY.update({
    **PIID_DICTIONARY,
    **ACTFLOWCONTROLLBALANCE_COUNTERS,
})


def get_all_counters(pi_dir: str, index: int = -1, inactive_cells: list = None,
                     ignore_zero: bool = True) -> dict:
    """Generates a dictionary with all pmcounters for performance

    :param pi_dir: directory where PM files are saved
    :param refresh_counters: creates a new global dictionary
    :return: dictionary with all pmcounters in the following format
                Format e.x.: {
                                "M55326C00501" :
                                {
                                    "MRBTS-31207/NRBTS-31207/PLMN-PLMN/MCC-311/MNC-488" : 0,
                                    "MRBTS-31207/NRBTS-31207/PLMN-PLMN/MCC-311/MNC-489" : 0
                                },
                                "M55326C00502" :
                                {
                                    "MRBTS-31207/NRBTS-31207/PLMN-PLMN/MCC-311/MNC-488" : 0,
                                    "MRBTS-31207/NRBTS-31207/PLMN-PLMN/MCC-311/MNC-489" : 0
                                },
                            }
    """
    return get_counter_dictionary_using_pd(pi_dir, [
        *PIID_DICTIONARY.keys(),
        *ACTFLOWCONTROLLBALANCE_COUNTERS.keys(),
        *create_pm_counter_range(55310, 5001, 5020)  # DL RLC DELAY L QOS GRP,
    ], index=index, inactive_cells=inactive_cells, ignore_zero=ignore_zero)


def get_counter_dictionary_using_pd(pi_dir: str, counters: list, index: int = -1, inactive_cells: list = None,
                                    ignore_zero: bool = True) -> dict:
    """
    :param pi_dir: directory where PM files are saved
    :param counters: list of counters to fetch
    :param index: -1 for the last measurement
    :return: dictionary with all pmcounters in the following format
        {
            '< pm Name: str >' : {
                "distnames" : {
                    < distname: str > : < INT >,
                    ...
                }
            },
            ...
        }
    """
    try:
        pm_dict = pmcounters.get_pi_dict(pi_dir, counters)
    except TypeError:
        logger.error("get_pi_dict error: please check pi dir: %s", pi_dir)
        return {}
    except PermissionError as e:
        logger.error("get_pi_dict PermissionError: please check pi dir: %s\n%s", pi_dir, e)
        return {}
    with open(pathlib.Path(pi_dir).parent.joinpath('pm_dict.json'), 'w', encoding='utf-8') as fwrite:
        json.dump(pm_dict, fwrite, indent=4)
    try:
        df = pd.DataFrame(pm_dict).T.iloc[int(index)]
    except IndexError as e:
        logger.exception(e)
        return {}
    df = pd.DataFrame(df).T
    frames = []
    for counter in counters:
        new_frame = pd.json_normalize(df[counter]).T
        new_frame.columns = [counter]
        frames.append(new_frame)
    df = pd.concat(frames, axis=1).astype('Int64')
    if inactive_cells is not None:
        remove_inactive_cells(df, inactive_cells)
    df.loc['mean'] = df.astype(float).mean()
    result = df.apply(lambda x: [x.dropna()], axis=0).to_json()
    parsed = json.loads(result)
    with open(pathlib.Path(pi_dir).parent.joinpath('parsed.json'), 'w', encoding='utf-8') as fwrite:
        json.dump(parsed, fwrite, indent=4)
    parsed_clean = {}
    for key, value in parsed.items():
        data = value.get("0", {'mean': 0})
        if ignore_zero and data.get('mean', 0) == 0:
            continue
        parsed_clean.update({
            key: {
                "distnames": data
            }
        })
    with open(pathlib.Path(pi_dir).parent.joinpath('parsed_clean.json'), 'w', encoding='utf-8') as fwrite:
        json.dump(parsed_clean, fwrite, indent=4)
    return parsed_clean


def get_pmc_tput(pmfile, interval: int = 300, rate: str = 'mbps', index=-1, inactive_cells: list = None) -> dict:
    logger.debug("===== start get_pmc_tput from file: %s", pmfile)
    counters = ['M55326C00501', 'M55326C00502']
    counter_dict = get_counter_dictionary_using_pd(pmfile, counters, index=index, inactive_cells=inactive_cells)
    counter_info = {}
    for counter in counters:
        counter_data = {}
        try:
            counter_dists = counter_dict.get(counter, {"distnames": {"mean": 0}})['distnames']
            mean = counter_dists.pop("mean") if "mean" in counter_dists else 0
            total = 0
            for key, value in counter_dists.items():
                dist = f"../{key.split('/')[-2]}/{key.split('/')[-1]}"
                counter_data.update({
                    dist: f"{scripts.convert_pmc_tput_to_rate(value, interval=interval, rate=rate)} {rate}"
                })
                total = total + value
            counter_data.update({
                    "[total]": f"{scripts.convert_pmc_tput_to_rate(total, interval=interval, rate=rate)} {rate}",
                    "[mean]": f"{scripts.convert_pmc_tput_to_rate(mean, interval=interval, rate=rate)} {rate}",
                })
        except KeyError as e:
            logger.debug("get_pmc_tput, KeyError : %s", e)
        except TypeError as e:
            logger.debug("get_pmc_tput, TypeError : %s", e)
        counter_info[counter] = counter_data
    logger.debug("===== end get_pmc_tput")
    return counter_info


def get_pmc_tput_as_table(*args, **kwargs):
    counter_info = get_pmc_tput(*args, **kwargs)
    ptable = prettytable.PrettyTable(['Obj', 'UL (M55326C00502)', 'DL (M55326C00501)'])
    dlkeys = counter_info.get("M55326C00501", {}).keys()
    ulkeys = counter_info.get("M55326C00502", {}).keys()
    keys = dlkeys if len(dlkeys) > len(ulkeys) else ulkeys
    if len(keys) > 0:
        for key in keys:
            ptable.add_row([key,
                            counter_info["M55326C00502"].get(key, "n/a"),
                            counter_info["M55326C00501"].get(key, "n/a"),])
    ptable.align = "r"
    return str(ptable)


def remove_inactive_cells(df, cells):
    if cells is not None:
        for index in list(df.index):
            for cell in cells:
                if f"NRCELL-{cell}" in index:
                    df = df.drop([index])
    return df


def create_pm_counter_range(measurement_id, start, end):
    counters = []
    for i in range(int(start), int(end)+1):
        number = "{:0>5}".format(i)
        counters.append(f"M{measurement_id}C{number}")
    return counters


def natural_sort(text):
    return [(lambda text: int(text) if text.isdigit() else text)(c) for c in re.split(r'(\d+)', text)]


def main():
    logger.info("pmcounter_manager.py")
    parser = argparse.ArgumentParser(description='pmcounter_manager.py')
    parser.add_argument('--pmdir')
    parser.add_argument('--index', default='-1')
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s|%(levelname)-5.5s|%(module)s.%(funcName)s:%(lineno)d:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    pmdir = pathlib.Path(args.pmdir)
    pi_dict = pmcounters.get_pi_dict(str(pmdir), ALL_PIID_DICTIONARY.keys())
    with open(pmdir.joinpath('pmcounter_common.json'), 'w', encoding='utf-8') as f:
        json.dump(pi_dict, f)

    all_counters = get_all_counters(str(pmdir), index=args.index)

    with open(pmdir.joinpath('pmcounter.json'), 'w', encoding='utf-8') as f:
        json.dump(all_counters, f)


if __name__ == "__main__":
    main()
