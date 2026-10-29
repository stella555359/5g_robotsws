import os
import getpass
import requests
import time
import sys
from taf.sbts.oam.coam.admin import admin
from RegexWatcher import log_path, timestamp
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens import Tokens


api = None
connection = None

sw_url = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/SBTS00/"
url_end = "_release_BTSSM_downloadable_A54.zip"
x2_cmd = "enb_x2_link_up enb=1 target=2"
x2_regex = r"ENB-[0-9]+: X2AP Link with GNB-[0-9]* \S* is up"


def get_api():
    global api, connection
    if api is None:
        api = admin()
        connection = api.connect_to()
    return api


def collect_snapshot():
    api = get_api()
    path = log_path._get_target()
    zip_name = "snapshot_" + timestamp._get_target() + ".zip"
    api.collect_snapshot(target_file_name=path + zip_name, connection=connection)


def return_x2_regex():
    return x2_regex


def wait_for_update_possible():
    get_api()
    connection.wait_sw_update_possible()


def activate_software(version, sw_path):
    get_api()
    filename = version + "_release_BTSSM_downloadable_A54.zip"
    connection.wait_sw_update_possible()
    connection.update_software(sw_package=sw_path + filename, timeout=2000)
    # wait_sw_update_possible()
    # connection.wait_sw_update_possible()
    # connection.software_postcheck(timeout=600)


def download_if_not_exist(version, sw_path):
    # Build filename
    filename = f"{version}_release_BTSSM_downloadable_A54.zip"

    # Make sure sw_path ends with slash and is absolute
    sw_path = os.path.abspath(sw_path)
    file_path = os.path.join(sw_path, filename)

    print(f"filename = {filename}")
    full_url = f"{sw_url}{version}/{filename}"
    print(f"full_url = {full_url}")
    print(f"target_path = {file_path}")

    # ? Ensure the directory exists (even in n8n / Docker)
    try:
        os.makedirs(sw_path, exist_ok=True)
    except Exception as e:
        print(f"ERROR: Unable to create directory {sw_path}")
        print(f"{type(e).__name__}: {e}")
        return f"Failed: Cannot create directory {sw_path}"

    # ? If file already exists, skip
    if os.path.exists(file_path):
        return f"File already exists: {file_path}"

    # DEBUG INFO (helps when running inside n8n/Docker)
    print(f"Running as user: {getpass.getuser()}")
    print(f"Working dir: {os.getcwd()}")
    print(f"Directory exists? {os.path.isdir(sw_path)}")
    print(f"Listing sw_path: {os.listdir(sw_path)}")

    # ? Download
    with requests.get(full_url, stream=True, headers=Tokens().authorization_bearer_token) as r:
        print(f"Trying to Download {full_url} >> {sw_path}")
        r.raise_for_status()   # Throws if unreachable / 404 / auth error
        total = int(r.headers.get("Content-Length", 0))
        downloaded = 0
        start = time.time()
        print("Started downloading")

        # ? Open file safely
        try:
            with open(file_path, "wb") as f:
                print("Started writing to file")
                last_percent = -1
                for chunk in r.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)

                        if total:
                            percent = downloaded * 100 // total
                            if percent != last_percent:  # print only when percentage changes
                                # last_percent = percent
                                elapsed = time.time() - start
                                speed = downloaded / elapsed if elapsed > 0 else 0
                                eta = (total - downloaded) / speed if speed > 0 else 0
                                msg = (
                                    f"\rDownloading: {percent:3d}% | "
                                    f"{downloaded/1024/1024:.2f}/{total/1024/1024:.2f} MB | "
                                    f"{speed/1024/1024:.1f} MB/s | ETA {int(eta)}s"
                                )
                                sys.__stdout__.write(msg)
                                sys.__stdout__.flush()
                sys.__stdout__.write("\n")
        except FileNotFoundError as e:
            print(f"CRITICAL ERROR: Cannot open file for writing!")
            print(f"{type(e).__name__}: {e}")
            return f"Failed: Cannot open {file_path}"

    return f"Downloaded {full_url} >> {sw_path}"
