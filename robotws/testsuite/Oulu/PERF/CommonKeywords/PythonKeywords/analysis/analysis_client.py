"""Client for analysis service REST API"""
import time
import requests
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter
from robot.api import logger


BASE_URL = "http://rsp-analysis-engine.ou.nsn-rdnet.net:8181/api/v1"
# BASE_URL = "http://dev-engine.analysis.dyn.nesc.nokia.net:8181/api/v1"
ANALYSIS_COMPLETE_TIMEOUT = 60
ANALYSIS_COMPLETE_POLL_INTERVAL = 10


class AnalysisClientException(Exception):
    """Generic client exception"""


class AnalysisClient:
    """Client for analysis service REST API"""

    def __init__(self):
        """Constructs the client"""
        self.session = requests.Session()
        self.session.trust_env = False
        retry_strategy = Retry(
            total=3,
            backoff_factor=10,
            status_forcelist=[429, 500, 502, 503, 504],
            method_whitelist=["POST", "GET"]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)

    def find_analysis(self, name=None, identifier=None):
        """Returns analysis object with the given name or identifier"""
        if name is not None:
            response = self.session.get(
                "{}/manage/analysis-group/?latest=true&name={}".format(BASE_URL, name), timeout=30
            )
        elif identifier is not None:
            response = self.session.get(
                "{}/manage/analysis-group/{}".format(BASE_URL, identifier), timeout=30
            )
        else:
            raise AnalysisClientException("Name or identifier is not valid")

        if response.status_code == requests.codes.ok:
            if name is not None and len(response.json()) > 1:
                raise AnalysisClientException(
                    "Found multiple analyses with name {}".format(name)
                )
            elif name is not None and len(response.json()) == 1:
                return response.json()[0]
            elif identifier is not None:
                return response.json()

        raise AnalysisClientException(
            "Analysis {} not found: {} {}".format(
                name or identifier, response.status_code, response.text
            )
        )

    def get_analysis_status(self, identifier):
        """Returns status for analysis run"""
        analysis = self.session.get(
            "{}/status/analysis-run/{}".format(BASE_URL, identifier), timeout=30
        ).json()
        return analysis["status"]

    def wait_for_analysis_to_complete(self, identifier):
        """Waits until analysis is complete"""
        start_time = time.time()
        analysis = {}
        while time.time() - start_time < ANALYSIS_COMPLETE_TIMEOUT:
            analysis = self.session.get(
                "{}/status/analysis-group-run/{}/?pretty=1".format(BASE_URL, identifier), timeout=30
            ).json()
            if analysis["status"] == "Finished":
                break
            time.sleep(ANALYSIS_COMPLETE_POLL_INTERVAL)
        if analysis["status"] != "Finished":
            logger.console("Analysis did not complete in {} seconds. Status: {}".format(
                ANALYSIS_COMPLETE_TIMEOUT, analysis["status"]))
        return analysis

    def trigger_analysis(self, analysis_id, bts_id, test_phase_name, test_run_id, sw_package, sw_build,
                         test_case_id=""):
        """Triggers analysis and returns its run identifier"""
        response = self.session.post(
            "{}/execute/".format(BASE_URL),
            json={
                "analysis_group": analysis_id,
                "data_context": {"bts_id": bts_id,
                                 "run_id": test_run_id,
                                 "case_id": test_case_id,
                                 "test_phase_name": test_phase_name,
                                 "sw_package": sw_package,
                                 "sw_build": sw_build},
            },
            timeout=30,
        )
        if response.status_code == requests.codes.created:
            return response.json()
        raise AnalysisClientException(
            "Failed to trigger analysis: {}".format(response.text)
        )


if __name__ == "__main__":

    # Client example use
    client = AnalysisClient()
    analysis = client.find_analysis(name="demo-analysis")
    analysis_run = client.trigger_analysis(analysis["id"],
                                           "12345",
                                           "Example",
                                           "d9d1b007-b83f-4ba0-ba74-b0b5f7d1723e",
                                           "SBTS20B_ENB_0000_001700_000000",
                                           "SBTS20B_ENB_0000_001700_000000",
                                           "d9d1b007-b83f-4ba0-ba74-b0b5f7d17xyz")
    finished_analysis = client.wait_for_analysis_to_complete(
        analysis_run["analysis_run_id"])
    print(finished_analysis)
