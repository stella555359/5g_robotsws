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

*** Test Cases ***
5GC000544_B_5_Dl_Rrc_Message_Transfer_Over_Srb3_Success_With_Aes
    [Tags]    CIT    SBTS23R1    SBTS22R4
    [Documentation]     This is to verify if DL RRC message is successfully transferred with AES security

    Find Scfc And Send Delta Commissioning    scfc_filename=delta_aes_and_actcdrx_true.json
    Attach Ue To Enb And Start Gnb Addition    ue_id=101
    Verify Tcpdump Log    packet_filter=${CHECK_AES_ALGORITHMS}
    Verify Tcpdump Log    packet_filter=${F1AP_DL_RRC_MESSAGE_TRANSFER}

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Detach Ue    ue_id=101
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=1
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg
