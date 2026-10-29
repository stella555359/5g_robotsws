*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Alin Necula (alin.necula@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: Doors
...    Feature Description: CB006758-SR__CB005770
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB006758-SR__CB005770/general.robot

Resource    ./resources/CB006758-SR__CB005770.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    SBTS00   SBTS22R4
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   #CLOUD_5G_I_BL_AP_KL_NSA_FS_CPRI_CMWV_TDD
...    CA_BTS_OAM_VERIF   #QCP_SRAN_SBTS  QCD_MN_SRAN  #SBTS21B  SBTS22R1  SBTS22R2 SBTS22R3

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
CB006758-SR__CB005770_mMimoAntArrayMode_Trigger_the_offline_HW_validation_from_WebEM
#    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] This test case is to verify that offline HW validation for mMimoAntArrayMode parameter
    ...    works when WebEM is used
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.04.2021 - - Created
    ...    *******************
    ...    alin.necula@nokia.com

    mMimoAntArrayMode_Trigger_the_offline_HW_validation_from_WebEM


#CB006758-SR__CB005770_supportsPhysicalAntennaPortsTrue_Trigger_the_online_HW_validation_from_WebEM
#    [Tags]   CRT
#    [Documentation]
#    ...    ****************
#    ...    - [TEST PURPOSE] This test case is to verify that offline HW validation for mMimoAntArrayMode parameter
#    ...    works when WebEM is used
#    ...    ******************
#    ...    History of changes
#    ...    ******************
#    ...    - 16.04.2021 - - Created
#    ...    *******************
#    ...    alin.necula@nokia.com
#
#    supportsPhysicalAntennaPortsTrue_Trigger_the_online_HW_validation_from_WebEM




