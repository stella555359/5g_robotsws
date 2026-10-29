import re
import requests
import logging
from bs4 import BeautifulSoup
from taf.rfrl.utilities.robot.general import get_builtin_value


def get_latest_plugin_url(plugin: str) -> str:
    """
    Get latest wireshark nokia plugin url specified in parameter.
    """
    url = _get_latest_plugin_version(plugin)
    r = requests.get(url)
    soup = BeautifulSoup(r.text, features="lxml")
    bookworm_so = soup.find_all("a", href=re.compile("bookworm.so$"))[0]["href"]
    return url + bookworm_so


def _get_latest_plugin_version(plugin: str) -> str:
    """
    Get latest nokia wireshark plugin version.
    """
    wslte5g_url = (
        "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/"
    )
    url = wslte5g_url + plugin
    r = requests.get(url)
    r.raise_for_status()
    soup = BeautifulSoup(r.text, features="lxml")
    latest_version = soup.find_all("a", href=re.compile(r"\d\d\..*"))[-1]["href"]
    return url + "/" + latest_version


def get_bands_names(band: int, treshold: int) -> list[str]:
    """
    Converts integer band value to list of bands covered under the int value.
    :param band: Integer value of a band
    :param treshold: The highest value of a band
    :return: List of string bands values
    """
    bands = []
    band_iter = treshold
    for band_pos in f"{band:b}"[::-1]:
        if band_pos == '1':
            bands.append("n" + str(band_iter))
        band_iter += 1
    return bands


def check_scells_counters(counters: dict, counter_name: str, pcell_id: int = 0, bts_id: int = 0) -> bool:
    """
       Checks if last value of selected counters increased
       :param counters: Dictionary which contains cells counters.
       :param counter_name: Name of the counter, we would like to get value of
       :param cells_ids: Ids of cells to check counters on.
       :param bts_id:  Index of list containing all gNBs in test line configuration.
       :param pcell_id: Index of pcell_id
       :return:  True if all counters incremented otherwise false.
    """
    _tl = get_builtin_value(param_name="tl")
    bts_name = _tl.gnbs[int(bts_id)].global_bts_id
    cells_counters = counters['BTS']['MRBTS-{}'.format(bts_name)]['NRBTS-{}'.format(bts_name)]
    for cell_name, cell_counter in cells_counters.items():
        cell_id = int(cell_name.split('-')[-1])  # Extract the numeric part of the cell name
        if cell_id < 52 or cell_id > 58:  # Skip cells outside the range
            continue

        counter_dict = cell_counter['NCADU'][str(counter_name)]
        last_key = list(counter_dict)[-1]
        last_val = counter_dict[last_key]
        logging.info(last_val)

        if str(counter_name) == 'M55316C00042':
            if int(cell_name[-1]) == pcell_id:
                if last_val != 0:
                    return False
            else:
                if last_val <= 0:
                    return False
        elif str(counter_name) == 'M55316C00041':
            if last_val != 0:
                return False

    return True
