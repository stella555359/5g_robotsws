"""
Author:  Michal Maz
"""

import re


def last_line(text):

    """
    takes the last line from given variable
    """
    return text.strip().splitlines()[-1]


def histogram_check(text):
    """
    checks if there are values for las 90 days in bbox file

    will find all examples of:

    Item id: SFP:RX:1

    and for each found example find the line which starts with Last days like below

    Last days 90:      0       0       0       0      9     920    1222

    after finding this line it will save the nonzero values to the SFP under which it as found
    """
    total = {}
    found_id = None
    for line in text.splitlines():
        match = re.search(r'Item.\s*id:\s*(SFP:[A-Z]+:\d+)', line, re.IGNORECASE)
        if match:
            found_id = match.group(1)
            total[found_id] = [0]
            continue

        if found_id and re.search(r'Last\s*days\s*\d*', line, re.IGNORECASE):
            test = line
            numbers = re.findall(r'\b[1-9]\d+\b', line)
            for n in numbers:
                total[found_id].append(n)
    return total


def reset_check(text):
    lines = text.split("\n")
    third_from_end = lines[-5]
    return third_from_end


def check_found_hist(text1, text2):
    all_id = set(text1.keys()) | set(text2.keys())
    state = True
    for sfp_id in all_id:
        if text1.get(sfp_id) != text2.get(sfp_id):
            state = False
    return state


def filtering_sfp_info(sfp_data_webem):
    """

    this function takes parameters defined in keys_needed
    the variable beeing filtersed is a list of dictionaries with multiple parameters
    each group of needed paramaters is labeled with the order in which they are obtained

    """
    keys_needed = ["vendor", "vendorPartNumber", "serialNumber", "linkSpeed"]
    result = {}
    sfp_index = 0
    for outer_dict in sfp_data_webem:
        for inner_dict in outer_dict.values():
            filtered = {k: inner_dict[k] for k in keys_needed if k in inner_dict}
            result[f"SFP{sfp_index}"] = filtered
            sfp_index += 1

    return result


def filtering_bbox_sfp_info(bbox_sfp_data):
    """
    this function takes an output like:

    Item type: SFP_info
    Item id: SFP1
    Last write: 2025-12-28T14:28:30+00:00
    Last write ISTI: 15701602.320000
    SFP_info[0] write: 2025-12-28T14:28:30+00:00
    SFP_info[0] write ISTI: 15701602.320000
    SFP_info[0] Vendor: WTD
    SFP_info[0] Part no: RTXM228-554-C20A
    SFP_info[0] SN: FR223614355
    SFP_info[0] Speed: 10300
    SFP_info[0] Registers: 110=0x00,111=0x00,118=0x00,119=0x00
    SFP_info[1] write: 1970-01-01T00:01:20+00:00
    SFP_info[1] write ISTI: 15701481.439000
    SFP_info[1] Vendor: WTD

       and takes the parameters labeled as keys_needed and groups them to the sfp
    """
    keys_needed = ["Vendor", "Part no", "SN", "Speed"]
    sfp_dict = {}
    current_sfp = None
    for line in bbox_sfp_data.splitlines():
        line = line.strip()
        if not line:
            continue

        if line.startswith("Item id: "):
            current_sfp = line.split(":")[1].strip()
            sfp_dict[current_sfp] = {}
            continue

        if line.startswith("SFP_info[0]") and current_sfp:
            try:
                _, rest = line.split("SFP_info[0]", 1)
                key, value = rest.split(":", 1)
                key = key.strip()
                value = value.strip()
                if key in keys_needed:
                    sfp_dict[current_sfp][key] = value

            except ValueError:
                continue

    return sfp_dict


def sfp_webem_bbox_comparison(data_webem_filtered, data_bbox_filtered):
    """
        compares the information from webem and bbox for a specific ru
        it takes the data taken from the BBOX and checks if there is a SFP logged by webem with the same parameters
        retruns the matches if founf all


    """
    key_mapping = {
        'vendor': 'Vendor',
        'Part no': 'vendorPartNumber',
        'SN': 'serialNumber',
        'Speed': 'linkSpeed'
    }
    matches = {}

    for i, sfp1 in enumerate(data_webem_filtered):
        found = False
        for sfp2 in data_bbox_filtered:
            if all(
                sfp1.get(k1) == sfp2.get(k2)
                for k1, k2 in key_mapping.items()
                if k1 in sfp1 and k2 in sfp2
            ):
                found = True
                break
        matches[i] = found
    return matches


def extract_release_from_bts_software_info(software_info_dict):
    sw_version = software_info_dict['Active SW version']
    if "SBTS" not in sw_version:
        raise ValueError("Provided BTS Active SW version doesn't contain 'SBTS' prefix")
    release = sw_version.split("_", 2)[0]
    return release
