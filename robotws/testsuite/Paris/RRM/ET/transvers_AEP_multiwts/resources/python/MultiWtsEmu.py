from taf.wts.runner.wts_emulator import WtsEmulator


class MultiWtsEmu(object):
    """Library to manage multiple WtsEmulator  instances for multi-WTS test scenarios."""

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        """Initializes the MultiWtsEmu library with an empty instance dictionary."""
        self.instances = {}
        self.current = None

    def create_instance(self, alias, egate_console, **kwargs):
        """Creates a new WtsEmulator  instance with the given alias and parameters.

        Args:
            alias (str): Alias to identify the WTS instance.
            **kwargs: All arguments required by WtsEmulator  (e.g., host, egate_port, edaemon_port, ssh_user, ssh_pass).

        Example:
            | multiwtsemu.create_instance | WTS1 | host=10.10.10.1 | egate_port=30000 | edaemon_port=22222
            | ssh_user=ute | ssh_pass=ute |
        """
        self.instances[alias] = WtsEmulator(egate_console, **kwargs)
        self.current = alias

    def select_instance(self, alias):
        """Selects the current WTS instance by alias.

        Args:
            alias (str): Alias of the WTS instance to select.

        Raises:
            Exception: If the alias does not exist.
        """
        if alias not in self.instances:
            raise Exception(f"No WTS instance named {alias}")
        self.current = alias

    def sim_cfg(self, *args, **kwargs):
        """Calls sim_cfg on the current WtsEmulator  instance.

        Args:
            *args: Positional arguments for sim_cfg.
            **kwargs: Keyword arguments for sim_cfg.

        Returns:
            The result of sim_cfg.
        """
        return self.instances[self.current].sim_cfg(*args, **kwargs)

    def script(self, *args, **kwargs):
        """Calls script on the current WtsEmulator  instance.

        Args:
            *args: Positional arguments for script.
            **kwargs: Keyword arguments for script.

        Returns:
            The result of script.
        """
        return self.instances[self.current].script(*args, **kwargs)

    def teardown(self, alias):
        """Releases and removes a specific WtsEmulator  instance by alias.

        Args:
            alias (str): Alias of the WTS instance to teardown.
        """
        if alias in self.instances:
            try:
                self.instances[alias].close()  # If WtsEmulator  has a close() or cleanup method
            except Exception:
                pass
            del self.instances[alias]
            if self.current == alias:
                self.current = None

    def teardown_all(self):
        """Releases and removes all WtsEmulator  instances."""
        for alias, instance in self.instances.items():
            try:
                instance.close()  # If WtsEmulator  has a close() or cleanup method
            except Exception:
                pass
        self.instances = {}
        self.current = None
