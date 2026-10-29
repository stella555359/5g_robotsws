import os

from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh

ssh = ssh()


class basic_system_operation(object):
    def __init__(self):
        pass

    @staticmethod
    def create_a_directory(log_path, directory_name, cu_vdu_index):
        builtin_obj = BuiltIn()
        rtn = ""
        try:
            abs_path = os.path.join(log_path, directory_name, cu_vdu_index)
            builtin_obj.log(abs_path, "INFO")
            if not os.path.exists(abs_path):
                os.makedirs(abs_path)
            rtn = abs_path
        except Exception as e:
            builtin_obj.log(e, "ERROR")
        if len(rtn) == 0:
            raise RuntimeError("get_a_directory(): fail!!")
        return rtn

    @staticmethod
    def create_a_file(log_path, file_name):
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

    @staticmethod
    def master_connect(hostname, username, password, port="22", alias="master", timeout="10"):
        conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=alias,
                              timeout=timeout)
        return conn

    @staticmethod
    def master_close(alias='master'):
        ssh.disconnect(connection=alias)

    @staticmethod
    def vm_connect(hostname, username, password, port="22", alias="VM", timeout="10"):
        conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=alias,
                              timeout=timeout)
        return conn

    @staticmethod
    def vm_close(alias="VM"):
        ssh.disconnect(connection=alias)
