import pytest
import os
import taf
import sys
# activate to run tests: be careful, this solution does NOT pass SANITY!
#
# path_test_file = os.path.abspath(__file__)
# path_test_dir = os.path.split(path_test_file)[0]
# project_path = os.path.split(path_test_dir)[0]
# sys.path.insert(0, project_path)
from ..ReadConfig import Release, Config, Ue, Var, printSystemInfo


class TestReadConfig(object):

    myrelease = Release('1.123.123')
    myconfig = Config()
    myvar = Var('name', 'source', 'isMandatory', 'isActive')
    myue = Ue('myUe')

    def test_basic(self):
        assert isinstance(self.myrelease, Release)
        assert isinstance(self.myconfig, Config)
        assert isinstance(self.myvar, Var)
        assert isinstance(self.myue, Ue)
        assert self.myconfig.configName == "fakeTLforTesting"

    def test_version(self):
        result = printSystemInfo()
        assert '3' in result
