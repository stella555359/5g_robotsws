*** Settings ***
Documentation
...  author: Jiang Shengyuan
...  contact: shengyuan.jiang@nokia-sbell.com

Resource   ./Resource/Common.robot

Force Tags   SG_07   CA_5G_OAM   CRT   master_classicalbts_all
...   5G_RAN_TDD   STATE_SW_UPLOADED
...    PY36

Test Timeout   16h

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup   Case Common Setup
Test Teardown   Case Common Teardown

*** Variables ***

*** Test Cases ***
CB009834-5G-05_Classical_SA_DU_PCMD_reporting_after_BB_card_restart_ASIB_ABIO
    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
    Log To Console   Modify TL864 PA Value
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=0    value=20
    Modify All Attenuation Ports Value For Specific RU    gnb_id=0    RU_id=1    value=127
    Modify All Attenuation Ports Value For Specific RU    gnb_id=1    RU_id=0    value=127

    Log To Console   CB009834-5G-05_Classical_SA_DU_PCMD_reporting_after_BB_card_restart_ASIB_ABIO
    Classical_SA_DU_PCMD_reporting_after_BB_card_restart_And_DU_continue_PCMD_reporting_during_unimpacted_BB_card_restart
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   Initialize PA
    ...   AND   Case Common Teardown

CB009834-5G-02_Classical_SA_DU_ continue_PCMD_reporting_during_unimpacted_BB_card_restart_ASIB_ABIL
    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
    Log To Console   CB009834-5G-02_Classical_SA_DU_ continue_PCMD_reporting_during_unimpacted_BB_card_restart_ASIB_ABIL
    Classical_SA_DU_PCMD_reporting_after_BB_card_restart_And_DU_continue_PCMD_reporting_during_unimpacted_BB_card_restart

Classical_SA_DU_PCMD_reporting_after_BB_card_restart_ABIP
    [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
    Log To Console   Classical_SA_DU_PCMD_reporting_after_BB_card_restart_ABIP
    Classical_SA_DU_PCMD_reporting_after_BB_card_restart_And_DU_continue_PCMD_reporting_during_unimpacted_BB_card_restart


*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    Common Setup 1756
    Remove And Add PCMD Object
    Run Keyword And Ignore Error   COAM Logout

    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${nrcellid_ue}   XML.Get Element Text   ${local_xml}   xpath=cmData/managedObject[@distName="${INSID}/NRCELL-2"]/p[@name="nrCellIdentity"]
    ${ue_cell_identity_filter}   convert_cellidentity_to_tcpdump_filter   ${nrcellid_ue}
    set suite variable   ${nrcellid_ue}
    set suite variable   ${ue_cell_identity_filter}

Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Common Teardown 1756

Case Common Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000

Case Common Teardown
#    ${hisory_faults_whitelist}   Create List   7313   7311   7312
#    Check Unexpected History Faults   hisory_faults_whitelist=${hisory_faults_whitelist}
    Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
    robot_common_operations.Common Case Teardown
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   15m   1m   COAM Check All Cells Onair
    Run Keyword And Ignore Error   COAM Logout
