import requests
import json
import subprocess
import os
from time import sleep
import shutil
import sys
import re
from requests.auth import HTTPBasicAuth


class Wtssoftwareupgrade:
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
        if latest_released_build > latest_released_with_restrictions_build:
            if test_result in latest_test_result:
                print("Exist")
                return [latest_released_build, latest_test_result]
            else:
                print("No exist")
            info[latest_released_build] = latest_test_result
        return [latest_released_with_restrictions_build, latest_test_result]


class Wts_software_upgrade:
    def __init__(self):
        self.build_Residing1 = ''

    def yaftpkginstallation(self, nsnusername, nsnpassword, test_result):
        os.chdir("/home/ute")
        p = subprocess.Popen("svn co --username=ca_ute_test --password=utetest"
                             "https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk /home/ute/trunk",
                             stdout=subprocess.PIPE, shell=True)
        sleep(3)
        print(os.getcwd())
        folder_path = "/home/ute/trunk"
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
            print(f"Folder '{folder_path}' created.")
        os.chdir("/home/ute/trunk")
        print(os.getcwd())
        if not os.path.isdir('build'):
            os.mkdir('build')
            print("directory created")
        os.chdir("/home/ute/trunk/build")
        print(os.getcwd())
        obj = Wtssoftwareupgrade()
        data = obj.get_ap_latest_load_released_or_released_with_restrictions(test_result=test_result)
        build_exists = False
        for file in os.listdir("/home/ute/trunk/build"):
            if data[0] in file:
                build_exists = True
                break
        if build_exists:
            print("Build already exists. Skipping download.")
            os.chdir("/home/ute/trunk/build")
            cwd = "/home/ute/trunk/build"
            for file_name in os.listdir(cwd):
                if file_name.startswith("esimmode"):
                    self.build_Residing1 = os.path.join(cwd, file_name)
                    break
        else:
            shutil.rmtree("/home/ute/trunk/build")
            os.mkdir("/home/ute/trunk/build")
            os.chdir("/home/ute/trunk/build")
            response = requests.get(
                "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/"+data[0]+"/",
                auth=HTTPBasicAuth(nsnusername, nsnpassword))
            data1 = response.text
            eism_list = []
            for i in data1.split("\n"):
                if "esimmode" in i and ".md5" not in i and ".sha256" not in i:
                    pattern = r'esimmode_.*.bz2'
                    match = re.search(pattern, i)
                    if match is not None:
                        eism_list.append(match.group(0).split(">")[1])
            print("_________eism_list", eism_list)
            cwd = "/home/ute/trunk/build"
            self.build_Residing1 = str(cwd)+"/"+str(eism_list[0])
            print(self.build_Residing1)
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

    def wts_configuration(self):
        # self.build_Residing1='/home/ute/trunk/build/esimmode_WTS_Esim.250402.01_sandybridge.tar.bz2'
        print(os.getcwd())
        print("_________self.build_Residing1", self.build_Residing1)
        data1 = (self.build_Residing1.split("esimmode_")[-1]).split("_sandybridge.tar.bz2")[0]
        data2 = self.build_Residing1.split("build")[-1]
        for file_name in os.listdir("/opt/iphy/"):
            file_path = os.path.join("/opt/iphy/", file_name)
            os.chdir("/opt/iphy")
            os.system("unlink latest")
            if os.path.isfile(file_path):
                os.remove(file_path)  # Delete the file
                print(f"Deleted file: {file_path}")
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)  # Delete the directory and its contents
                print(f"Deleted directory: {file_path}")
        print(f"All files and directories in /opt/iphy have been deleted.")
        shutil.copy("/home/ute/trunk/build"+data2, "/opt/iphy"+data2)
        print(os.getcwd())
        if not os.path.isdir(data1):
            os.mkdir(data1)
        os.system("ls -lrt")
        sleep(10)
        os.system("ln -s "+data1+" latest")
        sleep(10)
        os.system("tar xvf "+self.build_Residing1.split("build/")[-1]+" -C "+data1)
        os.chdir(data1)
        os.system("chmod a+x *")


if __name__ == "__main__":
    username = sys.argv[1]
    password = sys.argv[2]
    obj = Wts_software_upgrade()
    obj.yaftpkginstallation(nsnusername=username, nsnpassword=password,
                            test_result="fs_tdd_sansa_ecpri_cmwv_ASIL_ABIO_4G5GCUS_CIT")
    obj.wts_configuration()
