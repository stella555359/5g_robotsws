*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Alin Necula (alin.necula@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000955-A-a
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000955-A/general_SFP.robot

Resource    ./resources/5GC000955-A-a.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00      SBTS22R4     master_classicalbts_all
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD      CA_BTS_OAM_FMRECOV
#  QCP_BTS_OAM    QCD_MN_BTS_OAM   SBTS21B   SBTS22R1  SBTS22R2   SBTS22R3


Suite Setup       Run Keywords  Update Selenium Library
...               AND           Suite Preconditions
...               AND           Create SFP-LANE Objects
...               AND           ADMIN_CLI Suite Setup
...               AND           Branch or Trunk
Suite Teardown    Run Keywords  Delete SFP-LANE Objects
...               AND           Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
#5GC000955-A-a-Lock_LANE_by_CLI_is_performed_successfully
#    [Tags]   CRT                                               # regression optimization
#    [Documentation]
#    ...
#   Lock LANE by CLI is performed successfully


#5GC000955-A-a-Unlock_LANE_by_CLI_is_performed_successfully
#    [Tags]   CRT                                               # regression optimization
#    [Documentation]
#    ...
#    Unlock LANE by CLI is performed successfully


5GC000955-A-a-WebEM_shall_allow_SFP-LANE_lock_and_unlock_from_capacity_plug-in_unit_in_Detailed_Site_View
    [Tags]   CRT
#    [Documentation]
#    ...
    WebEM shall allow SFP-LANE lock and unlock from capacity plug-in unit in Detailed Site View
