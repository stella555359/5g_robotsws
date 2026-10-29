*** Settings ***
Documentation
...    This file contains keywords used for testing Feature CB008158 on Cloud RINLINE TL.

*** Keywords ***
Enable Latency Pm Counters Cloud
    Perform DU Delta Commissioning    ${CURDIR}/config/vdu_enable_latency_pm_counters.json
    Perform CU Delta Commissioning    ${CURDIR}/config/vcu_enable_latency_pm_counters.json

Set Dl Delay Threshold to 10ms
    Send XML DU Delta Commisioning    ${CURDIR}/config/vdu_delta_delay_threshold_value_10ms.xml

Set Dl Delay Threshold to 60ms
    Send XML DU Delta Commisioning    ${CURDIR}/config/vdu_delta_delay_threshold_value_60ms.xml

Set tReorderingUl To 3000ms PDCP 2 Profile
    Send XML CU Delta Commisioning    ${CURDIR}/config/vcu_tReorderingUl_set_to_3000ms_PDCP_2.xml

Prepare Bler Testmode In Dl
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 dl_bler=100,50,20,10

Acitvate Bler Testmode
    [Arguments]    ${ue_id}    ${scell}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=1 scell=${scell}

Deacitvate Bler Testmode
    [Arguments]    ${ue_id}    ${scell}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=deactivate profile_id=1 scell=${scell}
