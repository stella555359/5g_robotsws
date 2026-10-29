class ProcessNotFound(Exception):
    """
    Exception to be raised when no process is found.
    Purpose of this exception is to NOT raise any builtin exception.
    """


class ProcessNotRunning(Exception):
    """
    Exception to be raised when trying to terminate/kill process
    that was already finished/terminated/killed.
    """


class ProcessAlreadyRunning(Exception):
    """
    Exception to be raised when trying to spawn process with alias
    and another process with this alias is already running.
    """


class ProcessAliasUnavailable(Exception):
    """
    Exception to be raised when trying to spawn process with alias
    and another process with this alias was spawned but not necessarily running.
    """


class ProcessStillRunning(Exception):
    """
    Exception to be raised when accessing process output and process
    is still running.
    """
