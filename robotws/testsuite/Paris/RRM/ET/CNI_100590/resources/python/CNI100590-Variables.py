import os
import StringTool
from collections import namedtuple

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from testsuite.Paris.RRM.ET.CB009836.resources.python.CB009836_nidd_modify import MR_NR_NRPMRNL_1, MR_EQM_APEQM_BBMOD_1

module_name = os.path.basename(__file__)
msg = module_name + " is imported from :"
StringTool.datedConsole(StringTool.getHeaderLine(msg, __file__))

# scf_file = BuiltIn().get_variable_value('${_scf_file_path}')
# ids = get_mrbtsid_from_scf(scf_file)
# MR_NR_CELL_NAME = 'MRBTS-' + str(ids[0]) + '/NRBTS-' + str(ids[1]) + '/NRCELL-' + str(ids[2])

MRBTS_ID = BuiltIn().get_variable_value('${MRBTS_ID}')
NRBTS_ID = BuiltIn().get_variable_value('${NRBTS_ID}')
HOST_NAME = BuiltIn().get_variable_value('${Host_Name}')
btsName_CNI100590 = 'CNI100590 - ' + HOST_NAME

MR_BTS = 'MRBTS-' + str(MRBTS_ID)
MR_NR_BTS = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID)
MR_NR_CELL_NAME_CELL1 = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELL-1'
MR_NR_CELL_NAME_CELL2 = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELL-2'
MR_NR_CELL_NAME_CELL3 = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELL-3'
MR_NR_CELL_NAME_CELL4 = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELL-4'
MR_NR_CELL_NAME_CELL5 = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELL-5'
MR_NR_CELL_NAME_CELL6 = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELL-6'
# MR_EQM_APEQM_BBMOD_1 = 'MRBTS-' + str(MRBTS_ID) + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1'
MR_NR_CELL_NAME_CELL1_GRP = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELLGRP-0'
MR_NR_CELL_NAME_CELL2_GRP = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELLGRP-1'
MR_NR_CELL_NAME_CELL3_GRP = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELLGRP-2'
MR_NR_CELL_NAME_CELL4_GRP = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELLGRP-3'
MR_NR_CELL_NAME_CELL5_GRP = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELLGRP-4'
MR_NR_CELL_NAME_CELL6_GRP = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELLGRP-5'
MR_NR_CELL_NAME_CELL1_NRDSSLTE_1 = 'MRBTS-' + str(MRBTS_ID) + '/NRBTS-' + str(NRBTS_ID) + '/NRCELL-1/NRDSSLTE-1'

#####################################################
# Configuration parameters
#####################################################


# ABIO case
NIDD_100590_PARAMS_TESTS = [
    dict(dist_name=MR_BTS, pname='btsName', value=btsName_CNI100590),
    dict(dist_name=MR_NR_BTS, pname='actSlowPrbPooling', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolTddFr1', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actSpatialStreamPooling', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actTddPrePooling', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actFdmScheduling', value='true'),
    dict(dist_name=MR_NR_BTS, pname='actFdmEnhancedScheduling', value='true'),
    dict(dist_name=MR_NR_BTS, pname='drbInactivityTimerSA', value='7200'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolExtensionTddFr1', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolTddFr1Enh', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolTddFr1AlgEnh', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actInactDetNSAUe', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='actLteNrDssFastAlloc', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='lteNrDssFastAllocPerfEnh',
         value='exc_msg_reduction_static'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='actLteNrDssLteCatM', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='actRateMatchedCsiIm', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actPdschAtSsbSlots', value='true'),
    dict(dist_name=MR_NR_NRPMRNL_1, pname='miNrLowRlcReport', value='5min'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actPRBBlanking', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actVoNR', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actGbrLoadRepDss', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actEnhancedVoNR', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actNonVoNRGbrService', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actGBRAdmissionControl', value='GBRService'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actGbrRacTdEnhResourcePriority', value='false'),
    dict(dist_name=MR_NR_BTS, list_name='cipherPrefL',
         value=dict(nea0=9, nea1_128=0, nea2_128=0, nea3_128=0))
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='msg1FrequencyStart', value='19'),
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='gscnOrSsPbchArfcn', value='7880'),
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actDynUlResAlloc', value='true'),
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='reqMinNumPuschPrb', value='235'),
]

NIDD_100590_PARAMS_TESTS_FAST_ALLOC_OFF = [
    dict(dist_name=MR_BTS, pname='btsName', value=btsName_CNI100590),
    dict(dist_name=MR_NR_BTS, pname='actSlowPrbPooling', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolTddFr1', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actSpatialStreamPooling', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actTddPrePooling', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actFdmScheduling', value='true'),
    dict(dist_name=MR_NR_BTS, pname='actFdmEnhancedScheduling', value='true'),
    dict(dist_name=MR_NR_BTS, pname='drbInactivityTimerSA', value='7200'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolExtensionTddFr1', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolTddFr1Enh', value='false'),
    dict(dist_name=MR_NR_BTS, pname='actBbPoolTddFr1AlgEnh', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='actLteNrDssFastAlloc', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='lteNrDssFastAllocPerfEnh',
         value='exc_msg_reduction_static'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='actLteNrDssLteCatM', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1_NRDSSLTE_1, pname='actRateMatchedCsiIm', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actPdschAtSsbSlots', value='true'),
    dict(dist_name=MR_NR_NRPMRNL_1, pname='miNrLowRlcReport', value='5min'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actPRBBlanking', value='false'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actVoNR', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actGbrLoadRepDss', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actEnhancedVoNR', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actNonVoNRGbrService', value='true'),
    dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actGBRAdmissionControl', value='GBRService'),
    dict(dist_name=MR_NR_BTS, list_name='cipherPrefL',
         value=dict(nea0=9, nea1_128=0, nea2_128=0, nea3_128=0))
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='msg1FrequencyStart', value='19'),
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='gscnOrSsPbchArfcn', value='7880'),
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='actDynUlResAlloc', value='true'),
    # dict(dist_name=MR_NR_CELL_NAME_CELL1, pname='reqMinNumPuschPrb', value='235'),
]
