*** Settings ***
Documentation
...        maintainer:   Patryk Wojcik
...        contact:      patryk.wojcik@nokia.com
...        author:       Patryk Wojcik
...        description:  Resources for CB013507

Library     taf.sw.reporting_portal         WITH NAME    reporting_portal
Library     ta5g_tshark
Library     ute_tshark
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     CB013507_resources.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../resources/former_l2_sw1/robot/collectors.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot

*** Keywords ***
Deregister UE${UE_ID} and clear up test environment
    Stop tshark   alias=tcp_mss
    Deregister UE  UE_ID=${UE_ID}

Detach UE${UE_ID} and clear up test environment
    Stop tshark   alias=tcp_mss
    Detach UE  UE_ID=${UE_ID}

Set feature flag ${parameter} to ${value}
    Log to console  Set feature flag ${parameter} to ${value}
    Configure  {'MOC': 'NRBTS', 'ID': '1', '${parameter}': '${value}'}

Verify TADV in NRPPA
    [Arguments]  ${value}  ${alias}=tshark
    Verify tshark
    ...   alias=${alias}
    ...   packet_filter=nrppa.NR_TADV == ${value}
    ...   pass_criteria= ==1
    ...   timeout=30

Send LMF request
    ${command} =  Catenate
    ...    lmf_send_ecid_meas_req id=1 ue=1 nrppa_transaction_id=1 lmf_ue_measurement_id=1
    ...    report_characteristics=OnDemand meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    Execute egate command    cmd=${command}

Set Timing Advance to ${value}
    Execute egate command    cmd=ue_ta_nr profile_id=1 ue_p_delay_initial=${value}
    Execute egate command    cmd=ue_testmode_set_nr id=1 testmode=ta action=activate profile_id=1

Configure RRCRestablishment
    Execute egate command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=reconfigurationFailure
