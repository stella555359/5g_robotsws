*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com
...    R&D feature flags:
...         0x590253=0x1    rdActDedicatedCsiSlots -A
...         0x580953=0x0    rdActAutoSCellDeactivationOnLoad -B -C
...         0x580958=0x0    rdSinglePfMetricPerUeThreshold -D
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
...    rad_params=@{enable_CB012734-A}
...    x2=False
...    AND    Create aliases

Suite Teardown    Suite teardown after execution

*** Variables ***
${egate_config}=        ${CURDIR}/config/wts_212_UEs.lua
${scfc}=                ${CURDIR}/config/scfc_FR2_8CC_TDD_NSA.xml
${iphy}=                ${CURDIR}/config/AP_AWEUB_8cells.xml
@{enable_CB012734-A}    0x590253=0x1    0x580953=0x0    0x580958=0x0    0x580957=0x0    0x580959=0x0    0x580983=0x0    0x590254=0x0    0x590255=0x0

*** Test Cases ***
CB012734-A_B5_Check_L2PS_gain_with_or_without_actDedicatedCsiSlots_in_8_CC_DL_and_4CC_UL
    CB012734 feature enable
    Set maxNumScellsDl and maxNumScellsUl to value    dl_scells=7    ul_scells=3

    Wait for next full pm interval

    Attach multi ues    first_ue_id=107    last_ue_id=159
    Start NSA traffic for multiple UEs    ues=107-159    traffic_rate=75Mbps    dir=DL

    Sleep    5s    reason=wait for tput stabilization
    ${all_ues_traffic_feature_enabled}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=159
    ...                                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   All Ues traffic feature enabled: ${all_ues_traffic_feature_enabled}
    ${pm_counters}=  Wait for next pm interval and get counters
    Run Keyword And Continue On Failure    Verify Last Counters In File
    ...    M55316C02000    <15900    UE_PSCELL_ACT_SCELL_DL
    ...    M55316C02001    <15900    UE_PSCELL_ACT_SCELL_UL
    ...    M55316C03000    <20       PSCELL_UE_0_ACT_SCELL_DL
    ...    M55316C03001    0         PSCELL_UE_1_ACT_SCELL_DL
    ...    M55316C03002    0         PSCELL_UE_2_ACT_SCELL_DL
    ...    M55316C03003    0         PSCELL_UE_3_ACT_SCELL_DL
    ...    M55316C03004    0         PSCELL_UE_4_ACT_SCELL_DL
    ...    M55316C03005    0         PSCELL_UE_5_ACT_SCELL_DL
    ...    M55316C03006    0         PSCELL_UE_6_ACT_SCELL_DL
    ...    M55316C03007    <15900    PSCELL_UE_7_ACT_SCELL_DL
    ...    M55316C04000    <20       PSCELL_UE_0_ACT_SCELL_UL
    ...    M55316C04001    0         PSCELL_UE_1_ACT_SCELL_UL
    ...    M55316C04002    0         PSCELL_UE_2_ACT_SCELL_UL
    ...    M55316C04003    <15900    PSCELL_UE_3_ACT_SCELL_UL
    ...    M55316C05000    <20       MAX_PSCELL_UE_0_ACT_SCELL_DL
    ...    M55316C05001    0         MAX_PSCELL_UE_1_ACT_SCELL_DL
    ...    M55316C05002    0         MAX_PSCELL_UE_2_ACT_SCELL_DL
    ...    M55316C05003    0         MAX_PSCELL_UE_3_ACT_SCELL_DL
    ...    M55316C05004    0         MAX_PSCELL_UE_4_ACT_SCELL_DL
    ...    M55316C05005    0         MAX_PSCELL_UE_5_ACT_SCELL_DL
    ...    M55316C05006    0         MAX_PSCELL_UE_6_ACT_SCELL_DL
    ...    M55316C05007    53        MAX_PSCELL_UE_7_ACT_SCELL_DL
    ...    M55316C06000    <20       MAX_PSCELL_UE_0_ACT_SCELL_UL
    ...    M55316C06001    0         MAX_PSCELL_UE_1_ACT_SCELL_UL
    ...    M55316C06002    0         MAX_PSCELL_UE_2_ACT_SCELL_UL
    ...    M55316C06003    53        MAX_PSCELL_UE_3_ACT_SCELL_UL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

    Verify scells activation equal 53 on all cells    pm_counters_file=${pm_counters}

    Start TTI trace collection
    Stop and convert TTI trace collection
    ...    directory_name=TTI_feature_enabled
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlLoadControlData|dlSCellActivationData
    ...    delay=2

    ${tbsize_enabled}=    Verify TbSize    csv_directory=${OUTPUTDIR}/${TESTNAME}/TTI_feature_enabled/
    Log to console     ${tbsize_enabled}
    Verify forbiden sliv    csv_directory=${OUTPUTDIR}/${TESTNAME}/TTI_feature_enabled/
    ${scheduled_enabled}=    Calculate average type of ues    ue_type=scheduledUes    csv_directory=${OUTPUTDIR}/${TESTNAME}/TTI_feature_enabled/
    Log to console    ${scheduled_enabled}
    ${skipped_enabled}=    Calculate average type of ues    ue_type=skippedUes    csv_directory=${OUTPUTDIR}/${TESTNAME}/TTI_feature_enabled/
    Log to console    ${skipped_enabled}
    ${slot_enabled}=    Calculate slot processing time    csv_directory=${OUTPUTDIR}/${TESTNAME}/TTI_feature_enabled/
    Log to console   ${slot_enabled}
    ${sum_ues} =    Evaluate    ${scheduled_enabled} + ${skipped_enabled}
    Compare    ${tbsize_enabled}    >    71200
    Compare    ${scheduled_enabled}    >    7
    Compare    ${skipped_enabled}    <    0.99
    Compare    ${slot_enabled}    <    111000
    Compare    ${all_ues_traffic_feature_enabled}    >    3700
    Compare    ${sum_ues}    >    7.88
    Compare    ${sum_ues}    <=    8

    [Teardown]    Run keywords
    ...    Detach multi UEs    first_ue_id=107    last_ue_id=159
    ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Verify scells activation equal 53 on all cells
    [Arguments]    ${pm_counters_file}=None

    Run Keyword And Continue On Failure    Verify Last Counters In File
    ...    M55316C09000    53    SCELL_ACTIVATIONS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counters_file}
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C09000    53    SCELL_ACTIVATIONS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters_file}
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C09000    53    SCELL_ACTIVATIONS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
    ...    file_path=${pm_counters_file}
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C09000    53    SCELL_ACTIVATIONS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
    ...    file_path=${pm_counters_file}
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C09000    53    SCELL_ACTIVATIONS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
    ...    file_path=${pm_counters_file}
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C09000    53    SCELL_ACTIVATIONS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counters_file}
    Run Keyword And Continue On Failure  Verify Last Counters In File
    ...    M55316C09000    53    SCELL_ACTIVATIONS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-8
    ...    file_path=${pm_counters_file}
