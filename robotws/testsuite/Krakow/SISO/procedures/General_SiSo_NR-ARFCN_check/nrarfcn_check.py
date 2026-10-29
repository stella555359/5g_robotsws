# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: MN_RAN_PZ_KRK_TAG
:contact: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
:maintainer: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
"""

import logging
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from taf.rfrl.bts.tools.nrarfcn_calculator import NrarfcnCalculator, CalculatorResources
from taf.rfrl.bts.devices.exceptions import NrcellgrpNotFound


class NrarfcnCheck(GnbCell):
    """Custom Keywords for test case: General_SiSo_NR-ARFCN_check.robot """

    @login_logout
    def get_delta_commissioning_for_min_frequency(self, gnb_id=0, bandwidth=100, offset=5, du_id=0):
        """
        Prepare delta commissioning for all cells for minimum frequency
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param bandwidth: channel bandwidth related to radio unit
        :param offset:  offset in MHz added to bandwidth
        """
        ncc = NrarfcnCellConfigurator()
        return ncc.prepare_delta_for_all_cells(cell_obj=self, gnb_id=gnb_id, du_id=du_id, frequency_range='min',
                                               bandwidth=bandwidth, offset=offset)

    @login_logout
    def get_delta_commissioning_for_mid_frequency(self, gnb_id=0, bandwidth=100, offset=5, du_id=0):
        """
        Prepare delta commissioning for all cells for medium frequency
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param bandwidth: channel bandwidth related to radio unit
        :param offset:  offset in MHz added to bandwidth
        """
        ncc = NrarfcnCellConfigurator()
        return ncc.prepare_delta_for_all_cells(cell_obj=self, gnb_id=gnb_id, du_id=du_id, frequency_range='mid',
                                               bandwidth=bandwidth, offset=offset)

    @login_logout
    def get_delta_commissioning_for_max_frequency(self, gnb_id=0, bandwidth=100, offset=5, du_id=0):
        """
        Prepare delta commissioning for all cells for maximum frequency
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param bandwidth: channel bandwidth related to radio unit
        :param offset:  offset in MHz added to bandwidth
        """
        ncc = NrarfcnCellConfigurator()
        return ncc.prepare_delta_for_all_cells(cell_obj=self, gnb_id=gnb_id, du_id=du_id, frequency_range='max',
                                               bandwidth=bandwidth, offset=offset)


class NrarfcnCellConfigurator(object):
    """Class contains Cell keywords for NrarfcnCellConfigurator"""

    def get_min_frequency(self, band_number, bandwidth=100):
        """
        Get minimum frequecy for calculator
        :param band_number: related to radio unit ie. 257
        :param bandwidth: channel bandwidth related to radio unit
        """
        band = CalculatorResources.bands[str(band_number)]['frequency']
        start_freq = band['min'] + bandwidth / 2
        return start_freq

    def get_mid_frequency(self, cells_count, band_number, bandwidth=100, offset=5):
        """
        Get medium frequency for calculator
        :param cells_count: number of cells on radio
        :param band_number: related to radio unit ie. 257
        :param bandwidth: channel bandwidth related to radio unit
        :param offset:  offset in MHz added to bandwidth
        """
        band = CalculatorResources.bands[str(band_number)]['frequency']
        mid_freq = (band['min'] + band['max']) / 2
        mid_cel = int(cells_count / 2) + cells_count % 2
        start_freq = mid_freq - (bandwidth + offset) * (mid_cel - 1)
        return start_freq

    def get_max_frequency(self, cells_count, band_number, bandwidth=100, offset=5):
        """
        Get maximum frequency for calculator
        :param cells_count: number of cells on radio
        :param band_number: related to radio unit ie. 257
        :param bandwidth: channel bandwidth related to radio unit
        :param offset:  offset in MHz added to bandwidth
        """
        band = CalculatorResources.bands[str(band_number)]['frequency']
        start_freq = band['max'] - bandwidth / 2 - (bandwidth + offset) * (cells_count - 1)
        return start_freq

    def get_start_frequency(self, cells_count, band_number=257, bandwidth=100, offset=5, frequency_range='min'):
        """
        Get medium frequency for calculator
        :param cells_count: number of cells on radio
        :param band_number: related to radio unit ie. 257
        :param bandwidth: channel bandwidth related to radio unit
        :param offset:  offset in MHz added to bandwidth
        :param frequency_range: min mid or max
        """
        if frequency_range == 'min':
            return self.get_min_frequency(band_number, bandwidth)
        if frequency_range == 'mid':
            return self.get_mid_frequency(cells_count, band_number, bandwidth, offset)
        if frequency_range == 'max':
            return self.get_max_frequency(cells_count, band_number, bandwidth, offset)

    def prepare_delta_for_all_cells(self, cell_obj, gnb_id=0, frequency_range='min', bandwidth=100, offset=5, du_id=0):
        """
        :param cell_obj: object of gNB to use cell Class functions
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param frequency_range: min mid or max
        :param bandwidth:  channel bandwidth related to radio unit
        :param offset:  offset in MHz added to bandwidth
        """
        calc = NrarfcnCalculator()
        delta = []
        dist_name = cell_obj.adjust_dist_name("MRBTS-{}/NRBTS-{}", bts_id=gnb_id, du_id=du_id)
        cell_ids = cell_obj._get_all_global_cell_ids(bts_id=gnb_id, du_id=du_id)  # maybe _get_all_physical_cell_ids ?
        for index, cell_id in enumerate(cell_ids):
            cell_dist_name = "{}/NRCELL-{}".format(dist_name, cell_id)
            band, scs, scs_ssb, gscn_param_name = self.get_frequency_cell_parameters(cell_obj=cell_obj,
                                                                                     dist_name=dist_name,
                                                                                     cell_dist_name=cell_dist_name,
                                                                                     cell_id=cell_id,
                                                                                     gnb_id=gnb_id,
                                                                                     du_id=du_id)
            if index == 0:
                frequency = self.get_start_frequency(len(cell_ids), band, bandwidth, offset, frequency_range)

            gscn, nrarfcn = calc.get_aligned_gscn_and_nrarfcn(frequency, scs, scs_ssb)
            channel_bandwidth = "{}MHz".format(bandwidth)
            delta.append(self._prepare_delta_for_change_nrarfcn(cell_dist_name, nrarfcn, gscn,
                                                                bandwidth=channel_bandwidth,
                                                                gscn_parm_name=gscn_param_name))

            frequency = frequency + bandwidth + offset

        logging.debug("Calculated NRARFCN params for all cells: {}".format(delta))

        return delta

    def get_frequency_cell_parameters(self, cell_obj, dist_name, cell_dist_name, cell_id, gnb_id, du_id):
        """
        :param cell_obj: object of gNB to use cell Class functions
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param dist_name:   general dist name
        :param cell_dist_name:  new cell dist name
        :param cell_id: id of cell
        """
        nrcell_info = cell_obj._get_object_parameters_dict(dist_name=cell_dist_name, bts_id=gnb_id, du_id=du_id)
        band_id = nrcell_info["freqBandIndicatorNR"]
        scs_ssb = nrcell_info['ssbScs'].replace(' KHz', '')
        gscn_parameter_name = 'gscn' if 'gscn' in nrcell_info else 'gscnOrSsPbchArfcn'
        cell_groups_info = cell_obj._get_cell_groups_info(gnb_id, du_id)
        for cell_group_info in cell_groups_info:
            if "NRCELL-{}".format(cell_id) in cell_group_info["nrCellList"]:
                cell_group_name = cell_group_info["name"]
        if not cell_group_name:
            raise NrcellgrpNotFound("NRCELLGRP not found")
        scs_distname = "{}/{}".format(dist_name, cell_group_name)
        scs = cell_obj._get_object_parameters_dict(dist_name=scs_distname, bts_id=gnb_id, du_id=du_id)["scs"].\
            replace(' KHz', '')

        return band_id, scs, scs_ssb, gscn_parameter_name

    def _prepare_delta_for_change_nrarfcn(self, cell_dist_name, nrarfcn, gscn, bandwidth, gscn_parm_name):
        """
        Prepare dictionay to use in keyword Perform Delta Commissioning On gNB
        :param cell_dist_name: ie. MRBTS-10297/NRBTS-297/NRCELL-1
        :param nrarfcn: value or nrarfcn parameter
        :param gscn: value of gscn parameter
        :param bandwidth: value od chBw parameter
        :param gscn_parm_name: name of gscn param name: 'gscn' or 'gscnOrSsPbchArfcn'
        :return:
        """

        delta = {
            'distName': cell_dist_name,
            'operation': 'update',
            'parameters': [
                {
                    'operation': 'update',
                    'parameterName': 'nrarfcn',
                    'value': nrarfcn
                },
                {
                    'operation': 'update',
                    'parameterName': gscn_parm_name,
                    'value': gscn
                },
                {
                    'operation': 'update',
                    'parameterName': 'chBw',
                    'value': bandwidth
                }
            ]
        }
        return delta
