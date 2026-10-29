from lxml import html
import subprocess
import re
import os
import sys
import importlib
from robot.api import logger
import requests


artifactory_api_key = "AKCp5cc6qcfvRmnWFrznCzBbxvK73vsBJ8CCVPprVxPPTKzSMtqxsNi4TqaNpW59CTMpWwfzM"
artifactory_url = "https://artifactory-espoo1.int.net.nokia.com/artifactory/radio-factory-btssw-knives-local/"


def ls_artifactory_zip_files():
    ls_command = "curl -H 'X-JFrog-Art-Api:" + artifactory_api_key + "' -Ls " + artifactory_url
    command_output = subprocess.Popen(ls_command, shell=True, stdout=subprocess.PIPE).communicate()[0]
    tree = html.fromstring(command_output)
    files_list = tree.xpath('//a/text()')
    regex = re.compile(r'.*zip$')
    artifactory_knives_list = list(filter(regex.search, files_list))
    return artifactory_knives_list


def get_the_best_matching_knife_from_artifactory(sw_release, radio):
    available_knives_list = ls_artifactory_zip_files()
    logger.info("Knives found on Artifactory repository: ")
    logger.info(available_knives_list)
    available_radio_knives = list(filter(lambda knife: radio in knife, available_knives_list))
    logger.info("Knives matching radio:")
    logger.info(available_radio_knives)
    if not available_radio_knives:
        raise Exception("Knife for this radio is not available! The test will fail now.")
    perfect_match = list(filter(lambda knife: sw_release in knife, available_radio_knives))
    if perfect_match:
        logger.info("Perfect match <3 : " + perfect_match[0])
        return perfect_match[0]
    else:
        logger.warn(
            "Could not find radio knife matching SW release. Downloading this one: " + available_radio_knives[0])
        return available_radio_knives[0]


def download_knife_from_artifactory(sw_release, radio, download_path):
    best_knife_filename = get_the_best_matching_knife_from_artifactory(sw_release, radio)
    logger.console("Downloading " + best_knife_filename)
    download_command = (
        f"cd {download_path} && wget --continue --header 'X-JFrog-Art-Api:{artifactory_api_key}' "
        f"{artifactory_url}{best_knife_filename}")
    process = subprocess.Popen(download_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    logger.debug(f"WGET returned code {process.returncode}")
    if process.returncode == 0:
        logger.info(stdout.decode())
        logger.console("Download complete")
    else:
        logger.debug(stderr.decode())
        raise Exception(f"Download failed! WGET returned code {process.returncode}")
    return download_path + best_knife_filename


def download_fr_factory_sw_dictionary():
    download_command = (
            "cd " + os.path.dirname(__file__) +
            " && curl -C - -H 'X-JFrog-Art-Api:" + artifactory_api_key +
            "' -O " + artifactory_url + "fr_factory_sw_database.py"
    )
    logger.info("Downloading FR Factory SW dictionary to {0}".format(os.path.dirname(__file__)))
    command_output = subprocess.Popen(download_command,
                                      shell=True,
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.STDOUT).communicate()[0]
    logger.debug(command_output)
    config_py = importlib.import_module("fr_factory_sw_database")
    return config_py.FR_Factory_SW


def get_latest_promoted_build_for_branch(branch):
    access_key = "59Tc7CmEXbofWQ1A1h6bBIQPhXIitNOWT65bxiyI"
    url = ("https://wft.int.net.nokia.com:8091/ALL/api/v1/promotion.json?access_key=" + access_key +
           "&view[items]=1&view[sorting_field]=created_at&view[sorting_direction]=DESC&view[group_by]"
           "=promotion_tag.tag&view[columns[][id]]=branch.title&view[columns[][id]]=build.baseline&view[columns[][id]]"
           "=created_at&view[view_filters_attributes[33999848078554]][column]"
           "=active&view[view_filters_attributes[33999848078554]][operation]"
           "=eq&view[view_filters_attributes[33999848078554]]"
           "[value][]=1&view[view_filters_attributes[880374364999341]]"
           "[column]=promotion_tag.tag&view[view_filters_attributes[880374364999341]][operation]"
           "=eq&view[view_filters_attributes[880374364999341]][value][]=REGRESSION&view[view_filters_attributes"
           "[799598192158904]][column]=branch.title&view[view_filters_attributes[799598192158904]][operation]"
           "=eq&view[view_filters_attributes[799598192158904]][value][]=" + branch + "&")
    request = requests.get(url, stream=True, timeout=(10, 10))
    x = re.search(r'"build\.baseline":"(.*\d+)"', request.text)
    if not x:
        raise BaseException("This release has no candidates yet! WFT request output: " + request.text)
    return x.groups()[0]
