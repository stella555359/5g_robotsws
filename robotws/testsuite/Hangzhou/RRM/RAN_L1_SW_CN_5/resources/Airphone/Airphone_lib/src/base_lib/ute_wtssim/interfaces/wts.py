# -*- coding: utf-8 -*-

import logging

from ute_common_converter.to_list import to_int_list
from ute_common_converter.to_number import to_int
from ute_common_sshforwarder.forwarder import Forwarder

from .common import WTSCommonInterface
from ..wts.state_machine import WTSStateMachine
from ..luaconfiggenerator.luaconfgenerator import LuaConfigGenerator
from ..exception import SSHCommandError
from ..filecollector.filecollector import FileCollector
from ..wts.iphyvalidator import IphyConfigValidator


class WtsInterface(WTSCommonInterface):
    def start_wts_applications(self, egate_port=20000, edaemon_ports=(10000, 30000), cfg_file=None, suite_file=None,
                               timeout=None, tool_dir=None, lua_dirs=(), ext=(), **kwargs):
        alias = kwargs.get('alias')
        timeout = self._to_secs(timeout)
        edaemon_ports = self._to_port_list(edaemon_ports)

        ssh_client = self._create_ssh_client_for_alias(alias)
        telnet_client = self._create_telnet_client_for_alias(egate_port, alias)

        egate = self._create_egate(egate_port, ssh_client, telnet_client, tool_dir, lua_dirs)
        edaemons = self._create_edaemons(edaemon_ports, ssh_client, tool_dir)
        self._store_wts(egate, edaemons, cfg_file, suite_file, timeout, alias)
        self._notify_extenders(egate, alias, ext)
        self.wts_store.get(alias).start()

    def start_wts_services(self, timeout=None, retry=0, check_version=True, **kwargs):
        timeout = self._to_secs(timeout)
        alias = kwargs.get('alias')
        egate = self.wts_store.get(alias).egates[0]
        retry = int(retry)
        if retry <= 0:
            egate.start_services(timeout, check_version)
        if retry > 0:
            egate.retry_services(timeout, retry, check_version)

    def configure_ssh_connection_for_wts(self, host_ip=None, ssh_username=None, ssh_password=None, ssh_port=None,
                                         ssh_prompt=None, **kwargs):
        alias = kwargs.get('alias')
        self._configure_ssh_connection_for_alias(host_ip, ssh_username, ssh_password, ssh_port, ssh_prompt, alias)

    def configure_enb_ssh_connection_for_wts(self, enb_ip=None,  enb_username=None, enb_password=None,
                                             enb_prompt=None, **kwargs):
        alias = kwargs.get('alias')
        self._configure_ssh_connection_to_enb(enb_ip, enb_username, enb_password, enb_prompt, alias)

    def reset_wts_ssh_connection_parameters(self, **kwargs):
        alias = kwargs.get('alias')
        self._init_connection_parameters(alias)

    def stop_and_collect_wts_logs(self, unzip=None, subdirectory=None, **kwargs):
        alias = kwargs.get('alias')
        wts = self.wts_store.get(alias)
        wts.stop()
        self._collect_logs(wts, unzip, subdirectory)
        self.get_testline_info(subdirectory, alias=alias)
        wts.close_all_connections()
        self.wts_store.remove(alias)
        self.notifier.egate_deleted(alias)

    def get_testline_info(self, subdirectory=None, **kwargs):
        alias = kwargs.get('alias')
        client = self._create_ssh_client_for_alias(alias)
        FileCollector(ssh_client=client).get_testline_info(subdirectory)

    def teardown_all_aliases_for_wts(self, **kwargs):
        for alias_name_wts in self.wts_store.aliases:
            self.stop_and_collect_wts_logs(alias=alias_name_wts)

    def generate_lua_configuration_for_wts(self, config_dir, config_file, enb_index=1, iphy_path=None, **kwargs):
        logging.warning("Deprecated since 2.0.0. Reason: KW won't be able to generate SCF via ADMIN connection. "
                        "Only SSH SCFC fetch would be available (/ffs/run/config/SCFC_*.xml). "
                        "Please adjust your TCs to not use ADMIN")
        enb_index = to_int(enb_index)
        alias = kwargs.pop('alias', None)

        admin_params = {'admin_host': kwargs.pop('admin_host', '192.168.255.129'),
                        'admin_port': to_int(kwargs.pop('admin_port', 443)),
                        'admin_username': kwargs.pop('admin_username', 'Nemuadmin'),
                        'admin_password': kwargs.pop('admin_password', 'nemuuser')}

        settings = self._get_connection_settings_for_alias(alias)
        bind_port, forwarder = self._create_forwarder(settings)
        client_settings = self._configure_ssh_connection('127.0.0.1', settings.enb_username, settings.enb_password,
                                                         bind_port, settings.enb_prompt)
        self._generate_lua_via_tunneled_connection(client_settings, config_dir, config_file, forwarder,
                                                   enb_index, iphy_path, admin_params, settings, kwargs)

    def validate_iphy_config(self, scfc, iphyxml, iphydb=None, **kwargs):
        alias = kwargs.get('alias')
        client = self._create_ssh_client_for_alias(alias)
        validator = IphyConfigValidator(client)
        validator.validate(scfc, iphyxml, iphydb, **kwargs)

    def _store_wts(self, egate, edaemons, cfg_file, suite_file, timeout, alias):
        wts = WTSStateMachine()
        wts.add_egate(egate, cfg_file, suite_file, timeout)
        wts.add_edaemons(edaemons)
        self.wts_store.add(wts, alias)

    def _to_port_list(self, edaemon_ports):
        if not isinstance(edaemon_ports, (list, tuple)):
            edaemon_ports = [edaemon_ports]
        return to_int_list(edaemon_ports)

    def _create_forwarder(self, settings):
        forwarder = Forwarder(settings.ssh_connection_params, settings.ssh_login_params, settings.enb_ip, 22)
        bind_port = forwarder.start()
        return bind_port, forwarder

    def _generate_lua_via_tunneled_connection(self, client_settings, config_dir, config_file, forwarder,
                                              enb_index, iphy_path, admin, settings, kwargs):
        ssh_client = None
        try:
            ssh_client = self._create_ssh_client_from_settings(client_settings)
            LuaConfigGenerator(ssh_client, admin, settings).build_configuration(config_dir, config_file, enb_index,
                                                                                iphy_path, **kwargs)
        finally:
            if ssh_client:
                ssh_client.close()
            forwarder.stop()
