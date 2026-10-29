*** Settings ***
Documentation     [PURPOSE]
Suite Setup       Suite Setup For Trace
Suite Teardown    Suite Teardown For Trace
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1

Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/CommonKeywords.robot

Resource    ../TRACE/LBT2864.robot
Resource    ../TRACE/LTE1914.robot
Resource    ../TRACE/LTE644_01.robot
Resource    ../TRACE/LTE1308.robot
Resource    ../TRACE/LTE1049-B_02.robot
Resource    ../TRACE/LTE4488.robot
Resource    ../TRACE/LTE2812_TC02.robot
Resource    ../TRACE/LTE2812_TC04.robot


*** Variables ***
${TEMP_LOGS_DIR}    /tmp/logs/
${UE1}			SONY_XZ2
#${UE1}          Nokia_8
${UE2}			Nokia_8.3_5G
${LTE955_PASSED}    ${FALSE}


#*** Test Cases ***
#[1][1.0] LTE644_01_ST_Subscriber and Equipment Trace with_Handover
#    [Tags]	LTE644   QC_71160   3_5_UTE4G231
#    [Timeout]    45min
#    [Setup]    LTE644_01 Setup
#    LTE644_01_ST_Subscriber and Equipment Trace Session Start and stop_Handover
#    [Teardown]    LTE644_01 Teardown
#
#[1][1.0] Immediate MDT - Basic operation
#    [Tags]    LTE1308   QC_71129    3_5_UTE4G231
#    [Timeout]    45min
#    [Setup]    LTE1308 Setup
#    LTE1308 Immediate MDT Basic operation
#    [Teardown]    LTE1308 Teardown
