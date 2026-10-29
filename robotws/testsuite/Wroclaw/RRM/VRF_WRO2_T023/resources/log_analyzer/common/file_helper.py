from uuid import uuid4
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.regex import get_regex_match
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.log import blog
import os
import io


def yield_lines_from_file(file_path, skip_empty=True, strip=False):
    """
    Open file and yield lines. Line is empty if it only contains spaces and linesep.
    :param file_path: Path to file (str).
    :param skip_empty: Skip empty lines (bool).
    :param strip: Strip lines (bool).
    :returns Lines from the file (generator).
    """
    try:
        with io.open(file_path, errors='ignore') as f:
            if skip_empty:
                f = (line for line in f if not line.replace(' ', '') == os.linesep)
            if strip:
                f = (line.strip() for line in f)
            for line in f:
                yield line
    except (IOError, OSError) as file_err:
        em = 'error occurred while opening file:  {}'
        blog(message=em.format(str(file_path)))
        raise file_err


def write_data_to_file(data, file_path):
    """write data to a file"""
    blog(message='writing data to: {}'.format(file_path))
    try:
        with open(file_path, 'w+') as f:
            f.write(data)
    except (IOError, OSError) as file_err:
        em = 'error occurred while opening/writing to file:  {}'
        blog(message=em.format(str(file_path)))
        raise file_err


def get_tmp_filepath(target_dir='/tmp/', tail='', hash_length=8, append_tmp_to_end=True):
    """
    Create a file with a randomly generated ID in the specified directory.
    :param target_dir: Directory, in which the random file will be created (str).
    :param tail: additional file alias appended after the random ID (str).
    :param hash_length: Length of the random ID (int).
    :param append_tmp_to_end: Append .tmp extension to the generated file (bool).
    :returns Path to the generated file, e.g. {target_path}/{hash}/{tail}.tmp (str).
    """
    if hash_length > 36:  # uuid returns hash with len of 36
        m = 'maximum length of hash is 36 passed value: {}'
        blog(message=m.format(hash_length))
        hash_length = 36

    def _get_random_hash():
        return str(uuid4())[:hash_length]

    def _get_path_with_hash():
        return os.path.join(target_dir, _get_random_hash() + tail + the_end)

    def _check_if_file_exists(file_path):
        return os.path.exists(file_path)

    the_end = ''
    if append_tmp_to_end:
        the_end = '.tmp'

    candidate = _get_path_with_hash()
    while _check_if_file_exists(candidate):
        candidate = _get_path_with_hash()

    return candidate


def get_filepaths(dir, pattern='*', engine='fnmatch'):
    """
    Get all paths to matching files contained in the specified directory.
    :param dir: Path to directory (str).
    :param pattern: Pattern to match files (str).
    :param engine: Search engine (callable, str).
    :returns List of matching files in the specified folder (List<str>).
    """
    regex_match = get_regex_match(engine)
    return [
        os.path.join(dir, name)
        for name in os.listdir(dir)
        if regex_match(name, pattern)
    ]
