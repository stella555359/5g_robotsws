*** Settings ***
Documentation
...    Author: Zaharia Andreea (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: FGCR-9836-K
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /opt/ute/logs/
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/FGCR-9836-K/general_test3.robot
...    Dryrun: /opt/ute/python/bin/robot -t "FGCR-9836_K_ROBUSTNESS_Migration_from_dual-core_to_single-core"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/FGCR-9836-K/general.robot

Resource    ./resources/FGCR-9836-K.robot
Resource    ./resources/keyword.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS00   SBTS22R4   CRT
#...    CLOUD_5G_CLASSICAL_FULLRACK_ASIKL_ABILB1B2_ASIKR_ABILB4B5_AZQG_AZQP
#...    CA_BTS_OAM_VERIF    master_classicalbts_all

#Suite Setup       Run Keywords  Suite Preconditions
#...               AND           Branch or Trunk

Suite Setup       Run Keywords      FGCR-9836-K.UTE TL Preparation
...               AND               Suite Preconditions
...               AND               Branch or Trunk
Suite Teardown    FGCR-9836-K.Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
##FGCR-9836_ROBUSTNESS_Rollback_Migration_from_dual-core_to_single-core
#[1.0] FGCR-9836_K_ROBUSTNESS_Migration_from_dual-core_to_single-core
#    [Tags]   CRT
#    [Documentation]
#    ...
#    ROBUSTNESS_Rollback_Migration_from_dual-core_to_single-core

##FGCR-9836_K_Configuration_Reset_rejected_on_DualCore_SW_ or_Plan_Activation
#[1.0] FGCR-9836-K_Configuration_Reset_rejected_on_DualCore_SW_ or_Plan_Activation
#    [Tags]   CRT
#    [Documentation]
#    ...
#     [Setup]    Precondition for DW software
#    Configuration_Reset_rejected_on_DualCore_SW_or_Plan_Activation
#
#FGCR-9836_K_Configuration_Reset_on_Dual_Core
[1.0] FGCR-9836_K_Configuration_Reset_on_Dual_Core
    [Tags]   CRT
    [Documentation]
    ...
    [Setup]     Preconditions for Configuration_Reset_on_Dual_Core
    Configuration_Reset_on_Dual_Core

##FGCR-9836_K_Remote_Migration_from_single_core_to_dual_core_leftPrimary
#[1.0] FGCR-9836_K_Remote_Migration_from_single_core_to_dual_core_leftPrimary
#    [Tags]   CRT
#    [Documentation]
#    ...
#    Remote_Migration_from_single_core_to_dual_core_leftPrimary
