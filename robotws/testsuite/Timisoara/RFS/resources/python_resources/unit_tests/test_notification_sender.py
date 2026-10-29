# -*- coding: utf-8 -*-
"""
Unit tests for notification_sender module.
"""

import notification_sender
import unittest
from unittest.mock import patch, MagicMock, mock_open, call
import sys
import os
import json

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Mock the external dependencies before importing
sys.modules['robot'] = MagicMock()
sys.modules['robot.libraries'] = MagicMock()
sys.modules['robot.libraries.BuiltIn'] = MagicMock()
sys.modules['taf'] = MagicMock()
sys.modules['taf.ul'] = MagicMock()
sys.modules['taf.ul.sc'] = MagicMock()
sys.modules['taf.ul.sc.perf'] = MagicMock()
sys.modules['taf.ul.sc.perf.messenger'] = MagicMock()
sys.modules['taf.ul.sc.perf.messenger.messenger'] = MagicMock()


class TestNotificationSender(unittest.TestCase):
    """Test cases for notification_sender module functions."""

    def setUp(self):
        """Set up test fixtures."""
        self.mock_builtin = MagicMock()
        self.mock_messenger = MagicMock()
        self.mock_message = MagicMock()

        # Sample test data
        self.sample_cm_execution_id = "test_execution_123"
        self.sample_execution_link = "http://jenkins.com/job/test/123"
        self.sample_tl_owner = "test.user@nokia.com"
        self.sample_testline = "TEST_LINE_01"
        self.sample_test_name = "Test_Sample_Function"
        self.sample_suite_source = "/path/to/test/suite.robot"

    @patch('notification_sender.subprocess.call')
    @patch('notification_sender.BuiltIn')
    def test_send_teams_channel_notification_success(self, mock_builtin, mock_subprocess):
        """Test successful teams channel notification."""
        mock_builtin.return_value = self.mock_builtin

        notification_sender._send_teams_channel_notification(
            self.sample_cm_execution_id)

        expected_command = (r'echo "put /opt/ute/execution.context.json test_execution_123.json"'
                            r' | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/')
        mock_subprocess.assert_called_once_with(expected_command, shell=True)

    @patch('notification_sender.subprocess.call')
    @patch('notification_sender.BuiltIn')
    def test_send_teams_channel_notification_no_execution_id(self, mock_builtin, mock_subprocess):
        """Test teams channel notification with no execution ID."""
        mock_builtin.return_value = self.mock_builtin

        notification_sender._send_teams_channel_notification(None)

        mock_subprocess.assert_not_called()
        self.mock_builtin.log_to_console.assert_called_once_with(
            "Teams channel notification could not be sent!"
            "CM_EXECUTION_ID variable not available.\nEntering stop&fix anyway"
        )

    @patch('notification_sender.subprocess.call')
    @patch('notification_sender.BuiltIn')
    def test_send_teams_channel_notification_exception(self, mock_builtin, mock_subprocess):
        """Test teams channel notification with subprocess exception."""
        mock_builtin.return_value = self.mock_builtin
        mock_subprocess.side_effect = Exception("Subprocess error")

        notification_sender._send_teams_channel_notification(
            self.sample_cm_execution_id)

        self.mock_builtin.log_to_console.assert_called_once()
        args = self.mock_builtin.log_to_console.call_args[0][0]
        self.assertIn("Teams channel notification could not be sent!", args)
        self.assertIn("Subprocess error", args)

    @patch('notification_sender.Messenger')
    @patch('notification_sender.Message')
    @patch('notification_sender.BuiltIn')
    def test_send_email_notification_default_params(self, mock_builtin, mock_message_class, mock_messenger):
        """Test email notification with default parameters."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.side_effect = [
            self.sample_testline,  # TESTLINE_NAME
            self.sample_test_name,  # TEST_NAME
            self.sample_suite_source  # SUITE SOURCE
        ]

        mock_message_instance = MagicMock()
        mock_message_class.return_value = mock_message_instance

        notification_sender._send_email_notification()

        # Verify BuiltIn variable calls
        expected_calls = [
            call('${TESTLINE_NAME}', 'NA'),
            call('${TEST_NAME}', 'NA'),
            call('${SUITE SOURCE}', 'NA')
        ]
        self.mock_builtin.get_variable_value.assert_has_calls(expected_calls)

        # Verify Message creation
        mock_message_class.assert_called_once()
        call_kwargs = mock_message_class.call_args[1]
        self.assertEqual(call_kwargs['From'],
                         'i_btsauto_dev_tsr@internal.nsn.com')
        self.assertEqual(call_kwargs['To'],
                         'i_mn_ran_vrf_rfs_all@internal.nsn.com')
        self.assertEqual(call_kwargs['CC'],
                         'i_btsauto_dev_tsr@internal.nsn.com')
        self.assertEqual(call_kwargs['Subject'],
                         '[Action Required] Potential Truck Roll')
        self.assertIn(self.sample_testline, call_kwargs['Html'])
        self.assertIn(self.sample_test_name, call_kwargs['Html'])

        # Verify Messenger.send_message call
        mock_messenger.send_message.assert_called_once_with(
            mock_message_instance)

    @patch('notification_sender.Messenger')
    @patch('notification_sender.Message')
    @patch('notification_sender.BuiltIn')
    def test_send_email_notification_custom_params(self, mock_builtin, mock_message_class, mock_messenger):
        """Test email notification with custom parameters."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.side_effect = [
            self.sample_testline,
            self.sample_test_name,
            self.sample_suite_source
        ]

        custom_receiver = "custom@nokia.com"
        custom_sender = "sender@nokia.com"
        custom_cc = "cc@nokia.com"
        custom_files = ["file1.txt", "file2.log"]

        notification_sender._send_email_notification(
            receivers=custom_receiver,
            sender=custom_sender,
            cc=custom_cc,
            files=custom_files,
            execution_link=self.sample_execution_link,
            tl_execution_owner=self.sample_tl_owner
        )

        mock_message_class.assert_called_once()
        call_kwargs = mock_message_class.call_args[1]
        self.assertEqual(call_kwargs['From'], custom_sender)
        self.assertEqual(call_kwargs['To'], custom_receiver)
        self.assertEqual(call_kwargs['CC'], custom_cc)
        self.assertEqual(call_kwargs['attachments'], custom_files)
        self.assertIn(self.sample_execution_link, call_kwargs['Html'])
        self.assertIn(self.sample_tl_owner, call_kwargs['Html'])

    @patch('notification_sender.Messenger')
    @patch('notification_sender.Message')
    @patch('notification_sender.BuiltIn')
    def test_send_email_notification_with_execution_link(self, mock_builtin, mock_message_class, mock_messenger):
        """Test email notification HTML content with execution link."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.side_effect = [
            'TEST_LINE', 'TEST_NAME', 'SUITE_SOURCE']

        notification_sender._send_email_notification(
            execution_link=self.sample_execution_link,
            tl_execution_owner=self.sample_tl_owner
        )

        mock_message_class.assert_called_once()
        html_content = mock_message_class.call_args[1]['Html']

        # Verify execution link is included in the HTML
        self.assertIn(self.sample_execution_link, html_content)
        self.assertIn(
            "Please set TestLine in maintenance mode ASAP", html_content)

    @patch('notification_sender.Messenger')
    @patch('notification_sender.Message')
    @patch('notification_sender.BuiltIn')
    def test_send_email_notification_without_execution_link(self, mock_builtin, mock_message_class, mock_messenger):
        """Test email notification HTML content without execution link."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.side_effect = [
            'TEST_LINE', 'TEST_NAME', 'SUITE_SOURCE']

        notification_sender._send_email_notification()

        mock_message_class.assert_called_once()
        html_content = mock_message_class.call_args[1]['Html']

        # Verify no execution link and no maintenance message
        self.assertNotIn("EXECUTION:", html_content)
        self.assertNotIn(
            "Please set TestLine in maintenance mode ASAP", html_content)

    @patch('notification_sender.Messenger')
    @patch('notification_sender.Message')
    @patch('notification_sender.BuiltIn')
    def test_send_email_notification_messenger_exception(self, mock_builtin, mock_message_class, mock_messenger):
        """Test email notification with Messenger exception."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.side_effect = [
            'TEST_LINE', 'TEST_NAME', 'SUITE_SOURCE']
        mock_messenger.send_message.side_effect = Exception(
            "Email sending failed")

        notification_sender._send_email_notification()

        self.mock_builtin.log_to_console.assert_called_once()
        args = self.mock_builtin.log_to_console.call_args[0][0]
        self.assertIn("Email could not be sent!", args)
        self.assertIn("Email sending failed", args)

    @patch('notification_sender._send_email_notification')
    @patch('notification_sender.BuiltIn')
    @patch.dict('os.environ', {'BUILD_URL': 'http://jenkins.test', 'BUILD_USER_EMAIL': 'user@test.com'})
    def test_send_stop_and_fix_notification_no_cm_env(self, mock_builtin, mock_send_email):
        """Test stop and fix notification without CM environment."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.return_value = 'NA'

        notification_sender.send_stop_and_fix_notification()

        # Verify console logs
        expected_calls = [
            call("Teams channel notification will not be sent, execution was not performed "
                 "from Cloud Manager"),
            call("Trying to send email notification due to potential Truck Roll detection")
        ]
        self.mock_builtin.log_to_console.assert_has_calls(expected_calls)

        # Verify email notification call
        mock_send_email.assert_called_once_with(
            execution_link='http://jenkins.test',
            tl_execution_owner='user@test.com'
        )

    @patch('notification_sender._send_email_notification')
    @patch('notification_sender.BuiltIn')
    @patch.dict('os.environ', {}, clear=True)
    def test_send_stop_and_fix_notification_no_env_vars(self, mock_builtin, mock_send_email):
        """Test stop and fix notification without environment variables."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.return_value = False

        notification_sender.send_stop_and_fix_notification()

        # Verify email notification called with 'NA' defaults
        mock_send_email.assert_called_once_with(
            execution_link='NA',
            tl_execution_owner='NA'
        )

    @patch('notification_sender._send_teams_channel_notification')
    @patch('notification_sender._send_email_notification')
    @patch('notification_sender.BuiltIn')
    def test_send_stop_and_fix_notification_with_cm_env(self, mock_builtin, mock_send_email, mock_send_teams):
        """Test stop and fix notification with CM environment."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.return_value = 'CM_ENVIRONMENT'

        # Mock the JSON file content
        mock_json_content = {
            'CM_EXECUTION_ID': 'test_exec_123',
            'CM_EXECUTION_LINK': 'http://cm.test/exec/123',
            'CM_USERNAME': 'cm.user@nokia.com'
        }

        mock_file = mock_open(read_data=json.dumps(mock_json_content))

        with patch('builtins.open', mock_file):
            notification_sender.send_stop_and_fix_notification()

        # Verify file was opened
        mock_file.assert_called_once_with('/opt/ute/execution.context.json')

        # Verify console logs
        expected_calls = [
            call(
                "Trying to send teams channel notification due to potential Truck Roll detection"),
            call("Trying to send email notification due to potential Truck Roll detection")
        ]
        self.mock_builtin.log_to_console.assert_has_calls(expected_calls)

        # Verify notification calls
        mock_send_teams.assert_called_once_with(
            cm_execution_id='test_exec_123')
        mock_send_email.assert_called_once_with(
            execution_link='http://cm.test/exec/123',
            tl_execution_owner='cm.user@nokia.com'
        )

    @patch('notification_sender._send_email_notification')
    @patch('notification_sender.BuiltIn')
    def test_send_stop_and_fix_notification_json_file_error(self, mock_builtin, mock_send_email):
        """Test stop and fix notification with JSON file reading error."""
        mock_builtin.return_value = self.mock_builtin
        self.mock_builtin.get_variable_value.return_value = 'CM_ENVIRONMENT'

        # Mock file opening to raise an exception
        with patch('builtins.open', side_effect=FileNotFoundError("File not found")):
            with self.assertRaises(FileNotFoundError):
                notification_sender.send_stop_and_fix_notification()

    def test_email_html_content_structure(self):
        """Test the structure and content of email HTML."""
        with patch('notification_sender.BuiltIn') as mock_builtin, \
                patch('notification_sender.Message') as mock_message_class, \
                patch('notification_sender.Messenger'):

            mock_builtin.return_value = self.mock_builtin
            self.mock_builtin.get_variable_value.side_effect = [
                'WL39',  # TESTLINE_NAME (should be ignored)
                'Test_Function',  # TEST_NAME
                '/path/to/suite.robot'  # SUITE SOURCE
            ]

            notification_sender._send_email_notification(
                execution_link=self.sample_execution_link,
                tl_execution_owner=self.sample_tl_owner
            )

            html_content = mock_message_class.call_args[1]['Html']

            # Verify HTML structure
            self.assertIn('<html>', html_content)
            self.assertIn('<body>', html_content)
            self.assertIn('</body>', html_content)
            self.assertIn('</html>', html_content)

            # Verify content elements
            self.assertIn('Please ignore this notification', html_content)
            # Test team testlines
            self.assertIn('WL39, LG17, WL18', html_content)
            self.assertIn('Potential Truck Roll was detected', html_content)
            self.assertIn('TEST_SUITE:', html_content)
            self.assertIn('TEST_NAME:', html_content)
            self.assertIn('TESTLINE:', html_content)
            self.assertIn('TESTLINE_EXECUTION_OWNER:', html_content)
            self.assertIn('EXECUTION:', html_content)
            self.assertIn('confluence.ext.net.nokia.com',
                          html_content)  # Confluence link
            self.assertIn('TA Team', html_content)

    def test_email_cc_default_behavior(self):
        """Test email CC field default behavior."""
        with patch('notification_sender.BuiltIn') as mock_builtin, \
                patch('notification_sender.Message') as mock_message_class, \
                patch('notification_sender.Messenger'):

            mock_builtin.return_value = self.mock_builtin

            # Test with no CC provided (should default to sender)
            self.mock_builtin.get_variable_value.side_effect = [
                'TEST_LINE', 'TEST_NAME', 'SUITE_SOURCE']
            notification_sender._send_email_notification(
                sender='custom@nokia.com')

            call_kwargs = mock_message_class.call_args[1]
            self.assertEqual(call_kwargs['CC'], 'custom@nokia.com')

            # Test with CC provided - reset the side_effect for second call
            mock_message_class.reset_mock()
            self.mock_builtin.get_variable_value.side_effect = [
                'TEST_LINE', 'TEST_NAME', 'SUITE_SOURCE']
            notification_sender._send_email_notification(
                sender='sender@nokia.com',
                cc='cc@nokia.com'
            )

            call_kwargs = mock_message_class.call_args[1]
            self.assertEqual(call_kwargs['CC'], 'cc@nokia.com')


if __name__ == '__main__':
    unittest.main()
