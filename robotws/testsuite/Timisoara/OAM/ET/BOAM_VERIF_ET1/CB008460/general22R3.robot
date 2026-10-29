*** Settings ***
Documentation
...    Author: Sergiu Crisan (sergiu.crisan@nokia.com) ; Dan Moldovan
...    Maintainer: Sergiu Crisan (sergiu.crisan@nokia.com) ; Dan Moldovan
...    Group in charge: BOAM_VERIF_ET1
...    References: doors
...    Feature Description:CB008460
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008460/general22R3.robot
...    Note: These 4 test cases are dependant on each other and should only be executed together

Resource    ./resources/CB008460-5G-B.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_CLASSICAL_ASIL_ABIO_2xO-RU   SBTS22R3
#...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords  UTE TL Preparation O-RU
...               AND           Suite O-RU_Preconditions
...               AND           Prepare BTS with T1 SW
...               AND           Get Software Release
...               AND           Get last CIT promotion Build
...               AND           Download SW from WFT
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True
${BRANCH_from_JENKINS}  SBTS00


*** Test Cases ***

Software_Upgrade_from_N-1_to_N
    [Tags]  CRT
    [Documentation]
    Software_Upgrade_from_N-x_to_N

Software_Rollback_from_N_to_N-1
    [Tags]  CRT
    [Documentation]
    Software_Rollback_from_N_to_N-x

Software_Fallback_to_N-1
    [Tags]  CRT
    [Documentation]
    [Setup]    Update Software To T1
    Software_Fallback_to_N-x

#System_Upgrade_from_Remote_server_N-1_to_N
#    [Tags]  CRT
#    [Documentation]
#    ...  COPY CERTIFICATE TO BE DONE !
#    System_Upgrade_from_Remote_server_N-x_to_N
#    [Teardown]  Run  sshpass -p "ute" ssh ute@10.5.25.105 'sudo rm -rf /var/www/webdav/Remotepackage/*'
