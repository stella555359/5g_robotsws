import testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.data_collector_handler.DataCollectorHandler as dc
import testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.collector_api.collector_api_client
from unittest import TestCase
from mock import patch, Mock

TEST_RUN_ID = "94c84be1-4313-4bf3-b156-10dad7b3edad"

start_run_ok = {
    "result": "ok",
    "payload": {
        "test_run_id": TEST_RUN_ID,
        "timestamp": "2021-06-29T17:42:10.123456Z"
    }
}


class TestDataCollectorHandler(TestCase):

    def setUp(self):
        self.col = dc.DataCollectorHandler()

    def test_create_test_run(self):
        with patch.object(testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.collector_api.
                          collector_api_client.CollectorApiClient, 'start', Mock(return_value=start_run_ok)):
            run_id = self.col.create_test_run()
            self.assertEqual(run_id, TEST_RUN_ID)

    def test_stop_created_test_run(self):
        with patch.object(testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.collector_api.
                          collector_api_client.CollectorApiClient, 'stop', Mock(return_value="")):
            self.col.stop_test_run(TEST_RUN_ID)
