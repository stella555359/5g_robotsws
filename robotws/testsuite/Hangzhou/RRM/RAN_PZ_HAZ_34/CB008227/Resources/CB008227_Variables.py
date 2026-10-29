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

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSnames2 = 'NRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id

_NRCELL11 = _NRBTSname+'/NRCELL-1'
_NRCELL12 = _NRBTSname+'/NRCELL-2'
_NRCELL13 = _NRBTSname+'/NRCELL-3'
_DRB_4 = _NRBTSname+'/NRDRB-4'
_DRB_5 = _NRBTSname+'/NRDRB-5'
_DRB_6 = _NRBTSname+'/NRDRB-6'

_NRCELL22 = _NRBTSname2 + '/NRCELL-2'
_NRCELL23 = _NRBTSname2 + '/NRCELL-3'
_DRB2_4 = _NRBTSname2+'/NRDRB-4'
_DRB2_5 = _NRBTSname2+'/NRDRB-5'
_DRB2_6 = _NRBTSname2+'/NRDRB-6'
_SERVEDAMF_1 = _NRBTSname + '/SERVEDAMF-1'
_SERVEDAMF_2 = _NRBTSname2 + '/SERVEDAMF-1'
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
    dict(value='60', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_E01_24R2 = [
    dict(value='158', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value=[dict(maxQuota='60', minQuota='10')],
         dist_name=_NRBTSname + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1', parameter='schedulerParams'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='60', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_EA01 = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='60', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
]

PARAMETERS_TO_ONLINE_RECOVER_GNB1_A11 = [
    dict(value='Unlocked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value=[dict(maxQuota='100', minQuota='10')],
         dist_name=_NRBTSname + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1', parameter='schedulerParams'),
]

PARAMETERS_TO_MODIFY_GNB1_B = [
    dict(value='false', dist_name=_NRCELL11, p_name='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL11, p_name='actAdaptiveReTxResMcsEnh'),
]

ParamterToModify_CB008227_B02 = [
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='210000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='32000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-4', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-6', parameter='schedulWeight'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='Locked', dist_name=_SERVEDAMF_1, parameter='administrativeState')
]

ParamterToModify_CB008227_B02_24R2 = [
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='210', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='32', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-4', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-6', parameter='schedulWeight'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='Locked', dist_name=_SERVEDAMF_1, parameter='administrativeState')
]

Modify_Para_AMF_Unlock = [
    {'dist_name': _SERVEDAMF_1, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

Modify_Para_AMF_Lock = [
    {'dist_name': _SERVEDAMF_1, 'parameter': 'administrativeState', 'value': 'Locked'}
]

Modify_Online_Para_SA_B04 = [
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-14', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-12', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-14', parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='210000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='32000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='Unlocked', dist_name=_SERVEDAMF_1, parameter='administrativeState')
]

Modify_Online_Para_SA_B04_24R2 = [
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-14', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-12', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-14', parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='210', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='32', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='Unlocked', dist_name=_SERVEDAMF_1, parameter='administrativeState')
]

counter_id_B02_gNB1 = [
    'M55115C03509', 'M55115C03510', 'M55115C03511'
]

counter_dic_path_B02_gNB1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/RACDU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RACDU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RACDU',
]

counter_dic_path_C13_gNB2 = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RACDU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RACDU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RACDU',
]

PARAMETERS_TO_MODIFY_GNB2_C = [
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=_NRCELL22, p_name='dlMimoMode'),
]

Parameter_Delete_GNB2_C = [
    dict(dist_name=_NRCELL22, list_name='periodicCsiAcquisition')
]

LIST_TO_ADD_GNB2_C = [
    dict(
        dist_name=_NRCELL22,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
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
    dict(value='263000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='-43', dist_name=_NRCELL11, parameter='qRxLevMin'),
]

Modify_Online_Para_SA_C03_24R2 = [
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
    dict(value='263', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='-43', dist_name=_NRCELL11, parameter='qRxLevMin'),
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

counter_dic_path_C_gNB2_maxNumOfNbrBearers = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RSADU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RSADU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RSADU'
]

counter_id_C_gNB1_maxNumOfNbrBearers_NSA = [
    'M55115C03506', 'M55115C03507', 'M55115C03508'
]

counter_dic_path_C_gNB1_maxNumOfNbrBearers_NSA = [
    'BTS/' + _NRBTSname + '/NRCELL-1/RACDU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RACDU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RACDU'
]

counter_dic_path_C_gNB2_maxNumOfNbrBearers_NSA = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RACDU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RACDU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RACDU'
]

counter_id_C_gNB1_NBR = [
    'M55139C03509', 'M55139C03510', 'M55139C03511'
]

counter_dic_path_C_gNB1_NBR = [
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU',
    'BTS/' + _NRBTSname + '/NRCELL-1/RSADU'
]

counter_dic_path_C_gNB2_NBR = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RSADU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RSADU',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/RSADU'
]

Modify_Online_Para_SA_C12_gnb1 = [
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-12', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-2', dist_name=_NRBTSname + '/NRDRB-13', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-14', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-12', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-13', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-14', parameter='schedulWeight'),
    dict(value='70', dist_name=_NRBTSname + '/NRDRB-12', parameter='priorityLevel'),
    dict(value='80', dist_name=_NRBTSname + '/NRDRB-13', parameter='priorityLevel'),
    dict(value='90', dist_name=_NRBTSname + '/NRDRB-14', parameter='priorityLevel'),
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='158000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='-43', dist_name=_NRCELL11, parameter='qRxLevMin'),
]

Modify_Online_Para_SA_C12_gnb1_24R2 = [
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-12', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-2', dist_name=_NRBTSname + '/NRDRB-13', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-14', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-12', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-13', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-14', parameter='schedulWeight'),
    dict(value='70', dist_name=_NRBTSname + '/NRDRB-12', parameter='priorityLevel'),
    dict(value='80', dist_name=_NRBTSname + '/NRDRB-13', parameter='priorityLevel'),
    dict(value='90', dist_name=_NRBTSname + '/NRDRB-14', parameter='priorityLevel'),
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='158', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='-43', dist_name=_NRCELL11, parameter='qRxLevMin'),
]

Modify_Online_Para_SA_C12_gnb2 = [
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-12', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-2', dist_name=_NRBTSname2 + '/NRDRB-13', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-14', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-12', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-13', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-14', parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL22, parameter='actNbrForNonGbrBearers'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxNbrTrafficLimit'),
    dict(value='1', dist_name=_NRCELL22, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPuschCongHandling'),
    dict(value='158000', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35000', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRSADU'),
]

Modify_Online_Para_SA_C12_gnb2_24R2 = [
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-12', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-2', dist_name=_NRBTSname2 + '/NRDRB-13', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-14', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-12', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-13', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-14', parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL22, parameter='actNbrForNonGbrBearers'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxNbrTrafficLimit'),
    dict(value='1', dist_name=_NRCELL22, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPuschCongHandling'),
    dict(value='158', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRSADU'),
]

Modify_Online_Para_SA_C12_recover = [
    dict(value='80', dist_name=_NRCELL22, parameter='maxNumOfNbrBearers'),
]

Modify_Online_Para_NSA_C13_gnb1 = [
    dict(value='Locked', dist_name=_SERVEDAMF_1, parameter='administrativeState'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-1', dist_name=_NRBTSname + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-4', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-5', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-6', parameter='schedulWeight'),
    dict(value='70', dist_name=_NRBTSname + '/NRDRB-4', parameter='priorityLevel'),
    dict(value='80', dist_name=_NRBTSname + '/NRDRB-5', parameter='priorityLevel'),
    dict(value='90', dist_name=_NRBTSname + '/NRDRB-6', parameter='priorityLevel'),
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='158000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrInterGnbMobilityCellCuNsa'),
    dict(value='-43', dist_name=_NRCELL11, parameter='qRxLevMin'),
]

Modify_Online_Para_NSA_C13_gnb1_24R2 = [
    dict(value='Locked', dist_name=_SERVEDAMF_1, parameter='administrativeState'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-1', dist_name=_NRBTSname + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-4', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-5', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB-6', parameter='schedulWeight'),
    dict(value='70', dist_name=_NRBTSname + '/NRDRB-4', parameter='priorityLevel'),
    dict(value='80', dist_name=_NRBTSname + '/NRDRB-5', parameter='priorityLevel'),
    dict(value='90', dist_name=_NRBTSname + '/NRDRB-6', parameter='priorityLevel'),
    dict(value='true', dist_name=_NRCELL11, parameter='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='158', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', parameter='miNrInterGnbMobilityCellCuNsa'),
    dict(value='-43', dist_name=_NRCELL11, parameter='qRxLevMin'),
]

Modify_Online_Para_NSA_C13_gnb2 = [
    dict(value='Locked', dist_name=_SERVEDAMF_2, parameter='administrativeState'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-1', dist_name=_NRBTSname2 + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-4', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-5', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-6', parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL22, parameter='actNbrForNonGbrBearers'),
    dict(value='1', dist_name=_NRCELL22, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxNbrTrafficLimit'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPuschCongHandling'),
    dict(value='158000', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35000', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrInterGnbMobilityCellCuNsa'),
]

Modify_Online_Para_NSA_C13_gnb2_24R2 = [
    dict(value='Locked', dist_name=_SERVEDAMF_2, parameter='administrativeState'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-1', dist_name=_NRBTSname2 + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname2 + '/NRDRB_MAC-7', dist_name=_NRBTSname2 + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-4', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-5', parameter='schedulWeight'),
    dict(value='10', dist_name=_NRBTSname2 + '/NRDRB-6', parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL22, parameter='actNbrForNonGbrBearers'),
    dict(value='1', dist_name=_NRCELL22, parameter='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxNbrTrafficLimit'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL22, parameter='nbrPuschCongHandling'),
    dict(value='158', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='35', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrRacDu'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', parameter='miNrInterGnbMobilityCellCuNsa'),
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
         dist_name=_DRB_6, parameter='nsaDrbParam')
]

PARAMETERS_TO_DELETE_GNB1_nsaDrbParam = [
    dict(dist_name=_DRB_4, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_5, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_6, parameter='nsaDrbParam')
]

PARAMETERS_TO_ONLINE_ADD_GNB2_nsaDrbParam = [
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB2_4, parameter='nsaDrbParam'),
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB2_5, parameter='nsaDrbParam'),
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB2_6, parameter='nsaDrbParam')
]

PARAMETERS_TO_DELETE_GNB2_nsaDrbParam = [
    dict(dist_name=_DRB2_4, parameter='nsaDrbParam'),
    dict(dist_name=_DRB2_5, parameter='nsaDrbParam'),
    dict(dist_name=_DRB2_6, parameter='nsaDrbParam')
]

Modify_Online_Para_NSA_C13_gnb1_recover = [
    dict(value='Unlocked', dist_name=_SERVEDAMF_1, parameter='administrativeState')
]

Modify_Online_Para_NSA_C13_gnb2_recover = [
    dict(value='Unlocked', dist_name=_SERVEDAMF_2, parameter='administrativeState'),
    dict(value='0', dist_name=_NRCELL22, parameter='maxNumOfNbrBearers'),
]

counter_id_NSA_HO = [
    'M55112C08001', 'M55112C02501', 'M55176C00001'
]

dic_path_NSA_HO = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NIEGM'
]

PARAMETERS_TO_MODIFY_GNB1_D = [
    dict(value='true', dist_name=_NRCELL11, p_name='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, p_name='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, p_name='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPuschCongHandling'),
    dict(value='ms100', dist_name=_NRCELL11, p_name='congDetectPeriod'),
    dict(value='arpPrioPerVul', dist_name=_NRCELL11, p_name='congWeightAlg'),
    dict(value='70', dist_name=_DRB_4, p_name='priorityLevel'),
    dict(value='80', dist_name=_DRB_5, p_name='priorityLevel'),
    dict(value='90', dist_name=_DRB_6, p_name='priorityLevel'),
    dict(value='90', dist_name=_NRCELL11, p_name='maxNbrTrafficLimit'),
    dict(value='0', dist_name=_NRCELL11, p_name='maxGBRTrafficLimit'),
    dict(value='210000', dist_name=_NRBTSname + '/NRDRB_MAC-7', p_name='nbrDl'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', p_name='nrDrbMacDN'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrDlHarq'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrUlHarqOne'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrCaDu')
]

PARAMETERS_TO_MODIFY_GNB1_D_24R2 = [
    dict(value='true', dist_name=_NRCELL11, p_name='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL11, p_name='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL11, p_name='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, p_name='nbrPuschCongHandling'),
    dict(value='ms100', dist_name=_NRCELL11, p_name='congDetectPeriod'),
    dict(value='arpPrioPerVul', dist_name=_NRCELL11, p_name='congWeightAlg'),
    dict(value='70', dist_name=_DRB_4, p_name='priorityLevel'),
    dict(value='80', dist_name=_DRB_5, p_name='priorityLevel'),
    dict(value='90', dist_name=_DRB_6, p_name='priorityLevel'),
    dict(value='90', dist_name=_NRCELL11, p_name='maxNbrTrafficLimit'),
    dict(value='0', dist_name=_NRCELL11, p_name='maxGBRTrafficLimit'),
    dict(value='210', dist_name=_NRBTSname + '/NRDRB_MAC-7', p_name='nbrDl'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-6', p_name='nrDrbMacDN'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrDlHarq'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrUlHarqOne'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrCaDu')
]

PARAMETERS_TO_ONLINE_ADD_GNB1_nsaDrbParam_D = [
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
         dist_name=_DRB_6, parameter='nsaDrbParam')
]

PARAMETERS_TO_DELETE_GNB1_nsaDrbParam_D = [
    dict(dist_name=_DRB_4, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_5, parameter='nsaDrbParam'),
    dict(dist_name=_DRB_6, parameter='nsaDrbParam')
]

Modify_Para_Online_D01 = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-1', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='50', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='158000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
]

Modify_Para_Online_D01_24R2 = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-4', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-5', parameter='nrDrbMacDN'),
    dict(value=_NRBTSname + '/NRDRB_MAC-1', dist_name=_NRBTSname + '/NRDRB-6', parameter='nrDrbMacDN'),
    dict(value='50', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='158', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrDl'),
]

ParameterToDelete_D01 = [
    dict(dist_name=_NRCELL11, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
]

Modify_Para_Online_D01_1 = [
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit')
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

Modify_Para_Online_D01_2 = [
    dict(value='0', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl')
]

Modify_Para_Online_D01_Restore = [
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='Unlocked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState'),

]

Delete_Para_Online_D01_Restore = [
    {'dist_name': _NRBTSname + '/NRDRB_MAC-7', 'parameter': 'nbrDl'}
]

Modify_Para_Online_DA = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='10', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit')
]

Modify_Para_Online_D02 = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='priorityLevel', dist_name=_NRCELL11, parameter='congWeightAlg'),
    dict(value='32000', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='30', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState')
]

Modify_Para_Online_D02_24R2 = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='priorityLevel', dist_name=_NRCELL11, parameter='congWeightAlg'),
    dict(value='32', dist_name=_NRBTSname + '/NRDRB_MAC-7', parameter='nbrUl'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='30', dist_name=_NRCELL11, parameter='maxPrbsPerNbrUe'),
    dict(value='Locked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState')
]

Modify_Para_Online_D02_and_DA = [
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingDl'),
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPdcchCongHandlingUl'),
    dict(value='true', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit')
]

Modify_Para_Online_D02_Restore = [
    dict(value='false', dist_name=_NRCELL11, parameter='nbrPuschCongHandling'),
    dict(value='90', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
    dict(value='Unlocked', dist_name=_NRBTSname + '/SERVEDAMF-1', parameter='administrativeState')
]

Modify_Online_Para_NSA_E003_gnb2 = [
    dict(value='30', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
    dict(value='90', dist_name=_NRCELL23, parameter='maxPrbsPerNbrUe'),
    dict(value='Locked', dist_name=_NRBTSname2 + '/SERVEDAMF-1', parameter='administrativeState')
]

Modify_Online_Para_NSA_E003_gnb2_1 = [
    dict(value='90', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
    dict(value='30', dist_name=_NRCELL23, parameter='maxPrbsPerNbrUe')
]

Modify_Online_Para_NSA_E003_gnb2_2 = [
    dict(value='50', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
    dict(value='50', dist_name=_NRCELL23, parameter='maxPrbsPerNbrUe')
]

Modify_Online_Para_NSA_E003_gnb2_A2release = [
    dict(value='covBasedA1', dist_name=_NRCELL22 + '/NRREL-1', parameter='sCellAdditionMethod'),
    dict(value='210000', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
]

Modify_Online_Para_NSA_E003_gnb2_A2release_24R2 = [
    dict(value='covBasedA1', dist_name=_NRCELL22 + '/NRREL-1', parameter='sCellAdditionMethod'),
    dict(value='210', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='90', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
]

Modify_Online_Para_NSA_E003_gnb2_3 = [
    dict(value='105000', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='105000', dist_name=_NRBTSname2 + '/NRDRB_MAC-12', parameter='nbrDl'),
    dict(value='blind', dist_name=_NRCELL22 + '/NRREL-1', parameter='sCellAdditionMethod'),
    dict(value='50', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
]

Modify_Online_Para_NSA_E003_gnb2_3_24R2 = [
    dict(value='105', dist_name=_NRBTSname2 + '/NRDRB_MAC-7', parameter='nbrDl'),
    dict(value='105', dist_name=_NRBTSname2 + '/NRDRB_MAC-12', parameter='nbrDl'),
    dict(value='blind', dist_name=_NRCELL22 + '/NRREL-1', parameter='sCellAdditionMethod'),
    dict(value='50', dist_name=_NRCELL22, parameter='maxPrbsPerNbrUe'),
]

Modify_Online_Para_NSA_E003_gnb2_4 = [
    dict(value='Unlocked', dist_name=_NRBTSname2 + '/SERVEDAMF-1', parameter='administrativeState')
]

counter_id_D01_gNB1 = [
    'M55300C12010', 'M55370C00041', 'M55316C01003'
]

counter_dic_path_D01_gNB1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NDLHQ',
    'BTS/' + _NRBTSname + '/NRCELL-1/NULH',
    'BTS/' + _NRBTSname + '/NRCELL-1/NCADU',
]

counter_dic_path_E007_gNB2 = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/NDLHQ',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/NULH',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/NCADU',
]

counter_id_D02_gNB1 = [
    'M55370C00041', 'M55300C12010', 'M55316C01002'
]

counter_dic_path_D02_gNB1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NULH',
    'BTS/' + _NRBTSname + '/NRCELL-1/NDLHQ',
    'BTS/' + _NRBTSname + '/NRCELL-1/NCADU',
]

counter_id_E03_gNB1 = [
    'M55116C00015'
]

counter_dic_path_E03_gNB1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NNSAUE'
]

Swconfig_8227_EA = [
    '0x580928=1'
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1 = [
    dict(value='55', dist_name=_NRCELL11, parameter='maxNbrTrafficLimit'),
]
