# author: PZ_2_WRO_5
import re
import os
import time
import subprocess
import requests
from bs4 import BeautifulSoup
import urllib
from ute_common_abstract_core.config import Config
import paramiko
import yaml
from taf.hw.pdu import pdu
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from taf.sbts.oam.coam.admin import AdminConnection, admin
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.resources.syslog_checker import syslog_checker
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.tl_config import tl
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import (
    TSharkCommandAssembler,
    remove_luashark_loading_from_output,
)


class TShark_for_attach(TSharkCommandAssembler):
    def __init__(self, tshark_path="tshark"):
        self.parameters = []
        self.grep = ""
        self.parameters.extend([tshark_path])

    def with_filter(self, wireshark_filter):
        self.parameters.extend(["-Y", wireshark_filter])
        return self


def generated_pcap_data_for_attach(pcap_path):
    tshark = TShark_for_attach()
    output = (
        tshark.with_filter("x2ap || ngap")
        .with_pcap_file(pcap_file=pcap_path)
        .inject_additional_parameters(
            "-T fields -e x2ap.procedureCode "
            "-e nr-rrc.rrcReconfigurationComplete_element "
            "-e ngap.InitialUEMessage_element "
            "-e ngap.gTPTunnel_element"
        )
        .build()
    )
    pcap_data = []
    for line in output:
        if line != "\t\t":
            line = line.split("\t")
            pcap_data.append(line)
    return pcap_data


def verify_if_attach_success(pcap_path):
    pcap_msgs = generated_pcap_data_for_attach(pcap_path)
    print("pcap_Data: ", pcap_msgs)
    attach_sa_success = []
    attach_nsa_success = []
    # mgs_name = {27: "SgNBAdditionRequest", 28: "SgnbReconfigurationComplete", 30: "rrcReconfigurationComplete"}
    attach_sa_msg = [["", "", "1", ""], ["", "", "", "1"]]
    attach_nsa_msg = [["27", "", "", ""], ["28", "1", "", ""], ["30", "1", "", ""]]
    for mandatory_attach_msg in attach_sa_msg:
        if mandatory_attach_msg in pcap_msgs:
            attach_sa_success.append(1)
        else:
            attach_sa_success.append(0)
    for mandatory_attach_msg in attach_nsa_msg:
        if mandatory_attach_msg in pcap_msgs:
            attach_nsa_success.append(1)
        else:
            attach_nsa_success.append(0)
    if 0 in attach_sa_success:
        # in attach SA not all mandatory msg found, try to verify NSA attach
        if 0 in attach_nsa_success:
            # in attach SA and NSA not all mandatory msg found
            print("Attach to 5G failed please check collected pcap logs")
            return False
        else:
            # in attach NSA all mandatory msg found
            print("Attach to NSA Success")
            return True
    else:
        # in attach SA all mandatory msg found
        print("Attach to SA Success")
        return True


def configure_gnbmirroring_script_params(file_path, time, size):
    file = open(str(file_path), "r")
    file_res = open(str(file_path[:-21] + "tmp.sh"), "w")
    r_1 = r"(^CAPTURING_TIME_SECONDS=)(\d*)(\s)"
    r_2 = r"(^FILE_SIZE_MBYTES=)(\d*)(\s)"
    r_3 = r"(^BACKHAUL_MIRRORING=)(\'.*\')(\s)"
    for line in file:
        if re.match(r_1, line):
            t = re.match(r_1, line)
            temp = line.replace(t.group(2), str(time))
            file_res.write(temp)
            continue
        if re.match(r_2, line):
            t = re.match(r_2, line)
            temp = line.replace(t.group(2), str(size))
            file_res.write(temp)
            continue
        if re.match(r_3, line):
            t = re.match(r_3, line)
            temp = line.replace(t.group(2), str("'false'"))
            file_res.write(temp)
            continue
        file_res.write(line)
    os.remove(file_path)
    os.rename(str(file_path[:-21] + "tmp.sh"), file_path)


def get_ueip_based_on_pcap(pcap_path):
    tshark = TShark_for_attach()
    output = (
        tshark.with_filter("x2ap.s1_DL_GTPtunnelEndpoint_element")
        .with_pcap_file(pcap_file=pcap_path)
        .inject_additional_parameters("-T fields -e x2ap.transportLayerAddressIPv4")
        .build()
    )
    pcap_data = []
    for line in output:
        line = line.split(",")
        pcap_data.append(line[0])
    return pcap_data


def get_ueip_based_on_pcap_sa(pcap_path):
    tshark = TShark_for_attach()
    output = (
        tshark.with_filter("ngap.InitialContextSetupRequest_element")
        .with_pcap_file(pcap_file=pcap_path)
        .inject_additional_parameters("-T fields -e ngap.TransportLayerAddressIPv4")
        .build()
    )
    pcap_data = []
    for line in output:
        line = line.split(",")
        pcap_data.append(line[0])
    return pcap_data


def get_cell_id_from_list(listed_cells):
    if not (listed_cells):
        listed_cells = "0x00000000"
    cell_id = [listed_cells]
    print("Listed cells: ", cell_id)
    print("Duplicating cell id...")
    cell_id.append(cell_id[0])
    print("Listed cells now: ", cell_id)
    id_ret = int(cell_id[1], 16) + 1
    print("ID ret: ", id_ret)
    return str(id_ret)


def get_counter_value_from_single_cell(counters_list, cell_id, counter_id):
    for counter in counters_list:
        if counter_id in counter.keys():
            temp = counter.get(counter_id)
            value = temp.get(cell_id)
            print(value)
    return value


def generated_pcap_data_for_subcellid(pcap_path):
    tshark = TSharkCommandAssembler()
    filter = "dldata_pdschpayloadtbsendreq && !(DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti == 0xffff)"
    out = (
        tshark.with_attached_lua_scripts()
        .with_filter(filter)
        .with_pcap_file(pcap_file=pcap_path)
        .inject_additional_parameters("-T pdml")
        .inject_additional_parameters("-c 5")
        .build()
    )
    print("out: ", out)
    cds = re.search(
        r"DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId\".*?'", str(out)
    )
    subcell_id = re.search(r"\dx\d+", (re.search(r'show=".*?"', cds.group(0)).group(0)))
    print("cds: ", subcell_id.group(0))
    return subcell_id.group(0)


def compare_truputs(tpt_1, tpt_2):
    return int(tpt_1) > int(tpt_2)


def perform_cmd_over_ssh(
    cmd_line,
    hostname,
    username,
    password=None,
    ssh_key_file_path=None,
    port=22,
    timeout=180,
):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(
        hostname=hostname,
        port=port,
        username=username,
        key_filename=ssh_key_file_path,
        password=password,
        look_for_keys=False,
        banner_timeout=180,
        timeout=180,
    )
    try:
        cmd_line = cmd_line.decode("unicode-escape").replace("\\", "/")
    except Exception:
        pass
    stdin, stdout, stderr = ssh_client.exec_command(cmd_line, timeout=timeout)
    err = stderr.read()
    result = stdout.read()
    ssh_client.close()
    return err, result


def get_ue_config(capabilities):
    abstract_lib_config = os.environ["ABSTRACT_LIB_CONFIG"]
    device_configuration = Config().read_yaml_configfile(abstract_lib_config)
    try:
        ue_pools = device_configuration["UE_POOLS"]["AndroidUePool"]["inline_config"]
    except Exception:
        try:
            ue_pools = device_configuration["UE_POOLS"]["TafUeAndroidPool"][
                "inline_config"
            ]
        except Exception:
            raise RuntimeError(
                "Error occurred during getting UEs configuration from yaml"
            )
    for key in ue_pools.keys():
        print("ue_pools[key]: ", ue_pools[key])
        if capabilities in ue_pools[key]["CAPABILITIES"]:
            return ue_pools[key]
            break
    raise AssertionError(
        "Ue alias : {capabilities} not defined in Yaml config file".format(capabilities)
    )


def run_adb_cmd_on_ue(capabilities, cmd_line, timeout=30):
    _ue_config = get_ue_config(capabilities)
    ue_sn = _ue_config["CONSTRUCTOR_PARAMETERS"]["serial_number"]
    cmd = "adb -s " + ue_sn + " shell " + cmd_line
    err, result = perform_cmd_over_ssh(
        hostname=_ue_config["CONSTRUCTOR_PARAMETERS"]["configuration"]["ue_pc_ip"],
        username=_ue_config["CONSTRUCTOR_PARAMETERS"]["configuration"]["login"],
        password=_ue_config["CONSTRUCTOR_PARAMETERS"]["configuration"]["password"],
        cmd_line=cmd,
        timeout=timeout,
    )
    return err, result


def get_uepc_ip():
    """Function gets UEPC ip based on __init__.py from default UE_1."""
    _ue_config = get_ue_config("REAL_ANDROID_UE_NSA")
    uepc_ip = _ue_config["CONSTRUCTOR_PARAMETERS"]["configuration"]["ue_pc_ip"]
    return uepc_ip


def get_ue_sn(capabilities):
    """Function returns UE serial number based on UE capabilities."""
    _ue_config = get_ue_config(capabilities)
    ue_sn = _ue_config["CONSTRUCTOR_PARAMETERS"]["serial_number"]
    return ue_sn


def syslog_checker_for_suspicious_prints(syslog):
    return syslog_checker().find_suspicious_logs(search_folder=syslog)


def check_syslog_for_crashes(syslog_file):
    """Check if crashes occurred in syslog file and return them if any are present."""
    try:
        crashes = str(
            subprocess.check_output(
                "grep '{0}' {1}".format(RFRL_CRASH_PRINTS, syslog_file), shell=True
            )
        )
        if crashes:
            raise Exception(
                "Syslog Crash verification failed :\n Crash has been found in {0}: \n{1}".format(
                    syslog_file, crashes
                )
            )
    except subprocess.CalledProcessError as e:
        if e.returncode == 1:
            return True
        raise RuntimeError("Error occurred during executing {0}".format(e.cmd))


RFRL_CRASH_PRINTS = "\\|".join(
    [
        "FATAL DSPHWAPI ERROR",
        "\\-\\=\\-\\=",
        "Invalid memory reference",
        "Please contact the owner",
        "fatality",
        "Abort signal received",
        "Bus error",
    ]
)


def tl_prepare_to_ru_off():
    _pdu = pdu()
    blog("Shutting down radio's in 3min", level="WARN")
    time.sleep(120)
    blog("Last call for script stopping, 1min left")
    for i in range(60, -1, -1):
        blog("{}s left to shutdown..".format(i))
        time.sleep(1)
    save_power_consumption_ru(switch_state="off")


def tl_prepare_to_ru_on():
    save_power_consumption_ru(switch_state="on")


def save_power_consumption_ru(switch_state="on"):
    for gnb in tl.gnbs:
        for du in gnb.dus:
            for ru in du.rus:
                switch_pdu_port(pdu_port=ru.pdu_port, state=switch_state)


def switch_pdu_port(pdu_port, state="on"):
    if not pdu_port:
        return

    _pdu = pdu()
    try:
        _pdu.setup_pdu(pdu_port.pdu)
        blog(pdu_port)
        if state == "on":
            _pdu.power_on(port=pdu_port.port_no)
        if state == "off":
            _pdu.power_off(port=pdu_port.port_no)
    except Exception as e:
        blog("Failed to switch pdu ports. Reason: {}".format(str(e)))


def strip_devices_string(devices):
    x = devices.replace("List of devices attached", "")
    x = x.replace("\t", "")
    x = x.replace("\n", "")
    x = x.replace("\r", "")
    x = x.replace("device", ",")
    x = x.replace("unauthorized", ",")
    x = x.replace("offline", ",")
    x = x[:-1]
    device_list = []
    device_list = x.split(",")
    return device_list


def get_uepc_ip():
    ip_list = []
    for ue in tl.ues:
        if ".y" in str(ue):
            # yaml UE configuration
            with open(ue) as stream:
                uepc_ip = yaml.load(stream, Loader=yaml.FullLoader)
                try:
                    for ue in list(
                        uepc_ip["UE_POOLS"]["AndroidUePool"]["inline_config"]
                    ):
                        ip_list.append(
                            uepc_ip["UE_POOLS"]["AndroidUePool"]["inline_config"][ue][
                                "CONSTRUCTOR_PARAMETERS"
                            ]["configuration"]["ue_pc_ip"]
                        )
                except Exception:
                    try:
                        for ue in list(
                            uepc_ip["UE_POOLS"]["TafUeAndroidPool"]["inline_config"]
                        ):
                            ip_list.append(
                                uepc_ip["UE_POOLS"]["TafUeAndroidPool"][
                                    "inline_config"
                                ][ue]["CONSTRUCTOR_PARAMETERS"]["configuration"][
                                    "ue_pc_address"
                                ]
                            )
                    except Exception:
                        raise RuntimeError(
                            "Error occurred during getting UEs configuration from yaml"
                        )
        else:
            # class UE configuration
            for ue_conf in tl.ues:
                ip_list.append(ue_conf.ssh_connection_details.addr)
    # check if all UE IPs has the same UEPC IP address
    result = ip_list.count(ip_list[0]) == len(ip_list)
    if result:
        return ip_list[0]
    else:
        blog("There is more than one UEPC IP in TL configuration")
        return ip_list[0]


def get_attenuators():
    attenuators = []
    for att in tl.attenuators:
        attenuators.append(
            [att.ip_addr, att.port, att.attenuation_port_numbers, type(att).__name__]
        )
    return attenuators


def get_bbmod_status(host):
    client = AdminConnection(remote_host=host)
    smod_status = client.get_bts_info()
    return smod_status.get("basebandModules")[0].get("status")


def perform_decommisioning(host):
    cmd = "cd /ffs/run/config/ && rm -f *"
    cmd_reboot = "reboot"
    err, result = perform_cmd_over_ssh(
        hostname=host,
        username="toor4nsn",
        password="oZPS0POrRieRtu",
        cmd_line=cmd,
        timeout=30,
    )
    err, result = perform_cmd_over_ssh(
        hostname=host,
        username="toor4nsn",
        password="oZPS0POrRieRtu",
        cmd_line=cmd_reboot,
        timeout=30,
    )
    return err, result


def add_btslog_flag_to_swconfig(host="192.168.255.129"):
    cmd = 'echo "0x10041=5" >> /ffs/run/swconfig.txt'
    cmd_reboot = "reboot"
    err, result = perform_cmd_over_ssh(
        hostname=host,
        username="toor4nsn",
        password="oZPS0POrRieRtu",
        cmd_line=cmd,
        timeout=30,
    )
    return err, result


def stop_and_fix():
    client = AdminConnection()
    alarms = client.get_active_alarms()
    alarm_list = [alarm["faultId"] for alarm in alarms]
    critical_fid = [10, 1806, 16, 4341, 4383, 4352, 1868]
    print(alarm_list)
    for fid in critical_fid:
        print("fid: ", fid)
        if fid in alarm_list:
            stop_and_fix_procedure()
    return "False"


def stop_and_fix_neightbour():
    remote_admin = BuiltIn().get_variable_value("${{{}}}".format("REMOTE_ADMIN"))
    alarms = admin().get_active_alarms(connection=remote_admin)
    alarm_list = [alarm["faultId"] for alarm in alarms]
    critical_fid = [10, 1806, 16, 4341, 4383, 4352, 1868]
    print(alarm_list)
    for fid in critical_fid:
        print("fid: ", fid)
        if fid in alarm_list:
            stop_and_fix_procedure(is_local=False)
    return "False"


def stop_and_fix_procedure(is_local=True):
    cm_execution_id = os.environ.get("CM_EXECUTION_ID")
    if cm_execution_id is not None:
        if "stop_fix_reported" not in globals():
            if is_local:
                send_ute_stop_fix_cmd()
            BuiltIn().sleep(
                "24 hours",
                reason="Stop and Fix error detected. Waiting for manual logs gathering",
            )
    BuiltIn().fatal_error("Stop and Fix procedure triggered! Aborting test execution.")


def send_ute_stop_fix_cmd():
    command = (
        'echo "put /opt/ute/execution.context.json ${CM_EXECUTION_ID}.json" |'
        " cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/"
    )
    subprocess.call(command, shell=True)
    global stop_fix_reported
    stop_fix_reported = True
    time.sleep(10)


def download_Xn_and_F1_plugins():
    urls = {
        "XNAP": "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_Xn_AP/",
        "F1AP": "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_F1_AP/",
    }
    plugin_destination_path = "/home/ute/.local/lib/wireshark/plugins/4.0/epan/"
    for url in urls:
        try:
            print("*" * 40 + " INSTALLING {} PLUGIN ".format(url).upper() + "*" * 40)
            url_link = urls.get(url)
            artifactory_list = requests.get(url_link).text
            latest_version = sorted(
                re.findall(
                    r'nokia{}-\d*.\d*.\d*-\d*[^">]'.format(url),
                    artifactory_list,
                    re.IGNORECASE,
                )
            )[-1]
            url_link = str(BeautifulSoup(url_link + latest_version, "html.parser"))
            artifactory_list = requests.get(url_link).text
            latest_version = sorted(
                re.findall(
                    r'"nokia{}-\d.*buster.so"'.format(url),
                    artifactory_list,
                    re.IGNORECASE,
                )
            )[-1].strip('"')
            urllib.request.urlretrieve(
                url_link + latest_version,
                "{}{}".format(plugin_destination_path, latest_version),
            )
            print(
                "{}-{} plugin has been installed.\nInstalled Wireshark plugins: {}".format(
                    url, latest_version, os.listdir(plugin_destination_path)
                )
            )
        except Exception:
            print(
                "Could not install plugins. Check if path {} exists.".format(
                    plugin_destination_path
                )
            )


def get_cm_execution_id():
    return os.environ.get("CM_EXECUTION_ID")


def is_it_manual_execution():
    return False if get_cm_execution_id() else True


def get_sw_release():
    bts = AdminConnection()
    sw_release = bts.get_sw_release_name()
    return sw_release


def _get_swconfig(filename, swconfig_dir, sw_config_path, hostname="192.168.255.129"):
    swconfig_dir = os.path.join(
        BuiltIn().get_variable_value("${outputdir}"), swconfig_dir
    )
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=hostname, username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    if not os.path.exists(swconfig_dir):
        os.makedirs(swconfig_dir)
    swconfig_file = "{}/{}.txt".format(swconfig_dir, filename)
    sftp.get(sw_config_path, swconfig_file)
    ssh.close()
    return swconfig_file


def add_flag_to_swconfig(
    swconfig_backup_dir,
    flag,
    reset=True,
    sw_config_path="/ffs/run/swconfig.txt",
    connection="cOAM",
    hostname="192.168.255.129",
):
    """
    Add new flag to software configuration file.
    """
    swconfig_dir = os.path.join(
        BuiltIn().get_variable_value("${outputdir}"), swconfig_backup_dir
    )
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=hostname, username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    swconfig_backup_local = _get_swconfig(
        "swconfig_original", swconfig_dir, sw_config_path, hostname
    )
    modified_swconfig_local = "{}/swconfig.txt".format(swconfig_dir)
    sftp.get(sw_config_path, swconfig_backup_local)
    with open(swconfig_backup_local, "r") as swconfig_bk, open(
        modified_swconfig_local, "w"
    ) as new_swconfig:
        for line in swconfig_bk:
            if flag.split("=")[0] in line:
                continue
            new_swconfig.write(line)
        new_swconfig.write(
            "\n{} #{} Test flag".format(
                flag, BuiltIn().get_variable_value("${testname}")
            )
        )
    sftp.put(modified_swconfig_local, sw_config_path)
    ssh.close()
    if reset:
        admin().reset_site(timeout=600, connection=connection)


def restore_original_swconfig(
    swconfig_backup_dir,
    reset=True,
    sw_config_path="/ffs/run/swconfig.txt",
    connection="cOAM",
    hostname="192.168.255.129",
):
    """Restore original software configuration file."""
    swconfig_dir = os.path.join(
        BuiltIn().get_variable_value("${outputdir}"), swconfig_backup_dir
    )
    swconfig_backup_local = "{}/swconfig_original.txt".format(swconfig_dir)
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=hostname, username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    sftp.put(swconfig_backup_local, sw_config_path)
    ssh.close()
    if reset:
        admin().reset_site(timeout=600, connection=connection)
