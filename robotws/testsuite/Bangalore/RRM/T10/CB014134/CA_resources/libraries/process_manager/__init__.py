from . import exceptions
from . import process


class ProcessManager(object):
    """
    Process manager that handles running processes in background.

    This class utilizes Python's subprocess module
    with Popen [https://docs.python.org/3/library/subprocess.html]
    """

    _processes = {}

    def __init__(self):
        """
        ProcessManager written as borg design pattern
        which means every instance of this class will have same state.

        _processes dict is a container for every process spawned by this class
        key is for unique process alias and value is dict with
        following keys:
            - instance: subprocess.Popen instance with spawned process
            - result: ProcessResult instance
        """
        self.__dict__ = self._processes

    def start_process(self, alias, *args, **kwargs):
        """
        Start and store process with given alias to dictionary,
        if process was spawned earlier then raise ProcessAlreadyRunning
        or ProcessAliasUnavailable
        :param alias: unique string value
        :param args: Popen args
        :param kwargs: Popen kwargs
        """
        if alias in self._processes:
            proc = self._processes[alias]
            if proc.running:
                raise exceptions.ProcessAlreadyRunning(
                    "Process already spawned and running." " PID: {}".format(proc.pid)
                )
            else:
                raise exceptions.ProcessAliasUnavailable(
                    "Process already spawned and alias {} is unavailable."
                    " Release alias first.".format(alias)
                )
        self._processes[alias] = process.Process(*args, **kwargs)

    def terminate(self, alias, release=False, timeout=0.1):
        """
        Attempt to terminate process gracefully.

        :param alias: unique string
        :param release: flag to determine if process should be
         removed from processes dict
        :return: True if process was terminated else False
        """
        proc = self._get_process(alias)
        terminated = proc.terminate(timeout=timeout)
        if terminated and release:
            self.release_alias(alias)
        return terminated

    def kill(self, alias, release=False, timeout=0.1):
        """
        Attempt to kill process.

        :param alias: unique string
        :param release: flag to determine if process should be
         removed from processes dict
        :return:
        """
        proc = self._get_process(alias)
        killed = proc.kill(timeout=timeout)
        if killed and release:
            self.release_alias(alias)
        return killed

    def terminate_all(self, release=False, timeout=0.1):
        """
        Attempt to terminate all processes.

        :param release: flag to determine if process should be
         removed from processes dict
        :return: list of tuples (alias, terminated<bool>)
        """
        terminated = []
        aliases = list(self._processes.keys())
        for alias in aliases:
            try:
                terminated.append(
                    (alias, self.terminate(alias, release=release, timeout=timeout))
                )
            except exceptions.ProcessNotRunning:
                if release:
                    self.release_alias(alias)
        return terminated

    def kill_all(self, release=False, timeout=0.1):
        """
        Attempt to kill all processes.

        :param release: flag to determine if process should be
         removed from processes dict
        :return: list of tuples (alias, terminated<bool>)
        """
        killed = []
        aliases = list(self._processes.keys())
        for alias in aliases:
            try:
                killed.append(
                    (alias, self.kill(alias, release=release, timeout=timeout))
                )
            except exceptions.ProcessNotRunning:
                if release:
                    self.release_alias(alias)
        return killed

    def release_alias(self, alias):
        """
        Releases given unique alias from _processes and make it available
        for new Process, if alias is not in dictionary raise ProcessNotFound.

        :return: process instance
        """
        proc = self._get_process(alias)
        if proc.running:
            raise RuntimeError(
                "Unable to release alias {alias},"
                " process is still running, terminate process first."
                " PID: {pid}".format(pid=proc.pid, alias=alias)
            )
        del self._processes[alias]
        return proc

    def is_process_running(self, alias):
        """
        Check if process is still running

        :param alias: unique string
        :return: True or False
        """
        return self._get_process(alias).running

    def get_pid(self, alias):
        """
        Get PID of process by given alias.

        :param alias:
        :return: PID
        """
        return self._get_process(alias).pid

    def get_return_code(self, alias):
        """
        Get return code of process.

        :param alias: unique string
        :return:
        """
        proc = self._get_process(alias)
        return proc.return_code

    def get_output(self, alias):
        """
        Get output of process

        :param alias: unique string
        :return: tuple of process (stdout, stderr)
        """
        proc = self._get_process(alias)
        return proc.output

    def send_signal(self, alias, signal):
        """
        Send standard signal like SIGTERM/SIGKILL/etc..

        :param alias: unique string
        :param signal: signum
        :return:
        """
        proc = self._get_process(alias)
        proc.send_signal(signal)

    def _get_process(self, alias):
        proc = self._processes.get(alias)
        if proc is None:
            raise exceptions.ProcessNotFound()
        return proc
