# -*- coding: utf-8 -*-
"""
Library contains keywords for operations on extension module

:copyright: Nokia Networks
:author: MN_RAN_PZ_KRK_TAG
:contact: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
:maintainer: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
"""
import logging
import re
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue
from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException
from taf.rfrl.bts.devices.exceptions import UnexpectedWebemBehavior
from taf.rfrl.bts.devices.generic_bts import login_logout, login_logout_GUI
from taf.rfrl.utilities.tl_config import get_extension_product_code
from selenium.common.exceptions import TimeoutException


class GnbRadioExtension(GnbCellOperations, GnbRuOperations):
    bts_type = 'GNB'

    def __init__(self):
        super(GnbRadioExtension, self).__init__(bts_type=GnbRadioExtension.bts_type)

    @login_logout_GUI
    def add_extension_module_with_default_params(self, ext_rmod_id=2,
                                                 rmod_id=1, gnb_id=0, du_id=0, ru_id=0, ext_id=0):
        """
        Add to configuration RMOD object for extension module with default parameters, add required objects and modify
        required parameters to configure extension module.
        :param connector_label: The hardware connector label corresponding to the Ethernet link
        :param ext_rmod_id: RMOD id of extension module
        :param rmod_id: RMOD id of main radio module
        :param gnb_id: ID of gNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param ru_id: RU ID - id related to Test Line configuration - gnb.dus[].rus[]
        :param ext_id: Extension ID - id related to Test Line configuration - gnb.dus[].rus[].ru_extensions
        :return: None
        """
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        mrbts_id = self.get_bts_instance_id(bts_id=gnb_id, du_id=du_id)
        self.add_rmod_with_default_params(rmod_id=ext_rmod_id, gnb_id=gnb_id, du_id=du_id, ru_id=ru_id, ext_id=ext_id)
        loglinkId = 1
        loglinkName = "EXTMOD-{}".format(loglinkId)
        self._add_new_loglink_via_gui(loglinkId, loglinkName, first_rmod_id=rmod_id, second_rmod_id=ext_rmod_id,
                                      bts_id=gnb_id, du_id=du_id)
        self.gui_coam.add_object(object_name='MRBTS-{}/EQM-1/APEQM-1/RMOD-2'.format(mrbts_id),
                                 object_class_name='PHYANT',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from='MRBTS-{}/EQM-1/APEQM-1/RMOD-1/PHYANT-1'.format(mrbts_id),
                                 include_subobject=True,
                                 id_value='1',
                                 sbts=gui_alias)

        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=True, sbts=gui_alias)

    @login_logout_GUI
    def add_extension_module_cells_based_on_radio_module_cells(self, cell_parameters, ext_rmod_id=2, gnb_id=0,
                                                               du_id=0):
        """
        Add cells for extension module basing on main radio unit's cells.
        :param cell_parameters: dict containing cells parameters e.g. dict = {
                                6: {
                                    'nrarfcn': '2073339',
                                    'gscn': '22452',
                                    'coreset': '0',
                                    'physCellId': None,
                                    'freq_band': '257',
                                    'channel_ids': [1, 2, 3, 4]
                                    }, ...}
        :param ext_rmod_id: RMOD id of extension module
        :param gnb_id: ID of gNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=gnb_id, du_id=du_id)
        mrbts_id = self.get_bts_instance_id(bts_id=gnb_id, du_id=du_id)

        radio_cells_ids = self._get_all_physical_cell_ids()
        sorted_radio_cells_ids = sorted(radio_cells_ids, key=int)
        radio_cells_group_id = self.get_cell_group_id_linked_to_cell_id(cell_id=sorted_radio_cells_ids[0])['ID']

        ext_global_cells_ids = sorted(cell_parameters.keys(), key=int)
        ext_cells_in_group = []
        ext_cells_group_id = int(radio_cells_group_id) + 1
        ext_cells_group_dist_name = self.add_extension_module_cells_group(dist_name, ext_cells_group_id,
                                                                          radio_cells_group_id)
        ext_rmod_dist_name = "MRBTS-{}/EQM-1/APEQM-1/RMOD-{}".format(mrbts_id, ext_rmod_id)

        cells_added = 0
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        for global_cell_id in ext_global_cells_ids:
            logging.info("Adding NRCELL-{}...".format(global_cell_id))
            if cell_parameters[global_cell_id]['physCellId'] is None:
                physical_cell_id = sorted_radio_cells_ids[-1] + cells_added + 1
            else:
                physical_cell_id = cell_parameters[global_cell_id]['physCellId']

            cell_dist_name = "{}/NRCELL-{}".format(dist_name, global_cell_id)

            self._add_new_cell_based_on_existing_cell_to_configuration_via_gui(
                cell_id_to_copy_from=self._get_global_cell_id_for_physical_cell_id(
                    cell_id=sorted_radio_cells_ids[cells_added]),
                cell_id=str(global_cell_id),
                nrarfcn=cell_parameters[global_cell_id]['nrarfcn'],
                gscn=cell_parameters[global_cell_id]['gscn'],
                physCellId=str(physical_cell_id),
                type0CoresetConfigurationIndex=cell_parameters[global_cell_id]['coreset'],
                maxNumScellsDl=len(self._get_all_global_cell_ids(bts_id=gnb_id, du_id=du_id)),
                dist_name=dist_name,
                cell_dist_name=cell_dist_name,
                cell_group_dist_name=ext_cells_group_dist_name,
                mrbts_id=mrbts_id,
                cell_ids_in_group=ext_cells_in_group,
                nrcell_include_subobject=True, activate_plan_despite_errors=False, bts_id=gnb_id, du_id=du_id,
                gscn_filter_param='Synchronization channel number'
            )
            cells_added = cells_added + 1
            ext_cells_in_group.append(str(global_cell_id))
            self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                              filter_param='List of RMOD distinguished names',
                                              node_index=0,
                                              new_value=ext_rmod_dist_name,
                                              sbts=gui_alias)
            self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                              filter_param='Frequency band Indicator NR',
                                              new_value=cell_parameters[global_cell_id]['freq_band'],
                                              sbts=gui_alias)
        path = self.gui_coam.save_bts_configuration(save_configuration_type=0,
                                                    is_save_planned_parameter_changes_selected=True, sbts=gui_alias)
        logging.info("Path to scf with cells: {}".format(path))
        self.gui_coam.load_commissioning_file_and_check_load_status(file_path=path, sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=True, execute=True, sbts=gui_alias)

    @login_logout_GUI
    def add_cablink(self, connector_label='S-RF2', gnb_id=0, du_id=0):
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        mrbts_id = self.get_bts_instance_id(bts_id=gnb_id, du_id=du_id)
        self.gui_coam.add_object(object_name='MRBTS-{}/EQM-1/HWTOP-1'.format(mrbts_id),
                                 object_class_name='CABLINK',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-2'.format(mrbts_id),
                                 include_subobject=False,
                                 id_value='3',
                                 sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-3'.format(mrbts_id),
                                          filter_param='First endpoint port identifier',
                                          new_value='2',
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-3'.format(mrbts_id),
                                          filter_param='Second endpoint port identifier',
                                          new_value='2',
                                          sbts=gui_alias)
        self.gui_coam.add_object(object_name='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1'.format(mrbts_id),
                                 object_class_name='ETHLK',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1'.format(mrbts_id),
                                 include_subobject=True,
                                 id_value='2',
                                 sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2'.format(mrbts_id),
                                          filter_param='The hardware connector '
                                                       'label corresponding to the Ethernet link',
                                          new_value=connector_label,
                                          sbts=gui_alias)
        self.gui_coam.add_object(object_name='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1'.format(mrbts_id),
                                 object_class_name='ETHIF',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1'.format(mrbts_id),
                                 include_subobject=True,
                                 id_value='2',
                                 sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2/'
                                                    'VLANIF-1'.format(mrbts_id),
                                          filter_param='VLAN ID',
                                          new_value='2',
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2'.format(mrbts_id),
                                          filter_param='Reference to an external or internal bridge port',
                                          new_value='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2'.format(mrbts_id),
                                          sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=True, execute=True, sbts=gui_alias)

    def add_extension_module_cells_group(self, dist_name, group_id, group_id_to_copy_from=0, gnb_id=0, du_id=0):
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='NRCELLGRP',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from=dist_name + '/NRCELLGRP-' + str(group_id_to_copy_from),
                                 include_subobject=True,
                                 id_value=group_id,
                                 sbts=gui_alias)
        group_dist_name = "{}/NRCELLGRP-{}".format(dist_name, group_id)
        self.gui_coam.add_element(dist_name="{}/NRDU-1".format(dist_name),
                                  filter_param='Reference to cell group', sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name="{}/NRDU-1".format(dist_name),
                                          filter_param='Reference to cell group',
                                          node_index=group_id,
                                          new_value=group_id,
                                          sbts=gui_alias)
        return group_dist_name

    def add_rmod_with_default_params(self, rmod_id, gnb_id=0, du_id=0, ru_id=0, ext_id=0):
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        mrbts_id = self.get_bts_instance_id(bts_id=gnb_id, du_id=du_id)
        product_code = get_extension_product_code(bts_id=gnb_id, du_id=du_id, ru_id=ru_id, ext_id=ext_id)
        dist_name = "MRBTS-{}/EQM-1/APEQM-1".format(mrbts_id)
        rmod_dist_name = "MRBTS-{}/EQM-1/APEQM-1/RMOD-{}".format(mrbts_id, rmod_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='RMOD',
                                 id_value=rmod_id,
                                 is_load_default_values=True,
                                 sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=rmod_dist_name,
                                          filter_param='Product code planned',
                                          new_value=product_code,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=rmod_dist_name,
                                          filter_param='Administrative state',
                                          new_value='Unlocked',
                                          sbts=gui_alias)
        self.gui_coam.delete_parameter(dist_name=rmod_dist_name,
                                       filter_param='O-RU Energy Saving Enabled',
                                       sbts=gui_alias)
        return rmod_dist_name

    @login_logout_GUI
    def configure_beamforming_on_radio_end_extension_cells(self, radio_beamset=None, extension_beamset=None,
                                                           ext_rmod_id=2, rmod_id=1, gnb_id=0, du_id=0):
        """
        Configure basicBeamSet and set actBeamforming to true for main radio unit and extension.
        :param radio_beamset: basicBeamSet value for all cells on main radio, if None then parameter is not changed
        :param extension_beamset: basicBeamSet value for all cells on extension, if None then parameter is not changed
        :param ext_rmod_id: RMOD id of extension module
        :param rmod_id: RMOD id of main radio unit
        :param gnb_id: ID of gNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        logging.info("Configuring basicBeamSet params and activating beamforming for all cells...")
        radio_cells_ids = self._get_all_global_cell_ids(radio_id=rmod_id, bts_id=gnb_id, du_id=du_id)
        for cell_id in radio_cells_ids:
            self._configure_beamforming_for_one_cell(beamset=radio_beamset, cell_id=cell_id, gnb_id=gnb_id,
                                                     du_id=du_id)

        ext_cells_ids = self._get_all_global_cell_ids(radio_id=ext_rmod_id, bts_id=gnb_id, du_id=du_id)
        for cell_id in ext_cells_ids:
            self._configure_beamforming_for_one_cell(beamset=extension_beamset, cell_id=cell_id, gnb_id=gnb_id,
                                                     du_id=du_id)

        path = self.gui_coam.save_bts_configuration(save_configuration_type=0,
                                                    is_save_planned_parameter_changes_selected=True,
                                                    sbts=gui_alias)
        logging.info("Path to scf with beamforming: {}".format(path))
        self.gui_coam.load_commissioning_file_and_check_load_status(file_path=path, sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=True, execute=True, sbts=gui_alias)

    def _configure_beamforming_for_one_cell(self, beamset, cell_id, gnb_id, du_id):
        if beamset is not None:
            self._set_new_beamset_value_via_gui(basicBeamSet=beamset, cell_id=cell_id, bts_id=gnb_id, du_id=du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=gnb_id, du_id=du_id)
        logging.info("Activating beamforming...")
        self.gui_coam.set_parameter_value(dist_name="{}/NRCELL-{}".format(dist_name, cell_id),
                                          filter_param='Activate Beamforming',
                                          new_value='true', sbts=self.gui_alias.format(gnb_id, du_id))

    @login_logout
    def configure_channels_params_for_extension_cells(self, cell_parameters, ext_rmod_id=2, gnb_id=0, du_id=0):
        logging.info("Adding channels resourceDN...")
        mrbts_id = self.get_bts_instance_id(bts_id=gnb_id, du_id=du_id)
        ext_rmod_dist_name = "MRBTS-{}/EQM-1/APEQM-1/RMOD-{}".format(mrbts_id, ext_rmod_id)
        for global_cell_id in cell_parameters.keys():
            for channel_id in cell_parameters[global_cell_id]['channel_ids']:
                channel_dist_name = "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}/CHANNELGROUP-1/" \
                                    "CHANNEL-{}".format(mrbts_id, global_cell_id, channel_id)
                logging.info(channel_dist_name)
                self.admin.perform_parameter_recommissioning(
                    channel_dist_name, 'resourceDN', 'update', "{}/PHYANT-1".format(ext_rmod_dist_name),
                    skip_parameter_relation_errors=True, should_activate=True,
                    connection=self.rest_alias.format(gnb_id, du_id))
                logging.info("NRCELL-{} channel {} set".format(global_cell_id, channel_id))
            logging.info("All channels of NRCELL-{} were configured".format(global_cell_id))

    @login_logout_GUI
    def perform_cell_operation(self, operation, bts_id=0, du_id=0, rmod_id=1):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        cells_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, radio_id=rmod_id)
        cell_operation = self.lock_cell_via_gui if operation.lower() == 'lock' else self.unlock_cell_via_gui
        for cell_id in cells_ids:
            cell_operation(bts_id=bts_id, du_id=du_id, cell_id=cell_id, administrative_state=True)
        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(timeout=300, activate_plan_despite_errors=True, sbts=gui_alias)

    @login_logout_GUI
    def verify_cells_state(self, radio_cells_locked=True, extension_cells_locked=True, bts_id=0, du_id=0):
        self._verify_cells_list_status(verify_lock=radio_cells_locked, bts_id=bts_id, du_id=du_id, rmod_id=1)
        self._verify_cells_list_status(verify_lock=extension_cells_locked, bts_id=bts_id, du_id=du_id, rmod_id=2)

    @login_logout
    def _verify_cells_list_status(self, verify_lock=True, bts_id=0, du_id=0, rmod_id=1):
        verify_lock_state = self.verify_cell_is_locked if verify_lock else self.verify_cell_is_unlocked
        for cell_id in self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, radio_id=rmod_id):
            verify_lock_state(bts_id=bts_id, du_id=du_id, cell_id=cell_id)

    @login_logout
    def copy_cells_parameters_from_rmod(self, params_to_get_value_dict, gnb_id=0, du_id=0, cells_to_copy=None):
        """
        Copy given cells parameters from RU to Extension.
        :param params_to_get_value_dict: dict of parameters (key: how the param should be named in output dict,
        value: parameter name in SCF) to copy value from RU, if value is equal empty in output dict value will
        be empty 'param_name': empty
        :cells_to_copy: list of cell_ids to copy parameter from, default value is None - copy all existing cells
        :return: dict of parameter:value
        """
        if cells_to_copy is not None and not isinstance(cells_to_copy, list):
            cells_to_copy = list(cells_to_copy.replace(" ", "").split(','))
        mrbts = self.get_bts_instance_id(bts_id=gnb_id, du_id=du_id)
        nrbts = self.get_global_bts_id(bts_id=gnb_id, du_id=du_id)
        global_cells_ids_list = self.get_all_cells_id(bts_id=gnb_id, du_id=du_id)
        global_cells_ids_list_to_iter = global_cells_ids_list if cells_to_copy is None else cells_to_copy
        cells_parameters_dict = dict()
        scf_params = self.admin.get_scf(export_type="configurationAndRuntimeObjects",
                                        connection=self.rest_alias.format(gnb_id, du_id))
        for cell_id in global_cells_ids_list_to_iter:
            single_cell_parameter = dict()
            object_param_dict = self._get_object_parameters_dict(
                dist_name='MRBTS-{mr}/NRBTS-{nr}/NRCELL-{nrcell}'.format(mr=mrbts, nr=nrbts, nrcell=cell_id),
                bts_id=gnb_id, du_id=du_id)
            for param, value in object_param_dict.items():
                for param_to_get, value_to_get in params_to_get_value_dict.items():
                    if value_to_get == 'None':
                        single_cell_parameter[param_to_get] = None
                    elif value_to_get == param:
                        single_cell_parameter[param_to_get] = value
            if 'channel_ids' in params_to_get_value_dict.keys():
                dn = 'MRBTS-{mr}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{cell}/CHANNELGROUP-1/CHANNEL-'. \
                    format(mr=mrbts, cell=cell_id)
                single_cell_parameter['channel_ids'] = \
                    [int(chan_id[-1]) for chan_id in re.findall(dn + r'[0-9]', scf_params)]
            cells_parameters_dict[len(global_cells_ids_list) + int(cell_id)] = single_cell_parameter
        return cells_parameters_dict

    @login_logout_GUI
    def change_left_right_egde_angle_all_cells(self, angle_values, gnb_id=0, du_id=0):
        """
        Change parameters leftEdgeAngle and rightEdgeAngle for all cells
        :param angle_values:
        dict of dicts {<cell_number>: [<leftEdgeAngle>, <rightEdgeAngle>} if we need to set different value
        for different cells
        e.g. dict = {
                        1: [45, 45],
                        2: [30, 60],
                        3: [60, 30],
                        4: [45, 45],
                        ...}
        int if we need to set the same value for all cells
        e.g. int = 45
        :return: None
        """
        gui_alias = self.gui_alias.format(gnb_id, du_id)
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=gnb_id, du_id=du_id)

        angle_values = {cell_id: [angle_values, angle_values]
                        for cell_id in self.get_all_cells_id(bts_id=gnb_id, du_id=du_id)} \
            if isinstance(angle_values, int) else angle_values

        try:
            for cell_to_change_angle, angle_value in angle_values.items():
                self.gui_coam.set_parameter_value(dist_name='{distname}/NRCELL-{nrcell}'.
                                                  format(distname=dist_name, nrcell=cell_to_change_angle),
                                                  filter_param='Left Cell Edge Angle',
                                                  new_value=angle_value[0],
                                                  sbts=gui_alias)
                self.gui_coam.set_parameter_value(dist_name='{distname}/NRCELL-{nrcell}'.
                                                  format(distname=dist_name, nrcell=cell_to_change_angle),
                                                  filter_param='Right Cell Edge Angle',
                                                  new_value=angle_value[1],
                                                  sbts=gui_alias)
        except TimeoutException:
            raise Exception("There is no cell {cell} on BTS".format(cell=cell_to_change_angle))

        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=True, sbts=gui_alias)

    @login_logout_GUI
    def remove_cell_from_ru(self, cell_id_to_remove, bts_id=0, du_id=0):
        self.remove_cell_via_gui(cell_id_to_remove, bts_id=bts_id, du_id=du_id)


class GnbFeatureLicensing(GnbCommissioning):
    LICENSES = {
            'bronze': 'actGeneralConnectivityBronze',
            'silver': 'actGeneralConnectivitySilver',
            'gold': 'actGeneralConnectivityGold'
    }
    OPERATIONS = {
            'enable': 'true',
            'disable': 'false'
    }

    def __init__(self):
        super(GnbFeatureLicensing, self).__init__()

    @login_logout
    def modify_feature_licensing_if_needed(self, licenses, operation, gnb_id=0, du_id=0):
        """
        Check if given feature licenses are set according to given operation and if not modify
        configuration accordingly.
        :param licenses: single license as string or list of licenses
        :param operation: enable or disable
        :param gnb_id: ID of gNB, default set to 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=gnb_id, du_id=du_id)
        verify_dict = {
            dist_name: {}
        }
        if isinstance(licenses, str):
            licenses = [licenses, ]

        for _license in licenses:
            license_param = self.LICENSES[_license]
            verify_dict[dist_name][license_param] = self.OPERATIONS[operation]
        try:
            self._verify_configuration_parameters_values(verify_dict, gnb_id, du_id)
        except IncorrectParameterValue:
            logging.info("Disabling feature licenses: {}".format(licenses))
            modify_dict = {
                'distName': dist_name,
                'operation': 'update',
                'parameters': []
            }
            for _license in licenses:
                license_param = self.LICENSES[_license]
                modify_dict['parameters'].append({
                    'operation': 'update',
                    'parameterName': license_param,
                    'value': self.OPERATIONS[operation]
                })
            self.perform_bts_delta_commissioning(delta=[modify_dict], skip_parameter_relation_errors=True,
                                                 bts_id=gnb_id, du_id=du_id)

    @login_logout
    def verify_multiband_operation_is_rejected(self, operation, gnb_id=0, du_id=0):
        """
        Try to set value of actDualSectorRu parameter and verify if it's failed.
        :param operation: enable or disable
        :param gnb_id: ID of gNB, default set to 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        try:
            dist_name = "MRBTS-{}/NRBTS-{}"
            self.perform_configuration_parameter_recommissioning(dist_name, "actDualSectorRu", "update",
                                                                 value=self.OPERATIONS[operation],
                                                                 skip_parameter_relation_errors=True, bts_id=gnb_id,
                                                                 du_id=du_id)
            raise UnexpectedWebemBehavior("Operation {} for multiband flag should be rejected but it has been "
                                          "executed".format(operation))
        except AdminApiProcedureFailureException:
            logging.info("Operation {} for multiband flag has been rejected".format(operation))
