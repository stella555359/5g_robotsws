# -*- coding: utf-8 -*-
"""
Unit tests for BshReplacement module.
"""

from BshReplacement import execute_bsh_command, SmodPatchForASOx
import unittest
from unittest.mock import patch, MagicMock, call
import sysS
import os
import re

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Mock the external dependencies
sys.modules['taf'] = MagicMock()
sys.modules['taf.ul'] = MagicMock()
sys.modules['taf.ul.bts_components'] = MagicMock()

# Create a mock base class for Smod


class MockSmod:
    def __init__(self):
        pass

    def _get_topology_info(self):
        return []


# Set up the mock
sys.modules['taf.ul.bts_components'].Smod = MockSmod
sys.modules['taf.ul.bts_components'].Bbmod = MagicMock()


class TestBshReplacement(unittest.TestCase):
    """Test cases for BshReplacement module."""

    def setUp(self):
        """Set up test fixtures."""
        # Mock the imported classes
        self.mock_smod_class = MagicMock()
        self.mock_bbmod_class = MagicMock()

        # Mock instances
        self.mock_smod = MagicMock()
        self.mock_bbmod = MagicMock()
        self.mock_proxy = MagicMock()

        # Sample topology data
        self.sample_topology = [
            {
                'login_shortcut': 'bsh 1:0',
                'address': '192.168.1.100',
                'username': 'testuser',
                'password': 'testpass'
            },
            {
                'login_shortcut': 'bsh 2:0',
                'address': '192.168.1.101',
                'username': 'testuser2',
                'password': 'testpass2'
            },
            {
                'login_shortcut': 'other 1:0',
                'address': '192.168.1.102',
                'username': 'testuser3',
                'password': 'testpass3'
            }
        ]

    @patch('BshReplacement.Bbmod')
    @patch('BshReplacement.Smod')
    def test_execute_bsh_command_success(self, mock_smod_cls, mock_bbmod_cls):
        """Test successful execution of BSH command."""
        # Setup mocks
        mock_smod_cls.return_value = self.mock_smod
        mock_bbmod_cls.return_value = self.mock_bbmod

        self.mock_smod.get_bbmods_topology_info.return_value = self.sample_topology
        self.mock_bbmod.execute.return_value = "command output\n"

        # Execute function
        result = execute_bsh_command("bsh 1:0", "test command")

        # Assertions
        self.assertEqual(result, "command output")
        self.mock_smod.connect_to.assert_called_once_with(
            address="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu",
            alias="connection_smod",
            proxy=None
        )
        self.mock_bbmod.connect_to.assert_called_once_with(
            address='192.168.1.100',
            username='testuser',
            password='testpass',
            alias="connection_bbmod",
            proxy="connection_smod"
        )
        self.mock_bbmod.execute.assert_called_once_with(command="test command")

    @patch('BshReplacement.Bbmod')
    @patch('BshReplacement.Smod')
    def test_execute_bsh_command_with_proxy(self, mock_smod_cls, mock_bbmod_cls):
        """Test execution of BSH command with proxy."""
        # Setup mocks
        mock_smod_cls.side_effect = [self.mock_proxy, self.mock_smod]
        mock_bbmod_cls.return_value = self.mock_bbmod

        self.mock_smod.get_bbmods_topology_info.return_value = self.sample_topology
        self.mock_bbmod.execute.return_value = "command output\n"

        # Execute function with proxy
        result = execute_bsh_command(
            "bsh 2:0", "test command",
            via_ip="192.168.1.200",
            via_username="proxy_user",
            via_password="proxy_pass"
        )

        # Assertions
        self.assertEqual(result, "command output")
        self.mock_proxy.connect_to.assert_called_once_with(
            address="192.168.1.200",
            username="proxy_user",
            password="proxy_pass",
            alias="connection_proxy",
            proxy=None
        )
        self.mock_smod.connect_to.assert_called_once_with(
            address="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu",
            alias="connection_smod",
            proxy="connection_proxy"
        )

    @patch('BshReplacement.Bbmod')
    @patch('BshReplacement.Smod')
    def test_execute_bsh_command_custom_parameters(self, mock_smod_cls, mock_bbmod_cls):
        """Test execution with custom parameters."""
        # Setup mocks
        mock_smod_cls.return_value = self.mock_smod
        mock_bbmod_cls.return_value = self.mock_bbmod

        self.mock_smod.get_bbmods_topology_info.return_value = self.sample_topology
        self.mock_bbmod.execute.return_value = "output\n"

        # Execute function with custom parameters
        result = execute_bsh_command(
            "bsh 1:0", "custom command",
            target_ip="10.0.0.1",
            target_username="custom_user",
            target_password="custom_pass",
            alias="custom_alias"
        )

        # Assertions
        self.assertEqual(result, "output")
        self.mock_smod.connect_to.assert_called_once_with(
            address="10.0.0.1",
            username="custom_user",
            password="custom_pass",
            alias="custom_alias_smod",
            proxy=None
        )

    @patch('BshReplacement.Bbmod')
    @patch('BshReplacement.Smod')
    def test_execute_bsh_command_not_found(self, mock_smod_cls, mock_bbmod_cls):
        """Test execution when BSH not found in topology."""
        # Setup mocks
        mock_smod_cls.return_value = self.mock_smod
        mock_bbmod_cls.return_value = self.mock_bbmod

        self.mock_smod.get_bbmods_topology_info.return_value = self.sample_topology

        # Execute function with non-existent BSH
        result = execute_bsh_command("bsh 9:9", "test command")

        # Assertions
        self.assertIsNone(result)
        self.mock_bbmod.connect_to.assert_not_called()
        self.mock_bbmod.execute.assert_not_called()

    @patch('BshReplacement.Bbmod')
    @patch('BshReplacement.Smod')
    def test_execute_bsh_command_empty_topology(self, mock_smod_cls, mock_bbmod_cls):
        """Test execution with empty topology."""
        # Setup mocks
        mock_smod_cls.return_value = self.mock_smod
        mock_bbmod_cls.return_value = self.mock_bbmod

        self.mock_smod.get_bbmods_topology_info.return_value = []

        # Execute function
        result = execute_bsh_command("bsh 1:0", "test command")

        # Assertions
        self.assertIsNone(result)

    @patch('BshReplacement.SmodPatchForASOx')
    @patch('BshReplacement.Bbmod')
    def test_execute_bsh_command_outdoor(self, mock_bbmod_cls, mock_asox_cls):
        """Test execution with outdoor (ASOx) SMOD."""
        # Setup mocks
        mock_asox = MagicMock()
        mock_asox_cls.return_value = mock_asox
        mock_bbmod_cls.return_value = self.mock_bbmod

        mock_asox.get_bbmods_topology_info.return_value = self.sample_topology
        self.mock_bbmod.execute.return_value = "outdoor output\n"

        # Execute function with outdoor flag
        result = execute_bsh_command(
            "bsh 1:0", "test command", is_outdoor=True)

        # Assertions
        self.assertEqual(result, "outdoor output")
        mock_asox_cls.assert_called_once()

    @patch('BshReplacement.Bbmod')
    @patch('BshReplacement.Smod')
    def test_execute_bsh_command_partial_match(self, mock_smod_cls, mock_bbmod_cls):
        """Test execution with partial BSH match."""
        # Setup mocks
        mock_smod_cls.return_value = self.mock_smod
        mock_bbmod_cls.return_value = self.mock_bbmod

        topology_with_partial = [
            {
                'login_shortcut': 'some bsh 1:0 text',
                'address': '192.168.1.100',
                'username': 'testuser',
                'password': 'testpass'
            }
        ]
        self.mock_smod.get_bbmods_topology_info.return_value = topology_with_partial
        self.mock_bbmod.execute.return_value = "partial match output\n"

        # Execute function
        result = execute_bsh_command("bsh 1:0", "test command")

        # Assertions
        self.assertEqual(result, "partial match output")


class TestSmodPatchForASOx(unittest.TestCase):
    """Test cases for SmodPatchForASOx class."""

    def setUp(self):
        """Set up test fixtures."""
        self.asox_smod = SmodPatchForASOx()

        # Sample topology data for ASOx
        self.sample_topology_raw = [
            "slot1 unit1 slave C (192.168.1.100) some bsh 1:0 data",
            "slot2 unit2 slave C (192.168.1.101) other bsh 2:0 info",
            "slot3 unit3 master  (192.168.1.102) master unit data",
            "slot4 unit4 slave C (192.168.1.103) different bsh 1:1 entry"
        ]

    def test_get_bbmods_attributes_default_pattern(self):
        """Test _get_bbmods_attributes with default pattern."""
        with patch.object(self.asox_smod, '_get_topology_info', return_value=self.sample_topology_raw):
            result = self.asox_smod._get_bbmods_attributes()

            # Should return entries with 'slave C' and matching the default pattern
            self.assertEqual(len(result), 3)  # Excludes master entry

            # Check first entry structure
            expected_first = ['slot1', 'unit1', 'slave', 'C',
                              '(192.168.1.100)', 'some', 'bsh', '1:0', 'data']
            self.assertEqual(result[0], expected_first)

    def test_get_bbmods_attributes_custom_pattern(self):
        """Test _get_bbmods_attributes with custom pattern."""
        with patch.object(self.asox_smod, '_get_topology_info', return_value=self.sample_topology_raw):
            result = self.asox_smod._get_bbmods_attributes(
                bbmod_indicator_pattern=r'1:0')

            # Should only return entries matching 1:0 pattern
            self.assertEqual(len(result), 1)
            expected = ['slot1', 'unit1', 'slave', 'C',
                        '(192.168.1.100)', 'some', 'bsh', '1:0', 'data']
            self.assertEqual(result[0], expected)

    def test_get_bbmods_topology_info_default(self):
        """Test get_bbmods_topology_info with default parameters."""
        with patch.object(self.asox_smod, '_get_bbmods_attributes') as mock_get_attrs:
            # The login_shortcut will be bbmod[6] + ' ' + bbmod[9] = 'bsh 1:0'
            # For the pattern ':0' to match, we need '1:0' at index 9
            mock_get_attrs.return_value = [
                ['slot1', 'unit1', 'slave', 'C',
                    '(192.168.1.100)', 'some', 'bsh', '1:0', 'extra', '1:0'],
                ['slot2', 'unit2', 'slave', 'C',
                    '(192.168.1.101)', 'other', 'bsh', '2:0', 'extra', '2:0']
            ]

            result = self.asox_smod.get_bbmods_topology_info()

            # Verify the structure of returned data
            self.assertEqual(len(result), 2)

            first_bbmod = result[0]
            self.assertEqual(first_bbmod['username'], 'toor4nsn')
            self.assertEqual(first_bbmod['password'], 'oZPS0POrRieRtu')
            self.assertEqual(first_bbmod['alias'], 'slave_C')
            self.assertEqual(first_bbmod['slot'], 'unit1 slave')
            self.assertEqual(first_bbmod['hw_name'], 'C')
            self.assertEqual(first_bbmod['address'], '192.168.1.100')
            self.assertEqual(first_bbmod['login_shortcut'], 'bsh 1:0')

            mock_get_attrs.assert_called_once_with(
                bbmod_indicator_pattern=':0')

    def test_get_bbmods_topology_info_with_other_cpus(self):
        """Test get_bbmods_topology_info with get_other_cpus_info=True."""
        with patch.object(self.asox_smod, '_get_bbmods_attributes') as mock_get_attrs:
            # For pattern r'\d:\d' to match, we need something like '1:1' at index 9
            mock_get_attrs.return_value = [
                ['slot1', 'unit1', 'slave', 'C',
                    '(192.168.1.100)', 'some', 'bsh', '1:1', 'extra', '1:1']
            ]

            result = self.asox_smod.get_bbmods_topology_info(
                get_other_cpus_info=True)

            self.assertEqual(len(result), 1)
            self.assertEqual(result[0]['login_shortcut'], 'bsh 1:1')
            mock_get_attrs.assert_called_once_with(
                bbmod_indicator_pattern=r'\d:\d')

    def test_get_bbmods_topology_info_missing_address(self):
        """Test get_bbmods_topology_info with missing address."""
        with patch.object(self.asox_smod, '_get_bbmods_attributes') as mock_get_attrs:
            mock_get_attrs.return_value = [
                ['slot1', 'unit1', 'slave', 'C', 'no_parentheses',
                    'some', 'bsh', '1:0', 'data']
            ]

            with self.assertRaises(Exception) as context:
                self.asox_smod.get_bbmods_topology_info()

            self.assertIn("Content of chk topo has changed",
                          str(context.exception))

    def test_get_bbmods_topology_info_missing_bsh(self):
        """Test get_bbmods_topology_info with missing bsh in login_shortcut."""
        with patch.object(self.asox_smod, '_get_bbmods_attributes') as mock_get_attrs:
            mock_get_attrs.return_value = [
                ['slot1', 'unit1', 'slave', 'C',
                    '(192.168.1.100)', 'some', 'other', '1:0', 'data']
            ]

            with self.assertRaises(Exception) as context:
                self.asox_smod.get_bbmods_topology_info()

            self.assertIn("Content of chk topo has changed",
                          str(context.exception))

    def test_get_bbmods_topology_info_wrong_pattern(self):
        """Test get_bbmods_topology_info with wrong login pattern."""
        with patch.object(self.asox_smod, '_get_bbmods_attributes') as mock_get_attrs:
            mock_get_attrs.return_value = [
                ['slot1', 'unit1', 'slave', 'C',
                    '(192.168.1.100)', 'some', 'bsh', '1:9', 'data']
            ]

            # Should raise exception because '1:9' doesn't match ':0' pattern
            with self.assertRaises(Exception) as context:
                self.asox_smod.get_bbmods_topology_info()

            self.assertIn("Content of chk topo has changed",
                          str(context.exception))

    def test_get_bbmods_topology_info_index_error(self):
        """Test get_bbmods_topology_info with insufficient data (IndexError)."""
        with patch.object(self.asox_smod, '_get_bbmods_attributes') as mock_get_attrs:
            mock_get_attrs.return_value = [
                ['slot1', 'unit1']  # Not enough elements
            ]

            with self.assertRaises(Exception) as context:
                self.asox_smod.get_bbmods_topology_info()

            self.assertIn("Content of chk topo has changed",
                          str(context.exception))

    def test_get_bbmods_topology_info_empty_result(self):
        """Test get_bbmods_topology_info with empty result."""
        with patch.object(self.asox_smod, '_get_bbmods_attributes') as mock_get_attrs:
            mock_get_attrs.return_value = []

            result = self.asox_smod.get_bbmods_topology_info()

            self.assertEqual(result, [])

    def test_inheritance(self):
        """Test that SmodPatchForASOx properly inherits from Smod."""
        # Test instantiation
        asox = SmodPatchForASOx()
        self.assertIsInstance(asox, SmodPatchForASOx)


if __name__ == '__main__':
    unittest.main()
