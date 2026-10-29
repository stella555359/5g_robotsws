import json
import re
from datetime import datetime
import time
import taf.transport.ssh
import shutil
import os
import argparse


HOST = "192.168.255.1"
USRNAME = "toor4nsn"
PASSWORD = "oZPS0POrRieRtu"
PORT = "15007"
CLASSICAL_BTS_TYPE = "classical"
CLOUD_BTS_TYPE = "cloud"

LOG_LEVEL_DEBUG = 0
LOG_LEVEL_INFO = 1
LOG_LEVEL_WARN = 2
LOG_LEVEL_ERROR = 3
EXIT_ERROR = -1
EXIT_NO_LEAKAGE = 0
EXIT_HAS_LEAKAGE = 1
# DEFAULT_GNB_SSH = [HOST, USRNAME, PASSWORD]

g_debug_log_file = "hanging_resource_check.log"
g_check_components = ["cpcl", "cpue", "cprt", "cpnrt"]
g_get_processes = ["cp_nb", "cp-nrt", "Cprt"]


def set_check_processes(components_to_check):
    global g_check_components
    global g_get_processes
    if not components_to_check:
        g_check_components = ["cpcl", "cpue", "cprt", "cpnrt"]
        g_get_processes = ["cp_nb", "cp-nrt", "Cprt"]
        return
    check_set = set()
    get_set = set()
    for sc in components_to_check:
        if sc.lower() == "cpcl":
            get_set.add("cp_nb")
            check_set.add("cpcl")
        elif sc.lower() == "cpue":
            get_set.add("cp_nb")
            check_set.add("cpue")
        elif sc.lower() == "cprt":
            get_set.add("Cprt")
            check_set.add("cprt")
        elif sc.lower() == "cpnrt":
            get_set.add("cp-nrt")
            check_set.add("cpnrt")
        else:
            logging("Invalid component name: {}, ignore it.".format(sc), log_level=LOG_LEVEL_ERROR)
    g_get_processes = list(get_set)
    g_check_components = list(check_set)


def initialize_log(file_name):
    global g_debug_log_file
    g_debug_log_file = file_name
    logging("Start logging in {}".format(g_debug_log_file), recreate_file=True, log_level=LOG_LEVEL_DEBUG)


def logging(msg, recreate_file=False, log_level=LOG_LEVEL_INFO):
    log_level_info = {
        LOG_LEVEL_DEBUG: "DEBUG",
        LOG_LEVEL_INFO: "INFO",
        LOG_LEVEL_WARN: "WARNING",
        LOG_LEVEL_ERROR: "ERROR"
    }
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    text = "{} {} {}\n".format(current_time, log_level_info[log_level], msg)

    with open(g_debug_log_file, "w" if recreate_file else "a") as out_file:
        out_file.write("{}\n".format(text))
        if log_level > LOG_LEVEL_DEBUG:
            print(text)


def copy_log_to_dir(log_dir, log_file):
    if os.path.exists(log_dir):
        if os.path.exists(log_file):
            logging("copy {} to {}".format(log_file, log_dir), log_level=LOG_LEVEL_INFO)
            try:
                shutil.copyfile(log_file, "{}/{}".format(log_dir, log_file))
            except shutil.SameFileError:
                pass
        else:
            print("File {} doesn't exist.".format(log_file))
    else:
        logging("Directory {} doesn't exist.".format(log_dir), log_level=LOG_LEVEL_ERROR)


class OcpController(object):
    def __init__(self, host, user, password, name_space, ocp_type):
        self.host = host
        self.user = user
        self.pwd = password
        self.name_space = name_space
        self.ocp_type = ocp_type
        # For example
        # {
        #     "cp-nrt": {
        #         "srv": "cpnrt",
        #         "ctr": "cpnrt"
        #     },
        #     "cp_nb": {
        #         "srv": "cpnb",
        #         "ctr": "cpnb"
        #     },
        #     "oam": {
        #         "srv": "oamext",
        #         "ctr": "oamagent"
        #     },
        #     "healing-controller": {
        #         "srv": "healing-controller",
        #         "ctr": "healing-controller"
        #     },
        # }
        self.proc_dict = {}
        # For example:
        #    {
        #         "cp-nrt": {
        #             "po-namespace-cpnrt-0":"ctr-namespace-cpnrt",
        #             "po-namespace-cpnrt-1":"ctr-namespace-cpnrt",
        #         },
        #         "cp_nb":{
        #             "po-namespace-cpnb-0":"ctr-namespace-cpnb",
        #             "po-namespace-cpnb-1":"ctr-namespace-cpnb",
        #         },
        #         "oam":{
        #             "po-namespace-oamext-0":"ctr-namespace-oamagent",
        #             "po-namespace-oamext-1":"ctr-namespace-oamagent",
        #         },
        #     }
        self.pod_ctr_dict = {}
        self.ssh_conn = None
        self.active_pods = []
        self.exist_redundant = False

    def connect(self):
        self.ssh_conn = taf.transport.ssh.connect(self.host, self.user, self.pwd)
        if self.ssh_conn:
            logging("Connect to {} {} successful".format(self.ocp_type, self.host))
        else:
            raise Exception("Connect to {} {} failed".format(self.ocp_type, self.host))

    def disconnect(self):
        if self.ssh_conn:
            logging("Disconnect {} {}".format(self.ocp_type, self.host))
            self.ssh_conn.disconnect()

    def _execute(self, ocp_pod, ocp_ctr, cmd, timeout=None):
        ocp_cmd = f'kubectl exec {ocp_pod} -c {ocp_ctr} -n {self.name_space} -- timeout 3 bash -c'
        cmd = cmd.replace('"', '\\"').replace('`', '\\`').replace('$', '\\$')
        # logging(f'{ocp_pod}: {ocp_cmd} "{cmd}", timeout={timeout}, fail_on_error={fail_on_error}')
        logging("Run command on {}: {} {}".format(self.ocp_type, ocp_cmd, cmd), log_level=LOG_LEVEL_DEBUG)
        resp = self.ssh_conn.execute(f'{ocp_cmd} "{cmd}"', timeout=timeout)
        logging("Command response: {}".format(resp), log_level=LOG_LEVEL_DEBUG)
        return resp

    def _get_active_pods(self, timeout=None):
        heal_controller_pod = list(self.pod_ctr_dict["healing-controller"].keys())[0]
        cmd = f"kubectl exec -i {heal_controller_pod} -n {self.name_space} -- " \
              f"curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs "
        logging("Run command on {}: {}".format(self.ocp_type, cmd), log_level=LOG_LEVEL_DEBUG)
        resp = self.ssh_conn.execute(cmd, timeout=timeout)
        time.sleep(2)
        logging("Command response: {}".format(resp), log_level=LOG_LEVEL_DEBUG)
        data = json.loads(resp)
        for k, v in data.items():
            for pod_details in v:
                if "redundantRole" not in pod_details or pod_details["redundantRole"] == "active":
                    if self._find_matched_active_pod(pod_details["name"]):
                        self.active_pods.append(pod_details["name"])
        logging("Active pods in {} are: {}".format(self.ocp_type, self.active_pods))
        return resp

    def _find_matched_active_pod(self, name):
        for k, v in self.pod_ctr_dict.items():
            for pod, ctr in v.items():
                if pod == name:
                    return True
        return False

    def _parse_pod_result(self, data):
        # logging("response data: {}".format(data), log_level=LOG_LEVEL_DEBUG)
        lines = data.splitlines()
        pod_list = list()
        for line in lines:
            # logging("line: {}".format(line), log_level=LOG_LEVEL_DEBUG)
            result = re.search(r'^(.*?)\s+.*?\s+(.*?)\s+', line)
            if result is None:
                continue
            pod_name = result.group(1)
            pod_status = result.group(2)
            if pod_status.lower() != "running":
                logging("{} is not running in {}.".format(pod_name, self.ocp_type), log_level=LOG_LEVEL_ERROR)
                return None
            pod_list.append(pod_name)
        return pod_list

    def _get_pod_info(self, srv, ctr):
        cmd = f"kubectl get po -n {self.name_space} | grep {srv}"
        logging("Run command on {}: {}".format(self.ocp_type, cmd), log_level=LOG_LEVEL_DEBUG)
        resp = self.ssh_conn.execute(cmd)
        logging("Command response: {}".format(resp), log_level=LOG_LEVEL_DEBUG)
        pod_list = self._parse_pod_result(resp)
        if len(pod_list) > 1:
            self.exist_redundant = True
            logging("{} has redundant pods, {}".format(srv, pod_list), log_level=LOG_LEVEL_DEBUG)
        pod_info = dict()
        for pod_name in pod_list:
            pod_info[pod_name] = f"ctr-{ctr}"
        return pod_info

    def _get_process_info(self):
        self.pod_ctr_dict = {}
        logging("proc_dict: {}".format(self.proc_dict))
        for proc, item in self.proc_dict.items():
            info = self._get_pod_info(item["srv"], item["ctr"])
            if info:
                if proc in self.pod_ctr_dict:
                    self.pod_ctr_dict[proc].upate(info)
                else:
                    self.pod_ctr_dict[proc] = info
            else:
                logging("{} is not running.".format(proc), log_level=LOG_LEVEL_ERROR)
                return None
        logging("process info: {}".format(self.pod_ctr_dict))

        if self.exist_redundant:
            logging("Exist redundant pods in {}, start to get active pods.".format(self.ocp_type))
            self._get_active_pods()
        else:
            logging("No redundant pods in {}.".format(self.ocp_type))
        return self.pod_ctr_dict

    def _get_resource_usage(self, node_name, ocp_pod, ocp_ctr, retry_times=3, fail_on_error=True):
        sleep_time = 5
        n = 0
        while True:
            output = self._execute(ocp_pod,
                                   ocp_ctr,
                                   f"echo 'getResourcesUsage -l {node_name} ' | nc 127.0.0.1 15057",
                                   timeout=180)
            data = re.search(r'({"ResourcesUsage.*]})[.\t\r\n]*', output)
            if not data:
                data = re.search(r'AaShell>[\s\S]*?({[\s\S]*})', output)
            if data:
                resp = json.loads(data.group(1))
                if resp:
                    return resp

            n += 1
            if n < retry_times:
                logging("Get resources usage for {} not successful, trying again after {} seconds".format(
                    node_name, sleep_time), log_level=LOG_LEVEL_WARN)
                time.sleep(sleep_time)
            else:
                break

        if fail_on_error:
            logging("getResourcesUsage {} failed!".format(node_name), log_level=LOG_LEVEL_ERROR)
        return None

    def _get_resource_from_redundant_pods(self, name, pod_list):
        for pod, ctr in pod_list.items():
            if pod in self.active_pods:
                data = self._get_resource_usage(name, pod, ctr)
                if data:
                    return pod, data
                else:
                    break
            else:
                logging("{} is not active, then try to get resources from another active pod.".format(pod),
                        log_level=LOG_LEVEL_DEBUG)
                continue
        logging("Get resources usage of {} failed!".format(name), log_level=LOG_LEVEL_ERROR)
        return None, None

    def get_process_resources(self):
        logging("Get process resources in {}".format(self.ocp_type))
        process_info = self._get_process_info()
        if not process_info:
            logging("Get process info in {} failed.".format(self.ocp_type), log_level=LOG_LEVEL_ERROR)
            return None

        checked_processes = dict()
        process_resources = dict()
        for name, pod_list in process_info.items():
            if name not in g_get_processes:
                continue
            checked_processes[name] = []
            if len(pod_list) > 1:
                pod, data = self._get_resource_from_redundant_pods(name, pod_list)
            else:
                pod = list(pod_list.keys())[0]
                data = self._get_resource_usage(name, pod, list(pod_list.values())[0])

            if data is None:
                return None
            pod = '{}-{}'.format(self.ocp_type, pod)
            if name in process_resources:
                process_resources[name].update(dict({pod: data}))
            else:
                process_resources[name] = dict({pod: data})
            checked_processes[name].append(pod)

        logging("Get resources of processes: {} in {} success".format(checked_processes, self.ocp_type))
        return process_resources


class Vcu(OcpController):
    def __init__(self, host="10.47.21.4", user="core", password="system123", name_space="7-15-23-527"):
        super().__init__(host, user, password, name_space, "vCU")
        self.proc_dict = {
            "cp-nrt": {
                "srv": "cpnrt",
                "ctr": "cpnrt"
            },
            "cp_nb": {
                "srv": "cpnb",
                "ctr": "cpnb"
            },
            "oam": {
                "srv": "oamext",
                "ctr": "oamagent"
            },
            "healing-controller": {
                "srv": "healing-controller",
                "ctr": "healing-controller"
            },
        }


class Vdu(OcpController):
    def __init__(self, host="192.168.2.124", user="core", password="system123", name_space="7-15-23-527", number=1):
        super().__init__(host, user, password, name_space, f"vDU{number}")
        self.proc_dict = {
            "Cprt": {
                "srv": "cprt",
                "ctr": "cprt"
            },
            "oam": {
                "srv": "oamext",
                "ctr": "oamagent"
            },
            "healing-controller": {
                "srv": "healing-controller",
                "ctr": "healing-controller"
            },
        }


class Bts(object):
    def __init__(self, bts_type):
        self.bts_type = bts_type

    def connect(self):
        pass

    def disconnect(self):
        pass

    def get_process_resources(self):
        pass


class ClassicalBts(Bts):
    def __init__(self, conf):
        logging("Create ClassicalBts...")
        super().__init__(CLASSICAL_BTS_TYPE)
        self.conn = None
        # For example:
        # {'cp_nb': {'0x2513': data}, 'cp-nrt': {'0x2516': data}, 'Cprt': {'0x2515': data}}
        self.process_resources = dict()
        self.master_ip = conf.smod_master["IP"]
        self.user = conf.smod_master["User"]
        self.pwd = conf.smod_master["Password"]

    def connect(self):
        self.conn = taf.transport.ssh.connect(self.master_ip, self.user, self.pwd)
        if self.conn:
            logging("Connect to ClassicalBts {} successful".format(HOST))
        else:
            raise Exception("Connect to ClassicalBts {} failed!".format(HOST))

    def disconnect(self):
        if self.conn:
            logging("Disconnect ClassicalBts {}".format(HOST))
            self.conn.disconnect()

    def _find_process(self, name, lines):
        r = re.compile(r".*node:\s?(\w*)\s?")
        id_list = []
        for line in lines:
            out = r.search(line)
            if out:
                p_id = out.group(1)
            if name in line and p_id != "":
                id_list.append(p_id)
        return id_list

    def _get_process_info(self):
        # return process_info
        # such as {'cp_nb': ['0x2513'], 'cp-nrt': ['0x2516'], 'Cprt': ['0x2515']}
        process_info = {}
        resp = self._aashell("nodes -p")
        for name in g_get_processes:
            try:
                proc_ids = self._find_process(name, resp.splitlines())
            except IndexError:
                proc_ids = []
            if proc_ids:
                process_info[name] = proc_ids
            else:
                logging("{} is not running.".format(name), log_level=LOG_LEVEL_WARN)
        logging("get_process_info: {}".format(process_info))
        return process_info

    def _aashell(self, command):
        time.sleep(2)
        format_cmd = "echo '" + command + "' | nc 127.0.0.1 " + PORT + "\n"
        logging("Run command: {}".format(format_cmd), log_level=LOG_LEVEL_DEBUG)
        resp = self.conn.execute(format_cmd.encode(), timeout=60)
        logging("Command response: {}".format(resp), log_level=LOG_LEVEL_DEBUG)
        return resp

    def _get_resource_usage(self, name, loc, retry_times=3):
        n = 0
        sleep_time = 5
        while True:
            if name == "RROMexe":
                output = self._aashell(
                    "getResourcesUsage -a -j @{} #{}".format(name, loc))
            else:
                output = self._aashell(
                    "getResourcesUsage -l @{} #{}".format(name, loc))

            data = re.search(r'({"ResourcesUsage.*]})[.\t\r\n]*', output)
            if not data:
                data = re.search(r'AaShell>[\s\S]*?({[\s\S]*})', output)
            if data:
                resp = json.loads(data.group(1))
                if resp:
                    return resp

            n += 1
            if n < retry_times:
                logging("Get resources usage for {} {} not successful, trying again after {} seconds".format(
                    name, loc, sleep_time), log_level=LOG_LEVEL_WARN)
                time.sleep(sleep_time)
            else:
                break

        logging("getResourcesUsage failed for {} {}!".format(name, loc), log_level=LOG_LEVEL_ERROR)
        return None

    def get_process_resources(self):
        # return process_resources
        # such as {'cp_nb': {'0x2513': data}, 'cp-nrt': {'0x2516': data}, 'Cprt': {'0x2515': data}}
        process_info = self._get_process_info()
        if not process_info:
            logging("Get process info failed.", log_level=LOG_LEVEL_ERROR)
            return None

        checked_processes = dict()
        process_resources = dict()
        for proc_name, proc_id_list in process_info.items():
            checked_processes[proc_name] = []
            for proc_id in proc_id_list:
                data = self._get_resource_usage(proc_name, proc_id)
                if data:
                    if proc_name in process_resources:
                        process_resources[proc_name].update(dict({proc_id: data}))
                    else:
                        process_resources[proc_name] = dict({proc_id: data})
                    checked_processes[proc_name].append(proc_id)
                    break
                else:
                    return None
        logging("Get resources of processes: {}".format(checked_processes))
        return process_resources


class CloudBts(Bts):
    def __init__(self, conf):
        logging("Create CloudBts...")
        super().__init__(CLOUD_BTS_TYPE)
        self.vDUs = list()
        self.vCU = Vcu(host=conf.vCU["IP"],
                       user=conf.vCU["User"],
                       password=conf.vCU["Password"],
                       name_space=conf.vCU["Namespace"])
        for du in conf.vDUs:
            du_object = Vdu(host=du["IP"],
                            user=du["User"],
                            password=du["Password"],
                            name_space=du["Namespace"],
                            number=du["Id"])
            self.vDUs.append(du_object)
        logging("There are {} vDU in CloudBts.".format(len(self.vDUs)))

    def connect(self):
        if self.vCU:
            self.vCU.connect()
        for du in self.vDUs:
            du.connect()

    def disconnect(self):
        if self.vCU:
            self.vCU.disconnect()
        for du in self.vDUs:
            du.disconnect()

    def get_process_resources(self):
        all_resources = self.vCU.get_process_resources()
        if not all_resources:
            return None

        for du in self.vDUs:
            vdu_proc_resources = du.get_process_resources()
            if not vdu_proc_resources:
                return None
            for name, pod_data_dict in vdu_proc_resources.items():
                if name in all_resources:
                    all_resources[name].update(pod_data_dict)
                else:
                    all_resources[name] = pod_data_dict
        return all_resources


class BtsConfig(object):
    def __init__(self, bts_type):
        self.bts_type = bts_type

    def print(self):
        vars_dict = {}
        for attr in dir(self):
            if not attr.startswith('__'):
                vars_dict[attr] = getattr(self, attr)
        logging("BtsConfig vars: {}".format(vars_dict))

    def check(self):
        pass

    def check_ip(self, server_ip):
        tmp = re.search(r'^(\d+\.\d+\.\d+\.\d+)$', server_ip)
        if not tmp:
            # logging("Invalid server IP: {}!".format(server_ip), log_level=LOG_LEVEL_ERROR)
            return False
        return True


class ClassicalConfig(BtsConfig):
    def __init__(self):
        super().__init__(CLASSICAL_BTS_TYPE)
        self.smod_master = None

    def set_smod_ssh(self, ip=HOST, usr=USRNAME, pwd=PASSWORD):
        ssh_dict = dict({"IP": ip})
        ssh_dict["User"] = usr
        ssh_dict["Password"] = pwd
        self.smod_master = ssh_dict

    def check(self):
        if not self.smod_master or not self.smod_master["IP"]:
            logging("Invalid classical config:  no SystemModule Master IP!", log_level=LOG_LEVEL_ERROR)
            return False

        if not self.check_ip(self.smod_master["IP"]):
            logging("Invalid SystemModule Master IP: {}!".format(self.smod_master["IP"]), log_level=LOG_LEVEL_ERROR)
            return False
        return True


class CloudConfig(BtsConfig):
    def __init__(self):
        super().__init__(CLOUD_BTS_TYPE)
        self.vCU = None
        self.vDUs = None
        self.du_index = 0

    def set_vcu_ssh(self, ip, usr, pwd, namespace):
        ssh_dict = dict({"IP": ip})
        ssh_dict["User"] = usr
        ssh_dict["Password"] = pwd
        ssh_dict["Namespace"] = namespace
        self.vCU = ssh_dict

    def set_vdu_ssh(self, ip, usr, pwd, namespace):
        self.du_index += 1
        ssh_dict = dict({"IP": ip})
        ssh_dict["User"] = usr
        ssh_dict["Password"] = pwd
        ssh_dict["Namespace"] = namespace
        ssh_dict["Id"] = self.du_index
        if not self.vDUs:
            self.vDUs = list()
        self.vDUs.append(ssh_dict)

    def check(self):
        if not self.vCU or not self.vCU["IP"]:
            logging("Invalid cloud config:  no vCU IP!", log_level=LOG_LEVEL_ERROR)
            return False

        if not self.check_ip(self.vCU["IP"]):
            logging("Invalid vCU IP {}!".format(self.vCU["IP"]), log_level=LOG_LEVEL_ERROR)
            return False

        if len(self.vDUs) == 0:
            logging("Invalid cloud config:  no vDU!", log_level=LOG_LEVEL_ERROR)
            return False

        for du in self.vDUs:
            if not self.check_ip(du["IP"]):
                logging("Invalid vDU IP {}!".format(du["IP"]), log_level=LOG_LEVEL_ERROR)
                return False
        return True


class LeakDetect(object):
    def __init__(self):
        self.cpue_ueid_list_sa = list()
        self.cpue_ueid_list_nsa = list()
        self.cpcl_ueid_list = list()
        self.cprt_ueid_list = list()
        self.cpnrt_ueid_list = list()
        self.cpnb_leaked_dict = dict()
        self.cpnrt_leaked_dict = dict()
        self.cprt_leaked_dict = dict()
        self.cpnb_leak_counter = 1
        self.cprt_leak_counter = 1
        self.cpnrt_leak_counter = 1

    def check_if_resources_hanging(self, proc_resource_dict):
        logging("--------start to check hanging resource-----------", log_level=LOG_LEVEL_INFO)
        is_leakage = False
        leaked_process_list = list()
        for proc_name, resources_dict in proc_resource_dict.items():
            for proc_id, data in resources_dict.items():
                logging("check hanging resources for {} {} ".format(proc_name, proc_id))
                # logging("{}".format(data), log_level=LOG_LEVEL_DEBUG)
                content = data
                if proc_name == "cp_nb":
                    if "cpcl" in g_check_components and "cpue" not in g_check_components:
                        logging("check cpcl...", log_level=LOG_LEVEL_DEBUG)
                        if 'cpCellGetResourceUsageResp' in data:
                            content = dict({'cpCellGetResourceUsageResp': data['cpCellGetResourceUsageResp']})
                        else:
                            logging("No cpCellGetResourceUsageResp received!", log_level=LOG_LEVEL_WARN)
                            continue
                    elif "cpue" in g_check_components and "cpcl" not in g_check_components:
                        logging("check cpue...", log_level=LOG_LEVEL_DEBUG)
                        if 'cpUeGetResourceUsageResp' in data:
                            content = dict({'cpUeGetResourceUsageResp': data['cpUeGetResourceUsageResp']})
                        else:
                            logging("No cpUeGetResourceUsageResp received!", log_level=LOG_LEVEL_WARN)
                            continue
                result = self._hanging_parse(proc_name, content)
                if result:
                    leaked_process_list.append(proc_name)
        if leaked_process_list:
            is_leakage = True
            logging("There is hanging resources detected in processes: {}".format(leaked_process_list),
                    log_level=LOG_LEVEL_ERROR)
        logging("--------end to check hanging resource-----------", log_level=LOG_LEVEL_INFO)
        return is_leakage

    def __dict_generator(self, indict, pre=None):
        pre = pre[:] if pre else []
        if isinstance(indict, dict):
            for key, value in indict.items():
                if isinstance(value, dict):
                    for d in self.__dict_generator(value, [key] + pre):
                        yield d
                elif isinstance(value, (list, tuple)):
                    for v in value:
                        for d in self.__dict_generator(v, [key] + pre):
                            yield d
                else:
                    yield pre + [key, value]
        else:
            yield indict

    def _hanging_parse(self, process, data):
        nr_fields = [
            'admittedNsaUsers',
            'admittedSaUsers',
            'numOfUsers',
            'numOfNonGbrBearers',
            'countUsedSrbIndex',
            'numberOfActiveUeSa',
            'numberOfActiveUeNsa',
            'allocatedNumOfBearers',
            'allocatedNumOfPduSessions',
            'currentRohcCtxNumber',
            'allocatedDrbNumber',
            'allocatedSrbNumber',
            'currentUeNumber',
            'allocatedShortPCsiNumber',
            'allocatedLongPCsiNumber',
            'allocatedShortSRNumber',
            'allocatedLongSRNumber',
            'ueCount',
            'bearerCount',
            'numOfResources',
            'nbOfActiveUEs',
            'nbOfActiveSRBs',
            'nbOfActiveDRBs',
            'tempUeCount']
        # exclude still: rlcSduDescriptorUsingCount, ,
        # storedHarqEventCount,nbOfTemporaryUEs --> to be checked after
        # PR636845  corrected + Topi has checked.
        exclude_res_type = [
            'poolPayload',
            'poolCtrl',
            'poolPayloadRlcBundles',
            'poolInd']
        hanging_users = False
        nr = bool(process != "RROMexe")
        res_type = ""
        for a in self.__dict_generator(data):
            try:
                if a[-2] == "resourceType":
                    res_type = a[-1]
                elif ("num" in a[-2] and not a[-2] in ['numCells', 'numS1Links', 'numX2Links'] and not nr) or (
                        a[-2] in nr_fields and res_type not in exclude_res_type):
                    if str(a[-1]) != u'0' or str(a[-1]) != "0":
                        logging("Possibly hanging users: {}, resourceType: {}".format(a, res_type),
                                log_level=LOG_LEVEL_ERROR)
                        hanging_users = True
                    res_type = ""
                else:
                    res_type = ""
            except TypeError:
                pass
        return hanging_users

    def _analyze_cpnb(self, data):
        logging("Check ueIDs from cpnb resource...", log_level=LOG_LEVEL_DEBUG)
        for proc_id, cpnb in data.items():
            logging("Get ueIDs from cpnb {} data".format(proc_id))

            # CpCell
            cpcl_usage_list = []
            if 'cpCellGetResourceUsageResp' in cpnb:
                cpcl_usage_resp = cpnb['cpCellGetResourceUsageResp']
                if isinstance(cpcl_usage_resp, dict):
                    cpcl_usage_list.append(cpcl_usage_resp)
                elif isinstance(cpcl_usage_resp, list):
                    cpcl_usage_list = cpcl_usage_resp
                else:
                    logging("Invalid type of cpCellGetResourceUsageResp!", log_level=LOG_LEVEL_ERROR)
                    raise Exception("Invalid type of cpCellGetResourceUsageResp!")

            for cpcl_usage in cpcl_usage_list:
                for cell_group in cpcl_usage['resources']['cellGroups']:
                    for users in cell_group['nsaBearersPerUser']:
                        self.cpcl_ueid_list += {users['cuUeId']}

                    for users in cell_group['saBearersPerUser']:
                        self.cpcl_ueid_list += {users['cuUeId']}

            # CpUe
            cpue_usage_resp = []
            if 'cpUeGetResourceUsageResp' in cpnb:
                cpue_usage_resp = cpnb['cpUeGetResourceUsageResp']
            for cpue_app_id in cpue_usage_resp:
                for cpue in cpue_app_id['ueMapping']['ueMappingTable']:
                    if "meNbUeX2ApId" in cpue["cuUeAssociatedIds"]:
                        self.cpue_ueid_list_nsa += {cpue['ueIdCu']}
                    else:
                        self.cpue_ueid_list_sa += {cpue['ueIdCu']}

        logging("cpue SA ueid list:{}".format(self.cpue_ueid_list_sa))
        logging("cpue NSA ueid list:{}".format(self.cpue_ueid_list_nsa))
        logging("cpcl ueid list:{}".format(self.cpcl_ueid_list))
        notin_cpue_butin_cpcl = set(self.cpcl_ueid_list).difference(
            self.cpue_ueid_list_nsa + self.cpue_ueid_list_sa)
        notin_cpcl_butin_cpue = set(set(self.cpue_ueid_list_nsa) | set(self.cpue_ueid_list_sa)).difference(
            self.cpcl_ueid_list)

        intra_cucp_ues_to_watch = notin_cpue_butin_cpcl | notin_cpcl_butin_cpue - {0}
        logging("ueid_to_watch in cpnb:{}".format(intra_cucp_ues_to_watch))

        for elem in intra_cucp_ues_to_watch:
            if elem in self.cpue_ueid_list_sa:  # only look into SA users for now
                str_elem = str(elem)
                if str_elem in self.cpnb_leaked_dict:
                    self.cpnb_leaked_dict[str_elem] += 1
                else:
                    self.cpnb_leaked_dict[str_elem] = 1

    def _analyze_cprt(self, data):
        logging("Check ueIDs from cprt resource...", log_level=LOG_LEVEL_DEBUG)
        for proc_id, cprt in data.items():
            logging("Get ueIDs from cprt {} data".format(proc_id))
            for cell_info in cprt["cellList"]["cellInfo"]:
                for ue_ids in cell_info["ueIds"]:
                    self.cprt_ueid_list += {ue_ids["gNbCuUeId"]}

        logging("cprt ueid list:{}".format(self.cprt_ueid_list))
        notin_cprt_butin_cpue = set(set(self.cpue_ueid_list_nsa) | set(self.cpue_ueid_list_sa)).difference(
            self.cprt_ueid_list)
        notin_cpue_butin_cprt = set(self.cprt_ueid_list).difference(
            self.cpue_ueid_list_nsa + self.cpue_ueid_list_sa)
        ueid_to_watch = notin_cprt_butin_cpue | notin_cpue_butin_cprt
        logging("ueid_to_watch in cprt:{}".format(ueid_to_watch))

        for elem in ueid_to_watch:
            if elem not in self.cpue_ueid_list_nsa:  # only add if not NSA call
                str_elem = str(elem)
                if str_elem in self.cprt_leaked_dict:
                    self.cprt_leaked_dict[str_elem] += 1
                else:
                    self.cprt_leaked_dict[str_elem] = 1

    def _analyze_cpnrt(self, data):
        logging("Check ueIDs from cpnrt resource...", log_level=LOG_LEVEL_DEBUG)
        for proc_id, cpnrt in data.items():
            logging("Get ueIDs from cpnrt {} data".format(proc_id))
            for ueid_list in cpnrt["ueIdList"]["ueIdentifiers"]:
                self.cpnrt_ueid_list += {ueid_list["gNbCuCpUeId"]}

        logging("cpnrt ueid list:{}".format(self.cpnrt_ueid_list))
        # For now check is only between CPUE and CPNRT
        notin_cpnrt_butin_cpue = set(set(self.cpue_ueid_list_nsa) | set(self.cpue_ueid_list_sa)).difference(
            self.cpnrt_ueid_list)
        notin_cpue_butin_cpnrt = set(self.cpnrt_ueid_list).difference(
            self.cpue_ueid_list_sa + self.cpue_ueid_list_nsa)

        ueid_to_watch = notin_cpnrt_butin_cpue | notin_cpue_butin_cpnrt
        logging("ueid_to_watch in cpnrt:{}".format(ueid_to_watch))

        for elem in ueid_to_watch:
            if elem not in self.cpue_ueid_list_nsa:  # only add if not NSA call
                str_elem = str(elem)
                if str_elem in self.cpnrt_leaked_dict:
                    self.cpnrt_leaked_dict[str_elem] += 1
                else:
                    self.cpnrt_leaked_dict[str_elem] = 1

    def check_if_ueid_leaked(self, process_resources):
        logging("--------start to check ueIDs-----------", log_level=LOG_LEVEL_INFO)
        is_leaked = False
        # Check the resource data in order: cpnb, cprt, cpnrt
        self._analyze_cpnb(process_resources["cp_nb"])
        self._analyze_cprt(process_resources["Cprt"])
        self._analyze_cpnrt(process_resources["cp-nrt"])

        sorted_shortlisted_cpnb_set = set(
            sorted({key for (key, value) in self.cpnb_leaked_dict.items() if value >= self.cpnb_leak_counter},
                   reverse=True))
        if len(sorted_shortlisted_cpnb_set) >= 1:
            is_leaked = True
            logging(
                "Found cuUeIds in CPNB which are not consistent in CUCP:{}. "
                "Another snapshot request for these IDs will not be made again!!".format(
                    sorted_shortlisted_cpnb_set), log_level=LOG_LEVEL_ERROR)

        sorted_cprt_set = set(
            sorted({key for (key, value) in self.cprt_leaked_dict.items() if value >= self.cprt_leak_counter},
                   reverse=True))
        if len(sorted_cprt_set) >= 1:
            is_leaked = True
            logging(
                "Found cuUeIds in CPRT which are not consistent with CPUE:{}. "
                "Another snapshot request for these IDs will not be made again!!".format(
                    sorted_cprt_set), log_level=LOG_LEVEL_ERROR)

        sorted_cpnrt_set = set(
            sorted({key for (key, value) in self.cpnrt_leaked_dict.items() if value >= self.cpnrt_leak_counter},
                   reverse=True))
        if len(sorted_cpnrt_set) >= 1:
            is_leaked = True
            logging(
                "Found cuUeIds in CPNRT which are not consistent with CPUE:{}. "
                "Another snapshot request for these IDs will not be made again!!".format(
                    sorted_cpnrt_set), log_level=LOG_LEVEL_ERROR)
        logging("--------end to check ueIDs-----------", log_level=LOG_LEVEL_INFO)
        return is_leaked


class ResourceLeakDetector(object):
    def __init__(self, conf):
        self.process_resources = dict()
        self.is_leakage = False
        self.detector = LeakDetect()
        self.bts_type = conf.bts_type
        if self.bts_type == CLOUD_BTS_TYPE:
            self.bts = CloudBts(conf)
        else:
            self.bts = ClassicalBts(conf)

    def __enter__(self):
        self.bts.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.bts.disconnect()

    def get_process_resources(self):
        logging("************************ Start to get process resources ************************",
                log_level=LOG_LEVEL_INFO)
        self.process_resources = self.bts.get_process_resources()
        logging("************************ End to get process resources ************************",
                log_level=LOG_LEVEL_INFO)
        return self.process_resources

    def parse_resources(self):
        logging("************************ Start to parse process resources ************************",
                log_level=LOG_LEVEL_INFO)
        try:
            self.is_leakage = self.detector.check_if_resources_hanging(self.process_resources)
            if len(g_check_components) == 4 and self.detector.check_if_ueid_leaked(self.process_resources):
                self.is_leakage = True
                logging("There is cuUeId leakage detected.", log_level=LOG_LEVEL_ERROR)

            if not self.is_leakage:
                logging("There is no resources leakage.")
            logging("************************ End to parse process resources ************************",
                    log_level=LOG_LEVEL_INFO)
            return True
        except Exception as exception:
            logging("Analyze resources exception: {}".format(exception), log_level=LOG_LEVEL_ERROR)
            return False

    def has_leakage(self):
        return self.is_leakage


def check_resources_leakage(log_dir=None, conf=None, components_to_check=None):
    log_file = 'hanging_resource_check_' + datetime.now().strftime("%Y%m%d_%H%M%S") + '.log'
    initialize_log(log_file)
    try:
        if not conf:
            conf = ClassicalConfig()
            conf.set_smod_ssh()
            logging("Using default ClassicalBts config.")

        if not isinstance(conf, BtsConfig):
            exit_code = EXIT_ERROR
            text = "Invalid type of input parameter 'conf'"
            return

        conf.print()
        if not conf.check():
            exit_code = EXIT_ERROR
            text = "Check failed of input parameter 'conf'"
            return

        logging("Input components_to_check: {}".format(components_to_check))
        set_check_processes(components_to_check)
        logging("Need to check resources usage for components: {}".format(g_check_components))
        logging("Need to get resources usage from processes: {}".format(g_get_processes))

        with ResourceLeakDetector(conf) as detector:
            if detector.get_process_resources():
                if not detector.parse_resources():
                    exit_code = EXIT_ERROR
                    text = "Failed to parse resources"
                else:
                    if detector.has_leakage():
                        exit_code = EXIT_HAS_LEAKAGE
                        text = "There were hanging resources"
                    else:
                        exit_code = EXIT_NO_LEAKAGE
                        text = "No hanging resources"
            else:
                exit_code = EXIT_ERROR
                text = "Failed to get resources"
    except Exception as exception:
        exit_code = EXIT_ERROR
        text = "Exception: {}".format(exception)
    finally:
        if exit_code != EXIT_NO_LEAKAGE:
            logging("{}, exit_code={}".format(text, exit_code), log_level=LOG_LEVEL_ERROR)
        else:
            logging("{}, exit_code={}".format(text, exit_code), log_level=LOG_LEVEL_INFO)

        if log_dir:
            copy_log_to_dir(log_dir, log_file)
        print("You can see details from {}".format(log_file))

        if exit_code != EXIT_NO_LEAKAGE:
            raise Exception(text)
        return exit_code


def type_component(component):
    if component not in g_check_components:
        raise Exception(argparse.ArgumentTypeError("invalid component: '{}' (available component: {})"
                                                   .format(component, g_check_components)))
    return component


def parse_arguments():
    parser = argparse.ArgumentParser(
        allow_abbrev=False,
        formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument(
        '-l',
        '--log_dir',
        dest='log_dir',
        default=None,
        action=argparse._StoreAction,
        help=(
            'The directory path where log files are stored. \n'
            'Default value is None, then log files will be output to the current directory. \n'))

    parser.add_argument(
        '-t',
        '--bts_type',
        dest='bts_type',
        default=CLASSICAL_BTS_TYPE,
        action=argparse._StoreAction,
        choices=[CLASSICAL_BTS_TYPE, CLOUD_BTS_TYPE],
        help=(
            'BTS type, only can be classical or cloud\n'
            f'Default: {CLASSICAL_BTS_TYPE} \n'))

    parser.add_argument(
        '-p',
        '--components_to_check',
        dest='components_to_check',
        nargs='+',
        default=None,
        action=argparse._StoreAction,
        type=type_component,
        help=('Components that need to check resources leakage. \n'
              f'You can choose any combination of the components in this list {g_check_components}. \n'
              'Example: -p cpcl cpnrt\n'
              f'Default: {g_check_components} \n'))

    parser.add_argument(
        '-g',
        '--classical_gnb_ssh',
        dest='classical_gnb_ssh',
        nargs=3,
        default=None,
        action=argparse._StoreAction,
        help=(
            'This parameter is only valid when bts_type is classical. \n'
            'Argument should have following values:\n'
            ' "<ip> <username> <password>"\n'
            f'Exmaple: -g {HOST} {USRNAME} {PASSWORD} \n'))

    parser.add_argument(
        '-c',
        '--vcu_ssh',
        dest='vcu_ssh',
        nargs=4,
        default=None,
        action=argparse._StoreAction,
        help=(
            'This parameter is only valid when bts_type is cloud. \n'
            'Argument should have following values:\n'
            ' "<ip> <username> <password> <namespace>"\n'
            'Exmaple: -c 10.107.125.66 core system123 7-5-ute5gaic004 \n'))

    mutually_exclusive_group = parser.add_mutually_exclusive_group()
    mutually_exclusive_group.add_argument(
        '-d',
        '--vdu_ssh',
        dest='vdu_ssh_list',
        nargs=4,
        default=None,
        action=argparse._AppendAction,
        help=(
            'This parameter is only valid when bts_type is cloud. \n'
            'And this argument can be used multiple times when has multiple vdus.\n'
            'Each argument should have following values:\n'
            ' "<ip> <username> <password> <namespace>"\n'
            'Exmaple: -d 192.168.2.125 core system123 7-5-ute5gaic004'
            ' -d 192.168.2.126 core system123 7-5-ute5gaic004 \n'))

    examples = parser.add_argument_group('Examples of tests execution')
    examples.description = """
      Displays the command help information:
      $ python hanging_check.py -h

      Check resource leakage for classical bts with default config (192.168.255.130 toor4nsn oZPS0POrRieRtu)
      $ python hanging_check.py

      Check resource leakage for classical bts
      $ python hanging_check.py -t classical -g 192.168.255.130 toor4nsn aiq&om@fmob

      Check resource leakage for customized components(cpcl, cprt) on classical bts
      $ python hanging_check.py -p cpcl cprt

      Check resource leakage for cloud bts (only has 1 vdu)
      $ python hanging_check.py -t cloud -c 10.107.125.66 core system123 7-5-ute5gaic004 -d 192.168.2.125
      ...  core system123 7-5-ute5gaic004

      Check resource leakage for cloud bts (has 2 vdu)
      $ python hanging_check.py -t cloud -c 10.107.125.66 core system123 7-5-ute5gaic004 -d 192.168.2.125
      ...  core system123 7-5-ute5gaic004
      ...  -d 192.168.2.126 core system123 7-5-ute5gaic004
    """
    return parser.parse_args()


if __name__ == "__main__":
    print('------ start to check resource leakage ------')
    args = parse_arguments()
    print("Input arguments: {}".format(args))

    if args.log_dir and not os.path.exists(args.log_dir):
        error_msg = "log_dir {} doesn't exist.".format(args.log_dir)
        raise Exception(error_msg)

    if CLASSICAL_BTS_TYPE == args.bts_type:
        # Check classical bts with input config
        if args.classical_gnb_ssh:
            config = ClassicalConfig()
            config.set_smod_ssh(args.classical_gnb_ssh[0], args.classical_gnb_ssh[1], args.classical_gnb_ssh[2])
        else:
            config = None
        check_resources_leakage(conf=config, log_dir=args.log_dir, components_to_check=args.components_to_check)
    else:
        # Check cloud bts with input config
        config = CloudConfig()
        if not args.vcu_ssh:
            error_msg = "Please input argument vcu_ssh!\n"\
                        "It should like -c <ip> <username> <password> <namespace>"
            raise Exception(error_msg)
        if not args.vdu_ssh_list:
            error_msg = "Please input argument vdu_ssh!\n"\
                        "It should like -d <ip> <username> <password> <namespace>"
            raise Exception(error_msg)
        config.set_vcu_ssh(args.vcu_ssh[0], args.vcu_ssh[1], args.vcu_ssh[2], args.vcu_ssh[3])
        for vdu_ssh in args.vdu_ssh_list:
            config.set_vdu_ssh(vdu_ssh[0], vdu_ssh[1], vdu_ssh[2], vdu_ssh[3])
        check_resources_leakage(conf=config, log_dir=args.log_dir, components_to_check=args.components_to_check)
    print('------ end to check resource leakage ------')
