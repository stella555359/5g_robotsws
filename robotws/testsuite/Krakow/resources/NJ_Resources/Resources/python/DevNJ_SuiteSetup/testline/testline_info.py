import json
import sys
import os
import time
import importlib
from enum import Enum
from robot.api import logger
try:
    from urllib.request import urlopen
except ImportError:
    pass

try:
    import urllib.request
except Exception as e:
    import urllib
from pprint import pprint

# testline info
"""
{
    "code": 0,
    "msg": "success",
    "data": {
        "testlines": [
            {
                "id": 1,
                "name": "7_21_CLOUD006TL006",
                "jenkins_node": "7_21_CLOUD006TL006",
                "configuration": "7_21_CLOUD006TL006",
                "tl_type": "CLOUD_5G_CLASSICAL_ASIR_ASIKL_ABILB1_AWHQJ_COAM",
                "antenne_profile": "2T2R",
                "host_id": 1,
                "product_id": 1,
                "ci_strategy": {
                    "id": 1,
                    "enable_ci": true,
                    "reload_vm": true,
                    "prepare_env": true,
                    "upgrade": true,
                    "ci_branches": [
                        1
                    ]
                }
            },
            {
                "id": 2,
                "name": "7_21_CLOUD030TL068",
                "jenkins_node": "7_21_CLOUD030TL068",
                "configuration": "7_21_CLOUD030TL068",
                "tl_type": "CLOUD_5G_CLASSICAL_ASIR_ASIKL_ABILB1_multiAPHA",
                "antenne_profile": "4T2R",
                "host_id": 2,
                "product_id": 1,
                "ci_strategy": {
                    "id": 2,
                    "enable_ci": true,
                    "reload_vm": false,
                    "prepare_env": false,
                    "upgrade": true,
                    "ci_branches": [
                        2,
                        3
                    ]
                }
            },
            {
                "id": 3,
                "name": "7_21_UTE5G031TL072",
                "jenkins_node": "7_21_UTE5G031TL072",
                "configuration": "7_21_UTE5G031TL072",
                "tl_type": "CLOUD_5G_CLASSICAL_ASIR_ASIKL_ABILB1_2xAWHQC",
                "antenne_profile": "4T2R",
                "host_id": 3,
                "product_id": 1,
                "ci_strategy": {
                    "id": 3,
                    "enable_ci": true,
                    "reload_vm": false,
                    "prepare_env": true,
                    "upgrade": true,
                    "ci_branches": [
                        1,
                        2,
                        3
                    ]
                }
            }
        ]
    }
}
"""


class SysTlLables(Enum):
    CDD = "cdd"
    DSS_DAS = "dss_das"
    DUALCORE_MASTER = "dualcore_master"
    DUALCORE_SLAVE = "dualcore_slave"
    RFS_ALL = "rfs_all"


class TestlineInfo(object):
    def __init__(self, testline, api_base):
        self._api_base = api_base
        self._tl_info = self.get_tl_info(testline.strip())
        self._tl_cfg = self.load_tl_cfg(testline.strip())

    def get_tl_info(self, testline_name):
        url = "{}/testlines".format(self._api_base)
        json_dict = self._get_json_from_api(url)
        if json_dict is None or json_dict["code"] != 0:
            raise Exception("Get testlines failed")

        testlines = json_dict["data"]["testlines"]
        for testline in testlines:
            if testline.get("jenkins_node") == testline_name:
                name = self.get_tl_product_name(testline.get("product_id"))
                testline["product_name"] = name

                name = self.get_tl_product_arch_name(testline.get("arch_id"))
                testline["product_arch_name"] = name

                name = self.get_tl_product_type_name(testline.get("type_id"))
                testline["product_type_name"] = name

                logger.info("testline: {}.".format(testline))
                break
        else:
            raise Exception("Get testline {} failed.".format(testline_name))
        return testline

    def get_tl_product_name(self, product_id):
        url = "{}/products".format(self._api_base)
        json_dict = self._get_json_from_api(url)

        if json_dict is None or json_dict["code"] != 0:
            raise Exception("Get testlines failed")

        products = json_dict["data"]["products"]
        for product in products:
            if product.get("id") == product_id:
                name = product.get("name")
                logger.info("testline product: {}.".format(name))
                return name

        raise Exception("failed to get testline product by id {}".format(product_id))

    def get_tl_product_arch_name(self, arch_id):
        url = "{}/arches".format(self._api_base)
        json_dict = self._get_json_from_api(url)

        if json_dict is None or json_dict["code"] != 0:
            raise Exception("Get testlines failed")

        arches = json_dict["data"]
        for arch in arches:
            if arch.get("id") == arch_id:
                name = arch.get("name")
                logger.info("testline product arch: {}.".format(name))
                return name

        raise Exception("failed to get testline product arch by id {}".format(arch_id))

    def get_tl_product_type_name(self, type_id):
        url = "{}/types".format(self._api_base)
        json_dict = self._get_json_from_api(url)

        if json_dict is None or json_dict["code"] != 0:
            raise Exception("Get testlines failed")

        types = json_dict["data"]
        for item in types:
            if item.get("id") == type_id:
                name = item.get("name")
                logger.info("testline product type: {}.".format(name))
                return name

        raise Exception("failed to get testline product type by id {}".format(type_id))

    def get_tl_upgrade_method(self):
        pass

    def get_tl_branch_upgrade_method(self):
        pass

    @staticmethod
    def _get_json_from_api(url):
        json_dict = None
        try_times = 5
        while try_times > 0:
            try_times -= 1
            try:
                response = urlopen(url)
                try:
                    json_dict = json.load(response)
                except ValueError as err:
                    logger.error("Fail to parse the JSON data returned by server. Error: {}".format(err))
                    time.sleep(5)
                    continue
                break
            except Exception as err:
                logger.error("Cannot connect to server. Error message: {}".format(err))
                logger.info("Retrying ...")
                time.sleep(5)

        return json_dict

    @staticmethod
    def load_tl_cfg(testline):
        tl_cfg = "/home/ute/testline_configuration"
        tl_file = os.path.join(tl_cfg, testline, "__init__.py")
        if not os.path.exists(tl_file):
            logger.warn("{} not found, return None".format(tl_file))
            return

        sys.path.append(tl_cfg)
        try:
            tl_module = importlib.import_module(testline)
        finally:
            sys.path.pop()

        logger.info("testline configuration: {}".format(tl_module.tl))
        return tl_module.tl

    @property
    def tl(self):
        return self._tl_cfg

    @property
    def tl_type(self):
        return self._tl_info.get("tl_type")

    @property
    def product_id(self):
        return self._tl_info.get("product_id")

    @property
    def product_name(self):
        return self._tl_info.get("product_name")

    @property
    def product_arch(self):
        return self._tl_info.get("product_arch_name")

    @property
    def product_type(self):
        return self._tl_info.get("product_type_name")

    @property
    def testline(self):
        return self._tl_info

    @property
    def labels(self):
        return self._tl_info.get("labels")

    @property
    def upgrade_method_id(self):
        return self._tl_info.get("ci_strategy").get("upgrade_method")

    def branch_upgrade_method_id(self, branch_id):
        ci_branches = self._tl_info.get("ci_strategy").get("ci_branches")
        for ci_branch in ci_branches:
            if ci_branch.get("branch_id") == branch_id:
                return ci_branch.get("upgrade_method")

    @property
    def name(self):
        return self._tl_info.get("name")

    @property
    def antenna(self):
        return self._tl_info.get("antenne_profile")


class SysCfgTlLabels(object):
    def __init__(self, api_base):
        self._api_base = api_base
        self._labels = self.get_labels()

    @staticmethod
    def _get_json_from_api(url):
        json_dict = None
        try_times = 5
        while try_times > 0:
            try_times -= 1
            try:
                response = urlopen(url)
                try:
                    json_dict = json.load(response)
                except ValueError as err:
                    logger.error("Fail to parse the JSON data returned by server. Error: {}".format(err))
                    time.sleep(5)
                    continue
                break
            except Exception as err:
                logger.error("Cannot connect to server. Error message: {}".format(err))
                logger.info("Retrying ...")
                time.sleep(5)

        return json_dict

    def get_labels(self):
        url = "{}/testlines/labels".format(self._api_base)
        json_dict = self._get_json_from_api(url)

        if json_dict is None or json_dict["code"] != 0:
            raise Exception("Get testlines failed.")

        lables = json_dict["data"]
        logger.info(lables)
        return lables

    @property
    def tl_labels(self):
        return self._labels


class SysCfgUpgradeMethods(object):
    def __init__(self, api_base):
        self._api_base = api_base
        self._upgrade_method = self.get_upgrade_method()

    @staticmethod
    def _get_json_from_api(url):
        json_dict = None
        try_times = 5
        while try_times > 0:
            try_times -= 1
            try:
                response = urlopen(url)
                try:
                    json_dict = json.load(response)
                except ValueError as err:
                    logger.error("Fail to parse the JSON data returned by server. Error: {}".format(err))
                    time.sleep(5)
                    continue
                break
            except Exception as err:
                logger.error("Cannot connect to server. Error message: {}".format(err))
                logger.info("Retrying ...")
                time.sleep(5)

        return json_dict

    def get_upgrade_method(self):
        url = "{}/ci/upgrade/methods".format(self._api_base)
        json_dict = self._get_json_from_api(url)

        if json_dict is None or json_dict["code"] != 0:
            raise Exception("Get upgrade methods failure.")

        data = json_dict["data"]
        logger.info("upgrade method: {}".format(data))
        return data

    @property
    def upgrade_method(self):
        return self._upgrade_method

    @property
    def default_upgrade_method(self):
        for item in self._upgrade_method:
            if item.get("name") == "standard":
                return item


class SysCfgBranches(object):
    def __init__(self, api_base):
        self._api_base = api_base

    @staticmethod
    def _get_json_from_api(url):
        json_dict = None
        try_times = 5
        while try_times > 0:
            try_times -= 1
            try:
                response = urlopen(url)
                try:
                    json_dict = json.load(response)
                except ValueError as err:
                    logger.error("Fail to parse the JSON data returned by server. Error: {}".format(err))
                    time.sleep(5)
                    continue
                break
            except Exception as err:
                logger.error("Cannot connect to server. Error message: {}".format(err))
                logger.info("Retrying ...")
                time.sleep(5)

        return json_dict

    def get_branchs_info(self, product_id):
        url = "{}/product/id/{}/branches".format(self._api_base, product_id)
        json_dict = self._get_json_from_api(url)

        if json_dict is None or json_dict["code"] != 0:
            raise Exception("Get upgrade methos failure.")

        data = json_dict["data"]
        logger.info("Branches info: {}".format(data))
        return data


if __name__ == "__main__":
    testline_obj = TestlineInfo("7_21_UTE5G034TL087", "http://10.66.11.27/dashboard/s/api")
    print("================================")
    pprint(testline_obj.tl)
    print("================================")
    pprint(testline_obj.testline)
    print("================================")

    labels_obj = SysCfgTlLabels("http://10.66.11.27/dashboard/s/api")
    pprint(labels_obj.tl_labels)
    print("================================")

    upgrade_obj = SysCfgUpgradeMethods("http://10.66.11.27/dashboard/s/api")
    pprint(upgrade_obj.upgrade_method)
    print("================================")

    branch_obj = SysCfgBranches("http://10.66.11.27/dashboard/s/api")
    pprint(branch_obj.get_branchs_info(product_id="1"))
    print("================================")
