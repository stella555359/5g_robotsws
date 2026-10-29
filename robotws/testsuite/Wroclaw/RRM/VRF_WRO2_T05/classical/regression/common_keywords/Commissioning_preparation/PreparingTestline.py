import os
import re
import shutil
import requests
import subprocess
from robot.libraries.BuiltIn import BuiltIn
import taf.transport.ssh as ssh

access_key = "gKfr58ELsV5hdaBapwizQxhmBd9UR3Ndda0mbgvC"
artifactory_key = (
    "AKCp8oiHU5YPce4g24nY4H9XxoVHAVzcydFrggjst4Ym8FPW7jnEnLDyTDbkNk6ma5XV2NC95"
)
wft_url = "https://wft.int.net.nokia.com:8091/api/v1/"

tl = BuiltIn().get_variable_value("${tl}")


def mount_sw_dir():
    sw_dir = "/mnt/UUF_SW/"
    if not os.path.exists(os.path.join(sw_dir, "SBTS")):
        if not os.path.exists(sw_dir):
            cmd = (
                r"sudo mkdir /mnt/UUF_SW &&"
                r"sudo chmod 777 /mnt/UUF_SW &&"
                r"sudo mount -t cifs //10.42.248.45/Global_veryfication/[1]\ SW /mnt/UUF_SW/ -o"
                r" username=wro5grrm,password='5gpass!1'"
                r",domain=noklab,file_mode=0777,dir_mode=0777,uid=ute,gid=ute"
            )
        else:
            cmd = (
                r"sudo mount -t cifs //10.42.248.45/Global_veryfication/[1]\ SW /mnt/UUF_SW/ -o"
                r" username=wro5grrm,password='5gpass!1'"
                r",domain=noklab,file_mode=0777,dir_mode=0777,uid=ute,gid=ute"
            )
        try:
            subprocess.check_output(cmd, universal_newlines=True, shell=True)
        except subprocess.CalledProcessError as e:
            print(str(e), e.returncode, e.output)
            raise Exception(e)


def create_local_sw_dir():
    sw_dir = "/home/ute/autoupdate_sw/"
    if not os.path.exists(sw_dir):
        cmd = f"mkdir {sw_dir}"
        print("Creating local sw dir.")
        try:
            subprocess.check_output(cmd, universal_newlines=True, shell=True)
        except subprocess.CalledProcessError as e:
            print(str(e), e.returncode, e.output)
            raise Exception(e)


def delete_local_sw_dir():
    sw_dir = "/home/ute/autoupdate_sw/"
    cmd = f"rm -rf {sw_dir}"
    print("Clearing local sw dir.")
    try:
        subprocess.check_output(cmd, universal_newlines=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(str(e), e.returncode, e.output)
        raise Exception(e)


def get_download_link(branch, sw_version):
    endpoint = "{0}/CI_ENB/builds/{1}/storages/results.json?access_key={2}".format(
        branch, sw_version, access_key
    )
    response = requests.get(url=wft_url + endpoint)
    if response.status_code == 404:
        raise Exception(
            f"Error: 404 Not Found requested SW on WFT to download: {response.json()}"
        )
    download_link = ""
    file_name = "{}_release_BTSSM_downloadable_A54.zip".format(sw_version)
    download_link = [
        file_.get("path")
        for storage in response.json()
        for file_ in storage["storage"].get("storage-items")
        if file_name in file_["title"]
        and any(
            artifactory in file_.get("path")
            for artifactory in [
                "lterel.es-si-s3-z4",
                "https://artifactory-espoo2.int.net.nokia.com",
            ]
        )
    ][0]
    return download_link


def download_package(sw_version, burak=True):
    """
    Download .zip package with specified software version to the given directory.
    :param sw_version: string with specified software version
    :return: path to the directory with downloaded package file
    """
    branch = get_sw_branch(sw_version)
    print("branch", branch)
    if branch == "SBTS00":
        sw_version = "SBTS00_" + "_".join(sw_version.split("_")[1:])
    print("sw_version", sw_version)
    if burak:
        download_dir = f"/mnt/UUF_SW/SBTS/{branch}"
    else:
        download_dir = f"/home/ute/autoupdate_sw"
    print("download_dir", download_dir)
    local_file_path = get_local_file_path(sw_version, download_dir)
    print("local_file_path", local_file_path)
    link_to_file = get_download_link(branch, sw_version)
    print("link_to_file", link_to_file)
    wft_file_size = int(
        requests.get(url=link_to_file, stream=True, timeout=120).headers.get(
            "Content-Length"
        )
    )
    if local_file_path:
        local_file_size = int(os.path.getsize(local_file_path))
    if local_file_path and wft_file_size == local_file_size:
        BuiltIn().log_to_console(
            message="{} file already downloaded to {}".format(
                link_to_file.split("/")[-1], local_file_path
            )
        )
    else:
        local_file_path = "/".join([download_dir, link_to_file.split("/")[-1]])
        with requests.get(
            url=link_to_file,
            stream=True,
            timeout=120,
            headers={"X-JFrog-Art-Api": artifactory_key},
        ) as request:
            if request.status_code == 200:
                BuiltIn().log_to_console(
                    message="Downloading a {} file to {}".format(
                        link_to_file.split("/")[-1], download_dir
                    )
                )
                with open(local_file_path, "wb") as f:
                    shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
            else:
                raise Exception("'get' request error")
    return local_file_path.strip()


def get_sw_branch(sw_version=None):
    branch = sw_version.split("_")[0]
    if str(sw_version.split("_", 3)[2]) == "9999":
        branch = "SBTS00"
    else:
        branch = sw_version.split("_")[0]
    return branch


def get_local_file_path(sw_version, download_dir):
    file_name = "{}_release_BTSSM_downloadable_A54.zip".format(sw_version)
    path = None
    try:
        path = subprocess.check_output(
            "find {}* -name '{}'".format(download_dir, file_name),
            shell=True,
            universal_newlines=True,
        ).strip()
    except subprocess.CalledProcessError:
        BuiltIn().log_to_console(
            message="File {} does not exist in {}".format(file_name, download_dir)
        )
    return path


def delete_config(mplane_ip):
    class DeleteConfigException(Exception):
        pass

    try:
        conn = ssh.connect(
            hostname=mplane_ip, username="toor4nsn", password="oZPS0POrRieRtu"
        )
        ls_active_partition_dir = conn.execute("ls -alh /ffs/run/")
        print("BEFORE ls -alh /ffs/run/", ls_active_partition_dir)
        conn.execute("rm -rf /ffs/run/config")
        ls_active_partition_dir = conn.execute("ls -alh /ffs/run/")
        print("AFTER ls -alh /ffs/run/", ls_active_partition_dir)
        pattern = re.compile(r"\bconfig\b")
        for el in ls_active_partition_dir.split("\n"):
            if pattern.findall(el):
                raise Exception(
                    "Config still exists on active partition. Testline can not be prepared."
                )
    except Exception as e:
        raise DeleteConfigException("Delete config failed due to - {}".format(e))
    finally:
        conn.disconnect()


def get_pdu_model(gnb_id, du_id, common_unit_id, capacity_unit_id, ru_id):
    """
    Retrieves the PDU model from the network configuration.

    Args:
        gnb_id (int): The ID of the gNB.
        du_id (int): The ID of the DU.
        common_unit_id (int): The ID of the common unit.
        capacity_unit_id (int): The ID of the capacity unit.
        ru_id (int): The ID of the RU.

    Returns:
        str: The PDU model name.
    """
    pdu = tl.gnbs[gnb_id].dus[du_id].airscale. \
        common_units[common_unit_id].capacity_units[capacity_unit_id].rus[ru_id].pdu_port.pdu.__class__.__name__
    return pdu


def get_pdu_ip(gnb_id, du_id, common_unit_id, capacity_unit_id, ru_id):
    """
    Retrieves the PDU IP address from the network configuration.

    Args:
        gnb_id (int): The ID of the gNB.
        du_id (int): The ID of the DU.
        common_unit_id (int): The ID of the common unit.
        capacity_unit_id (int): The ID of the capacity unit.
        ru_id (int): The ID of the RU.

    Returns:
        str: The PDU IP address.
    """
    pdu_ip = tl.gnbs[gnb_id].dus[du_id].airscale. \
        common_units[common_unit_id].capacity_units[capacity_unit_id].rus[ru_id].pdu_port.pdu.addr
    return pdu_ip


def get_radio_port(gnb_id, du_id, common_unit_id, capacity_unit_id, ru_id):
    """
    Retrieves the radio port number from the network configuration.

    Args:
        gnb_id (int): The ID of the gNB.
        du_id (int): The ID of the DU.
        common_unit_id (int): The ID of the common unit.
        capacity_unit_id (int): The ID of the capacity unit.
        ru_id (int): The ID of the RU.

    Returns:
        int: The radio port number.
    """
    radio_port = tl.gnbs[gnb_id].dus[du_id].airscale. \
        common_units[common_unit_id].capacity_units[capacity_unit_id].rus[ru_id].pdu_port.port_no
    return radio_port


def get_pdu_version(gnb_id, du_id, common_unit_id, capacity_unit_id, ru_id):
    """
    Retrieves the PDU version from the network configuration.

    Args:
        gnb_id (int): The ID of the gNB.
        du_id (int): The ID of the DU.
        common_unit_id (int): The ID of the common unit.
        capacity_unit_id (int): The ID of the capacity unit.
        ru_id (int): The ID of the RU.

    Returns:
        str: The PDU version.
    """
    pdu_version = tl.gnbs[gnb_id].dus[du_id].airscale.\
        common_units[common_unit_id].capacity_units[capacity_unit_id].rus[ru_id].pdu_port.pdu.version
    return pdu_version
