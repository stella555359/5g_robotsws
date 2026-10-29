*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CIT    CDRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...               team-SG2    owner-xianjiao.xie    release-5G20A    5GC000708
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{CIT029_Base}

@{CIT029_Base}
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=45
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeasRedirectEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=none
...    MRBTS-1/NRBTS-1:actRedirect=true
...    MRBTS-1/NRBTS-1:actUeCapaEnquiryHoCa=true
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=9
...    MRBTS-1/NRBTS-1:cipherPrefL:nea1_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea2_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:nullFallback=true
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqNr
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirFreqEutra=1350
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-0:redirPrio=2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-0:redirPrio=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirRat=eutra
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs
...    MRBTS-1/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=30
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=30
...    MRBTS-1/NRBTS-1/NRCELL-1:rlpDetCsiBsiThreshold=10000


${UE_CAPA_UE}    SEPARATOR=
...    E1A0700007D0F7F17DECE6B83A000D01A4FFCDE3F998024026C038FFCC31E50B03C3E0101F8A0300A67002B8F88DAC31B47498A823F96524CA0
...    D00416C9824060C78C7FE618F28581C0E1E013FFFFFFFEFFFFFFFF8B80001C00158388C0000002C0800808C2A00034030226C73E1FFAAAAA82E
...    003E002A1C1401C0FC2400703E01C8200000148200000548200000949280000D300F81B795378195BA401410000096526040000659490100002
...    96524040000E594941000049652424000154B29200BA07974AA2E81C4D2A89A55115D8816007801A0100800000000002004008D40A800102030
...    3898081858808890C860C0D8FA092931394122A400

@{PM_Counters_Check_CIT029}
...    NRCELL-1:${NRRCC_RRC_RELEASE_REDIR_LTE}=1

${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502    #Number of RRC Releases with LTE frequency redirection information


@{Delta_708_actRedirect_False}
...    NRCELL:a2MeasRedirectEnabled=rsrp
...    NRBTS:actRedirect=false

@{Delta_708_actRedirect_True}
...    NRCELL:a2MeasRedirectEnabled=none
...    NRBTS:actRedirect=true

*** Test Cases ***
5GSW-CP-CIT029_Verify Classical SA FDD cmWave_UE is redirected to LTE via RRC Connection Release due to A2 event with RSRP non SRB3
    [Documentation]    This user scenario describes the gNB behavior, for a UE for which A2 measurements for redirection
    ...    have been configured. UE/Airphone sends a A2 measurement report and gNB performs RRC Connection Release with\
    ...    redirection information procedure specifying the redirection target.
    [Tags]    QC_61694    5GC000708_D003
    Register UE
    UE Triggers A2
    Analyze wireshark log
    Check Counters    ${PM_Counters_Check_CIT029}
    OnlineParamChange    ${Delta_708_actRedirect_False}
    Ue Register And Not Contain EventA2    3
    OnlineParamChange    ${Delta_708_actRedirect_True}
    Ue Register And Not Contain EventA2    4
    Release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
    ${Variables_UE}    catenate
    ...    ue_param id=1 ue_nr_capabilities=${UE_CAPA_UE}
    Update Cfg    ${Variables_UE}
    ${Variables_UE}    catenate
    ...    ue_param id=2 ue_nr_capabilities=${UE_CAPA_UE}
    Update Cfg    ${Variables_UE}
    ${Variables_UE}    catenate
    ...    ue_param id=3 ue_nr_capabilities=${UE_CAPA_UE}
    Update Cfg    ${Variables_UE}

Register UE
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table


Ue Register And Not Contain EventA2
    [Arguments]    ${ue_id}=2
    execute egate command    state_sim_disp
    execute egate command    ue_change_location id=${ue_id} cell=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registe
    ${ret1}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table
    should not contain    ${ret1}    eventA2

UE Triggers A2
    Execute Egate Command     ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=Redirected carrier info is present in RRC Release

Analyze wireshark log
    Check Wireshark Log     ${CURDIR}${/}a2a_CIT029${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    BuiltIn.Log To Console    Wirshark check is done

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir