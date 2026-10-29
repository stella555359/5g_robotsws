import unittest
from testsuite.Oulu.TrunkEng.Resources.python.ReportCounters import ReportCounters


event_log = "2018-11-20 23:01:41.587 :: " \
            "------------------------------------------------------------------------------- 2018-11-20 " \
            "23:01:41.596 :: Update S1 induced cell deactivation time to 900 2018-11-20 23:01:41.607 :: [" \
            "BTS-22279 CLOUD_FR_F_[2]_[FRHA]_[3A]]: Requesting plan file update. 2018-11-20 23:01:42.308 :: [" \
            "BTS-22279 CLOUD_FR_F_[2]_[FRHA]_[3A]]: Sent /CDNL_BTSA_22279_3508145087.xml.gz (294 bytes) " \
            "2018-11-20 23:01:54.055 :: RPortal counters: {'value': '0', 'id': 'M8020C0', 'result': 'passed'} " \
            "{'value': '0', 'id': 'M8020C1', 'result': 'passed'} {'value': '0', 'id': 'M8020C2', " \
            "'result': 'passed'} {'value': '900', 'id': 'M8020C3', 'result': 'passed'} {'value': '0', " \
            "'id': 'M8020C4', 'result': 'passed'} {'value': '0', 'id': 'M8020C5', 'result': 'passed'} {" \
            "'value': '900', 'id': 'M8020C6', 'result': 'passed'} {'value': '0', 'id': 'M8020C0', " \
            "'result': 'passed'} {'value': '0', 'id': 'M8020C1', 'result': 'passed'} {'value': '1', " \
            "'id': 'M8020C2', 'result': 'passed'} {'value': '470', 'id': 'M8020C3', 'result': 'passed'} {" \
            "'value': '0', 'id': 'M8020C4', 'result': 'passed'} {'value': '430', 'id': 'M8020C5', " \
            "'result': 'passed'} {'value': '900', 'id': 'M8020C6', 'result': 'passed'} {'value': '1', " \
            "'id': 'M8020C0', 'result': 'passed'} {'value': '0', 'id': 'M8020C1', 'result': 'passed'} {" \
            "'value': '0', 'id': 'M8020C2', 'result': 'passed'} {'value': '644', 'id': 'M8020C3', " \
            "'result': 'passed'} {'value': '0', 'id': 'M8020C4', 'result': 'passed'} {'val2018-11-20 " \
            "23:01:54.058 :: ue': '256', 'id': 'M8020C5', 'result': 'passed'} {'value': '900', " \
            "'id': 'M8020C6', 'result': 'passed'} {'value': '0', 'id': 'M8020C0', 'result': 'passed'} {" \
            "'value': '0', 'id': 'M8020C1', 'result': 'passed'} {'value': '0', 'id': 'M8020C2', " \
            "'result': 'passed'} {'value': '900', 'id': 'M8020C3', 'result': 'passed'} {'value': '0', " \
            "'id': 'M8020C4', 'result': 'passed'} {'value': '0', 'id': 'M8020C5', 'result': 'passed'} {" \
            "'value': '900', 'id': 'M8020C6', 'result': 'passed'} {'value': '0', 'id': 'M8020C0', " \
            "'result': 'passed'} {'value': '0', 'id': 'M8020C1', 'result': 'passed'} {'value': '1', " \
            "'id': 'M8020C2', 'result': 'passed'} {'value': '469', 'id': 'M8020C3', 'result': 'passed'} {" \
            "'value': '0', 'id': 'M8020C4', 'result': 'passed'} {'value': '431', 'id': 'M8020C5', " \
            "'result': 'passed'} {'value': '900', 'id': 'M8020C6', 'result': 'failed'} {'value': '1', " \
            "'id': 'M8020C0', 'result': 'passed'} {'value': '0', 'id': 'M8020C1', 'result': 'passed'} {" \
            "'value': '0', 'id': 'M8020C2', 'result': 'passed'} {'value': '643', 'id': 'M802018-11-20 " \
            "23:01:54.073 :: 20C3', 'result': 'passed'} {'value': '0', 'id': 'M8020C4', 'result': 'passed'} {" \
            "'value': '257', 'id': 'M8020C5', 'result': 'passed'} {'value': '900', 'id': 'M8020C6', " \
            "'result': 'passed'} {'value': '0', 'id': 'M8020C0', 'result': 'passed'} {'value': '0', " \
            "'id': 'M8020C1', 'result': 'passed'} {'value': '0', 'id': 'M8020C2', 'result': 'passed'} {" \
            "'value': '900', 'id': 'M8020C3', 'result': 'passed'} {'value': '0', 'id': 'M8020C4', " \
            "'result': 'passed'} {'value': '0', 'id': 'M8020C5', 'result': 'passed'} {'value': '900', " \
            "'id': 'M8020C6', 'result': 'failed'} {'value': '0', 'id': 'M8020C0', 'result': 'passed'} {" \
            "'value': '0', 'id': 'M8020C1', 'result': 'passed'} {'value': '1', 'id': 'M8020C2', " \
            "'result': 'passed'} {'value': '470', 'id': 'M8020C3', 'result': 'passed'} {'value': '0', " \
            "'id': 'M8020C4', 'result': 'passed'} {'value': '430', 'id': 'M8020C5', 'result': 'passed'} {" \
            "'value': '900', 'id': 'M8020C6', 'result': 'passed'} {'value': '1', 'id': 'M8020C0', " \
            "'result': 'passed'} {'value': '0', 'id': 'M8020C1', 'result': 'pass2018-11-20 23:01:54.076 :: " \
            "ed'} {'value': '0', 'id': 'M8020C2', 'result': 'passed'} {'value': '645', 'id': 'M8020C3', " \
            "'result': 'passed'} {'value': '0', 'id': 'M8020C4', 'result': 'passed'} {'value': '255', " \
            "'id': 'M8020C5', 'result': 'passed'} {'value': '900', 'id': 'M8020C6', 'result': 'passed'} " \
            "2018-11-20 23:01:54.085 :: Checking syslog and SEM alarm histories. 2018-11-20 23:01:54.090 :: " \
            "Checking alarm history. 2018-11-20 23:01:54.095 :: Checking mandatory alarms. 2018-11-20 " \
            "23:01:54.100 :: Checking unallowed alarms. 2018-11-20 23:01:54.105 :: Alarm history check " \
            "completed. 2018-11-20 23:01:54.108 :: Alarm History - pass 2018-11-20 23:01:54.160 :: Trs trace " \
            "2018-11-20 23:01:59.471 :: [BTS-22279 CLOUD_FR_F_[2]_[FRHA]_[3A]]: Disconnecting... 2018-11-20 " \
            "23:01:59.847 :: [BTS-22279 CLOUD_FR_F_[2]_[FRHA]_[3A]]: Disconnected: Remote end closed socket. " \
            "2018-11-20 23:01:59.858 :: Wireshark 2018-11-20 23:01:59.875 :: [BTS-22279 CLOUD_FR_F_[2]_[" \
            "FRHA]_[3A]]: InfoModel disconnected. 2018-11-20 23:02:00.351 :: Test case success = pass " \
            "2018-11-20 23:02:00.354 :: " \
            "------------------------------------------------------------------------------- 2018-11-20 " \
            "23:02:00.356 :: Automated PM MME Connection Outage stopped 2018-11-20 23:02:00.359 :: GUID: " \
            "a8a81abd-bbeb-4752-9fb0-b9c887e5acd2 2018-11-20 23:02:00.362 :: VERSION: 8 2018-11-20 " \
            "23:02:00.365 :: ------------------------------------------------------------------------------- " \
            "2018-11-20 23:02:00.545 :: Current success verdict: True 2018-11-20 23:02:00.750 :: Writing " \
            "report: /home/ute/test_results/Flame5_TestSettings_20181120-210448" \
            "/PM_MME_Connection_Outtage_generic.html 2018-11-20 23:02:01.190 :: Finished running " \
            "'/home/ute/robotlte/testsuite/WMP/GRD/Oulu/LTE432/resources" \
            "/FSMr3_pm_MME_connection_outtage_FL18A.fws' 2018-11-20 23:02:01.190 :: Logs: " \
            "/home/ute/test_results/Flame5_TestSettings_20181120-210448 2018-11-20 23:02:01.190 :: Result: " \
            "PASS 2018-11-20 23:02:01.190 :: Delete temp workspace directory from /tmp/sfz03vji.keu... " \
            "2018-11-20 23:02:01.191 :: Temp workspace directory deleted... Stderr: " \
            "-------------------------------------------------------------------------------- OK, result was " \
            "pass. Actual test result: True"


class TestReportCounters(unittest.TestCase):

    def test_collect_counters_from_log(self):
        amount_M8020C0 = 9
        collect_counters = ReportCounters(log=event_log)
        counters_list = collect_counters.collect_counters_from_log()
        self.assertEqual(amount_M8020C0, len([counter for counter in counters_list if counter[1] == "M8020C0"]))

    def test_set_counters_from_tuple(self):
        amount_M8020C0 = 9
        collect_counters = ReportCounters(log=event_log)
        counters_list = collect_counters.collect_counters_from_log()
        counters = collect_counters.set_counters_from_tuple(counters_list)
        self.assertEqual(amount_M8020C0, len([counter for counter in counters if counter.id == "M8020C0"]))

    @unittest.skip("Only for debugging")
    def test_report_counters(self):
        collect_counters = ReportCounters(log=event_log)
        print(collect_counters.report_counters())
