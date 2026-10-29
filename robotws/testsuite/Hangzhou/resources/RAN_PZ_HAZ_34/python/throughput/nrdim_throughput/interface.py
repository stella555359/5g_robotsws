# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
#### please notice
add expert correction, 27.4.2023
modify pucch correction, 9.11.2023
modify WA in set_parameter_in_expert for https://jiradc.ext.net.nokia.com/browse/REX-18184, 25.12.2023
####
"""

from taf.sw.nrdim import nrdim
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis import ScfAnalysis
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.pucch_configuration_calculator import calculate_cell_pucch
from robot.libraries.BuiltIn import BuiltIn
import logging

__all__ = ['get_theoretical_throughput']


class NrdimOperation(object):
    def __init__(self, scf_path, cell_id=1, calculator='peak'):
        self.scf_path = scf_path
        self.scf_analysis = ScfAnalysis()
        self.scf_analysis.setup(scf_path=self.scf_path)
        self.cell_id = cell_id
        self.calculator = calculator
        self.cell_distname = 'MRBTS-' + self.scf_analysis.mrbtsID + '/NRBTS-' + self.scf_analysis.nrbtsID + \
                             '/NRCELL-' + str(self.cell_id)
        self.cellgroup_distname = self.scf_analysis.get_cellgrp_distname_from_cell(cell_id=self.cell_id)
        self.nrdim = None
        self.nrdim_params = None

    def setup(self, url):
        self.nrdim = nrdim()
        self.nrdim.setup(scf_file_path=self.scf_path,
                         cell_distname=self.cell_distname,
                         cellgroup_distname=self.cellgroup_distname,
                         alias=self.calculator,
                         url=url)
        self.nrdim_params = self.nrdim.get_parameter(calculator=self.calculator)

    def set_parameter_in_pucch(self, pucchprb=None):
        longPucch = self.nrdim.get_parameter(name='longPucch', calculator=self.calculator)
        if longPucch == 1 and pucchprb is not None:
            # pucchprb set by given value
            self.nrdim.set_parameter(name='autoPRBforLongPUCCH', value=0, calculator=self.calculator)
            self.nrdim.set_parameter(name='pucchPrb', value=pucchprb, calculator=self.calculator)
            logging.info('Add WA, set autoPRBforLongPUCCH in [Parameters for PUCCH] to list index {}'.format(0))
            logging.info('Add WA, set pucchPrb in [Parameters for PUCCH] to list index {}'.format(pucchprb))

    def set_parameter_in_expert(self):
        # trsMCS should correct in nrdim for 2538, https://jiradc.ext.net.nokia.com/browse/REX-18184
        trsFDM = self.nrdim.get_parameter(name='trsFDM', calculator=self.calculator)
        freqRange = self.nrdim.get_parameter(name='freqRange', calculator=self.calculator)
        DLBandwidth = self.nrdim.get_parameter(name='DLBandwidth', calculator=self.calculator)
        trsRbAllocation = self.nrdim.get_parameter(name='trsRbAllocation', calculator=self.calculator)
        if freqRange == 0:
            self.nrdim.set_parameter(name='SslotMCS', value=29, calculator=self.calculator)
            logging.info('Add WA, set SslotMCS in [Parameters for Expert] to list index {}'.format(29))
        if freqRange == 0 and trsFDM == 1:
            if trsRbAllocation == 52 and DLBandwidth >= 5:
                trsMCS = 10
            else:
                trsMCS = 24
            self.nrdim.set_parameter(name='trsMCS', value=trsMCS, calculator=self.calculator)
            logging.info('Add WA, set trsMCS in [Parameters for Expert] to list index {}'.format(trsMCS))
        # fix initialCRbStartDl for NSA,  https://jiradc.ext.net.nokia.com/browse/LEOPARD-1186
        gNbCuType = self.nrdim.get_parameter(name='gNbCuType', calculator=self.calculator)
        if gNbCuType == 0:
            self.nrdim.set_parameter(name='initialCRbStartDl', value=1, calculator=self.calculator)
            logging.info('Add WA, set initialCRbStartDl in [Parameters for Expert] to list index {}'.format(1))

    def analysis_dl_layers(self):
        dlLayers = self.nrdim.get_parameter(name='dlLayers', calculator=self.calculator)
        if dlLayers == 4:
            dl_layer = dlLayers
        else:
            dl_layer = dlLayers + 1
        return dl_layer

    def analysis_ul_layers(self):
        ulLayers = self.nrdim.get_parameter(name='ulLayers', calculator=self.calculator)
        ul_layer = ulLayers + 1
        return ul_layer

    def read_theoretical_dl_and_ul(self):
        tp = self.nrdim.calculate_expected_throughput(calculator=self.calculator)
        peak_dl = tp['downlink']
        peak_ul = tp['uplink']
        return peak_dl, peak_ul

    def set_UEmaxDataCheck_parameter(self, value=0):
        if int(value) == 1:
            self.nrdim.set_parameter(name='UEmaxDataCheck', value=1, calculator=self.calculator)

    def set_extra_parameters(self, mod_params):
        if not mod_params:
            return
        for name, value in mod_params.items():
            self.nrdim.set_parameter(name=name, value=int(value), calculator=self.calculator)


def get_theoretical_throughput_from_nrdim(scf_path, cell_id, pucchprb=None, UEmaxData=0, mod_params=None):
    """
    get theoretical throughput(dl/ul) from nrdim
    :param scf_path: String: scf file path
    :param cell_id: String: cell id
    :param pucchprb: [optional]String: pucchPrb num, None is default means use nrdim calculate automatically.
    :param mod_params: Dictionary, can set all needed odify nrdimm parameters in this dictionary
    :return: theoretical_dl , theoretical_ul
    """
    BuiltIn().set_test_variable("${use_nrdim}", True)
    obj = NrdimOperation(scf_path=scf_path, cell_id=cell_id)
    local_nrdim_url_order_1 = 'http://10.57.195.99'
    local_nrdim_url_order_2 = 'http://10.183.70.247'
    logging.info('Please refer to document '
                 'https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId='
                 '1294474605#NRDIMinAutomation-HowtodebugNRDIMCommonKW?')
    for url in [local_nrdim_url_order_1, local_nrdim_url_order_2]:
        try:
            obj.setup(url=url)
            obj.set_parameter_in_pucch(pucchprb=pucchprb)
            obj.set_parameter_in_expert()
            obj.set_UEmaxDataCheck_parameter(value=UEmaxData)
            obj.set_extra_parameters(mod_params)
            theoretical_dl, theoretical_ul = obj.read_theoretical_dl_and_ul()
            dlLayers = obj.analysis_dl_layers()
            ulLayers = obj.analysis_ul_layers()
            return theoretical_dl, theoretical_ul, dlLayers, ulLayers
        except Exception as err:
            logging.exception(err)
            continue
    else:
        raise Exception("Can't get theoretical from any NRDIM server.")


def get_theoretical_throughput(scf_path, cell_id, ue_dl_layer=None, ue_ul_layer=None, branch=None, UEmaxData=0,
                               mod_params=None, **kwargs):
    """
    get theoretical throughput(dl/ul) from nrdim
    :param scf_path: String: scf file path
    :param cell_id: String: cell id
    :param ue_dl_layer: [optional]Int: ue capability of dl layer, None by default.
        when theoretical throughput need be only decided by NRDIM.
    :param ue_ul_layer: [optional]Int: ue capability of ul layer, None by default
        when theoretical throughput need be only decided by NRDIM.
    :param branch: [optional]String, branch version, e.g 23R4, 23R3, 23R2, 23R1, default use latest version 23R4.
    :param kwargs:
        pucchprb: [optional]int: pucchPrb num, None is default means use pucch excel calculate automatically.
    :param mod_params: Dictionary, can set all needed odify nrdimm parameters in this dictionary
    :return: new_theoretical_dl , new_theoretical_dl
    """

    pucchprb = kwargs.get("pucchprb", None)
    if pucchprb is None:
        pucchprb = calculate_pucchprb(scf_path, cell_id, branch)
        if pucchprb is None:
            logging.warn("calculated pucchprb with excel failed, set pucchprb None, use nrdim calcuating")

    theoretical_dl, theoretical_ul, dl_layer, ul_layer = get_theoretical_throughput_from_nrdim(
        scf_path=scf_path, cell_id=cell_id, pucchprb=pucchprb, UEmaxData=UEmaxData, mod_params=mod_params)
    if ue_dl_layer is not None and int(ue_dl_layer) < int(dl_layer):
        dl_ratio = dl_layer / ue_dl_layer
        theoretical_dl = theoretical_dl / dl_ratio
    if ue_ul_layer is not None and int(ue_ul_layer) < int(ul_layer):
        ul_ratio = ul_layer / ue_ul_layer
        theoretical_ul = theoretical_ul / ul_ratio
    return theoretical_dl, theoretical_ul


def calculate_pucchprb(scf_path, cell_id, branch):
    scf_analysis = ScfAnalysis()
    scf_analysis.setup(scf_path=scf_path)

    cell_distname = 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(scf_analysis.mrbtsID, scf_analysis.nrbtsID, cell_id)
    cellgroup_distname = scf_analysis.get_cellgrp_distname_from_cell(cell_id=cell_id)

    try:
        longpucch_sr, longpucch_harq, longpucch_total = calculate_cell_pucch(scf_file_path=scf_path,
                                                                             cell=cell_distname,
                                                                             cell_group=cellgroup_distname,
                                                                             branch=branch)

        actDynUlResAlloc = scf_analysis.get_actDynUlResAlloc_from_scf(cell_id)
    except Exception as err:
        logging.warn("calculating pucch prb failed, err={}, use default None for pucchprb".format(err))
        return None

    if actDynUlResAlloc.lower() == 'true':
        pucchprb = int(longpucch_sr) + int(longpucch_harq)
    else:
        pucchprb = int(longpucch_total)

    logging.info("calulated pucchprb={} with pucch configuration excel table".format(pucchprb))
    return pucchprb


# # Get theoretical tput example
# if __name__ == '__main__':
#     theoretical_dl, theoretical_ul = get_theoretical_throughput(
#         scf_path='/home/ute/robotws/commissionings/HGZ/7_5_UTE5G402T593/SCF_SBTS00.xml',
#         cell_id=1,
#     )
#     print(theoretical_dl, theoretical_ul)
