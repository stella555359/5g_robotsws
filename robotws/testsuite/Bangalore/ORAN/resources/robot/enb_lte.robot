*** Settings ***
Documentation		The basic operattion for WMP lte.
...			author: Xing Jing
...			contact: jing.1.xing@nokia-sbell.com
...			in case of changes please contact author,
...			do not modify without permission
...                     Modified : 19-02-2019
...                     Modified By: Xing jing

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.gnb.oam.coam.admin   WITH NAME    enblte
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info


*** Variables ***
@{pdu_enb_port}
@{GNB_PS_CELL_INDEX_LIST}    1

*** Keywords ***
Connect to eNB via ssl
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${enb_index}=${0}
    enblte.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}

Modify the parameter on enblte
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte

Check the enb cell onAir
    Connect to eNB via ssl
	${enbcell_status}=    Get the cell status from btsinfo    'cells.lte.0.status.availabilityStatus'
	should be equal    ${enbcell_status}    Online

Get the cell status from btsinfo
    [Arguments]    ${filter}
	${output} =    enblte.get_bts_info    connection=enblte
	enblte.teardown    connection=enblte
    @{list} =    Evaluate    ${filter}.split('.')
    ${output_VALUE} =   get from dictionary    ${output}    @{list}[0]
    ${output_VALUE_1} =   get from dictionary    ${output_VALUE}    @{list}[1]
    ${output_VALUE_2} =   get from dictionary    ${output_VALUE_1}    @{list}[2]
    ${output_VALUE_3} =   get from list   ${output_VALUE_2}     @{list}[3]
    ${output_VALUE_4} =   get from dictionary    ${output_VALUE_3}    @{list}[4]
    ${enbcell_status} =   get from dictionary    ${output_VALUE_4}    @{list}[5]
	[Return]    ${enbcell_status}

Enblte close down
    [Arguments]    ${connection}=enblte
    enblte.teardown    connection=${connection}

Connect and Modify the parameter on enblte
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte    ${dist_name}     ${parameter}    ${value}
    enblte.teardown    connection=enblte

Powerreset eNB BTS
    pdu.setup_pdu       host=${tl.enbs[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...    model=facom        alias=BTS_PDU
    pdu.reset_ports     ports=${pdu_enb_port}
    ...    time_interval= 5     pdu_device=BTS_PDU

Connect to eNB
    [Arguments]    ${alias}=ENB    ${enb_index}=${0}
    csn.Connect to    hostname=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.password}    alias=${alias}

Start to collect the X2 log on eNB
    [Arguments]     ${port}=br1     ${x2_log_name}=x2_log_eNB.pcap
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    csn.send command    command=tcpdump -i ${port} -w /tmp/${x2_log_name}   connection=ENB

Stop and download X2 Logs on eNB
    [Arguments]     ${x2_log_name}=x2_log_eNB.pcap    ${log_path}=${LOG_PATH}
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    sleep    30
    csn.send command    command=killall tcpdump     connection=ENB
    sleep    5
    csn.download_file   /tmp/${x2_log_name}   ${log_path}/${x2_log_name}   connection=ENB

Check X2 link to gnb is available
    [Documentation]    Author: Ding Binmei
    ...                Description: Check that X2 link to gnb status is available in case GNB on air is fake
    ...                2020/3/13 Liu Zheng: update this KW to check all nrStatus.
    [Arguments]    ${alias}=enblte    ${gnb_alias}=GNB_OAM    ${gnb_ps_cell_list}=${GNB_PS_CELL_INDEX_LIST}
    Connect to eNB via ssl    connection=${alias}
    @{MOs}    enblte.get_managed_objects    class_name=LNADJGNB_A    connection=${alias}
    &{x2_link_status}    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=x2ToGnbLinkStatus    connection=${alias}
    Should be equal as strings    ${x2_link_status['x2ToGnbLinkStatus']}    available    msg=X2 link to gnb is unavailable

    @{MOs_nrStatus}    enblte.get_managed_objects    class_name=LNRELGNBCELL_A    connection=${alias}
    ${len}    get length    ${MOs_nrStatus}

    Run keyword if    ${len}==${1}    Check nrStatus for only one neighbour relation    MOs_nrStatus=${MOs_nrStatus}    alias=${alias}
    ...    ELSE IF    ${len}>${1}    Check nrStatus for more neighbour relations    MOs_nrStatus=${MOs_nrStatus}    alias=${alias}
    ...            gnb_alias=${gnb_alias}    gnb_ps_cell_list=${gnb_ps_cell_list}
    ...    ELSE    should be true    ${len} != ${0}    msg=There is no nrStatus
    [Teardown]    Enblte close down    connection=${alias}

Check nrStatus for only one neighbour relation
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${MOs_nrStatus}    ${alias}=enblte
    &{dict_nrStatus}     enblte.get_parameters    dist_name=${MOs_nrStatus[0]['distName']}  pattern=nrStatus    connection=${alias}
    should be equal as strings    ${dict_nrStatus['nrStatus']}    available    msg=nr status is not in available status

Check nrStatus for more neighbour relations
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${MOs_nrStatus}    ${alias}=enblte    ${gnb_alias}=GNB_OAM    ${gnb_ps_cell_list}=${GNB_PS_CELL_INDEX_LIST}
    @{nrCellIdentity_list}    create list
    ${len}    get length    ${MOs_nrStatus}
    &{nr_cell_id_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${gnb_alias}
    FOR    ${ps_cell_index}    IN    @{gnb_ps_cell_list}
        Append to list    ${nrCellIdentity_list}    ${nr_cell_id_mapping[${ps_cell_index}]['nrCellIdentity']}
    END
    FOR    ${index}    IN RANGE    ${len}
        &{dict_nrCellId}     enblte.get_parameters    dist_name=${MOs_nrStatus[${index}]['distName']}    pattern=nrCellId    connection=${alias}
        &{dict_nrStatus}     enblte.get_parameters    dist_name=${MOs_nrStatus[${index}]['distName']}  pattern=nrStatus    connection=${alias}
        Run keyword if    ${dict_nrCellId['nrCellId']} in ${nrCellIdentity_list}
        ...    should be equal as strings    ${dict_nrStatus['nrStatus']}    available    msg=nr status is not in available status
    END

Check enb status is in cell on air status
    [Documentation]  Author: Ding Binmei
    ...              Description: Check if enb status is on air
    [Arguments]    ${enb_alias}=enblte
    ${bts_status}    enblte.get_bts_statuses    connection=${enb_alias}
    ${enb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Should be equal as strings    ${enb_cell_status}    OnAir    msg=ENB is not on air, Current status is ${enb_cell_status}
    ...                      ignore_case=${True}

Wait until enb cell on air status
    [Documentation]  Author: Ding Binmei
    ...              Description: 2020-12-14: Extend to support to multi enbs
    [Timeout]  20 min
    [Arguments]    ${enb_alias}=enblte    ${timeout}=10 min    ${enb_index}=${0}
    ${enb_alias}    Set variable if    '${enb_index}'!='0'    ${enb_alias}_${enb_index}    ${enb_alias}
    wait until keyword succeeds    ${timeout}    20 sec    Connect to eNB via ssl    connection=${enb_alias}    enb_index=${enb_index}
    wait until keyword succeeds    ${timeout}    20 sec    Check enb status is in cell on air status    enb_alias=${enb_alias}
    [Teardown]    Enblte close down    connection=${enb_alias}

Make SgNBAddition on specific cell
    [Documentation]   Author: zheng.4.liu@nokia-sbell.com
    ...               Description: do attach on specific cell.
    ...               update actDynTrigLteNrDualConnectivity parameters to false,
    ...               and set defaultLnRelGnbCellId in eNB scf to force the SgNBAddition on specific cell.
    ...               ${gnb_ps_cell_index} is the cell index on GNB which can do attach.
    ...               ${value_dlrgci} is the defaultLnRelGnbCellId
    ...               ${LTE_ID} to fit muti cell in ENB ,${LTE_ID} use defualt value will use the first cell
    ...               else you can input which cell you want
    [Arguments]    ${gnb_ps_cell_index}    ${para_update_timeout}=6 min    ${alias}=enblte   ${LTE_ID}=${None}
    #step1: ------get lnCelID, and set the actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId distName
    ${lncelid_onlyone}    Get lncelid on enb    alias=${alias}
    ${lncelid}    set variable if   ${LTE_ID}==${None}      ${lncelid_onlyone}      ${LTE_ID}
    ${value_dlrgci}      get gnbcell id    LTE_ID=${lncelid}   gnb_set_ID=${gnb_ps_cell_index}
    ${value_dlrgci}    convert to string    ${value_dlrgci}
    ${dist_name_dlrgci}    set variable    LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${lncelid}
    ${dist_name_adtlndc}    set variable     LNBTS-${tl.enbs[0].global_bts_id}
    #step2: ------get actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId parameter value------
    Connect to eNB via ssl    connection=${alias}
    ${actDynTrigLteNrDualConnectivity_pre}    Get NIDD parameter value    class_name=LNBTS_A    pattern=actDynTrigLteNrDualConnectivity
    ...     connection=${alias}
    ${defaultLnRelGnbCellId_pre}    Get NIDD parameter value    class_name=LNCEL_A    pattern=defaultLnRelGnbCellId     connection=${alias}
    #step3: ------set parameters which need to be updated------
    &{actDynTrigLteNrDualConnectivity}    Create Dictionary    dist_name=${dist_name_adtlndc}
    ...    parameter=actDynTrigLteNrDualConnectivity    value=false
    @{modify_adtlndc}    Evaluate   [&{actDynTrigLteNrDualConnectivity}]
    &{defaultLnRelGnbCellId}    Create Dictionary    dist_name=${dist_name_dlrgci}
    ...    parameter=defaultLnRelGnbCellId    value=${value_dlrgci}
    @{modify_dlrgci}     Evaluate    [&{defaultLnRelGnbCellId}]
    #step4: ------update parameters if needed------
#    ${actDynTrigLteNrDualConnectivity_pre_l}    Convert to lowercase    ${actDynTrigLteNrDualConnectivity_pre}
    ${update_status}    run keyword if    '${actDynTrigLteNrDualConnectivity_pre}' != 'False'     COAM Update several parameters via rest api
    ...    connection=${alias}     parameters_to_update_via_api=${modify_adtlndc}    timeout=${para_update_timeout}
    ...    ELSE    log to console    the actDynTrigLteNrDualConnectivity is already false, no need to be updated.
    Run keyword if    '${actDynTrigLteNrDualConnectivity_pre}' != 'False'    Should be true    '${update_status}'=='PASS'
    ${update_status}    run keyword if    '${defaultLnRelGnbCellId_pre}' != '${value_dlrgci}'    COAM Update several parameters via rest api
    ...    connection=${alias}     parameters_to_update_via_api=${modify_dlrgci}    timeout=${para_update_timeout}
    ...    ELSE    log to console    the defaultLnRelGnbCellId is already ${value_dlrgci}, no need to be updated.
    Run keyword if     '${defaultLnRelGnbCellId_pre}' != '${value_dlrgci}'     Should be true    '${update_status}'=='PASS'
    [Teardown]    Enblte close down    connection=${alias}

get gnbcell id
    [Documentation]   author: fang ludan
    ...    get defaultLnRelGnbCellId in eNB  to force the SgNBAddition on specific cell
    ...    ${gnb_set_ID}is the cell index on GNB which can do attach
    ...    ${LTE_ID}is the cell index on ENB can do attach
    [Arguments]   ${LTE_ID}   ${gnb_set_ID}
    ${gnb_set_ID}   evaluate   int(${gnb_set_ID})
    ${LTE_ID}   evaluate   int(${LTE_ID})
    &{nr_cell_id_mapping_gnb}    get_relation_mapping_between_cell_index_and_other_ids
    ${nr_cell_id_mapping_gnb_cell}  set variable    &{nr_cell_id_mapping_gnb}[${gnb_set_ID}]
    log to console    &{nr_cell_id_mapping_gnb_cell}[nrCellIdentity]
    ${physicalCellId}  set variable   &{nr_cell_id_mapping_gnb_cell}[nrCellIdentity]
    Connect to eNB via ssl    connection=enblte
    @{MOs}    enblte.get_managed_objects    class_name=LNRELGNBCELL_A    connection=enblte
    ${lncel_a_lte_id}     set variable   LNCEL_A-${LTE_ID}
    FOR   ${item}   IN   @{MOs}
        ${status}   run keyword and return status   should contain    ${item['distName']}   ${lncel_a_lte_id}
        ${cellID}  run keyword if  ${status}==${True} and ${item['parameters']['nrCellId']}==${physicalCellId}
        ...              Get Substring    ${item['distName']}   -1
        exit for loop if    ${cellID}!=${None}
    END

    [Return]    ${cellID}
    [Teardown]   run keyword and ignore error   enb_lte.Enblte close down    connection=enblte

Get NIDD parameter value
    [Documentation]    Author: Liu Zheng
    [Arguments]   ${class_name}=LNBTS_A    ${pattern}=actDynTrigLteNrDualConnectivity    ${connection}=enblte
    @{MOs}    enblte.get_managed_objects    class_name=${class_name}    connection=${connection}
    &{dict_pattern}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}  pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Get lncelid on enb
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${alias}=enblte
    Connect to eNB via ssl    connection=${alias}
    @{MOs}    enblte.get_managed_objects    class_name=LNCEL_A    connection=${alias}
    ${lncelid}    Fetch from right    ${MOs[0]['distName']}    -
    [Teardown]    Enblte close down    connection=${alias}
    [Return]    ${lncelid}

Wait for all ENB status are on air based on testline config file
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait for all ENB status are on air based on testline config file
    [Arguments]    ${timeout}=10 min    ${enb_index}=${None}
    ${enbs}    testline_info.get_real_enbs    tl=${tl}
    ${count_enb}    Get length    ${enbs}
    ${all_enb_index}    Evaluate    list(range(0, ${count_enb}))
    ${list_enb_index}    Convert data type to a list    input_data=${enb_index}
    ${enb_indexes}    Set variable if    ${enb_index}!=${None}    ${list_enb_index}    ${all_enb_index}
    FOR    ${enb_index}    IN     @{enb_indexes}
        Run keyword and continue on failure    Wait until enb cell on air status    timeout=${timeout}    enb_index=${enb_index}
    END

Convert data type to a list
    [Documentation]    Author: Ding Binmei
    ...                Description: Convert the input data type to a list
    ...                             Input data type can be a string or a list
    [Arguments]    ${input_data}
    ${is_input_data_a_list}    Evaluate    isinstance(${input_data}, list)
    Return from keyword if    ${is_input_data_a_list}    ${input_data}
    ${input_data_list}    Create list    ${input_data}
    [Return]    ${input_data_list}
