import requests
import xml.etree.ElementTree as Et


def get_latest_released_build_name(branch):
    builds_wft_api = "https://wft.int.net.nokia.com/ext/builds?custom_filter[baseline]={}" \
                     "&custom_filter[branch_names][]={}&custom_filter[sorting_field]=delivery_date" \
                     "&custom_filter[sorting_direction]=DESC&custom_filter[items]=1" \
                     "&custom_filter[state][]=released&custom_filter[state][]=released_with_restrictions"

    builds_wft_api_response = requests.get(url=builds_wft_api.format(branch, branch))
    xml_root = Et.fromstring(builds_wft_api_response.text)
    return xml_root[0][1].text
