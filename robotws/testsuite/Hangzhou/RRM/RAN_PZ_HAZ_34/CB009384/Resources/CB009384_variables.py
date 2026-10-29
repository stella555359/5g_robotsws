from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'zhang qingqing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'qingqing.zhang@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSnames = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSnames2 = 'NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id

_enb_id = str(tl.enbs[0].instance_id)
_MRBTSname_enb = 'MRBTS-'+_enb_id
_NRBTSname_enb = _MRBTSname_enb+'/LNBTS-'+_enb_id

BTSnameEnb = [_NRBTSname_enb]

_NRCELL11 = _NRBTSname+'/NRCELL-1'
_NRCELL12 = _NRBTSname+'/NRCELL-2'
_NRCELL13 = _NRBTSname+'/NRCELL-3'

_NRREL11 = _NRCELL11+'/NRREL-1'
_NRREL12 = _NRCELL12+'/NRREL-1'
_NRREL13 = _NRCELL13+'/NRREL-1'

_NRCELL21 = _NRBTSname2+'/NRCELL-1'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'

_NRREL21 = _NRCELL21+'/NRREL-1'
_NRREL22 = _NRCELL22+'/NRREL-1'

_PDCP12 = _NRBTSname+'/NRDRB_PDCP-2'
_PDCP22 = _NRBTSname2+'/NRDRB_PDCP-2'

_RLCAM12 = _NRBTSname+'/NRDRB_RLC_AM-2'
_RLCAM22 = _NRBTSname2+'/NRDRB_RLC_AM-2'

_NRDRB12name = _NRBTSname+'/NRDRB-12'
_alSelection_20 = _NRBTSname+'/BWP_PROFILE-20'
_alSelection_21 = _NRBTSname+'/BWP_PROFILE-21'
_BWP_PROFILE_20 = _alSelection_20+'/PDCCH-1'
_BWP_PROFILE_21 = _alSelection_21+'/PDCCH-1'

PARAM_8246_gnb1_L_001 = [
    dict(value='true', dist_name=_NRCELL13, parameter='actLAForHiReliab'),
    dict(value='static', dist_name=_BWP_PROFILE_21, parameter='alSelection'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='AL4', dist_name=_BWP_PROFILE_20, parameter='dciDedicatedAggregationLevelHR'),
    dict(value='AL4', dist_name=_BWP_PROFILE_21, parameter='dciDedicatedAggregationLevelHR'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAMETERS_TO_MO_GNB1_A_18bit = [
    dict(value='true', dist_name=_NRCELL13, parameter='actRedCapUeSupport'),
    dict(value='len18bits', dist_name=_PDCP12, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm18bitSN', dist_name=_RLCAM12, parameter='rlcAMDrbSNLengthRedCap')
]

PARAMETERS_TO_MO_GNB1_A_18bit_gnb2 = [
    dict(value='true', dist_name=_NRCELL22, parameter='actRedCapUeSupport'),
    dict(value='len18bits', dist_name=_PDCP22, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm18bitSN', dist_name=_RLCAM22, parameter='rlcAMDrbSNLengthRedCap')
]

PARAMETERS_TO_MO_GNB1_A_12bit = [
    dict(value='true', dist_name=_NRCELL13, parameter='actRedCapUeSupport'),
    dict(value='len12bits', dist_name=_PDCP12, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm12bitSN', dist_name=_RLCAM12, parameter='rlcAMDrbSNLengthRedCap'),
    dict(value='viaRRCSetup', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
]

PARAMETERS_TO_MO_GNB2_RRE = [
    dict(value='viaRRCSetup', dist_name=_NRBTSname2, parameter='rrcReestabTypeSA'),
]

PARAMETERS_TO_MO_GNB1_A_12bit_gnb2 = [
    dict(value='true', dist_name=_NRCELL22, parameter='actRedCapUeSupport'),
    dict(value='len12bits', dist_name=_PDCP22, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm12bitSN', dist_name=_RLCAM22, parameter='rlcAMDrbSNLengthRedCap')
]

PARAMETERS_TO_MO_GNB1_grant = [
    dict(value='slots40', dist_name=_NRCELL13, parameter='srPeriodicityMin')
]

PARAMETERS_TO_MO_GNB1_maxNumOfRrcSARedCap = [
    dict(value='0', dist_name=_NRCELL13, parameter='maxNumOfRrcSARedCap')
]

PARAMETERS_TO_MO_GNB1_recover = [
    dict(value='200', dist_name=_NRCELL13, parameter='maxNumOfRrcSARedCap'),
    dict(value='slots5', dist_name=_NRCELL13, parameter='srPeriodicityMin')
]

PARAMETERS_TO_MO_GNB1_A_BBpooling_off = [
    dict(value='true', dist_name=_NRCELL13, parameter='actRedCapUeSupport'),
    dict(value='len18bits', dist_name=_PDCP12, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm18bitSN', dist_name=_RLCAM12, parameter='rlcAMDrbSNLengthRedCap'),
    dict(value='false', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh')
]

PARAMETERS_TO_MO_GNB1_A_BBpooling_on = [
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh')
]

PARAMETERS_TO_MO_GNB1_E12 = [
    dict(value='true', dist_name=_NRCELL13, p_name='actRedCapUeSupport'),
    dict(value='len18bits', dist_name=_PDCP12, p_name='pdcpSNLengthRedCap'),
    dict(value='rlcAm18bitSN', dist_name=_RLCAM12, p_name='rlcAMDrbSNLengthRedCap'),
    dict(value='30MHz', dist_name=_NRCELL13 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='30MHz', dist_name=_NRCELL13 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='true', dist_name=_NRCELL13, p_name='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL13, p_name='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL13, p_name='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPuschCongHandling'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-14', p_name='nrDrbMacDN'),
    dict(value='51000', dist_name=_NRBTSname + '/NRDRB_MAC-7', p_name='nbrDl'),
    dict(value='10000', dist_name=_NRBTSname + '/NRDRB_MAC-7', p_name='nbrUl'),
    dict(value='1', dist_name=_NRBTSname + '/NRDRB-14', p_name='schedulWeight'),
    dict(value='1', dist_name=_NRBTSname + '/NRDRB-16', p_name='schedulWeight')
]

PARAMETERS_TO_MO_GNB1_E12_24R2 = [
    dict(value='true', dist_name=_NRCELL13, p_name='actRedCapUeSupport'),
    dict(value='len18bits', dist_name=_PDCP12, p_name='pdcpSNLengthRedCap'),
    dict(value='rlcAm18bitSN', dist_name=_RLCAM12, p_name='rlcAMDrbSNLengthRedCap'),
    dict(value='30MHz', dist_name=_NRCELL13 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='30MHz', dist_name=_NRCELL13 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='true', dist_name=_NRCELL13, p_name='actNbrForNonGbrBearers'),
    dict(value='80', dist_name=_NRCELL13, p_name='maxNumOfNbrBearers'),
    dict(value='90', dist_name=_NRCELL13, p_name='maxPrbsPerNbrUe'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPdcchCongHandlingDl'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPdcchCongHandlingUl'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPdschCongHandling'),
    dict(value='false', dist_name=_NRCELL13, p_name='nbrPuschCongHandling'),
    dict(value=_NRBTSname + '/NRDRB_MAC-7', dist_name=_NRBTSname + '/NRDRB-14', p_name='nrDrbMacDN'),
    dict(value='51', dist_name=_NRBTSname + '/NRDRB_MAC-7', p_name='nbrDl'),
    dict(value='10', dist_name=_NRBTSname + '/NRDRB_MAC-7', p_name='nbrUl'),
    dict(value='1', dist_name=_NRBTSname + '/NRDRB-14', p_name='schedulWeight'),
    dict(value='1', dist_name=_NRBTSname + '/NRDRB-16', p_name='schedulWeight')
]

LIST_TO_ADD_GNB1_A_7225_SBTS24R1_ENB_0000 = [
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-30',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-31',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-310',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')
    )

]

LIST_TO_ADD_GNB1_A_7225 = [
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-30',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-31',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-310',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')
    )

]

LIST_TO_ADD_GNB1_A_7225_SBTS23R4_ENB_0000 = [
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-30',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-31',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL13,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-310',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')
    )

]

PARAMETERS_TO_DELETE_GNB1_A_BWP = [
    dict(dist_name=_NRCELL13, list_name='cellBwpList')
]

PARAMETERS_TO_MO_GNB1_A_20M = [
    dict(value='20MHz', dist_name=_NRCELL13 + '/NRCELL_FDD-1', parameter='chBwDl'),
    dict(value='20MHz', dist_name=_NRCELL13 + '/NRCELL_FDD-1', parameter='chBwUl')
]

PARAMETERS_TO_DEL_GNB1_A_20M = [
    {'dist_name': _NRCELL13, 'parameter': 'cellBwpList'}
]

PARAMETERS_TO_ADD_GNB1_A_20M_trunk = [
    dict(value=[dict(bwpDN=_NRBTSname + '/BWP_PROFILE-20', cellBwpId='0', pdcchResourcePreference='peakRate'),
                dict(bwpDN=_NRBTSname + '/BWP_PROFILE-21', cellBwpId='1', pdcchResourcePreference='peakRate')],
         dist_name=_NRCELL13, parameter='cellBwpList'),
]

PARAMETERS_TO_ADD_GNB1_A_20M = [
    dict(value=[dict(bwpDN=_NRBTSname + '/BWP_PROFILE-20', cellBwpId='0'),
                dict(bwpDN=_NRBTSname + '/BWP_PROFILE-21', cellBwpId='1')],
         dist_name=_NRCELL13, parameter='cellBwpList'),
]

counter_id_18bit = [
    'M55308C36003',
    'M55308C36004'
]

counter_dic_path_18bit = [
    'BTS/CELLS/NRCELL-3/NCELA',
    'BTS/CELLS/NRCELL-3/NCELA'
]

counter_dic_path_18bit_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA',
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA'
]

counter_id_12bit_1 = [
    'M55166C00011',
    'M55166C00012',
    'M55138C00057'
]

counter_dic_path_12bit_1 = [
    'BTS/CELLS/NRCELL-3/NRCCD',
    'BTS/CELLS/NRCELL-3/NRCCD',
    'BTS/CELLS/NRCELL-3/RSACU'
]

counter_dic_path_12bit_1_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTSname + '/NRCELL-3/RSACU'
]

counter_value_12bit_1 = [
    1,
    1,
    1
]

counter_id_12bit_0 = [
    'M55166C00014',
    'M55166C00015',
    'M55166C00016'
]

counter_dic_path_12bit_0 = [
    'BTS/CELLS/NRCELL-3/NRCCD',
    'BTS/CELLS/NRCELL-3/NRCCD',
    'BTS/CELLS/NRCELL-3/NRCCD'
]

counter_dic_path_12bit_0_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD'
]

counter_value_12bit_0 = [
    0,
    0,
    0
]

counter_id_12bit_release = [
    'M55166C00013'
]

counter_dic_path_12bit_release = [
    'BTS/CELLS/NRCELL-3/NRCCD'
]

counter_dic_path_12bit_release_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD'
]

counter_value_12bit_release = [
    1
]

counter_id_12bit_sum = [
    'M55138C00056'
]

counter_dic_path_12bit_sum = [
    'BTS/CELLS/NRCELL-3/RSACU'
]

counter_dic_path_12bit_sum_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/RSACU'
]

counter_id_attach_fail = [
    'M55166C00011',
    'M55166C00015'
]

counter_dic_path_attach_fail = [
    'BTS/CELLS/NRCELL-3/NRCCD',
    'BTS/CELLS/NRCELL-3/NRCCD'
]

counter_dic_path_attach_fail_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD'
]

counter_id_CGType2 = [
    'M55166C00005',
    'M55139C00017',
    'M55308C00020',
    'M55308C00021',
    'M55308C00022',
    'M55308C00023',
    'M55308C00026',
    'M55308C00032'
]

counter_dic_path_CGType2 = [
    'BTS/CELLS/NRCELL-3/NRCCD',
    'BTS/CELLS/NRCELL-3/RSADU',
    'BTS/CELLS/NRCELL-3/NCELA',
    'BTS/CELLS/NRCELL-3/NCELA',
    'BTS/CELLS/NRCELL-3/NCELA',
    'BTS/CELLS/NRCELL-3/NCELA',
    'BTS/CELLS/NRCELL-3/NCELA',
    'BTS/CELLS/NRCELL-3/NCELA'
]

counter_dic_path_CGType2_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTSname + '/NRCELL-3/RSADU',
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA',
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA',
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA',
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA',
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA',
    'BTS/' + _NRBTSname + '/NRCELL-3/NCELA'
]

counter_id_7552 = [
    'M55166C00001',
    'M55166C00003'
]

counter_dic_path_7552 = [
    'BTS/CELLS/NRCELL-3/NRCCD',
    'BTS/CELLS/NRCELL-3/NRCCD'
]

counter_dic_path_7552_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTSname + '/NRCELL-3/NRCCD'
]

counter_value_7552 = [
    1, 1
]

PARAMETERS_TO_MO_GNB1_B_NG_HO_12bit = [
    dict(value='true', dist_name=_NRCELL13, parameter='actRedCapUeSupport'),
    dict(value='len12bits', dist_name=_PDCP12, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm12bitSN', dist_name=_RLCAM12, parameter='rlcAMDrbSNLengthRedCap'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='XnHoNotAllowed', dist_name=_NRREL13, parameter='handoverAllowedSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward'),
    dict(value='false', dist_name=_NRBTSname, parameter='actMFBIEutra')
]

PARAMETERS_TO_MO_GNB1_B_NG_HO_12bit_gnb2 = [
    dict(value='true', dist_name=_NRCELL22, parameter='actRedCapUeSupport'),
    dict(value='len12bits', dist_name=_PDCP22, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm12bitSN', dist_name=_RLCAM22, parameter='rlcAMDrbSNLengthRedCap'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname2, parameter='actIntraNrNgHo'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterRatHoSA'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterRatHoSADlDataForward'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actMFBIEutra')
]

PARAMETERS_TO_MO_NGHO_recover = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='allowed', dist_name=_NRREL13, parameter='handoverAllowedSA')
]

PARAMETERS_TO_MO_NGHO_recover_gnb2 = [
    dict(value='disabled', dist_name=_NRBTSname2, parameter='actIntraNrNgHo')
]

PARAMETERS_TO_MO_GNB1_B_XN_HO_18bit = [
    dict(value='true', dist_name=_NRCELL13, parameter='actRedCapUeSupport'),
    dict(value='len18bits', dist_name=_PDCP12, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm18bitSN', dist_name=_RLCAM12, parameter='rlcAMDrbSNLengthRedCap'),
    dict(value='true', dist_name=_NRBTSname, parameter='includeRlcBearerToRelease')
]

PARAMETERS_TO_MO_GNB2_B_XN_HO_12bit = [
    dict(value='true', dist_name=_NRCELL22, parameter='actRedCapUeSupport'),
    dict(value='len12bits', dist_name=_PDCP22, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm12bitSN', dist_name=_RLCAM22, parameter='rlcAMDrbSNLengthRedCap'),
    dict(value='true', dist_name=_NRBTSname2, parameter='includeRlcBearerToRelease')
]

counter_id_XN_HO = [
    'M55178C00009',
    'M55178C00010',
    'M55178C00011'
]

counter_dic_path_XN_HO_gnb0 = [
    'BTS/CELLS/NRCELL-3/SIEXM',
    'BTS/CELLS/NRCELL-3/SIEXM',
    'BTS/CELLS/NRCELL-3/SIEXM'
]

counter_dic_path_XN_HO_gnb1 = [
    'BTS/CELLS/NRCELL-2/SIEXM',
    'BTS/CELLS/NRCELL-2/SIEXM',
    'BTS/CELLS/NRCELL-2/SIEXM'
]

counter_dic_path_XN_HO_gnb0_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/SIEXM',
    'BTS/' + _NRBTSname + '/NRCELL-3/SIEXM',
    'BTS/' + _NRBTSname + '/NRCELL-3/SIEXM'
]

counter_dic_path_XN_HO_gnb1_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/SIEXM',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/SIEXM',
    'BTS/' + _NRBTSname2 + '/NRCELL-2/SIEXM'
]

counter_value_XN_HO = [
    1,
    1,
    1
]
