*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_VRF_OAM
Library           taf.sbts.oam.coam.admin
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../SWM/SWM__SW_update_for_RMOD_with_fault_23.robot
Resource          ../SWM/SWM__Local_Software_Activation.robot
Resource          ../SWM/CB007335/CB007335_02_05_Health_check_before_copy_BTS_SW_and_configuration.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB007425/LTE2866-R_01_08_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource          ../HWM/LTE4498/Dualcore_LTE4498.robot
#Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot
Resource          ../SWM/SWM__SW_post_check_successful.robot
Resource          ../SWM/SWM__Local_Software_Download.robot
Resource          ../SWM/SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF.robot
Resource          ../SWM/RP00913/RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW.robot
Resource          ../SWM/RP00913/RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.robot
Resource          ../SWM/CB006536/SWM/LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.robot
Resource         ../SWM/CB007425/LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.robot



*** Variables ***
${target_release}    SBTS00


*** Test Cases ***

SWM__SW_update_for_RMOD_with_fault_23
    [Tags]    QC_33320    original:3_5_UTE4G500      1st:3_5_UTE4G884      prio-1      test
    [Setup]    run keywords    Set Library Search Order    SWM__SW_update_for_RMOD_with_fault_23    hran_general
    ...    AND     SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Setup
    step1: Check SW versions
    [Teardown]    SWM__SW_update_for_RMOD_with_fault_23.TC_Custom Teardown

CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
    [Tags]    QC_33411     original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB006053_LTE4498
    ...    AND    TC setup
    Log    Check the the suite    level=INFO
    [Teardown]    TC Teardown

LTE4498_ST_04_Do_HW_inverntory_upload_from_Netact_independently_form_CM
    [Tags]    QC_33410     original:10_5_CLOUD602         1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    Dualcore_LTE4498
    ...    AND    TC setup
    Log    Check the the suite    level=INFO
    [Teardown]    TC teardown

SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    [Tags]    QC_33309    3_5_UTE4G204      1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords   Set Library Search Order    SWM_BTS_SOAM_Local_Software_Download_and_Activation_lock_unlock_BCF
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    Log    Try to Check the the suite    level=INFO
    [Teardown]    TC Teardown
SWM__SBTS_upgrade_fails_due_to_hash_verification_failure_for_downloaded_software_file
    [Tags]    QC_33339     original:3_5_UTE4G500     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order    RP00913_SBTS_upgrade_fails_due_to_Verification_failure_for_HCS
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    TC Setup
    Log    Try to Check the the suite    level=INFO
    [Teardown]    TC Teardown
SWM__SBTS_Signed_SW_SignedSWtoUnSignedSW
    [Tags]    QC_33338     original:3_5_UTE4G500      1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order    RP000913_SBTS_SOAM_signed_SW_update_to_unsigned_SW
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND   TC Setup
    Log    Try to Check the the suite    level=INFO
    [Teardown]    TC Teardown
LTE2866-R_01_09_ST BTS SW fallback in primary core with fault 4082
    [Tags]    QC_33302    original:3_5_UTESRAN602    1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords     Set Library Search Order
    ...    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    NR_Switch_Open
    ...    AND     LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Setup
    Log    Try to Check the the suite    level=INFO
    [Teardown]    LTE2866-R_01_09_ST_BTS_SW_fallback_in_primary_core_with_fault_4082.TC_Custom Teardown

CB007425_LTE2866-R_01_08_ST BTS SW fallback in secondary core with fault 4082
    [Tags]    QC_33348    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords    Set Library Search Order    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082
    ...  taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Setup
    Log    Try to Check the the suite    level=INFO
    [Teardown]    LTE2866-R_01_06_ST_BTS_SW_fallback_in_secondary_core_with_fault_4082.TC_Custom Teardown

CB007425_LTE2866-R_01_02_ST BTS SW update for secondary core which running different LTE SW
    [Tags]    QC_33349    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-2
    [Setup]    run keywords     Set Library Search Order        LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW
    ...    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND     NR_Switch_Open
    ...    AND    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Setup

    Log    Try to Check the the suite    level=INFO
    [Teardown]    LTE2866-R_01_02_ST_BTS_SW_update_for_secondary_core_which_running_different_LTE_SW.TC_Custom Teardown

LTE1685-A Autonomous removal of Neighbor eNBs and Neighbor Cells - basic scenario
    [Tags]    QC_33420    original:3_5_UTE4G884     1st:3_5_UTE4G884      prio-1
    [Setup]    run keywords    Set Library Search Order    SWM__Local_Software_Download    taf.sbts.oam.coam.admin     taf.nms.netact
    ...    AND   TC Setup
    Log    Try to Check the the suite    level=INFO
    [Teardown]    TC Teardown
