import requests
import json
import subprocess
import os
from time import sleep
import time
import shutil
import paramiko
from scp import SCPClient
import sys
import textwrap
from requests.auth import HTTPBasicAuth


class Airphonesoftwareupgrade:
    def __init__(self):
        self.base_url = 'https://wft.int.net.nokia.com:8091/'
        self.build_url = self.base_url + 'TOOLS/api/v1/build.json'
        self.headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
        self.access_key = 'apJbdeEE72Bj6gkiqoTtFhvDokuehdk4NNCH8vsD'

    def get_latest_ap_load(self, project, state):
        payload = self.get_ap_payload(project, state)
        response_data = self.get_json_response(self.build_url, payload)
        return response_data['items'][-0]['version'].replace('airphone_', '')

    def get_test_result(self, project, state):
        output = []
        payload = self.get_ap_payload(project, state)
        response_data = self.get_json_response(self.build_url, payload)
        val = response_data['items'][-0]['test_results']
        for i in val:
            output.append(i['test_type'])
        return output

    def get_ap_payload(self, project, state):
        payload = {'sorting_field': 'planned_delivery_date', 'sorting_direction': 'DESC', 'group_by': '',
                   'group_by_processor': '', 'access_key': self.access_key,
                   'columns': {'0': {'id': 'state'}, '1': {'id': 'version'}, '2': {'id': 'test_results'}},
                   'view_filters_attributes': {'0': {'column': 'branch',
                                                     'operation': 'cont', 'value': project},
                                               '1': {'column': 'state', 'operation': 'eq_any',
                                                     'value': [state]},
                                               '2': {'column': 'version', 'operation': 'not_cont_any',
                                                     'value': ['airph_mzoam_l1r51_tdd_1.']},
                                               '3': {'column': 'version', 'operation': 'not_cont_any',
                                                     'value': ['airphone_1.']},
                                               '4': {'column': 'version', 'operation': 'not_cont_any',
                                                     'value': ['WTS']},
                                               '5': {'column': 'component', 'operation': 'eq',
                                                     'value': 'airphone'}}}
        return payload

    def get_json_response(self, url, payload=None):
        data = json.dumps(payload)
        response = requests.get(url,
                                headers=self.headers,
                                data=data, verify=False)
        response_data = json.loads(response.text)
        return response_data

    def get_ap_latest_load_released_or_released_with_restrictions(self, project='master_airphone', test_result=None):
        info = {}
        latest_released_build = self.get_latest_ap_load(project, 'RELEASED')
        latest_test_result = self.get_test_result(project, 'RELEASED')
        latest_released_with_restrictions_build = self.get_latest_ap_load(project, 'RELEASED_WITH_RESTRICTIONS')
        print("______latest_released_build", latest_released_build)
        print("________latest_test_result", latest_test_result)
        print("___________latest_released_with_restrictions_build", latest_released_with_restrictions_build)
        print("___________test_result", test_result)
        if latest_released_build > latest_released_with_restrictions_build:
            if test_result in latest_test_result:
                print("Exist")
                return [latest_released_build, latest_test_result]
            else:
                print("No exist")
            info[latest_released_build] = latest_test_result
            # return latest_released_build
        # return latest_released_with_restrictions_build
        return [latest_released_with_restrictions_build, latest_test_result]


class Airphone_software_upgrade:
    def __init__(self):
        self.build_Residing1 = ''

    def yaftpkginstallation(self, nsnusername, nsnpassword, test_result):

        os.chdir("/home/ute")
        folder_path = "/home/ute/trunk"
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
            print("___trunk folder created")
        else:
            for item in os.listdir(folder_path):
                item_path = os.path.join(folder_path, item)
                if item != "build":
                    if os.path.isdir(item_path):
                        shutil.rmtree(item_path)
                    else:
                        os.remove(item_path)
        print(f"Folder '{folder_path}' created.")
        command = [
            "svn", "checkout",
            "--username=ca_ute_test",
            "--password=utetest",
            "https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk",
            "/home/ute/trunk"
        ]
        p = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        sleep(3)
        print(os.getcwd())
        os.chdir("/home/ute/trunk")
        print(os.getcwd())
        if not os.path.isdir('build'):
            os.mkdir('build')
            print("directory created")
        os.chdir("/home/ute/trunk/build")
        print(os.getcwd())
        obj = Airphonesoftwareupgrade()
        data = obj.get_ap_latest_load_released_or_released_with_restrictions(test_result=test_result)
        build_exists = False
        for file in os.listdir("/home/ute/trunk/build"):
            if data[0] in file:
                build_exists = True
                break
        print("_____build_exists", build_exists)
        if build_exists:
            print("Build already exists. Skipping download.")
            os.chdir("/home/ute/trunk/build")
            cwd = "/home/ute/trunk/build"
            for file_name in os.listdir(cwd):
                if file_name.startswith("esimmode"):
                    self.build_Residing1 = os.path.join(cwd, file_name)
                    break
            print("_____self.build_Residing1", self.build_Residing1)
        else:
            shutil.rmtree("/home/ute/trunk/build")
            os.mkdir("/home/ute/trunk/build")
            os.chdir("/home/ute/trunk/build")
            response = requests.get(
                "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/"+data[0]+"/",
                auth=HTTPBasicAuth(nsnusername, nsnpassword))
            data1 = response.text
            zip_list = []
            eism_list = []
            for i in data1.split("\n"):
                if "zip" in i and "md5" not in i and "sha256" not in i:
                    import re
                    pattern = r'AirScale.*.zip'
                    match = re.search(pattern, i)
                    # if match !=None:
                    if match is not None:
                        zip_list.append(match.group(0).split(">")[1])
                elif "esimmode" in i and ".md5" not in i and ".sha256" not in i:
                    pattern = r'esimmode_.*.bz2'
                    match = re.search(pattern, i)
                    # if match !=None:
                    if match is not None:
                        eism_list.append(match.group(0).split(">")[1])
            print("________zip_list", zip_list)
            print("_________eism_list", eism_list)
            linkBuildDownloaderCreation = (
                    "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/" +
                    data[0]+"/"+zip_list[0])
            print("________linkbuilddownloadercreation", linkBuildDownloaderCreation)
            response = requests.get(linkBuildDownloaderCreation, stream=True, verify=False, timeout=30,
                                    auth=HTTPBasicAuth(nsnusername, nsnpassword))
            cwd = "/home/ute/trunk/build"
            if (os.path.exists(str(cwd))):
                filearr = os.listdir(str(cwd))
                print(filearr)
                for file in filearr:
                    try:
                        shutil.rmtree(str(cwd)+"/" + str(str(file)))
                    except Exception as e:
                        print(f"An unexpected error occurred while removing the directory: {e}")
                build_Residing = str(cwd)
            else:
                os.mkdir(str(cwd))
            build_Residing = str(cwd)+"/"+str(zip_list[0])
            self.build_Residing1 = str(cwd)+"/"+str(eism_list[0])
            print(build_Residing)
            print(self.build_Residing1)
            with open(build_Residing, "wb") as f:
                for chunk in response.iter_content(chunk_size=100000000):
                    print("HAI I am HERE")
                    if chunk:
                        f.write(chunk)
                        file_info = os.stat(build_Residing)
                        file_size_download = self.convert_bytes(file_info.st_size)
                        print("###################### " + str(file_size_download) + " Downloaded ####################")
                    else:
                        break
            sleep(10)
            linkBuildDownloaderCreation1 = (
                    "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/" +
                    data[0]+"/"+eism_list[0])
            print(linkBuildDownloaderCreation1)
            response1 = requests.get(linkBuildDownloaderCreation1, stream=True, verify=False, timeout=30,
                                     auth=HTTPBasicAuth(nsnusername, nsnpassword))
            with open(self.build_Residing1, "wb") as f1:
                for chunk1 in response1.iter_content(chunk_size=100000000):
                    print("HAI I am HERE")
                    if chunk1:
                        f1.write(chunk1)
                        file_info1 = os.stat(self.build_Residing1)
                        file_size_download1 = self.convert_bytes(file_info1.st_size)
                        print("###################### " + str(file_size_download1) + " Downloaded ###################")
                    else:
                        break

    def convert_bytes(self, num):
        """
        this function will convert bytes to MB.... GB... etc
        """
        for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
            if num < 1024.0:
                return "%3.1f %s" % (num, x)
            num /= 1024.0

    def update_sshd_config(self, host, user, password):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        sftp = ssh.open_sftp()
        remote_path = '/home/ute/sshd_config'
        if os.path.exists(remote_path):
            print(f"The file {remote_path} exists.")
        else:
            ssh_config_content = textwrap.dedent("""
                                Protocol 2
                                HostKey /etc/ssh/ssh_host_rsa_key
                                PermitRootLogin yes
                                UsePAM yes
                                AllowAgentForwarding no
                                PrintLastLog no
                                ClientAliveInterval 900
                                MaxStartups 3
                                Banner /etc/ssh/banner
                                Subsystem sftp /usr/libexec/ssh/sftp-server
                                Ciphers aes192-ctr,aes128-ctr,aes256-ctr
                                DenyUsers root
                                MACs hmac-sha1,hmac-sha1-etm@openssh.com,umac-64@openssh.com
                                KexAlgorithms diffie-hellman-group1-sha1,diffie-hellman-group14-sha1
                                """)
            with open(remote_path, 'w') as file:
                file.write(ssh_config_content.strip())
            sftp.put("/home/ute/sshd_config", "/etc/ssh/sshd_config")
            time.sleep(3)
            restart_ssh_command = "pkill sshd"
            ssh_command = f"sshpass -p '{password}' ssh {user}@{host} '{restart_ssh_command}'"
            subprocess.run(ssh_command, shell=True)
        ssh.close()

    def backup_xml_files(self, host, user, password):
        cu_path = os.getcwd()
        file_path = cu_path+"/swconfig.txt"
        if not os.path.isfile(file_path):
            raise FileNotFoundError(f"The file '{file_path}' does not exist. Place your Airphone Swconfig.txt in same"
                                    f"path where Airphone_Software_Upgrade python file is present and rerun the python"
                                    f"file")
        else:
            print(f"The file '{file_path}' exists.")
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        sftp = ssh.open_sftp()
        source_dir = '/rom/simmode/'
        local_backup_dir = '/home/ute/airphone_simmode_backup'
        try:
            for file_name in os.listdir(local_backup_dir):
                full_file_name = os.path.join(local_backup_dir, file_name)
                os.remove(full_file_name)
            os.rmdir(local_backup_dir)
            print(f"Removed existing backup directory: {local_backup_dir}")
        except FileNotFoundError:
            pass
        os.makedirs(local_backup_dir)
        for file_name in sftp.listdir(source_dir):
            if file_name.endswith('.xml'):
                full_file_name = os.path.join(source_dir, file_name)
                local_backup_file_name = os.path.join(local_backup_dir, file_name)
                print(f"Copying {full_file_name} to {local_backup_file_name} on local machine.")
                try:
                    sftp.get(full_file_name, local_backup_file_name)
                except FileNotFoundError:
                    print(f"File {full_file_name} not found. Skipping backup for this file.")
        print("Backup of XML files completed on local machine.")
        sftp.close()
        ssh.close()

    def clean_simmode_files(self, host, user, password):
        import stat
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        sftp = ssh.open_sftp()
        simmode_dir = '/rom/simmode/'

        def remove_dir_recursive(path):
            for file_attr in sftp.listdir_attr(path):
                full_path = os.path.join(path, file_attr.filename)
                if stat.S_ISDIR(file_attr.st_mode):
                    remove_dir_recursive(full_path)
                    sftp.rmdir(full_path)
                    print(f"Removed directory: {full_path}")
                else:
                    sftp.remove(full_path)
                    print(f"Removed file: {full_path}")
        try:
            remove_dir_recursive(simmode_dir)
            sftp.rmdir(simmode_dir)
            sftp.mkdir(simmode_dir)
            print(f"Recreated directory: {simmode_dir}")
        except Exception as e:
            print(f"An error occurred: {e}")
        sftp.close()
        ssh.close()

    def Yafting_of_Airphone(self, test_result):
        os.chdir("/home/ute/trunk/")
        obj = Airphonesoftwareupgrade()
        data = obj.get_ap_latest_load_released_or_released_with_restrictions(test_result=test_result)
        os.chdir("/home/ute/")
        print(os.getcwd())
        script_path = (
                "python3 /home/ute/trunk/yaft.py --ignore_FSPs -i 192.168.200.1 -z /home/ute/trunk/build/AirScale-" +
                data[0]+".zip --clean_to_default")
        process = subprocess.Popen(script_path, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, universal_newlines=True, executable='/bin/bash')
        sleep(15)
        output = process.communicate()[0]
        print("Script Output:", output)

    def wts_configuration(self):
        # self.build_Residing1='/home/ute/trunk/build/esimmode_WTS_Esim.250402.01_sandybridge.tar.bz2'
        print(os.getcwd())
        data1 = (self.build_Residing1.split("esimmode_")[-1]).split("_sandybridge.tar.bz2")[0]
        data2 = self.build_Residing1.split("build")[-1]
        for file_name in os.listdir("/opt/iphy/"):
            file_path = os.path.join("/opt/iphy/", file_name)
            os.chdir("/opt/iphy")
            os.system("unlink latest")
            if os.path.isfile(file_path):
                os.remove(file_path)
                print(f"Deleted file: {file_path}")
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
                print(f"Deleted directory: {file_path}")
        print(f"All files and directories in /opt/iphy have been deleted.")
        shutil.copy("/home/ute/trunk/build"+data2, "/opt/iphy"+data2)
        print(os.getcwd())
        if not os.path.isdir(data1):
            os.mkdir(data1)
        os.system("ls -lrt")
        sleep(10)
        print("____link", "ln -s "+data1+" latest")
        os.system("ln -s "+data1+" latest")
        os.system("ls -lrt")
        os.system("tar xvf "+self.build_Residing1.split("build/")[-1]+" -C "+data1)
        os.chdir(data1)
        os.system("chmod a+x *")

    def copy_swconfig_and_reboot(self, host, user, password):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        sftp = ssh.open_sftp()
        script_dir = os.path.dirname(os.path.abspath(__file__))
        local_sshd_config_path = os.path.join(script_dir, 'swconfig.txt')
        remote_sshd_config_path = '/rom/swconfig.txt'
        print(f"Copying Swconfig file from {local_sshd_config_path} to {remote_sshd_config_path} on remote machine.")
        sftp.put(local_sshd_config_path, remote_sshd_config_path)
        restart_ssh_command = "system-module-reboot"
        stdin, stdout, stderr = ssh.exec_command(restart_ssh_command)
        output = stdout.read().decode()
        error = stderr.read().decode()
        if output:
            print(f"Command output: {output}")
        if error:
            print(f"Command error: {error}")
        sftp.close()
        ssh.close()

    def fetch_linked_xml_files(self, host, user, password):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        sftp = ssh.open_sftp()
        simmode_dir = '/rom/simmode/'
        linked_files = []
        try:
            files = sftp.listdir(simmode_dir)
            for file_name in files:
                if file_name.endswith('.xml'):
                    full_file_name = os.path.join(simmode_dir, file_name)
                    try:
                        # Check if the file is a symbolic link
                        if sftp.lstat(full_file_name).st_mode & 0o170000 == 0o120000:
                            # Read the target of the symbolic link
                            target = sftp.readlink(full_file_name)
                            linked_files.append((full_file_name, target))
                    except FileNotFoundError:
                        print(f"File {full_file_name} not found. Skipping.")
            if linked_files:
                print("Linked XML files in /rom/simmode:")
                for link, target in linked_files:
                    print(f"{link} -> {target}")
            else:
                print("No linked XML files found in /rom/simmode.")
        except Exception as e:
            print(f"An error occurred: {e}")
        sftp.close()
        ssh.close()
        return linked_files

    def recreate_links_in_backup_dir(self, host, user, password, linked_files):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        try:
            command = "ln -fs "+linked_files[0][1]+" "+linked_files[0][0]
            stdin, stdout, stderr = ssh.exec_command(command)
            output = stdout.read().decode()
            error = stderr.read().decode()
            if output:
                print(f"Command output: {output}")
            if error:
                print(f"Command error: {error}")
        except Exception as e:
            print(f"An error occurred: {e}")
        ssh.close()

    def copy_xmlfiles_simmode(self, host, user, password):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        sftp = ssh.open_sftp()
        local_path = '/home/ute/airphone_simmode_backup'
        remote_path = '/rom/simmode'
        try:
            sftp.stat(remote_path)
        except FileNotFoundError:
            sftp.mkdir(remote_path)
        for file_name in os.listdir(local_path):
            local_file_path = os.path.join(local_path, file_name)
            remote_file_path = os.path.join(remote_path, file_name)
            if os.path.isfile(local_file_path):
                print(f"Copying {local_file_path} to {remote_file_path} on remote machine.")
                sftp.put(local_file_path, remote_file_path)
        print("All files copied to /rom/simmode on remote machine.")
        sftp.close()
        ssh.close()
        time.sleep(3)

    def verify(self, host, user, password):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, username=user, password=password)
        directory_path = '/rom'
        self.found = "None"
        command = f"ls {directory_path}"
        stdin, stdout, stderr = ssh.exec_command(command)
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()
        if error:
            print(f"Error: {error}")
        else:
            print(f"Files and directories under '{directory_path}':")
            print(output)
            files = output.split("\n")
            obj = Airphonesoftwareupgrade()
            self.airp_build = obj.get_latest_ap_load('master_airphone', 'RELEASED')
            self.airp_build1 = (self.airp_build.split("."))[-1]
            for file in files:
                if self.airp_build1 in file:
                    self.found = "True"
        ssh.close()
        if self.found == "True":
            print(
                "Aiphone Software build already updated with with latest build Airphone_" + self.airp_build +
                " Build, Skipping upgrade......")
        else:
            print("Aiphone Software upgrade not updated")
        return self.found


if __name__ == "__main__":
    username = sys.argv[1]
    password = sys.argv[2]
    obj = Airphone_software_upgrade()
    data = obj.verify(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")
    if data != "True":
        obj.backup_xml_files(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")
        time.sleep(5)
        obj.update_sshd_config(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")
        sleep(10)
        linked_files = obj.fetch_linked_xml_files(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")
        sleep(10)
        obj.yaftpkginstallation(nsnusername=username, nsnpassword=password,
                                test_result="fs_tdd_sansa_ecpri_cmwv_ASIL_ABIO_4G5GCUS_CIT")
        sleep(15)
        obj.Yafting_of_Airphone("fs_tdd_sansa_ecpri_cmwv_ASIL_ABIO_4G5GCUS_CIT")
        print("Airphone Restart is going on Please Wait.....")
        sleep(240)
        print("Airphone Restart completed")
        obj.wts_configuration()
        sleep(20)
        obj.clean_simmode_files(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")
        sleep(10)
        obj.copy_xmlfiles_simmode(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")
        sleep(10)
        obj.recreate_links_in_backup_dir(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu",
                                         linked_files=linked_files)
        sleep(10)
        obj.copy_swconfig_and_reboot(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")
        print("Software Config Loaded and airphone restart going on Please Wait.....")
        sleep(460)
        # obj.verify(host='192.168.200.1', user='toor4nsn', password="oZPS0POrRieRtu")


# To run this file use command python <file name> <nsnusername> <token>
# Token we can generate using link https://hzisoj70.china.nsn-net.net/ui/user_profile)
