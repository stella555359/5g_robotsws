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
...         0x580959=0x0    rdActEnhBeamSelection -E
...         0x580983=0x1    rdActPucchBeamConstraintFR2 -F
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
...    rad_params=@{enable_CB012734-F}
...    x2=False
...    AND    Create aliases

Suite Teardown    Suite teardown after execution

*** Variables ***
${egate_config}=        ${CURDIR}/config/wts_212_UEs_different_QCIs.lua
${scfc}=                ${CURDIR}/config/scfc_FR2_8CC_TDD_NSA.xml
${iphy}=                ${CURDIR}/config/AP_AWEUB_8cells.xml
@{enable_CB012734-F}    0x590253=0x0    0x580953=0x0    0x580958=0x0    0x580957=0x0    0x580959=0x0    0x580983=0x1    0x590254=0x0    0x590255=0x0

*** Test Cases ***
CB012734-F_B1_Filtering_UE_improves_the_scheduling_time
    [Tags]    SBTS25R1
    execute egate command    cmd=uec_l2_testmode_params fixed_csi_report=on
    CB012734 feature enable
    Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=7    ul_scells=1
    Set parameter to value    moc=NRCELLGRP    id=0    parameter=nbActiveCarriersThreshold    value=1000
    Attach multi ues to different beams with traffic    first_ue=107    last_ue=128    mbps=100
    Attach multi ues to specific beam with traffic    first_ue=129    last_ue=159    mbps=100
    Sleep    10s    reason=wait for tput stabilization
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=159
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console    Cells traffic is ${all_ues_traffic}
    Compare    ${all_ues_traffic}    >    3850
    Start TTI trace
    Stop and convert TTI trace collection    delay=1
    Run Keyword And Continue On Failure    Verify percentage of skipped ues
    ...    expected_limit=0.13
    ...    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces/
    ...    direction=dl

    [Teardown]    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report
