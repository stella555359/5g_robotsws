from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

frame_structure_list_100MHz_90MHz = [
    {
        'cellid': 3,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
    },
    {
        'cellid': 5,
        'frame': '1116_0ms_GP1_A7',
        'band': '90',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '120M',
        'dl_data_transfer': '1300M',
        'expect_ul_tput': '99',
        'expect_dl_tput': '1050'
    }
]

frame_structure_list_100MHz_80MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '80',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '120M',
        'dl_data_transfer': '1200M',
        'expect_ul_tput': '86',
        'expect_dl_tput': '960'
    }
]

frame_structure_list_100MHz_60MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '60',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '100M',
        'dl_data_transfer': '1000M',
        'expect_ul_tput': '62',
        'expect_dl_tput': '720'
    }
]

frame_structure_list_100MHz_50MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '50',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '90M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '50',
        'expect_dl_tput': '580'
    }
]

frame_structure_list_100MHz_40MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
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
        'dl_data_transfer': '700M',
        'expect_ul_tput': '38',
        'expect_dl_tput': '470'
    }
]

frame_structure_list_100MHz_30MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '30',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '70M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '26',
        'expect_dl_tput': '340'
    }
]

frame_structure_list_90MHz_40MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '90',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '130M',
        'dl_data_transfer': '1300M',
        'expect_ul_tput': '99',
        'expect_dl_tput': '1050'
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
        'dl_data_transfer': '700M',
        'expect_ul_tput': '38',
        'expect_dl_tput': '470'
    }
]

frame_structure_list_90MHz_30MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '90',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'ul_data_transfer': '130M',
        'dl_data_transfer': '1300M',
        'expect_ul_tput': '99',
        'expect_dl_tput': '1050'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '30',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '70M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '26',
        'expect_dl_tput': '340'
    }
]

frame_structure_list_80MHz_50MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '80',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '120M',
        'dl_data_transfer': '1200M',
        'expect_ul_tput': '86',
        'expect_dl_tput': '960'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '50',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '90M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '50',
        'expect_dl_tput': '580'
    }
]

frame_structure_list_80MHz_40MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '80',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '120M',
        'dl_data_transfer': '1200M',
        'expect_ul_tput': '86',
        'expect_dl_tput': '960'
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
        'dl_data_transfer': '700M',
        'expect_ul_tput': '38',
        'expect_dl_tput': '470'
    }
]

frame_structure_list_70MHz_50MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '70',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '110M',
        'dl_data_transfer': '1100M',
        'expect_ul_tput': '75',
        'expect_dl_tput': '830'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '50',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '90M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '50',
        'expect_dl_tput': '580'
    }
]

frame_structure_list_70MHz_40MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '70',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '110M',
        'dl_data_transfer': '1100M',
        'expect_ul_tput': '75',
        'expect_dl_tput': '830'
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
        'dl_data_transfer': '700M',
        'expect_ul_tput': '38',
        'expect_dl_tput': '470'
    }
]

frame_structure_list_70MHz_30MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '70',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '110M',
        'dl_data_transfer': '1100M',
        'expect_ul_tput': '75',
        'expect_dl_tput': '830'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '30',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '70M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '26',
        'expect_dl_tput': '340'
    }
]

frame_structure_list_60MHz_50MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '60',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '100M',
        'dl_data_transfer': '1000M',
        'expect_ul_tput': '62',
        'expect_dl_tput': '720'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '50',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '90M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '50',
        'expect_dl_tput': '580'
    }
]

frame_structure_list_60MHz_30MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '60',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '100M',
        'dl_data_transfer': '1000M',
        'expect_ul_tput': '62',
        'expect_dl_tput': '720'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '30',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '70M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '26',
        'expect_dl_tput': '340'
    }
]

frame_structure_list_100MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '60M',
        'dl_data_transfer': '400M',
        'expect_ul_tput': '15',
        'expect_dl_tput': '210'
    }
]

frame_structure_list_90MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '90',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '130M',
        'dl_data_transfer': '1300M',
        'expect_ul_tput': '99',
        'expect_dl_tput': '1050'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '60M',
        'dl_data_transfer': '400M',
        'expect_ul_tput': '15',
        'expect_dl_tput': '210'
    }
]

frame_structure_list_80MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '80',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '120M',
        'dl_data_transfer': '1200M',
        'expect_ul_tput': '86',
        'expect_dl_tput': '960'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '60M',
        'dl_data_transfer': '400M',
        'expect_ul_tput': '15',
        'expect_dl_tput': '210'
    }
]

frame_structure_list_60MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '60',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '100M',
        'dl_data_transfer': '1000M',
        'expect_ul_tput': '62',
        'expect_dl_tput': '720'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '60M',
        'dl_data_transfer': '400M',
        'expect_ul_tput': '15',
        'expect_dl_tput': '210'
    }
]

frame_structure_list_10MHz_40MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
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
        'dl_data_transfer': '700M',
        'expect_ul_tput': '38',
        'expect_dl_tput': '470'
    }
]

frame_structure_list_90MHz_50MHz_SBTS00 = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '90',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '130M',
        'dl_data_transfer': '1300M',
        'expect_ul_tput': '99',
        'expect_dl_tput': '1050'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '50',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '90M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '73.5',
        'expect_dl_tput': '700'
    }
]

frame_structure_list_90MHz_50MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '90',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '130M',
        'dl_data_transfer': '1300M',
        'expect_ul_tput': '99',
        'expect_dl_tput': '1050'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '50',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '90M',
        'dl_data_transfer': '800M',
        'expect_ul_tput': '50',
        'expect_dl_tput': '678'
    }
]

frame_structure_list_80MHz_30MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '80',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '120M',
        'dl_data_transfer': '1200M',
        'expect_ul_tput': '86',
        'expect_dl_tput': '960'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '30',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '70M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '26',
        'expect_dl_tput': '340'
    }
]

frame_structure_list_60MHz_40MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '60',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '100M',
        'dl_data_transfer': '1000M',
        'expect_ul_tput': '62',
        'expect_dl_tput': '720'
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
        'dl_data_transfer': '700M',
        'expect_ul_tput': '38',
        'expect_dl_tput': '470'
    }
]

frame_structure_list_70MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '70',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '110M',
        'dl_data_transfer': '1100M',
        'expect_ul_tput': '75',
        'expect_dl_tput': '830'
    },
    {
        'cellid': 2,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '60M',
        'dl_data_transfer': '400M',
        'expect_ul_tput': '15',
        'expect_dl_tput': '210'
    }
]

frame_structure_list_100MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '150M',
        'dl_data_transfer': '1400M',
        'expect_ul_tput': '110',
        'expect_dl_tput': '1200'
    }
]
