*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00    CONFIGURED
...           RAN_5G_TDD    RAN_5G    PY310
...           NoResUsage    RF50

Documentation    :copyright: Nokia
...              :author: Kamila Bialczyk
...              :contact: kamila.bialczyk@nokia.com

Resource     ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_ue_measurements
Library      ta5g_testline_management

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/airphone/egate_2c_tdd_2c_fdd_sansa.lua
...             AND             Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=true
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Run Keywords    Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=false
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${CHECK_AES_ALGORITHMS}=    ${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}  and
...    nr-rrc.integrityProtAlgorithm == 2  and nr-rrc.cipheringAlgorithm == 2
${CHECK_ZUC_ALGORITHMS}=    ${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}  and
...    nr-rrc.integrityProtAlgorithm == 3  and  nr-rrc.cipheringAlgorithm == 3
${CHECK_SNOW3G_ALGORITHMS}=    ${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}  and
...    nr-rrc.integrityProtAlgorithm == 1  and nr-rrc.cipheringAlgorithm == 1

*** Test Cases ***
5GC000544_Dl_Ul_Rrc_Message_Transfer_Over_Srb3_Success_With_Aes_Zuc_Snow3g
    [Tags]    CRT    SBTS23R1    SBTS22R4
    [Documentation]     This is to verify:
    ...                 1. If UL RRC message is successfully transferred with AES security
    ...                 2. If DL RRC message is successfully transferred with ZUC security
    ...                 3. If UL RRC message is successfully transferred with ZUC security
    ...                 4. If DL RRC message is successfully transferred with SNOW3G security
    ...                 5. If UL RRC message is successfully transferred with SNOW3G security

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_A3_meas_enable_with_aes.json
    Attach Ue To Enb And Start Gnb Addition    ue_id=101
    Send Ue Measurement Nr    ue_id=101     meas_id=1     index=0    nrs_result=40:0:0    event=A3     phycell_id=10
    ...                       nrsrp_nr=40     srsrp_nr=30
    Verify Tcpdump Log    packet_filter=${CHECK_AES_ALGORITHMS}
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER}

    Detach Ue And Restore Default Ul Parameters    ue_id=101

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_zuc_and_actcdrx_true.json
    Attach Ue To Enb And Start Gnb Addition    ue_id=102
    Verify Tcpdump Log    packet_filter= ${CHECK_ZUC_ALGORITHMS}
    Verify Tcpdump Log    packet_filter= ${F1AP_DL_RRC_MESSAGE_TRANSFER}

    Detach Ue And Restore Default Dl Parameters    ue_id=102

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_A3_meas_enable_with_zuc.json
    Attach Ue To Enb And Start Gnb Addition    ue_id=103
    Send Ue Measurement Nr    ue_id=103     meas_id=1     index=0    nrs_result=40:0:0    event=A3     phycell_id=10
    ...                       nrsrp_nr=40     srsrp_nr=30
    Verify Tcpdump Log    packet_filter=${CHECK_ZUC_ALGORITHMS}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER}    number_of_messages=3

    Detach Ue And Restore Default Ul Parameters    ue_id=103

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_snow3g_and_actcdrx_true.json
    Attach Ue To Enb And Start Gnb Addition    ue_id=104
    Verify Tcpdump Log    packet_filter=${CHECK_SNOW3G_ALGORITHMS}
    Verify Tcpdump Log    packet_filter=${F1AP_DL_RRC_MESSAGE_TRANSFER}    number_of_messages=2

    Detach Ue And Restore Default Dl Parameters    ue_id=104

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_A3_meas_enable_with_snow3g.json
    Attach Ue To Enb And Start Gnb Addition    ue_id=105
    Send Ue Measurement Nr    ue_id=105    meas_id=1     index=0    nrs_result=40:0:0    event=A3     phycell_id=10
    ...                       nrsrp_nr=40     srsrp_nr=30
    Verify Tcpdump Log    packet_filter=${CHECK_SNOW3G_ALGORITHMS}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UL_RRC_MESSAGE_TRANSFER}    number_of_messages=5

    Detach Ue And Restore Default Ul Parameters    ue_id=105

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Detach Ue And Restore Default Dl Parameters
    [Arguments]    ${ue_id}
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actCDrx    value=false
    Detach Ue    ue_id=${ue_id}

Detach Ue And Restore Default Ul Parameters
     [Arguments]    ${ue_id}
     Find Scfc And Send Delta Commissioning    scfc_filename=delta_A3_meas_disable.json
     Detach Ue    ue_id=${ue_id}

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=1
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg
