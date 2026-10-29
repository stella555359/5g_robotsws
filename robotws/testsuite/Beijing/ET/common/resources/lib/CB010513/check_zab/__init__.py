# -*- coding: utf-8 -*-
"""
2023/05/18 first version by sheng.1.ye@nokia-sbell.com
           this is checker to verify zab for CB10513E
2023/05/29 when zab_on or zab_off not exists, give warning only, by Ye Sheng
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker
import json


class InvalidInfo:
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"
    CELL_SETUP_REQ_NOT_FOUND = "itf_l2_ps_cell_cellsetupreq not found in C-BIP file"
    NOT_ALL_CELLS_HAS_TTIDL_INFO = "Only {cell_num} cells: {cells} has TTIDL info for ZAB"
    PHYSCELLID_NOT_FOUND = "PhysSellId {phys_cell_id} not found"


class WarningInfo:
    ZAB_ON_SLOTS_NOT_EXISTS = "Zab On slot not found for cell {cell}"
    ZAB_OFF_SLOTS_NOT_EXISTS = "Zab Off slot not found for cell {cell}"


class PassInfo:
    ZAB_ON_VALID_SLOTS_SHOULD_FOUND = ("zab on valid slots should found -- "
                                       "pooling_group_id={pooling_group_id}, zab on valid slots: {slots}")
    ZAB_OFF_INVALID_SLOTS_SHOULD_NOT_FOUND = ("zab off invalid slots should not found -- "
                                              "pooling_group_id={pooling_group_id}, zab off invalid slots: {slots}")


class CheckZab(Checker):

    def __init__(self, log_path, scf_file, cp_bip_file, swconfig_file, ttidl_file, scf_cells,
                 *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_cells = scf_cells
        self.scf_file = scf_file
        self.cp_bip_file = cp_bip_file
        self.swconfig_file = swconfig_file
        self.ttidl_file = ttidl_file
        self.info_api = None
        self.cell_info = None
        self.ttidl_info = None

        self.init_info()

    def init_info(self):
        self.init_info_api()
        self.init_cell_info_from_scf()
        self.init_cell_id_info()
        self.init_ttidl_info()

    def init_ttidl_info(self):
        ttidl_parser = InfoParser(filename=self.ttidl_file)
        ttidl_info = ttidl_parser.get_info(
            item_list=['type', '=20*(sfn%8)+slot as periodSlot', 'sfn', 'slot', 'rnti', 'physCellId',
                       'hasZabPrivilege'],
            filter_expression="type in ('dlAllocatedPooledResourcesData','dlFdSchedData')")
        self.ttidl_info = {}
        cell_zab = {}
        for item in ttidl_info:
            period_slot, phys_cell_id, zab = item['periodSlot'], item['physCellId'], item['hasZabPrivilege']
            zab = {'1.0': True, '0.0': False, '': None, 1: True, 0: False, None: None}[zab]
            if zab is not None:
                cell_zab[phys_cell_id] = zab
            if phys_cell_id in cell_zab and item['type'] != 'dlAllocatedPooledResourcesData':
                self.ttidl_info.setdefault(phys_cell_id, []).append([period_slot, cell_zab[phys_cell_id]])
        for k, v in self.ttidl_info.items():
            self.logger.debug("self.ttidl_info[%s], len=(%d), v=%s %s\n" % (k, len(v), v[:100],
                                                                            '...' if len(v) >= 100 else ''))
        if len(self.ttidl_info) < len(self.scf_cells):
            self.case_invalid(InvalidInfo.NOT_ALL_CELLS_HAS_TTIDL_INFO, cell_num=len(self.ttidl_info),
                              cells=list(self.ttidl_info.keys()))

    def init_info_api(self):
        self.info_api = InfoAPI(log_files=(self.scf_file, self.swconfig_file))

    def init_cell_info_from_scf(self):
        self.cell_info = self.info_api.scf_get_nr_cell_info()
        for cell in self.scf_cells:
            if cell not in self.cell_info:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=cell)
            self.cell_info[cell].update(self.info_api.scf_get_tdd_frame_structure_type(cell=cell))
        self.logger.debug("self.cell_info: %s" % json.dumps(self.cell_info, indent=4))

    def init_cell_id_info(self):
        cp_bip_parser = InfoParser(filename=self.cp_bip_file)
        cell_id_info = cp_bip_parser.get_info(item_list=['nrCellGrpId:', 'nrCellIdentity:', 'csirsPoolingGroupId:',
                                                         'dlSubcellId:[]', 'physCellId:'],
                                              filter_pattern='itf_l2_ps_cell_cellsetupreq')
        if cell_id_info:
            for item in cell_id_info:
                cell_group = item['nrCellGrpId']
                cell_id = item['nrCellIdentity']
                for info in self.cell_info.values():
                    if info['grp'] == cell_group:
                        info['cell_id'] = cell_id
                        info['csirsPoolingGroupId'] = item['csirsPoolingGroupId']
                        info['dlSubcellId'] = item['dlSubcellId']
                        info['physCellId'] = item['physCellId']
        else:
            self.case_invalid(InvalidInfo.CELL_SETUP_REQ_NOT_FOUND)
        self.logger.debug("cell_id_info: %s" % json.dumps(cell_id_info, indent=4))

    def get_stats_parameters(self):
        stats_param = []
        for cell in self.scf_cells:
            info = self.cell_info[cell]
            pooling_group_id = info['csirsPoolingGroupId']
            for item in ['zabon', 'zaboff']:
                stats_param.append(['cell%d(pooling_group%d)' % (cell, pooling_group_id), item])
        return stats_param

    def verify_ttidl_zab(self):
        for phys_cell_id, period_slot_info in self.ttidl_info.items():
            for cell, info in self.cell_info.items():
                if info['physCellId'] == phys_cell_id:
                    if cell in self.scf_cells:
                        i, j, pooling_group_id = info['I'], info['J'], info['csirsPoolingGroupId']
                        self.verify_zab_slot(cell, i, j, pooling_group_id, period_slot_info)
                    break
            else:
                self.case_invalid(InvalidInfo.PHYSCELLID_NOT_FOUND, phys_cell_id=phys_cell_id)

    def verify_zab_slot(self, cell, i, j, pooling_group_id, period_slot_info):
        zab_off_disallowed_slots = set()
        for group_id, n in enumerate((0, 40, 80)):
            zab_off_disallowed_slots |= {n + i, n + i + 1, n + j}
            if group_id != pooling_group_id:
                zab_off_disallowed_slots.add(n + j + 1)

        zab_on_real_slots = set(period_slot for period_slot, zab_on in period_slot_info if zab_on)
        zab_off_real_slots = set(period_slot for period_slot, zab_on in period_slot_info if not zab_on)
        zab_on_valid_slots = sorted(list(zab_on_real_slots & zab_off_disallowed_slots))
        zab_off_invalid_slots = sorted(list(zab_off_real_slots & zab_off_disallowed_slots))

        classify_cell = 'cell%d(pooling_group%d)' % (cell, pooling_group_id)
        if not zab_on_real_slots:
            self.case_warning(WarningInfo.ZAB_ON_SLOTS_NOT_EXISTS, cell=cell)
            self.assert_true('', True, classify=[classify_cell, 'zabon'], classify_value='Absent')
        else:
            self.assert_true(PassInfo.ZAB_ON_VALID_SLOTS_SHOULD_FOUND.format(pooling_group_id=pooling_group_id,
                                                                             slots=zab_on_valid_slots),
                             zab_on_valid_slots, classify=[classify_cell, 'zabon'],
                             classify_value=("%s in %s" % (zab_on_valid_slots, sorted(list(zab_off_disallowed_slots)))))

        if not zab_off_real_slots:
            self.case_warning(WarningInfo.ZAB_OFF_SLOTS_NOT_EXISTS, cell=cell)
            self.assert_true('', True, classify=[classify_cell, 'zaboff'], classify_value='Absent')
        else:
            self.assert_true(PassInfo.ZAB_OFF_INVALID_SLOTS_SHOULD_NOT_FOUND.format(pooling_group_id=pooling_group_id,
                                                                                    slots=zab_off_invalid_slots),
                             not zab_off_invalid_slots, classify=[classify_cell, 'zaboff'],
                             classify_value=("%s in %s" %
                                             (zab_off_invalid_slots, sorted(list(zab_off_disallowed_slots)))))

    def verify(self):
        self.verify_ttidl_zab()
        stats_param = self.get_stats_parameters()
        self.case_pass(stats_param=stats_param)


def verify_zab(log_path, scf_file, cp_bip_file, swconfig_file, ttidl_file,
               scf_cells=(1, 2, 3),
               log_level=None):
    checker = CheckZab(log_path, scf_file, cp_bip_file, swconfig_file,
                       ttidl_file, scf_cells=scf_cells, log_level=log_level)
    checker.create_robot_file()
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
