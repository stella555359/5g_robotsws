'''This file is a representation of SIC_addresses.xlsx file from RPREQ_8838 in a form of dictionary.
It's used by node_id_generator.py to compile regex for each BBmod/Smod '''

ASIA = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Core_IDs': '1-4AE'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Offset_IDs': '6-9BC'
    }
}
ASIB = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Core_IDs': '1-4A'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '5A',
        'SoC_IDs': '1',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Offset_IDs': '6-9B-D'
    }
}
ASIK = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': '0',
        'SoC_IDs': '1-2',
        'Core_IDs': '1-3'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '5A',
        'SoC_IDs': '1-2',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Offset_IDs': '8-9AD'
    }
}
ASIL = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Core_IDs': '1-4'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '5A',
        'SoC_IDs': '1',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Offset_IDs': '6-9A-D'
    }
}
ASIM = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Core_IDs': '1-3'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '5A',
        'SoC_IDs': '1',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Offset_IDs': '6-9B-D'
    }
}
ABIA = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-6',
        'Core_IDs': 'ABD'  # Core_IDs 1-8 (DSP cores) are saved on SMOD, so removed from here.
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-6',
        'Offset_IDs': 'AC'
    }
}
ABIC = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-58-9',
        'Core_IDs': '0-9A-F'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-4',
        'Offset_IDs': '0-9A-E'
    }
}
ABIL = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-5',
        'Core_IDs': 'AD'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_position',
        'SoC_IDs': '3-4',
        'Offset_IDs': '0-9A-E'
    }
}
ABIN = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-4',
        'Core_IDs': 'AD'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3',
        'Offset_IDs': '1-46-9'
    }
}
ABIO = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-5',
        'Core_IDs': 'AD'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3',
        'Offset_IDs': '1-46-9'
    }
}
ABIP = {
    'Physical_NodeID': {
        'Domain_ID': 'depends_on_horizontal_position',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3-4',
        'Core_IDs': 'AD'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': 'depends_on_vertical_position',
        'SoC_IDs': '3',
        'Offset_IDs': '1-46-9'
    }
}
ABIQ = ABIP
ASOE = {
    'Physical_NodeID': {
        'Domain_ID': '1',
        'Board_ID': '0',
        'SoC_IDs': '145',
        'Core_IDs': '1-3D'
    },
    'Virtual_NodeID_CommonPool': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '5A',
        'SoC_IDs': '1',
        'Offset_IDs': '0-9A-E'
    },
    'Virtual_NodeID_BoardID': {
        'Domain_ID': '1-9A-C',
        'Board_ID': '0',
        'SoC_IDs': '1',
        'Offset_IDs': '5-9A-E'
    }
}
ASOF = ASOE
