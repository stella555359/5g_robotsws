from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_enb_id = str(tl.gnbs[0].instance_id + 10)
_MRBTSname = 'MRBTS-' + _global_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_LNBTSname = _MRBTSname + '/LNBTS-' + _enb_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRCELL2name = _NRBTSname + '/NRCELL-2'
_NRDRB15name = _NRBTSname + '/NRDRB-15'
_NRBTSDUname = _NRBTSname + '/NRDU-9999'
_NRBTSDUnameGRPgNB1cell = _NRBTSname + '/NRCELLGRP-1'
_NRPRIOACC_1 = _NRBTSname + '/NRPRIOACC_PROFILE-1'
_SERVEDAMF = _NRBTSname + '/SERVEDAMF-1'
_LTECELLname = _LNBTSname + '/LNCEL-4'
_NRMEASCFG_IR_1 = _NRBTSname + '/NRMEASCFG_IR-1'

_LTECELL48040name = _LNBTSname + '/LNCEL-48040'
_LTECELL48041name = _LNBTSname + '/LNCEL-48041'
_LTECELL48042name = _LNBTSname + '/LNCEL-48042'
_LTECELL48043name = _LNBTSname + '/LNCEL-48043'
_LTECELL48044name = _LNBTSname + '/LNCEL-48044'
_LTECELL48045name = _LNBTSname + '/LNCEL-48045'
_LTECELL48046name = _LNBTSname + '/LNCEL-48046'
_LTECELL48047name = _LNBTSname + '/LNCEL-48047'
_LTECELL48048name = _LNBTSname + '/LNCEL-48048'
_LTECELL48049name = _LNBTSname + '/LNCEL-48049'

_NRCELL400name = _NRBTSname + '/NRCELL-400'
_NRCELL410name = _NRBTSname + '/NRCELL-410'
_NRCELL544name = _NRBTSname + '/NRCELL-544'
_NRCELL545name = _NRBTSname + '/NRCELL-545'
_NRCELL644name = _NRBTSname + '/NRCELL-644'
_NRCELL645name = _NRBTSname + '/NRCELL-645'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'

_NRCELL400_FDD1 = _NRCELL400name + '/NRCELL_FDD-1'
_NRRELL400namegnb12 = _NRCELL400name + '/NRREL-2'

PATH_TO_SCF = ''

CB008200_ciphering_algorithms_json_file = 'CB008200_ciphering_algorithms.json'
CB008200_ciphering_algorithms = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')
                ]
            }
        ]
    }
]

CB008200_recover_ciphering_algorithms_json_file = 'CB008200_recover_ciphering_algorithms.json'
CB008200_recover_ciphering_algorithms = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')
                ]
            }
        ]
    }
]

PARAMS_TO_MODIFY_CB007564_01_1 = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n56'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Locked'),
]

PARAMS_TO_MODIFY_CB007564_01_1_recover = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n56'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Unlocked'),
]

PARAMS_TO_MODIFY_CB007564_05_1 = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n64'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Locked'),
]

PARAMS_TO_MODIFY_CB007564_05_1_recover = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n56'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Unlocked'),
]

PARAMETERS_TO_UPDATE_A01 = [
    dict(value='0', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
]

PARAMETERS_TO_UPDATE_A01_pre = [
    dict(value='10', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='0', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELLname, parameter='actGBRAdmissionControl'),
    dict(value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='1', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='emergencyCallFails'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    # dict(value='500', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    # dict(value='500', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value=[dict(nea1_128='9', nea2_128='3', nea3_128='3')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='3', nia3_128='3')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_A01_pre_recover = [
    dict(value='550', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='10', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='off', dist_name=_NRCELLname, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='emergencyCallFails'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    # dict(value='500', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    # dict(value='500', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value=[dict(nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAM_8200_B_WA_348 = [
    dict(value='unlocked', dist_name=_LTECELL48042name, parameter='administrativeState')
]
PARAM_8200_B_WA = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState')
]

PARAM_8200_B_001_348 = [
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    # dict(value='locked', dist_name=_LTECELL48042name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL544name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL644name, parameter='administrativeState'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actVonr40msProGrant'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actForcedDftSOfdmVonrUl'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL400name, parameter='voiceFBMode'),
    dict(value='dlSrbPowerBoost', dist_name=_NRCELL400name, parameter='actDlPowerBoost'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrxVoNR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actPriorityAccess'),
    dict(value='Disabled', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='off', dist_name=_NRCELL400name, parameter='actVoNrMobilityThresholds'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actVoipPacketAggr'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actMaxInitDeltaCqiClampVoNR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUlMinTbsForVoNR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actTargetBlerVoNR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actVoNRIncCodingGain'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actMcQosSupport'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL'),
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
]
PARAM_DELETE_8200_B_001_348 = [
    dict(dist_name=_NRCELL400name, parameter='n310VoNR'),
    dict(dist_name=_NRCELL400name, parameter='t310VoNR')
]
PARAM_8200_recover_B_001_348 = [
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    # dict(value='unlocked', dist_name=_LTECELL48042name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL544name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL644name, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actVonr40msProGrant'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actForcedDftSOfdmVonrUl'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL400name, parameter='voiceFBMode'),
    dict(value='dlVoNRAndSrbPowerBoost', dist_name=_NRCELL400name, parameter='actDlPowerBoost'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actPriorityAccess'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='VoNrMobilityThresholds', dist_name=_NRCELL400name, parameter='actVoNrMobilityThresholds'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actMaxInitDeltaCqiClampVoNR'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUlMinTbsForVoNR'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actTargetBlerVoNR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actVoNRIncCodingGain'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actMcQosSupport'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL'),
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n0', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
]
PARAM_ADD_8200_B_001_348 = [
    dict(value='n20', dist_name=_NRCELL400name, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELL400name, parameter='t310VoNR')
]

PARAM_recover_delete_gnb1_8200_B_001_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_8200_B_001 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward'),
    dict(value='false', dist_name=_NRCELLname, parameter='actVoipPacketAggr'),
    dict(value='deactivated', dist_name=_NRCELLname, parameter='actDataForwardingForVoNr'),
    dict(value='false', dist_name=_NRCELLname, parameter='actMaxInitDeltaCqiClampVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actTargetBlerVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actVoNRIncCodingGain'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]
PARAM_DELETE_8200_B_001 = [
    dict(dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(dist_name=_NRCELLname, parameter='t310VoNR')
]
PARAM_8200_recover_B_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoipPacketAggr'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]
PARAM_ADD_8200_B_001 = [
    dict(value='n10', dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELLname, parameter='t310VoNR')
]

PARAM_8200_B_003 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCDrxVoNR')
]
PARAM_DELETE_8200_B_003 = [
    dict(dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(dist_name=_NRCELLname, parameter='t310VoNR')
]
PARAM_8200_recover_B_003 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR')
]
PARAM_ADD_8200_B_003 = [
    dict(value='n10', dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELLname, parameter='t310VoNR')
]

PARAM_8200_B_007 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]
PARAM_8200_recover_B_007 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]

PARAM_EDA_04943472_CELL_ALL_64Qam_348 = [
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_LTECELL48040name, parameter='administrativeState', value='locked'),
    dict(dist_name=_LTECELL48045name, parameter='administrativeState', value='locked'),
    dict(dist_name=_NRCELL400name, parameter='actDl256Qam', value='false'),
    dict(dist_name=_NRCELL700name, parameter='actDl256Qam', value='false'),
    dict(dist_name=_NRCELL400name, parameter='actUl256Qam', value='false'),
    dict(dist_name=_NRCELL700name, parameter='actUl256Qam', value='false'),
    dict(dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget', value='false'),
    dict(dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget', value='false'),
]

PARAM_recover_EDA_04943472_CELL_ALL_64Qam_348 = [
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_LTECELL48040name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_LTECELL48045name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_NRCELL400name, parameter='actDl256Qam', value='true'),
    dict(dist_name=_NRCELL700name, parameter='actDl256Qam', value='true'),
    dict(dist_name=_NRCELL400name, parameter='actUl256Qam', value='true'),
    dict(dist_name=_NRCELL700name, parameter='actUl256Qam', value='true'),
    dict(dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget', value='true'),
    dict(dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget', value='true'),
]

PARAM_EDA_04943472_CELL_400_64Qam_348 = [
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_LTECELL48040name, parameter='administrativeState', value='locked'),
    dict(dist_name=_LTECELL48045name, parameter='administrativeState', value='locked'),
    dict(dist_name=_NRCELL400name, parameter='actDl256Qam', value='false'),
    dict(dist_name=_NRCELL400name, parameter='actUl256Qam', value='false'),
    dict(dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget', value='false'),
]

PARAM_recover_EDA_04943472_CELL_400_64Qam_348 = [
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_LTECELL48040name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_LTECELL48045name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_NRCELL400name, parameter='actDl256Qam', value='true'),
    dict(dist_name=_NRCELL400name, parameter='actUl256Qam', value='true'),
    dict(dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget', value='true'),
]

PARAM_EDA_04943472_CELL_700_64Qam_348 = [
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_LTECELL48040name, parameter='administrativeState', value='locked'),
    dict(dist_name=_LTECELL48045name, parameter='administrativeState', value='locked'),
    dict(dist_name=_NRCELL700name, parameter='actDl256Qam', value='false'),
    dict(dist_name=_NRCELL700name, parameter='actUl256Qam', value='false'),
    dict(dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget', value='false'),
]

PARAM_recover_EDA_04943472_CELL_700_64Qam_348 = [
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_LTECELL48040name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_LTECELL48045name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_NRCELL700name, parameter='actDl256Qam', value='true'),
    dict(dist_name=_NRCELL700name, parameter='actUl256Qam', value='true'),
    dict(dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget', value='true'),
]

PARAM_8200_B_011_348 = [
    dict(dist_name=_NRCELL544name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL644name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_LTECELL48043name, parameter='administrativeState', value='locked'),
    dict(dist_name=_LTECELL48044name, parameter='administrativeState', value='locked'),
    dict(dist_name=_NRCELL700name, parameter='a2MeasRedirectEnabled', value='none'),
    # CNI-136169 02396060 ADD 2025/12/23
    dict(dist_name=_NRCELL700name, parameter='actDlForceRankDowng', value='disabled'),
    dict(dist_name=_NRCELL700name, parameter='actDlVoNrLimMaxMcsAndLayer', value='true'),
    # CNI-136169 02396060 ADD 2025/12/23
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL')
]

PARAM_8200_B_011_EDA = [
    dict(value='true', dist_name=_NRBTSname, parameter='actEutranFreqBandFiltering'),
]

PARAM_8200_recover_B_011_EDA = [
    dict(value='false', dist_name=_NRBTSname, parameter='actEutranFreqBandFiltering'),
]

PARAM_8200_recover_B_011_348 = [
    dict(dist_name=_NRCELL544name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELL644name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_LTECELL48043name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_LTECELL48044name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_NRCELL700name, parameter='a2MeasRedirectEnabled', value='rsrp'),
    # CNI-136169 02396060 ADD 2025/12/23
    dict(dist_name=_NRCELL700name, parameter='actDlForceRankDowng', value='dlVoNROnly'),
    dict(dist_name=_NRCELL700name, parameter='actDlVoNrLimMaxMcsAndLayer', value='false'),
    # CNI-136169 02396060 ADD 2025/12/23
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL')
]

PARAM_8200_B_011 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8200_recover_B_011 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8200_B_013 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]
PARAM_8200_recover_B_013 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]

PARAM_8200_C_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam')
]
PARAM_8200_recover_C_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam')
]

PARAM_8200_D_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward')
]
PARAM_8200_recover_D_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward')
]

PARAM_8200_D_003 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actGnbInitRlf')
]
PARAM_8200_recover_D_003 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actGnbInitRlf')
]

PARAM_8200_E_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_8200_recover_E_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]

PARAM_707_348 = [
    dict(dist_name=_NRCELL544name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL644name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Locked'),
    dict(dist_name=_LTECELL48043name, parameter='administrativeState', value='locked'),
    dict(dist_name=_LTECELL48044name, parameter='administrativeState', value='locked'),
    dict(dist_name=_NRMEASCFG_IR_1, parameter='b2MeashoEnabled', value='rsrpCombined'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL')
]

PARAM_707_recover_348 = [
    dict(dist_name=_NRCELL544name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELL644name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELL701name, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_LTECELL48043name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_LTECELL48044name, parameter='administrativeState', value='unlocked'),
    dict(dist_name=_NRMEASCFG_IR_1, parameter='b2MeashoEnabled', value='rsrp'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL')
]

PARAM_707 = [
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_707_recover = [
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8700_A_021 = [
    dict(value='on', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='3', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA')
]

PARAM_8700_recover_A_021 = [
    dict(value='off', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='550', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA')
]

PARAM_6112_A_13 = [
    dict(value='drb', dist_name=_NRBTSname, parameter='activityNotificationLevelSA'),
]

PARAM_6112_recover_A_13 = [
    dict(value='ue', dist_name=_NRBTSname, parameter='activityNotificationLevelSA'),
]

PARAM_8698_A_001 = [
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfUsersPerCell'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_A_001 = [
    dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfUsersPerCell'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_ADD_8698_C_004 = [
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse'),
]
PARAM_8698_C_004 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='7', dist_name=_NRBTSDUnameGRPgNB1cell, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='false', dist_name=_NRCELLname, parameter='preferNsaPreemption'),
    dict(value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='10', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_DELETE_8698_C_004 = [
    dict(dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse')
]
PARAM_8698_recover_C_004 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='550', dist_name=_NRBTSDUnameGRPgNB1cell, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='true', dist_name=_NRCELLname, parameter='preferNsaPreemption'),
    dict(value='30', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

# _mcc = str(tl.core.mcc)
# _mnc = str(tl.core.mnc)
_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path1_348 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path1_348_400 = 'BTS/CELLS/NRCELL-400/NNGCC'
_ho_path1_c2 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path1_trunk = f'BTS/{_NRBTSname}/NRCELL-1/NNGCC'
_ho_path1_trunk_348 = f'BTS/{_NRBTSname}/NRCELL-400/NNGCC'
_ho_path700_trunk_348 = f'BTS/{_NRBTSname}/NRCELL-700/NNGCC'
_ho_path1_c2_trunk = f'BTS/{_NRBTSname}/NRCELL-2/NNGCC'
_ho_path12_trunk = f'BTS/{_NRBTSname2}/NRCELL-1/NNGCC'
_ho_path12_trunk_348 = f'BTS/{_NRBTSname2}/NRCELL-1/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path2_348 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path2_trunk_348 = f'BTS/{_NRBTSname}/NRCELL-400/NRPMQAP-1/NGCCQ'
_ho_path2_trunk = f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path22_trunk = f'BTS/{_NRBTSname2}/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path22_trunk_348 = f'BTS/{_NRBTSname2}/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path3_trunk = f'BTS/{_NRBTSname}/NRCELL-1/NRRCC'
_ho_path3_trunk_348 = f'BTS/{_NRBTSname}/NRCELL-400/NRRCC'
_ho_path4 = 'BTS/CELLS/NRCELL-3/NNGCC'
_ho_path4_trunk = f'BTS/{_NRBTSname}/NRCELL-3/NNGCC'
_ho_path4_trunk_348 = f'BTS/{_NRBTSname}/NRCELL-700/NNGCC'
_ho_path4_trunk_383 = f'BTS/{_NRBTSname}/NRCELL-2/NNGCC'
_ho_path5 = 'BTS/CELLS/NRCELL-3/NRPMQAP-1/NGCCQ'
_ho_path5_trunk = f'BTS/{_NRBTSname}/NRCELL-3/NRPMQAP-1/NGCCQ'
_ho_path5_trunk_348 = f'BTS/{_NRBTSname}/NRCELL-700/NRPMQAP-1/NGCCQ'
_ho_path5_trunk_383 = f'BTS/{_NRBTSname}/NRCELL-2/NRPMQAP-1/NGCCQ'
_ho_path6 = 'BTS/CELLS/NRCELL-1/NDLSQ'
_ho_path6_trunk = f'BTS/{_NRBTSname}/NRCELL-1/NDLSQ'
_SA_path = 'BTS/CELLS/NRCELL-1/RSACU'
_SA_path_trunk = f'BTS/{_NRBTSname}/NRCELL-1/RSACU'
_RACH = 'BTS/CELLS/NRCELL-1/NRACH'
_RACH_trunk = f'BTS/{_NRBTSname}/NRCELL-1/NRACH'

NG_FLOW_SETUP_FAIL_FALLBACK_348 = {'gnb_id': 1, 'dic_path': _ho_path1_trunk_348, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_348 = {'gnb_id': 1, 'dic_path': _ho_path2_trunk_348, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_348 = {'gnb_id': 1, 'dic_path': _ho_path1_trunk_348, 'counter_id': 'M55125C09519'}
NR_RRC_RELEASE_REDIR_VFB_LTE_348 = {'gnb_id': 1, 'dic_path': _ho_path3_trunk_348, 'counter_id': 'M55124C02501'}
NG_FLOW_SETUP_FAIL_FALLBACK_383 = {'gnb_id': 1, 'dic_path': _ho_path1_trunk, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_383 = {'gnb_id': 1, 'dic_path': _ho_path2_trunk, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_383 = {'gnb_id': 1, 'dic_path': _ho_path1_trunk, 'counter_id': 'M55125C09519'}
NR_RRC_RELEASE_REDIR_VFB_LTE_383 = {'gnb_id': 1, 'dic_path': _ho_path3_trunk, 'counter_id': 'M55124C02501'}

NG_FLOW_REL_GNB_UE_INACTIVITY_348 = {'gnb_id': 1, 'dic_path': _ho_path1_348_400, 'counter_id': 'M55125C09004'}
NG_FLOW_REL_GNB_UE_INACTIVITY = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09004'}
NG_FLOW_REL_GNB_UE_INACTIVITY_trunk_348 = {'gnb_id': 1, 'dic_path': _ho_path1_trunk_348, 'counter_id': 'M55125C09004'}
NG_FLOW_REL_GNB_UE_INACTIVITY_trunk = {'gnb_id': 1, 'dic_path': _ho_path1_trunk, 'counter_id': 'M55125C09004'}
NG_FLOW_SETUP_FAIL_FALLBACK_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09008'}
NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09008'}
NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_348 = {'gnb_id': 1, 'dic_path': _ho_path4_trunk_348, 'counter_id': 'M55125C09008'}
NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk_383 = {'gnb_id': 1, 'dic_path': _ho_path4_trunk_383, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk = {'gnb_id': 1, 'dic_path': _ho_path5_trunk, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_348 = {'gnb_id': 1, 'dic_path': _ho_path5_trunk_348,
                                              'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk_383 = {'gnb_id': 1, 'dic_path': _ho_path5_trunk_383,
                                              'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09519'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09519'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_348 = {'gnb_id': 1, 'dic_path': _ho_path4_trunk_348,
                                             'counter_id': 'M55125C09519'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk_383 = {'gnb_id': 1, 'dic_path': _ho_path4_trunk_383,
                                             'counter_id': 'M55125C09519'}

NG_FLOW_SETUP_FAIL_WRONG_MSG = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09012'}
NG_FLOW_STP_FAIL_WRG_MSG_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09523'}
NG_FLOW_STP_FAIL_WRG_MSG_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00512'}

NG_FLOW_SETUP_FAIL_UNSPECIFIED = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09011'}
NG_FLOW_SETUP_FAIL_UNSPC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00511'}
NG_FLOW_SETUP_FAIL_UNSPC_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09522'}

NG_FLOW_STP_ATT_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_ATT_INC_HO_5QI1_2_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_SUC_INC_HO_5QI1_2_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_2_trunk = {'gnb_id': 1, 'dic_path': _ho_path5_trunk, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_2_trunk = {'gnb_id': 1, 'dic_path': _ho_path5_trunk, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_ATT_INC_HO_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09014'}
NG_FLOW_STP_SUC_INC_HO_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09014'}

NG_FLOW_STP_ATT_INC_HO_5QI1_3_348 = {'gnb_id': 2, 'dic_path': _ho_path1_348, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk_348 = {'gnb_id': 2, 'dic_path': _ho_path12_trunk_348, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3_348 = {'gnb_id': 2, 'dic_path': _ho_path1_348, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk_348 = {'gnb_id': 2, 'dic_path': _ho_path12_trunk_348, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3_348 = {'gnb_id': 2, 'dic_path': _ho_path2_348, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk_348 = {'gnb_id': 2, 'dic_path': _ho_path22_trunk_348,
                                            'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3_348 = {'gnb_id': 2, 'dic_path': _ho_path2_348, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk_348 = {'gnb_id': 2, 'dic_path': _ho_path22_trunk_348,
                                            'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk = {'gnb_id': 2, 'dic_path': _ho_path12_trunk, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk = {'gnb_id': 2, 'dic_path': _ho_path12_trunk, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk = {'gnb_id': 2, 'dic_path': _ho_path22_trunk, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk = {'gnb_id': 2, 'dic_path': _ho_path22_trunk, 'counter_id': 'M55163C00514'}

NG_FLOW_REL_IRAT_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09509'}
NG_FLOW_REL_IRAT_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00516'}
NG_FLOW_REL_IRAT_SUC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09016'}
NG_FLOW_REL_IRAT_SUC_HO_5QI1_348 = {'gnb_id': 1, 'dic_path': _ho_path700_trunk_348, 'counter_id': 'M55125C09509'}
NG_FLOW_REL_IRAT_SUC_HO_PMQAP_348 = {'gnb_id': 1, 'dic_path': _ho_path5_trunk_348, 'counter_id': 'M55163C00516'}
NG_FLOW_REL_IRAT_SUC_HO_348 = {'gnb_id': 1, 'dic_path': _ho_path700_trunk_348, 'counter_id': 'M55125C09016'}
NG_FLOW_REL_IRAT_SUC_HO_5QI1_383 = {'gnb_id': 1, 'dic_path': _ho_path1_c2_trunk, 'counter_id': 'M55125C09509'}
NG_FLOW_REL_IRAT_SUC_HO_PMQAP_383 = {'gnb_id': 1, 'dic_path': _ho_path5_trunk_383, 'counter_id': 'M55163C00516'}
NG_FLOW_REL_IRAT_SUC_HO_383 = {'gnb_id': 1, 'dic_path': _ho_path1_c2_trunk, 'counter_id': 'M55125C09016'}

NG_FLOW_STP_ATT_RES_IADU_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00530'}
NG_FLOW_STP_ATT_RES_IADU_PMQAP_trunk = {'gnb_id': 1, 'dic_path': _ho_path5_trunk, 'counter_id': 'M55163C00530'}
NG_FLOW_STP_ATT_RES_IADU_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09531'}
NG_FLOW_STP_ATT_RES_IADU_5QI1_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09531'}
NG_FLOW_STP_SUC_RES_IADU_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00531'}
NG_FLOW_STP_SUC_RES_IADU_PMQAP_trunk = {'gnb_id': 1, 'dic_path': _ho_path5_trunk, 'counter_id': 'M55163C00531'}
NG_FLOW_STP_SUC_RES_IADU_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09532'}
NG_FLOW_STP_SUC_RES_IADU_5QI1_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09532'}
NG_FLOW_STP_ATT_REEST_IADU = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09023'}
NG_FLOW_STP_ATT_REEST_IADU_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09023'}
NG_FLOW_STP_SUC_REEST_IADU = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09024'}
NG_FLOW_STP_SUC_REEST_IADU_trunk = {'gnb_id': 1, 'dic_path': _ho_path4_trunk, 'counter_id': 'M55125C09024'}

NG_FLOW_CON_SESSION_TIME_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00521'}
NG_FLOW_SETUP_ATT_TOT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08501'}
NG_FLOW_SETUP_ATT_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09517'}
NG_FLOW_SETUP_SUCC = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08502'}
NG_FLOW_SETUP_SUCC_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09518'}
NG_FLOW_SETUP_SUCC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00002'}
NG_FLOW_SETUP_ATT_TOT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00001'}
NG_FLOW_REL_AMF_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09512'}
NG_FLOW_REL_AMF_NORMAL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00519'}
NG_FLOW_REL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00003'}
NG_FLOW_REL_NORMAL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00004'}
NG_FLOW_REL_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09514'}
NG_FLOW_REL_AMF_NORMAL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09019'}
NG_FLOW_REL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08503'}
NG_FLOW_REL_NORMAL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08504'}
NG_FLOW_CONNECTED_SESSION_TIME = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09516'}
NG_FLOW_SESSION_DUR_NORM_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09526'}

WB_CQI_64TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21000'}
WB_CQI_64TBL_5QI1_CQI1 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21001'}
WB_CQI_64TBL_5QI1_CQI2 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21002'}
WB_CQI_64TBL_5QI1_CQI3 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21003'}
WB_CQI_64TBL_5QI1_CQI4 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21004'}
WB_CQI_64TBL_5QI1_CQI5 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21005'}
WB_CQI_64TBL_5QI1_CQI6 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21006'}
WB_CQI_64TBL_5QI1_CQI7 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21007'}
WB_CQI_64TBL_5QI1_CQI8 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21008'}
WB_CQI_64TBL_5QI1_CQI9 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21009'}
WB_CQI_64TBL_5QI1_CQI10 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21010'}
WB_CQI_64TBL_5QI1_CQI11 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21011'}
WB_CQI_64TBL_5QI1_CQI12 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21012'}
WB_CQI_64TBL_5QI1_CQI13 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21013'}
WB_CQI_64TBL_5QI1_CQI14 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21014'}
WB_CQI_64TBL_5QI1_CQI15 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21015'}

WB_CQI_256TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22000'}
WB_CQI_256TBL_5QI1_CQI1 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22001'}
WB_CQI_256TBL_5QI1_CQI2 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22002'}
WB_CQI_256TBL_5QI1_CQI3 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22003'}
WB_CQI_256TBL_5QI1_CQI4 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22004'}
WB_CQI_256TBL_5QI1_CQI5 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22005'}
WB_CQI_256TBL_5QI1_CQI6 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22006'}
WB_CQI_256TBL_5QI1_CQI7 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22007'}
WB_CQI_256TBL_5QI1_CQI8 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22008'}
WB_CQI_256TBL_5QI1_CQI9 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22009'}
WB_CQI_256TBL_5QI1_CQI10 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22010'}
WB_CQI_256TBL_5QI1_CQI11 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22011'}
WB_CQI_256TBL_5QI1_CQI12 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22012'}
WB_CQI_256TBL_5QI1_CQI13 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22013'}
WB_CQI_256TBL_5QI1_CQI14 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22014'}
WB_CQI_256TBL_5QI1_CQI15 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22015'}

WB_CQI_64TBL_5QI1_CQI = [
    WB_CQI_64TBL_5QI1_CQI0, WB_CQI_64TBL_5QI1_CQI1, WB_CQI_64TBL_5QI1_CQI2, WB_CQI_64TBL_5QI1_CQI3,
    WB_CQI_64TBL_5QI1_CQI4, WB_CQI_64TBL_5QI1_CQI5, WB_CQI_64TBL_5QI1_CQI6, WB_CQI_64TBL_5QI1_CQI7,
    WB_CQI_64TBL_5QI1_CQI8, WB_CQI_64TBL_5QI1_CQI9, WB_CQI_64TBL_5QI1_CQI10, WB_CQI_64TBL_5QI1_CQI1,
    WB_CQI_64TBL_5QI1_CQI12, WB_CQI_64TBL_5QI1_CQI13, WB_CQI_64TBL_5QI1_CQI14, WB_CQI_64TBL_5QI1_CQI15
]

WB_CQI_256TBL_5QI1_CQI = [
    WB_CQI_256TBL_5QI1_CQI0, WB_CQI_256TBL_5QI1_CQI1, WB_CQI_256TBL_5QI1_CQI2, WB_CQI_256TBL_5QI1_CQI3,
    WB_CQI_256TBL_5QI1_CQI4, WB_CQI_256TBL_5QI1_CQI5, WB_CQI_256TBL_5QI1_CQI6, WB_CQI_256TBL_5QI1_CQI7,
    WB_CQI_256TBL_5QI1_CQI8, WB_CQI_256TBL_5QI1_CQI9, WB_CQI_256TBL_5QI1_CQI10, WB_CQI_256TBL_5QI1_CQI11,
    WB_CQI_256TBL_5QI1_CQI12, WB_CQI_256TBL_5QI1_CQI13, WB_CQI_256TBL_5QI1_CQI14, WB_CQI_256TBL_5QI1_CQI15
]

NG_FLOW_REL_GNB_REDIRECT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09002'}
NG_FLOW_REL_GNB_REDIRECT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09502'}
NG_FLOW_REL_GNB_REDIRECT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00503'}

NG_FLOW_REL_GNB_RLF = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09003'}
NG_FLOW_REL_GNB_RLF_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09503'}
NG_FLOW_REL_GNB_RLF_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00504'}

PEAK_NUMBER_OF_UE_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09530'}
AVE_NUMBER_OF_UE_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09528'}
AVE_NUMBER_OF_UE_5QI1_DENOM = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09529'}

SA_PART_ADMISSION = {'gnb_id': 1, 'dic_path': _SA_path, 'counter_id': 'M55138C02001'}
NG_FLOW_SETUP_ATT_TOT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00001'}
NG_FLOW_SETUP_SUCC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00002'}
NG_FLOW_SETUP_FAIL_RRNA_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C02000'}
NG_FLOW_SETUP_ATT_TOT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08501'}
NG_FLOW_SETUP_SUCC = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08502'}
NG_FLOW_SETUP_FAIL_RRNA = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C10501'}

AMOUNT_OF_CELLS = 1

# -------8232_A_021------ #
PARAM_8232_A_021 = [
    dict(
        value='true', dist_name=_NRCELLname, parameter='actPriorityAccess'),
    dict(
        value='0', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
]

PARAM_8232_A_021_ADD = [
    dict(
        value='MPS', dist_name=_NRBTSname, parameter='applyPriorityAccess'),
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),

]

PARAM_8232_recover_A_021 = [
    dict(
        value='false', dist_name=_NRCELLname, parameter='actPriorityAccess'),
    dict(
        value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
]

PARAM_8232_delete_A_021 = [
    dict(
        value='MPS', dist_name=_NRBTSname, parameter='applyPriorityAccess'),
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),
]

# -------8232_D_009------ #
D_009_Modify_Online = [

    dict(
        value='true', dist_name=_NRCELLname, parameter='actPriorityAccess'),
    dict(
        value='0', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(
        value='7',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='7',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMin'),
]

D_009_ADD_Para = [
    dict(
        value='MPS', dist_name=_NRBTSname, parameter='applyPriorityAccess'),
    dict(
        value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),

]

PARAM_8232_recover_D_009 = [
    dict(
        value='false', dist_name=_NRCELLname, parameter='actPriorityAccess'),
    dict(
        value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMin'),
]

PARAM_8232_delete_D_009 = [
    dict(
        value='MPS', dist_name=_NRBTSname, parameter='applyPriorityAccess'),
    dict(
        value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),
]

# -------8232_counter------ #
counter_dic_path_mps_GNB1CELL1 = [
    'BTS/BTS/NRBTS-1342/NRDU-1/NRRCD',
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/BTS/NRBTS-1342/NRDU-1/NRRCD',
]

counter_id_mps = [
    'M55127C03003', 'M55124C09003', 'M55124C01015', 'M55127C00013'
]

counter_dic_path_ICS_mps_GNB1CELL1 = [
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC',
]

counter_id_ICS_mps = [
    'M55125C12502', 'M55125C12504'
]

# -------5GC00784-------- #
PARAMETERS_TO_UPDATE_A21_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actGBRAdmissionControl', 'value': 'EnhancedVoNR'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'arpPrioEmergencyCall', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '2'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '2'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A21_1 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A21_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'false'}
]

PARAM_784_recover_A21 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '550'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actGBRAdmissionControl', 'value': 'off'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '600'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '600'}
]

PARAMETERS_TO_UPDATE_COUNTER = [
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/PMCADM-1', 'parameter': 'reportingIntervalPm', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrNGCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRRCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRSACU', 'value': '5min'}
]

PARAMETERS_TO_UPDATE_A11_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRMOPR_SA-1', 'parameter': 'emergencyCallFails', 'value': 'disabled'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actGBRAdmissionControl', 'value': 'EnhancedVoNR'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'arpPrioEmergencyCall', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A11_1 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A11_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRMOPR_SA-1', 'parameter': 'emergencyCallFails', 'value': 'redirection'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'}
]

PARAM_784_recover_A11 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRMOPR_SA-1', 'parameter': 'emergencyCallFails', 'value': 'disabled'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '550'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '600'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '600'}
]

counter_id_A11_1 = [
    'M55125C05509', 'M55125C05511', 'M55125C05512', 'M55125C03501', 'M55125C03503', 'M55125C03504', 'M55138C01001',
    'M55124C04002', 'M55124C01502'
]

counter_id_A11_0 = [
    'M55138C01002'
]

counter_dic_path_A11_1 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/RSACU', 'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC'
]

counter_dic_path_A11_0 = [
    'BTS/CELLS/NRCELL-1/RSACU'
]

# -------5GC00784A01-------- #
counter_id_A01_should_be_1 = [
    'M55125C05505', 'M55125C05506', 'M55125C05513', 'M55125C05514'
]

counter_dic_path_A01_should_be_1 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_id_A01_not_zero = [
    'M55125C02504', 'M55125C02505', 'M55149C01001', 'M55125C05509', 'M55125C05510'
]

counter_dic_path_A01_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/BTS/NRBTS-1342/MCC-310_MNC-260/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

# -------CB007564_C005-------- #
RA_CB_INIT_RESOLVED = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09006'}
RA_MSG3_RECEP_INIT = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09008'}

# -------CB007564_C001-------- #
DED_PREAMBL_SENT_CFRA_INIT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09021'}
INIT_MSG2_ACK_CFRA = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09003'}
DED_PREAMBL_USED_CFRA_INIT = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09000'}
