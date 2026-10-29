from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

frame_structure_list_80MHz_70MHz = [
    {
        'cellid': 3,
        'frame': '1116_0ms_GP1_A7',
        'band': '80',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '95M',
        'dl_data_transfer': '1200M',
        'expect_ul_tput': '90',
        'expect_dl_tput': '1100'
    },
    {
        'cellid': 5,
        'frame': '1116_0ms_GP1_A7',
        'band': '70',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '85M',
        'dl_data_transfer': '1100M',
        'expect_ul_tput': '80',
        'expect_dl_tput': '900'
    }
]

frame_structure_list_60MHz_60MHz = [
    {
        'cellid': 3,
        'frame': '1116_0ms_GP1_A7',
        'band': '60',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '71M',
        'dl_data_transfer': '1000M',
        'expect_ul_tput': '70',
        'expect_dl_tput': '800'
    },
    {
        'cellid': 5,
        'frame': '1116_0ms_GP1_A7',
        'band': '60',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '71M',
        'dl_data_transfer': '1000M',
        'expect_ul_tput': '70',
        'expect_dl_tput': '800'
    }
]
