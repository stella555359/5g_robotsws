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


class SrsResource:
    def __init__(self, freq_domain_position, freq_domain_shift, srs_values):
        self.freq_domain_position = freq_domain_position
        self.freq_domain_shift = freq_domain_shift
        self.srs_values = srs_values


class DssFreqHoppingSRSCalculator:
    @staticmethod
    def get_srs_values_for_long_pucch(long_pucch_num_pusch_prb_dedicated_bwp, is_fdd, l1_hw_variant,
                                      ch_bw, is_fr1):
        # Placeholder function to simulate the retrieval of SRS values
        # In actual implementation, this function would contain logic to get the SRS values
        return {'c_srs': 10, 'b_srs': 20}

    def get_srs_resource_for_long_pucch_with_dss(self, long_pucch_num_pusch_prb_dedicated_bwp,
                                                 offset_prb_ul, is_fdd, l1_hw_variant, ch_bw, is_fr1):
        freq_domain_position = int(math.floor(offset_prb_ul / 4))
        freq_domain_shift = offset_prb_ul % 4
        srs_values = self.get_srs_values_for_long_pucch(long_pucch_num_pusch_prb_dedicated_bwp,
                                                        is_fdd, l1_hw_variant, ch_bw, is_fr1)
        return SrsResource(freq_domain_position, freq_domain_shift, [srs_values['c_srs'], srs_values['b_srs']])


def main_test():
    # Example usage
    calculator = DssFreqHoppingSRSCalculator()
    nbr_of_blanked_prbs_low_edge_ul_scf = 0
    nbr_of_blanked_prbs_high_edge_ul_scf = 13
    # prach_prb_offset=StartUl+msg1FrequencyStart with cRbStartUl of bwpDN_init
    msg1frequencyStart = 11
    offset_prb_ul = msg1frequencyStart + nbr_of_blanked_prbs_low_edge_ul_scf
    srs_resource = calculator.get_srs_resource_for_long_pucch_with_dss(100, offset_prb_ul, True, 'variant', '15', True)
    print(f"Freq Domain Position: {srs_resource.freq_domain_position},"
          f" Freq Domain Shift: {srs_resource.freq_domain_shift}, SRS Values: {srs_resource.srs_values}")


def FreqHoppingSRS(nbr_of_blanked_prbs_low_edge_ul_scf=0,
                   nbr_of_blanked_prbs_high_edge_ul_scf=0,
                   ul_bandwidth=79,
                   msg1frequencyStart=11,
                   cRbStartUl=0):
    calculator = DssFreqHoppingSRSCalculator()
    # offset_prb_ul=StartUl+msg1FrequencyStart with cRbStartUl of bwpDN_init
    offset_prb_ul = int(msg1frequencyStart) + int(nbr_of_blanked_prbs_low_edge_ul_scf)
    srs_resource = calculator.get_srs_resource_for_long_pucch_with_dss(100, offset_prb_ul, True, 'variant', '15', True)
    print(f"Freq Domain Position: {srs_resource.freq_domain_position},"
          f" Freq Domain Shift: {srs_resource.freq_domain_shift}, SRS Values: {srs_resource.srs_values}")
    return srs_resource.freq_domain_position, srs_resource.freq_domain_shift


def main_test_for_robot():
    FreqHoppingSRS()


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    main_test()
    main_test_for_robot()
