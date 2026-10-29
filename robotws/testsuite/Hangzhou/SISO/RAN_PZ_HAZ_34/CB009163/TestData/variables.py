from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


frame_structure_list_100MHz_40MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '160M',
        'dl_data_transfer': '1600M',
        'expect_ul_tput': '125',
        'expect_dl_tput': '1300'
    },
    {
        'cellid': 4,
        'frame': '1116_0ms_GP1_A7',
        'band': '40',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '70M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '45',
        'expect_dl_tput': '500'
    },
    {
        'cellid': 7,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '50M',
        'dl_data_transfer': '500M',
        'expect_ul_tput': '20',
        'expect_dl_tput': '230'
    }
]
