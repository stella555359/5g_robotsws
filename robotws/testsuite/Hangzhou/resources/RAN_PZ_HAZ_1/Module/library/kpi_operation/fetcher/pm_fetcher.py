"""
:copyright: Nokia
:author: winnie.he
:contact: winnie.he@nokia-sbell.com
:maintainer winnie.he:
:contact winnie.he@nokia-sbell.com
"""
import time
import os
import re
import shutil
import json
import requests
from abc import ABCMeta
import sys
import paramiko
import logging


class PMFetcher(metaclass=ABCMeta):
    def __init__(self):
        self._base_dir = ''
        self.conn = None
        self._ip = ''
        self._username = ''
        self._password = ''
        self._identity = 'base'
        self._logdir = ''

    def _set_logger(self):
        os.makedirs(self._base_dir, exist_ok=True)
        self._logger = logging.getLogger(f"fetcher {self._identity}")
        self._logger.setLevel(logging.DEBUG)

        log_path = os.path.join(self._logdir, 'fetcher.log')
        self._file_handler = logging.FileHandler(log_path, 'w', encoding='UTF-8')
        self._file_handler.setLevel(logging.DEBUG)
        file_formatter = logging.Formatter('%(asctime)s %(name)s - %(message)s')
        self._file_handler.setFormatter(file_formatter)
        # self._logger.addHandler(console_handler)
        self._logger.addHandler(self._file_handler)
        self._logger.debug(f'app started.')

    def _master_connect(self):
        if self.conn is None:
            self.conn = paramiko.SSHClient()
            self.conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.conn.connect(hostname=self._ip,
                              port="22",
                              username=self._username,
                              password=self._password,
                              timeout=30,
                              allow_agent=False,
                              look_for_keys=False)
            self._shell = self.conn.invoke_shell()

    def is_connection_alive(self):
        try:
            if self.conn and self.conn.get_transport() is not None:
                return self.conn.get_transport().is_active()
        except Exception as e:
            print("Connection lost : %s" % e)
            return False

    def _master_close(self):
        if self.conn:
            self.conn.close()
            self.conn = None
            if self._shell:
                self._shell.close()

    def _rm_tree(self, download_path):
        if os.path.exists(download_path):
            try:
                shutil.rmtree(download_path)
            except Exception:
                self._logger.info(f"Error deleting {download_path}")

    def _smart_decode(self, output1):
        try:
            output = output1.decode("utf8")
        except Exception:
            self._logger.debug('Try to use gbk decode...')
            try:
                output = output1.decode("gbk")
                self._logger.debug(output)
            except Exception:
                self._logger.debug('Try to use iso-8859-1 decode...')
                output = output1.decode("iso-8859-1", "ignore")
        # remove color special character
        import re
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        output = ansi_escape.sub('', output)
        return output

    def _execute_shell_cmd(self, command):
        self._shell.send(command + '\n')
        self._logger.info(f'----> {command}')
        time.sleep(5)
        response = self._smart_decode(self._shell.recv(9999))
        self._logger.info(f'<---- {response}')
        return response

    def perform_cmd(self, cmd_line):
        if not self.is_connection_alive():
            self._master_connect()
        timeout = 60
        # cmd_line = cmd_line.decode("unicode-escape").replace("\\", "/")
        # print(cmd_line)
        try:
            stdin, stdout, stderr = self.conn.exec_command(cmd_line)
            endtime = time.time() + timeout
            while not stdout.channel.eof_received:
                time.sleep(1)
                if time.time() > endtime:
                    stdout.channel.close()
                    break
            err = stderr.read()
            result = stdout.read()
            return err, result
        except Exception as exc:  # pylint: disable=broad-except
            error = "{!r}".format(exc)
            err = (
                ">>> Error while executing:\n"
                + cmd_line
                + "\n>>> Returned with error:\n"
                + str(error)
            )
            return err, ""

    def _download_file_to_local(self, remote_path, local_path):
        self._sftp_connect(
            host=self._ip,
            username=self._username,
            password=self._password)
        os.makedirs(local_path, exist_ok=True)
        filename = os.path.basename(remote_path)
        local_file = os.path.join(local_path, filename)
        self._sftp.get(remotepath=remote_path, localpath=local_file)
        self._logger.info(f'{remote_path} downloaded to {local_file}')
        self._sftp_disconnect()

    def _sftp_connect(self, host, username, password, port=22):
        transport = paramiko.Transport((host, port))
        transport.connect(username=username, password=password)
        self._sftp = paramiko.SFTPClient.from_transport(transport)

    def _sftp_disconnect(self):
        self._sftp.close()

    def _extract_pm_file(self, local_path, file_name):
        pass

    def fetch(self):
        pass

    def shutdown(self):
        try:
            self._master_close()
        except Exception:
            pass
        if self._file_handler is not None:
            self._logger.debug(f'closing log file: {self._file_handler.baseFilename}')
            self._file_handler.close()
        if self._base_dir:
            self._logger.debug(f'deleting artifact directory: {self._base_dir}')
            self._rm_tree(self._base_dir)


class ClassicalPMFetcher(PMFetcher):
    def __init__(self, s1_ip, site_name, basedir='', logdir='') -> None:
        super().__init__()
        self._ip = s1_ip
        self._logdir = logdir
        self._username = 'toor4nsn'
        self._password = 'oZPS0POrRieRtu'
        self.site_name = site_name
        self._base_dir = basedir
        self._workspace = '/ram/'
        self._identity = f"{self.site_name}_{self._ip}"
        if self._base_dir:
            self._rm_tree(self._base_dir)
            self._set_logger()

    def get_version(self):
        cmd = f"find /ffs/run/ -name 'TargetBD_*.xml'"
        _, result = self.perform_cmd(cmd)
        if result:
            found = re.search(r'TargetBD_([\w]+)', result.decode().strip())
            if found:
                return found.group(1)

    def _compress_pm_file(self, pm_tar_gz):
        rm_cmd = f"rm -rf {pm_tar_gz} "
        _, result = self.perform_cmd(rm_cmd)
        self._logger.debug(rm_cmd)
        self._logger.debug(result.decode().strip())

        tar_cmd = f"cd {self._workspace} && tar zcf {pm_tar_gz} -C {self._workspace} PM*.xml.gz"
        self._logger.info(tar_cmd)
        err, result = self.perform_cmd(tar_cmd)
        if err:
            raise Exception(err.decode().strip())
        # self._execute_shell_cmd(tar_cmd)
        # self._execute_shell_cmd('exit')

    def _process(self):
        unzip_cmd = f"gunzip {self._base_dir}/*.gz"
        self._logger.info(str(unzip_cmd))
        os.system(unzip_cmd)

    def fetch(self):
        pm_tar_gz = '/tmp/pm.tar.gz'
        self._master_connect()
        try:
            self._compress_pm_file(pm_tar_gz)
            self._download_file_to_local(pm_tar_gz, self._base_dir)
            self._extract_pm_file(self._base_dir, os.path.basename(pm_tar_gz))
        except Exception as e:
            print(e)
        self._master_close()
        self._process()
        return [x for x in os.listdir(self._base_dir) if x.endswith('.xml')]

    def _extract_pm_file(self, local_path, file_name):
        file_path = os.path.join(local_path, file_name)
        cmd = f"tar zxf {file_path} -C {local_path} && rm -f {file_path}"
        self._logger.info(str(cmd))
        output = os.system(cmd)


class AICPMFetcher(PMFetcher):
    def __init__(self, ne, ip, username, password, namespace, basedir='', logdir='',
                 pod_name="pm", container_name="pmcore"):
        super().__init__()
        self._ip = ip
        self._logdir = logdir
        self._username = username
        self._password = password
        self.namespace = namespace
        self.full_pod_name = f"po-{namespace}-{pod_name}-0"
        self.full_container_name = f"ctr-{namespace}-{container_name}"
        self.tmp_log_dir = "/tmp/"
        self._workspace = '/var/opt/nokia/performancemanagement/storage/results/'
        self.ne = ne
        self._base_dir = basedir
        self._identity = f"{self._ip}_{self.ne}"
        if self._base_dir:
            self._set_logger()

    def get_pod_name_prefix(self):
        cmd = f"kubectl -n {self.namespace} get pod | grep {self.namespace} | awk '{{print $1}}'| head -n 1"
        pod_name = self._execute_shell_cmd(cmd).strip()
        if len(pod_name) == 0:
            raise ValueError("The pod_name is empty.")
        else:
            logging.info(f"The pod_name is {pod_name}")
        pod_prefix = pod_name.split(self.namespace)[0]
        self.full_pod_name = self.full_pod_name.replace("po-", pod_prefix)
        return pod_prefix

    def _compress_pm_file(self, pm_tar_gz):

        enter_container_cmd = f'kubectl exec -it {self.full_pod_name} -c " + \
            f"{self.full_container_name} -n {self.namespace} -- bash'
        self._logger.info(enter_container_cmd)
        self._execute_shell_cmd(enter_container_cmd)
        rm_cmd = f"rm -rf {os.path.join(self._workspace, pm_tar_gz)} "
        self._logger.info(rm_cmd)
        tar_cmd = f"cd {self._workspace} && tar cf {pm_tar_gz} -C {self._workspace} *.xml.gz"
        self._logger.info(tar_cmd)
        self._execute_shell_cmd(rm_cmd)
        self._execute_shell_cmd(tar_cmd)
        self._execute_shell_cmd('exit')

    def _download_file_to_master(self, filename):
        rm_cmd = f"rm -f {os.path.join(self.tmp_log_dir, filename)}"
        cp_cmd = f"kubectl exec {self.full_pod_name} -c {self.full_container_name} -n {self.namespace} -- cat " + \
            f"{os.path.join(self._workspace, filename)} > { os.path.join(self.tmp_log_dir, filename)}"
        self._logger.info(cp_cmd)
        self.perform_cmd(rm_cmd)
        self.perform_cmd(cp_cmd)

    def _download_file(self, filename):
        self._download_file_to_master(filename)
        self._download_file_to_local(os.path.join(self.tmp_log_dir, filename),
                                     local_path=os.path.join(self._base_dir, self.ne + '_pm/'))

    def fetch(self):
        pm_path = os.path.join(self._base_dir, self.ne + '_pm')
        pm_tar_gz = f'{self._username}_pm.tar'
        self._master_connect()
        self._rm_tree(pm_path)
        self.get_pod_name_prefix()
        # self._download_file('resultMapping.json')
        self._compress_pm_file(pm_tar_gz)
        self._download_file(pm_tar_gz)
        self._master_close()
        self._extract_pm_file(pm_path, pm_tar_gz)

    def _extract_pm_file(self, local_path, file_name):
        file_path = os.path.join(local_path, file_name)
        cmd = f"tar xf {file_path} -C {local_path} && rm -f {file_path}"
        self._logger.info(str(cmd))
        os.system(cmd)

    def alive(self):
        try:
            return True, self.get_version()
        except Exception as e:
            return False, str(e)

    def get_version(self):
        get_version_cmd = f"helm list -n {self.namespace} | awk  '/aic-v.u/{{print $9}}' | head -1"
        err, result = self.perform_cmd(get_version_cmd)
        version = result.decode()
        if version.startswith('aic'):
            return version.strip().replace('.', '_').replace('-', '_')
        else:
            return 'unknown'

    def list_all_files(self, files_path):
        return os.listdir(files_path)

    def list_all_files_with_path(self, files_path):
        files_list = []
        list_file = os.listdir(files_path)
        self._logger.info(list_file)
        for i in range(0, len(list_file)):
            path = os.path.join(files_path, list_file[i])
            if os.path.isdir(path):
                files_list.extend(self.list_all_files(path))
            if os.path.isfile(path) and "xml" in list_file[i]:
                files_list.append(path)
        return files_list


if __name__ == '__main__':
    kwargs = {"s1_ip": "10.69.70.44",
              "site_name": "BTS-1466",
              "mode": "AIC",
              "site_pool_id": "1xxxxx11"}
    s = ClassicalPMFetcher(kwargs.get('s1_ip'),
                           kwargs.get('site_name')).fetch()
