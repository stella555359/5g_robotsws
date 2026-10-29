"""Robot Framework test library for parsing BTS Snapshot files.

Library supports following snapshot types:

- BTS Site Manager snapshots

- WebEM (a.k.a. ADMIN) snapshots

Usage
=====

A typical usage of ``snapshot`` library is to collect snapshot using Element
Manager (BTSSM or WebEM), then parse it content using ``Open Snapshot``.
Returned object can be used as an argument for the rest of the keywords in
this library, as in the example:

.. sourcecode:: robotframework

    *** Settings ***
    Library  ute_admin
    Library  snapshot   # or /path/to/snapshot.py if not in $PYTHONPATH

    Test Setup     Setup Admin
    Test Teardown  Teardown Admin

    *** Variables ***
    ${PATH}     ${CURDIR}/snapshot.zip
    ${PATTERN}  *fault_log.xz
    ${FILE}     BTS1_1011_im_snapshot.ims2.xz

    *** Test Cases ***
    Test Example
        Collect Snapshot            ${PATH}
        ${snapshot}=                Open Snapshot  ${PATH}
        List Files In Snapshot      ${snapshot}    ${PATTERN}
        Extract File From Snapshot  ${snapshot}    ${FILE}     path=${TEMPDIR}

See specific keywords for more usage examples.

Pattern matching
----------------

Some keywords allow their arguments to be specified as
`glob patterns <http://en.wikipedia.org/wiki/Glob_(programming)>`_ where:

============  =======================================================
``*``         matches any string, even an empty string
``?``         matches any single character
``[chars]``   matches one character in the bracket
``[!chars]``  matches one character not in the bracket
``[a-z]``     matches one character from the range in the bracket
``[!a-z]``    matches one character not from the range in the bracket
============  =======================================================

Matching is always case-sensitive.
"""
import os
import logging
import fnmatch
from io import BytesIO
from zipfile import ZipFile, ZIP_DEFLATED, BadZipfile, is_zipfile

__all__ = ['extract_file_from_snapshot', 'extract_files_from_snapshot',
           'list_files_in_snapshot', 'open_snapshot']

ROBOT_LIBRARY_DOC_FORMAT = 'reST'

SUPPORTED_SNAPSHOT_TYPES = ('ADMIN', 'BTSSM')

logger = logging.getLogger(__name__)


def _absnorm(path):
    """Returns normalized, absolute path"""
    path = os.path.normpath(os.path.expanduser(path.replace('/', os.sep)))
    return os.path.abspath(path)


def _snapshot_type(filename):
    """Checks what tool was used to collect snapshot file"""
    result = 'UNKNOWN'
    logger.debug('checking content of %r' % filename)
    with ZipFile(filename, mode='r') as zf:
        names = zf.namelist()

    # These files are tool dependent, and their presence is mutually exclusive
    unique_files = {
        'snapshot_file_list.txt': 'ADMIN',
        'snapshotDesc.xml': 'BTSSM'
    }
    for _file, _tool in unique_files.items():
        if _file in names:
            logger.debug('found file %r unique to %r' % (_file, _tool))
            result = _tool
            break
    else:
        logger.debug('snapshot %r has %r type' % (filename, result))
    return result


def is_snapshot(filename):
    """Quickly see if a file is a valid Snapshot, by looking for signature file.

    Since snapshot is just a regular zip file, in order to distinguish a valid
    from an invalid one, file content is checked if it *feels like* a snapshot.

    The filename argument may be a path to file or file-like object.
    """
    result = False
    if is_zipfile(filename):
        result = _snapshot_type(filename) in SUPPORTED_SNAPSHOT_TYPES
    return result


class SnapshotFile(ZipFile):
    """Class with methods to open, read, write, close, list snapshot files.

    s = SnapshotFile(file, mode="r")

    file: Either the path to the file, or a file-like object.

    Although writing to archive is supported, it will only modify in-memory
    representation of the snapshot, not the actual file.
    """

    def __init__(self, file, mode="r"):
        """Open the Snapshot file with mode read "r", write "w" or append "a".
        """
        self.logger = logging.getLogger("{}.{}".format(self.__class__.__module__,
                                                       self.__class__.__name__))
        self.logger.debug('creating new instance from file=%r' % file)

        self._orig_file = file
        self._buffer = BytesIO()  # in-memory storage for techlogs

        self.type = _snapshot_type(file)
        self.logger.debug('%s type detected' % self.type)

        def _missing_parser():
            raise BadZipfile("Snapshot type '%s' is not supported." % self.type)

        techlogs_parser = {
            'ADMIN': self._merge_parts,
            'BTSSM': self._copy_btslogfiles
        }
        techlogs_parser.get(self.type, _missing_parser)()
        ZipFile.__init__(self, self._buffer, mode)

    def _copy_btslogfiles(self):
        """Create ZipFile form snapshot, containing only BTSLogFiles."""
        items = []
        with ZipFile(self._orig_file) as zip_file:
            items = [(zinfo, zip_file.read(zinfo))
                     for zinfo in zip_file.filelist
                     if zinfo.filename.startswith('LTEBTS/BTSLogFiles/')]
        # check if we get any techlogs:
        if not items:
            raise BadZipfile("Invalid or corrupted file: '%s'. Detected %s"
                             " snapshot, but files in 'BTSLogFiles' folder"
                             " are missing." % (self._orig_file, self.type))

        with ZipFile(self._buffer, 'a', ZIP_DEFLATED, False) as zip_buffer:
            for zinfo, rawbytes in items:
                zinfo.filename = os.path.basename(zinfo.filename)
                zip_buffer.writestr(zinfo, rawbytes)

    def _merge_parts(self):
        """Merge partial zip files from snapshot into single ZipFile."""
        parts = []
        with ZipFile(self._orig_file) as zfile:
            parts = [ZipFile(BytesIO(raw_bytes))
                     for raw_bytes in [zfile.read(zinfo)
                     for zinfo in zfile.filelist if '_part' in zinfo.filename]]
        # check if we get any techlogs:
        if not parts:
            raise BadZipfile("Invalid or corrupted file: '%s'. Detected %s"
                             " snapshot, but '_part*.zip' files"
                             " are missing." % (self._orig_file, self.type))

        with ZipFile(self._buffer, 'a', ZIP_DEFLATED, False) as zip_buffer:
            for zinfo, raw_bytes in [(zinfo, part.read(zinfo))
                                     for part in parts
                                     for zinfo in part.filelist]:
                zip_buffer.writestr(zinfo, raw_bytes)


def open_snapshot(path):
    """Returns snapshot object, loaded from given ``path``.

    This keyword reads specified file and returns ZipFile object, that
    can be passed later as an argument for other keywords in this library.
    """
    path = _absnorm(path)
    logger.info('Opening file=%r' % path)
    return SnapshotFile(path)


def list_files_in_snapshot(snapshot, pattern=None):
    """Returns file names in snapshot, optionally filtered with ``pattern``.

    ``snapshot`` can be either a path to snapshot file or an snapshot object
    returned by ``Open Snapshot``.

    If ``pattern`` is given, only file names matching it are returned.
    The pattern matching syntax is explained in ``introduction``.

    Examples:

    =====================  ======================  ===========  ==========
    ${snapshot} =          Open Snapshot           ${FILE}
    ${files1} =            List Files In Snapshot  ${snapshot}
    ${files2} =            List Files In Snapshot  ${file}
    Lists Should Be Equal  ${files1}               ${files2}
    ${list_filtered} =     List Files In Snapshot  ${snapshot}  BTS?_201D*
    =====================  ======================  ===========  ==========

    Note that empty list is returned if given pattern does not match anything.
    """
    if not isinstance(snapshot, SnapshotFile):
        logger.debug('passed %r as an argument' % type(snapshot))
        snapshot = open_snapshot(snapshot)

    items = snapshot.namelist()
    if pattern:
        items = [i for i in items if fnmatch.fnmatchcase(i, pattern)]
    return items


def extract_file_from_snapshot(snapshot, filename, path=None):
    """Extracts a file from the snapshot to the current working directory.

    Different target directory can be specified using ``path`` argument.
    That directory is created and file from snapshot is extracted into it.
    Possible missing intermediate directories are also created.
    If ``filename`` exists within target ``path``, it is overwritten.

    ``filename`` has to be exact name, and match one returned by
    ``List Files In Snapshot``.

    Example:

    =========  ==========================  ===========  ========================
    ${file} =  Extract File From Snapshot  ${snapshot}  BTS1_123D_MurkkuLogs.tgz
    =========  ==========================  ===========  ========================

    To extract multiple files at once, use ``Extract Files From Snapshot``.

    Returns path to extracted file.
    """
    if not isinstance(snapshot, SnapshotFile):
        snapshot = open_snapshot(snapshot)

    path = _absnorm(path or '.')
    logger.info('Extracting filename=%r from snapshot=%r into directory=%r' %
                (filename, snapshot, path))
    return snapshot.extract(filename, path)


def extract_files_from_snapshot(snapshot, *files_and_destination):
    """Extract specified files to the target directory.

    Files to extract can be given as exact names and as glob patterns
    (see ``introduction``). At least one source must be given, but it is
    not an error if it is a pattern that does not match anything.

    Last argument must be the destination directory. If the destination
    does not exist, it will be created.

    Examples:

    ===========================  ======================  ========  =======  =======
    ${snapshot} =                Open Snapshot           ${FILE}
    Extract Files From Snapshot  ${snapshot}             log1      log2     ${DIR1}
    Extract Files From Snapshot  ${snapshot}             log?      ${DIR2}
    ${logs} =                    List Files In Snapshot  ${FILE}   log?
    Extract Files From Snapshot  ${FILE}                 @{files}  ${DIR3}
    ===========================  ======================  ========  =======  =======

    Assuming ``${FILE}``  has *log1* and *log2* inside, all above are equivalent.

    Returns list with paths to extracted files.
    """
    if len(files_and_destination) < 2:
        raise TypeError('At least one file and a destination expected.')

    if not isinstance(snapshot, SnapshotFile):
        snapshot = open_snapshot(snapshot)

    namelist = snapshot.namelist()
    members = []
    for pattern in files_and_destination[:-1]:
        members.extend([name for name in namelist
                        if fnmatch.fnmatchcase(name, pattern)])
    logger.debug('Matched files: %r' % members)
    path = _absnorm(files_and_destination[-1])
    logger.info('Extracting files from snapshot=%r into directory=%r' %
                (snapshot, path))
    snapshot.extractall(path, members)
    extracted = [os.path.join(path, member) for member in members]
    return extracted
