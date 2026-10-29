*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Madalin Budulan (madalin.budulan@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: FGCR-5052-A
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/FGCR-5052-A/general.robot

Resource    ./resources/FGCR-5052-A.robot

Force Tags   STATE_ON_AIR  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD   CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM  #21A_classicalbts  SBTS21B  SBTS22R1   SBTS22R2

Suite Setup       run keywords  Suite Preconditions
...   AND  Download SW
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
FGCR-5052-A-Software_Update_Without_Activation
   [Tags]    SBTS22R3
   [Documentation]
    ...
    Software_Update_Without_Activation

FGCR-5052-A-Software_Rollback_After_Donwload_Fails
    [Tags]    SBTS22R3
    [Documentation]
    ...
    Software_Rollback_After_Download

#FGCR-5052-A-Software_Activate_After_Download
#    [Tags]
#    [Documentation]
#    ...
#    Software_Activate_After_Download

FGCR-5052-A-Radio_Software_Update
    [Tags]    SBTS22R3
    [Documentation]
    ...
    Radio_Software_Update

#FGCR-5052-A-Software_Rollback
#    [Tags]
#    [Documentation]
#    ...
#    Software_Rollback
