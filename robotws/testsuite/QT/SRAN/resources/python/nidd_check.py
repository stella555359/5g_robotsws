import os
import time
import sys
import logging
import re
import requests
import xml.etree.ElementTree as ElementTree
from taf.transport.ssh import ssh
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh

ssh = ssh()


def get_scf_file_from_testline(scf_location):
    """
    :param scf_location: absolute path, where to save SCF file, i.e: "/home/ute/scf.xml"
    :return: (bool) True if SCF saved successfully in 'scf_path', else False.
    """
    scf_name = scf_location.split("/")[-1]
    scf_dir = "/".join(scf_location.split("/")[0:-1])
    coam = admin()
    coam.connect_to(bts_host="192.168.255.129")
    logging.info("[SUCCESS] connected to BTS (192.168.255.129).")
    coam.get_current_scf_file(local_dir_path=scf_dir, file_name=scf_name)
    coam.teardown_admin()
    scf_exists = os.path.isfile("{}/{}".format(scf_dir, scf_name))
    if scf_exists:
        logging.info("[SUCCESS] SCF collected from BTS.")
    else:
        logging.error("[FAIL] Problem with saving SCF file from BTS.")

    return scf_exists


def get_nidd_version_from_scf_file(scf_location, managed_object=1):
    """
    :param (str) scf_location: absolute path to SCF file, i.e: "/home/ute/scf.xml"
    :param (int) managed_object: number for looking managedObject in SCF file
    :return: (str) NIDD version checked from provided SCF file.
    """
    tree = ElementTree.parse(scf_location)
    try:
        nidd = tree.getroot().find(
            "./{raml}cmData/{raml}managedObject[{object}]".format(
                raml="{raml21.xsd}", object=managed_object)).attrib["version"]
        nidd = nidd.strip() if len(nidd) > 3 else "error"
    except Exception:
        nidd = "error"
    print(nidd)  # do not delete this print, it's necessary!

    return nidd


def get_nidd_version_from_vendor_xml(alias, loadBuild, tenant=None):
    nidd_ver = "None"
    try:
        if ".300." in loadBuild or ".250." in loadBuild:
            vendor_path = "/opt/nokia/SS_OAM/vendor/vendor.xml"
            command = 'oc -n {} exec -it po-{}-oamcm-0 -c ctr-{}-oamcm cat {}|grep -i nidd\n'.format(
                tenant, tenant, tenant, vendor_path)
            print(command)
            output = ssh().execute(command, connection=alias).strip()
            time.sleep(2)
            output = output.split('<')[1]
            print(output)
        else:
            output = ssh().execute('grep -i nidd /ffs/run/swpool/OAM/vendor_*.xml\n', connection=alias).strip()
        out = output.split(' ')
        print('out is:', out)
        nidd_ver = out[3].split('.')[0]
    except Exception:
        print('xml read failed')
    print(nidd_ver)

    if "_NIDD_" in nidd_ver:
        return nidd_ver
    else:
        print('get nidd version failed!')
        return nidd_ver


def compare_nidd_ver_for_ap(wft_sub_ver, scf_sub_ver1, scf_sub_ver2):
    scf_sub_ver_list = [scf_sub_ver2, scf_sub_ver1]
    if len(wft_sub_ver) < 1:
        return [False]
    difference = []
    if wft_sub_ver != scf_sub_ver_list:
        for i in range(len(wft_sub_ver)):
            if wft_sub_ver[i] > scf_sub_ver_list[i]:
                difference.append([wft_sub_ver[i], 1])
            if wft_sub_ver[i] < scf_sub_ver_list[i]:
                difference.append([wft_sub_ver[i], -1])
        if len(difference) == 1 and difference[0][1] == 1:
            result = difference[0]
            return False, result
        elif len(difference) == 2 and difference[0][1] == 1:
            result = difference
            return False, result
        elif len(difference) == 1 and difference[0][1] == -1:
            result = difference[0][0]
            return True, result
        else:
            result = max(difference[0][0][-8:-1], difference[1][0][-8:-1])
            return True, result
    else:
        return [False]


def compare_nidd_ver_for_ap_scf(nidd_version, expected_version):
    """
    Compare two versions with the format EQM25R3_2506_102.

    :param nidd_version: First version string.
    :param expected_version: Second version string.
    :return: 1 if nidd_version is higher, -1 if nidd_version is lower, 0 if they are equal.
    """
    def parse_version(version):
        # Split the version into components
        parts = version.split('_')
        # Extract the numeric parts
        major = parts[0]
        minor = int(parts[1])
        patch = int(parts[2])
        return major, minor, patch

    # Parse both versions
    major1, minor1, patch1 = parse_version(nidd_version)
    major2, minor2, patch2 = parse_version(expected_version)

    # Compare the major parts
    if major1 == major2:
        # Compare the minor parts
        if minor1 > minor2:
            return 1
        elif minor1 < minor2:
            return -1
        else:
            # Compare the patch parts
            if patch1 > patch2:
                return 1
            elif patch1 < patch2:
                return -1
            else:
                return 0
    elif major1 > major2:
        return 1
    else:
        return -1


def get_commit_hash_and_nidd_ver_for_ap_scf(ap_configs_path, commit_msg, alias="UTE_VM"):
    commits_cmd = f"cd {ap_configs_path}; git log --oneline --author prodzn --grep EQM | head -n 10"
    print(f"Use below command to find nidd related commits: {commits_cmd}")
    commits = ssh.execute(commits_cmd, connection=alias)
    commits_list = commits.split("\r\n")
    print(commits_list)
    for commit in commits_list:
        if "EQM" in commit and "Merge branch" not in commit:
            commit_hash = commit.split(" ")[0]
            commit_nidd_ver = commit.split(" ")[1]
            print(f"commit hash is: {commit_hash}, \
commit nidd version is: {commit_nidd_ver}, target nidd version is: {commit_msg}")
            if compare_nidd_ver_for_ap_scf(commit_nidd_ver, commit_msg) <= 0:
                print("proper commit nidd version is found!")
                return commit_hash, commit_nidd_ver
    return "", ""


if __name__ == "__main__":
    '''
    func = sys.argv[1]
    scf_path = sys.argv[2]
    try:
        managed_object = int(sys.argv[3])
    except (IndexError, ValueError):
        managed_object = 1

    if func == "get_scf":
        get_scf_file_from_testline(scf_path)
    elif func == "get_nidd":
        get_nidd_version_from_scf_file(scf_path, managed_object)
    else:
        logging.critical("Wrong arg provided. Possible options : 'get_scf', 'get_nidd'.")
    '''
    ssh.connect_to(hostname='10.56.108.123', username='ute', password='UTE.debian12', alias='UTE_VM')
    print(get_commit_hash_and_nidd_ver_for_ap_scf("/home/ute/topology-configs", "EQM25R3_2505_102"))
