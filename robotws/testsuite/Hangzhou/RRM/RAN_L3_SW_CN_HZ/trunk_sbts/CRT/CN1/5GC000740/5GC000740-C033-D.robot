*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC000740
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{5GC000740_HO_flag}    @{MultiAMF}    @{PLMN}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}
...    @{NRHOIF}    @{NRADJNRCELL}    @{A2_A3_event}    @{XNLINK}    @{NRADJGNB}

@{5GC000740_HO_flag}
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1:actIncXn=true
...    NRBTS-1:actInterFreqHoSA=true

...    NRPMRNL-1:miNrRelReportCu=5min

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-3:amfIPAddress=10.0.1.103
...    SERVEDAMF-3:administrativeState=Unlocked

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{NRADJGNB}
...    NRADJGNB-5:administrativeState=Unlocked
...    NRADJGNB-5:gNodeBId=36
...    NRADJGNB-5:gNbIdLength=22
...    NRADJGNB-5:xnLinkRef=5
...    NRADJGNB-5:gnbPlmn:mcc=311
...    NRADJGNB-5:gnbPlmn:mnc=489
...    NRADJGNB-5:gnbPlmn:mncLength=3

@{XNLINK}
...    XNLINK-5:cPlaneIpAddr=10.0.1.124

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=36
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:scs=30 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=637248
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:freqBandIndicatorNR=78
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636660
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:ssbFrequency=637248

@{A2_A3_event}
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=25
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{fault_7317}    fault_id=7317    fault_name=NgSetupStopRetry

*** Test Cases ***
5GC000740-ET-C033_Verify_successful_AMF_selection_during_Xn_handover_at_target_gNB
    [Documentation]
    ...    1. This case is to verify failed NG links can not be repaired after lock-unlock action.
    ...       All NG-C link will failed with cause that MISC_control_processing_overload.
    ...       The NG-C can't be repaired after locking and unlocking all AMF.
    ...    2. This user scenario describes the case where Xn handover is performed and the target gNB has to select and route
    ...       the first NGAP message to an AMF, based on the information received from source gNB.
    ...    3. This user scenario describes XN Setup and XN NG-RAN Node Configuration Update with transfer of AMF Region Information addition and
    ...       deletion upon AMF Configuration update from AMF
    ...    AMF-1 -> region-1
    ...    AMF-2 -> region-2
    ...    AMF-3 -> region-3
    [Tags]    QC_60758    5GC000740-C033    5GC000740-D    5GC000740-B022
    Tigger NG Failed with Overload
    Check NGlink and Xnlink status    amfs_status=Inactive
    Lock and Unlock AMF
    Check NGlink and Xnlink status    amfs_status=Inactive
    Reset AMF to default values and All Nglinks should be Active
    Add UE History Information List
    UE Register and PDU setup on AMF1
    Trigger Inter-Frequency Inter-gNB HO from sim-gnb to real-gnb
    Modify AMF3 from region-3 to region-4
    release ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_C033_D${/}a2a.ini    wait_string=UEContextReleaseComplete

*** Keywords ***
Modify Cfg
#sim gnb5
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1-2
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=16:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636660:636660
    ...    gscn=7887 mandatory_for_activation=off
    Update Cfg    ${set_gnb5}
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=on send_xn_setup=false sib1_period=40
    #other
    Update Cfg Param    set_ue simulated id=1 enb=5 cell=1
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf_region id=4 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=1 pointer=2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=1 pointer=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 ue=all amf=1-3 default=on

Check NGlink and Xnlink status
    [Arguments]    ${amfs_status}=Active
    object should exist    SERVEDAMF-1:ngLinkStatus=${amfs_status}
    object should exist    SERVEDAMF-2:ngLinkStatus=${amfs_status}
    object should exist    SERVEDAMF-3:ngLinkStatus=${amfs_status}
    object should exist    XNLINK:xnLinkStatus=available

Tigger NG Failed with Overload
    Check NGlink and Xnlink status
    execute egate command    amf_ng_setup_param id=1-3 reset
    execute egate command    amf_ng_setup_param id=1 gnb=2 action=force_failure cause=MISC_control_processing_overload nth=1 ntimes=indefinite
    execute egate command    amf_ng_setup_param id=2 gnb=2 action=force_failure cause=MISC_control_processing_overload nth=1 ntimes=indefinite
    execute egate command    amf_ng_setup_param id=3 gnb=2 action=force_failure cause=MISC_control_processing_overload nth=1 ntimes=indefinite
    Lock and Unlock AMF
    rrc should contain    NG Setup Failure with cause-MISC_control_processing_overload
    fm fault should be raised    ${fault_7317}

Lock and Unlock AMF
    ${params_lock}    create list    SERVEDAMF-1:administrativeState=Locked    SERVEDAMF-2:administrativeState=Locked
    ...    SERVEDAMF-3:administrativeState=Locked
    delta commission parameters    ${params_lock}
    ${params_unlock}    create list    SERVEDAMF-1:administrativeState=Unlocked    SERVEDAMF-2:administrativeState=Unlocked
    ...    SERVEDAMF-3:administrativeState=Unlocked
    delta commission parameters    ${params_unlock}
    cells should be onair    check_sib=${False}

Reset AMF to default values and All Nglinks should be Active
    fm fault should be raised    ${fault_7317}
    execute egate command    amf_ng_setup_param id=1-3 reset
    Lock and Unlock AMF
    fm fault should be cleared    ${fault_7317}
    Check NGlink and Xnlink status

Add UE History Information List
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=5 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    Execute Egate Command    ue_history_information_list id=1 action=commit
    Execute Egate Command    ue_enb_param id=1 ue_history_list=1

Trigger Inter-Frequency Inter-gNB HO from sim-gnb to real-gnb
    ${A2_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=637248    event_type=A2
    ${A2_cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${A2_measid} event=A2 srsrp_nr=7 srsrq_nr=7
    Execute Egate Command    ${A2_cmd}    eventA3
    ${A3_measid}    get nr meas id for specific type and frequency    ue_id=1    carrierfreq=636576    event_type=A3
    ${A3_cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${A3_measid} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${A3_cmd}    Inter-eNB handover
    Verify Throughput

UE Register and PDU setup on AMF1
    Execute Egate Command    ue_nr_rrc_setup_param id=1 registered_amf=311:489|1:1:1
    Execute Egate Command    ue_register id=1    AMF-1:.*NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1    QoS Routing Table
    Send Throughput
    Verify Throughput

Modify AMF3 from region-3 to region-4
    Execute Egate Command    amf_config_update id=3 plmn=311:489 amfi=4:1:3    Received AMF Configuration Acknowledge from GNB-2

Send Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10    UDP UL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=10    UDP DL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9.5
    Should Be True    ${dl_throuput}/1000>9.5
