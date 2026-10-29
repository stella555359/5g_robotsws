*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...    owner-xianjiao.xie    release-5G20B
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:x2ResetRspTmr=60
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=NSA
...    MRBTS-1/NRBTS-1:gNbCuType=NSA
...    @{MODIFY_RELATION_ERROR}
@{MODIFY_RELATION_ERROR}
...    MRBTS-1/NRBTS-1:actSACallProcessingDU=false
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1
...    delete:NRBTS-1/TRACKINGAREA-200:snssaiList
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN
...    delete:MRBTS-1/NRBTS-1/SNSSAI-1:ngUplane
...    @{NRDRB-10}
...    @{NRDRB-11}
...    @{NRDRB-12}
...    @{NRDRB-13}
...    @{NRDRB-14}
@{NRDRB-10}
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitGainThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:nsa3xBearerAllowed=true
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:prioritizeX2Period=500
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:ulDataPath=ulOverNr
...    MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:MRBTS-1/NRBTS-1/NRDRB-10:nsaDrbParam:dlPreferredPath
@{NRDRB-11}
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitGainThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:nsa3xBearerAllowed=true
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:prioritizeX2Period=500
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:ulDataPath=ulOverNr
...    MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:MRBTS-1/NRBTS-1/NRDRB-11:nsaDrbParam:dlPreferredPath
@{NRDRB-12}
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitGainThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:nsa3xBearerAllowed=true
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:prioritizeX2Period=500
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:ulDataPath=ulOverNr
...    MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:MRBTS-1/NRBTS-1/NRDRB-12:nsaDrbParam:dlPreferredPath
@{NRDRB-13}
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitGainThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:nsa3xBearerAllowed=true
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:prioritizeX2Period=500
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:ulDataPath=ulOverNr
...    MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:MRBTS-1/NRBTS-1/NRDRB-13:nsaDrbParam:dlPreferredPath
@{NRDRB-14}
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitGainThreshold=5
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:nsa3xBearerAllowed=true
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:prioritizeX2Period=500
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:ulDataPath=ulOverNr
...    MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:MRBTS-1/NRBTS-1/NRDRB-14:nsaDrbParam:dlPreferredPath
@{Delete_Useless_Cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
@{Online_Param_Lock_Cell}
...    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Locked
@{Online_Param_Unlock_Cell}
...    MRBTS-1/NRBTS-1/NRCELL-1:administrativeState=Unlocked
@{Online_Param_Lock_X2}
...    LTEENB:x2LinkLock=locked
@{Online_Param_Unlock_X2}
...    LTEENB:x2LinkLock=unlocked
${Update_Cfg_1}    set_enb id=1 plmn=311:489 s1=10.0.1.121 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.12
...    x2u=10.0.1.136 type=simulated x2_peers=none
${Update_Cfg_2}    set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy=10.0.2.1:12219|10.0.2.1:8889 earfcn=2000:20000
...    mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off
${Update_Cfg_3}    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22
...    daemon=10.0.2.80:22222 xn=10.0.1.2 x2_peers=none amf=1-3
${Update_Cfg_4}    set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 eci=0x000021f tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
${Update_Cfg_5}    set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    eia=null+snow3g+aes eea=null nea=null+zuc nia=null+zuc imsi=311:489:21645400
${Update_Cfg_6}    set_ue simulated id=15 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    eia=null+snow3g+aes eea=null nea=null+zuc nia=null+zuc imsi=311:489:21645404
${Update_Cfg_7}    set_ue simulated id=16 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
...    eia=null+snow3g+aes eea=null nea=null+zuc nia=null+zuc imsi=311:489:21645405
${ue_nr_capabilities_UE11}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7807E29040
...    1BFFEF0BFFEBC00E54D00158800000000023003CAA08
${ue_eutra_nr_capabilities_UE11}    SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A
...    00000C0C03058100713400001018060B0600E26800002030048BC500C200020100801002570010040200804010080201004020080401008020100
...    402008040100802010040201004020080401008000000402008040000000000040200000000000000004020080401008020100000008040100800
...    0000000008040000000000000000804010080201004020080400000020100402008040000000000000000804000000000000000000001009C0020
...    200804008080101000000040400808000000000004040000000000000000402010040100802010040200804010080201004020080401008020100
...    402008080201002020000000808010100000004040000000000020200000000000101004020040400808000000202004040000000000020200404
...    000000000002020000000000000000202700100802010040200000010080201000000080400000000000402000000000002010040200804000000
...    201004020000001008000000000008040000000000040100802010040200804010080201004020080401008020100402008040100804010080201
...    000000080401008000000402000000100800000040200000000000201000000000001009C00202004040080801010020200000008080101002020
...    000000000010100000004040080801010020200404000000101002020040400000000000202000000080801010020200404008080000002020040
...    400808000000000004040000001008020100402008040100802010040200804010080201004020080401008020100402008040100804017001008
...    010100000004040080800000000000000008080000000000000000000020100202000000080801010000000000000000101000000000000000000
...    000402004040000001010020200000000000000002020000000000000000000008040080800000020200404008080000000000040400000010100
...    20200000000000000002020000000809C40080180100300200600400C0080180100300200600400C0080180100300200600400C00801801003002
...    00600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200
...    600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030020060
...    0400C008010800040202004008400040101002004
${ue_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409A00CFDBFCB98AD7FFBF900001F53FFFFC000104880000073BF79FFF9FFFF60000FBC00BFFF0000163C03F
...    148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0
${ue_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C0305810071340
...    0001018060B0600E2680000203000100510400801002826C4100289178A028400040201002004AE00200804010080201004020080401008020100
...    402008040100802010040200804020080401008020100000008040100800000000000804000000000000000080401008020100402000000100802
...    010000000000010080000000000000001008020100402008040100800000040200804010080000000000000001008000000000000000000002013
...    800404010080101002020000000808010100000000000080800000000000000008040200802010040200804010080201004020080401008020100
...    402008040101004020040400000010100202000000080800000000000404000000000002020080400808010100000004040080800000000000404
...    00808000000000004040000000000000000404E002010040200804000000201004020000001008000000000008040000000000040200804010080
...    000004020080400000020100000000000100800000000000802010040200804010080201004020080401008020100402008040100802010080201
...    004020000001008020100000008040000002010000000804000000000004020000000000020138004040080801010020200404000000101002020
...    040400000000000202000000080801010020200404008080000002020040400808000000000004040000001010020200404008080101000000040
...    4008080101000000000000808000000201004020080401008020100402008040100802010040200804010080201004020080401008020100802E0
...    020100202000000080801010000000000000000101000000000000000000000402004040000001010020200000000000000002020000000000000
...    000000008040080800000020200404000000000000000040400000000000000000000100801010000000404008080101000000000000808000000
...    2020040400000000000000004040000001013880100300200600400C0080180100300200600400C0080180100300200600400C008018010030020
...    0600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801003002006
...    00400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600
...    400C00801801002100008040400801080008020200400800804018010020040100600400C00801
@{pm_couter_A014}
...    NRBTS-1:${X2_SHUTDOWN_LOCKED}==0
...    NRBTS-1:${DENOM_CELL_AVAIL}>=479
...    NRBTS-1:${SDCCH_SEIZ_ATT}==3
...    NRBTS-1:${SAMPLES_CELL_AVAIL}>0
...    NRBTS-1:${ENDC_X2_SETUP_RESPONSE_SENT}==2
...    NRBTS-1:${X2_PARTIAL_RESET_CONF_RCVD}==1
...    NRBTS-1:${X2_PARTIAL_RESET_REQUIRED_SENT}==1
...    NRBTS-1:${X2_ENDC_CONF_UPDATE_ACK_RCVD}==1
...    NRBTS-1:${ENDC_X2_SETUP_REQUEST_RECEIVED}==2
...    NRBTS-1:${X2_SHUTDOWN_DETECTED}==1
...    NRBTS-1:${X2_UEREL_OUT_PARTIAL_RESET}==1
...    NRBTS-1:${X2_ENDC_CONF_UPDATE_SENT}==1
${X2_SHUTDOWN_LOCKED}    M55110C00007
${DENOM_CELL_AVAIL}    M55601C00001
${SDCCH_SEIZ_ATT}    M55110C00034
${SAMPLES_CELL_AVAIL}    M55601C00002
${ENDC_X2_SETUP_RESPONSE_SENT}    M55110C00004
${X2_PARTIAL_RESET_CONF_RCVD}    M55110C00032
${X2_PARTIAL_RESET_REQUIRED_SENT}    M55110C00031
${X2_UEREL_OUT_PARTIAL_RESET}    M55110C00028
${X2_SHUTDOWN_DETECTED}    M55110C00002
${ENDC_X2_SETUP_REQUEST_RECEIVED}    M55110C00003
${X2_ENDC_CONF_UPDATE_SENT}    M55110C00015
${X2_ENDC_CONF_UPDATE_ACK_RCVD}    M55110C00016

*** Test Cases ***
5GC002478-ET-A014 Single_X2_Single_Cell
    [Documentation]
    ...    [purpose]: The purpose of this case is to Verify x2 SCTP failure + DU cell lock and recover with x2 link recover + DU cell unlock
    ...    second part is about DU cell lock+ x2 link lock then same recovery way. Merge A005/A006 also
    ...    Counters checking coverred: M55110C00002-Number of SCTP shutdown detected on X2 link by SCTP layer,
    ...    M55110C00003-Number of incoming EN-DC X2 SETUP request received from LTE eNB,
    ...    M55110C00004-Number of successful EN-DC X2 SETUP procedure (number of EN-DC X2 SETUP response sent to LTE eNB),
    ...    M55110C00015-Number of X2 EN-DC Configuration Update sent to LTE eNB,
    ...    M55110C00016-Number of successful outgoing EN-DC X2 Configuration Update procedure,
    ...    M55110C00034-Number of incoming SGNB ADDITION REQUEST received from LTE eNB for call setup,
    ...    M55110C00028-Number of UE release due to outgoing X2 Partial Reset,
    ...    M55110C00031-Number of X2 PARTIAL RESET Required sent by gNB,
    ...    M55110C00032-Number of successful outgoing X2 PARTIAL RESET procedure, M55601C00001-Cell availability denominator,
    ...    M55601C00002-Samples when the cell is available, M55110C00007-Number of SCTP shutdown due to lock
    [Tags]    QC_60840
    Precondition For Case A014
    Set SCTP Failure and Lock Cell
    Recover SCTP Unlock cell and check
    Lock Cell and Lock X2 on gNB
    Unlock X2 Unlock cell on gNB and check
    Detach UEs
    Check Wireshark Log    ${CURDIR}${/}A2A_A_014${/}a2a.ini    wait_string=ENDCX2SetupRequest::2
    Check counters    ${pm_couter_A014}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    ${Update_Cfg_5}
    Update Cfg    ${Update_Cfg_6}
    Update Cfg    ${Update_Cfg_7}
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on
    Update Cfg    set_bearer id=2 ue=11 qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal
    update cfg    set_bearer id=2 ue=15 qci=9 pdn=1 ip=4.7.254.212 default=on trf_type=internal
    update cfg    set_bearer id=2 ue=16 qci=9 pdn=1 ip=4.7.254.213 default=on trf_type=internal
    update cfg    set_bearer id=3 ue=11 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    update cfg    set_bearer id=3 ue=15 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2

Precondition For Case A014
    delta commission parameters    ${Delete_Useless_Cell}
    Set UE Parameters Before Attach    ue_id=11,15,16
    clear counter files
    Check X2 State Available or Unavailable    state=available
    Check Unlocked Cell State
    UE Attach and Establish EN-DC    ue_id=11    ue_nr_capabilities=${ue_nr_capabilities_UE11}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_UE11}

Set UE Parameters Before Attach
    [Arguments]    ${ue_id}
    Execute Egate Command    enb_timer T_RRC_TRANSACTION=4s
    Execute Egate Command    trace enb=1 protocol=all on

UE Attach and Establish EN-DC
    [Arguments]    ${ue_id}    ${ue_nr_capabilities}    ${ue_eutra_nr_capabilities}
    Execute Egate Command    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell 1\\) reported successful RA

Set SCTP Failure and Lock Cell
    [Arguments]    ${enb_id}=1    ${gnb_id}=2
    @{x2_drop}    create list
    ...    dropped by command
    ...    Bearer-type change from SCG-split to MCG is successful
    Execute Egate Command    link_drop link=x2 by=enb:${enb_id} to=gnb:${gnb_id} msg_type=abort     pass_regexp=${x2_drop}
    Check X2 State Available or Unavailable    state=unavailable
    Check Locked Cell State
    delta commission parameters    ${Online_Param_Lock_Cell}
    Check Locked Cell State

Recover SCTP Unlock cell and check
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=Attempt to SCTP connection to    timeout=120
    Check Locked Cell State
    delta commission parameters    ${Online_Param_Unlock_Cell}
    cell should be unlocked    cell_id=1
    Check X2 State Available or Unavailable    state=available
    Check Unlocked Cell State
    UE Attach and Establish EN-DC    ue_id=15    ue_nr_capabilities=${ue_nr_capabilities}    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}


Lock Cell and Lock X2 on gNB
    delta commission parameters    ${Online_Param_Lock_Cell}
    Check Locked Cell State
    Wait Until Keyword Succeeds    30s    5s    Object Should Not Exist    LTEENB:x2LinkStatus=available


Unlock X2 Unlock cell on gNB and check
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=Attempt to SCTP connection to    timeout=120
    Check Locked Cell State
    delta commission parameters    ${Online_Param_Unlock_Cell}
    Check X2 State Available or Unavailable    state=available
    Check Unlocked Cell State
    UE Attach and Establish EN-DC    ue_id=16    ue_nr_capabilities=${ue_nr_capabilities}    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Check Locked Cell State
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=disabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred

Check Unlocked Cell State
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred

Check X2 State Available or Unavailable
    [Arguments]    ${state}
    Wait Until Keyword Succeeds    30s    5s    Object Should Exist    LTEENB:x2LinkStatus=${state}

Detach UEs
    Execute Egate Command    ue_detach id=11    UE IS OFF
    Execute Egate Command    ue_detach id=15    UE IS OFF
    Execute Egate Command    ue_detach id=16    UE IS OFF