*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Suite Setup    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${False}

*** Variables ***
${CONFIG_DIR_PATH}      ${CURDIR}/Resources/configs
${SCFC_NAME}    gNB_scf_ASIL_ABIO_3XAQQK_eCPRI_cmwv.xml
${AIRPHONE_NAME}    AP_iphy_ASIL_ABIO_3XAQQK_eCPRI_cmwv.xml
${WTS_NAME}      wts_config_ASIL_ABIO_3XAQQK_eCPRI_cmwv.cfg
${par_of_bsr_name}    BSR_AQQK_6_H6_ALN60_ARP60_P00_25DBTAPER_00424_00001

*** Test Cases ***
[1.0] CNI_108786_A_09_Dynamic Transform Precoder Switching in Presence of Adapative Number of SRS Ports For TDD cell with 108786 enable
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable    ${ue_type}
    log to console    \n***Prepare UE***
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    5s
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Sleep   5sec
    ${bip_log}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${timestamp}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

*** Keywords ***