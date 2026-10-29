*** Settings ***
Documentation
...               Feature ID: CB007814
Resource          ../resources/Common_resource.robot
Resource                  ./resources/CB007623_keywords.robot
Library           taf.sw.dcap.rd     WITH NAME   dcap

Force Tags        CRT    SBTS24R2    FL00    QCD_MN_RAN    QCP_RAN_ST


Test setup        CB007623_keywords.Admin Setup
Test Teardown     CB007623_keywords.Admin Teardown
*** Variables ***
&{CB007814_5GC000774_Verification_VONR_with_ROHC_enabled_UE_with_IPv4_with_FDD}
...     QC_ID_FL00=QC_679374   QC_ID_SBTS24R2=QC_773646
&{CB007814_5GC001085_CB006127_ANR_addition_for_intra_frequency_intra_gNB_neighbour_for_SA_deployment}
...     QC_ID_FL00=QC_679946    QC_ID_SBTS24R2=QC_774137
&{CB007814_5GC002139_Verify_DL_&_UL_traffic_with_varying_network_conditions_Closed_loop_4X4 MIMO_20Mhz_SA}
...     QC_ID_FL00=QC_670685    QC_ID_SBTS24R2=QC_774139
&{CB007814_5GC002060_FR1_SA_call_with_DRX_LongCycle_640_ms}
...     QC_ID_FL00=QC_670685    QC_ID_SBTS24R2=QC_774138
&{Call_Test_lock_unlock_multi_AMF}
...     QC_ID_FL00=QC_670685    QC_ID_SBTS24R2=QC_773795
&{Verify_the_TCP_call_with_10Gbps_eCPRI_link_speed}
...     QC_ID_FL00=QC_670685    QC_ID_SBTS24R2=QC_774142
&{CB007814_5GC001875_5GC000522_Verification_of_spill_over_256QAM_feature_in_gNB_10Mhz_SA_4T4R}
...     QC_ID_FL00=QC_670685    QC_ID_SBTS24R2=QC_774135
&{CB007814_5GC000517_5GC001796_Verification_of_downlink_and_Uplink_link_adaptation_20_MHZ_SA}
...     QC_ID_FL00=QC_670685    QC_ID_SBTS24R2=QC_774136
*** Test Cases ***
#CB007814_5GC000774_Verification_VONR_with_ROHC_enabled_UE_with_IPv4_with_FDD
#    Log     PASS

CB007814_5GC001085_CB006127_ANR_addition_for_intra_frequency_intra_gNB_neighbour_for_SA_deployment
    Log     PASS

#CB007814_5GC002139_Verify_DL_&_UL_traffic_with_varying_network_conditions_Closed_loop_4X4 MIMO_20Mhz_SA
#    Log     PASS

CB007814_5GC002060_FR1_SA_call_with_DRX_LongCycle_640_ms
    Log     PASS

#Call_Test_lock_unlock_multi_AMF
#    Log     PASS

#Verify_the_TCP_call_with_10Gbps_eCPRI_link_speed
#    Log     PASS

#CB007814_5GC001875_5GC000522_Verification_of_spill_over_256QAM_feature_in_gNB_10Mhz_SA_4T4R
#    Log     PASS

#CB007814_5GC000517_5GC001796_Verification_of_downlink_and_Uplink_link_adaptation_20_MHZ_SA
#    Log     PASS

*** Keywords ***
Counter value ROHC
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NE1CS']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}

Counter value ROHC NRRCC
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${dict}     Catenate    ${dict} ['${counter_name}']
    ${values}=      Get Dictionary Values   ${result${dict}}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}

