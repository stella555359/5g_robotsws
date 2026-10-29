from __future__ import print_function
from builtins import object
import pytest
from ..StringTool import *


class TestStringTool(object):

    def test_timestamp(self):
        print(getDateTimeStamp())
        assert '20' in getDateTimeStamp()

    def test_toDecimalStr(self):
        assert '12' in toDecimalStr('0x000c')
        assert '1' in toDecimalStr('0x0000001')
        assert '0' in toDecimalStr('0x0000')
