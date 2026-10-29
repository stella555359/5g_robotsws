import os
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.csv4all.resources.utilities.wft import CSV4ALLWft
from core.RegexWatcher import log_path, timestamp


api = None
connection = None

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


def activate_software(sw_path):
    get_api()
    connection.wait_sw_update_possible()
    connection.update_software(sw_package=sw_path, timeout=2000)


def download_if_not_exist(version, sw_path):
    downloader = CSV4ALLWft()
    filename = f"{version}_release_BTSSM_downloadable_A54"
    sw_path = os.path.abspath(sw_path)
    sw_filepath = os.path.join(sw_path, f'{filename}.zip')
    if os.path.exists(sw_filepath):
        print(f"File already exists: {sw_filepath}")
        return sw_filepath
    downloader.download_build_from_wft(builds_to_download=version, download_path=sw_path, use_build_storage=False)
    return downloader.target_sw_dict[filename]
