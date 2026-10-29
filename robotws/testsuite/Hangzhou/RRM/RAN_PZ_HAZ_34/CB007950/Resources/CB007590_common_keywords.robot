*** Settings ***
Resource          ../../5GC000523_samsung/Resources/5GC000523_common_keyword.robot
#Library     taf.sbts.oam.coam.admin       WITH NAME    sbts_coam
Library         taf.config.scf   WITH NAME      scf
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot


*** Variables ***
${scf_22R2}            SCF_SBTS22R2_7950.xml
${scf_trunk}             SCF_Trunk_7950.xml
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_737_IP}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${host}                     ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}                 ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}                 ${tl.test_pc.default_ssh_connection_details.password}
${bip_log_file}              biglog

${connection}    du_con
${dist_name}    MRBTS-10431/NRBTS-10431/NRCELL-1
${UL_Transm}      nr-rrc.dl_UL_TransmissionPeriodicity
${nr_Dwslot}      nr-rrc.nrofDownlinkSlots
${nr_Dwsymbol}   nr-rrc.nrofDownlinkSymbols
${nr_Uslot}      nr-rrc.nrofUplinkSlots
${nr_Upsymbols}       nr-rrc.nrofUplinkSymbols
${period_dict}     periodicCsiAcquisition

*** Keywords ***
Rest Login DU
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${WEBEM_USERNAME}
    ...    ${password}=${WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

Disconnect from DU
    [Arguments]    ${alias}=default
    coam.teardown     connection=${alias}

Input SCF
    [Timeout]  20 min
    [Arguments]      ${timeout}=10 min
    ${connection}     CB007590_common_keywords.Rest Login DU
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R4
    ${default_scf}    set variable if    ${if_common_load}   ${scf_path}SCF_SBTS22R4_7950.xml
    ...    ${scf_path}SCF_Trunk_7950.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${connection}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${connection}
    [Teardown]     CB007590_common_keywords.Disconnect from DU

Input NSA SCF
    [Timeout]  20 min
    [Arguments]      ${timeout}=10 min
    ${connection}     CB007590_common_keywords.Rest Login DU
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
    ${default_scf}    set variable if    ${if_common_load}   ${scf_path}SCF_SBTS22R2_NSA_7950.xml
    ...    ${scf_path}SCF_Trunk_NSA_7950.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${connection}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${connection}
    [Teardown]     CB007590_common_keywords.Disconnect from DU

Check if Cell Blocked
    [Arguments]    ${ip_address}=10.71.209.230
    ...   ${dist_name}=/MRBTS-1/RAT-1/NRTS-1/NRBTS_L-10432/NRCELL_L-1
    ${connection}    CB007590_common_keywords.Rest Login DU     ip_address=${DU_737_IP}
#    ${info}    sbts_coam.get_subcells_info    connection=${connection}
    ${info}    coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${return_status}    run keyword and return status   should be equal as strings     ${info['stateInfo']['blockingState']}     Blocked
    Run keyword if    ${return_status}     log to console    CELL_1 is block
    ...    ELSE      Block Cell through admin
    [Teardown]

Block Cell through admin
    [Arguments]  ${ip_address}=10.71.209.230     ${dist_name}=/MRBTS-10432/NRBTS-10432/NRCELL-1
    ${connection}    CB007590_common_keywords.Rest Login DU      ip_address=${DU_737_IP}
    ${info}    coam.block_cell     dist_name=${dist_name}    connection=${connection}
    [Teardown]  CB007590_common_keywords.Disconnect from DU

Connect to GNB Common Unit Master
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                This keyword currently only suitable for DU with singe Common Unit.
    ...                In cloud gNB, Common Unit Master connection need OAM as proxy.
    ...                In classical gNB, Common Unit Master connection don't need any proxy.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: Common Unit Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=Common Unit Master    ${common_unit_id}=${0}    ${gnb_index}=${0}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAMget parameters from Bip log
    ${proxy}    Set Variable If    ${has_cbts}    OAM
    ...                                           ${None}
    ssh.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_unit_id}].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_unit_id}].lmp_connection.password}
    ...               proxy=${proxy}   alias=${alias}
    [Return]    ${alias}

get AN report from Bip log
    [Arguments]    ${biplog_list}    ${filter}
    csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
    ...    alias=connection_ute
    FOR   ${i}   IN   @{biplog_list}
        csn.send command
        ...    command=/usr/bin/tshark -r ${LOG_PATH}/${i} -X ${lua_path} -Y "${filter}"
        ...    connection=connection_ute
        sleep   5s
        ${return_value}  csn.Read Output   connection=connection_ute
        run keyword and continue on failure    should not be empty    ${return_value}
    END
    sleep    3s
    [Teardown]    csn.Disconnect    connection=${connection}

get parameters from Bip log
    [Arguments]    ${biplog_list}    ${filter}    ${condition_expression}
    csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
    ...    alias=connection_ute
    FOR   ${i}   IN   @{biplog_list}
        csn.send command
        ...    command=/usr/bin/tshark -r ${LOG_PATH}/${i} -X ${lua_path} -Y "${filter}" -T fields -e ${condition_expression}
        ...    connection=connection_ute
        sleep   5s
        ${return_value}  csn.Read Output   connection=connection_ute
        ${return_value}    remove duplicates     ${return_value.split('\n')[:-1]}
        remove values from list     ${return_value}    ${EMPTY}
        ${return_value}    remove duplicates      ${return_value}
    END
    sleep    3s
    [Teardown]    csn.Disconnect    connection=${connection}
    [Return]       ${return_value}

Judge item should greater than 0
    [Arguments]  ${return_value}
    FOR    ${item}    IN     @{return_value}
            should be true     ${item}>0
    END

Judge item should be greater and equal 0
    [Arguments]  ${return_value}
    FOR    ${item}    IN     @{return_value}
            should be true     ${item}>=0
    END

get modulationType from Bip log
    [Arguments]    ${biplog_list}    ${filter}   ${condition_expression}
    csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
    ...    alias=connection_ute
    FOR   ${i}   IN   @{biplog_list}
        csn.send command
        ...    command=/usr/bin/tshark -r ${LOG_PATH}/${i} -X ${lua_path} -Y "${filter}" -T fields -e ${condition_expression}
        ...    connection=connection_ute
        sleep   5s
        ${return_value}  csn.Read Output   connection=connection_ute
        ${return_list}     Set Variable     ${return_value.split('\n')[:-1]}
    END
    [Teardown]   csn.Disconnect    connection=${connection}
   [Return]    ${return_list}

Start Capture BIP log
#    ${connection}       ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
#    ...    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#    ${PID}    Get PID    connection=${connection}
#    ...    command=ps -ef | grep tcpdump | grep -v grep | grep tcpdump_L2L1 | tail -n 1 |awk '{print $2}'
#    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
#    run keyword and continue on failure    ssh.send_command    command=cd /tmp && rm -rf tcpdump_L2L1_bip*    connection=${connection}
#    Precondition for bip capture with gnbMirroring scripts     connection=${connection}
#    _replace_gnbMirroringConfig    connection=${connection}
    Log To Console    Capture BIP Logs
    Collect Interface Mirroring Bip Collector
#    ssh.send_command   command=sh /ffs/run/config/scripts/gnbMirroring.sh > /dev/null    connection=${connection}
#    [Return]     ${connection}

Stop Capture BIP log and download file
    [Arguments]    ${connection}=UTE
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector
    ${num}    get length    ${full_log_path}
    ssh.Connect to    hostname=${host}    username=${ute_name}
    ...    password=${ute_password}    alias=${connection}
    Log To Console    Copy BIP Logs To Test PC
    ${biplog_list}    create list
    FOR    ${item}    IN RANGE    int(${num})
       ssh.download_file    remote_path=${full_log_path}[${item}]
       ...    local_path=${LOG_PATH}/${bip_log_file}_${item}.pcap    connection=${connection}
       append to list    ${biplog_list}    ${bip_log_file}_${item}.pcap
    END
    [Return]    ${biplog_list}
    [Teardown]    ssh.Disconnect    connection=${connection}

_replace_gnbMirroringConfig
    [Arguments]    ${connection}
    ssh.upload_file     local_path=${CURDIR}/gnbMirroringConfig.sh
    ...    remote_path=/ffs/run/config/scripts/gnbMirroringConfig.sh    connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    [Return]    ${PID}

################### case 10 #################
Modify multi parameter in case 10
     ${connection}    CB007590_common_keywords.Rest Login DU
     Modify scf parameter     dist_name=${dist_name}    parameter=srPeriodicity     value=slots160    connection=${connection}
     Modify scf parameter     dist_name=${dist_name}    parameter=actBeamforming     value=false  connection=${connection}
     Modify scf parameter     dist_name=${dist_name}    parameter=actLongPucchPhase2     value=true    connection=${connection}
     Modify scf parameter     dist_name=${dist_name}    parameter=actIncreasedFdmUsersPerSlot     value=true     connection=${connection}
     wait until keyword succeeds    10min    30sec   COAM Check GNB cell on air    connection=${connection}
     Modify scf parameter     dist_name=${dist_name}    parameter=maxNumPdschAllocationPerSlot     value=4    connection=${connection}
     wait until keyword succeeds    10min    30sec   COAM Check GNB cell on air    connection=${connection}
     Modify scf parameter     dist_name=${dist_name}    parameter=maxNumPuschAllocationPerSlot    value=4    connection=${connection}
     wait until keyword succeeds    10min    30sec   COAM Check GNB cell on air    connection=${connection}
     Modify scf parameter     dist_name=${dist_name}    parameter=reqMinNumPuschPrb     value=243    connection=${connection}
     [Teardown]     CB007590_common_keywords.Disconnect from DU

Check numofPrb in TTitrace
     [Arguments]     ${result_Prb}     ${actual_Prb}
     ${result}    Get Dictionary Values     ${result_Prb}
     FOR    ${item}    IN    @{result}
        should be true    ${item}<=${actual_Prb}
     END

###################### case 8 ################################
Modify scf parameter
  [Arguments]    ${dist_name}    ${parameter}     ${value}     ${connection}=${None}
   coam.perform_parameter_recommissioning   dist_name=${dist_name}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${value}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}
   sleep  10s

Case precondition
     ${connection}    CB007590_common_keywords.Rest Login DU
     ${object_list}    coam.get_managed_objects    class_name=NRCELL_A   connection=${connection}
     ${object}     set variable    ${None}
     ${parameter}    get from dictionary     ${object_list}[0]    parameters
     ${CSI_List}     get from dictionary    ${parameter}   tddFrameStructure
     @{List_temp}     create list
     Append To List      ${List_temp}     ${CSI_List}
     log to console       ${List_temp}
     set to dictionary    ${List_temp}[0]     frameStructureType=tdLte
     set to dictionary    ${List_temp}[0]     guardPeriodLength=4Symbols
     set to dictionary    ${List_temp}[0]     lteToNrFrameShift=3ms
     set to dictionary    ${List_temp}[0]     tdLteUlDlConfig=tdLteConfig2
     set to dictionary    ${List_temp}[0]     ulDlDataSlotRatio=1/4
     ${dict}    create dictionary    parameterName=tddFrameStructure   operation=update    value=${List_temp}
     ${list}    create list    ${dict}
     coam.perform_object_recommissioning    dist_name=${dist_name}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}     connection=${connection}
    CB007590_common_keywords.Disconnect from DU

################# case 3 ####################################
get SIBI_information from Bip log
    [Arguments]    ${biplog_list}     ${filter}      ${condition_expression}
    csn.connect_to    hostname=${host}    username=${ute_name}    password=${ute_password}
    ...    alias=connection_ute
    FOR   ${i}   IN   @{biplog_list}
        csn.send command
        ...    command=/usr/bin/tshark -r ${LOG_PATH}/${i} -X ${lua_path} -Y "${filter}" -T fields -e ${condition_expression}
        ...    connection=connection_ute
        sleep   5s
        ${return_value}  csn.Read Output   connection=connection_ute
        ${return_value}    remove duplicates     ${return_value.split('\n')[:-1]}
        ${result}    run keyword and return status    should not be empty    ${return_value}
        Exit For Loop If     ${result}==${True}
    END
    sleep   3s
    [Teardown]   csn.Disconnect    connection=${connection}
   [Return]    ${return_value}

################  case 9 #####################################
Get BTS Counters
    ${connection}    CB007590_common_keywords.Rest Login DU
    ${result_1}    coam.get_PM_counters    couter_ids=M55303C14001    connection=${connection}
    ${counter_dict1}    get dictionary values    ${result_1['BTS']['CELLS']['NRCELL-1']['NULSQ']['M55303C14001']}
    ${result_2}    coam.get_PM_counters    couter_ids=M55303C13001    connection=${connection}
    ${counter_dict2}    get dictionary values    ${result_2['BTS']['CELLS']['NRCELL-1']['NULSQ']['M55303C13001']}
    ${result_3}    coam.get_PM_counters    couter_ids=M55303C18001    connection=${connection}
    ${counter_dict3}    get dictionary values    ${result_3['BTS']['CELLS']['NRCELL-1']['NULSQ']['M55303C18001']}
    ${result_4}    coam.get_PM_counters    couter_ids=M55303C17001    connection=${connection}
    ${counter_dict4}    get dictionary values    ${result_4['BTS']['CELLS']['NRCELL-1']['NULSQ']['M55303C17001']}
    CB007590_common_keywords.Disconnect from DU
    [Return]    ${counter_dict1}    ${counter_dict2}    ${counter_dict3}    ${counter_dict4}

###################### Capture TTI Log #########################
start tti trace
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    log to console  start capture tti trace
    Create default connection    hw_slot=${hw_slot}
    Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}

Stop tti trace log
    [Arguments]
    log to console  stop capture tti trace
    Stop TTI trace log capturing
    ${UL_DL_csv_file_path_dict}    TTI_Trace.Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
    ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
    [Return]    ${UL_DL_csv_file_path_dict}

Convert TTI trace log and download combined csv logs to test pc
    [Documentation]    Author: Ding Binmei  5G_PZ_MMW_HZ_1_SG
    ...                Description:
    ...                             1. ${local_path} Refers to the test case log path in test pc
    ...                             2. Convert bin files to csv files
    ...                             3. Combine multiple CSV files to one csv file for UL and DL direction
    ...                             4. Will return the local file path as a dict with UL and DL csv file paths in test pc.
    ...                                Example output: {'UL':'XXXX', 'DL':'XXXX'}
    ...                2020-3-12 Ding Binmei: Added ${is_need_to_close_connection} to let user decide whether need to disconnect ssh connection
    ...                         Add ${connection_for_abil} and ${connection_for_asik} to extend keyword to support for log capturing on other ABIL
    ...                         It will support log capturing on ABIL master by default

    [Arguments]    ${local_path}=${TS_CASE_LOG_PATH}    ${is_need_to_close_connection}=${False}    ${connection_for_abil}=${None}
    ...    ${connection_for_asik}=${None}
    ${connection_for_abil}    Set variable if    '${connection_for_abil}'=='${None}'    ${ABIL_ALIAS}    ${connection_for_abil}
    ${connection_for_asik}    Set variable if    '${connection_for_asik}'=='${None}'    ${ASIK}    ${connection_for_asik}
    ${csv_path}    tti.convert_tti_trace_to_csv    connection=${connection_for_abil}
    ${csv_file_path_ul}    tti.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=ul    connection=${connection_for_abil}
    ${csv_file_path_dl}    tti.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=dl    connection=${connection_for_abil}
    ${remote_files}    Create list    ${csv_file_path_ul}     ${csv_file_path_dl}
    ssh.download file    remote_path=${remote_files}    local_path=${local_path}    connection=${connection_for_abil}
    Run keyword if    ${is_need_to_close_connection}
    ...    Run keyword and ignore error    Run keywords    ssh.disconnect    connection=${connection_for_abil}    AND
    ...                    ssh.disconnect    connection=${connection_for_asik}
    @{csv_file_name_ul}    Split string    ${csv_file_path_ul}    /
    @{csv_file_name_dl}    Split string    ${csv_file_path_dl}    /
    &{local_csv_file_path}    create dictionary
    Set to dictionary    ${local_csv_file_path}    UL    ${local_path}/${csv_file_name_ul}[-1]
    Set to dictionary    ${local_csv_file_path}    DL    ${local_path}/${csv_file_name_dl}[-1]
    [Return]    ${local_csv_file_path}
