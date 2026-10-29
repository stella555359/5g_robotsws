import json
import logging
import time
from pprint import pformat, pprint

import Pyro4
import requests

logger = logging.getLogger("lab_scanner")
logger.setLevel("WARN")
logger.addHandler(logging.StreamHandler())


DATABASE_FILE = "lab_scanner_results.json"
MIN_RSRP = float("-inf")
MIN_RSRQ = float("-inf")


class LabScannerClient:
    def __init__(self, host, port):
        self.uri = f"PYRO:LAB_SCANNER@{host}:{port}"
        self._proxy = Pyro4.Proxy(uri=self.uri)
        self._scout_cell_testline_endpoint = (
            "https://scout.nsn-rdnet.net/future/api/v1/testlines/?filter[infomodel][cells.*.*][jpq][of]="
            "{global_cell_id}&include=user&apitoken="
        )
        self._database_endpoint = "http://10.44.236.194:8000/api/cells"
        self._proxy.set_min_rsrp(MIN_RSRP)
        self._proxy.set_min_rsrq(MIN_RSRQ)

    def connect_qxdm(self, com_port):
        return self._proxy.connect_to_qxdm(com_port)

    def start_logging(self):
        return self._proxy.start_logging()

    def stop_logging(self):
        return self._proxy.stop_logging()

    def get_report(self, timeout=20):
        cell_report = self._proxy.get_report(timeout)
        full_report = []
        for cell in cell_report:
            if "identity" in cell:
                tl_data = self.poll_scout(cell["identity"])
                full_report.append(tl_data | {"cell": cell})
            else:
                full_report.append({"cell": cell | {"identity": "unknown"}})
        return full_report

    def shutdown(self):
        return self._proxy.shutdown()

    def teardown(self):
        return self._proxy.teardown()

    def clear_data_queue(self):
        return self._proxy.clear_data_queue()

    def poll_scout(self, cell_id):
        with requests.get(url=self._scout_cell_testline_endpoint.format(global_cell_id=cell_id)) as request:
            if request.status_code != 200:
                logger.error(f"Failed to receive data from SCOUT: HTTP request returned code {request.status_code}")
                raise requests.RequestException(f"'GET' request from SCOUT returned code {request.status_code}")
            data = request.json()
        if not data["data"]:
            logger.warning(f"Could not find any testline with cell_id = {cell_id} in SCOUT!")
            return {}
        testlines = []
        for scout_testline in data["data"]:
            infomodel = scout_testline["attributes"]["infomodel"]
            user_id = scout_testline["relationships"]["user"]["data"]["id"]
            user_name, user_mail = self._extract_personal_data_by_id(user_id, data)
            testline = {
                "bts": {
                    "mplane": infomodel["mplane"],
                    "name": infomodel["bts_name"],
                    "scout_link": scout_testline["links"]["self"],
                },
                "user": {"name": user_name, "email": user_mail},
            }
            testlines.append(testline)
        if len(testlines) > 1:
            testlines = self._remove_ute_user_if_duplicate_testline(testlines)
        if len(testlines) > 1:
            logger.warning(
                f"Found {len(testlines)} testlines in SCOUT with provided cell_id ({cell_id})! \n"
                f"Testlines: {pformat(testlines)}"
            )
        return testlines[0]

    @staticmethod
    def _extract_personal_data_by_id(user_id, data):
        for user in data["included"]:
            if user["id"] == user_id:
                return user["attributes"]["display_name"], user["attributes"]["email"]
        raise ValueError(f"No user with id {user_id} found in provided data")

    @staticmethod
    def _remove_ute_user_if_duplicate_testline(testlines):
        idx_to_be_removed = set()
        for i in range(len(testlines)):
            for j in range(i + 1, len(testlines)):
                if testlines[i] == testlines[j]:
                    continue
                if (
                    testlines[i]["bts"]["mplane"] == testlines[j]["bts"]["mplane"]
                    and testlines[i]["bts"]["name"] == testlines[j]["bts"]["name"]
                ):
                    if testlines[i]["user"]["email"] == "ute_inactive_mail@nokia.com":
                        idx_to_be_removed.add(i)
                    if testlines[j]["user"]["email"] == "ute_inactive_mail@nokia.com":
                        idx_to_be_removed.add(j)
        return [testline for idx, testline in enumerate(testlines) if idx not in idx_to_be_removed]

    def post_cell_report(self, cell_report):
        for single_report in cell_report:
            if single_report["cell"]["identity"] == "unknown" or "stats" not in single_report["cell"]:
                continue
            report = self.prepare_post_data(single_report)
            headers = {"Content-Type": "application/json", "Accept": "*/*"}
            response = requests.post(url=self._database_endpoint, data=report, headers=headers)
            if response.status_code not in (200, 201):
                logger.error(
                    f"Error while posting cell report; Server response status: {response.status_code}, "
                    f"response: {response.text}"
                )

    @staticmethod
    def prepare_post_data(report):
        return json.dumps(
            {
                "identity": str(report["cell"]["identity"]),
                "pci": int(report["cell"]["pci"]),
                "rsrp": str(report["cell"].get("stats", dict()).get("rsrp", dict()).get("avg", "0")),
                "owner": report.get("user", dict()).get("email", "not_found"),
                "scout_link": report.get("bts", dict()).get("scout_link", "not_found"),
            }
        )


if __name__ == "__main__":
    client = LabScannerClient("10.45.172.248", 9091)
    try:
        client.connect_qxdm("COM3")
        client.start_logging()
        while True:
            report = client.get_report()
            if report:
                pprint(report, indent=4)
                print(60 * "*")
                client.post_cell_report(report)
            time.sleep(20)
    finally:
        client.shutdown()
