# -*- coding: utf-8 -*-
"""
Note: ues for tl687 60M case
"""
import importlib
import os
import re

from dynamic_pdcch import *
from modify_bsrs_csrs import *
from prach_frequency_start import *
from taf.transport.ssh import ssh
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis import ScfAnalysis
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_calculater import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.throughput.nrdim_throughput.interface import *
from taf.rfrl.common_resources.python.common_utilities import get_builtin_value


class TheoreticalThoughput():
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
        cellTechnology = self.scf_analysis.get_cellTechnology_from_scf(cell_id=self.cell_id)
        final_pucchprb = None
        if cellTechnology.lower() == 'tdd':
            _, final_pucchprb = calculate_pucchprb_tdd(
                scf_path=self.scf_path, cell_id=self.cell_id, nband=self.nband, productName=self.productName,
                release=self.release)
            print(
                "use pucchprb without nrdim auto, but calculate_pucchprb_tdd, get pucchprb is: {}".format(
                    final_pucchprb))
        final_pucchprb = 18
        print("final_pucchprb is:{}".format(final_pucchprb))
        peak_dl, peak_ul = get_theoretical_throughput(scf_path=self.scf_path, cell_id=self.cell_id,
                                                      pucchprb=final_pucchprb,
                                                      ue_dl_layer=self.ue_dl_layer, ue_ul_layer=self.ue_ul_layer)
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


def generate_real_peak_info_687(cell_id, scf_path, ue_dl_layer=4, ue_ul_layer=1, avg_expect_rate=0.9,
                                min_expect_rate=0.8, duration=600, nband='n78',
                                productName='ABIO AirScale Capacity', release='master'):
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
    tput_analysis = TheoreticalThoughput(cell_id=cell_id, scf_path=scf_path, ue_dl_layer=ue_dl_layer,
                                         ue_ul_layer=ue_ul_layer, nband=nband,
                                         avg_expect_rate=avg_expect_rate, min_expect_rate=min_expect_rate,
                                         duration=duration, productName=productName, release=release)
    tput_analysis.generate_peak_info()
    peak_info = tput_analysis.peak_info
    return peak_info
