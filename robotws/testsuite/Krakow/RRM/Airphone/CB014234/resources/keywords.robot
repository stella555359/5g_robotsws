*** Settings ***
Documentation
...            author:     Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...            maintainer:     Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...


Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/resources/former_l3_sw2/main_cls.robot
Library     resources_lib.py
Library     Collections
Library     OperatingSystem
Library     ta5g_pm_counters
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.core    WITH NAME    core
Library    taf.transport.ssh    WITH NAME    ssh
Library    String
Library    ute_wtssim
Library    ute_syslog



*** Keywords ***
Set the number of UE SCell allocations for NRCELL-${cell_id} to ${number_of_ues}
    [Documentation]     Updates the number of possible SCell allocations for a cell
    ...                - ``cell_id``: Cell ID of the candidate SCell
    ...                - ``number_of_ues``: Number of UEs accepted by the cell to be part of CA
    ...
    Should Be True    type(${cell_id}) is int    msg=Invalid KW parameter: cell_id is not int type
    Should Be True    type(${number_of_ues}) is int    msg=Invalid KW parameter: number_of_ues is not int type
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-${cell_id}    param=maxNumOfSCellAlloc
    ...      value=${number_of_ues}


Set indexes and Feature Set Entry Index of Initial allowedBC-ListMRDC configured during SgNB Addition
    [Documentation]      Configure the initial band combination indexes and feature set entry index
    ...                  that shall be used, or configured after SgNB Addition.
    ...                - ``allowed_bc_list``: BC and FSEI pair to be included in SgNB Addition Request
    ...                - ``ue_id``: ID of attached UE, default=None
    ...                - ``params``: Additional parameters for ue_enb_endc_param,
    ...                    e.g. menb_ue_x2ap_id_extension = on | off
    ...                    e.g. menb_ue_x2ap_id_extension = on | off
    ...                 Example:
    ...       | Set indexes and Feature Set Entry Index of Initial allowedBC-ListMRDC configured during SgNB Addition
    ...       | allowed_bc_list=1:1,2|2:2,3 | ue_id=10 |
    ...
    [Arguments]          ${allowed_bc_list}=${None}      ${ue_id}=${None}     &{params}
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id is not int type
    ${cmd}        Set Variable        ue_enb_endc_param id=${ue_id} allowed_bc_list_mrdc=${allowed_bc_list}
    ${log_msg}    Set Variable        Updating SgNB Addition Request message by adding content to allowedBC-ListMRDC
    Execute Egate Command Ext   cmd=${cmd}    log_msg=${log_msg}    &{params}


Set lowBound to ${low_bound} and upBound to ${up_bound} in servCellIndexRangeSCG during SgNB Addition phase for UE-${ue_id}
    [Documentation]    Configure the lowBound and upBound values in configRestrictInfo.servCellIndexRangeSCG.lowBound
    ...                and configRestrictInfo.servCellIndexRangeSCG.upBound in SgNBAdditionRequest message
    ...                - ``low_bound``: This field defines the starting index for the range of ServCellIndex values
    ...                                 that the SgNB can assign.
    ...                - ``up_bound``: This field defines the ending index for the range of ServCellIndex values
    ...
    Should Be True    type(${up_bound}) is int     msg=Invalid KW parameter: up_bound is not int type
    Should Be True    type(${low_bound}) is int    msg=Invalid KW parameter: low_bound is not int type
    ${cmd}        Set Variable    ue_enb_endc_param id=${ue_id} serving_cell_index_range_scg=${low_bound}:${up_bound}
    ${log_msg}    Set Variable    Configuring SCG lowbound and upbound for ue in SgNBAdditionRequest from MeNB
    Execute Egate Command Ext   cmd=${cmd}    log_msg=${log_msg}


Include NR and EUTRA-NR ue-CapabilityInfo Information Element in the SgNBModificationRequest message for UE
   [Documentation]    MeNB shall include ue-CapabilityInfo IE in the SgNBAdditionRequest message
    ...                - ``ue_id``: ID of attached UE, default=None
    ...                - ``nr_ue_capability``: Capability Hex string or ue capability variable name in file
    ...                - ``eutra_nr_ue_capability``: Capability Hex string or ue capability variable name in file
    ...                - ``ue_capability_file_path``: File where ue capabilities are defined
    ...
    [Arguments]      ${ue_id}=11     ${nr_ue_capability}=${None}    ${eutra_nr_ue_capability}=${None}
    ...              ${ue_capability_file_path}=/opt/wts/latest/basic_setup.cfg       &{params}
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id is not int type
    ${cmd_1}        Catenate    ue_sgnb_mod_addl_param id=${ue_id} include_ue_capabilities=on
    ...             ue_nr_capabilities=${nr_ue_capability} ue_eutra_nr_capabilities=${eutra_nr_ue_capability}
    ...             ue_capability_file=${ue_capability_file_path}
    ${log_msg}    Set Variable    Include ue-CapabilityInfo IE in SgNB Modification Request
    Execute Egate Command Ext   cmd=${cmd_1}    log_msg=${log_msg}    &{params}


Include measGapConfig Information Element in the SgNBModificationRequest message for UE-${ue_id}
    [Documentation]    MeNB shall include in SgNB Modification Request message, the measGapConfig IE.
    ...                AllowedBC-ListMRDC must be disabled when sending measGapConfig IE
    ...                - ``ue_id``: ID of attached UE, default=None
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id is not int type
    ${cmd_1}     Set Variable    ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=enb_and_gnb_triggered
    ${log_msg}    Set Variable    Include measGapConfig Information Element in the SgNBModificationRequest message for UE-${ue_id}
    Execute Egate Command Ext   cmd=${cmd_1}    log_msg=${log_msg}


Set BC and FSEI indexes in allowedBC-ListMRDC configured during SgNB Modification Request
    [Documentation]      Configure the SgNB modification request band combination indexes and feature set entry index
    ...                  that shall be used, or configured in SgNBModificationRequest.
    ...                - ``allowed_bc_list``: BC and FSEI pair to be included in SgNB Addition Request
    ...                - ``ue_id``: ID of attached UE, default=None
    ...                - ``params``: Additional parameters for ue_enb_endc_param,
    ...                    e.g. menb_ue_x2ap_id_extension = on | off
    ...                    e.g. menb_ue_x2ap_id_extension = on | off
    ...
    [Arguments]      ${ue_id}=${None}    ${allowed_bc_list}=${None}      &{params}
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id is not int type
    ${cmd}        Catenate    ue_sgnb_mod_param id=${ue_id} allowed_bc_list_mrdc=${allowed_bc_list} exclude_plmn=yes
    ...                       exclude_sgnb_security_key=yes
    ${log_msg}    Set Variable    Updating SgNB Modification Request message by adding content to allowedBC-ListMRDC
    Execute Egate Command Ext   cmd=${cmd}    log_msg=${log_msg}     &{params}

Trigger SgNB Modification Request message from MeNB
    [Documentation]      Trigger the SgNB Modification Request message
    ...
    ...                - ``ue_id``: ID of attached UE, default=None
    ...                - ``by``: Source of the request
    ...                - ``cause``: Cause to be included in the modification request
    [Arguments]      ${ue_id}=${None}     ${by}=enb   ${cause}=RN_count_reaches_max_value
    Should Be True    type(${ue_id}) is int       msg=Invalid KW parameter: ue_id is not int type
    Should Be True    '${by}' in ('enb','gnb')    msg=Invalid KW parameter: by is not enb or gnb
    Log to console     Trigger SgNB Modification Request message from MeNB
    ${cmd}        Set Variable    enb_ue_dc_modify ue=${ue_id} by=${by} cause=${cause}
    ${log_msg}    Set Variable    Sending SgNB Modification Request from MeNB
    Execute Egate Command Ext    cmd=${cmd}    log_msg=${log_msg}    pass_regexp=Sending SgNB Modification Request


Reset MeNB parameters for SgNBModification
    [Arguments]     ${ue_id}
    Log to console      Reset MeNB parameters for SgNBModification
    ${cmd}        Set Variable    ue_sgnb_mod_param id=${ue_id} reset
    ${cmd_2}      Set Variable    enb_endc_param id=${ue_id} reset
    ${cmd_3}      Set Variable    ue_enb_endc_param id=${ue_id} reset
    Execute Egate Command Ext    cmd=${cmd}
    Execute Egate Command Ext    cmd=${cmd_2}
    Execute Egate Command Ext    cmd=${cmd_3}


Modify the maxNumOfSCellAlloc parameter for all 8 Cells setting it to ${value}
    Set the number of UE SCell allocations for NRCELL-1 to ${value}
    Set the number of UE SCell allocations for NRCELL-2 to ${value}
    Set the number of UE SCell allocations for NRCELL-3 to ${value}
    Set the number of UE SCell allocations for NRCELL-4 to ${value}
    Set the number of UE SCell allocations for NRCELL-5 to ${value}
    Set the number of UE SCell allocations for NRCELL-6 to ${value}
    Set the number of UE SCell allocations for NRCELL-7 to ${value}
    Set the number of UE SCell allocations for NRCELL-8 to ${value}

# ------------------------------------------------ Verificators -------------------------------------------------------
Verify that the SgNBModRequestReject was sent for UE
    [Arguments]      ${json_filepath}     ${exp_nr}
    ${json_string}    Get File        ${json_filepath}
    ${data_dict}      Evaluate        json.loads('''${json_string}''')    json
    ${cause_dict}    find_root_information_element
    ...     data=${data_dict}
    ...     info_element=x2ap.Cause_tree
    ${error_nr}     Get from dictionary
    ...     ${cause_dict}
    ...     x2ap.protocol
    Should be equal     ${error_nr}     ${exp_nr}
    ...    msg=The error cause is not equal to expected one


Get the Mirror Interface
    [Documentation]     To Get the interface on which AP mirroring is done and where tcpdump needs to be captured.
    ssh.Connect To        ${AP.Ip}    ${AP.Username}    ${AP.Password}    alias=${AP.Connection}
    ssh.Execute           mkdir -p /ffs/run/config/scripts/    ${AP}[Connection]
    Run And Return Rc And Output    scp ${shell_script} 192.168.200.1:/ffs/run/config/scripts/
    ssh.Execute           chmod +x /ffs/run/config/scripts/airphone_mirror.sh    ${AP}[Connection]
    ssh.Execute           cd /ffs/run/config/scripts && ./airphone_mirror.sh    ${AP}[Connection]
    ${str_out}     SSH.Execute    ps -aux | grep [C]CSPacketCapture    ${AP}[Connection]
    ssh.Execute           cd /ffs/run/config/scripts && ./airphone_mirror.sh --stop    ${AP}[Connection]
    ${interface}    Get Regexp Matches    ${str_out}    -i${SPACE}(.*)${SPACE}-w    1
    [Return]    ${interface}[0]
    [Teardown]    ssh.Disconnect        ${AP.Connection}


