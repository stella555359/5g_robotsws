from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

frame_structure_list_30MHz_40MHz = [
    {
        'cellid': 1,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '30',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 2,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '40',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]
