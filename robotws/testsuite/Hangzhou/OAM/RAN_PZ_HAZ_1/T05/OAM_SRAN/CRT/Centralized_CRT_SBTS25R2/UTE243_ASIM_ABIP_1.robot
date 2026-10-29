*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Library           xml
Library            ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/CB007821/CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.robot
Resource          ../SWM/CB007821/CB007821_CB006147_SFP_QSFP_control.robot
Resource         ../SWM/CB007500/CB007500.robot
Resource        ../SWM/CB007500/CB007500ET.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
[CB007821] CB007821_LTE4934-C_ST_05_17_Software_Management_SWM_Trigger_NE_Initiated_SoftwareUpdate
    [Tags]    QC_392059        original:3_5_UTE4G243     1st:3_5_UTE4G243       prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
    ...    AND    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.TC_Custom Setup

    LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update
    [Teardown]    CB007821_LTE4934-C_ST_05_17_Flat_SOAM_Software_Management_SWM_Trigger_NE_Initiated_Software_Update.TC_Custom Teardown

CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Tags]    QC_581840    original:3_5_UTE4G502     1st:3_5_UTE4G243       prio-1
    [Setup]    run keywords    set library search order    CB007500    taf.sbts.oam.coam.admin      AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Teardown]  CB007500 TC teardown

CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
    [Tags]    QC_547587      original:3_5_UTE4G502    1st:3_5_UTE4G243       prio-1
    [Setup]    run keywords    set library search order    CB007500    taf.sbts.oam.coam.admin     AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
    [Teardown]  CB007500 TC teardown
