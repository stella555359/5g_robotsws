from robot.libraries.BuiltIn import BuiltIn
import os
from SSHLibrary import SSHLibrary
from taf.transport.ssh import ssh
import yaml

sshlib = SSHLibrary()
ssh = ssh()


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

    def vm_connect(self, hostname, username, password, port="22", alias="VM", timeout="10"):
        """
        This keyword is used to connect to vdu master
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
        | vm_connect | 10.108.229.191 | user |  password  | 22 |
         """
        conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=alias,
                              timeout=timeout)
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
