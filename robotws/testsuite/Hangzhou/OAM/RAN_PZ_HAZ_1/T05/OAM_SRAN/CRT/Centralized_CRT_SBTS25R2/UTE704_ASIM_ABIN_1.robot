*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup   #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/RP002315/RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS.robot
Resource          ../SWM/CB007335/CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation.robot


*** Variables ***
${target_release}    SBTS25R2


*** Test Cases ***
CB009826_RP002315_05_01_Software Precheck from NetAct for single SBTS
    [Tags]    QC_33457   original:3_5_UTESRAN704       1st:3_5_UTESRAN704      prio-1
    [Setup]    run keywords    Set Library Search Order  RP002315_05_01_Software_Precheck_postcheck_from_NetAct_for_single_SBTS
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    RP002315_05_01_Software Precheck from NetAct for single SBTS
    [Teardown]    TC Teardown

CB009826_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset_inCMplan_ASIL_DualCore
    [Tags]    QC_33461   original:3_5_UTESRAN704       1st:3_5_UTESRAN704      prio-1
    [Setup]    run keywords    Set Library Search Order
    ...    CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    TC_CB007335_05_02_Trigger_Copy_BTS_SW_and_configuration_operation_need_site_reset
    [Teardown]    TC Teardown
