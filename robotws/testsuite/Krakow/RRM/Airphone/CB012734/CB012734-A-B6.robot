*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com
...    Description:
...    R&D feature flags:
...         0x590253=0x1    rdActDedicatedCsiSlots -A
...         0x580953=0x0    rdActAutoSCellDeactivationOnLoad -B -C
...         0x580958=0x0    rdSinglePfMetricPerUeThreshold -D
...         0x580957=0x0    rdActSinglePfMetricPerUeOnLoad -D
...         0x580959=0x0    rdActEnhBeamSelection -E
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
CB012734-A_B6_Worst_case_with_UE_releases
    execute egate command    cmd=uec_l2_testmode_params fixed_csi_report=on
    CB012734 feature enable
    Disable CA
    Set parameter to value    moc=NRCELLGRP    id=0    parameter=nbActiveCarriersThreshold    value=1000
    Attach ues from 107 to 212
    Start NSA traffic for multiple UEs    ues=107-212    traffic_rate=20Mbps    dir=DL
    Sleep    5s    reason=wait for tput stabilization
    ${all_ues_traffic}=    Get summarize data rate for multiple NSA UEs    dir=dl    first_ue=107    last_ue=212
    ...                                                                    data_rate_type=Average    bearer_type=scg    bearer=2
    Log to console   All Ues traffic : ${all_ues_traffic}
    Start TTI trace collection
    Stop and convert TTI trace collection
    ...    directory_name=TtiTraces_all_ues
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlLoadControlData|dlSCellActivationData
    ...    delay=2

    ${tbsize_all_ues}=    Verify TbSize    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_all_ues/
    Verify forbiden sliv    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_all_ues/
    ${scheduled_all_ues}=    Calculate average type of ues    ue_type=scheduledUes    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_all_ues/
    ${skipped_all_ues}=    Calculate average type of ues    ue_type=skippedUes    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_all_ues/
    ${slot_all_ues}=    Calculate slot processing time    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_all_ues/

    ${sellected_ues_traffic}=    Detach selected ues and get cells traffic    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_all_ues/
                                 ...                                          ues_id_and_crnti=${ues_id_and_crnti}
    Log to console   Selected Ues traffic : ${sellected_ues_traffic}
    Start TTI trace collection
    Stop and convert TTI trace collection
    ...    directory_name=TtiTraces_chosen_ues
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlLoadControlData|dlSCellActivationData
    ...    delay=2

    ${tbsize_chosen_ues}=    Verify TbSize    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_chosen_ues/
    Verify forbiden sliv    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_chosen_ues/
    ${scheduled_chosen_ues}=    Calculate average type of ues    ue_type=scheduledUes    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_chosen_ues/
    ${skipped_chosen_ues}=    Calculate average type of ues    ue_type=skippedUes    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_chosen_ues/
    ${slot_chosen_ues}=    Calculate slot processing time    csv_directory=${OUTPUTDIR}/${TESTNAME}/TtiTraces_chosen_ues/

    Compare    ${tbsize_all_ues}    <=    ${tbsize_chosen_ues}
    Compare    ${tbsize_all_ues}    <=    71688
    Compare    ${tbsize_all_ues}    >=    68000
    Compare    ${scheduled_all_ues}    <=    0.99
    Compare    ${scheduled_all_ues}    >=    0.90
    Compare    ${scheduled_chosen_ues}    <=    1
    Compare    ${scheduled_chosen_ues}    >=    0.96
    Compare    ${skipped_all_ues}    <    0.06
    Compare    ${skipped_all_ues}    >=    0.001
    Compare    ${skipped_chosen_ues}    >=    0
    Compare    ${skipped_chosen_ues}    <=    0.01
    Compare    ${slot_all_ues}    >    ${slot_chosen_ues}
    Compare    ${all_ues_traffic}    >    480
    Compare    ${sellected_ues_traffic}    >    510

    [Teardown]    Run keywords
    ...    Execute egate command    cmd=ue_detach id=107-212
    ...    AND    Run Keyword And Ignore Error   setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Attach ues from ${start_ue} to ${end_ue}
    FOR    ${id}    IN RANGE    ${start_ue}    ${end_ue}+1
        Attach UE    UE_ID=${id}
        SgNB Addition    UE_ID=${id}    CELL_ID=1    GNB_ID=2    BEARER_ID=2    RRC_CHECK=True
    END
    ${ues_list}=    Create ues id string    first_ue=${start_ue}    last_ue=${end_ue}
    Create ues deployment    ues=${ues_list}
    ${ues_id_and_crnti}=    Create Dictionary
    Set suite variable    ${ues_id_and_crnti}
    FOR   ${id}   IN RANGE   ${start_ue}    ${end_ue}+1
        ${id}=    Convert to string    ${id}
        Get Ue C-RNTI    UE_ID=${id}
        Set To Dictionary    ${ues_id_and_crnti}    ${id}    ${${crnti}${id}}
    END
