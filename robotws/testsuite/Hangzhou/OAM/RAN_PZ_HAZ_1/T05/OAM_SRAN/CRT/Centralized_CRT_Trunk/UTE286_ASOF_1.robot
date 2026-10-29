*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../SWM/RRM_SWM_ASMI/SWM_eNB_reboot_during_SWDL.robot
Resource          ../SWM/CB007402/CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem.robot
Resource          ../SWM/CB007402/CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact.robot
Resource          ../SWM/CB007425/SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource       ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB009469/CB009469_LTE655.robot
Resource       ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot
Resource          ../SWM/CB008313/CB008313_LTE655_05_09_Automatic_SW_Fallback.robot
Resource          ../SWM/CB007335/CB007335_02_02_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_Netact.robot


*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
CB009469_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
# just kpi result fetch, to update QC
    [Tags]    QC_33433   10_5_UTESRAN286    SWM   Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown

SWM_eNB_reboot_during_SWDL
    [Tags]    QC_33441    10_5_UTESRAN286  Prio-3
    [Setup]    run keywords    TC Setup
    ...    AND    Set Library Search Order    SWM_eNB_reboot_during_SWDL
    SWM_eNB_reboot_during_SWDL
    [Teardown]    TC Teardown

CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
    [Tags]    QC_33431    7402    10_5_UTESRAN286  Prio-3
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
    ...  AND    TC Setup
    TC_CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
    [Teardown]    TC Teardown

CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    [Tags]    QC_33432    7402    10_5_UTESRAN286  Prio-3
    [Setup]    run keywords
    ...  Set Library Search Order
    ...  CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    ...  AND    TC Setup
    TC_CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
    [Teardown]    TC Teardown

CB009469_LTE4934-C_ST_05_17_ Flat SOAM_Software Management_SWM_Trigger NE Initiated Software Update
    [Tags]    QC_33436   10_5_UTESRAN286    SWM  Prio-1
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
    ...    AND    Set Library Search Order    SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    TC__CB007425_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
    [Teardown]    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown

CB007335_02_02_Copy_BTS_SW_and_configuration_from_active_to_passive_Netact
    [Tags]    QC_33337   7335    11
    [Setup]    run keywords    Set Library Search Order
    ...   CB007335_02_02_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_Netact
    ...    AND    TC Setup
    TC_CB007335_02_02_Copy_BTS_SW_and_configuration_from_active_to_passive_Netact
    [Teardown]    TC Teardown

CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_WithoutHealthCheck
    [Tags]    QC_33442   10_5_UTESRAN286    SWM  Prio-1
    [Setup]    run keywords    Set Library Search Order
    ...    CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck
    ...    AND    TC Setup
    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
    [Teardown]    TC Teardown

CB008313_LTE655_05_09_Automatic_SW_Fallback
    [Tags]    QC_33435   10_5_UTESRAN286    SWM  Prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB008313_LTE655_05_09_Automatic_SW_Fallback
    ...    AND    TC Setup
    CB008313_LTE655_05_09_Automatic_SW_Fallback
    [Teardown]    TC Teardown

CB009469_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback Software for multi-MRBTS
#The function case include three kpi check,1th is upload,2th is provision, 3th is rollback, the final step is rollback
#so choose rollback as the case name
    [Tags]    QC_33434   10_5_UTESRAN286    SWM  Prio-2
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
    ...    AND    Set Library Search Order
    ...    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
