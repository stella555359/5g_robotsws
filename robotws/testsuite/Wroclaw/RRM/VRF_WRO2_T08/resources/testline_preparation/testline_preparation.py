import json
import os
import re
import shutil
import socket
import subprocess
import time

import paramiko
import requests
from robot.libraries.BuiltIn import BuiltIn as RobotBuiltIn
from taf.sbts.oam.coam.admin import admin
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.statuses import STATUSES
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.mcshark import prepare_mcshark

admin = admin()
ssh = paramiko.SSHClient()
branches = ['SBTS22R1', 'SBTS22R2', 'SBTS22R3', 'SBTS22R4', 'SBTS23R1', 'SBTS23R2', 'SBTS23R3', 'SBTS23R4',
            'SBTS24R1', 'SBTS00']
access_key = "1rr68OUDVBboLWbUcSxcN4tyFyTt3vTFiibZTxKx"
wft_url = "https://wft.int.net.nokia.com:8091/api/v1/"
artifactory_key = "AKCp8oiHU5YPce4g24nY4H9XxoVHAVzcydFrggjst4Ym8FPW7jnEnLDyTDbkNk6ma5XV2NC95"


def cut_gnb_for_t322(gnbs, cut_324):
    return gnbs[1:] if cut_324 else gnbs


def fix_branch(software):
    return "_".join(["SBTS00", software.split("_", 1)[1]]) if software.split("_")[2] in ['9999', '9990'] else software


def switch_pdu_ports(mode) -> None:
    """Execute a PDU power action via ``ecolab_cli``.

    :param str mode: Action to perform power_on, power_off or reboot.
    :raises AssertionError: If mode is not one of the allowed values.
    :returns: None
    """
    assert mode in ['power_on', 'power_off', 'reboot'], \
        'wrong mode input, please use \'power_on\', \'power_off\' or \'reboot\''
    tl_name = '_'.join(socket.gethostname().split('-')[:3])
    commands = ['pip install taf.tools.ecolab', 'ecolab_cli {mode} -c /home/ute/testline_configuration/{tl_name}/'
                '__init__.py'.format(mode=mode, tl_name=tl_name)]
    for command in commands:
        try:
            output = subprocess.check_output(command, shell=True)
        except subprocess.CalledProcessError as error:
            logger.console(f'Error code: {error.returncode}')


def find_sw_in_reservation_json(sw_for_update, current_sw):
    if os.path.exists('/opt/ute/reservation.json'):
        with open('/opt/ute/reservation.json', 'r') as json_file:
            reservation_details = json.load(json_file)
        return reservation_details['enb_build']
    return current_sw if sw_for_update is None else sw_for_update


def check_if_agent_updated_software(sw, sw_for_update):
    return True if fix_branch(sw) == sw_for_update else False


def get_compatible_enb_build(branch, build):
    build = fix_branch(build)
    if '5G21A_GNB' in build:
        build_parts = build.split("_")
        build = '5G21A_11.' + build_parts[-2].lstrip('0') + '.' + build_parts[-1].lstrip('0')
    if branch == "trunk":
        branch = "SBTS00"
    endpoint = "https://wft.int.net.nokia.com:8091/api/v1/{0}/CI_ENB/builds/{1}/attributes.json".format(branch, build)
    r = requests.get('{0}?access_key={1}'.format(endpoint, access_key))
    response = r.json()
    compatible_build = []
    for attribute in response:
        if "Compatibility" in attribute["build_attribute_type"]["title"]:
            compatible_build = json.loads(attribute["value"])["eNB"][0]
            break
    if not compatible_build:
        if '5G' in build:
            parts = build.split('.')
            parts[-1] = str(int(parts[-1]) - 1)
            new_build = '.'.join(parts)
            compatible_build = get_compatible_enb_build(branch, new_build)
        else:
            compatible_build = build
    return compatible_build


def find_compatible_build(branch, build):
    if branch == "trunk":
        branch = "SBTS00"
    return get_compatible_enb_build(branch, build)


def check_if_conf_reset_is_needed(source_sw, target_sw):
    return True if branches.index(source_sw) > branches.index(target_sw) else \
        False if branches.index(source_sw) + 2 >= branches.index(target_sw) else True


def check_if_update_is_needed(build, compatible_build):
    build = fix_branch(build)
    return False if compatible_build == build else True, \
        check_if_conf_reset_is_needed(build.split("_")[0], compatible_build.split("_")[0])


def compare_branches(current_sw, sw_for_update):
    current_sw = fix_branch(current_sw)
    return True if current_sw.split("_")[0] == sw_for_update.split("_")[0] else False


def get_number_of_neighbour_gnbs_and_enbs():
    init_dir = '/home/ute/testline_configuration/{tl_name}/__init__.py'. \
        format(tl_name=socket.gethostname().replace('-', '_'))
    print(init_dir)
    gnbs = find_stations(init_dir, 'gnb')
    enbs = find_stations(init_dir, 'enb')
    return gnbs, enbs


def find_stations(init_file, node_type):
    regex = "_lmp_vm_gnb_\\d{1,5} = " if node_type == 'gnb' else "_lmp_vm_enb_\\d{1,5} = "
    textfile = open(init_file, 'r')
    filetext = textfile.read()
    textfile.close()
    matches = [x.split(" ")[0] for x in re.findall(regex, filetext)]
    if node_type == 'gnb' and '_lmp_vm_gnb_1' in matches:
        matches.remove('_lmp_vm_gnb_1')
    return matches


def find_lmp_index_in_init(node):
    init_dir = '/home/ute/testline_configuration/{tl_name}/__init__.py'. \
        format(tl_name=socket.gethostname().replace('-', '_'))
    textfile = open(init_dir, 'r')
    for line in textfile:
        if 'test_pcs' in line:
            test_pcs = line.split(',')
            for x in range(0, len(test_pcs)):
                if str(node) in str(test_pcs[x]):
                    return x


def find_node_index_in_init(bts_type, node):
    init_dir = '/home/ute/testline_configuration/{tl_name}/__init__.py'. \
        format(tl_name=socket.gethostname().replace('-', '_'))
    textfile = open(init_dir, 'r')
    look_for = 'enbs' if bts_type == 'enb' else 'gnbs'
    for line in textfile:
        if look_for in line:
            nodes = line.split(',')
            for x in range(0, len(nodes)):
                if node.split('_')[-1] in str(nodes[x]):
                    return x


def get_node_scf_path(node_name, branch_scf):
    if node_name.split('_')[-2] == 'gnb':
        ending = '_' + node_name.split('_')[-1] + '_5g.xml'
        node_scf_path = branch_scf.replace('_5g.xml', ending)
    else:
        ending = '_' + node_name.split('_')[-1] + '_4g.xml'
        node_scf_path = branch_scf.replace('_4g.xml', ending)
    return node_scf_path, node_scf_path.split('/')[-1]


def get_bts_id_from_scf_name(scf_path):
    return int(scf_path.split("_")[-2])


def get_main_bts_id(scf_path):
    pattern = re.compile("MRBTS-\\d{1,6}")
    with open(scf_path, 'r') as f:
        for line in f:
            bts_id = re.search(pattern, line)
            if bts_id:
                return str(bts_id.group()).split("-")[1]


def connect_to_neighbour_bts_admin_through_mplane(bts_type, bts_id):
    index = find_node_index_in_init(bts_type, bts_id)
    print(index)
    if bts_type == 'enb':
        mplane = \
            RobotBuiltIn().get_variable_value('${tl.enbs[{}].x2_link_addr.v4}'.replace('{}', str(index)))
    else:
        mplane = \
            RobotBuiltIn().get_variable_value('${tl.gnbs[{}].cu.backhaul_site_oam_ip.v4}'.replace('{}', str(index)))
    return admin.connect_to(bts_host=mplane)


def update_rmod_sw(connection):
    sw_version = admin.get_sw_version(connection=connection)
    sw_dir = download_sw_package(fix_branch(sw_version))
    admin.update_software(sw_dir, connection=connection)
    time.sleep(180)
    os.remove(sw_dir)


def get_config_dir():
    return 'custom-config/Wroclaw/{}'.format(socket.gethostname().replace('-', '_'))


def get_branch(software_name):
    return 'trunk' if software_name.split("_")[2] == '9999' \
        else software_name.split("_")[0].replace("SBTS", "").replace("5G", "")


def get_scf_path(branch, enb_branch):
    tl_name = socket.gethostname().replace('-', '_')
    return str('/home/ute/testline_configuration/' + tl_name + '/' + branch + '/' + tl_name + '_' + branch +
               '_5g.xml'), str('/home/ute/testline_configuration/' + tl_name + '/' + enb_branch + '/' + tl_name +
                               '_' + enb_branch + '_4g.xml')


def upload_scf(scf_path, connection):
    admin.perform_commissioning(scf_path, skip_parameter_relation_errors=False, connection=connection)


def check_alarms_for_incompatible_sw_on_rmod(alarms):
    for alarm in alarms:
        if str(alarm['alarmId']) in ['7111', '7653'] and 'ncompatible' in alarm['faultName']:
            return True
    return False


def download_sw_package(sw_version):
    url = get_download_link(sw_version=str(sw_version))
    _file = '/tmp/' + url.split('/')[-1]
    if os.path.isfile(_file):
        return _file
    with requests.get(url=url, stream=True, timeout=120, headers={"X-JFrog-Art-Api": artifactory_key}) as request:
        if request.status_code == 200:
            print("Downloading {url} to {path}".format(url=url, path=_file))
            with open(_file, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise Exception("'get' request error")
    return _file


def get_download_link(sw_version):
    branch = sw_version.split("_")[0]
    endpoint = "{0}/CI_ENB/builds/{1}/storages/results.json?access_key={2}".format(branch, sw_version,
                                                                                   access_key)
    response = requests.get(url=wft_url + endpoint).json()
    files_list = response[0]["storage"]["storage-items"]
    download_link = ""
    if "5G" in branch:
        file_name = "AirScale-{}.zip".format(sw_version.split("_", 1)[1])
        dw_link = [item["path"] for item in files_list if item["title"] == file_name]
        download_link = dw_link[0]
    elif "SBTS" in branch:
        file_name = "{}_release_BTSSM_downloadable_A54.zip".format(sw_version)
        download_link = [file_.get("path") for storage in response
                         for file_ in storage["storage"].get("storage-items") if
                         file_name in file_["title"] and
                         any(artifactory in file_.get("path")
                             for artifactory in ["lterel.es-si-s3-z4",
                                                 "https://artifactory-espoo2.int.net.nokia.com"])][0]
    return download_link


def update_software_for_rmods(software, connection):
    sw_path = download_sw_package(sw_version=fix_branch(software))
    admin.update_software(sw_package=sw_path, connection=connection, timeout=1500)


def extract_bts_number(bts_id):
    return bts_id.split('_')[-1]


def set_cell_type(bts_type):
    return 'nr' if bts_type == 'gnb' else 'lte'


def check_rmod_states(when, connection):
    rmod_list = admin.get_ids_for_all(class_name="RMOD", connection=connection)
    if rmod_list:
        for rmod in rmod_list:
            rmod_status = admin.get_parameters(rmod, connection=connection)
            if when == 'After Update':
                assert rmod_status["operationalState"] in STATUSES['operationalState']['enabled']
            else:
                assert rmod_status["operationalState"] in STATUSES['operationalState']['enabled'] or \
                       rmod_status["proceduralStatus"] in STATUSES['proceduralStatus']['initializing']


def check_bbmod_states(connection):
    bbmod_list = admin.get_ids_for_all(class_name="BBMOD", connection=connection)
    if bbmod_list:
        for bbmod in bbmod_list:
            bbmod_status = admin.get_parameters(bbmod, connection=connection)
            assert bbmod_status["operationalState"] in STATUSES['operationalState']['enabled']


def verify_x2_link_is_available(connection):
    lteenb_objects = admin.get_managed_objects(
        class_name="LTEENB_R", connection=connection
    )
    for _ in range(20):
        for lteenb in lteenb_objects:
            print(lteenb["parameters"])
            print(str(lteenb["parameters"]["eNodeBId"]))
            if str(lteenb["parameters"]["eNodeBId"]) != "None":
                break
            time.sleep(5)

    if not lteenb_objects:
        raise Exception("Waiting for LTEENB_R object to be available")

    for lteenb in lteenb_objects:
        link_status = lteenb["parameters"]["x2LinkStatus"]
        if "unavailable" in link_status:
            raise Exception(
                "X2 link unavailable to {}".format(lteenb["parameters"]["eNodeBId"])
            )

        return True


def prepare_main_vm_tools(sw_version):
    tti_link = generate_links_for_tools(sw_version)
    tti_lib = download_file_from_wft(tti_link)
    install_tti_dec_lib(tti_lib)
    os.system("sudo rm {}".format(tti_lib))
    prepare_mcshark()
    os.system("sudo rm /tmp/mcshark*")


def install_tti_dec_lib(path):
    os.system('sudo dpkg -i {}'.format(path))


def generate_links_for_tools(sw_version):
    link = get_download_link(sw_version)
    return link.replace('_release_BTSSM_downloadable_A54.zip', '_tti-dec.deb')


def download_file_from_wft(url):
    _file = '/tmp/' + url.split('/')[-1]
    if os.path.isfile(_file):
        return _file
    with requests.get(url=url, stream=True, timeout=10) as request:
        if request.status_code == 200:
            print("Downloading {url} to {path}".format(url=url, path=_file))
            with open(_file, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
                return _file
        else:
            raise Exception("'get' request error")


def get_flags_from_swconfig(swconfig_file):
    try:
        with open(swconfig_file, 'r+') as f:
            file_lines = [_f for _f in (line.rstrip() for line in f) if _f]
            existing_flags = remove_commented_lines(file_lines)
            return existing_flags
    except EnvironmentError:
        print('No swconfig found or you don\'t have access to the file.')
        raise


def remove_commented_lines(file_lines):
    relevant_lines = []
    for line in file_lines:
        if line[0] != '#':
            relevant_lines.append(line)
    return relevant_lines


def split_flags_into_params_and_values(flags_to_check):
    params_and_values = []
    for flag in flags_to_check:
        params_and_values.append(get_param_and_value_from_flag(flag))
    return params_and_values


def get_param_and_value_from_flag(flag):
    return flag.split('=')[0], flag.split('=')[1]


def add_flags_to_swconfig(new_flags, swconfig_dir):
    """
    Add new flag to software configuration file.
    :param new_flags: list of new flags to be added
    :param swconfig_dir: path to swconfig file directory
    :return: None
    """
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    swconfig_backup_local = "{}/swconfig_original.txt".format(swconfig_dir)
    modified_swconfig_local = "{}/swconfig.txt".format(swconfig_dir)
    sftp.get("/ffs/run/swconfig.txt", swconfig_backup_local)
    for new_flag in new_flags:
        try:
            subprocess.check_output("grep {} {}".format(new_flag, swconfig_backup_local), shell=True)
            print("Given flag {} is already in swconfig.".format(new_flag))
        except subprocess.CalledProcessError:
            print("Given flag {} is not in swconfig and will be added.".format(new_flag))
            with open(swconfig_backup_local, "r") as swconfig_bk, open(modified_swconfig_local, "w") as new_swconfig:
                for line in swconfig_bk:
                    new_swconfig.write(line)
                new_swconfig.write("\n{}".format(new_flag))
            sftp.put(modified_swconfig_local, "/ffs/run/swconfig.txt")
    ssh.close()
