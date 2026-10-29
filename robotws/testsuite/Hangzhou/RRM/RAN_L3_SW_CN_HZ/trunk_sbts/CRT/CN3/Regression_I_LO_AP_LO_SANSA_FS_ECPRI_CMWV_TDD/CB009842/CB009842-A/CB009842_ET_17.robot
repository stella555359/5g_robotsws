*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env And IP added for simGNB
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO
...    team-CN3ET    owner-xu.wang    release-SBTS24R2     CB009842
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB009842}
...    @{CB008281}
...    @{5GC000740}
...    @{CB006999}

@{CB006999}
...    NRBTS:actAmfPlannedRemoval=true
...    NRBTS:amfPlannedRemovalTimer=0

@{CB009842}
...    NRCELL:actUlNrEcIdTAdv=true

@{CB008281}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:timerRRCGuard=6000
...    NRBTS:nrEcidMeasSupervisionTimer=6500

@{5GC000740}
...    NRBTS-1:actNgcFlexSaMode=true
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:administrativeState=Unlocked

*** Test Cases ***
CB009842-SR-A_ET_17_01_Handling of E-CID Measurement Report during NGAP AMFStatusIndication received with Timer Approach for GUAMI Removal
    [Documentation]
    ...       The purpose of this test case is to check the behaviour when AMFStatusIndication received during E-CID Measurement Reporting
    ...       1 gNB response E-CID MEASUREMENT INITIATION RESPONSE if Same AMF valid GUAMI reselected:
    ...       1.1 UE registered to amf1 guami1 311:489|1:2:1
    ...       1.2 delay 8s to send MR , then UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue:
    ...           NR Timing Advance and sS-RSRP,ReportCharacteristics: onDemand
    ...       1.3 reselected guami2 of amf1 (send_amf_status_indication)
    ...       1.4 gNB response E-CID MEASUREMENT INITIATION RESPONSE
    ...       2 gNB skip E-CID MEASUREMENT INITIATION RESPONSE if new AMF reselected
    ...       2.1 UE registered to amf1 guami2 311:489|1:2:2
    ...       2.2 delay 8s to send MR , then UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue:
    ...           NR Timing Advance and sS-RSRP,ReportCharacteristics: onDemand
    ...       2.3 reselected new amf2 (send_amf_status_indication)
    ...       2.4 gNB skip E-CID MEASUREMENT INITIATION RESPONSE
    ...       3 gNB skip E-CID MEASUREMENT INITIATION RESPONSE if no valid GUAMI can be reselected
    ...       3.1 UE registered to amf2 guami1 311:489|2:2:2
    ...       3.2 delay 8s to send MR , then UE-1: LMF trigger "E-CID Measurement Initiation request" with measurementQuantitiesValue:
    ...           NR Timing Advance and sS-RSRP,ReportCharacteristics: onDemand
    ...       3.3 no valid guami can be reselected (send_amf_status_indication)
    ...       3.4 gNB skip E-CID MEASUREMENT INITIATION RESPONSE
    [Tags]
    trigger E-CID Measurement Initiation request Then Same AMF Valid GUAMI selected
    trigger E-CID Measurement Initiation request Then New AMF selected
    trigger E-CID Measurement Initiation request Then No Valid GUAMI selected
    Check Wireshark Log    ${CURDIR}${/}A2A_A017${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    [teardown]    Test Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env And IP added for simGNB
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK
    execute egate command    sim_trace amf=1,2 protocol=ng on

Test Teardown
    sleep    20    #clear fault 7325
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    update cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_amf id=1 name=AMF1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=1,2
    Update Cfg    set_amf id=2 name=AMF2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=2

SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=1    ${sleep_time}=0    ${registered_amf}=311:489|1:2:1    ${amf_id}=1    ${guami_index}=1
    Execute Egate Command    ue_nr_rrc_setup_param id=1 registered_amf=${registered_amf}
    Execute Egate Command    amf_registration_param id=${amf_id} guami_index=${guami_index}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${sleep_time}
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

Delay Measurement Report from UE
    [Arguments]    ${ue_id}=1    ${delay}=6000
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=${delay} srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP,NR_Timing_Advance    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s

trigger E-CID Measurement Initiation request Then Same AMF Valid GUAMI selected
    SA UE attach with single PDU    registered_amf=311:489|1:2:1    amf_id=1    guami_index=1
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,NR_Timing_Advance    pass_regexp=will be sent after 6000 ms
    ${cmd}    Catenate    send_amf_status_indication id=1 guami_index=1 timer_guami_removal=on action=redirect_other_guami
    Execute Egate Command    ${cmd}    pass_regexp=Received ECID Measurement Response    timeout=8
    UE Deregister From gNB

trigger E-CID Measurement Initiation request Then New AMF selected
    SA UE attach with single PDU    registered_amf=311:489|1:2:2    amf_id=1    guami_index=2
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,NR_Timing_Advance    pass_regexp=will be sent after 6000 ms
    ${cmd}    Catenate    send_amf_status_indication id=1 guami_index=2 backup_amf_index=1 timer_guami_removal=on
    ...    action=redirect_other_amf redirect_amf_index=1
    Execute Egate Command    ${cmd}    fail_regexp=Received ECID Measurement Response    timeout=8
    UE Deregister From gNB

trigger E-CID Measurement Initiation request Then No Valid GUAMI selected
    SA UE attach with single PDU    registered_amf=311:489|2:2:2    amf_id=2    guami_index=1
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,NR_Timing_Advance    pass_regexp=will be sent after 6000 ms
    ${cmd}    Catenate    send_amf_status_indication id=2 guami_index=1 timer_guami_removal=on action=redirect_other_guami
    Execute Egate Command    ${cmd}    fail_regexp=Received ECID Measurement Response    timeout=8