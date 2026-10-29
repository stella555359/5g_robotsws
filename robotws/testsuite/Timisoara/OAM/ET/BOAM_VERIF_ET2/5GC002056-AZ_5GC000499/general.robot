*** Settings ***
Documentation
...    Author: Ioana Sandu (ioana.sandu-andrei@nokia.com)
...    Maintainer: Ioana Sandu (ioana.sandu-andrei@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002056-AZ-5GC000499
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC000499/general.robot

Resource    ./resources/5GC002056-AZ_5GC000499.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   master_classicalbts_all
...   #Regression Optimisation -part 2- July 2022    SBTS00
...    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM  #21A_classicalbts  SBTS21B  SBTS22R1  SBTS22R2  SBTS22R3

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions  #With Reset Site

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
Check if PM result file is generated every 5m
    [Tags]   CRT
    [Documentation]
    ...
    Check if PM files are generated every 5 minutes

Verify if raw PM files are available for each measurement type after the selected measurement interval has passed
    [Tags]   CRT
    [Documentation]
    ...
    Verify if raw PM files are available for each measurement type
