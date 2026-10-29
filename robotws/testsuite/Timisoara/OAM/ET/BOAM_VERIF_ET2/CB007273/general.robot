*** Settings ***
Documentation
...    Author: David Brinzei
...    Maintainer: David Brinzei
...    Test Description: BTS shall support CPRI radio RMOD reduction.
...    It means RMOD and the cells mapped on the removed RMOD are removed from the BTS configuration,
...    and after radio is disconnected, it is no longer visible to the operator.
...    Execution: robot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    /opt/ute/logs/ testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007273/general.robot
...    Dryrun: robot -t "1.0 1_CPRI_RMOD_Reduction_Without_Service_Impact"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007273/general.robot
...    REQ: LTE_OPR_REQ_5771, LTE_OPR_REQ_32448, LTE_OPR_REQ_32451

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00   SBTS22R4
#...    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4-B5_AHEGA_AZNA_CPRI
#...    CA_OAM    CA_MANO_SOAM3   CA_BTS_OAM_VERIF    master_classicalbts_all

#Suite Setup       Run Keywords      CB008022.UTE TL Preparation
#...               AND               Suite Preconditions

Resource    ../resources/pretest_posttest.robot
Resource    ./resources/CB007273.robot

Suite Setup       Suite Preconditions
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
[1]2_Faults_4589_ EFaultID_UnitPowerResetAl
    [Tags]   CRT
    [Documentation]
    ...
    Check_Fault_4589

[1]3_Faults_4590_EFaultId_CrashOrFailureSignatureAl
    [Tags]   CRT
    [Documentation]
    ...
    Check_Fault_4590

[1]Robustness_2_Faults_4589_EFaultID_UnitPowerResetAl
    [Tags]   CRT
    [Documentation]
    ...
#   First Check
    Check_Fault_4590
#   Second Check
    Check_Fault_4590
#   Third Check
    Check_Fault_4590
#   Forth Check
    Check_Fault_4590
#   Fifth Check
    Check_Fault_4590




