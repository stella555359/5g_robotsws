# -*- coding: utf-8 -*-

import time

from ..filecollector.filecollector import FileCollector
from ..utils.decorator import StateAllowed


class WTSStateMachine(object):

    def __init__(self, alias=None):
        self._egates = []
        self._edaemons = []
        self.alias = alias
        StateAllowed.set_state('INIT', alias)

    @property
    def egates(self):
        return [each[0] for each in self._egates]

    @property
    def edaemons(self):
        return self._edaemons

    @StateAllowed('INIT')
    def add_egate(self, egate, cfg_file=None, suite_file=None, timeout=None, retry=0):
        self._egates.append([egate, cfg_file, suite_file, timeout, retry])

    @StateAllowed('INIT')
    def add_edaemons(self, edaemons):
        for each in edaemons:
            self._edaemons.append(each)

    @StateAllowed('INIT')
    def start(self):
        for each in self.edaemons:
            each.setup()
        for each in self._egates:
            each[0].setup()
            each[0].configure_egate(*each[1:])
        StateAllowed.set_state('STARTED', self.alias)

    @StateAllowed('ANY')
    def reconnect(self):
        for each in self.edaemons:
            each.setup(reconnect=True)
        for each in self._egates:
            each[0].setup(reconnect=True)
            time.sleep(1)
            each[0].configure_egate(*each[1:])
        StateAllowed.set_state('STARTED', self.alias)

    @StateAllowed('STARTED')
    def stop(self, **kwargs):
        self._shutdown_applications()
        StateAllowed.set_state('INIT', self.alias)

    @StateAllowed('ANY')
    def get_egates_logs(self, files_list, unzip, subdir):
        for each in self.egates:
            name = "wtssim_egate_{}.tar.gz".format(each.port)
            self._get_log(name, each.client, each.tool_dir, files_list, unzip, subdir)

    @StateAllowed('ANY')
    def get_edaemons_logs(self, files_list, unzip, subdir):
        for each in self.edaemons:
            name = "wtssim_edaemon_{}.tar.gz".format(each.port)
            self._get_log(name, each.client, each.tool_dir, files_list, unzip, subdir)

    @StateAllowed('INIT')
    def close_all_connections(self):
        self._close_all_connections()

    @StateAllowed('INIT')
    def set_egate_params(self, cfg_file=None, suite_file=None, timeout=None, retry=0):
        for each in self._egates:
            each[1] = cfg_file if cfg_file else each[1]
            each[2] = suite_file if timeout else each[2]
            each[3] = timeout if timeout else each[3]
            each[4] = retry

    def _get_log(self, name, client, tool_dir, files_list, unzip, subdir):
        files_list = [entry.format(tool_dir) for entry in files_list]
        FileCollector(ssh_client=client, tar_name=name).get_files(
            files_list=files_list,
            unzip=unzip,
            subdirectory=subdir)

    def _close_all_connections(self):
        for each in self.egates:
            each.client.close()
        for each in self.edaemons:
            each.client.close()

    def _shutdown_applications(self):
        for each in self.egates:
            each.teardown()
        for each in self.edaemons:
            each.teardown()
