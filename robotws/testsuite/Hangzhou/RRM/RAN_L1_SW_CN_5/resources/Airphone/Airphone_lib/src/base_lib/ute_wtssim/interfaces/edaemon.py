# -*- coding: utf-8 -*-

from .common import WTSCommonInterface
from ..wts.state_machine import WTSStateMachine


class WTSEdaemonInterface(WTSCommonInterface):
    def setup_edaemon(self, edaemon_port, host_ip='127.0.0.1', tool_dir=None, **kwargs):
        alias = kwargs.get('alias')
        connection_settings = self._configure_ssh_connection(host_ip,
                                                             kwargs.get('ssh_user'),
                                                             kwargs.get('ssh_pass'),
                                                             kwargs.get('ssh_port'),
                                                             kwargs.get('ssh_prompt'))
        ssh_client = self._create_ssh_client_from_settings(connection_settings)
        edaemon = self._create_edaemons([edaemon_port], ssh_client, tool_dir)[0]
        self._store_edaemon(edaemon, alias)

    def teardown_edaemon(self, **kwargs):
        alias = kwargs.get('alias')
        self.edaemon_store.get(alias).stop()
        self.edaemon_store.get(alias).close_all_connections()
        self.edaemon_store.remove(alias)

    def teardown_all_aliases_for_edaemon(self, **kwargs):
        for alias_name_edaemon in self.edaemon_store.aliases:
            self.collect_edaemon_log_files(alias=alias_name_edaemon)
            self.teardown_edaemon(alias=alias_name_edaemon)

    def start_edaemon_process(self, **kwargs):
        alias = kwargs.get('alias')
        self.edaemon_store.get(alias).start()

    def collect_edaemon_log_files(self, unzip=None, subdirectory=None, **kwargs):
        alias = kwargs.get('alias')
        wts = self.edaemon_store.get(alias)
        self._collect_logs(wts, unzip, subdirectory)

    def _store_edaemon(self, edaemon, alias):
        wts = WTSStateMachine(alias=alias)
        wts.edaemons.append(edaemon)
        self.edaemon_store.add(wts, alias=alias)
