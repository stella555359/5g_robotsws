import random
import logging
import requests
import regex as re


def get_builds_from_API(number_of_builds, branch="SBTS00", number_of_search_builds=200):
    """
    Getting latest released builds via WFT API.

    :param number_of_builds: number of builds to return
    :param branch: branch name
    :param number_of_released_builds: number of builds to obtain from WFT (RELEASED/RELEASED_WITH_RESTRICTIONS status)

    :return: dict with <number_of_builds> 1)random builds,2)latest builds,3)builds within couple days (different FM SW)
    """
    number_of_builds = int(number_of_builds)
    builds_api = "https://wft.int.net.nokia.com/ext/builds?custom_filter[baseline]=SBTS" \
                 "&custom_filter[branch_names][]={}&custom_filter[sorting_field]=delivery_date" \
                 "&custom_filter[sorting_direction]=DESC&custom_filter[items]={}&custom_filter[state][]=released" \
                 "&custom_filter[state][]=released_with_restrictions"
    builds_api_response = requests.get(url=builds_api.format(branch, number_of_search_builds))
    builds_released = re.findall(r"{}[\w*]+".format(branch), builds_api_response.text)
    number_of_released_builds = len(builds_released)
    logging.debug("API response: {}".format(builds_api_response.text))
    logging.debug("Last {} builds released: {}".format(number_of_released_builds, builds_released))
    builds = [random.choice(builds_released) for _ in range(number_of_builds)]
    builds_same_sm = builds_released[:number_of_builds]
    builds_different_sm = []
    for i in range(number_of_builds):
        builds_different_sm.append(builds_released[i * (int(number_of_released_builds / number_of_builds))])
    builds_different_sm.reverse()
    return_builds = {"builds": builds, "builds_same_sm": builds_same_sm, "builds_different_sm": builds_different_sm}
    logging.debug("Builds used: {}".format(return_builds))
    return return_builds


def get_variables(number_of_builds, branch="SBTS00", number_of_search_builds=200):
    """
    Getting latest released builds via WFT API.

    :param number_of_builds: number of builds to return
    """
    return get_builds_from_API(number_of_builds, branch, number_of_search_builds)
