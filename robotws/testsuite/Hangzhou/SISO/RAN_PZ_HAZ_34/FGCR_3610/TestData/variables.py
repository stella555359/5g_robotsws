from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

frame_structure_list_80MHz = [
    {
        'cellid': 1,
        'frame': '1116_3ms_GP1_A5',
        'band': '80',
        'prach_index': '98',
        'beamset': 'single beam',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    },
    {
        'cellid': 2,
        'frame': '1116_3ms_GP1_A5',
        'band': '80',
        'prach_index': '98',
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
    }
]

frame_structure_list_50MHz = [
    {
        'cellid': 1,
        'frame': '1070_GP1_A3',
        'band': '50',
        'prach_index': '98',
        'beamset': 'single beam',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    },
    {
        'cellid': 2,
        'frame': '1070_GP1_A3',
        'band': '50',
        'prach_index': '98',
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
    }
]

frame_structure_list_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_3ms_GP1_A5',
        'band': '20',
        'prach_index': '98',
        'beamset': 'single beam',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    },
    {
        'cellid': 2,
        'frame': '1116_3ms_GP1_A5',
        'band': '20',
        'prach_index': '98',
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
    }
]
