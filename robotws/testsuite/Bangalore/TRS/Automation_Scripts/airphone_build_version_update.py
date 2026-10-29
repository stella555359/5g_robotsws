####################################################################################
#   VERSION          DATE                AUTHOR                     	    COMMENTS
#   1.0              27-Sep-2022         ruchika.vilas_gaurkar@nokia.com     Initial
#                                        mansi.sanjay_sontakke@nokia.com
#                                        nupur.rupram_kohadkar@nokia.com
####################################################################################

import logging
import datetime
import os
import paramiko
import sys
import subprocess
import time
import xmltodict

###########################################################################################
ip_list = ["192.168.255.129", "192.168.200.129"]
fct_username = "toor4nsn"
fct_password = "oZPS0POrRieRtu"
iphy_file_path = "/ffs/run/simmode/"
TargetBD_file_path = "/ffs/run/"


###########################################################################################

def nice_print(message, sign='*'):
    print(''.join([' ', sign * len(message)]))
    print(''.join([' ', message]))
    print(''.join([' ', sign * len(message)]))
    logging.info(message)


def log(filename='airphone_buildversion_update.log'):
    logging.basicConfig(filename=filename, level=logging.DEBUG, format='%(asctime)-6s: %(name)s - %(levelname)s - %('
                                                                       'message)s')
    console = logging.StreamHandler(stream=sys.stdout)
    console.setLevel(logging.WARNING)
    console.setFormatter(logging.Formatter('%(message)s'))
    logger = logging.getLogger()
    logger.addHandler(console)


def check_ping_status():
    logging.debug("Checking Ping Status")
    for ip in ip_list:
        response = subprocess.check_output(["ping", "-c", "4", ip])
        if "4 received" in response:
            logging.debug("Ping Successful for {0}".format(ip))
        else:
            logging.error("Ping Unsuccessful for {0}".format(ip))
            nice_print("FAILED : Ping Unsuccessful for {0}".format(ip))
            sys.exit(1)


def get_iphy_file():
    logging.debug("Getting iphy.xml file")
    output = os.system(
        "sshpass -p {0} scp {1}@{2}:{3}iphy.xml /home/ute/".format(fct_password, fct_username, ip_list[1],
                                                                   iphy_file_path))
    if output != 0:
        nice_print("Unable to Get iphy.xml file")
        sys.exit(1)
    logging.debug("Collected iphy.xml file")


def ssh_to_board(ip):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username=fct_username, password=fct_password)
        return ssh_client

    except Exception as e:
        logging.error(e)
        nice_print("Unable to ssh " + ip)
        sys.exit(1)


def get_targetBD_file():
    logging.debug("Getting TargetBD.xml file")
    ssh_client = ssh_to_board(ip_list[0])
    cmd = "ls -lrt /ffs/run/ | grep TargetBD_*.*xml"
    stdin, stdout, stderr = ssh_client.exec_command(cmd)
    file_list = stdout.read().splitlines()
    filename = file_list[0].strip().split()[-1]
    print(filename)
    if ".p7" in filename:
        filename = filename.replace(".p7", "")
        print(filename)
    logging.info(filename)
    ssh_client.close()
    output = os.system("sshpass -p {0} scp {1}@{2}:{3}{4} /home/ute/".format(fct_password, fct_username, ip_list[0],
                                                                             TargetBD_file_path, filename))
    if output != 0:
        nice_print("Unable to Get TargetBD.xml file")
        sys.exit(1)
    logging.debug("Collected TargetBD.xml file")
    return filename


def get_resource_build_key():
    logging.debug("Getting resource build key")
    with open("{0}/iphy.xml".format(os.getcwd())) as xml_file:
        data_dict = xmltodict.parse(xml_file.read(), force_list=('RE',))
        logging.info(len(data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE']))
    if len(data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE']) > 1:
        build_key = data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][0]['identity']['resourceBuildKey']
    else:
        build_key = data_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE'][0]['identity']['resourceBuildKey']
    logging.info(build_key)
    return build_key, data_dict


def get_compatible_version(filename, build_key):
    global sw_file_key, build_version
    logging.debug("Getting compatible resource key and version")
    with open("/home/ute/{0}".format(filename)) as xml_file:
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
        "sshpass -p {0} scp /home/ute/iphy.xml {1}@{2}:{3}iphy.xml ".format(fct_password, fct_username, ip_list[1],
                                                                            iphy_file_path))
    if output != 0:
        nice_print("Unable to Update IPHY file on AP")
        sys.exit(1)
    logging.debug("Successfully Updated IPHY file")
    print("Successfully Updated IPHY file")


def reboot_boards():
    logging.debug("Rebooting boards!!")
    for ip in ip_list:
        ssh_client = ssh_to_board(ip)
        stdin, stdout, stderr = ssh_client.exec_command("reboot")
        logging.debug(stdout.read().splitlines())
        ssh_client.close()


def main_block():
    log(filename=''.join(
        ["airphone_buildversion_update_", datetime.datetime.now().strftime("%y-%m-%d_%H-%M-%S"), ".log"]))
    check_ping_status()
    get_iphy_file()
    filename = get_targetBD_file()
    build_key, data_dict = get_resource_build_key()
    build_version, sw_file_key = get_compatible_version(filename, build_key)
    logging.info(build_version)
    logging.info(sw_file_key)
    prepare_compatible_file(data_dict, build_version, sw_file_key)
    reboot_boards()
    time.sleep(300)
    print("Reboot Successful for gNB and Airphone.")


if __name__ == "__main__":
    try:
        main_block()
    except KeyboardInterrupt as err:
        logging.debug(err)
        nice_print('Killed from keyboard!', '!')
