from collections import OrderedDict
import requests
import logging
from robot.libraries.BuiltIn import BuiltIn


logging.basicConfig(format="%(asctime)s : %(levelname)s - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)


def robot_logger(msg):
    BuiltIn().log(console=True, message=msg, level="INFO")


class wft_api:
    def __init__(self):
        self.access_key = "1rr68OUDVBboLWbUcSxcN4tyFyTt3vTFiibZTxKx"
        self.wft_url = "https://wft.int.net.nokia.com:8091/api/v1/"
        self.connection = ""

    def get_latest_gnb_build(self, branch=None, release_state=None, promotion_tags=None):
        if not release_state:
            release_state = ["RELEASED", "RELEASED_WITH_RESTRICTIONS"]
        if not promotion_tags:
            promotion_tags = ["RAN_5G_CIT"]
        list_of_promoted_sw = self.__promoted_gnb_build(branch, release_state, promotion_tags)
        sw = list_of_promoted_sw[0]
        robot_logger("\nLatest RAN_5G_CIT gNB build in WFT : {}".format(sw))
        return sw

    def get_latest_ap_build(self, branch=None, release_state=None):
        if not release_state:
            release_state = ["RELEASED", "RELEASED_WITH_RESTRICTIONS"]
        list_of_promoted_sw = self.__released_ap_build(branch, release_state)
        sw = list_of_promoted_sw[0].split('_')[1]
        robot_logger("\nLatest Released[_with_restrictions] AP build in WFT : {}".format(sw))
        return sw

    def __promoted_gnb_build(self, branch, release_state, promotion_tags):
        json_endpoint = "promotion.json"
        promoted_sw_json = {
            "items": "20",
            "sorting_field": "created_at",
            "sorting_direction": "DESC",
            "columns": {"0": {"id": "build.baseline"}, "1": {"id": "build|state"}},
            "view_filters_attributes": {
                "0": {
                    "column": "branch.title",
                    "operation": "eq",
                    "value": branch,
                },
                "1": {
                    "column": "promotion_tag.tag",
                    "operation": "eq_any",
                    "value": promotion_tags,
                },
                "2": {
                    "column": "build|state",
                    "operation": "eq_any",
                    "value": release_state,
                },
            },
            "access_key": self.access_key,
        }
        response = requests.post(url=self.wft_url + json_endpoint, json=promoted_sw_json).json()
        sw_list = list(OrderedDict.fromkeys([str(build["build.baseline"]) for build in response["items"]]))
        return sw_list

    def __released_ap_build(self, branch, release_state):
        json_endpoint = "build_branch.json"
        promoted_sw_json = {
            "page": "",
            "items": "20",
            "sorting_field": "created_at",
            "sorting_direction": "DESC",
            "columns": {"0": {"id": "version"}, "1": {"id": "delivery_date"}},
            "view_filters_attributes": {
                "0": {
                    "column": "branch.title",
                    "operation": "eq",
                    "value": branch,
                },
                "1": {
                    "column": "state",
                    "operation": "eq_any",
                    "value": release_state,
                },
            },
            "access_key": self.access_key,
        }
        response = requests.post(url=self.wft_url + json_endpoint, json=promoted_sw_json).json()
        sw_list = list(OrderedDict.fromkeys([str(build["version"]) for build in response["items"]]))
        return sw_list
