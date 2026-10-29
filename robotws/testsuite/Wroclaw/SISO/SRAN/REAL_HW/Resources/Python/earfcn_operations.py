from robot.api import logger


class Band:
    def __init__(self,
                 id,
                 earfcn_dl_low,
                 earfcn_dl_high,
                 earfcn_ul_low=-1,
                 earfcn_ul_high=-1,
                 freq_dl_low=-1,
                 freq_ul_low=-1):
        self.id = id
        self.earfcn_dl_low = earfcn_dl_low
        self.earfcn_dl_high = earfcn_dl_high
        self.earfcn_ul_low = earfcn_ul_low
        self.earfcn_ul_high = earfcn_ul_high
        self.freq_dl_low = freq_dl_low
        self.freq_ul_low = freq_ul_low


class BandList(Band):
    def __init__(self):
        self.bandlist = []

    def __lshift__(self, band_object):
        self.bandlist.append(band_object)


def bands_info():
    bands = BandList()

#   FDD
    bands << Band(1, 0, 599, 18000, 18599, 2110, 1920)
    bands << Band(2, 600, 1199, 18600, 19199, 1930, 1850)
    bands << Band(3, 1200, 1949, 19200, 19949, 1805, 1710)
    bands << Band(4, 1950, 2399, 19950, 20399, 2110, 1710)
    bands << Band(5, 2400, 2649, 20400, 20649, 869, 824)
    bands << Band(6, 2650, 2749, 20650, 20749, 875, 830)
    bands << Band(7, 2750, 3449, 20750, 21449, 2620, 2500)
    bands << Band(8, 3450, 3799, 21450, 21799, 925, 880)
    bands << Band(9, 3800, 4149, 21800, 22149, 1844.9, 1749.9)
    bands << Band(10, 4150, 4749, 22150, 22749, 2110, 1710)
    bands << Band(11, 4750, 4949, 22750, 22949, 1475.9, 1427.9)
    bands << Band(12, 5010, 5179, 23010, 23179, 729, 699)
    bands << Band(13, 5180, 5279, 23180, 23279, 746, 777)
    bands << Band(14, 5280, 5379, 23280, 23379, 758, 788)
    bands << Band(17, 5730, 5849, 23730, 23849, 734, 704)
    bands << Band(18, 5850, 5999, 23850, 23999, 860, 815)
    bands << Band(19, 6000, 6149, 24000, 24149, 875, 830)
    bands << Band(20, 6150, 6449, 24150, 24449, 791, 832)
    bands << Band(24, 7700, 8039, 25700, 26039, 1525, 1626.5)
    bands << Band(25, 8040, 8689, 26040, 26689, 1930, 1850)
    bands << Band(26, 8690, 9039, 26690, 27039, 859, 814)
    bands << Band(27, 9040, 9209, 27040, 27209, 852, 807)
    bands << Band(28, 9210, 9659, 27210, 27659, 758, 703)
    bands << Band(29, 9660, 9769, freq_dl_low=717)
    bands << Band(30, 9770, 9869, 27660, 27710, 2350, 2305)
    bands << Band(31, 9870, 9919, 27760, 27785, 462.5, 452.5)
    bands << Band(32, 9920, 10359, freq_dl_low=1452)
    bands << Band(46, 46790, 53639, freq_dl_low=5150)
    bands << Band(66, 66436, 67335, 131972, 132671, 2110, 1710)
    bands << Band(70, 68336, 68585, 132972, 133121, 1995, 1695)
    bands << Band(71, 68586, 68935, 133122, 133471, 617, 663)
    bands << Band(72, 68936, 68985, 133472, 133521, 461, 451)
    bands << Band(85, 70366, 70545, 134002, 134181, 728, 698)
    bands << Band(111, 9660, 9769, 32111, 32160, 717, 1915)
    bands << Band(125, 130000, 130029, 195536, 195565, 2347, 2315)
    bands << Band(126, 130200, 130249, 195736, 195785, 420, 410)
#    bands << Band(222, 68336, 68585, 32111, 32160, 1995, 1915)

#   TDD
    bands << Band(34, 36200, 36349, freq_dl_low=2010)
    bands << Band(38, 37750, 38249, freq_dl_low=2570)
    bands << Band(39, 38250, 38649, freq_dl_low=1880)
    bands << Band(40, 38650, 39649, freq_dl_low=2300)
    bands << Band(41, 39650, 41589, freq_dl_low=2496)
    bands << Band(42, 41590, 43589, freq_dl_low=3400)
    bands << Band(43, 43590, 45589, freq_dl_low=3600)
    bands << Band(48, 55240, 56739, freq_dl_low=3550)

    return bands


def bands_info_listed():
    bands = bands_info()
    band_ids = []
    earfcn_dl_low = []
    earfcn_dl_high = []
    earfcn_ul_low = []
    earfcn_ul_high = []
    freq_dl_low = []
    freq_ul_low = []
    for band in bands.bandlist:
        band_ids.append(band.id)
        earfcn_dl_low.append(band.earfcn_dl_low)
        earfcn_dl_high.append(band.earfcn_dl_high)
        earfcn_ul_low.append(band.earfcn_ul_low)
        earfcn_ul_high.append(band.earfcn_ul_high)
        freq_dl_low.append(band.freq_dl_low)
        freq_ul_low.append(band.freq_ul_low)

    return band_ids, earfcn_dl_low, earfcn_dl_high, earfcn_ul_low, earfcn_ul_high, freq_dl_low, freq_ul_low


def convert_earfcn_to_mhz(earfcn):
    """
    :param earfcn: EARFCN
    :return: frequency in MHz
    variable prefixes:
    'e' - EARFCN
    'f' - frequency
    """
    earfcn = float(earfcn)
    band_ids, e_dl_low, e_dl_high, e_ul_low, e_ul_high, f_dl_low, f_ul_low = bands_info_listed()
    for i in range(len(band_ids)):
        if e_dl_low[i] <= earfcn <= e_dl_high[i]:
            logger.info("Downlink EARFCN found in band " + str(band_ids[i]))
            frequency = f_dl_low[i] + 0.1 * (earfcn - e_dl_low[i])
            break
        if i < len(e_ul_low):
            if e_ul_low[i] <= earfcn <= e_ul_high[i]:
                logger.info("Uplink EARFCN found in band " + str(band_ids[i]))
                frequency = f_ul_low[i] + 0.1 * (earfcn - e_ul_low[i])
                break
    else:
        raise KeyError("Invalid EARFCN")
    return frequency


def get_band_for_earfcn(earfcn):
    """
    :param earfcn:
    :return: band id
    variable prefixes:
    'e' - EARFCN
    'f' - frequency
    """
    earfcn = float(earfcn)
    band_ids, e_dl_low, e_dl_high, e_ul_low, e_ul_high, f_dl_low, f_ul_low = bands_info_listed()
    for i in range(len(band_ids)):
        if e_dl_low[i] <= earfcn <= e_dl_high[i]:
            return band_ids[i]
        if i < len(e_ul_low):
            if e_ul_low[i] <= earfcn <= e_ul_high[i]:
                return band_ids[i]
    else:
        raise KeyError("Invalid EARFCN")


def get_band_info(band_id, parameter):
    """
    :param band_id:
    :param parameter: choose between:
    earfcn_dl_low, earfcn_dl_high, earfcn_ul_low, earfcn_ul_high, freq_dl_low, freq_ul_low
    :return: parameter value for given band
    """
    bands = bands_info()
    for band in bands.bandlist:
        if band.id == band_id:
            return getattr(band, parameter)
