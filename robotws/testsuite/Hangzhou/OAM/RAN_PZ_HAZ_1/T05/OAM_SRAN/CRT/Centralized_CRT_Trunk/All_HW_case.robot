*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Library           xml
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource          ../SWM/CB007821/CB007821_CB006147_SFP_QSFP_control.robot
Resource          ../SWM/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource          ../SWM/CB007335/CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation.robot
Resource          ../HWM/LTE4498/Dualcore_LTE4498.robot
Resource         ../SWM/CB007500/CB007500.robot
Resource        ../SWM/CB007500/CB007500ET.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
Automated__SWM__SW_update_for_RMOD_with_fault_23
    [Tags]    QC_599099   original:3_5_UTESRAN704     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    ...    AND    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
    TC__Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Teardown]    Repeated_SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown

CB006147_05_01_Lock_Unlock of [Q]SFP
    [Tags]    QC_33438    original:10_5_UTESRAN286     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    TC Setup
    CB007821_CB006147_SFP_QSFP_control.TC CB006147 05 01 Lock Unlock Of SFP
    [Teardown]    TC Teardown

SWM__SW_update_for_RMOD_with_fault_23
    [Tags]    QC_71298    original:3_5_UTE4G500      1st:3_5_UTE4G884      prio-1      test
    [Setup]    run keywords    Set Library Search Order    SWM__SW_update_for_RMOD_with_fault_23    hran_general
    ...    AND     SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Setup
    TC__SWM__SW_update_for_RMOD_with_fault_23
    [Teardown]    SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Teardown

CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Tags]    QC_581840    original:3_5_UTE4G502     1st:3_5_UTE4G243       prio-1
    [Setup]    run keywords    set library search order    CB007500    taf.sbts.oam.coam.admin
    ...   taf.nms.netact
    ...    AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Teardown]  CB007500 TC teardown

CB008325_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset_inCMplan_ASIL_DualCore
    [Tags]    QC_460147   original:3_5_UTESRAN704       1st:3_5_UTESRAN704      prio-1
    [Setup]    run keywords    Set Library Search Order
    ...    CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset
    [Teardown]    TC Teardown

LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Tags]    QC_528887      original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Dualcore_LTE4498
    ...    AND    TC setup
    Dualcore_ASMI_LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Teardown]    TC teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_33437    original:10_5_UTESRAN286     1st:3_5_UTE4G225      prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND   TC Setup
    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
    [Teardown]    TC Teardown
