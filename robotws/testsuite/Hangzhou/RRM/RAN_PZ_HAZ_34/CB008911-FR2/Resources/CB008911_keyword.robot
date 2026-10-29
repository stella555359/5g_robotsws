*** Settings ***

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature CB008064 in 5G23R4 program

Library     taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Library     XML    True
Library     taf.analyzer.pcap          WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables   ./CB008911_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${smod_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${smod_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${smod_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_path}    /tmp
${connection}    GNB_OAM
${nrbtsId}    ${tl.gnbs[0].global_bts_id}
${mrbtsId}    ${tl.gnbs[0].instance_id}
${logname}    attach.pcap
${UE_TYPE}    samsung
${scf_name}    CB008911_SCF_SBTS00.xml
${scf_path}    ${commissionings_path}/HGZ/7_5_UTE5G402T911
*** Keywords ***

Make L3 Call
    [Arguments]    ${UE_TYPE}=${UE_TYPE}    ${dltp}=${100}    ${ultp}=${10}    ${4G_check}=${False}
    ...    ${ue_index}=${0}    ${twice_flag}=${false}
    Log To Console    \n ### Prepare UE ###
    run keyword if    ${twice_flag}==${false}   power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    ...    ELSE    Log    msg=UE already prepared
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    #Log To Console    \n ###UE Start traffic ###
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=50M    duration=60
    #power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=200M    duration=60
    #log to console     \n ### Stop traffic ###
    #Run keyword and ignore error     power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}
    #Run keyword and ignore error     power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}
    log to console      n ### UE Detach ###
    Run keyword and ignore error     power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}


########## BTS config ###########
COAM Get SCF Content
    [Documentation]   export_type: configuration, configurationAndRuntimeObjects, runtimeObjects
    [Arguments]   ${export_type}=configurationAndRuntimeObjects
    ${scf_xml}   admin_cli.get_scf
    ...   export_type=${export_type}
    ...   timeout=${300}
    ...   connection=${connection}
    [Return]   ${scf_xml}

Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    admin_cli.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=${connection}


COAM Perform Delta Recommission
    [Documentation]   delta_file(string): Delta JSON or path to JSON file.
    ...   **SAMPLE DELTA:**
    ...   [
    ...       {
    ...           "distName": "MRBTS-1/LNBTS-1/LNMME-0",
    ...           "operation": "update",
    ...           "parameters": [
    ...               {
    ...                   "parameterName": "ipAddrPrim",
    ...                   "value": "10.0.1.99",
    ...                   "operation": "update"
    ...               }
    ...           ]
    ...       }
    ...   ]
    [Arguments]   ${delta_file}
    admin_cli.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}

COAM Remove All Trace Object
    ${NRCTRLTS_EXIST}   ${NRCTRLTSDU_EXIST}    ${TCEADM_EXIST}   ${NRCTRLTSCUUP_EXIST}
    ...  Check Trace Related Object Exist
    #...   ${NRSTRACECU_EXIST}   ${TCE2_EXIST}   ${TCE1_EXIST}  ${TCE_EXIST}   ${NRMTRACECU_EXIST}
    @{del_all_trace}   Create List
    Run Keyword If    ${NRCTRLTS_EXIST}    Append To List    ${del_all_trace}    ${del_nrctrlts}
    Run Keyword If    ${NRCTRLTSDU_EXIST}    Append To List    ${del_all_trace}    ${del_nrctrltsdu}
    Run Keyword If    ${TCEADM_EXIST}    Append To List    ${del_all_trace}    ${del_tceadm}
    Run Keyword If    ${NRCTRLTSCUUP_EXIST}    Append To List    ${del_all_trace}    ${del_nrctrltscuup}
    ${del_str}   Convert To String   ${del_all_trace}
    ${del_str}   Set Variable   ${del_str.replace("'","\"")}
    Run Keyword If    ${NRCTRLTS_EXIST} or ${NRCTRLTSDU_EXIST} or ${TCEADM_EXIST} or ${NRCTRLTSCUUP_EXIST}
	...    COAM Perform Delta Recommission    delta_file=${del_str}

Check Trace Related Object Exist
    ${scf_xml}   COAM Get SCF Content
    # COAM Backup Full SCF
    # ${scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    ${TCEADM_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCEADM"]
    ${NRCTRLTS_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTS"]
    #${NRSTRACECU_EXIST}   Run Keyword And Return Status
    #...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRSTRACECU"]
    #${TCE2_EXIST}   Run Keyword And Return Status
    #...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@distName="MRBTS-837/MNL-1/TCEADM-1/TCE-2"]
    ${NRMTRACECU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRMTRACECU"]
    #${TCE1_EXIST}   Run Keyword And Return Status
    #...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@distName="MRBTS-837/MNL-1/TCEADM-1/TCE-1"]
    ${NRCTRLTSDU_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSDU"]
    #${TCE_EXIST}   Run Keyword And Return Status
    #...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.mnl:TCE"]
    ${NRCTRLTSCUUP_EXIST}   Run Keyword And Return Status
    ...   XML.Element Should Exist   ${scf_xml}   cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCTRLTSCUUP"]
    [Return]   ${NRCTRLTS_EXIST}   ${NRCTRLTSDU_EXIST}  ${TCEADM_EXIST}    ${NRCTRLTSCUUP_EXIST}
    #...  ${TCE_EXIST}   ${NRSTRACECU_EXIST}   ${TCE2_EXIST}   ${TCE1_EXIST}   ${NRMTRACECU_EXIST}

COAM Add ${add_para}
    ${add_str}   Convert To String   ${add_para}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    COAM Perform Delta Recommission   delta_file=${add_str}

Measure Cell Block
    [Arguments]    ${dist_name}
    admin_cli.block_cell   ${dist_name}   connection=${connection}   timeout=${600}

Measure Cell Unblock
    [Arguments]    ${dist_name}
    admin_cli.unblock_cell   ${dist_name}   connection=${connection}   timeout=${600}

Get Cell Status
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: return cell status info DICT.
    ...                            Key are availabilityStatus,administrativeState,operationalState
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${subcells_status}    admin_cli.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate
    ...                         'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}',
    ...                         'blockingState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["blockingState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

#Cell Should Be Blocked
#    [Documentation]   Author: lanwen.cai@nokia-sbell.com
#    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=20   ${connection}=GNB_OAM
#    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
#    ...                                      cell_group_idx=${cell_group_idx}
#    ...                                      timeout=${timeout}
#    ...                                      connection=${connection}
#    ${sw_version}     admin_cli.get_sw_version    connection=${connection}
#    ${result}    run keyword and return status    should contain any
#    ...    ${sw_version}
#    ...    12.400    14.400    22R1    22R2    21B
#    ${disabled}    Set Variable If    ${result}    Disabled    disabled
#    ${offline}    Set Variable If    ${result}    Offline    off line
#    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
#    Should Be Equal As Strings  ${subcell_status["operationalState"]}    ${disabled}
#    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}    ${offline}
#    Should Be Equal As Strings  ${subcell_status["administrativeState"]}    ${unlocked}
#    Should Be Equal As Strings  ${subcell_status["blockingState"]}    Blocked
#
#Cell Should Be UnBlocked
#    [Documentation]   Author: lanwen.cai@nokia-sbell.com
#    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=20   ${connection}=GNB_OAM
#    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
#    ...                                      cell_group_idx=${cell_group_idx}
#    ...                                      timeout=${timeout}
#    ...                                      connection=${connection}
#    ${sw_version}     admin_cli.get_sw_version    connection=${connection}
#    ${result}    run keyword and return status    should contain any
#    ...    ${sw_version}
#    ...    12.400    14.400    22R1    22R2    21B
#    ${enabled}    Set Variable If    ${result}    Enabled    enabled
#    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
#    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${enabled}
#    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${unlocked}
#    Should Be Equal As Strings  ${subcell_status["blockingState"]}  Unblocked
#    run keyword if    ${result}    Should be equal as strings    ${subcell_status["availabilityStatus"]}    Online

Check bts status after block cell
    [Arguments]    ${cell_index}=${1}
    ${cell_group_idx}    Set Variable    ${${cell_index}-${1}}
    Cell Should Be Blocked    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}    connection=${connection}
    Wait For Expect Fault Present    faultId=49    timeout=120

Check bts status after unblock cell
    [Arguments]    ${cell_index}=${1}
    ${cell_group_idx}    Set Variable    ${${cell_index}-${1}}
    Cell Should Be UnBlocked    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}    connection=${connection}
    Wait For Expect Fault To Disappear    faultId=49    timeout=120

Block cell and Check status
    [Arguments]    ${dist_name}    ${cell_index}=${1}
    Measure Cell Block    ${dist_name}
    Wait Until Keyword Succeeds    3min    2s    Check bts status after block cell    cell_index=${cell_index}

Unblock cell and Check status
    [Arguments]    ${dist_name}     ${cell_index}=${1}
    Measure Cell Unblock    ${dist_name}
    Wait Until Keyword Succeeds    10min    10s    Check bts status after unblock cell    cell_index=${cell_index}

Lock&Unlock
    log to console    Lock&Unlock
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    Change Parameter    MRBTS-${nrbtsId}/NRBTS-${mrbtsId}/NRCELL-1   administrativeState    update    Locked
    sleep    5s
    Change Parameter    MRBTS-${nrbtsId}/NRBTS-${mrbtsId}/NRCELL-1   administrativeState    update    Unlocked
    sleep    5s
    Change Parameter    MRBTS-${nrbtsId}/NRBTS-${mrbtsId}/NRCELL-1   administrativeState    update    Locked
    sleep    5s
    Change Parameter    MRBTS-${nrbtsId}/NRBTS-${mrbtsId}/NRCELL-1   administrativeState    update    Unlocked
    sleep    5s
    [Teardown]    admin_cli.teardown    connection=${connection}

Block&Unblock
    log to console    Block&Unblock
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    ${cell_id_list}    Get All Cell Id
    ${cell_index_length}    get length    ${cell_id_list}
    FOR    ${cell_index}    IN RANGE    1    ${cell_index_length}+1
        Block cell and Check status    dist_name=MRBTS-${nrbtsId}/NRBTS-${mrbtsId}/NRCELL-${cell_index}
        ...        cell_index=${cell_index}
        Unblock cell and Check status    dist_name=MRBTS-${nrbtsId}/NRBTS-${mrbtsId}/NRCELL-${cell_index}
        ...        cell_index=${cell_index}
    END
    sleep    20s
    [Teardown]    admin_cli.teardown    connection=${connection}

Check FID:${FID} Raised
    ${FID}    Convert To Integer    ${FID}
    @{fault_list}    create list
    ${active_alarms}    admin_cli.get_active_alarms    connection=${connection}
    FOR    ${alarms}    IN    @{active_alarms}
        Append To List    ${fault_list}    ${alarms}[additionalFaultID]
    END
    should contain    ${fault_list}    ${FID}


########## Log Capture & Analyze###########
Identify Interface with IP
    [Documentation]  :Author: Srihari Janardhan | The keyword returns the interface name associated with an IP.
    ...    If no interface is found with the corrosponding IP, None is returned
    ...
    ...    :param ip: the ip address for which the corrosponding interface name needs to be found
    ...    :param connection: the alias to an ssh connection to the machine on which the interface name has to be determined
    ...    :return: interface name
    ...
    [Arguments]    ${ip}    ${connection}
    ${cl_output}=    ssh.execute  ip -o -4 addr show | awk '{print $2" "$4}' | grep ${ip}     connection=${connection}
    @{words}=    Split String    ${cl_output}
    ${if_name}=    Run keyword and ignore error    Set variable    ${words[0]}
    ${interface_name}=    Set variable if    '${if_name[0]}'=='PASS'    ${if_name[1]}
    [Return]    ${interface_name}

Start Wireshark Capture
    [Arguments]  ${logname}=${logname}
    ssh.Connect To    hostname=${smod_addr}
    ...               username=${smod_username}
    ...               password=${smod_password}
    ...               alias=gnb
    ${interface_name}    Identify Interface with IP    ip=${smod_addr}    connection=gnb
    ssh.send command    command=rm -rf ${gnb_path}/*.pcap     connection=gnb
    sleep    6s
    ssh.send command    command=tcpdump -i ${interface_name} -w ${gnb_path}/${logname}   connection=gnb
    [Teardown]    csn.disconnect      connection=gnb

Stop Wireshark Capture
    [Arguments]    ${logname}=${logname}
    ssh.Connect To    hostname=${smod_addr}
    ...               username=${smod_username}
    ...               password=${smod_password}
    ...               alias=gnb
    sleep    5
    ssh.send command    command=killall tcpdump     connection=gnb
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${logname}   local_path=/home/ute/piao/${logname}   connection=gnb
    sleep    3
    [Teardown]  csn.disconnect      connection=gnb

Get Wireshark Value
    [Arguments]  ${cap_file}    ${FILTER_MSG}    ${FILTER_Sepcific}    ${field_name}=_3gpp.sfn
    ${filter}    set variable    (${FILTER_MSG})&&(${FILTER_Sepcific})
    ${cmd}    set variable    /usr/bin/tshark -r {pcap_file} -Y \"${filter}\" -T pdml
    pcap.load_pcap_file    command_template=${cmd}    pcap_file=${cap_file}
    ${field_value}=    pcap.get_field_value_by_name    field_name=${field_name}    attribute_name=show
    [Return]  ${field_value}

Check TraceIds
    [Arguments]    ${trace_list}    ${cap_file}=/home/ute/piao/${logname}    ${trace_type}=Cu
    [Documentation]    Check specifid trace exists.
    ...    :param  trace_type: The type of trace record data. It could be  Cu / Du / CuUp
    ${trace_ids}=    Get Wireshark Value    cap_file=${cap_file}
    ...    field_name=nsetapx.traceId
    ...    FILTER_MSG=ntrstr    FILTER_Sepcific=nsetapx.${trace_type}VendorExtensionRecordDataType
    FOR    ${trace_id}    IN    @{trace_list}
        should contain    ${trace_ids}    ${trace_id}
    END

Check SetupSCells
    [Arguments]    ${cap_file}=/home/ute/piao/${logname}    ${trace_type}=Cu
    [Documentation]    Check specifid trace exists.
    ...    :param  trace_type: The type of trace record data. It could be  Cu / Du
    ${setupSCells}=    Get Wireshark Value    cap_file=${cap_file}
    ...    field_name=nsetapx.setupSCells
    ...    FILTER_MSG=ntrstr    FILTER_Sepcific=nsetapx.${trace_type}VendorExtensionRecordDataType && nsetapx.caConfigurationRecord
    should be true    ${setupSCells}==['7','7','7','7','7']
##########  ###########


Check CB007538
    [Arguments]    ${cap_file}=/home/ute/piao/${logname}    ${group_name}=csiReportRecord
    [Documentation]    Check specifid trace exists.
    ${trace_ids}=    Get Wireshark Value    cap_file=${cap_file}
    ...    field_name=nsetapx.traceId
    ...    FILTER_MSG=ntrstr    FILTER_Sepcific=nsetapx.${group_name}
    FOR    ${trace_id}    IN    00:00:01    00:00:02    00:00:03    00:00:04    00:00:05
        should contain    ${trace_ids}    ${trace_id}
    END


Check ueCallType
    [Arguments]    ${cap_file}=/home/ute/piao/${logname}
    [Documentation]    Check specifid trace exists.
    ...    :param  trace_type: The type of trace record data. It could be  Cu / Du
    ${ueCallType}=    Get Wireshark Value    cap_file=${cap_file}
    ...    field_name=nsetapx.ueCallType
    ...    FILTER_MSG=ntrstr    FILTER_Sepcific=nsetapx.ueCallType
    ${length}    get length   ${ueCallType}
    should be true    '${length}'=='15'
##########  ###########

Precondition
    [Arguments]
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    Adapt SCF Name By Release and Commition SCF
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    Change Parameter    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}   actPCMDReport    update    true
    Change Parameter    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}   actCellTraceReport    update    true
    Change Parameter    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}   actMDTTraceReport    update    true
#    COAM Remove All Trace Object

Teardown
    [Arguments]
    Run Keyword And Ignore Error     admin_cli.teardown    connection=${connection}

Adapt SCF Name By Release and Commition SCF
    wait until keyword succeeds    60s    2s    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    Set Suite Variable    ${sw_version}
    ${stream}    get stream from version    ${SW_version}
    Set Suite Variable    ${stream}
    ${scf_name}    Run keyword if   '${stream}'=='SBTS23R4'     set variable   CB008911_SCF_SBTS23R4.xml
    ...   ELSE IF    '${stream}'=='SBTS24R1'     set variable   CB008911_SCF_SBTS24R1.xml
    ...   ELSE        set variable   CB008911_SCF_SBTS00.xml
    Set Suite Variable    ${scf_name}
    COAM Commission with scf file    scf_file_path=${scf_path}/${scf_name}    connection=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    [Teardown]    coam.teardown    connection=GNB_OAM
