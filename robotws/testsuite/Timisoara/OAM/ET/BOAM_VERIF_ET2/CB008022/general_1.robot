*** Settings ***

Documentation
...    Author: Monika Szlovak
...    Maintainer: Monika Szlovak
...    Test Description: BTS shall support RMOD reduction. For eCPRI case it means RMOD and the cells mapped on the removed
...    RMOD are removed from the BTS configuration and no longer visible to the operator.
...    BTS shall support eCPRI radio replacement with same capabilities.
...    Execution: /opt/ute/python3/bin/robot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    /opt/ute/logs/ testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB008022/general_1.robot
...    Dryrun: /opt/ute/python3/bin/robot -t "1.0 5_eCPRI_RMOD_Reduction_Without_Service_Impact"
...    Dryrun: /opt/ute/python3/bin/robot -t "1.0 6_eCPRI_RMOD_Replacement_Without_Service_Impact"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB008022/general_1.robot
...    REQ: LTE_OPR_REQ_5771, LTE_OPR_REQ_32448, LTE_OPR_REQ_32451

Resource    ../resources/pretest_posttest.robot
Resource    ./resources/CB008022.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00
#...    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4-B5_AHEGA_AZNA_CPRI
#...    CA_OAM    CA_MANO_SOAM3   CA_BTS_OAM_VERIF    master_classicalbts_all

#Suite Setup       Run Keywords      CB008022.UTE TL Preparation
#...               AND               Suite Preconditions

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
1.0 5_eCPRI_RMOD_Reduction_Without_Service_Impact
    [Tags]   CRT
    [Documentation]
    ...
    5_eCPRI_RMOD_Reduction_Without_Service_Impact

1.0 6_eCPRI_RMOD_Replacement_Without_Service_Impact
    [Tags]   CRT
    [Documentation]
    ...
    6_eCPRI_RMOD_Replacement_Without_Service_Impact
