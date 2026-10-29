from decimal import Decimal

frequency_table = [
    (34, 36200, 36349, 2010),
    (38, 37750, 38249, 2570),
    (39, 38250, 38649, 1880),
    (40, 38650, 39649, 2300),
    (41, 39650, 41589, 2496),
    (42, 41590, 43589, 3400),
    (43, 43590, 45589, 3600),
    (48, 55240, 56739, 3550),
    (1, 0, 599, 0),
    (2, 600, 1199, 0),
    (3, 1200, 1949, 0),
    (4, 1950, 2399, 0),
    (5, 2400, 2649, 0),
    (6, 2650, 2749, 0),
    (7, 2750, 3449, 0),
    (8, 3450, 3799, 0),
    (9, 3800, 4149, 0),
    (10, 4150, 4749, 0),
    (11, 4750, 4949, 0),
    (12, 5010, 5179, 0),
    (13, 5180, 5279, 0),
    (14, 5280, 5379, 0),
    (17, 5730, 5849, 0),
    (18, 5850, 5999, 0),
    (20, 6150, 6449, 0),
    (21, 6450, 6559, 0),
    (22, 6600, 7399, 0),
    (23, 7500, 7699, 0),
    (24, 7700, 8039, 0),
    (25, 8040, 8689, 0),
    (28, 9210, 9559, 0),
    (29, 9600, 9769, 0),
    (66, 66436, 67335, 2110)
]


def get_band_with_earfcn(searfcn):
    earfcn = int(searfcn)
    for band, low, high, frequency in frequency_table:
        if low <= earfcn <= high:
            return band
    raise Exception('EARFCN %d is not a valid EARFCN!' % earfcn)


def change_earfcn_to_frequency(searfcn):
    earfcn = int(searfcn)
    for band, low, high, frequency in frequency_table:
        if low <= earfcn <= high:
            return Decimal(earfcn*0.1 - (low*0.1 - frequency)).quantize(Decimal("0.01"))
    raise Exception('EARFCN %d is not a valid EARFCN!' % earfcn)
