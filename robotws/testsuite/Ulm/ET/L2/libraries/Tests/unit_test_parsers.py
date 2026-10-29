import logging
import unittest

from testsuite.Ulm.ET.L2.libraries.json_reader import JsonReader
from testsuite.Ulm.ET.L2.libraries.parsers import LogsTracesParser

# logging.basicConfig(level=Warning)


class TestLogsTracesParser(unittest.TestCase):
    def setUp(self) -> None:
        return super().setUp()

    def test_logs_and_traces_creation(self):
        reader_object = JsonReader(relative_path_to_json="Tests/Test_Data/test_config.json")
        logs_and_traces_parser = LogsTracesParser(reader_object, True)
        self.assertIsInstance(logs_and_traces_parser, LogsTracesParser)

    def test_traces_bip_delay_longer_then_tti(self):
        reader_object = JsonReader(relative_path_to_json="Tests/Test_Data/test_config.json")
        logs_and_traces_parser = LogsTracesParser(reader_object, True)
        logs_and_traces_flags = logs_and_traces_parser.logs_and_traces_flags
        self.assertEqual(logs_and_traces_flags["BIPTrace"]["stop_delay_sec"], 15)
        self.assertEqual(logs_and_traces_flags["TTITrace"]["stop_delay_sec"], 0)

    def test_traces_tti_delay_longer_than_bip(self):
        reader_object = JsonReader(relative_path_to_json="Tests/Test_Data/test_config.json")
        logs_and_traces_parser = LogsTracesParser(reader_object, True)
        logs_and_traces_flags = logs_and_traces_parser.logs_and_traces_flags
        logs_and_traces_parser.reader_object.logs_and_traces["TTITrace"]["stop_point"] = "after_detach"
        logs_and_traces_parser.reader_object.logs_and_traces["TTITrace"]["stop_delay_sec"] = 15
        logs_and_traces_parser.reader_object.logs_and_traces["BIPTrace"]["stop_point"] = "after_detach"
        logs_and_traces_parser.reader_object.logs_and_traces["BIPTrace"]["stop_delay_sec"] = 5
        logs_and_traces_flags = logs_and_traces_parser.logs_and_traces_flags
        self.assertEqual(logs_and_traces_flags["BIPTrace"]["stop_delay_sec"], 5)
        self.assertEqual(logs_and_traces_flags["TTITrace"]["stop_delay_sec"], 10)

    def test_traces_tti_and_bip_different_stop_location(self):
        reader_object = JsonReader(relative_path_to_json="Tests/Test_Data/test_config.json")
        logs_and_traces_parser = LogsTracesParser(reader_object, True)
        logs_and_traces_flags = logs_and_traces_parser.logs_and_traces_flags
        logs_and_traces_parser.reader_object.logs_and_traces["TTITrace"]["stop_point"] = "after_traffic"
        logs_and_traces_parser.reader_object.logs_and_traces["TTITrace"]["stop_delay_sec"] = 15
        logs_and_traces_parser.reader_object.logs_and_traces["BIPTrace"]["stop_point"] = "after_detach"
        logs_and_traces_parser.reader_object.logs_and_traces["BIPTrace"]["stop_delay_sec"] = 5
        logs_and_traces_flags = logs_and_traces_parser.logs_and_traces_flags
        self.assertEqual(logs_and_traces_flags["BIPTrace"]["stop_delay_sec"], 5)
        self.assertEqual(logs_and_traces_flags["TTITrace"]["stop_delay_sec"], 15)

    def test_no_warning_logged_if_both_delays_are_zero(self):
        reader_object = JsonReader(relative_path_to_json="Tests/Test_Data/test_config.json")
        logs_and_traces_parser = LogsTracesParser(reader_object, True)
        logs_and_traces_flags = logs_and_traces_parser.logs_and_traces_flags
        logs_and_traces_parser.reader_object.logs_and_traces["TTITrace"]["stop_point"] = "after_traffic"
        logs_and_traces_parser.reader_object.logs_and_traces["TTITrace"]["stop_delay_sec"] = 0
        logs_and_traces_parser.reader_object.logs_and_traces["BIPTrace"]["stop_point"] = "after_traffic"
        logs_and_traces_parser.reader_object.logs_and_traces["BIPTrace"]["stop_delay_sec"] = 0
        with self.assertLogs(level="INFO") as cm:
            logs_and_traces_flags = logs_and_traces_parser.logs_and_traces_flags
            self.assertEqual(cm.output, ['INFO:root:Since TTI Trace and BIP Trace stop locations are the same: The '
                                         'stop delays for the TTI Trace and BIP Trace are as calculated as follows -> '
                                         'delaying 0 s before BIP Trace and 0 s before TTI Trace.',
                                         'INFO:root:adjusted tti-delay: 0',
                                         'INFO:root:adjusted bip-delay: 0'])


if __name__ == '__main__':
    suite = unittest.TestSuite()
    suite = unittest.TestLoader().loadTestsFromTestCase(TestLogsTracesParser)
    unittest.TextTestRunner(verbosity=2).run(suite)
