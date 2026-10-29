import sys
import os
import json
from taf.sbts.oam.coam.admin import admin
import telnetlib
import time
import re


def get_total_cmp(pm_report, expected_value, cell_id=None):
    value = 0
    counter = 0
    sd_level = {}

    for record in pm_report:
        for time in record.keys():
            for counter in record[time].keys():
                for moc in record[time][counter].keys():

                    # --- FIXED MATCH CONDITION ---
                    if cell_id is None or moc == cell_id:
                        val = int(float(record[time][counter][moc]))
                        value += val
                        sd_level[moc] = sd_level.get(moc, 0) + val

    print(sd_level)

    # --- PASS / FAIL LOGIC ---
    if expected_value == value:
        return 'PASS' + '#' + str(sd_level)
    elif expected_value == -1:
        # -1 means we just expect value > 0
        if value < 1:
            return 'FAIL' + '#' + str(sd_level)
        else:
            return 'PASS' + '#' + str(sd_level)
    else:
        print("counter-->", counter, "expected value-->", expected_value, "Actual Value", value)
        return 'FAIL' + '#' + str(sd_level)


def compare_eq(l1, l2):
    for i in range(len(l1)):
        l1[i] = int(l1[i], 16)
    if isinstance(l2, list):
        for i in range(len(l2)):
            l2[i] = int(str(l2[i]))
        for i in l1:
            if i not in l2:
                return 'Fail'
    else:
        print(l2, l1)
        if int(l2) not in l1:
            return 'Fail'
    return 'Pass'


def update_slice_value(val):
    return eval(val)


def get_active_alarm(sev=None):
    api = admin()
    connection = api.connect_to()
    result = connection.get_active_alarms(severity=sev)
    return result


def get_alarm_history(filepath):
    api = admin()
    connection = api.connect_to()
    result = connection.collect_raw_alarm_history_file(filepath)
    return result


def validate_alarm_enhanced(data, arg):
    """
    Checks if AT LEAST ONE alarm record in the 'data' list contains
    ALL key-value pairs specified in the 'arg' dictionary, ensuring
    type conversion for robust comparison.

    :param data: A list of alarm dictionaries.
    :param arg: A dictionary of key-value pairs to match against (the required criteria).
    :return: 'Pass' if a matching record is found, or a detailed 'Fail' string.
    """
    if not isinstance(data, list) or not data:
        return "Fail (Input list is empty or invalid)"

    first_failure_details = None
    first_failure_index = -1

    for index, record in enumerate(data):
        if not isinstance(record, dict):
            if first_failure_details is None:
                first_failure_details = "Record is not a dictionary"
                first_failure_index = index
            continue

        is_match = True

        for key, expected_value in arg.items():
            actual_value = record.get(key)

            # --- FIX APPLIED: Convert actual value to string for comparison ---
            # This handles cases where alarm IDs or fault IDs are stored as integers
            actual_value_str = str(actual_value) if actual_value is not None else None

            if actual_value_str != expected_value:
                # Mismatch found for this record.
                is_match = False

                if first_failure_details is None:
                    # Record the first mismatch detail
                    if key not in record:
                        first_failure_details = (
                            f"Key '{key}' is missing from the record."
                        )
                    else:
                        first_failure_details = (
                            f"Key '{key}' Fails: Expected '{expected_value}' (string), "
                            f"but found '{actual_value}' ({type(actual_value).__name__})."
                        )
                    first_failure_index = index

                # Move to the next record since this one has failed a criterion
                break

        if is_match:
            # As soon as we find one matching record, we can return 'Pass'
            return 'Pass'

    # If the loop finishes without finding a match, return the detailed failure message
    if first_failure_details is not None:
        return (
            f"Fail (No matching record found). First Mismatch in Record [{first_failure_index}]: "
            f"{first_failure_details}"
        )

    return 'Fail (Unexpected error or no criteria specified)'


def execute_egate_command_new(cmd, host="127.0.0.1", port=20000, prompt=b"EGATE>", connect_timeout=10,
                              capture_time=10, read_interval=0.2):

    """
    Executes an EGATE command and returns CLEAN text output
    suitable for writing directly to a text file.
    Everything is self-contained inside this function.
    """

    # ---- ANSI escape sequence remover (local) ----
    ansi_escape_re = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]')

    tn = telnetlib.Telnet(host, port, timeout=connect_timeout)

    # Wait for EGATE prompt
    tn.read_until(prompt, timeout=connect_timeout)

    # Send command
    tn.write(cmd.encode("ascii") + b"\n")

    raw_chunks = []
    start_time = time.time()

    # Capture async output
    while time.time() - start_time < capture_time:
        try:
            data = tn.read_very_eager()
        except EOFError:
            break

        if data:
            raw_chunks.append(data.decode(errors="ignore"))

        time.sleep(read_interval)

    tn.close()

    # ---- Post-processing ----
    raw_output = "".join(raw_chunks)

    # Strip ANSI escape sequences
    cleaned = ansi_escape_re.sub("", raw_output)

    # Normalize newlines
    cleaned = cleaned.replace("\r\n", "\n").replace("\r", "\n")

    # Remove empty / whitespace-only lines
    lines = [line.rstrip() for line in cleaned.split("\n") if line.strip()]

    return "\n".join(lines)


def parse_amf_file(filepath):
    """
    Parse AMF log file and return cells structure.
    Uses os + built-in file I/O (no pathlib).
    """

    CELL_NUMBER_TO_IDENTITY = {
        1: 16385, 2: 16386, 3: 16387, 4: 16388,
        7: 16391, 8: 16392, 10: 16394, 11: 16395,
    }

    if not os.path.isfile(filepath):
        raise FileNotFoundError(f"{filepath} does not exist")

    with open(filepath, "r", errors="ignore") as f:
        lines = f.read().splitlines()

    cells = {}

    # ---------- helpers ----------
    def bin_to_dec(b):
        return int(b.replace(" ", ""), 2)

    # ---------- regex ----------
    sib1_start = "value BCCH-DL-SCH-Message ::="
    mib_start = "value BCCH-BCH-Message ::="

    cell_barred_re = re.compile(r"cellBarred\s+(barred|notBarred)", re.I)
    warn_cell_re = re.compile(r"Cell\s+(\d+)\s+is\s+barr", re.I)
    inf_cell_re = re.compile(r"eNB\s+2\s+cell\s+(\d+):\s+MasterInformationBlock-NR Updated", re.I)

    plmn_re = re.compile(
        r"mcc\s*\{\s*(\d),\s*(\d),\s*(\d)\s*\}.*?"
        r"mnc\s*\{\s*(\d),\s*(\d),\s*(\d)\s*\}.*?"
        r"(?:trackingAreaCode\s*'([01\s]+)'B.*?)?"
        r"cellIdentity\s*'([01\s]+)'B.*?"
        r"cellReservedForOperatorUse\s+(\w+)",
        re.S
    )

    i = 0
    while i < len(lines):
        line = lines[i]

        # ================= SIB-1 =================
        if sib1_start in line:
            brace, block = 0, []

            while i < len(lines):
                brace += lines[i].count("{") - lines[i].count("}")
                block.append(lines[i])
                if brace == 0 and "}" in lines[i]:
                    break
                i += 1

            block_text = "\n".join(block)

            for idx, p in enumerate(plmn_re.finditer(block_text), start=1):
                cell_id = bin_to_dec(p.group(8))

                cells.setdefault(cell_id, {
                    "cellBarred": "notBarred",  # default
                    "plmns": {}
                })

                cells[cell_id]["plmns"][f"PLMN-{idx}"] = {
                    "mcc": f"{p.group(1)}{p.group(2)}{p.group(3)}",
                    "mnc": f"{p.group(4)}{p.group(5)}{p.group(6)}",
                    "tac": bin_to_dec(p.group(7)) if p.group(7) else 'None',
                    "cellReservedForOperatorUse": p.group(9)
                }

        # ================= MIB =================
        if mib_start in line:
            brace, block = 0, []

            while i < len(lines):
                brace += lines[i].count("{") - lines[i].count("}")
                block.append(lines[i])
                if brace == 0 and "}" in lines[i]:
                    break
                i += 1

            block_text = "\n".join(block)
            bm = cell_barred_re.search(block_text)

            if bm:
                barred_value = bm.group(1)
                cell_no = None

                # barred ? WARN
                if barred_value.lower() == "barred":
                    for j in range(i, min(i + 20, len(lines))):
                        wm = warn_cell_re.search(lines[j])
                        if wm:
                            cell_no = int(wm.group(1))
                            break
                # notBarred ? INF
                else:
                    for j in range(i, min(i + 20, len(lines))):
                        im = inf_cell_re.search(lines[j])
                        if im:
                            cell_no = int(im.group(1))
                            break

                if cell_no is not None:
                    cell_id = CELL_NUMBER_TO_IDENTITY.get(cell_no)
                    if cell_id is not None:
                        cells.setdefault(cell_id, {
                            "cellBarred": "notBarred",
                            "plmns": {}
                        })
                        cells[cell_id]["cellBarred"] = barred_value

        i += 1

    return cells


def generate_cells_structure(tac_plmn1, tac_plmn2, cellBarred):
    """
    Generate cell ? PLMN structure.
    Assumption: ALL cells support PLMN-1 and PLMN-2.
    """

    CELL_IDS = [
        16385, 16386, 16387, 16388,
        16391, 16392, 16394, 16395
    ]

    cells = {}

    for cell_id in CELL_IDS:
        cells[cell_id] = {
            "cellBarred": cellBarred,
            "plmns": {
                "PLMN-1": {
                    "mcc": "310",
                    "mnc": "260",
                    "tac": tac_plmn1,
                    "cellReservedForOperatorUse": "notReserved"
                },
                "PLMN-2": {
                    "mcc": "311",
                    "mnc": "490",
                    "tac": tac_plmn2,   # can be None
                    "cellReservedForOperatorUse": "notReserved"
                }
            }
        }

    return cells


def validate_cells(parsed_cells, expected_cells):

    errors = []
    warnings = []

    parsed_cell_ids = set(parsed_cells.keys())
    expected_cell_ids = set(expected_cells.keys())

    # ---------- Cell presence ----------
    missing_cells = expected_cell_ids - parsed_cell_ids
    if missing_cells:
        errors.append(f"Missing cells in parsed output: {sorted(missing_cells)}")

    # ---------- Per-cell validation ----------
    for cell_id in sorted(parsed_cell_ids & expected_cell_ids):
        p_cell = parsed_cells[cell_id]
        e_cell = expected_cells[cell_id]

        # ---- cellBarred ----
        p_barred = p_cell.get("cellBarred", "notBarred")
        e_barred = e_cell.get("cellBarred", "notBarred")

        if p_barred != e_barred:
            errors.append(
                f"Cell {cell_id}: cellBarred mismatch "
                f"(parsed={p_barred}, expected={e_barred})"
            )

        p_plmns = p_cell.get("plmns", {})
        e_plmns = e_cell.get("plmns", {})  # always has PLMN-1 & PLMN-2

        p_plmn_keys = set(p_plmns.keys())
        e_plmn_keys = set(e_plmns.keys())

        # ---- Missing PLMNs (WARN only) ----
        missing_plmns = e_plmn_keys - p_plmn_keys
        if missing_plmns:
            warnings.append(
                f"Cell {cell_id}: missing PLMNs in parsed data {sorted(missing_plmns)}"
            )

        # ---- Validate only PLMNs that are present ----
        for plmn in p_plmn_keys:
            if plmn not in e_plmns:
                warnings.append(
                    f"Cell {cell_id}: unexpected PLMN {plmn} in parsed data"
                )
                continue

            p_plmn = p_plmns[plmn]
            e_plmn = e_plmns[plmn]

            # Missing required fields ? FAIL
            missing_fields = set(e_plmn) - set(p_plmn)
            if missing_fields:
                errors.append(
                    f"Cell {cell_id}, {plmn}: missing fields {sorted(missing_fields)}"
                )
                continue

            # Strict field comparison
            for field in ["mcc", "mnc", "tac", "cellReservedForOperatorUse"]:
                p_val = p_plmn.get(field)
                e_val = e_plmn.get(field)

                if p_val != e_val:
                    errors.append(
                        f"Cell {cell_id}, {plmn}: {field} mismatch "
                        f"(parsed={p_val}, expected={e_val})"
                    )

    # ---------- Final decision ----------
    if errors:
        report = "VALIDATION FAILED:\n" + "\n".join(errors)
        if warnings:
            report += "\n\nWARNINGS:\n" + "\n".join(warnings)
        return "Fail", report

    if warnings:
        return "Pass", "PASS with warnings:\n" + "\n".join(warnings)

    return "Pass", "PASS: No errors or warnings"


def validate_inactive_fault(filepath, fault_id, expected_text_substring):
    """
    Generic validator for inactive faults.

    Args:
        filepath (str): alarm log file path
        fault_id (int): FaultId to validate
        expected_text_substring (str): substring expected in fault text

    Returns:
        ("Pass", None) on success
        ("Fail", reason_string) on failure
    """

    if not os.path.isfile(filepath):
        return "Fail", f"File not found: {filepath}"

    with open(filepath, "r", errors="ignore") as f:
        lines = f.readlines()

    in_inactive_section = False
    found_fault = False
    found_text_match = False
    collected_texts = []

    # Dynamic regex for given FaultId
    fault_re = re.compile(
        rf"\(\s*{re.escape(str(fault_id))}\s*\)\s+(\S+)"
    )

    for line in lines:
        line = line.strip()

        # Enter Inactive faults section
        if line == "Inactive faults":
            in_inactive_section = True
            continue

        # Exit when another section starts
        if in_inactive_section and line.endswith("faults") and line != "Inactive faults":
            break

        if not in_inactive_section:
            continue

        match = fault_re.search(line)
        if match:
            found_fault = True
            fault_text = match.group(1)
            collected_texts.append(fault_text)

            if expected_text_substring in fault_text:
                found_text_match = True

    # ----------- Validation results -----------
    if not found_fault:
        return (
            "Fail",
            f"FaultId {fault_id} not found in Inactive faults"
        )

    if not found_text_match:
        return (
            "Fail",
            f"FaultId {fault_id} found, but expected text "
            f"'{expected_text_substring}' not associated.\n"
            f"Found texts: {collected_texts}"
        )

    return "Pass", None
