"""CSI-RS Syslog Analysis Module.

This module provides utilities for analyzing CSI-RS (Channel State Information - Reference Signal)
overhead reduction in 5G NR systems. It extracts and validates CSI-RS muting symbol configurations
from syslog files and verifies PDSCH grant parameters from CSV reports.

Key Features:
    - Extract CSI-RS pooling group and cell configuration from syslogs
    - Validate muting symbol slot configurations (RS1, RS2, RS4)
    - Analyze PDSCH scheduling parameters for muted slots
    - Verify CSI report periodicity and slot offset calculations

Typical Usage:
    1. Parse syslog to extract cell setup and CSI pooling group information
    2. Map physical cell IDs to CSI groups
    3. Verify muting symbol configurations match expected slots
    4. Analyze CSV reports to validate PDSCH symbol counts in muted slots
"""

from pprint import pprint
import sys
import os
import csv

import testsuite.Paris.RRM.ET.resources.vrf_nps2.python.syslog_operations as syslog_operations


def get_zab_privilege_status(tti_file: str, physCellId: str) -> bool:
    """
    Check if hasZabPrivilege is equal to 1 for a given physCellId.

    Args:
        tti_file: The path to the TTI file to read
        physCellId: The physical cell ID to search for (e.g., "54")

    Returns:
        True if hasZabPrivilege is 1 for the given physCellId, False otherwise

    Raises:
        ValueError: If the physCellId is not found in the TTI content
    """
    physCellId_found = False

    with open(tti_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if 'dlAllocatedPooledResourcesData' not in line:
                continue
            parts = line.split(';')
            data = {}
            for i in range(0, len(parts) - 1, 2):
                key = parts[i]
                value = parts[i + 1] if i + 1 < len(parts) else None
                data[key] = value
            if data.get('physCellId') == physCellId:
                physCellId_found = True
                if data.get('hasZabPrivilege') != '1':
                    return False
    if not physCellId_found:
        raise ValueError(f"physCellId '{physCellId}' not found in TTI file")

    return True


def get_RS_muted_symbole_setup_info(syslog_path):
    """Extract CSI-RS muting symbol configuration from syslog.

    Parses the syslog file to extract muting symbol slot information for both
    4-symbol and 2-symbol muting patterns.

    Args:
        syslog_path (str): Path to the syslog file to parse

    Returns:
        list: List of dictionaries containing muting symbol slot configurations.
              Each dictionary has keys 'muting symbol4 slots' and 'muting symbol2 slots'
              with space-separated slot numbers as values.

    Raises:
        RuntimeError: If syslog data extraction fails

    Example:
        >>> slots = get_RS_muted_symbole_setup_info('/path/to/syslog.log')
        >>> print(slots)
        [{'muting symbol4 slots': '26 27 66', 'muting symbol2 slots': '67 76'}]
    """
    pattern_list = ["minCsiRsSymbols", "muting symbol"]
    csv_columns = ["muting symbol4 slots", "muting symbol2 slots"]
    csv_data = []
    try:
        filtered_lines = syslog_operations.filter_pattern(syslog_path, pattern_list)

        if not filtered_lines:
            return []
        for column in csv_columns:
            selected_lines = []
            for line in filtered_lines:
                if column in line:
                    selected_lines.append(line)
            csv_data.extend(syslog_operations.extract_csv_data(selected_lines, [column]))
        return csv_data
    except Exception as e:
        # Log error or handle as needed for Robot Framework
        raise RuntimeError(f"syslog_data_extraction failed: {e}")


def cell_setup_info(syslog_path):
    """Extract cell setup configuration from syslog.

    Parses syslog to extract cell configuration parameters including cell identity,
    technology type, physical cell ID, and DL MIMO mode.

    Args:
        syslog_path (str): Path to the syslog file

    Returns:
        list: List of dictionaries with cell configuration data containing:
              - nrCellIdentity: NR cell identifier
              - cellTechnology: Technology type (e.g., NR)
              - physCellId: Physical cell ID (PCI)
              - dlMimoMode: Downlink MIMO mode configuration

    Example:
        >>> cells = cell_setup_info('/path/to/syslog.log')
        >>> print(cells[0]['physCellId'])
        '50'
    """
    pattern_list = ["ps::cell::CellSetupReq:", "physCellId"]
    csv_columns = ["nrCellIdentity", "cellTechnology", "physCellId", "dlMimoMode"]

    try:
        result = syslog_operations.syslog_data_extraction(syslog_path, pattern_list, csv_columns)
        return result
    except Exception as e:
        print(f"Error: {e}")


def csi_pool_group_info(syslog_path):
    """Extract CSI-RS pooling group configuration from syslog.

    Parses syslog to extract CSI-RS pooling group assignments for each cell.

    Args:
        syslog_path (str): Path to the syslog file

    Returns:
        list: List of dictionaries with CSI pooling group data containing:
              - NrCellIdentity: NR cell identifier
              - CsiRsPoolingGroup: CSI-RS pooling group ID (typically 0 or 1)
              - l1PoolId: L1 pool identifier

    Example:
        >>> groups = csi_pool_group_info('/path/to/syslog.log')
        >>> print(groups[0]['CsiRsPoolingGroup'])
        '0'
    """
    pattern_list = [" added NrCellIdentity:", "CsiRsPoolingGroup"]
    csv_columns = ["NrCellIdentity", "CsiRsPoolingGroup", "l1PoolId"]

    try:
        result = syslog_operations.syslog_data_extraction(syslog_path, pattern_list, csv_columns)
        return result
    except Exception as e:
        print(f"Error: {e}")


def csi_report_info(syslog_path):
    """Extract and merge cell setup and CSI pooling group information.

    Combines cell configuration data with CSI-RS pooling group assignments
    for comprehensive cell reporting.

    Args:
        syslog_path (str): Path to the syslog file

    Returns:
        list: List of dictionaries with merged cell and CSI pooling data containing
              all fields from both cell_setup_info and csi_pool_group_info.

    Example:
        >>> info = csi_report_info('/path/to/syslog.log')
        >>> print(info[0])  # Contains physCellId, CsiRsPoolingGroup, etc.
    """
    cell_infos = cell_setup_info(syslog_path)
    csi_pool_infos = csi_pool_group_info(syslog_path)

    # Merge the two lists of dictionaries based on 'nrCellIdentity' and 'NrCellIdentity' keys
    merged_info = []
    for cell_info in cell_infos:
        for csi_pool_info in csi_pool_infos:
            if cell_info["nrCellIdentity"] == csi_pool_info["NrCellIdentity"]:
                merged_dict = {**cell_info, **csi_pool_info}
                merged_info.append(merged_dict)
    return merged_info


def check_csi_group_info(csi_pool_infos):
    """Validate CSI-RS pooling group configuration.

    Verifies that both CSI-RS pooling groups (0 and 1) are present in the configuration.
    Each cell should belong to one group, and both groups should be represented.

    Args:
        csi_pool_infos (list): List of CSI pooling information dictionaries

    Returns:
        str: Success message if both groups are present

    Raises:
        Exception: If only one group is present, no groups found, or unexpected group IDs exist

    Example:
        >>> info = csi_report_info('/path/to/syslog.log')
        >>> result = check_csi_group_info(info)
        >>> print(result)
        'Both CSI groups 0 and 1 are present in the syslog.'
    """
    csi_group_0 = False
    csi_group_1 = False
    csi_group_Unexpected = False
    for csi_pool_info in csi_pool_infos:
        if csi_pool_info["CsiRsPoolingGroup"] == "0":
            csi_group_0 = True
        elif csi_pool_info["CsiRsPoolingGroup"] == "1":
            csi_group_1 = True
        else:
            csi_group_Unexpected = True
    if csi_group_Unexpected:
        raise Exception("Unexpected CSI group found in the syslog.")
    elif csi_group_0 and csi_group_1:
        return "Both CSI groups 0 and 1 are present in the syslog."
    elif csi_group_0:
        raise Exception("Only CSI group 0 is present in the syslog.")
    elif csi_group_1:
        raise Exception("Only CSI group 1 is present in the syslog.")
    else:
        raise Exception("No CSI groups are present in the syslog.")


def get_all_pci_4_csi_group(csi_pool_infos, group_id=None):
    """Get all physical cell IDs belonging to a specific CSI-RS pooling group.

    Filters cell information to extract physical cell IDs that belong to the
    specified CSI-RS pooling group.

    Args:
        csi_pool_infos (list): List of CSI pooling information dictionaries
                              (from csi_report_info or csi_pool_group_info)
        group_id (str): CSI-RS pooling group ID (typically '0' or '1')

    Returns:
        list: List of physical cell IDs (as strings) belonging to the specified group

    Example:
        >>> info = csi_report_info('/path/to/syslog.log')
        >>> pci_list = get_all_pci_4_csi_group(info, '0')
        >>> print(pci_list)
        ['50', '51', '54', '55']
    """
    pci_list = []
    for csi_pool_info in csi_pool_infos:
        if group_id:
            if csi_pool_info["CsiRsPoolingGroup"] == group_id:
                pci_list.append(csi_pool_info["physCellId"])
        else:
            pci_list.append(csi_pool_info["physCellId"])
    return pci_list


def get_pci_per_group(csi_pool_infos):
    """Get mapping of physical cell IDs to their respective CSI-RS pooling groups.

    Creates a dictionary mapping each physical cell ID to its corresponding CSI-RS
    pooling group ID based on the provided CSI pooling information.

    Args:
        csi_pool_infos (list): List of CSI pooling information dictionaries
                              (from csi_report_info or csi_pool_group_info)

    Returns:
        dict: Dictionary mapping physical cell IDs (as strings) to CSI group IDs (as integers)
              e.g., {'50': 0, '51': 0, '52': 1, '53': 1}

    Example:
        >>> info = csi_report_info('/path/to/syslog.log')
        >>> pci_group_mapping = get_pci_per_group(info)
        >>> print(pci_group_mapping)
        {'50': 0, '51': 0, '52': 1, '53': 1}
    """
    pci_group_mapping = {}
    for csi_pool_info in csi_pool_infos:
        pci = csi_pool_info["physCellId"]
        group_id = int(csi_pool_info["CsiRsPoolingGroup"])
        pci_group_mapping[pci] = group_id
    return pci_group_mapping


def verify_slots_in_range(csi_rs_slots_list, psc_csi_gp={}, muting_symbol={}):
    """Verify that extracted muting symbol slots match expected configurations.

    Validates that the muting symbol slot values extracted from syslogs match
    the expected slot numbers for each CSI-RS pooling group.

    Args:
        csi_rs_slots_list (list): List of dictionaries with extracted slot configurations
        psc_csi_gp (dict): Mapping of physical cell IDs to CSI group IDs
                          e.g., {'50': 0, '51': 0, '52': 1, '53': 1}
        muting_symbol (dict): Expected muting symbol configurations per group
                             Format: {group_id: {'muting symbol4 slots': 'slot numbers',
                                                 'muting symbol2 slots': 'slot numbers'}}

    Raises:
        ValueError: If slot values don't match expected configurations or
                   invalid column names are encountered

    Example:
        >>> psc_csi_gp = {'50': 0, '51': 0, '52': 1, '53': 1}
        >>> verify_slots_in_range(extracted_slots, psc_csi_gp, rs4_muted_slots)
    """
    # Parse expected muting symbol configurations into integer lists
    muting_symbol_slots = {
        "muting symbol4 slots": {
            0: list(map(int, muting_symbol[0]["muting symbol4 slots"].split())),
            1: list(map(int, muting_symbol[1]["muting symbol4 slots"].split())),
        },
        "muting symbol2 slots": {
            0: list(map(int, muting_symbol[0]["muting symbol2 slots"].split())),
            1: list(map(int, muting_symbol[1]["muting symbol2 slots"].split())),
        },
    }
    psc_csi_gp_list = [psc_csi_gp[key] for key in sorted(psc_csi_gp.keys(), key=lambda x: int(x))]
    cell_count = len(psc_csi_gp_list)
    for i, csi_rs_slots in enumerate(csi_rs_slots_list):
        if i >= cell_count:
            group_id = psc_csi_gp_list[i - cell_count]
        else:
            group_id = psc_csi_gp_list[i]
        for column, slots in csi_rs_slots.items():
            if column not in ["muting symbol4 slots", "muting symbol2 slots"]:
                raise ValueError(f"Invalid column name '{column}' in csi_rs_slots. Expected 'muting symbol4 slots' or \
                        'muting symbol2 slots'.")
            rs_slots = list(map(int, slots.split()))
            for slot in rs_slots:
                if slot not in muting_symbol_slots[column][group_id]:
                    raise ValueError(f"Invalid slot value '{slot}' in group {group_id} for {column}. \
                            Slots should be in {muting_symbol_slots[column][group_id]}.")


def convert_to_int(value):
    """Convert comma-separated string to integer.

    Extracts the first value from a comma-separated string and converts it to integer.
    Used for parsing CSV fields that may contain multiple values.

    Args:
        value (str): String value, potentially comma-separated

    Returns:
        int or None: Integer value of the first element, or None if conversion fails

    Example:
        >>> convert_to_int('123,456')
        123
        >>> convert_to_int('789')
        789
        >>> convert_to_int('invalid')
        None
    """
    try:
        return int(value.split(",")[0])
    except ValueError:
        return None


def update_slots(muting_symbol_slots_checked, slot_offset, groupId):
    if slot_offset not in muting_symbol_slots_checked[groupId]:
        muting_symbol_slots_checked[groupId].append(slot_offset)
    return muting_symbol_slots_checked


def analyze_csi_rs_periodicity(
    bip_csv_file_path,
    psc_csi_gp={},
    muting_symbol={},
    csiReportPeriodicity=320,
    nbSlotsPerSFN=20,
    rateMatchingOption=0,
    startSymbol=1,
):
    """Analyze PDSCH scheduling behavior in muted CSI-RS slots.

    Validates that PDSCH grants in CSI-RS muted slots have the correct number of symbols.
    For muting symbol4 slots, PDSCH should have 9 symbols. For muting symbol2 slots,
    PDSCH should have 11 symbols.

    Args:
        bip_csv_file_path (str): Path to CSV file containing PDSCH grant information
                                Expected columns: 3gpp.sfn, 3gpp.slot, 3gpp.rnti,
                                DlData_PdschGrantL1sw.pdschScramblingSeqInit,
                                DlData_PdschGrantL1sw.rateMatchingOption,
                                DlData_PdschGrantL1sw.startSymbol,
                                DlData_PdschGrantL1sw.numOfPdschSymbols
        psc_csi_gp (dict): Mapping of physical cell IDs to CSI group IDs
                          e.g., {'50': 0, '51': 0, '52': 1, '53': 1}
        muting_symbol (dict): Muting symbol configurations per group
                             Format: {group_id: {'muting symbol4 slots': 'slot numbers',
                                                'muting symbol2 slots': 'slot numbers'}}
        csiReportPeriodicity (int): CSI report periodicity in slots (default: 320)
        nbSlotsPerSFN (int): Number of slots per system frame (default: 20)
        rateMatchingOption (int): Expected rate matching option value (default: 0)
        startSymbol (int): Expected PDSCH start symbol (default: 1)

    Raises:
        AssertionError: If PDSCH symbol count doesn't match expected values in muted slots

    Algorithm:
        1. Calculate slot offset: (sfn * nbSlotsPerSFN + slot) % csiReportPeriodicity
        2. Determine CSI group from pdschScramblingSeqInit using psc_csi_gp mapping
        3. Filter rows where:
           - rnti != 65535 (not broadcast)
           - rateMatchingOption matches expected value
           - startSymbol matches expected value
        4. For muted slots, verify:
           - muting symbol4 slots: numOfPdschSymbols == 9
           - muting symbol2 slots: numOfPdschSymbols == 11

    Example:
        >>> psc_csi_gp = {'50': 0, '51': 0, '52': 1, '53': 1}
        >>> analyze_csi_rs_periodicity('report.csv', psc_csi_gp=psc_csi_gp,
        ...                            muting_symbol=rs4_muted_slots)
    """
    # Parse muting symbol configurations into integer lists for fast lookup
    muting_symbol4_slots = {
        0: list(map(int, muting_symbol[0]["muting symbol4 slots"].split())),
        1: list(map(int, muting_symbol[1]["muting symbol4 slots"].split())),
    }
    muting_symbol2_slots = {
        0: list(map(int, muting_symbol[0]["muting symbol2 slots"].split())),
        1: list(map(int, muting_symbol[1]["muting symbol2 slots"].split())),
    }

    symbol4_slots_checked = {0: [], 1: []}
    symbol2_slots_checked = {0: [], 1: []}

    with open(bip_csv_file_path, "r", encoding="utf-8") as csvfile:
        csv_reader = csv.DictReader(csvfile, delimiter="\t")
        headers = csv_reader.fieldnames
        # for i, header in enumerate(headers):
        #     print(f"{header} index: {i}")
        for row in csv_reader:
            slot_offset = (
                convert_to_int(row["3gpp.sfn"]) * nbSlotsPerSFN + convert_to_int(row["3gpp.slot"])
            ) % csiReportPeriodicity
            csi_group_id = psc_csi_gp.get(row["DlData_PdschGrantL1sw.pdschScramblingSeqInit"], None)
            # row['DlData_PdschGrantL1sw.pdschScramblingSeqInit']
            if csi_group_id is not None:
                if (
                    row["3gpp.rnti"] != "65535"
                    and row["DlData_PdschGrantL1sw.rateMatchingOption"] == str(rateMatchingOption)
                    and row["DlData_PdschGrantL1sw.startSymbol"] == str(startSymbol)
                ):
                    if slot_offset in muting_symbol4_slots[csi_group_id]:
                        assert (
                            row["DlData_PdschGrantL1sw.numOfPdschSymbols"] == "9"
                        ), f"Muting symbol4 slots should have numOfPdschSymbols equal to 9, \
                            but got {row['DlData_PdschGrantL1sw.numOfPdschSymbols']} for slot offset {slot_offset}"
                        symbol4_slots_checked = update_slots(
                            symbol4_slots_checked, slot_offset, csi_group_id
                        )
                    elif slot_offset in muting_symbol2_slots[csi_group_id]:
                        assert (
                            row["DlData_PdschGrantL1sw.numOfPdschSymbols"] == "11"
                        ), f"Muting symbol2 slots should have numOfPdschSymbols equal to 11, \
                            but got {row['DlData_PdschGrantL1sw.numOfPdschSymbols']} for slot offset {slot_offset}"
                        symbol2_slots_checked = update_slots(
                            symbol2_slots_checked, slot_offset, csi_group_id
                        )
        return symbol4_slots_checked, symbol2_slots_checked
