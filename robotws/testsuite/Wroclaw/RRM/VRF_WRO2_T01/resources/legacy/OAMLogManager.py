import paramiko
import socket
import os
import shutil
from datetime import datetime


class OAMLogManager:
    def __init__(self):
        self.local_logs_path = None
        self.remote_logs_path = "/var/www/html/storage/{}/".format(self._get_hostname())
        self.remote_server = {
            'hostname': '10.42.53.241',
            'username': 'ute',
            'password': 'Ut3pa5s#1be1'
        }
        self.zipped_logs_root_path = "/home/ute"
        self.local_zipped_file_name = None

    def __set_zip_file_name(self):
        raw_file_name = "{}__{}".format(self._get_hostname(), str(datetime.now()).replace(" ", "__").replace(":", "_").
                                        replace("-", "_"))
        self.local_zipped_file_name = raw_file_name + '.zip'
        raw_file_name_with_path = os.path.join(self.zipped_logs_root_path, raw_file_name)
        self.local_logs_path = raw_file_name_with_path + '.zip'
        return raw_file_name_with_path

    def zip_files(self, logs_dir_to_zip):
        root, base = os.path.split(logs_dir_to_zip)
        shutil.make_archive(self.__set_zip_file_name(), format="zip", root_dir=root, base_dir=base)

    @staticmethod
    def _get_hostname():
        return socket.gethostname().replace('-', '_')

    def send_logs_to_remote_server(self):
        s = paramiko.SSHClient()
        s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        s.connect(hostname=self.remote_server['hostname'], port=22, username=self.remote_server['username'],
                  password=self.remote_server['password'], timeout=4)

        sftp = s.open_sftp()
        try:
            sftp.chdir(self.remote_logs_path)
        except IOError:
            sftp.mkdir(self.remote_logs_path)
            sftp.chdir(self.remote_logs_path)
        finally:
            sftp.put(self.local_logs_path, self.remote_logs_path + self.local_zipped_file_name)
            sftp.close()
        return "http://{}/storage/{}/{}".format(self.remote_server['hostname'], self._get_hostname(),
                                                self.local_zipped_file_name)
