*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1
Library           taf.sbts.oam.coam.admin
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/RRM_SWM_ASMI/SWM_eNB_reboot_during_SWDL.robot
Resource          ../SWM/CB007402/CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem.robot
Resource          ../SWM/CB007402/CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact.robot
Resource          ../SWM/CB007425/SWM__SW_update_for_Second_Core_RMOD_with_fault_23.robot
Resource          ../SWM/CB006053/CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.robot
Resource          ../SWM/CB009469/CB009469_LTE655.robot
Resource          ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot
Resource          ../SWM/CB008313/CB008313_LTE655_05_09_Automatic_SW_Fallback.robot
Resource          ../HWM/LBT5358/TD_OM_LBT5358_SFP_Monitoring.robot
Resource          ../SWM/CB006536/HWM/CB006147_SFP_QSFP_control.robot
Resource          ../HWM/LTE4498/CB006053_LTE4498.robot


*** Variables ***
${target_release}    SBTS25R3


#*** Test Cases ***
#SWM_eNB_reboot_during_SWDL
#    [Tags]    QC_687931    10_5_UTESRAN286
#    [Setup]    run keywords    TC Setup
#    ...    AND    Set Library Search Order    SWM_eNB_reboot_during_SWDL
#    SWM_eNB_reboot_during_SWDL
#    [Teardown]    TC Teardown
#
#CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
#    [Tags]    QC_33431    7402    10_5_UTESRAN286
#    [Setup]    run keywords
#    ...  Set Library Search Order
#    ...  CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
#    ...  AND    TC Setup
#    TC_CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
#    [Teardown]    TC Teardown
#
#CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
#    [Tags]    QC_33432    7402    10_5_UTESRAN286
#    [Setup]    run keywords
#    ...  Set Library Search Order
#    ...  CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
#    ...  AND    TC Setup
#    TC_CB007402_ST_05_01_execute_upgradeCfgDataValidCheck_successful_from_Netact
#    [Teardown]    TC Teardown
#
#CB009469_LTE4934-C_ST_05_17_ Flat SOAM_Software Management_SWM_Trigger NE Initiated Software Update
#    [Tags]    QC_83693  10_5_UTESRAN286    SWM   amli
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Setup
#    ...    AND    Set Library Search Order    SWM__SW_update_for_Second_Core_RMOD_with_fault_23
#    TC__CB007425_SWM__SW_update_for_Second_Core_RMOD_with_fault_23
#    [Teardown]    SWM__SW_update_for_Second_Core_RMOD_with_fault_23.TC_Custom Teardown
#
#CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_WithoutHealthCheck
#    [Tags]    QC_33442   10_5_UTESRAN286    SWM
#    [Setup]    run keywords    Set Library Search Order
#    ...    CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck
#    ...    AND    TC Setup
#    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
#    [Teardown]    TC Teardown
#
#CB008313_LTE655_05_09_Automatic_SW_Fallback
#    [Tags]    QC_33435   10_5_UTESRAN286    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB008313_LTE655_05_09_Automatic_SW_Fallback
#    ...    AND    TC Setup
#    CB008313_LTE655_05_09_Automatic_SW_Fallback
#    [Teardown]    TC Teardown
#
#CB009469_LTE4934-C_ST_05_16_ Flat SOAM_Software Management_SWM_rollback Software for multi-MRBTS
##The function case include three kpi check,1th is upload,2th is provision, 3th is rollback, the final step is rollback
##so choose rollback as the case name
#    [Tags]    QC_848093   10_5_UTESRAN286    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
#
#CB009469_LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software
## just kpi result fetch, to update QC
##    [Tags]    QC_83694   10_5_UTESRAN286
##    Run keyword if    '${SW_UPLOAD_KPI_Check}'=='True'    Log    SW_CONFIGURATION_UPLOAD_OPERATION_KPI is as expected.
##    ...  ELSE   FAIL   SW_CONFIGURATION_UPLOAD_OPERATION_KPI is not expected, you can find result in the previous case.
##    [Teardown]    TC Teardown
#    [Tags]    QC_83694   10_5_UTESRAN286    amli
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Setup
#    ...    AND    Set Library Search Order    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software
#    LTE4934-C_ST_05_15_ Flat SOAM_Software Management_SWM_Provision Software  CB006053
#    [Teardown]    CB006053_LTE4934-C_ST_05_15_Flat_SOAM_Software_Management_SWM_Provision_Software.TC_Custom Teardown
#
#CB009469_LBT5358_01_SFP monitoring in BTS SM(ADMIN)&Netact-Static Dynamic SFP Parameters
#    [Tags]    QC_33439    10_5_UTESRAN286    HWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    TD_OM_LBT5358_SFP_Monitoring
#    ...    AND    TC setup
#    LBT5358-1_CB007425
#    [Teardown]    TC teardown
#
#TC_CB006147_05_01_Lock_Unlock of [Q]SFP
#    [Tags]    QC_33438    SFP    10_5_CLOUD602
#    [Setup]    run keywords    Set Library Search Order    CB006147_SFP_QSFP_control   taf.sbts.oam.coam.admin
#    ...    AND    TC Setup
#    TC_CB006147_05_01_Lock_Unlock_of_SFP
#    [Teardown]    TC Teardown
#
#CB007425_LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add, change and remove
#    [Tags]    QC_33437    3_5_UTESRAN201    HWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB006053_LTE4498
#    ...    AND    TC setup
#    LTE4498_ST_01_Check HW inverntory information automatic updated after new HW_ABIAorRRU add,change and remove_R4
#    [Teardown]    TC Teardown
