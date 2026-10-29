# -*- coding: utf-8 -*-
"""
Unit tests for extract module.
"""

from extract import zip_file_list, zip_open_file
import unittest
from unittest.mock import patch, MagicMock, mock_open
import sys
import os
import zipfile

# Add the parent directory to the path to import the module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


class TestExtract(unittest.TestCase):
    """Test cases for extract module functions."""

    def setUp(self):
        """Set up test fixtures."""
        self.sample_archive_path = "/path/to/test.zip"
        self.sample_filename = "test_file.txt"
        self.sample_file_content = b"This is test file content"
        self.sample_namelist = ["file1.txt", "file2.py", "dir/file3.log"]

    @patch('extract.zipfile.ZipFile')
    def test_zip_file_list_success(self, mock_zipfile):
        """Test zip_file_list returns correct file list."""
        # Mock ZipFile instance
        mock_zip = MagicMock()
        mock_zip.namelist.return_value = self.sample_namelist
        mock_zipfile.return_value = mock_zip

        result = zip_file_list(self.sample_archive_path)

        # Verify ZipFile was called with correct path
        mock_zipfile.assert_called_once_with(self.sample_archive_path)

        # Verify namelist was called
        mock_zip.namelist.assert_called_once()

        # Verify close was called
        mock_zip.close.assert_called_once()

        # Verify correct result
        self.assertEqual(result, self.sample_namelist)

    @patch('extract.zipfile.ZipFile')
    def test_zip_file_list_empty_archive(self, mock_zipfile):
        """Test zip_file_list with empty archive."""
        mock_zip = MagicMock()
        mock_zip.namelist.return_value = []
        mock_zipfile.return_value = mock_zip

        result = zip_file_list(self.sample_archive_path)

        self.assertEqual(result, [])
        mock_zip.close.assert_called_once()

    @patch('extract.zipfile.ZipFile')
    def test_zip_file_list_exception_handling(self, mock_zipfile):
        """Test zip_file_list properly closes file even when exception occurs."""
        mock_zip = MagicMock()
        mock_zip.namelist.side_effect = Exception("Test exception")
        mock_zipfile.return_value = mock_zip

        with self.assertRaises(Exception):
            zip_file_list(self.sample_archive_path)

        # Verify close was still called despite exception
        mock_zip.close.assert_called_once()

    @patch('extract.zipfile.ZipFile')
    def test_zip_open_file_success(self, mock_zipfile):
        """Test zip_open_file returns correct file content."""
        mock_zip = MagicMock()
        mock_zip.read.return_value = self.sample_file_content
        mock_zipfile.return_value = mock_zip

        result = zip_open_file(self.sample_archive_path, self.sample_filename)

        # Verify ZipFile was called with correct path
        mock_zipfile.assert_called_once_with(self.sample_archive_path)

        # Verify read was called with correct filename
        mock_zip.read.assert_called_once_with(self.sample_filename)

        # Verify close was called
        mock_zip.close.assert_called_once()

        # Verify correct result
        self.assertEqual(result, self.sample_file_content)

    @patch('extract.zipfile.ZipFile')
    def test_zip_open_file_binary_content(self, mock_zipfile):
        """Test zip_open_file with binary file content."""
        binary_content = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR'
        mock_zip = MagicMock()
        mock_zip.read.return_value = binary_content
        mock_zipfile.return_value = mock_zip

        result = zip_open_file(self.sample_archive_path, "image.png")

        self.assertEqual(result, binary_content)
        mock_zip.close.assert_called_once()

    @patch('extract.zipfile.ZipFile')
    def test_zip_open_file_exception_handling(self, mock_zipfile):
        """Test zip_open_file properly closes file even when exception occurs."""
        mock_zip = MagicMock()
        mock_zip.read.side_effect = KeyError("File not found in archive")
        mock_zipfile.return_value = mock_zip

        with self.assertRaises(KeyError):
            zip_open_file(self.sample_archive_path, "nonexistent_file.txt")

        # Verify close was still called despite exception
        mock_zip.close.assert_called_once()

    @patch('extract.zipfile.ZipFile')
    def test_zip_open_file_empty_content(self, mock_zipfile):
        """Test zip_open_file with empty file content."""
        mock_zip = MagicMock()
        mock_zip.read.return_value = b''
        mock_zipfile.return_value = mock_zip

        result = zip_open_file(self.sample_archive_path, "empty_file.txt")

        self.assertEqual(result, b'')
        mock_zip.close.assert_called_once()

    @patch('extract.zipfile.ZipFile')
    def test_zip_file_list_with_nested_directories(self, mock_zipfile):
        """Test zip_file_list with nested directory structure."""
        nested_list = [
            "root_file.txt",
            "dir1/file1.txt",
            "dir1/subdir/file2.txt",
            "dir2/file3.txt"
        ]
        mock_zip = MagicMock()
        mock_zip.namelist.return_value = nested_list
        mock_zipfile.return_value = mock_zip

        result = zip_file_list(self.sample_archive_path)

        self.assertEqual(result, nested_list)
        self.assertEqual(len(result), 4)

    @patch('extract.zipfile.ZipFile')
    def test_zip_open_file_with_path_separators(self, mock_zipfile):
        """Test zip_open_file with file in subdirectory."""
        file_in_subdir = "subdir/nested_file.txt"
        mock_zip = MagicMock()
        mock_zip.read.return_value = b"Content from nested file"
        mock_zipfile.return_value = mock_zip

        result = zip_open_file(self.sample_archive_path, file_in_subdir)

        mock_zip.read.assert_called_once_with(file_in_subdir)
        self.assertEqual(result, b"Content from nested file")


if __name__ == '__main__':
    unittest.main()
