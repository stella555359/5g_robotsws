import os
import requests
import json
import subprocess


def sherpabuilddownload(downloadpath):
    abe = []
    abc = os.popen("curl --silent "
                   "https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/pool/sherpa5g_18_debian10/")\
        .read()
    abd = abc.split("a href=")
    for ij in abd:
        if ".deb</a>" in ij:
            abe.append(ij)
    build = (abe[-1].split('.deb">')[-1]).split("</a>")[0]
    oldversion = ((os.popen("/opt/Nokia/Sherpa_5G_18/Sherpa.run --version").read()).split("\n")[0]).split(": ")[-1]
    newversion = build.split(".debian")[0]
    if "LICENSE_FILE_NOT_FOUND" in oldversion:
        print("License File Not Found Please copy License file")
    elif oldversion in newversion:
        if len(oldversion) == 0:
            downinst(build, downloadpath)
        else:
            print("Build was already UptoDate")
    else:
        downinst(build, downloadpath)


def downinst(build, downloadpath):
    # linkBuildDownloaderCreation = "https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/pool/sherpa5g
    # _18_debian10/Sherpa_5G_1.0.86.0.debian10.deb"
    linkBuildDownloaderCreation = "https://artifactory-espoo1.int.net.nokia.com/artifactory/sherpa-local/pool/" \
                                  "sherpa5g_18_debian10/"+build
    print(linkBuildDownloaderCreation)
    response = requests.get(linkBuildDownloaderCreation, stream=True, verify=False, timeout=60)
    cwd = downloadpath
    if (os.path.exists(str(cwd))):
        filearr = os.listdir(str(cwd))
        for file in filearr:
            os.remove(cwd + "/" + str(str(file)))
        build_Residing = str(cwd)
    else:
        os.mkdir(str(cwd))
    build_Residing = str(cwd)+"/"+build
    with open(build_Residing, "wb") as f:
        for chunk in response.iter_content(chunk_size=10000000):
            if chunk:
                f.write(chunk)
                file_info = os.stat(build_Residing)
                file_size_download = convert_bytes(file_info.st_size)
                print(f"###################### {(file_size_download)} Downloaded ##########################")
            else:
                break
    os.chdir(str(cwd))
    os.system("sudo dpkg -i "+build)


def convert_bytes(num):
    for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, x)
        num /= 1024.0


sherpabuilddownload("/home/ute/sherpa")
