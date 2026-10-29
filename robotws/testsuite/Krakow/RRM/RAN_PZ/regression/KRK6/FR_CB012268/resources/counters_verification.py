"""
This module provides utilities for parsing and verifying PM counters from XML files,
specifically for NRPMQAP and DL PDCP SDU bin counters in a 5G network context.

:copyright:     Nokia Networks
:author:        Dawid Chuchnowski
:maintainer:    Jakub Matuszczyk
:contact:       jakub.matuszczyk@nokia.com
:team:          KRK6
"""
from __future__ import annotations

import logging
import xml.etree.ElementTree as ET

from typing import Optional
from ta5g_pm_counters import ta5g_pm_counters
from taf.rfrl.utilities.robot.general import get_builtin_value


pm = ta5g_pm_counters()


def get_mrbts_id() -> str:
    tl = get_builtin_value("tl")
    return tl.gnbs[0].instance_id


def extract_NRPMQAP_counters(xml_path: str, meas_type: str) -> dict[str, dict[str, dict[str, str]]]:
    """
    Parses PM XML and returns nested dictionary with structure:
    results[NRCELL][NRPMQAP]['M55353Cxxxxx']
    :param xml_path: path to PM counters xml
    :return: nested dict with NRCELL, NRPMQAP and counters
    """

    tree = ET.parse(xml_path)
    root = tree.getroot()

    results = {}

    for pm_result in root.findall(".//PMMOResult"):
        parsed_pmmoresult = _parse_PMMOResult(pm_result, meas_type)
        if not parsed_pmmoresult:
            continue
        cell_key, profile_key, hrlcq = parsed_pmmoresult
        counters = _unpack_counters(hrlcq)

        if cell_key not in results:
            results[cell_key] = {}

        results[cell_key][profile_key] = counters
    return results


def _parse_PMMOResult(pm_result: ET.Element, meas_type: str) -> Optional[tuple[str, str, ET.Element]]:
    """
    Parses PMMOResult object of PMCounters XML and returns NRCELL ID, NRPMQAP profile ID and
    list of HRLCQ counter objects:
    :param pm_result: PMMOResult ElementTree object from PM Counters xml file
    :return: cell id, nrpmqap profile id, list of HRLCQ counter ElemenentTree objects
    """
    mo_elements = pm_result.findall("MO")
    if len(mo_elements) != 2:
        return None
    cell_dn = mo_elements[0].findtext("DN")
    profile_dn = mo_elements[1].findtext("DN")
    hrlcq_measurements = pm_result.find(f'NE-WBTS_1.0[@measurementType="{meas_type}"]')

    if cell_dn is None or profile_dn is None or hrlcq_measurements is None:
        return None
    else:
        cell_key = cell_dn.split("/")[-1]
        profile_key = profile_dn.split("/")[-1]
        return cell_key, profile_key, hrlcq_measurements


def _unpack_counters(hrlcq_measurements: ET.Element) -> dict[str, Optional[str]]:
    """Converts list of ElementTree objects to dict with counter ids : counter values
    :param hrlcq_measurements: list of HRLCQ counter ElemenentTree objects
    :return: dict with counter:value pairs
    """
    counters = {}
    for child in hrlcq_measurements:
        counters[child.tag] = child.text
    return counters


def verify_NRPMQAP_counters_for_cell(counters_list: str, cell_id: str, nrpmqap_profile: str) -> None:
    """
    Verifies that NRPMQAP counters for specified cell and NRPMQAP profile were incremented

    :param counters_list: list of counters
    :param cell: cell id
    :param nrpmqap_profile: nrpmqap profile number
    :return: none
    """
    pm_file = pm.get_latest_unpacked_full_pm_counters_file()
    nrpmqap_counters = extract_NRPMQAP_counters(pm_file, meas_type='HRLCQ')

    logging.info(f"PM Counters file path: {pm_file}")

    for counter in counters_list.split(','):
        counter_value = float(nrpmqap_counters[f"NRCELL-{cell_id}"][f"NRPMQAP-{nrpmqap_profile}"][counter])
        logging.info(f"NRCELL-{cell_id} PMQAP-{nrpmqap_profile} {counter} - value: {counter_value}")
        assert counter_value > 10000, (f"NRPMQAP-{nrpmqap_profile} {counter} is not incremented "
                                       f"(value {counter_value}, expected >10000)")


def verify_NRPMQAP_throughput_counters_for_cell(pm_file: str, counters_list: str,
                                                cell_id: str, nrpmqap_profile: str) -> None:
    """
    Verifies that NRPMQAP counters for specified cell and NRPMQAP profile were incremented

    :param pm_file: pm counters file
    :param counters_list: list of counters
    :param cell: cell id
    :param nrpmqap_profile: nrpmqap profile number
    :return: none
    """
    nrpmqap_counters = extract_NRPMQAP_counters(pm_file, meas_type='LRLCQ')

    logging.info(f"PM Counters file path: {pm_file}")

    for counter in counters_list.split(','):
        counter_value = float(nrpmqap_counters[f"NRCELL-{cell_id}"][f"NRPMQAP-{nrpmqap_profile}"][counter])
        logging.info(f"NRCELL-{cell_id} PMQAP-{nrpmqap_profile} {counter} - value: {counter_value}")
        assert counter_value > 0, (f"NRPMQAP-{nrpmqap_profile} {counter} is not incremented ")


def check_DL_PDCP_SDU_bin_counters(counters_list: str, cell: str) -> None:
    """
    Verifies DL PDCP SDU bin counters for specified cell

    :param counters_list: list of counters
    :param cell: cell id
    :return: none
    """
    mrbts_id = get_mrbts_id()
    local_moid = f"PLMN-PLMN/MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-{cell}"
    pm_file = pm.get_latest_unpacked_full_pm_counters_file()

    logging.info(f"PM Counters file path: {pm_file}")
    counters_sum = 0
    for number, counter in enumerate(counters_list.split(',')):
        counter_value = pm.get_pm_counter_value(counter=counter,
                                                localmoid=local_moid,
                                                filepath=pm_file)
        logging.info(f"{counter} Number of DL PDCP SDUs whose size is in Bin{number} - value: {counter_value[0]}")
        counters_sum += counter_value[0]
    assert counters_sum > 1000000, f"DL PDCP SDU bin counters are not incremented"
