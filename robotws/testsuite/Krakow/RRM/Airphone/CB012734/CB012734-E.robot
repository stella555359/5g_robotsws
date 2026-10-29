*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Patryk Wojcik
...    contact: patryk.wojcik@nokia.com
...    R&D feature flags:
...         0x590253=0x0    rdActDedicatedCsiSlots -A
...         0x580953=0x0    rdActAutoSCellDeactivationOnLoad -B -C
...         0x580958=0x0    rdSinglePfMetricPerUeThreshold -D
...         0x580957=0x0    rdActSinglePfMetricPerUeOnLoad -D
...         0x580959=0x1    rdActEnhBeamSelection -E
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
...    rad_params=@{enable_CB012734-E}
...    x2=False
...    AND    Create aliases

Suite Teardown    Suite teardown after execution

*** Variables ***
${egate_config}=        ${CURDIR}/config/wts_212_UEs_different_QCIs.lua
${scfc}=                ${CURDIR}/config/scfc_FR2_8CC_TDD_NSA.xml
${iphy}=                ${CURDIR}/config/AP_AWEUB_8cells.xml
@{enable_CB012734-E}    0x590253=0x0    0x580953=0x0    0x580958=0x0    0x580957=0x0    0x580959=0x1    0x580983=0x0    0x590254=0x0    0x590255=0x0

*** Test Cases ***
CB012734-E_B1_Verification_of_the_performance_of_new_beam_selection_algorithm_in_DL_scheduler_with_scheduling_traffic_and_4CC
    [Tags]    SBTS25R1
    CB012734 feature enable
    Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=3    ul_scells=3
    Set parameter to value    moc=NRCELLGRP    id=0    parameter=nbActiveCarriersThreshold    value=1000
    Attach multi ues to specific beam and bearer with traffic    first_ue=107    last_ue=117    beam_id=0    bearer_id=1    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=118    last_ue=124    beam_id=1    bearer_id=1    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=125    last_ue=129    beam_id=2    bearer_id=1    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=130    last_ue=133    beam_id=3    bearer_id=1    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=134    last_ue=135    beam_id=4    bearer_id=1    mbps=50
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=135
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=1
    Log to console    Cells traffic bearer-1 is ${all_ues_traffic}
    Attach multi ues to specific beam and bearer with traffic    first_ue=136    last_ue=137    beam_id=0    bearer_id=3    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=138    last_ue=141    beam_id=1    bearer_id=3    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=142    last_ue=146    beam_id=2    bearer_id=3    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=147    last_ue=152    beam_id=3    bearer_id=3    mbps=50
    Attach multi ues to specific beam and bearer with traffic    first_ue=153    last_ue=159    beam_id=4    bearer_id=3    mbps=50
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=135
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=1
    Log to console    Cells traffic bearer-1 is ${all_ues_traffic}
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=136    last_ue=159
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=3
    Log to console    Cells traffic bearer-3 is ${all_ues_traffic}
    Sleep    10s  reason=wait for tput stabilization
    Start TTI trace
    Stop and convert TTI trace collection    delay=2
    Run Keyword And Continue On Failure    Verify percentage of skipped ues
    ...    expected_limit=0.15
    ...    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces/
    ...    direction=dl

    [Teardown]    Run Keywords
    ...    Detach multi UEs    first_ue_id=107    last_ue_id=159
    ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB012734-E_B2_Verification_of_the_performance_of_new_beam_selection_algorithm_in_UL_scheduler_with_scheduling_traffic_and_2CC
    CB012734 feature enable
    Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=3    ul_scells=3

    Attach multi ues to specific beam and bearer with traffic    first_ue=107    last_ue=117    beam_id=0    bearer_id=1    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=118    last_ue=124    beam_id=1    bearer_id=1    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=125    last_ue=129    beam_id=2    bearer_id=1    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=130    last_ue=133    beam_id=3    bearer_id=1    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=134    last_ue=135    beam_id=4    bearer_id=1    trf_dir=ul

    Attach multi ues to specific beam and bearer with traffic    first_ue=136    last_ue=137    beam_id=0    bearer_id=3    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=138    last_ue=141    beam_id=1    bearer_id=3    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=142    last_ue=146    beam_id=2    bearer_id=3    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=147    last_ue=152    beam_id=3    bearer_id=3    trf_dir=ul
    Attach multi ues to specific beam and bearer with traffic    first_ue=153    last_ue=159    beam_id=4    bearer_id=3    trf_dir=ul
    Sleep    10s    reason=wait for tput stabilization
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=ul    first_ue=107    last_ue=135
    ...                                                                    data_rate_type=Average    bearer_type=mcg    bearer=1
    Log to console    Cells traffic bearer-1 is ${all_ues_traffic}
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=ul    first_ue=136    last_ue=159
    ...                                                                    data_rate_type=Average    bearer_type=mcg    bearer=3
    Log to console    Cells traffic bearer-3 is ${all_ues_traffic}
    Start TTI trace
    Stop and convert TTI trace collection    delay=2
    Run Keyword And Continue On Failure    Verify percentage of skipped ues
    ...    expected_limit=0.15
    ...    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces/
    ...    direction=ul

    [Teardown]    Run keywords
    ...    Detach multi UEs     first_ue_id=107    last_ue_id=159
    ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
