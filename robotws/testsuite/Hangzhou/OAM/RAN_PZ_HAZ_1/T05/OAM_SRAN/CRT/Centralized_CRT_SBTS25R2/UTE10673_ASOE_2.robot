*** Settings ***
Documentation     [PURPOSE]
Force Tags        QCD_MN_RAN    QCP_RAN_ST
Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/CommonKeywords.robot
Resource    ../TRACE/LBT2864.robot
Resource    ../TRACE/LTE1914.robot
Resource    ../TRACE/LTE644_01.robot
Resource    ../TRACE/LTE1308.robot
Resource    ../TRACE/LTE1049-B_02.robot
Resource    ../TRACE/LTE4488.robot
Resource    ../TRACE/LTE2812_TC02.robot
Resource    ../TRACE/LTE2812_TC04.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../TRACE/CB006590-A_Get_active_UEs.robot
Resource    ../TRACE/CB006590-C_IP_Traffic_Capturing.robot
Resource    ../TRACE/CB006590-C_L1_IQ_Data_Capturing.robot
Resource    ../TRACE/CB006590-B_Get_active_UEs.robot
Resource    ../TRACE/CB006590-B_Reset_5G_Cell_Group.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/CommonKeywords.robot
Resource    ../SWM/CB010738/CB010738.robot


*** Variables ***
${TEMP_LOGS_DIR}    /tmp/logs/
${UE1}			SONY_XZ2
${UE2}			Nokia_8.3_5G
${LTE955_PASSED}    ${FALSE}
${bts_ip}=    10.97.97.135
${USERNAME}     Nemuadmin
${PASSWORD}=    nemuuser
${vdu_username}     Nemuadmin
${vdu_password}     N0kia@dmin56
${target_release}    SBTS25R2


*** Test Cases ***
[1][1.0] L1 IQ data capture commands with WebEM Remote Tool
    [Tags]    CB006590   QC_33365  CDRT  original:3_5_UTE4G231    1st:10_5_UTESRAN10673    Prio-2
    [Timeout]    10min
    [Setup]    CB006590 Setup
    L1 IQ data capture commands with WebEM Remote Tool
    [Teardown]    CB006590 Teardown

[1][1.0] IP data capture commands with WebEM Remote Tool
    [Tags]    CB006590   QC_33366  CDRT  original:3_5_UTE4G231    1st:10_5_UTESRAN10673    Prio-2
    [Timeout]    10min
    [Setup]    CB006590 Setup
    IP Traffic Capturing commands with WebEM Remote Tool
    [Teardown]    CB006590 Teardown

[1][1.0] Number of active UE per cell monitor with WebEM Remote tool
    [Tags]    CB006590   QC_33367  CDRT    original:3_5_UTE4G231    1st:10_5_UTESRAN10673    Prio-2
    [Timeout]    20min
    [Setup]    CB006590 Setup
    ActiveUEs with WebEM Remote Tool
    [Teardown]    CB006590 Teardown
