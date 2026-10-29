*** Settings ***
Documentation
...    Author: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Maintainer: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002056-AZ_5GC000507
...    Sample execution: robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d /opt/ute/logs/
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC002056-AZ_5GC000507/general.robot

Resource    ./resources/5GC002056-AZ_5GC000507.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00  SBTS23R1   master_classicalbts_all
...    CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts  SBTS21B  SBTS22R4

#Suite Setup       Suite Preconditions
#Suite Teardown    Suite Postconditions
Suite Setup     Run Keywords     Reach OnAir Setup for LO_AP_LO
...             AND              Suite Preconditions
Suite Teardown    Run Keywords    Reach OnAir Teardown
...               AND             Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     5GC001542-RA-Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
#5GC000507_ABION_Fault_trigger_to_LSS_viaSFTP_when_fault_is_detected
#    [Tags]   CIT    SBTS22R1  SBTS22R2   SBTS22R3
#    [Documentation]
#    ...
#    5GC000507_ABION_Fault_trigger_automatic_to_LSS_viaSFTP_when_fault_is_detected

5GC000507_ABION_Fault_trigger_automatic_to_LSS_but_not_performed_when_fault_is_detected
    [Tags]   CRT
    [Documentation]
    ...
    5GC000507_ABION_Fault_trigger_automatic_to_LSS_but_not_performed_when_fault_is_detected
