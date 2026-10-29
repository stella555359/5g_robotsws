import os
import requests
from subprocess import Popen, PIPE, run
import subprocess
import urllib
import ast
import json
from time import time
import urllib.request
import re
from datetime import datetime


class downloadwftpackage:
    def __init__(self):
        self.cwd = ''
        self.USERNAME = ''
        self.PASSWORD = ''
        self.HOST = ''
        self.PORT = ''
        self.DATA = '{"requestId":100,"parameters":{"name":"generateNokiaCompliantORUSWPackage"}}'
        self.INPUT_FILE = ""
        self.OUTPUT_FILE = ""
        self.flag = 0
        self.release_name = ""

    def read_last_build_from_promotion_datatrunk(self, promotion_data, promotion_step, rel, typeOfReg="REGRESSION"):
        buildanddetails = {}
        buildtimeall = []
        daysdict = {}
        promotionsdictcit = {}
        latestbuilddetails = {}
        for days in promotion_data['data']:
            if len(days['promotions']) != 0:
                daysdict = ast.literal_eval(str(days['promotions']))
                try:
                    if len(daysdict['qt']) != 0:
                        promotionsdictcit = ast.literal_eval(str(daysdict['qt']))
                        if (promotionsdictcit['buildid'] is not None and promotionsdictcit['buildid'] != 'null') and (
                                typeOfReg in promotionsdictcit['promotionTag']):
                            buildtimeall.append(int(promotionsdictcit['promotion_time']))
                            buildanddetails[str(promotionsdictcit['promotion_time'])] = promotionsdictcit['buildid']
                except Exception as e:
                    continue

        if len(buildtimeall) != 0:
            latesttime = max(buildtimeall)
            latestbuilddetails[latesttime] = str(buildanddetails[str(latesttime)])
        else:
            print("This Relase is not having any Data")
            latesttime = 0
            latestbuilddetails[0] = "None"
        return latestbuilddetails, latesttime

    def read_last_build_from_promotion_minus1(self, promotion_data, promotion_step, rel, typeOfReg="REGRESSION"):
        buildanddetails = {}
        buildtimeall = []
        daysdict = {}
        promotionsdictcit = {}
        latestbuilddetails = {}
        for days in promotion_data['data']:
            if len(days['promotions']) != 0:
                daysdict = ast.literal_eval(str(days['promotions']))
                try:
                    if len(daysdict['qt']) != 0:
                        promotionsdictcit = ast.literal_eval(str(daysdict['qt']))
                        if (promotionsdictcit['buildid'] is not None and promotionsdictcit['buildid'] != 'null') and (
                                typeOfReg in promotionsdictcit['promotionTag']):
                            buildtimeall.append(int(promotionsdictcit['promotion_time']))
                            buildanddetails[str(promotionsdictcit['promotion_time'])] = promotionsdictcit['buildid']
                except Exception as e:
                    continue

        if len(buildtimeall) != 0:
            latesttime = buildtimeall[1]
            latestbuilddetails[latesttime] = str(buildanddetails[str(latesttime)])
        else:
            print("This Relase is not having any Data")
            latesttime = 0
            latestbuilddetails[0] = "None"
        return latestbuilddetails, latesttime

    def getlatest_build_from_coop(self, branch, typeOfReg):
        waitForLatestBuild = "NO"
        link = "http://coop.int.net.nokia.com/ext/api/pci_promotion/get/restructure?bl=sran&product=sbts&branch=" + \
               str(branch)
        print("####link", link)
        start_time = time()
        while True:
            if time() - start_time > 60:
                break
            nowtime = int(time())
            dictionarylatestbuild = {}
            data20json = ""
            timelist = []
            timelist.append(nowtime)
            try:
                proxy = urllib.request.ProxyHandler({
                    'http': '10.158.100.6:8080',
                    'https': '10.158.100.6:8080'
                })

                opener = urllib.request.build_opener(proxy)
                urllib.request.install_opener(opener)
                req = urllib.request.urlopen(link)
            except Exception as e:
                print("Links not accessible going to continue checking the loop")
                continue
            timebuildavailable = []
            build20information = {}
            try:
                datatrunk = json.loads(req.read().decode('utf-8'))
                build20information, timetrunk = self.read_last_build_from_promotion_datatrunk(
                                                datatrunk, 'qt', branch, typeOfReg)
                timebuildavailable.append(timetrunk)
                dictionarylatestbuild[timetrunk] = build20information[timetrunk]
            except Exception as e:
                print("No Data is available for given branch")
            try:
                timela = max(timebuildavailable)
            except Exception as e:
                continue
            latbuild = dictionarylatestbuild[timela]
            timelist.append(timela)
            if nowtime == max(timelist) and waitForLatestBuild == "NO":
                break
            else:
                break

        release = latbuild.split("_")
        return latbuild

    def getlatest_build_from_coop_minus1(self, branch, typeOfReg):
        waitForLatestBuild = "NO"
        link = "http://coop.int.net.nokia.com/ext/api/pci_promotion/get/restructure?bl=sran&product=sbts&branch=" + \
               str(branch)
        print("####link", link)
        start_time = time()
        while True:
            if time() - start_time > 60:
                break
            nowtime = int(time())
            dictionarylatestbuild = {}
            data20json = ""
            timelist = []
            timelist.append(nowtime)
            try:
                proxy = urllib.request.ProxyHandler({
                    'http': '10.158.100.6:8080',
                    'https': '10.158.100.6:8080'
                })

                opener = urllib.request.build_opener(proxy)
                urllib.request.install_opener(opener)
                req = urllib.request.urlopen(link)
            except Exception as e:
                print("Links not accessible going to continue checking the loop")
                continue
            timebuildavailable = []
            build20information = {}
            try:
                datatrunk = json.loads(req.read().decode('utf-8'))
                build20information, timetrunk = self.read_last_build_from_promotion_minus1(
                                                datatrunk, 'qt', branch, typeOfReg)
                timebuildavailable.append(timetrunk)
                dictionarylatestbuild[timetrunk] = build20information[timetrunk]
            except Exception as e:
                print("No Data is available for given branch")
            try:
                timela = max(timebuildavailable)
            except Exception as e:
                continue
            latbuild = dictionarylatestbuild[timela]
            timelist.append(timela)
            if nowtime == max(timelist) and waitForLatestBuild == "NO":
                break
            else:
                break

        release = latbuild.split("_")
        return latbuild

    def latestSbtsBuild(self, build_name='', downloadable_type='A54', branch='', typeOfReg="REGRESSION"):
        """
        this function will download latestsbts build
        """
        if build_name:
            build_name = build_name
        else:
            build_name = self.getlatest_build_from_coop(branch, typeOfReg)
        self.build_name = build_name
        buildname = build_name.split("_")[0]
        build = str(build_name) + "_release_BTSSM_downloadable_" + str(downloadable_type) + ".zip"
        link = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran" \
               "-central-public-local/build/" + str(buildname) + '/' + build_name + "/" + build
        cwd = "/home/ute/Downloads/Builds"
        if os.path.exists(str(cwd)):
            filearr = os.listdir(str(cwd))
            for file in filearr:
                os.remove(str(cwd) + "/" + str(str(file)))
            build_residing = str(cwd)
        else:
            os.mkdir(str(cwd))
        build_residing = str(cwd) + "/" + str(build)
        file_size_download = self.download(link, build_residing)
        if "0.0 bytes" in str(file_size_download):
            self.flag = self.flag + 1
            if self.flag > 2:
                return
            self.latestSbtsBuild(self.release_name, downloadable_type)
        return build_residing

    def download_admincli(self, build, target_path):
        self.cwd = target_path
        os.chdir(self.cwd)
        build_list = build.split("_")
        download_path = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/" \
                        "build/" + str(build_list[0]) + "/" + str(build) + "/" + str(build) + "_ADMIN_CLI.zip"
        print(download_path)
        build_residing = str(self.cwd) + "/" + str(build) + "_ADMIN_CLI.zip"
        self.download(download_path, build_residing)
        if not os.path.exists(str(target_path) + "/" + str(build) + "_ADMIN_CLI.zip"):
            raise Exception("check build is present in wft link or not")
        run(["unzip", os.path.basename(build_residing)], cwd=self.cwd)

    def latestSbtsBuild_minus1(self, build_name='', downloadable_type='A54', branch='', typeOfReg="REGRESSION"):
        """
        this function will download latestsbts build
        """
        if branch:
            build_name = self.getlatest_build_from_coop_minus1(branch, typeOfReg)
        else:
            build_name = build_name
        self.build_name = build_name
        buildname = build_name.split("_")[0]
        build = str(build_name) + "_release_BTSSM_downloadable_" + str(downloadable_type) + ".zip"
        link = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran" \
               "-central-public-local/build/" + str(buildname) + '/' + build_name + "/" + build
        cwd = "/home/ute/Downloads/SourceBuild"
        if os.path.exists(str(cwd)):
            filearr = os.listdir(str(cwd))
            for file in filearr:
                os.remove(str(cwd) + "/" + str(str(file)))
            build_residing = str(cwd)
        else:
            os.mkdir(str(cwd))
        build_residing = str(cwd) + "/" + str(build)
        file_size_download = self.download(link, build_residing)
        if "0.0 bytes" in str(file_size_download):
            self.flag = self.flag + 1
            if self.flag > 2:
                return
            self.latestSbtsBuild_minus1(self.release_name, downloadable_type)
        return build_residing

    def download_admincli(self, build, target_path):
        self.cwd = target_path
        os.chdir(self.cwd)
        build_list = build.split("_")
        download_path = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/" \
                        "build/" + str(build_list[0]) + "/" + str(build) + "/" + str(build) + "_ADMIN_CLI.zip"
        print(download_path)
        build_residing = str(self.cwd) + "/" + str(build) + "_ADMIN_CLI.zip"
        self.download(download_path, build_residing)
        if not os.path.exists(str(target_path) + "/" + str(build) + "_ADMIN_CLI.zip"):
            raise Exception("check build is present in wft link or not")
        run(["unzip", os.path.basename(build_residing)], cwd=self.cwd)

    def download_latest_RU(self, user, auth_key, radio=None, fjserial="05"):
        self.cwd = os.getcwd()
        if radio is None:
            url = "curl -u " + user + ":" + auth_key + " -X GET https://artifactory-espoo1.int.net.nokia.com/" \
                                                       "artifactory/mn-rfsw-fru6-release-packages-local/" \
                                                       "FRU6/trunk/"
            res = subprocess.check_output(url, shell=True)
            list1 = (res.decode('utf-8')).split('<a')
            latest_oru = ((list1[-2].split("</a>")[0].split(">"))[1].replace("/", ""))
            print(latest_oru)
            download_path = "curl -u " + user + ":" + auth_key + " -O https://artifactory-espoo1.int.net.nokia.com/" \
                                                                 "artifactory/list/mn-rfsw-fru6-release-packages-" \
                                                                 "local/FRU6/trunk/" \
                            + str(latest_oru) + "/C_Element/SE_RFM/SS_FRU6/" \
                                                "Target/NK." + str(latest_oru) + ".zip"

            os.chdir(self.cwd)
            print(download_path)
            build_residing = str(self.cwd) + "/NK." + str(latest_oru) + ".zip"
        else:
            url = "curl -u " + user + ":" + auth_key + " -X GET https://artifactory-blr1.int.net.nokia.com/" \
                                                       "artifactory/mn-fujitsu-data-local/OFEGSA/"
            res = subprocess.check_output(url, shell=True)
            patt_latest_ru_folder = re.compile(rf'({fjserial}\d+)/</a>\s+(\d{{2}}-\w{{3}}-\d{{4}}\s+\d{{2}}:\d{{2}})')
            pattern = re.compile(r'(FJ-RU-ET1---------' + fjserial
                                 + r'\d+\.FGF\.zip)<\/a>\s+(\d{2}-\w{3}-\d{4}\s+\d{2}:\d{2})')
            matches = patt_latest_ru_folder.findall(res.decode('utf-8'))
            print("@@@@@@@@@", matches)
            files_with_dates = []
            for match in matches:
                file_name = match[0]
                date_str = match[1]
                file_date = datetime.strptime(date_str, '%d-%b-%Y %H:%M')
                files_with_dates.append((file_name, file_date))
            files_with_dates.sort(key=lambda x: x[1], reverse=True)
            latest_oru_folder = files_with_dates[0][0]
            latest_oru = "FJ-RU-ET1---------" + str(latest_oru_folder) + ".FGF.zip"
            download_path = (
                    "curl -u " + user + ":" + auth_key + " -O "
                                                         "https://artifactory-blr1.int.net.nokia.com"
                                                         "/artifactory/mn-fujitsu-data-local/OFEGSA/"
                    + str(latest_oru_folder) + "/" + str(latest_oru))
            os.chdir(self.cwd)
            print(download_path)
            build_residing = str(self.cwd) + "/" + str(latest_oru)
        res = subprocess.check_output(download_path, shell=True)
        if not os.path.exists(build_residing):
            raise Exception("failed to download latest ORU file" + str(latest_oru))
        run(["unzip", "-n", os.path.basename(build_residing)], cwd=self.cwd)
        self.INPUT_FILE = build_residing
        parts = self.INPUT_FILE.rpartition(".")
        self.OUTPUT_FILE = parts[0] + "_NMS" + parts[1] + parts[2]

    def create_nms_file(self, build, target_path, user, auth_key, host='192.168.255.129', data='',
                        username='Nemuadmin', password='nemuuser', port='443', radio=None,
                        ru_build=None, ru_link=None, fjserial="05"):
        self.USERNAME = username
        self.PASSWORD = password
        self.HOST = host
        self.PORT = port
        if data != '':
            self.DATA = data
        if not os.path.exists(target_path):
            os.mkdir(target_path)
            os.chmod(target_path, 0o777)
        self.download_admincli(build, target_path)

        if radio != '':
            if ru_link is not None and ru_build is not None:
                build_residing = self.download_build(ru_link, ru_build, user, auth_key)
                run(["unzip", "-n", os.path.basename(build_residing)], cwd=self.cwd)
                self.INPUT_FILE = build_residing
                self.OUTPUT_FILE = os.path.splitext(build_residing)[0] + "_NMS.zip"
            else:
                self.download_latest_RU(user, auth_key, radio, fjserial)
            cmd1 = "./admin-cli.sh --bundle-path=../bundle.js --bts-username=" + self.USERNAME + " --bts-password=" + \
                   self.PASSWORD + " --bts-host=" + self.HOST + " --bts-port=" + self.PORT + " --data='" + self.DATA + \
                   "' --format=human" + \
                   " --input-files=\"" + self.INPUT_FILE + "\"" + " --output-file=\"" + self.OUTPUT_FILE + "\""
            print(cmd1)
            result = Popen([cmd1], stdout=PIPE, stderr=PIPE, shell=True)
            out, err = result.communicate()
            print("resukts inside create nsm", result, out)
            return os.path.basename(self.OUTPUT_FILE), os.path.basename(self.INPUT_FILE)
        else:
            self.download_latest_RU(user, auth_key)
            cmd1 = "./admin-cli.sh --bts-username=" + self.USERNAME + " --bts-password=" + self.PASSWORD + \
                   " --bts-host=" + self.HOST + " --bts-port=" + self.PORT + " --data='" + self.DATA + \
                   "' --input-file=" + self.INPUT_FILE + " --output-file=" + self.OUTPUT_FILE
            result = Popen(cmd1, shell=True).communicate()
            print(result)
            return os.path.basename(self.OUTPUT_FILE)

    def download(self, link, build_residing):
        print("**************", build_residing)
        response = requests.get(link, stream=True, verify=False, timeout=60)
        print(response, link)
        file_size_download = "0.0 bytes"
        if not os.path.isfile(build_residing):
            with open(build_residing, "wb") as f:
                for chunk in response.iter_content(chunk_size=10000000):
                    if chunk:
                        f.write(chunk)
                        file_info = os.stat(build_residing)
                        file_size_download = self.convert_bytes(file_info.st_size)
                        print("#### {(file_size_download)} Downloaded ####", file_size_download)
                    else:
                        break
        return file_size_download

    def convert_bytes(self, num):
        """
        this function will convert bytes to MB.... GB... etc
        """
        for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
            if num < 1024.0:
                return "%3.1f %s" % (num, x)
            num /= 1024.0

    def download_build(self, url_link, build, user, auth_key):
        self.cwd = os.getcwd()
        url = "curl -u " + user + ":" + auth_key + " -X GET " + url_link
        res = subprocess.check_output(url, shell=True)
        list1 = (res.decode('utf-8')).split('<a')
        build_get = None
        build_list = [((ele.split("</a>")[0].split(">"))[1].replace("/", "")) for ele in list1]
        print(build_list)
        print(build)
        for build_name in build_list:
            if build_name == build:
                build_get = build_name
        if build_get:
            download_path = "curl -u " + user + ":" + auth_key + " -O " + url_link + str(build_get)
            os.chdir(self.cwd)
            print(download_path)
            build_residing = str(self.cwd) + "/" + str(build)
            res = subprocess.check_output(download_path, shell=True)
            print(build_residing)
            if not os.path.exists(build_residing):
                raise Exception("failed to download build " + str(build))
        else:
            raise Exception("check build is present in given link or not")
        return build_residing

    def download_from_wft(self, url, username, wft_access_key):
        netrc_path = os.path.expanduser("~/.netrc")
        entry = f"machine wft.int.net.nokia.com\nuser {username}\npassword {wft_access_key}\n"
        self.cwd = os.getcwd()
        try:
            if os.path.exists(netrc_path):
                with open(netrc_path, "a") as netrc_file:
                    netrc_file.write("\n" + entry)
            else:
                with open(netrc_path, "w") as netrc_file:
                    netrc_file.write(entry)

            os.chmod(netrc_path, 0o600)
            print(f"Configuration for  added to {netrc_path}")
        except Exception as e:
            print(f"Failed to configure .netrc: {e}")

        response = requests.get(url, allow_redirects=True)
        os.chdir(self.cwd)
        if '%2F' in url:
            file_name = url.split('%2F')[-1]
        else:
            file_name = url.split('/')[-1]
        build_residing = str(self.cwd) + "/" + str(file_name)
        try:
            if response.status_code == 200:
                with open(file_name, "wb") as file:
                    file.write(response.content)
                print("File downloaded successfully.")
            else:
                print(f"Failed to download file. HTTP Status Code: {response.status_code}")
        except Exception as e:
            raise e
        if not os.path.exists(build_residing):
            raise Exception("failed to download build " + str(file_name))
