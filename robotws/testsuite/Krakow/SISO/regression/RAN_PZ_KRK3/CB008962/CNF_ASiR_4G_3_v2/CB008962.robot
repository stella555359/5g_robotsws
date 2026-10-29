*** Settings ***
Documentation
...         Suite for CB008962


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
...                                                                   scfs_path=commissionings/Krakow/7_7_TSPY226/SBTS00
...                                                                   list_of_additional_allowed_alarms=@{ALLOWED_ALARMS_DURING_TL_PREPARATION}

Suite Teardown      Common Suite Teardown

Test Teardown   Run Keywords
...             Run Keyword And Ignore Error     taf.sw.reporting_portal.Set Reference Configuration Id    CNF_ASiR_4G_3
...             AND
...             Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***

${SEND_CONFIGURATION_VALIDATION_EMAIL}    ${False}
${Configuration_ID}    CNF_ASiR_4G_3

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
...                                                 61510     # BTS Operator Certificate access unsuccessful

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
...                             61510     # BTS Operator Certificate access unsuccessful

@{ASIR_ALLOWED_ALARMS}           61648     # LMP_CONNECTIVITY_DETECTED
...                              61510     # BTS Operator Certificate access unsuccessful

@{TEMPORARY_ALLOWED_AlARMS}      4479       # EFaultId_AntennasAssignmentNotAvailAl
@{TEMPORARY_CRITICAL_AlARMS}     10         # No Connection to Unit
@{CRITICAL_AlARMS}
@{hub_gen1_sns}                 NH223900163
@{hub_superCell_sns}            NH223900213
@{hub_HFC_sn}                   NH213100444

*** Test Cases ***
[1]CB008962_SR_D_5_site_reset KPI_1st cell down to last up
    &{kpi_target}=     Create Dictionary    kpi1a=${380}    kpi1b=${280}     kpi1c=${280}
    ${results}=                         run_site_reset_in_loop
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${20}
    ...                                 timeout=${720}
    ...                                 collect_passed_snapshot=${False}
    ...                                 collect_ru_logs=${True}
    ...                                 report_to_rep=${True}


[1]CB008962_SR_D_11_ant reset KPI__cell degraded to cell normal_prrh_gen1
    &{kpi_target}=     Create Dictionary    kpi42=${100}
    ${results}=                         run_reset_ant_in_loop
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${20}
    ...                                 timeout=${720}
    ...                                 collect_passed_snapshot=${False}
    ...                                 related_asirmod_sns=${hub_gen1_sns}
    ...                                 report_to_rep=${True}

[1]CB008962_SR_D_10_hub reset KPI_last cell down to 1st cell up_prrh_gen1
    &{kpi_target}=     Create Dictionary    kpi41=${240}
    ${results}=                         run_reset_hub_in_loop_via_asir_cli
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${20}
    ...                                 timeout=${720}
    ...                                 collect_passed_snapshot=${False}
    ...                                 hubs_sns=${hub_gen1_sns}
    ...                                 report_to_rep=${True}

[1]CB008962_SR_D_9_ cell ublock on KP_unBlock request to cell up_HFC
    &{kpi_target}=     Create Dictionary    kpi17b=${15}    kpi17a=${10}
    ${results}=                         run_cell_block_unblock_in_loop
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${20}
    ...                                 timeout=${720}
    ...                                 collect_passed_snapshot=${False}
    ...                                 related_asirmod_sns=${hub_HFC_sn}
    ...                                 report_to_rep=${True}

