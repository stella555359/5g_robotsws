*** Settings ***
Documentation
...    Author: Monika Szlovak
...    Maintainer: Monika Szlovak
...    Test Description: Software management
...    Execution: pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/ /home/ute/

Resource    ./resources/5GC001196-E-a_5GC000174.robot

#Force Tags   STATE_SW_UPLOADED   RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN        
#...    CLOUD_5G_I_LO_AP_KL_NSA_L1B_ECPRI_CMWV_TDD   CLOUD_5G_CLASSICAL_ASILL_ABILB1_AZQG_ECPRI_ENB
#...    CA_BTS_OAM_FMRECOV    # SBTS22R1  SBTS22R2

Suite Setup       Run Keywords  UTE TL Preparation
...               AND           Suite Preconditions
...               AND           Download SW
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
[1.0] ASIL_Activation_for_pre-downloaded_SW
    [Tags]    CIT       SBTS22R3   SBTS22R4   SBTS00  SBTS23R1
    [Documentation]
    ...
    5GC001196-E-a_5GC000174_Activation_for_pre-downloaded_SW


#[1.0]ASIL_Configuration_backup
#    [Tags]    CRT      
#    [Documentation]
#    ...
#    5GC001196-E-a_5GC000174_Configuration_backup


#[1.0]ASIL_Software_download_reject
#    [Tags]    CRT              #  regression optimization 20.07.2022
#    [Documentation]
#    ...
#    5GC001196-E-a_5GC000174_Software_download_reject


#[1.0]ASIL_Stop_software_download
#    [Tags]    CRT              #  regression optimization 20.07.2022
#    [Documentation]
#    ...
#    5GC001196-E-a_5GC000174_Stop_software_download


#[1.0]ASIL_Save_SW_history_report
#    [Tags]    CRT              #  regression optimization 20.07.2022
#    [Documentation]
#    ...
#   5GC001196-E-a_5GC000174_Save_SW_history_report


#[1.0]ASIL_Save_SW_update_report
#    [Tags]    CRT              #  regression optimization 20.07.2022
#    [Documentation]
#    ...
#    5GC001196-E-a_5GC000174_Save_SW_update_report

#[1.0]ASIL_Software_rollback
#    [Tags]    CRT              #  regression optimization 20.07.2022
#    [Documentation]
#    ...
#    5GC001196-E-a_5GC000174_Software_rollback

