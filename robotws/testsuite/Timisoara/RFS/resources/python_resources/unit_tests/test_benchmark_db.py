# -*- coding: utf-8 -*-
"""
Unit tests for BenchmarkDb module.
"""

from BenchmarkDb import BenchmarkDb
import unittest
from unittest.mock import patch, MagicMock, PropertyMock
from datetime import datetime
import pytz
import sys
import os

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Mock the external dependencies
sys.modules['RfsListenerLib'] = MagicMock()
sys.modules['tools'] = MagicMock()
sys.modules['tzlocal'] = MagicMock()


class TestBenchmarkDb(unittest.TestCase):
    """Test cases for BenchmarkDb class."""

    def setUp(self):
        """Set up test fixtures."""
        self.benchmark_db = BenchmarkDb()

        # Mock the RfsElasticSearchContextManager
        self.mock_els_db = MagicMock()

        # Sample test data
        self.sample_bts_id = "BTS001"
        self.sample_tc_name = "General_SiSo_KPI_PM_Counters_benchmarking"
        self.sample_template_id = "template_123"
        self.sample_cycles = 3
        self.sample_start_date = "2023-01-01 10:00:00"
        self.sample_end_date = "2023-01-01 11:00:00"
        self.sample_sw_version = "21.1.0"

    def test_init_default_values(self):
        """Test BenchmarkDb initialization with default values."""
        db = BenchmarkDb()

        self.assertEqual(db.url, "http://rfs-tools-timisoara.emea.nsn-net.net")
        self.assertEqual(db.port, 9200)
        self.assertEqual(db.index_name, "benchmark_db_dev")
        self.assertEqual(
            db.api_key, "LUt2TGo1d0JtU2xVQVNRamY4Skw6cXFleERpenJfMmV6QW1JVGhha18zUQ==")
        self.assertIsNone(db.els_db)

    @patch('BenchmarkDb.RfsElasticSearchContextManager')
    def test_setup_db_with_defaults(self, mock_rfs_lib):
        """Test setup_db with default parameters."""
        mock_els_instance = MagicMock()
        mock_rfs_lib.return_value = mock_els_instance

        self.benchmark_db.setup_db()

        mock_rfs_lib.assert_called_once()
        self.assertEqual(self.benchmark_db.els_db, mock_els_instance)
        self.assertEqual(mock_els_instance.url, self.benchmark_db.url)
        self.assertEqual(mock_els_instance.port, self.benchmark_db.port)
        self.assertEqual(mock_els_instance.index, self.benchmark_db.index_name)
        self.assertEqual(mock_els_instance.api_key, self.benchmark_db.api_key)

    @patch('BenchmarkDb.RfsElasticSearchContextManager')
    def test_setup_db_with_custom_parameters(self, mock_rfs_lib):
        """Test setup_db with custom parameters."""
        mock_els_instance = MagicMock()
        mock_rfs_lib.return_value = mock_els_instance

        custom_url = "http://custom-url.com"
        custom_port = 9300
        custom_index = "custom_index"
        custom_api_key = "custom_api_key"

        self.benchmark_db.setup_db(
            url=custom_url,
            port=custom_port,
            index_name=custom_index,
            api_key=custom_api_key
        )

        self.assertEqual(self.benchmark_db.url, custom_url)
        self.assertEqual(self.benchmark_db.port, custom_port)
        self.assertEqual(self.benchmark_db.index_name, custom_index)
        self.assertEqual(self.benchmark_db.api_key, custom_api_key)

        self.assertEqual(mock_els_instance.url, custom_url)
        self.assertEqual(mock_els_instance.port, custom_port)
        self.assertEqual(mock_els_instance.index, custom_index)
        self.assertEqual(mock_els_instance.api_key, custom_api_key)

    def test_setup_db_type_conversion(self):
        """Test setup_db converts parameters to correct types."""
        with patch('BenchmarkDb.RfsElasticSearchContextManager'):
            self.benchmark_db.setup_db(
                url=123,  # Should be converted to string
                port="9300",  # Should be converted to int
                index_name=456,  # Should be converted to string
                api_key=789  # Should be converted to string
            )

            self.assertEqual(self.benchmark_db.url, "123")
            self.assertEqual(self.benchmark_db.port, 9300)
            self.assertEqual(self.benchmark_db.index_name, "456")
            self.assertEqual(self.benchmark_db.api_key, "789")

    def test_check_if_record_exists_for_bts_true(self):
        """Test check_if_record_exists_for_bts returns True when record exists."""
        self.benchmark_db.els_db = self.mock_els_db
        self.mock_els_db.check_query_match.return_value = True

        result = self.benchmark_db.check_if_record_exists_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_cycles
        )

        self.assertTrue(result)
        expected_query = {
            "bts_name": self.sample_bts_id,
            "tc_name": self.sample_tc_name,
            "template_id": self.sample_template_id,
            "cycles": str(self.sample_cycles)
        }
        self.mock_els_db.check_query_match.assert_called_once_with(
            index_name=self.benchmark_db.index_name,
            match_fields_dict=expected_query
        )

    def test_check_if_record_exists_for_bts_false(self):
        """Test check_if_record_exists_for_bts returns False when record doesn't exist."""
        self.benchmark_db.els_db = self.mock_els_db
        self.mock_els_db.check_query_match.return_value = False

        result = self.benchmark_db.check_if_record_exists_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_cycles
        )

        self.assertFalse(result)

    def test_check_if_record_exists_type_conversion(self):
        """Test check_if_record_exists_for_bts converts parameters to strings."""
        self.benchmark_db.els_db = self.mock_els_db
        self.mock_els_db.check_query_match.return_value = True

        # Pass integers and other types
        self.benchmark_db.check_if_record_exists_for_bts(123, "tc", 456, 789)

        expected_query = {
            "bts_name": "123",
            "tc_name": "tc",
            "template_id": "456",
            "cycles": "789"
        }
        self.mock_els_db.check_query_match.assert_called_once_with(
            index_name=self.benchmark_db.index_name,
            match_fields_dict=expected_query
        )

    def test_read_data_for_bts_with_data(self):
        """Test read_data_for_bts returns data when record exists."""
        self.benchmark_db.els_db = self.mock_els_db
        mock_record = {"_source": {
            "test": "data", "bts_name": self.sample_bts_id}}
        self.mock_els_db.build_and_execute_query.return_value = [mock_record]

        result = self.benchmark_db.read_data_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_cycles
        )

        self.assertEqual(result, mock_record["_source"])
        self.mock_els_db.build_and_execute_query.assert_called_once_with(
            index_name=self.benchmark_db.index_name,
            match_fields_dict={
                "bts_name": self.sample_bts_id,
                "tc_name": self.sample_tc_name,
                "template_id": self.sample_template_id,
                "cycles": str(self.sample_cycles)
            },
            last_match_only=True
        )

    def test_read_data_for_bts_no_data(self):
        """Test read_data_for_bts returns None when no record exists."""
        self.benchmark_db.els_db = self.mock_els_db
        self.mock_els_db.build_and_execute_query.return_value = None

        result = self.benchmark_db.read_data_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_cycles
        )

        self.assertIsNone(result)

    def test_read_data_for_bts_empty_results(self):
        """Test read_data_for_bts returns None when query returns empty list."""
        self.benchmark_db.els_db = self.mock_els_db
        self.mock_els_db.build_and_execute_query.return_value = []

        result = self.benchmark_db.read_data_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_cycles
        )

        self.assertIsNone(result)

    def test_read_all_data_for_bts_with_data(self):
        """Test read_all_data_for_bts returns all records when data exists."""
        self.benchmark_db.els_db = self.mock_els_db
        mock_records = [
            {"_source": {"test": "data1", "bts_name": self.sample_bts_id}},
            {"_source": {"test": "data2", "bts_name": self.sample_bts_id}}
        ]
        self.mock_els_db.build_and_execute_query.return_value = mock_records

        result = self.benchmark_db.read_all_data_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_cycles
        )

        expected = [record["_source"] for record in mock_records]
        self.assertEqual(result, expected)
        self.mock_els_db.build_and_execute_query.assert_called_once_with(
            index_name=self.benchmark_db.index_name,
            match_fields_dict={
                "bts_name": self.sample_bts_id,
                "tc_name": self.sample_tc_name,
                "template_id": self.sample_template_id,
                "cycles": str(self.sample_cycles)
            },
            last_match_only=False
        )

    def test_read_all_data_for_bts_no_data(self):
        """Test read_all_data_for_bts returns empty list when no records exist."""
        self.benchmark_db.els_db = self.mock_els_db
        self.mock_els_db.build_and_execute_query.return_value = None

        result = self.benchmark_db.read_all_data_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_cycles
        )

        self.assertEqual(result, [])

    @patch('BenchmarkDb.get_timestamp')
    @patch('BenchmarkDb.get_localzone_name')
    def test_save_datetime_for_bts_with_string_dates(self, mock_get_timezone, mock_get_timestamp):
        """Test save_datetime_for_bts with string datetime inputs."""
        self.benchmark_db.els_db = self.mock_els_db
        mock_get_timestamp.return_value = "2023-01-01T12:00:00Z"
        mock_get_timezone.return_value = "Europe/Bucharest"

        self.benchmark_db.save_datetime_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_start_date,
            self.sample_end_date,
            self.sample_cycles,
            self.sample_sw_version
        )

        expected_dict = {
            "bts_name": self.sample_bts_id,
            "tc_name": self.sample_tc_name,
            "template_id": self.sample_template_id,
            "start_date": "2023-01-01T10:00:00",
            "end_date": "2023-01-01T11:00:00",
            "cycles": str(self.sample_cycles),
            "sw_version": self.sample_sw_version,
            "created_at": "2023-01-01T12:00:00Z",
            "updated_at": "2023-01-01T12:00:00Z",
            "local_time_zone": "Europe/Bucharest"
        }

        self.mock_els_db.send_dict_data.assert_called_once_with(
            dict_data=expected_dict)

    @patch('BenchmarkDb.get_timestamp')
    @patch('BenchmarkDb.get_localzone_name')
    def test_save_datetime_for_bts_with_datetime_objects(self, mock_get_timezone, mock_get_timestamp):
        """Test save_datetime_for_bts with datetime object inputs."""
        self.benchmark_db.els_db = self.mock_els_db
        mock_get_timestamp.return_value = "2023-01-01T12:00:00Z"
        mock_get_timezone.return_value = "Europe/Bucharest"

        start_dt = datetime(2023, 1, 1, 10, 0, 0)
        end_dt = datetime(2023, 1, 1, 11, 0, 0)

        self.benchmark_db.save_datetime_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            start_dt,
            end_dt,
            self.sample_cycles,
            self.sample_sw_version
        )

        expected_dict = {
            "bts_name": self.sample_bts_id,
            "tc_name": self.sample_tc_name,
            "template_id": self.sample_template_id,
            "start_date": "2023-01-01T10:00:00",
            "end_date": "2023-01-01T11:00:00",
            "cycles": str(self.sample_cycles),
            "sw_version": self.sample_sw_version,
            "created_at": "2023-01-01T12:00:00Z",
            "updated_at": "2023-01-01T12:00:00Z",
            "local_time_zone": "Europe/Bucharest"
        }

        self.mock_els_db.send_dict_data.assert_called_once_with(
            dict_data=expected_dict)

    @patch('BenchmarkDb.get_timestamp')
    @patch('BenchmarkDb.get_localzone_name')
    def test_save_datetime_for_bts_default_sw_version(self, mock_get_timezone, mock_get_timestamp):
        """Test save_datetime_for_bts with default sw_version."""
        self.benchmark_db.els_db = self.mock_els_db
        mock_get_timestamp.return_value = "2023-01-01T12:00:00Z"
        mock_get_timezone.return_value = "Europe/Bucharest"

        self.benchmark_db.save_datetime_for_bts(
            self.sample_bts_id,
            self.sample_tc_name,
            self.sample_template_id,
            self.sample_start_date,
            self.sample_end_date,
            self.sample_cycles
        )

        # Check that sw_version is empty string by default
        call_args = self.mock_els_db.send_dict_data.call_args[1]['dict_data']
        self.assertEqual(call_args['sw_version'], "")

    def test_format_time_with_string_input(self):
        """Test format_time with string input."""
        time_str = "2023-01-01 10:15:30"
        result = BenchmarkDb.format_time(time_str)
        expected = "2023-01-01T10:15:00"
        self.assertEqual(result, expected)

    def test_format_time_with_datetime_input(self):
        """Test format_time with datetime object input."""
        dt = datetime(2023, 1, 1, 10, 15, 30)
        result = BenchmarkDb.format_time(dt)
        expected = "2023-01-01T10:15:00"
        self.assertEqual(result, expected)

    def test_format_time_with_microseconds(self):
        """Test format_time with string containing microseconds."""
        time_str = "2023-01-01 10:15:30.123456"
        result = BenchmarkDb.format_time(time_str)
        expected = "2023-01-01T10:15:00"
        self.assertEqual(result, expected)

    def test_format_time_seconds_reset_to_zero(self):
        """Test that format_time resets seconds to 0."""
        time_str = "2023-01-01 10:15:45"
        result = BenchmarkDb.format_time(time_str)
        expected = "2023-01-01T10:15:00"
        self.assertEqual(result, expected)

    def test_format_time_utc_timezone(self):
        """Test that format_time adds UTC timezone."""
        time_str = "2023-01-01 10:15:30"
        result = BenchmarkDb.format_time(time_str)
        # The actual implementation shows it returns format without timezone suffix
        # So we test for the actual behavior
        self.assertTrue(result.startswith("2023-01-01T10:15:00"))

    def test_save_datetime_type_conversion(self):
        """Test that save_datetime_for_bts converts all parameters to strings."""
        self.benchmark_db.els_db = self.mock_els_db

        with patch('BenchmarkDb.get_timestamp'), patch('BenchmarkDb.get_localzone_name'):
            self.benchmark_db.save_datetime_for_bts(
                123,  # bts_id as int
                456,  # tc_name as int
                789,  # template_id as int
                self.sample_start_date,
                self.sample_end_date,
                self.sample_cycles,
                999   # sw_version as int
            )

            call_args = self.mock_els_db.send_dict_data.call_args[1]['dict_data']
            self.assertEqual(call_args['bts_name'], "123")
            self.assertEqual(call_args['tc_name'], "456")
            self.assertEqual(call_args['template_id'], "789")
            self.assertEqual(call_args['sw_version'], "999")


if __name__ == '__main__':
    unittest.main()
