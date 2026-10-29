*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R1    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1  10_5_UTESRAN610
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library     taf.sbts.oam.coam.admin
Library     xml
Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB007500/RP001540_R3.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS25R1_FSM3
${Target SW dir}       /home/ute/btsauto/TARGET_SW  #

#
#*** Test Cases ***
#RP001540_A_ST_05_03_Trigger AutoConnection with SiteID information with DHCP
#    [Tags]    QC_35805    10_5_UTESRAN610
#    [Setup]    TC setup
#    [Timeout]   3600
#    RP001540_A_05_03_Trigger AutoConnection with SiteID information with DHCP
#    #RP001540_A_05_01_Trigger Autoconnection by HW ID with DHCP after Power-up at SBTS20A
#    [Teardown]    TC teardown
#
#[1]CB007215_ST_PnP_05_05 Duration of Configuration Reset
#    [Tags]    QC_33430    10_5_UTESRAN610
#    [Setup]    TC setup
#    [Timeout]    300
#    ${ConfigReset_KPI_check}=    Operation_KPI_Check    ${ConfigResetEndTime}    ${ConfigResetStartTime}
#    ...    ${ConfigReset_expect_time}    ConfigReset_BTS_KPI
#    [Teardown]    TC teardown
