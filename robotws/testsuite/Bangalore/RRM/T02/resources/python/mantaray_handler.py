# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Arunkumar A
:contact: arunkumar.a@nokia.com
"""
import paramiko
import os
import logging
import subprocess
import time
import socket
from taf.transport.ssh import ssh as taf_ssh  # type: ignore
# try:
#    import taf.internal.node
# except ImportError:
#    os.system("pip install taf.internal.node")


class mantaray_handler(object):
    '''
    Mantaray Handler contains airscale, Flexi build download from user given artifactory.
    uploading the downloaded build into Mantaray node (depends on node ip, username, password)
    from the node the build is pushing to Mantaray server.
    :param - nodeIP
    :param - username
    :param - password
    :param - commands
    '''
    def __init__(self):
        self.log_file_name = "mantaray_code_output.log"
        self.username = "test2"
        self.password = "Qwer_1234"
        self.end_file_string = "_release_BTSSM_downloadable_A54.zip"
        # self.hostname="10.43.48.16"
        logging.basicConfig(filename=self.log_file_name,
                            filemode="a",
                            format="[%(asctime)s] - [%(levelname)s] : %(message)s")
        logger = logging.getLogger("Mantaray")
        logger.setLevel(logging.DEBUG)
        self.logger = logger

    def ssh_connection(self, remote_ip=None):
        '''
        Create connection via ssh from paramiko
        '''
        try:
            if remote_ip is not None:
                self.logger.info(f"User remote ip: {remote_ip}")
                ssh = paramiko.SSHClient()
                ssh.load_host_keys(os.path.expanduser(os.path.join("~", ".ssh", "known_hosts")))
                ssh.connect(hostname=remote_ip, username=self.username, password=self.password)
                self.logger.info(f"""SSH connection estabilished. hostname:{remote_ip},
                                 username:{self.username}, password:{self.password}""")
                self.ssh = ssh
                return True
        except ConnectionRefusedError as err:
            self.logger.error(f"ssh connection is failed.\nREASON:<{err}>")
        except Exception as err:
            self.logger.error(f"ssh connection is failed.\nREASON:<{err}>")
        return self.ssh

    def ssh_connection_close(self):
        '''
        tear down of connection to be close
        '''
        try:
            self.ssh.close()
        except Exception as err:
            self.logger.error(f"Connection close function failed.\nREASON <{err}>")

    def sftp_connection(self):
        '''Estabilish sftp connection'''
        raise NotImplementedError

    def sftp_file_transfer(self, local_swpath=None, server_swpath=None):
        '''
        method does file transfer via sftp protocol
        '''
        def file_transfer_status(start, pending):
            print(f"File transfering from {start} -- {pending}")
        try:
            if local_swpath and server_swpath is not None:
                sftp = self.ssh.open_sftp()
                print(f"Opened sftp from ssh : {sftp}")
                self.logger.info(f"Sftp connection estabilished: details: {sftp}")
                file_name = str(local_swpath + self.sw_file_name).encode('utf-8')
                print(f"sftp file local path: {file_name}")
                server_path = str(server_swpath + self.sw_file_name).encode('utf-8')
                z = sftp.put(localpath=bytes(file_name), remotepath=bytes(server_path), confirm=True)
                print(f"put file details\n{z}")
                self.logger.info(f"file transfer happens between local path:{local_swpath}",
                                 f"remote path:{server_swpath}")
        except FileNotFoundError as err:
            self.logger.error(f"File paths are not found.\nFile Path not exist {local_swpath}",
                              f"{server_swpath}\nREASON: <{err}>")
            raise err("File paths are not found.")
        finally:
            sftp.close()
            self.logger.info("Sftp Connection is closed.")

    def get_hostname_from_machine(self):
        '''get hostname from linux mechine and convert into required format'''
        hostname = socket.gethostname()
        self.logger.info(f"Linux Mechine Host name: {hostname}")
        print(f"hostname: {hostname}")
        str_hyphen = '-'
        str_underscore = '_'
        testline_name = ""
        for i in str(hostname):
            if i == str_hyphen:
                testline_name += str_underscore
            else:
                testline_name += i
        return testline_name

    def file_transfer_to_remote_machine_via_scp(self):
        '''
        create scp connection along with ssh
        '''
        raise NotImplementedError

    def single_thread_function_for_file_transfer(self, remote_ip=None, local_swpath=None, server_swpath=None):
        '''
        single connection of sftp
        '''
        estabilish_connection = self.ssh_connection(remote_ip)
        if estabilish_connection:
            sftp_connection = self.sftp_file_transfer(local_swpath, server_swpath)
        teardown_connection = self.ssh_connection_close()
        return True

    def file_transfer_via_sftp_test(self, remote_ip=None, local_swpath=None, server_swpath=None):
        '''
        File transfer from client to server
        '''
        try:
            if remote_ip is not None:
                self.logger.info(f"User remote ip: {remote_ip}")
                ssh = paramiko.SSHClient()
                ssh.load_host_keys(os.path.expanduser(os.path.join("~", ".ssh", "known_hosts")))
                ssh.connect(hostname=remote_ip, username=self.username, password=self.password)
                self.logger.info(f"SSH connection estabilished. hostname:{remote_ip}, username:{self.username}",
                                 f"password:{self.password}")
            try:
                if local_swpath and server_swpath is not None:
                    sftp = ssh.open_sftp()
                    self.logger.info(f"Sftp connection estabilished: details: {sftp}")
                    sftp.put(localpath=local_swpath, remotepath=server_swpath)
                    self.logger.info(f"file transfer happens between local path:{local_swpath}",
                                     f"remote path:{server_swpath}")
            except FileNotFoundError as err:
                self.logger.error("local or remote file not found.\nREASON:<{err}>")
                raise err("local_swpath or server_swpath not found.")
            finally:
                sftp.close()
                self.logger.info("Sftp Connection closed successfully.!")
        except paramiko.ConfigParseError as err:
            self.logger.error("ssh configuration error")
            raise err("Found configuration error.!")
        finally:
            ssh.close()
            self.logger.info("ssh Connection closed successfully.!")

    def verify_swbuild_availability_in_remote_machine(self, remote_ip=None, server_swpath=None, target_builds=[]):
        '''
        Validate file present in netact server or not.!
        '''
        estabilish_connection = self.ssh_connection(remote_ip)
        try:
            if estabilish_connection:
                # os.chdir(server_swpath)
                # print(f"server path file status {server_swpath}")
                for target_build in target_builds:
                    print(f"target build : {target_build}")
                    file_name = str(server_swpath + target_build + self.end_file_string).encode('utf-8')
                    print(f"file name: {file_name}")
                    return True
            else:
                return False
        except AssertionError as err:
            self.logger.error(f"Validation failed.! SW build package not present in netact server\nREASON: <{err}>")
        finally:
            self.ssh_connection_close()

    def verify_swbuild_available_in_host_machine(self, local_dir, target_swbuilds):
        '''
        Check the sw build available in host machine
        '''
        try:
            for build in range(len(target_swbuilds)):
                print(f"verify {__name__}: {target_swbuilds}")
                print(f"verifiy {__name__}: {target_swbuilds[build]}")
                sw_file_path_name = local_dir + "/" + str(target_swbuilds[build]) + self.end_file_string
                self.sw_file_name = str(target_swbuilds[build]) + self.end_file_string
                print(f"verify: {self.sw_file_name}")
                if os.path.isfile(sw_file_path_name):
                    return True
                else:
                    return False
        except FileNotFoundError as err:
            self.logger.error("find file operation failed.\nREASON <{err}>")
            raise err("Finding file operation failed")

    def select_kw_build_download_liner_search(self, artifacory_base_url, target_sws):
        '''
        download link provider
        '''
        for target_sw in range(len(target_sws)):
            convert_str = str(target_sw)
            try:
                if "FSM3" in convert_str:
                    downloaded_link = self.create_swbuild_download_link_Flexi(artifacory_base_url, target_sw)
                elif "FSM3" not in convert_str:
                    downloaded_link = self.create_swbuild_download_link_airscale(artifacory_base_url, target_sw)
            except Exception as err:
                raise err("Given target sw is not part of airscale or FSMF")
            return downloaded_link

    def sbts_sw_build(self, artifacory_base_url, target_sws):
        '''
        dicission maker for airscale or flexi
        '''
        for target_sw in target_sws:
            print(f"sbts_sw_build: {target_sw}")
            if "FSM3" in target_sw:
                downloaded_link = self.create_swbuild_download_link_Flexi(artifacory_base_url, target_sw)
                print(f"it is fsmf build: {downloaded_link}")
            elif "FSM3" not in target_sw:
                downloaded_link = self.create_swbuild_download_link_airscale(artifacory_base_url, target_sw)
                print(f"it is airscal build: {downloaded_link}")
            else:
                raise ("Given target sw is not part of airscale or FSMF")
        return downloaded_link

    def create_swbuild_download_link_Flexi(self, artifacory_base_url, targetbuild):
        """
        method create link for download Flexi build
        :reference: SBTS00_FSM3_9999_240712_000002
        """
        if targetbuild:
            sw_file_name = targetbuild + self.end_file_string
            splited_target_build = targetbuild.split("_")
            fsmf_build_name = str(splited_target_build[0]+"_"+splited_target_build[1])
            create_url = str(artifacory_base_url + fsmf_build_name + "/" + targetbuild + "/" + sw_file_name)
            return create_url

    def create_swbuild_download_link_airscale(self, artifacory_base_url, targetbuild):
        '''
        method create link for download airscale build
        '''
        print(f"target_builds: {targetbuild}")
        print(type(targetbuild))
        if targetbuild:
            print(f"target build: {targetbuild}")
            sw_file_name = targetbuild + self.end_file_string
            splited_target_build = targetbuild.split("_")
            print(f"target build splited{splited_target_build}")
            airscale_build_release = splited_target_build[0]
            print(f"Airscal build: {airscale_build_release}")
            create_url = str(artifacory_base_url + airscale_build_release + "/" + targetbuild + "/" + sw_file_name)
            print(f"Created link: {create_url}")
            return create_url

    def download_sbts_builds_and_save_in_target_path(self, artifactory_url, local_dir, target_swpath=[]):
        '''
        Downloading sbts builds in user given path
        '''
        print(f"{__name__} target build: {target_swpath}")
        try:
            status = self.verify_swbuild_available_in_host_machine(local_dir, target_swpath)
            if not status:
                get_download_link = self.sbts_sw_build(artifactory_url, target_swpath)
                splited_content_in_sw_link = str(get_download_link).split("/")
                sw_file_name = splited_content_in_sw_link[-1]
                self.sw_file_name = sw_file_name
                try:
                    os.system(f"cd")
                    print("Entered to cd")
                    time.sleep(2)
                    ch = os.chdir(local_dir)
                    print(f"target path: {local_dir}")
                    print(f"target path: {ch}")
                    print(f"url link: {get_download_link}")
                    stdout_ = os.getcwd()
                    print(f"current working directory: {stdout_}")
                    if str(stdout_ + "/") == local_dir:
                        return_status_dl = os.system(f"wget {get_download_link}")
                        print(f"build download status: {return_status_dl}")
                    else:
                        print("get link failed in folder")
                    return True
                except OSError as err:
                    raise err(f"Requested build Not able to downloaded. check aritfactory link: {artifactory_url}")
            elif status:
                self.logger.info(f"sw file is present in {local_dir}")
                print(f"software is available in {local_dir}. Download not required.")
                return True
            else:
                self.logger.error("Not able determin the file availablity")
                return False
        except OSError as err_1:
            self.logger.error(f"Download build failed via os.system command.!\nREASON: <{err_1}>")
            raise err_1("Download build failed via os.system command.!")

    def push_sw_form_netactVM_mantaray_server_old(self, remote_ip=None, target_builds=[]):
        '''
        1. pushing sw from netact vm to mantaray server.
        2. using command the method is performming.!
        '''
        cmd_cd = "cd /d/oss/global/swmanager/swm_temp/"
        base_cmd_push = "swmCLI.sh import --file "
        for target_build in target_builds:
            sw_file_name = str(target_build) + self.end_file_string + " --mo-type MRBTS " + target_build
            cmd_push = str(base_cmd_push + sw_file_name)
            try:
                if remote_ip is not None:
                    estabilish_connection = self.ssh_connection(remote_ip)
                    if estabilish_connection:
                        self.channel.exec_command(cmd_cd)
                        out = self.channel.recv(-1)
                        subprocess.run(str(cmd_cd))
                        print(f" push cmd :{cmd_push}")
                        subprocess.run(cmd_push)
                    self.ssh_connection_close()
            except Exception as err:
                self.logger.error(f"{__name__} got failed.!\nREASON: <{err}>")

    def push_sw_form_netactVM_mantaray_server_via_taf(self, remote_ip=None, cmd=None, target_builds=[]):
        '''
        using taf ssh connection
        '''
        cmd_cd = "cd /d/oss/global/swmanager/swm_temp/"
        base_cmd_push = "swmCLI.sh import --file "
        for target_build in target_builds:
            sw_file_name = str(target_build) + self.end_file_string + " --mo-type MRBTS " + target_build
            cmd_push = str(base_cmd_push + sw_file_name)
            self.logger.debug(f"command send: {cmd_push}")
            try:
                api = taf_ssh()
                connection = api.connect_to(remote_ip,
                                            username=self.username,
                                            password=self.password)
                self.logger.debug(f"Connection status: {connection}")
                print(f"Connection status: {connection}")
                if connection:
                    try:
                        change_dir = api.execute(command=cmd_cd)
                        print(f"Change dir {change_dir}")
                        output = api.execute(command=cmd_push)
                        print(f"command output: {output}")
                        if output:
                            print(f"Command executed successfully.\nOutput: {output}")
                    except Exception as err:
                        self.logger.error(f"Command Execution failed.\nREASON <{err}>")
                return True
            except Exception as err:
                self.logger.error(f"Send command using taf not working.!\nREASON <{err}>")
                raise err("Send command using taf not working.!")

    def delete_sw_package_from_vm(self):
        '''
        check the disk space --> need to implement
        Delete sw package under given path.
        retrun true.
        8 bit --> 1 bytes,
        when total size exceeds 10 GB then remove'''
        raise NotImplementedError
