*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
...             The aim of the feature is to validate the counters introduced in 8204-C.

Resource        resources/Keywords/CB008204_C_Keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${NSA_UEID_11}          11
${LOG_DIR}              /home/ute/logs


*** Test Cases ***
[1][2.0] CB008204_C_4_4_PM_Counters_For_time_on_each_leg_NSA_UEs_With_UL_Data_Splitting_Bearer_Added_With_UL_On_LTE_HO_Case
    [Documentation]      TC04-4
    [Tags]    QC_28349   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008204_C_4_4
    Link SCOUT SCF to Configuration ID for Reporting
    Run         sudo rm -rf ${LOG_DIR}/${Test_CaseNumber}*
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${LOG_PATH}         Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    Set Test Variable       ${LOG_PATH}
    Log To Console      Starting the test......
    GNB Delta Commission     ${CURDIR}/config/scf/Delta_Configuration_APoABIO_IADU_IntergNB_IAFR_NSA.json
    GNB Reboot
    Sleep   360s
    Wait Coam Site To Be Ready
	Create Basic Interface On UTE
    Create Interface For Xn HO
    Start UTE WTS      basic_IADU_IntergNB_NSA.cfg
    Wait For Next Full Pm Interval
    X2AP Link Should Be UP
    Setup X2 With RANSIM GNB
    Make ENDC Call
    Sleep   30s
    Traffic Should Be Successful For NSA    ${NSA_UEID_11}  5   2
    Sleep        30s
    Log To Console      HO from Real to RANSIM
    Stop Traffic    ${NSA_UEID_11}      1
    UE 5GDetach Should Be Successful For NSA    11
    UE Detach Should Be Successful For NSA 8204      11
    Delete Interface Created By Xn HO
