*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Release All UEs And Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_BOO_AP_LOO
...               team-CN3ET    owner-lishuo.geng    release-SBTS23R3    CB009169    CRT
Resource          ../../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F

# if FDD cells have a bandwidth > 25MHz, need configure FR1_WB
@{PARAMS_IN_IPHY_XML}  fddFrequencyRange=FR1_WB

@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}

@{rdULCaEnablerPhase}
...    0x580591=0

@{rdUseOptimizedDpaAlgo}
...    0x58056B=1

@{PARAMS_IN_SCF}
...    @{CB009169}
...    @{CA}
...    @{NRREL}
...    @{gscn_Arfcn}

${Cell1_TDD_PCI}    50
${Cell12_FDD_PCI}    61
${Cell1_ssbFrequency}    518430
${Cell1_carrierBandwidth}    162
${cell12_frequencyband}    71
${Cell12_absoluteFrequencyPointA}    135164

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

${carrierAggregationSupportList_with_CB009169_disable}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa

${carrierAggregationSupportList_with_CB009169_enable}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{CB009169}

...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchModeSelect=longPucch

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=518598
...    NRCELL-1:gscnOrSsPbchArfcn=6480
...    NRCELL-1:chBw=60MHz

...    NRCELL-2:nrarfcn=636666
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:chBw=80MHz

...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5297

...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1587

...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430920
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=350920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=30MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=30MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5385

...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1587
# for 10HZ FDD chbw, need to remove BWP coresetDedicated
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    delete:MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:lcrId=2
...    NRCELL-1/NRREL-5:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3

@{enable_beamforming}
...    NRCELL-1:actBeamforming=true
...    NRCELL-2:actBeamforming=true
...    NRBTS:actFdmEnhancedScheduling=true
# if actBeamforming=true, NRBTS:actChannelMapVal must be ShowAsWarning, and fix related relation error,
# otherwise cell setup will fail in fullstack TL
...    NRBTS:actChannelMapVal=ShowAsWarning
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-4:numberOfTransmittedSsBlocks=2 beams

@{pMax_config_And_sCellOperationalMode_DlOnly}
...    NRCELL-1:pMaxNROwnCell=20
...    NRCELL-12:pMaxNROwnCell=21
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

@{beamforming_enable_and_delete_NRREL}
...    @{enable_beamforming}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    delete:NRCELL-1/NRREL-2
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_CB009169_enable}

@{add_NRREL_Without_sCellAdditionMethod_sCellOperationalMode}
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3

${scelloperationmode_dlandul}
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl

@{add_sCellAdditionMethod_and_sCellOperationalMode}
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl

@{delete_sCellAdditionMethod_and_sCellOperationalMode}
...    delete:NRCELL-1/NRREL-2:sCellAdditionMethod
...    delete:NRCELL-1/NRREL-2:sCellOperationalMode

@{disable_CB009169}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-5:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_CB009169_disable}

@{enable_CB009169}
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList_with_CB009169_enable}
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-5:sCellAdditionMethod=blind

${N41DLUL_N71_DLUL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6
...    C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480C
...    AD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B6
...    4C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FF8007003FF0004C0003815C7C46D608C21A08107CA090155B262A
...    C2873E238F180000000000000000000003C04FFF800003FFE00000260001C001787850001C4600000216020401C0468051013602
...    087A00380410002808CF413003C00281C1401C0C02500700060240040603E0900200000001000002008000000040000080200000
...    8010000060080000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002
...    C01000812048020000300CE54D654D60A560A560CD60AD652D64CD602D606D6025604560ED034100000965240400006594901000
...    0296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A9652404000
...    2E5949010000C96524040000C594900CD2A8BA55154AA2E95455058AA0B1541A2A94C55268AA031540A2A93455078A1202F012A0
...    5028140A05028140A05028140A05028140A0502800304040300601002004202004008080600C20100200404030060100C0182020
...    18030080600C20100200404030060100C000402018030080600C02018030C04030060100C0180400802010020086A87C0004080C
...    10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05060B40

@{COUNTER_CHECK}
...    NRCELL-1:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-12:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    last NRCELL-1:CUCM:${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}=1
...    NRCELL-1:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=0
...    NRCELL-1:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=0
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=1
...    NRCELL-1:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=1

${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}    M55156C10007
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
${A2MEAS_REL1ULSCELL_ATT_SA}    M55118C10003
${A2MEAS_REL1ULSCELL_SUCC_SA}    M55118C10004

${SYSCOM_FLAG}    true

*** Test Cases ***
CB009169-SR-AA-B3_03_01_feature activation and deactivation via add and delete NRREL object and verify UL layer and maxdatarateUl
    [Documentation]
    ...    Verify CB009169 FR1 TDD_FDD UL CA can be activation and deactivation by online change NRREL
    ...    when ConfigurationIndependent and Beamforming is enabled
    ...    Check maxrank and maxMIMO-Layers for UL scell in rrc log
    ...    Check maxdatarateUl and maxNumOfUlLayers for UL scell in L2PS
    [Tags]
    Online Change And Wait Cell Onair WA     ${beamforming_enable_and_delete_NRREL}
    Ue with specified capabilitiy Register And Pdu Session Setup And Check No CA At TDD Cell-1    ue_id=1    ue_capa=${N41DLUL_N71_DLUL}
    Online Change And Wait Cell Onair    ${add_NRREL_Without_sCellAdditionMethod_sCellOperationalMode}
    Ue with specified capabilitiy Register And Pdu Session Setup And Check No CA At TDD Cell-1    ue_id=2    ue_capa=${N41DLUL_N71_DLUL}
    Online Change And Wait Cell Onair    ${add_sCellAdditionMethod_and_sCellOperationalMode}
    Ue with specified capabilitiy Register And ICS with Scell Addtion At TDD Cell-1    ue_id=3    ue_capa=${N41DLUL_N71_DLUL}
    Check Scell Addition For Cell12 With ULDL
    Online Change And Wait Cell Onair    ${delete_sCellAdditionMethod_and_sCellOperationalMode}
    Ue with specified capabilitiy Register And Pdu Session Setup And Check No CA At TDD Cell-1    ue_id=4    ue_capa=${N41DLUL_N71_DLUL}
    Check RRC log And Wireshark Log For case3

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

Online Change And Wait Cell Onair
    [Arguments]    ${parameters}
    delta commission parameters    ${parameters}
    Cells Should Be Onair

Online Change And Wait Cell Onair WA
    [Arguments]    ${parameters}
    delta commission parameters    ${parameters}
    sleep    60s
    Cells Should Be Onair
	
Release All UEs And Common Test Teardown And Stop Capture Logs	
    Release Ues    ue_type=all
    Common Test Teardown And Stop Capture Logs

Ue with specified capabilitiy Register And Pdu Session Setup And Check No CA At TDD Cell-1
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    fail_regexp=scellIdx:1    
    Should Not Contain    ${ret}    sCellIndex 1    
    Should Contain    ${ret}    QoS Routing Table

Ue with specified capabilitiy Register And ICS with Scell Addtion At TDD Cell-1
    [Arguments]    ${ue_id}    ${ue_capa}
    Start rrc log    scell_addition_UE${ue_id}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=scellIdx:1
    Set Test Variable    ${ret}
    Get rrc log

Check Scell Addition For Cell12 With DLonly
    Should Contain    ${ret}    sCellIndex 1
    Should Contain    ${ret}    physCellId ${Cell12_FDD_PCI}
    Should Not Contain    ${ret}    uplinkConfigCommon

Check Scell Addition For Cell12 With ULDL
    Should Contain    ${ret}    sCellIndex 1
    Should Contain    ${ret}    physCellId ${Cell12_FDD_PCI}
    Should Contain    ${ret}    uplinkConfigCommon
    Should Not Contain    ${ret}    frequencyShift7p5khz

Check RRC log And Wireshark Log For case3
    Check rrc log    ${CURDIR}${/}A2A_case3${/}a2a_01.ini
    Check Wireshark Log    ${CURDIR}${/}A2A_case3${/}a2a_01.ini    wait_string=UEContextModificationResponse::22

Check RRC log And Counters For case4
    check rrc log    ${CURDIR}${/}A2A_case4${/}a2a_01.ini
    Check Counters     ${COUNTER_CHECK}

Online Change And Wait Cell Onair And Clear Counter Files
    [Arguments]    ${online_change}
    Online Change And Wait Cell Onair    ${online_change}
    Clear Counter Files
