from __future__ import print_function
from builtins import object
import pytest
from ..StringTool import *
# activate to run tests: be careful, this solution does NOT pass SANITY!
#
# path_test_file = os.path.abspath(__file__)
# path_test_dir = os.path.split(path_test_file)[0]
# project_path = os.path.split(path_test_dir)[0]
# sys.path.insert(0, project_path)


class TestStringTool(object):

    def test_timestamp(self):
        print(getDateTimeStamp())
        assert '20' in getDateTimeStamp()

    def test_toDecimalStr(self):
        assert '12' in toDecimalStr('0x000c')
        assert '1' in toDecimalStr('0x0000001')
        assert '0' in toDecimalStr('0x0000')
