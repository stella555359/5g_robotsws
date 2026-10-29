*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Library      taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      ./resources/keywords.py    WITH NAME    max_config

#Suite Setup       common_setups_and_teardowns.Common Suite Setup
#Suite Teardown    common_setups_and_teardowns.Common Suite Teardown
#
#Test Setup        Custom Test Setup
#Test Teardown     common_setups_and_teardowns.Common Postconditions

*** Variables ***
${RP_CA}                            VRF_SiSo
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T07

@{ALLOWED_ALARMS}               4655     # Service account root access is enabled
...                             61649    # LMP_ACCESS_VIA_PORT
...                             4654     # EFaultId_DisabledEthernetPortSecurityAl
...                             61524    # SSH_ENABLED
...                             61648    # LMP_CONNECTIVITY_DETECTED
...                             61652    # R&D_SERVICE_PORT_ENABLED
...                             4681     # EFaultId_SanityCheckErrAl
...                             4420     # EFaultId_OngoingGpsSwUpgradeAl
...                             4592     # EFaultId_BtsResetCauseAl

@{TEMPORARY_ALLOWED_AlARMS}
@{TEMPORARY_CRITICAL_AlARMS}    10       # No Connection to Unit
@{CRITICAL_AlARMS}




*** Test Cases ***
MAX_CONFIG_OAM_KPI_TC01_SW_upgrade
    [Tags]    upgrade
    @{target_builds}=    create list
    ...                  SBTS00_ENB_9999_250331_000010

    @{source_builds}=    Create List
    ...                  SBTS25R1_ENB_0000_000628_000000

    &{kpi_target}=                      Create Dictionary
    ...                                 kpi2a=${3000}
    ...                                 kpi2b=${3000}
    ...                                 kpi2c=${3000}
    ...                                 kpi2d=${3000}

    ${results}=                         run_sw_upgrade_in_loop
    ...                                 source_build=${source_builds}
    ...                                 target_builds=${target_builds}
    ...                                 target_dir=/home/ute/UUF_SW
    ...                                 target=${kpi_target}
    ...                                 timeout=${7200}
    ...                                 iterations=${2}

MAX_CONFIG_OAM_KPI_TC02_site_reset
    [Tags]    site_reset
    &{kpi_target}=                      Create Dictionary    kpi1a=${1600}    kpi1b=${720}     kpi1c=${1200}
    ${results}=                         run_site_reset_in_loop
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${2}
    ...                                 timeout=${7200}
    ...                                 collect_passed_snapshot=${False}
    ...                                 report_to_rep=${False}

MAX_CONFIG_OAM_KPI_TC03_BBMOD_reset
    [Tags]    bbmod_reset
    &{kpi_target}=                      Create Dictionary    kpi5=${1600}    kpi14=${1600}
    ${results}=                         run_reset_bbmod_in_loop
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${5}
    ...                                 timeout=${7200}
    ...                                 collect_passed_snapshot=${False}
    ...                                 report_to_rep=${False}
    ...                                 bbmod_id=6

MAX_CONFIG_OAM_KPI_TC00_NR_RAT_reset
    [Tags]    nr_rat_reset
    &{kpi_target}=                      Create Dictionary    kpi10=${2000}    kpi10a=${2000}     kpi10b=${2000}
    ${results}=                         run_rat_reset_in_loop
    ...                                 rat_type=NR
    ...                                 additional_allowed_alarms=${ALLOWED_ALARMS}
    ...                                 temp_allowed_alarms=${TEMPORARY_ALLOWED_AlARMS}
    ...                                 critical_alarms=${CRITICAL_AlARMS}
    ...                                 temp_critical_alarms=${TEMPORARY_CRITICAL_AlARMS}
    ...                                 target=${kpi_target}
    ...                                 iterations=${1}
    ...                                 timeout=${7200}
    ...                                 collect_passed_snapshot=${False}
    ...                                 report_to_rep=${False}
