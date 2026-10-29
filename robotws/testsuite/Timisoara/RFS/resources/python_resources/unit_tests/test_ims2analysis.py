# -*- coding: utf-8 -*-
"""
Unit tests for ims2analysis module.
"""

import ims2analysis
import unittest
from unittest.mock import patch, MagicMock, call
from datetime import datetime
import sys
import os

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Mock the external dependencies before importing


class MockIms2ChangesetLogEntry:
    """Mock class for Ims2ChangesetLogEntry."""

    def __init__(self):
        self.timestamp = datetime.now()
        self.updates = {}
        self.removals = []


class MockIms2LogReader:
    """Mock class for Ims2LogReader."""
    @classmethod
    def from_file(cls, file_path):
        return []


mock_ims2_module = MagicMock()
mock_ims2_module.Ims2ChangesetLogEntry = MockIms2ChangesetLogEntry
mock_ims2_module.Ims2LogReader = MockIms2LogReader

sys.modules['taf'] = MagicMock()
sys.modules['taf.analyzer'] = MagicMock()
sys.modules['taf.analyzer.ims2'] = mock_ims2_module


# Replace the classes in the imported module with our mocks
ims2analysis.Ims2ChangesetLogEntry = MockIms2ChangesetLogEntry
ims2analysis.Ims2LogReader = MockIms2LogReader


class TestIms2Analysis(unittest.TestCase):
    """Test cases for ims2analysis module functions."""

    def setUp(self):
        """Set up test fixtures."""
        self.sample_file_path = "/path/to/ims2_trace.log"
        self.sample_begin_time = "20230101120000.000000+0000"
        self.sample_end_time = "20230101130000.000000+0000"
        self.sample_obj_dist_name = "ALARM-123"
        self.sample_parameter_name = "status"

        # Create mock log entry
        self.mock_log_entry = MockIms2ChangesetLogEntry()
        self.mock_log_entry.timestamp = datetime(2023, 1, 1, 12, 30, 0)
        self.mock_log_entry.updates = {
            "ALARM-123": {
                "alarmNumber": 123,
                "faultId": 456,
                "alarmName": "Test Alarm",
                "alarmingResourceDN": "test_resource",
                "observationTime": "2023-01-01T12:30:00Z",
                "visibleForEM": True,
                "visibleForNetAct": False,
                "visibleForOnap": True,
                "alarmText": {
                    "alarmAdditionalInfo": {
                        "supplAlarmInfo": "Additional info"
                    }
                },
                "affectedResources": [
                    {"reportingResourceDN": "resource1"},
                    {"reportingResourceDN": "resource2"}
                ],
                "alarmAttribute": [
                    {"attributeName": "serial_no", "attributeValue": "SN123456"}
                ]
            }
        }
        self.mock_log_entry.removals = []

    @patch('ims2analysis.Ims2LogReader')
    def test_get_object_updates_in_interval_basic(self, mock_log_reader):
        """Test get_object_updates_in_interval with basic parameters."""
        mock_log_reader.from_file.return_value = [self.mock_log_entry]

        result = ims2analysis.get_object_updates_in_interval(
            self.sample_file_path,
            self.sample_obj_dist_name
        )

        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 1)
        self.assertIn('log_entry_timestamp', result[0])
        self.assertIn('log_entry_dist_name', result[0])

    @patch('ims2analysis.Ims2LogReader')
    def test_get_object_updates_in_interval_with_time_bounds(self, mock_log_reader):
        """Test get_object_updates_in_interval with time boundaries."""
        mock_log_reader.from_file.return_value = [self.mock_log_entry]

        result = ims2analysis.get_object_updates_in_interval(
            self.sample_file_path,
            self.sample_obj_dist_name,
            begin=self.sample_begin_time,
            end=self.sample_end_time
        )

        mock_log_reader.from_file.assert_called_once_with(
            file_path=self.sample_file_path)
        self.assertIsInstance(result, list)

    @patch('ims2analysis.Ims2LogReader')
    def test_get_object_updates_in_interval_exact_match(self, mock_log_reader):
        """Test get_object_updates_in_interval with exact match."""
        mock_log_reader.from_file.return_value = [self.mock_log_entry]

        result = ims2analysis.get_object_updates_in_interval(
            self.sample_file_path,
            "ALARM-123",
            obj_exact_match=True
        )

        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 1)

    @patch('ims2analysis.Ims2LogReader')
    def test_check_object_status_change_true(self, mock_log_reader):
        """Test check_object_status_change returns True when status changes."""
        # Create multiple entries with different status values
        entry1 = MockIms2ChangesetLogEntry()
        entry1.timestamp = datetime(2023, 1, 1, 12, 0, 0)
        entry1.updates = {"ALARM-123": {"status": "active"}}

        entry2 = MockIms2ChangesetLogEntry()
        entry2.timestamp = datetime(2023, 1, 1, 12, 30, 0)
        entry2.updates = {"ALARM-123": {"status": "inactive"}}

        mock_log_reader.from_file.return_value = [entry1, entry2]

        result = ims2analysis.check_object_status_change(
            self.sample_file_path,
            self.sample_obj_dist_name,
            "status"
        )

        self.assertTrue(result)

    @patch('ims2analysis.Ims2LogReader')
    def test_check_object_status_change_false(self, mock_log_reader):
        """Test check_object_status_change returns False when status doesn't change."""
        entry1 = MockIms2ChangesetLogEntry()
        entry1.timestamp = datetime(2023, 1, 1, 12, 0, 0)
        entry1.updates = {"ALARM-123": {"status": "active"}}

        entry2 = MockIms2ChangesetLogEntry()
        entry2.timestamp = datetime(2023, 1, 1, 12, 30, 0)
        entry2.updates = {"ALARM-123": {"status": "active"}}

        mock_log_reader.from_file.return_value = [entry1, entry2]

        result = ims2analysis.check_object_status_change(
            self.sample_file_path,
            self.sample_obj_dist_name,
            "status"
        )

        self.assertFalse(result)

    @patch('ims2analysis.Ims2LogReader')
    def test_get_object_status_changes(self, mock_log_reader):
        """Test get_object_status_changes returns list of changes."""
        entry1 = MockIms2ChangesetLogEntry()
        entry1.timestamp = datetime(2023, 1, 1, 12, 0, 0)
        entry1.updates = {"ALARM-123": {"status": "active",
                                        "log_entry_timestamp": 1672574400.0}}

        entry2 = MockIms2ChangesetLogEntry()
        entry2.timestamp = datetime(2023, 1, 1, 12, 30, 0)
        entry2.updates = {"ALARM-123": {"status": "inactive",
                                        "log_entry_timestamp": 1672576200.0}}

        mock_log_reader.from_file.return_value = [entry1, entry2]

        result = ims2analysis.get_object_status_changes(
            self.sample_file_path,
            self.sample_obj_dist_name,
            "status"
        )

        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 2)  # Initial value and change
        self.assertIn("timestamp", result[0])
        self.assertIn("value", result[0])
        self.assertIn("value_initial", result[0])

    @patch('ims2analysis.Ims2LogReader')
    def test_check_object_status_change_to_desired_value_true(self, mock_log_reader):
        """Test check_object_status_change_to_desired_value returns True when value matches."""
        mock_log_reader.from_file.return_value = [self.mock_log_entry]
        self.mock_log_entry.updates["ALARM-123"]["status"] = "desired_status"

        result = ims2analysis.check_object_status_change_to_desired_value(
            self.sample_file_path,
            self.sample_obj_dist_name,
            "status",
            "desired_status"
        )

        self.assertTrue(result)

    @patch('ims2analysis.Ims2LogReader')
    def test_check_object_status_change_to_desired_value_false(self, mock_log_reader):
        """Test check_object_status_change_to_desired_value returns False when value doesn't match."""
        mock_log_reader.from_file.return_value = [self.mock_log_entry]
        self.mock_log_entry.updates["ALARM-123"]["status"] = "other_status"

        result = ims2analysis.check_object_status_change_to_desired_value(
            self.sample_file_path,
            self.sample_obj_dist_name,
            "status",
            "desired_status"
        )

        self.assertFalse(result)

    @patch('ims2analysis.Ims2LogReader')
    def test_get_alarms_in_interval_rfs_format(self, mock_log_reader):
        """Test get_alarms_in_interval with RFS format."""
        mock_log_reader.from_file.return_value = [self.mock_log_entry]

        result = ims2analysis.get_alarms_in_interval(
            self.sample_file_path,
            rfs_format=True
        )

        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 1)

        alarm = result[0]
        self.assertIn("alarmId", alarm)
        self.assertIn("faultId", alarm)
        self.assertIn("alarmName", alarm)
        self.assertIn("object_id", alarm)
        self.assertIn("observationTime", alarm)

    @patch('ims2analysis.Ims2LogReader')
    def test_get_alarms_in_interval_non_rfs_format(self, mock_log_reader):
        """Test get_alarms_in_interval with non-RFS format."""
        mock_log_reader.from_file.return_value = [self.mock_log_entry]

        result = ims2analysis.get_alarms_in_interval(
            self.sample_file_path,
            rfs_format=False
        )

        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 1)

        alarm = result[0]
        self.assertIn("alarmNumber", alarm)
        self.assertNotIn("alarmId", alarm)

    def test_create_alarm_dict_rfs_format(self):
        """Test _create_alarm_dict with RFS format."""
        alarm_data = {
            "alarmNumber": 123,
            "faultId": 456,
            "alarmName": "Test Alarm",
            "alarmingResourceDN": "test_resource",
            "observationTime": "2023-01-01T12:30:00Z",
            "log_entry_dist_name": "ALARM-123",
            "visibleForEM": True,
            "visibleForNetAct": False,
            "visibleForOnap": True,
            "alarmText": {
                "alarmAdditionalInfo": {
                    "supplAlarmInfo": "Additional info"
                }
            },
            "affectedResources": [
                {"reportingResourceDN": "resource1"}
            ],
            "alarmAttribute": [
                {"attributeName": "serial_no", "attributeValue": "SN123456"}
            ]
        }

        result = ims2analysis._create_alarm_dict(alarm_data, rfs_format=True)

        self.assertEqual(result["alarmId"], "123")
        self.assertEqual(result["faultId"], "456")
        self.assertEqual(result["alarmName"], "Test Alarm")
        self.assertEqual(result["object_id"], "test_resource")
        self.assertEqual(result["sn_attribute"], "SN123456")

    def test_create_alarm_dict_non_rfs_format(self):
        """Test _create_alarm_dict with non-RFS format."""
        alarm_data = {
            "alarmNumber": 123,
            "faultId": 456,
            "alarmName": "Test Alarm",
            "alarmingResourceDN": "test_resource",
            "observationTime": "2023-01-01T12:30:00Z",
            "visibleForEM": True,
            "visibleForNetAct": False,
            "visibleForOnap": True,
            "alarmText": {
                "alarmAdditionalInfo": {}
            },
            "affectedResources": [],
            "alarmAttribute": []
        }

        result = ims2analysis._create_alarm_dict(alarm_data, rfs_format=False)

        self.assertEqual(result["alarmNumber"], 123)
        self.assertEqual(result["faultId"], 456)
        self.assertNotIn("alarmId", result)

    def test_get_obj_dist_name_match_exact_true(self):
        """Test _get_obj_dist_name_match with exact match True."""
        result = ims2analysis._get_obj_dist_name_match(
            "ALARM-123", "ALARM-123", obj_exact_match=True)
        self.assertTrue(result)

    def test_get_obj_dist_name_match_exact_false(self):
        """Test _get_obj_dist_name_match with exact match False."""
        result = ims2analysis._get_obj_dist_name_match(
            "ALARM-123", "ALARM-123-456", obj_exact_match=True)
        self.assertFalse(result)

    def test_get_obj_dist_name_match_partial_true(self):
        """Test _get_obj_dist_name_match with partial match True."""
        result = ims2analysis._get_obj_dist_name_match(
            "ALARM", "ALARM-123", obj_exact_match=False)
        self.assertTrue(result)

    def test_get_obj_dist_name_match_partial_false(self):
        """Test _get_obj_dist_name_match with partial match False."""
        result = ims2analysis._get_obj_dist_name_match(
            "EVENT", "ALARM-123", obj_exact_match=False)
        self.assertFalse(result)

    def test_check_parameter_change_true(self):
        """Test _check_parameter_change returns True when parameter changes."""
        object_updates = [
            {"status": "active", "log_entry_timestamp": 1672574400.0},
            {"status": "inactive", "log_entry_timestamp": 1672576200.0}
        ]

        result = ims2analysis._check_parameter_change(object_updates, "status")
        self.assertTrue(result)

    def test_check_parameter_change_false(self):
        """Test _check_parameter_change returns False when parameter doesn't change."""
        object_updates = [
            {"status": "active", "log_entry_timestamp": 1672574400.0},
            {"status": "active", "log_entry_timestamp": 1672576200.0}
        ]

        result = ims2analysis._check_parameter_change(object_updates, "status")
        self.assertFalse(result)

    def test_intersect_alarms_dicts_keys(self):
        """Test _intersect_alarms_dicts_keys finds intersection correctly."""
        list1 = [
            {"alarmId": "123", "faultId": "456", "alarmName": "Alarm1"},
            {"alarmId": "789", "faultId": "101", "alarmName": "Alarm2"}
        ]
        list2 = [
            {"alarmId": "123", "faultId": "456",
                "alarmName": "Alarm1", "extra": "data"},
            {"alarmId": "999", "faultId": "888", "alarmName": "Alarm3"}
        ]
        keys = ["alarmId", "faultId", "alarmName"]

        result = ims2analysis._intersect_alarms_dicts_keys(list1, list2, keys)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["alarmId"], "123")

    def test_get_timestamp_in_datetime_format_string_with_colon(self):
        """Test _get_timestamp_in_datetime_format with string containing colon."""
        timestamp_str = "2023-01-01T12:30:00"
        result = ims2analysis._get_timestamp_in_datetime_format(timestamp_str)
        self.assertIsInstance(result, datetime)

    def test_get_timestamp_in_datetime_format_string_without_colon(self):
        """Test _get_timestamp_in_datetime_format with string without colon."""
        # Use a simpler format that will work
        timestamp_str = "20230101123000.000000+0000"
        result = ims2analysis._get_timestamp_in_datetime_format(timestamp_str)
        self.assertIsInstance(result, datetime)

    def test_get_timestamp_in_datetime_format_datetime_object(self):
        """Test _get_timestamp_in_datetime_format with datetime object."""
        timestamp_obj = datetime(2023, 1, 1, 12, 30, 0)
        result = ims2analysis._get_timestamp_in_datetime_format(timestamp_obj)
        self.assertEqual(result, timestamp_obj)

    def test_translate_alarms(self):
        """Test _translate_alarms converts alarmId to alarmNumber."""
        alarms = [
            {"alarmId": "123", "faultId": "456"},
            {"alarmNumber": "789", "faultId": "101"}
        ]

        result = ims2analysis._translate_alarms(alarms)

        self.assertEqual(len(result), 2)
        self.assertEqual(result[0]["alarmNumber"], 123)
        self.assertEqual(result[0]["faultId"], 456)
        self.assertNotIn("alarmId", result[0])
        self.assertEqual(result[1]["alarmNumber"], 789)

    @patch('ims2analysis.get_alarms_in_interval')
    def test_get_expected_alarms_all_found(self, mock_get_alarms):
        """Test get_expected_alarms when all alarms are found."""
        expected_alarms = [
            {"alarmId": "123", "faultId": "456", "alarmName": "Alarm1"}
        ]
        detected_alarms = [
            {"alarmId": "123", "faultId": "456",
                "alarmName": "Alarm1", "extra": "data"}
        ]

        mock_get_alarms.return_value = detected_alarms

        found, not_found = ims2analysis.get_expected_alarms(
            self.sample_file_path,
            expected_alarms,
            rfs_format=True
        )

        self.assertEqual(len(found), 1)
        self.assertEqual(len(not_found), 0)

    @patch('ims2analysis.get_alarms_in_interval')
    def test_get_expected_alarms_none_found(self, mock_get_alarms):
        """Test get_expected_alarms when no alarms are found."""
        expected_alarms = [
            {"alarmId": "123", "faultId": "456", "alarmName": "Alarm1"}
        ]
        detected_alarms = [
            {"alarmId": "999", "faultId": "888", "alarmName": "Alarm2"}
        ]

        mock_get_alarms.return_value = detected_alarms

        found, not_found = ims2analysis.get_expected_alarms(
            self.sample_file_path,
            expected_alarms,
            rfs_format=True
        )

        self.assertEqual(len(found), 0)
        self.assertEqual(len(not_found), 1)

    @patch('ims2analysis.get_expected_alarms')
    def test_verify_expected_alarms_success(self, mock_get_expected):
        """Test verify_expected_alarms succeeds when all alarms found."""
        found_alarms = [{"alarmId": "123", "faultId": "456"}]
        not_found_alarms = []

        mock_get_expected.return_value = (found_alarms, not_found_alarms)

        result = ims2analysis.verify_expected_alarms(
            self.sample_file_path,
            [{"alarmId": "123", "faultId": "456"}]
        )

        self.assertEqual(result, found_alarms)

    @patch('ims2analysis.get_expected_alarms')
    def test_verify_expected_alarms_failure(self, mock_get_expected):
        """Test verify_expected_alarms raises AssertionError when alarms not found."""
        found_alarms = []
        not_found_alarms = [{"alarmId": "123", "faultId": "456"}]

        mock_get_expected.return_value = (found_alarms, not_found_alarms)

        with self.assertRaises(AssertionError):
            ims2analysis.verify_expected_alarms(
                self.sample_file_path,
                [{"alarmId": "123", "faultId": "456"}]
            )

    @patch('ims2analysis.Ims2LogReader')
    def test_get_alarms_not_cleared_in_interval(self, mock_log_reader):
        """Test get_alarms_not_cleared_in_interval returns only uncleared alarms."""
        # Create mock entry with uncleared alarm only
        uncleared_entry = MockIms2ChangesetLogEntry()
        uncleared_entry.timestamp = datetime(2023, 1, 1, 12, 30, 0)
        uncleared_entry.updates = {
            "ALARM-456": {
                "alarmNumber": 456,
                "faultId": 789,
                "alarmName": "Test Alarm 2",
                "alarmingResourceDN": "test_resource_2",
                "observationTime": "2023-01-01T12:30:00Z",
                "visibleForEM": True,
                "visibleForNetAct": False,
                "visibleForOnap": True,
                "cleared": False,
                "log_entry_dist_name": "ALARM-456",
                "alarmText": {"alarmAdditionalInfo": {}},
                "affectedResources": [],
                "alarmAttribute": []
            }
        }
        uncleared_entry.removals = []

        mock_log_reader.from_file.return_value = [uncleared_entry]

        with patch('ims2analysis._return_alarm_removes_in_interval', return_value=False):
            result = ims2analysis.get_alarms_not_cleared_in_interval(
                self.sample_file_path)

        self.assertEqual(len(result), 1)


if __name__ == '__main__':
    unittest.main()
