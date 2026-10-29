# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import os
import shutil
from dynamic_pdcch import *
from modify_bsrs_csrs import *
from prach_frequency_start import *
from obtain_information import *
from configuration_automation import *
from taf.transport.ssh import ssh
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis import ScfAnalysis
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.throughput.nrdim_throughput.interface import *
from taf.rfrl.common_resources.python.common_utilities import get_builtin_value

__all__ = ['generate_real_peak_info', 'generate_real_modify_params_then_modify_scf',
           'get_start_traffic_information', 'get_verify_traffic_information',
           'get_ue_attached_cell_id_from_log', 'get_ue_index_list', 'get_ue_attached_cell_id_by_pci']


class ThroughputAnalysis(object):
    def __init__(self, cell_id, scf_path, ue_dl_layer=None, ue_ul_layer=None, avg_expect_rate=0.9, min_expect_rate=0.8,
                 duration=600, nband='n78', productName='ABIO AirScale Capacity', release='master'):
        self.cell_id = cell_id
        self.scf_path = scf_path
        self.scf_analysis = ScfAnalysis()
        self.scf_analysis.setup(scf_path=scf_path)
        self.ue_dl_layer = ue_dl_layer
        self.ue_ul_layer = ue_ul_layer
        self.nband = nband
        self.productName = productName
        self.avg_expect_rate = avg_expect_rate
        self.min_expect_rate = min_expect_rate
        self.duration = duration
        self.release = release
        self.peak_info = {}

    def get_peak_dl_ul(self):
        """
        long pucch and TDD use pucchprb calculate by
        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/scf/scf_calculater.py
        exercise caution when using this function.
        """
        if self.release == 'master':
            branch = None
        else:
            branch = re.search(r'SBTS(.*)', self.release).group(1)
            if branch in ['23R4', '23R3', '23R2', '23R1']:
                branch = branch
            else:
                branch = None
        peak_dl, peak_ul = get_theoretical_throughput(scf_path=self.scf_path, cell_id=self.cell_id,
                                                      ue_dl_layer=self.ue_dl_layer, ue_ul_layer=self.ue_ul_layer,
                                                      branch=branch)
        peak_dl_tp = round(peak_dl, 2)
        peak_ul_tp = round(peak_ul, 2)
        dl_send_tp, dl_exp_tput = str(round(peak_dl_tp * 1.25, 2)) + 'M', peak_dl_tp
        ul_send_tp, ul_exp_tput = str(round(peak_ul_tp * 1.5, 2)) + 'M', peak_ul_tp
        return dl_send_tp, dl_exp_tput, ul_send_tp, ul_exp_tput

    def generate_peak_info(self):
        dl_send_tp, dl_exp_tput, ul_send_tp, ul_exp_tput = self.get_peak_dl_ul()
        self.peak_info = {
            'dl_tp': dl_send_tp,
            'ul_tp': ul_send_tp,
            'dl_exp': dl_exp_tput,
            'ul_exp': ul_exp_tput,
            'peak_dl_tp': dl_exp_tput,
            'peak_ul_tp': ul_exp_tput,
            'avg_expect_rate': self.avg_expect_rate,
            'min_expect_rate': self.min_expect_rate,
            'duration': self.duration,
        }
        return self.peak_info


class BaseTddCellFrameStructure(object):
    cell_tdd_frame_structure = ''

    value = []

    @classmethod
    def generate_tdd_frame_structure_params(cls, dist_name, list_name):
        tdd_params = []
        tdd_params.append(dict(dist_name=dist_name, parameter=list_name, value=cls.value))
        return tdd_params


class TddCellFrameStructure1208GP1(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1208_GP1'

    value = {'frameStructureType': 'semiStatic', 'ulDlDataSlotRatio': '1/4',
             'guardPeriodLength': '2Symbols'}


class TddCellFrameStructure1208GP2(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1208_GP2'

    value = {'frameStructureType': 'semiStatic', 'ulDlDataSlotRatio': '1/4',
             'guardPeriodLength': '4Symbols'}


class TddCellFrameStructure1070GP1(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1070_GP1'

    value = {'frameStructureType': 'semiStatic', 'ulDlDataSlotRatio': '3/7',
             'guardPeriodLength': '2Symbols'}


class TddCellFrameStructure1070GP2(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1070_GP2'

    value = {'frameStructureType': 'semiStatic', 'ulDlDataSlotRatio': '3/7',
             'guardPeriodLength': '4Symbols'}


class TddCellFrameStructure11163msGP1(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1116_3ms_GP1'

    value = {'frameStructureType': 'tdLte',
             'guardPeriodLength': '4Symbols', 'tdLteUlDlConfig': 'tdLteConfig2', 'lteToNrFrameShift': '3ms'}


class TddCellFrameStructure11163msGP2(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1116_3ms_GP2'

    value = {'frameStructureType': 'tdLte',
             'guardPeriodLength': '6Symbols', 'tdLteUlDlConfig': 'tdLteConfig2', 'lteToNrFrameShift': '3ms'}


class TddCellFrameStructure11160msGP1(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1116_0ms_GP1'

    value = {'frameStructureType': 'tdLte',
             'guardPeriodLength': '4Symbols', 'tdLteUlDlConfig': 'tdLteConfig2', 'lteToNrFrameShift': '0ms'}


class TddCellFrameStructure11160msGP2(BaseTddCellFrameStructure):
    cell_tdd_frame_structure = '1116_0ms_GP2'

    value = {'frameStructureType': 'tdLte',
             'guardPeriodLength': '6Symbols', 'tdLteUlDlConfig': 'tdLteConfig2', 'lteToNrFrameShift': '0ms'}


class GenerateModifyParams(object):

    _SUPPORTED_FRAMESTRUCTURE = [TddCellFrameStructure1208GP1, TddCellFrameStructure1208GP2,
                                 TddCellFrameStructure1070GP1, TddCellFrameStructure1070GP2,
                                 TddCellFrameStructure11163msGP1, TddCellFrameStructure11163msGP2,
                                 TddCellFrameStructure11160msGP1, TddCellFrameStructure11160msGP2]

    def __init__(self, scf_path, cell_id, cell_band, cell_frame_structure, assembly_type):
        self.scf_analysis = ScfAnalysis()
        self.scf_analysis.setup(scf_path=scf_path)
        self.cell_id = str(cell_id)
        self.cell_band = str(cell_band)
        self.cell_frame_structure = cell_frame_structure
        self.assembly_type = assembly_type
        self.dist_name = ('MRBTS-' + self.scf_analysis.mrbtsID + '/NRBTS-' + self.scf_analysis.nrbtsID +
                          '/NRCELL-' + self.cell_id)
        self.dist_name_cellgrp = self.scf_analysis.get_cellgrp_distname_from_cell(cell_id=cell_id)
        self.list_name = 'tddFrameStructure'

    def generate_band_params(self):
        modify_params = []
        present_band = self.scf_analysis.get_band_from_scf(cell_id=self.cell_id)
        if str(present_band.strip()) != self.cell_band:
            value = (self.cell_band + ' MHz') if self.cell_band == '70' else (self.cell_band + 'MHz')
            modify_params.append(dict(dist_name=self.dist_name, parameter='chBw',  value=value))
            if self.cell_band == '20':
                # modify_params.append(dict(dist_name=self.dist_name, parameter='frequencyDensityThresNrb1',
                #                           value='277'))
                modify_params.append(dict(dist_name=self.dist_name, parameter='type0CoresetConfigurationIndex',
                                          value='10'))
                if (self.assembly_type is not None) and (self.assembly_type.upper() == 'CTA6'):
                    limitedBeamsPerStreamPerSlot = self.scf_analysis.get_limitedBeamsPerStreamPerSlot_from_scf(
                        cell_id=self.cell_id)
                    if limitedBeamsPerStreamPerSlot.lower() != 'none':
                        modify_params.append(dict(dist_name=self.dist_name, parameter='limitedBeamsPerStreamPerSlot',
                                                  value=True))
        return modify_params

    def generate_advance_offset(self):
        modify_params = []
        present_frame_structure = self.scf_analysis.get_frame_structure_from_scf(cell_id=self.cell_id)
        if str(present_frame_structure) != self.cell_frame_structure:
            if 'A' in self.cell_frame_structure:
                modify_params.append(dict(dist_name=self.dist_name, parameter='timingAdvanceOffset',
                                          value='n25600'))
            elif 'B' in self.cell_frame_structure:
                modify_params.append(dict(dist_name=self.dist_name, parameter='timingAdvanceOffset',
                                          value='n39936'))
        return modify_params

    def generate_tdd_frame_structure_params(self):
        modify_params = []
        present_frame_structure = self.scf_analysis.get_frame_structure_from_scf(cell_id=self.cell_id)
        if str(present_frame_structure) != self.cell_frame_structure:
            modify_params = (self._select_cell_frame_structure_class(self.cell_frame_structure)
                             .generate_tdd_frame_structure_params(self.dist_name, self.list_name))
        return modify_params

    def generate_prach_index_params(self, prach_index):
        modify_params = []
        present_prach_index = self.scf_analysis.get_prach_index_from_scf(cell_id=self.cell_id)
        if str(present_prach_index) != str(prach_index):
            modify_params.append(dict(dist_name=self.dist_name, parameter='prachConfigurationIndex',
                                      value=prach_index))
        return modify_params

    def generate_beamset_params(self, beamset_num, basicBeamSet):
        modify_params = []
        present_beamset_mum = self.scf_analysis.get_beamset_num_from_scf(cell_id=self.cell_id)
        present_basicBeamSet = self.scf_analysis.get_basicBeamSet_from_scf(cell_id=self.cell_id)
        if str(present_beamset_mum) != str(beamset_num) and str(present_basicBeamSet) != str(basicBeamSet):
            modify_params.append(dict(dist_name=self.dist_name_cellgrp, parameter='numberOfTransmittedSsBlocks',
                                      value=beamset_num))
            modify_params.append(dict(dist_name=self.dist_name, parameter='basicBeamSet',
                                      value=basicBeamSet))
        return modify_params

    def generate_dl_ul_layer_params(self, dl_ul_layer):
        modify_params = []
        present_dl_ul_layer = self.scf_analysis.get_nrcell_type_from_scf(cell_id=self.cell_id)
        if str(present_dl_ul_layer) != str(dl_ul_layer):
            if str(present_dl_ul_layer) == '4DL4UL' and str(dl_ul_layer) == '4DL2UL':
                pass
            else:
                raise Exception(
                    'expect present dl_ul_layer is ' + str(dl_ul_layer) + 'but ' + str(present_dl_ul_layer))
        return modify_params

    def generate_dl_modulation_params(self, dl_modulation):
        modify_params = []
        present_dl_modulation = self.scf_analysis.get_dl_modulation_from_scf(cell_id=self.cell_id)
        dl_modulation_256_enable = 'true' if dl_modulation == 'dl_256QAM' else 'false'
        if str(present_dl_modulation).lower() != dl_modulation_256_enable:
            modify_params.append(dict(dist_name=self.dist_name, parameter='actDl256Qam',
                                      value=dl_modulation_256_enable))
        return modify_params

    def generate_msg1frequencystart(self, msg1frequencystart):
        modify_params = []
        modify_params.append(dict(dist_name=self.dist_name, parameter='msg1FrequencyStart',
                                  value=msg1frequencystart))
        return modify_params

    def _select_cell_frame_structure_class(self, frame_structure):
        for supported_cell_frame_structure in self._SUPPORTED_FRAMESTRUCTURE:
            if supported_cell_frame_structure.cell_tdd_frame_structure in frame_structure:
                return supported_cell_frame_structure
        raise Exception('get TddCellFrameStructure failed')


class GenerateInformation(object):

    def __init__(self, scf_path, cell_id, band, frame_structure, save_path='SAVE LOG DIRECTORY',
                 connection='GNB_OAM', calculator='peak', release='master',
                 nband='n78', productName='ABIO AirScale Capacity', modify_msg1frequencystart=True,
                 **kwargs):
        self.cell_id = cell_id
        self.scf_path = scf_path
        self.scf_analysis = ScfAnalysis()
        self.scf_analysis.setup(scf_path=self.scf_path)
        self.band = str(band)
        self.frame_structure = str(frame_structure)
        self.dist_name = ('MRBTS-' + self.scf_analysis.mrbtsID +
                          '/NRBTS-' + self.scf_analysis.nrbtsID + '/NRCELL-' + str(self.cell_id))
        self.list_name = 'tddFrameStructure'
        self.modify_params = []
        self.expect_rate = 0.95
        self.duration = 600
        self.peak_info = {}
        (self.prach_index, self.beamset_num, self.basicBeamSet,
         self.dl_ul_layer, self.dl_modulation) = self.generate_default_arguments(**kwargs)
        self.save_path = save_path
        self.new_scf_path = self.genarate_new_scf_path()
        self.commission_flag = False
        self.connection = connection
        self.calculator = calculator
        self.release = release
        self.actUlSrsBm = self.scf_analysis.get_actUlSrsBm_from_scf(cell_id=self.cell_id)
        self.nband = nband
        self.productName = productName
        self.modify_msg1frequencystart = modify_msg1frequencystart
        self.assembly_type = kwargs["assembly_type"] if 'assembly_type' in kwargs else None

    def genarate_new_scf_path(self):
        scf_name = os.path.basename(self.scf_path)
        scf_name_1 = scf_name.strip('.xml')
        try:
            self.save_path = get_builtin_value(self.save_path)
        except BaseException:
            self.save_path = None
        new_scf_path = os.path.join(self.save_path, scf_name_1 + '_new.xml') if self.save_path is not None else \
            os.path.join(os.getcwd(), scf_name_1 + '_new.xml')
        return new_scf_path

    # kwargs: prach_index='97', beamset='2 beams', dl_ul_layer='4DL2UL', dl_modulation='dl_256QAM'
    def generate_default_arguments(self, **kwargs):
        frame_structure = self.frame_structure[:-3]
        key_list = kwargs.keys()
        old_beamset = self.scf_analysis.get_beamset_num_from_scf(cell_id=self.cell_id)
        old_basicBeamSet = self.scf_analysis.get_basicBeamSet_from_scf(cell_id=self.cell_id)
        old_dl_ul_layer = self.scf_analysis.get_nrcell_type_from_scf(cell_id=self.cell_id)
        old_dl_modulation = self.scf_analysis.get_dl_modulation_from_scf(cell_id=self.cell_id)
        old_dl_modulation = 'dl_256QAM' if old_dl_modulation.lower() == 'true' else 'dl_64QAM'
        prach_index = (kwargs['prach_index']
                       if 'prach_index' in key_list and kwargs['prach_index'] is not None
                       else '97' if '0ms' in frame_structure else '98')
        beamset = kwargs['beamset'] if 'beamset' in key_list and kwargs['beamset'] is not None else old_beamset
        basicBeamSet = (kwargs['basicBeamSet'] if 'basicBeamSet' in key_list and kwargs['basicBeamSet'] is not None
                        else old_basicBeamSet)
        dl_ul_layer = (kwargs['dl_ul_layer'] if 'dl_ul_layer' in key_list and kwargs['dl_ul_layer'] is not None
                       else old_dl_ul_layer)
        dl_modulation = (kwargs['dl_modulation'] if 'dl_modulation' in key_list and kwargs['dl_modulation'] is not None
                         else old_dl_modulation)
        return prach_index, beamset, basicBeamSet, dl_ul_layer, dl_modulation

    def generate_timeoffset(self):
        return []

    def generate_modify_params_then_modify_scf(self):
        if os.path.exists(self.new_scf_path):
            self.scf_analysis.scf.load_scf(self.new_scf_path)
        generate_modify_params = GenerateModifyParams(self.scf_path, self.cell_id, self.band,
                                                      self.frame_structure, self.assembly_type)
        self._modify_scf_element(generate_modify_params.generate_band_params())
        self._modify_scf_element(generate_modify_params.generate_advance_offset())
        self._modify_tdd_frame_structure_list(generate_modify_params.generate_tdd_frame_structure_params())
        self.scf_analysis.scf.save_scf(self.new_scf_path)
        if self.commission_flag:
            self._modify_scf_element(self.generate_timeoffset())
            self.scf_analysis.scf.save_scf(self.new_scf_path)
            package_version = coam.get_sw_version(connection=self.connection)
            if self.release >= 'SBTS24R1':
                new_file_path = generate_new_scf_via_configuration_automation(
                    scf_path=self.new_scf_path, package_version=package_version)
                os.remove(self.new_scf_path)
                shutil.move(new_file_path, self.new_scf_path)
                self.scf_analysis.scf.load_scf(self.new_scf_path)
            else:
                self._modify_scf_element(generate_modify_parameters_delta_file_new(
                    scf_path=self.scf_path, cell_id=self.cell_id, release=self.release,
                    cell_band=self.band, cell_frame_structure=self.frame_structure)
                )
                self.scf_analysis.scf.save_scf(self.new_scf_path)
            pucchModeSelect = self.scf_analysis.get_pucchModeSelect_from_scf(cell_id=self.cell_id)
            if pucchModeSelect.lower() == 'longpucch' and self.modify_msg1frequencystart:
                msg1frequencystart = calculate_msg1frequencystart(scf_path=self.new_scf_path,
                                                                  cell_id=self.cell_id,
                                                                  cell_band=self.band,
                                                                  cell_frame_structure=self.frame_structure,
                                                                  nband=self.nband,
                                                                  productName=self.productName,
                                                                  release=self.release)
                self._modify_scf_element(
                    generate_modify_params.generate_msg1frequencystart(msg1frequencystart=msg1frequencystart))
            if self.actUlSrsBm.lower() == 'true':
                self._modify_scf_element(generate_srs_modify_params(
                    cell_band=self.band, dist_name=self.dist_name, release=self.release))
        self._modify_scf_element(generate_modify_params.generate_prach_index_params(prach_index=self.prach_index))
        self._modify_scf_element(generate_modify_params.generate_beamset_params(
            beamset_num=self.beamset_num, basicBeamSet=self.basicBeamSet))
        self._modify_scf_element(generate_modify_params.generate_dl_ul_layer_params(dl_ul_layer=self.dl_ul_layer))
        self._modify_scf_element(generate_modify_params.generate_dl_modulation_params(
            dl_modulation=self.dl_modulation))
        self.scf_analysis.scf.save_scf(self.new_scf_path)

    def _modify_scf_element(self, modify_params):
        if modify_params:
            for param in modify_params:
                list_name = param['list_name'] if 'list_name' in param.keys() else None
                if 'index' in param.keys():
                    self.scf_analysis.scf.modify_scf_element(dist_name=param['dist_name'], list_name=list_name,
                                                             p_name=param['parameter'], value=param['value'],
                                                             index=param['index'])
                else:
                    self.scf_analysis.scf.modify_scf_element(dist_name=param['dist_name'], list_name=list_name,
                                                             p_name=param['parameter'], value=param['value'])
                self.commission_flag = True

    def _modify_tdd_frame_structure_list(self, modify_params):
        if modify_params:
            self.scf_analysis.scf.remove_list_from_scf(dist_name=self.dist_name, list_name=self.list_name)
            self.scf_analysis.scf.add_list_to_scf(dist_name=self.dist_name, list_name=self.list_name)
            for param in modify_params:
                self.scf_analysis.scf.add_item_to_list(
                    dist_name=self.dist_name, list_name=param['parameter'], elements=param['value'])
                self.commission_flag = True


class GenerateInformation20A(GenerateInformation):
    pass


class GenerateInformationOther(GenerateInformation):
    def generate_timeoffset(self):
        modify_params = []
        if '0ms' in self.frame_structure:
            modify_params.append(dict(dist_name=self.dist_name, parameter='lteToNrTimeOffset', value=0))
        elif '3ms' in self.frame_structure:
            modify_params.append(dict(dist_name=self.dist_name, parameter='lteToNrTimeOffset', value=30))
        return modify_params


def generate_real_modify_params_then_modify_scf(release, scf_path, cell_id, band, frame_structure, **kwargs):
    """
    generate recommission scf
    :param release: String: gnb software release, 20B/21A/master,...
    :param scf_path: String: scf file path
    :param cell_id: String: cell id
    :param band: String: cell band, 20/40/50,...
    :param frame_structure: String: cell frame structure, 1208_GP1_A1/1070_GP1_A3,...
    :param kwargs: dict: keys: prach_index/beamset/dl_ul_layer/dl_modulation
    :return: peak_info: , list_name
    """
    if release == '20A':
        object = GenerateInformation20A(scf_path, cell_id, band, frame_structure, release=release, **kwargs)
    else:
        object = GenerateInformationOther(scf_path, cell_id, band, frame_structure, release=release, **kwargs)
    object.generate_modify_params_then_modify_scf()
    return object.commission_flag, object.new_scf_path


def generate_real_peak_info(cell_id, scf_path, ue_dl_layer=4, ue_ul_layer=1, avg_expect_rate=0.9, min_expect_rate=0.8,
                            duration=600, nband='n78', productName='ABIO AirScale Capacity', release='master'):
    """
    get peak info via scf
    :param cell_id: String: cell id
    :param scf_path: String: scf file path
    :param ue_dl_layer: String: ue dl layer
    :param ue_ul_layer: String: ue ul layer
    :param avg_expect_rate: Int, tput avg check rate
    :param min_expect_rate: Int, tput min check rate
    :param duration: int: check tput duration
    :return: peak_info: dict
    """
    tput_analysis = ThroughputAnalysis(cell_id=cell_id, scf_path=scf_path, ue_dl_layer=ue_dl_layer,
                                       ue_ul_layer=ue_ul_layer, nband=nband,
                                       avg_expect_rate=avg_expect_rate, min_expect_rate=min_expect_rate,
                                       duration=duration, productName=productName, release=release)
    tput_analysis.generate_peak_info()
    peak_info = tput_analysis.peak_info
    return peak_info


def get_start_traffic_information(cell_id, ue_number, dl_tp='300M', ul_tp='100M', duration=600,
                                  cell_and_peak_info=None, check_wait_time=30):
    """
    get send dl/ul tput and traffic duration, from given data or peak information
    :param cell_id: String: cell id to get peak information dict
    :param ue_number: String or Int: ue number to start traffic
    :param dl_tp: String: given dl send tput
    :param ul_tp: String: given ul send tput
    :param duration: String: given duration to calculate traffic duration
    :param cell_and_peak_info: dict: cell and peak information dict
    :param check_wait_time: int: ignore time
    :return: real_dl_tp, real_ul_tp, real_traffic_duration
    """
    if cell_and_peak_info is not None:
        peak_info = cell_and_peak_info[str(cell_id)]
        real_dl_tp = peak_info['dl_tp']
        real_ul_tp = peak_info['ul_tp']
    else:
        real_dl_tp = dl_tp
        real_ul_tp = ul_tp
    real_traffic_duration = int(duration)
    real_traffic_duration = (real_traffic_duration + 1500 + int(check_wait_time)) * int(ue_number)
    return real_dl_tp, real_ul_tp, real_traffic_duration


def get_verify_traffic_information(cell_id, dl_exp=300, ul_exp=100, avg_expect_rate=0.9, min_expect_rate=0.8,
                                   duration=600, cell_and_peak_info=None):
    """
    get check dl/ul tput and duration, from given data or peak information
    :param cell_id: String: cell id to get peak information dict
    :param dl_exp: Number: given exp dl
    :param ul_exp: Number: given exp ul
    :param avg_expect_rate: Number: given actual rate
    :param min_expect_rate: Number: given min rate
    :param duration: Number: verify duration
    :param cell_and_peak_info: dict: cell and peak information dict
    :return: real_dl_exp, real_ul_exp, actual_rate, check_duration
    """
    if cell_and_peak_info is not None:
        peak_info = cell_and_peak_info[str(cell_id)]
        real_dl_exp = peak_info['dl_exp']
        real_ul_exp = peak_info['ul_exp']
        avg_expect = peak_info['avg_expect_rate']
        min_expect = peak_info['min_expect_rate']
        check_duration = peak_info['duration']
    else:
        real_dl_exp = dl_exp
        real_ul_exp = ul_exp
        avg_expect = avg_expect_rate
        min_expect = min_expect_rate
        check_duration = duration

    check_duration = int(check_duration)
    return real_dl_exp, real_ul_exp, avg_expect, min_expect, check_duration


def get_ue_attached_cell_id_from_log(log_path, alias='ASIK MASTER', connection='GNB_OAM'):
    """
    get Store UE information and get attached cell id
    :param log_path: String: log path on ASIK
    :param alias: String: alias to send command
    :param connection: String: admin connection
    :return: key
    """
    nrcell_cmd = 'cat ' + log_path + ' | grep -a "Store UE\\|Store SRB\\|Store DRB"'
    csn = ssh()
    output = csn.execute(command=nrcell_cmd, connection=alias, timeout=10)
    match = re.search(r'(?:nrCellIdentity|cellId|cellIdentity|nrCellId)\s?[=,:]\s?(\d+)', output)
    relation_mapping = get_relation_mapping_between_cell_index_and_nrCellIdentity(connection_alias=connection)
    for key, value in relation_mapping.items():
        nrCellIdentity = value['nrCellIdentity']
        if str(nrCellIdentity) == str(match.group(1)):
            return key
    raise Exception('get attached ue id failed!')


def get_ue_attached_cell_id_by_pci(pci, connection='GNB_OAM'):
    """
    get attached cell id via pci
    :param pci: Int: physical cell id
    :param connection: String: admin connection
    :return: key
    """
    relation_mapping = get_relation_mapping_between_cell_index_and_cell_info(connection_alias=connection)
    for key, value in relation_mapping.items():
        physicalCellId = value['physicalCellId']
        if str(physicalCellId) == str(pci):
            return key
    return None


def get_ue_index_list(testline_name, cell_list, used_ue_num, scf_path):
    """
    get ue index list
    :param cell_list: List: cell id list
    :param used_ue_num: Int: ue num to throughput
    :param scf_path: String: scf file path
    :return: ue_index_list
    """
    if len(cell_list) == 1:
        ue_num_for_call_per_cell = used_ue_num
    else:
        ue_num_for_call_per_cell = 1
    scf_analysis = ScfAnalysis()
    scf_analysis.setup(scf_path=scf_path)
    scf_name = os.path.basename(scf_path)
    ue_index_list = []
    call_cell_list = []
    for cell_id in cell_list:
        cell_network_type = scf_analysis.get_cell_network_type_from_scf(cell_id=cell_id)
        ue_sub_index_list = get_ue_for_cell_with_condition_from_ue_mapping_file(
            testline_name=testline_name, cell_id=cell_id, ue_num=ue_num_for_call_per_cell, scf_name=scf_name,
            mobile_network_system='NR', ext_ue_index_ist=ue_index_list, network_type=cell_network_type)
        if len(ue_sub_index_list) == 0:
            continue
        ue_index_list.extend(ue_sub_index_list)
        call_cell_list.append(cell_id)
        if len(ue_index_list) == int(used_ue_num):
            break
    return ue_index_list, call_cell_list
