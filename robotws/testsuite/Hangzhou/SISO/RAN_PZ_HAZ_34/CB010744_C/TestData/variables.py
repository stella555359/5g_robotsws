from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

frame_structure_list_100MHz_40MHz_40MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '16DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '250M',
        'dl_data_transfer': '1600M',
        'expect_ul_tput': '202',
        'expect_dl_tput': '1400'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '40',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '80M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '72',
        'expect_dl_tput': '488'
    },
    {
        'cellid': 3,
        'frame': '1116_0ms_GP1_A7',
        'band': '40',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '80M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '72',
        'expect_dl_tput': '488'
    },
]

frame_structure_list_100MHz_50MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '16DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '2500000',
        'dl_data_transfer': '1600M',
        'expect_ul_tput': '204',
        'expect_dl_tput': '1400'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '50',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '800000',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '75',
        'expect_dl_tput': '700'
    },
    {
        'cellid': 3,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '400000',
        'dl_data_transfer': '400M',
        'expect_ul_tput': '19',
        'expect_dl_tput': '230'
    },
]
