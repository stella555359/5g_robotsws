"""
:copyright: Nokia Networks
:author: Prateek Joshi
:contact: prateek.joshi@nokia.com
:maintainer: Prateek Joshi
:contact: prateek.joshi@nokia.com
"""
try:
    from pathlib import Path
except ImportError:
    from pathlib2 import Path
from filetype import guess
import subprocess
from uuid import uuid4
import logging

logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())


class ExecutionError(Exception):
    """
    An execution failed.
    """

    def __init__(self, stdout, stderr, exit_status, **kwargs):
        super(ExecutionError, self).__init__(**kwargs)
        self.stdout = stdout
        self.stderr = stderr
        self.exit_status = exit_status

    def __str__(self):
        return "stdout=%r, stderr=%r, exit_status=%r" % (self.stdout, self.stderr, self.exit_status)

    def __repr__(self):
        return "ExecutionError(stdout=%r, stderr=%r, exit_status=%r)" % (self.stdout, self.stderr, self.exit_status)


class Executor:
    @staticmethod
    def execute(command, cwd=None):
        logger.debug("Executing %r in %r", command, cwd)
        popen = subprocess.Popen(
            command,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=cwd
        )
        stdout, stderr = popen.communicate()
        exit_status = popen.wait()
        logger.debug("stdout=%r, stderr=%r, exit_status=%r",
                     stdout, stderr, exit_status)

        if exit_status != 0 or stderr:
            raise ExecutionError(stdout, stderr, exit_status)


def extract(
        path,
        output_dir=".",
        **selections):
    """
     Recursively extract a selection of path patterns from an archive file into an output directory.

    The extraction ends, when no more archive files can be unpacked according to the selection criteria.


    :param str path: file to unpack.
    :param str output_dir: (optional) directory to extract files. Default ".".
            if existing, extracted files are merged with rsync.
    :param dict selections: (optional) specify what to extract.
                        Each key is a path of an archive, that shall be unpacked. The keys are used in glob() to
                        retrieve files for further unpack.
                        Each value is a pattern of files, that shall be extracted from the archive. The values are
                        used in 7z -i wildcard option.
                        default is {[.=*],[**/*=*]}'. Everything recursive extracted from file collection
    :return:

    .. code-block:: robotframework

        *** Settings ***
        Library    taf.file.pack

        *** Test Cases ***
        Extract pcap from snapshot

            Extract
            ...  path=/tmp/snapshot.zip
            ...  output_dir=snap
            ...  .=*
            ...  *=*coldreset*
            ...  **/*=*startup*
            ...  **=*pcap

        Extract 5gm from dcap.zip

            Extract
            ...  path=/tmp/dcap.zip
            ...  .=*/*/5g/controlPlane/*.5gm
    """

    local_executor = _create_local_executor()
    if not selections:
        selections = {".": "*", "**/*": "*"}
    logger.info("Unpacking name %s output_dir %s selections %s",
                path, output_dir, selections)
    path = Path(path)
    directory = str(path.parent)
    filename = str(path.name)
    local_executor.execute(
        "ln '{filename}' '{filename}.bak'".format(filename=filename),
        cwd=directory)
    _extract_selections(path, selections, local_executor)
    local_executor.execute(
        "if [ -d '{filename}' ]; then mkdir -p '{output_dir}' ;"
        "rsync -av '{filename}'/* '{output_dir}' ; "
        "rm -rf '{filename}' ; "
        "mv '{filename}.bak' '{filename}' ;"
        "else unlink '{filename}.bak'; fi".format(
            filename=filename,
            output_dir=output_dir),
        cwd=directory)


def _extract_selections(path, selections, local_executor):
    changed = True
    directory = path.parent
    filename = path.name
    guessed_files = set()
    while changed:
        changed = False
        for archive_rel_paths, pattern in selections.items():
            glob_pattern = _construct_glob_pattern(filename, archive_rel_paths)
            for archive_path in directory.glob(glob_pattern):
                if archive_path not in guessed_files:
                    changed = _process_archive(
                        archive_path, pattern, guessed_files, local_executor)


def _extract_archive(archive_path, pattern, local_executor):
    archive_path = Path(archive_path)
    archive_dir = str(archive_path.parent)
    archive_file = str(archive_path.name)
    extract_dir = str(uuid4())
    try:
        local_executor.execute(
            "7z x -o{extract_dir} -i!'{pattern}' -aos '{archive_file}'".format(
                extract_dir=extract_dir,
                pattern=pattern,
                archive_file=archive_file),
            cwd=archive_dir)
    except ExecutionError as e:
        logger.debug(
            "Extraction failed for the file %r with error: %r", archive_file, e.stderr)

    if (archive_path.parent / extract_dir).is_dir():
        local_executor.execute(
            "rm '{archive_file}' ; "
            "mv '{extract_dir}' '{archive_file}'".format(
                archive_file=archive_file,
                extract_dir=extract_dir),
            cwd=archive_dir)
        return True
    return False


def _construct_glob_pattern(filename, archive_rel_paths):
    return '{filename}/{archive_rel_paths}'.format(filename=filename, archive_rel_paths=archive_rel_paths)


def _process_archive(archive_path, pattern, guessed_files, local_executor):
    extension = None
    if archive_path.is_file():
        file_type = guess(str(archive_path))
        guessed_files.add(archive_path)
        if file_type is not None:
            extension = file_type.extension

    if extension in ("7z", "gz", "tar", "xz", "zip"):
        return _extract_archive(archive_path, pattern, local_executor)

    return False


def _create_local_executor():
    return Executor()
