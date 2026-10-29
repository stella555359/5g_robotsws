*** Settings ***
Documentation
...    Author: Monika Szlovak
...    Maintainer: Monika Szlovak
...    Test Description: Remote Syslog for continous log storage
...    Execution: /opt/ute/python/bin/robot -v CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d
...    /opt/ute/logs/ testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007310-5G-A/5GC001525-OA/general.robot
...    Dryrun: /opt/ute/python/bin/robot -t "1.0 Remote_syslog_transmission_using_UDP_with_remoteSyslogFormat=NSN"
...    --dryrun --log NONE --report NONE --output NONE -v CONFIGURATION:dryrun -C off -d /home/ute/logs -L TRACE
...    testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007310-5G-A/5GC001525-OA/general.robot
...    AC/REQ: LTE_OPR_AC_4546 / LTE_OPR_REQ_7994
...    NA in OSSEMS TRUNK

Resource    ../../resources/pretest_posttest.robot
Resource    ./resources/5GC001525-OA.robot
#Resource    ../../OAM_Common.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS23R1
...    CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB
...    CA_BTS_OAM_VERIF    master_classicalbts_all  # SBTS22R1  SBTS22R2  SBTS22R3

Suite Setup       Run Keywords      5GC001525-OA.UTE TL Preparation
...               AND               Suite Preconditions

#Suite Setup       Suite Preconditions
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
[1.0] Remote_syslog_transmission_using_UDP_with_remoteSyslogFormat=NSN
    [Tags]   CRT
    [Documentation]
    ...
    Remote_syslog_transmission_using_UDP_with_remoteSyslogFormat=NSN



