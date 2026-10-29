# -*- coding: utf-8 -*

"""
:copyright: Nokia Networks
:author: Christophe SAMSON
:contact: christophe.samson@nokia.com
:maintainer:
:contact:
"""

import logging
import math


class DSS:
    def __init__(self, lte_dl_bandwidth, min_nr_dss_ratio, max_nr_dss_ratio, prbs_in_static_area):
        self._lte_dl_bandwidth = lte_dl_bandwidth
        self._min_nr_dss_ratio = min_nr_dss_ratio
        self._max_nr_dss_ratio = max_nr_dss_ratio
        self._lte_available_bw = 0
        self._min_max_ul_prb = {'min': 0, 'max': 0}
        self._prbs_in_static_area = int(prbs_in_static_area)

    def get_lte_dl_bandwidth(self):
        return self._lte_dl_bandwidth

    def get_lte_nr_dss_ul_ratio(self):
        return {'minNrDssRatio': self._min_nr_dss_ratio, 'maxNrDssRatio': self._max_nr_dss_ratio}

    def lte_available_bw(self):
        return self._lte_available_bw

    def set_lte_available_bw(self, value):
        self._lte_available_bw = value

    def min_max_ul_prb(self):
        return self._min_max_ul_prb

    def set_min_max_ul_prb(self, min_val, max_val):
        self._min_max_ul_prb['min'] = min_val
        self._min_max_ul_prb['max'] = max_val

    def prbs_in_static_area(self):
        return self._prbs_in_static_area


class UlSubcarrierErrorCaseChecker:
    '''
    checker for start_prb and amount_of_prb
    prach zone (prachoffset = msg1FrequencyStart) must be included in pusch prbArea
    '''
    @staticmethod
    def is_valid_start_prb(start_prb, cell_db):
        is_valid_start_prb = (
                    cell_db.rach_config().prach_prb_offset >= start_prb
                    >= cell_db.prb_blanking().nbr_of_blanked_prbs_low_edge_ul)
        if not is_valid_start_prb:
            print(
                f"start_prb {start_prb} is out of range against nbr_of_blanked_prbs_low_edge_ul or prach_prb_offset, "
                f"nbr_of_blanked_prbs_low_edge_ul={cell_db.prb_blanking().nbr_of_blanked_prbs_low_edge_ul}, "
                f"prach_prb_offset={cell_db.rach_config().prach_prb_offset}"
            )
        return is_valid_start_prb

    @staticmethod
    def is_min_amount_of_prb_valid(start_prb, amount_of_prb, cell_db, dss):
        is_min_amount_of_prb_valid = (
            amount_of_prb + start_prb >=
            cell_db.minimum_amount_of_prb_config().minimum_amount_of_prb + cell_db.rach_config().prach_prb_offset and
            amount_of_prb >= dss.prbs_in_static_area()
        )
        return is_min_amount_of_prb_valid

    @staticmethod
    def is_max_amount_of_prb_valid(amount_of_prb, cell_db):
        is_max_amount_of_prb_valid = amount_of_prb <= cell_db.ul_dedicated_bwp_size()
        return is_max_amount_of_prb_valid


def calculate_lte_prb_blanked(nbr_of_blanked_prbs_edge, ul_bandwidth, lte_dl_bandwidth):
    diff = ul_bandwidth - lte_dl_bandwidth
    lte_prb_blanked = 0
    if nbr_of_blanked_prbs_edge > (diff / 2):
        lte_prb_blanked = nbr_of_blanked_prbs_edge - (diff / 2)
    return lte_prb_blanked


def calculate_min_max_prb(min_ratio, max_ratio, lte_available_bw):
    min_ul_prb = math.ceil(min_ratio * lte_available_bw / 100.0)
    max_ul_prb = math.floor(max_ratio * lte_available_bw / 100.0)
    if min_ul_prb > max_ul_prb:
        min_ul_prb = max_ul_prb
    return min_ul_prb, max_ul_prb


def check_range(amount_of_prb, dss):
    is_in_range = (amount_of_prb <= dss.min_max_ul_prb()['max']) and (amount_of_prb >= dss.min_max_ul_prb()['min'])
    # PR523247
    if not is_in_range:
        print(
            f"AssignedPRB is out of range against minNrDssRatio or maxNrDssRatio, amountOfPrb={amount_of_prb}, "
            f"minUlPrb={dss.min_max_ul_prb()['min']}, maxUlPrb={dss.min_max_ul_prb()['max']}"
        )
    return is_in_range


class Cell:
    def __init__(self, dss,
                 nbr_of_blanked_prbs_low_edge_ul_scf,
                 nbr_of_blanked_prbs_high_edge_ul_scf,
                 prach_prb_offset,
                 minimum_amount_of_prb,
                 ul_dedicated_bwp_size):
        self._dss = dss
        self.nbr_of_blanked_prbs_low_edge_ul_scf = nbr_of_blanked_prbs_low_edge_ul_scf
        self.nbr_of_blanked_prbs_high_edge_ul_scf = nbr_of_blanked_prbs_high_edge_ul_scf
        self.prach_prb_offset = prach_prb_offset
        self.minimum_amount_of_prb = int(minimum_amount_of_prb)
        self._ul_dedicated_bwp_size = int(ul_dedicated_bwp_size)

    def calculate_lte_bw(self, ul_bandwidth):
        nbr_of_blanked_prbs_low_edge = self.nbr_of_blanked_prbs_low_edge_ul_scf
        nbr_of_blanked_prbs_high_edge = self.nbr_of_blanked_prbs_high_edge_ul_scf

        lte_prb_blanked_low = calculate_lte_prb_blanked(nbr_of_blanked_prbs_low_edge,
                                                        ul_bandwidth,
                                                        self._dss.get_lte_dl_bandwidth())
        lte_prb_blanked_high = calculate_lte_prb_blanked(nbr_of_blanked_prbs_high_edge,
                                                         ul_bandwidth,
                                                         self._dss.get_lte_dl_bandwidth())
        self._dss.set_lte_available_bw(self._dss.get_lte_dl_bandwidth() - (lte_prb_blanked_high + lte_prb_blanked_low))

    def set_min_max_ul_prb(self, ul_bandwidth):
        self.calculate_lte_bw(ul_bandwidth)
        min_max_ul_prb_pair = calculate_min_max_prb(
            self._dss.get_lte_nr_dss_ul_ratio()['minNrDssRatio'],
            self._dss.get_lte_nr_dss_ul_ratio()['maxNrDssRatio'],
            self._dss.lte_available_bw()
        )
        self._dss.set_min_max_ul_prb(min_max_ul_prb_pair[0], min_max_ul_prb_pair[1])

    def prb_blanking(self):
        ''' This method should return an object with attributes `nbr_of_blanked_prbs_low_edge_ul` and
         nbr_of_blanked_prbs_high_edge_ul`
        '''
        class PRBBlanking:
            def __init__(self, low_edge, high_edge):
                self.nbr_of_blanked_prbs_low_edge_ul = low_edge
                self.nbr_of_blanked_prbs_high_edge_ul = high_edge
        return PRBBlanking(self.nbr_of_blanked_prbs_low_edge_ul_scf, self.nbr_of_blanked_prbs_high_edge_ul_scf)

    def rach_config(self):
        class RachConfig:
            def __init__(self, prach_prb_offset):
                self.prach_prb_offset = prach_prb_offset
        return RachConfig(self.prach_prb_offset)

    def minimum_amount_of_prb_config(self):
        class MinAmountPrbConfig:
            def __init__(self, minimum_amount_of_prb):
                self.minimum_amount_of_prb = minimum_amount_of_prb
        return MinAmountPrbConfig(self.minimum_amount_of_prb)

    def ul_dedicated_bwp_size(self):
        return int(self._ul_dedicated_bwp_size)


def UlSubcarrierReqErrorCaseChecker(lte_dl_bandwidth=100,
                                    min_nr_dss_ratio=5,
                                    max_nr_dss_ratio=70,
                                    nbr_of_blanked_prbs_low_edge_ul_scf=13,
                                    nbr_of_blanked_prbs_high_edge_ul_scf=13,
                                    ul_bandwidth=106,
                                    msg1frequencyStart=19,
                                    cRbStartUl=0,
                                    ul_dedicated_bwp_size=80,
                                    prbs_in_static_area=6,
                                    start_prb=18,
                                    amount_of_prb=20):
    dss = DSS(lte_dl_bandwidth=int(lte_dl_bandwidth),
              min_nr_dss_ratio=int(min_nr_dss_ratio),
              max_nr_dss_ratio=int(max_nr_dss_ratio),
              prbs_in_static_area=int(prbs_in_static_area))
    # prach_prb_offset=StartUl+msg1FrequencyStart with cRbStartUl of bwpDN_init
    prach_prb_offset = int(msg1frequencyStart) + int(nbr_of_blanked_prbs_low_edge_ul_scf)
    cell = Cell(dss, nbr_of_blanked_prbs_low_edge_ul_scf=int(nbr_of_blanked_prbs_low_edge_ul_scf),
                nbr_of_blanked_prbs_high_edge_ul_scf=int(nbr_of_blanked_prbs_high_edge_ul_scf),
                prach_prb_offset=int(prach_prb_offset),
                minimum_amount_of_prb=6,
                ul_dedicated_bwp_size=int(ul_dedicated_bwp_size))
    cell.set_min_max_ul_prb(ul_bandwidth=int(ul_bandwidth))
    print(dss.min_max_ul_prb())

    checker = UlSubcarrierErrorCaseChecker()

    # Check if a start PRB is valid
    is_valid_start_prb = checker.is_valid_start_prb(int(start_prb), cell)
    print(f"is_valid_start_prb={is_valid_start_prb}")

    # Check if the amount of PRB is in range
    is_amount_of_prb_in_range = check_range(int(amount_of_prb), dss)

    is_min_amount_of_prb_valid = checker.is_min_amount_of_prb_valid(start_prb, amount_of_prb, cell, dss)
    print(f"is_min_amount_of_prb_valid={is_min_amount_of_prb_valid}")

    is_max_amount_of_prb_valid = checker.is_max_amount_of_prb_valid(amount_of_prb, cell)
    print(f"is_max_amount_of_prb_valid={is_max_amount_of_prb_valid}")

    return dss.min_max_ul_prb(), is_valid_start_prb, is_amount_of_prb_in_range, is_min_amount_of_prb_valid, \
        is_max_amount_of_prb_valid


def main_test():
    # Example usage
    dss = DSS(lte_dl_bandwidth=100, min_nr_dss_ratio=5, max_nr_dss_ratio=70, prbs_in_static_area=6)
    nbr_of_blanked_prbs_low_edge_ul_scf = 13
    nbr_of_blanked_prbs_high_edge_ul_scf = 13
    ul_dedicated_bwp_size = 80
    # prach_prb_offset=StartUl+msg1FrequencyStart with cRbStartUl of bwpDN_init
    msg1frequencyStart = 19
    prach_prb_offset = msg1frequencyStart + nbr_of_blanked_prbs_low_edge_ul_scf
    cell = Cell(dss, nbr_of_blanked_prbs_low_edge_ul_scf=nbr_of_blanked_prbs_low_edge_ul_scf,
                nbr_of_blanked_prbs_high_edge_ul_scf=nbr_of_blanked_prbs_high_edge_ul_scf,
                prach_prb_offset=prach_prb_offset,
                minimum_amount_of_prb=6,
                ul_dedicated_bwp_size=int(ul_dedicated_bwp_size))
    cell.set_min_max_ul_prb(ul_bandwidth=106)
    print(dss.min_max_ul_prb())

    checker = UlSubcarrierErrorCaseChecker()

    # Check if a start PRB is valid
    start_prb = 18
    print(f"is_valid_start_prb={checker.is_valid_start_prb(start_prb, cell)}")

    # Check if the amount of PRB is in range
    amount_of_prb = 20
    check_range(amount_of_prb, dss)

    is_min_amount_of_prb_valid = checker.is_min_amount_of_prb_valid(start_prb, amount_of_prb, cell, dss)
    print(f"is_min_amount_of_prb_valid={is_min_amount_of_prb_valid}")

    is_max_amount_of_prb_valid = checker.is_max_amount_of_prb_valid(amount_of_prb, cell)
    print(f"is_max_amount_of_prb_valid={is_max_amount_of_prb_valid}")


def main_test_for_robot():
    UlSubcarrierReqErrorCaseChecker()


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    main_test()
    main_test_for_robot()
