import subprocess
import requests
import argparse
from robot.api import logger
import tarfile
import os
import glob
from tabulate import tabulate
import shutil
from bs4 import BeautifulSoup
from command_execution_in_bts import (
    connect_and_execute_command_on_ru,
    connect_and_scp_file_to_ru,
)
import time
import re

TOKEN = (
    "cmVmdGtuOjAxOjE4MTE0ODgxOTQ6TzBnTDNzNTFsWkJwcEsyU2d3QUludEY3RVlI"
)
INSTALLER = (
    "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/"
    "RAN_L1_SW_CN_5/resources/python/installer.sh"
)


def get_rf_candidate_build_version(
    release, component, state="released", version=""
):
    access_key = "mzwMktgLPhlMbaBy9ckoBlJA3vt458S8EeBsOJue"
    item_num = 20
    state = state.upper()
    url_1 = (
        "https://wft.int.net.nokia.com:8091/Common/api/v1/build.json?"
        "access_key={access_key}"
        "&view[page]=1"
        "&view[items]={item_num}"
        "&view[sorting_field]=created_at&view[sorting_direction]=DESC"
        "&view[columns][][id]=deliverer.project.full_path"
        "&view[columns][][id]=deliverer.title"
        "&view[columns][][id]=version"
        "&view[columns][][id]=branch.title"
        "&view[columns][][id]=state"
        "&view[columns][][id]=planned_delivery_date"
        "&view[columns][][id]=common_links"
        "&view[columns][][id]=compare_link"
        "&view[view_filters_attributes][224647926933679][column]=version"
        "&view[view_filters_attributes][224647926933679][operation]=cont"
        "&view[view_filters_attributes][224647926933679][value][]={release}"
        "&view[view_filters_attributes][877719395256431][column]=component"
        "&view[view_filters_attributes][877719395256431][operation]=eq"
        "&view[view_filters_attributes][877719395256431][value][]={component}"
        "&view[view_filters_attributes][198321988384082][column]=state"
        "&view[view_filters_attributes][198321988384082][operation]=eq"
        "&view[view_filters_attributes][198321988384082][value][]={state}&"
    ).format(
        access_key=access_key,
        item_num=item_num,
        release=release,
        component=component,
        state=state,
    )

    url_2 = (
        "https://wft.int.net.nokia.com:8091/ALL/api/v1/build.json?"
        "access_key={access_key}"
        "&view[items]={item_num}"
        "&view[sorting_field]=created_at"
        "&view[sorting_direction]=DESC"
        "&view[columns][][id]=deliverer.project.full_path"
        "&view[columns][][id]=deliverer.title"
        "&view[columns][][id]=version"
        "&view[columns][][id]=branch.title"
        "&view[columns][][id]=state"
        "&view[columns][][id]=planned_delivery_date"
        "&view[columns][][id]=common_links"
        "&view[columns][][id]=compare_link"
        "&view[view_filters_attributes][516090544272748][column]=version"
        "&view[view_filters_attributes][516090544272748][operation]=eq"
        "&view[view_filters_attributes][516090544272748][value][]={version}"
        "&view[view_filters_attributes][474660250313217][column]=deliverer.project.full_path"
        "&view[view_filters_attributes][474660250313217][operation]=eq"
        "&view[view_filters_attributes][474660250313217][value][]=Common&"
    ).format(
        access_key=access_key, item_num=item_num, version=version
    )

    url = url_2 if version else url_1

    proxy = {"https": "http://10.158.100.8:8080"}
    result = requests.get(url, proxies=proxy, verify=False, timeout=90)
    if result.status_code != 200:
        logger.console(url)
        raise Exception("REQUEST_FAIL")
    build_info = []
    logger.console("-" * 55)
    for item in result.json()["items"]:
        if item["state"] in ("RELEASED",):
            logger.console(f"State                :  {item['state']}")
            logger.console(f"Version              :  {item['version']}")
            logger.console(
                f"Planned_delivery_date:  {item['planned_delivery_date']}"
            )
            logger.console(f"Component            :  {item['deliverer.title']}")
            build_info.append(item["version"])
            break
        else:
            logger.console(f"State                :  {item['state']}")
            logger.console(f"Version              :  {item['version']}")
            logger.console(
                f"Planned_delivery_date:  {item['planned_delivery_date']}"
            )
            logger.console(f"Component            :  {item['deliverer.title']}")
            build_info.append(item["version"])
    selected_build = build_info.pop(0)
    print("selected_build:", selected_build)
    return selected_build


def download_rf_knife(link_url, package_path="/home/ute/Downloads/"):
    tar_file_path = os.path.join(package_path, "C_Element.tar.gz")
    if os.path.exists(tar_file_path):
        os.remove(tar_file_path)
    subprocess.Popen(
        f"rm -f {package_path}C_Element.tar.gz",
        stdout=subprocess.PIPE,
        shell=True,
    )
    c_element_dir = os.path.join(package_path, "C_Element")
    if os.path.exists(c_element_dir):
        shutil.rmtree(c_element_dir)
    if not link_url.endswith(".tar.gz"):
        link_url = link_url.rstrip("/") + "/C_Element.tar.gz"
    is_exist = subprocess.Popen(
        f"curl -s -I {link_url}", stdout=subprocess.PIPE, shell=True
    )
    if "404 Not Found" in str(is_exist.stdout.read()):
        raise Exception(f"Knife link not found: {link_url}")
    else:
        target_file = package_path.rstrip("/") + "/C_Element.tar.gz"
        download = subprocess.Popen(
            f'wget --header="X-JFrog-Art-Api: {TOKEN}" -t 0 -c --progress=bar {link_url} -O {target_file}',
            stdout=subprocess.PIPE,
            shell=True,
        )
        logger.console(download.stdout.read())
        ls_result = subprocess.Popen(
            f"ls -l {target_file}", stdout=subprocess.PIPE, shell=True
        )
        is_download = ls_result.stdout.read()
        if not is_download or "C_Element.tar.gz" not in str(is_download):
            raise Exception(f"[ERROR] Failed to download! {is_download}")
        if int(is_download.split()[4]) < 8888888:
            raise Exception(
                f"[ERROR] Download build size = {is_download.split()[4]}"
            )
    logger.console(f"Knife downloaded successfully: {target_file}")
    extract_dir = os.path.join(package_path, "C_Element")
    os.makedirs(extract_dir, exist_ok=True)
    gz_path = os.path.join(package_path, "C_Element.tar.gz")
    if not os.path.exists(gz_path):
        raise FileNotFoundError(f"can't find the download file: {gz_path}")
    logger.console(f"Extracting C_Element.tar.gz to {extract_dir}")
    with tarfile.open(gz_path, "r:gz") as tar:
        tar.extractall(path=extract_dir)
        print(f"unpack ok file is saved: {extract_dir}")
    search_pattern = os.path.join(extract_dir, "**", "rfsw-package-*.tar")
    tar_files = glob.glob(search_pattern, recursive=True)
    knife_ver_search_pattern = os.path.join(extract_dir, "**", "for_targetBD.txt")
    knife_ver_file = glob.glob(knife_ver_search_pattern, recursive=True)
    print(f"tar_files: {tar_files}")
    print(f"knife_ver_file: {knife_ver_file}")
    if tar_files:
        print(f"found the tar file path: {tar_files[0]}")
    else:
        raise FileNotFoundError(f"can't find tar file: {search_pattern}")

    if knife_ver_file:
        knife_ver = get_knife_base_version(knife_ver_file[0])
        print(f"found the knife base version is: {knife_ver}")
    else:
        raise FileNotFoundError(f"can't find knife version file: {knife_ver_search_pattern}")

    return os.path.abspath(tar_files[0]), knife_ver


def get_knife_base_version(file):
    output_rru_ver_str = subprocess.check_output(['cat', f'{file}'], text=True)
    logger.console(f"cat {file} output: {output_rru_ver_str}")
    knife_ver = extract_rru_version_from_knife(output_rru_ver_str)
    return knife_ver


def extract_rru_version_from_knife(knife_ver_str):
    match = re.search(r'(RF\.\w+\.\w+\.\d{8}\.\d{3})', knife_ver_str)
    if match:
        rru_ver = match.group(1)
        return rru_ver
    return None


def find_build_on_wft_tar_url(link_ep_base):
    headers = {"X-JFrog-Art-Api": TOKEN}
    resp = requests.get(link_ep_base, headers=headers, verify=False)

    if resp.status_code != 200:
        raise Exception(
            f"Failed to access {link_ep_base}, status: {resp.status_code}"
        )
    soup = BeautifulSoup(resp.text, "html.parser")
    for a in soup.find_all("a"):
        href = a.get("href")
        if href and href.endswith(".tar"):
            if not href.startswith("http"):
                tar_url = link_ep_base.rstrip("/") + "/" + href.lstrip("/")
            else:
                tar_url = href
            return tar_url
    raise FileNotFoundError(f"No .tar file found at {link_ep_base}")


def download_rf_package(link_url, package_path="/home/ute/Downloads/"):
    tar_file_name = link_url.split("/")[-1]
    print("tar_file_name:", tar_file_name)
    target_file = os.path.join(package_path, tar_file_name)
    download = subprocess.Popen(
        f'wget --header="X-JFrog-Art-Api: {TOKEN}" -t 0 -c --progress=bar {link_url} -O {target_file}',
        stdout=subprocess.PIPE,
        shell=True,
    )
    logger.console(download.stdout.read())

    ls_result = subprocess.Popen(
        f"ls -l {target_file}", stdout=subprocess.PIPE, shell=True
    )
    is_download = ls_result.stdout.read()
    if not is_download or tar_file_name not in str(is_download):
        raise Exception(f"[ERROR] Failed to download! {is_download}")
    if int(is_download.split()[4]) < 8888888:
        raise Exception(
            f"[ERROR] Download build size = {is_download.split()[4]}"
        )
    logger.console(f"Package downloaded successfully: {target_file}")
    return target_file


def rf_lxc_attach_and_install_package_on_rf(ru_sn, rfsw_package, server_ip):
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn, command="cat /etc/version", ip=server_ip
    )
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn,
        command="ls /tmp -l; chmod +x /tmp/installer.sh",
        ip=server_ip,
    )
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn,
        command=f"cd /tmp; sudo ./installer.sh {rfsw_package}",
        ip=server_ip,
    )
    print(f"install {rfsw_package} in current directory successfully.")
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn, command='sudo su -c "reboot"', ip=server_ip
    )
    time.sleep(300)
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn, command="cat /etc/version", ip=server_ip
    )


def SWmanShellCommand_install_package_on_rf(ru_sn, rfsw_ver, rfsw_package, server_ip):
    act_packege, current_rf_ver = rfsw_inquire_result(ru_sn, server_ip)
    logger.console(f"current RF version {current_rf_ver}, current package {act_packege},\n"
                   f"target RF version {rfsw_ver}, target package {rfsw_package}")
    if current_rf_ver == rfsw_ver and act_packege == rfsw_package:
        logger.console(f"Current RF version {current_rf_ver} is same with target {rfsw_ver}, "
                       f"Current RF package {act_packege} is same with target {rfsw_package}, skip RF upgrade.")
        return
    upgrade_and_active_cmd = []
    commit_id = str(rfsw_package).split(".tar")[0].split("_")[1]
    if str(current_rf_ver).split(".")[1] != str(rfsw_ver).split(".")[1]:
        logger.console(f"[WARN] current RF version {current_rf_ver} is not align with target {rfsw_ver},\n"
                       f"change target version to {current_rf_ver} for avoiding rfsw incompatible issue.\n"
                       f"it maybe cause some unexpected issue, user should check with related developer.")
        return
    upgrade_rf_package_cmd = f'SWmanShellCommand -s /tmp/{rfsw_package} {commit_id} {rfsw_ver} ""'
    upgrade_and_active_cmd.append(upgrade_rf_package_cmd)
    print(f"cmd: {upgrade_rf_package_cmd}")
    print(f"install {rfsw_package} in current directory successfully.")
    active_rf_package_cmd = f'SWmanShellCommand -a {rfsw_ver} {rfsw_ver} {rfsw_package} {rfsw_ver}'
    print(f"cmd: {active_rf_package_cmd}")
    upgrade_and_active_cmd.append(active_rf_package_cmd)
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn,
        command=upgrade_and_active_cmd,
        ip=server_ip,
    )
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn, command='sudo su -c "reboot"', ip=server_ip
    )
    time.sleep(300)
    connect_and_execute_command_on_ru(
        rmod_id=ru_sn, command="cat /etc/version", ip=server_ip
    )
    act_packege, current_rf_ver = rfsw_inquire_result(ru_sn, server_ip)
    logger.console(f"current RF version {current_rf_ver}, current package {act_packege},\n"
                   f"target RF version {rfsw_ver}, target package {rfsw_package}")
    if current_rf_ver == rfsw_ver and act_packege == rfsw_package:
        logger.console(f"[INFO] RFSW upgrade successfully.")
    else:
        logger.console(f"[ERROR] RFSW upgrade failed, please check target version and package.")


def rfsw_inquire_result(ru_sn, server_ip):
    sw_inquire_output = connect_and_execute_command_on_ru(
        rmod_id=ru_sn, command="SWmanShellCommand -i", ip=server_ip
    )
    build_version_pattern = r'.*runningBuildVersion:\s+([A-Za-z0-9.]+)'
    build_version_matches = re.findall(build_version_pattern, sw_inquire_output)
    current_rf_ver = build_version_matches[0]
    package = r'rfsw-package-\w+_0x[0-9A-Fa-f]+\.tar'
    act_packege_pattern = fr'\s*name:\s+({package})\s*version:\s+([^\n]+)\s*usage:\s+([^\n]+)\s*integrity:\s+([^\n]+)'
    matches = re.findall(act_packege_pattern, sw_inquire_output, re.DOTALL)
    act_packege = ''
    for match in matches:
        if "active" in match[2]:
            act_packege = match[0]
    return act_packege, current_rf_ver


def get_rfs_info(ip):
    cmd_get_rru_type = f"sshpass -p oZPS0POrRieRtu ssh toor4nsn@{ip} 'cat /rom/config/FRIps.txt'"
    output_rru_type = execute_cmd_on_fct(cmd_get_rru_type)
    output_fr_lines_list = [item for item in output_rru_type.strip().split('\n') if 'MRBTS-1/' in item]
    rfs_info = {}
    for fr_line in output_fr_lines_list:
        rru_type = str(fr_line).split(";")[-1]
        rru_sn = str(fr_line).split(";")[-2]
        rru_ip = str(fr_line).split(";")[-3]
        cmd_check_rru_ver = (f"sshpass -p oZPS0POrRieRtu ssh toor4nsn@{ip} "
                             f"'cat /ffs/run/TargetBD_SBTS*.xml|grep {rru_type}'")
        output_rru_version = execute_cmd_on_fct(cmd_check_rru_ver)
        rru_sw_version, rru_package_name = get_swversion_from_output(rru_type, output_rru_version)
        if 'FRU6' in rru_sw_version:
            rru_package_name = rru_package_name.replace('rfsw-package', 'rfsw-package-fru6')
        print(f"{rru_type} version: {rru_sw_version}, package name: {rru_package_name} in TargetBD.xml")
        rfs_info[rru_sn] = {
            'rru_type': rru_type,
            'rru_ip': rru_ip,
            'rru_sw_version': rru_sw_version,
            'rru_package_name': rru_package_name
        }
    return rfs_info


def execute_cmd_on_fct(cmd):
    output = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out = output.stdout.read().decode(encoding='utf-8', errors='ignore')
    return out


def get_swversion_from_output(rru_type, input_str):
    sw_ver_pattern = f'.*{rru_type}.*resourceSWVersion="([^"]+)".*'
    sw_ver_matches = re.findall(sw_ver_pattern, input_str)
    package_name_pattern = f'.*{rru_type}.*(rfsw-package[^"]+)</.*'
    package_name_matches = re.findall(package_name_pattern, input_str)
    return sw_ver_matches[0], package_name_matches[0]


def check_rru_version(ver_in_tbd, target_ver, rru_type):
    knife_rf_type = target_ver.split(".")[1]
    real_rf_type = ver_in_tbd.split(".")[1]
    if knife_rf_type != real_rf_type:
        raise Exception(f"Target RF version {target_ver} is invalid for {rru_type}"
                        f"knife is for {knife_rf_type}, and {rru_type} is {real_rf_type}")
    else:
        if target_ver != ver_in_tbd:
            logger.console(f"[ ERROR ] Target RF version {target_ver} is not align "
                           f"with version {ver_in_tbd} in targetBD")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Personal information")
    parser.add_argument(
        "-r",
        "--release",
        dest="release",
        type=str,
        default="trunk",
        help="release of the candidate, like as trunk/25R1/25R2/, default is trunk",
    )
    parser.add_argument(
        "-c",
        "--component",
        dest="component",
        type=str,
        default="rf-SRM7",
        help="component of the candidate, like as rf-SRM7/mMIMO_SRM6, default is rf-SRM7",
    )
    parser.add_argument(
        "-b",
        "--build_name",
        dest="build_name",
        type=str,
        default="",
        help="specific build name",
    )
    parser.add_argument(
        "-k",
        "--knife_link",
        dest="knife_link",
        type=str,
        default="",
        help=(
            "specific knife link, like as "
            "https://artifactory-espoo1.../RF_KNIVES/KNIFER-DEV_small_knifer/32749/"
        ),
    )
    parser.add_argument(
        "-sn",
        "--serial_number",
        dest="serial_number",
        type=str,
        help='serial number of the RU, like as "1M243613553,1M243613554"',
    )
    parser.add_argument(
        "-ip",
        "--ip_address",
        dest="ip_address",
        type=str,
        help='bts local IP address, like as "10.108.241.133".',
    )
    args = parser.parse_args()
    data = [
        ["release", args.release],
        ["component", args.component],
        ["specific build name", args.build_name],
        ["knife link", args.knife_link],
        ["serial numbers", args.serial_number],
        ["IP address", args.ip_address],
    ]
    print(tabulate(data, headers=["Argument", "Input"], tablefmt="psql"))
    if args.ip_address:
        ip = (
            args.ip_address.strip("https:").replace("/", "")
            if "https" in args.ip_address
            else args.ip_address
        )
    else:
        ip = None
    serial_number_list = (
        args.serial_number.strip().replace(" ", "").split(",")
    )
    rfs_info = get_rfs_info(ip)
    for sn in serial_number_list:
        rru_type = rfs_info[sn]['rru_type']
        ver_in_tbd = rfs_info[sn]['rru_sw_version']
        if args.knife_link:
            tar_files_path, knife_ver = download_rf_knife(args.knife_link)
            check_rru_version(ver_in_tbd, knife_ver, rru_type)
            rfsw_version = ver_in_tbd
        else:
            tar_files_path = None
            rf_package_name = None
            rfsw_version = get_rf_candidate_build_version(
                args.release,
                args.component,
                state="released",
                version=args.build_name,
            )
            if args.build_name == "":
                if rru_type == "AWHQN":
                    rfsw_version = ver_in_tbd
            check_rru_version(ver_in_tbd, rfsw_version, rru_type)
            logger.console("-" * 55)
            logger.console(f"SELECTED_BUILD       :  {rfsw_version}\n")
            rf_type = rfsw_version.split(".")[1]
            logger.console(f"rf_type: {rf_type}")
            branch = rfsw_version.split(".")[2]
            logger.console(f"branch: {branch}")

            link_root = (
                "https://artifactory-espoo1.int.net.nokia.com/artifactory/"
            )
            link_rfsw1 = (
                f"mn-rfsw-{rf_type.lower()}-release-packages-local/"
                f"{rf_type}/{branch}/"
            )
            if rf_type == "SRM6":
                link_rfsw2 = f"C_Element/SE_RFM/SS_mMIMO_{rf_type}/Target/"
            else:
                link_rfsw2 = f"C_Element/SE_RFM/SS_{rf_type}/Target/"
            logger.console(f"build_on_wft: {rfsw_version}")
            link_ep_base = (
                    link_root + link_rfsw1 + rfsw_version + "/" + link_rfsw2
            )
            logger.console(f"link_ep_base: {link_ep_base}")
            cmd = (
                f'curl -H "X-JFrog-Art-Api: {TOKEN}" -s -I {link_ep_base}'
            )
            is_exist = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
            logger.console(f"isExist: {is_exist.stdout.read()}")
            wft_tar_url = find_build_on_wft_tar_url(link_ep_base)
            logger.console(f"wft_tar_url: {wft_tar_url}")
            tar_files_path = download_rf_package(wft_tar_url)
            logger.console(f"wft_tar_file: {tar_files_path}")

        tar_file = tar_files_path if tar_files_path else None
        local_files = [tar_file]

        upload_files = connect_and_scp_file_to_ru(
            local_files=local_files, rmod_id=sn, ip=ip
        )
        package = [p for p in upload_files if p.endswith(".tar")]
        if not package:
            raise FileNotFoundError(
                f"No .tar package uploaded for serial number {sn}"
            )
        SWmanShellCommand_install_package_on_rf(sn, rfsw_version, package[0], ip)
