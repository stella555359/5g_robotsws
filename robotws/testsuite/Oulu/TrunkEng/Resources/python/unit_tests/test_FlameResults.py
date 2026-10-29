import unittest
import os
from testsuite.Oulu.TrunkEng.Resources.python import FlameResults
import re


class TestFlameResults(unittest.TestCase):

    @unittest.skip("No need to check every time")
    def test_save_crash_log(self):
        output_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "test_data")
        output = os.popen('tail -n 60 {}'.format(os.path.join(output_dir, "stdout.txt"))).read()
        FlameResults.save_crash_log(output, output_dir + "/results/")
        self.assertTrue(os.path.isfile(os.path.join(output_dir+"/results/", "crash_test.trl")))
        output2 = os.popen('tail -n 60 {}'.format(os.path.join(output_dir, "stdout2.txt"))).read()
        FlameResults.save_crash_log(output2, output_dir + "/results/")
        self.assertTrue(os.path.isfile(os.path.join(output_dir + "/results/", "crash_test2.trl")))

    def test_grep_counters(self):
        test_file_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "test_data")
        output = FlameResults.grep_counters(test_file_dir, "stdout_counter_report.txt")
        amount_elements = len(re.findall(r".*value.*id.*result.*", output))
        self.assertEqual(14, amount_elements)
