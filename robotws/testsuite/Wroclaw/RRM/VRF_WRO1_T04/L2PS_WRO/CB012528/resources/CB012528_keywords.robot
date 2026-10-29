*** Settings ***
Documentation    :copyright: Nokia

Library    Collections
Library    DateTime
Library    OperatingSystem
Library    String
Library    ta5g_syslog
Library    taf.collectors.core            WITH NAME    tcc
Library    taf.collectors.l2stream3       WITH NAME    tcl
Library    taf.config.scf                 WITH NAME    scf
Library    taf.converters.eventdecoder    WITH NAME    tce
Library    taf.sbts.oam.coam.admin        WITH NAME    admin
Library    ute_admin_infomodel
Library    XML   True
Library    ./CB012528_keywords.py

*** Variables ***
${VLANID}    ${tl.gnbs[0].cu.x2c.vlan_id}

*** Keywords ***
Attach Multiple UEs And Start Traffic
    [Arguments]    ${last_ue}    ${dir}    ${mbps}
    FOR    ${i}    IN RANGE    0    ${last_ue}
        ${pdu_index}    Evaluate    ${i}%${15}+${1}
        ${ue_id}        Evaluate    ${i}+${1}
        Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_index} trf_type=internal
        Sleep    2s
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${ue_id}
        Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_index}    gw_id=1
        Sleep    2s
        Run Keyword If    '${dir}'=='dl'
        ...    Run Keyword And Continue On Failure
        ...    Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} trf_id=1 mbps=${mbps} dir=${dir}
        ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu_index} Qfi:1 TrfId:1
        ...    timeout=5s
        Run Keyword If    '${dir}'=='ul'
        ...    Run Keyword And Continue On Failure
        ...    Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} trf_id=1 mbps=${mbps} dir=${dir}
        ...    pass_regexp=UE${ue_id}: Started Uplink Internal traffic over UDP on Ue:${ue_id} UecId:1 Pdu:${pdu_index} Qfi:1 TrfId:1
        ...    timeout=5s
    END

Attach Multiple UEs And Start Traffic TC CB012528 B C5
    Execute Egate Command    cmd=set_pdu_param ue=101-260 pdu=1 trf_type=internal
    FOR    ${i}    IN RANGE    101    261
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${i}
    END
    ${ue_id}    Set Variable    ${101}
    FOR    ${i}    IN RANGE    1    17
        Log To Console           ue_pdu_session_setup ue=${ue_id}-${ue_id+9} pdu=1 nwslice=1 gw=1
        Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id}-${ue_id+9} pdu=1 nwslice=1 gw=1
        ${ue_id}    Evaluate    ${ue_id}+${10}
        Sleep    2s
    END
    Run Keyword And Continue On Failure
    ...    Execute Egate Command
    ...    cmd=trf_data_start ue=101-260 pdu=1 trf_id=1 mbps=7 dir=dl
    ...    timeout=30s
    Sleep    30s    reason=Wait for throughput stabilization
    Run Keyword And Continue On Failure
    ...    Execute Egate Command
    ...    cmd=trf_data_start ue=101-260 pdu=1 trf_id=1 mbps=7 dir=ul
    ...    timeout=30s
    Sleep    60s    reason=Wait for throughput stabilization

CB012528 Setup
    admin.Setup Admin
    Get SW Release Name And Set As Suite Variable

Change actDynOverloadControl Value
    [Arguments]    ${actDynOverloadControl}
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1
    ...    parameter=actDynOverloadControl
    ...    operation=update
    ...    value=${actDynOverloadControl}
    ...    skip_parameter_relation_errors=True

Check Cell Average Load Ratio
    [Arguments]    ${optimal_ratio_list}    ${overloaded}
    ${optim_ratio_avg}    Evaluate    sum(@{optimal_ratio_list})/len(@{optimal_ratio_list})
    Run Keyword And Continue On Failure    Run Keyword If        ${overloaded}    Should Be True    ${optim_ratio_avg} > 0.25
    Run Keyword And Continue On Failure    Run Keyword If    not ${overloaded}    Should Be True    ${optim_ratio_avg} < 0.25

Check Core Mapping
    [Arguments]    ${cell_amount}
    ${date}    Collect TTI And Convert To CSV
    ${ul_core_mapping_list}    Compare TTI And Syslog Core Mapping    date=${date}    cell_amount=${cell_amount}
    ${dl_core_mapping_list}    Compare TTI And Syslog Core Mapping    date=${date}    direction=dl    cell_amount=${cell_amount}
    Check If Ul And Dl Are On Separate Cores
    ...    ul_core_mapping_list=${ul_core_mapping_list}
    ...    dl_core_mapping_list=${dl_core_mapping_list}
    Check If Ul And Dl Core Pairs Are Even
    ...    ul_core_mapping_list=${ul_core_mapping_list}
    ...    dl_core_mapping_list=${dl_core_mapping_list}

Check DL Overload Control Adjustment
    [Arguments]    ${date}    ${cell_id}    ${overloaded}=${True}
    ${file_name}    Get File Name    date=${date}
    ${optimal_ratio}    Get Optimal Ratio For Cell TTI
    ...    file_name=${file_name}
    ...    physCellId=${cell_id}
    Check Cell Average Load Ratio
    ...    optimal_ratio_list=${optimal_ratio}
#    ...    cell_id=${cell_id}
    ...    overloaded=${overloaded}

Check If L2 Subpool Assignment Is According To New Deployment
    [Arguments]    ${cells_amount}    ${subpool_list}
    ${l2sp_amount}    Evaluate    ${cells_amount}/3
    FOR    ${i}    IN RANGE    3
        ${count}    Get Count    ${subpool_list}    ${i}
        Should Be Equal As Numbers    ${count}    ${l2sp_amount}    precision=1
    END

Check If Selected Cells Are Mapped To The Same L2Subpool
    [Documentation]    Selected cell ids: 50, 54, 57, 59, (may vary in future)
    [Arguments]    ${subpool_dict}
    ${l2sp_id_cell_50}    Get From Dictionary	${subpool_dict}    1
    ${l2sp_id_cell_54}    Get From Dictionary	${subpool_dict}    5
    ${l2sp_id_cell_57}    Get From Dictionary	${subpool_dict}    8
    ${l2sp_id_cell_59}    Get From Dictionary	${subpool_dict}    10
    Should Be True        ${l2sp_id_cell_50}==${l2sp_id_cell_54}==${l2sp_id_cell_57}==${l2sp_id_cell_59}

Check If Ul And Dl Are On Separate Cores
    [Arguments]    ${ul_core_mapping_list}    ${dl_core_mapping_list}
    ${list_len}    Evaluate    len(${ul_core_mapping_list})
    FOR    ${i}    IN RANGE    ${list_len}
        Should Not Be Equal As Numbers    ${ul_core_mapping_list[${i}]}    ${dl_core_mapping_list[${i}]}
    END

Check If Ul And Dl Core Pairs Are Even
    [Arguments]    ${ul_core_mapping_list}    ${dl_core_mapping_list}
    ${set_ul}       Evaluate    len(set(${ul_core_mapping_list}))
    ${set_dl}       Evaluate    len(set(${dl_core_mapping_list}))
    ${set_pairs}    Evaluate    len(set(list(zip(${ul_core_mapping_list}, ${dl_core_mapping_list}))))
    Should Be True    ${set_ul}==${set_dl}==${set_pairs}

Check L2 Subpool Assignment
    [Arguments]    ${cells_amount}    ${deployment}=new
    ${subpool_list}    ${subpool_dict}    Get Assigned L2 Subpool List from Info Model    cells_amount=${cells_amount}
    ${isnewdeployment}    Run Keyword And Return Status
    ...    Check If L2 Subpool Assignment Is According To New Deployment
    ...    cells_amount=${cells_amount}
    ...    subpool_list=${subpool_list}
    Run Keyword If    not ${isnewdeployment}    Should Be Equal    ${deployment}    old
    [Return]    ${subpool_dict}

Compare TTI And Syslog Core Mapping
    [Arguments]    ${date}    ${direction}=ul    ${first_nrCellIdentity}=16385    ${cell_amount}=12
    @{core_mapping_log}     Create List
    @{core_mapping_list}    Create List
    FOR    ${i}    IN RANGE    ${first_nrCellIdentity}    ${first_nrCellIdentity}+${cell_amount}
        ${tti_core_id}    Get Core Id From TTI
        ...    file_name=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output_${date}_${direction}.csv
        ...    nrCellIdentity=${i}
        ...    direction=${direction}
        ${dir}    Set Variable If	'${direction}'=='dl'    Dl    Ul
        ${syslog_core_id}    Get Core ID From Syslog
        ...    nrCellIdentity=${i}
        ...    direction=${dir}
        Should Be Equal    ${syslog_core_id}    ${tti_core_id}
        @{cell_to_core_mapping}=    Create List
        ...    cell_id=${i}
        ...    core_id=${syslog_core_id}
        Append To List    ${core_mapping_log}     ${cell_to_core_mapping}
        Append To List    ${core_mapping_list}    ${syslog_core_id}
    END
    Log To Console    core mapping for ${direction}=${core_mapping_log}
    [Return]   ${core_mapping_list}

Collect TTI And Convert To CSV
    [Arguments]    ${duration}=5    ${conversion_filter}=${None}    ${excel_csv_options}=${None}
    Log To Console    Start TTI trace
    Start TTI trace
    Sleep    ${duration}s    reason=Collecting TTI trace timeout
    Stop TTI trace
    ${date}    Convert TTI Trace From pcap To excelCsv
    ...    conversion_filter=${conversion_filter}
    ...    excel_csv_options=${excel_csv_options}
    [Return]    ${date}

Convert TTI Trace From pcap To excelCsv
    [Arguments]    ${conversion_filter}=${None}    ${excel_csv_options}=${None}
    ${date}    Get Current Date    result_format=%H%M%S
    tce.Create EventDecoder Converter
    ...    name=ttitrace_converter
    ...    input_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...    output_file_format=excelCsv
    ...    output_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output_${date}
    ...    conversion_filter=${conversion_filter}
    ...    excel_csv_options=${excel_csv_options}
    tce.Convert
    ...    name=ttitrace_converter
    [Return]    ${date}

Delta Preparation For TC CB012528
    [Arguments]    ${actual_scf}=scf_B_C1C2_1x20_4DL4UL.xml
    ...            ${target_scf}=scf_B_C1C2_2x20_4DL4UL.xml
    Update SCF File    scf_file_name=${actual_scf}
    Update SCF File    scf_file_name=${target_scf}
    scf.Calculate Delta Scf
    ...    actual_scf_path=${OUTPUT DIR}/updated_${actual_scf}
    ...    target_scf_path=${OUTPUT DIR}/updated_${target_scf}
    ...    delta_scf_path=${OUTPUT DIR}/delta_cell_addition.json

Download Modify And Apply Vendor File
    [Arguments]    ${vendor_file_path}=${OUTPUT DIR}/vendor_file_original.xml
    ...            ${modified_vendor_file_name}=vendor_file_new_deployment.xml
    ...            ${actTwoCoresL2DeploymentFddFr1}=true
    ...            ${maxNumScheUePdschL2Sp}=26
    ...            ${maxNumScheUePuschL2Sp}=22
    admin.Download Vendor File    target_file_name=${vendor_file_path}
    Modify Vendor File Content    file_path=${vendor_file_path}
    ...                           modified_file_name=${modified_vendor_file_name}
    ...                           actTwoCoresL2DeploymentFddFr1=${actTwoCoresL2DeploymentFddFr1}
    ...                           maxNumScheUePdschL2Sp=${maxNumScheUePdschL2Sp}
    ...                           maxNumScheUePuschL2Sp=${maxNumScheUePuschL2Sp}
    admin.Set Vendor File         vendor_file=${OUTPUT DIR}/${modified_vendor_file_name}

Get Assigned L2 Subpool List from Info Model
    [Arguments]    ${cells_amount}
    ${cells_amount}    Convert To Integer    ${cells_amount}
    Setup infomodel    address=192.168.255.129    port=443    use_ssl=True
    Connect Infomodel
    ${connected}    Is Infomodel Connected
    Should Be True    ${connected}    msg=Info model not connected!
    ${l2sp_deploy_dict}        Create Dictionary
    @{l2sp_deployment_list}    Create List
    FOR    ${cell_to_pool_mapping}    IN RANGE    1    ${cells_amount+1}
        ${object_exists}       Check Infomodel Object     dist_name=/MRBTS-1/RAT-1/NRTS-*/CELL_TO_POOL_MAPPING_L-${cell_to_pool_mapping}
        Should Be True         ${object_exists}           msg= CELL_TO_POOL_MAPPING_L-${cell_to_pool_mapping} not found in InfoModel.
        ${infomodel_object}    Get Infomodel Object       dist_name=/MRBTS-1/RAT-1/NRTS-*/CELL_TO_POOL_MAPPING_L-${cell_to_pool_mapping}
        ${cell_id}             Get From Dictionary	      ${infomodel_object}	             cellDN
        ${cell_id}             Fetch From Right 	      ${cell_id} 	                     -
        ${subpool_instance}    Get From Dictionary	      ${infomodel_object.cellSlots[2]}    subpoolInstance
        @{subpool_mapping}     Create List                cell_id=${cell_id}                  l2sp_inst=${subpool_instance}
        Set To Dictionary      ${l2sp_deploy_dict}        ${cell_id}=${subpool_instance}
        Append To List         ${l2sp_deployment_list}    ${subpool_instance}
    END
    Log To Console    \nL2 Subpool mapping {'cell_id': l2sp_id} \n${l2sp_deploy_dict}
    Disconnect Infomodel
    Teardown Infomodel
    [Return]   ${l2sp_deployment_list}    ${l2sp_deploy_dict}

Get Core ID From Syslog
    [Arguments]    ${nrCellIdentity}
    ...            ${direction}=Ul
    ...            ${syslog_filename}=syslog127.0.0.1.log
    ...            ${syslog_path}=${OUTPUT DIR}/${SUITE NAME}
    ${justfordebug}      Run    grep 'L2PsCel${direction}.*Cell.cpp.*${nrCellIdentity}\\>' ${syslog_path}/${syslog_filename}
    ${syslog_core_id}    Run    grep 'L2PsCel${direction}.*Cell.cpp.*${nrCellIdentity}\\>' ${syslog_path}/${syslog_filename} | head -1
    ${syslog_core_id}    Remove String Using Regexp    ${syslog_core_id}    .*Disp_    .<.*
    ${syslog_core_id}    Convert To Integer    ${syslog_core_id}
    [Return]    ${syslog_core_id}

Get File Name
    [Arguments]    ${date}
    ${file_name}    Run    ls ${OUTPUTDIR}/${SUITENAME}/${TESTNAME} | grep output_${date}_dl | head -1
    ${file_name}    Set Variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${file_name}
    [Return]    ${file_name}

Get SW Release Name And Set As Suite Variable
    ${sw_release_name}    admin.Get Sw Release Name
    Set Suite Variable    ${SW_RELEASE_NAME}    ${sw_release_name}

Lock And Unlock NG link
    [Arguments]    ${dist_name}=MRBTS-1/NRBTS-1/SERVEDAMF-1
    admin.Setup Admin     name=ng
    admin.Lock Ng Link    dist_name=${dist_name}    connection=ng
    admin.Assert Alarm Active      parameters=faultId=7107    timeout=30    connection=ng
    admin.Unlock Ng Link           dist_name=${dist_name}    connection=ng
    admin.Assert Alarm Inactive    parameters=faultId=7107    timeout=30    connection=ng
    admin.Teardown Admin           connection=ng

Start Traffic For Multiple UEs
    [Arguments]    ${last_ue}    ${dir}    ${mbps}
    FOR    ${i}    IN RANGE    0    ${last_ue}
        ${pdu_index}    Evaluate    ${i}%${15}+${1}
        ${ue_id}        Evaluate    ${i}+${1}
        Run Keyword If    '${dir}'=='dl'
        ...    Run Keyword And Continue On Failure
        ...    Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} trf_id=1 mbps=${mbps} dir=${dir}
        ...    pass_regexp=Started Downlink Internal traffic over UDP on Ue:${ue_id}
        ...    timeout=5s
        Run Keyword If    '${dir}'=='ul'
        ...    Run Keyword And Continue On Failure
        ...    Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_index} trf_id=1 mbps=${mbps} dir=${dir}
        ...    pass_regexp=Started Uplink Internal traffic over UDP on Ue:${ue_id}
        ...    timeout=5s
    END

Start TTI trace
    ${configurations}    tcc.Load Configurations    ${CURDIR}/ttitrace_collectors.yaml
    tcc.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias      alias=l2stream3
    tcc.Setup Collectors     names=l2stream3
    tcc.Start Collectors     names=l2stream3

Stop Traffic For Multiple UEs
    [Arguments]    ${last_ue}
    FOR    ${i}    IN RANGE    0    ${last_ue}
        ${pdu_index}    Evaluate    ${i}%${15}+${1}
        ${ue_id}        Evaluate    ${i}+${1}
        Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_index}
    END

Stop TTI trace
    tcc.Stop Collectors        names=l2stream3
    tcc.Collect Collectors     names=l2stream3
    tcc.Teardown Collectors    names=l2stream3

Update SCF And Perform Commissioning
    [Arguments]    ${scf_file_name}
    Update SCF File    scf_file_name=${scf_file_name}
    admin.Perform Commissioning    scf_file=${OUTPUT DIR}/updated_${scf_file_name}

Update SCF File
    [Arguments]    ${scf_file_name}    ${sw_release_name}=${SW_RELEASE_NAME}
    admin.Migrate Scf
    ...    input_scf_file=${CURDIR}/../config/${sw_release_name}/${scf_file_name}
    ...    output_scf_file=${OUTPUT DIR}/updated_${scf_file_name}
    Update Scf Vlanid
    ...    file_path=${OUTPUT DIR}/updated_${scf_file_name}
    ...    vlanId=${VLANID}

Verify Avg Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}    ${accuracy}=99
    ${avg_tput}    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0-1   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}*0.${accuracy}

Verify Avg Tput For Multiple UEs
    [Arguments]    ${last_ue}    ${dir}    ${expected_tput}    ${first_ue}=0
    FOR    ${i}    IN RANGE    ${first_ue}    ${last_ue}
        ${ue_id}    Evaluate    ${i}+${1}
        Run Keyword And Continue On Failure    Verify Avg Tput For UE SA
        ...    ue_id=${ue_id}
        ...    dir=${dir}
        ...    expected_tput=${expected_tput}
    END
