# -*- coding: utf-8 -*-
"""
2023/04/04 first version by sheng.1.ye@nokia-sbell.com
           this is checker to verify CSI-RS allocation for CB10513E
2023/05/08 fix subcell mapping to cell, only check csi_rs_send_req after user_modify, add stats check, by Ye Sheng
2023/05/19 improve to support verify only some of cells, by Ye Sheng
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker
import json
import copy


class Const:
    MAX_CSIRS_POOLING_GROUPS = 3
    CSIRS_SYMBOLS = {"RS1": [10, 11], "RS2": [12, 13], "RS4": [2, 3, 6, 7]}


class InvalidInfo:
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"
    CSI_RS_SEND_REQ_FOR_ACQ_NOT_FOUND = "dldata_csirssendreq with TrsInfo=False not found"

    RRC_SETUP_REQ_NOT_FOUND = "rrcSetupRequest not found"
    USER_SETUP_REQ_USER_MODIFY_REQ_NOT_FOUND = "itf_l2_ps_user_usersetupreq or usermodifyreq not found"
    RRC_SETUP_REQ_CSI_RS_RESOURCE_SET_NOT_FOUND = "CSI-RS Resource Set not found in rrcSetupRequest"
    RRC_SETUP_REQ_CSI_RS_RESOURCE_NOT_FOUND = "CSI-RS Resource not found in rrcSetupRequest"
    RRC_SETUP_REQ_CELL_ID_NOT_FOUND = "Cell {cell} in rrcSetupRequest not found in cellsetupreq"
    RRC_SETUP_REQ_NO_CELL_INFO = "Cell {cell} in scf not found in rrcSetupRequest"
    CELL_SETUP_REQ_NOT_FOUND = "itf_l2_ps_cell_cellsetupreq not found in C-BIP file"
    CELL_SETUP_RESP_NOT_FOUND = "itf_l2_ps_cell_cellsetupresp not found in C-BIP file"
    ACT_BB_POOL_EXTENSITION_TDD_FR1_IS_NOT_SET = "Rd Parameter actBbPoolExtensionTddFr1 is not set"


class FailInfo:
    CSIRS_RESOURCE_SLOT_OFFSET_UNMATCH = "Slot Offset in CsiRs Resource of {msg} unmatch(pooling_grp={pooling_grp})"
    CSIRS_RESOURCE_SYMBOL_UNMATCH = "Symbol in CsiRs Resource of {msg} unmatch(pooling_grp={pooling_grp})"

    UNEXPECTED_CSIRS_ACQ_SLOT_AND_SYMBOL = "Slot={slot}, Symbol={symbol} is not expected for ACQ for cell={cell}"
    RRC_SETUP_REQ_CSIRS_RESOURCE_ID_NOT_FOUND = "CsiRs Resource Id: {res_id} not found for cell: {cell}"

    CELL_SETUP_RESP_UNEXPECTED_CSIRS_RESOURCE_SET_NUMBER = "Unexpected CsiRs ResourceSet Number for cell={cell}"
    UNEXPECTED_SUB_CELL_ID_IN_CSIRS_SEND_REQ = "unexpected sub_cell_id{sub_cell} in CsiRsSendReq"


class PassInfo:
    EXPECTED_CSIRS_ACQ_SLOT_AND_SYMBOL = "[{msg}] Get Expected ACQ for cell={cell}: Slot={slot}, Symbol={symbol}"


class CheckCsiRsAllocation(Checker):

    def __init__(self, log_path, scf_file, cp_bip_file, bip_file, emil_file, swconfig_file, scf_cells,
                 *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_cells = scf_cells
        self.scf_file = scf_file
        self.cp_bip_file = cp_bip_file
        self.bip_file = bip_file
        self.emil_file = emil_file
        self.swconfig_file = swconfig_file
        self.info_api = None
        self.cell_info = None
        self.cp_bip_info = None
        self.csi_rs_send_req_info = None
        self.cell_setup_resp_info = None
        self.user_setup_req_user_modify_req_info = None
        self.rrc_setup_req_reconfig_req_info = None
        self.rd_parameters = None

        self.init_info()

    def init_info(self):
        self.init_info_api()
        self.init_rd_parameters()
        self.init_cell_info_from_scf()
        self.init_cell_setup_resp_info()
        self.init_user_setup_req_user_modify_req_info()
        self.init_csi_rs_send_req_info()
        self.init_rrc_setup_req_reconfig_req_info()

    def init_info_api(self):
        self.info_api = InfoAPI(log_files=(self.scf_file, self.swconfig_file))

    def init_rd_parameters(self):
        self.rd_parameters = {}
        self.rd_parameters['actBbPoolExtensionTddFr1'] = self.info_api.swconfig_get_rd_parameter('0x58070a')
        self.rd_parameters['bellCanadaFrameType'] = self.info_api.swconfig_get_rd_parameter('0x58012b')

    def init_cell_info_from_scf(self):
        self.cell_info = self.info_api.scf_get_nr_cell_info(
            cell_items=['actCellCsirsTddOnSsbBf:',
                        'actCellCsiRsImTddNonBf:',
                        'dlMimoMode:',
                        'csiReportPeriodicity:',
                        'csirsTrackingPeriod:',
                        'csirsNumberWithinReportPeriod_Set1:',
                        'maxCsirsNumber:',
                        '=int(csirsTrackingPeriod[:-2]) as csirsTrackingPeriod',
                        '=int(int(csiReportPeriodicity[5:])/(1<<(csirsNumberWithinReportPeriod_Set1-1))) '
                        'as csirsPeriodicity'],
            grp_items=["numberOfTransmittedSsBlocks:"])
        for cell in self.scf_cells:
            if cell not in self.cell_info:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=cell)
            self.cell_info[cell].update(self.info_api.scf_get_tdd_frame_structure_type(cell=cell))
        self.logger.debug("self.cell_info: %s" % json.dumps(self.cell_info, indent=4))

    def init_cell_setup_resp_info(self):
        cp_bip_parser = InfoParser(filename=self.cp_bip_file)
        self.init_cell_id_info(cp_bip_parser)

        cell_setup_resp_info = cp_bip_parser.get_info(
            item_list=['nrCellIdentity:',
                       r'resourceSet->resourceSet_item_(\d+)->res_item_(\d+)->slotOffset:',
                       r'resourceSet->resourceSet_item_(\d+)->res_item_(\d+)->startingSymbolIndex:'],
            filter_pattern='itf_l2_ps_cell_cellsetupresp')
        if not cell_setup_resp_info:
            self.case_invalid(InvalidInfo.CELL_SETUP_RESP_NOT_FOUND)
        self.cell_setup_resp_info = {}
        for item in cell_setup_resp_info:
            nr_cell_id = item['nrCellIdentity']
            self.cell_setup_resp_info[nr_cell_id] = item['group']
        self.logger.debug("cell_setup_resp_info: %s" % json.dumps(self.cell_setup_resp_info, indent=4))

    def init_user_setup_req_user_modify_req_info(self):
        cp_bip_parser = InfoParser(filename=self.cp_bip_file)
        user_setup_req_info = cp_bip_parser.get_info(
            item_list=['nrCellIdentity:',
                       r'Arrival Time',
                       r'(perCsiRsResConfig_item_\d+)->periodicity()',
                       r'(perCsiRsResConfig_item_\d+)->slotOffset:',
                       r'(perCsiRsResConfig_item_\d+)->startingSymbolIndex:'
                       ],
            filter_pattern='itf_l2_ps_user_usersetupreq|itf_l2_ps_user_usermodifyreq',
            filter_expression='nrCellIdentity is not None')
        if not user_setup_req_info:
            self.case_invalid(InvalidInfo.USER_SETUP_REQ_USER_MODIFY_REQ_NOT_FOUND)
        self.user_setup_req_user_modify_req_info = {}
        for item in user_setup_req_info:
            nr_cell_id = item['nrCellIdentity']
            self.user_setup_req_user_modify_req_info.setdefault(nr_cell_id, {}).update(item.get('group', {}))
            self.user_setup_req_user_modify_req_info[nr_cell_id]['time_ms'] = item['time_ms']
        self.logger.debug("user_setup_req_user_modify_req_info: %s"
                          % json.dumps(self.user_setup_req_user_modify_req_info, indent=4))

    def init_cell_id_info(self, cp_bip_parser):
        cell_id_info = cp_bip_parser.get_info(item_list=['nrCellGrpId:', 'nrCellIdentity:', 'csirsPoolingGroupId:',
                                              'dlSubcellId:[]'], filter_pattern='itf_l2_ps_cell_cellsetupreq')
        if cell_id_info:
            for item in cell_id_info:
                cell_group = item['nrCellGrpId']
                cell_id = item['nrCellIdentity']
                for info in self.cell_info.values():
                    if info['grp'] == cell_group:
                        info['cell_id'] = cell_id
                        info['csirsPoolingGroupId'] = item['csirsPoolingGroupId']
                        info['dlSubcellId'] = item['dlSubcellId']
        else:
            self.case_invalid(InvalidInfo.CELL_SETUP_REQ_NOT_FOUND)
        self.logger.debug("cell_id_info: %s" % json.dumps(cell_id_info, indent=4))

    def init_csi_rs_send_req_info(self):
        bip_parser = InfoParser(filename=self.bip_file)
        bip_info = bip_parser.get_info(
            item_list=["sfn:", "slot:", "subcellId:", "startSymbol:[]", "density:[]", "trsInfo:[]", "csiRsConfig:[]",
                       'Arrival Time'],
            filter_pattern='dldata_csirssendreq',
            filter_expression="'DISABLED' in trsInfo")
        if not bip_info:
            self.case_invalid(InvalidInfo.CSI_RS_SEND_REQ_FOR_ACQ_NOT_FOUND)
        self.csi_rs_send_req_info = bip_info
        self.logger.debug("csi_rs_send_req_info: %s" % json.dumps(self.csi_rs_send_req_info[:10], indent=4))

    def init_rrc_setup_req_reconfig_req_info(self):
        self.rrc_setup_req_reconfig_req_info = {}
        emil_parser = InfoParser(filename=self.emil_file)
        rrc_setup_cell_info = emil_parser.get_info(item_list=['scramblingID0', 'nRCellIdentity()'],
                                                   filter_pattern=r'rrcSetupRequest|rrcReconfiguration\b',
                                                   filter_expression='scramblingID0 is not None')
        if not rrc_setup_cell_info:
            self.case_invalid(InvalidInfo.RRC_SETUP_REQ_NOT_FOUND)
        for item in rrc_setup_cell_info:
            nr_cell_id = item['nRCellIdentity']
            scrambling_id = item['scramblingID0']
            match_cell = [cell for cell in self.cell_info if self.cell_info[cell]['cell_id'] == nr_cell_id]
            if not match_cell:
                match_cell = [cell for cell in self.cell_info
                              if self.cell_info[cell].get('scramblingID0', None) == scrambling_id]
            if match_cell:
                cell = match_cell[0]
                self.cell_info[cell]['scramblingID0'] = scrambling_id
                resource_set_info = self.rrc_setup_get_csi_rs_resource_set_info(item['item_id'], emil_parser)
                resource_info = self.rrc_setup_get_csi_rs_resource_info(item['item_id'], emil_parser)
                self.update_rrc_setup_req_reconfig_req_info(resource_set_info, resource_info, cell)
            else:
                self.case_invalid(InvalidInfo.RRC_SETUP_REQ_CELL_ID_NOT_FOUND, cell=nr_cell_id)
        self.logger.debug("rrc_setup_req_reconfig_req_info: %s"
                          % json.dumps(self.rrc_setup_req_reconfig_req_info, indent=4))

    def update_rrc_setup_req_reconfig_req_info(self, resource_set_info, resource_info, cell):
        cell_res_set_info = self.rrc_setup_req_reconfig_req_info.setdefault(cell, {})
        for res_set_id, res_set_info in resource_set_info.items():
            if res_set_info.get("trs-Info", False) != "true":
                cell_res_set_info[res_set_id] = res_set_info
        for set_id, set_info in self.rrc_setup_req_reconfig_req_info[cell].items():
            resource_id_list = set_info.get('nzp-CSI-RS-Resources', [])
            for n, res_id in enumerate(resource_id_list):
                if type(res_id) is int:
                    if res_id in resource_info:
                        resource_id_list[n] = resource_info[res_id]
                    else:
                        self.case_fail(FailInfo.RRC_SETUP_REQ_CSIRS_RESOURCE_ID_NOT_FOUND, cell=cell, res_id=res_id)

    def rrc_setup_get_csi_rs_resource_set_info(self, item_id, emil_parser):
        resource_set_prefix = r"nzp-CSI-RS-ResourceSetToAddModList->#(\d+)"
        resource_set_info = emil_parser.get_info(item_list=[resource_set_prefix + "->nzp-CSI-ResourceSetId",
                                                            resource_set_prefix + "->nzp-CSI-RS-Resources->[]",
                                                            resource_set_prefix + "->trs-Info"],
                                                 item_id_list=[item_id])
        if not resource_set_info:
            self.case_invalid(InvalidInfo.RRC_SETUP_REQ_CSI_RS_RESOURCE_SET_NOT_FOUND)
        group = resource_set_info[0].get('group', {})
        return {v['nzp-CSI-ResourceSetId']: v for v in group.values()}

    def rrc_setup_get_csi_rs_resource_info(self, item_id, emil_parser):
        resource_prefix = r"nzp-CSI-RS-ResourceToAddModList->#(\d+)"
        resource_info = emil_parser.get_info(
            item_list=[resource_prefix + "->nzp-CSI-RS-ResourceId",
                       resource_prefix + "->frequencyDomainAllocation find '[01]+'",
                       resource_prefix + "->nrofPorts",
                       resource_prefix + "->firstOFDMSymbolInTimeDomain",
                       resource_prefix + r"->periodicityAndOffset-> find \d+ as period",
                       resource_prefix + r"->periodicityAndOffset-> find \b\d+\b as offset"],
            item_id_list=[item_id])
        if not resource_info:
            self.case_invalid(InvalidInfo.RRC_SETUP_REQ_CSI_RS_RESOURCE_NOT_FOUND)
        group = resource_info[0].get('group', {})
        return {v['nzp-CSI-RS-ResourceId']: v for v in group.values()}

    def validate_rd_parameters(self):
        if not self.rd_parameters['actBbPoolExtensionTddFr1']:
            self.case_invalid(InvalidInfo.ACT_BB_POOL_EXTENSITION_TDD_FR1_IS_NOT_SET)

    def verify_cell_setup_resp(self):
        for nr_cell_id, resource_set in self.cell_setup_resp_info.items():
            cell, cell_info = [(cell, info) for cell, info in self.cell_info.items()
                               if info['cell_id'] == nr_cell_id][0]
            if cell in self.scf_cells:
                csirs_offsets = self.get_cell_specific_multi_set_csirs_offsets(cell_info)
                csirs_symbols = self.get_cell_specific_multi_set_csirs_start_symbols(cell_info)
                expected_max_csirs_number = cell_info['maxCsirsNumber'] or 1
                real_max_csirs_number = max(len(res) for res in resource_set.values())
                self.assert_equal("[CellSetupResp] csi rs resource number",
                                  expected_max_csirs_number, real_max_csirs_number,
                                  FailInfo.CELL_SETUP_RESP_UNEXPECTED_CSIRS_RESOURCE_SET_NUMBER.format(cell=nr_cell_id),
                                  classify=["cell%d" % cell, 'CellSetupResp', 'csi_rs_resource_num'])
                for res_set, res_set_info in resource_set.items():
                    res_set_id = {0: 'RS1', 1: 'RS2', 2: 'RS4'}[res_set]
                    expected_offset = csirs_offsets[res_set_id]
                    for res_id, res_info in res_set_info.items():
                        expected_symbol = csirs_symbols[res_set_id][res_id]
                        self.assert_equal('[CellSetupResp] slotOffset of csirs', expected_offset,
                                          res_info['slotOffset'],
                                          FailInfo.CSIRS_RESOURCE_SLOT_OFFSET_UNMATCH.format(
                                              msg='CellSetupResp', pooling_grp=cell_info['csirsPoolingGroupId']),
                                          classify=["cell%d" % cell, 'CellSetupResp', 'slotOffset'])
                        self.assert_equal('[CellSetupResp] symbol in csirs',
                                          expected_symbol, res_info['startingSymbolIndex'],
                                          FailInfo.CSIRS_RESOURCE_SYMBOL_UNMATCH.format(
                                              msg='CellSetupResp', pooling_grp=cell_info['csirsPoolingGroupId']),
                                          classify=["cell%d" % cell, 'CellSetupResp', 'symbol'])

    def verify_user_setup_req_user_modify_req_info(self):
        for nr_cell_id, alloc_info in self.user_setup_req_user_modify_req_info.items():
            cell, cell_info = [(cell, info) for cell, info in self.cell_info.items()
                               if info['cell_id'] == nr_cell_id][0]
            if cell in self.scf_cells:
                csirs_offsets = self.get_cell_specific_multi_set_csirs_offsets(cell_info)
                csirs_symbols = self.get_cell_specific_multi_set_csirs_start_symbols(cell_info)
                res_set_id = 'RS%d' % (len(alloc_info) - 1)
                cell_info["ue_res_set_id"] = res_set_id
                expected_offset = csirs_offsets[res_set_id]
                expected_periodicity = cell_info['csirsPeriodicity']
                for item, res_info in alloc_info.items():
                    if item == 'time_ms':
                        continue
                    self.assert_equal('[UserSetupReq] slotOffset', expected_offset, res_info['slotOffset'],
                                      FailInfo.CSIRS_RESOURCE_SLOT_OFFSET_UNMATCH.format(
                                          msg='UserSetupReq', pooling_grp=cell_info['csirsPoolingGroupId']),
                                      classify=["cell%d" % cell, 'userSetupReq', 'slotOffset'])
                    self.assert_true('[UserSetupReq] symbol',
                                     res_info['startingSymbolIndex'] in csirs_symbols[res_set_id],
                                     FailInfo.CSIRS_RESOURCE_SYMBOL_UNMATCH.format(
                                         msg='UserSetupReq', pooling_grp=cell_info['csirsPoolingGroupId']),
                                     classify=["cell%d" % cell, 'userSetupReq', 'startingSymbolIndex'],
                                     classify_value=res_info['startingSymbolIndex'])
                    self.assert_equal('[UserSetupReq] periodicity',
                                      expected_periodicity, res_info['periodicity'],
                                      FailInfo.CSIRS_RESOURCE_SYMBOL_UNMATCH.format(
                                          msg='UserSetupReq', pooling_grp=cell_info['csirsPoolingGroupId']),
                                      classify=["cell%d" % cell, 'userSetupReq', 'periodcity'])

    def verify_csi_rs_send_req(self):
        for item in self.csi_rs_send_req_info:
            # cell = item['subcellId'] // 2 + 1
            sub_cell = item['subcellId']
            for cell_id, info in self.cell_info.items():
                if sub_cell in info['dlSubcellId']:
                    cell = cell_id
                    nr_cell_id = info['cell_id']
                    break
            else:
                self.case_fail(FailInfo.UNEXPECTED_SUB_CELL_ID_IN_CSIRS_SEND_REQ, sub_cell=sub_cell)
                return
            if self.user_setup_req_user_modify_req_info[nr_cell_id]['time_ms'] > item['time_ms']:
                continue
            if cell in self.scf_cells:
                acq_period = self.cell_info[cell]['csirsPeriodicity']
                current_slot = ((item['sfn'] * 20) + item['slot']) % acq_period
                trs_info_list = item['trsInfo']
                start_symbol_list = item['startSymbol']
                for n, start_symbol in enumerate(start_symbol_list):
                    if trs_info_list[n] == 'DISABLED':
                        self.validate_csirs_acq_slot_and_symbol(current_slot, start_symbol, cell, msg='CsiRsSendReq')

    def validate_csirs_acq_slot_and_symbol(self, current_slot, current_symbol, cell, msg):
        cell_info = self.cell_info[cell]
        acq_offsets = self.get_cell_specific_multi_set_csirs_offsets(cell_info)
        acq_symbols = self.get_cell_specific_multi_set_csirs_symbols(cell_info)
        res_set_id = cell_info['ue_res_set_id']
        symbols = acq_symbols[res_set_id]
        expected_offset = acq_offsets[res_set_id]
        for expected_symbol in symbols:
            if expected_offset == current_slot and expected_symbol == current_symbol:
                self.assert_true(PassInfo.EXPECTED_CSIRS_ACQ_SLOT_AND_SYMBOL
                                 .format(msg=msg, slot=current_slot, symbol=current_symbol, cell=cell), True,
                                 classify=["cell%d" % cell, msg,  'slot, symbol'],
                                 classify_value=(current_slot, current_symbol))
                return
        self.case_fail(FailInfo.UNEXPECTED_CSIRS_ACQ_SLOT_AND_SYMBOL,
                       slot=current_slot, symbol=current_symbol, cell=cell)

    def verify_rrc_setup_req_reconfig_req(self):
        for cell in self.scf_cells:
            if cell not in self.rrc_setup_req_reconfig_req_info:
                self.case_invalid(InvalidInfo.RRC_SETUP_REQ_NO_CELL_INFO, cell=cell)
            self.validate_csi_rs_resource_info(self.rrc_setup_req_reconfig_req_info[cell], cell)

    def validate_csi_rs_resource_info(self, csi_rs_resource, cell):
        cell_info = self.cell_info[cell]
        for resource_set_info in csi_rs_resource.values():
            if resource_set_info.get("trs-Info", False) != "true":
                for resource in resource_set_info['nzp-CSI-RS-Resources']:
                    self.assert_equal('[RrcSetupReq/RrcReconfig] periodicity',
                                      cell_info['csirsPeriodicity'], resource['period'],
                                      FailInfo.CSIRS_RESOURCE_SYMBOL_UNMATCH.format(
                                          msg='RrcSetupReq/RrcReconfig', pooling_grp=cell_info['csirsPoolingGroupId']),
                                      classify=['cell%d' % cell, 'RrcSetupReq/RrcReconfig', 'period'])
                    offset = resource['offset']
                    symbol = resource['firstOFDMSymbolInTimeDomain']
                    self.validate_csirs_acq_slot_and_symbol(offset, symbol, cell, msg="RrcSetupReq/RrcReconfig")

    @staticmethod
    def get_cell_specific_multi_set_csirs_offsets(cell_info):
        csirs_offsets = {}
        slot_offsets = cell_info['I'], cell_info['I']+1, cell_info['J'], cell_info['J']+1
        csirs_acq_period = cell_info['csirsPeriodicity']
        csirs_pooling_group_id = cell_info['csirsPoolingGroupId']
        group_id_mod_max = csirs_pooling_group_id % Const.MAX_CSIRS_POOLING_GROUPS
        group_id_plus1_mod_max = (csirs_pooling_group_id + 1) % Const.MAX_CSIRS_POOLING_GROUPS
        group_id_plus2_mod_max = (csirs_pooling_group_id + 2) % Const.MAX_CSIRS_POOLING_GROUPS
        offset_group_id_mod_max = slot_offsets[group_id_mod_max]
        offset_group_id_plus1_mod_max = slot_offsets[group_id_plus1_mod_max]
        offset_group_id_plus2_mod_max = slot_offsets[group_id_plus2_mod_max]
        if csirs_acq_period == 40:
            csirs_offsets['RS1'] = offset_group_id_mod_max
            csirs_offsets['RS2'] = offset_group_id_plus1_mod_max
            csirs_offsets['RS4'] = offset_group_id_plus2_mod_max
        elif csirs_acq_period == 80:
            csirs_offsets['RS1'] = offset_group_id_mod_max + 40
            csirs_offsets['RS2'] = offset_group_id_plus1_mod_max + 40
            csirs_offsets['RS4'] = offset_group_id_plus2_mod_max
        elif csirs_acq_period in (160, 320):
            csirs_offsets['RS1'] = offset_group_id_mod_max + group_id_mod_max * 40
            csirs_offsets['RS2'] = offset_group_id_plus1_mod_max + group_id_plus1_mod_max * 40
            csirs_offsets['RS4'] = offset_group_id_plus2_mod_max + group_id_plus2_mod_max * 40
        if csirs_pooling_group_id == 2:
            csirs_offsets['RS1'], csirs_offsets['RS2'] = csirs_offsets['RS2'], csirs_offsets['RS1']
        return csirs_offsets

    @classmethod
    def get_cell_specific_multi_set_csirs_start_symbols(cls, cell_info):
        csirs_symbols = cls.get_cell_specific_multi_set_csirs_symbols(cell_info)
        csirs_symbols['RS2'][1] = csirs_symbols['RS2'][0]
        csirs_symbols['RS4'][1], csirs_symbols['RS4'][3] = csirs_symbols['RS4'][0], csirs_symbols['RS4'][2]
        return csirs_symbols

    @staticmethod
    def get_cell_specific_multi_set_csirs_symbols(cell_info):
        csirs_symbols = copy.deepcopy(Const.CSIRS_SYMBOLS)
        csirs_pooling_group_id = cell_info['csirsPoolingGroupId']
        if csirs_pooling_group_id == 2:
            csirs_symbols['RS1'], csirs_symbols['RS2'] = csirs_symbols['RS2'], csirs_symbols['RS1']
        if not cell_info['dlMimoMode'].startswith('8x4 Closed Loop'):
            csirs_symbols['RS1'] = csirs_symbols['RS1'][1:2]
        if cell_info['actCellCsirsTddOnSsbBf'] == 'true':
            csirs_symbols['RS4'][0:2], csirs_symbols['RS4'][2:4] = csirs_symbols['RS4'][2:4], csirs_symbols['RS4'][0:2]
        return csirs_symbols

    def get_stats_parameters(self):
        stats_param = []
        for cell in self.scf_cells:
            for item in ['CellSetupResp', 'userSetupReq', 'CsiRsSendReq', 'RrcSetupReq/RrcReconfig']:
                stats_param.append(['cell%d' % cell, item])
        return stats_param

    def verify(self):
        self.validate_rd_parameters()
        self.verify_cell_setup_resp()
        self.verify_user_setup_req_user_modify_req_info()
        self.verify_csi_rs_send_req()
        self.verify_rrc_setup_req_reconfig_req()
        stats_param = self.get_stats_parameters()
        self.case_pass(stats_param=stats_param)


def verify_csirs_allocation(log_path, scf_file, cp_bip_file, bip_file, emil_file, swconfig_file, scf_cells=(1, 2, 3),
                            log_level=None):
    checker = CheckCsiRsAllocation(log_path, scf_file, cp_bip_file, bip_file, emil_file, swconfig_file,
                                   scf_cells=scf_cells, log_level=log_level)
    checker.create_robot_file()
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
