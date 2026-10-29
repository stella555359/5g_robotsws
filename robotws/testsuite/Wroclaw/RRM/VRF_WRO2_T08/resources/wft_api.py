import logging
import os.path
import shutil
import socket
from collections import OrderedDict

import requests
from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
from taf.sbts.oam.coam.admin import admin

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.testline_preparation.testline_preparation import \
    get_compatible_enb_build

scf = scf()
admin = admin()
logging.basicConfig(format="%(asctime)s : %(levelname)s - %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logging_separator = 45 * '-'


def robot_logger(msg):
    BuiltIn().log(console=True, message=msg, level="INFO")


class wft_api:
    def __init__(self):
        robot_logger("\n" + logging_separator)
        self.access_key = "1rr68OUDVBboLWbUcSxcN4tyFyTt3vTFiibZTxKx"
        self.wft_url = "https://wft.int.net.nokia.com:8091/api/v1/"
        self.connection = ""

    def __get_list_of_latest_builds(self, branch=None, release_state=None, promotion_tags=None):
        if not branch:
            robot_logger("Branch wasn't provided. Active SW branch will be used.")
            robot_logger("Active SW : {}".format(self.get_active_sw_version()))
            branch = self.__get_active_sw_branch()
            robot_logger("Active SW branch is : {}".format(branch))
        elif branch == "5G21A":
            branch = "21A_classicalbts"
        if not release_state:
            robot_logger("SW release state wasn't provided. Default criteria will be used")
            release_state = ["RELEASED", "RELEASED_WITH_RESTRICTIONS"]
        if promotion_tags:
            list_of_promoted_sw = self.__promoted_sw_when_tags_present(branch, release_state, promotion_tags)
        else:
            list_of_promoted_sw = self.__promoted_sw_when_tags_missing(branch, release_state)
        return list_of_promoted_sw

    def __promoted_sw_when_tags_present(self, branch, release_state, promotion_tags):
        robot_logger(logging_separator)
        robot_logger("SW search criteria:")
        robot_logger("Branch: {}".format(branch))
        robot_logger("Release State: {}".format(" or ".join(release_state)))
        robot_logger("Promotion Tags: {}".format(" or ".join(promotion_tags)))
        robot_logger(logging_separator)
        json_endpoint = "promotion.json"
        promoted_sw_json = {
            "items": "1000",
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

    def __promoted_sw_when_tags_missing(self, branch, release_state):
        robot_logger(logging_separator)
        robot_logger("No specific promotion tags were provided")
        robot_logger(logging_separator)
        robot_logger("SW search criteria:")
        robot_logger("Branch: {}".format(branch))
        robot_logger("Release State: {}".format(" or ".join(release_state)))
        robot_logger(logging_separator)
        json_endpoint = "build_branch.json"
        build_json = {
            "items": "100",
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
        response = requests.post(url=self.wft_url + json_endpoint, json=build_json).json()
        sw_list = list(OrderedDict.fromkeys([str(build["version"]) for build in response["items"]]))
        return sw_list

    def setup_admin_connection(self, admin_connection):
        self.connection = admin_connection

    def get_active_sw_version(self, ):
        active_sw_version = admin.get_sw_version(connection=self.connection)
        # active_sw_version = admin.get_software_info(alias=self.connection)["Active SW version"]
        if active_sw_version.split("_", 3)[2] in ['9999', '9990']:
            active_sw_version = "_".join(["SBTS00", active_sw_version.split("_", 1)[1]])
        if "5G" in active_sw_version.split("_", 1)[0]:
            release = active_sw_version.split("_", 1)[0]
            build_number = ".".join([_.lstrip("0") for _ in active_sw_version.split("_")[2::]])
            active_sw_version = "_".join([release, build_number])
        return active_sw_version

    def __get_active_sw_branch(self):
        branch = self.get_active_sw_version().split("_", 3)[0]
        if branch == "5G21A":
            branch = "21A_classicalbts"
        return branch

    def __get_download_link(self, sw_version, test_package=False):
        branch = sw_version.split("_")[0]
        endpoint = "{0}/CI_ENB/builds/{1}/storages/results.json?access_key={2}".format(
            branch, sw_version, self.access_key
        )
        response = requests.get(url=self.wft_url + endpoint).json()
        files_list = response[0]["storage"]["storage-items"]
        if "5G" in branch:
            if test_package:
                file_name = "AirScale-{}T1.zip".format(sw_version.split("_", 1)[1])
            else:
                file_name = "AirScale-{}.zip".format(sw_version.split("_", 1)[1])
            dw_link = [item["path"] for item in files_list if item["title"] == file_name]
            download_link = dw_link[0]
        elif "SBTS" in branch:
            if test_package:
                file_name = ("{}_release_BTSSM_downloadable_testpackage_T1_A54.zip".format(sw_version))
            else:
                file_name = "{}_release_BTSSM_downloadable_A54.zip".format(sw_version)
            dw_link = [item["path"] for item in files_list if item["title"] == file_name]
            download_link = dw_link[0].replace("lterel.es-si-s3-z2", "lterel.es-si-s3-z4")
        return download_link

    def get_latest_build(self, branch=None, release_state=None, promotion_tags=None):
        if branch:
            if branch == "5G21A":
                branch = "21A_classicalbts"
            build_list = self.__get_list_of_latest_builds(branch, release_state, promotion_tags)
            latest_build = self.__check_for_builds(build_list, branch, release_state, promotion_tags)
        else:
            branch = self.__get_active_sw_branch()
            build_list = self.__get_list_of_latest_builds(branch, release_state, promotion_tags)
            latest_build = self.__check_for_builds(build_list, branch, release_state, promotion_tags)
        return latest_build, branch

    def __check_for_builds(self, builds_list, branch, release_state, promotion_tags):
        if self.get_active_sw_version() != builds_list[0]:
            robot_logger("Latest build with given criteria : {}".format(builds_list[0]))
            build = builds_list[0]
        else:
            previous_build = self.get_previous_build(branch, release_state, promotion_tags)
            robot_logger("Latest build with given criteria is same as active software.")
            robot_logger("Previous build which match given criteria is chosen : {}".format(previous_build))
            build = previous_build
        return build

    def check_bts_mode(self, execdir, branch):
        try:
            mode = admin.get_bts_info(connection=self.connection)["gNbCuType"]
        except Exception:
            if branch is None:
                branch = self.__get_active_sw_branch()
            branch = 'trunk' if branch == 'SBTS00' else branch.replace('SBTS', '')
            scf.load_scf(execdir + '/custom-config/Wroclaw/{}/'.format(socket.gethostname().replace('-', '_')) +
                         branch + '/' + socket.gethostname().replace('-', '_').split('/')[-1] +
                         '_' + branch + '_5g.xml'
                         )
            mode = scf.get_value_from_scf(p_name="gNbCuType", list_name=None, index=0)
        return 'NSA' if 'NSA' in mode else 'SA'

    def find_enb_build(self, branch, gnb_build):
        return get_compatible_enb_build(branch, gnb_build)

    def get_previous_build(self, sw_version=None, release_state=None, promotion_tags=None):
        if not sw_version:
            sw_version = self.get_active_sw_version()
        branch = self.__get_sw_branch(sw_version)
        build_list = self.__get_list_of_latest_builds(branch, release_state, promotion_tags)
        sw_index = build_list.index(sw_version)
        robot_logger("Previous build which match given criteria : {}".format(build_list[sw_index + 1]))
        return build_list[sw_index + 1]

    def get_active_sw_test_package(self):
        return self.download_package(self.get_active_sw_version())

    def __get_sw_branch(self, sw_version=None):
        if not sw_version:
            branch = self.__get_active_sw_branch()
        else:
            branch = sw_version.split("_")[0]
            if branch == "5G21A":
                branch = "21A_classicalbts"
            elif str(sw_version.split("_", 3)[2]) == "9999":
                branch = "SBTS00"
            else:
                branch = sw_version.split("_")[0]
        return branch

    def update_to_specific_sw(self, sw_version, test_package=False, ):
        """
        Update software to specific one.
        :param sw_version: string with specific software version
        :param test_package: True if should be updated as test package; default: False
        """
        path_to_file = self.download_package(sw_version, test_package)
        admin.update_software(sw_package=path_to_file, timeout=2100, should_activate=True, alias=self.connection)

    def update_to_latest_build(self, branch=None, release_state=None, promotion_tags=None, ):
        """
        Update software to the latest available build.
        :param branch: string with branch name; default: None
        :param release_state: list containing accepted states; default: None
        :param promotion_tags: list of tags to be included in search; default: None
        :param connection: alias for already setup TAF admin
        """
        sw_version = self.get_latest_build(branch, release_state, promotion_tags)
        if sw_version == self.get_active_sw_version():
            robot_logger("Latest build is already installed. Downgrade to previous build is started")
            sw_version = self.get_previous_build(branch, release_state, promotion_tags)
        path_to_file = self.download_package(sw_version)
        robot_logger("Starting Update to build: {}".format(sw_version))
        admin.update_software(sw_package=path_to_file, timeout=2100, alias=self.connection)

    def update_to_latest_candidate_build(self, branch=None, release_state=None, promotion_tags=None, ):
        """
        Update software to the latest candidate build for specified criteria.
        :param branch: string with branch name; default:None
        :param release_state: list containing accepted states; default: None
        :param promotion_tags: list of tags to be included in search; default: None
        :param connection: alias for already setup TAF admin
        """
        default_tags = ["5G_RAN_CRT", "5G_RAN_CIT", "RAN_MRAT_CRT"]
        if promotion_tags:
            promotion_tags.extend(default_tags)
        if not promotion_tags:
            promotion_tags = default_tags
            robot_logger("Promotions tags for candidate weren't provided")
            robot_logger("Default tags will be used {}".format(" OR ".join(default_tags)))
        sw_version = self.get_latest_build(branch, release_state, promotion_tags)
        if sw_version == self.get_active_sw_version():
            robot_logger("Latest candidate build is already installed")
            return True
        path_to_file = self.download_package(sw_version)
        robot_logger("Starting Update to build: {}".format(sw_version))
        admin.update_software(sw_package=path_to_file, timeout=2100, alias=self.connection)

    def download_package(self, download_dir, sw_version, test_package=False):
        """
        Download .zip package with specified software version to the given directory.
        :param download_dir: string with path to selected download directory
        :param sw_version: string with specified software version
        :param test_package: TBA
        :return: path to the directory with downloaded package file
        """
        if not os.path.isdir(download_dir):
            os.mkdir(download_dir)
        link_to_file = self.__get_download_link(sw_version, test_package)
        local_file_path = str(download_dir) + link_to_file.split("/")[-1]
        if os.path.isfile(local_file_path):
            robot_logger("{} file already downloaded to {}".format(link_to_file.split("/")[-1], local_file_path))
        else:
            with requests.get(url=link_to_file, stream=True, timeout=10) as request:
                if request.status_code == 200:
                    robot_logger("Downloading a {} file to {}".format(link_to_file.split("/")[-1], local_file_path))
                    with open(local_file_path, "wb") as f:
                        shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
                else:
                    raise Exception("'get' request error")
        return local_file_path

    def download_candidate_package(self, download_dir, promotion_tags=None, package_type='latest', test_package=False):
        """
        Download package and return path to directory, where candidate package was downloaded
        :param download_dir: string with path to selected download directory
        :param promotion_tags: optional list of tags; if omitted, default tags will be used
        :param package_type: optional string to specify whether 'latest' or 'previous' package should be downloaded;
                             default value: 'latest'
        :param test_package: TBA
        :return path to directory with downloaded package
        """
        default_tags = ["5G_RAN_CRT", "5G_RAN_CIT", "RAN_MRAT_CRT"]
        robot_logger("Promotion tags for candidate provided: {}".format(promotion_tags))
        if promotion_tags:
            promotion_tags.extend(default_tags)
        if not promotion_tags:
            promotion_tags = default_tags
            robot_logger("Default tags will be used: {}".format(" OR ".join(default_tags)))
        if package_type == 'latest':
            candidate_build = self.get_latest_build(promotion_tags=promotion_tags)
        elif package_type == 'previous':
            candidate_build = self.get_previous_build(promotion_tags=promotion_tags)
        else:
            raise Exception("Wrong package type name provided. Try with 'latest' or 'previous'.")
        candidate_path = self.download_package(download_dir, sw_version=candidate_build, test_package=test_package)
        return candidate_path

    def download_active_sw_package(self):
        path_to_file = self.download_package(self.get_active_sw_version(), test_package=False)
        return path_to_file

    def download_active_sw_test_package(self):
        path_to_file = self.download_package(self.get_active_sw_version(), test_package=True)
        return path_to_file

    def downgrade_to_previous_build(self, release_state=None, promotion_tags=None, ):
        """
        Perform downgrade to previous build with specified criteria.
        :param release_state: list containing accepted states; default: None
        :param promotion_tags: list of tags to be included in search; default: None
        :param connection: alias for already setup TAF admin
        :return:
        """
        sw_version = self.get_previous_build(release_state, promotion_tags)
        path_to_file = self.download_package(sw_version)
        admin.update_software(sw_package=path_to_file, timeout=2100, connection=self.connection, should_activate=True)

    def downgrade_5g_site_to_previous_candidate(self):
        path_to_file = self.download_candidate_package(package_type='latest')
        admin.update_software(sw_package=path_to_file, timeout=2400, connection=self.connection)

    def check_if_active_sw_is_test_package(self, initial_sw=None):
        active_sw = self.get_active_sw_version()
        if str(initial_sw) == str(active_sw):
            is_test_package = False
        elif str(initial_sw) in str(active_sw):
            is_test_package = True
        else:
            raise Exception("Current SW is : {}, starting update to initial sw {}".format(active_sw, initial_sw))
        return is_test_package
