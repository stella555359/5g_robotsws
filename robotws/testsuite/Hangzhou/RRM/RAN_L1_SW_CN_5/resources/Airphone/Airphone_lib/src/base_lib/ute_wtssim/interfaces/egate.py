# -*- coding: utf-8 -*-

import logging

from ute_common_converter.to_number import to_int
from ute_common_converter.to_bool import to_bool

from .common import WTSCommonInterface
from ..wts.state_machine import WTSStateMachine


class WTSEgateInterface(WTSCommonInterface):

    def setup_egate(self, egate_port, host_ip='127.0.0.1', tool_dir=None, save_egate=False, **kwargs):
        self.save_egate = to_bool(save_egate)

        if self.save_egate:
            logging.warn("\'save_egate\' flag is set. Egate will not terminate after test execution "
                         "unless overriden with Teardown keywords.")

        alias = kwargs.get('alias')
        connection_settings = self._configure_ssh_connection(host_ip,
                                                             kwargs.get('ssh_user'),
                                                             kwargs.get('ssh_pass'),
                                                             kwargs.get('ssh_port'),
                                                             kwargs.get('ssh_prompt'))
        ssh_client = self._create_ssh_client_from_settings(connection_settings)
        telnet_client = self._create_telnet_client_from_settings(connection_settings, egate_port)
        egate = self._create_egate(egate_port, ssh_client, telnet_client, tool_dir)
        self._notify_extenders(egate, alias, kwargs.get('ext', []))
        self._store_egate(egate, alias)

    def start_egate_process(self, cfg_file=None, suite_file=None, timeout=None, retry=0, **kwargs):
        alias = kwargs.get('alias')
        timeout = self._to_secs(timeout)
        wts = self.wts_store.get(alias)
        wts.set_egate_params(cfg_file, suite_file, timeout, retry)

        if to_bool(kwargs.get('reconnect', False)):
            if wts.egates[0].is_running:
                wts.reconnect()
            else:
                logging.warn("UNABLE TO RECONNECT TO EGATE: No egate found in port {}.\n"
                             "Creating new egate process...".format(wts.egates[0].port))
                wts.start()
        else:
            wts.start()

    def link_edaemons_to_egate(self, *edaemons_aliases, **kwargs):
        alias = kwargs.get('alias')
        for edaemon_alias in edaemons_aliases:
            egate = self.wts_store.get(alias).egates[0]
            edaemon = self.edaemon_store.get(edaemon_alias).edaemons[0]
            egate.add_edaemon(edaemon)

    def start_egate_services(self, timeout=None, retry=0, check_version=True, **kwargs):
        timeout = self._to_secs(timeout)
        alias = kwargs.get('alias')
        egate = self.wts_store.get(alias).egates[0]
        retry = to_int(retry)
        if retry <= 0:
            egate.start_services(timeout, check_version)
        if retry > 0:
            egate.retry_services(timeout, retry, check_version)

    def add_egate_lua_dirs(self, *lua_dirs, **kwargs):
        alias = kwargs.get('alias')
        egate = self.wts_store.get(alias).egates[0]
        for each in lua_dirs:
            egate.lua_dirs.append(each)

    def teardown_egate(self, **kwargs):
        alias = kwargs.get('alias')
        self.wts_store.get(alias).stop()
        self.wts_store.get(alias).close_all_connections()
        self.wts_store.remove(alias)
        self.notifier.egate_deleted(alias)

    def teardown_all_aliases_for_egate(self, **kwargs):
        for alias_name_wts in self.wts_store.aliases:
            self.collect_egate_log_files(alias=alias_name_wts)
            self.teardown_egate(alias=alias_name_wts)

    def collect_egate_log_files(self, unzip=None, subdirectory=None, **kwargs):
        alias = kwargs.get('alias')
        wts = self.wts_store.get(alias)
        self._collect_logs(wts, unzip, subdirectory)

    def execute_egate_command(self, cmd, pass_regexp=None, fail_regexp=None, timeout=None, **kwargs):
        alias = kwargs.get('alias')
        return_output = kwargs.get('return_output', True)
        timeout = self._to_secs(timeout)
        egate = self.wts_store.get(alias).egates[0]
        padding_buffer = kwargs.get("padding_buffer", 5000)

        if type(pass_regexp) is str:
            pass_regexp_L = [pass_regexp]
        elif pass_regexp is None:
            pass_regexp_L = []
        else:
            pass_regexp_L = pass_regexp
        if type(fail_regexp) is str:
            fail_regexp_L = [fail_regexp]
        elif fail_regexp is None:
            fail_regexp_L = []
        else:
            fail_regexp_L = fail_regexp
        return egate.execute_telnet_command(cmd=cmd,
                                            return_output=return_output,
                                            ignore_prompt_prefix=True,
                                            pass_regexp_L=pass_regexp_L,
                                            fail_regexp_L=fail_regexp_L,
                                            timeout=timeout,
                                            padding_buffer=padding_buffer)

    def execute_egate_command_and_wait_for_data(self, cmd, timeout=None, **kwargs):
        alias = kwargs.get('alias')
        return_output = kwargs.get('return_output', True)
        pass_regexp = kwargs.get('pass_regexp', 'EGATE>')
        timeout = self._to_secs(timeout)
        egate = self.wts_store.get(alias).egates[0]
        return egate.execute_telnet_command(cmd=cmd,
                                            return_output=return_output,
                                            pass_regexp=pass_regexp,
                                            timeout=timeout,
                                            ignore_prompt_prefix=True)

    def _store_egate(self, egate, alias):
        wts = WTSStateMachine(alias=alias)
        wts.add_egate(egate)
        self.wts_store.add(wts, alias)
