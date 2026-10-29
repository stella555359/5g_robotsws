# -*- coding: utf-8 -*-
"""
Unit tests for pandas_gate module.
"""

import pandas_gate
import unittest
from unittest.mock import patch, MagicMock, mock_open, call
import sys
import os
import tempfile

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


class TestPandasGate(unittest.TestCase):
    """Test cases for pandas_gate module functions."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = "/tmp"
        self.sample_requirements_content = """pandas
    numpy
    pytz
    python-dateutil
    openpyxl
    """

    def test_module_global_pd_variable(self):
        """Test that the global pd variable exists and is initially None."""
        self.assertIsNone(pandas_gate.pd)

    @patch('pandas_gate.gettempdir')
    @patch('pandas_gate.os.remove')
    @patch('builtins.open')
    def test_temp_pandas_requirements_file_context_manager(self, mock_open_func, mock_remove, mock_gettempdir):
        """Test temp_pandas_requirements_file context manager."""
        mock_gettempdir.return_value = self.temp_dir
        mock_file = MagicMock()
        mock_open_func.return_value.__enter__.return_value = mock_file

        expected_file_path = os.path.join(
            self.temp_dir, 'pandas_requirements.log')

        with pandas_gate.temp_pandas_requirements_file() as requirements_file:
            self.assertEqual(requirements_file, expected_file_path)

        # Verify file operations
        mock_open_func.assert_called_once_with(expected_file_path, 'w')
        mock_file.write.assert_called_once()
        written_content = mock_file.write.call_args[0][0]
        self.assertIn('pandas', written_content)
        self.assertIn('numpy', written_content)
        self.assertIn('pytz', written_content)
        self.assertIn('python-dateutil', written_content)
        self.assertIn('openpyxl', written_content)

        # Verify cleanup
        mock_remove.assert_called_once_with(expected_file_path)

    @patch('pandas_gate.gettempdir')
    @patch('pandas_gate.os.remove')
    @patch('builtins.open')
    def test_temp_pandas_requirements_file_exception_cleanup(self, mock_open_func, mock_remove, mock_gettempdir):
        """Test temp_pandas_requirements_file cleans up even on exception."""
        mock_gettempdir.return_value = self.temp_dir
        mock_file = MagicMock()
        mock_open_func.return_value.__enter__.return_value = mock_file

        expected_file_path = os.path.join(
            self.temp_dir, 'pandas_requirements.log')

        try:
            with pandas_gate.temp_pandas_requirements_file() as requirements_file:
                raise ValueError("Test exception")
        except ValueError:
            pass

        # Verify cleanup still happened
        mock_remove.assert_called_once_with(expected_file_path)

    @patch('pandas_gate.subprocess.call')
    def test_install_requirements_success(self, mock_subprocess):
        """Test install_requirements with successful installation."""
        test_requirements_file = "/tmp/test_requirements.txt"
        mock_subprocess.return_value = 0

        pandas_gate.install_requirements(test_requirements_file)

        mock_subprocess.assert_called_once_with([
            'pip', 'install', '--no-deps', '-r', test_requirements_file
        ])

    @patch('pandas_gate.subprocess.call')
    def test_install_requirements_exception(self, mock_subprocess):
        """Test install_requirements with subprocess exception."""
        test_requirements_file = "/tmp/test_requirements.txt"
        mock_subprocess.side_effect = Exception("pip install failed")

        with self.assertRaises(AssertionError) as context:
            pandas_gate.install_requirements(test_requirements_file)

        self.assertIn("Error installing requirements", str(context.exception))
        self.assertIn("pip install failed", str(context.exception))

    @patch('pandas_gate.pkgutil.find_loader')
    def test_is_pandas_installed_true(self, mock_find_loader):
        """Test is_pandas_installed returns True when pandas is available."""
        mock_find_loader.return_value = MagicMock()  # Non-None value

        result = pandas_gate.is_pandas_installed()

        self.assertTrue(result)
        mock_find_loader.assert_called_once_with('pandas')

    @patch('pandas_gate.pkgutil.find_loader')
    def test_is_pandas_installed_false(self, mock_find_loader):
        """Test is_pandas_installed returns False when pandas is not available."""
        mock_find_loader.return_value = None

        result = pandas_gate.is_pandas_installed()

        self.assertFalse(result)
        mock_find_loader.assert_called_once_with('pandas')

    @patch('pandas_gate.importlib.import_module')
    @patch('pandas_gate.is_pandas_installed')
    def test_install_and_import_pandas_already_installed(self, mock_is_installed, mock_import_module):
        """Test install_and_import_pandas when pandas is already installed."""
        mock_is_installed.return_value = True
        mock_pandas_module = MagicMock()
        mock_import_module.return_value = mock_pandas_module

        result = pandas_gate.install_and_import_pandas()

        self.assertEqual(result, mock_pandas_module)
        mock_is_installed.assert_called_once()
        mock_import_module.assert_called_once_with('pandas')

    @patch('pandas_gate.importlib.import_module')
    @patch('pandas_gate.install_requirements')
    @patch('pandas_gate.temp_pandas_requirements_file')
    @patch('pandas_gate.is_pandas_installed')
    def test_install_and_import_pandas_not_installed(self, mock_is_installed, mock_temp_file,
                                                     mock_install_req, mock_import_module):
        """Test install_and_import_pandas when pandas needs to be installed."""
        mock_is_installed.return_value = False
        mock_temp_file.return_value.__enter__.return_value = "/tmp/requirements.txt"
        mock_temp_file.return_value.__exit__.return_value = None
        mock_pandas_module = MagicMock()
        mock_import_module.return_value = mock_pandas_module

        result = pandas_gate.install_and_import_pandas()

        self.assertEqual(result, mock_pandas_module)
        mock_is_installed.assert_called_once()
        mock_temp_file.assert_called_once()
        mock_install_req.assert_called_once_with("/tmp/requirements.txt")
        mock_import_module.assert_called_once_with('pandas')

    @patch('pandas_gate.importlib.import_module')
    @patch('pandas_gate.install_requirements')
    @patch('pandas_gate.temp_pandas_requirements_file')
    @patch('pandas_gate.is_pandas_installed')
    def test_install_and_import_pandas_installation_failure(self, mock_is_installed, mock_temp_file,
                                                            mock_install_req, mock_import_module):
        """Test install_and_import_pandas when installation fails."""
        mock_is_installed.return_value = False
        mock_temp_file.return_value.__enter__.return_value = "/tmp/requirements.txt"
        mock_temp_file.return_value.__exit__.return_value = None
        mock_install_req.side_effect = AssertionError("Installation failed")

        with self.assertRaises(AssertionError) as context:
            pandas_gate.install_and_import_pandas()

        self.assertIn("Installation failed", str(context.exception))
        mock_install_req.assert_called_once_with("/tmp/requirements.txt")
        mock_import_module.assert_not_called()

    @patch('pandas_gate.importlib.import_module')
    @patch('pandas_gate.install_requirements')
    @patch('pandas_gate.temp_pandas_requirements_file')
    @patch('pandas_gate.is_pandas_installed')
    def test_install_and_import_pandas_import_failure(self, mock_is_installed, mock_temp_file,
                                                      mock_install_req, mock_import_module):
        """Test install_and_import_pandas when import fails after installation."""
        mock_is_installed.return_value = False
        mock_temp_file.return_value.__enter__.return_value = "/tmp/requirements.txt"
        mock_temp_file.return_value.__exit__.return_value = None
        mock_import_module.side_effect = ImportError("pandas import failed")

        with self.assertRaises(ImportError) as context:
            pandas_gate.install_and_import_pandas()

        self.assertIn("pandas import failed", str(context.exception))
        mock_install_req.assert_called_once_with("/tmp/requirements.txt")
        mock_import_module.assert_called_once_with('pandas')

    def test_requirements_content_structure(self):
        """Test that the requirements content contains expected packages."""
        # This test verifies the hardcoded requirements in the module
        expected_packages = ['pandas', 'numpy',
                             'pytz', 'python-dateutil', 'openpyxl']

        # Since the requirements are defined in the function, we test via the context manager
        with patch('pandas_gate.gettempdir', return_value="/tmp"), \
                patch('pandas_gate.os.remove'), \
                patch('builtins.open') as mock_open_func:

            mock_file = MagicMock()
            mock_open_func.return_value.__enter__.return_value = mock_file

            with pandas_gate.temp_pandas_requirements_file():
                pass

            # Get the written content
            written_content = mock_file.write.call_args[0][0]

            # Verify all expected packages are in the requirements
            for package in expected_packages:
                self.assertIn(package, written_content)

    @patch('pandas_gate.subprocess.call')
    def test_install_requirements_command_structure(self, mock_subprocess):
        """Test that install_requirements calls pip with correct arguments."""
        test_file = "/path/to/requirements.txt"

        pandas_gate.install_requirements(test_file)

        # Verify the exact command structure
        expected_command = ['pip', 'install', '--no-deps', '-r', test_file]
        mock_subprocess.assert_called_once_with(expected_command)

    def test_module_docstring_and_purpose(self):
        """Test that the module has proper documentation."""
        self.assertIsNotNone(pandas_gate.__doc__)
        if pandas_gate.__doc__:
            self.assertIn("gate to install pandas", pandas_gate.__doc__)
            self.assertIn("global pd", pandas_gate.__doc__)

    @patch('pandas_gate.install_and_import_pandas')
    def test_module_usage_pattern(self, mock_install_import):
        """Test the intended usage pattern described in module docstring."""
        mock_pandas_module = MagicMock()
        mock_install_import.return_value = mock_pandas_module

        # Simulate the usage pattern from the docstring
        def import_pandas():
            global pd
            pandas_gate.pd = pandas_gate.install_and_import_pandas()

        # Initially pd should be None
        self.assertIsNone(pandas_gate.pd)

        # After calling the function, pd should be set
        import_pandas()
        self.assertEqual(pandas_gate.pd, mock_pandas_module)

    @patch('pandas_gate.gettempdir')
    def test_temp_file_path_construction(self, mock_gettempdir):
        """Test that temporary file path is constructed correctly."""
        mock_gettempdir.return_value = "/custom/temp/dir"

        with patch('builtins.open') as mock_open_func, \
                patch('pandas_gate.os.remove'):

            mock_file = MagicMock()
            mock_open_func.return_value.__enter__.return_value = mock_file

            with pandas_gate.temp_pandas_requirements_file() as file_path:
                expected_path = os.path.join(
                    "/custom/temp/dir", "pandas_requirements.log")
                self.assertEqual(file_path, expected_path)

            mock_open_func.assert_called_once_with(expected_path, 'w')

    @patch('pandas_gate.pkgutil.find_loader')
    def test_is_pandas_installed_edge_cases(self, mock_find_loader):
        """Test is_pandas_installed with various return values."""
        # Test with empty string (falsy but not None)
        mock_find_loader.return_value = ""
        self.assertFalse(pandas_gate.is_pandas_installed())

        # Test with actual loader object
        mock_loader = MagicMock()
        mock_find_loader.return_value = mock_loader
        self.assertTrue(pandas_gate.is_pandas_installed())

        # Test with any truthy value
        mock_find_loader.return_value = "some_loader"
        self.assertTrue(pandas_gate.is_pandas_installed())


class TestPandasGateIntegration(unittest.TestCase):
    """Integration tests for pandas_gate module workflow."""

    @patch('pandas_gate.os.remove')
    @patch('pandas_gate.gettempdir')
    @patch('pandas_gate.subprocess.call')
    @patch('pandas_gate.pkgutil.find_loader')
    @patch('pandas_gate.importlib.import_module')
    def test_full_installation_workflow(self, mock_import, mock_find_loader, mock_subprocess,
                                        mock_gettempdir, mock_remove):
        """Test complete workflow from checking installation to importing pandas."""
        # Setup: pandas not installed initially
        mock_find_loader.return_value = None
        mock_gettempdir.return_value = "/tmp"
        mock_subprocess.return_value = 0
        mock_pandas_module = MagicMock()
        mock_import.return_value = mock_pandas_module

        expected_file_path = os.path.join("/tmp", "pandas_requirements.log")

        with patch('builtins.open', mock_open()) as mock_file:
            result = pandas_gate.install_and_import_pandas()

        # Verify the complete workflow
        mock_find_loader.assert_called_once_with('pandas')
        mock_file.assert_called_once_with(expected_file_path, 'w')
        mock_subprocess.assert_called_once()
        mock_import.assert_called_once_with('pandas')
        mock_remove.assert_called_once_with(expected_file_path)

        self.assertEqual(result, mock_pandas_module)

    @patch('pandas_gate.pkgutil.find_loader')
    @patch('pandas_gate.importlib.import_module')
    def test_skip_installation_when_already_installed(self, mock_import, mock_find_loader):
        """Test that installation is skipped when pandas is already available."""
        # Setup: pandas already installed
        mock_find_loader.return_value = MagicMock()
        mock_pandas_module = MagicMock()
        mock_import.return_value = mock_pandas_module

        with patch('pandas_gate.temp_pandas_requirements_file') as mock_temp_file, \
                patch('pandas_gate.install_requirements') as mock_install:

            result = pandas_gate.install_and_import_pandas()

        # Verify installation was skipped
        mock_temp_file.assert_not_called()
        mock_install.assert_not_called()
        mock_import.assert_called_once_with('pandas')

        self.assertEqual(result, mock_pandas_module)


if __name__ == '__main__':
    unittest.main()
