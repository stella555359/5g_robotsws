"""
:copyright: Nokia Networks
:author: Rafal Janik
:contact: rafal.janik@nokia.com
:maintainer: I_EXT_5G_IV_WRO_OAM3_GMS

This module contains intermediate frequencies calculation.
"""

step = 99.96


def calculate_frequencies(low_carrier_freq, ssref=0, lowest_carrier_bw=100, highest_carrier_bw=100, cell_amount=1):
    """
    Based on 3GPP document 38.104

    :param low_carrier_freq: Uplink FRef min
    :param ssref: Frequency for SSB (SSRef)
    :param lowest_carrier_bw: Channel bandwidth
    :param highest_carrier_bw: Channel bandwidth
    :param cell_amount: Cell amount

    """
    lowest_carrier_bw_step = float(lowest_carrier_bw) * 47.52 / 50.0
    highest_carrier_bw_step = float(highest_carrier_bw) * 47.52 / 50.0

    band_low = float(low_carrier_freq) - lowest_carrier_bw_step / 2
    band_high = float(low_carrier_freq) + highest_carrier_bw_step / 2
    band_avg = (band_low + band_high) / 2
    if band_avg > 28800:
        signal_center = 28800
    elif band_avg < 27200:
        signal_center = 27200
    else:
        signal_center = band_avg
    am_lo = round(((signal_center - 4853.76) / 10.24), 0) * 10.24
    rf = float(low_carrier_freq) + (float(cell_amount) - 1.0) * step

    DL_CARRIER_FREQ = round((rf - am_lo) * 10, 2)
    UL_CARRIER_FREQ = round((rf - am_lo) * 10, 2)
    ABSOLUTE_FREQ_A = round((rf - am_lo - 47.52) * 10, 2)
    ABSOLUTE_FREQ_SSB = round((rf - am_lo - (signal_center - float(ssref))) * 10, 2)
    GNB_DL_CARRIER_FREQ = signal_center * 10

    return DL_CARRIER_FREQ, UL_CARRIER_FREQ, ABSOLUTE_FREQ_A, ABSOLUTE_FREQ_SSB, GNB_DL_CARRIER_FREQ
