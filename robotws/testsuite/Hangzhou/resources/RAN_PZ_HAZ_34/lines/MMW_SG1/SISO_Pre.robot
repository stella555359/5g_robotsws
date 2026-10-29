*** Settings ***
Documentation
...   author: Ding Binmei
...   contact: binmei.ding@nokia-sbell.com
...   squad group: SG_04
...   Team common keywords for siso features

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    ./common_setup_teardown.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library    taf.analyzer.pcap    WITH NAME   cap
Library     OperatingSystem
Library     String
Library     Collections
Library     taf.pdu
Library     taf.rfrl.common_resources.python.ssh_common_commands
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Variables    ./lib/defult_testline_scf.py

*** Variables ***
@{LIST_ATTENUATION_VALUE}    6    6    10    10

*** Keywords ***
Enable soap log flag
    [Documentation]    Author: Ding Binmei
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP    ru_alias=RU_1
    Enable capture soap msg flag on RU    ru_alias=RU_1
    [Teardown]    Run keywords    COAM Teardown gnb connections    AND
    ...    csn.disconnect    connection=RU_1    AND
    ...    csn.disconnect    connection=ASIK Master

Download SOAP log in suite setup
    [Documentation]    Author: Ding Binmei
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP    ru_alias=RU_1
    ${SOAP_LOG_PATH_SUITE}    Download soap msg from RU Reg   soap_log=UnitOAM_SOAP_Log*.xml    log_path=${SUITE_LOG_PATH}    ru_alias=RU_1
    set suite variable    ${SOAP_LOG_PATH_SUITE}
    [Teardown]    Run keywords    csn.Disconnect    connection=RU_1    AND
    ...                           csn.disconnect    connection=ASIK Master
Check cpri link status
    [Documentation]    Author: Miao Jingwei
    ...                Description: Check CPRI link status in Loner Register
    ...                For CPRI link 8, the register is 0xdf201004
    ...                For CPRI link 9, the register is 0xdf241004
    [Arguments]     ${cpri_state_register}    ${loner_alias}=ABIL Loner_1
    ${cmd_get_cpri_link_state}    set variable    devmem ${cpri_state_register}
    ${cpri_link_state_raw}    csn.Execute    command=${cmd_get_cpri_link_state}    connection=${loner_alias}
    ${cpri_link_state}    Strip String     ${cpri_link_state_raw}
    ${cpri_link_state_explainatin}    Set variable if    '${cpri_link_state}'=='0x00000010'    Synced
    ...    '${cpri_link_state}'=='0x00000002'    Loss of Frame
    ...    '${cpri_link_state}'=='0x00000003'    Loss of Signal
    ...    Undefined state
    should be equal    ${cpri_link_state}    0x00000010
    ...    msg=CPRI Link NOT Synced, current state is: ${cpri_link_state}, ${cpri_link_state_explainatin}

Ping to destination from local should be success
    [Documentation]    Author: Liu Zheng
    ...                ${destation} can be host name or IP or gateway
    [Arguments]     ${destation}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${rc}=    Run and return rc    ping ${destation} -w 10
    Should be equal as numbers    first=${0}    second=${rc}

Ping to destination from ASIK should be success
    [Documentation]  Author: Liu Zheng
    [Arguments]     ${destation}    ${connection}=ASIK Master
    ${result} =    csn.execute    command=ping ${destation} -w 10    connection=${connection}
    should contain    ${result}    0% packet loss
    Should not contain    ${result}    100% packet loss

Verify ASIK is disconnected
    [Documentation]  Author: Liu Zheng
    ${status} =    Run Keyword And Return Status    Ping to destination from local should be success
    Should Be Equal    ${status}    ${False}

Verify RU is disconnected
    [Documentation]  Author: Liu Zheng
    ${status} =    Run Keyword And Return Status    Ping to all RU with allocated IP should be success
    Should Be Equal    ${status}    ${False}

Ping to all RU with allocated IP should be success
    [Documentation]  Author: Liu Zheng
    [Arguments]    ${connection}=GNB_OAM
    ${rus}    connection_alias_store.Get RU List
    connection_alias_store.Connect to Common Unit Master
    ${ru_index}    Set Variable    ${1}
    FOR    ${ru}    IN    @{rus}
        &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
        ${ru_ip_addr}    Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
        Ping to destination from ASIK should be success    destation=${ru_ip_addr}
        ${ru_index}    Evaluate    ${ru_index}+1
    END

Verify MSG3 exist in bip for attach process
    [Documentation]    Auther:Jin Journey
    ...                Description: Verify msg3 message "puschreceiveresplo" exist in BIP log
    [Arguments]    ${bip_log}    ${lua_script_path}
     Wait until keyword succeeds    1 min     5 s    cap.Read cap
     ...    cap_file=${bip_log}    display_filter=uldata_puschreceiveresplo    X=lua_script:${lua_script_path}
    ${rnti_list} =    cap.Get Element Value    element_expression=UlData_PuschReceiveRespLo.PuschReceiveRespLo.rnti
    ...    element_idx=${0}
    ...    default_value=True
    should not be empty    ${rnti_list}
    [Return]    @{rnti_list}

Close iperf progress
    [Documentation]    Author: Wang Yixiang
    ...    2020/4/22 Biyao modify to adapt to power_ue.robot
    ...    ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    ...     data_transfer_direction: supported values are both, ul, dl
    ...    2021/03/24 Lingxue: this keyword is replaced by l3call.Stop data transfer based on direction, stop use this one in new feature.
    [Arguments]    ${data_transfer_direction}=both     ${ue_type}=${UE_TYPE}
    run keyword if     '${ue_type}' == 'huawei'    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP
    ${iperf_ul}    Set variable if    '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${None}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if      '${ue_type}' == 'inseego' or '${ue_type}' == 'mtk'
    ...    ${None}    ${tl.ues[0].iperf_details.port}
    Run keyword if    '${data_transfer_direction}'=='both'
    ...    Run keywords     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    ...            dt_name=dt_ul    iperf_port=${iperf_ul}    AND
    ...                     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    ...            dt_name=dt_dl    iperf_port=${iperf_dl}
    ...    ELSE IF    '${data_transfer_direction}'=='ul'
    ...        power_ue.Stop traffic    ue_type=${ue_type}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}    iperf_port=${iperf_ul}
    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...        power_ue.Stop traffic    ue_type=${ue_type}    direction=${data_transfer_direction}
    ...            dt_name=dt_${data_transfer_direction}    iperf_port=${iperf_dl}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl

Get nrCellIdentity for specific cell
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${cell_id}
    ${nrCellIdentity}   Get SCF single Value from current xml file
    ...   parameter=nrCellIdentity   list_name=${None}   dist_name=NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_id}   p_index=${0}
    ...   alias=GNB_OAM    config_type=configurationAndRuntimeObjects
    [Return]    ${nrCellIdentity}

Verify Parameter Value In SOAP Log
    [Documentation]    Author: Wang Yixiang
    ...                Description: Verify distName value of soap log
    ...                2019-11-15 Ding Binmei: Add ru_type argument to support ru type AWHHD
    [Arguments]    ${soap_log_path}=${SOAP_LOG_PATH_SUITE}
    Run keyword and continue on failure
    ...    Verify SOAP Modify Parameter Req    distName_value=module    expected_value=TRUE    log_path=${soap_log_path}
    Run keyword and continue on failure
    ...    Verify SOAP Parameter Change Ind    distName_value=module    expected_value=TRUE    log_path=${soap_log_path}
    Run keyword and continue on failure
    ...    Verify SOAP Modify Parameter Req    distName_value=led1    expected_value=TRUE    log_path=${soap_log_path}
    Run keyword and continue on failure
    ...    Verify SOAP Parameter Change Ind    distName_value=led1    expected_value=TRUE    log_path=${soap_log_path}
    Run keyword and continue on failure
    ...    Verify SOAP Modify Parameter Req    distName_value=faultManagement    expected_value=TRUE    log_path=${soap_log_path}
    Run keyword and continue on failure
    ...    Verify SOAP Parameter Change Ind    distName_value=faultManagement    expected_value=TRUE    log_path=${soap_log_path}
    ${tx_carrier_distname}    search_distname_tx_carrier    log_path=${soap_log_path}
    Run keyword and continue on failure
    ...    Verify SOAP Modify Parameter Req    distName_value=${tx_carrier_distname}    expected_value=TRUE    log_path=${soap_log_path}
    Run keyword and continue on failure
    ...    Verify SOAP Parameter Change Ind    distName_value=${tx_carrier_distname}    expected_value=TRUE    log_path=${soap_log_path}

Verify SOAP Msg Module Ready Ind Ack
    [Documentation]    Author: Wang Yixiang
    ...                Description: Verify items in moduleReadyInd and moduleReadyAck
    [Arguments]     ${module_ready_ind_ack_dict}    ${serialNum}=${RU_1_SERIAL_NUM}    ${productCode}=${RU_PRODUCT_CODE}
    ...             ${interfaceType}=${INTERFACE_TYPE}    ${moduleType}=${MODULE_TYPE}
    Run keyword and continue on failure
    ...    Should Be Equal    ${module_ready_ind_ack_dict['serialNum']}    ${serialNum}    Check RU_1_SERIAL_NUM failed.
    Run keyword and continue on failure
    ...    Should Be Equal    ${module_ready_ind_ack_dict['productCode']}    ${productCode}    Check RU_PRODUCT_CODE failed.
    Run keyword and continue on failure
    ...    Should Be Equal    ${module_ready_ind_ack_dict['interfaceType']}    ${interfaceType}     Check INTERFACE_TYPE failed.
    Run keyword and continue on failure
    ...    Should Be Equal    ${module_ready_ind_ack_dict['moduleType']}    ${moduleType}        Check MODULE_TYPE failed.

Verify Carrier Parameter SOAP log compare WebUI
    [Documentation]    Author: Wang Yixiang
    ...                Description: All related carrier parameter has correct value (power, channel bandwidth, frequency, type etc)
    ...                             according to configuration.
    ...                2019-11-15 Ding Binmei: Add ru_type argument to support ru type AWHHD
    [Arguments]    ${soap_log_path}=${SOAP_LOG_PATH_SUITE}
    ${cell_info}                  COAM get cell specific info
    ${tx_carrier_distname}        search_distname_tx_carrier    log_path=${soap_log_path}
    ${carrier_info_dict}          Get And Convert SOAP Carrier Info to webUI Format
    ...                           log_path=${soap_log_path}    distName_value=${tx_carrier_distname}
    Run keyword and continue on failure
    ...    Should Be Equal As Strings    ${carrier_info_dict['bandwidth']}MHz    ${cell_info['chBw']}    Bandwidth should be equal
    Run keyword and continue on failure
    ...    Should Be Equal As Strings    ${carrier_info_dict['frequency']}    ${cell_info['nrarfcn']}    Frequency should be equal

Modify parameters exceed and bellow and within RU range and verify
    [Documentation]  Author: Ren Biyao
    ...              1900 fault refers to 'EFaultId_FrConfiguringFailed'
    ...              4001 fault refers to  'BTS reset required'
    ...              Not needed to modify pmax with below range if ru type is AEQB
    [Arguments]  ${timeout}=${360}     ${ru_type}=${RU_TYPE}
    ...    ${parameters_above_required_value}=${MODIFY_VALUE_ABOVE_AEQB_REQUIRED_RANGE_VIA_API}
    ...    ${parameters_bellow_required_value}=${MODIFY_VALUE_BELOW_AEQB_REQUIRED_RANGE_VIA_API}
    ...    ${parameters_within_required_value}=${MODIFY_VALUE_WITHIN_AEQB_REQUIRED_RANGE_VIA_API}    ${connection}=GNB_OAM
    # Step 1: Modify nrarfcn or pmax on cell-1(above range)
    Modify parameters exceed RU range and check 1900 fault and recover status
    ...    parameters_to_update_via_api=${parameters_above_required_value}    timeout=${timeout}     connection=${connection}
    # Step 2: Modify nrarfcn or pmax on cell-1(below range)
    Run keyword if    '${ru_type}'!='AEQB'
    ...    Modify parameters exceed RU range and check 1900 fault and recover status
    ...    parameters_to_update_via_api=${parameters_bellow_required_value}    timeout=${timeout}     connection=${connection}
    # Step 3: Modify nrarfcn or pmax on cell-1(within range)
    COAM Update several parameters via rest api
    ...     parameters_to_update_via_api=${parameters_within_required_value}    timeout=${timeout}    connection=${connection}
    coam_gnb_classical.COAM Wait for gnb ready and cell setup    connection=${connection}

Modify parameters exceed RU range and check 1900 fault and recover status
    [Documentation]  Author: Ren Biyao
    ...              1900 fault refers to 'EFaultId_FrConfiguringFailed'
    ...              4001 fault refers to  'BTS reset required'
    [Arguments]  ${parameters_to_update_via_api}    ${timeout}=${360}    ${connection}=GNB_OAM    ${if_need_check_4001_fault}=${False}
    ...    ${alarms_source_list}=${ALARMS_SOURCE_LIST}
    # Step 1: Modify nrarfcn or pmax on cell (exceed RU e.g. AEQB range, above or below)
    ${update_status}    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
    ...    timeout=${timeout}    connection=${connection}
    Run keyword and continue on failure    Should be equal as strings    ${update_status}    RESET_PASS
    # Step 2: Check 1900 fault for all cells.
    Wait until keyword succeeds    1 min     5 sec    coam_gnb_classical.Connect to gnb coam via ssl   connection=${connection}
    Wait Until Keyword Succeeds    25 min    5 sec    Verify fault via active alarm for all cells    faultId=1900
    ...    alarms_source_list=${alarms_source_list}    connection=${connection}
    Run keyword if    '${if_need_check_4001_fault}'!='${False}'     Wait Until Keyword Succeeds    10 min    5 sec
    ...    Verify fault via active alarm for all cells    faultId=4001    alarms_source_list=${alarms_source_list}    connection=${connection}
    # Step 3: Check bts will not reset
    Repeat keyword    3 times    Run keywords
    ...    coam_gnb_classical.COAM Check GNB ASIK status    connection=${connection}    AND
    ...    Sleep   3s

Verify fault via active alarm for all cells
    [Documentation]  Author: Ren Biyao
    ...    This keyword is to check the alarms from active alarms.
    [Arguments]    ${faultId}=1900    ${alarms_source_list}=${None}    ${connection}=GNB_OAM
    FOR  ${cur_alarm_source}  IN  @{alarms_source_list}
      Run keyword and continue on failure    Expect Fault Should Present    faultId=${faultId}    source=${cur_alarm_source}
      ...    connection=${connection}
    END

COAM clear commission then reset BTS and wait bts startup via lmp internal ip
    [Documentation]  Author: Ren Biyao
    ...    After clearing all the configuration files in BTS, the external ip of lmp will lose. Then, internal
    ...    ip will be used instead.
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=10 min    ${gnb_coam_alias}=GNB_OAM    ${asik_alias}=ASIK Master
    ...    ${lmp_internal_ip}=${LMP_INTERNAL_IP}
    #Step 1: clear commission and then reset BTS
    connection_alias_store.Connect to Common Unit Master    alias=${asik_alias}
    csn.Send command    command=rm -rf /ffs/run/config/*    connection=${asik_alias}
    sleep    2 sec
    csn.Send command    command=ls -l /ffs/run/config/   connection=${asik_alias}
    csn.read output    connection=${asik_alias}
    csn.Disconnect    connection=${asik_alias}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.Reset site
    log to console  WAIT FOR ASIK TO BE UNREACHABLE!!!
    Wait until keyword succeeds    10 min    2 sec    Verify ASIK is disconnected
    #Step 2: COAM Check GNB ASIK status via lmp internal ip
    Wait until keyword succeeds    ${timeout}    20 sec    coam_gnb_classical.Connect to gnb coam via ssl
    ...    bts_host=${lmp_internal_ip}    connection=${gnb_coam_alias}
    Wait until keyword succeeds    ${timeout}    20 sec    coam_gnb_classical.COAM Check GNB ASIK status    connection=${gnb_coam_alias}
    #Step 3: COAM Check GNB ABIL status via lmp internal ip
    Wait until keyword succeeds    ${timeout}    20 sec    coam_gnb_classical.COAM Check GNB ABIL status    connection=${gnb_coam_alias}

Do commission and swconfig via internal lmp ip
    [Arguments]    ${lmp_internal_ip}=${LMP_INTERNAL_IP}    ${alias}=ASIK Master        ${is_called_in_test_case_level}=${False}
    ...    ${gnb_coam_alias}=GNB_OAM    ${du_index}=${0}
    csn.Connect to    hostname=${lmp_internal_ip}
    ...               username=${tl.gnbs[0].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${None}   alias=${alias}
    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${default_swconfig_file_path}    Copy file    source=${SWCONFIG_DEFAULT_FILE_PATH}    destination=${local_log_file_folder}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign
    ...    localFilePath=${default_swconfig_file_path}
    ...    asik_alias=${alias}
    csn.Disconnect    connection=${alias}
    Log to console    Start to modify scf files and commission via internal lmp ip, please wait...
    ${default_scf_file_path}    Copy file    source=${SCF_DEFAULT_FILE_PATH}    destination=${TS_CASE_LOG_PATH}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${default_scf_file_path}
    ...    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    coam_gnb_classical.Connect to gnb coam via ssl    bts_host=${LMP_INTERNAL_IP}    connection=${gnb_coam_alias}
    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${output_scf_file_path}    connection=${gnb_coam_alias}

Set CPRI link state register by program
    [Documentation]    author: Wang Yixiang
    ${program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${program}

    run keyword if    '${program}'=='19A'    run keywords
    ...    set suite variable    ${CPRI_LINK_8_STATE_REGISTER}    0xdf201004    AND
    ...    set suite variable    ${CPRI_LINK_9_STATE_REGISTER}    0xdf241004
    run keyword if    '${program}'=='19B'    run keywords
    ...    set suite variable    ${CPRI_LINK_8_STATE_REGISTER}    0xdf261004    AND
    ...    set suite variable    ${CPRI_LINK_9_STATE_REGISTER}    0xdf271004
    run keyword if    '${program}'=='master'    run keywords
    ...    set suite variable    ${CPRI_LINK_8_STATE_REGISTER}    0xdf281004    AND
    ...    set suite variable    ${CPRI_LINK_9_STATE_REGISTER}    0xdf291004
    run keyword if    '${program}'=='20A'       run keywords
    ...    set suite variable    ${CPRI_LINK_8_STATE_REGISTER}    0xdf261004    AND
    ...    set suite variable    ${CPRI_LINK_9_STATE_REGISTER}    0xdf271004

Get cell group index list
    [Documentation]  Author: Liu Zheng
    ...              Description: Support to check with multiple rmod
    [Arguments]    ${connection}=GNB_OAM
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${number_of_cell_group_info}    get length    ${cell_info}
    ${cellgrp_list}    Get Dictionary Keys    ${cell_info}
    @{cellgrp_index_list}    create list
    FOR    ${cellgrp}    IN    @{cellgrp_list}
        ${cellgrp_index}    Fetch from right    ${cellgrp}    -
        Append to list    ${cellgrp_index_list}    ${cellgrp_index}
    END
    [Return]    ${cellgrp_index_list}

Check if testline configured with attenuation
    [Documentation]     Author: Ren Biyao
    ...    This keyword is to check whether the testline is configured with attenuation.
    ${attenuation_channels}     set variable    ${tl.gnbs[0].dus[0].rus[${0}].attenuation_ports}
    ${is_attenuation_exists}    set variable if   '${attenuation_channels}'!='${None}'    ${True}
    ...     '${attenuation_channels}'=='${None}'    ${False}
    [Return]    ${is_attenuation_exists}

Adjust the Attenuation
   [Documentation]     Author: Ren Biyao
   ...      This keyword is setting the same attenuation value for all ports.
   ...      :para${list_attenuation_value}: should be list,eg [6, 6, 10, 10]
    [Arguments]    ${list_attenuation_value}=${LIST_ATTENUATION_VALUE}
    ${attenuation_ports} =     gnb_classical_hangzhou.Get Attenuation Channels For RU
    attenuator.setup_attenuator
    ...    ip_addr=${tl.attenuator.ip_addr}
    ...    port=${tl.attenuator.port}
    ...    attenuation_port_numbers=${attenuation_ports}
    ...    vendor=TopYoung
    ${ports_number_to_modify}    get length     ${attenuation_ports}
    FOR    ${i}    IN RANGE  ${ports_number_to_modify}
        ${cur_atten_port}    convert to string     ${attenuation_ports[${i}]}
        &{modify_cur_port}    create dictionary    ${cur_atten_port}=${list_attenuation_value[${i}]}
        wait until keyword succeeds     30 sec    2 sec    gnb_classical_hangzhou.Modify Attenuation
        ...                                                channels_to_modify=${modify_cur_port}
    END

Get the ru index list and cell index list and cell group index list and set to suite variable
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl  connection=${connection}
    ${ru_index_list}    Get RU index list
    ${cell_index_list}    Get all cell index list
    ${cellgrp_index_list}    Get cell group index list
    COAM Teardown gnb connections    connection=${connection}
    Sort List    ${ru_index_list}
    Sort List    ${cell_index_list}
    Sort List    ${cellgrp_index_list}
    Set suite variable    ${RU_INDEX_LIST}    ${ru_index_list}
    Set suite variable    ${CELL_INDEX_LIST}    ${cell_index_list}
    Set suite variable    ${CELLGRP_INDEX_LIST}    ${cellgrp_index_list}

Connect to all the rus with allocated IP
    [Documentation]  Author: Liu Zheng
    [Arguments]    ${connection}=GNB_OAM    ${alias}=ASIK Master
    connection_alias_store.Connect to Common Unit Master    alias=ASIK Master
    Connect to gnb coam via ssl  connection=${connection}
    @{list_ru_alias}    Create list
    ${ru_index_list}    Get RU index list
    FOR    ${ru_index}    IN    @{ru_index_list}
      Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
      ...    connection=${connection}
      Append to list    ${list_ru_alias}    RU_${ru_index}
    END
    [Teardown]   run keywords    COAM Teardown gnb connections    connection=${connection}    AND
    ...    ssh.disconnect    connection=${alias}
    [Return]  ${list_ru_alias}

Get all cell index list
    [Documentation]    Author: Liu Zheng
    ${cell_list_all}    Get all cells
    @{cell_index_list_all}    create list
    FOR    ${cell}    IN    @{cell_list_all}
        ${cell_index}    Fetch from right    ${cell}    -
        ${cell_index}    convert to integer    ${cell_index}
        append to list    ${cell_index_list_all}    ${cell_index}
    END
    [Return]    ${cell_index_list_all}

Get all cells
    [Documentation]    Author: Cui Lingxue
    ...    Get all gnb cells, and combined to one list variable. Return will be like: ['NRCELL-1', 'NRCELL-2', 'NRCELL-3', 'NRCELL-4']
    ${cell_list_gnb}    Get cell list for GNB
    ${cell_group_num}    get length    ${cell_list_gnb}
    ${cell_list_all}    create list
    FOR    ${cell_group_index}    IN RANGE    ${cell_group_num}
        ${cell_list_all}    combine lists    ${cell_list_all}    ${cell_list_gnb[${cell_group_index}]}
    END
    [Return]    ${cell_list_all}

Get cell list for GNB
    [Documentation]   Author: Liu Zheng
    ...               This keyword is used to get all the cells and store them into list.
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=GNB_OAM
    ${number_of_cell_group_info}    get length    ${cell_info}
    @{cell_list}    Create list
    FOR  ${index}    IN RANGE    ${number_of_cell_group_info}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
        ${cell_list_in_cellgrp}    Get Dictionary Keys    ${cell_from_cellgrp}
        Append to list    ${cell_list}    ${cell_list_in_cellgrp}
    END
    [Return]    ${cell_list}

Case env recovery for 1900 cases
    [Documentation]    author: Liu Zheng
    [Arguments]    ${parameters_within_required_value}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    run keywords
    ...    Connect to gnb coam via ssl    AND
    ...    COAM Update several parameters via rest api
    ...     parameters_to_update_via_api=${parameters_within_required_value}    timeout=6 min
    Case env recovery common
