# -*- coding: utf-8 -*-
"""
2022/06/22 first version by @author: sheng.1.ye@nokia.com
    The TestInfoChecker class is unittest and example class for InfoChecker.
2022/07/06 add filter_expression example, by Ye Sheng
2023/09/19 add example 10, by Ye Sheng

"""
import sys
import os
import unittest

try:
    from testsuite.Beijing.ET.common.resources.lib.info_checker import InfoChecker
except ModuleNotFoundError:
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from info_checker import InfoChecker


class TestInfoChecker(unittest.TestCase):

    def setUp(self):
        self.base_folder = os.path.dirname(__file__)
        self.test_folder = os.path.join(self.base_folder, r"logs")

    def test01_basic(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "basic.json"), self.base_folder)
        info_checker.run()

    def test02_filename_wildcard(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "filename_wildcard.json"), self.base_folder)
        info_checker.run()

    def test03_basic_fail(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "basic_fail.json"), self.base_folder)
        try:
            info_checker.run()
        except Exception as e:
            self.assertTrue("Failed Validation={'match_id': 0, 'assert_false': 'periodicityAndOffset==7'}" in str(e))
        else:
            self.fail("Exception is expected")

    def test04_two_files(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "two_files.json"), self.base_folder)
        info_checker.run()

    def test05_two_checks(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "two_checks.json"), self.base_folder)
        info_checker.run()

    def test06_use_variables(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "use_variables.json"), self.base_folder)
        info_checker.run()

    def test07_miss_validation(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "miss_validation.json"), self.base_folder)
        try:
            info_checker.run()
        except Exception as e:
            self.assertTrue("Validations are missing" in str(e))
        else:
            self.fail("Exception is expected")

    def test08_filter_expression(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "filter_expression.json"), self.base_folder)
        info_checker.run()

    def test09_egate_check_pucch_starting_prb(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "pucch_starting_prb.json"), self.base_folder)
        info_checker.run()

    def test10_cplane_e1f1(self):
        info_checker = InfoChecker(os.path.join(self.test_folder, "cplane_e1f1.json"), self.base_folder)
        info_checker.run()


if __name__ == '__main__':
    unittest.main()
