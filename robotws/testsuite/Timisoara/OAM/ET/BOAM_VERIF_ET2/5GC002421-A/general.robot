*** Settings ***

Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Madalin Budulan (madalin.budulan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: 5GC002421-A
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002421-A/general.robot

Resource    ./resources/5GC002421-A.robot

#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN    #20Bb1_classicalbts   #master_classicalbts_all
#...    CLOUD_5G_I_KL_AP_KL_NSA_FS_CPRI_CMWV_TDD   CLOUD_5G_KL_AP_NSA_FS_CMWV
#...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM

Suite Setup       Run Keywords  Suite Preconditions
...               AND           ADMIN_CLI Suite Setup
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
[1]Operator tries to execute command with invalid command name
    [Tags]   CRT
    [Documentation]
    ...
    Operator tries to execute command with invalid command name

[2]Operator tries to execute command with invalid additional parameter values
    [Tags]   CRT
    [Documentation]
    ...
    Operator tries to execute command with invalid additional parameter values

[3]Operator tries to execute command with invalid credentials
    [Tags]   CRT
    [Documentation]
    ...
    Operator tries to execute command with invalid credentials

[4]BTS supports dedicated port for connection 3600
    [Tags]   CRT
    [Documentation]
    ...
    BTS supports dedicated port for connection 3600

[5]BTS supports dedicated port for connection 443
    [Tags]   CRT
    [Documentation]
    ...
    BTS supports dedicated port for connection 443

[6]Connection with the BTS is detected and error code 4 - Site unreachable - is reported
    [Tags]   CRT
    [Documentation]
    ...
    Connection with the BTS is detected and error code 4 - Site unreachable - is reported

[7]Error code - License not available - is detected by CLI
    [Tags]   CRT
    [Documentation]
    ...
    Error code - License not available - is detected by CLI

[8]WebEM CLI shall support command Commission
    [Tags]   CRT
    [Documentation]
    ...
    WebEM CLI shall support command Commission

[9]WebEM CLI shall support command generate SCF
    [Tags]   CRT
    [Documentation]
    ...
    WebEM CLI shall support command generate SCF

[10]WebEM CLI shall support command getBtsInformation
    [Tags]   CRT
    [Documentation]
    ...
    WebEM CLI shall support command getBtsInformation

[11]WebEM CLI shall support command recommission
    [Tags]   CRT
    [Documentation]
    ...
    WebEM CLI shall support command recommission
