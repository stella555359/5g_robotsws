*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        bibo.lei@nokia-sbell.com
...    Maintainer:    blei

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_model.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/variables.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${5AHEGC_3AHEGB_18cell_20M_40M}=    {"530":[190,30],"531":[380,30],"532":[190,30],"533":[380,30],"534":[190,30],
...    "535":[380,30],"536":[190,30],"537":[190,30],"538":[190,30],"539":[190,30],"540":[380,30],"541":[190,30],
...    "542":[380,30],"543":[190,30],"544":[380,30],"545":[190,30],"546":[190,30],"547":[190,30]}
&{CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_18cell_20M_40M}    HW_ID=AHEGC   site_mode=5G    ONAIR_TIME=15 min
...	  peak_rate_config=${5AHEGC_3AHEGB_18cell_20M_40M}
${5AHEGC_3AHEGB_24cell_20M}=    {"530":[190,30],"531":[380,30],"532":[190,30],"533":[380,30],"534":[190,30],
...    "535":[380,30],"536":[190,30],"537":[190,30],"538":[190,30],"539":[190,30],"540":[380,30],"541":[190,30],
...    "542":[380,30],"543":[190,30],"544":[380,30],"545":[190,30],"546":[190,30],"547":[190,30],"548":[190,30],
...    "549":[190,30],"550":[190,30],"551":[190,30],"552":[190,30],"553":[190,30]}
&{CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_24cell_20M}    HW_ID=AHEGC   site_mode=5G    ONAIR_TIME=15 min
...	  peak_rate_config=${5AHEGC_3AHEGB_24cell_20M}
${5AHEGC_3AHEGB_test_model}=    {"530":[190,30],"532":[190,30],"534":[190,30],
...    "536":[190,30],"539":[190,30],"541":[190,30],
...    "543":[190,30],"545":[190,30]}
&{CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_test_model}    HW_ID=AHEGC   site_mode=5G    ONAIR_TIME=15 min
...	  peak_rate_config=${5AHEGC_3AHEGB_test_model}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${ru_password_user}=    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
${GLO_PERFORM_SAVE_LOG}    FAIL
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset

*** Test Cases ***
[1][1.0] Common_SiSo_Call_1UE ULDL L3 call(Robustness)
    [Tags]    QC_146152   QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Precondition With GPS Check    case_name=L3_call
    ...    config_id=CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_18cell_20M_40M
    Modify vendor parameters of CB012528    bts_id=37072
    Make L3Call All    required_cells=530:535:536:540:542:543
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell Block&unblock_Then_RF Lock&Unlock
    [Tags]    QC_146150    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_unblock_Then_RF Lock_Unlock
    ...    config_id=CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_24cell_20M
    Cell Block And Unblock All    required_cells=536
    Append To List    ${GLO_ADMIN_ALLOWED_ALARM}    Cell blocked
    Ru lock And Unlock All    required_cells=536
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_146149  QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Ru_lock_and_RU_reset_with_resetBBMOD
    [Timeout]    72h
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock    required_cells=536
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_RF Lock & Unlock_Then_Cell Block & unblock
    [Tags]    QC_146154    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RF_Lock_Unlock_Then_Cell_Block_unblock
    Ru lock And Unlock All    required_cells=541
    Cell Block And Unblock All    required_cells=536
    [Teardown]    Testcase Basic Postcondition

#[1.0] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
 #   [Tags]    QC_33099    QCD_MN_RAN    QCP_RAN_VRF
  #  [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm
   # RAT reset from WebEm For NR testline     required_cells=546
    #[Teardown]    Testcase Basic Postcondition

[1][3.0] Common_SiSo_Testability_Downlink Test Model
    [Tags]    QC_146151    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=test_model
    ...      config_id=CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_test_model
    [Timeout]    72h
    Test_Dedicated_downlink
    [Teardown]    Testcase Basic Postcondition

*** Keywords ***
Wait For GPS Self Check
    ${status}    Run Keyword And Return Status    Check Alarm Is Appear    37072    faultId=4405
    Return From Keyword If    not ${status}
    ${status}    Wait For Complete
    Should Be True    ${status}

Wait For Complete
    FOR    ${i}    IN RANGE    ${20}
        ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37072
        ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
        Return From Keyword If    "${selfSurveyStatus}"=="Completed"    ${True}
        sleep    10 min
    END
    ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37072
    ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
    ${gnsse_distname}    Set Variable    ${gps_info["gnsse"][0]["id"]["internal"]}
    Run Keyword If    "${selfSurveyStatus}"=="In progress 99%"    coam.reset unit    ${gnsse_distname}    connection=${CASE_NAME}_37072
    sleep    5 min
    FOR    ${i}    IN RANGE    ${20}
        ${gps_info}    coam.get_gps_status    connection=${CASE_NAME}_37072
        ${selfSurveyStatus}    Set Variable    ${gps_info["gnsse"][0]["parameters"]["selfSurveyStatus"]}
        Return From Keyword If    "${selfSurveyStatus}"=="Completed"    ${True}
        sleep    10 min
    END
    Return From Keyword    ${False}

Testcase Precondition With GPS Check
    [Arguments]    ${case_name}    ${config_id}=${EMPTY}    ${force_recommission}=${False}
    Close Multi Node Process
    Set Test Variable    ${CASE_NAME}    ${case_name}
    Set TC Dir Path
    Create Nodes Parameters Init    ${config_id}    force=False
    Update Qc Id Tag
    Run Keyword If    "${${CURRENT_CONFIG_ID}.site_mode}"!="4G"    Run Keyword And Ignore Error
    ...    Get Resource Usage Setup    aashell_name=aashell
    Logging Multinode Start    ${TEST_LOGS_DIR_PATH}/setup
    ${out_SAS_SIM_config}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SAS_SIM}
    ${out_need_SAS_SIM}    Set Variable If     ${out_SAS_SIM_config}      ${tl_config.SAS_SIM}    False
    Run Keyword If     "${out_need_SAS_SIM}"=="True"    Run Keywords    Restart SAS Simulator
    ...    AND    Sleep    2 min
    Log Dictionary    ${NODE_CFG}
    Change Testline Configuration    ${config_id}    force_recommission=${force_recommission}
    ${status}    Run Keyword If    "${NOT_COMMISSIONED}"=="True"    Run Keyword And Return Status    Verify All Cells OnAir
    ${status}    Run Keyword And Return Status    Run Keyword If    "${NOT_COMMISSIONED}"=="True" and "${status}" == "False"
    ...    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    ...    ELSE IF    "${NOT_COMMISSIONED}"=="False"    Run Keywords    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    ...    AND    Check Default Value Of Parameter
    Run Keyword If    not ${status}    Run Keywords    Wait For GPS Self Check
    ...    AND    Check All Cells OnAir
    Check Multinode Without Unexpect Alarm
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="PASS"    Run Keywords
    ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    ...    AND    Logging Multinode Start
    ...    AND    Logging Gnb Admin Start
    ...    AND    Get And Check Reset Counter For All BTS Node
