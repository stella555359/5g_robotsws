from robot.libraries.BuiltIn import BuiltIn


tl = BuiltIn().get_variable_value('${tl}')
all_cell_ids = BuiltIn().get_variable_value('${all_cell_ids}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
BTS_ID = str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRIAFIM = MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1'
NRIRFIM1 = MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1'
NRIRFIM2 = MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2'
NRPMRNL = MR_NR_BTS_NAME + '/NRPMRNL-1'


CELL_INDEX_1TH = str(all_cell_ids[0])
CELL_INDEX_2TH = str(all_cell_ids[1])
CELL_INDEX_3TH = str(all_cell_ids[2])
CELL_INDEX_4TH = str(all_cell_ids[3])
CELL_INDEX_5TH = str(all_cell_ids[4])
CELL_INDEX_6TH = str(all_cell_ids[5])
CELL_INDEX_7TH = str(all_cell_ids[6])
CELL_INDEX_8TH = str(all_cell_ids[7])


NRCELL_1TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_1TH
NRCELL_2TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_2TH
NRCELL_3TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_3TH
NRCELL_4TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_4TH
NRCELL_5TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_5TH
NRCELL_6TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_6TH
NRCELL_7TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_7TH
NRCELL_8TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_8TH

CELL_3TH_CHANNEL_2 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_3TH + '/CHANNELGROUP-1/CHANNEL-2'
CELL_3TH_CHANNEL_4 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_3TH + '/CHANNELGROUP-1/CHANNEL-4'
CELL_4TH_CHANNEL_2 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_4TH + '/CHANNELGROUP-1/CHANNEL-2'
CELL_4TH_CHANNEL_4 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_4TH + '/CHANNELGROUP-1/CHANNEL-4'
CELL_5TH_CHANNEL_1 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_5TH + '/CHANNELGROUP-1/CHANNEL-1'
CELL_5TH_CHANNEL_2 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_5TH + '/CHANNELGROUP-1/CHANNEL-2'
CELL_5TH_CHANNEL_3 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_5TH + '/CHANNELGROUP-1/CHANNEL-3'
CELL_5TH_CHANNEL_4 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_5TH + '/CHANNELGROUP-1/CHANNEL-4'
CELL_6TH_CHANNEL_1 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_6TH + '/CHANNELGROUP-1/CHANNEL-1'
CELL_6TH_CHANNEL_2 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_6TH + '/CHANNELGROUP-1/CHANNEL-2'
CELL_6TH_CHANNEL_3 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_6TH + '/CHANNELGROUP-1/CHANNEL-3'
CELL_6TH_CHANNEL_4 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_6TH + '/CHANNELGROUP-1/CHANNEL-4'
CELL_7TH_CHANNEL_2 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_7TH + '/CHANNELGROUP-1/CHANNEL-2'
CELL_7TH_CHANNEL_4 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_7TH + '/CHANNELGROUP-1/CHANNEL-4'
CELL_8TH_CHANNEL_2 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_8TH + '/CHANNELGROUP-1/CHANNEL-2'
CELL_8TH_CHANNEL_4 = \
    MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1' + '/LCELNR-' + CELL_INDEX_8TH + '/CHANNELGROUP-1/CHANNEL-4'
RMOD_EXT_PANNEL = MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-3/PHYANT-1'
LNADJGNB = MR_BTS_NAME + '/LNBTS-' + str(tl.gnbs[0].global_bts_id) + '/LNADJGNB-1'

# PART1: OSI config
ADD_OBJ_NRIAFIM = [
    {'dist_name': NRIAFIM, 'parameter': 'numberOfTransmittedSsBlocks', 'value': '32 beams'},
    {'dist_name': NRIAFIM, 'parameter': 'qQualMin', 'value': '-14'},
    {'dist_name': NRIAFIM, 'parameter': 'qRxLevMin', 'value': '-50'},
    {'dist_name': NRIAFIM, 'parameter': 'sIntraSearchP', 'value': '22'},
    {'dist_name': NRIAFIM, 'parameter': 'sIntraSearchQ', 'value': '1'},
    {'dist_name': NRIAFIM, 'parameter': 'sfHigh', 'value': 'oDot75'},
    {'dist_name': NRIAFIM, 'parameter': 'sfMedium', 'value': 'oDot25'},
    {'dist_name': NRIAFIM, 'parameter': 'tReselectionNr', 'value': '2'},
]

ADD_OBJ_NRIAFIM1 = [
    {'dist_name': NRIRFIM1, 'parameter': 'cellReselectionPriority', 'value': '6'},
    {'dist_name': NRIRFIM1, 'parameter': 'cellReselectionSubPriority', 'value': 'oDot8'},
    {'dist_name': NRIRFIM1, 'parameter': 'dlCarrierFreq', 'value': '2091547'},
    {'dist_name': NRIRFIM1, 'parameter': 'dssCellsDeployed', 'value': 'false'},
    {'dist_name': NRIRFIM1, 'parameter': 'freqBandIndicatorNR', 'value': '257'},
    {'dist_name': NRIRFIM1, 'parameter': 'idleMMNrCelResWeight', 'value': '100'},
    {'dist_name': NRIRFIM1, 'parameter': 'numberOfTransmittedSsBlocks', 'value': '32 beams'},
    {'dist_name': NRIRFIM1, 'parameter': 'pMaxInterFreq', 'value': '23'},
    {'dist_name': NRIRFIM1, 'parameter': 'qOffsetFreq', 'value': '0dB'},
    {'dist_name': NRIRFIM1, 'parameter': 'qRxLevMin', 'value': '-60'},
    {'dist_name': NRIRFIM1, 'parameter': 'ssbScs', 'value': '240 KHz'},
    {'dist_name': NRIRFIM1, 'parameter': 'tReselectionNr', 'value': '1'},
    {'dist_name': NRIRFIM1, 'parameter': 'threshXHighP', 'value': '10'},
    {'dist_name': NRIRFIM1, 'parameter': 'threshXLowP', 'value': '6'},
]

ADD_OBJ_NRIAFIM2 = [
    {'dist_name': NRIRFIM2, 'parameter': 'cellReselectionPriority', 'value': '6'},
    {'dist_name': NRIRFIM2, 'parameter': 'cellReselectionSubPriority', 'value': 'oDot8'},
    {'dist_name': NRIRFIM2, 'parameter': 'dlCarrierFreq', 'value': '2058139'},
    {'dist_name': NRIRFIM2, 'parameter': 'dssCellsDeployed', 'value': 'false'},
    {'dist_name': NRIRFIM2, 'parameter': 'freqBandIndicatorNR', 'value': '258'},
    {'dist_name': NRIRFIM2, 'parameter': 'idleMMNrCelResWeight', 'value': '100'},
    {'dist_name': NRIRFIM2, 'parameter': 'numberOfTransmittedSsBlocks', 'value': '32 beams'},
    {'dist_name': NRIRFIM2, 'parameter': 'pMaxInterFreq', 'value': '23'},
    {'dist_name': NRIRFIM2, 'parameter': 'qOffsetFreq', 'value': '0dB'},
    {'dist_name': NRIRFIM2, 'parameter': 'qRxLevMin', 'value': '-60'},
    {'dist_name': NRIRFIM2, 'parameter': 'ssbScs', 'value': '240 KHz'},
    {'dist_name': NRIRFIM2, 'parameter': 'tReselectionNr', 'value': '1'},
    {'dist_name': NRIRFIM2, 'parameter': 'threshXHighP', 'value': '10'},
    {'dist_name': NRIRFIM2, 'parameter': 'threshXLowP', 'value': '6'},
]

MODIFY_ENABLE_OSI = [
    {'dist_name': NRCELL_1TH, 'parameter': 'actOsiMismatchCheck', 'value': 'true'}]

MODIFY_DISABLE_OSI = [
    {'dist_name': NRCELL_1TH, 'parameter': 'actOsiMismatchCheck', 'value': 'false'}]

DELETE_OBJ_UNDER_NRSYSINFO = [
    {'dist_name': NRIAFIM},
]

ADD_OBJ_3_NRIAFIM = ADD_OBJ_NRIAFIM + ADD_OBJ_NRIAFIM1 + ADD_OBJ_NRIAFIM2

DICT_ENABLE_OSI_CREATE_MISMATCH = {
    'param_to_upd': MODIFY_ENABLE_OSI,
    'object_to_add': ADD_OBJ_NRIAFIM + ADD_OBJ_NRIAFIM1 + ADD_OBJ_NRIAFIM2
}
# PART2: FEATCADM SCF MOD
ADD_SCF_PARAM_PREVENT = [
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/FEATCADM-1', list_name='preventParamModifList',
         elements=['NRCELL-sCellOnlyFr2Sa'])
]

MOD_PARAM_PREVENT = [dict(dist_name=NRCELL_5TH, parameter='sCellOnlyFr2Sa', value='false')]

# PART3: CB006020
MODIFY_SCF_6020 = [
    dict(dist_name=MR_NR_BTS_NAME, p_name='actDualSectorRu', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='gNbCuType', value='SA+NSA'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_5TH, p_name='cellDepType', value='NSA'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='x2LinkSupervisionTmr', value='4'),
    dict(dist_name=NRCELL_6TH, p_name='cellDepType', value='NSA'),
    dict(dist_name=NRCELL_7TH, p_name='cellDepType', value='NSA'),
    dict(dist_name=NRCELL_8TH, p_name='cellDepType', value='NSA'),
    # ####### channel #######
    dict(dist_name=CELL_5TH_CHANNEL_2, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_5TH_CHANNEL_4, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_6TH_CHANNEL_2, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_6TH_CHANNEL_4, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_7TH_CHANNEL_2, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_7TH_CHANNEL_4, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_8TH_CHANNEL_2, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_8TH_CHANNEL_4, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=NRCELL_3TH, p_name='intraFreqReselection', value='notAllowed'),
    dict(dist_name=NRCELL_3TH, p_name='nrCellType', value='2DL0UL'),
    dict(dist_name=NRCELL_4TH, p_name='intraFreqReselection', value='notAllowed'),
    dict(dist_name=NRCELL_4TH, p_name='nrCellType', value='2DL0UL'),
    dict(dist_name=NRCELL_5TH, p_name='intraFreqReselection', value='notAllowed'),
    dict(dist_name=NRCELL_5TH, p_name='nrCellType', value='2DL2UL'),
    dict(dist_name=NRCELL_6TH, p_name='intraFreqReselection', value='notAllowed'),
    dict(dist_name=NRCELL_6TH, p_name='nrCellType', value='2DL2UL'),
    # ###### beamset ######
    dict(dist_name=NRCELL_1TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_1TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_1TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    dict(dist_name=NRCELL_2TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_2TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_2TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    dict(dist_name=NRCELL_3TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_3TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_3TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    dict(dist_name=NRCELL_4TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_4TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_4TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    dict(dist_name=NRCELL_5TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_5TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_5TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    dict(dist_name=NRCELL_6TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_6TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_6TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    dict(dist_name=NRCELL_7TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_7TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_7TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    dict(dist_name=NRCELL_8TH, list_name='beamSet', p_name='basicBeamSet', value='beamSetFR2_16_8_8_1P'),
    dict(dist_name=NRCELL_8TH, list_name='beamSet', p_name='leftEdgeAngle', value='45'),
    dict(dist_name=NRCELL_8TH, list_name='beamSet', p_name='rightEdgeAngle', value='45'),
    # ### nrSysInfoProfileDN ###
    dict(dist_name=NRCELL_5TH, p_name='nrSysInfoProfileDN', value=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE_NSA-1'),
    dict(dist_name=NRCELL_6TH, p_name='nrSysInfoProfileDN', value=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE_NSA-1'),
    dict(dist_name=NRCELL_7TH, p_name='nrSysInfoProfileDN', value=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE_NSA-1'),
    dict(dist_name=NRCELL_8TH, p_name='nrSysInfoProfileDN', value=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE_NSA-1')
]

ADD_SCF_6020 = [
    dict(dist_name=NRCELL_5TH, p_name='configuredEpsTac', value='1'),
    dict(dist_name=NRCELL_6TH, p_name='configuredEpsTac', value='1'),
    dict(dist_name=NRCELL_7TH, p_name='configuredEpsTac', value='1'),
    dict(dist_name=NRCELL_8TH, p_name='configuredEpsTac', value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['0', '1']),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1',
         version='NRBTSCL23R4_2313_101', class_name='com.nokia.srbts.nrbts:NRCELLGRP'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="actLoadCsiPeriodicity", value='false'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="actNackDtxFloodControlDetection", value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="addNumOfHoUsers", value='0'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="addNumOfNonGBRBearersCGRPSAHo", value='0'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="addNumOfNonGBRBearersHo", value='0'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="addNumOfRrcCGRPSAHo", value='0'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="beamformingGridSel", value='ABFG90'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="loadBasedCsiPerThreshold", value='50Percent'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxDlHarqTx", value='5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxHarqMsg3Tx", value='5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxNumOfNonGBRBearers", value='550'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxNumOfNonGBRBearersCGRPSA", value='550'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxNumOfNrDcSnNonGBRBearersCGRP", value='550'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxNumOfNrDcSnUsersCGRP", value='275'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxNumOfRrcCGRPSA", value='275'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxNumOfUsers", value='550'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="maxUlHarqTx", value='5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="numberOfTransmittedSsBlocks", value='32 beams'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="pucchF2MaxCodeRate", value='zeroDot15'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="scs", value='120 KHz'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="spCellChangeEnabled", value='false'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', p_name="ssBurstSetPeriod", value='20'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', list_name='nackFloodControlF1',
         elements={"dataFlowResumeThrFR1": "5", "dataFlowResumeThrFR2": "20", "forgettingRatioFR1": "50",
                   "forgettingRatioFR2": "50", "maxNackFloodBurstSizeFR1": "10",
                   "maxNackFloodBurstSizeFR2": "40"}),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList',
         elements=[CELL_INDEX_1TH, CELL_INDEX_2TH, CELL_INDEX_3TH, CELL_INDEX_4TH]),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1', list_name='nrCellList',
         elements=[CELL_INDEX_5TH, CELL_INDEX_6TH, CELL_INDEX_7TH, CELL_INDEX_8TH]),
    # ########## NRIAFIM #############
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1',
         version='NRBTSCL23R4_2313_101', class_name='com.nokia.srbts.nrbts:NRIAFIM'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="numberOfTransmittedSsBlocks",
         value='32 beams'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="qQualMin", value='-14'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="qRxLevMin", value='-50'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="sIntraSearchP", value='22'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="sIntraSearchQ", value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="sfHigh", value='oDot75'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="sfMedium", value='oDot25'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name="tReselectionNr", value='2'),
    # ###### LNADJ ######
    dict(dist_name=LNADJGNB, version='NRBTSCL23R4_2313_101', class_name='NOKLTE:LNADJGNB'),
    dict(dist_name=LNADJGNB, p_name="adjGnbId", value=str(tl.gnbs[0].instance_id)),
    dict(dist_name=LNADJGNB, p_name="adjGnbIdLength", value='22'),
    dict(dist_name=LNADJGNB, p_name="administrativeState", value='unlocked'),
    dict(dist_name=LNADJGNB, p_name="cPlaneIpAddr", value=str(tl.gnbs[0].cu.oam_ssh_connection_details.addr)),
    dict(dist_name=LNADJGNB, p_name="cPlaneIpAddrCtrl", value='oamControlled'),
    dict(dist_name=LNADJGNB, list_name='plmnId', elements={"mcc": "262", "mnc": "3", "mncLength": "2"}),
    # ########## CHANNEL #############
    dict(dist_name=CELL_5TH_CHANNEL_1,
         version='NRBTSCL23R4_2313_101', class_name='com.nokia.srbts.mnl:CHANNEL'),
    dict(dist_name=CELL_5TH_CHANNEL_3,
         version='NRBTSCL23R4_2313_101', class_name='com.nokia.srbts.mnl:CHANNEL'),
    dict(dist_name=CELL_6TH_CHANNEL_1,
         version='NRBTSCL23R4_2313_101', class_name='com.nokia.srbts.mnl:CHANNEL'),
    dict(dist_name=CELL_6TH_CHANNEL_3,
         version='NRBTSCL23R4_2313_101', class_name='com.nokia.srbts.mnl:CHANNEL'),
    dict(dist_name=CELL_5TH_CHANNEL_1, p_name='direction', value='RX'),
    dict(dist_name=CELL_5TH_CHANNEL_1, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_5TH_CHANNEL_3, p_name='direction', value='RX'),
    dict(dist_name=CELL_5TH_CHANNEL_3, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_6TH_CHANNEL_1, p_name='direction', value='RX'),
    dict(dist_name=CELL_6TH_CHANNEL_1, p_name='resourceDN', value=RMOD_EXT_PANNEL),
    dict(dist_name=CELL_6TH_CHANNEL_3, p_name='direction', value='RX'),
    dict(dist_name=CELL_6TH_CHANNEL_3, p_name='resourceDN', value=RMOD_EXT_PANNEL),
]

DELETE_SCF_6020 = [
    dict(dist_name=NRCELL_5TH, p_name='t320'),
    dict(dist_name=NRCELL_6TH, p_name='t320'),
    dict(dist_name=NRCELL_7TH, p_name='t320'),
    dict(dist_name=NRCELL_8TH, p_name='t320'),
    dict(dist_name=NRCELL_5TH, p_name='trackingAreaDN'),
    dict(dist_name=NRCELL_6TH, p_name='trackingAreaDN'),
    dict(dist_name=NRCELL_7TH, p_name='trackingAreaDN'),
    dict(dist_name=NRCELL_8TH, p_name='trackingAreaDN'),
    dict(dist_name=NRCELL_5TH, p_name='idleMMSteeringPercentageOfUes'),
    dict(dist_name=NRCELL_6TH, p_name='idleMMSteeringPercentageOfUes'),
    dict(dist_name=NRCELL_7TH, p_name='idleMMSteeringPercentageOfUes'),
    dict(dist_name=NRCELL_8TH, p_name='idleMMSteeringPercentageOfUes'),
    dict(dist_name=NRCELL_5TH, p_name='idleMMSteeringAlgo'),
    dict(dist_name=NRCELL_6TH, p_name='idleMMSteeringAlgo'),
    dict(dist_name=NRCELL_7TH, p_name='idleMMSteeringAlgo'),
    dict(dist_name=NRCELL_8TH, p_name='idleMMSteeringAlgo'),
    dict(dist_name=NRCELL_5TH, p_name='idleMMSteeringWRREnabled'),
    dict(dist_name=NRCELL_6TH, p_name='idleMMSteeringWRREnabled'),
    dict(dist_name=NRCELL_7TH, p_name='idleMMSteeringWRREnabled'),
    dict(dist_name=NRCELL_8TH, p_name='idleMMSteeringWRREnabled'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup'),
    dict(dist_name=CELL_3TH_CHANNEL_2),
    dict(dist_name=CELL_3TH_CHANNEL_4),
    dict(dist_name=CELL_4TH_CHANNEL_2),
    dict(dist_name=CELL_4TH_CHANNEL_4),
]

DICT_ENABLE_B4 = []
for i in all_cell_ids:
    print(i)
    cellId = str(i)
    dist_name_cell = MR_NR_BTS_NAME + '/NRCELL-' + cellId
    set_ulMimoMode = dict(dist_name=dist_name_cell, parameter='ulMimoMode',
                          value='Closed loop Spatial Multiplexing (2x2)')
    set_prachConfigurationIndex = dict(dist_name=dist_name_cell, parameter='prachConfigurationIndex', value='121')
    set_zeroCorrelationZoneConfig = dict(dist_name=dist_name_cell, parameter='zeroCorrelationZoneConfig', value='0')
    set_rangeExtension = dict(dist_name=dist_name_cell, parameter='rangeExtension', value='0-6.9km')
    set_totalNumberOfRAPreambles = dict(dist_name=dist_name_cell, parameter='totalNumberOfRAPreambles', value='32')
    set_type0SearchSpaceConfigurationIndex = dict(dist_name=dist_name_cell,
                                                  parameter='type0SearchSpaceConfigurationIndex', value='13')
    set_guardPeriodLength = dict(dist_name=dist_name_cell,
                                 parameter='tddFrameStructure', value=[{'guardPeriodLength': '6Symbols'}])
    # [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='tddFrameStructure', value=[{'guardPeriodLength': '${GP}'}])]
    set_inactiveSsbFr2 = dict(dist_name=dist_name_cell, parameter='inactiveSsbFr2', value='0x0800F8842100F210')
    set_numOfPagingFrames = dict(dist_name=dist_name_cell, parameter='numOfPagingFrames', value='oneEighthT')
    set_cbraPreamblesPerSsb = dict(dist_name=dist_name_cell, parameter='cbraPreamblesPerSsb', value='n32')
    DICT_ENABLE_B4.extend([set_ulMimoMode, set_prachConfigurationIndex,
                           set_zeroCorrelationZoneConfig, set_guardPeriodLength,
                           set_rangeExtension, set_totalNumberOfRAPreambles, set_type0SearchSpaceConfigurationIndex,
                           set_inactiveSsbFr2, set_numOfPagingFrames, set_cbraPreamblesPerSsb])

DICT_ENABLE_5GC000532 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1', parameter='miNrUlSignalQuality', value='5min'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCoverageNonCoherentUes', value='false'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', parameter='ssBurstSetPeriod', value='40')
]

DICT_ENABLE_B4_532 = DICT_ENABLE_B4 + DICT_ENABLE_5GC000532

DICT_ENABLE_1732_15 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCsiReportsMuxOnPucch', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1', parameter='miNrRachUsage', value='5min'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', parameter='pucchF2MaxCodeRate', value='zeroDot15')
]

DICT_ENABLE_1732_25 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCsiReportsMuxOnPucch', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', parameter='pucchF2MaxCodeRate', value='zeroDot25')
]
#
# CB007723
ADD_SCF_7723 = [
    dict(dist_name=NRCELL_1TH, p_name='inactiveSsbFr2', value='576733998676505104'),
    dict(dist_name=NRCELL_2TH, p_name='inactiveSsbFr2', value='576733998676505104'),
    dict(dist_name=NRCELL_3TH, p_name='inactiveSsbFr2', value='576733998676505104'),
    dict(dist_name=NRCELL_4TH, p_name='inactiveSsbFr2', value='576733998676505104'),
]

MODIFY_SCF_7723 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', p_name='ssBurstSetPeriod', value='40'),
    dict(dist_name=NRCELL_1TH, p_name='zeroCorrelationZoneConfig', value='0'),
    dict(dist_name=NRCELL_2TH, p_name='zeroCorrelationZoneConfig', value='0'),
    dict(dist_name=NRCELL_3TH, p_name='zeroCorrelationZoneConfig', value='0'),
    dict(dist_name=NRCELL_4TH, p_name='zeroCorrelationZoneConfig', value='0'),

    dict(dist_name=NRCELL_1TH, p_name='prachConfigurationIndex', value='135'),
    dict(dist_name=NRCELL_2TH, p_name='prachConfigurationIndex', value='135'),
    dict(dist_name=NRCELL_3TH, p_name='prachConfigurationIndex', value='135'),
    dict(dist_name=NRCELL_4TH, p_name='prachConfigurationIndex', value='135'),

    dict(dist_name=NRCELL_1TH, p_name='guardPeriodLength', value='10Symbols'),
    dict(dist_name=NRCELL_2TH, p_name='guardPeriodLength', value='10Symbols'),
    dict(dist_name=NRCELL_3TH, p_name='guardPeriodLength', value='10Symbols'),
    dict(dist_name=NRCELL_4TH, p_name='guardPeriodLength', value='10Symbols'),

    dict(dist_name=NRCELL_1TH, p_name='rangeExtension', value='0-6.9km'),
    dict(dist_name=NRCELL_2TH, p_name='rangeExtension', value='0-6.9km'),
    dict(dist_name=NRCELL_3TH, p_name='rangeExtension', value='0-6.9km'),
    dict(dist_name=NRCELL_4TH, p_name='rangeExtension', value='0-6.9km'),

    dict(dist_name=NRCELL_1TH, p_name='totalNumberOfRAPreambles', value='32'),
    dict(dist_name=NRCELL_2TH, p_name='totalNumberOfRAPreambles', value='32'),
    dict(dist_name=NRCELL_3TH, p_name='totalNumberOfRAPreambles', value='32'),
    dict(dist_name=NRCELL_4TH, p_name='totalNumberOfRAPreambles', value='32'),

    dict(dist_name=NRCELL_1TH, p_name='cbraPreamblesPerSsb', value='n32'),
    dict(dist_name=NRCELL_2TH, p_name='cbraPreamblesPerSsb', value='n32'),
    dict(dist_name=NRCELL_3TH, p_name='cbraPreamblesPerSsb', value='n32'),
    dict(dist_name=NRCELL_4TH, p_name='cbraPreamblesPerSsb', value='n32'),

    dict(dist_name=NRCELL_1TH, p_name='type0SearchSpaceConfigurationIndex', value='13'),
    dict(dist_name=NRCELL_2TH, p_name='type0SearchSpaceConfigurationIndex', value='13'),
    dict(dist_name=NRCELL_3TH, p_name='type0SearchSpaceConfigurationIndex', value='13'),
    dict(dist_name=NRCELL_4TH, p_name='type0SearchSpaceConfigurationIndex', value='13'),
]

# Enable 5GC000733
Enable_733 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='drbInactivityTimerSA', value='600'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='srbInactivityTimerSA', value='600'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actPaging', value='true'),
]

DEFAULT_INACT_TIME = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='drbInactivityTimerSA', value='10'),
]

MODIFY_RX_LEVEL = [
    dict(dist_name=NRCELL_1TH, parameter='qRxLevMin', value='-64'),
]

# 5GC000740: AMF config
SERVEDAMF1 = MR_NR_BTS_NAME + '/SERVEDAMF-1'
SERVEDAMF2 = MR_NR_BTS_NAME + '/SERVEDAMF-2'
SERVEDAMF3 = MR_NR_BTS_NAME + '/SERVEDAMF-3'
NRPMRNL = MR_NR_BTS_NAME + '/NRPMRNL-1'

MODIFY_SCF_NG_LINK_COUNTER_INTERVAL = [
    dict(dist_name=NRPMRNL, p_name='miNrNgInterface', value='5min')
]

ADD_OBJ_SERVEDAMF2 = [
    {'dist_name': SERVEDAMF2, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': SERVEDAMF2, 'parameter': 'amfIPAddress', 'value': '10.70.255.6'},
    {'dist_name': SERVEDAMF2, 'parameter': 'defaultAMF', 'value': 'false'},
]

ADD_OBJ_SERVEDAMF3 = [
    {'dist_name': SERVEDAMF3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': SERVEDAMF3, 'parameter': 'amfIPAddress', 'value': '10.110.194.134'},
    {'dist_name': SERVEDAMF3, 'parameter': 'defaultAMF', 'value': 'false'},
]

MODIFY_LOCK_SERVEDAMF1 = [
    {'dist_name': SERVEDAMF1, 'parameter': 'administrativeState', 'value': 'Locked'}]

MODIFY_UNLOCK_SERVEDAMF1 = [
    {'dist_name': SERVEDAMF1, 'parameter': 'administrativeState', 'value': 'Unlocked'}]

DICT_ADD_MULTI_NG_LINK = {
    'object_to_add': ADD_OBJ_SERVEDAMF2 + ADD_OBJ_SERVEDAMF3
}

# CNI-94156
MODIFY_ENABLE_CNI_94156 = [
    {'dist_name': MR_NR_BTS_NAME, 'parameter': 'actMultipleDedicatedBWPs', 'value': 'false'},
    {'dist_name': NRCELL_1TH, 'parameter': 'ueConnectionEstablishmentMode', 'value': 'useInitialBwp'}]

# PART4: CB007516
MODIFY_SCF_7516 = [
    dict(dist_name=MR_NR_BTS_NAME, p_name='actIdleMMSteering', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='actMobilityProfile', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='actSPID', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='drbInactivityTimerSA', value='10'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='srbInactivityTimerSA', value='10'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1', p_name='miNrNRMOP', value='5min'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1', p_name='miNrRRCC', value='5min'),
]

ADD_SCF_7516 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPRMA_SA-1',
         version='NRBTSCL23R4_2315_10', class_name='com.nokia.srbts.nrbts:NRMOPRMA_SA'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPRMA_SA-1',
         p_name='mobilityProfilePriority', value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPRMA_SA-1', p_name='nrMoPrSaDN',
         value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPRMA_SA-1', list_name='nrPlmnDNList',
         elements=[MR_NR_BTS_NAME + '/NRPLMN-1']),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1',
         version='NRBTSCL23R4_2315_10', class_name='com.nokia.srbts.nrbts:NRMOPR_SA'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1', p_name='a1MeashoEnabledSA', value='none'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1', p_name='a1MeashoPrefNRLayerEnabledSA', value='none'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1', p_name='a2MeasRedirectEnabled', value='rsrp'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1', p_name='a2MeashoEnabledSA', value='none'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1', p_name='emergencyCallFails', value='disabled'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1', p_name='emergencyFBMode', value='disabled'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1', p_name='voiceFBMode', value='disabled'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1' + '/NRMOIMP_SA-1',
         version='NRBTSCL23R4_2315_10', class_name='com.nokia.srbts.nrbts:NRMOIMP_SA'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1/NRMOIMP_SA-1', list_name='dlCarFreqNrList',
         elements={"dlCarFreqNr": "2058139", "idleMMNrCelResWeight": "100",
                   "dlCarFreqNr": "2059867", "idleMMNrCelResWeight": "100"}),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1/NRMOIMP_SA-1',
         p_name='idleMMEnDcSteeringPercentageOfUes', value='100'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1/NRMOIMP_SA-1',
         p_name='idleMMEnDcSteeringWRREnabled', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1/NRMOIMP_SA-1',
         p_name='idleMMSteeringAlgo', value='non CA aware'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1/NRMOIMP_SA-1',
         p_name='idleMMSteeringPercentageOfUes', value='100'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRMOPR_SA-1/NRMOIMP_SA-1', p_name='idleMMSteeringWRREnabled', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1' + '/NRIAFIM-1',
         version='NRBTSCL23R4_2315_10', class_name='com.nokia.srbts.nrbts:NRIAFIM'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1',
         p_name='numberOfTransmittedSsBlocks', value='32 beams'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='qQualMin', value='-14'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='qRxLevMin', value='-50'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sIntraSearchP', value='22'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sIntraSearchQ', value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sfHigh', value='oDot75'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sfMedium', value='oDot25'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='tReselectionNr', value='2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1' + '/NRIRFIM-1',
         version='NRBTSCL23R4_2315_10', class_name='com.nokia.srbts.nrbts:NRIRFIM'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='cellReselectionPriority', value='6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1',
         p_name='cellReselectionSubPriority', value='oDot8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='dlCarrierFreq', value='2058139'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='dssCellsDeployed', value='false'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='freqBandIndicatorNR', value='258'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='idleMMNrCelResWeight', value='100'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1',
         p_name='numberOfTransmittedSsBlocks', value='32 beams'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='pMaxInterFreq', value='23'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='qOffsetFreq', value='0dB'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='qRxLevMin', value='-60'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='ssbScs', value='240 KHz'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='tReselectionNr', value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='threshXHighP', value='10'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='threshXLowP', value='6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1' + '/NRIRFIM-2',
         version='NRBTSCL23R4_2315_10', class_name='com.nokia.srbts.nrbts:NRIRFIM'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='cellReselectionPriority', value='6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2',
         p_name='cellReselectionSubPriority', value='oDot8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='dlCarrierFreq', value='2059867'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='dssCellsDeployed', value='false'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='freqBandIndicatorNR', value='258'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='idleMMNrCelResWeight', value='100'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2',
         p_name='numberOfTransmittedSsBlocks', value='32 beams'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='pMaxInterFreq', value='23'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='qOffsetFreq', value='0dB'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='qRxLevMin', value='-60'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='ssbScs', value='240 KHz'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='tReselectionNr', value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='threshXHighP', value='10'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2', p_name='threshXLowP', value='6'),
    dict(dist_name=NRCELL_1TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_1TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_1TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_1TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
    dict(dist_name=NRCELL_2TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_2TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_2TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_2TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
    dict(dist_name=NRCELL_3TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_3TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_3TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_3TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
    dict(dist_name=NRCELL_4TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_4TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_4TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_4TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
    dict(dist_name=NRCELL_5TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_5TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_5TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_5TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
    dict(dist_name=NRCELL_6TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_6TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_6TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_6TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
    dict(dist_name=NRCELL_7TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_7TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_7TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_7TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
    dict(dist_name=NRCELL_8TH, p_name='nrDefMoPrSaDN', value=MR_NR_BTS_NAME + '/NRMOPR_SA-1'),
    dict(dist_name=NRCELL_8TH, list_name='a1MeashoSsbRsrqSA',
         elements={"a1HysteresishoSsbRsrqSA": "0", "a1HysteresisHoSsbRsrqVoNr": "0",
                   "a1ThresholdhoSsbRsrqSA": "63", "a1ThresholdHoSsbRsrqVoNr": "63",
                   "a1TimeToTriggerhoSsbRsrqSA": "ms480", "a1TimeToTriggerHoSsbRsrqVoNr": "ms480"}),
    dict(dist_name=NRCELL_8TH, list_name='a2MeasRedirectSsbRsrp',
         elements={"a2HysteresisRedirectSsbRsrp": "0", "a2ThresholdRedirectSsbRsrp": "34",
                   "a2TimeToTriggerRedirectSsbRsrp": "ms480"}),
    dict(dist_name=NRCELL_8TH, list_name='a2MeasRedirectSsbRsrq',
         elements={"a2HysteresisRedirectSsbRsrq": "0", "a2ThresholdRedirectSsbRsrq": "31",
                   "a2TimeToTriggerRedirectSsbRsrq": "ms480"}),
]

ENABLE_PCMD_CELL_TRACE_REPORT = [
    dict(dist_name=MR_NR_BTS_NAME, p_name='actPCMDReport', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='actSubscriberTraceReport', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, p_name='actCellTraceReport', value='true'),
]

ADD_SCF_PCMD_TRACE_REPORT = [
    dict(dist_name=MR_BTS_NAME + '/MNL-1/TCEADM-1',
         version='MNL23R4_2315_100', class_name='com.nokia.srbts.mnl:TCEADM'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/TCEADM-1/TCE-1',
         version='MNL23R4_2315_100', class_name='com.nokia.srbts.mnl:TCE'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/TCEADM-1/TCE-1', p_name='certTypeForTlsAuth', value='RSA'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/TCEADM-1/TCE-1', p_name='tceIdentifier', value='1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/TCEADM-1/TCE-1', p_name='tceIpAddress', value='10.57.167.186'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/TCEADM-1/TCE-1', p_name='tcePortNumber', value='49151'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/TCEADM-1/TCE-1', p_name='tlsEnabled', value='false'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1',
         version='NRBTSCL23R4_2315_100', class_name='com.nokia.srbts.nrbts:NRCTRLTS'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1',
         version='NRBTSCL23R4_2315_100', class_name='com.nokia.srbts.nrbts:NRMTRACECU'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='actCellTraceReportingCU', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='actPCMDReporting', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='cellMaxActiveUEsTraced', value='100'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='jobType', value='TraceOnly'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='nrTceIdentifier', value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='scope', value='allResources'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='traceNGAPSetting', value='all'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='traceNRRRCSetting', value='all'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='traceX2Setting', value='all'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='traceXNSetting', value='all'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', p_name='traceNRRRCSetting', value='all'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1', list_name='nrRanTraceReference',
         elements={"mcc": "262", "mnc": "3", "mncLength": "2", "traceId": "1"}),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1',
         version='NRBTSCL23R4_2315_100', class_name='com.nokia.srbts.nrbts:NRCTRLTSDU'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1',
         version='NRBTSCL23R4_2315_100', class_name='com.nokia.srbts.nrbts:NRMTRACEDU'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', p_name='actPCMDReporting', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', p_name='actRIReporting', value='false'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', p_name='cellMaxActiveUEsTraced', value='100'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', p_name='jobType', value='TraceOnly'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', p_name='nrTceIdentifier', value='1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', p_name='riReportInterval', value='s5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', p_name='scope', value='allResources'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1', list_name='nrRanTraceReference',
         elements={"mcc": "262", "mnc": "3", "mncLength": "2", "traceId": "1"}),
]
