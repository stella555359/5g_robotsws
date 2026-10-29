import responses
import testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.collector_api.collector_api_client as cl
from unittest import TestCase

TEST_RUN_ID = '94c84be1-4313-4bf3-b156-10dad7b3edad'
create_test_run = {
    "result": "ok",
    "payload": {
        "test_run_id": TEST_RUN_ID,
        "timestamp": "2021-06-29T17:41:10.123456Z"
    }
}

stop_test_run = {
    "result": "ok",
    "payload": {
        "test_run_id": TEST_RUN_ID,
        "test_case_id": "465c8a60-99c7-4fe2-a9ef-a98ecff93f7f",
        "test_step": "1",
        "timestamp": "2021-03-29T14:34:00.123456Z",
        "bts_id": "12345",
        "sw_package": "SBTS00_ENB_9999_190719_001993",
        "sw_build": "SBTS00_ENB_9999_190719_001993",
        "test_phase_name": "test case 1"
    }
}


class TestDataCollectorApiClient(TestCase):

    @responses.activate
    def test_start_test_run(self):
        responses.add(responses.POST, 'http://localhost:8080/api/v1/testrun/',
                      json=create_test_run, status=200)
        dc_client = cl.CollectorApiClient()
        resp = dc_client.start()
        assert resp == create_test_run

    @responses.activate
    def test_stop_test_run(self):
        responses.add(responses.PUT, 'http://localhost:8080/api/v1/testrun/',
                      json=stop_test_run, status=200)
        dc_client = cl.CollectorApiClient()
        resp = dc_client.stop(TEST_RUN_ID)
        assert resp == stop_test_run
