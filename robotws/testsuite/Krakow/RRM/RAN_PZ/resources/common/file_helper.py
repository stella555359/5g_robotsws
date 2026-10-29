
from uuid import uuid4
from os import linesep, path, listdir

from testsuite.Krakow.RRM.RAN_PZ.resources.common.regex import get_regex_match
from testsuite.Krakow.RRM.RAN_PZ.resources.log.log import blog

import unittest
from mock import MagicMock, mock_open, patch


def yield_lines_from_file(file_path, skip_empty=True, strip=False):
    """
    open file and
    yield non empty lines for skip_empty=True [default]
    yield with empty lines for skip_empty=False
    yield stripped lines for strip=True

    line is empty if contains only spaces and linesep

    if passed skip_empty=False, strip=True
    then empty lines will result in as ''
    so best use skip_empty=True with strip=True
    """
    try:
        with open(file_path) as f:
            if skip_empty:
                f = (line for line in f if not line.replace(' ', '') == linesep)
            if strip:
                f = (line.strip() for line in f)
            for line in f:
                yield line
    except (IOError, OSError) as file_err:
        em = 'error occurred while opening file:  {}'
        blog(message=em.format(str(file_path)))
        raise file_err


# TODO: MOVE THIS TO COMMON file_helper.py
def write_data_to_file(data, file_path):
    """
    writes data to a file
    """
    blog(message='writing data to: {}'.format(file_path))
    try:
        with open(file_path, 'w+') as f:
            f.write(data)
    except (IOError, OSError) as file_err:
        em = 'error occurred while opening/writing to file:  {}'
        blog(message=em.format(str(file_path)))
        raise file_err


def get_tmp_file_file_path(
    target_path='/tmp/', tail='',
    hash_lenght=8, append_tmp_to_end=True
):
    """
    return non existing semi random file path
    like
        {target_path}|{hash}  |{tail}|{.tmp}
               /tmp/ |a33fg4bs|tail  |.tmp

    by default
        path is set to '/tmp/',
        hash length is set to 8
        tail is empty string
        '.tmp' is appended at end
    """
    if hash_lenght > 36:  # uuid returns hash with len of 36
        m = 'maximum length of hash is 36 passed value: {}'
        blog(message=m.format(hash_lenght))
        hash_lenght = 36

    def _get_random_hash():
        return str(uuid4())[:hash_lenght]

    def _get_path_with_hash():
        return '{}{}{}{}'.format(target_path, _get_random_hash(), tail, the_end)

    def _check_if_file_exists(file_path):
        return path.exists(file_path)

    if not target_path[-1] is '/':
        target_path += '/'

    the_end = ''
    if append_tmp_to_end:
        the_end = '.tmp'

    candidate = _get_path_with_hash()
    while _check_if_file_exists(candidate):
        candidate = _get_path_with_hash()

    return candidate


def get_files_filepaths(path, pattern='*', engine='fnmatch'):
    """
    gets all paths to files from 'path' that match 'pattern'
    witch is wildcard by default, returns list of paths, allows
    to change regex engine, by default fnmatch
    """
    regex_match = get_regex_match(engine)
    return [
        path + name
        for name in listdir(path)
        if regex_match(name, pattern)
    ]


class TestFileHelperFunctions(unittest.TestCase):

    @patch(
        '__builtin__.open',
        new_callable=mock_open,
        read_data=' '+linesep+'asd'+linesep+'   asd'+linesep
    )
    def test_yield_lines_from_file(self, m_open):
        no_skip = list(yield_lines_from_file('/mocked', skip_empty=False, strip=False))
        assert no_skip == [' '+linesep, 'asd'+linesep, '   asd'+linesep]

        skip = list(yield_lines_from_file('/mocked', skip_empty=True, strip=False))
        assert skip == ['asd'+linesep, '   asd'+linesep]

        no_skip_and_strip = list(yield_lines_from_file('/mocked', skip_empty=False, strip=True))
        assert no_skip_and_strip == ['', 'asd', 'asd']

        skip_and_strip = list(yield_lines_from_file('/mocked', skip_empty=True, strip=True))
        assert skip_and_strip == ['asd', 'asd']

    #
    # write_data_to_file only uses open, write, catch and raise nothing else
    # don't really feel need to test this
    #

    def test_get_tmp_file_file_path(self):
        tmp = get_tmp_file_file_path(
            target_path='/tmp', tail='.tail',
            hash_lenght=0, append_tmp_to_end=True
        )
        expected_len = len('/tmp/') + len('.tail') + len('.tmp')
        assert tmp[:5] == '/tmp/'        # target_path check + missing slash check
        assert tmp[5:-4] == '.tail'      # tail present check
        assert tmp[-4:] == '.tmp'        # end check
        assert len(tmp) == expected_len  # hash len==0 check
        assert not path.exists(tmp)      # file does not exist check

        tmp2 = get_tmp_file_file_path(
            target_path='/tmp/', tail='',
            hash_lenght=4, append_tmp_to_end=False
        )
        assert len(tmp2) == len('/tmp/') + 4  # hash length check + no end check
        assert not path.exists(tmp2)

        tmp3 = get_tmp_file_file_path(
            target_path='/tmp/', tail='',
            hash_lenght=40, append_tmp_to_end=False
        )
        assert len(tmp3) == len('/tmp/') + 36  # max hash length check
        assert not path.exists(tmp3)

    @patch(__name__+'.listdir')
    def test_get_files_filepaths(self, m_listdir):
        path = '/tmp/'
        files = ['file_1.txt', 'file_2.txt', 'data_1.csv', 'data_2.csv']
        path_files = [path + f for f in files]
        m_listdir.return_value = files

        assert get_files_filepaths(path) == path_files
        assert get_files_filepaths(path, pattern='*.txt') == path_files[:2]
        assert get_files_filepaths(path, pattern='*asd') == []
