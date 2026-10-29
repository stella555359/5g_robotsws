# class ConfigurationError(Exception):
#    pass


class ConfigurationError(Exception):
    def __init__(self, message: str, details: str):
        super().__init__(message)
        self.details = details


class CoresetSizeAndOffset:
    def __init__(self, size, offset):
        self.size = size
        self.offset = offset


size_and_offset_lut = [
    [CoresetSizeAndOffset(24, 0), CoresetSizeAndOffset(24, 5), CoresetSizeAndOffset(48, 2), CoresetSizeAndOffset(24, 0),
     CoresetSizeAndOffset(48, 4), CoresetSizeAndOffset(24, 0), CoresetSizeAndOffset(48, 0), CoresetSizeAndOffset(24, 0),
     CoresetSizeAndOffset(96, 0), CoresetSizeAndOffset(48, 0)],
    [CoresetSizeAndOffset(24, 2), CoresetSizeAndOffset(24, 6), CoresetSizeAndOffset(48, 6), CoresetSizeAndOffset(24, 1),
     CoresetSizeAndOffset(48, 4), CoresetSizeAndOffset(24, 4), CoresetSizeAndOffset(48, 8), CoresetSizeAndOffset(24, 4),
     CoresetSizeAndOffset(96, 16), CoresetSizeAndOffset(48, 8)],
    [CoresetSizeAndOffset(24, 4), CoresetSizeAndOffset(24, 7), CoresetSizeAndOffset(48, 2), CoresetSizeAndOffset(24, 2),
     CoresetSizeAndOffset(48, 4), CoresetSizeAndOffset(24, 0), CoresetSizeAndOffset(48, 0),
     CoresetSizeAndOffset(48, 14), CoresetSizeAndOffset(96, 0), CoresetSizeAndOffset(48, 0)],
    [CoresetSizeAndOffset(24, 0), CoresetSizeAndOffset(24, 8), CoresetSizeAndOffset(48, 6), CoresetSizeAndOffset(24, 3),
     CoresetSizeAndOffset(96, 0), CoresetSizeAndOffset(24, 4), CoresetSizeAndOffset(48, 8),
     CoresetSizeAndOffset(48, 14), CoresetSizeAndOffset(96, 16), CoresetSizeAndOffset(48, 8)],
    [CoresetSizeAndOffset(24, 2), CoresetSizeAndOffset(24, 5), CoresetSizeAndOffset(48, 2), CoresetSizeAndOffset(24, 4),
     CoresetSizeAndOffset(96, 56), CoresetSizeAndOffset(48, 0), CoresetSizeAndOffset(48, 0), None, None, None],
    [CoresetSizeAndOffset(24, 4), CoresetSizeAndOffset(24, 6), CoresetSizeAndOffset(48, 6),
     CoresetSizeAndOffset(24, 0), CoresetSizeAndOffset(96, 0), CoresetSizeAndOffset(48, 28),
     CoresetSizeAndOffset(48, 8), None, None, None],
    [CoresetSizeAndOffset(48, 12), CoresetSizeAndOffset(24, 7), CoresetSizeAndOffset(96, 28),
     CoresetSizeAndOffset(24, 1), CoresetSizeAndOffset(96, 56), CoresetSizeAndOffset(48, 0),
     CoresetSizeAndOffset(96, 28), None, None, None],
    [CoresetSizeAndOffset(48, 16), CoresetSizeAndOffset(24, 8), CoresetSizeAndOffset(96, 28),
     CoresetSizeAndOffset(24, 2), CoresetSizeAndOffset(96, 0), CoresetSizeAndOffset(48, 28),
     CoresetSizeAndOffset(96, 28), None, None, None],
    [CoresetSizeAndOffset(48, 12), CoresetSizeAndOffset(48, 18), CoresetSizeAndOffset(96, 28),
     CoresetSizeAndOffset(24, 3), CoresetSizeAndOffset(96, 56), CoresetSizeAndOffset(48, 0), None, None, None, None],
    [CoresetSizeAndOffset(48, 16), CoresetSizeAndOffset(48, 20), None, CoresetSizeAndOffset(24, 4), None,
     CoresetSizeAndOffset(48, 28), None, None, None, None],
    [CoresetSizeAndOffset(48, 12), CoresetSizeAndOffset(48, 18), None, CoresetSizeAndOffset(48, 12),
     None, None, None, None, None, None],
    [CoresetSizeAndOffset(48, 16), CoresetSizeAndOffset(48, 20), None, CoresetSizeAndOffset(48, 14),
     None, None, None, None, None, None],
    [CoresetSizeAndOffset(96, 38), CoresetSizeAndOffset(48, 18), None, CoresetSizeAndOffset(48, 16),
     None, None, None, None, None, None],
    [CoresetSizeAndOffset(96, 38), CoresetSizeAndOffset(48, 20), None, CoresetSizeAndOffset(48, 12),
     None, None, None, None, None, None],
    [CoresetSizeAndOffset(96, 38), None, None, CoresetSizeAndOffset(48, 14), None, None, None, None, None, None],
    [None, None, None, CoresetSizeAndOffset(48, 16), None, None, None, None, None, None]
]


duration_lut = [
    [2, 2, 1, 2, 1, 2, 1, 2, 1, 1],
    [2, 2, 1, 2, 2, 2, 1, 2, 1, 1],
    [2, 2, 2, 2, 3, 3, 2, 1, 2, 2],
    [3, 2, 2, 2, 1, 3, 2, 2, 2, 2],
    [3, 3, 3, 2, 1, 1, 3, 2, None, 1],
    [3, 3, 3, 3, 2, 1, 3, 2, None, 1],
    [1, 3, 1, 3, 2, 2, 1, 2, None, 1],
    [1, 3, 2, 3, 3, 2, 2, 2, None, 1],
    [2, 1, 3, 3, 3, 3, 1, None, None, None],
    [2, 1, None, 3, None, 3, 1, None, None, None],
    [3, 2, None, 1, None, None, 1, None, None, None],
    [3, 2, None, 1, None, None, 1, None, None, None],
    [1, 3, None, 1, None, None, None, None, None, None],
    [2, 3, None, 2, None, None, None, None, None, None],
    [3, None, None, 2, None, None, None, None, None, None],
    [None, None, None, 2, None, None, None, None, None, None]
]


def lookup(scs_index, type0_coreset_configuration_index, lut, no_entry):
    if type0_coreset_configuration_index >= len(lut):
        # text = "Illegal value of type0CoresetConfigurationIndex. Please set type0CoresetConfigurationIndex to 0-15"
        # raise ConfigurationError(text)
        raise ConfigurationError("Illegal value of type0CoresetConfigurationIndex",
                                 "Please set type0CoresetConfigurationIndex to 0-15")
    entry = lut[type0_coreset_configuration_index][scs_index]
    if entry == no_entry:
        # text = "Too high type0CoresetConfigurationIndex for configured SCS & SSB_SCS pair. "
        # text = text + "Please reduce type0CoresetConfigurationIndex"
        # raise ConfigurationError(text)
        raise ConfigurationError("Too high type0CoresetConfigurationIndex for configured SCS & SSB_SCS pair",
                                 "Please reduce type0CoresetConfigurationIndex")
    return entry


class Types:
    class NRSCS:
        scs15 = 0
        scs30 = 1
        scs60 = 2
        scs120 = 3

    class SsbScs:
        khz15 = 0
        khz30 = 1
        khz120 = 2
        khz240 = 3

    class FreqBandIndicatorNR:
        n79 = 79


def calculate_lut_index(scs, ssb_scs, freq_band_indicator_nr):
    n79 = Types.FreqBandIndicatorNR.n79

    if ssb_scs == Types.SsbScs.khz15 and scs == Types.NRSCS.scs15:
        return 0
    if ssb_scs == Types.SsbScs.khz15 and scs == Types.NRSCS.scs30:
        return 1
    if ssb_scs == Types.SsbScs.khz30 and scs == Types.NRSCS.scs15:
        return 4 if freq_band_indicator_nr == n79 else 2
    if ssb_scs == Types.SsbScs.khz30 and scs == Types.NRSCS.scs30:
        return 5 if freq_band_indicator_nr == n79 else 3
    if ssb_scs == Types.SsbScs.khz120 and scs == Types.NRSCS.scs60:
        return 6
    if ssb_scs == Types.SsbScs.khz120 and scs == Types.NRSCS.scs120:
        return 7
    if ssb_scs == Types.SsbScs.khz240 and scs == Types.NRSCS.scs60:
        return 8
    if ssb_scs == Types.SsbScs.khz240 and scs == Types.NRSCS.scs120:
        return 9

    # raise ConfigurationError("Illegal SCS & SSB_SCS combination", "Please change either SCS or SSB_SCS")
    raise ConfigurationError("Illegal SCS & SSB_SCS combination", "Please change either SCS or SSB_SCS")


def additional_case(scs_common, ssb_scs):
    return scs_common == Types.NRSCS.scs60 and (ssb_scs == Types.SsbScs.khz15 or ssb_scs == Types.SsbScs.khz30)


def lookup_coreset_size_and_offset(type0_coreset_configuration_index, scs_common, ssb_scs, freq_band_indicator_nr, lut,
                                   no_entry):
    if additional_case(scs_common, ssb_scs):
        return CoresetSizeAndOffset(0, 0)

    scs_index = calculate_lut_index(scs_common, ssb_scs, freq_band_indicator_nr)
    return lookup(scs_index, type0_coreset_configuration_index, lut, no_entry)


def lookup_coreset_duration(type0_coreset_configuration_index, scs_common, ssb_scs, freq_band_indicator_nr, lut,
                            no_entry):
    if additional_case(scs_common, ssb_scs):
        return 0

    scs_index = calculate_lut_index(scs_common, ssb_scs, freq_band_indicator_nr)
    return lookup(scs_index, type0_coreset_configuration_index, lut, no_entry)
