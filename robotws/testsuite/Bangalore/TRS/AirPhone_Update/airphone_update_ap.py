#!/usr/bin/python
#####################################################################################################################
#   VERSION          DATE                            AUTHOR                     	           COMMENTS
#   1.0              10-Jun-2022         nupur.rupram_kohadkar@nokia.com                      Initial
#   2.0              01-Nov-2022         nupur.rupram_kohadkar@nokia.com                     Multicell Config
#   3.0              14-Nov-2022         nupur.rupram_kohadkar@nokia.com                     APoABIO Config
#####################################################################################################################
import argparse
import logging
import datetime
import os
import paramiko
import sys
import subprocess
import xmltodict
from bs4 import BeautifulSoup
import requests
import time

#####################################################################################################################
ip = "192.168.200.129"
yaft_path = "/home/ute/YAFT/yaft.py"
fct_username = "toor4nsn"
fct_password = "oZPS0POrRieRtu"
backup_folder_ap = "/backup_configuration/AP"
dci_folder_path = "/user/toor4nsn/DCI/"
iphy_file_path = "/ffs/run/simmode/"
swconfig_file_path = "/ffs/run/"
TargetBD_file_path = "/ffs/run/"
#####################################################################################################################
AP_DCI_SYSCOM_PORT = {
    "asik": ["eif02", "sei13"],
    "asib": "sei13",
    "asil": ["sei10", "sei13"],
    "asoe": "sei10",
    "asim": "sei13"
}


#####################################################################################################################

def nice_print(message, sign='*'):
    print(''.join([' ', sign * len(message)]))
    print(''.join([' ', message]))
    print(''.join([' ', sign * len(message)]))
    logging.info(message)


def log(filename='airphone_update.log'):
    logging.basicConfig(filename=filename, level=logging.DEBUG,
                        format='%(asctime)-6s: %(name)s - %(levelname)s - %(message)s')
    console = logging.StreamHandler(stream=sys.stdout)
    console.setLevel(logging.WARNING)
    console.setFormatter(logging.Formatter('%(message)s'))
    logger = logging.getLogger()
    logger.addHandler(console)


def args_parser():
    parser = argparse.ArgumentParser(description='Script is use to update Airphone Build.\r\n')
    parser.add_argument('--smod', action='store', dest='smod', help='Mention System Module.')
    parser.add_argument('--bbmod', action='store', dest='bbmod', help='Mention Baseband Module.')
    parser.add_argument('--build_version', action='store', dest='build_version', help='Mention gNB Build Version.')
    parser.add_argument('--ap_version', action='store', dest='ap_version', help='Mention AP Build Version.')
    parser.add_argument('--cell', action='store', dest='CellType', help='Mention Cell Type - FDD/TDD.')
    parser.add_argument('--deployment', action='store', dest='CellDeployment',
                        help='Mention Cell Deployment Type - NSA/SANSA.')
    parser.add_argument('--configuration', action='store', dest='Config', help='Mention gNB Configuration - FS/L1b.')
    parser.add_argument('--port', action='store', dest='port', help='Mention Port - SEI/EIF/SEI1/SEI2.')
    parser.add_argument('--ncell', action='store', dest='numcell', help='Number of cells e.g. 1cell/2cell')
    parser.add_argument('--ap_unit', action='store', dest='unit', help='Airphone Unit e.g. ASIK/ASIL')
    args = parser.parse_args()
    return args


def check_ping_status():
    logging.debug("Checking Ping Status")
    response = subprocess.check_output(["ping", "-c", "4", ip])
    if "4 received" in response:
        logging.debug("Ping Successful for {0}".format(ip))
    else:
        logging.error("Ping Unsuccessful for {0}".format(ip))
        nice_print("FAILED : Ping Unsuccessful for {0}".format(ip))
        sys.exit(1)


def check_yaft():
    logging.info("Checking YAFT...")
    if os.path.exists(yaft_path):
        logging.info("YAFT is present")
    else:
        logging.error("YAFT is not present in /home/ute/")
        nice_print("FAILED : YAFT is not present \r\n \
         Please Make sure that YAFT is present in /home/ute/ directory ")
        sys.exit(1)


def download_current_config():
    logging.info("Downloading Current Configuration")
    os.system("mkdir -p {0}{1}".format(os.getcwd(), backup_folder_ap))
    os.system("sshpass -p {3} scp {0}:/ffs/run/swconfig.txt {1}{2}".format(ip, os.getcwd(), backup_folder_ap,
                                                                           fct_password))
    os.system("sshpass -p {3} scp {0}:/rom/simmode/iphy.xml {1}{2}".format(ip, os.getcwd(), backup_folder_ap,
                                                                           fct_password))

    try:
        os.system("sshpass -p {3} scp -r {0}:DCI {1}{2}".format(ip, os.getcwd(), backup_folder_ap, fct_password))
    except Exception as e:
        logging.info(e)
        logging.info("No DCI Link Installed on AP")


def download_ap_build(ap_build):
    logging.info("Downloading AirPhone Build")
    ap_url = "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/" \
             "Airphone/{0}/AirScale-{0}.zip".format(ap_build)
    dci_url = "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/" \
              "Airphone/{0}/DCI_link_network_config-{0}.tar.gz".format(ap_build)
    logging.debug(ap_url)
    logging.debug(dci_url)
    if os.path.exists("{1}/AirScale-{0}.zip".format(ap_build, os.getcwd())):
        os.system("rm -rf {1}/AirScale-{0}.zip".format(ap_build, os.getcwd()))
    ap_output = os.system("wget -P {1}/ {0}".format(ap_url, os.getcwd()))
    if os.path.exists("{1}/DCI_link_network_config-{0}.tar.gz".format(ap_build, os.getcwd())):
        os.system("rm -rf {1}/DCI_link_network_config-{0}.tar.gz".format(ap_build, os.getcwd()))
    dci_output = os.system("wget -P {1}/ {0}".format(dci_url, os.getcwd()))

    if (ap_output != 0) and (dci_output != 0):
        nice_print("Unable to Download Airphone Build")
        sys.exit(1)

    logging.info("Airphone Build Downloaded Sucessfully.")


def get_wts_build(ap_build):
    logging.info("Get WTS Build")
    page = requests.get(
        "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/{0}/".format(ap_build))
    soup = BeautifulSoup(page.content, 'html.parser')
    files = soup.find_all("a")

    for file in files:
        if file.get_text().startswith("esimmode_WTS"):
            logging.debug("Required WTS Build : {0}".format(file.get_text()))
            return file.get_text()

    nice_print("Unable to get WTS Build")
    sys.exit(1)


def download_wts_build(ap_build, wts_build):
    logging.info("Downloading WTS Build")
    wts_url = "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/{0}/{1}".format(
        ap_build, wts_build)
    if os.path.exists("/opt/iphy/latest/{0}".format(wts_build)):
        os.system("rm -rf /opt/iphy/latest/{0}".format(wts_build))

    wts_output = os.system("sudo wget -P /opt/iphy/latest/ {0}".format(wts_url))
    if wts_output != 0:
        nice_print("Unable to download WTS build")
        sys.exit(1)
    logging.info("Downloaded WTS Build")


def install_wts_build(wts_build):
    logging.info("Installing WTS Build")
    os.system("cd /opt/iphy/latest/ ; tar -xvf {0}".format(wts_build))
    logging.info("Installed WTS Build")


def upgrade_ap(ap_build):
    logging.info("Upgrading AP Software")

    ap_output = os.system(
        "python {0} -i {1} -z {3}/AirScale-{2}.zip --clean_to_default "
        "--ask_for_password".format(yaft_path, ip, ap_build, os.getcwd()))
    if ap_output != 0:
        nice_print("Unable to Upgrade Airphone Software")
        sys.exit(1)


def ssh_to_board(ip):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username=fct_username, password=fct_password)
        return ssh_client
    except Exception as e:
        logging.debug(e)
        nice_print("Unable to ssh " + ip)
        sys.exit(1)


def upload_dci_link(ap_build):
    logging.info("Updating DCI link on GNB and AP")

    try:
        ssh_client = ssh_to_board(ip)
        ssh_client.exec_command("rm -rf {0}".format(dci_folder_path))
        ssh_client.exec_command("mkdir {0}".format(dci_folder_path))
        os.system("sshpass -p {0} scp {5}/DCI_link_network_config-{1}.tar.gz {2}@{3}:{4}".format(
            fct_password, ap_build, fct_username, ip, dci_folder_path, os.getcwd()))
        time.sleep(5)
        logging.info(
            "sshpass -p '{4}' ssh {3}@{2} tar -xvf {0}DCI_link_network_config-{1}.tar.gz -C {0}".format(
                dci_folder_path,
                ap_build, ip,
                fct_username,
                fct_password))
        os.system(
            "sshpass -p '{4}' ssh {3}@{2} tar -xvf {0}DCI_link_network_config-{1}.tar.gz -C {0}".format(
                dci_folder_path,
                ap_build, ip,
                fct_username,
                fct_password))
        ssh_client.close()
        logging.info("Uploaded DCI Link for {0}".format(ip))
    except Exception as e:
        print(e)
        nice_print("Unable to Upload DCI Link for {0}".format(ip))
        sys.exit(1)


def install_dci_link(smod, port="default"):
    logging.info("Installing DCI link on GNB and AP")
    try:
        ssh_client = ssh_to_board(ip)
        logging.info("SMOD: {0} PORT: {1}".format(smod.upper(), port.upper()))
        if smod.lower() == "asik":
            if port.lower() == "sei":
                cmd = '0,/eif02/s//{0}/'.format(AP_DCI_SYSCOM_PORT['asik'][1])
            else:
                cmd = '0,/eif02/s//{0}/'.format(AP_DCI_SYSCOM_PORT['asik'][0])
        elif smod.lower() == "asib":
            cmd = '0,/eif02/s//{0}/'.format(AP_DCI_SYSCOM_PORT['asib'])
        elif smod.lower() == "asil":
            if port.lower() == "sei2":
                cmd = '0,/eif02/s//{0}/'.format(AP_DCI_SYSCOM_PORT['asil'][1])
            else:
                cmd = '0,/eif02/s//{0}/'.format(AP_DCI_SYSCOM_PORT['asil'][0])
        elif smod.lower() == "asoe":
            cmd = '0,/eif02/s//{0}/'.format(AP_DCI_SYSCOM_PORT['asoe'])
        elif smod.lower() == "asim":
            cmd = '0,/eif02/s//{0}/'.format(AP_DCI_SYSCOM_PORT['asim'])

        ssh_client.exec_command("sed -i {0} /user/toor4nsn/DCI/deploy.cfg".format(cmd))
        time.sleep(10)

        os.system("sshpass -p '{0}' ssh {1}@{2} 'cd {3} && sh deploy.sh <<< yes'".format(fct_password, fct_username,
                                                                                         ip, dci_folder_path))
        ssh_client.close()
        logging.info("Installed DCI link on AP")
    except Exception as e:
        logging.error(e)
        nice_print("Unable to Install DCI Link")
        sys.exit(1)


def set_ddal_value():
    logging.info("Setting ddal value for AP")
    try:
        ssh_client = ssh_to_board(ip)
        ssh_client.exec_command("ddal -s ddal_sysinfo_module_set_domain_id 0 5")
        ssh_client.close()
    except Exception as e:
        logging.error(e)
        nice_print("Unable to Set ddal value")
        sys.exit(1)
    logging.info("Set ddal value for AP")


def push_iphy_for_rmod_with_bbmod(CellDeployment, Config, smod, bbmod, CellType, Ncell, ap_top):
    logging.info("Pushing IPHY file for RMOD with BBMOD")
    if os.path.exists(
            "{0}/config/{7}/{1}/{2}/{3}/{4}/{5}/{6}/iphy.xml".format(os.getcwd(), CellDeployment.upper(),
                                                                     Config.upper(), smod.upper(), bbmod.upper(),
                                                                     CellType.upper(), Ncell.lower(), ap_top)):
        logging.debug("sshpass -p {0} scp {10}/config/{11}/{1}/{2}/{3}/{4}/{5}/{6}/iphy.xml {7}@{8}:{9}".format(
            fct_password, CellDeployment.upper(), Config.upper(), smod.upper(), bbmod.upper(), CellType.upper(),
            Ncell.lower(), fct_username, ip, iphy_file_path, os.getcwd(), ap_top))
        time.sleep(10)
        os.system("sshpass -p {0} scp {10}/config/{11}/{1}/{2}/{3}/{4}/{5}/{6}/iphy.xml {7}@{8}:{9}".format(
            fct_password,
            CellDeployment.upper(),
            Config.upper(),
            smod.upper(),
            bbmod.upper(),
            CellType.upper(),
            Ncell.lower(),
            fct_username, ip,
            iphy_file_path,
            os.getcwd(),
            ap_top))
    else:
        nice_print("Unable to Push Iphy file as file is not present in config")
        sys.exit(1)
    logging.info("Sucessfully Pushed IPHY file")


def push_iphy_for_rmod(CellDeployment, Config, smod, CellType, Ncell, ap_top):
    logging.info("Pushing IPHY file for RMOD")
    if os.path.exists("{0}/config/{6}/{1}/{2}/{3}/{4}/{5}/iphy.xml".format(os.getcwd(), CellDeployment.upper(),
                                                                           Config.upper(), smod.upper(),
                                                                           CellType.upper(), Ncell.lower(), ap_top)):
        logging.debug("sshpass -p {0} scp {9}/config/{10}/{1}/{2}/{3}/{4}/{5}/iphy.xml {6}@{7}:{8}".format(
            fct_password,
            CellDeployment.upper(),
            Config.upper(),
            smod.upper(),
            CellType.upper(),
            Ncell.lower(),
            fct_username, ip,
            iphy_file_path,
            os.getcwd(),
            ap_top))
        time.sleep(10)
        os.system("sshpass -p {0} scp {9}/config/{10}/{1}/{2}/{3}/{4}/{5}/iphy.xml {6}@{7}:{8}".format(
            fct_password,
            CellDeployment.upper(),
            Config.upper(),
            smod.upper(),
            CellType.upper(),
            Ncell.lower(),
            fct_username, ip,
            iphy_file_path,
            os.getcwd(),
            ap_top))
    else:
        nice_print("Unable to Push Iphy file as file is not present in config")
        sys.exit(1)
    logging.info("Sucessfully Pushed IPHY file")


def upload_swconfig(build_version, ap_version, CellDeployment, Config, smod, CellType, ap_top):
    logging.info("Downloading and Uploading swconfig files for GNB and AP")
    page = requests.get(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};"
        "f={1}/{2}/{3};a=tree;".format(
            ap_version, build_version, CellDeployment.upper(), Config))
    logging.debug(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};"
        "f={1}/{2}/{3};a=tree;".format(
            ap_version, build_version, CellDeployment.upper(), Config))
    soup = BeautifulSoup(page.content, 'html.parser')
    files = soup.find_all("a")
    logging.debug(files)
    try:
        for file in files:
            if file.get_text().startswith("AP_swconfig_{0}_{1}".format(smod.upper(), CellType.upper())):
                file_name = file.get_text()
                logging.info(file_name)
            elif file.get_text().startswith("AP_swconfig_{0}_{1}_AP_{2}_{3}".format(
                    smod.upper()[-2], smod.upper()[-1], ap_top.upper(), CellType.upper())):
                file_name = file.get_text()
                logging.info(file_name)

        response = requests.get(
            "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};"
            "f={1}/{2}/{3}/{4};a=blob_plain;".format(
                ap_version, build_version, CellDeployment, Config, file_name))
        logging.debug(response)
        with open("swconfig.txt", 'w') as f:
            f.write(response.text)
            f.write("\n")
        logging.info("Downloaded swconfig file for AP")
        os.system("sshpass -p {0} scp {1}/swconfig.txt {2}@{3}:{4}".format(fct_password, os.getcwd(), fct_username, ip,
                                                                           swconfig_file_path))
        logging.debug(
            "sshpass -p {0} scp {1}/swconfig.txt {2}@{3}:{4}".format(fct_password, os.getcwd(), fct_username, ip,
                                                                     swconfig_file_path))
        os.system("rm -rf {0}/swconfig.txt".format(os.getcwd()))
    except Exception as e:
        logging.error(e)
        nice_print("Unable to Upload swconfig")
        sys.exit(1)


def upload_swconfig_with_bbmod(build_version, ap_version, CellDeployment, Config, smod, bbmod, CellType, ap_top):
    logging.info("Downloading and Uploading swconfig files for GNB and AP")
    page = requests.get(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};f={1}/{2}/{3};"
        "a=tree;".format(
            ap_version, build_version, CellDeployment.upper(), Config))
    logging.debug(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};f={1}/{2}/{3};"
        "a=tree;".format(
            ap_version, build_version, CellDeployment.upper(), Config))
    soup = BeautifulSoup(page.content, 'html.parser')
    files = soup.find_all("a")
    logging.debug(files)
    try:
        for file in files:
            if smod.lower() == "asil" and (ap_top.upper() == "KL"):
                if file.get_text().startswith("AP_swconfig_ASIB_{1}_{2}".format(
                        smod.upper(), bbmod.upper(), CellType.upper())) and not file.get_text().endswith("ORAN.txt"):
                    file_name = file.get_text()
                    logging.info(file_name)
            else:
                if file.get_text().startswith("AP_swconfig_{0}_{1}_{2}".format(
                        smod.upper(), bbmod.upper(), CellType.upper())) and not file.get_text().endswith("ORAN.txt"):
                    file_name = file.get_text()
                    logging.info(file_name)
                elif file.get_text().startswith("AP_swconfig_{0}{1}_AP_{2}_{3}".format(
                        smod.upper()[-1], bbmod.upper()[-1], ap_top.upper(), CellType.upper())
                ) and not file.get_text().endswith("ORAN.txt"):
                    file_name = file.get_text()
                    logging.info(file_name)

        response = requests.get(
            "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};"
            "f={1}/{2}/{3}/{4};a=blob_plain;".format(
                ap_version, build_version, CellDeployment, Config, file_name))
        logging.debug(response)
        with open("swconfig.txt", 'w') as f:
            f.write(response.text)
            f.write("\n")
        logging.info("Downloaded swconfig file for AP")
        os.system("sshpass -p {0} scp {1}/swconfig.txt {2}@{3}:{4}".format(fct_password, os.getcwd(), fct_username, ip,
                                                                           swconfig_file_path))
        logging.debug(
            "sshpass -p {0} scp {1}/swconfig.txt {2}@{3}:{4}".format(fct_password, os.getcwd(), fct_username, ip,
                                                                     swconfig_file_path))
        os.system("rm -rf {0}/swconfig.txt".format(os.getcwd()))
    except Exception as e:
        logging.error(e)
        nice_print("Unable to Upload swconfig")
        sys.exit(1)


def reboot_gnb_ap():
    logging.info("Rebooting AP and GNB")
    try:
        ssh_client = ssh_to_board(ip)
        ssh_client.exec_command("reboot")
        ssh_client.close()
    except Exception as e:
        logging.error(e)
        nice_print("Unable to Reboot")
        sys.exit(1)
    logging.info("Sucessfully Updated Airphone Software")
    print("Sucessfully Updated Airphone Software")


def get_iphy_file():
    logging.debug("Getting iphy.xml file")
    output = os.system(
        "sshpass -p {0} scp {1}@{2}:{3}iphy.xml {4}/".format(fct_password, fct_username, ip,
                                                             iphy_file_path, os.getcwd()))
    if output != 0:
        nice_print("Unable to Get iphy.xml file")
        sys.exit(1)
    logging.debug("Collected iphy.xml file")


def get_targetBD_file():
    logging.debug("Getting TargetBD.xml file")
    ssh_client = ssh_to_board("192.168.255.129")
    cmd = "ls -lrt /ffs/run/ | grep TargetBD_*.*xml"
    stdin, stdout, stderr = ssh_client.exec_command(cmd)
    file_list = stdout.read().splitlines()
    filename = file_list[0].strip().split()[-1]
    if ".p7" in filename:
        filename = filename.replace(".p7", "")
        print(filename)
    logging.info(filename)
    ssh_client.close()
    output = os.system("sshpass -p {0} scp {1}@{2}:{3}{4} {5}/".format(fct_password, fct_username,
                                                                       "192.168.255.129",
                                                                       TargetBD_file_path, filename, os.getcwd()))
    if output != 0:
        nice_print("Unable to Get TargetBD.xml file")
        sys.exit(1)
    logging.debug("Collected TargetBD.xml file")
    return filename


def get_resource_build_key():
    logging.debug("Getting resource build key")
    with open("{0}/iphy.xml".format(os.getcwd())) as xml_file:
        data_dict = xmltodict.parse(xml_file.read(), force_list=('RE',))
    if len(data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE']) > 1:
        build_key = data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][0]['identity']['resourceBuildKey']
    else:
        build_key = data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][0]['identity']['resourceBuildKey']
    logging.info(build_key)
    return build_key, data_dict


def get_compatible_version(filename, build_key):
    global sw_file_key, build_version
    logging.debug("Getting compatible resource key and version")
    with open("{0}/{1}".format(os.getcwd(), filename)) as xml_file:
        data_dict_1 = xmltodict.parse(xml_file.read())
    for id in range(len(data_dict_1['targetBD']['hwResource'])):
        if (data_dict_1['targetBD']['hwResource'][id]['@resourceBuildKey']) == build_key:
            build_version = data_dict_1['targetBD']['hwResource'][id]['@resourceSWVersion']
            sw_file_key = data_dict_1['targetBD']['hwResource'][id]['swFileKey']
    return build_version, sw_file_key


def prepare_compatible_file(data_dict, build_version, sw_file_key):
    logging.debug("Preparing compatible IPHY file")
    for rmod in range(len(data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'])):
        data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][rmod]['identity'][
            'bldVersion'] = build_version
        data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][rmod]['identity'][
            'buildversion'] = build_version
        for key in range(len(
                data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][rmod]['soap-config']['software'][
                    'file'])):
            data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][rmod]['soap-config']['software']['file'][
                key]['name'] = sw_file_key
            data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][rmod]['soap-config']['software']['file'][
                key]['version'] = build_version
    logging.info("Versions are Updated !!")
    xml = xmltodict.unparse(data_dict, pretty=True)
    xmlfile = open("iphy.xml", "w")
    xmlfile.write(xml)
    xmlfile.close()
    logging.debug("File Created Successfully !!")
    output = os.system(
        "sshpass -p {0} scp iphy.xml {1}@{2}:{3}iphy.xml ".format(fct_password, fct_username, ip,
                                                                  iphy_file_path))
    if output != 0:
        nice_print("Unable to Update IPHY file on AP")
        sys.exit(1)
    logging.debug("Successfully Updated IPHY file")


def main_block():
    args = args_parser()
    log(filename=''.join(["airphone_update_", datetime.datetime.now().strftime("%y-%m-%d_%H-%M-%S"), ".log"]))
    logging.info(args)
    check_ping_status()
    check_yaft()
    download_current_config()
    time.sleep(10)
    download_ap_build(args.ap_version)
    time.sleep(10)
    wts_build = get_wts_build(args.ap_version)
    time.sleep(10)
    download_wts_build(args.ap_version, wts_build)
    time.sleep(10)
    install_wts_build(wts_build)
    time.sleep(10)
    upgrade_ap(args.ap_version)
    time.sleep(300)

    if args.unit is None:
        ap_unit = "ASIK"
    else:
        ap_unit = args.unit

    if ap_unit.lower() == "asik":
        ap_top = "KL"
    elif ap_unit.lower() == "asil":
        ap_top = "LO"

    if ap_unit.lower() == "asik":
        upload_dci_link(args.ap_version)
        time.sleep(10)
        if args.port is None:
            install_dci_link(args.smod)
        else:
            install_dci_link(args.smod, args.port)

    if args.numcell is None:
        ncell = "1cell"
    else:
        ncell = args.numcell

    set_ddal_value()
    if args.bbmod is None:
        push_iphy_for_rmod(args.CellDeployment, args.Config, args.smod, args.CellType, ncell, ap_top)
        time.sleep(10)
        upload_swconfig(args.build_version, args.ap_version, args.CellDeployment, args.Config, args.smod,
                        args.CellType, ap_top)
    else:
        push_iphy_for_rmod_with_bbmod(args.CellDeployment, args.Config, args.smod, args.bbmod, args.CellType, ncell,
                                      ap_top)
        time.sleep(10)
        upload_swconfig_with_bbmod(args.build_version, args.ap_version, args.CellDeployment, args.Config, args.smod,
                                   args.bbmod, args.CellType, ap_top)
    get_iphy_file()
    filename = get_targetBD_file()
    build_key, data_dict = get_resource_build_key()
    build_version, sw_file_key = get_compatible_version(filename, build_key)
    logging.info(build_version)
    logging.info(sw_file_key)
    prepare_compatible_file(data_dict, build_version, sw_file_key)
    reboot_gnb_ap()
    time.sleep(300)
    print("Reboot Successful for gNB and Airphone.")


if __name__ == "__main__":
    try:
        main_block()
    except KeyboardInterrupt as err:
        logging.debug(err)
        nice_print('Killed from keyboard!', '!')
