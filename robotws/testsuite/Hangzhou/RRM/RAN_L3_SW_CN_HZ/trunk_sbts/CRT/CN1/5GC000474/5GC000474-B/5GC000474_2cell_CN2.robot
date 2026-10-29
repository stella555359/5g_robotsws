*** Settings ***
Documentation     this case is the 5GC000474_C_4302 and 5GC000474_C_4308 for AP testline
...               \n Author: peach.fu@nokia-sbell.com
...               \n 5GC000474_C_4302_Test_ENDC_X2_Setup_Procedure_on_an_X2_Link_already_Established
...               \n 5GC000474_C_4308_Test_X2_Link_Detection_Failure_with_SCTP_Association_Unavailable_Initiated_by_eNB
...               \n Please do not edit the existing keywords in this file without testing.
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he   release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
#check cell2 state
${Cell2_operationalState}  MRBTS-1/NRBTS-1/NRCELL-2:operationalState=enabled

#delete cell2
@{DELTA_PARAS_delete_2nd_cell}
...  delete:MRBTS-1/NRBTS-1/NRCELL-2
...  delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...  delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...  delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...  delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...  delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...  delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...  delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...  delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...  NRDU-1:refNrCellGroup=0
...  NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs

#add cell2
@{Add_Cell2_Back}
...  @{NRCELL-2}
...  @{NRREL}
...  @{NRREDRT}
...  MRBTS-1/NRBTS-1/NRCELLGRP-1:spCellChangeEnabled=false
...  MRBTS-1/NRBTS-1/NRCELLGRP-1:scs=30 KHz
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:direction=TX
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:direction=RX
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:direction=TX
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:direction=RX
...  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-2/PHYANT-1
...  NRDU-1:refNrCellGroup=0,1

@{NRREL}
...  NRCELL-1/NRREL-1:gNbId=1
...  NRCELL-1/NRREL-1:gNbIdLength=22
...  NRCELL-1/NRREL-1:lcrId=2
...  NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-2/NRREL-1:gNbId=1
...  NRCELL-2/NRREL-1:gNbIdLength=22
...  NRCELL-2/NRREL-1:lcrId=1
...  NRCELL-2/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-2/NRREL-1:gnbPlmn:mnc=489|mncLength=3

@{NRCELL-2}
...  MRBTS-1/NRBTS-1/NRCELL-2:dlQam256PowerBackoffSub6=15
...  MRBTS-1/NRBTS-1/NRCELL-2:lcrId=2
...  MRBTS-1/NRBTS-1/NRCELL-2:absThreshSsbRsrpConsolidation=1
...  MRBTS-1/NRBTS-1/NRCELL-2:actAdaptiveSr=false
...  MRBTS-1/NRBTS-1/NRCELL-2:actEnhancedVoNR=false
...  MRBTS-1/NRBTS-1/NRCELL-2:actGBRAdmissionControl=off
...  MRBTS-1/NRBTS-1/NRCELL-2:ccLoadThreshold=50
...  MRBTS-1/NRBTS-1/NRCELL-2:csirsForTracking:firstRE=0|rbAllocation=BWP
...  MRBTS-1/NRBTS-1/NRCELL-2:csirsForTracking:startRB=0|rbAllocation=BWP
...  MRBTS-1/NRBTS-1/NRCELL-2:csirsForTracking:csirsTrackingPeriod=80ms|rbAllocation=BWP
...  MRBTS-1/NRBTS-1/NRCELL-2:dlDMRSAdditionalPosition=No additional DMRS
...  MRBTS-1/NRBTS-1/NRCELL-2:dllaDeltaCqiMax=3
...  MRBTS-1/NRBTS-1/NRCELL-2:dllaDeltaCqiMin=-3
...  MRBTS-1/NRBTS-1/NRCELL-2:dllaIniMcs=0
...  MRBTS-1/NRBTS-1/NRCELL-2:dlMuMaxNumPairedUEs=8
...  MRBTS-1/NRBTS-1/NRCELL-2:drxWactDlEnabled=false
...  MRBTS-1/NRBTS-1/NRCELL-2:drxWactUlEnabled=false
...  MRBTS-1/NRBTS-1/NRCELL-2:duratScgFailures=0ms
...  MRBTS-1/NRBTS-1/NRCELL-2:enDcSyncStatus=synchronous
...  MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7880
...  MRBTS-1/NRBTS-1/NRCELL-2:pagingOffset=1
...  MRBTS-1/NRBTS-1/NRCELL-2:payloadSizeProactiveDrx=64
...  MRBTS-1/NRBTS-1/NRCELL-2:payloadSizeProactiveNonDrx=16
...  MRBTS-1/NRBTS-1/NRCELL-2:physCellId=51
...  MRBTS-1/NRBTS-1/NRCELL-2:pucchDataDtxNumOfSamples=30
...  MRBTS-1/NRBTS-1/NRCELL-2:puschDataDtxNumOfSamples=30
...  MRBTS-1/NRBTS-1/NRCELL-2:pucchModeSelect=shortPucch
...  MRBTS-1/NRBTS-1/NRCELL-2:actVoNR=false
...  MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=636666
...  MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac=200
...  MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...  MRBTS-1/NRBTS-1/NRCELL-2:ueConnectionEstablishmentMode=useDedicatedBwp
...  MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-5|cellBwpId=0
...  MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-54|cellBwpId=1
...  MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1|a3TimeToTriggerSsbRsrp=ms0
...  MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10|a3TimeToTriggerSsbRsrp=ms0
...  delete:MRBTS-1/NRBTS-1/NRCELL-2:maxGBRTrafficLimit
...  delete:MRBTS-1/NRBTS-1/NRCELL-2:n310VoNR
...  delete:MRBTS-1/NRBTS-1/NRCELL-2:t310VoNR
...  delete:MRBTS-1/NRBTS-1/BWP_PROFILE-1
...  delete:MRBTS-1/NRBTS-1/BWP_PROFILE-2
...  delete:MRBTS-1/NRBTS-1/NRCELL-2:nrhoirDNList
...  delete:MRBTS-1/NRBTS-1/NRCELL-2:pciExcludeList
...  delete:MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN

@{NRREDRT}
...  NRBTS/NRCELL-2/NRREDRT-1:nrredrtId=1
...  NRBTS/NRCELL-2/NRREDRT-1:redirFreqNr=633364
...  NRBTS/NRCELL-2/NRREDRT-1:redirPrio=1
...  NRBTS/NRCELL-2/NRREDRT-1:redirRat=nr
...  NRBTS/NRCELL-2/NRREDRT-1:redirSsbScs=30 KHz


#PM counter

${X2_UEREL_OUT_PARTIAL_RESET}      M55110C00028
${X2_PARTIAL_RESET_REQUIRED_SENT}  M55110C00031
${X2_PARTIAL_RESET_CONF_RCVD}      M55110C00032
${X2_ENDC_CONF_UPDATE_SENT}        M55110C00015
${X2_ENDC_CONF_UPDATE_ACK_RCVD}    M55110C00016


@{Delete Cell2 Counter Check}
...  ${X2_UEREL_OUT_PARTIAL_RESET}=1
...  ${X2_PARTIAL_RESET_REQUIRED_SENT}=1
...  ${X2_PARTIAL_RESET_CONF_RCVD}=1

@{Lock Cell1 Counter Check}
...  ${X2_UEREL_OUT_PARTIAL_RESET}=2
...  ${X2_PARTIAL_RESET_REQUIRED_SENT}=2
...  ${X2_PARTIAL_RESET_CONF_RCVD}=2

@{Add Cell2 Counter Check}
...  ${X2_ENDC_CONF_UPDATE_SENT}=3
...  ${X2_ENDC_CONF_UPDATE_ACK_RCVD}=3


#X2 fault
${7300_fault_name}    No X2 link available
${7300_fault_id}    7300
${7300_alarm_id}    7107

${ue_nr_capabilities}  SEPARATOR=
...  ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E
...  77EF3FFF3FFFEC0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${ue_eutra_nr_capabilities}  SEPARATOR=
...  BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801
...  C4D000006060182C000389A00000C0C03058100713400001018060B0600E2680000203004
...  8BC500C200020100801002570010040200804010080201004020080401008020100402008
...  0401008020100402010040200804010080000004020080400000000000402000000000000
...  0000402008040100802010000000804010080000000000080400000000000000008040100
...  8020100402008040000002010040200804000000000000000080400000000000000000000
...  1009C00202008040080801010000000404008080000000000040400000000000000004020
...  1004010080201004020080401008020100402008040100802010040200808020100202000
...  0000808010100000004040000000000020200000000000101004020040400808000000202
...  0040400000000000202004040000000000020200000000000000002027001008020100402
...  0000001008020100000008040000000000040200000000000201004020080400000020100
...  4020000001008000000000008040000000000040100802010040200804010080201004020
...  0804010080201004020080401008040100802010000000804010080000004020000001008
...  00000040200000000000201000000000001009C0020200404008080101002020000000808
...  0101002020000000000010100000004040080801010020200404000000101002020040400
...  0000000002020000000808010100202004040080800000020200404008080000000000040
...  4000000100802010040200804010080201004020080401008020100402008040100802010
...  0402008040100804017001008010100000004040080800000000000000008080000000000
...  0000000000201002020000000808010100000000000000001010000000000000000000004
...  0200404000000101002020000000000000000202000000000000000000000804008080000
...  002020040400808000000000004040000001010020200000000000000002020000000809C
...  40080180100300200600400C0080180100300200600400C0080180100300200600400C008
...  0180100300200600400C0080180100300200600400C0080180100300200600400C0080180
...  100300200600400C0080180100300200600400C0080180100300200600400C00801801003
...  00200600400C0080180100300200600400C0080180100300200600400C008018010030020
...  0600400C0080180100300200600400C008010800040202004008400040101002004


*** Test Cases ***
5GC000474_IA_4902_Test_outgoing X2 Partial Reset due to cell deletion
    [Documentation]
    ...    [Purpose]:The purpose of this test case is to check:
    ...    474 I's 5G_RAN_USR_4641:outgoing X2 Partial Reset due to cell deletion.
    ...    474 HB's 5G_RAN_USR_2883:ENDC_Configuration_Update_procedure_triggered_by_a_new_gNB_cell.
    ...    Also covers scenario that locking the last cell which replaces the last cell's deletion.
    ...    Because WebUI doesn't allow to delete the last cell.
    ...    Refered PM counts:
    ...    M55110C00028  number of Ue Context release due to outgoing X2 Partial Reset.
    ...    M55110C00031  Number of outgoing X2AP PARTIAL RESET Required sent to LTE eNB
    ...    M55110C00032  Number of successful X2AP PARTIAL RESET procedure
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 2 Cell, NSA
    ...    [Cover Feature]: 5GC000474
    ...    [Owner]: zhubaijie
    [Tags]    QC_90832
    Set X2AP To GNB
    2UEs ATTACH TO 2 CELLs
    Delete Cell2 And Check X2 Partial Reset
    Lock Cell1 And Check X2 Partial Reset
    Add Cell2 Back and Check ENDC Configuration Update
    Check Wireshark Log    ${CURDIR}${/}a2a_4902${/}a2a.ini
    UE detach
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    ue_param id=31-39 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Set X2AP To GNB
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Clear Counter Files

2UEs ATTACH TO 2 CELLs
    UE attach to gNB cell    31    1
    UE attach to gNB cell    32    2

Delete Cell2 And Check X2 Partial Reset

    Delete gNB Cell2
    check counters    ${Delete Cell2 Counter Check}
    Check No 7300_X2 Alarms

Lock Cell1 And Check X2 Partial Reset
    Lock Cell1
    check counters    ${Lock Cell1 Counter Check}
    Unlock Cell1

Add Cell2 Back and Check ENDC Configuration Update
    Recover 2nd Cell Configuration
    Wait Until Cell2 Is Enable
    check counters    ${Add Cell2 Counter Check}
    Check No 7300_X2 Alarms

UE attach to gNB cell
    [Arguments]  ${ue_id}=1   ${target_cell}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...  UE${ue_id}: Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA

Delete gNB Cell2
    delta commission parameters    ${DELTA_PARAS_delete_2nd_cell}

Recover 2nd Cell Configuration
    delta commission parameters    ${Add_Cell2_Back}

Check No 7300_X2 Alarms
    ${fault7300}  Create List    fault_id=${7300_fault_id}    alarm_id=${7300_alarm_id}    severity=Major
    ...    fault_name=${7300_fault_name}
    Fm Fault Should Be Cleared    ${fault7300}    40

Wait Until Cell2 Is Enable
    Wait Until Keyword Succeeds    5s    1s    object should exist    ${Cell2_operationalState}


UE detach
    Execute Egate Command    ue_detach id=31-32  UE IS OFF
