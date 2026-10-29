# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lin Stella
:contact: stella.lin@nokia-sbell.com

"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

# ------------ swconfig CB008360 flags ------------------
# rdPairedUEsDeltaSINR
# 0x58054b=0x32
SWCONFIG_rdPairedUEsDeltaSINR = ["0x58054b=5"]

# rdActUlMuMimoEnhance
# 0x58054f=0
SWCONFIG_rdActUlMuMimoEnhance_false = ["0x58054f=0"]
SWCONFIG_rdActUlMuMimoEnhance_true = ["0x58054f=1"]


MODIFY_SCF_fs_1208__chbw_100MHz = {
    'framestructure': '1208',
    'cell_chbw': {
        '3': '100MHz'},
    'case_level_params':
        ['modify:NRCELL-3:prachConfigurationIndex=98',
         'modify:NRCELL-3:prachRootSequenceIndex=137',
         'modify:NRCELL-3:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-3:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-3:ulDataDmrsFdm:actUlDataDmrsFdm=true',
         'modify:NRULMUMIMO-0:actUlMuMimoTapering=true',
         'modify:NRULMUMIMO-0:ulMaxMuMimoLayer=4',
         'modify:NRCELL-3:actDlMuMimoEnh=true',
         'modify:NRCELL-3:actUl256Qam=false',
         'modify:NRCELL-3:actUlDftSOfdm=true',
         'modify:NRCELL-3:p0NominalPucchF1F3=-90',
         'modify:NRCELL-3:p0NominalPusch=-88',
         ]
}

# SCF parameters to delete
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
Cablink_TO_DELETE = [
    dict(dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-57')
]
