from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.regex import get_regex_match

import unittest


class TestGetRegexmatch(unittest.TestCase):
    def test_get_regex_match_return_passed_engine(self):

        def func():
            pass

        class Obj:
            pass

        f = func
        s = 'NONEXISTENT'
        o = Obj()
        assert get_regex_match(f) == f
        assert get_regex_match(s) == s
        assert get_regex_match(o) == o
