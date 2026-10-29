*** Settings ***

Documentation
...    Author: Dan Moldovan (dan.moldovan@nokia.com)
...    Maintainer: an Moldovan (dan.moldovan@nokia.com)
...    Group in charge: BOAM_VERIF_ET1
...    References: doors
...    Feature Description:CB006943-5G-D-B1
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB006943-5G-D-B4/general.robot

Resource    ./resources/CB006943-B4.robot

#Force Tags   STATE_CONFIGURED  5G_RAN_FDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD     SBTS00
#...    CA_BTS_OAM_FMRECOV    QCP_BTS_OAM    QCD_MN_BTS_OAM

Suite Setup       Run Keywords  Suite O-RU_Preconditions
...               AND  Get Software Release
...               AND  Set Var For Different Branches
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

Test1_TT_TTSEC_2340 Disable IPsec for O-RUs
    [Tags]   CRT
    [Documentation]  Purpose of the test is to check that O-DU is automatically disabling IPsec tunnel
    ...   for O-DU<->O-RU connection even if IPsec is actEcpriRuMPlaneSecurity=RuProtectEnabled
    ...   Precondition: actEcpriRuMPlaneSecurity=RuProtectDisabled
    Test1 Disable IPsec for O-RUs








