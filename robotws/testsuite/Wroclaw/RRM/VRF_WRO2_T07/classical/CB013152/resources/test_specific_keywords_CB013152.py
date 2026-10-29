import logging
from locale import str
import builtins
from typing import re

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB007564.resources.test_specific_keywords_7564 import atten, tcpdump
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import au
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from taf.collectors.pmcounters import pmcounters
from taf.analyzer.pmcounter.interface import pmcounter
from collections.abc import Mapping
from builtins import str as py_str
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder, LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import load_scf, wait_for_online_state
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher

l1l2 = L1L2()
mrbts_id = 55200  # for purpose of problem
nrbts_id = tl.gnbs[0].instance_id


def preparing_for_prb_blanking_13152(handover='handover', bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actDynUlResAlloc', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actDynUlResAllocPhase2', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actLongPucchResourceOpt', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actPRBBlanking', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'nbrOfBlankedPRBsHighEdgeUL', '26')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRCELL_FDD-1',
                          'nrarfcnDl', '397000')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRCELL_FDD-1',
                          'nrarfcnUl', '381000')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-22')
    ds.add_complex_item_to_delta(nrbts_object + '/BWP_PROFILE-7',
                                 'locationAndBandwidthUl', cRbSizeUl='n80', cRbStartUl="crb0")
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    logging.debug("------------------Preconditions for PRB BLANKING-------------------------")
    au.wait_for_all_cells_on_air_state(cell_type='nr')
    atten.initialise_attenuator()
    logging.debug("attenuating target cell")
    atten.set_attenuation(value_string='0', ports=[11, 12])
    atten.set_attenuation(value_string='90', ports=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10])


def deactivating_for_prb_blanking_13152(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actDynUlResAlloc', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actDynUlResAllocPhase2', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actLongPucchResourceOpt', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'actPRBBlanking', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'nbrOfBlankedPRBsHighEdgeUL', '0')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRCELL_FDD-1',
                          'nrarfcnDl', '388200')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRCELL_FDD-1',
                          'nrarfcnUl', '372200')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-60')
    ds.add_complex_item_to_delta(nrbts_object + '/BWP_PROFILE-7',
                                 'locationAndBandwidthUl', cRbSizeUl='allRb', cRbStartUl="sameAsDl")
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    logging.debug("------------------Preconditions for PRB BLANKING revert-------------------------")
    au.wait_for_all_cells_on_air_state(cell_type='nr')


def check_pcap_13152(pcap_file, protocol='f1ap', filter_pcap='initiatingMessage', parameter_1=None,
                     value_to_check_list1=None, value_to_check_list2=None):

    exported_list = log_finder(pcap_file, protocol, filter_pcap)
    return exported_list


def find_pucch_resources(data):
    results = []

    if isinstance(data, dict):
        if "pucch-ResourceId" in data:
            resource_info = {
                "pucch-ResourceId": data.get("pucch-ResourceId"),
                "startingPRB": data.get("startingPRB"),
                "secondHopPRB": data.get("secondHopPRB"),
            }
            results.append(resource_info)

        for value in data.values():
            results.extend(find_pucch_resources(value))

    elif isinstance(data, list):
        for item in data:
            results.extend(find_pucch_resources(item))

    return results


def get_nested_value(data, target_key):

    if isinstance(data, Mapping):
        if target_key in data:
            return data[target_key]

        for value in data.values():
            result = get_nested_value(value, target_key)
            if result is not None:
                return result

    elif isinstance(data, (list, tuple)):
        for item in data:
            result = get_nested_value(item, target_key)
            if result is not None:
                return result

    return None


def pucch_resources_configuration_pcap(data):

    if isinstance(data, Mapping):

        if "pucch-ResourceId" in data:

            yield {
                "pucch-ResourceId": data.get("pucch-ResourceId"),
                "startingPRB": data.get("startingPRB"),
                "secondHopPRB": data.get("secondHopPRB"),
                "nrofPRBs": get_nested_value(data, "nrofPRBs"),
                "nrofSymbols": get_nested_value(data, "nrofSymbols"),
                "startingSymbolIndex": get_nested_value(data, "startingSymbolIndex")

            }

        for value in data.values():
            yield from pucch_resources_configuration_pcap(value)

    elif isinstance(data, (list, tuple)):
        for item in data:
            yield from pucch_resources_configuration_pcap(item)


def pucch_configuration_pcap_searcher(data, target_ids=None):

    if target_ids is None:
        target_ids = []

    if isinstance(target_ids, py_str):
        target_ids = target_ids.split()

    if not isinstance(target_ids, (list, tuple, set)):
        target_ids = [target_ids]

    results = list(pucch_resources_configuration_pcap(data))
    seen = {}
    cleaned = []

    for item in results:
        rid = item.get("pucch-ResourceId")

        if rid not in seen:
            seen[rid] = item
            cleaned.append(item)
        else:

            if seen[rid] != item:
                raise AssertionError(
                    f"Conflict for pucch-ResourceId {rid} ? "
                    "different configurations detected on duplicated data, check pcap!!!"
                )

    target_pucch_ids = [
        item for item in cleaned
        if item.get("pucch-ResourceId") in target_ids
    ]

    found_ids = {item.get("pucch-ResourceId") for item in target_pucch_ids}
    missing = set(target_ids) - found_ids

    if missing:
        raise AssertionError(
            f"""
            Missing pucch-ResourceId: {missing}
            Requested: {target_ids}
            Found: {found_ids}
            """
        )
    return target_pucch_ids


def normalize_prb_swap(config):
    for item in config:

        if "startingPRB" in item and "secondHopPRB" in item:

            v1 = item["startingPRB"]
            v2 = item["secondHopPRB"]

            try:
                v1_int = int(v1)
                v2_int = int(v2)
            except (TypeError, ValueError):
                continue

            sorted_values = sorted([v1_int, v2_int])

            item["startingPRB"] = str(sorted_values[0])
            item["secondHopPRB"] = str(sorted_values[1])

    return config


def validation_of_cplane(actual, expected):

    def to_dict_by_id(data):
        return {
            item["pucch-ResourceId"]: item
            for item in sorted(data, key=lambda x: x["pucch-ResourceId"])
        }
    blog("------------------prb config before normalization--------------------", actual)
    actual = normalize_prb_swap(actual)
    expected = normalize_prb_swap(expected)

    actual_map = to_dict_by_id(actual)
    expected_map = to_dict_by_id(expected)
    if actual_map == expected_map:
        blog(
            "\n"
            "---------------- EXPECTED PUCCH CONFIG ----------------\n"
            f"{expected_map}\n"
            "-------------------- ACTUAL CONFIG --------------------\n"
            f"{actual_map}\n"
            "---------------------- STATUS -------------------------\n"
            "Configs are identical\n"
        )
    else:
        raise AssertionError(
            f"""
            ? CPlane mismatch

            Actual:
            {actual_map}

            Expected:
            {expected_map}
            """
        )

    return True


@logged_keyword
def stop_logging_bip_13152(teardown=False):
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def start_logging_bip_13152(pcap_filename="default", smod_slave=False):
    l1l2.start_gnbmirroring(filename=pcap_filename)


def iter_invalid_prb_values_fast(data, target_l1l2_keys, pucch_prb_values, path="root"):
    if not isinstance(data, (dict, list, tuple)):
        return

    if isinstance(data, dict):
        for key, value in data.items():
            current_path = f"{path} -> {key}"

            if key in target_l1l2_keys and value not in pucch_prb_values:
                yield current_path, value

            yield from iter_invalid_prb_values_fast(
                value,
                target_l1l2_keys,
                pucch_prb_values,
                current_path
            )

    else:
        for idx, item in enumerate(data):
            yield from iter_invalid_prb_values_fast(
                item,
                target_l1l2_keys,
                pucch_prb_values,
                f"{path}[{idx}]"
            )


def validation_of_bip_log(my_data, target_l1l2_keys, pucch_prb_values):
    blog("Starting PUCCH validation...")
    errors = []

    for path, value in iter_invalid_prb_values_fast(
        my_data,
        target_l1l2_keys,
        pucch_prb_values
    ):
        blog(f"Checking: {path} = {value}")
        errors.append((path, value))

    if errors:
        raise AssertionError(
            "Problematic values not equal to defined PUCCH:\n" +
            "\n".join(f"{p} = {v}" for p, v in errors)
        )

    blog("PUCCH assignment from L1L2 correct")


def validation_of_bip_log_bwp(my_data, target_l1l2_keys):
    blog("Starting PUCCH validation...")
    blog(my_data)
    blog(type(my_data))


def validate_pucch(obj):

    errors = []

    def recursive_search(d, results):
        if isinstance(d, dict):

            if "pucchFormat (l1_common_pucchFormat_t)" in d:

                block = {
                    "format": d.get("pucchFormat (l1_common_pucchFormat_t)"),
                    "startPrb": d.get("startPrb (Uint16)"),
                    "secondHopPrb": d.get("secondHopPrb (Uint16)")
                }

                if block not in results:
                    results.append(block)

            for value in d.values():
                if isinstance(value, (dict, list)):
                    recursive_search(value, results)

        elif isinstance(d, list):
            for item in d:
                recursive_search(item, results)

    results = []
    recursive_search(obj, results)
    if errors:
        raise AssertionError("\n".join(errors))

    return results


def checking_pucch_prbs_l1l2(data, pucch_format1_prbs, pucch_format2_prbs):
    blog(data)
    valid_values_1 = {int(v) for v in pucch_format1_prbs}
    valid_values_3 = {int(v) for v in pucch_format2_prbs}
    for block in data:

        fmt = block["format"]
        start = int(block["startPrb"])
        second = int(block["secondHopPrb"])

        if "PUCCH_FORMAT_1" in fmt:

            if start not in valid_values_1:
                raise AssertionError(f"[FORMAT1] Not correct startingPrb: {block}")
            if second not in valid_values_1:
                raise AssertionError(f"[FORMAT1] Not correct secondHopPrb: {block}")

        if "PUCCH_FORMAT_3" in fmt:

            if start not in valid_values_3:
                raise AssertionError(f"[FORMAT3] Not correct startingPrb: {block}")
            if second not in valid_values_3:
                raise AssertionError(f"[FORMAT3] Not correct secondHopPrb: {block}")
    blog("all assignment pass from PUCCH")


@logged_keyword
def upload_scf_from_path(scf_path_robot='None', skip_relation_errors=False):
    load_scf(scf_path=scf_path_robot, skip_relation_errors=skip_relation_errors)
    wait_for_online_state()


@logged_keyword
def attenuation_for_bwp_13152():
    atten.initialise_attenuator()
    logging.debug("attenuating target cell")
    atten.set_attenuation(value_string='0', ports=[11, 12])
    atten.set_attenuation(value_string='90', ports=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10])


class StrPatternDict(dict):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if args and isinstance(args[0], list) and all(isinstance(item, tuple) and len(item) == 2 for item in args[0]):
            for k, v in args[0]:
                self[k] = v


def safe_int_conversion(value):
    if isinstance(value, str):
        match = re.match(r'(\d+)', value)
        if match:
            return int(match.group(1))
    elif isinstance(value, (int, float)):
        return int(value)
    return None


def find_all_values_for_keys(data, target_keys):
    found_values = []

    if isinstance(data, (dict, StrPatternDict)):
        for key, value in data.items():
            if key in target_keys:
                found_values.append(value)
            found_values.extend(find_all_values_for_keys(value, target_keys))
    elif isinstance(data, (list, tuple)):
        for item in data:
            found_values.extend(find_all_values_for_keys(item, target_keys))

    return found_values


def check_size_of_pusch(found_val, wide_prbs):
    wide_prbs = int(wide_prbs)
    for i in range(0, len(found_val), 2):
        total_sum = int(found_val[i]) + int(found_val[i + 1])
        assert int(found_val[i]) <= wide_prbs, (
            f"Single PRB is greater than {wide_prbs} value {found_val[i]}"
        )
        assert int(found_val[i + 1]) <= wide_prbs, (
            f"Second single PRB is greater than {wide_prbs} value {found_val[i + 1]}"
        )
        assert total_sum <= wide_prbs, (
            f"Amount of PRBS is greater than {wide_prbs}"
        )
    blog("Size of PUSCH is expected, lower than", wide_prbs)
