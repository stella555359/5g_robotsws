from __future__ import print_function
from builtins import object
import sys
import os
import pytest
# activate to run tests: be careful, this solution does NOT pass SANITY!
#
# path_test_file = os.path.abspath(__file__)
# path_test_dir = os.path.split(path_test_file)[0]
# project_path = os.path.split(path_test_dir)[0]
# sys.path.insert(0, project_path)
from ..OsTool import getSnapshotPath


class TestOsTool(object):

    def test_getSnapshotPath(self):
        result = getSnapshotPath("THEPATH", "PREF", True, "POST")
        assert 'THEPATH' in result
        assert 'PREF' in result
        assert 'POST' in result
        assert result is not "THEPATH/PREFPOST"
