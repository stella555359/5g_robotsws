*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    R&D feature flags:
...         0x590253=0x0    rdActDedicatedCsiSlots -A
...         0x580953=0x0    rdActAutoSCellDeactivationOnLoad -B -C
...         0x580958=0x1    rdSinglePfMetricPerUeThreshold -D
...         0x580957=0x0    rdActSinglePfMetricPerUeOnLoad -D
...         0x580959=0x0    rdActEnhBeamSelection -E
...         0x580983=0x0    rdActPucchBeamConstraintFR2 -F
...         0x590254=0x0    rdActIncreasedUciBits -G
...         0x590255=0x0    rdActSingleBeamReport -H

Resource      resources/CB012734_resources.robot

Suite Setup    Run keywords
...    Setup egate instances
...    AND    Prepare IWF configuration
...    AND    Prepare suite environment
...    scfc=${scfc}
...    egate_config=${egate_config}
...    ap_xml=${iphy}
...    rad_params=@{enable_CB012734-D}
...    x2=False
...    AND    Create aliases

Suite Teardown    Suite teardown after execution

*** Variables ***
${egate_config}=        ${CURDIR}/config/wts_212_UEs_different_QCIs.lua
${scfc}=                ${CURDIR}/config/scfc_FR2_8CC_TDD_NSA.xml
${iphy}=                ${CURDIR}/config/AP_AWEUB_8cells.xml
@{enable_CB012734-D}    0x590253=0x0    0x580953=0x0    0x580958=0x0    0x580957=0x1    0x580959=0x0    0x580983=0x0    0x590254=0x0    0x590255=0x0

*** Test Cases ***
CB012734-D_B1_Normal_usage_of_TD_metrics_when_threshold_not_reached
    CB012734 feature enable
    Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=7    ul_scells=1
    Attach multi ues    first_ue_id=107    last_ue_id=130
    Start NSA traffic for multiple UEs    ues=107-130    traffic_rate=200Mbps    dir=DL
    Sleep    5s
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=130
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   All Ues traffic : ${all_ues_traffic}
    Start TTI trace
    Stop and convert TTI trace collection    delay=1
    Run Keyword And Continue On Failure    Verify percentage of skipped ues
    ...    expected_limit=0.1
    ...    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces/
    ...    direction=dl
    Verify that number of active UEs is between thresholds    dir=dl    scells=8-16    up_limit=200    low_limit=170

    [Teardown]    Run keywords
    ...    Detach multi UEs    first_ue_id=107    last_ue_id=130
    ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB012734-D_B2_Check_usage_of_the_new_merged_TD_metric
    CB012734 feature enable
    Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=7    ul_scells=1
    Attach multi ues    first_ue_id=107    last_ue_id=130
    Start NSA traffic for multiple UEs    ues=107-130    traffic_rate=75Mbps    dir=DL
    Attach multi ues    first_ue_id=131    last_ue_id=159
    Start NSA traffic for multiple UEs    ues=131-159    traffic_rate=75Mbps    dir=DL
    Sleep    5s    reason=wait_for_tput_stabilization
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=159
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   All Ues traffic : ${all_ues_traffic}
    Start TTI trace
    Stop and convert TTI trace collection    delay=1
    Run Keyword And Continue On Failure    Verify percentage of skipped ues
    ...    expected_limit=0.15
    ...    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces/
    ...    direction=dl
    Verify that number of active UEs is between thresholds    dir=dl    scells=8-16    up_limit=450    low_limit=400

    [Teardown]    Run keywords
    ...    Detach multi UEs    first_ue_id=107    last_ue_id=159
    ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB012734-D_B3_Check_new_metric_with_different_radio_conditions
    [Tags]    SBTS25R1    SBTS25R2
    CB012734 feature enable
    Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=7    ul_scells=1
    Set target MCS to 27 for UEs 107-124 on profile 1
    Set target MCS to 20 for UEs 125-142 on profile 2
    Set target MCS to 15 for UEs 143-159 on profile 3
    Attach multi ues    first_ue_id=107    last_ue_id=159
    Start NSA traffic for multiple UEs    ues=107-124    traffic_rate=50Mbps    dir=DL
    Start NSA traffic for multiple UEs    ues=125-142    traffic_rate=30Mbps    dir=DL
    Start NSA traffic for multiple UEs    ues=143-159    traffic_rate=30Mbps    dir=DL
    Sleep    5s    reason=wait_for_tput_stabilization
    ${ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=124
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   Ues 107-124 traffic : ${ues_traffic}

    ${ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=125    last_ue=142
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   Ues 125-142 traffic : ${ues_traffic}

    ${ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=143    last_ue=159
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   Ues 143-159 traffic : ${ues_traffic}

    Detach and attach some ues with traffic
    Detach and attach some ues with traffic
    Detach and attach some ues with traffic

    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=159
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   All Ues traffic : ${all_ues_traffic}

    Run Keyword And Continue On Failure    Verify that number of active UEs is between thresholds
    ...                                    dir=dl    scells=8-16    up_limit=425    low_limit=400    first_ue_id=107    last_ue_id=159

    Start TTI trace
    Stop and convert TTI trace collection    conversion_filter=dlLoadControlData    delay=2

    Run Keyword And Continue On Failure    Verify percentage of skipped ues
    ...    expected_limit=0.13
    ...    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces/
    ...    direction=dl

    [Teardown]    Run keywords
    ...    Detach multi UEs    first_ue_id=107    last_ue_id=159
    ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Set target MCS to ${MCS} for UEs ${firstUE}-${lastUE} on profile ${profile}
    Set specific mcs for multi UEs    first_ue=${firstUE}    last_ue=${lastUE}    target_mcs=${MCS}    profile=${profile}

Detach and attach some ues with traffic
    Detach multi ues    first_ue_id=120    last_ue_id=124
    Detach multi ues    first_ue_id=138    last_ue_id=142
    Detach multi ues    first_ue_id=155    last_ue_id=159
    Sleep    5s    reason=Wait for stabilization

    Attach multi ues    first_ue_id=120    last_ue_id=124
    Attach multi ues    first_ue_id=138    last_ue_id=142
    Attach multi ues    first_ue_id=155    last_ue_id=159
    Sleep    5s    reason=Wait for stabilization

    Start NSA traffic for multiple UEs    ues=120-124    traffic_rate=50Mbps    dir=DL
    Start NSA traffic for multiple UEs    ues=138-142    traffic_rate=30Mbps    dir=DL
    Start NSA traffic for multiple UEs    ues=155-159    traffic_rate=30Mbps    dir=DL
    Sleep    5s    reason=Wait for stabilization
