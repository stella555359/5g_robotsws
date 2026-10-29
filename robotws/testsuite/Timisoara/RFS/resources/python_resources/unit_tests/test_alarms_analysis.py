# -*- coding: utf-8 -*-
"""
Unit tests for alarms_analysis module.
"""

import unittest
from unittest.mock import patch, MagicMock
import sys
import os

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from alarms_analysis import (
        get_wcdma_alarms_from_file,
        get_btssm_alarms_from_file,
        convert_wcdma_patterns,
        get_filtered_alarms,
        print_alarms,
        LTE_SIMPLIFIED_DICT,
        SBTS16_SIMPLIFIED_DICT
    )
except ImportError:
    # Mock the tools module if it's not available
    sys.modules['tools'] = MagicMock()
    from alarms_analysis import (
        get_wcdma_alarms_from_file,
        get_btssm_alarms_from_file,
        convert_wcdma_patterns,
        get_filtered_alarms,
        print_alarms,
        LTE_SIMPLIFIED_DICT,
        SBTS16_SIMPLIFIED_DICT
    )


class TestAlarmsAnalysis(unittest.TestCase):
    """Test cases for alarms_analysis module."""

    def setUp(self):
        """Set up test fixtures."""
        self.sample_wcdma_alarm_data = """
        Header line
        Some other line
        Alarm 1234 5678 Some alarm description
        Another 5678 Core Different alarm
        Footer line
        """

        self.sample_btssm_alarm_data = """
        Header
        123 456 789 Source description Major 12:34:56.78 +0200 Alarm description text
        234 567  Another source Minor 13:45:67.89 +0200 Different alarm text
        345 678  Final source Critical 14:56:78.90 +0200 Critical alarm description
        """

        self.sample_alarms = [
            {'alarm': '1234', 'detail': '5678'},
            {'alarm': '5678', 'detail': 'Core'},
            {'alarm': '9999', 'detail': '1111'}
        ]

    def test_get_wcdma_alarms_from_file_default_keys(self):
        """Test parsing WCDMA alarms with default keys."""
        result = get_wcdma_alarms_from_file(self.sample_wcdma_alarm_data)

        expected = [
            {'alarm': '1234', 'detail': '5678'},
            {'alarm': '5678', 'detail': 'Core'}
        ]

        self.assertEqual(result, expected)

    def test_get_wcdma_alarms_from_file_custom_keys(self):
        """Test parsing WCDMA alarms with custom keys."""
        custom_keys = ('number', 'fault_id')
        result = get_wcdma_alarms_from_file(
            self.sample_wcdma_alarm_data, keys=custom_keys)

        expected = [
            {'number': '1234', 'fault_id': '5678'},
            {'number': '5678', 'fault_id': 'Core'}
        ]

        self.assertEqual(result, expected)

    def test_get_wcdma_alarms_from_file_empty_input(self):
        """Test parsing WCDMA alarms with empty input."""
        result = get_wcdma_alarms_from_file("")
        self.assertEqual(result, [])

    def test_get_btssm_alarms_from_file_default_severities(self):
        """Test parsing BTSSM alarms with default severities."""
        result = get_btssm_alarms_from_file(self.sample_btssm_alarm_data)

        self.assertEqual(len(result), 3)

        # Check first alarm
        first_alarm = result[0]
        self.assertEqual(first_alarm['alarm'], '123')
        self.assertEqual(first_alarm['faultId'], '456')
        self.assertEqual(first_alarm['rawFaultId'], '789')
        self.assertEqual(first_alarm['severity'], 'Major')
        self.assertIn('Source description', first_alarm['source'])
        self.assertIn('Alarm description text', first_alarm['description'])

    def test_get_btssm_alarms_from_file_custom_severities(self):
        """Test parsing BTSSM alarms with custom severities."""
        custom_severities = ["High", "Medium", "Low"]
        result = get_btssm_alarms_from_file(
            self.sample_btssm_alarm_data, custom_severities)

        # Should return empty list as no alarms match custom severities
        self.assertEqual(result, [])

    def test_get_btssm_alarms_from_file_empty_input(self):
        """Test parsing BTSSM alarms with empty input."""
        result = get_btssm_alarms_from_file("")
        self.assertEqual(result, [])

    def test_convert_wcdma_patterns_default_keys(self):
        """Test converting WCDMA patterns with default keys."""
        patterns = [('1234', '5678'), ('9999', '1111')]
        result = convert_wcdma_patterns(patterns)

        expected = [
            {'alarm': '1234', 'detail': '5678'},
            {'alarm': '9999', 'detail': '1111'}
        ]

        self.assertEqual(result, expected)

    def test_convert_wcdma_patterns_custom_keys(self):
        """Test converting WCDMA patterns with custom keys."""
        patterns = [('1234', '5678'), ('9999', '1111')]
        custom_keys = ('number', 'fault_id')
        result = convert_wcdma_patterns(patterns, keys=custom_keys)

        expected = [
            {'number': '1234', 'fault_id': '5678'},
            {'number': '9999', 'fault_id': '1111'}
        ]

        self.assertEqual(result, expected)

    def test_convert_wcdma_patterns_empty_input(self):
        """Test converting WCDMA patterns with empty input."""
        result = convert_wcdma_patterns([])
        self.assertEqual(result, [])

    @patch('alarms_analysis._filter_alarms')
    def test_get_filtered_alarms(self, mock_filter_alarms):
        """Test filtering alarms with various patterns."""
        # Mock the _filter_alarms function calls
        mock_filter_alarms.side_effect = [
            # First call (expected patterns)
            (['expected_alarm'], ['other_alarm'], ['missing_pattern']),
            # Second call (ignored patterns)
            (['ignored_alarm'], ['remaining_alarm'], []),
            # Third call (critical patterns)
            (['critical_alarm'], ['unclassified_alarm'], [])
        ]

        current_alarms = self.sample_alarms
        expected_patterns = [{'alarm': '1234'}]
        ignored_patterns = [{'alarm': '5678'}]
        critical_patterns = [{'alarm': '9999'}]

        result = get_filtered_alarms(
            current_alarms,
            expected_patterns,
            ignored_patterns,
            critical_patterns
        )

        expected_result = (
            ['expected_alarm'],  # found_expected_alarms
            ['missing_pattern'],  # not_found_expected_patterns
            ['critical_alarm'],   # found_critical_alarms
            ['ignored_alarm'],    # found_ignored_alarms
            ['unclassified_alarm']  # found_not_classified_alarms
        )

        self.assertEqual(result, expected_result)
        self.assertEqual(mock_filter_alarms.call_count, 3)

    @patch('alarms_analysis._filter_alarms')
    def test_get_filtered_alarms_empty_patterns(self, mock_filter_alarms):
        """Test filtering alarms with empty patterns."""
        mock_filter_alarms.side_effect = [
            ([], self.sample_alarms, []),
            ([], self.sample_alarms, []),
            ([], self.sample_alarms, [])
        ]

        result = get_filtered_alarms(self.sample_alarms)

        expected_result = ([], [], [], [], self.sample_alarms)
        self.assertEqual(result, expected_result)

    @patch('alarms_analysis.logging')
    @patch('alarms_analysis._make_pretty_alarm')
    def test_print_alarms_with_all_types(self, mock_make_pretty, mock_logging):
        """Test printing alarms with all alarm types."""
        mock_make_pretty.side_effect = lambda alarm, simplified: f"pretty_{alarm['alarm']}"

        found_expected = [{'alarm': 'expected'}]
        missing_patterns = [{'alarm': 'missing'}]
        critical_alarms = [{'alarm': 'critical'}]
        ignored_alarms = [{'alarm': 'ignored'}]
        warnings = [{'alarm': 'warning'}]

        print_alarms(
            found_expected_alarms=found_expected,
            missing_alarms_patterns=missing_patterns,
            critical_alarms=critical_alarms,
            ignored_alarms=ignored_alarms,
            warnings=warnings
        )

        # Verify logging calls
        mock_logging.info.assert_any_call(
            "Ignored alarms detected: ['pretty_ignored']")
        mock_logging.info.assert_any_call(
            "Expected alarms detected: ['pretty_expected']")
        mock_logging.warning.assert_called_once_with(
            "Unexpected non critical alarms detected: ['pretty_warning']")
        mock_logging.error.assert_any_call(
            "Missing alarms: ['pretty_missing']")
        mock_logging.error.assert_any_call(
            "Critical alarms detected: ['pretty_critical']")

    @patch('alarms_analysis.logging')
    def test_print_alarms_empty_lists(self, mock_logging):
        """Test printing alarms with empty lists."""
        print_alarms()

        # Verify no logging calls were made
        mock_logging.info.assert_not_called()
        mock_logging.warning.assert_not_called()
        mock_logging.error.assert_not_called()

    @patch('alarms_analysis.logging')
    @patch('alarms_analysis._make_pretty_alarm')
    def test_print_alarms_no_simplified_dict(self, mock_make_pretty, mock_logging):
        """Test printing alarms without simplified dictionary."""
        found_expected = [{'alarm': 'expected'}]

        print_alarms(
            found_expected_alarms=found_expected,
            simplified_dictionary=None
        )

        # When simplified_dictionary is None, should use original alarms
        mock_logging.info.assert_called_once_with(
            "Expected alarms detected: [{'alarm': 'expected'}]")
        mock_make_pretty.assert_not_called()

    def test_lte_simplified_dict_structure(self):
        """Test LTE simplified dictionary structure."""
        expected_structure = {
            'alarmInformation': {
                'alarmNumber': None,
                'alarmText': {'alarmDetail': None},
                'faultId': None
            }
        }
        self.assertEqual(LTE_SIMPLIFIED_DICT, expected_structure)

    def test_sbts16_simplified_dict_structure(self):
        """Test SBTS16 simplified dictionary structure."""
        expected_structure = {
            'number': None,
            'text': None,
            'faultId': None
        }
        self.assertEqual(SBTS16_SIMPLIFIED_DICT, expected_structure)


if __name__ == '__main__':
    unittest.main()
