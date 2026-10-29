*** Settings ***
Resource     ../../resources/common_keywords.robot
Resource    ../../resources/common_variables.robot
Resource     ../../resources/common_configuration.robot
Library     ../../resources/common_keywords.py
Library      5GC000782_A.py
Library      ta5g_tshark
Variables    ta5g_global_var
Documentation
...    author: Marek Niescioruk
...    maintainer: Marek Niescioruk (marek.niescioruk@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN
...    release: 22R3

Suite Setup    Enable srb3Support

Test Setup      Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}

Test Teardown    Send Configuration ID To Scout

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SgNBAdditionRequestReject}=    x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 2 and x2ap.Cause == 0 and x2ap.radioNetwork == 15

*** Test Cases ***
5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_A/tc1_nea0_0_nea1_1_nea2_0_nea3_2.json
    Attach Ue And Perform SgNBAdditionRequest    ue_id=24
    Verify Tshark For Single Message    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}    packet_filter=${SgNBAdditionRequestReject}
    Detach Ue    ue_id=24

*** Keywords ***
Attach Ue And Perform SgNBAdditionRequest
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg

Enable srb3Support
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_srb3Support.json
