from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_global_bts_id = str(tl.gnbs[0].global_bts_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_global_bts_id
_NRBTSnames = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_NRCELL11 = _NRBTSname+'/NRCELL-1'
_NRCELL12 = _NRBTSname+'/NRCELL-2'
_NRCELL13 = _NRBTSname+'/NRCELL-3'
_DRB_4 = _NRBTSname+'/NRDRB-4'
_DRB_5 = _NRBTSname+'/NRDRB-5'
_DRB_6 = _NRBTSname+'/NRDRB-6'
_DRB_12 = _NRBTSname+'/NRDRB-12'
_DRB_13 = _NRBTSname+'/NRDRB-13'
_DRB_14 = _NRBTSname+'/NRDRB-14'

_SERVEDAMF_1 = _NRBTSname + '/SERVEDAMF-1'
_NRPLMNSET_NSA_1 = _NRCELL11 + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA_2 = _NRCELL12 + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA_3 = _NRCELL13 + '/NRPLMNSET_NSA-1'
_NRPLMN_1 = _NRBTSname + '/NRPLMN-1'
_NRPLMN_2 = _NRBTSname + '/NRPLMN-2'

ParamterToModify_A = [
    dict(value='false', dist_name=_NRCELL11, p_name='actNbrForNonGbrBearers'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_A11 = [
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='263000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrDlHarq'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrUlHarqOne'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrCaDu')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_A11_24R2 = [
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='263', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrDlHarq'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrUlHarqOne'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrCaDu')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_E01 = [
    dict(value='158000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value=[dict(maxQuota='60', minQuota='10')],
         dist_name=_NRBTSname + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1', parameter='schedulerParams'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='45', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_E01_24R2 = [
    dict(value='158', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value=[dict(maxQuota='60', minQuota='10')],
         dist_name=_NRBTSname + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1', parameter='schedulerParams'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='45', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_EA01 = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='45', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
]

PARAMETERS_TO_ONLINE_RECOVER_GNB1_A11 = [
    dict(value='Unlocked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value=[dict(maxQuota='100', minQuota='10')],
         dist_name=_NRBTSname + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1', parameter='schedulerParams'),
]

Modify_Para_AMF_Unlock = [
    {'dist_name': _SERVEDAMF_1, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

Modify_Para_AMF_Lock = [
    {'dist_name': _SERVEDAMF_1, 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_ONLINE_ADD_GNB1_nsaDrbParam = [
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB_4, parameter='nsaDrbParam'),
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB_5, parameter='nsaDrbParam'),
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB_6, parameter='nsaDrbParam'),
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB_12, parameter='nsaDrbParam'),
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB_13, parameter='nsaDrbParam'),
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB_14, parameter='nsaDrbParam')
]

PARAMETERS_TO_DELETE_GNB1_nsaDrbParam = [
    dict(dist_name=_DRB_4, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_5, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_6, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_12, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_13, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_14, parameter='nsaDrbParam')
]

counter_id_D01_gNB1 = [
    'M55300C12010', 'M55370C00041', 'M55316C01003'
]

counter_dic_path_D01_gNB1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NDLHQ',
    'BTS/' + _NRBTSname + '/NRCELL-1/NULH',
    'BTS/' + _NRBTSname + '/NRCELL-1/NCADU',
]

Modify_Online_Para_SA_C03 = [
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-12', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-13', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-14', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-12', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-13', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-14', parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='315000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='Unlocked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
]

Modify_Online_Para_SA_C03_1 = [
    dict(value='0', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='false', dist_name=_NRCELL11, parameter='actPriorityAccess')
]

Modify_Online_Para_SA_C03_2 = [
    dict(value='1', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='false', dist_name=_NRCELL11, parameter='actPriorityAccess')
]

Modify_Online_Para_SA_C03_3 = [
    dict(value='1', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='true', dist_name=_NRCELL11, parameter='actPriorityAccess'),
    dict(value='HPA', dist_name=_NRBTSname, parameter='applyPriorityAccess')
]

counter_id_C_gNB1_maxNumOfNbrBearers = [
    'M55139C03506', 'M55139C03507', 'M55139C03508'
]

counter_dic_path_C_gNB1_maxNumOfNbrBearers = [
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU'
]

counter_id_C_gNB1_NBR = [
    'M55139C03509', 'M55139C03510', 'M55139C03511'
]

counter_dic_path_C_gNB1_NBR = [
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU'
]

Modify_Para_Online_D01 = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-1', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='50', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='158000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='arpPrioPerVul', dist_name=_NRCELL11, parameter='congWeightAlg'),
    dict(value='70', dist_name=_DRB_4, parameter='priorityLevel'),
    dict(value='80', dist_name=_DRB_5, parameter='priorityLevel'),
    dict(value='90', dist_name=_DRB_6, parameter='priorityLevel'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrDlHarq'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrUlHarqOne'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrCaDu')
]

ParameterToDelete_D01 = [
    dict(dist_name=_NRCELL11, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
]

Modify_Para_Online_D01_1 = [
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit')
]

Modify_Para_Online_D01_2 = [
    dict(value='0', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl')
]

Modify_Para_Online_D01_and_DA = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-1', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit')
]

Modify_Para_Online_DA = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='10', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit')
]

Modify_Para_Online_D01_Restore = [
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='Unlocked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
]
