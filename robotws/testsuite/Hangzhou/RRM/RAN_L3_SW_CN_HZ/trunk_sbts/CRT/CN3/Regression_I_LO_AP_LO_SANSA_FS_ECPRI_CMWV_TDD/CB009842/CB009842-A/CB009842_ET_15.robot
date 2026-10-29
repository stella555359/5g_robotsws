*** Settings ***
Documentation
...    author: Geng Lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env And IP added for simGNB
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-CN3ET    owner-lishuo.geng    release-SBTS24R2     CB009842
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    True
@{PARAMS_IN_SCF}
...    @{8281_enable}
...    @{9842_enable}

@{9842_enable}
...    NRCELL:actUlNrEcIdTAdv=true
...    NRBTS:nrEcidMeasSupervisionTimer=2600

@{8281_enable}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:timerRRCGuard=2000


*** Test Cases ***


CB009842-SR-A-B5_ET_15_01_Successful E-CID Measurement Reporting for TADV along with RSRP and RSRQ with failure due to measurement report timeout
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:Verify that gNB-CU-CP sends E-CID MEASUREMENT INITIATION RESPONSE with
    ...        Tadv and Cell-Id when there is no Measurement Report from UE for any of the E-CID Measurement Quantities and E-CID Measurement
    ...        supervision timer expired activation configuration is updated at NRCELL level.
    ...    2. Test Case Steps:
    ...      1) setup SA call for UE1 sucessfully.
    ...      2) delay 3s to send MR.
    ...      3) egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:SS-RSRP and SS-RSRQ
    ...         and Tadv from LMF to UE1.
    ...      4) gNB response E-CID MEASUREMENT INITIATION RESPONSE with NR-TADV value and Cell-ID filled
    [Tags]     owner-lishuo.geng
    SA UE attach with single PDU
    Delay Measurement Report from UE
    trigger E-CID Measurement Initiation request    meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    Recover Measurement Report from UE
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_A015${/}a2a.ini    wait_string=UEContextReleaseComplete::8


*** Keywords ***
Common Suite Setup And Setup Airphone Env And IP added for simGNB
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK


Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh


Delay Measurement Report from UE
    [Arguments]    ${ue_id}=1    ${delay}=8000
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=${delay} srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

Recover Measurement Report from UE
    [Arguments]    ${ue_id}=1
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=0 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    sleep    1s    #wait nrEcidMeasSupervisionTimer timeout


SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=2    ${sleep_time}=5
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=${sleep_time}
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached    timeout=10s


