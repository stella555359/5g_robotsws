# -*- coding: utf-8 -*-
"""
Author: Yang Mengli, Liu Renhui
Contacts: mengli.yang@nokia-sbell.com, renhui-david.liu@nokia-sbell.com
Description: this script is used for collect and analysis bip log
with check status of all pods

"""

import re
import logging
import yaml
import os
import sys
import paramiko
import csv
import glob
import time
from taf.transport.ssh import ssh
from SSHLibrary import SSHLibrary
from basic import basic

ssh = ssh()
sshlib = SSHLibrary()


class collect_and_analysis_tti_log():
    def __init__(self, vdu_hostname="10.56.104.206", vdu_username="core", vdu_password="system123",
                 namespace="cran1", pod_name="up", vdu_version="0.300.3176", container_name="l2rt"):
        self.vdu_hostname = vdu_hostname
        self.vdu_username = vdu_username
        self.vdu_password = vdu_password
        self.namespace = namespace
        self.pod_name = pod_name
        self.vdu_version = vdu_version
        self.container_name = container_name

    def ttilog(self):
        conn = basic.master_connect(hostname=self.vdu_hostname, username=self.vdu_username, password=self.vdu_password,
                                    alias="vdu_master")
        vm_conn = basic.vm_connect(hostname="10.108.229.190", username="ute", password="ute", alias="VM")
        full_pod_name = "po-" + namespace + "-" + pod_name + "-0"
        full_container_name = "ctr-" + namespace + "-" + container_name
        self.start_tti_trace(master_ip=self.vdu_hostname, username=self.vdu_username, password=self.vdu_password,
                             pod_name=full_pod_name,
                             namespace=self.namespace, container_name=full_container_name, conn=conn)
        time.sleep(5)
        self.stop_decode_tti_log(conn=conn, vdu_version=self.vdu_version, pod_name=self.pod_name,
                                 container_name=self.container_name)

    def start_tti_log(self, vdu_hostname, vdu_username, vdu_password, namespace, conn):
        full_pod_name = "po-" + namespace + "-" + pod_name + "-0"
        full_container_name = "ctr-" + namespace + "-" + container_name
        self.start_tti_trace(master_ip=vdu_hostname, username=vdu_username, password=vdu_password,
                             pod_name=full_pod_name,
                             namespace=namespace, container_name=full_container_name, conn=conn)

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

    def download_tti_file_to_vm(self, conn, remote_path='/tmp/tti/tti.tar', local_path='/home/ute/tti/tti.tar'):
        tar_cmd = "cd /tmp/tti/ && tar cvf tti.tar /tmp/tti/"
        ssh.send_command(tar_cmd, connection=conn, timeout=60)
        rm_cmd = "rm -rf /home/ute/tti/; mkdir -p /home/ute/tti/"
        ssh.send_command(rm_cmd, connection="VM", timeout=60)
        # make_path= "/home/ute/tti/"
        # if not os.path.exists(make_path):
        #     os.makedirs(make_path)
        ssh.download_file(remote_path=remote_path, local_path=local_path, connection=conn)

    def untar_tti_file(self, conn, path="/home/ute/tti/"):
        tti_file_path = os.path.join(path, "tmp/tti/")
        untar_cmd = "cd " + path + " && tar xvf tti.tar"
        ssh.send_command(untar_cmd, connection=conn, timeout=60)
        list_file_names = self.get_file_names_under_directory(directory=tti_file_path, connection=conn)
        print(list_file_names)
        for file_name in list_file_names:
            untar_tti_cmd = "cd " + tti_file_path + " && tar zxvf " + file_name + "&& rm -rf " + file_name
            print(untar_tti_cmd)
            ssh.send_command(untar_tti_cmd, connection=conn, timeout=60)
        return tti_file_path

    def start_tti_trace(self, master_ip, username, password, pod_name, namespace, container_name, conn, ):
        """
        Description: Start TTI trace log capturing on vdu,
        :param pod_name: define pod name
        :return: no return for this method
        """
        self.connect_to_container(master_ip, username, password, pod_name, container_name, namespace)
        rm_cmd = " rm -rf /var/eventsTrace/*"
        self.execute_command_in_container(cmd=rm_cmd)
        start_tti_cmd = "nohup bash /opt/nokia/tools/ttiTrace/eventsCollect.sh > /tmp/tti_logs 2>&1 &  bash"
        output = self.execute_command_in_container(cmd=start_tti_cmd)
        print(output)
        logging.debug("Start TTI trace command: {}".format(start_tti_cmd))
        time.sleep(0.1)
        if self.check_process_exist(conn=conn):
            logging.info(
                "Started TTI trace log capturing successfully")
        else:
            raise Exception("Fail to start TTI trace, process is not found")

    def check_process_exist(self, conn, process_name="eventsCollect.sh"):
        cmd_check_process = "ps -ef | grep -v 'grep'|grep '{}'".format(process_name)
        logging.debug("Execute command: {}".format(cmd_check_process))
        output_check_process = ssh.execute(
            command=cmd_check_process,
            connection=conn).strip()
        logging.info("Output for checking process: {}".format(output_check_process))
        if len(output_check_process) > 0:
            return True
        else:
            return False

    def stop_tti_trace(self, conn, timeout="60"):
        """
        Description: kill the TTI trace process
        :return: No return for this keyword
        """
        kill_cmd = "sudo pkill -f tti"
        logging.info(
            "sudo pkill -f tti")
        ssh.send_command(kill_cmd, connection=conn, timeout=timeout)
        process_cmd = "ps -ef | grep tti"
        logging.info(
            "ps -ef | grep tti")
        ssh.send_command(process_cmd, connection=conn, timeout=timeout)
        ls_cmd = "cd /var/eventsTrace; ls"
        ttiTrace_files_list = self.execute_command_in_container(cmd=ls_cmd)
        return ttiTrace_files_list

    def download_tti_log_to_master(self, pod_name, namespace, container_name, tmp_log_dir, conn=None, timeout="60"):
        """
            *Args:*
                - namespace: the tenant namespace which pod created in
                - pod_name: see `collect log in which pod `
                - container_name: see `collect log in which container `

            *Command:* `` kubectl cp -n cran1 po-cran1-up-0:/var/eventsTrace /tmp/tti/eventsTrace -c ctr-cran1-l2rt'``

            *Returns:*
                - remote_log_dir

            *Example:*
            | ${pod_name_list} | get_vdu_pods_name_list | cran1
            """

        pod_prefix = "po-" + namespace
        container_prefix = "ctr-" + namespace
        tmp_log_dir = tmp_log_dir.rstrip("/") + "/"
        mkdir_cmd = "rm -rf " + tmp_log_dir + "; mkdir -p " + tmp_log_dir
        print(mkdir_cmd)
        output = ssh.send_command(mkdir_cmd, connection=conn, timeout=timeout)
        print(output)
        copy_cmd = (
                "kubectl cp " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
                ":/var/eventsTrace" + " " + tmp_log_dir + " -c " + container_prefix + "-" + container_name)
        print(copy_cmd)
        output = ssh.send_command(copy_cmd, connection=conn, timeout=timeout)
        time.sleep(2)
        print(output)
        remote_log_dir = tmp_log_dir
        return remote_log_dir

    def decode_tti(self, vdu_version, tti_trace_dir, tti_archive, is_combine_dl_ul, conn,
                   tool_name_postfix="_tti-dec.deb", timeout="60"):
        """
        Description: decode tti log
        :return: tti_csv_file_paths
        """
        tti_trace_dir = tti_trace_dir.rstrip("/") + "/"
        tmp_tti_path = "/home/ute/tmp_tti_deb"
        tti_dec_path = "/opt/tti-dec"
        url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/" \
              "mnp5g-central-public-local/System_Release/"
        version = vdu_version.split('_')[0]
        pkg_name = vdu_version + tool_name_postfix
        pkg_url = os.path.join(url, version, vdu_version, pkg_name)

        install_pkg_cmd = "if [ ! -d {} ]; then mkdir -p {}; fi; " \
                          "if [ ! -d {} ]; then cd {}; wget {}; " \
                          "sudo apt install ./{}; fi; " \
                          "sudo chmod +x {}/tti-dec-bin/TtiTraceDecoder.py;".format(tmp_tti_path, tmp_tti_path,
                                                                                    tti_dec_path, tmp_tti_path,
                                                                                    pkg_url, pkg_name,
                                                                                    tti_dec_path)
        print("install_pkg_cmd:", install_pkg_cmd)
        output = ssh.execute(command=install_pkg_cmd, connection=conn).strip()
        print("The result of install_pkg_cmd command:", output)

        decoded_log_dir = os.path.join(tti_trace_dir, "decoded_log")
        tti_file_paths = self.extract_log_from_zip_file(tti_archive, tti_trace_dir, postfix='.pcap')
        tti_csv_file_paths = []
        for tti_file_path in tti_file_paths:
            tti_basename = os.path.basename(tti_file_path)
            tti_filename = os.path.splitext(tti_basename)[0]
            decoder_cmd = "if [ ! -d {} ]; then mkdir -p {}; fi; " \
                          "source {}/venv/bin/activate; cd {}; " \
                          "python3 {}/tti-dec-bin/TtiTraceDecoder.py {} excelCsv --timeout 10000" \
                          " -o {}".format(decoded_log_dir, decoded_log_dir, tti_dec_path,
                                          decoded_log_dir, tti_dec_path, tti_file_path, tti_filename)
            if is_combine_dl_ul:
                decoder_cmd = decoder_cmd + " --combineDlAndUl; deactivate;"
            print("decoder_cmd:", decoder_cmd)
            output = ssh.execute(command=decoder_cmd, connection=conn).strip()
            print("The result of decoding tti log:\n", output)
            get_csv_filename_cmd = "find {} -maxdepth 1 -type f -name '*.csv'".format(decoded_log_dir)
            ssh.send_command(get_csv_filename_cmd, connection=conn, timeout=60)
            lines = ssh.read_output(connection=conn)
            file_paths = lines.strip().splitlines()
            tti_csv_file_paths.extend(file_paths)
        return list(set(tti_csv_file_paths))

    def download_decode_tool(self, vdu_version, tti_trace_dir, conn, tool_name_postfix="_tti-dec.deb", timeout="60"):
        """
        Description: download decode tool to decode tti log
        :return: No return for this keyword
        """
        rm_tmp = "cd " + tti_trace_dir + "; rm -rf *qemux86-64-static.txz; rm -rf tti-dec-bin"
        print(rm_tmp)
        ssh.execute(command=rm_tmp,
                    connection=conn).strip()
        tool_url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/" \
                   "mnp5g-central-public-local/System_Release/"
        version = vdu_version.split('_')[0]
        # decoder_tool_name = vdu_version + "_tti-dec_qemux86-64-static.txz"
        decoder_tool_name = vdu_version + tool_name_postfix
        decoder_tool_url = os.path.join(tool_url, version, vdu_version, decoder_tool_name)
        process_cmd = "wget --no-check-certificate " + decoder_tool_url + " -P " + tti_trace_dir
        output = ssh.execute(command=process_cmd, connection=conn).strip()
        print("The result of downloading decode tool:", output)
        return tti_trace_dir

    def decode_tti_tool(self, vdu_version, tti_trace_dir, tti_archive, is_combine_dl_ul, conn, timeout="60"):
        """
        Description: download decode tool to decode tti log
        :return: No return for this keyword
        """
        tti_trace_dir = tti_trace_dir.rstrip("/") + "/"
        decoder_tool_name = vdu_version + "_tti-dec_qemux86-64-static.txz"
        tar_cmd = "cd " + tti_trace_dir + " && tar -xJvf " + decoder_tool_name
        print(tar_cmd)
        logging.info("tar -xJvf " + tti_trace_dir + decoder_tool_name)
        output = ssh.execute(command=tar_cmd, connection=conn).strip()
        print("The result of tar command:", output)
        tti_bins_dir = os.path.join(tti_trace_dir, "tti-dec-bin")
        tti_file_paths = self.extract_log_from_zip_file(tti_archive, tti_trace_dir, postfix='.pcap')
        tti_csv_file_paths = []
        for tti_file_path in tti_file_paths:
            tti_basename = os.path.basename(tti_file_path)
            tti_filename = os.path.splitext(tti_basename)[0]
            decoder_cmd = "rm -rf /home/ute/tti_decode_env; virtualenv --python=python3 /home/ute/tti_decode_env; " \
                          "source /home/ute/tti_decode_env/bin/activate; " \
                          "echo yes | pip install -U numpy; echo yes | pip install -U pandas; pip list;" \
                          "cd {}; python3 TtiTraceDecoder.py {} excelCsv --timeout 10000 " \
                          "-o {}".format(tti_bins_dir, tti_file_path, tti_filename)
            if is_combine_dl_ul:
                decoder_cmd = decoder_cmd + " --combineDlAndUl"
            print(decoder_cmd)
            output = ssh.execute(command=decoder_cmd, connection=conn).strip()
            print("The result of decoding tti log:\n", output)
            get_csv_filename_cmd = "find {} -maxdepth 1 -type f -name '*.csv'".format(tti_bins_dir)
            ssh.send_command(get_csv_filename_cmd, connection=conn, timeout=60)
            lines = ssh.read_output(connection=conn)
            file_paths = lines.strip().splitlines()
            tti_csv_file_paths.extend(file_paths)
        return list(set(tti_csv_file_paths))

    def extract_log_from_zip_file(self, archive, directory, postfix='.pcap', substring=None):
        """
        Description: Get all required files from a zip file
        :param archive: a zip file
        :param directory: the directory to unzip file to
        :param postfix: the log filenames' postfix
        :param substring: require the log filename contains this substring
        :return: Return a list which includes all tti filenames with the postfix '.pcap'
        """
        import zipfile
        tti_file_paths = []

        if not postfix and not substring:
            return tti_file_paths

        with zipfile.ZipFile(archive, 'r') as zip_file:
            if postfix and substring:
                tti_file_paths = [zip_file.extract(file, directory)
                                  for file in zip_file.namelist() if file.endswith(postfix) and substring in file]
            elif postfix:
                tti_file_paths = [zip_file.extract(file, directory)
                                  for file in zip_file.namelist() if file.endswith(postfix)]
            else:
                tti_file_paths = [zip_file.extract(file, directory)
                                  for file in zip_file.namelist() if substring in file]

        return tti_file_paths

    def extract_log_from_nested_zip_file(self, archive, directory, filters):
        """
        Description: Get all required files from a nested zip file
        :param archive: a zip file
        :param directory: the directory to unzip file to
        :param filters: a list, such as [{postfix=x, substring=x}, {postfix=xx, substring=xx}]

        :return: Return a list which includes all the required filenames
        """
        archives = [archive]
        log_file_paths = []
        for filter in filters:
            log_file_paths = []
            for arc in archives:
                tmp = self.extract_log_from_zip_file(arc, directory,
                                                     postfix=filter["postfix"], substring=filter["substring"])
                log_file_paths.extend(tmp)
            archives = log_file_paths
        return log_file_paths

    def get_file_names_under_directory(self, directory, connection, file_indicator='*'):
        """
        Description: Get all file names from an existing directory
        :param directory: folder path, example input can be: /XXX/XXX
        :param file_indicator: regular expression to identify the files. Default to list all files.
                               Example input: 5GTtiTrace.bin.[0-9]*{}.csv
        :param connection:
        :return: Return a list which includes all file names
        """
        cmd_list_file_name = "cd {};ls {}".format(directory, file_indicator)
        output = ssh.execute(cmd_list_file_name, connection=connection).strip()
        logging.debug("cmd:{}, output:{}".format(cmd_list_file_name, output))
        list_file_names = []
        if output.find('No such file or directory') == -1:
            list_file_names = output.split()
        else:
            logging.info("No file found under folder {}".format(directory))
        return list_file_names

    def combine_csv_files_to_one(self, csv_log_path, direction, connection):
        """
        Description: 1. Get the csv files with name sorted
                     2. Combine CSV files one by one based on file name sequence
                     3. Combined csv log name will share the same timestamp with the csv_log_path
        :param csv_log_path: log path for storing the converted csv files
        :param direction: value can only be ul or dl. Case is sensitive
        :param connection: connection alias for ABIL master
        :return: will return the file path for the combined csv file.
                 Example output: /XXX/XXX/TA_Combine_ul_Full_20190225084328.csv
                            or   /XXX/XXX/TA_Combine_dl_Full_20190225084328.csv
        """
        list_csv_file_names = self._get_sorted_csv_file_names(
            csv_log_path=csv_log_path, direction=direction, connection=connection)
        logging.debug("sorted csv file names:{}".format(list_csv_file_names))
        timestamp = csv_log_path.split('_')[-1]
        csv_file_name_full = "TA_Combine_{}_Full_{}.csv".format(
            direction, timestamp)
        csv_file_path_full = "{}/{}".format(csv_log_path, csv_file_name_full)

        logging.info("Start to combine csv contents")
        for csv_file_name in list_csv_file_names:
            cmd_add_csv_content = "cd {};cat {} >>{}".format(
                csv_log_path, csv_file_name, csv_file_path_full)
            output_add_csv_content = ssh.execute(
                command=cmd_add_csv_content, connection=connection).strip()
            if len(output_add_csv_content) != 0:
                raise Exception(
                    "Combine csv file for {} failed. Output message is {}".format(
                        csv_file_name, output_add_csv_content))
            else:
                logging.info("Combine csv file {} to {} successfully".format(csv_file_name, csv_file_name_full))
                continue
        logging.info(
            "All CSV files have been combined. File path after combine is ")
        return csv_file_path_full

    def _get_sorted_csv_file_names(self, csv_log_path, direction, connection):
        """
        Description: Get csv file names with name sorted by log id
        :param csv_log_path: log path for storing the converted csv files
        :param direction: value can only be ul or dl. Case is sensitive
        :param connection: connection alias for ABIL master
        :return: return a list for csv names
        """
        list_csv_file_name = self.get_file_names_under_directory(
            directory=csv_log_path,
            file_indicator='*L2TtiTrace_EventsSnapshot.bin.[0-9]*{}.csv'.format(direction),
            connection=connection)
        if len(list_csv_file_name) != 0:
            dict_csv_file_names = {}
            for csv_log_name in list_csv_file_name:
                log_index = int(re.findall(r'EventsSnapshot.bin.([\d]*).', csv_log_name)[0])
                logging.debug("log_index:{}".format(log_index))
                dict_csv_file_names[log_index] = csv_log_name
            list_sorted_csv_file_names = self._get_dict_value_sorted_by_key(
                dict_csv_file_names)
            return list_sorted_csv_file_names
        else:
            raise Exception(
                "There is no csv log found with {} direction under {}".format(
                    direction, csv_log_path))

    def _get_dict_value_sorted_by_key(self, input_dict):
        """
        Description: Sort a dictionary by key
        :param input_dict:
        :return: Return a list with dict values
        """
        dict_keys = sorted(input_dict.keys())
        list_dict_value = []
        for dict_key in dict_keys:
            list_dict_value.append(input_dict[dict_key])
        return list_dict_value

    def stop_decode_tti_log(self, conn="vdu_master", vdu_version="0.300.3176", pod_name="up", container_name="l2rt",
                            tmp_log_dir="/tmp/tti/",
                            tti_trace_dir="/home/ute/"):
        self.stop_tti_trace(conn=conn)
        self.download_tti_log_to_master(pod_name=pod_name, namespace="cran1", container_name=container_name,
                                        tmp_log_dir=tmp_log_dir, conn=conn)
        tti_trace_dir = self.download_decode_tool(vdu_version=vdu_version, tti_trace_dir=tti_trace_dir, conn="VM")
        self.download_tti_file_to_vm(conn="vdu_master")
        tti_file_path = self.untar_tti_file(conn="VM")
        # tti_file_path= "/home/ute/tti/tmp/tti/"
        self.decode_tti_tool(vdu_version=vdu_version, tti_trace_dir=tti_trace_dir, conn="VM",
                             bin_file_path=tti_file_path)
        basic.master_close(alias="vdu_master")
        basic.vm_close(alias="VM")
