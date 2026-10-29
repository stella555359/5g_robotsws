from robot.libraries.BuiltIn import BuiltIn
import os
from SSHLibrary import SSHLibrary
from taf.transport.ssh import ssh
from taf.gnb.oam.coam.vdu import vdu
import yaml
import time
import re
import zipfile
import json

sshlib = SSHLibrary()
ssh = ssh()
vdu = vdu()


class basic(object):
    def __init__(self):
        pass

    def master_connect(self, hostname, username, password, port="22", alias="master", timeout="10"):
        """
        This keyword is used to connect to vdu/vcu master
        *Args:*
            - _ip_: k8s master ip address(mandatory)
            - _user_: user name of k8s master (mandatory)
            - _password_: password of user (mandatory)
            - _port_: k8s master ssh port
            - _timeout_: timeout of login, default is 10s

        *Command:*  None
        *Returns:*
            - connection alias
        *Example:*
        | master_connect | 10.71.174.254 | user |  password  | 22 |
         """
        conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=alias,
                              timeout=timeout)
        return conn

    def master_close(self, alias='master'):
        """
        This keyword is used to close vdu master
        *Command:*  None
        *Returns:*
            - None
        *Example:*
        | vdu_master_close |  |
         """
        ssh.disconnect(connection=alias)

    def vm_connect(self, hostname, username, password, port="22", key_path=None, alias="VM", timeout="10"):
        """
        This keyword is used to connect to vdu master
        *Args:*
            - _ip_: k8s master ip address(mandatory)
            - _user_: user name of k8s master (mandatory)
            - _password_: password of user (mandatory)
            - _port_: k8s master ssh port
            - key_path: the path to key that should be used to authenticate with the remote
            - _timeout_: timeout of login, default is 10s

        *Command:*  None
        *Returns:*
            - connection alias
        *Example:*
        | vm_connect | 10.108.229.191 | user |  password  | 22 |
         """
        conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=alias,
                              key_path=key_path, timeout=timeout)
        return conn

    def vm_close(self, alias="VM"):
        """
        This keyword is used to close vdu master
        *Command:*  None
        *Returns:*
            - None
        *Example:*
        | vm_close |
         """
        ssh.disconnect(connection=alias)

    def connect_to_container(self, master_ip, username, password, pod_name, container_name, namespace):
        """
        *Args:*
            - master_ip: the OE20 cluster ip
            - username: the username that used to login master, it should be tenant username
            - password: the password that used to login master, it should be tenant username
            - pod_name: the pod name that container belongs to
            - container_name: the container name that you want to login

        *Command:* ``kubectl exec -it <pod_name> -c <container_name> -- bash``

        *Returns:*

        *Example:*

        """
        sshlib.set_default_configuration(timeout=20)
        sshlib.open_connection(master_ip, prompt='REGEXP:~]\\$')
        res = sshlib.login(username, password, delay='5s')
        sshlib.set_client_configuration(prompt='REGEXP:(bash.*\\$)|#')
        log_cmd = 'kubectl exec -it {} -c {} -n {} -- bash'.format(pod_name, container_name, namespace)
        # print log_cmd
        sshlib.write(log_cmd)
        res = sshlib.read_until_prompt()
        return res

    def execute_command_in_container(self, cmd='', prompt=""):
        """
            *Args:*
                - cmd: the command you want to execute
                - prompt: the prompt after the command executed

            *Command:*

            *Returns:none

            *Example:execute_command_in_container(cmd,prompt)

            """
        try:
            print(sshlib.read())
        except Exception:
            pass
        if prompt is None or prompt == "":
            prompt = "bash.*\\$|#"

        sshlib.write(cmd)
        try:
            ret = ''
            ret = sshlib.read_until_regexp(prompt)
            return ret
        except Exception as e:
            print(e)

    def create_a_directory(self, log_path, directory_name):
        """create a directory name with absolute path
        *AUTHOR* mengli.yang@nokia-sbell.com
        | Input Parameters  | Man. | Description |
        | log_path          | Yes  |   list type, e.g, ["log_path", "scf"] |

        *RETURN VALUE*
        string

        Example:
        | ${folder_name}  | create_a_directory | log_path | scf |
        """
        builtin_obj = BuiltIn()
        rtn = ""
        try:
            abs_path = os.path.join(log_path, directory_name)
            builtin_obj.log(abs_path, "INFO")
            if not os.path.exists(abs_path):
                os.makedirs(abs_path)
            rtn = abs_path
        except Exception as e:
            builtin_obj.log(e, "ERROR")
        if len(rtn) == 0:
            raise RuntimeError("get_a_directory(): fail!!")
        return rtn

    def create_a_file(self, log_path, file_name):
        """create a file name with absolute path,Raise exception if failed to generate a file name.
        *AUTHOR* mengli.yang@nokia-sbell.com
        | Input Parameters  | Man. | Description |
        | path            | Yes  |   list type, e.g, ["folder1", "fold2", "filename.txt"] |
        *RETURN VALUE*
        string

        Example:
        | ${file_name}  | create_a_file | folder1 | folder2 | filename.txt |
        """
        builtin_obj = BuiltIn()
        rtn = ""
        try:
            file_abs_path = os.path.join(log_path, file_name)
            builtin_obj.log(file_abs_path, "INFO")
            file_dir, file_name = os.path.split(file_abs_path)
            if not os.path.exists(file_dir):
                os.makedirs(file_dir)
            if not os.path.exists(file_abs_path):
                os.system("touch %s" % file_abs_path)
            rtn = file_abs_path
        except Exception as e:
            builtin_obj.log(e, "ERROR")
        if len(rtn) == 0:
            raise RuntimeError("get_a_file(): fail!!")
        return rtn

    def transfer_dictionary_to_yaml_file(self, dict_values, file_path):
        """Get dictionary according yaml format file.
        *AUTHOR* mengli.yang@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | dict_values      | Yes  | dict_values to be dumped|
        | file_path       | Yes  | file_path of yaml file |

        *RETURN VALUE*
        None

        Example
        | ${dictionary_content} | yaml_file_to_dictionary | /home/ute/a.yaml |
        """
        with open(file_path, 'w') as f:
            yaml.safe_dump(dict_values, f, encoding='utf-8', allow_unicode=True)

    def update_service_account_password_and_get_result(self, username, password, new_password):
        """
        this function is used to update service account password and get operation result.

        Parameters:
            username(str): current username
            password(str): current password
            new_password(str): new desired password

        Return dict:
            the dict including content, summary of result.
        """
        try:
            operation_result = vdu.update_service_account_password(username=username, password=password,
                                                                   new_password=new_password)
        except Exception as e:
            print('The error object is: {}'.format(e))
            http_response_body = getattr(e, 'body')
            print('Body attribute of error object is: {}'.format(http_response_body))
            operation_result = http_response_body
        finally:
            print('The operation result is: {}'.format(operation_result))
            return operation_result

    def get_ru_ip(self, namespace, conn, serial_number, timeout="10"):
        pod_prefix = "po-" + namespace
        container_prefix = "ctr-" + namespace
        cmd = "kubectl exec -n " + namespace + " " + pod_prefix + "-" + "oamfh-0 -c " + \
              container_prefix + "-dhcp -- cat /var/log/kea-leasesdb/kea-leases4.csv |tail -3"
        print(cmd)
        ssh.send_command(cmd, connection=conn, timeout=timeout)
        res = ssh.read_output(connection=conn)
        num = 10
        ips = res.split()
        for i in ips:
            ip = i.split(',')[0]
            print(ip)
            ip_text = i.split(',')[2]
            ip_ids = ip_text.split(':')
            ru_id = '1M'
            for j in range(1, num):
                ip_id = ip_ids[j - num][1]
                ru_id = ru_id + ip_id
            print(ru_id)
            if ru_id == serial_number:
                ru_ip = ip
                return ru_ip

    def download_file_to_server(self, conn="master", hostname="10.69.69.204", username="ute", password="Ut3pa5s#ff97",
                                port="22", remote_path="/logs/a.tar", local_path='/home/ute/a.tar'):
        """download file to server
        *AUTHOR* ge.cao@nokia-sbell.com
        | Input Parameters  | Man. | Description |
            - conn: connection alias
            - remote_path: The path where the file needs to be uploaded (mandatory)
            - local_path: The path of local file(mandatory)

        *RETURN VALUE*
            - None

        Example:
        |download_file_to_server | remote_path | local_path |
        """
        ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=conn)
        ssh.upload_file(local_path=local_path, remote_path=remote_path, connection=conn)
        time.sleep(15)
        ssh.disconnect(connection=conn)

    def verify_local_file_size(self, local_path="/home/ute/a.tar"):
        """verify_local_file_size
        *AUTHOR* ge.cao@nokia-sbell.com
        | Input Parameters  | Man. | Description |
            - local_path: The path of local file(mandatory)

        *RETURN VALUE*
            - local_file_size

        Example:
        |verify_local_file_size | local_path |
        """
        local_file_size = int(os.path.getsize(local_path))
        return local_file_size

    def verify_remote_file_size(self, hostname="10.69.69.204", username="ute", password="Ut3pa5s#ff97", port="22",
                                conn="master", remote_path="/logs/a.tar"):
        """verify_remote_file_size
        *AUTHOR* ge.cao@nokia-sbell.com
        | Input Parameters  | Man. | Description |
            - hostname: hostname of remote server
            - username: user name of remote server
            - password: password of remote server
            - conn: connection alias
            - remote_path: The path of remote server file(mandatory)

        *RETURN VALUE*
            - file_size

        Example:
        |verify_remote_file_size | remote_path |
        """
        file_size = None
        ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=conn)
        flags = ssh.file_exists(remote_path=remote_path, connection=conn)
        if flags:
            file_size = ssh.execute(command="ls -l " + remote_path + " | awk -F' ' '{print $5}'",
                                    connection="master")
            file_size = int(file_size.strip())
        ssh.disconnect(connection=conn)
        return file_size

    def get_match_files(self, dir_file, filter_pattern):
        """
        this keyword to get match file name list from specified folder
        *AUTHOR* ge.cao@nokia-sbell.com
        Parameters:
            dir_file(str): folder path that needs to be filtered
            filter_pattern(str): a regular expression pattern

        Returns:
            match_file_name_list(list)
        """
        match_file_name_list = []
        for root, dirs, files in os.walk(dir_file):
            for file in files:
                pre, suf = os.path.splitext(file)
                script_file_filter = re.compile(r"%s" % filter_pattern)
                z = re.search(script_file_filter, pre)
                if z:
                    match_file_name_list.append(os.path.join(root, file))
        return match_file_name_list

    def collect_iq_data_by_rannic_command_blind(self, master_ip, username="core", password="system123",
                                                vdu_ns="cran1", log_file_name="LOG_FILE_NAME.tar.gz",
                                                alias="vdu_connect", ute_path="/home/ute/MN/"):
        """
        this keyword to collect iq data by rannic command blind way
        *AUTHOR* ge.cao@nokia-sbell.com
        Parameters:
             master_ip(str): vdu OE ssh ip
             username(str): user name of vdu OE
             password(str): password of vdu OE
             vdu_ns(str): vdu namespace
             log_file_name(str): log compressed package name
             alias(str): connection alias
             ute_path(str): log path of IQ data will be saved
        Returns:
            log_path_on_ute(str) log path saved on ute server
        """
        sshlib.set_default_configuration(timeout=20)
        sshlib.open_connection(master_ip, alias=alias, prompt='REGEXP:~]\\$')
        sshlib.login(username, password, delay='5s')
        # sshlib.set_client_configuration(prompt='REGEXP:(bash.*\\$)|#')
        cmd_delete_dir = 'rm -rf /tmp/%s/tmp_iq_data/*' % vdu_ns
        cmd_mkdir = 'mkdir -p /tmp/%s/tmp_iq_data' % vdu_ns
        sshlib.write(cmd_delete_dir)
        sshlib.read_until_prompt()
        sshlib.write(cmd_mkdir)
        sshlib.read_until_prompt()
        config_cmd = "sudo ifconfig ens35f0 192.168.254.16/24"
        ping_cmd = "sudo ping -I ens35f0 192.168.254.20 -c 2"
        sshlib.write(config_cmd)
        sshlib.read_until_prompt()
        sshlib.write(ping_cmd)
        sshlib.read_until_prompt()
        cmd_login = "sshpass -p 'oZPS0POrRieRtu@09' ssh -o StrictHostKeyChecking=no serviceuser@192.168.254.20"
        sshlib.write(cmd_login)
        sshlib.set_client_configuration(prompt='REGEXP:~\\$')
        sshlib.write("pwd")
        sshlib.read_until_prompt()
        cmd_delete_dir = "echo oZPS0POrRieRtu@09 | sudo -S rm -rf /tmp/mine"
        sshlib.write(cmd_delete_dir)
        sshlib.read_until_prompt()
        cmd_cell_config = "echo oZPS0POrRieRtu@09 | sudo -S /usr/lib64/python/antenna_snapshot_config.py --subcellid 0"
        sshlib.write(cmd_cell_config)
        sshlib.read_until_prompt()
        cmd_config_blind = "echo oZPS0POrRieRtu@09 | sudo -S /usr/lib64/python/antenna_snapshot_config.py --blind"
        sshlib.write(cmd_config_blind)
        sshlib.read_until_prompt()
        cmd_tar = "echo oZPS0POrRieRtu@09 | sudo -S tar -czvf /tmp/%s /tmp/mine/" % log_file_name
        sshlib.write(cmd_tar)
        sshlib.read_until_prompt()
        cmd_chmod = "echo oZPS0POrRieRtu@09 | sudo -S chmod 774 /tmp/%s" % log_file_name
        sshlib.write(cmd_chmod)
        sshlib.read_until_prompt()
        cmd_exit = "exit"
        sshlib.set_client_configuration(prompt='REGEXP:~]\\$')
        sshlib.write(cmd_exit)
        sshlib.read_until_prompt()
        iq_data_log_dir = "/var/home/core/iq_data"
        sshlib.write("rm -rf /var/home/core/iq_data/*")
        sshlib.read_until_prompt()
        sshlib.write("mkdir -p /var/home/core/iq_data/")
        sshlib.read_until_prompt()
        cmd_scp = "sshpass -p oZPS0POrRieRtu@09 scp serviceuser@192.168.254.20:/tmp/%s /var/home/core/iq_data" \
                  % log_file_name
        sshlib.write(cmd_scp)
        sshlib.read_until_prompt()
        sshlib.close_connection()
        conn = self.master_connect(hostname=master_ip, username=username, password=password, alias="master")
        log_path_on_ute = ute_path + "/" + log_file_name
        ssh.download_file(remote_path="/var/home/core/iq_data/" + log_file_name, local_path=log_path_on_ute,
                          connection=conn)
        return log_path_on_ute

    @staticmethod
    def run_local_command(command):
        """
        *Usage:*
            - Keyword
            - This keyword is used to run a linux command locally.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - command: a linux command
        """
        import subprocess
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        print("stdout:\n", stdout.decode())
        if stderr:
            print("stderr:\n", stderr.decode())

    def connect_to_server_with_key(self, alias, server):
        """
        *Usage:*
            - Keyword
            - This keyword is used to connect to a remote server with a key.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - alias: an alias for ssh connection
            - server: dict type. the remote_server, {host=x, username=x, password=x, key_path=x}
        """
        self.run_local_command("chmod 600 {}".format(server["key_path"]))
        self.vm_connect(server["host"], server["username"], server["password"], key_path=server["key_path"],
                        alias=alias)

    def disconnect_from_server(self, alias):
        """
        *Usage:*
            - Keyword
            - This keyword is used to disconnect from a remote server.
        *Contact:*
            - renhui-david.liu@nokia-sbell.com
        *Args:*
            - alias: an alias for ssh connection
        """
        self.vm_close(alias)

    def find_file_in_zip_archives_in_directory(self, dir_zip, target_file_name_regex):
        """find_file_in_zip_archives_in_directory
        *AUTHOR* ge.cao@nokia-sbell.com
        | Input Parameters  | Man. | Description |
            - dir_zip: connection alias
            - target_file_name_regex: The path where the file needs to be uploaded (mandatory)

        *RETURN VALUE*
            - target zip file name

        Example:
        |find_file_in_zip_archives_in_directory | dir_zip | target_file_name_regex |
        """
        pattern = re.compile(target_file_name_regex)
        for root, dirs, files in os.walk(dir_zip):
            for file in files:
                if file.endswith('.zip'):
                    zip_path = os.path.join(root, file)
                    try:
                        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                            for zip_info in zip_ref.infolist():
                                if pattern.search(zip_info.filename):
                                    return file
                    except zipfile.BadZipFile:
                        continue
        return None

    def modify_json_file(self, json_file_path, new_distname, param_updates, new_file_name, target_operation):
        """modify_json_file
        *AUTHOR* ge.cao@nokia-sbell.com
        | Input Parameters  | Man. | Description |
          - json_file_path: json file path
          - new_distname: new distname
          - param_updates: the new value that you want to set(list)
          - new_file_name: the new json file name
          -target_operation: the new operation,create or delete or replace

        Example:
        |modify_json_file | json_file_path | new_distname | param_updates | new_file_name | target_operation |
        """
        dir_json, file_name = os.path.split(json_file_path)
        new_file_path = os.path.join(dir_json, new_file_name)
        with open(json_file_path, 'r') as file:
            data = json.load(file)
        pattern = r'MRBTS-\d+/NRBTS-\d+'
        data[0]['distName'] = re.sub(pattern, new_distname, data[0]['distName'])
        data[0]['operation'] = target_operation
        for param in data[0]['parameters']:
            if param['parameterName'] in param_updates:
                param['value'] = param_updates[param['parameterName']]
        with open(new_file_path, 'w') as file:
            json.dump(data, file, indent=4)

    def check_column_in_csv(self, file_path, column_name):
        with open(file_path, 'r') as csvfile:
            csv_reader = csv.reader(csvfile)
            for row in csv_reader:
                for cell in row:
                    if column_name in cell:
                        return cell
        return False
