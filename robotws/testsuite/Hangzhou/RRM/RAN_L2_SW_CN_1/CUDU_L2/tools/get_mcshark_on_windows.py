# -*- coding: utf-8 -*-
import wget
import os
import glob
import re
gnb_version = "SBTS00_ENB_9999_221227_000013"
mcshark_url = "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark"
# old: https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/
"""
usage:
1. you need install wget lib for python first:
pip install wget -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com --proxy 87.254.212.121:8080
2. change gnb_version parameter
3. run python get_mcshark_on_windows.py
note:
1. download newest wireshark for win10:
https://artifactory-hz1.int.net.nokia.com/artifactory/wireshark-lte-5g-win-local/wireshark/wireshark-stable/win10/
2. mcshark is downloaded automatically
mcshark installed path:(You can only put mcshark into one folder.It will crash if you put mcshark in both.)
C:\\Users\\yuema\\AppData\\Roaming\\Wireshark\\plugins\\3.6\\epan
C:\\Program Files\\Wireshark\\plugins\\3.6\\epan
"""


def files(curr_dir='.', ext='*.exe'):
    """list files in current folder"""
    for i in glob.glob(os.path.join(curr_dir, ext)):
        yield i


def remove_files_hint(rootdir, ext, show=False):
    """rm files in rootdir"""
    for i in files(rootdir, ext):
        if show:
            print(i)
        try:
            os.remove(i)
        except IOError:
            if (i.startswith("C:\\Users\\")):
                print("Old plugin is used now. Please close wireshark software firstly.")
            else:
                print(
                    "There are old plugin file in your computer. Please remove it first and rerun this script.")
            exit(0)


mcshark_windows_plugin_common_folder = "C:\\Program Files\\Wireshark\\plugins\\3.6\\epan"
username = os.environ['USERNAME']
mcshark_windows_plugin_private_folder = "C:\\Users\\{}\\AppData\\Roaming\\Wireshark\\plugins\\3.6\\epan".format(
    username)
print("mcshark_windows_plugin_common_folder:{}".format(
    mcshark_windows_plugin_common_folder))
print("mcshark_windows_plugin_private_folder:{}".format(
    mcshark_windows_plugin_private_folder))
print("You can only put mcshark into one folder.It will crash if you put mcshark in both.")
mcshark_folder_address = "{0}/{1}/".format(mcshark_url, gnb_version)
print("mcshark_folder_address={}".format(mcshark_folder_address))
wget.download(mcshark_folder_address, "./")
fh = open("./download.wget")
data = fh.read()
mcshark_names = re.findall("mcshark-3.6.*?dll", data)
print("mcshark_names={}".format(mcshark_names))
mcshark_name = mcshark_names[0]
fh.close()
mcshark_adress = "{0}/{1}/{2}"\
    .format(mcshark_url, gnb_version, mcshark_name)
print("Download link:\n"+mcshark_adress)
# remove old plugin
remove_files_hint(mcshark_windows_plugin_common_folder,
                  "mcshark*.dll", show=True)
remove_files_hint(mcshark_windows_plugin_private_folder,
                  "mcshark*.dll", show=True)
remove_files_hint("./", "download*wget", show=False)
# download new plugin
wget.download(mcshark_adress, mcshark_windows_plugin_private_folder)
print("Mcshark plugin is downloaded sucessfully in {}".format(
    mcshark_windows_plugin_private_folder))
print("Search wireshark in windows and run as administrator.")
