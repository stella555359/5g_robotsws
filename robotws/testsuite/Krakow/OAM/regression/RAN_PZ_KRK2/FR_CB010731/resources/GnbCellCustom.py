# -*- coding: utf-8 -*-
"""
Author: Grzegorz Kaczor
"""
import logging
import shutil
import os

from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from taf.rfrl.bts.devices.generic_bts import login_logout, login_logout_GUI


OBJ_NR_CELL = 'NRCELL'
OBJ_LTE_CELL = 'LNCEL'
OBJ_ASIRMOD = 'ASIRMOD'
OBJ_ASIRMOD_RUNTIME = 'ASIRMOD_R'
OBJ_CELLS = (OBJ_NR_CELL, OBJ_LTE_CELL)
RAT_MAPPING = {
    OBJ_LTE_CELL: "LTE",
    OBJ_NR_CELL: "NR"
}


class GnbCellCustom(GnbCell):

    def __init__(self):
        super(GnbCellCustom, self).__init__()
        self.cells_info = []
        self.nbiot_cells_info = []

    @login_logout_GUI
    def block_cell_via_gui(self, cell_id=1, technology="NR", bts_id=0, du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.block_cell(cell_idx=cell_id, technology=technology, sbts=gui_alias)

    @login_logout_GUI
    def unblock_cell_via_gui(self, cell_id=1, technology="NR", bts_id=0, du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.unblock_cell(cell_idx=cell_id, technology=technology, sbts=gui_alias)

    @login_logout
    def block_all_lte_cells_via_gui(self, bts_id=0, du_id=0):
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, cell_type="lte")
        for cell_id in cell_ids:
            self.block_cell_via_gui(cell_id=cell_id, technology="LTE", bts_id=bts_id, du_id=du_id)

    @login_logout
    def unblock_all_lte_cells_via_gui(self, bts_id=0, du_id=0):
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, cell_type="lte")
        for cell_id in cell_ids:
            self.unblock_cell_via_gui(cell_id=cell_id, technology="LTE", bts_id=bts_id, du_id=du_id)

    @login_logout
    def block_all_nr_cells_via_gui(self, bts_id=0, du_id=0):
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, cell_type="nr")
        for cell_id in cell_ids:
            self.block_cell_via_gui(cell_id=cell_id, technology="NR", bts_id=bts_id, du_id=du_id)

    @login_logout
    def unblock_all_nr_cells_via_gui(self, bts_id=0, du_id=0):
        cell_ids = self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, cell_type="nr")
        for cell_id in cell_ids:
            self.unblock_cell_via_gui(cell_id=cell_id, technology="NR", bts_id=bts_id, du_id=du_id)

    @login_logout_GUI
    def perform_rf_diagnostic_test(self, output_dir, cells, bts_id=0, du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self._configure_rf_diagnostic_test(cells=cells, gui_alias=gui_alias)
        test_status = self._start_rf_diagnostic_test(gui_alias=gui_alias)
        if "Test completed" not in test_status:
            raise AssertionError(f"RF diagnostic test failed: {test_status}")
        self._validate_general_test_results(gui_alias=gui_alias)
        results_save_path = self._save_all_logs(gui_alias=gui_alias)
        self._move_rf_diagnostic_test_results(output_dir=output_dir, results_save_path=results_save_path, cells=cells)
        self.gui_coam.clear_finished_results(sbts=gui_alias)

    def _configure_rf_diagnostic_test(self, cells,  gui_alias):
        self.gui_coam.configure_rf_diagnostic_test(activate=False, cell=cells,
                                                   bts_thresholds=None, bands_thresholds=None, timeout=10,
                                                   sbts=gui_alias)

    def _start_rf_diagnostic_test(self, gui_alias):
        return self.gui_coam.start_rf_diagnostic_test(sbts=gui_alias, timeout=120)

    def _save_all_logs(self, gui_alias):
        file_path = self.gui_coam.save_all_results(sbts=gui_alias)
        if os.path.getsize(file_path) == 0:
            raise AssertionError(f"RF diagnostic test failed to save results in: {file_path}")
        return file_path

    def _validate_general_test_results(self, gui_alias, cell_id=None):
        general_result = self.gui_coam.get_general_test_information(cell_id=cell_id, sbts=gui_alias)
        logging.info(f"General result: {general_result}")
        for result in general_result:
            if result["Result"] != "success":
                raise AssertionError(f"RF diagnostic test failed when expected to pass: {general_result}")

    @staticmethod
    def _move_rf_diagnostic_test_results(output_dir, results_save_path, cells):
        output_path = os.path.join(output_dir, f"RF_diagnostic_test_{cells.replace(' ', '_')}.txt")
        logging.info(f"Moving RF diagnostic test results from: {results_save_path} to: {output_path}")
        shutil.move(src=results_save_path, dst=output_path)

    @login_logout_GUI
    def get_bts_cell_info(self, bts_id=0, du_id=0):
        gui_alias = self.gui_alias.format(bts_id, du_id)
        # check 5G cell and 4G cell
        rat_info = {}
        for cell_object_name in OBJ_CELLS:
            rat = RAT_MAPPING[cell_object_name]
            object_names = self.gui_coam.get_object_name_list(object_name=cell_object_name, sbts=gui_alias)
            for object_name in object_names:
                if object_name.split('-')[0] != cell_object_name:
                    logging.debug('Skip object name: {}'.format(object_name))
                    continue
                dn_list = self.gui_coam.get_dist_name_list_by_object_name(object_name=object_name, sbts=gui_alias)
                logging.debug('DN list: {}'.format(dn_list))
                for dn in dn_list:
                    cell_id = dn.split('-')[-1]
                    # global cell id/lcrid/target bts id
                    target_bts_id = dn.split('/')[1].split('-')[-1]
                    lcrid = self.gui_coam.get_parameter_value(
                        dist_name=dn, filter_param='Local cell resource ID', abbr='lcrid', sbts=gui_alias)
                    logging.debug('{}/lcrid: {}'.format(dn, lcrid))
                    cell_info = self.gui_coam.get_cell_info(cell_idx=int(cell_id), technology=rat, sbts=gui_alias)
                    logging.debug('Got Cell info: {}'.format(cell_info))
                    if '4x' in cell_info['Downlink MIMO mode']:
                        ant_channels = '4T4R'
                    elif '2x' in cell_info['Downlink MIMO mode']:
                        ant_channels = '2T2R'
                    elif rat == "LTE":
                        ant_channels = '2T2R'
                    else:
                        raise ValueError('Need define new ant_channels')
                    rat_info[dn] = {'lcrid': lcrid, 'cell_id': cell_id, 'tech': cell_info['Cell technology'],
                                    'cell_band': cell_info['Band'], 'ant_channels': ant_channels, 'rat': rat,
                                    'target_bts_id': target_bts_id
                                    }
        return rat_info

    def _teardown_browser(self, bts_id=0, du_id=0):
        super()._teardown_browser(bts_id=bts_id, du_id=du_id)
        try:
            self.gui_coam.disable_virtual_display()
        except Exception as e:
            logging.debug(f"Failed to disable virtual display: {e}")
        self.gui_coam = None
