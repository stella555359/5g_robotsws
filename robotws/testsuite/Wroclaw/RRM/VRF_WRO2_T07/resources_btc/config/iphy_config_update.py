from lxml import etree as ET
import sys
import paramiko
import re


def find_sw_version(targetbd_path, radio_type):
    tree = ET.parse(targetbd_path)
    root = tree.getroot()
    hwresources = root.findall(".//*[@resourceBuildKey]")
    for hwres in hwresources:
        if hwres.get("resourceBuildKey").replace('LTX_', '') == radio_type:
            return hwres.get("resourceSWVersion")


def radio_info(identity_el):
    prod_name = identity_el.xpath("identity/productname|identity/cardName")[0].text
    build_name = identity_el.xpath("identity/buildname|identity/bldVersion")[0].text
    build_version = identity_el.xpath("identity/buildversion")[0].text
    return prod_name, build_name, build_version


def check_iphy_xml_and_update_if_required(iphy_xml, target_bd):
    tree = ET.parse(iphy_xml)
    root = tree.getroot()
    radio_list = root.findall(".//*[identity]")
    for radio in radio_list:
        prod_name, build_name, build_version = radio_info(radio)
        required_sw_ver = find_sw_version(target_bd, prod_name)
        if not build_name == build_version == required_sw_ver:
            radio.xpath("identity/buildname|identity/bldVersion")[0].text = required_sw_ver
            radio.xpath("identity/buildversion")[0].text = required_sw_ver
            tree.write(iphy_xml, xml_declaration=True, encoding='utf8')
            print("Updated build name and build version for radio", prod_name, "to", required_sw_ver)


def collect_target_bd_file():
    server, username, password = ("192.168.255.129", 'toor4nsn', 'oZPS0POrRieRtu')
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(server, username=username, password=password)
    sftp = ssh.open_sftp()
    ls = sftp.listdir('/rom')
    for fi in ls:
        if re.search(r'TargetBD.*xml', fi):
            file_name = re.search(r'TargetBD.*xml', fi).group(0)
    sftp.get('/rom/' + file_name, '/tmp/' + file_name)
    sftp.close()
    ssh.close()
    return '/tmp/' + file_name


if __name__ == "__main__":
    if len(sys.argv) > 1:
        iphy_xml_path = sys.argv[1]
        target_bd_path = collect_target_bd_file()
        check_iphy_xml_and_update_if_required(iphy_xml_path, target_bd_path)
    else:
        print("Missing argument - path to iphy.xml file.")
