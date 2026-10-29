# -*- coding: utf-8 -*-
"""
Unit tests for KeepAlive module.
"""

from KeepAlive import KeepAlive, KeepAliveThread
import unittest
from unittest.mock import patch, MagicMock, call
import sys
import os
import time
from threading import Event

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Mock the external dependencies before importing
sys.modules['robot'] = MagicMock()
sys.modules['robot.libraries'] = MagicMock()
sys.modules['robot.libraries.BuiltIn'] = MagicMock()


class TestKeepAliveThread(unittest.TestCase):
    """Test cases for KeepAliveThread class."""

    def setUp(self):
        """Set up test fixtures."""
        self.thread = KeepAliveThread()
        self.mock_library = MagicMock()
        self.test_alias = "test_alias"
        self.test_username = "test_user"
        self.test_password = "test_pass"

    def test_init(self):
        """Test KeepAliveThread initialization."""
        self.assertIsInstance(self.thread.stop_event, Event)
        self.assertIsNone(self.thread.library_instance)
        self.assertEqual(self.thread.library_name, "")
        self.assertEqual(self.thread.alias, "")
        self.assertEqual(self.thread.username, "")
        self.assertEqual(self.thread.password, "")

    def test_stop(self):
        """Test stop method sets the stop event."""
        self.assertFalse(self.thread.stop_event.is_set())
        self.thread.stop()
        self.assertTrue(self.thread.stop_event.is_set())

    @patch('KeepAlive.BuiltIn')
    def test_start_keepalive(self, mock_builtin):
        """Test start_keepalive method configuration."""
        mock_builtin_instance = MagicMock()
        mock_builtin.return_value = mock_builtin_instance
        mock_builtin_instance.get_library_instance.return_value = self.mock_library

        library_name = "test_library"

        with patch.object(self.thread, 'start') as mock_start:
            self.thread.start_keepalive(library_name, self.test_alias,
                                        self.test_username, self.test_password)

        self.assertEqual(self.thread.library_instance, self.mock_library)
        self.assertEqual(self.thread.library_name, library_name)
        self.assertEqual(self.thread.alias, self.test_alias)
        self.assertEqual(self.thread.username, self.test_username)
        self.assertEqual(self.thread.password, self.test_password)
        mock_start.assert_called_once()

    @patch('KeepAlive.time.sleep')
    def test_run_non_vdu_library(self, mock_sleep):
        """Test run method with non-VDU library."""
        self.thread.library_instance = self.mock_library
        self.thread.library_name = "test_library"
        self.thread.alias = self.test_alias
        self.thread.username = self.test_username
        self.thread.password = self.test_password

        # Set stop event after first iteration
        def side_effect(*args):
            self.thread.stop_event.set()

        mock_sleep.side_effect = side_effect

        self.thread.run()

        # Verify refresh_token was called with correct parameters
        self.mock_library.refresh_token.assert_called_once_with(
            username=self.test_username,
            password=self.test_password,
            connection=self.test_alias
        )

    @patch('KeepAlive.time.sleep')
    def test_run_vdu_library(self, mock_sleep):
        """Test run method with VDU library."""
        self.thread.library_instance = self.mock_library
        self.thread.library_name = "vdu"
        self.thread.alias = self.test_alias
        self.thread.username = self.test_username
        self.thread.password = self.test_password

        # Set stop event after first iteration
        def side_effect(*args):
            self.thread.stop_event.set()

        mock_sleep.side_effect = side_effect

        self.thread.run()

        # Verify refresh_token was called with vdu_connection parameter
        self.mock_library.refresh_token.assert_called_once_with(
            username=self.test_username,
            password=self.test_password,
            vdu_connection=self.test_alias
        )

    @patch('KeepAlive.time.sleep')
    def test_run_stop_during_sleep_loop(self, mock_sleep):
        """Test run method stops correctly during sleep loop."""
        self.thread.library_instance = self.mock_library
        self.thread.library_name = "test_library"
        self.thread.alias = self.test_alias
        self.thread.username = self.test_username
        self.thread.password = self.test_password

        # Counter to track sleep calls
        sleep_call_count = 0

        def sleep_side_effect(*args):
            nonlocal sleep_call_count
            sleep_call_count += 1
            if sleep_call_count == 3:  # Stop after 3 sleep calls
                self.thread.stop_event.set()

        mock_sleep.side_effect = sleep_side_effect

        self.thread.run()

        # Verify refresh_token was called
        self.mock_library.refresh_token.assert_called_once()
        # Verify sleep was called multiple times but stopped when event was set
        self.assertEqual(mock_sleep.call_count, 3)

    @patch('KeepAlive.time.sleep')
    def test_run_multiple_refresh_cycles(self, mock_sleep):
        """Test run method performs multiple refresh cycles."""
        self.thread.library_instance = self.mock_library
        self.thread.library_name = "test_library"
        self.thread.alias = self.test_alias
        self.thread.username = self.test_username
        self.thread.password = self.test_password

        refresh_call_count = 0

        def refresh_side_effect(*args, **kwargs):
            nonlocal refresh_call_count
            refresh_call_count += 1
            if refresh_call_count == 2:  # Stop after 2 refresh calls
                self.thread.stop_event.set()

        self.mock_library.refresh_token.side_effect = refresh_side_effect

        self.thread.run()

        # Verify refresh_token was called twice
        self.assertEqual(self.mock_library.refresh_token.call_count, 2)


class TestKeepAlive(unittest.TestCase):
    """Test cases for KeepAlive class."""

    def setUp(self):
        """Set up test fixtures."""
        self.keepalive = KeepAlive()
        self.test_library = "test_library"
        self.test_alias = "test_alias"
        self.test_username = "test_user"
        self.test_password = "test_pass"

    def test_init(self):
        """Test KeepAlive initialization."""
        self.assertIsInstance(self.keepalive.keepalive_threads, dict)

    @patch('KeepAlive.KeepAliveThread')
    @patch('KeepAlive.logging')
    def test_start_keepalive(self, mock_logging, mock_thread_class):
        """Test start_keepalive creates and starts thread."""
        mock_thread = MagicMock()
        mock_thread_class.return_value = mock_thread

        self.keepalive.start_keepalive(self.test_library, self.test_alias,
                                       self.test_username, self.test_password)

        # Verify thread was created and configured
        mock_thread_class.assert_called_once()
        mock_thread.start_keepalive.assert_called_once_with(
            self.test_library, self.test_alias, self.test_username, self.test_password
        )

        # Verify thread was stored
        self.assertEqual(
            self.keepalive.keepalive_threads[self.test_library][self.test_alias],
            mock_thread
        )

        # Verify logging
        mock_logging.info.assert_called_once_with(
            f'Keepalive started - {self.test_library}, on {self.test_alias}'
        )

    @patch('KeepAlive.logging')
    def test_stop_keepalive(self, mock_logging):
        """Test stop_keepalive stops the correct thread."""
        # Set up a mock thread
        mock_thread = MagicMock()
        self.keepalive.keepalive_threads[self.test_library][self.test_alias] = mock_thread

        self.keepalive.stop_keepalive(self.test_library, self.test_alias)

        # Verify thread stop was called
        mock_thread.stop.assert_called_once()

        # Verify logging
        mock_logging.info.assert_called_once_with(
            f'Keepalive stopped - {self.test_library}, on {self.test_alias}'
        )

    @patch('KeepAlive.KeepAliveThread')
    def test_multiple_libraries_and_aliases(self, mock_thread_class):
        """Test handling multiple libraries and aliases."""
        mock_thread1 = MagicMock()
        mock_thread2 = MagicMock()
        mock_thread3 = MagicMock()
        mock_thread_class.side_effect = [
            mock_thread1, mock_thread2, mock_thread3]

        # Start keepalive for different libraries and aliases
        self.keepalive.start_keepalive("lib1", "alias1", "user1", "pass1")
        self.keepalive.start_keepalive("lib1", "alias2", "user2", "pass2")
        self.keepalive.start_keepalive("lib2", "alias1", "user3", "pass3")

        # Verify all threads were created and stored correctly
        self.assertEqual(
            self.keepalive.keepalive_threads["lib1"]["alias1"], mock_thread1)
        self.assertEqual(
            self.keepalive.keepalive_threads["lib1"]["alias2"], mock_thread2)
        self.assertEqual(
            self.keepalive.keepalive_threads["lib2"]["alias1"], mock_thread3)

        # Verify all threads were configured
        mock_thread1.start_keepalive.assert_called_once_with(
            "lib1", "alias1", "user1", "pass1")
        mock_thread2.start_keepalive.assert_called_once_with(
            "lib1", "alias2", "user2", "pass2")
        mock_thread3.start_keepalive.assert_called_once_with(
            "lib2", "alias1", "user3", "pass3")

    def test_stop_keepalive_specific_thread(self):
        """Test stopping specific thread doesn't affect others."""
        # Set up multiple mock threads
        mock_thread1 = MagicMock()
        mock_thread2 = MagicMock()
        mock_thread3 = MagicMock()

        self.keepalive.keepalive_threads["lib1"]["alias1"] = mock_thread1
        self.keepalive.keepalive_threads["lib1"]["alias2"] = mock_thread2
        self.keepalive.keepalive_threads["lib2"]["alias1"] = mock_thread3

        # Stop only one thread
        self.keepalive.stop_keepalive("lib1", "alias1")

        # Verify only the correct thread was stopped
        mock_thread1.stop.assert_called_once()
        mock_thread2.stop.assert_not_called()
        mock_thread3.stop.assert_not_called()

    @patch('KeepAlive.KeepAliveThread')
    def test_start_keepalive_overwrites_existing_thread(self, mock_thread_class):
        """Test starting keepalive on same library/alias overwrites existing thread."""
        mock_thread1 = MagicMock()
        mock_thread2 = MagicMock()
        mock_thread_class.side_effect = [mock_thread1, mock_thread2]

        # Start keepalive twice on same library/alias
        self.keepalive.start_keepalive(self.test_library, self.test_alias,
                                       "user1", "pass1")
        self.keepalive.start_keepalive(self.test_library, self.test_alias,
                                       "user2", "pass2")

        # Verify the second thread overwrote the first
        self.assertEqual(
            self.keepalive.keepalive_threads[self.test_library][self.test_alias],
            mock_thread2
        )

        # Verify both threads were configured
        mock_thread1.start_keepalive.assert_called_once_with(
            self.test_library, self.test_alias, "user1", "pass1"
        )
        mock_thread2.start_keepalive.assert_called_once_with(
            self.test_library, self.test_alias, "user2", "pass2"
        )

    def test_keepalive_threads_structure(self):
        """Test that keepalive_threads maintains proper nested structure."""
        # Initially empty
        self.assertEqual(len(self.keepalive.keepalive_threads), 0)

        # Add a thread
        mock_thread = MagicMock()
        self.keepalive.keepalive_threads["lib1"]["alias1"] = mock_thread

        # Verify structure
        self.assertIn("lib1", self.keepalive.keepalive_threads)
        self.assertIn("alias1", self.keepalive.keepalive_threads["lib1"])
        self.assertEqual(
            self.keepalive.keepalive_threads["lib1"]["alias1"], mock_thread)

        # Verify defaultdict behavior - accessing non-existent library creates empty dict
        self.keepalive.keepalive_threads["lib2"]["alias2"] = MagicMock()
        self.assertIn("lib2", self.keepalive.keepalive_threads)
        self.assertIn("alias2", self.keepalive.keepalive_threads["lib2"])


class TestKeepAliveIntegration(unittest.TestCase):
    """Integration tests for KeepAlive components."""

    @patch('KeepAlive.BuiltIn')
    @patch('KeepAlive.time.sleep')
    def test_full_workflow(self, mock_sleep, mock_builtin):
        """Test complete workflow from start to stop."""
        # Set up mocks
        mock_library = MagicMock()
        mock_builtin_instance = MagicMock()
        mock_builtin.return_value = mock_builtin_instance
        mock_builtin_instance.get_library_instance.return_value = mock_library

        # Control the thread execution
        def sleep_side_effect(*args):
            pass  # Don't actually sleep in tests

        mock_sleep.side_effect = sleep_side_effect

        # Create KeepAlive instance
        keepalive = KeepAlive()

        # Start keepalive
        keepalive.start_keepalive("test_lib", "test_alias", "user", "pass")

        # Verify thread was created and started
        self.assertIn("test_lib", keepalive.keepalive_threads)
        self.assertIn("test_alias", keepalive.keepalive_threads["test_lib"])

        thread = keepalive.keepalive_threads["test_lib"]["test_alias"]
        self.assertIsInstance(thread, KeepAliveThread)

        # Stop the thread immediately to prevent it from running
        thread.stop()

        # Verify the thread can be stopped via KeepAlive
        keepalive.stop_keepalive("test_lib", "test_alias")


if __name__ == '__main__':
    unittest.main()
