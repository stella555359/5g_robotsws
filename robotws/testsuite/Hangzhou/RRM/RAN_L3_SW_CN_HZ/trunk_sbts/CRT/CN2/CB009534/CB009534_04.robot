*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-keyu.a.du
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB009534    release-SBTS23R3
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${ue_nr_capabilities_TC04_DLCA_Only_BCS4_60M}
...    SEPARATOR=
...    01800000010B809400C28D608C21A08107483401B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782FFCBFF162000D9780
...    01780001400C4180000001A0020080000027FE9FF8B10006D3C0013C0000A0060C6B04610D04083A41A00DAD931563439F11C7A067D813E31
...    238F21CFA8E7CC31E50B0381C3C27FE9FF8B10006D3C0013C0000A006236B04610D04083A41A00DAD931563439F11C7A067D813E31238F21C
...    FA8E7CC31E50B0381C3C27FE9FF8B10006D3C0013C0000A006266B04610D04083A41A00DAD931563439F11C7A067D813E31238F21CFA8E7CC
...    31E50B0381C3C15545550B1000ADB80038001B8003800000150F850105C41000E2300071300000005BE1000000000E0144041808D01305D00
...    03C030A24ED8E7C30140467C02000002008040000000300000000006CA9ACA1ACA5AC0DA010000802010000006000000007654DB286994B4C
...    0DA160038005000006020040080802006020080100803006

${ue_nr_capabilities_TC04_ULDLCA_BCS4_60M}
...    SEPARATOR=
...    01800000010B809400C28D608C21A08107483401B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782FFCBFF162000D9780
...    01780001400C4180000001A0020080000027FE9FF8B10006D3C0013C0000A0060C6B04610D04083A41A00DAD931563439F11C7A067D813E31
...    238F21CFA8E7CC31E50B0381C3C27FE9FF8B10006D3C0013C0000A006236B04610D04083A41A00DAD931563439F11C7A067D813E31238F21C
...    FA8E7CC31E50B0381C3C27FE9FF8B10006D3C0013C0000A006266B04610D04083A41A00DAD931563439F11C7A067D813E31238F21CFA8E7CC
...    31E50B0381C3C15545550B1000ADB80038001B8003800000150F850105C41000E2300071300000005BE1000000000E0144041808D01305D00
...    03C030A24ED8E7C30140467C02000002008040000000300000000006CA9ACA1ACA5AC0DA010000802010000006000000007654DB286994B4C
...    0DA160038005000006020040080802004020080100803006

@{PARAMS_IN_SCF}
...    @{CA_Enable}
...    @{PCell_Carriers_Config_60M}
...    @{CB009534_Enable}

@{CA_Enable}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actEutranFreqBandFiltering=false
...    NRBTS:actForceFullRRCConfigurationSaHo=disabled
...    NRBTS:actInterGnbRREPreparedCell=false
...    NRBTS:actUlCAUe=true
...    NRBTS/NRDU-1:actNonBfAndBfCa=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-3:gscnOrSsPbchArfcn=6399
...    NRCELL-3:maxNumScellsDlFr1=3

@{BWP_Profile_TDD_n41_30M}
...    NRBTS/BWP_PROFILE-49:bwpType=dedicated
...    NRBTS/BWP_PROFILE-49:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-49:locationAndBandwidthDl:cRbStartDl=crb0
...    NRBTS/BWP_PROFILE-49:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    NRBTS/BWP_PROFILE-49:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    NRBTS/BWP_PROFILE-49/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-49/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-49/PDCCH-1:dciPagingAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-49/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-49/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    NRBTS/BWP_PROFILE-49/PDCCH-1:dciSiAggregationLevel=AL4
...    NRBTS/BWP_PROFILE-49/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=4
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=1
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=48
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=7
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n5|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=8
...    NRBTS/BWP_PROFILE-49/PDSCH-1:pdschRat0RbgConfig=config1

@{PCell_Carriers_Config_60M}
...    NRCELL-3:chBw=60MHz
...    NRCELL-3:cellBwpList:cellBwpId=0|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-2
...    NRCELL-3:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4
...    NRCELL-4:nrarfcn=526014
...    NRCELL-4:gscnOrSsPbchArfcn=6573
...    NRBTS/NRSYSINFO_PROFILE-4/NRIRFIM-1:dlCarrierFreq=526014

@{CB009534_Enable}
...    NRCELL-1:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-2:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-3:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-4:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-11:allowUnsuppBcOrBcs=complete BCS check
...    NRCELL-12:allowUnsuppBcOrBcs=complete BCS check

@{CA_SCellAddition_TC04}
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:lcrId=4
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-2:nrDcAllowed=false
...    NRCELL-3/NRREL-2:removeNotAllowed=false
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:lcrId=11
...    NRCELL-3/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-3/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-3/NRREL-3:nrDcAllowed=false
...    NRCELL-3/NRREL-3:removeNotAllowed=false
...    NRCELL-3/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-3:gNbId=1
...    NRCELL-3/NRREL-3:gNbIdLength=22
...    NRCELL-3/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-3:lcrId=1
...    NRCELL-3/NRREL-3:sCellOperationalMode=dlOnly

*** Test Cases ***
CB009534_04_interBand_BCS45_5CC_CA_N41C_N66A_N71A_N77A_60MHz_80MHz_20MHz_20MHz_100MHZ_UL_DL_CA_BCS_Check_Fail_fallback_2_DL_Only
    [Documentation]
    [Tags]    QC_280303    owner-keyu.a.du
    onlineParamChange    ${CA_SCellAddition_TC04}
    TC04 SA UE Attach    ue_id=81    cell_id=3    pdu_id=1    nwslice_id=1    gw_id=1
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=1    send_dl=148    send_ul=42    sleep_time=40s
    UE Deregister From gNB    ue_id=81
    Check RRC Log    ${CURDIR}${/}a2a_CB009534_TC04${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_N77_N78_2N41_N66_N71
    Execute Egate Command    sim_debug_log level=0
    Execute Egate Command    sim_debug_log level=0 uec=1
    Execute Egate Command    sim_debug_log level=0 app_type=ueproxy

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${ue_nr_capabilities_TC04_DLCA_Only_BCS4_60M}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${ue_nr_capabilities_TC04_ULDLCA_BCS4_60M}

onlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

TC04 SA UE Attach
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}
    ...    scellIdx:3

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Verify Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${sleep_time}=20s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${send_ul}
    sleep    ${sleep_time}    sleep for Interval between ul & dl traffic
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${send_dl}
    ${dl_threshold}    Evaluate    ${send_dl}*0.9
    ${ul_threshold}    Evaluate    ${send_ul}*0.9
    Verify Throuput    ${ue_id}    ${pdu_id}    ${qfi_id}    ${dl_threshold}    ${ul_threshold}    ${sleep_time}
