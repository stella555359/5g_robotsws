*** Settings ***
Documentation
...    Author: Moldovan Dan (dan.moldovan@nokia.com)
...    Maintainer: Moldovan Dan (dan.moldovan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006615-5G-B
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB006615-5G-B/general.robot

Resource    ./resources/CB006615-5G-B.robot
Resource    ./resources/keyword.robot

Force Tags   STATE_SW_UPLOADED   CRT  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN     SBTS00     SBTS22R4  SBTS23R1
...    CLOUD_5G_CLASSICAL_MULTIGNB_ASIB_ABIL_ABIO_4xAEUD     master_classicalbts_all
...    CA_RAN_BOAM_VERIF   #SBTS22R3

Suite Setup       Run Keywords      UTE TL Preparation Dual Core
...               AND               Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***

[1.0] 8_Configuration_Reset_rejected_on_DualCore_SW_ or_Plan_Activation
    [Documentation]
    ...     Precondition:  Check that the corresponding T1 SW package exist
    ...     Test will download T1 clone package
    [Setup]    Precondition for DW software
    Configuration_Reset_rejected_on_DualCore_SW_or_Plan_Activation

[1.0] Configuration_Reset_on_DualCore_Tests_4_5_6
    [Documentation]
    ...     Test will perform Config Reset
    ...     At the end the BTS should be in dual core and on air
    ...     Before start copy bts-83_cert.p12 in "resources" dir
    ...
    [Setup]     Preconditions for Configuration_Reset_on_Dual_Core
    Configuration_Reset_on_Dual_Core
#
[1.0] 2_Remote_Migration_from_single-core_to_dual-core_leftPrimary
    [Documentation]
    ...     Precondition:  BTS Primary and Secondary must be in Single-Core !
    ...
    Remote_Migration_from_single_core_to_dual_core_leftPrimary
