*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Library    Collections
Library    OperatingSystem
Library    String
Library    taf.collectors.dcap            WITH NAME    dcap
Library    taf.sbts.oam.coam.admin        WITH NAME    admin
Library    ute_admin_infomodel
Library    ./CNI120418_keywords.py

*** Variables ***
${VLANID}    ${tl.gnbs[0].cu.x2c.vlan_id}

*** Keywords ***
Attach Multiple UEs And Start Traffic
    [Arguments]    ${first_ue}    ${last_ue}    ${dir}    ${mbps}
    FOR    ${i}    IN RANGE    ${first_ue}    ${last_ue}
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${i}
        Sleep    2s
        Establish Pdu Session    ue_id=${i}    pdu_id=1    gw_id=1
        Sleep    2s
        Execute Egate Command
        ...    cmd=trf_data_start ue=${i} pdu=1 trf_id=1 mbps=${mbps} dir=${dir}
        ...    timeout=5s
    END
    Sleep    20s    reason=Wait for throughput stabilization

Check If All Cells Are Mapped To The Same L2 Pool
    [Arguments]    ${cells_amount}    ${subpool_list}
    ${the_same_pool_ids}    Count Values In List	${subpool_list}    ${subpool_list[0]}
    Should Be Equal As Integers    ${the_same_pool_ids}    ${cells_amount}

Check If l2RTPool has recovered from overload state
    [Arguments]    ${syslog_filename}=syslog127.0.0.1.log
    ...            ${syslog_path}=${OUTPUT DIR}/CNI120418_B1B2/${TEST NAME}
    ${syslog_last_ovl_state}    Get Last Overload State For l2RTPool
    ...    syslog_filename=${syslog_filename}
    ...    syslog_path=${syslog_path}
    Should Contain    ${syslog_last_ovl_state}    has recovered from overload state
    ${ovl_state}      Fetch From Right    ${syslog_last_ovl_state}    OverloadProtectionHandler
    Log To Console    ${ovl_state}
    [Return]    ${syslog_last_ovl_state}

Check L2 Pool Assignment
    [Arguments]    ${cells_amount}
    ${subpool_list}    Get L2 Pool Mapping List from Info Model    cells_amount=${cells_amount}
    Check If All Cells Are Mapped To The Same L2 Pool    cells_amount=${cells_amount}    subpool_list=${subpool_list}

Check PM And RD Counters For CNI120418 B2 Scenario
    ${rd_counter_file}    Get Next Unpacked Raw Rd Counters File
    ${pm_counter_file}    Get Latest Unpacked Raw Pm Counters File
    FOR    ${i}    IN RANGE    1    4
        Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55166C00020
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${i}
        ...    filepath=${pm_counter_file}
        Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55166C00021
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${i}
        ...    filepath=${pm_counter_file}
        Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55124C00023
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${i}
        ...    filepath=${pm_counter_file}
        Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55166C00019
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${i}
        ...    filepath=${pm_counter_file}
        Verify If Latest RD Counter Has Exact Value
        ...    counter_id=RRC_NEME_FAIL_SIG_OVLDU_UP
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${i}
        ...    filepath=${rd_counter_file}
    END

Check There Were No More Overload State Triggered
    [Arguments]    ${ovl_state_timestamp}
    ${syslog_last_ovl_state}    Get Last Overload State For l2RTPool
    Should Be Equal As Strings   ${syslog_last_ovl_state}    ${ovl_state_timestamp}

CNI120418 Setup
    admin.Setup Admin
    Get SW Release Name And Set As Suite Variable
    Run    DCAP_Basic_controller start

Get Last Overload State For l2RTPool
    [Arguments]    ${syslog_filename}=syslog127.0.0.1.log
    ...            ${syslog_path}=${OUTPUT DIR}/CNI120418_B1B2/${TEST NAME}
    ${justfordebug}             Run    grep OverloadProtectionHandler ${syslog_path}/${syslog_filename}
    ${syslog_last_ovl_state}    Run    grep 'OverloadProtectionHandler.*l2RTPoolId' ${syslog_path}/${syslog_filename} | tail -1
    [Return]    ${syslog_last_ovl_state}

Get L2 Pool Mapping List from Info Model
    [Arguments]    ${cells_amount}
    ${cells_amount}    Convert To Integer    ${cells_amount}
    Setup infomodel    address=192.168.255.129    port=443    use_ssl=True
    Connect Infomodel
    ${connected}    Is Infomodel Connected
    Should Be True    ${connected}    msg=Info model not connected!
    ${l2pool_deploy_dict}        Create Dictionary
    @{l2pool_deploy_list}    Create List
    FOR    ${cell_to_pool_mapping}    IN RANGE    1    ${cells_amount+1}
        ${object_exists}       Check Infomodel Object
        ...    dist_name=/MRBTS-1/RAT-1/NRTS-*/CELL_TO_POOL_MAPPING_L-${cell_to_pool_mapping}
        Should Be True         ${object_exists}
        ...    msg= CELL_TO_POOL_MAPPING_L-${cell_to_pool_mapping} not found in InfoModel.
        ${infomodel_object}    Get Infomodel Object
        ...    dist_name=/MRBTS-1/RAT-1/NRTS-*/CELL_TO_POOL_MAPPING_L-${cell_to_pool_mapping}
        ${cell_id}             Get From Dictionary     ${infomodel_object}	                cellDN
        ${cell_id}             Fetch From Right 	    ${cell_id} 	                        -
        ${l2pool}              Get From Dictionary	    ${infomodel_object.cellSlots[2]}    poolDN
        ${l2pool}              Fetch From Right 	    ${l2pool} 	                        -
        Set To Dictionary      ${l2pool_deploy_dict}    ${cell_id}=${l2pool}
        Append To List         ${l2pool_deploy_list}    ${l2pool}
    END
    Log To Console    \nL2_RT pool mapping: \n{'cell_id': l2rt_pool_id} \n${l2pool_deploy_dict}
    Disconnect Infomodel
    Teardown Infomodel
    [Return]   ${l2pool_deploy_list}

Get SW Release Name And Set As Suite Variable
    ${sw_release_name}    admin.Get Sw Release Name
    Set Suite Variable    ${SW_RELEASE_NAME}    ${sw_release_name}

Move UEs to RRC CONNECTED State Using RRCResumeRequest1
    Wait Until Keyword Succeeds     4x     15s     Verify Ue State    ue_id=101    expected_state=ue_inactive
    Wait Until Keyword Succeeds     2x     15s     Verify Ue State    ue_id=102    expected_state=ue_inactive
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=101 gnb=2 cell=1 msg=resume_request_1
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=102 gnb=2 cell=1 msg=resume_request_1 cause=mo_Signalling
    Execute Egate Command    cmd=ue_nr_rrc_resume id=101
    ...                      pass_regexp=UE101: UE performed resume procedure
    ...                      timeout=10
    Execute Egate Command    cmd=ue_nr_rrc_resume id=102
    ...                      pass_regexp=UE102: UE performed resume procedure
    ...                      timeout=10
    Wait Until Keyword Succeeds     4x     15s     Verify Ue State    ue_id=101    expected_state=active
    Wait Until Keyword Succeeds     2x     15s     Verify Ue State    ue_id=102    expected_state=active

Setup UEs
    Execute Egate Command    cmd=set_pdu_param ue=101-280 pdu=1 trf_type=internal
    Attach Ue    ue_id=101
    Attach Ue    ue_id=102
    FOR    ${i}    IN RANGE    103    271
        Wait Until Keyword Succeeds    30s   5s    Attach Ue    ue_id=${i}
    END
    ${ue_id}    Set Variable    ${101}
    FOR    ${i}    IN RANGE    1    11
        Log To Console           ue_pdu_session_setup ue=${ue_id}-${ue_id+16} pdu=1 nwslice=1 gw=1
        Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id}-${ue_id+16} pdu=1 nwslice=1 gw=1
        ${ue_id}    Evaluate    ${ue_id}+${17}
        Sleep    2s
    END

Start Dcap And Syslog Collection
    Start Dcap Logs Collection
    Start Syslog For Enb    log_filename_prefix=syslog    alias=mandatory_log

Start Dcap Logs Collection
    &{bts}    Create Dictionary
    ...    host=10.0.1.2
    ...    port=443
    ...    username=Nemuadmin
    ...    password=nemuuser
    @{gnb_custom_profile}    Create List    cp_5g
    &{trace}    Create Dictionary
    ...    bts=${bts}
    ...    gnb_custom_profile=${gnb_custom_profile}
    Create DCAP Trace Collector
    ...    name=dcap
    ...    trace=${trace}
    dcap.Setup Collectors    names=dcap
    dcap.Start Collectors    names=dcap
    dcap.set_suite_alias     alias=dcap

Stop Dcap Logs Collection
    dcap.Stop_collectors       names=dcap
    dcap.Collect Collectors    names=dcap
    [Teardown]   dcap.Teardown Collectors  names=dcap

Start Traffic For Multiple UEs
    [Arguments]    ${first_UE}    ${last_ue}    ${dir}    ${mbps}
        Execute Egate Command
        ...    cmd=trf_data_start ue=${first_UE}-${last_ue} pdu=1 trf_id=1 mbps=${mbps} dir=${dir}
    Sleep    30s    reason=Wait for throughput stabilization

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
