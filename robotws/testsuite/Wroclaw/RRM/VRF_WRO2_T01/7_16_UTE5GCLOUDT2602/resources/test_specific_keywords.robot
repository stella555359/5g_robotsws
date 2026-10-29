*** Settings ***
Documentation    Keywords for the CB006878, CB008392, CB009409 features

Library      taf.ue
Library      test_specific_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/admin_api/DeltaStore.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    GnbPmCounter
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore.DeltaStore    WITH NAME    DeltaStore
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters    WITH NAME    pm
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/ue_logs/QxdmLogsCollector.py    WITH NAME    qxdm
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/ue_logs/ue_logs.py
Library      taf.collectors.dcap     WITH NAME    dcap_collector
Variables    test_constants.py


*** Keywords ***
##  CB006878 specific keywords
CB006878_RRM_Common
    [Arguments]    ${ue_alias}    ${ue_caps}
    ${chosen_cell_id}=    Dist Name To Cell ID     dist_name=${CELL_DISTNAME_6878}
    Nullify Attenuation
    AdminUtils.Lock All Cells Except Chosen One    chosen_cell_id=${chosen_cell_id}
    Require UE    ue_alias=${ue_alias}    capabilities=${ue_caps}
    Change CB006878 Feature Activation Status    is_activate=False    cell_num=${CELL_NUM_6878}
    ${disabled_max_value}    ${disabled_average_ul_tput}=    Collect MaxNumPrbUl Values Using TTI Traces
    ...    ue_alias=${ue_alias}    nr_cell_dns=${CELL_DISTNAME_6878}    output_file=${DISABLED_TTI_FILENAME}_${ue_alias}
    Change CB006878 Feature Activation Status    is_activate=True     cell_num=${CELL_NUM_6878}
    ${enabled_max_value}    ${enabled_average_ul_tput}=    Collect MaxNumPrbUl Values Using TTI Traces
    ...    ue_alias=${ue_alias}    nr_cell_dns=${CELL_DISTNAME_6878}    output_file=${ENABLED_TTI_FILENAME}_${ue_alias}
    Log To Console    Disabled max value: ${disabled_max_value} Enabled max value: ${enabled_max_value}
    Log To Console    Disabled avg tput: ${disabled_average_ul_tput} Enabled avg tput: ${enabled_average_ul_tput}
    Should Be True    ${enabled_max_value} >= ${disabled_max_value}
    Should Be True    ${enabled_average_ul_tput} >= ${disabled_average_ul_tput}
    Log To Console    All done
    [Teardown]    Run Keywords
    ...    Change CB006878 Feature Activation Status    is_activate=False    cell_num=${CELL_NUM_6878}    AND
    ...    AdminUtils.Unlock All Cells     AND
    ...    AdminUtils.Wait For All Cells On Air State

Change CB006878 Feature Activation Status
    [Arguments]    ${is_activate}    ${cell_num}
    Log To Console    Setting actDynUlResAlloc to ${is_activate}
    Initialise Delta Store
    Run Keyword If    ${is_activate}    Run Keywords
    ...    Add Parameters To Delta    dist_name=${CELL_DISTNAME_6878}    actDynUlResAlloc=true    AND
    ...    Add Parameters To Delta    dist_name=${CELL_DISTNAME_6878}    pucchModeSelect=longPucch
    ...    ELSE    Add Parameters To Delta    dist_name=${CELL_DISTNAME_6878}    actDynUlResAlloc=false
    ${delta_store}=    Collect Delta Store
    DeltaStore.Perform Delta Recommissioning    delta_file=${delta_store}
    ${cell_number}=    Convert To Integer    ${cell_num}
    AdminUtils.Wait For Cell Availability    cell_number=${cell_number}
    Log To Console    Parameter set
    [Teardown]    Delete Delta If Already Present    name=${delta_store}

Collect MaxNumPrbUl Values Using TTI Traces
    [Arguments]    ${ue_alias}    ${nr_cell_dns}    ${output_file}
    @{nr_cell_dns_list}=    Create List    ${nr_cell_dns}
    Attach UE     ue_alias=${ue_alias}
    Log To Console    Starting data transfer
    Start Data Transfer
    ...    dt_name=${ue_alias}_DT_UL
    ...    ue_alias=${ue_alias}
    ...    throughput=500 Mbits/sec
    ...    direction=UL
    ...    duration=${TRANSFER_DURATION_DYN_UL_ALLOC}
    ...    protocol=udp
    Start Data Transfer
    ...    dt_name=${ue_alias}_DT_DL
    ...    ue_alias=${ue_alias}
    ...    throughput=10 Gbits/sec
    ...    direction=DL
    ...    duration=${TRANSFER_DURATION_DYN_UL_ALLOC}
    ...    protocol=udp
    BuiltIn.Sleep    ${TRACE_OFFSET}
    Start TTI Traces In Streaming Mode For Specified Cells    nr_cell_dns=${nr_cell_dns_list}
    BuiltIn.Sleep    ${TRACE_DURATION}
    Stop TTI Traces In Streaming Mode     decoded_output_file=${output_file}
    Await Data Transfer Finish    dt_name=${ue_alias}_DT_UL
    Await Data Transfer Finish    dt_name=${ue_alias}_DT_DL
    ${average_ul_tput}=    Get Average Throughput    dt_name=${ue_alias}_DT_UL    omit=30
    ${max_value}=    Get Max RRM Value    tti_path=${OUTPUT_DIR}/${output_file}.dlAndUl.csv
    Log to console    Data transfer finished, max val = ${max_value}, average UL tput = ${average_ul_tput}
    [Return]     ${max_value}    ${average_ul_tput}
    [Teardown]    Run Keywords
    ...    Teardown TTI Traces In Streaming Mode    decoded_output_file=${output_file}    AND
    ...    Detach UE     ue_alias=${ue_alias}

##  CB008392 specific keywords
CB008392_RRM_Common
    Activate Load-Based Reduced TX Path Power Saving
    Nullify Attenuation
    AdminUtils.Lock Cells    cell_list=${CELLS_LIST_TO_LOCK_8392}
    Require Ue    ue_alias=${UE_ALIAS_SA}    capabilities=${SA_UE_CAPS}
    GnbPmCounter.Wait For Next Pm Period    interval=${PM_INTERVAL}
    Log To Console    Load-Based Power Saving Suspending
    Suspend Load-Based Power Saving    is_suspended=suspended
    Log To Console    Load-Based Power Saving Suspended
    Attach Ue And Start Data Traffic    ue_alias=${UE_ALIAS_SA}
    Check If Cells Are Not In Reduced Energy Saving State    cell_list=${CELLS_DIST_FOR_8392}
    Verify Pm Counters    is_suspended=${True}    cell_list=${CELLS_FOR_8392}
    Log To Console    Load-Based Power Saving Unsuspending
    Suspend Load-Based Power Saving    is_suspended=notSuspended
    Log To Console    Load-Based Power Saving Unsuspended
    Attach Ue And Start Data Traffic    ue_alias=${UE_ALIAS_SA}
    Wait For Cells To Achieve Reduced Energy Saving State    cell_list=${CELLS_DIST_FOR_8392}
    Verify Pm Counters    is_suspended=${False}    cell_list=${CELLS_FOR_8392}
    [Teardown]    Run Keywords    AdminUtils.Unlock All Cells    AND
    ...           AdminUtils.Wait For All Cells On Air State    AND
    ...           Run Keyword And Ignore Error    Delete Given NRPGRP    nrpgrp_id=${NRPGRP_ID}

Activate Load-Based Reduced TX Path Power Saving
    [Arguments]    ${nrpgrp_id}=${NRPGRP_ID}
    Log To Console    Activate Load-Based Reduced TX Path Power Saving
    Run Keyword And Ignore Error    Delete Given NRPGRP    nrpgrp_id=${nrpgrp_id}
    Initialise Delta Store
    Add Parameters To Delta    dist_name=${BTS_DISTNAME}/NRPMRNL-1    miNrCellAvailability=5min
    Add Parameters To Delta    dist_name=${BTS_DISTNAME}              actNrLBRTXPowerSaving=true
    ${nrpgrp_params}=    Set Parameters For New NRPGRP
    Add Managed Object And Parameter To Delta    dist_name=${BTS_DISTNAME}/NRPGRP-${nrpgrp_id}    &{nrpgrp_params}
    Create Load-Based Power Saving Cell Lists    cell_list=${CELLS_FOR_8392}    order_list=${ORDERS_LIST}
    ...                                          nrpgrp_id=${nrpgrp_id}
    Create Load-Based Power Saving Period List    nrpgrp_id=${nrpgrp_id}
    ${delta_store}=    Collect Delta Store
    DeltaStore.Perform Delta Recommissioning    delta_file=${delta_store}
    Log To Console    Load-Based Reduced TX Path Power Saving Activated
    [Teardown]    Delete Delta If Already Present    name=${delta_store}

Delete Given NRPGRP
    [Arguments]    ${nrpgrp_id}
    Initialise Delta Store
    Delete Managed Object From Delta    dist_name=${BTS_DISTNAME}/NRPGRP-${nrpgrp_id}
    ${delta_store}=    Collect Delta Store
    DeltaStore.Perform Delta Recommissioning    delta_file=${delta_store}
    [Teardown]    Delete Delta If Already Present    name=${delta_store}

Set Parameters For New NRPGRP
    ${nrpgrp_dict}=    Create Dictionary
    ...                lbpsSOMethod=TX switch off
    ...                lbpsRTXMaxLoad=60
    ...                lbpsRTXMinLoad=20
    ...                lbpsLastCellRTXMinLoad=20
    ...                lbpsRTXCellCapOffset=70
    ...                lbpsPdcchLoadOffset=4
    ...                lbpsLastCellSOEnabled=true
    ...                lbpsRTXSOffTime=${RTXS_OFF_TIME}
    ...                lbpsRTXSOnTime=60
    ...                lbpsCSONCtlEnabled=true
    ...                lbpsLastCellMinLoad=0
    ...                lbpsMaxLoad=60
    ...                lbpsMinLoad=20
    [Return]    ${nrpgrp_dict}

Create Load-Based Power Saving Cell Lists
    [Arguments]    ${cell_list}    ${order_list}    ${nrpgrp_id}
    FOR    ${cell}    ${order}    IN ZIP    ${cell_list}    ${order_list}
        ${lbpsCellList_params}=      Create Dictionary
        ...                          nrCellId=${cell}
        ...                          lbpsCellSOOrder=${order}
        ...                          lbpsUseExtConfig=false
        Add Complex Item To Delta    dist_name=${BTS_DISTNAME}/NRPGRP-${nrpgrp_id}
        ...                          list_name=lbpsCellList    &{lbpsCellList_params}
    END

Set Parameters For Load-Based Power Saving Period List
    [Arguments]    ${is_suspended}
    ${day_of_week}=    Get Day Of Week
    ${lbpsPeriodList_dict}=    Create Dictionary
    ...                        lbpsDayOfWeek=${day_of_week}
    ...                        lbpsDuration=1440
    ...                        lbpsStartTimeHour=0
    ...                        lbpsStartTimeMinute=0
    ...                        lbpsSuspended=${is_suspended}
    [Return]    ${lbpsPeriodList_dict}

Create Load-Based Power Saving Period List
    [Arguments]    ${nrpgrp_id}
    ${lbpsPeriodList_params}=    Set Parameters For Load-Based Power Saving Period List    is_suspended=notSuspended
    Add Complex Item To Delta    dist_name=${BTS_DISTNAME}/NRPGRP-${nrpgrp_id}
    ...                          list_name=lbpsPeriodList    &{lbpsPeriodList_params}

Suspend Load-Based Power Saving
    [Arguments]    ${is_suspended}    ${nrpgrp_id}=${NRPGRP_ID}
    Initialise Delta Store
    ${lbpsPediodList_params}=    Set Parameters For Load-Based Power Saving Period List    is_suspended=${is_suspended}
    Add List Parameters To Delta    dist_name=${BTS_DISTNAME}/NRPGRP-${nrpgrp_id}
        ...                         list_name=lbpsPeriodList     &{lbpsPediodList_params}
    ${delta_store}=    Collect Delta Store
    DeltaStore.Perform Delta Recommissioning    delta_file=${delta_store}
    [Teardown]    Delete Delta If Already Present    name=${delta_store}

Attach Ue And Start Data Traffic
    [Arguments]    ${ue_alias}
    Attach UE    ue_alias=${ue_alias}
    Sleep     5s
    Log To Console    Starting data transfer
    Start Data Transfer
    ...    dt_name=${ue_alias}_DT_UL
    ...    ue_alias=${ue_alias}
    ...    throughput=500 Mbits/sec
    ...    direction=UL
    ...    duration=${TRANSFER_DURATION_PS}
    ...    protocol=udp
    Start Data Transfer
    ...    dt_name=${ue_alias}_DT_DL
    ...    ue_alias=${ue_alias}
    ...    throughput=10 Gbits/sec
    ...    direction=DL
    ...    duration=${TRANSFER_DURATION_PS}
    ...    protocol=udp
    Await Data Transfer Finish    dt_name=${ue_alias}_DT_UL
    Await Data Transfer Finish    dt_name=${ue_alias}_DT_DL
    Log to console    Data transfer finished
    [Teardown]    Detach UE    ue_alias=${ue_alias}

Wait For Cells To Achieve Reduced Energy Saving State
    [Arguments]   ${cell_list}
    Log To Console    Waiting for RTX Off Timeout
    BuiltIn.Sleep     ${RTXS_OFF_TIME}
    FOR    ${cell}    IN    @{cell_list}
        Wait Until Keyword Succeeds    300s    30s    Assert Cell In Reduced Energy Saving State    cell_id=${cell}
    END

Check If Cells Are Not In Reduced Energy Saving State
    [Arguments]   ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Assert Cell Not In Reduced Energy Saving State    cell_id=${cell}
    END

Verify Pm Counters
    [Arguments]    ${is_suspended}    ${cell_list}
    Log To Console    Verifying counters
    GnbPmCounter.Wait For Next Pm Period    interval=${PM_INTERVAL}
    ${pm_counters_path}=    pm.Collect Counters
    FOR    ${cell}    IN    @{cell_list}
        ${cell_to_list}=    Create List    ${cell}
        IF    ${is_suspended}
            pm.Check Counter Equals X
            ...    pi_dir=${pm_counters_path}
            ...    counter_name=M55601C02001
            ...    object_id=${cell_to_list}
            ...    x=0
            ...    n_last_values=1
            pm.Check Counter Equals X
            ...    pi_dir=${pm_counters_path}
            ...    counter_name=M55601C02002
            ...    object_id=${cell_to_list}
            ...    x=0
            ...    n_last_values=1
        ELSE
            pm.Check Counter Greater Than X
            ...    pi_dir=${pm_counters_path}
            ...    counter_name=M55601C02001
            ...    object_id=${cell_to_list}
            ...    x=0
            ...    n_last_values=3
            pm.Check Counter Greater Than X
            ...    pi_dir=${pm_counters_path}
            ...    counter_name=M55601C02002
            ...    object_id=${cell_to_list}
            ...    x=0
            ...    n_last_values=3
        END
    END

##  CB009409 specific keywords
CB009409_RRM_Common
    Nullify Attenuation
    AdminUtils.Lock Cells     ${CELLS_LIST_TO_LOCK_9409}
    Require UE    ue_alias=${UE_ALIAS_SA}    capabilities=${SA_UE_CAPS}
    Activate TCP Boost Proactive Uplink Grants
    Wait Until Keyword Succeeds    5 min    40 sec    Get 5G QXDM And QCAT License
    ...    username=${LK_USERNAME}    password=${LK_PASSWORD}    ue_id=0    lk_path=${LK_PATH}
    Collect And Save QXDM HDF Log    log_file=${QXDM_LOG_FILE}    duration=${QXDM_DURATION}
    ...      dmc_file=${QXDM_DMC_FILE}    com_port=${COM_PORT}         python_path=python
    Collect Emil Logs From Data Transfer    ue_alias=${UE_ALIAS_SA}
    ${emil_files}=    Extract Emil Logs
    ${decoded_files}=     Decode Emil Logs On UEPC
    ...    local_path=${OUTPUT_DIR}/dcap/
    ...    file_list=${emil_files}
    ...    remote_path=${EMIL_LOG_PATH}
    ...    emil_path=${EMIL_PATH}
    Check Emil Log For Carrier Aggregation
    ...    file_list=${decoded_files}    pcell_pcid=${PCELL_PCID}    scell_pcid=${SCELL_PCID}
    ${txt_log}=    Convert HDF Log To TXT    hdf_log=${QXDM_LOG_FILE}    qcat_path=${QCAT_PATH}
    Download QXDM Log    output_dir=${OUTPUT_DIR}/${QXDM_OUTPUT_FILENAME}.txt    log_filepath=${txt_log}
    Check PDSCH TB Size    filepath=${OUTPUT_DIR}/${QXDM_OUTPUT_FILENAME}.txt    tb_size=${TB_SIZE}
    [Teardown]    Run Keywords
    ...     AdminUtils.Unlock All Cells       AND
    ...     AdminUtils.Wait For All Cells On Air State    AND
    ...     Release 5G QXDM And QCAT License    ue_id=0    lk_path=${LK_PATH}

Activate TCP Boost Proactive Uplink Grants
    Log To Console    Setting actTcpBoostPug to allUes
    Initialise Delta Store
    Add Parameters To Delta    dist_name=${CELL_DISTNAME_9409}    actTcpBoostPug=allUes
    ${delta_store}=    Collect Delta Store
    DeltaStore.Perform Delta Recommissioning    delta_file=${delta_store}
    ${cell_number}=    Convert To Integer    ${PCELL_NUM_9409}
    AdminUtils.Wait For Cell Availability    cell_number=${cell_number}
    Log To Console    Parameter set
    [Teardown]    Delete Delta If Already Present    name=${delta_store}

Collect Emil Logs From Data Transfer
    [Arguments]    ${ue_alias}
    Setup DCAP
    Attach UE     ue_alias=${ue_alias}
    Log To Console    Starting data transfer
    Start Data Transfer
    ...    dt_name=${ue_alias}_DT_DL
    ...    ue_alias=${ue_alias}
    ...    throughput=10 Gbits/sec
    ...    direction=DL
    ...    duration=${TRANSFER_DURATION_TCP_BOOST}
    ...    protocol=tcp
    Await Data Transfer Finish    dt_name=${ue_alias}_DT_DL
    Log To Console    Data transfer finished
    Stop And Gather DCAP
    [Teardown]    Detach UE     ue_alias=${ue_alias}

Extract Emil Logs
    ${output}=    Run    cd ${OUTPUT_DIR}/dcap/ && unzip -o dcap.zip '*.5gm' | grep '.5gm' | awk '{print $2}'
    @{split_output}=    Split String    ${output}    ${\n}
    [Return]    ${split_output}

Setup DCAP
    Log To Console    Starting DCAP
    &{bts}=  Create Dictionary
             ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
             ...  port=443
             ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
             ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}

    @{gnb_custom_profile}=  Create List  cp_5g

    &{trace}=  Create Dictionary
                ...  bts=${bts}
                ...  gnb_custom_profile=${gnb_custom_profile}

    &{utflab}=    Create Dictionary
    ...    host=${UTF_IP}
    ...    port=${UTF_PORT}
    ...    username=${UTF_USERNAME}
    ...    password=${UTF_PASSWORD}

    dcap_collector.Create DCAP Trace Collector
                ...  name=dcap
                ...  dcap=${utflab}
                ...  trace=${trace}
    dcap_collector.Set Suite Alias     dcap

    dcap_collector.Setup Collectors   names=dcap
    dcap_collector.Start Collectors   names=dcap

    Sleep    60

Stop And Gather DCAP
    dcap_collector.Stop Collectors     names=dcap
    dcap_collector.Collect Collectors  names=dcap    target_dir=${OUTPUT_DIR}
