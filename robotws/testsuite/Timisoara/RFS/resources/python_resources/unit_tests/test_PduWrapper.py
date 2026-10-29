# -*- coding: utf-8 -*-
"""
Unit tests for PduWrapper module.
"""

from PduWrapper import PduWrapper
import unittest
from unittest.mock import patch, MagicMock
import sys
import os

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Mock the external dependencies before importing
sys.modules['taf'] = MagicMock()
sys.modules['taf.hw'] = MagicMock()
sys.modules['taf.hw.pdu'] = MagicMock()


class TestPduWrapper(unittest.TestCase):
    """Test cases for PduWrapper class."""

    def setUp(self):
        """Set up test fixtures."""
        self.mock_pdu_class = MagicMock()
        self.mock_pdu_instance = MagicMock()
        self.mock_pdu_class.return_value = self.mock_pdu_instance

        # Sample test data
        self.sample_model = "APC_7900"
        self.sample_alias = "pdu_test_01"
        self.sample_timeout = 30

    @patch('PduWrapper.pdu')
    def test_init(self, mock_pdu_class):
        """Test PduWrapper initialization."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Verify pdu class was instantiated
        mock_pdu_class.assert_called_once()

        # Verify pduobj attribute is set correctly
        self.assertEqual(wrapper.pduobj, mock_pdu_instance)

    @patch('PduWrapper.pdu')
    def test_setup_pdu_basic(self, mock_pdu_class):
        """Test setup_pdu method with basic parameters."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Call setup_pdu
        wrapper.setup_pdu(self.sample_model,
                          self.sample_alias, self.sample_timeout)

        # Verify setup_pdu was called on the pdu instance with correct parameters
        mock_pdu_instance.setup_pdu.assert_called_once_with(
            model=self.sample_model,
            alias=self.sample_alias,
            timeout=self.sample_timeout
        )

    @patch('PduWrapper.pdu')
    def test_setup_pdu_parameter_passing(self, mock_pdu_class):
        """Test setup_pdu method parameter passing with various types."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Test with different parameter types
        test_cases = [
            ("APC_7900", "pdu_alias_1", 30),
            ("RARITAN_PX2", "pdu_alias_2", 60),
            ("CUSTOM_MODEL", "test_pdu", 45),
        ]

        for model, alias, timeout in test_cases:
            with self.subTest(model=model, alias=alias, timeout=timeout):
                mock_pdu_instance.reset_mock()
                wrapper.setup_pdu(model, alias, timeout)

                mock_pdu_instance.setup_pdu.assert_called_once_with(
                    model=model,
                    alias=alias,
                    timeout=timeout
                )

    @patch('PduWrapper.pdu')
    def test_setup_pdu_string_parameters(self, mock_pdu_class):
        """Test setup_pdu with string parameters."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Test with string timeout (should be passed as-is)
        string_timeout = "30"
        wrapper.setup_pdu(self.sample_model, self.sample_alias, string_timeout)

        mock_pdu_instance.setup_pdu.assert_called_once_with(
            model=self.sample_model,
            alias=self.sample_alias,
            timeout=string_timeout
        )

    @patch('PduWrapper.pdu')
    def test_setup_pdu_none_parameters(self, mock_pdu_class):
        """Test setup_pdu with None parameters."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Test with None values
        wrapper.setup_pdu(None, None, None)

        mock_pdu_instance.setup_pdu.assert_called_once_with(
            model=None,
            alias=None,
            timeout=None
        )

    @patch('PduWrapper.pdu')
    def test_setup_pdu_exception_propagation(self, mock_pdu_class):
        """Test that exceptions from pdu.setup_pdu are propagated."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance
        mock_pdu_instance.setup_pdu.side_effect = Exception("PDU setup failed")

        wrapper = PduWrapper()

        # Verify exception is propagated
        with self.assertRaises(Exception) as context:
            wrapper.setup_pdu(self.sample_model,
                              self.sample_alias, self.sample_timeout)

        self.assertIn("PDU setup failed", str(context.exception))

    @patch('PduWrapper.pdu')
    def test_multiple_pdu_wrappers(self, mock_pdu_class):
        """Test creating multiple PduWrapper instances."""
        mock_pdu_instance1 = MagicMock()
        mock_pdu_instance2 = MagicMock()
        mock_pdu_class.side_effect = [mock_pdu_instance1, mock_pdu_instance2]

        wrapper1 = PduWrapper()
        wrapper2 = PduWrapper()

        # Verify each wrapper has its own pdu instance
        self.assertEqual(wrapper1.pduobj, mock_pdu_instance1)
        self.assertEqual(wrapper2.pduobj, mock_pdu_instance2)
        self.assertNotEqual(wrapper1.pduobj, wrapper2.pduobj)

        # Test that setup_pdu calls the correct instance
        wrapper1.setup_pdu("MODEL1", "ALIAS1", 30)
        wrapper2.setup_pdu("MODEL2", "ALIAS2", 60)

        mock_pdu_instance1.setup_pdu.assert_called_once_with(
            model="MODEL1", alias="ALIAS1", timeout=30
        )
        mock_pdu_instance2.setup_pdu.assert_called_once_with(
            model="MODEL2", alias="ALIAS2", timeout=60
        )

        # Verify cross-calls didn't happen
        mock_pdu_instance1.setup_pdu.assert_called_once()
        mock_pdu_instance2.setup_pdu.assert_called_once()

    @patch('PduWrapper.pdu')
    def test_setup_pdu_multiple_calls(self, mock_pdu_class):
        """Test calling setup_pdu multiple times on same wrapper."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Call setup_pdu multiple times
        wrapper.setup_pdu("MODEL1", "ALIAS1", 30)
        wrapper.setup_pdu("MODEL2", "ALIAS2", 60)
        wrapper.setup_pdu("MODEL3", "ALIAS3", 45)

        # Verify all calls were made
        expected_calls = [
            unittest.mock.call(model="MODEL1", alias="ALIAS1", timeout=30),
            unittest.mock.call(model="MODEL2", alias="ALIAS2", timeout=60),
            unittest.mock.call(model="MODEL3", alias="ALIAS3", timeout=45),
        ]

        mock_pdu_instance.setup_pdu.assert_has_calls(expected_calls)
        self.assertEqual(mock_pdu_instance.setup_pdu.call_count, 3)

    @patch('PduWrapper.pdu')
    def test_pduobj_attribute_accessibility(self, mock_pdu_class):
        """Test that pduobj attribute is accessible and modifiable."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Verify pduobj is accessible
        self.assertEqual(wrapper.pduobj, mock_pdu_instance)

        # Verify we can access attributes/methods through pduobj
        wrapper.pduobj.some_method = MagicMock()
        wrapper.pduobj.some_method("test")
        wrapper.pduobj.some_method.assert_called_once_with("test")

        # Verify we can modify pduobj
        new_mock = MagicMock()
        wrapper.pduobj = new_mock
        self.assertEqual(wrapper.pduobj, new_mock)

    @patch('PduWrapper.pdu')
    def test_wrapper_isolation(self, mock_pdu_class):
        """Test that wrapper instances are properly isolated."""
        mock_pdu_instance1 = MagicMock()
        mock_pdu_instance2 = MagicMock()
        mock_pdu_class.side_effect = [mock_pdu_instance1, mock_pdu_instance2]

        wrapper1 = PduWrapper()
        wrapper2 = PduWrapper()

        # Modify one wrapper's pduobj
        wrapper1.pduobj.custom_attribute = "test_value"

        # Verify the other wrapper is not affected
        self.assertNotEqual(wrapper1.pduobj, wrapper2.pduobj)
        self.assertTrue(hasattr(wrapper1.pduobj, 'custom_attribute'))
        # Check that wrapper2.pduobj doesn't have the custom_attribute or it's different
        self.assertNotEqual(
            getattr(wrapper1.pduobj, 'custom_attribute', None),
            getattr(wrapper2.pduobj, 'custom_attribute', None)
        )

    @patch('PduWrapper.pdu')
    def test_pdu_import_and_instantiation(self, mock_pdu_class):
        """Test that pdu is imported and instantiated correctly."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        # Create wrapper - this should trigger pdu import and instantiation
        wrapper = PduWrapper()

        # Verify pdu class was called (instantiated)
        mock_pdu_class.assert_called_once_with()

        # Verify the instance is stored correctly
        self.assertIs(wrapper.pduobj, mock_pdu_instance)

    def test_class_structure(self):
        """Test PduWrapper class structure and methods."""
        # Verify class exists and has expected methods
        self.assertTrue(hasattr(PduWrapper, '__init__'))
        self.assertTrue(hasattr(PduWrapper, 'setup_pdu'))

        # Verify methods are callable
        self.assertTrue(callable(getattr(PduWrapper, '__init__')))
        self.assertTrue(callable(getattr(PduWrapper, 'setup_pdu')))

    @patch('PduWrapper.pdu')
    def test_setup_pdu_keyword_arguments(self, mock_pdu_class):
        """Test setup_pdu preserves keyword argument structure."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Call with positional arguments
        wrapper.setup_pdu(self.sample_model,
                          self.sample_alias, self.sample_timeout)

        # Verify the call was made with keyword arguments as expected
        mock_pdu_instance.setup_pdu.assert_called_once_with(
            model=self.sample_model,
            alias=self.sample_alias,
            timeout=self.sample_timeout
        )

    @patch('PduWrapper.pdu')
    def test_edge_case_empty_strings(self, mock_pdu_class):
        """Test setup_pdu with empty string parameters."""
        mock_pdu_instance = MagicMock()
        mock_pdu_class.return_value = mock_pdu_instance

        wrapper = PduWrapper()

        # Test with empty strings
        wrapper.setup_pdu("", "", "")

        mock_pdu_instance.setup_pdu.assert_called_once_with(
            model="",
            alias="",
            timeout=""
        )


if __name__ == '__main__':
    unittest.main()
