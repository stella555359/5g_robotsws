# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


Variables_CFAM = {
    'AZQG': {
        'Uint_name': 'AZQG',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QG</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474994A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    }
}
MR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_NAME = MR_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_NAME + '/NRCELL-1'
MR_NR_CELLGRP_NAME = MR_NR_NAME + '/NRCELLGRP-0'
MR_MNL_MNL_NET_PMMNL = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/PMMNL-1'
MR_MNL_MNL_SYNC_CLOCK_1 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1'

PARA_2SubSector = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors',
        new_value='2sub-sectors'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='4x4 or 4x2 Open Loop Spatial Multiplexing'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_2SS')
]

PARA_8TRX_BF_Peak = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='ssPbchBlockPower',
        new_value='16'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='pMax',
        new_value='460'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType',
        new_value='4DL2UL'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='p0NominalPucch',
        new_value='-108'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='p0NominalPucchF1F3',
        new_value='-98'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='p0NominalPusch',
        new_value='-88')
]
ATTENUATION_VALUE_nonBF_4D4U_1234 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127
}

ATTENUATION_VALUE_BF_1234 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port4': 0,
    'atten_value_of_port5': 0,
    'atten_value_of_port6': 0,
    'atten_value_of_port7': 0
}

ATTENUATION_VALUE_2SS = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 0,
    'atten_value_of_port11': 0
}
