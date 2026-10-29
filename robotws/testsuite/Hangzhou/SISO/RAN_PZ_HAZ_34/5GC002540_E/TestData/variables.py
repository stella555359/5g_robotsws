from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

frame_structure_list_90MHz = ['1070_GP1_A3']
frame_structure_list_50MHz = ['1116_3ms_GP1_A5']
frame_structure_list_20MHz = ['1116_0ms_GP2_A7']
frame_structure_list_40MHz = ['1208_GP1_A1']
frame_structure_list_60MHz = ['1116_3ms_GP1_B5']
frame_structure_list_80MHz = ['1116_3ms_GP1_A5']
frame_structure_list_100MHz = ['1116_0ms_GP1_A8']

frame_structure_list_20MHz_100MHz = [
    {
        'cellid': 1,
        'frame': ['1116_0ms_GP2_A7'],
        'band': '20',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    },
    {
        'cellid': 2,
        'frame': ['1208_GP1_A1'],
        'band': '100',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]

frame_structure_list_40MHz_50MHz = [
    {
        'cellid': 1,
        'frame': ['1116_0ms_GP2_A7'],
        'band': '20',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    },
    {
        'cellid': 2,
        'frame': ['1116_0ms_GP1_A8'],
        'band': '60',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]

rate_for_stream = {
    '20B': 'peak',
    '21A': '0.8',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}

rate_for_stream_min = {
    '20B': '0.8',
    '21A': '0.8',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}
