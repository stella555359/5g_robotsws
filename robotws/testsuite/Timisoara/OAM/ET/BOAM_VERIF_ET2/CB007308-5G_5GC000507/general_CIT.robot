*** Settings ***
Documentation
...    Author: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Maintainer: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002056-AZ_5GC000507
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC000507/general.robot

Resource    ./resources/CB007308-5G_5GC000507.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot
Resource    ../CB007422-5G/resources/CB007422-5G.robot

Force Tags   STATE_CONFIGURED   RAN_5G   RAN_5G_TDD   5G_RAN_TDD   5G_RAN   master_classicalbts_all   SBTS00   SBTS22R4
...    CA_BTS_OAM_FMRECOV   CLOUD_5G_O_E_AP_LO_NSA_FS_ECPRI_MMWV_TDD   CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#        SBTS22R1

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
#Suite Setup     Run Keywords     Reach OnAir Setup for OE
#...             AND              Suite Preconditions
#Suite Teardown    Run Keywords    Reach OnAir Teardown
#...               AND             Suite Postconditions

Test Setup        Test Preconditions
Test Teardown     5GC001542-RA-Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
#5GC000507_ASOE_Fault_trigger_automatic_to_LSS_but_not_performed_when_fault_is_detected
#    [Tags]   CRT
#    [Documentation]
#    ...
#    5GC000507_ASOE_Fault_trigger_automatic_to_LSS_but_not_performed_when_fault_is_detected


5GC000507_ASOE_Fault_trigger_to_LSS_viaSFTP_when_fault_is_detected
    [Tags]   CIT   CIT__WITH__SBTS00   SBTS22R1  SBTS22R2   SBTS22R3
    [Documentation]
    ...
    5GC000507_ASOE_Fault_trigger_automatic_to_LSS_viaSFTP_when_fault_is_detected

