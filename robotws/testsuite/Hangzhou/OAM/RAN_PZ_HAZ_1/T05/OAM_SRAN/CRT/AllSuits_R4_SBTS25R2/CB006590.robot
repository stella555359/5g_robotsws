*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup   skip_build_download=${TRUE}
Suite Teardown    suite teardown
Force Tags        QCD_MN_RAN    QCP_RAN_VRF
#Library    taf.sbts.oam.coam.admin
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
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
${target_release}    SBTS25R2
${sw_update_needed}    ${FALSE}


*** Test Cases ***
L1 IQ data capture commands with WebEM Remote Tool
    [Tags]    CB006590   QC_146429  CDRT    10_5_UTESRAN22259
    [Timeout]    60min
    [Setup]    CB006590 Setup
    L1 IQ data capture commands with WebEM Remote Tool
    [Teardown]    CB006590 Teardown

IP data capture commands with WebEM Remote Tool
    [Tags]    CB006590   QC_146430  CDRT    10_5_UTESRAN22259
    [Timeout]    60min
    [Setup]    CB006590 Setup
    IP Traffic Capturing commands with WebEM Remote Tool
    [Teardown]    CB006590 Teardown

Number of active UE per cell monitor with WebEM Remote tool
    [Tags]    CB006590   QC_146428  CDRT    10_5_UTESRAN22259
    [Timeout]    60min
    [Setup]    CB006590 Setup
    ActiveUEs with WebEM Remote Tool
    [Teardown]    CB006590 Teardown
