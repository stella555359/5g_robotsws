# -*- coding: utf-8 -*-
"""
2022/08/23 first version by @author: sheng.1.ye@nokia.com
    The InfoAPI class is a collection of API methods built on InfoParser
2022/09/14 add scf_get_nr_cell_info, by Ye Sheng
2023/04/10 add scf_get_tdd_frame_structure_type, by Ye Sheng
"""

import sys
import os
import re
import unittest
from operator import itemgetter

try:
    from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser, InfoReader
    from testsuite.Beijing.ET.common.resources.lib.logger_et import LoggingEt
except ModuleNotFoundError:
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from info_parser import InfoParser, InfoReader
    from logger_et import LoggingEt


class InvalidInfo:
    PCAP_FILE_UNAVAILABLE = "Pcap File unavailable"
    SCF_FILE_UNAVAILABLE = "Scf File unavailable"
    SCF_CELLGRP_UNAVAILABLE = "Scf Cell Group unavailable"
    SCF_CELL_UNAVAILABLE = "Scf Cell unavailable"
    SWCONFIG_FILE_UNAVAILABLE = "Swconfig file unavailable"
    UNSUPPORTED_FRAME_STRUCTURE = "Unsupported Frame Structure: {frame_structure}"


class Const:
    BWP_SIZE = 275
    CORESET0_SET_RB_MAP_TDD = [
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 1},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 3},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 1},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 3},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 14},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 14},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 16}
    ]
    CORESET0_SET_RB_MAP_FDD = [
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 3, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 3, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 96, 'Num of Symbol': 1, 'Offset': 38},
        {'CORESET multi pattern': 1, 'Num of RB': 96, 'Num of Symbol': 2, 'Offset': 38},
        {'CORESET multi pattern': 1, 'Num of RB': 96, 'Num of Symbol': 3, 'Offset': 38}
    ]
    CORESET0_SET_RB_MAP = {'TDD': CORESET0_SET_RB_MAP_TDD, 'FDD': CORESET0_SET_RB_MAP_FDD}

    FRAME_STRUCTURE_TO_INFO_MAP = {
        ('semiStatic', '1/4', None, None): {'I': 20, 'J': 16, 'FrameStructureTypeName': 'semiStatic_Ratio1_4'},
        ('semiStatic', '3/7', None, None): {'I': 20, 'J': 15, 'FrameStructureTypeName': 'semiStatic_Ratio3_7'},
        ('semiStatic', '4/6', None, None): {'I': 20, 'J': 16, 'FrameStructureTypeName': 'semiStatic_Ratio4_6'},
        ('tdLte', None, '0ms', None): {'I': 20, 'J': 18, 'FrameStructureTypeName': 'tdLte0ms'},
        ('tdLte', None, '3ms', 1): {'I': 20, 'J': 22, 'FrameStructureTypeName': 'tdLte3msCanadaBell'},
        ('tdLte', None, '3ms', None): {'I': 20, 'J': 15, 'FrameStructureTypeName': 'tdLte3ms'},
    }


class InfoAPI:
    def __init__(self, log_files=None):
        self.log_dict = self._classify_logs(log_files)
        self.parsers = {}

    @staticmethod
    def _classify_logs(log_files):
        log_dict = {}
        for log_file in log_files or []:
            log_type = InfoReader.get_file_type(log_file)
            log_dict.setdefault(log_type, []).append(log_file)
        return log_dict

    def get_parser(self, parser_type):
        if parser_type not in self.log_dict:
            return None
        parser = self.parsers.get(parser_type, None) or InfoParser(filename=self.log_dict[parser_type][0])
        self.parsers[parser_type] = parser
        return parser

    def scf_get_rb_start_and_size(self, bwp_type, cell=1):
        scf_parser = self.get_parser('scf')
        if scf_parser:
            cell_str = "MRBTS-1/NRBTS-1/NRCELL-%d" % cell
            scf_info = scf_parser.get_info(item_list=[cell_str + "->cellBwpList->bwpDN:[]",
                                                      cell_str + "->type0CoresetConfigurationIndex:",
                                                      cell_str + "->cellTechnology:",
                                                      cell_str + "->physCellId:"
                                                      ])
            for node in scf_info[0]['bwpDN']:
                item_to_check = ("bwpType:", "cRbSizeDl:", "cRbStartDl:", "cRbSizeUl:", "cRbStartUl:")
                item_list = [node + '->' + item for item in item_to_check]
                scf_config = scf_parser.get_info(item_list=item_list)
                if scf_config[0]['bwpType'] == bwp_type:
                    bwp_config = scf_config[0]
                    bwp_config.update(scf_info[0])
                    return self._convert_rb_size_and_start(bwp_config)
            return {}
        else:
            raise Exception(InvalidInfo.SCF_FILE_UNAVAILABLE)

    def scf_get_tdd_frame_structure_type(self, cell=1):
        scf_parser = self.get_parser('scf')
        if scf_parser:
            cell_str = "MRBTS-1/NRBTS-1/NRCELL-%d" % cell
            scf_info = scf_parser.get_info(item_list=[cell_str + "->tddFrameStructure->frameStructureType:",
                                                      cell_str + "->tddFrameStructure->ulDlDataSlotRatio:",
                                                      cell_str + "->lteToNrFrameShift:"
                                                      ])
            scf_info[0]['bellCanadaFrameType'] = self.swconfig_get_rd_parameter('0x58012b')
            self._update_tdd_frame_structure_info(scf_info[0])
            return scf_info[0]
        else:
            raise Exception(InvalidInfo.SCF_FILE_UNAVAILABLE)

    def _update_tdd_frame_structure_info(self, info):
        f = [info['frameStructureType'], info['ulDlDataSlotRatio'], info['lteToNrFrameShift'],
             info['bellCanadaFrameType']]
        for (frame_type, ratio, shift, bell), v in Const.FRAME_STRUCTURE_TO_INFO_MAP.items():
            if frame_type in (f[0], None) and ratio in (f[1], None) and shift in (f[2], None) and bell in (f[3], None):
                info.update(v)
                break
        else:
            raise Exception(InvalidInfo.UNSUPPORTED_FRAME_STRUCTURE.format(frame_structure=f))

    def _convert_rb_size_and_start(self, bwp_config):
        bwp_config.update(self._get_dl_rb_size_and_start(bwp_config))
        bwp_config.update(self._get_ul_rb_size_and_start(bwp_config))
        return bwp_config

    def _get_dl_rb_size_and_start(self, bwp_config):
        config = {'dl_rb_size': self._convert_rb_size(bwp_config['cRbSizeDl'], bwp_config),
                  'dl_rb_start': self._convert_rb_start(bwp_config['cRbStartDl'], bwp_config)}
        return config

    def _get_ul_rb_size_and_start(self, bwp_config):
        config = {'ul_rb_size': self._convert_rb_size(bwp_config['cRbSizeUl'], bwp_config),
                  'ul_rb_start': self._convert_rb_start(bwp_config['cRbStartUl'], bwp_config)}
        return config

    def _convert_rb_size(self, rb_size_str, bwp_config):
        if rb_size_str == 'allRb':
            return rb_size_str
        elif rb_size_str == 'sameAsDl':
            if 'dl_rb_size' in bwp_config or {}:
                return bwp_config['dl_rb_size']
            else:
                return rb_size_str
        elif rb_size_str == 'coreset0':
            coreset0_rb_size = self._get_coreset0_rb_size(bwp_config)
            return coreset0_rb_size
        else:
            m = re.match(r"n(\d+)$", rb_size_str)
            if m:
                return int(m.group(1))
            else:
                return rb_size_str

    def _convert_rb_start(self, rb_start_str, bwp_config):
        if rb_start_str == 'sameAsDl':
            if 'dl_rb_start' in (bwp_config or {}):
                return bwp_config['dl_rb_start']
            else:
                return rb_start_str
        elif rb_start_str == 'coreset0':
            coreset0_rb_start = self._get_coreset0_rb_start(bwp_config)
            return coreset0_rb_start
        else:
            m = re.match(r"crb(\d+)$", rb_start_str)
            if m:
                return int(m.group(1))
            else:
                return rb_start_str

    def _get_coreset0_rb_start(self, bwp_config):
        type0_coreset_config_index = bwp_config['type0CoresetConfigurationIndex']
        cell_technology = bwp_config['cellTechnology']
        phys_cell_id = bwp_config['physCellId']
        ssb_prb_offset = self.get_ssb_prb_offset_from_pcap(cell=phys_cell_id)
        return ssb_prb_offset - Const.CORESET0_SET_RB_MAP[cell_technology][type0_coreset_config_index]['Offset']

    def _get_coreset0_rb_size(self, bwp_config):
        type0_coreset_config_index = bwp_config['type0CoresetConfigurationIndex']
        cell_technology = bwp_config['cellTechnology']
        return Const.CORESET0_SET_RB_MAP[cell_technology][type0_coreset_config_index]['Num of RB']

    def get_ssb_prb_offset_from_pcap(self, cell):
        pcap_parser = self.get_parser('other')
        if pcap_parser:
            cell_setup_info = pcap_parser.get_info(item_list=["ssBlockPrbOffset:", "physCellId:"],
                                                   filter_pattern=r'itf_l2_ps_cell_cellsetupreq',
                                                   filter_expression='physCellId == %d' % cell)
            if cell_setup_info:
                return cell_setup_info[0].get("ssBlockPrbOffset", None)
            return None
        raise Exception(InvalidInfo.PCAP_FILE_UNAVAILABLE)

    def scf_get_nr_cell_info(self, cell_items=None, grp_items=None):
        cell_info = {}
        raw_cell_items = [i for i in cell_items or [] if i[0] == '=']
        raw_grp_items = [i for i in grp_items or [] if i[0] == '=']
        cell_items = [i for i in cell_items or [] if i[0] != '=']
        grp_items = [i for i in grp_items or [] if i[0] != '=']

        scf_parser = self.get_parser('scf')
        if not scf_parser:
            raise Exception(InvalidInfo.SCF_FILE_UNAVAILABLE)
        scf_info = scf_parser.get_info(item_list=['MRBTS-1/NRBTS-1/NRCELLGRP-[]'])
        if not scf_info:
            raise Exception(InvalidInfo.SCF_CELLGRP_UNAVAILABLE)
        group_list = scf_info[0]['MRBTS-1/NRBTS-1/NRCELLGRP-']
        for grp_id in group_list:
            scf_info = scf_parser.get_info(item_list=['MRBTS-1/NRBTS-1/NRCELLGRP-%d->nrCellList~[]' % grp_id])
            if scf_info:
                for cell in scf_info[0]['nrCellList~']:
                    cell_str = 'MRBTS-1/NRBTS-1/NRCELL-%d' % cell
                    grp_str = 'MRBTS-1/NRBTS-1/NRCELLGRP-%d' % grp_id
                    cells = [(cell_str + "->" + i).replace('->#', '') for i in (["physCellId:"] + (cell_items or []))]
                    grps = [(grp_str + "->" + i).replace('->#', '') for i in (grp_items or [])]
                    cell_info_parser = scf_parser.get_info(item_list=cells + grps + raw_cell_items + raw_grp_items)
                    if not cell_info_parser:
                        raise Exception(InvalidInfo.SCF_CELL_UNAVAILABLE)
                    cell_info[cell] = {'grp': grp_id}
                    cell_info[cell].update(cell_info_parser[0])
                    del cell_info[cell]['item_id']
                    del cell_info[cell]['match_id']
        if not cell_info:
            raise Exception(InvalidInfo.SCF_CELL_UNAVAILABLE)
        return cell_info

    def swconfig_get_rd_parameter(self, *args):
        swconfig_parser = self.get_parser('swconfig')
        if not swconfig_parser:
            raise Exception(InvalidInfo.SWCONFIG_FILE_UNAVAILABLE)
        return itemgetter(*args)(swconfig_parser.get_info(item_list=[*args])[0])


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
