*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: George Medesan (george.medesan@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description:CB008313-5G-B_CB007422-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008313-5G-B_CB007422/general.robot


Resource    ./resources/CB007422-5G.robot
Resource    ../resources/AirPhone/resources/ute/ute_wts_runner.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_FDD  5G_RAN_FDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   
...    CA_RAN_BOAM_VERIF


#Suite Setup       Suite Preconditions
#Suite Teardown    Suite Postconditions
#Suite Setup       Run Keywords    Reach OnAir Setup for OE
#...               AND             Suite Preconditions
#Suite Teardown    Run Keywords    Reach OnAir Teardown
#...               AND             Suite Postconditions
#
#Test Setup        Test Preconditions for CB008313
#Test Teardown     Test Postconditions for CB008313

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Run Keywords     Reach OnAir Setup for OE
...               AND              Test Preconditions for CB008313
...               AND              Branch or Trunk
Test Teardown     Run Keywords    Reach OnAir Teardown
...               AND             Test Postconditions for CB008313

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
#2_FAULT_4592_triggering
#    [Tags]   CRT    SBTS22R4
#    [Documentation]
#    CB008313-5G-B_CB007422-1_Fault_4592_triggering_with_actFaultSignature

3_FAULT_52_triggering
    [Tags]   CRT   SBTS00    SBTS22R4  SBTS23R1
    [Documentation]
    CB008313-5G-B_CB007422-2_Fault_4383_triggering_with_actFaultSignature
