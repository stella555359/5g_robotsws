import subprocess
import time
from subprocess import check_output
from taf.transport.ssh import ssh, ConnectFailedError
import os
from robot.libraries.BuiltIn import BuiltIn

REPORT_TXT_FILE_PATH = "/home/ute/Desktop/!logs_6048.txt"

exceptions = ["sshd", "vsftpd", "CCSDeamonExe", "CCSEmDispatcherExe", "rpc.mountd"]

grep_exceptions = [
    "/usr/bin/ministarter -p /etc/rcpprovidercontrollerstarter.json",
    "/bin/bash /opt/NE3SADAPT/ne3sadapt_runner.sh",
    "/opt/CCS_RT/CCSRTDaemonExe --startup=nid=0x1516 rtconfigfile=/ram/RTCCSConfig.xml masternid=0x1011 "
    "executable=/opt/rthwapi/RTHWAPIDaemon --file /ram/RTHWAPIConfig.xml --rat 5G#sys.hwapi.online -c "
    "app.hwapi.appcfg.filename /ram/AppDefRT.txt ccs.service.aapostmortem.forcelogs 1 sys.env.arch mcu-ascb "
    "sys.env.btsmode 1 sys.env.boardconfig 1 sys.env.device A sys.env.instance 0",
    "bash -c set -o pipefail; { /usr/sbin/ntpd -U 30 -g -q -u ntp:ntp -c /tmp/ntp.oneshot.conf; } > >("
    "logger -p user.info -t BTS_SW/ntpd) 2>&1",
    "logger -p user info -t BTS_SW/ntpd"]


def add_to_report_file(string_line):
    try:
        with open(REPORT_TXT_FILE_PATH, 'a') as txt_f:
            txt_f.write(string_line + "\n")
    except IOError:
        print("No report file")


def bts_connection(bts_ip="192.168.255.129"):
    user = "toor4nsn"
    password = "oZPS0POrRieRtu"
    return ssh().connect_to(bts_ip, user, password, alias="connect", timeout=10)


def get_parameter_from_protocol(protocol_name):
    parameters_dictionary = {"UDP": "u", "TCP": "t", "SCTP": "S"}
    return parameters_dictionary[protocol_name]


def get_list_result_ss_grep_port(port_to_check, parameter_of_protocol):
    global bts
    try:
        bts = bts_connection()
        bash_command = "ss -l4pn{} | grep ':{} ' ".format(parameter_of_protocol, port_to_check)
        ss_grep_port = bts.execute(bash_command)
        list_result_grep_port = ss_grep_port.split("\r\n")[:-1]
        from robot.api import logger
        logger.console("PORT" + str(list_result_grep_port))
        return [list_result_grep_port, bash_command]
    except Exception:
        print('No connection to BTS for "get_list_result_ss_grep_port" in CommonKeywords.py')
        raise
    finally:
        try:
            bts.disconnect()
        except Exception:
            print('No connection to disconnect')


def add_to_lists_ports_to_check(grep_port, opened_port_to_check, list_result_ss_grep_port, bash_command):
    """
    port_list = []
    process_list = []
    port_list_case = []
    """
    results = {}
    print(grep_port)
    if grep_port.find('"') != -1:
        process_string = grep_port.split('"')
        process = process_string[1]
        print(process)
        if len(process) > 1:
            if process not in exceptions:
                results["process"] = process
                results["port"] = opened_port_to_check
            print(opened_port_to_check + ": " + str(list_result_ss_grep_port))
            if len(list_result_ss_grep_port) > 0:
                add_to_report_file("BASH COMMAND:" + bash_command)
            add_to_report_file("     " + str(list_result_ss_grep_port))
            try:
                with open("/home/ute/Desktop/ports.txt", 'a') as txt_f:
                    txt_f.write(grep_port + '\n')
            except IOError:
                print("No ports.txt file")
    return results


def add_users_processes_to_dictionary_without_exceptions(process):
    global bts
    try:
        bts = bts_connection()
        bash_command = 'ps aux | grep {} | grep -v "grep {}"'.format(process, process)
        out_ps_aux_grep_process = bts.execute(bash_command)
        list_ps_aux_grep_process = out_ps_aux_grep_process.split("\r\n")[:-1]
        print(list_ps_aux_grep_process)
        results = {}
        if len(list_ps_aux_grep_process) != 0:
            for ps_aux_grep_process in list_ps_aux_grep_process:
                not_exception = True
                for exception in grep_exceptions:
                    if ps_aux_grep_process.find(exception) != -1:
                        not_exception = False
                print(ps_aux_grep_process)
                if not_exception:
                    user_of_process = ps_aux_grep_process.split(" ")[0]
                    add_to_report_file("     BASH COMMAND:" + bash_command)
                    add_to_report_file("          " + ps_aux_grep_process)
                    results["process"] = process
                    results["user"] = user_of_process
        return results
    except Exception:
        print('No connection to BTS for "add_users_processes_to_dictionary_without_exceptions" in CommonKeywords.py')
        raise
    finally:
        try:
            bts.disconnect()
        except Exception:
            print('No connection to disconnect')


def add_heading_to_file(test_case):
    try:
        with open(REPORT_TXT_FILE_PATH, 'a') as txt_f:
            txt_f.write('\n' + '\n    >>>>    ' + test_case + "  ")
    except IOError:
        print("No report.txt file")


def add_build_to_file():
    sw_version = str(check_output(['grep', '-rnF', "GNB BUILD:",
                                   '/home/ute/testline_init_results/logs/INFO_log.txt']))
    sw_version = sw_version.split("GNB BUILD: ")[1].replace('\n', '').replace('\\n', '').replace("'", '')
    try:
        with open(REPORT_TXT_FILE_PATH, 'a') as txt_f:
            txt_f.write(sw_version + '\n')
    except IOError:
        print("No report.txt file")


def add_to_file(test_case):
    test_case = str(test_case)
    try:
        with open(REPORT_TXT_FILE_PATH, 'a') as txt_f:
            txt_f.write(test_case + '\n')
    except IOError:
        print("No report.txt file")


def get_firewall_status():
    global bts
    try:
        bts = bts_connection()
        lines = bts.execute("cat /ffs/run/swconfig.txt")
        list_open_ports = lines.split("\r\n")[:-1]
        status = "empty"
        for line in list_open_ports:
            if line.find("0x1a1300") != -1:
                status = line
        return status
    except Exception:
        print('No connection to BTS for "get_firewall_status" in CommonKeywords.py')
        raise
    finally:
        try:
            bts.disconnect()
        except Exception:
            print('No connection to disconnect')


def get_tl_name():
    tl_name = str(check_output(['grep', '-rnF', "TL NAME:",
                                '/home/ute/testline_init_results/logs/INFO_log.txt']))
    tl_name = tl_name.split("TL NAME: ")[1].replace('\n', '').replace('\\n', '').replace("'", '')
    return tl_name


def configuration_tag():
    configuration = str(check_output(['grep', '-rnF', "LABEL:",
                                      '/home/ute/testline_init_results/logs/INFO_log.txt']))
    configuration = configuration.split("LABEL: ")[1].replace('\n', '').replace('\\n', '').replace("'", '')
    return configuration


def get_build():
    sw_version = str(check_output(['grep', '-rnF', "GNB BUILD: ",
                                   '/home/ute/testline_init_results/logs/INFO_log.txt']))
    sw_version = sw_version.split("GNB BUILD: ")[1].replace('\n', '').replace('\\n', '').replace("'", '')
    return sw_version


def get_ip_from_bts():
    global bts
    try:
        bts = bts_connection()
        lines = bts.execute("ip a")
        bts.disconnect()
        list_open_ports = lines.split("\r\n")[:-1]
        print(list_open_ports)
        with open("/home/ute/Desktop/interfaces_ip.txt", 'a') as txt_f:
            for x in list_open_ports:
                txt_f.write(x + '\n')
    except Exception:
        print('No connection to BTS for "get_ip_from_bts" in CommonKeywords.py')
        raise
    finally:
        try:
            bts.disconnect()
        except Exception:
            print('No connection to disconnect')


def copy_files_of_nmap_results():
    try:
        with open("/home/ute/Desktop/ports.txt", 'r') as txt_f:
            ports = txt_f.read().splitlines()
            ports = set(ports)

        with open("/home/ute/Desktop/processes.txt", 'r') as txt_f:
            processes = txt_f.read().splitlines()
            processes = set(processes)
    except IOError:
        print("No port.txt and process.txt file")

    os.system('mkdir -p /home/ute/Desktop/nmap/')
    os.system('mkdir -p /home/ute/Desktop/open/')
    try:
        for port in ports:
            try:
                grep_output = str(check_output('grep -rnlF "{}/open/" /home/ute/robotws/krzys/'.format(port),
                                               shell=True))
            except subprocess.CalledProcessError as e:
                grep_output = e.output
            nmap_files_results = grep_output.split("\n")
            for nmap_file in nmap_files_results:
                if len(nmap_file) > 1:
                    os.system('cp {} /home/ute/Desktop/nmap/'.format(nmap_file))
        for process in processes:
            try:
                grep_output = str(check_output('grep -rnlF "{}" /home/ute/Desktop/nmap/'.format(process), shell=True))
            except subprocess.CalledProcessError as e:
                grep_output = e.output
            nmap_files_results = grep_output.split("\n")
            for nmap_file1 in nmap_files_results:
                if len(nmap_file1) > 1:
                    os.system('cp {} /home/ute/Desktop/open/'.format(nmap_file1))
        add_content_open_processes_files_to_file()
    except Exception:
        add_to_report_file("No nmap scanned open root ports" + "\n")


def compare_root_and_btssw_processes_list():
    global bts
    try:
        bts = bts_connection()
        root_output = bts.execute("ps -u root -o comm")
        root_list = root_output.split("\r\n")[:-1]
        root_list = set(root_list)
        btssw_output = bts.execute("ps -U btssw -o comm")
        bts.disconnect()
        btssw_list = btssw_output.split("\r\n")[:-1]
        btssw_list = set(btssw_list)
        duplicate_list = []
        for x in root_list:
            if x in btssw_list and x != "COMMAND" and x != "dhcpd":
                duplicate_list.append(x)
        print(root_list)
        print(btssw_list)
        print(duplicate_list)
        try:
            with open(REPORT_TXT_FILE_PATH, 'a') as txt_f:
                txt_f.write("ROBUSTNESS(12,13):" + str(duplicate_list) + '\n')
        except IOError:
            print("No report.txt file")

        assert not duplicate_list, "Duplikate list:\n{}" \
            .format(str(duplicate_list))
    except Exception:
        print('No connection to BTS for "compare_root_and_btssw_processes_list" in CommonKeywords.py')
        raise
    finally:
        try:
            bts.disconnect()
        except Exception:
            print('No connection to disconnect')


def get_lte_build(lte_ip):
    try:
        bts = bts_connection(lte_ip)
        file_out = bts.execute('ls /ffs/run/ | grep "HashContainer_" | grep -v "p7"')
        bts.disconnect()
        lte_build = file_out.split("r_")[1].split(".")[0]
    except ConnectFailedError:
        lte_build = "NO CONNECTION TO LTE BTS:{}".format(lte_ip)
    return lte_build


def get_lte_ip_to_check():
    if check_if_classical():
        lte_mplane_ip_path = "${tl.enbs[0].m_plane.v4}"
    else:
        lte_mplane_ip_path = "${tl.enbs[0].m_plane[0].v4}"
    return lte_mplane_ip_path


def add_headline_to_output_file():
    try:
        create_report_file()
        lte_mplane_ip_path = get_lte_ip_to_check()
        lte_build = BuiltIn().get_variable_value(lte_mplane_ip_path)
        if lte_build is None:
            lte_build = "Not LTE IP in init file"
        date_and_time = actual_time()
        vm_ip = get_vm_ip()
        tl_name = get_tl_name()
        conf_tag = configuration_tag()
        build_5g = get_build()
        firewall_status = get_firewall_status()
        ipv4 = get_ipv4_interfaces()
        ipv6 = get_ipv6_interfaces()
        with open(REPORT_TXT_FILE_PATH, 'a') as txt_f:
            txt_f.write("      TEST TIME: " + date_and_time + '\n' +
                        " VM_TESTLINE_IP: " + vm_ip + '\n' +
                        "      LINE_NAME: " + tl_name + '\n' +
                        "         CONFIG: " + conf_tag + '\n' +
                        "       5G_BUILD: " + build_5g + '\n' +
                        "      LTE_BUILD: " + lte_build + '\n' +
                        "  FIREWALL_FLAG: " + firewall_status + '\n' +
                        "IPv4_INTERFACES: " + str(ipv4) + '\n' +
                        "IPv6_INTERFACES: " + str(ipv6) + '\n' +
                        "     EXCEPTIONS: " + str(exceptions) + '\n' + '\n')
    except Exception:
        print("Problem with adding headline to output file")


def add_currently_ip_to_file(ip, protocol, current_state):
    if protocol == "TCP":
        with open(REPORT_TXT_FILE_PATH, 'a') as txt_f:
            txt_f.write(ip + "  " + current_state + '\n')


def get_vm_ip():
    vm_ip_out = str(check_output(['hostname', '-I']).split(" ")[0])
    return vm_ip_out


def actual_time():
    return str(time.strftime("%D %H:%M", time.localtime()))


def _get_ip_interfaces(ip_version):
    _commands = {'ipv4': 'ip a | grep "inet " | grep "10"',
                 'ipv6': 'ip a | grep "inet6 " | grep "2a00"', }
    try:
        con = bts_connection()
        bash_output = con.execute(_commands.get(ip_version))
        list_bash_output = bash_output.split("\r\n")[:-1]
        ipv4_list = []
        for x in list_bash_output:
            ipv4_list.append(x.split("/")[0].split(" ")[-1])
        con.disconnect()
        return ipv4_list
    except Exception:
        print('No connection to BTS for "get_{}_interfaces" in CommonKeywords.py'.format(ip_version))
        raise
    finally:
        try:
            bts.disconnect()
        except Exception:
            print('No connection to disconnect')


def get_ipv4_interfaces():
    _get_ip_interfaces(ip_version='ipv4')


def get_ipv6_interfaces():
    _get_ip_interfaces(ip_version='ipv6')


def add_content_open_processes_files_to_file():
    try:
        list_files_output = str(check_output('ls /home/ute/Desktop/open', shell=True))
    except subprocess.CalledProcessError as e:
        list_files_output = e.output
    try:
        list_files = list_files_output.split("\n")
        for path in list_files:
            add_to_report_file("\n")
            with open("/home/ute/Desktop/open/{}".format(path), 'r') as txt_f:
                lines = txt_f.read().splitlines()
                for line in lines:
                    add_to_report_file(line)
    except IOError:
        add_to_report_file("No nmap scanned open root ports" + "\n")


def get_cloud_ip_splane():
    dic_splane = {"7_16_UTE5G333": "10.44.81.174",
                  "7_16_UTE5G331": "10.44.81.167",
                  "7_16_UTE5G264": "10.44.83.228",
                  "7_16_UTE5G071": "10.44.81.165",
                  "7_16_UTE5G184": "10.44.83.231",
                  "7_16_UTE5G332": "10.44.81.168"}
    tl_name = get_tl_name()
    return dic_splane[tl_name]


def get_path_to_report_file():
    return REPORT_TXT_FILE_PATH


def check_if_classical():
    conf_tag = configuration_tag()
    if conf_tag.find("CLASSICAL") != -1:
        result = True
    else:
        result = False
    return result


def create_report_file():
    os.system('sudo touch {}'.format(REPORT_TXT_FILE_PATH))
    os.system('sudo chmod 666 {}'.format(REPORT_TXT_FILE_PATH))


def get_root_opened_processes_on_ports(opened_ports_to_check, protocol_name):
    parameter_of_protocol = get_parameter_from_protocol(protocol_name)

    port_list = []
    process_list = []
    root_protocol_list = []

    add_to_report_file("OPENED PORTS TO CHECK: " + str(opened_ports_to_check))

    for opened_port_to_check in opened_ports_to_check:
        result_ss_grep_with_bash_command = get_list_result_ss_grep_port(opened_port_to_check, parameter_of_protocol)
        list_result_ss_grep_port = result_ss_grep_with_bash_command[0]
        bash_command = result_ss_grep_with_bash_command[1]
        print("LIST RESULT GREP '{}': {}".format(opened_port_to_check, list_result_ss_grep_port))

        port_list_case = []
        if len(list_result_ss_grep_port) > 0:
            for grep_port in list_result_ss_grep_port:
                port_and_process = add_to_lists_ports_to_check(grep_port, opened_port_to_check,
                                                               list_result_ss_grep_port, bash_command)
                if len(port_and_process) > 0:
                    process_list.append(port_and_process["process"])
                    port_list.append(port_and_process["port"])
                    port_list_case.append(port_and_process["port"])

        if len(port_list_case) > 0:
            add_to_report_file("OPENED PORTS FOR PROCESSES: " + str(port_list_case))

    process_list = set(process_list)
    if len(process_list) > 0:
        add_to_report_file("OPEN PROCESSES: " + str(process_list))
    print("PROCESSES LIST: " + str(process_list))

    list_of_users_processes = {}
    for process in process_list:
        if process not in exceptions:
            users_processes_in_dictionary = add_users_processes_to_dictionary_without_exceptions(process)
            if len(users_processes_in_dictionary) > 0:
                process = users_processes_in_dictionary["process"]
                user_of_process = users_processes_in_dictionary["user"]
                root_protocol_list.append(process)
                list_of_users_processes.setdefault(user_of_process, [])
                list_of_users_processes[user_of_process].append(process)

    list_of_users_processes = {key: set(val) for key, val in list_of_users_processes.items()}
    add_to_report_file(protocol_name + str(list_of_users_processes) + "\n")
    port_list = set(port_list)

    try:
        with open("/home/ute/Desktop/ports.txt", 'a') as txt_f:
            for p in port_list:
                txt_f.write(p + '\n')
    except IOError:
        print("No ports.txt file")

    try:
        with open("/home/ute/Desktop/processes.txt", 'a') as txt_f:
            for proc in root_protocol_list:
                txt_f.write(proc + '\n')
    except IOError:
        print("No process.txt file")

    try:
        root_users_processes = list_of_users_processes['root']
    except KeyError:
        root_users_processes = []
    assert not root_users_processes, "Open Processes:\n{}" \
        .format(str(root_users_processes))
