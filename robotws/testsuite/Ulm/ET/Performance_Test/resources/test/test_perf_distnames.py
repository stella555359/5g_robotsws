"""test
"""
import logging

from testsuite.Ulm.ET.Performance_Test.resources.python import perf_distnames

logger = logging.getLogger(__name__)


def test_get_distnames(scf_dummy):
    """test
    """
    gnbid = perf_distnames.get_distnames(r"MRBTS-[0-9]+", scf=scf_dummy, connection='dummy')[0].split("-")[1]
    assert gnbid == '1234'


def test_get_nrbts_distnames(scf_dummy):
    """test
    """
    nrbts_distnames = perf_distnames.get_nrbts_distnames(scf=scf_dummy, connection='dummy')
    assert nrbts_distnames[0] == 'MRBTS-1234/NRBTS-1234'


def test_get_nrcell_distnames(scf_dummy):
    """test
    """
    nrbts_distnames = perf_distnames.get_nrcell_distnames(scf=scf_dummy, connection='dummy')
    assert nrbts_distnames[0] == 'MRBTS-1234/NRBTS-1234/NRCELL-1'
