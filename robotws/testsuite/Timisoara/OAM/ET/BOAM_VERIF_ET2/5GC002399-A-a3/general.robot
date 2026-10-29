*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002399-A-a3
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001525-SA-TA/general.robot

Resource    ./resources/5GC002399-A-a3.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   SBTS00   SBTS22R4   SBTS23R1   master_classicalbts_all
#...   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CA_BTS_OAM_FMRECOV
#QCP_BTS_OAM   QCD_MN_BTS_OAM  SBTS21B  SBTS22R1  SBTS22R3  CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD

#TC to be dropped due to overlap with ST


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
#[1.0] 5GC002399-A-a3_BTS_Site_reset_L2RT
#    [Tags]   CIT   SBTS00   SBTS22R1  SBTS22R2  SBTS22R3            # regression optimization
#    [Documentation]
#    ...     Test modified after feature 5GC002399-A-B1
#    BTS_Site_reset_L2RT

[1.0] 5GC002399-A-a3_BTS_commissioning_L2RT
    [Tags]   CRT
    [Documentation]
    ...     Test modified after feature 5GC002399-A-B1
    BTS_commissioning_L2RT

#[1.0] 5GC002399-A-a3_Check_L2RT__not_running_with_EnableL2RTInSystemd!=0
#    [Tags]   CRT
#    [Documentation]
#    ...     Test modified after feature 5GC002399-A-B1,
#    ...     Test is obsolete according to CNI-57257_1_F1: CNI-57257 Removal of feature activation flag for 5GC002399
#    Check_L2RT_not_running_with_EnableL2RTInSystemd!=0
