*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R2  SRAN  CLOUD_SRAN_NL_1747_2ASIB_4ABIO_9AHEH_3AHPE_3AZQS_3AZQU


Resource    ../../KPI/test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../KPI/test_resources/KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.robot
Resource    ../../KPI/test_resources/KPI__Site_reset.robot
Resource    ../../KPI/test_resources/KPI__Site_power_reset.robot
Resource    ../../KPI/test_resources/KPI__BBMOD_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__BBMOD_Power_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__5G_RAT_Reset_From_WebEM.robot
Resource    ../../KPI/test_resources/KPI__LTE_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__WCDMA_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__GSM_RAT_reset_from_ADMIN.robot
Resource    ../../KPI/test_resources/KPI__Remote_power_reset.robot
Resource    ../../KPI/test_resources/KPI__BTS_autonomous_reset_after_plan_activation.robot
Resource    ../../KPI/test_resources/KPI__Configuration_plan_activation_with_cell_locking
Resource    ../../KPI/test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot
Resource    ../../KPI/test_resources/KPI__Cell_block_unblock.robot
Resource    ../../KPI/test_resources/KPI__Radio_module_reset_from_admin.robot
Resource    ../../KPI/test_resources/KPI__RMOD_power_reset.robot
Resource    ../../KPI/test_resources/KPI__Energy_Consumption_Measurements.robot
Resource    ../../KPI/test_resources/KPI__Compare_KPI.robot


*** Variables ***
${SCF_ID}                        01
${REQUEST_SCF_SCOUT}             ${TRUE}
${SCOUT_TL_NAME}                 #
${REF_FILE_PATH}                 #
${REFERENCE_CONFIGURATION_ID}    #


*** Test Cases ***
Download software for SWR test case
    Log  TC: Download software for SWR test case.

TC__SW_download_and_activation__SBTS_to_SBTS_TARGET
    Log  TC: KPI__SW_download_and_activation__SBTS_to_SBTS.

TC__SBTS_SOAM_rollback_to_SBTS_SOAM
    Log  TC: KPI__SBTS_SOAM_rollback_to_SBTS_SOAM.

TC__SW_download_and_activation__SBTS_to_SBTS_INTERMEDIATE
    Log  TC: KPI__SW_download_and_activation__SBTS_to_SBTS.

TC__Site_reset_WITH_SNAPSHOT
    Log  TC: KPI__Site_reset.

TC__Site_reset_WITHOUT_SNAPSHOT
    Log  TC: KPI__Site_reset.

TC__Site_power_reset
    Log  TC: KPI__Site_power_reset.

TC__BBMOD_Reset_From_WebEM_SN1
    Log  TC: KPI__BBMOD_Reset_From_WebEM.

TC__BBMOD_Reset_From_WebEM_SN2
    Log  TC: KPI__BBMOD_Reset_From_WebEM.

TC__LTE_RAT_reset_from_ADMIN
    Log  TC: KPI__LTE_RAT_reset_from_ADMIN.

TC__LTE_RAT_reset_from_ADMIN_Soft
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESET_TYPE}               Soft
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order

TC__LTE_RAT_reset_from_ADMIN_Hard
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${LTE_RAT_RESET_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RESET_TYPE}               Hard
    ...    AND    KPI__LTE_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Modify Resource Search Order    KPI__LTE_RAT_reset_from_ADMIN
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    KPI__LTE_RAT_reset_from_ADMIN.TC Teardown
    ...    AND    Restore Resource Search Order


TC__WCDMA_RAT_reset_from_ADMIN
    Log  TC: KPI__WCDMA_RAT_reset_from_ADMIN.


TC__GSM_RAT_reset_from_ADMIN
    Log  TC: KPI__GSM_RAT_reset_from_ADMIN.

TC__5G_RAT_Reset_From_WebEM
    Log  TC: KPI__5G_RAT_Reset_From_WebEM.

TC__5G_RAT_Reset_From_WebEM_Soft
    Log  TC: KPI__5G_RAT_Reset_From_WebEM_Soft.

TC__5G_RAT_Reset_From_WebEM_Hard
    Log  TC: KPI__5G_RAT_Reset_From_WebEM_Hard.

TC__Remote_power_reset
    Log  TC: KPI__Remote_power_reset.

TC__BTS_autonomous_reset_after_plan_activation
    Log  TC: KPI__BTS_autonomous_reset_after_plan_activation.

TC__BBMOD_Power_Reset_From_WebEM
    Log  TC: KPI__BBMOD_Power_Reset_From_WebEM.

TC__Configuration_plan_activation_with_cell_locking
    Log  TC: KPI__Configuration_plan_activation_with_cell_locking.

TC__Cell_lock_unlock_for_LTE_or_NR_cell_dn_1
    Log  TC: KPI__Cell_lock_unlock_for_LTE_or_NR.

TC__Cell_lock_unlock_for_LTE_or_NR_cell_dn_2
    Log  TC: KPI__Cell_lock_unlock_for_LTE_or_NR.

TC__Cell_block_unblock
    Log  TC: TC__Cell_block_unblock.

TC__Radio_module_reset_from_admin
    Log  TC: KPI__Radio_module_reset_from_admin.

TC__RMOD_power_reset
    Log  TC: KPI__RMOD_power_reset.

[1][1.0] Energy Consumption Measurements
    [Tags]  QC_[test_instance_id]
    Log  Testul de functionalitate.


[1][1.0] KPI#2a(b) Inter-Release SW Activation Downtime - N-1 to N
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#2a(b) Inter-Release SW Activation Downtime - N-1 to N.

[1][1.0] KPI#2c(d) Intra-Release SW Activation Downtime
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#2c(d) Intra-Release SW Activation Downtime.

[1][1.0] KPI#4 Complete BTS SW Upgrade
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#4 Complete BTS SW Upgrade.

[1][1.0] KPI#1 Site Reset Downtime
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#1 Site Reset Downtime.

[1][1.0] KPI#3 Power-on Startup Availability
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#3 Power-on Startup Availability.

[1][1.0] KPI#5 Capacity Module Reset Downtime
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#5 Capacity Module Reset Downtime.

[1][1.0] KPI#7 LTE RAT Reset Downtime
    [Tags]  QC_[test_instance_id]
    LOg  TC: KPI#7 LTE RAT Reset Downtime.

KPI#7a_b
    [Tags]  QC_784473  QC_784475
    [Timeout]    300
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${REF_CONFIGURATION}    12
    ...    AND    Set Test Variable    @{KPIS_TO_CALCULATE}    kpi7a  kpi7b
    ...    AND    KPI__Compare_KPI.TC Setup
    TC__Compare delta files
    [Teardown]    Run Keywords    KPI__Compare_KPI.TC Teardown
	...    AND    Report KPI    kpi7a

[1][1.0] KPI#10 5G RAT Reset Downtime
    [Tags]  QC_[test_instance_id]
    Log  [1][1.0] KPI#10 5G RAT Reset Downtime.

[1][1.0] [1][1.0]KPI#10a Manual 5G RAT reset downtime
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#10a Manual 5G RAT reset downtime.

[1][1.0] [1][1.0]KPI#10b Manual 5G RAT reset downtime RAT Hard Reset
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#10b Manual 5G RAT reset downtime RAT Hard Reset.

[1][1.0] KPI#11 - Manual remote power reset downtime
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#11 - Manual remote power reset downtime.

[1][1.0] KPI#12 - BTS autonomous reset after plan activation
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#12 - BTS autonomous reset after plan activation.

[1][1.0] [1][1.0]KPI#14 BBMOD_Power_Reset_From_WebEM
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#14 BBMOD_Power_Reset_From_WebEM.

[1][1.0] KPI#16 - Manual cell lock unlock duration
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#16 - Manual cell lock unlock duration.

[1][1.0] KPI#17a_b Cell Block-Unblock duration
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#17a_b Cell Block-Unblock duration.

[1][1.0] KPI#51a_b Radio Unit Reset Downtime
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#51a_b Radio Unit Reset Downtime.

[1][1.0] KPI#54a_b Power-on Radio Unit startup availability
    [Tags]  QC_[test_instance_id]
    Log  TC: KPI#54a_b Power-on Radio Unit startup availability.

Max_Duration_of_RAT_Reset
    [Tags]  QC_[test_instance_id]
    Log  TC: Max_Duration_of_RAT_Reset.

Max_Duration_of_Remote_Power_Reset
    [Tags]  QC_[test_instance_id]
    Log  TC: Max_Duration_of_Remote_Power_Reset.

Max_Duration_of_Capacity_Module_Reset
    [Tags]  QC_[test_instance_id]
    Log  TC: Max_Duration_of_Capacity_Module_Reset.

Max_Duration_of_Radio_Module_Reset
    [Tags]  QC_[test_instance_id]
    Log  TC: Max_Duration_of_Radio_Module_Reset.

