# -*- coding: utf-8 -*-
"""
Unit tests for BlackBox module.
"""

from BlackBox import BlackBox
import unittest
from unittest.mock import patch, mock_open, MagicMock
import sys
import os
from io import StringIO

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Mock the robot framework
sys.modules['robot'] = MagicMock()
sys.modules['robot.api'] = MagicMock()
sys.modules['robot.api.logger'] = MagicMock()


class TestBlackBox(unittest.TestCase):
    """Test cases for BlackBox class."""

    def setUp(self):
        """Set up test fixtures."""
        self.sample_blackbox_content = """Header line
RESET COUNTER: 5
Another line
2023-01-01T10:15:30.123Z Software watchdog reset
2023-01-02T14:22:45.456Z Hardware failure
Some other line
2023-01-03T09:30:12.789Z Power failure reset
Footer line
"""

        self.sample_file_path = "/path/to/blackbox.txt"

    def test_init(self):
        """Test BlackBox initialization."""
        blackbox = BlackBox()
        self.assertIsInstance(blackbox, BlackBox)

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_valid_content(self, mock_file):
        """Test parse_blackbox with valid content."""
        mock_file.return_value.readlines.return_value = self.sample_blackbox_content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 5)
        self.assertEqual(len(reset_reason_list), 3)

        expected_resets = [
            ("2023-01-01T10:15:30.123Z", "Software watchdog reset"),
            ("2023-01-02T14:22:45.456Z", "Hardware failure"),
            ("2023-01-03T09:30:12.789Z", "Power failure reset")
        ]

        self.assertEqual(reset_reason_list, expected_resets)
        mock_file.assert_called_once_with(self.sample_file_path, 'r')

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_no_reset_counter(self, mock_file):
        """Test parse_blackbox with no reset counter in file."""
        content = """Header line
2023-01-01T10:15:30.123Z Software watchdog reset
Footer line
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 0)
        self.assertEqual(len(reset_reason_list), 1)
        self.assertEqual(
            reset_reason_list[0], ("2023-01-01T10:15:30.123Z", "Software watchdog reset"))

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_no_reset_entries(self, mock_file):
        """Test parse_blackbox with no reset entries in file."""
        content = """Header line
RESET COUNTER: 10
Some other line
Footer line
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 10)
        self.assertEqual(len(reset_reason_list), 0)

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_empty_file(self, mock_file):
        """Test parse_blackbox with empty file."""
        mock_file.return_value.readlines.return_value = []

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 0)
        self.assertEqual(len(reset_reason_list), 0)

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_multiple_reset_counters(self, mock_file):
        """Test parse_blackbox with multiple reset counters (should use last one)."""
        content = """RESET COUNTER: 3
RESET COUNTER: 7
2023-01-01T10:15:30.123Z Software reset
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 7)
        self.assertEqual(len(reset_reason_list), 1)

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_invalid_timestamp_format(self, mock_file):
        """Test parse_blackbox with invalid timestamp format (should be ignored)."""
        content = """RESET COUNTER: 2
2023-01-01 10:15:30 Invalid timestamp format
2023-01-01T10:15:30.123Z Valid timestamp format
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 2)
        self.assertEqual(len(reset_reason_list), 1)
        self.assertEqual(
            reset_reason_list[0], ("2023-01-01T10:15:30.123Z", "Valid timestamp format"))

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_zero_reset_counter(self, mock_file):
        """Test parse_blackbox with zero reset counter."""
        content = """RESET COUNTER: 0
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 0)
        self.assertEqual(len(reset_reason_list), 0)

    @patch('BlackBox.BlackBox.parse_blackbox')
    def test_get_reset_info_from_file_success(self, mock_parse):
        """Test get_reset_info_from_file with successful parsing."""
        expected_counter = 5
        expected_list = [("2023-01-01T10:15:30.123Z", "Test reset")]
        mock_parse.return_value = (expected_counter, expected_list)

        result_counter, result_list = BlackBox.get_reset_info_from_file(
            self.sample_file_path)

        self.assertEqual(result_counter, expected_counter)
        self.assertEqual(result_list, expected_list)
        mock_parse.assert_called_once_with(self.sample_file_path)

    @patch('BlackBox.logger')
    @patch('BlackBox.BlackBox.parse_blackbox')
    def test_get_reset_info_from_file_os_error(self, mock_parse, mock_logger):
        """Test get_reset_info_from_file with OS error."""
        mock_error = OSError(2, "No such file or directory")
        mock_parse.side_effect = mock_error

        with self.assertRaises(Exception) as context:
            BlackBox.get_reset_info_from_file(self.sample_file_path)

        self.assertEqual(str(context.exception),
                         "OS Error(2): No such file or directory")
        mock_logger.error.assert_called_once_with(
            "Cannot get info from blackbox file because of IOError. TC ended."
        )

    @patch('BlackBox.logger')
    @patch('BlackBox.BlackBox.parse_blackbox')
    @patch('BlackBox.sys.exc_info')
    def test_get_reset_info_from_file_unexpected_error(self, mock_exc_info, mock_parse, mock_logger):
        """Test get_reset_info_from_file with unexpected error."""
        mock_parse.side_effect = ValueError("Test error")
        mock_exc_info.return_value = (
            ValueError, ValueError("Test error"), None)

        with self.assertRaises(Exception) as context:
            BlackBox.get_reset_info_from_file(self.sample_file_path)

        self.assertIn("Unexpected error:", str(context.exception))
        mock_logger.error.assert_called_once_with(
            "Unexpected error. TC ended.")

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_complex_reset_reasons(self, mock_file):
        """Test parse_blackbox with complex reset reason descriptions."""
        content = """RESET COUNTER: 3
2023-01-01T10:15:30.123Z Software watchdog reset: Module XYZ timeout
2023-01-02T14:22:45.456Z Hardware failure - Memory corruption detected
2023-01-03T09:30:12.789Z Power failure reset (voltage drop below threshold)
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 3)
        self.assertEqual(len(reset_reason_list), 3)

        expected_resets = [
            ("2023-01-01T10:15:30.123Z", "Software watchdog reset: Module XYZ timeout"),
            ("2023-01-02T14:22:45.456Z",
             "Hardware failure - Memory corruption detected"),
            ("2023-01-03T09:30:12.789Z",
             "Power failure reset (voltage drop below threshold)")
        ]

        self.assertEqual(reset_reason_list, expected_resets)

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_whitespace_variations(self, mock_file):
        """Test parse_blackbox with various whitespace scenarios."""
        content = """   RESET COUNTER: 2
2023-01-01T10:15:30.123Z   Software reset with spaces
RESET COUNTER: 4
2023-01-02T14:22:45.456Z Hardware reset
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        # Reset counter should be 4 (last occurrence)
        self.assertEqual(reset_counter, 4)
        self.assertEqual(len(reset_reason_list), 2)

        # Check that whitespace in reset reasons is preserved
        self.assertEqual(
            reset_reason_list[0][1], "  Software reset with spaces   ")
        self.assertEqual(reset_reason_list[1][1], "Hardware reset")

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_with_large_reset_counter(self, mock_file):
        """Test parse_blackbox with large reset counter value."""
        content = """RESET COUNTER: 999999
2023-01-01T10:15:30.123Z Test reset
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        self.assertEqual(reset_counter, 999999)
        self.assertEqual(len(reset_reason_list), 1)

    @patch('builtins.open', new_callable=mock_open)
    def test_parse_blackbox_regex_patterns(self, mock_file):
        """Test that regex patterns work correctly with edge cases."""
        content = """RESET COUNTER: 123
2023-12-31T23:59:59.999Z End of year reset
2024-01-01T00:00:00.000Z New year reset
Not a timestamp line
RESET COUNTER: not a number
2023-01-01T25:00:00.000Z Invalid hour but matches regex
2023-01-01T10:15:30.123Z Valid reset entry
"""
        mock_file.return_value.readlines.return_value = content.splitlines(
            True)

        reset_counter, reset_reason_list = BlackBox.parse_blackbox(
            self.sample_file_path)

        # "not a number" should be ignored
        self.assertEqual(reset_counter, 123)
        # The regex doesn't validate time values, just format
        self.assertEqual(len(reset_reason_list), 4)

        expected_resets = [
            ("2023-12-31T23:59:59.999Z", "End of year reset"),
            ("2024-01-01T00:00:00.000Z", "New year reset"),
            ("2023-01-01T25:00:00.000Z", "Invalid hour but matches regex"),
            ("2023-01-01T10:15:30.123Z", "Valid reset entry")
        ]

        self.assertEqual(reset_reason_list, expected_resets)


if __name__ == '__main__':
    unittest.main()
