import os
import testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.sw_operations as sw_ops
from unittest import TestCase
from mock import patch, Mock
import taf.sbts.oam.coam.admin


class TestSwUpdate(TestCase):

    def test_update_bts_software(self):
        with \
                patch.object(taf.sbts.oam.coam.admin.admin, 'update_software',
                             Mock(return_value='Software update has been completed')), \
                patch('testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.sw_operations.' +
                      'ping_until_unavailable', return_value=True), \
                patch('testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.sw_operations.time.sleep',
                      return_value=False):
            status = sw_ops.update_bts_software("", None, 1, 'False')
            self.assertEqual(status, 'Software update has been completed')

    def test_update_bts_software_no_activation_reset_use_force(self):
        with \
                patch.object(taf.sbts.oam.coam.admin.admin, 'update_software',
                             Mock(return_value='Software update has been completed')), \
                patch.object(taf.sbts.oam.coam.admin.admin, 'reset_site', Mock(return_value='Completed')), \
                patch('testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.sw_operations.' +
                      'ping_until_unavailable', return_value=False):
            status = sw_ops.update_bts_software("", None, 1, 'True')
            self.assertEqual(status, 'Software update has been completed')

    def test_update_bts_software_no_activation_reset_no_force(self):
        with \
                patch.object(taf.sbts.oam.coam.admin.admin, 'update_software',
                             Mock(return_value='Software update has been completed')), \
                patch('testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.sw_operations.' +
                      'ping_until_unavailable', return_value=False):
            status = sw_ops.update_bts_software("", None, 1, 'False')
            self.assertEqual(status, 'Software update has been completed')

    def test_update_bts_software_failed(self):
        with patch.object(taf.sbts.oam.coam.admin.admin, 'update_software',
                          Mock(return_value='targetBd is not found')):
            status = sw_ops.update_bts_software("", None, 1, 'False')
            self.assertEqual(status, 'Fail')

    @patch('os.system', return_value=1)
    def test_ping_until_unavailable_no_reply(self, system_function):
        self.assertTrue(sw_ops.ping_until_unavailable())

    @patch('os.system', return_value=0)
    def test_ping_until_unavailable_reply(self, system_function):
        self.assertFalse(sw_ops.ping_until_unavailable(max_number_of_tries=1))

    def test_get_allowed_alarms_from_file(self):
        dir_path = os.path.dirname(os.path.realpath(__file__))
        alarms = sw_ops.get_allowed_alarms_from_file(os.path.join(dir_path, 'config/allowed_alarms.txt'))
        self.assertTrue(alarms, "Alarms table is empty")
