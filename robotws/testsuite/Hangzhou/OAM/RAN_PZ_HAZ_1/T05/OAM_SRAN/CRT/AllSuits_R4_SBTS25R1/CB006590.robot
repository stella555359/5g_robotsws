*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup   skip_build_download=${TRUE}
Suite Teardown    suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../TRACE/CB006590-A_Get_active_UEs.robot
Resource    ../TRACE/CB006590-C_IP_Traffic_Capturing.robot
Resource    ../TRACE/CB006590-C_L1_IQ_Data_Capturing.robot
Resource    ../TRACE/CB006590-B_Get_active_UEs.robot
Resource    ../TRACE/CB006590-B_Reset_5G_Cell_Group.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/CommonKeywords.robot


*** Variables ***
${TEMP_LOGS_DIR}    /tmp/logs/
${bts_ip}=    192.168.255.129
${USERNAME}     Nemuadmin
${PASSWORD}=    nemuuser
${vdu_username}     Nemuadmin
${vdu_password}     N0kia@dmin56
${target_release}    SBTS00
${sw_update_needed}    ${FALSE}

#
#*** Test Cases ***
#Number of active UE per cell monitor with WebEM Remote tool
#    [Tags]    CB006590   QC_83631    10_5_UTESRAN22259
#    [Timeout]    60min
#    [Setup]    CB006590 Setup
#    ActiveUEs with WebEM Remote Tool
#    [Teardown]    CB006590 Teardown
