*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Alin Necula (alin.necula@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000955-A
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000955-A/general_QSFP.robot

Resource    ./resources/5GC000955-A-a.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN            master_classicalbts_all   #regression optimization
#...     CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    CA_BTS_OAM_FMRECOV
#...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    CA_BTS_OAM_FMRECOV
#  QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts   SBTS21B   SBTS22R1  SBTS22R2

Suite Setup       Run Keywords  Update Selenium Library
...               AND           Suite Preconditions
...               AND           Create QSFP-LANE Objects
...               AND           Branch or Trunk
Suite Teardown    Run Keywords  Delete QSFP-LANE Objects
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
5GC000955-A-a-QSFP_Monitoring
    [Tags]   CRT   SBTS22R3 
#    [Documentation]
#    ...
    QSFP Monitoring


#5GC000955-A-a-WebEM_User_Access_Control_Permissions_for_SFP_or_QSFP_Control_and_Monitor_BTS_System_Administrator
#    [Tags]   CRT   SBTS00  SBTS22R3                                     # regression optimization
#    [Documentation]
#    ...
#    WebEM User Access Control Permissions for QSFP control and monitor - BTS System Administrator


5GC000955-A-a-QSFP_LANE_Lock_and_Unlock
    [Tags]   CRT   SBTS22R3
#    [Documentation]
#    ...
    QSFP LANE lock and unlock



