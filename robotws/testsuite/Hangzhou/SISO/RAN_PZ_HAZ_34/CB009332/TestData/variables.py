from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

frame_structure_list_100MHz_30MHz_20MHz = [
    {
        'cellid': 3,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '130M',
        'dl_data_transfer': '1600M',
        'expect_ul_tput': '125',
        'expect_dl_tput': '1300'
    },
    {
        'cellid': 5,
        'frame': '1116_0ms_GP1_A7',
        'band': '30',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '40M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '36',
        'expect_dl_tput': '400'
    },
    {
        'cellid': 6,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '30M',
        'dl_data_transfer': '500M',
        'expect_ul_tput': '19',
        'expect_dl_tput': '260'
    }
]

frame_structure_list_40MHz_30MHz_20MHz = [
    {
        'cellid': 3,
        'frame': '1116_0ms_GP1_A7',
        'band': '40',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '130M',
        'dl_data_transfer': '1600M',
        'expect_ul_tput': '46',
        'expect_dl_tput': '550'
    },
    {
        'cellid': 5,
        'frame': '1116_0ms_GP1_A7',
        'band': '30',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '40M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '36',
        'expect_dl_tput': '400'
    },
    {
        'cellid': 6,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '30M',
        'dl_data_transfer': '500M',
        'expect_ul_tput': '19',
        'expect_dl_tput': '260'
    }
]

FRAME_TO_11160ms_40MHz_4Symbols_For_Cell3 = {
    'framestructure': {
        '3': '11160ms'},
    'cell_chbw': {
        '3': '40MHz'},
    'case_level_params':
        ['modify:NRCELL-3:prachConfigurationIndex=156',
         'modify:NRCELL-3:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4']
}
