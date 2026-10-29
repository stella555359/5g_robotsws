import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper as file_helper

import unittest
from mock import mock_open, patch

os = file_helper.os


class TestFileHelperFunctions(unittest.TestCase):
    @patch('__builtin__.open', new=mock_open(read_data=' '+os.linesep+'asd'+os.linesep+'   asd'+os.linesep))
    def test_yield_lines_from_file(self):
        no_skip = list(file_helper.yield_lines_from_file('/mocked', skip_empty=False, strip=False))
        assert no_skip == [' '+os.linesep, 'asd'+os.linesep, '   asd'+os.linesep]

        skip = list(file_helper.yield_lines_from_file('/mocked', skip_empty=True, strip=False))
        assert skip == ['asd'+os.linesep, '   asd'+os.linesep]

        no_skip_and_strip = list(file_helper.yield_lines_from_file('/mocked', skip_empty=False, strip=True))
        assert no_skip_and_strip == ['', 'asd', 'asd']

        skip_and_strip = list(file_helper.yield_lines_from_file('/mocked', skip_empty=True, strip=True))
        assert skip_and_strip == ['asd', 'asd']

    def test_get_tmp_filepath(self):
        tmp = file_helper.get_tmp_filepath(
            target_dir='/tmp', tail='.tail',
            hash_length=0, append_tmp_to_end=True
        )
        expected_len = len('/tmp/') + len('.tail') + len('.tmp')
        assert tmp[:5] == '/tmp/'        # target_path check + missing slash check
        assert tmp[5:-4] == '.tail'      # tail present check
        assert tmp[-4:] == '.tmp'        # end check
        assert len(tmp) == expected_len  # hash len==0 check
        assert not os.path.exists(tmp)      # file does not exist check

        tmp2 = file_helper.get_tmp_filepath(
            target_dir='/tmp/', tail='',
            hash_length=4, append_tmp_to_end=False
        )
        assert len(tmp2) == len('/tmp/') + 4  # hash length check + no end check
        assert not os.path.exists(tmp2)

        tmp3 = file_helper.get_tmp_filepath(
            target_dir='/tmp/', tail='',
            hash_length=40, append_tmp_to_end=False
        )
        assert len(tmp3) == len('/tmp/') + 36  # max hash length check
        assert not os.path.exists(tmp3)

    @patch('os.listdir')
    def test_get_filepaths(self, m_listdir):
        path = '/tmp/'
        files = ['file_1.txt', 'file_2.txt', 'data_1.csv', 'data_2.csv']
        path_files = [path + f for f in files]
        m_listdir.return_value = files

        assert file_helper.get_filepaths(path) == path_files
        assert file_helper.get_filepaths(path, pattern='*.txt') == path_files[:2]
        assert file_helper.get_filepaths('/tmp', pattern='*.txt') == path_files[:2]
        assert file_helper.get_filepaths(path, pattern='*asd') == []
