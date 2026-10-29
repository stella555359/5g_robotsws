*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G    PY310
...           SBTS00    SBTS23R1    CRT    SBTS23R2    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Rafal Magnowski
...              :contact: rafal.magnowski@nokia.com

Resource    CNI75624_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_DRX_on_and_A2_A5_meas_on.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_inter_gnb_and_event_A2_A5.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_DRX_on_and_A2_A5_meas_on.json
...               AND             Find Scfc and Send Delta Commissioning    scfc_filename=remove_nrrel.json
...               AND             Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${DEFAULT_DRX_RELEASE} =    ${RRC_RECONFIGURATION} && nr-rrc.drx_Config == 0
${DEFAULT_DRX_SETUP_COMPLETE} =   ${RRC_RECONFIGURATION} && nr-rrc.drx_Config == 1 && nr-rrc.milliSeconds == 7
${DEDICTED_DRX_SETUP_COMPLETE} =   ${RRC_RECONFIGURATION} && nr-rrc.drx_Config == 1 && nr-rrc.milliSeconds == 8
${MEASUREMENT_GAPS_SETUP} =    ${RRC_RECONFIGURATION} && nr-rrc.gapFR1 == 1
${MEASUREMENT_GAPS_RELEASE} =    ${RRC_RECONFIGURATION} && nr-rrc.gapFR1 == 0

*** Test Cases ***
CNI75624_B1_Intra_NR_ANR_SA_Dedicated_DRX_Setup_Success
    [Documentation]    Testcase verifies the gNB behaviour of adding dedicated DRX profile.
    ...                Default DRX is released and after that dedicated DRX is configured for ANR Ho purpous.
    ...                Ue4 check if deafult DRX are restored after HO is failed after dedicated DRX where set up.
    ...                Reqirement ID for TC - 5G_RAN_USR_RRM_15402

    Attach Ue And Establish Pdu Session    ue_id=4
    Set UE To Not Send NRCGI Measurement Report    ue_id=4
    Send Custom Measurement And Wait For Reconfiguration Complete    ue_id=4    meas_id=4    event=A5    phycell_id=51
    Verify Traces For Setup Default Drx After Failed HO

    Attach Ue And Establish Pdu Session    ue_id=1
    Send Custom Measurement With Delay And Wait For Reconfiguration Complete    ue_id=1    meas_id=4    event=A5    phycell_id=51
    Verify Traces For Release Default Drx And Setup Dedicated DRX
    Add Scout External Execution ID To Reporting Portal

CNI75624_B1_A1_Intra_NR_ANR_SA_Dedicated_DRX_Setup_Witch_Meas_Gaps_configured
    [Documentation]    Testcase verifies the gNB behaviour of adding dedicated DRX profile.
    ...                In this scenario meas gaps are configured by A2 even instead default DRX profile.
    ...                After A5 event measGaps are relased and dedcated DRX are configured
    ...                Reqirement ID for TC - 5G_RAN_USR_RRM_15402

    Attach UE And Establish PDU Session    ue_id=2
    Send Custom Measurement With Delay And Wait For Reconfiguration Complete    ue_id=2    meas_id=1    event=A2    phycell_id=150
    Send Custom Measurement With Delay And Wait For Reconfiguration Complete    ue_id=2    meas_id=4    event=A5    phycell_id=150
    Verify Traces For Release Measurement Gaps And Setup Dedicated DRX
    Add Scout External Execution ID To Reporting Portal

CNI75624_B1_A3_Intra_NR_ANR_SA_Dedicated_DRX_Setup_T321_Timer_Expiration_Or_No_CGI_IE
    [Documentation]    Testcase verifies the gNB behaviour of adding dedicated DRX profile.
    ...                In this scenario no CGI reprt is send durung A5 event Meas Gaps are configured.
    ...                Reqirement ID for TC - 5G_RAN_USR_RRM_15402

    Attach Ue And Establish Pdu Session    ue_id=3
    Send Custom Measurement With Delay And Wait For Reconfiguration Complete    ue_id=3    meas_id=1    event=A2    phycell_id=151
    Set UE To Not Send NRCGI Measurement Report    ue_id=3
    Send Custom Measurement And Wait For Reconfiguration Complete    ue_id=3    meas_id=4    event=A5    phycell_id=151
    Verify Traces For Release Measurement Gaps And Setup Dedicated DRX
    Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}
    Attach UE    ue_id=${ue_id}
    Establish Pdu Session With Traffic    ue_id=${ue_id}    gw_id=${ue_id}

Send Custom Measurement With Delay And Wait For Reconfiguration Complete
    [Arguments]    ${ue_id}    ${meas_id}    ${event}    ${phycell_id}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=200
    Sleep    1s    reason=Waiting for delay to be processed
    Send Custom Ue Measurement Nr    id=${ue_id}    meas_id=${meas_id}    index=0    nrs_result=125:125:0
    ...                              event=${event}    phycell_id=${phycell_id}    nrsrq_nr=125    srsrq_nr=17
    Sleep    3s    reason=Waiting for measurement to be processed

Send Custom Measurement And Wait For Reconfiguration Complete
    [Arguments]    ${ue_id}    ${meas_id}    ${event}    ${phycell_id}
    Send Custom Ue Measurement Nr    id=${ue_id}    meas_id=${meas_id}    index=0    nrs_result=125:125:0
    ...                              event=${event}    phycell_id=${phycell_id}    nrsrq_nr=125    srsrq_nr=17
    Sleep    3s    reason=Waiting for measurement to be processed

Set UE To Not Send NRCGI Measurement Report
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}    if_contains=report_cgi    action=donot_send_NRCGI

Verify Traces For Release Default DRX And Setup Dedicated DRX
    Verify Tcpdump Log    packet_filter=${DEFAULT_DRX_RELEASE}    number_of_messages=4
    Verify Tcpdump Log    packet_filter=${DEDICTED_DRX_SETUP_COMPLETE}    number_of_messages=2    relation_symbol= >=

Verify Traces For Release Measurement Gaps And Setup Dedicated DRX
    Verify Tcpdump Log    packet_filter=${DEFAULT_DRX_RELEASE}
    Verify Tcpdump Log    packet_filter=${MEASUREMENT_GAPS_SETUP}
    Verify Tcpdump Log    packet_filter=${MEASUREMENT_GAPS_RELEASE}
    Verify Tcpdump Log    packet_filter=${DEDICTED_DRX_SETUP_COMPLETE}

Verify Traces For Setup Default DRX After Failed HO
    Verify Tcpdump Log    packet_filter=${DEFAULT_DRX_SETUP_COMPLETE}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${DEDICTED_DRX_SETUP_COMPLETE}
