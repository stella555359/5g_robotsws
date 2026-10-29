*** Settings ***
Documentation
...    Author: Dan Novacescu (dan.novacescu@nokia.com)
...    Maintainer: Dan Novacescu (dan.novacescu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB008797

Resource    ./resources/CB008797.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00   SBTS23R1
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    master_classicalbts_all
...    CA_BTS_OAM_FMRECOV   #SBTS22R3

Suite Setup       Suite Preconditions
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
OAM_Block_Unblock_and_Lock_UnLock_for_NR
#    [Tags]   CRT
    [Documentation]
    ...
    OAM_Block_Unblock_and_Lock_UnLock_for_NR
