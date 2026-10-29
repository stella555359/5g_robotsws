*** Settings ***
Documentation
...   author: Tomasz Mozola
...   contact: tomasz.mozola@nokia.com

Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008697/resources/keywords.robot
Resource           ../resources/attach_verification.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008697/resources/keywords.py
Library            ute_ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/color_log.py

*** Variables ***
${3CC_EXP_TPUT_FDD}      320
${1CC_EXP_TPUT_FDD}      44
${3CC_EXP_TPUT_TDD}    250
${2CC_EXP_TPUT_TDD}    222

*** Keywords ***
[1]US_CB008697-A#B7_Scell_deactivation_and_activation_based_UE_OAI_status
    [Documentation]   Checking deactivation and activation scells scheduling based on UE Overheating Information,
     ...              checking if traffic is scheduled or not depends OAI status
#step1 n5(250)+n2(252)+n66(252)
    Require Ue                       MediaTekUe   capabilities=REAL_MEDIATEK_UE
    write line               \n STEP_1 prepare for 3CC F+F+F n5(250)+n2(251)+n66(252)
    Prepare TL for Overheating Assistance
    Start tracing on SMOD
    Attach Ue                        MediaTekUe    15
    ${log_path}    Stop tracing and download logs from SMOD
    Verify CA status
    write line               \n A1 meas done 3CC Succesfully perform ... check traffic for step_1
    ${avg_tput_step_1}    Start CA full Buffer DL Traffic
    Compare with expected traffic     ${avg_tput_step_1}    ${3CC_EXP_TPUT_FDD}
#step2
    write line               \n STEP_2 overheating simulation cc_dl=0, deactivate traffic for both scells n2(251)+n66(252)
    Start tracing on SMOD                                                 filename=STEP2_OAI_deactivated_both_scells_n2_n66
    trigger Overheating Assistance command from UE
    BuiltIn.Sleep    3s              reason=wait for prohibit timer
    ${STEP_2_F1AP_logs}    Stop tracing and download logs from SMOD      filename=STEP2_OAI_deactivated_both_scells_n2_n66
    Verify Overheating Assistance in F1AP messages when ON    ${STEP_2_F1AP_logs}
    write line          \n STEP_2 Traffic with expected all scells deactivated, Pcell n5(250) traffic only
    ${avg_tput_step_2}    Start CA full Buffer DL Traffic    DL_1CC
    Compare with expected traffic     ${avg_tput_step_2}    ${1CC_EXP_TPUT_FDD}
#step3
    write line          \n STEP_3 Restore scells n2(251)+n66(252), cc_dl=2, Traffic should back for 3CC traffic
    Start tracing on SMOD                                                 filename=STEP_3_OAI_restore_3CC_traffic
    trigger Overheating Assistance command from UE     DL=${2}
    BuiltIn.Sleep    3s              reason=wait for prohibit timer
    ${STEP_3_F1AP_logs}    Stop tracing and download logs from SMOD      filename=STEP_3_OAI_restore_3CC_traffic
    Verify Overheating Assistance in F1AP messages when ON    ${STEP_3_F1AP_logs}    expected_CCsDL=2
    write line          \n STEP_3 Traffic 3CC expected after OAI scells restore
    ${avg_tput_step_3}    Start CA full Buffer DL Traffic    DL_3CC_back
    Compare with expected traffic     ${avg_tput_step_3}    ${3CC_EXP_TPUT_FDD}
#step4
    write line          \n STEP_4 Perform command overheating assistance no longer occurs on_off=0
    Start tracing on SMOD                                                 filename=STEP_4_OAI_turned_off
    BuiltIn.Sleep    3s              reason=wait for logcollector start
    trigger Overheating Assistance command from UE     on_off=${0}
    BuiltIn.Sleep    3s              reason=wait for prohibit timer
    ${STEP_4_F1AP_logs}    Stop tracing and download logs from SMOD    filename=STEP_4_OAI_turned_off
    Verify Overheating Assistance in F1AP messages when OFF    ${STEP_4_F1AP_logs}
    write line          \n STEP_4 Traffic with all scells 3CC still expected
    ${avg_tput_step_4}    Start CA full Buffer DL Traffic    DL_3CC_off
    Compare with expected traffic     ${avg_tput_step_4}    ${3CC_EXP_TPUT_FDD}
#preconditions for step 5
    Detach Ue                   ue_alias=MediaTekUe
    write line          \n UE detached, and precondition for STEP_5 change relations for cells
    Add_paraeter_Scell_Addition_method_per_cell    250    255
    Del_paraeter_Scell_Addition_method_per_cell    250    252
    BuiltIn.Sleep    10s              reason=wait proper activation
#    Require Ue                       MediaTekUe   capabilities=REAL_MEDIATEK_UE
    Attach Ue                        MediaTekUe    15
#step5 n5(250)+n2(252)+n77(255)
    write line          \n STEP_5 prepare for 3CC F+F+T n5(250)+n2(251)+n77(255), next OAI cc_dl=1 FDD scell should be blocked by OAI
    Start tracing on SMOD                                                 filename=STEP_5_FDD_scell_blocked_by_OAI_2CC_with_TDD_scell_traffic_only
    trigger Overheating Assistance command from UE     on_off=${1}   DL=${1}
    BuiltIn.Sleep    3s              reason=wait for prohibit timer
    ${STEP_5_F1AP_logs}    Stop tracing and download logs from SMOD      filename=STEP_5_FDD_scell_blocked_by_OAI_2CC_with_TDD_scell_traffic_only
    Verify Overheating Assistance in F1AP messages when ON    ${STEP_5_F1AP_logs}    expected_CCsDL=1
    write line          \n STEP_5 Traffic 2CC with TDD scell
    ${avg_tput_step_5}    Start CA full Buffer DL Traffic    DL_2CC_with_TDD
    Compare with expected traffic     ${avg_tput_step_5}    ${2CC_EXP_TPUT_TDD}
#step6
    Start tracing on SMOD                                                 filename=STEP6_OAI_drop_scells
    write line               \n STEP_6 trigger OAI command cc_dl=0 sells n2(FDD) and n77(TDD) deactivated
    trigger Overheating Assistance command from UE    DL=${0}
    BuiltIn.Sleep    3s              reason=wait for prohibit timer
    ${STEP_6_F1AP_logs}    Stop tracing and download logs from SMOD      filename=STEP6_OAI_drop_scells
    Verify Overheating Assistance in F1AP messages when ON    ${STEP_6_F1AP_logs}    expected_CCsDL=0
    write line          \n STEP_6 Traffic with expected all scells deactivated 1CC FDD only
    ${avg_tput_step_6}    Start CA full Buffer DL Traffic    DL_1CC_wo_TDD
    Compare with expected traffic     ${avg_tput_step_6}    ${1CC_EXP_TPUT_FDD}
    Add_paraeter_Scell_Addition_method_per_cell    250    252
    Del_paraeter_Scell_Addition_method_per_cell    250    255
    [Teardown]  Run Keywords
    ...         Overheating                 alias=MediaTekUe     cc_dl=2     AND
    ...         Overheating                 alias=MediaTekUe     oh_op=0     AND
    ...         Detach Ue                   ue_alias=MediaTekUe
