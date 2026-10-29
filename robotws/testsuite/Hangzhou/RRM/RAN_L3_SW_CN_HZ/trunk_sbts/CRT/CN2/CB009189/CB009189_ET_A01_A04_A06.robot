*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-QIAN QIAN.GUO
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{2271_related_modification}
...    @{9189_related_modification}
...    @{9189_alternate_drx_enabled}
...    @{9189_IWK_5GC002426_CB008847}
...    @{9189_IWK_CA}
...    @{GBR_5qi_2}
...    @{nonGBR_5qi_80}
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0

@{2271_related_modification}
...    NRCELL-11:actVoNR=true
...    NRCELL-11:actEnhancedVoNR=true
...    NRCELL-11:actAdaptiveSr=true
...    NRCELL-11:adaptiveSrBlockingMinimization=20
...    NRCELL-11:adaptiveSrLoadThresholdDown=50
...    NRCELL-11:adaptiveSrLoadThresholdUp=80
...    NRCELL-11:vonrReservation=15
...    NRCELL-11:srPeriodicity=slots80
...    NRCELL-11:srPeriodicityMin=slots20
...    NRCELL-11:preferredVoNrSrPeriod=slots40
...    NRCELL-1:actVoNR=true
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-1:actAdaptiveSr=true
...    NRCELL-1:adaptiveSrBlockingMinimization=20
...    NRCELL-1:adaptiveSrLoadThresholdDown=50
...    NRCELL-1:adaptiveSrLoadThresholdUp=80
...    NRCELL-1:vonrReservation=15
...    NRCELL-1:srPeriodicity=slots160
...    NRCELL-1:srPeriodicityMin=slots20
...    NRCELL-1:preferredVoNrSrPeriod=slots80

@{9189_related_modification}
...    NRBTS/NRDRB-11:srPeriodicityDrb=40ms
...    NRBTS/NRDRB-11:payloadSizeSRDrb=4
...    NRBTS/NRDRB-12:srPeriodicityDrb=20ms
...    NRBTS/NRDRB-12:payloadSizeSRDrb=500
...    NRBTS/NRDRB-13:srPeriodicityDrb=5ms
...    NRBTS/NRDRB-13:payloadSizeSRDrb=1000
...    NRCELL-1:actServiceAwareConfig=true
...    NRCELL-11:actServiceAwareConfig=true

@{9189_alternate_drx_enabled}
...    NRCELL-11:actCDrx=true
...    NRCELL-11:actCDrxVoNR=true
...    NRCELL-11:drxProfile1:drxInactivityTimer=40ms|drxRetransTimerUl=16slot
...    NRCELL-11:drxProfile1:drxLongCycle=80ms|drxRetransTimerUl=16slot
...    NRCELL-11:drxProfile1:drxOnDurationTimer=10ms|drxRetransTimerUl=16slot
...    NRCELL-11:drxProfile1:drxRetransTimerDl=16slot|drxRetransTimerUl=16slot
...    NRCELL-11:drxProfile2:drxInactivityTimer=4ms|drxRetransTimerUl=0slot
...    NRCELL-11:drxProfile2:drxLongCycle=40ms|drxRetransTimerUl=0slot
...    NRCELL-11:drxProfile2:drxOnDurationTimer=6ms|drxRetransTimerUl=0slot
...    NRCELL-11:drxProfile2:drxRetransTimerDl=0slot|drxRetransTimerUl=0slot

@{9189_IWK_5GC002426_CB008847}
...    MRBTS-1/NRBTS-1:actConnRrcPooling=true
...    MRBTS-1/NRBTS-1:actScheUePooling=true

@{9189_IWK_CA}
...    NRBTS:actCarrierAggregation=true

...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:sCellActivationMethod=blind
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa

@{GBR_5qi_2}
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB-16:discardTimer=300ms
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=35
...    NRBTS/NRDRB-16:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-16:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=1
...    NRBTS/NRDRB-16:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-16:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    delete:NRBTS/NRDRB-16:drbInactivityTimerSA

@{nonGBR_5qi_80}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=80
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    delete:NRBTS/NRDRB-15:drbInactivityTimerSA

@{OnlineParam_for_A04}
...    NRBTS/NRDRB-11:srPeriodicityDrb=20ms
...    NRBTS/NRDRB-15:srPeriodicityDrb=80ms
...    NRBTS/NRDRB-16:srPeriodicityDrb=10ms
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-11:srPeriodicityMin=slots10

@{OnlineParam_for_A06}
...    NRBTS/NRDRB-12:srPeriodicityDrb=5ms
...    NRBTS/NRDRB-13:srPeriodicityDrb=80ms

*** Test Cases ***
CB009189-ET-A01_CA_F_T_SA_9189_enabling_non-VoNR_addmission_control_multiDRB_AMFdel_all9189DRBs_and_add_VoNR
    [Documentation]
    ...    1. This user scenario describes SRperiodicity reconfigurred after add or delete 9189 drbs for
    ...    SA+FDD+non-VoNR scenario.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled. srPeriodicityDrb is configurred for several NRDRBs.
    ...    3. Test Case Steps:
    ...    a.UE register and setup 9189 DRB1, and check SR period selection.
    ...    b.add 9189 DRB2, check SR periodicity.
    ...    c.delete 9189 DRB3, check SR periodicity.
    ...    d.add vonr and delete 9189 DRB1, check SR periodicity.
    ...    e.UE deregister.
    [Tags]    QC_223934    owner-QIAN QIAN.GUO
    UE Attach To Target Cell and Setup DRB1    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl5
    Add 9189 drb2 on NRCELL-11    ue_id=81    regexp=schedulingRequestResourceToAddModList
    Add 9189 drb3 on NRCELL-11    ue_id=81    regexp=schedulingRequestResourceToAddModList
    Del 9189 drb2 and drb3 on NRCELL-11    ue_id=81    regexp=chedulingRequestResourceToAddModList
    Setup VONR on NRCELL-11 and del DRB1    ue_id=81    regexp=periodicityAndOffset sl40
    UE Deregister From gNB    ue_id=81
    Check RRC log    ${CURDIR}${/}a2a_CB009189A01${/}a2a.ini

CB009189-ET-A04_SA_FDD_VoNR_5QI_1_5_online_UE1_add_9189_DRBs_AMFdel_one_9189_DRB_readd
    [Documentation]
    ...    1. This user scenario describes SRperiodicity reconfigurred after add or delete 9189 drbs for
    ...    SA+FDD+VoNR scenario.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled. srPeriodicityDrb is configurred for several NRDRBs.
    ...    3. Test Case Steps:
    ...    a.change default 5qi to 5qi5
    ...    b.UE register and setup 2271 DRB, and check SR period selection.
    ...    c.setup VONR, check SR period selection.
    ...    d.delete vonr DRB, and check SR period selection.
    ...    e.add vonr and 9189 DRB, check SR period selection.
    ...    f.delete 9189 DRB, check SR period selection.
    ...    g.UE deregister.
    [Tags]    QC_223933    owner-QIAN QIAN.GUO
    OnlineParamChange    ${OnlineParam_for_A04}
    Modify default qosflow    qos_flow=5
    UE Attach To Target Cell and Setup DRB1    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl10
    Add vonr drb on NRCELL-11    ue_id=81    regexp=periodicityAndOffset sl20
    Add 9189 drb1 and drb2 on NRCELL-11    ue_id=81    regexp=periodicityAndOffset sl10
    Del 9189 drb2 and add drb3 on NRCELL-11    ue_id=81    regexp=periodicityAndOffset sl20
    Add 9189 drb4 on NRCELL-11    ue_id=81    regexp=periodicityAndOffset sl5
    UE Deregister From gNB    ue_id=81
    Check RRC log    ${CURDIR}${/}a2a_CB009189A04${/}a2a.ini

CB009189-ET-A06_TDD_SA_VoNR_add_5QI_5_1_and_9189sl160_AMFdel_5QI1_or_9189sl160
    [Documentation]
    ...    1. This user scenario describes SRperiodicity reconfigurred after add or delete 9189 drbs for
    ...    SA+TDD+VoNR scenario.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    3. Test Case Steps:
    ...    a.change default 5qi to 5qi5
    ...    b.UE register and setup 2271 DRB, and check SR period selection.
    ...    c.setup VONR and add 9189 DRB1, check SR period selection.
    ...    d.delete vonr DRB, and check SR period selection.
    ...    e.delete 9189 DRB1, check SR period selection.
    ...    f.add vonr ans 9189 DRB2, check SR period selection.
    ...    g.delete 9189 DRB2, check SR period selection.
    ...    h.UE deregister.
    [Tags]    QC_222500    owner-QIAN QIAN.GUO
    OnlineParamChange    ${OnlineParam_for_A06}
    Modify default qosflow    qos_flow=5
    UE Attach To Target Cell and Setup DRB1    ue_id=81    cell_id=1    regexp=periodicityAndOffset sl20
    Add vonr and 9189 drb1 on NRCELL-1    ue_id=81    regexp=periodicityAndOffset sl80
    Del vonr drb on NRCELL-1    ue_id=81    regexp=periodicityAndOffset sl160
    Del 9189 drb1 on NRCELL-1    ue_id=81    regexp=periodicityAndOffset sl20
    Add vonr and 9189 drb2 on NRCELL-1    ue_id=81    regexp=periodicityAndOffset sl10
    Del 9189 drb2 on NRCELL-1    ue_id=81    regexp=periodicityAndOffset sl80
    UE Deregister From gNB    ue_id=81
    Check RRC log    ${CURDIR}${/}a2a_CB009189A06${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=10 5qi=80

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Attach To Target Cell and Setup DRB1
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=70    send_ul=800    sleep_time=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=81    ${qfi}=1    ${send_dl}=70    ${send_ul}=800    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul kbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.7    ${send_ul}*0.7    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Add 9189 drb2 on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:7
    should not contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s

Add 9189 drb3 on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:6
    should not contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=720    sleep_time=2s

Del 9189 drb2 and drb3 on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=6,7 by=amf
    ...    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 6 qfi 3
    should contain    ${retvalue}    Removed FiveQi:Qfi mapping fiveQi 7 qfi 2
    should not contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s

Setup VONR on NRCELL-11 and del DRB1
    [Arguments]    ${ue_id}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:5
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 qosflows_to_del=8 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:1
    should contain    ${retvalue}    Removed FiveQi:Qfi mapping fiveQi 8 qfi 1
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=720    sleep_time=2s

Add vonr drb on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:1
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=800   sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s

Modify default qosflow
    [Arguments]    ${qos_flow}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow} priority=1

Add 9189 drb1 and drb2 on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2,6 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:2
    should contain    ${retvalue}    Added QosFlow with QFI:4 fiveQI:6
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=800    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=4    send_dl=10    send_ul=800   sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=720    sleep_time=2s

Del 9189 drb2 and add drb3 on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=10 qosflows_to_del=2 by=amf
    ...    pass_regexp=Added QosFlow with QFI:5 5QI:80
    should contain    ${retvalue}    Removed FiveQi:Qfi mapping fiveQi 2 qfi 3
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=5    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=720    sleep_time=2s

Add 9189 drb4 on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=8 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:8
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=5    Tput_dl=9    Tput_ul=720    sleep_time=2s

Add vonr and 9189 drb1 on NRCELL-1
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1,8 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:8
    should contain    ${retvalue}    Added QosFlow with QFI:2 5QI:1
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=800    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s


Del vonr drb on NRCELL-1
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=1 by=amf
    ...    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 1 qfi 2
    should contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=720    sleep_time=2s

Del 9189 drb1 on NRCELL-1
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=8 by=amf
    ...    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 8 qfi 3
    should contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s

Add vonr and 9189 drb2 on NRCELL-1
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1,7 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:7
    should contain    ${retvalue}    Added QosFlow with QFI:3 5QI:1
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=800    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s

Del 9189 drb2 on NRCELL-1
    [Arguments]    ${ue_id}    ${regexp}
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=7 by=amf
    ...    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 7 qfi 2
    should contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=720    sleep_time=2s
