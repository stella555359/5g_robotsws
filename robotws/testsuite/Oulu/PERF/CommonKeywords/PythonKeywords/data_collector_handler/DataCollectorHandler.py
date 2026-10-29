import json
from datetime import datetime
from time import sleep
from robot.api import logger
from testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.\
    analysis.analysis_client import (
        AnalysisClient, AnalysisClientException
    )
from testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.\
    collector_api.collector_api_client import (
        CollectorApiClient, CollectorApiClientException
    )


class DataCollectorHandler(object):

    BOLD_GREEN = "\x1b[32;1m"
    BOLD_RED = "\x1b[31;1m"
    RESET_COLOR = "\x1b[0m"

    def __init__(self):
        self._collector_api_client = CollectorApiClient()

    def create_test_run(self, run_id=None):
        try:
            test_run_response = self._collector_api_client.start(run_id=run_id)
            run_id = test_run_response["payload"]["test_run_id"]
            logger.console('New test run created \"{}\"'.format(run_id))
            return run_id
        except CollectorApiClientException as err:
            logger.console(err)

    def start_data_collectors(self, run_id=None, case_id=None, step_id=None, phase_name=None):
        logger.console('Starting data collection for test case \"{}\" in test run \"{}\"'.format(phase_name, run_id))
        try:
            test_start_response = self._collector_api_client.start(run_id=run_id, case_id=case_id,
                                                                   step_id=step_id, phase_name=phase_name)
            logger.console('Test case ID: \"{}\"'.format(test_start_response["payload"]["test_case_id"]))
            return test_start_response["payload"]
        except CollectorApiClientException as err:
            logger.console(err)

    def stop_data_collectors(self, run_id=None, case_id=None, step_id=None, phase_name=None):
        logger.console('Stopping data collection for test case \"{}\" in test run \"{}\"'.format(phase_name, run_id))
        try:
            _ = self._collector_api_client.stop(run_id=run_id, case_id=case_id, step_id=step_id)
        except CollectorApiClientException as err:
            logger.console(err)

    def stop_test_run(self, run_id):
        logger.console('Stopping test run \"{}\"'.format(run_id))
        try:
            _ = self._collector_api_client.stop(run_id=run_id)
        except CollectorApiClientException as err:
            logger.console(err)

    def run_analysis(self, analysis_template, bts_id, test_phase_name, test_run_id, sw_package, sw_build,
                     test_case_id=""):
        logger.console("Calling analysis service...")
        client = AnalysisClient()
        try:
            analysis_group = client.find_analysis(name=analysis_template)
            analysis_group_run = client.trigger_analysis(analysis_group["id"],
                                                         bts_id,
                                                         test_phase_name,
                                                         test_run_id,
                                                         sw_package,
                                                         sw_build,
                                                         test_case_id=test_case_id)
            finished_analysis = client.wait_for_analysis_to_complete(analysis_group_run["analysis_group_run_id"])
            logger.console("Analysis execution done.")
            return finished_analysis
        except AnalysisClientException as err:
            logger.console('Analysis execution failed: {}'.format(err))
            return {"result": "Failed", "status": err}

    def log_results(self, result):
        if result:
            color = self.BOLD_GREEN if result["result"] == "Passed" else self.BOLD_RED
            logger.console("Analysis execution Result: {}, Status: {}".format(
                color+result["result"]+self.RESET_COLOR,
                result["status"]))
            try:
                for set_runs in result["analysis_set_runs"]:
                    color = self.BOLD_GREEN if set_runs["result"] == "Passed" else self.BOLD_RED
                    logger.console("Set: {}, Result {}, Status: {}".format(
                        set_runs["analysis_set"],
                        color+set_runs["result"]+self.RESET_COLOR,
                        set_runs["status"]))
                    for analysis in set_runs["analysis_runs"]:
                        color = self.BOLD_GREEN if analysis["result"] == "Passed" else self.BOLD_RED
                        logger.console(" |---> Analysis: {}, Result {}, Status: {}".format(
                            analysis["analysis"],
                            color+analysis["result"]+self.RESET_COLOR,
                            analysis["status"]))
            except KeyError as e:
                logger.console(e)

    def write_result_to_file(self, file, data):
        with open(file, 'w') as f:
            json.dump(data, f, indent=4)

    def check_start_time(self):
        dt = datetime.now()
        minute = dt.minute
        wait_time = 0
        if minute == 0:
            wait_time = 1
        elif minute >= 10 and minute <= 15:
            wait_time = 15-minute+1
        elif minute >= 25 and minute <= 30:
            wait_time = 30-minute+1
        elif minute >= 40 and minute <= 45:
            wait_time = 45-minute+1
        elif minute >= 55 and minute <= 59:
            wait_time = 60-minute+1
        if wait_time > 0:
            logger.console("Waiting {} minutes to start data collection".format(wait_time))
            sleep(wait_time*60)
