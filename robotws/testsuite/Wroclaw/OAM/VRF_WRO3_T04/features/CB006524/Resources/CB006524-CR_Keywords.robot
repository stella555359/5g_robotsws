*** Settings ***
Documentation
...  author:     Patryk Tatarek
...  contact:    patryk.tatarek@nokia.com

*** Keywords ***
Restore vCUs states before test case
    ${conn_prim}=     Connect to ADMIN    hw_type=vCU
    ${vcu_1_vnf}=     vcu_admin.get_cu_vnf    connection=${conn_prim}
    Run Keyword If    "${vcu_1_vnf["activity_mode"]}"=="standby"
    ...               Switchover vCU from Standby to Active mode    connection=${conn_prim}
    Run Keyword If    "${vcu_1_vnf["activity_mode"]}"=="standby"    Sleep    120s    reason=Wait after switchover
    Wait Until Keyword Succeeds    10min    10s    Check if Unit Status is OnAir    hw_type=vDU
    [Teardown]        Disconnect from ADMIN    connection=${conn_prim}     hw_type=vCU

Remove redundancy parameters from vCU-1
    @{delta}=             Create List
    @{delta}=             _Add change in single object to Delta    param_name=redundancyRole
    ...                   param_value=standalone    param_operation=update    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=peerVnf
    ...                   param_operation=delete    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=peerVnfIpAddress
    ...                   param_operation=delete    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=georedundancyType
    ...                   param_operation=delete    delta=${delta}
    &{change_dict}=       Create Dictionary    distName=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
    ...                   operation=update    parameters=@{delta}
	@{delta_list}=        Create List    ${change_dict}
	${delta_json}=        Evaluate    json.dumps(${delta_list})    json
	${conn_prim_temp}=    Connect to ADMIN    hw_type=vCU
	vcu_admin.perform_delta_recommissioning    delta_file=${delta_json}    connection=${conn_prim_temp}
	Sleep    30s          reason=Wait after removing redundancy parameters
	[Teardown]            Disconnect from ADMIN    connection=${conn_prim_temp}    hw_type=vCU

Remove redundancy parameters from vCU-2
    @{delta}=             Create List
    @{delta}=             _Add change in single object to Delta    param_name=redundancyRole
    ...                   param_value=standalone    param_operation=update    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=peerVnf
    ...                   param_operation=delete    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=peerVnfIpAddress
    ...                   param_operation=delete    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=georedundancyType
    ...                   param_operation=delete    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=georedundancySecondaryCnfGroup
    ...                   param_operation=delete    delta=${delta}
    &{change_dict}=       Create Dictionary    distName=MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ...                   operation=update    parameters=@{delta}
	@{delta_list}=        Create List    ${change_dict}
	${delta_json}=        Evaluate    json.dumps(${delta_list})    json
	${conn_sec_temp}=     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                   custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
	vcu_admin.perform_delta_recommissioning    delta_file=${delta_json}    connection=${conn_sec_temp}
	Sleep    30s          reason=Wait after removing redundancy parameters
	[Teardown]            Disconnect from ADMIN    connection=${conn_sec_temp}    hw_type=vCU

Remove redundancy parameters from vDU
    Delete Parameter on BTS    dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRDU-${MRBTS}
    ...                        param_name=remotef1CplaneIpAddr2    hw_type=vDU

Restore redundancy parameters for vCU-1
    [Arguments]    ${restored_id}    ${restored_addr}
    ${dn}=    Create List      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
    ...                        MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
    ...                        MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
    ...                        MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
    ${pn}=    Create List      redundancyRole    peerVnf    peerVnfIpAddress    georedundancyType
    ${pv}=    Create List      primary    ${restored_id}    ${restored_addr}    ${n_plus_one}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU

Restore redundancy parameters for vCU-2
    [Arguments]    ${restored_id}    ${restored_addr}
    ${dn}=    Create List      MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ...                        MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ...                        MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ...                        MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ...                        MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ${pn}=    Create List      redundancyRole    peerVnf    peerVnfIpAddress
    ...                        georedundancyType    georedundancySecondaryCnfGroup
    ${pv}=    Create List      secondary    ${restored_id}    ${restored_addr}    ${n_plus_one}    ${1}
    ${conn_sec_temp}=     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                   custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU    pre-connection=${conn_sec_temp}
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec_temp}    hw_type=vCU

Restore redundancy parameters for vDU
    [Arguments]    ${sec_F1C_addr}
    Add Parameter on BTS    dist_name=MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRDU-${MRBTS}    param_name=remotef1CplaneIpAddr2
    ...                     param_value=${sec_F1C_addr}    hw_type=vDU

Check if vCUs are in the right mode
    ${conn_prim}=                 Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                  Wait Until Keyword Succeeds     5x    10s
    ...                           Connect to ADMIN    custom_LMP_addr=${sec_cu_addr}
    ...                           alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                 vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                 vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings    ${vcu_1_vnf["activity_mode"]}      active
    Should be Equal As Strings    ${vcu_1_vnf["redundancy_role"]}    primary
    Should be Equal As Strings    ${vcu_2_vnf["activity_mode"]}      standby
    Should be Equal As Strings    ${vcu_2_vnf["redundancy_role"]}    secondary
    [Teardown]    Run Keywords    Disconnect from ADMIN    connection=${conn_prim}     hw_type=vCU
    ...    AND                    Disconnect from ADMIN    connection=${conn_sec}      hw_type=vCU

Check if vCUs are in the standalone mode
    ${conn_prim}=                 Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
    ${conn_sec}=                  Wait Until Keyword Succeeds     5x    10s
    ...                           Connect to ADMIN    custom_LMP_addr=${sec_cu_addr}
    ...                           alias=admin_sec    hw_type=vCU
    ${vcu_1_vnf}=                 vcu_admin.get_cu_vnf    connection=${conn_prim}
    ${vcu_2_vnf}=                 vcu_admin.get_cu_vnf    connection=${conn_sec}
    Should be Equal As Strings    ${vcu_1_vnf["activity_mode"]}      active
    Should be Equal As Strings    ${vcu_1_vnf["redundancy_role"]}    standalone
    Should be Equal As Strings    ${vcu_2_vnf["activity_mode"]}      standby
    Should be Equal As Strings    ${vcu_2_vnf["redundancy_role"]}    standalone
    [Teardown]    Run Keywords    Disconnect from ADMIN    connection=${conn_prim}     hw_type=vCU
    ...    AND                    Disconnect from ADMIN    connection=${conn_sec}      hw_type=vCU

Check if vDU is in the right state
    [Arguments]    ${exp_state}
    Wait Until Keyword Succeeds    15min    30s    Check if Unit Status is OnAir    hw_type=vDU
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${data}=         vdu_admin.get_vdu_state_data    vdu_connection=${temp_conn}
    Should be Equal As Strings    ${data["f1_c_link_status_du"]}    ${exp_state}
    [Teardown]       Disconnect from ADMIN    connection=${temp_conn}      hw_type=vDU

Change georedundancy type to N+1 on vCU-1
    ${conn_prim}=    Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN    hw_type=vCU
#    ${dn_prim}=      Create List     MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
#    ${pn}=           Create List     georedundancySecondaryCnfGroup    georedundancyType
#    ${pv_one}=       Create List     ${1}    ${n_plus_one}
#    Change Multiple Parameters on BTS    ${dn_prim}    ${pn}    ${pv_one}    hw_type=vCU    pre-connection=${conn_prim}
    Change Parameter On BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
    ...                        param_name=georedundancyType    param_value=${n_plus_one}
    ...                        hw_type=vCU    pre-connection=${conn_prim}
    [Teardown]       Disconnect from ADMIN    connection=${conn_prim}     hw_type=vCU

Change georedundancy type to N+1 on vCU-2
    ${conn_sec}=    Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...             custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
    ${dn_sec}=      Create List      MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1    MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ${pn}=          Create List     georedundancySecondaryCnfGroup    georedundancyType
    ${pv_one}=      Create List     ${1}    ${n_plus_one}
    Change Multiple Parameters on BTS    ${dn_sec}    ${pn}    ${pv_one}    hw_type=vCU    pre-connection=${conn_sec}
    [Teardown]      Disconnect from ADMIN          connection=${conn_sec}      hw_type=vCU

Change georedundancy type to 1+1 on vCU-1
    @{delta}=             Create List
    @{delta}=             _Add change in single object to Delta    param_name=georedundancyType
    ...                   param_value=${one_plus_one}    param_operation=update    delta=${delta}
#    @{delta}=             _Add delete change in single object to Delta    param_name=georedundancySecondaryCnfGroup
#    ...                   param_operation=delete    delta=${delta}
    &{change_dict}=       Create Dictionary    distName=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1
    ...                   operation=update    parameters=@{delta}
	@{delta_list}=        Create List    ${change_dict}
	${delta_json}=        Evaluate    json.dumps(${delta_list})    json
	${conn_prim_temp}=    Connect to ADMIN    hw_type=vCU
	vcu_admin.perform_delta_recommissioning    delta_file=${delta_json}    connection=${conn_prim_temp}
	[Teardown]            Disconnect from ADMIN    connection=${conn_prim_temp}    hw_type=vCU

Change georedundancy type to 1+1 on vCU-2
    @{delta}=             Create List
    @{delta}=             _Add change in single object to Delta    param_name=georedundancyType
    ...                   param_value=${one_plus_one}    param_operation=update    delta=${delta}
    @{delta}=             _Add delete change in single object to Delta    param_name=georedundancySecondaryCnfGroup
    ...                   param_operation=delete    delta=${delta}
    &{change_dict}=       Create Dictionary    distName=MRBTS-${sec_cu_mrbts}/MNL-1/MNLENT-1
    ...                   operation=update    parameters=@{delta}
	@{delta_list}=        Create List    ${change_dict}
	${delta_json}=        Evaluate    json.dumps(${delta_list})    json
	${conn_sec_temp}=     Wait Until Keyword Succeeds     5x    10s    Connect to ADMIN
    ...                   custom_LMP_addr=${sec_cu_addr}    alias=admin_sec    hw_type=vCU
	vcu_admin.perform_delta_recommissioning    delta_file=${delta_json}    connection=${conn_sec_temp}
	[Teardown]            Disconnect from ADMIN    connection=${conn_sec_temp}    hw_type=vCU

Check if CNF is in right state
    [Arguments]       ${action}    ${status}    ${phase}
    ${cnf}=           SSHLibrary.Execute Command    ${rancnf_command}
    Should Contain    ${cnf}    ${action}
    Should Contain    ${cnf}    ${status}
    Should Contain    ${cnf}    ${phase}

Check if vCU-2 is pingable
    [Arguments]    ${ip}=${sec_cu_addr}
    ${output}=    Run    ping -c 3 -W 10 ${ip}
    Should contain    ${output}    3 packets transmitted, 3 received

Check if vCU-2 is not pingable
    [Arguments]    ${ip}=${sec_cu_addr}
    ${output}=    Run    ping -c 3 -W 10 ${ip}
    Should contain    ${output}    3 packets transmitted, 0 received
