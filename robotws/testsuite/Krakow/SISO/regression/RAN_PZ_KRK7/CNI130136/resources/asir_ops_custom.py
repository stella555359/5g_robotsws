from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.asir.generic_asir import login_logout, login_gui_if_needed
from taf.rfrl.bts.devices.asir.generic_asir import GenericAsirHub
from taf.rfrl.bts.devices.asir.dist_name_patterns import AsirDistNamePatterns
from taf.rfrl.bts.devices.exceptions import AlarmIsActive, AlarmIsNotActive

from robot.libraries.BuiltIn import BuiltIn, logger
from pprint import pformat
import time
import json

from testsuite.Krakow.resources.RAN_PZ_KRK7.sshrmod.helpers_12097 import f_log


class asir_ops_custom(GnbAsirHubOperations):

    def __init__(self):
        super().__init__()

    def get_all_hubmod_dist_names_and_uids(self):
        hub_dist_names = self._get_all_dist_names_and_uids(AsirDistNamePatterns.re_hubmod_dist_name.format(r'\d'))
        logger.debug(f'{hub_dist_names=}')
        return hub_dist_names

    def get_all_antmod_dist_names_and_uids(self):
        ant_dist_names = self._get_all_dist_names_and_uids(AsirDistNamePatterns.re_antmod_dist_name.format(r'\d'))
        logger.debug(f'{ant_dist_names=}')
        return ant_dist_names

    @staticmethod
    def get_subcontainer(container, key, value):
        logger.debug(f'get_subcontainer {container=}, {key=}, {value=}')
        for el in container:
            if el[key] == value:
                logger.debug('get_subcontainer return value: ' + pformat(el))
                return el
        logger.warn('No container meeting criteria')

    def get_hubmod_id(self, hubmod_sn):
        for hubmod in self.get_all_hubmod_dist_names_and_uids():
            hub_info = self.get_unit_logical_info(uid=hubmod['uid'])
            gen_info = self.get_subcontainer(hub_info['paragraphs'], 'title', 'General Information')
            sn = self.get_subcontainer(gen_info['paragraphs'], 'title', 'Serial Number')
            if sn['text'] == hubmod_sn:
                return hubmod['dn']
        logger.warn('No hubmod found')

    def get_hubmod_general_info(self, hubmod_sn):
        for hubmod in self.get_all_hubmod_dist_names_and_uids():
            hub_info = self.get_unit_logical_info(uid=hubmod['uid'])
            _gen_info = self.get_subcontainer(hub_info['paragraphs'], 'title', 'General Information')
            sn = self.get_subcontainer(_gen_info['paragraphs'], 'title', 'Serial Number')
            if sn['text'] == hubmod_sn:
                gen_info = {el['title']: el['text'] for el in _gen_info['paragraphs']}
                logger.info(f'hubmod_gen_info: {pformat(gen_info)}')
                return gen_info
        logger.warn('No hubmod found')

    def get_antmod_general_info(self, antmod_uid):
        antmod_info = self.get_unit_logical_info(antmod_uid)
        _gen_info = self.get_subcontainer(antmod_info['paragraphs'], 'title', 'General Information')
        gen_info = {el['title']: el['text'] for el in _gen_info['paragraphs']}
        logger.debug(f'gen_info: {pformat(gen_info)}')
        return gen_info

    def get_antmods_connected_to_hubmod(self, hubmod_sn):
        hubmod = self.get_all_hubs_with_cell_and_antenna_mapping(scf_file_path=None, bts_id=0)[hubmod_sn]
        logger.debug(f'hubmod["antennas"]: {pformat(hubmod["antennas"])}')
        return hubmod['antennas']

    def get_antmod_connected_to_hubmod(self, hubmod_sn, id_on_hub=0):
        antennas = self.get_antmods_connected_to_hubmod(hubmod_sn)
        ant_count = len(antennas)
        logger.debug(f'{ant_count=}')
        if id_on_hub > ant_count - 1:
            logger.warn(f'{id_on_hub=} shouldn\'t be greater than {ant_count - 1 = }, recalculating...', html=True)
            id_on_hub %= ant_count
            logger.info('.. Recalculated to ' + id_on_hub)
        antmod = list(enumerate(antennas.items()))[id_on_hub][1]
        logger.debug(f'antmod: {pformat(antmod)}')
        return antmod

    def get_antmod_id_connected_to_hubmod(self, hubmod_sn, id_on_hub=0):
        return self.get_antmod_connected_to_hubmod(hubmod_sn, id_on_hub=id_on_hub)[1]['id']

    def get_antmod_sn_connected_to_hubmod(self, hubmod_sn, id_on_hub=0):
        return self.get_antmod_connected_to_hubmod(hubmod_sn, id_on_hub=id_on_hub)[1]['serial_number']

    def get_antmod_uid_connected_to_hubmod(self, hubmod_sn, id_on_hub=0):
        return self.get_antmod_connected_to_hubmod(hubmod_sn, id_on_hub=id_on_hub)[1]['uid']

    def get_antmod_type_connected_to_hubmod(self, hubmod_sn, id_on_hub=0):
        return self.get_antmod_connected_to_hubmod(hubmod_sn, id_on_hub=id_on_hub)[1]['type']

    def wait_for_alarm_activation(self, fault_id, bts_id=0, timeout=60, interval=10):
        start_time = time.time()
        ex = None
        logger.info(f'Waiting for {fault_id} activation for {timeout} seconds...', also_console=True)
        while time.time() - start_time < timeout:
            try:
                self.verify_alarm_is_active(fault_id, bts_id)
                logger.info(f'Activation of {fault_id} successful. Took {(time.time() - start_time):.1f} sec',
                            also_console=True)
                return
            except AlarmIsNotActive as ex_:
                BuiltIn().log_to_console('.', no_newline=True)
                logger.info(f'Waiting for {fault_id} activation...'
                            f'{(start_time + timeout - time.time()):.1f} s left...', also_console=False)
                ex = ex_
            time.sleep(interval)
        raise TimeoutError(
            f'Activation of {fault_id} timeout. Took {(time.time() - start_time):.1f} sec. '
            f'Original exception: {ex}')

    def wait_for_alarm_deactivation(self, fault_id, bts_id=0, timeout=60, interval=10):
        start_time = time.time()
        ex = None
        logger.info(f'Waiting for {fault_id} deactivation for {timeout} seconds...', also_console=True)
        while time.time() - start_time < timeout:
            try:
                self.verify_alarm_is_not_active(fault_id, bts_id)
                logger.info(f'Deactivation of {fault_id} successful. Took {(time.time() - start_time):.1f} sec',
                            also_console=True)
                return
            except AlarmIsActive as ex_:
                BuiltIn().log_to_console('.', no_newline=True)
                logger.info(f'Waiting for {fault_id} deactivation, '
                            f'{(start_time + timeout - time.time()):.1f} s left...', also_console=False)
                ex = ex_
            time.sleep(interval)
        raise TimeoutError(
            f'Dectivation of {fault_id} timeout. Took {(time.time() - start_time):.1f} sec. '
            f'Original exception: {ex}')

    def get_all_dist_names(self, bts_id=0):
        active_objects = self._get_active_objects()
        logger.info(f'get_all_dist_names active_objects={pformat(active_objects)}')
        dist_names = self._get_all_dist_names('')
        return dist_names

    def change_asirmod_id_in_hubmod(self, hubmod_dn, asirmodid, btsid=1):
        delta = [{'distName': hubmod_dn,
                 'parameters': [
                     {
                         'operation': 'update',
                         'parameterName': 'externalIds',
                         'index': 0,
                         'field': 'btsId',
                         'value': str(btsid),
                     },
                     {
                         'operation': 'update',
                         'parameterName': 'externalIds',
                         'index': 0,
                         'field': 'asiRmodId',
                         'value': str(asirmodid)
                     },
                 ]}]
        logger.info(f'change_asirmod_id_in_hubmod {delta=}')
        self.perform_asir_recommissioning(delta)

    def change_asirmods_id_in_2_hubmods_at_once(self, hubmod_dn1, asirmodid1, hubmod_dn2, asirmodid2, btsid=1):
        delta = [
            {'distName': hubmod_dn1,
             'parameters': [
                 {
                     'operation': 'update',
                     'parameterName': 'externalIds',
                     'index': 0,
                     'field': 'btsId',
                     'value': str(btsid),
                 },
                 {
                     'operation': 'update',
                     'parameterName': 'externalIds',
                     'index': 0,
                     'field': 'asiRmodId',
                     'value': str(asirmodid1)
                 },
             ]},
            {'distName': hubmod_dn2,
             'parameters': [
                 {
                     'operation': 'update',
                     'parameterName': 'externalIds',
                     'index': 0,
                     'field': 'btsId',
                     'value': str(btsid),
                 },
                 {
                     'operation': 'update',
                     'parameterName': 'externalIds',
                     'index': 0,
                     'field': 'asiRmodId',
                     'value': str(asirmodid2)
                 },
             ]}]
        assert hubmod_dn1 and asirmodid1 and hubmod_dn2 and asirmodid2, 'All params has to be set'
        logger.info(f'change_asirmod_id_in_hubmod delta={pformat(delta)}')
        self.perform_asir_recommissioning(delta)
