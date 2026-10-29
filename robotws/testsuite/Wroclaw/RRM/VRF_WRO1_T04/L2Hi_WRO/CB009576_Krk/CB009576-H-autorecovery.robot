*** Settings ***
Resource    resources/CB009576_keywords.robot

Documentation
...    author: Damian Piasecki
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    Description: Test Suite for CB009576-SR-H - Recovery & Reset

*** Keywords ***
CB009576-SR-H-B2_ASOH_07_auto_recovery_upon_Marlin_container_SW_critical_failure_rat_reset
    Autorecovery Preparation
    Marlin Container Sw Critical Failure Procedures Rat Reset
    ...     containers_list=${MARLIN_CONTAINER_SW_CRITICAL_FAILURE_RAT_RESET}

CB009576-SR-H-B3_ASOH_11_auto_recovery_upon_Thor_platform_L1_fronthaul_failure
    Autorecovery Preparation
    Thor L1 Application Critical Failure
    ...     processes_list=${THOR_L1_FRONTHAUL_PROCESS}
