*** Settings ***
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource            taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource            ../../CB007306_OTA/Resources/CB007306_common_keyword.robot
Library             ./CB007403_common.py
Library             ute_syslog
Library             taf.config.scf.interface.scf     WITH NAME   scf
Variables          ./CB007403_modify_para.py

*** Variables ***
${CURDIR_path}                  ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip}                       ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_SSH_USERNAME}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${enb_ip}                       ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${ul_power_port_list}           ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}           ${tl.ues[0].iperf_details.ports[3:6]}
${TEST_PC_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}
${att_ipaddr}                   ${tl.attenuator.ip_addr}
${att_connection_port}          ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_api_port}                 ${tl.attenuator.port}
${att_port_5}                   ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6}                   ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7}                   ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_8}                   ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${NRBTS_ID}                     NRBTS-${tl.gnbs[0].global_bts_id}
${PositionMotion_ip1}           10.71.216.4
${PositionMotion_ip2}           10.71.216.6
${gnb1_pci}                     50
${gnb1_pci2}                    60
${gnb1_pci3}                    80
${gnb2_pci}                     70
${enb1_pci}                     100
${enb1_pci1}                    101
${enb2_pci}                     102
${filter_enb}                       x2ap || s1ap
${dl_tput_expected}             500
${ul_tput_expected}             80
${dl_send_tput}                 800M
${ul_send_tput}                 100M
${dl_exp_tput}                  500
${ul_exp_tput}                  50
@{empty_list}
${model}                     ${tl.attenuator.model}

*** Keywords ***
Setup Commission SCF
    [Arguments]     ${gnbnumber}   ${if_gnb}=${True}   ${BTS_Host}=${gNB_ip}
     ${default_scf}    CB007403_common_keyword.Get BTS Version And Perare SCF    if_gnb=${if_gnb}
     ...    gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file      scf_file_path=${default_scf}    timeout=1000
     Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Only Setup Commission SCF
    [Arguments]      ${gnbnumber}    ${if_gnb}=${True}    ${BTS_Host}=${gNB_ip}
     ${default_scf}    CB007403_common_keyword.Get BTS Version And Perare SCF    gnbnumber=${gnbnumber}    if_gnb=${if_gnb}
     ...    gNB_ip=${BTS_Host}     CURDIR_path=${CURDIR_path}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}    timeout=1000
     [Teardown]    Run keyword and ignore error     coam.teardown    connection=GNB_OAM

Get BTS Version And Perare SCF
    [Arguments]   ${gnbnumber}    ${if_gnb}=${True}    ${gNB_ip}=${gNB_ip}   ${CURDIR_path}=${CURDIR_path}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${gNB_ip}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    CB007306_common.Covert_BTS_Version      gnbnumber=${gnbnumber}    version=${version}    if_gnb=${if_gnb}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Get distname due to cell list
    [Arguments]      ${cell_group_index}=${0}  ${bts_host}=${gNB_ip}    ${username}=${gNB_username}    ${password}=${gNB_password}
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${bts_host}    username=${username}    password=${password}
    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
    ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${cell_group_index}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    ${distName_list}     create list
    FOR  ${cell}   IN    @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        ${distName}    set variable    ${eachcell['NRCELL_L']['distName']}
        append to list      ${distName_list}   ${distName}
    END
    [Return]    ${distName_list}
    [Teardown]    COAM Teardown gnb connections

Block Cell
    [Arguments]    ${dist_name}   ${cell_dist_name}    ${connection}=GNB_OAM    ${bts_host}=${gNB_ip}
    Connect to gnb coam via ssl     bts_host=${bts_host}
    ${info}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState}    set variable      ${info['stateInfo']['blockingState']}
    run keyword if    '${blockingState}'=="Unblocked"
    ...    coam.block     dist_name=${cell_dist_name}    connection=${connection}
    sleep     5s
    ${info1}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState1}    set variable      ${info1['stateInfo']['blockingState']}
    should be true    '${blockingState1}'=="Blocked"
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

UnBlock Cell
    [Arguments]    ${dist_name}   ${cell_dist_name}   ${connection}=GNB_OAM    ${bts_host}=${gNB_ip}
    Connect to gnb coam via ssl     bts_host=${bts_host}
    ${info}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState}    set variable      ${info['stateInfo']['blockingState']}
    run keyword if    '${blockingState}'=="Blocked"
    ...    coam.unblock_cell    dist_name=${cell_dist_name}    connection=${connection}
    sleep     5s
    ${info1}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState1}    set variable      ${info1['stateInfo']['blockingState']}
    should be true    '${blockingState1}'=="Unblocked"
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Adjust the HBTE attenuation value for 7403
    [Arguments]     ${value_1}=${10}    ${value_2}=${127}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...     attenuation_port_numbers=${att_connection_port}
    ...     max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_list}     Create list      ${0}    ${1}
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value_1}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        should be equal    ${value_port}    ${value_1}
    END
    ${port_list1}     Create list    ${2}    ${3}    ${4}   ${5}    ${6}    ${7}
    ${port_num1}    Get Length   ${port_list1}
    FOR    ${i}    IN RANGE    ${port_num1}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}    value=${value_2}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}
        should be equal    ${value_port}    ${value_2}
    END

Adjust the HBTE attenuation value for 7403 710
    [Arguments]     ${value_1}=${0}    ${value_2}=${127}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...     attenuation_port_numbers=${att_connection_port}
    ...     max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_list}     Create list      ${2}    ${3}
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value_1}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        should be equal    ${value_port}    ${value_1}
    END
    ${port_list1}     Create list    ${0}    ${1}    ${4}   ${5}    ${6}    ${7}
    ${port_num1}    Get Length   ${port_list1}
    FOR    ${i}    IN RANGE    ${port_num1}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}    value=${value_2}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}
        should be equal    ${value_port}    ${value_2}
    END

Adjust the HBTE attenuation value for 7403 574
    [Arguments]     ${value_1}=${0}    ${value_2}=${127}    ${value_3}=${30}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_list}     Create list      ${0}    ${1}
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value_1}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        should be equal    ${value_port}    ${value_1}
    END
    ${port_list1}     Create list    ${2}    ${3}
    ${port_num1}    Get Length   ${port_list1}
    FOR    ${i}    IN RANGE    ${port_num1}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}    value=${value_2}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}
        should be equal    ${value_port}    ${value_2}
    END
    ${port_list2}     Create list      ${4}   ${5}    ${6}    ${7}
    ${port_num2}    Get Length   ${port_list2}
    FOR    ${i}    IN RANGE    ${port_num2}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list2[${i}]}].port_no}    value=${value_3}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list2[${i}]}].port_no}
        should be equal    ${value_port}    ${value_3}
    END

Adjust the HBTE attenuation value for 7403 575
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_list}     Create list      ${0}    ${1}
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${0}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        should be equal    ${value_port}    ${0}
    END
    ${port_list1}     Create list    ${2}    ${3}
    ${port_num1}    Get Length   ${port_list1}
    FOR    ${i}    IN RANGE    ${port_num1}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}    value=${10}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}
        should be equal    ${value_port}    ${10}
    END
    ${port_list2}     Create list    ${4}    ${5}    ${6}    ${7}
    ${port_num2}    Get Length   ${port_list2}
    FOR    ${i}    IN RANGE    ${port_num2}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list2[${i}]}].port_no}    value=${127}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list2[${i}]}].port_no}
        should be equal    ${value_port}    ${127}
    END


Adjust the HBTE attenuation value for 7403 574 HO
    [Arguments]     ${value1}=${0}    ${value2}=${0}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_list1}     Create list      ${0}    ${1}
    ${port_num1}    Get Length   ${port_list1}
    FOR    ${i}    IN RANGE    ${port_num1}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}    value=${value1}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list1[${i}]}].port_no}
        should be equal    ${value_port}    ${value1}
    END
    ${port_list2}     Create list      ${4}    ${5}    ${6}    ${7}
    ${port_num2}    Get Length   ${port_list2}
    FOR    ${i}    IN RANGE    ${port_num2}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list2[${i}]}].port_no}    value=${value2}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list2[${i}]}].port_no}
        should be equal    ${value_port}    ${value2}
    END

Adjust the HBTE attenuation value for 7403 575 HO
    [Arguments]     ${value}=${0}    ${port_list1}=${0}    ${port_list2}=${1}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_list}     Create list      ${port_list1}    ${port_list2}
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        should be equal    ${value_port}    ${value}
    END

Get Alarm Info
    [Arguments]    ${timeout}=50s    ${connection}=GNB_OAM    ${faultID}=${4547}    ${BTS_Host}=${gNB2_ip}
    Connect to gnb coam via ssl    bts_host=${BTS_Host}     connection=${connection}
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=${connection}
    sleep    1s
    log     ${alarms}
    ${alarm_list}    create list
    FOR    ${item}    IN     @{alarms}
        ${fault_id}    get from dictionary    ${item}      faultId
        ${alarm_id}    get from dictionary    ${item}      alarmId
        run keyword if    '${fault_id}'=='${faultID}'    append to list    ${alarm_list}    ${alarm_id}
    END
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
    END
    [Return]    ${alarm_list}    ${fault_id_list}

check fault
    [Arguments]    ${faultID}=${4547}         ${connection}=GNB_OAM
    ${alarm_list}    ${fault_id_list}    Get Alarm Info      connection=${connection}
    list should contain value    ${fault_id_list}    ${faultID}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections     connection=${connection}

check counter phase1 increase
    ${M55601C00006}    Check PM counter result    counter_id=M55601C00006     counter_object=NCAV    index=${1}
    ${counter_value_sum}    Get length and Check sum counter value    list_input=${M55601C00006}    except_value=${1}

check counter phase2 increase
    ${M55601C00007_cell1}    Check PM counter result    counter_id=M55601C00007    counter_object=NCAV     index=${1}
    ${M55601C00007_cell2}    Check PM counter result    counter_id=M55601C00007    counter_object=NCAV     index=${1}     NRCELL=NRCELL-2
    ${M55601C00007_cell1_sum}    Get sum counter value     list_input=${M55601C00007_cell1}
    ${M55601C00007_cell2_sum}    Get sum counter value     list_input=${M55601C00007_cell2}
    ${M55601C00007_sum}     Evaluate    ${M55601C00007_cell1_sum}+${M55601C00007_cell2_sum}
    run keyword and continue on failure     should be true    ${M55601C00007_sum}==${1}

check counter phase3 increase
    ${M55601C00008_cell1}    Check PM counter result    counter_id=M55601C00008    counter_object=NCAV     index=${1}
    ${M55601C00008_cell2}    Check PM counter result    counter_id=M55601C00008    counter_object=NCAV     index=${1}     NRCELL=NRCELL-2
    ${M55601C00008_cell1_sum}    Get sum counter value     list_input=${M55601C00008_cell1}
    ${M55601C00008_cell2_sum}    Get sum counter value     list_input=${M55601C00008_cell2}
    ${M55601C00008_sum}     Evaluate    ${M55601C00008_cell1_sum}+${M55601C00008_cell2_sum}
    run keyword and continue on failure     should be true    ${M55601C00008_sum}==${1}

Check BBmod State
    [Arguments]     ${BTS_Host}=${gNB2_ip}     ${connection}=GNB_OAM
    ${bbmod_state}   Get SCF single Value from current xml file
    ...   parameter=operationalState   list_name=${None}   dist_name=${BBMOD_R_DN}   p_index=${0}
    ...   alias=${connection}    config_type=configurationAndRuntimeObjects
    should be true    '${bbmod_state}'=='disabled'

Verify BBMOD Reset
    [Arguments]     ${BTS_Host}=${gNB2_ip}     ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${BTS_Host}     connection=${connection}
    Wait Until Keyword Succeeds    5 min    10 sec    Check BBmod State     connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections     connection=${connection}

Verify BBMOD normal
    [Arguments]     ${BTS_Host}=${gNB2_ip}     ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${BTS_Host}     connection=${connection}
    ${bbmod_state}   Get SCF single Value from current xml file
    ...   parameter=operationalState   list_name=${None}   dist_name=${BBMOD_R_DN}   p_index=${0}
    ...   alias=${connection}    config_type=configurationAndRuntimeObjects
    should be true    '${bbmod_state}'=='enabled'
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections     connection=${connection}

gNB.PingOAM
    ${result}  run   command=ping ${gNB2_ip} -c 10
    should contain    ${result}    64 bytes from ${gNB2_ip}

gNB.CheckBTSReset
    ${status}    Run Keyword And Return Status    gNB.PingOAM
    Should Be True    '${status}'=='False'

gNB.CheckBTSNormal
    ${status}    Run Keyword And Return Status    gNB.PingOAM
    Should Be True    '${status}'=='True'

check case4 counter from BTSLog
    [Arguments]    ${btslog_name}=${OUTPUT_DIR}/${TEST NAME}/btslog_2083.log     ${connection}=sshtestpc
    CB007306_common_keyword.Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}
    ...     alias=${connection}
    ${outph2}    csn.Execute     command=cat ${btslog_name} | grep -i "maxNumSlCellRecActForPh2PerDay"
    ...    connection=${connection}
    Should Match Regexp    ${outph2}    [\\s\\S]*is 1, current value is 0[\\s\\S]*is 1, current value is 1
    ${outph3}    csn.Execute     command=cat ${btslog_name} | grep -i "maxNumSlCellRecActForPh3PerDay"
    ...    connection=${connection}
    Should Match Regexp    ${outph3}    [\\s\\S]*is 1, current value is 0[\\s\\S]*is 1, current value is 1
    [Teardown]    csn.disconnect    connection=${connection}

Modify ENB parameter to control UE attach
    [Arguments]   ${control_cell_Parameter}     ${enb}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter}     gNB_ip=${enb}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${control_cell_Parameter}     gNB_ip=${enb}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb}

Get initial UL and DL TP
    [Arguments]    ${cell}    ${control_cell_Parameter}   ${attached_pci}   ${sourceCellList}   ${enb}=${enb_ip}
    ...    ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=300M    ${dl_throughput}=1000M    ${gnb_index}=${0}
    ...    ${logpath}=${OUTPUT_DIR}
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    log to console    start attach...
    Modify ENB parameter to control UE attach     control_cell_Parameter=${control_cell_Parameter}    enb=${enb}
    Start wireshark capture from gNB or Enb      filename=tcpdump_attach_${cell}    alias=enb   if_gnb=${False}
    ${attach_status}    Run keyword and return status     CB007306_common_keyword.attach multi power ue    ue_num=${1}   gnb_index=${gnb_index}
    Stop wireshark capture from gNB or Enb       filename=tcpdump_attach_${cell}    alias=enb   if_gnb=${False}    logpath=${logpath}
    should be true    ${attach_status}    ${True}
    CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
    sleep    10s
    start btslog capture on ute     btslog_name=btslog_${cell}.log    log_dir=${OUTPUT_DIR}
    sleep    10s
    stop syslog     alias=ute
    sleep    3s
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_${cell}.pcap
    ...    txt_filename=tcpdump_attach_${cell}.txt    filter=${filter}    logpath=${logpath}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci}    txt_filename=tcpdump_attach_${cell}.txt    logpath=${logpath}
    ${DL_tputDataDic}    CB007403_common.get_tput_from_syslog     syslog_path=${logpath}/btslog_${cell}.log
    ...    sourceCellList=${sourceCellList}   alias=DL
    ${avg_DL_tputDataDic}    CB007403_common.get_source_tput_avg     tputDataDic=${DL_tputDataDic}
    ${UL_tputDataDic}    CB007403_common.get_tput_from_syslog     syslog_path=${logpath}/btslog_${cell}.log
    ...    sourceCellList=${sourceCellList}   alias=UL
    ${avg_UL_tputDataDic}    CB007403_common.get_source_tput_avg     tputDataDic=${UL_tputDataDic}
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    [Teardown]     stop syslog     alias=ute
    [Return]    ${avg_DL_tputDataDic}    ${avg_UL_tputDataDic}

Start tcpdump log attach UE for 7403
    [Arguments]       ${logname}    ${gnb_index}=${0}
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    Start wireshark capture from gNB or Enb      filename=tcpdump_attach_${logname}    alias=enb   if_gnb=${False}
    log to console    start attach...
    ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}    gnb_index=${gnb_index}
    Stop wireshark capture from gNB or Enb       filename=tcpdump_attach_${logname}    alias=enb
    ...    logpath=${OUTPUT_DIR}/${TEST NAME}    if_gnb=${False}
    should be true    ${attach_status}    ${True}

Start tcpdump and send DL or UL traffic for 573 001
     [Arguments]   ${NUM}   ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=${ul_send_tput}    ${dl_throughput}=${dl_send_tput}
     ...    ${cell1}=${gnb1_pci}    ${cell2}=${gnb2_pci}
     start btslog capture on ute     btslog_name=btslog_${cell1}_${cell2}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     Start wireshark capture from gNB or Enb      filename=573_ho_${cell1}_${cell2}_${NUM}    alias=enb2    if_gnb=${False}
     sleep     3s
     Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_X=${False}   start_Y=${0}     end_Y=${90}         exceed=${360}
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${270}     end_Y=${360}      exceed=${360}
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=573_ho_50_70_${NUM}     alias=enb2    if_gnb=${False}
     CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
     stop syslog     alias=ute
     sleep     5s
     start btslog capture on ute     btslog_name=btslog_${cell2}_${cell1}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...      ul_throughput=10M      dl_throughput=10M     protocol=udp
     Start wireshark capture from gNB or Enb      filename=573_ho_${cell2}_${cell1}_${NUM}    alias=enb3    if_gnb=${False}
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}     if_X=${False}   start_Y=${360}     end_Y=${270}      exceed=${360}
     Set X and Y PositionMotion    ip=${PositionMotion_ip1}     if_X=${False}   start_X=${90}      end_X=${0}        exceed=${360}
     sleep     10s
     Stop wireshark capture from gNB or Enb          filename=573_ho_${cell2}_${cell1}_${NUM}     alias=enb3    if_gnb=${False}
     CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
     stop syslog     alias=ute
#     [Teardown]    CB007306_common_keyword.detach multi power ue     ue_num=${1}

Check wiresgark log for 573 001
    ${ip_list}    Create list     ${gNB_ip}    ${gNB2_ip}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_573.pcap
    ...    txt_filename=tcpdump_attach_573.txt    filter=${filter}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_573.txt
    Check wireshark log data Flow message     sgnb_chg_flow_message=${attach_message_flow}    txt_filename=tcpdump_attach_573.txt
    ${measConfigDic}     Create dictionary
    ${measConfigDic}    Get MeasConfig From Txt N     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_attach_573.txt
    ...    measConfigDic=${measConfigDic}
    FOR    ${NUM}    IN RANGE    ${0}    ${2}    1
        CB007306_common_keyword.Convert pcap to text     pacp_filename=573_ho_50_70_${NUM}.pcap
        ...     txt_filename=573_ho_50_70_${NUM}.txt    filter=${filter}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_70}    txt_filename=573_ho_50_70_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_chg_ho_cause}    txt_filename=573_ho_50_70_${NUM}.txt
        Check wireshark log data Flow message
        ...    sgnb_chg_flow_message=${intra_freq_inter_gnb_ho_message_flow}    txt_filename=573_ho_50_70_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=573_ho_70_50_${NUM}.pcap
        ...     txt_filename=573_ho_70_50_${NUM}.txt    filter=${filter}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=573_ho_70_50_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_chg_ho_cause}    txt_filename=573_ho_70_50_${NUM}.txt
        Check wireshark log data Flow message
        ...    sgnb_chg_flow_message=${intra_freq_inter_gnb_ho_message_flow}    txt_filename=573_ho_70_50_${NUM}.txt

        ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/573_ho_50_70_${NUM}.txt
        ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/573_ho_70_50_${NUM}.txt
        ${MC_N_1}     Evaluate     1+${NUM}*2
        ${MC_N_2}     Evaluate     2+${NUM}*2
        Check measid    txt_filename=573_ho_50_70_${NUM}.txt   para1=report    para2=eventId    expect=eventA3
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_1}
        Check measid    txt_filename=573_ho_50_70_${NUM}.txt    para1=report    para2=ho_method    expect=rsrp
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_1}
        Check measid    txt_filename=573_ho_70_50_${NUM}.txt    para1=report    para2=eventId    expect=eventA3
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_2}
        Check measid    txt_filename=573_ho_70_50_${NUM}.txt    para1=report    para2=ho_method    expect=rsrp
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_2}
    END

Compare HO TP with initial TP for 573
    [Arguments]   ${sourceCellList}    ${targetCellList}   
    ...     ${avg_DL_GNB1}=${dl_exp_tput}    ${avg_UL_GNB1}=${ul_exp_tput}   
    ...     ${avg_DL_GNB2}=${dl_exp_tput}    ${avg_UL_GNB2}=${ul_exp_tput}    
    ...     ${cell1}=${gnb1_pci}    ${cell2}=${gnb2_pci}
    ${DL_tput_large}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell1}_${cell2}_0.log
    ...    sourceCellList=${sourceCellList}    targetCellList=${targetCellList}   sourcePCI=${cell1}   targetPCI=${cell2}    alias=DL
    ${DL_tput_small}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell2}_${cell1}_0.log
    ...    sourceCellList=${targetCellList}    targetCellList=${sourceCellList}    sourcePCI=${cell2}   targetPCI=${cell1}   alias=DL
    ${DL_large_status}    check_ho_tput    tputDataDic=${DL_tput_large}    source_excpted=${dl_exp_tput}    target_excpted=${dl_exp_tput}
    ${DL_small_status}    check_ho_tput    tputDataDic=${DL_tput_small}    source_excpted=${10}    target_excpted=${10}
    run keyword and continue on failure    should be true     ${DL_large_status}==${True}
    run keyword and continue on failure    should be true     ${DL_small_status}==${True}
    ${UL_tput_large}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell1}_${cell2}_1.log
    ...    sourceCellList=${sourceCellList}    targetCellList=${targetCellList}    sourcePCI=${cell1}   targetPCI=${cell2}   alias=UL
    ${UL_tput_small}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell2}_${cell1}_1.log
    ...    sourceCellList=${targetCellList}    targetCellList=${sourceCellList}    sourcePCI=${cell2}   targetPCI=${cell1}   alias=UL
    ${UL_large_status}    check_ho_tput    tputDataDic=${UL_tput_large}   source_excpted=${ul_exp_tput}    target_excpted=${ul_exp_tput}
    ${UL_small_status}    check_ho_tput    tputDataDic=${UL_tput_small}   source_excpted=${10}    target_excpted=${10}
    Run Keyword And Continue On Failure    should be true     ${UL_large_status}==${True}
    Run Keyword And Continue On Failure    should be true     ${UL_small_status}==${True}

Compare HO TP with initial TP with two gnb
    [Arguments]   ${btslog_name}   ${avg_DL_GNB1}    ${avg_UL_GNB1}   ${avg_DL_GNB2}    ${avg_UL_GNB2}
    ...      ${sourceCellList}    ${targetCellList}    ${cell1}=${gnb1_pci}    ${cell2}=${gnb2_pci}     ${is_lte_ho}=${False}
    ${DL_tput}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/${btslog_name}
    ...    sourceCellList=${sourceCellList}    targetCellList=${targetCellList}   sourcePCI=${cell1}   targetPCI=${cell2}    alias=DL
    ${DL_status}    check_ho_tput     tputDataDic=${DL_tput}    source_excpted=${dl_tput_expected}    target_excpted=${dl_tput_expected}
    ...    is_lte_ho=${is_lte_ho}
    Run Keyword And Continue On Failure    should be true     ${DL_status}==${True}
    ${UL_tput}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/${btslog_name}
    ...    sourceCellList=${sourceCellList}    targetCellList=${targetCellList}    sourcePCI=${cell1}   targetPCI=${cell2}   alias=UL
    ${UL_status}    check_ho_tput    tputDataDic=${UL_tput}   source_excpted=${ul_tput_expected}    target_excpted=${ul_tput_expected}
    ...    is_lte_ho=${is_lte_ho}
    Run Keyword And Continue On Failure    should be true     ${UL_status}==${True}

Compare HO TP with initial TP with one gnb
    [Arguments]   ${btslog_name}   ${avg_DL_GNB}    ${avg_UL_GNB}     ${CellList}    ${cell}=${gnb1_pci}    ${is_lte_ho}=${False}
    ${DL_tput}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/${btslog_name}   sourceCellList=${CellList}
    ...    targetCellList=${CellList}    alias=DL
    ${DL_status}    check_ho_tput    tputDataDic=${DL_tput}   source_excpted=${dl_tput_expected}    is_lte_ho=${is_lte_ho}
    Run Keyword And Continue On Failure    should be true     ${DL_status}==${True}
    ${UL_tput}    get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/${btslog_name}  sourceCellList=${CellList}
    ...    targetCellList=${CellList}    alias=UL
    ${UL_status}    check_ho_tput    tputDataDic=${UL_tput}   source_excpted=${ul_tput_expected}    is_lte_ho=${is_lte_ho}
    Run Keyword And Continue On Failure    should be true     ${UL_status}==${True}

Start tcpdump and send DL or UL traffic for 573_005
     [Arguments]     ${if_ul}=${False}    ${if_dl}=${True}   ${ul_throughput}=150M    ${dl_throughput}=500M
     ...    ${cell1}=${gnb1_pci}      ${cell2}=${gnb2_pci}    ${case_name}=573_005
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${cell1}_${cell2}   alias=enb1    if_gnb=${False}
     sleep     2s
     Set X and Y PositionMotion    ip=${PositionMotion_ip1}     start_X=${0}     end_X=${0}   start_Y=${90}     end_Y=${90}      exceed=${360}
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}     start_X=${0}     end_X=${0}   start_Y=${360}     end_Y=${360}      exceed=${360}
     sleep     8s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${cell1}_${cell2}    alias=enb1    if_gnb=${False}
     [Teardown]     CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}

Start tcpdump and send DL or UL traffic for 574
     [Arguments]   ${NUM}   ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=300M    ${dl_throughput}=1000M
     ...    ${enb1}=${enb1_pci}      ${enb2}=${enb2_pci}    ${case_name}=574
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     sleep    10s
     start btslog capture on ute     btslog_name=btslog_${case_name}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${enb1}_${enb2}_${NUM}    alias=enb1    if_gnb=${False}
     Start wireshark capture from gNB or Enb      filename=enb2_${case_name}_${enb1}_${enb2}_${NUM}    alias=enb2    if_gnb=${False}    index=${1}
     sleep     10s
     FOR    ${Item_Value}    IN RANGE    ${0}    ${31}    ${5}
         Adjust the HBTE attenuation value for 7403 574 HO    value1=${Item_Value}    value2=${0}
         sleep     1s
     END
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${enb1}_${enb2}_${NUM}     alias=enb1    if_gnb=${False}
     Stop wireshark capture from gNB or Enb       filename=enb2_${case_name}_${enb1}_${enb2}_${NUM}     alias=enb2    if_gnb=${False}   index=${1}

     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${enb2}_${enb1}_${NUM}     alias=enb3    if_gnb=${False}
     Start wireshark capture from gNB or Enb      filename=enb2_${case_name}_${enb2}_${enb1}_${NUM}     alias=enb4    if_gnb=${False}    index=${1}
     sleep     8s
     FOR    ${Item_Value}    IN RANGE    ${0}    ${11}    ${5}
         Adjust the HBTE attenuation value for 7403 574 HO    value1=${0}    value2=${Item_Value}
         sleep     1s
     END
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${enb2}_${enb1}_${NUM}      alias=enb3    if_gnb=${False}
     Stop wireshark capture from gNB or Enb       filename=enb2_${case_name}_${enb2}_${enb1}_${NUM}      alias=enb4    if_gnb=${False}    index=${1}
     stop syslog     alias=ute

Start tcpdump and send DL or UL traffic for 575
     [Arguments]   ${NUM}   ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=300M    ${dl_throughput}=1000M
     ...    ${enb1}=${enb1_pci}      ${enb2}=${enb1_pci1}    ${case_name}=575
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     sleep    10s
     start btslog capture on ute     btslog_name=btslog_${case_name}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${enb1}_${enb2}_${NUM}    alias=enb1    if_gnb=${False}
     sleep     10s
     Adjust the HBTE attenuation value for 7403 575 HO    value=${15}    port_list1=${2}    port_list2=${3}
     Adjust the HBTE attenuation value for 7403 575 HO    value=${15}    port_list1=${0}    port_list2=${1}
     sleep     3s
     Adjust the HBTE attenuation value for 7403 575 HO    value=${0}    port_list1=${2}    port_list2=${3}
     Adjust the HBTE attenuation value for 7403 575 HO    value=${30}    port_list1=${0}    port_list2=${1}
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${enb1}_${enb2}_${NUM}     alias=enb1    if_gnb=${False}

     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${enb2}_${enb1}_${NUM}     alias=enb3    if_gnb=${False}
     sleep     8s
     Adjust the HBTE attenuation value for 7403 575 HO    value=${15}    port_list1=${0}    port_list2=${1}
     Adjust the HBTE attenuation value for 7403 575 HO    value=${15}    port_list1=${2}    port_list2=${3}
     sleep     3s     
     Adjust the HBTE attenuation value for 7403 575 HO     value=${0}    port_list1=${0}    port_list2=${1}
     Adjust the HBTE attenuation value for 7403 575 HO     value=${30}    port_list1=${2}    port_list2=${3}
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${enb2}_${enb1}_${NUM}      alias=enb3    if_gnb=${False}
     stop syslog     alias=ute

Start tcpdump and send DL or UL traffic for 1094
     [Arguments]   ${NUM}   ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=${ul_send_tput}    ${dl_throughput}=${dl_send_tput}
     ...    ${cell1}=${gnb1_pci}      ${cell2}=${gnb1_pci3}    ${case_name}=1094     ${ip}=${PositionMotion_ip2}
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     sleep    10s
     start btslog capture on ute     btslog_name=btslog_${case_name}_${cell1}_${cell2}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}    alias=enb1    if_gnb=${False}
     sleep     10s
     Set X and Y PositionMotion    ip=${ip}     start_X=${90}     end_X=${90}   start_Y=${360}     end_Y=${360}      exceed=${360}
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}     alias=enb1    if_gnb=${False}
     stop syslog     alias=ute
     sleep    5s
     start btslog capture on ute     btslog_name=btslog_${case_name}_${cell2}_${cell1}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}     alias=enb3    if_gnb=${False}
     sleep     10s
     positionerDemo.setYPositionMotion     ip=${ip}      start=${270}   end=${270}    speed=${5}    loopCount=${1}    exceed=${360}
     positionerDemo.setXPositionMotion     ip=${ip}      start=${0}     end=${0}      speed=${5}    loopCount=${1}    exceed=${360}
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}      alias=enb3    if_gnb=${False}
     stop syslog     alias=ute

Start tcpdump and send DL or UL traffic cell 50 to cell 60
     [Arguments]   ${NUM}   ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=100M    ${dl_throughput}=400M
     ...    ${cell1}=${gnb1_pci}      ${cell2}=${gnb1_pci2}    ${case_name}=1416
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     sleep    10s
     start btslog capture on ute     btslog_name=btslog_${case_name}_${cell1}_${cell2}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}    alias=enb1    if_gnb=${False}
     sleep     10s
     Set X and Y PositionMotion    ip=${PositionMotion_ip1}     start_X=${90}     end_X=${90}   start_Y=${0}     end_Y=${0}      exceed=${360}
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}     start_X=${0}      end_X=${0}    start_Y=${360}     end_Y=${360}      exceed=${360}
     sleep     15s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}     alias=enb1    if_gnb=${False}
     stop syslog     alias=ute
     start btslog capture on ute     btslog_name=btslog_${case_name}_${cell2}_${cell1}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}     alias=enb3    if_gnb=${False}
     sleep     10s
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}     start_X=${0}     end_X=${0}   start_Y=${275}     end_Y=${275}      exceed=${360}
     Set X and Y PositionMotion    ip=${PositionMotion_ip1}     start_X=${0}      end_X=${0}    start_Y=${0}     end_Y=${0}      exceed=${360}
     sleep     15s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}      alias=enb3    if_gnb=${False}
     stop syslog     alias=ute
     sleep     15s

Start tcpdump and send DL or UL traffic for 710
     [Arguments]    ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=150M    ${dl_throughput}=600M    ${case_name}=710
     power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
     CB007306_common_keyword.detach multi power ue     ue_num=${1}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}    alias=enb   if_gnb=${False}
     log to console    start attach...
     ${attach_status}    Run keyword and return status    CB007306_common_keyword.attach multi power ue    ue_num=${1}
     should be true    ${attach_status}    ${True}
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     sleep     10s
     start btslog capture on ute     btslog_name=btslog_${case_name}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     sleep     10s
     Set X and Y PositionMotion    ip=${PositionMotion_ip2}      if_X=${False}     start_Y=${335}     end_Y=${270}      exceed=${360}
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}    alias=enb    if_gnb=${False}
     stop syslog     alias=ute
     sleep    5s
     CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
     [Teardown]     run keyword if    ${attach_status}==${False}        Stop wireshark capture from gNB or Enb
     ...    filename=enb1_${case_name}    alias=enb    if_gnb=${False}

Start tcpdump and send DL or UL traffic for 710_014
     [Arguments]   ${NUM}   ${if_ul}=${True}    ${if_dl}=${True}   ${ul_throughput}=50M    ${dl_throughput}=600M
     ...    ${cell1}=${gnb2_pci}      ${cell2}=${gnb1_pci2}    ${case_name}=710_014     ${ip}=${PositionMotion_ip1}
     CB007306_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
     ...     ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}      protocol=udp
     sleep    10s
     start btslog capture on ute     btslog_name=btslog_${case_name}_${cell1}_${cell2}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}    alias=enb1    if_gnb=${False}
     sleep     10s
     Set X and Y PositionMotion    ip=${ip}     start_X=${90}     end_X=${90}   start_Y=${0}     end_Y=${0}      exceed=${360}
     sleep     10s
     Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}     alias=enb1    if_gnb=${False}
     stop syslog     alias=ute
     #sleep     3s
     #start btslog capture on ute     btslog_name=btslog_${case_name}_${cell2}_${cell1}_${NUM}.log    log_dir=${OUTPUT_DIR}/${TEST NAME}
     #Start wireshark capture from gNB or Enb      filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}     alias=enb3    if_gnb=${False}
     #sleep     10s
     #positionerDemo.setYPositionMotion     ip=${ip}      start=${90}   end=${90}    speed=${3}    loopCount=${1}    exceed=${360}
     #positionerDemo.setXPositionMotion     ip=${ip}      start=${0}     end=${0}      speed=${3}    loopCount=${1}    exceed=${360}
     #sleep     10s
     #Stop wireshark capture from gNB or Enb       filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}      alias=enb3    if_gnb=${False}
     #stop syslog     alias=ute
     sleep      15s

Check LTEMO PM counter result
    [Arguments]    ${counter_id}    ${index}=${1}    ${enb}=${False}    ${BTS}=BTS    ${counter_object}=LTEMO    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${counter_values}=    coam.get pm counters   counter_ids=${counter_id}    timeout=120    connection=${connection}
    ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${0}
    ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${0}].instance_id}
    ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${0}].global_bts_id}
    ${result}    run keyword if    ${is_large_24R1_release}
    ...    Get Dictionary Values   ${counter_values['${BTS}']['${MR_BTS}']['${NR_BTS}']['${counter_object}']['${counter_id}']}
    ...    ELSE    Get Dictionary Values   ${counter_values['${BTS}']['${BTS}']['${NRBTS_ID}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections   connection=${connection}

Check NX2CC PM counter result
    [Arguments]    ${counter_id}    ${index}=${1}    ${enb}=${False}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-1    ${counter_object}=NX2CC    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${counter_values}=    coam.get pm counters   counter_ids=${counter_id}    timeout=120    connection=${connection}
    ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${0}
    ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${0}].instance_id}
    ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${0}].global_bts_id}
    ${result}    run keyword if    ${is_large_24R1_release}
    ...    Get Dictionary Values   ${counter_values['${BTS}']['${MR_BTS}']['${NR_BTS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    ...    ELSE    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections   connection=${connection}

check counter for 574
    ${M55112C03501}    Check NX2CC PM counter result    counter_id=M55112C03501
    ${M55112C03502}    Check NX2CC PM counter result    counter_id=M55112C03502
    ${M55128C00502}    Check LTEMO PM counter result    counter_id=M55128C00502
    ${M55128C00503}    Check LTEMO PM counter result    counter_id=M55128C00503
    ${M55128C00504}    Check LTEMO PM counter result    counter_id=M55128C00504
    ${M55112C03501_sum}    Get sum counter value    ${M55112C03501}
    ${M55112C03502_sum}    Get sum counter value    ${M55112C03502}
    ${M55128C00502_sum}    Get sum counter value    ${M55128C00502}
    ${M55128C00503_sum}    Get sum counter value    ${M55128C00503}
    ${M55128C00504_sum}    Get sum counter value    ${M55128C00504}
    run keyword and continue on failure     should be true     ${M55112C03501_sum}==${4}
    run keyword and continue on failure     should be true     ${M55112C03502_sum}==${4}
    run keyword and continue on failure     should be true     ${M55128C00502_sum}==${4}
    run keyword and continue on failure     should be true     ${M55128C00503_sum}==${4}
    run keyword and continue on failure     should be true     ${M55128C00504_sum}==${4}

check counter for 575
    [Arguments]     ${M55112C04001}    ${M55112C04002}    ${M55112C00003}    ${M55112C00004}
    ${M55112C04001_2}    Check NX2CC PM counter result    counter_id=M55112C04001
    ${M55112C04002_2}    Check NX2CC PM counter result    counter_id=M55112C04002
    ${M55112C00003_2}    Check NX2CC PM counter result    counter_id=M55112C00003
    ${M55112C00004_2}    Check NX2CC PM counter result    counter_id=M55112C00004
    ${M55112C04001_2_sum}    Get sum counter value    ${M55112C04001_2}
    ${M55112C04002_2_sum}    Get sum counter value    ${M55112C04002_2}
    ${M55112C00003_2_sum}    Get sum counter value    ${M55112C00003_2}
    ${M55112C00004_2_sum}    Get sum counter value    ${M55112C00004_2}
    ${M55112C04001_diff}    Evaluate    ${M55112C04001_2_sum}-${M55112C04001}
    ${M55112C04002_diff}    Evaluate    ${M55112C04002_2_sum}-${M55112C04002}
    ${M55112C00003_diff}    Evaluate    ${M55112C00003_2_sum}-${M55112C00003}
    ${M55112C00004_diff}    Evaluate    ${M55112C00004_2_sum}-${M55112C00004}
    run keyword and continue on failure     should be true     ${M55112C04001_diff}==${4}
    run keyword and continue on failure     should be true     ${M55112C04002_diff}==${4}
    run keyword and continue on failure     should be true     ${M55112C00003_diff}==${1}
    run keyword and continue on failure     should be true     ${M55112C00004_diff}==${1}
    ${M55128C00004}    Check LTEMO PM counter result    counter_id=M55128C00004
    ${M55128C00002}    Check LTEMO PM counter result    counter_id=M55128C00002
    ${M55128C00004_sum}    Get sum counter value    ${M55128C00004}
    ${M55128C00002_sum}    Get sum counter value    ${M55128C00002}
    run keyword and continue on failure     should be true     ${M55128C00004_sum}==${4}
    run keyword and continue on failure     should be true     ${M55128C00002_sum}==${4}

check counter for 1094
    ${M55120C00001_cell1}     Check NX2CC PM counter result    counter_id=M55120C00001    counter_object=NINFC
    ${M55120C00001_cell21}    Check NX2CC PM counter result    counter_id=M55120C00001    counter_object=NINFC    NRCELL=NRCELL-21
    ${M55120C00001_cell1_sum}     Get sum counter value    ${M55120C00001_cell1}
    ${M55120C00001_cell21_sum}    Get sum counter value    ${M55120C00001_cell21}
    run keyword and continue on failure     should be true     ${M55120C00001_cell1_sum}==${1}
    run keyword and continue on failure     should be true     ${M55120C00001_cell21_sum}==${1}

check counter for 1416
    Wait for counter to be gathered after guard peroid
    ${M55114C00501_cell1}       Check NX2CC PM counter result    counter_id=M55114C00501      counter_object=RACCU
    ${M55114C00502_cell1}       Check NX2CC PM counter result    counter_id=M55114C00502      counter_object=RACCU
    ${M55114C00503_cell1}       Check NX2CC PM counter result    counter_id=M55114C00503      counter_object=RACCU
    ${M55114C00504_cell1}       Check NX2CC PM counter result    counter_id=M55114C00504      counter_object=RACCU
    ${M55114C00501_cell11}      Check NX2CC PM counter result    counter_id=M55114C00501      counter_object=RACCU     NRCELL=NRCELL-11
    ${M55114C00502_cell11}      Check NX2CC PM counter result    counter_id=M55114C00502      counter_object=RACCU     NRCELL=NRCELL-11
    ${M55114C00503_cell11}      Check NX2CC PM counter result    counter_id=M55114C00503      counter_object=RACCU     NRCELL=NRCELL-11
    ${M55114C00504_cell11}      Check NX2CC PM counter result    counter_id=M55114C00504      counter_object=RACCU     NRCELL=NRCELL-11
    ${M55114C00501_cell1_sum}     Get sum counter value    ${M55114C00501_cell1}
    ${M55114C00502_cell1_sum}     Get sum counter value    ${M55114C00502_cell1}
    ${M55114C00503_cell1_sum}     Get sum counter value    ${M55114C00503_cell1}
    ${M55114C00504_cell1_sum}     Get sum counter value    ${M55114C00504_cell1}
    ${M55114C00501_cell11_sum}     Get sum counter value    ${M55114C00501_cell11}
    ${M55114C00502_cell11_sum}     Get sum counter value    ${M55114C00502_cell11}
    ${M55114C00503_cell11_sum}     Get sum counter value    ${M55114C00503_cell11}
    ${M55114C00504_cell11_sum}     Get sum counter value    ${M55114C00504_cell11}
    run keyword and continue on failure     should be true     ${M55114C00501_cell1_sum}==${1}
    run keyword and continue on failure     should be true     ${M55114C00502_cell1_sum}==${1}
    run keyword and continue on failure     should be true     ${M55114C00503_cell1_sum}==${2}
    run keyword and continue on failure     should be true     ${M55114C00504_cell1_sum}==${2}
    run keyword and continue on failure     should be true     ${M55114C00501_cell11_sum}==${0}
    run keyword and continue on failure     should be true     ${M55114C00502_cell11_sum}==${0}
    run keyword and continue on failure     should be true     ${M55114C00503_cell11_sum}==${2}
    run keyword and continue on failure     should be true     ${M55114C00504_cell11_sum}==${2}

Check LTE PCI attach log
    [Arguments]   ${log_name}    ${except_LTE_btsid}   ${except_LTE_lcrid}=${1}    ${connection}=ute
    ...    ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    CB007306_common_keyword.Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
    ...    password=${TEST_PC_PASSWORD}    alias=${connection}
    csn.Send Command    command=cat ${logpath}/${log_name} | grep cell-ID | cut -d ':' -f 2|awk '{print}'|sed 's/^[ \t]*//g'|sort -n|uniq
    ...    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${LTE_btsid}     ${LTE_lcrid}     Check_LTE_Cell_ID    cell_id=${data}
    run keyword and continue on failure     should be equal as strings    ${LTE_btsid}    ${except_LTE_btsid}
    run keyword and continue on failure     should be equal as strings    ${LTE_lcrid}    ${except_LTE_lcrid}
    [Teardown]    csn.Disconnect    connection=${connection}

Get actual value from Search result
    [Arguments]    ${log_path}   ${parameters}   ${get_value}
    ${actual_value}     Check_Wireshark_Parameter_From_Txt     parameters=${parameters}
    ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/${log_path}
    ${actual_value}    get from dictionary    ${actual_value}    resultSearch
    ${actual_value}    get from dictionary    ${actual_value}[0]    actual_value
    ${actual_value}    get from dictionary    ${actual_value}    ${get_value}
    [Return]   ${actual_value}

Check wiresgark log and btslog for 573_005
    [Arguments]     ${cell1}=${gnb1_pci}      ${cell2}=${gnb2_pci}     ${case_name}=573_005
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_${case_name}.pcap
    ...    txt_filename=tcpdump_attach_${case_name}.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_${case_name}.txt
    CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell1}_${cell2}.pcap
    ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_chg_ho_cause}    txt_filename=enb1_${case_name}_${cell1}_${cell2}.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${sgnb_chg_ho_refuse}    txt_filename=enb1_${case_name}_${cell1}_${cell2}.txt
    Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_573_005}
    ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}.txt
    ${measConfigDic}     Create dictionary
    ${measConfigDic}    Get MeasConfig From Txt N      measConfigDic=${measConfigDic}
    ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_attach_${case_name}.txt
    Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}.txt   para1=report    para2=eventId    expect=eventA3
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
    Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}.txt    para1=report    para2=ho_method    expect=rsrp
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1

Check wiresgark log and btslog for 574
    [Arguments]    ${avg_DL_GNB}=${dl_exp_tput}    ${avg_UL_GNB}=${ul_exp_tput}    ${enb1}=${enb1_pci}      ${enb2}=${enb2_pci}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_574.pcap
    ...    txt_filename=tcpdump_attach_574.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_574.txt
    Check LTE PCI attach log     log_name=tcpdump_attach_574.txt    except_LTE_btsid=${10705}     except_LTE_lcrid=${1}
    ${SgNBSecurityKey_attach}     Get actual value from Search result     log_path=tcpdump_attach_574.txt   parameters=${SgNBSecurityKey}
    ...    get_value=SgNBSecurityKey
    ${before_value}    set variable     ${SgNBSecurityKey_attach}
    FOR    ${NUM}    IN RANGE    ${0}    ${2}    1
        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_574_${enb1}_${enb2}_${NUM}.pcap
        ...    txt_filename=enb1_574_${enb1}_${enb2}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${enb1_ho_enb2_check_for_574}    txt_filename=enb1_574_${enb1}_${enb2}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_source}
        ...    txt_filename=enb1_574_${enb1}_${enb2}_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb2_574_${enb1}_${enb2}_${NUM}.pcap
        ...    txt_filename=enb2_574_${enb1}_${enb2}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=enb2_574_${enb1}_${enb2}_${NUM}.txt
        ${SgNBSecurityKey_enb1_enb2}     Get actual value from Search result    log_path=enb2_574_${enb1}_${enb2}_${NUM}.txt
        ...     parameters=${SgNBSecurityKey}    get_value=SgNBSecurityKey
        Run Keyword And Continue On Failure    should be true    '${before_value}'!='${SgNBSecurityKey_enb1_enb2}'
        ${before_value}    set variable     ${SgNBSecurityKey_enb1_enb2}
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_target}
        ...    txt_filename=enb2_574_${enb1}_${enb2}_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb2_574_${enb2}_${enb1}_${NUM}.pcap
        ...    txt_filename=enb2_574_${enb2}_${enb1}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${enb2_ho_enb1_check_for_574}    txt_filename=enb2_574_${enb2}_${enb1}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_source}
        ...    txt_filename=enb2_574_${enb2}_${enb1}_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_574_${enb2}_${enb1}_${NUM}.pcap
        ...    txt_filename=enb1_574_${enb2}_${enb1}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=enb1_574_${enb2}_${enb1}_${NUM}.txt
        ${SgNBSecurityKey_enb2_enb1}     Get actual value from Search result    log_path=enb1_574_${enb2}_${enb1}_${NUM}.txt
        ...     parameters=${SgNBSecurityKey}    get_value=SgNBSecurityKey
        Run Keyword And Continue On Failure    should be true    '${before_value}'!='${SgNBSecurityKey_enb2_enb1}'
        ${before_value}    set variable     ${SgNBSecurityKey_enb2_enb1}
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_target}
        ...    txt_filename=enb1_574_${enb2}_${enb1}_${NUM}.txt

        Compare HO TP with initial TP with one gnb    btslog_name=btslog_574_${NUM}.log
        ...    avg_DL_GNB=${avg_DL_GNB}    avg_UL_GNB=${avg_UL_GNB}    CellList=${GNB1_cell_List}    is_lte_ho=${True}
    END

Check wiresgark log and btslog for 575
    [Arguments]      ${avg_DL_GNB}=${dl_exp_tput}    ${avg_UL_GNB}=${ul_exp_tput}    ${enb1}=${enb1_pci}      ${enb2}=${enb1_pci1}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_575.pcap
    ...    txt_filename=tcpdump_attach_575.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_575.txt
    Check LTE PCI attach log     log_name=tcpdump_attach_575.txt    except_LTE_btsid=${10705}    except_LTE_lcrid=${1}
    ${SgNBSecurityKey_attach}     Get actual value from Search result    log_path=tcpdump_attach_575.txt
    ...     parameters=${SgNBSecurityKey}    get_value=SgNBSecurityKey
    ${DL_GTP_TEIDatMCG}     Get actual value from Search result    log_path=tcpdump_attach_575.txt
    ...     parameters=${DL_GTP_TEIDatMCG}    get_value=gTP-TEID
    ${UL_GTP_TEIDatPDCP}     Get actual value from Search result    log_path=tcpdump_attach_575.txt
    ...     parameters=${UL_GTP_TEIDatPDCP}    get_value=gTP-TEID
    ${before_SgNBSecurityKey}      set variable       ${SgNBSecurityKey_attach}
    ${before_DL_GTP_TEIDatMCG}     set variable       ${DL_GTP_TEIDatMCG}
    ${before_UL_GTP_TEIDatPDCP}    set variable       ${UL_GTP_TEIDatPDCP}
    FOR    ${NUM}    IN RANGE    ${0}    ${2}    1
        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_575_${enb1}_${enb2}_${NUM}.pcap
        ...    txt_filename=enb1_575_${enb1}_${enb2}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50_Modification}    txt_filename=enb1_575_${enb1}_${enb2}_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${enb1_check_for_575}    txt_filename=enb1_575_${enb1}_${enb2}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_575}    txt_filename=enb1_575_${enb1}_${enb2}_${NUM}.txt
        ${SgNBSecurityKey_enb1_ho1}     Get actual value from Search result    log_path=enb1_575_${enb1}_${enb2}_${NUM}.txt
        ...     parameters=${SgNBSecurityKey_Modification}    get_value=sgNB-SecurityKey
        Run Keyword And Continue On Failure    should be true    '${before_SgNBSecurityKey}'!='${SgNBSecurityKey_enb1_ho1}'
        ${before_SgNBSecurityKey}    set variable     ${SgNBSecurityKey_enb1_ho1}
        ${DL_GTP_TEIDatMCG_ho1}     Get actual value from Search result    log_path=enb1_575_${enb1}_${enb2}_${NUM}.txt
        ...     parameters=${DL_GTP_TEIDatMCG_Modification}    get_value=gTP-TEID
        Run Keyword And Continue On Failure    should be true    '${before_DL_GTP_TEIDatMCG}'!='${DL_GTP_TEIDatMCG_ho1}'
        ${before_DL_GTP_TEIDatMCG}    set variable     ${DL_GTP_TEIDatMCG_ho1}
        ${UL_GTP_TEIDatPDCP_ho1}     Get actual value from Search result    log_path=enb1_575_${enb1}_${enb2}_${NUM}.txt
        ...     parameters=${UL_GTP_TEIDatPDCP_Modification}    get_value=gTP-TEID
        Run Keyword And Continue On Failure    should be true    '${before_UL_GTP_TEIDatPDCP}'!='${UL_GTP_TEIDatPDCP_ho1}'
        ${before_UL_GTP_TEIDatPDCP}    set variable     ${UL_GTP_TEIDatPDCP_ho1}

        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_575_${enb2}_${enb1}_${NUM}.pcap
        ...    txt_filename=enb1_575_${enb2}_${enb1}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50_Modification}    txt_filename=enb1_575_${enb2}_${enb1}_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${enb1_check_for_575}    txt_filename=enb1_575_${enb2}_${enb1}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_575}    txt_filename=enb1_575_${enb2}_${enb1}_${NUM}.txt
        ${SgNBSecurityKey_enb1_ho2}     Get actual value from Search result    log_path=enb1_575_${enb2}_${enb1}_${NUM}.txt
        ...     parameters=${SgNBSecurityKey_Modification}    get_value=sgNB-SecurityKey
        Run Keyword And Continue On Failure    should be true    '${before_SgNBSecurityKey}'!='${SgNBSecurityKey_enb1_ho2}'
        ${before_SgNBSecurityKey}    set variable     ${SgNBSecurityKey_enb1_ho2}
        ${DL_GTP_TEIDatMCG_ho2}     Get actual value from Search result    log_path=enb1_575_${enb2}_${enb1}_${NUM}.txt
        ...     parameters=${DL_GTP_TEIDatMCG_Modification}    get_value=gTP-TEID
        Run Keyword And Continue On Failure    should be true    '${before_DL_GTP_TEIDatMCG}'!='${DL_GTP_TEIDatMCG_ho2}'
        ${before_DL_GTP_TEIDatMCG}    set variable     ${DL_GTP_TEIDatMCG_ho2}
        ${UL_GTP_TEIDatPDCP_ho2}     Get actual value from Search result    log_path=enb1_575_${enb2}_${enb1}_${NUM}.txt
        ...     parameters=${UL_GTP_TEIDatPDCP_Modification}    get_value=gTP-TEID
        Run Keyword And Continue On Failure    should be true    '${before_UL_GTP_TEIDatPDCP}'!='${UL_GTP_TEIDatPDCP_ho2}'
        ${before_UL_GTP_TEIDatPDCP}    set variable     ${UL_GTP_TEIDatPDCP_ho2}

        Compare HO TP with initial TP with one gnb    btslog_name=btslog_575_${NUM}.log
        ...    avg_DL_GNB=${avg_DL_GNB}    avg_UL_GNB=${avg_UL_GNB}    CellList=${GNB1_cell_List}    is_lte_ho=${True}
    END

Check DL and UL counter for 573 001
    [Arguments]      ${cell1}=${gnb1_pci}    ${cell2}=${gnb2_pci}
    ${M55316C05001}    Check PM counter result    counter_id=M55316C05001    counter_object=NCADU
    Check counter value    ${M55316C05001}
    ${M55316C06001}    Check PM counter result    counter_id=M55316C06001    counter_object=NCADU
    Check counter value    ${M55316C06001}
#    ${DL_nrCellId_list}    create list
#    ${DL_nrCellId_list}    Get nrcellid with the lcrid      bts_host=${gNB_ip}
#    ${UL_nrCellId_list}    Get nrcellid with the lcrid      bts_host=${gNB_ip}
#    ${M55316C03003}    Check PM counter result    counter_id=M55316C03003    counter_object=NCADU
#    ${M55316C03003_sum}    Get sum counter value    ${M55316C03003}
#    ${M55316C04001}    Check PM counter result    counter_id=M55316C04001    counter_object=NCADU
#    ${M55316C04001_sum}    Get sum counter value    ${M55316C04001}
#    ${DLcounter1}    get_720_counter_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell1}_${cell2}_0.log
#    ...    celllist=${GNB1_cell_List}   alias=DL
#    ${DLcounter2}    get_720_counter_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell2}_${cell1}_0.log
#    ...    celllist=${GNB1_cell_List}   alias=DL
#    ${ULcounter1}    get_720_counter_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell1}_${cell2}_1.log
#    ...    celllist=${GNB2_cell_List}   alias=UL
#    ${ULcounter2}    get_720_counter_from_syslog     syslog_path=${OUTPUT_DIR}/${TEST NAME}/btslog_${cell2}_${cell1}_1.log
#    ...    celllist=${GNB2_cell_List}   alias=UL
#    ${DLcounterdif}    Evaluate   abs(${DLcounter1}+${DLcounter2}-${M55316C03003_sum})
#    ${ULcounterdif}    Evaluate   abs(${ULcounter1}+${ULcounter2}+${M55316C03003_sum}-${M55316C04001_sum})
#    run keyword and continue on failure     should be true     ${DLcounterdif}<=50
#    run keyword and continue on failure     should be true     ${ULcounterdif}<=50

Check wiresgark log and btslog for 1094
    [Arguments]     ${cell1}=${gnb1_pci}      ${cell2}=${gnb1_pci3}     ${case_name}=1094
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_${case_name}.pcap
    ...    txt_filename=tcpdump_attach_${case_name}.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_${case_name}.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${SCELL_ARFCN_LIST_FOR_2518}    txt_filename=tcpdump_attach_${case_name}.txt
    FOR    ${NUM}    IN RANGE    ${0}    ${1}    1
        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.pcap
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_80_ModificationRequired}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_1094}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.pcap
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50_ModificationRequired}
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_1094}
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt

        run keyword and continue on failure    Compare HO TP with initial TP with two gnb
        ...     btslog_name=btslog_${case_name}_${cell1}_${cell2}_${NUM}.log
        ...     avg_DL_GNB1=${dl_exp_tput}       avg_UL_GNB1=${ul_exp_tput}
        ...     avg_DL_GNB2=${dl_exp_tput}       avg_UL_GNB2=${ul_exp_tput}
        ...     sourceCellList=${GNB1_cell_List}         targetCellList=${GNB1_cell_List_group3}
        run keyword and continue on failure    Compare HO TP with initial TP with two gnb
        ...     btslog_name=btslog_${case_name}_${cell2}_${cell1}_${NUM}.log
        ...     avg_DL_GNB1=${dl_exp_tput}       avg_UL_GNB1=${ul_exp_tput}
        ...     avg_DL_GNB2=${dl_exp_tput}       avg_UL_GNB2=${ul_exp_tput}
        ...     sourceCellList=${GNB1_cell_List_group3}         targetCellList=${GNB1_cell_List}
    END

Check wiresgark log and btslog for 1416
    [Arguments]     ${cell1}=${gnb1_pci}      ${cell2}=${gnb1_pci2}     ${case_name}=1416
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_${case_name}.pcap
    ...    txt_filename=tcpdump_attach_${case_name}.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=tcpdump_attach_${case_name}.txt
    FOR    ${NUM}    IN RANGE    ${0}    ${1}    1
        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.pcap
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_60_ModificationRequired}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_1094}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.pcap
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50_ModificationRequired}
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_1094}
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt

        run keyword and continue on failure    Compare HO TP with initial TP with two gnb
        ...     btslog_name=btslog_${case_name}_${cell1}_${cell2}_${NUM}.log
        ...     avg_DL_GNB1=${300}       avg_UL_GNB1=${80}
        ...     avg_DL_GNB2=${300}       avg_UL_GNB2=${80}
        ...     sourceCellList=${GNB1_cell_50}         targetCellList=${GNB1_cell_60}
        ...     cell1=${cell1}    cell2=${cell2}
        run keyword and continue on failure    Compare HO TP with initial TP with two gnb
        ...     btslog_name=btslog_${case_name}_${cell2}_${cell1}_${NUM}.log
        ...     avg_DL_GNB1=${300}       avg_UL_GNB1=${80}
        ...     avg_DL_GNB2=${300}       avg_UL_GNB2=${80}
        ...     sourceCellList=${GNB1_cell_60}         targetCellList=${GNB1_cell_50}
        ...     cell1=${cell2}    cell2=${cell1}
    END

Check wiresgark log and btslog for 710
    [Arguments]       ${case_name}=710
    CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}.pcap
    ...    txt_filename=enb1_${case_name}.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=enb1_${case_name}.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${spid_710}    txt_filename=enb1_${case_name}.txt
    CB007306_common.remove_repeat_measurement_report     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${measGap_710}    txt_filename=enb1_${case_name}.txt
    ${measConfigDic}     Create dictionary
    ${measConfigDic}    Get MeasConfig From Txt N      measConfigDic=${measConfigDic}
    ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}.txt
    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}.txt   para1=report    para2=eventId    expect=eventA2
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}.txt    para1=report    para2=ho_method    expect=rsrp
    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=1
    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}.txt   para1=report    para2=eventId    expect=eventA1
    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=2
    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}.txt    para1=report    para2=ho_method    expect=rsrp
    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=2
    ${measid}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2078299    eventId=eventA3    ho_method=rsrp    n=2
    Run Keyword And Continue On Failure    should not be true     ${measid}==${-1}
    ${measid1}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2074267    eventId=eventA3    ho_method=rsrp    n=2
    Run Keyword And Continue On Failure    should not be true     ${measid1}==${-1}

Check wiresgark log and btslog for 710_001
    [Arguments]       ${cell1}=${gnb1_pci}      ${cell2}=${gnb1_pci2}     ${case_name}=710_001
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_${case_name}.pcap
    ...    txt_filename=enb1_${case_name}.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50}    txt_filename=enb1_${case_name}.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${spid_710}    txt_filename=enb1_${case_name}.txt
#    CB007306_common.remove_repeat_measurement_report     txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}.txt
    ${measConfigDic}     Create dictionary
    ${measConfigDic}    Get MeasConfig From Txt N      measConfigDic=${measConfigDic}
    ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}.txt
    FOR    ${NUM}    IN RANGE    ${0}    ${1}    1
        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.pcap
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_60_ModificationRequired}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${measGap_710}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_710_001}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt

        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.pcap
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_50_ModificationRequired}
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_710_001}
        ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt

        ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        ${MC_N_1}     Evaluate     1+${NUM}*4
        ${MC_N_2}     Evaluate     2+${NUM}*4
        ${MC_N_3}     Evaluate     3+${NUM}*4
        ${MC_N_4}     Evaluate     4+${NUM}*4
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_1}    para1=report    para2=eventId    expect=eventA2
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_1}    para1=report    para2=ho_method    expect=rsrp
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_2}    para1=report    para2=eventId    expect=eventA3
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_2}    para1=report    para2=ho_method    expect=rsrp

        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_3}    para1=report    para2=eventId    expect=eventA2
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_3}    para1=report    para2=ho_method    expect=rsrp
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_4}    para1=report    para2=eventId    expect=eventA3
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_4}    para1=report    para2=ho_method    expect=rsrp

        ${measid}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2078299    eventId=eventA3    ho_method=rsrp    n=${MC_N_2}
        Run Keyword And Continue On Failure    should not be true     ${measid}==${-1}
        ${measid1}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2071387    eventId=eventA3    ho_method=rsrp    n=${MC_N_4}
        Run Keyword And Continue On Failure    should not be true     ${measid1}==${-1}

        run keyword and continue on failure    Compare HO TP with initial TP with two gnb
        ...     btslog_name=btslog_${case_name}_${cell1}_${cell2}_${NUM}.log
        ...     avg_DL_GNB1=${ul_exp_tput}       avg_UL_GNB1=${10}
        ...     avg_DL_GNB2=${ul_exp_tput}       avg_UL_GNB2=${10}
        ...     sourceCellList=${GNB1_cell_50}         targetCellList=${GNB1_cell_60}
        ...     cell1=${cell1}    cell2=${cell2}
        run keyword and continue on failure    Compare HO TP with initial TP with two gnb
        ...     btslog_name=btslog_${case_name}_${cell2}_${cell1}_${NUM}.log
        ...     avg_DL_GNB1=${ul_exp_tput}       avg_UL_GNB1=${10}
        ...     avg_DL_GNB2=${ul_exp_tput}       avg_UL_GNB2=${10}
        ...     sourceCellList=${GNB1_cell_60}         targetCellList=${GNB1_cell_50}
        ...     cell1=${cell2}    cell2=${cell1}
    END

Check wiresgark log and btslog for 710_014
    [Arguments]       ${case_name}=710_014    ${cell1}=${gnb2_pci}      ${cell2}=${gnb1_pci2}
    CB007306_common_keyword.Convert pcap to text     pacp_filename=tcpdump_attach_${case_name}.pcap
    ...    txt_filename=tcpdump_attach_${case_name}.txt    filter=${filter_enb}
    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_70}    txt_filename=tcpdump_attach_${case_name}.txt
    Check wireshark log Parameter    sgnb_chg_ho_message=${spid_710}    txt_filename=tcpdump_attach_${case_name}.txt
    ${measConfigDic}     Create dictionary
    ${measConfigDic}    Get MeasConfig From Txt N      measConfigDic=${measConfigDic}
    ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/tcpdump_attach_${case_name}.txt
    FOR    ${NUM}    IN RANGE    ${0}    ${1}    1
        CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.pcap
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt    filter=${filter_enb}
        Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_60_AdditionRequestAcknowledge}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        Check wireshark log Parameter    sgnb_chg_ho_message=${measGap_710_014}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_710_014}
        ...    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt

    #    CB007306_common_keyword.Convert pcap to text     pacp_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.pcap
    #    ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt    filter=${filter_enb}
    #    Check wireshark log Parameter    sgnb_chg_ho_message=${attached_pci_70_AdditionRequestAcknowledge}
    #    ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
    #    Check wireshark log data Flow message     sgnb_chg_flow_message=${enb_message_flow_710_014}
    #    ...    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt

        ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
        ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
    #    ${measConfigDic}    Get MeasConfig From Txt N     measConfigDic=${measConfigDic}
    #    ...    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
        ${MC_N_1}     Evaluate     1+${NUM}*4
        ${MC_N_2}     Evaluate     2+${NUM}*4
        ${MC_N_3}     Evaluate     3+${NUM}*4
        ${MC_N_4}     Evaluate     4+${NUM}*4
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_1}    para1=report    para2=eventId    expect=eventA2
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_1}    para1=report    para2=ho_method    expect=rsrp
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_2}    para1=report    para2=eventId    expect=eventA5
        Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell1}_${cell2}_${NUM}.txt
        ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_2}    para1=report    para2=ho_method    expect=rsrp

    #    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
    #    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_3}    para1=report    para2=eventId    expect=eventA2
    #    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
    #    ...         measConfigDic=${measConfigDic}    mr_n=1    mc_n=${MC_N_3}    para1=report    para2=ho_method    expect=rsrp
    #    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
    #    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_4}    para1=report    para2=eventId    expect=eventA5
    #    Run Keyword And Continue On Failure   Check measid    txt_filename=enb1_${case_name}_${cell2}_${cell1}_${NUM}.txt
    #    ...         measConfigDic=${measConfigDic}    mr_n=2    mc_n=${MC_N_4}    para1=report    para2=ho_method    expect=rsrp

        ${measid}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2078299    eventId=eventA5    ho_method=rsrp    n=${MC_N_2}
        Run Keyword And Continue On Failure    should not be true     ${measid}==${-1}
    #    ${measid1}    Get_Meas_Id    measConfigDic=${measConfigDic}     ssbFrequency=2071387    eventId=eventA5    ho_method=rsrp    n=${MC_N_4}
    #    Run Keyword And Continue On Failure    should not be true     ${measid1}==${-1}

        run keyword and continue on failure    Compare HO TP with initial TP with two gnb
        ...     btslog_name=btslog_${case_name}_${cell1}_${cell2}_${NUM}.log
        ...     avg_DL_GNB1=${dl_exp_tput}       avg_UL_GNB1=${ul_exp_tput}
        ...     avg_DL_GNB2=${dl_exp_tput}       avg_UL_GNB2=${ul_exp_tput}
        ...     sourceCellList=${GNB2_cell_70}         targetCellList=${GNB1_cell_60}
        ...     cell1=${cell1}    cell2=${cell2}
    #    run keyword and continue on failure    Compare HO TP with initial TP with two gnb
    #    ...     btslog_name=btslog_${case_name}_${cell2}_${cell1}_${NUM}.log
    #    ...     avg_DL_GNB1=${dl_exp_tput}       avg_UL_GNB1=${ul_exp_tput}
    #    ...     avg_DL_GNB2=${dl_exp_tput}       avg_UL_GNB2=${ul_exp_tput}
    #    ...     sourceCellList=${GNB2_cell_70}         targetCellList=${GNB1_cell_60}
    #    ...     cell1=${cell2}    cell2=${cell1}
    END

Get UL and DL TP due to cell ID
    [Arguments]    ${btslog_name}     ${CellList}
    ${DL_tputDataDic}    CB007403_common.get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${btslog_name}
    ...    sourceCellList=${CellList}   alias=DL
    ${avg_DL_tputDataDic}    CB007403_common.get_source_tput_avg     tputDataDic=${DL_tputDataDic}
    ${UL_tputDataDic}    CB007403_common.get_tput_from_syslog     syslog_path=${OUTPUT_DIR}/${btslog_name}
    ...    sourceCellList=${CellList}   alias=UL
    ${avg_UL_tputDataDic}    CB007403_common.get_source_tput_avg     tputDataDic=${UL_tputDataDic}
    [Return]    ${avg_DL_tputDataDic}    ${avg_UL_tputDataDic}
