import xml.etree.ElementTree as ET
import re
import sys

file_name = sys.argv[1]

tree = ET.parse(file_name)
root = tree.getroot()


def get_dist_names_list(root):
    """Extract distName and DN values from XML."""
    dist_names = []
    dn_names = []

    for item in root.iter():
        if "distName" in item.attrib:
            dist_names.append(item.attrib["distName"])

        if "name" in item.attrib and re.search(r".*DN$", item.attrib["name"]):
            dn_names.append(item.text)

    dn_names = [s.strip() for s in dn_names if s and s.strip()]
    return dist_names, dn_names


def get_short_dn_name(dn_name, dist_names):
    """Determine short DN name based on patterns."""
    str_parts = dn_name.split("/")[::-1]
    sht_name = ""

    if "TNLSVC" in dn_name:
        pattern = r"TNLSVC.*"
        sht_name = re.search(pattern, dn_name).group(0)
        if "TNL-" in dn_name:
            sht_name = re.search(r"TNL-.*", dn_name).group(0)
    else:
        for part in str_parts:
            match_pattern = rf".*{part}$"
            filtered = list(filter(lambda v: re.match(match_pattern, v), dist_names))

            if len(filtered) == 1:
                sht_name = re.search(rf"{part}.*", dn_name).group(0)
                break

            if re.search(match_pattern, dn_name):
                sht_name = re.search(match_pattern, dn_name).group(0)

    return sht_name


def create_edited_file(filename):
    """Remove namespace prefixes and write modified XML file."""
    edited_name = f"{filename.split('.xml')[0]}_edit.xml"

    with open(filename, "r", encoding="utf8") as file:
        data = file.readlines()

    for idx in range(len(data)):
        if "ns0:" in data[idx]:
            data[idx] = data[idx].replace("ns0:", "")
        if ":ns0" in data[idx]:
            data[idx] = data[idx].replace(":ns0", "")

    with open(edited_name, "w", encoding="utf8") as file:
        file.writelines(data)


dist_names, dn_names = get_dist_names_list(root)


def write_short_dn_name_to_file(root):
    for item in root.iter():
        if "name" in item.attrib and re.search(r".*DN$", item.attrib["name"]):
            item.text = get_short_dn_name(item.text, dist_names)
            ET.register_namespace("", file_name)

            tree.write(
                file_name,
                xml_declaration=True,
                method="xml",
                encoding="utf8",
                default_namespace=None
            )


def dist_name_newformat(param):
    """Convert DN path to dot separated short format."""
    parts = param.split("/")
    cleaned = [re.sub(r"-\d+", "", part) for part in parts]
    return ".".join(cleaned)


removed_parameters = [
    "MRBTS.frozenOMVersionVerizon",
    "MRBTS.frozenOMVersionAtt",
    "MNL.frozenOMVersionVerizon",
    "MNL.frozenOMVersionAtt",
    "LNBTS.frozenOMVersionVerizon",
    "LNBTS.frozenOMVersionATT",
    "EQM.frozenOMVersionVerizon",
    "EQM.frozenOMVersionATT",
    "EQM_R.frozenOMVersionVerizon",
    "EQM_R.frozenOMVersionATT",
    "ASI.frozenOMVersion"
]


def check_for_removed_parameters(dist_names, removed_parameters):
    """Check whether removed parameters exist in dist names."""
    rmv_param_list = []
    new_format_dst_names = [dist_name_newformat(dst) for dst in dist_names]

    for param in removed_parameters:
        if param in new_format_dst_names:
            rmv_param_list.append(param)

    if not rmv_param_list:
        print("No removed parameters found")
    else:
        print(f"List of removed parameters found: {rmv_param_list}")


check_for_removed_parameters(dist_names, removed_parameters)

write_short_dn_name_to_file(root)
create_edited_file(file_name)

print("Short DN's changed in XML")
