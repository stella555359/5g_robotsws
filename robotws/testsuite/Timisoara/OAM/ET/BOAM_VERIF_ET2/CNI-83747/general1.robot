*** Settings ***
Documentation
...    Author: Izabela Muntean (izabela.muntean@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: RAN_BOAM_VERIF_SG04
...    References: doors
...    Feature Description:CNI-83747

Resource    ./resources/CNI-83747.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD     master_classicalbts_all
...    CA_BTS_OAM_FMRECOV

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             False

*** Test Cases ***
1_Trigger_FAULT_6929_SSD_Wearout
    [Tags]    CRT
    1_Trigger_FAULT6929_SSD_Wearout

2_Trigger_FAULT_6929_SSD_Wearout
   [Tags]    CRT
   2_Trigger_FAULT6929_SSD_Wearout




