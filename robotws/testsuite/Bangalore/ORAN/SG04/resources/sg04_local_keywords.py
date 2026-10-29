"""
:copyright: NOKIA
:author: Sudarshan Kanapuram
:contact: sudarshan.kanapuram@nokia.com
:maintainer: Sudarshan
"""
import os
import subprocess
import re


def check_shared_vol():
    command = 'df -h'
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
    res, error = process.communicate()
    res = res.decode().splitlines()
    ret = False
    print(res[0])
    for x in res:
        if "sharedvolume" in x:
            print(x)
            ret = True
    return ret


def verify_shared_vol_mount():
    if check_shared_vol():
        return True
    else:
        command = 'sudo mount -v -t nfs 10.43.207.2:/RAN_PZ_BLR/Dcapserver/DCAP_UTE/SG4/BTS-578 /sharedvolume'
        process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
        res, error = process.communicate()
        res = res.decode().splitlines()
        print(res)
        if check_shared_vol():
            return True
        else:
            return False


def scf_create_from_old(scf_old, scf_new):
    fh = open(scf_old, "r")
    fh1 = open(scf_new, "w")
    i = 0
    for x in fh:
        if "<managedObject class=" in x:
            i = i + 1
            fh1.write(x[:19] + "operation=\"create\" " + x[19:])
            continue
        fh1.write(x)
    fh.close()
    fh1.close()

# count = 0


def Fetch_Required_Enb_SW(Req_Enb_SW_ver,
                          current_bts_SW_ver, is_trunk_build, SW_dwl_dir="/home/ute/Downloads"):
    # Req_Enb_SW_ver="SBTS23R1_ENB_0000_001070_000000"
    # current_bts_SW_ver = "SBTS23R2_ENB_0000_001069_000000"
    # SW_dwl_dir = "/home/ute/Downloads"
    print("User req SW ver:", Req_Enb_SW_ver)
    print("Curr BTS SW ver:", current_bts_SW_ver)
    pattern = re.compile(r"^SBTS.*$")
    check1 = Req_Enb_SW_ver + "_release_BTSSM_downloadable_A54.zip"

    ints = 0
    digits = ''
    precheck = 0
    postcheck = 0

    if (Req_Enb_SW_ver[4:6] == '00' and is_trunk_build):
        print("Trunk build validation!")
        if (Req_Enb_SW_ver[4:6] == current_bts_SW_ver[4:6]):
            c1 = int(Req_Enb_SW_ver[16:-7])
            c2 = int(current_bts_SW_ver[16:-7])
            # print("c1",c1)
            # print("c2",c2)
            if (c1 == c2):
                c3 = int(Req_Enb_SW_ver[-6:])
                c4 = int(current_bts_SW_ver[-6:])
                # print("c3",c3)
                # print("c4",c4)
                if (c3 > c4):
                    precheck += 1

                else:
                    print("1. Please take latest Build!")
            elif (c1 > c2):
                precheck += 1

            else:
                print("2. Please take latest Build!")
        else:
            print("3. Please take latest Build!")

    elif (Req_Enb_SW_ver[4:8] == current_bts_SW_ver[4:8]):
        print("Branch build 2XRX validation!")
        print(Req_Enb_SW_ver[18:24])
        print(current_bts_SW_ver[18:24])
        if (int(Req_Enb_SW_ver[18:24]) > int(current_bts_SW_ver[18:24])):
            precheck += 1
        else:
            print("4. Please take latest Build!")
    else:
        print("No validation!")

        precheck += 1

    if (precheck == 1):
        files = os.listdir(SW_dwl_dir)
        if check1 in files:
            ints += 1
            print("File Exists!")
        else:
            print("Proceeding with SW_Download...")
            proc = subprocess.Popen(
                ['df -h'], stdout=subprocess.PIPE, shell=True)
            (space, err) = proc.communicate()
            space1 = space.decode('UTF-8')
            for line in space1.split('\n'):
                if "/dev/mapper/vg_sys-lv_home" in line:
                    words = line.split()
                    req = words[4]
                    print(req)
                    print(type(req))
                    reqs = req[0:2]
                    print(type(reqs))
                    if int(reqs) < 70:
                        print(reqs)
                        print("Space available")
                    else:
                        file_list = os.listdir(SW_dwl_dir)
                        for file_name in file_list:
                            if pattern.match(file_name):
                                file_path = os.path.join(SW_dwl_dir, file_name)
                                os.remove(file_path)
                                print("File removed!")
            if Req_Enb_SW_ver.strip()[4:6] == "00":
                cmd = "wget https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local\
                       /build/" + Req_Enb_SW_ver.strip()[0:6] + "/" + Req_Enb_SW_ver.strip() + "/" +\
                    Req_Enb_SW_ver.strip() + "_release_BTSSM_downloadable_A54.zip -P " + SW_dwl_dir
            else:
                cmd = "wget https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local\
                       /build/" + Req_Enb_SW_ver.strip()[0:8] + "/" + Req_Enb_SW_ver.strip() + "/" + \
                    Req_Enb_SW_ver.strip() + "_release_BTSSM_downloadable_A54.zip -P " + SW_dwl_dir
            print("wget : ", cmd)
            proc1 = subprocess.Popen([cmd], stdout=subprocess.PIPE, shell=True)
            (download, err) = proc1.communicate()
            download_sw = download.decode('UTF-8')
            print(download_sw)
            print("Download completed!")


if __name__ == "__main__":
    scf_create_from_old("scf_org.xml", "scf_mod.xml")
