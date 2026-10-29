"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
"""

import logging
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI, login_logout
from taf.rfrl.bts.devices.du.combined.cell_operations import GnbCombinedCellOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


class CustomCell(GnbCombinedCellOperations):

    @login_logout
    def add_new_cell_based_on_existing_cell_to_configuration_with_new_cell_group(self, cell_parameters,
                                                                                 cell_id_to_copy_from=143,
                                                                                 nrcell_include_subobject=True,
                                                                                 activate_plan_despite_errors=False,
                                                                                 group_id=144,
                                                                                 bts_id=0,
                                                                                 du_id=0,
                                                                                 power_group_id=1,
                                                                                 power_saving_cell_list=None):
        """
        Adds a new cell to configuration based on an existing cell
        [Support only NRCELL]

        :param cell_parameters:          dictionary containing values for mandatory parameters:
                                         lcrId, nrarfcn, gscn, physCellId
                                            example:
                                            cell_parameters =[{
                                                'lcrId': '4',
                                                'nrarfcn': '2103311',
                                                'gscn': '22558',
                                                'physCellId': '44'
                                            }]
        :param cell_id_to_copy_from:     id of cell that new cell will be based on
        :param group_id:                 group id of new cell
        :param nrcell_include_subobject: whether include subobjects when add NRCELL object
        :param activate_plan_despite_errors    activate plan despite errors when do activation, by default is False
        :param bts_id:                   gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        bts_build_raw = self.bbu.get_bts_sw_version(bts_id=bts_id, du_id=du_id)
        bts_build = SbtsSwVersion(bts_build_raw)
        release_24r2_or_newer = True if bts_build >= SbtsSwVersion('SBTS24R2_ENB_0000_000000_000000') else False

        cell_configuration = self.cell.copy_existing_cell_configuration(cell_parameters, group_id, bts_id, du_id)
        cell_groups = self.cell._get_all_cell_group_ids()
        logging.debug(f"New cell parameters: {cell_configuration}")
        self._add_new_cell_based_on_existing_cell_to_configuration_via_gui_with_new_cell_group(
            cell_id_to_copy_from,
            cell_configuration['cell_id'],
            cell_configuration['nrarfcn'],
            cell_configuration['gscn'],
            cell_configuration['physCellId'],
            cell_configuration['type0CoresetConfigurationIndex'],
            cell_configuration['maxNumScellsDl'],
            cell_configuration['dist_name'],
            cell_configuration['cell_dist_name'],
            cell_configuration['cell_group_dist_name'],
            cell_configuration['mrbts_id'],
            cell_configuration['cell_ids_in_group'],
            cell_groups,
            nrcell_include_subobject,
            activate_plan_despite_errors,
            bts_id,
            du_id,
            cell_configuration['gscn_filter_param'])

        if power_saving_cell_list:
            dist_name = self.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=bts_id, du_id=du_id)
            delta = [
                {
                    'distName': f'{dist_name}/NRPGRP-{power_group_id}',
                    'operation': 'update',
                    'parameters': [{
                        'operation': 'update',
                        'parameterName': 'lbpsCellList',
                        'value': power_saving_cell_list
                    }]
                }]

            cells_tdd = self.cell.get_tdd_cells_info(bts_id=bts_id, du_id=du_id)
            if release_24r2_or_newer and len(cells_tdd) >= 8 and len(
                    self.cell.get_all_cells_id(bts_id=bts_id, du_id=du_id)) == 8:
                delta.extend([
                    {
                        'distName': dist_name,
                        'operation': 'update',
                        'parameters': [{
                            'operation': 'update',
                            'parameterName': 'actFr2L2DlTdMetricPreCalc8CC',
                            'value': 'true'
                        }]
                    }])
            logging.debug(f'Adding cell to configuration - adjustment delta:\n{delta}')
            self.scf.perform_bts_delta_commissioning(delta=delta)

    @login_logout_GUI
    def _add_new_cell_based_on_existing_cell_to_configuration_via_gui_with_new_cell_group(
            self, cell_id_to_copy_from, cell_id, nrarfcn, gscn, physCellId, type0CoresetConfigurationIndex,
            maxNumScellsDl, dist_name, cell_dist_name, cell_group_dist_name, mrbts_id, cell_ids_in_group, cell_groups,
            nrcell_include_subobject=True, activate_plan_despite_errors=False, bts_id=0, du_id=0,
            gscn_filter_param='Global synchronization channel number'):
        """
        Adds a new cell to configuration based on an existing cell, using Selenium
        [Support only NRCELL]

        :param cell_id_to_copy_from:     id of cell that new cell will be based on
        :param cell_id:                  id of the new cell
        :param nrarfcn:                  value of nrarfcn parameter of new cell
        :param gscn:                     value of gscn parameter of new cell
        :param physCellId:               value of physCellId parameter of new cell
        :param type0CoresetConfigurationIndex: value of type0CoresetConfigurationIndex parameter of new cell
        :param maxNumScellsDl            new value of maxNumScellsDl
        :param dist_name:                general dist name
        :param cell_dist_name:           new cell dist name
        :param cell_group_dist_name:     cell group dist name
        :param mrbts_id:                 mrbts value
        :param cell_ids_in_group:        ids of cells in cell group
        :param nrcell_include_subobject: whether include subobjects when add NRCELL object
        :param activate_plan_despite_errors    activate plan despite errors when do activation, by default is False
        :param bts_id:                   gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='NRCELLGRP',
                                 id_value=cell_id,
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from=dist_name + '/NRCELLGRP-' + str(cell_id_to_copy_from),
                                 sbts=gui_alias)
        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='NRCELL',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from=dist_name + '/NRCELL-' + str(cell_id_to_copy_from),
                                 include_subobject=nrcell_include_subobject,
                                 id_value=cell_id,
                                 sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param='Local cell resource ID',
                                          new_value=cell_id,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param='NR Absolute radio frequency channel number',
                                          new_value=nrarfcn,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param=gscn_filter_param,
                                          new_value=gscn,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param='Physical cell identifier',
                                          new_value=physCellId,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=cell_dist_name,
                                          filter_param='Coreset configuration Index',
                                          new_value=type0CoresetConfigurationIndex,
                                          sbts=gui_alias)

        self.gui_coam.add_element(dist_name=dist_name + '/NRDU-1',
                                  filter_param='Reference to cell group',
                                  sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=dist_name + '/NRDU-1',
                                          filter_param='Reference to cell group',
                                          node_index=len(cell_groups),
                                          new_value=cell_id,
                                          sbts=gui_alias)
        self.gui_coam.set_parameter_value(dist_name=cell_group_dist_name,
                                          filter_param='List of NR cells assigned to cell group',
                                          node_index=len(cell_ids_in_group),
                                          new_value=cell_id,
                                          sbts=gui_alias)

        self.gui_coam.add_object(object_name='MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1',
                                 object_class_name='LCELNR',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from='MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-'
                                           + str(cell_id_to_copy_from),
                                 include_subobject=True,
                                 id_value=cell_id,
                                 sbts=gui_alias)

        if maxNumScellsDl is not None:
            self.gui_coam.set_parameter_value(dist_name=dist_name,
                                              filter_param='Maximum number of secondary cells for '
                                                           'DL carrier aggregation',
                                              new_value=maxNumScellsDl,
                                              sbts=gui_alias)
        else:
            logging.debug("Setup does not contain maxNumScellsDl parameter, skipping setting it")

        self.gui_coam.validate_plan(sbts=gui_alias)
        self.gui_coam.activate_plan(activate_plan_despite_errors=activate_plan_despite_errors, sbts=gui_alias)
