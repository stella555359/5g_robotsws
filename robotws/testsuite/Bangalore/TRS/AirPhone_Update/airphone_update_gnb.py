#!/usr/bin/python
######################################################################################################################
#   VERSION          DATE                            AUTHOR                     	           COMMENTS
#   1.0              10-Jun-2022         nupur.rupram_kohadkar@nokia.com                      Initial
#   2.0              01-Nov-2022         nupur.rupram_kohadkar@nokia.com                     Multicell Config
#   3.0              14-Nov-2022         nupur.rupram_kohadkar@nokia.com                     APoABIO Config
######################################################################################################################
import argparse
import logging
import datetime
import os
import paramiko
import sys
import subprocess
from bs4 import BeautifulSoup
import requests
import time

######################################################################################################################
ip = "192.168.255.119"
fct_username = "toor4nsn"
fct_password = "oZPS0POrRieRtu"
backup_folder_gnb = "/backup_configuration/GNB"
dci_folder_path = "/user/toor4nsn/DCI/"
swconfig_file_path = "/ffs/run/"
#####################################################################################################################
GNB_DCI_SYSCOM_PORT = {
    "asik": ["eif02", "sei13"],
    "asib": "ncpeth49",
    "asil": ["sei21", "sei28"],
    "asoe": "naceth19",
    "asim": "ncpeth49"
}


#####################################################################################################################


def nice_print(message, sign='*'):
    print(''.join([' ', sign * len(message)]))
    print(''.join([' ', message]))
    print(''.join([' ', sign * len(message)]))
    logging.info(message)


def log(filename='airphone_update.log'):
    logging.basicConfig(filename=filename, level=logging.DEBUG, format='%(asctime)-6s: %(name)s - %(levelname)s - %('
                                                                       'message)s')
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
    parser.add_argument('--deployment', action='store', dest='CellDeployment', help='Mention Cell Deployment Type - '
                                                                                    'NSA/SANSA.')
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


def download_current_config():
    logging.info("Downloading Current Configuration")
    os.system("mkdir -p Backup_Configuration/GNB")
    os.system("sshpass -p {3} scp {0}:/ffs/run/swconfig.txt {1}{2}".format(ip, os.getcwd(), backup_folder_gnb,
                                                                           fct_password))
    try:
        os.system("sshpass -p {3} scp -r {0}:DCI {1}{2}".format(ip, os.getcwd(), backup_folder_gnb, fct_password))
    except Exception as e:
        logging.error(e)
        logging.info("No DCI Link Installed on GNB")


def ssh_to_board(ip):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username=fct_username, password=fct_password)
        return ssh_client
    except Exception as e:
        logging.info(e)
        nice_print("Unable to ssh " + ip)
        sys.exit(1)


def download_ap_build(ap_build):
    logging.info("Downloading DCI Package")
    dci_url = "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/{0}/" \
              "DCI_link_network_config-{0}.tar.gz".format(ap_build)
    logging.debug(dci_url)
    if os.path.exists("{1}/DCI_link_network_config-{0}.tar.gz".format(ap_build, os.getcwd())):
        os.system("rm -rf {1}/DCI_link_network_config-{0}.tar.gz".format(ap_build, os.getcwd()))
    dci_output = os.system("wget -P {1} {0}".format(dci_url, os.getcwd()))

    if dci_output != 0:
        nice_print("Unable to Download DCI Package")
        sys.exit(1)

    logging.info("DCI Package Downloaded Sucessfully.")


def upload_dci_link(ap_build):
    logging.info("Updating DCI link on GNB")

    try:
        ssh_client = ssh_to_board(ip)
        ssh_client.exec_command("rm -rf {0}".format(dci_folder_path))
        ssh_client.exec_command("mkdir {0}".format(dci_folder_path))
        os.system("sshpass -p {0} scp {5}/DCI_link_network_config-{1}.tar.gz {2}@{3}:{4}".format(
            fct_password, ap_build, fct_username, ip, dci_folder_path, os.getcwd()))
        time.sleep(10)
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
    logging.info("Installing DCI link on GNB")
    try:
        ssh_client = ssh_to_board(ip)
        logging.info("SMOD: {0} PORT: {1}".format(smod.upper(), port.upper()))
        if smod.lower() == "asik":
            if port.lower() == "sei":
                cmd = '0,/eif02/s//{0}/'.format(GNB_DCI_SYSCOM_PORT['asik'][1])
            else:
                cmd = '0,/eif02/s//{0}/'.format(GNB_DCI_SYSCOM_PORT['asik'][0])
        elif smod.lower() == "asib":
            cmd = '0,/eif02/s//{0}/'.format(GNB_DCI_SYSCOM_PORT['asib'])
        elif smod.lower() == "asil":
            if port.lower() == "sei2":
                cmd = '0,/eif02/s//{0}/'.format(GNB_DCI_SYSCOM_PORT['asil'][1])
            else:
                cmd = '0,/eif02/s//{0}/'.format(GNB_DCI_SYSCOM_PORT['asil'][0])
        elif smod.lower() == "asoe":
            cmd = '0,/eif02/s//{0}/'.format(GNB_DCI_SYSCOM_PORT['asoe'])

        ssh_client.exec_command("sed -i {0} /user/toor4nsn/DCI/deploy.cfg".format(cmd))
        time.sleep(10)
        os.system("sshpass -p '{0}' ssh {1}@{2} 'cd {3} && sh deploy.sh <<< yes'".format(fct_password, fct_username,
                                                                                         ip,
                                                                                         dci_folder_path))
        ssh_client.close()
        logging.info("Installed DCI link on GNB")
    except Exception as e:
        logging.error(e)
        nice_print("Unable to Install DCI Link")
        sys.exit(1)


def upload_swconfig(build_version, ap_version, CellDeployment, Config, smod, CellType, ap_top):
    logging.info("Downloading and Uploading swconfig files for GNB and AP")
    page = requests.get(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};f={1}/{2}/{3};"
        "a=tree;".format(ap_version, build_version, CellDeployment.upper(), Config))
    logging.debug(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};f={1}/{2}/{3};"
        "a=tree;".format(ap_version, build_version, CellDeployment.upper(), Config))
    soup = BeautifulSoup(page.content, 'html.parser')
    files = soup.find_all("a")
    logging.debug(files)
    try:
        for file in files:
            if file.get_text().startswith("gNB_swconfig_{0}_{1}".format(smod.upper(), CellType.upper())):
                file_name = file.get_text()
                logging.info(file_name)
            elif file.get_text().startswith("gNB_swconfig_{0}_{1}_AP_{2}_{3}".format(
                    smod.upper()[-2], smod.upper()[-1], ap_top.upper(), CellType.upper())):
                file_name = file.get_text()
                logging.info(file_name)

        response = requests.get(
            "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};"
            "f={1}/{2}/{3}/{4};a=blob_plain;".format(ap_version, build_version, CellDeployment, Config, file_name))
        logging.debug(response)
        with open("swconfig.txt", 'w') as f:
            f.write(response.text)
            f.write("\n")
        logging.info("Downloaded swconfig file for GNB")
        os.system("sshpass -p {0} scp {1}/swconfig.txt {2}@{3}:{4}".format(fct_password, os.getcwd(), fct_username, ip,
                                                                           swconfig_file_path))
        logging.debug(
            "sshpass -p {0} scp {1}/swconfig.txt {2}@{3}:{4}".format(fct_password, os.getcwd(), fct_username, ip,
                                                                     swconfig_file_path))
    except Exception as e:
        logging.error(e)
        nice_print("Unable to Upload swconfig")
        sys.exit(1)


def upload_swconfig_with_bbmod(build_version, ap_version, CellDeployment, Config, smod, bbmod, CellType, ap_top):
    logging.info("Downloading and Uploading swconfig files for GNB and AP")
    page = requests.get(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};f={1}/{2}/{3};"
        "a=tree;".format(ap_version, build_version, CellDeployment.upper(), Config))
    logging.debug(
        "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};f={1}/{2}/{3};"
        "a=tree;".format(ap_version, build_version, CellDeployment.upper(), Config))
    soup = BeautifulSoup(page.content, 'html.parser')
    files = soup.find_all("a")
    logging.debug(files)
    try:
        for file in files:
            if smod.lower() == "asil" and (ap_top.upper() == "KL"):
                if file.get_text().startswith("gNB_swconfig_ASIB_{1}_{2}".format(
                        smod.upper(), bbmod.upper(), CellType.upper())) and not file.get_text().endswith("ORAN.txt"):
                    file_name = file.get_text()
                    logging.info(file_name)
            else:
                if file.get_text().startswith("gNB_swconfig_{0}_{1}_{2}".format(
                        smod.upper(), bbmod.upper(), CellType.upper())) and not file.get_text().endswith("ORAN.txt"):
                    file_name = file.get_text()
                    logging.info(file_name)
                elif file.get_text().startswith("gNB_swconfig_{0}{1}_AP_{2}_{3}".format(
                        smod.upper()[-1], bbmod.upper()[-1], ap_top.upper(), CellType.upper())
                ) and not file.get_text().endswith("ORAN.txt"):
                    file_name = file.get_text()
                    logging.info(file_name)

        response = requests.get(
            "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/TEST/testconfigs.git;hb=refs/tags/{0};"
            "f={1}/{2}/{3}/{4};a=blob_plain;".format(ap_version, build_version, CellDeployment, Config, file_name))
        logging.debug(response)
        with open("swconfig.txt", 'w') as f:
            f.write(response.text)
            f.write("\n")
        logging.info("Downloaded swconfig file for GNB")
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
    logging.info("Sucessfully Updated files")
    print("Sucessfully Updated files")


def main_block():
    args = args_parser()
    log(filename=''.join(["gnb_update_", datetime.datetime.now().strftime("%y-%m-%d_%H-%M-%S"), ".log"]))
    logging.info(args)
    check_ping_status()
    download_current_config()
    #    download_ap_build(args.ap_version)
    if args.unit is None:
        ap_unit = "ASIK"
    else:
        ap_unit = args.unit

    if ap_unit.lower() == "asik":
        ap_top = "KL"
    elif ap_unit.lower() == "asil":
        ap_top = "LO"
    '''
    if ap_unit.lower() == "asik":
        upload_dci_link(args.ap_version)
        time.sleep(10)
        if args.port is None:
            install_dci_link(args.smod)
        else:
            install_dci_link(args.smod, args.port)
    '''
    if args.numcell is None:
        ncell = "1cell"
    else:
        ncell = args.numcell

    time.sleep(10)

    if args.bbmod is None:
        upload_swconfig(args.build_version, args.ap_version, args.CellDeployment, args.Config, args.smod,
                        args.CellType, ap_top)
    else:
        upload_swconfig_with_bbmod(args.build_version, args.ap_version, args.CellDeployment, args.Config, args.smod,
                                   args.bbmod, args.CellType, ap_top)
    reboot_gnb_ap()


if __name__ == "__main__":
    try:
        main_block()
    except KeyboardInterrupt as err:
        logging.debug(err)
        nice_print('Killed from keyboard!', '!')
