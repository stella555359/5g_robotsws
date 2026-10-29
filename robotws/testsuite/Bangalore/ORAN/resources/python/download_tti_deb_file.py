import os
import requests
import time
import sys


def download_tti_debfile(releaseName, setuppassword):
    http_proxy = "http://10.158.100.6:8080"
    https_proxy = "https://10.158.100.6:8080"
    proxyDictproxyDict = {
        "http": http_proxy,
        "https": https_proxy
    }
    buildvalue = releaseName.split("_")[0]
    url = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/" + str(
        buildvalue) + "/" + str(releaseName) + "/" + str(releaseName) + "_tti-dec.deb"
    os.chdir("/home/ute/")
    save_path = str(releaseName) + "_tti-dec.deb"
    response = requests.get(url, stream=True, verify=False)
    if response.status_code == 200:
        print(save_path)
        with open(save_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=100000000):
                time.sleep(10)
                print("HAI I am HERE")
                if chunk:
                    f.write(chunk)
                    file_info = os.stat(save_path)
                    file_size_download = convert_bytes(file_info.st_size)
                    print(
                        "###################### " + str(file_size_download) + " Downloaded ##########################")
                else:
                    break
    else:
        print(f"Failed to download {url}")
    os.chdir("/home/ute/")
    import subprocess
    cmd = "sudo dpkg -i " + str(releaseName) + "_tti-dec.deb"
    print("______cmd", cmd)
    proc = subprocess.Popen(['su', '-c', cmd], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate(input=setuppassword.encode())
    print(stdout.decode())
    print(stderr.decode())
    # os.system("su\nUteuteute@123")
    # os.system("dpkg -i *.deb")
    # print("______3")


def convert_bytes(num):
    """
    this function will convert bytes to MB.... GB... etc
    """
    for x in ['bytes', 'KB', 'MB', 'GB', 'TB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, x)
        num /= 1024.0


if __name__ == "__main__":
    release = sys.argv[1]
    password = sys.argv[2]
    download_tti_debfile(release, password)
