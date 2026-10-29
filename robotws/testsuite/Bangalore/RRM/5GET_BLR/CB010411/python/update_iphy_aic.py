import xml.etree.ElementTree as ET
import os
import subprocess
import re
import sys


def parse_xml_update_value(xml_file, card_bld_version_dict):
    tree = ET.parse(xml_file)
    config_xml = tree.getroot()

    print("card_bld_version_dict", card_bld_version_dict)
    for all_identities in config_xml.findall(".//RE/identity"):
        print(all_identities)
        cardname = all_identities.find('cardName').text
        print(cardname)
        for key_name in card_bld_version_dict.keys():
            if cardname == key_name:
                bld_version = card_bld_version_dict[key_name]
                all_identities.find('bldVersion').text = bld_version
    tree.write(xml_file)


def get_build_version_from_enb(cardname):
    cmd = "ssh toor4nsn@192.168.255.129 grep -i " + cardname + \
        "  /ffs/run/TargetBD* 2>&1| grep -i resourceSWVersion | \
        awk -F '=|\"' '{print $12}' | uniq > /tmp/bldversion.txt"
    print("cmd", cmd)
    os.system(cmd)
    temp = subprocess.Popen(["cat", "/tmp/bldversion.txt"],
                            stdout=subprocess.PIPE, text=True)
    output = str(temp.communicate())
#    print("output==>", output)
    output = re.split('(|\'|\\n', output)
    output = output[2].replace('\\n', '')
    print("build_version", output)
    return (output)


# if __name__ == "__main__":
#    iphy_xml_file = sys.argv[1]
#    parse_xml_update_value(iphy_xml_file)
