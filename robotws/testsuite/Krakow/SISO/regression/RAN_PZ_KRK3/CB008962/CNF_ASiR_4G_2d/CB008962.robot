*** Settings ***
Documentation
...         Suite for CB008962


Library      Collections
Library      taf.sw.reporting_portal
Library      taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot


Test Teardown   Run Keywords
...             Run Keyword And Ignore Error    taf.sw.reporting_portal.Set Reference Configuration Id    CNF_ASiR_4G_2d
...             AND
...             Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Suite Setup     Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                  should_5G_neighbour_be_changed=${False}
...                                                                  swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown      Common Suite Teardown

*** Variables ***

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
@{TEMPORARY_ALLOWED_AlARMS}
@{TEMPORARY_CRITICAL_AlARMS}     10      # No Connection to Unit
@{CRITICAL_AlARMS}

*** Test Cases ***

CB008962_SR_D_10_hub reset KPI_last cell down to 1st cell up_CNF_ASiR_4G_2d
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
   ...                                report_to_rep=${True}

CB008962_SR_D_11_ant reset KPI__cell degraded to cell normal_ASiR_4G_2d
   &{kpi_target}=     Create Dictionary    kpi42=${110}
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

CB008962_SR_D_9_ cell ublock on KP_unBlock request to cell up_CNF_ASiR_4G_2d
  &{kpi_target}=     Create Dictionary    kpi17a=${10}     kpi17b=${15}
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

CB008962_SR_D_5_site_reset KPI_1st cell down to last up
  &{kpi_target}=                      Create Dictionary    kpi1a=${510}    kpi1b=${390}     kpi1c=${390}
  ${results}=                         run_site_reset_in_loop
  ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
  ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
  ...                                 critical_alarms=${CRITICAL_AlARMS}
  ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
  ...                                 target=${kpi_target}
  ...                                 iterations=${20}
  ...                                 timeout=${720}
  ...                                 collect_passed_snapshot=${False}
  ...                                 report_to_rep=${True}

CB008962_SR_D_6_Poweron KPI_Poweron request to1st up
  &{4590_SMOD_1}=    Create Dictionary    fault_name=Fault signature for crash or failure   fault_id=4590   alarm_id=7652   hw_path=/SMOD_R-1(Left)
  ${additional_temp_list}=    Create List    ${4590_SMOD_1}
  ${power_reset_temp_list}=   Combine Lists  ${additional_temp_list}    ${TEMPORARY_ALLOWED_AlARMS}
  &{kpi_target}=     Create Dictionary    kpi3=${450}
  ${results}=                         run_bts_power_on_in_loop
  ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
  ...                                 temp_allowed_alarms=${power_reset_temp_list}
  ...                                 critical_alarms=${CRITICAL_AlARMS}
  ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
  ...                                 target=${kpi_target}
  ...                                 iterations=${20}
  ...                                 timeout=${720}
  ...                                 collect_passed_snapshot=${False}
  ...                                 report_to_rep=${True}
