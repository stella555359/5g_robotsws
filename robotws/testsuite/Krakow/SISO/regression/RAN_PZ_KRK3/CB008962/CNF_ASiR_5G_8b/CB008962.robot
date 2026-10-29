
*** Settings ***
Documentation    Test Suite for OAM KPI
...              authors: Jakub Siluch
...              contact: jakub.siluch@nokia.com

Library      taf.sw.reporting_portal
Library      taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Library      Collections
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                   scfs_path=commissionings/Krakow/7_7_TSPY221/SBTS00
...                                                                   list_of_additional_allowed_alarms=@{ALLOWED_ALARMS_DURING_TL_PREPARATION}

Suite Teardown      Common Suite Teardown

Test Teardown       Run Keywords
...                 Run Keyword And Ignore Error     taf.sw.reporting_portal.Set Reference Configuration Id   CNF_ASiR_5G_8b
...                 AND
...                 Run Keyword And Ignore Error     setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***

${SEND_CONFIGURATION_VALIDATION_EMAIL}    ${False}
${Configuration_ID}    CNF_ASiR_5G_8b

@{ALLOWED_ALARMS_DURING_TL_PREPARATION}             4655     # Service account root access is enabled
...                                                 61649    # LMP_ACCESS_VIA_PORT
...                                                 4654     # EFaultId_DisabledEthernetPortSecurityAl
...                                                 61524    # SSH_ENABLED
...                                                 61648    # LMP_CONNECTIVITY_DETECTED
...                                                 61652    # R&D_SERVICE_PORT_ENABLED
...                                                 4681     # EFaultId_SanityCheckErrAl
...                                                 4700     # EFaultId_TxPowerTooLowAl
...                                                 4699     # EFaultId_TxBiasCurrentTooLowAl
...                                                 4420     # EFaultId_OngoingGpsSwUpgradeAl
...                                                 6351     # EFaultId_SystemInfoValueTagHandlingFailed
...                                                 4592     # EFaultId_BtsResetCauseAl
...                                                 4479     # EFaultId_FailureDetectedOnAssignedAntennasAl
...                                                 4480     # ANTMOD not detected
...                                                 23       # EFaultId_IncompatibleSwVersionAl
...                                                 4478     # EFaultId_AntennasAssignmentNotAvailAl

@{ALLOWED_ALARMS}               4655     # Service account root access is enabled
...                             61649    # LMP_ACCESS_VIA_PORT
...                             4654     # EFaultId_DisabledEthernetPortSecurityAl
...                             61524    # SSH_ENABLED
...                             61648    # LMP_CONNECTIVITY_DETECTED
...                             61652    # R&D_SERVICE_PORT_ENABLED
...                             4681     # EFaultId_SanityCheckErrAl
...                             4700     # EFaultId_TxPowerTooLowAl
...                             4699     # EFaultId_TxBiasCurrentTooLowAl
...                             4420     # EFaultId_OngoingGpsSwUpgradeAl
...                             6351     # EFaultId_SystemInfoValueTagHandlingFailed
...                             4592     # EFaultId_BtsResetCauseAl

@{ASIR_ALLOWED_ALARMS}           ${61648}    # LMP_CONNECTIVITY_DETECTED
@{TEMPORARY_ALLOWED_AlARMS}      4479       # EFaultId_AntennasAssignmentNotAvailAl
@{TEMPORARY_CRITICAL_AlARMS}     10         # No Connection to Unit
@{CRITICAL_AlARMS}
@{HUB_prefix}                   HUB
@{HUB_SNs}                      NH213100387


*** Test Cases ***

[1][1.0] CB009402-D_TC01_CNF_ASiR_5G_kpi1a_gnb_site_reset
   &{kpi_target}=                      Create Dictionary    kpi1a=${350}    kpi1b=${315}     kpi1c=${315}
   ${results}=                         run_site_reset_in_loop
   ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
   ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
   ...                                 critical_alarms=${CRITICAL_AlARMS}
   ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
   ...                                 target=${kpi_target}
   ...                                 iterations=${20}
   ...                                 timeout=${720}
   ...                                 collect_passed_snapshot=${True}
   ...                                 report_to_rep=${True}

[1][1.0] CB009402-D_TC05_CNF_ASiR_5G_kpi41_hub_reset
    &{kpi_target}=     Create Dictionary    kpi41=${360}
    ${results}=                         run_reset_hub_in_loop_via_asir_cli
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${20}
    ...                                 timeout=${720}
    ...                                 collect_passed_snapshot=${False}
    ...                                 report_to_rep=${True}
    ...                                 hubs_sns=${HUB_SNs}

[1][1.0] CB009402-D_TC06_CNF_ASiR_5G_kpi42_prrh_reset
    &{kpi_target}=     Create Dictionary    kpi42=${130}
    ${results}=                         run_reset_ant_in_loop
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${20}
    ...                                 timeout=${720}
    ...                                 collect_passed_snapshot=${False}
    ...                                 report_to_rep=${True}
    ...                                 ant_id=${25}

[1][1.0] CB009402-D_TC07_CNF_ASiR_5G_kpi17b_gnb_cell_unblock_request
    &{kpi_target}=     Create Dictionary    kpi17a=${10}     kpi17b=${24}
    ${results}=                         run_cell_block_unblock_in_loop
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${20}
    ...                                 timeout=${720}
    ...                                 collect_passed_snapshot=${False}
    ...                                 report_to_rep=${True}
    ...                                 cell_id=${7}

[1][1.0] CB009402-D_TC04_CNF_ASiR_5G_kpi3_gnb_power_reset
     &{kpi_target}=      Create Dictionary    kpi3=${395}
     &{4590_SMOD_1}=     Create Dictionary      fault_name=Fault signature for crash or failure    fault_id=4590    alarm_id=7115    hw_path=/SMOD_R-1
     ${additional_temp_list}=    Create List    ${4590_SMOD_1}
     ${power_reset_temp_list}=   Combine Lists  ${additional_temp_list}    ${TEMPORARY_ALLOWED_AlARMS}
     ${results}=                         run_bts_power_on_in_loop
     ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
     ...                                 temp_allowed_alarms=${power_reset_temp_list}
     ...                                 critical_alarms=${CRITICAL_AlARMS}
     ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
     ...                                 target=${kpi_target}
     ...                                 iterations=${20}
     ...                                 timeout=${720}
     ...                                 collect_passed_snapshot=${False}
