import os
import importlib
import sys
from testsuite.Ulm.resources.Common.python import connect
import unittest  # type: ignore

try:
    import unittest.mock as mock
except ImportError:
    import mock  # type: ignore


def create_testline_configuration():
    path, _ = os.path.split(__file__)
    path = os.path.realpath(path)
    sys.path.append(path)

    tl_module = importlib.import_module("tl_config")
    return tl_module.tl


class TestConnect(unittest.TestCase):

    def test_get_test_pc_ip_for_remote_connection(self):
        tl = mock.MagicMock()
        gnb = mock.MagicMock()
        tl.gnbs = [gnb]
        node_id = 0
        node_type = "gnb"
        connect.get_test_pc_ip_for_remote_connection(tl, node_type, node_id)

    def test_get_test_pc_for_nodeb(self):
        tl = create_testline_configuration()
        test_pc = connect.get_test_pc_for_nodeb(tl=tl, nodeb=tl.gnbs[1])

        self.assertEqual(test_pc, tl.test_pcs[1])

    def test_setup_oam_http_session(self):
        gnb = mock.MagicMock()
        tl = mock.MagicMock()
        tl.gnbs = [gnb]

        with mock.patch("testsuite.Ulm.resources.Common.python.connect.os"):
            with mock.patch("testsuite.Ulm.resources.Common.python.connect.BuiltIn") as builtin:
                builtin.return_value.get_library_instance.return_value.get_sw_release_name.side_effect = [
                    RuntimeError(), "Release_1"]

                connect.setup_oam_http_session(tl)


if __name__ == '__main__':
    unittest.main()
