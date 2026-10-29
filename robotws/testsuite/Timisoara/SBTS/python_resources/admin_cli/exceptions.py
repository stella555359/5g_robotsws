class HranAdminCLIException(Exception):
    """Base for all hran_admin_cli exceptions"""


class AdminCLINotSetUpException(Exception):
    """Raised when hran_admin_cli was not set up correctly"""


class AdminCLIDownloaderException(Exception):
    """Raised when AdminCLI was not downloaded correctly"""


class FileLocked(Exception):
    """Exception raised whenever lock file is not accessible to read,
    therefore, there is not possible to check whether another
    instance of downloader is currently working or not
    """


class NetworkException(Exception):
    """Exception raised whenever any non-VCS
    connection-related problem occurred
    """


class InvalidBuildException(Exception):
    """Exception raised whenever there is any issue with baseline in any case.

    Doesn't matter if there is no package with such baseline in repository
    or its not matching pattern for given technology.
    """
