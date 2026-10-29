##################################################################################################################
# To Launch the test (example):
#
#   cd /home/ute/robotws/
#   source /home/ute/test_repo/bin/activate
#   robot -L TRACE -d results -b debug.log -V config/Lannion/7_17_UTE5GTLMORGANE/ffsagent_sim show-supported
#         --variable DOCKER_BRANCH:orusim --variable DOCKER_TAG:v1.22.16
#         --variable DOCKER_NB:1 --variable GNB_COMMISSIONING_REQ:True
#         --variable GNB_DOWNLOADING_REQ:True --variable GNB_SW_TO_DOWNLOAD:SBTS22R1_ENB_0000_001160_000000
#         /home/ute/robotws/testsuite/Lannion/Airphone/ORUsim/test.robot
# Or :
#   /opt/ute/python/bin/python /home/ute/robotws/testsuite/Lannion/Airphone/ORUsim/launch_test.py
##################################################################################################################
# config/Lannion/7_17_UTE5GTLMORGANE/__init__/py must be updated as follows (example):
#
# _oru1 = {'docker': 'docker0',
#          'name': 'orusim',
#          'eth_link': 'eth5'}
#
# o_rus = [_oru1]
#
# ip_addr_list = {'enb_s1': '10.0.1.136',
#                 'enb_x2': '10.0.1.136',
#                 'mme_s1': '10.0.1.131',
#                 'sgw_s1u': '10.0.1.133',
#                 'sgw_s11': '10.0.1.134'}
#
# wts_conf = {'ip': ip_addr_list, 'eth': 'eth3'}
#
# __all__ = ['tl', 'o_rus', 'wts_conf']
##################################################################################################################


*** Settings ***

Library    XML
Library    String
Library    DateTime
Library    Collections
Library    OperatingSystem    WITH NAME    os
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    wft_api.py

Suite Setup    suite setup for orusim
Suite Teardown    suite cleanup for orusim


*** Variables ***

${NORMAL}   "\\033[0m"
${RED}      "\\033[31m"
${GREEN}    "\\033[32m"
${YELLOW}   "\\033[33m"
${BLUE}     "\\033[34m"

${WTS_CONNECTION}    wts_connection
${GNB_CONNECTION}    gnb_connection
${NETCONF_CONFIG_NEEDED}    False
${SBTS21R1_RESTRICTION}    False

${TEST_TYPE}    orusim
${DOCKER_BRANCH}    orusim
${DOCKER_TAG}    v1.22.16
${DOCKER_NB}    1
${GNB_COMMISSIONING_REQ}    True
${GNB_DOWNLOADING_REQ}    False
${GNB_SW_TO_DOWNLOAD}    None
${WTS_DOWNLOADING_REQ}    False
${WTS_SW_TO_DOWNLOAD}    None


*** Test Cases ***

APoDOCKER test for RUSIM or ORUSIM

    [Documentation]    ${TEST_TYPE} test

    run keyword if    '${GNB_DOWNLOADING_REQ}' == '${True}'    gnb downloading
    run keyword if    '${GNB_COMMISSIONING_REQ}' == '${True}'    gnb full generic commissioning
    run keyword if    '${WTS_DOWNLOADING_REQ}' == '${True}'    wts downloading
    orusim docker image installation and setup
    egate launch
    gNB check cell state
    orusim docker image exit and cleanup
    egate exit


*** Keywords ***

RUsim iphy.xml Update

    [Documentation]    Update iphy.xml template with gNB RMOD SW information

    ${file}    ssh.execute    command=ls /ffs/run/Tar*.xml    connection=${GNB_CONNECTION}
    ${file}    remove string    ${file}    \r\n
    ssh.download file    remote_path=${file}    local_path=/tmp/TargetBD.xml    connection=${GNB_CONNECTION}
    ${xml}    XML.parse xml    /tmp/TargetBD.xml
    ${resourceSWVersion}    xml.get element attribute    ${xml}    resourceSWVersion
    ...                                                            xpath=.//hwResource[@resourceBuildKey="LTX_AEQN_E1"]
    ${swFileKey}    xml.get element text    ${xml}    xpath=.//hwResource[@resourceBuildKey="LTX_AEQN_E1"]
    ${swFileKey}    remove string    ${swFileKey}    \n    ${SPACE}
    ${tmp_file}    os.get file    ${CURDIR}/resources/iphy_rusim.xml
    ${tmp_file}    replace string    ${tmp_file}    {swFileKey}    ${swFileKey}
    ${tmp_file}    replace string    ${tmp_file}    {resourceSWVersion}    ${resourceSWVersion}
    create file    ${RUN_RESULTS}/iphy.xml    content=${tmp_file}
    os.run    command=rm /tmp/TargetBD.xml


WTS Downloading

    [Documentation]    Install esimmode_WTS (egate) associated with an Airphone SW load on the VM (/opt/iphy/latest)

    ###################################################################################################################
    log to console    \nRetrieve ${WTS_SW_TO_DOWNLOAD} esimmode_WTS from server... May take few minutes
    ###################################################################################################################
    ${esimmode_path}    set variable
    ...    hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/${WTS_SW_TO_DOWNLOAD}/
    ${sw_file_server}    catenate    https://${esimmode_path}
    os.run    command=mkdir -p /tmp/AP/
    os.run    command=mkdir -p /opt/iphy/${WTS_SW_TO_DOWNLOAD}
    os.run    command=mkdir -p /opt/iphy/older
    os.run    command=wget -r -l1 --no-parent https://${esimmode_path} -nv -P /tmp/AP
    os.run    command=tar -xvf /tmp/AP/${esimmode_path}*core2.tar.bz2 -C /opt/iphy/${WTS_SW_TO_DOWNLOAD}/
    os.run    command=rm -Rf /tmp/AP/*
    ${latest}    os.run    command=ls -ll /opt/iphy/latest | awk '{ print $11 }'
    run keyword if    '/opt/iphy/${WTS_SW_TO_DOWNLOAD}' != '${latest}'    run keywords
    ...    os.run    command=rm -Rf /opt/iphy/older/*    AND
    ...    os.run    command=cp -r ${latest}/* /opt/iphy/older/    AND
    ...    os.run    command=rm -Rf ${latest}/*    AND
    ...    os.run    command=rm -df ${latest}   AND
    ...    os.run    command=rm /opt/iphy/latest    AND
    ...    os.run    command=ln -s /opt/iphy/${WTS_SW_TO_DOWNLOAD} /opt/iphy/latest


GNB Check Cell State

    [Documentation]    Establish a ssh connection to the gNB and check the gNB and cells status
    [Teardown]    run keywords
    ...    log to console    \nRelease gNB connection    AND
    ...    admin.teardown    connection=${GNB_CONNECTION}    AND
    ...    ssh.disconnect    connection=${GNB_CONNECTION}

    ###################################################################################################################
    log to console    \nConnection to gNB ongoing
    ###################################################################################################################
    ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${GNB_CONNECTION}
    admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 name=${GNB_CONNECTION}

    ${cells_info}    admin.get_cells_info    cell_type=nr
    ...                                      timeout=${30}
    ...                                      connection=${GNB_CONNECTION}
    ${cells_number}    get length    ${cells_info}

    FOR    ${index}    IN RANGE    ${cells_number}
        ${cell}    evaluate    ${index} + 1
        ${cell_id}    set variable    ${cells_info[${index}]['id']['configuration']}
        ${cell_id}    catenate    ${green}${cell_id}${normal}
        ${cell_status}    set variable    ${cells_info[${index}]['status']}
        ${verdict_1}    run keyword and return status    should be equal
        ...             ${cell_status['operationalState']}    Enabled    ignore_case=true
        ${verdict_2}    run keyword and return status    should be equal
        ...             ${cell_status['proceduralStatus']}    configured    ignore_case=true
        ${verdict}    run keyword and return status    variable should exist    ${cell_status['availabilityStatus']}
        ${var}    set variable if    ${verdict} == True    ${cell_status['availabilityStatus']}    Online
        ${verdict_3}    run keyword and return status    should contain any
        ...             ${var}    Online    on line    Degraded    ignore_case=true
        ${verdict}    evaluate    '${verdict_1}'=='${True}' and '${verdict_2}'=='${True}' and '${verdict_3}'=='${True}'
        ${status}    run keyword if    '${verdict}'=='${True}'
        ...    catenate    ${green}${var}${normal}    ELSE
        ...    catenate    ${red}${var}${normal}
    ###################################################################################################################
        log to console    \n___ CELL_${cell} (${cell_id}) availability status is ${status}
    ###################################################################################################################
    END

    ${alarms_info}    admin.get_active_alarms    severity=critical
    ...                                          timeout=${30}
    ...                                          connection=${GNB_CONNECTION}
    ${critical_alarms_number}    get length    ${alarms_info}

    FOR    ${index}    IN RANGE    ${critical_alarms_number}
        ${alarm_id}    set variable    ${alarms_info[${index}]['alarmId']}
        ${fault_id}    set variable    ${alarms_info[${index}]['faultId']}
        ${fault_name}    set variable    ${alarms_info[${index}]['faultName']}
        log to console    \n!!! Critical alarmId ${red}${alarm_id}${normal}: faultId ${fault_id} (${fault_name})
    END

    ${alarms_info}    admin.get_active_alarms    severity=major
    ...                                          timeout=${30}
    ...                                          connection=${GNB_CONNECTION}
    ${major_alarms_number}    get length    ${alarms_info}

    FOR    ${index}    IN RANGE    ${major_alarms_number}
        ${alarm_id}    set variable    ${alarms_info[${index}]['alarmId']}
        ${fault_id}    set variable    ${alarms_info[${index}]['faultId']}
        ${fault_name}    set variable    ${alarms_info[${index}]['faultName']}
        log to console    \n!!! Major alarmId ${yellow}${alarm_id}${normal}: faultId ${fault_id} (${fault_name})
    END

    ${container_list}    create list
    FOR    ${index}    IN RANGE    ${DOCKER_NB}
        ${container_id}    os.run
        ...    command=sudo docker ps | grep ${DOCKER_TAG} | grep ${TEST_TYPE}${index} | awk '{ print $1 }'
        append to list    ${container_list}    ${container_id}
    END

    run keyword if    "${critical_alarms_number}"!="${0}" or "${major_alarms_number}"!="${0}" or ${verdict}!=${True}
    ...    run keywords
    ###################################################################################################################
    ...        log to console    \nStart collecting gNB snapshot... (see ${RUN_RESULTS}/gnb_snapshot.zip)    AND
    ###################################################################################################################
    ...        ssh.send command    echo log -a -z snapshot.zip > snapshotcommand.txt
    ...                            connection=${GNB_CONNECTION}    AND
    ...        ssh.execute    nc 0 15007 < snapshotcommand.txt
    ...                       connection=${GNB_CONNECTION}    AND
    ...        ssh.download file    remote_path=/tmp/snapshot.zip
    ...                             local_path=${RUN_RESULTS}/gnb_snapshot.zip
    ...                             timeout=${30}
    ...                             connection=${GNB_CONNECTION}   AND
    ###################################################################################################################
    ...        log to console    \nStart collecting docker logs... (see ${RUN_RESULTS}/supervisord_x.log)
    ###################################################################################################################
    ${log_file}    set variable if    "${TEST_TYPE}" == "orusim"     /var/log/supervisord.log
        ...    /workspace/supervisor_rusim.log

    ${index}    set variable    ${0}
    FOR    ${container_id}    IN    @{container_list}
        run keyword if    "${critical_alarms_number}"!="${0}" or "${major_alarms_number}"!="${0}" or ${verdict}!=${True}
        ...    os.run
        ...    command=sudo docker cp ${container_id}:${log_file} ${RUN_RESULTS}/supervisord_${index}.log
        run keyword if    "${critical_alarms_number}"!="${0}" or "${major_alarms_number}"!="${0}" or ${verdict}!=${True}
        ...    os.run    command=sudo chmod 777 ${RUN_RESULTS}/supervisord_${index}.log
        ${index}    evaluate    ${index} + 1
    END

    should be equal    ${verdict}    ${True}    ignore_case=true    msg=${red}gNB is not in the expected state${normal}

    ${bts_status}    admin.get_bts_statuses    timeout=${30}
    ...                                        connection=${GNB_CONNECTION}
    should be equal    ${bts_status['operationalState']}    Enabled    ignore_case=true
    should contain any    ${bts_status['proceduralState']}    OnAir    Configured    ignore_case=true
    ###################################################################################################################
    log to console    \nBTS procedural state is ${green}${bts_status['proceduralState']}${normal}
    ###################################################################################################################

    ${rmods_info}    admin.get_frm    timeout=${30}
    ...                               connection=${GNB_CONNECTION}
    ${rmods_number}    get length    ${rmods_info}
    FOR    ${index}    IN RANGE    ${rmods_number}
        ${rmod}    evaluate    ${index} + 1
        log to console    \n___ RMOD_${rmod} ${blue}${rmods_info[${index}]['productName']}${normal} detected by the gNB
        ${text}    catenate    \n___ RMOD_${rmod} running SW version is    AND
        ${text}    run keyword if    "${TEST_TYPE}" == "orusim"
        ...    catenate    ${text}    ${blue}${rmods_info[${index}]['swInfo']['runningSwVersion']}${normal}
        run keyword if    "${TEST_TYPE}" == "orusim"    log to console    ${text}
    END


Check RU SW Alarm

    [Arguments]    ${instance}
    [Return]    ${test}

    ${rmod_r}    evaluate    ${instance} + 1
    ${rmod_r}    catenate    MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_r}
    ${alarms_info}    admin.get_active_alarms    severity=critical
    ...                                          timeout=${30}
    ...                                          connection=${GNB_CONNECTION}
    ${critical_alarms_number}    get length    ${alarms_info}
    ${alarm_id}    set variable    ${0}
    ${fault_id}    set variable    ${0}
    ${alarm_count}    set variable    ${0}
    ${test}    set variable    ${False}

    FOR    ${index}    IN RANGE    ${critical_alarms_number}
        ${verdict}    set variable    ${False}
        ${alarm_id}    set variable    ${alarms_info[${index}]['alarmId']}
        ${fault_id}    set variable    ${alarms_info[${index}]['faultId']}
        ${fault_name}    set variable    ${alarms_info[${index}]['faultName']}
        ${faulty_rmod}    convert to string    ${alarms_info[${index}]['configObjectName']}
        ${verdict}    run keyword and return status    should contain    ${faulty_rmod}    ${rmod_r}
        ${alarm_count}    run keyword if    '${verdict}' == '${True}'    evaluate    ${alarm_count} + 1
        ...    ELSE    set variable    ${alarm_count}
        ${test}     set variable if
        ...    '${verdict}' == '${True}' and '${alarm_id}' == '${7111}' and '${fault_id}' == '${23}'
        ...    ${True}    ${test}
    END
    log to console    \n${alarm_count} critical alarm(s) detected for ${rmod_r}
    run keyword if    '${test}' == '${True}'   log to console    \nAlarm : "${fault_name}"


Check RU State

    [Arguments]    ${state}=OnLine
    # only "NotInstalled" (or "not installed") and "Online" (or "-") values supported
    ...            ${instance}=All

    ${rmods_info}    admin.get_frm    timeout=${30}
    ...                               connection=${GNB_CONNECTION}
    ${rmods_number}    get length    ${rmods_info}
    ${state_list}    create list
    FOR    ${index}    IN RANGE    ${rmods_number}
        ${rmod}    evaluate    ${index} + 1

        ${verdict}    run keyword and return status    variable should exist
        ...    ${rmods_info[${index}]['status']['availabilityStatus']}
        ${var}    set variable if    ${verdict} == True
        ...    ${rmods_info[${index}]['status']['availabilityStatus']}    OnLine
        ${rmod_r}    run keyword if    '${instance}' != 'All'    evaluate    ${instance} + 1
        ${rmod_r}    run keyword if    '${instance}' != 'All'    catenate    MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_r}
        ${verdict}    run keyword if    '${state}' == 'NotInstalled'
        ...    run keyword and return status    should contain any    ${var}    not installed    NotInstalled    off line
        ...    ELSE    run keyword and return status    should contain any    ${var}    OnLine
        run keyword if    '${verdict}' == '${True}'
        ...    log to console    \n... RMOD_${rmod} availability status is ${green}${var}${normal}    ELSE
        ...    log to console    \n... RMOD_${rmod} availability status is ${yellow}${var}${normal}
        run keyword if    '${instance}' == 'All' or '${rmod_r}' == '${rmods_info[${index}]['id']['configuration']}'
        ...    append to list   ${state_list}   ${var}
    END
    FOR    ${item}    IN    @{state_list}
        run keyword if    '${state}' == 'NotInstalled'
        ...    should contain any    '${item}'    not installed    NotInstalled    off line    ignore_case=true
        ...    ELSE    should contain any    '${item}'    OnLine    -    ignore_case=true
    END


Check Cell To RU Mapping

    [Arguments]    ${antennas_info}
    ...            ${instance}
    [Return]    ${test}

    ${rmod_r}    evaluate    ${instance} + 1
    ${rmod_r}    catenate    MRBTS-1/EQM-1/APEQM-1/RMOD-${rmod_r}
    ${antennas_number}    get length    ${antennas_info}
    ${test}    set variable    ${True}
    FOR    ${antenna}    IN RANGE    ${antennas_number}
        ${text}    convert to string    ${antennas_info[${antenna}]}
        ${verdict}    run keyword and return status    should contain    ${text}    ${rmod_r}
        ${test}    set variable if    '${verdict}' == '${True}'    ${Test}    ${False}
    END


Check Cell State

    [Arguments]    ${state}=Failed
    # only "Failed" and "Offline" (or "off line") values supported
    ...            ${instance}=All

    ${cells_info}    admin.get_cells_info    cell_type=nr
    ...                                      timeout=${30}
    ...                                      connection=${GNB_CONNECTION}
    ${cells_number}    get length    ${cells_info}
    ${state_list}    create list
    FOR    ${index}    IN RANGE    ${cells_number}
        ${cell}    evaluate    ${index} + 1

        ${verdict}    run keyword and return status    variable should exist
        ...    ${cells_info[${index}]['status']['availabilityStatus']}
        ${var}    set variable if    ${verdict} == True
        ...    ${cells_info[${index}]['status']['availabilityStatus']}    Online

        ${antennas_info}    set variable    ${cells_info[${index}]['carrierList']}
        ${verdict}    run keyword if    '${state}' == 'Failed'
        ...    run keyword and return status    should contain    ${var}    'Failed'
        ...    ELSE    run keyword and return status    should contain any    ${var}    OffLine    off line
        run keyword if    '${verdict}' == '${True}'
        ...    log to console    \n... CELL_${cell} availability status is ${green}${var}${normal}    ELSE
        ...    log to console    \n... CELL_${cell} availability status is ${yellow}${var}${normal}
        ${test}    run keyword if    '${instance}' == 'All'    set variable    ${True}    ELSE
        ...    check cell to ru mapping    ${antennas_info}    ${instance}
        run keyword if    '${test}' == '${True}'    append to list   ${state_list}   ${var}

    END
    FOR    ${item}    IN    @{state_list}
        run keyword if    '${state}' == 'Failed'
        ...    should contain    '${item}'    'Failed'    ignore_case=true
        ...    ELSE    should contain any    '${item}'    OffLine    off line    ignore_case=true
    END


GNB Check BTS State

    [Arguments]    ${state}=Commissioned

    ${bts_status}    admin.get_bts_statuses    timeout=30s
    ...                                        connection=${GNB_CONNECTION}
    run keyword if    '${bts_status['proceduralState']}' == '${state}'
    ...    log to console    \n... BTS procedural state is ${green}${bts_status['proceduralState']}${normal}    ELSE
    ...    log to console    \n... BTS procedural state is ${yellow}${bts_status['proceduralState']}${normal}
    should be equal    ${bts_status['proceduralState']}    ${state}    ignore_case=true


GNB Full Generic Commissioning

    [Documentation]    GNB genaric commissioning
    [Teardown]    run keywords
    ...    log to console    \nRelease gNB connection    AND
    ...    admin.teardown    connection=${GNB_CONNECTION}    AND
    ...    ssh.disconnect    connection=${GNB_CONNECTION}

    log to console    \nConnection to gNB ongoing
    ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${GNB_CONNECTION}
    admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                name=${GNB_CONNECTION}

    ${sw_version}    admin.get_sw_version    timeout=${30}
    ...                                      connection=${GNB_CONNECTION}

    ${branch}    ${not_used_1}    ${trunk}    ${not_used_2}    split string    ${sw_version}    _    max_split=3
    ${branch}    set variable if    '${trunk}' == '9999'    SBTS00     ${branch}

    ${NETCONF_CONFIG_NEEDED}    set variable if
    ...    (('${GNB_DOWNLOADING_REQ}' == '${False}') and ('${trunk}' != '0000' or '${branch}' != 'SBTS22R1'))
    ...    ${True}    ${NETCONF_CONFIG_NEEDED}

    run keyword if    '${GNB_DOWNLOADING_REQ}' == '${False}'
    ...    run keywords
    ###################################################################################################################
    ...        log to console    \nReset gNB configuration... May take few minutes    AND
    ###################################################################################################################
    ...        admin.reset_configuration    timeout=${900}
    ...                                     connection=${GNB_CONNECTION}    AND
    ...        sleep    30s    AND
    ...        wait until keyword succeeds    300s    30s    gnb check bts state    state=NotCommissioned

    ###################################################################################################################
    log to console    \nConfigure the gNB (generic commissioning file)... May take few minutes
    ###################################################################################################################
    sleep    60s
    admin.perform_commissioning
    ...    scf_file=${RUN_RESULTS}/gnb_scf_new.xml
    ...    timeout=${900}
    ...    connection=${GNB_CONNECTION}
    sleep    30s

    log to console   \nWait until the gNB detects the RU link failure
    wait until keyword succeeds    1800s    30s    check cell state    state=Failed
    wait until keyword succeeds    900s    30s    check ru state    state=NotInstalled

    run keyword if    '${NETCONF_CONFIG_NEEDED}' == '${True}'
    ...    run keywords
    ...        admin.enable_ssh_access    timeout=${30}
    ...                                   connection=${GNB_CONNECTION}    AND
    ...        admin.configure_netconf_radio_management    authentication_method=NoAuthentication
    ...                                                    id=1
    ...                                                    name=xranuser
    ...                                                    password=xran-password
    ...                                                    dist_name=${EMPTY}
    ...                                                    unsecure_ciphering=False
    ...                                                    format=${EMPTY}
    ...                                                    value=${EMPTY}
    ...                                                    connection=${GNB_CONNECTION}


GNB Downloading

    [Documentation]    GNB SW and swconfig download
    [Teardown]    run keywords
    ...    log to console    \nRelease gNB connection    AND
    ...    admin.teardown    connection=${GNB_CONNECTION}    AND
    ...    ssh.disconnect    connection=${GNB_CONNECTION}

    log to console    \nConnection to gNB ongoing
    ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${GNB_CONNECTION}
    admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 name=${GNB_CONNECTION}

    ${sw_version}    admin.get_sw_version    timeout=${30}
    ...                                      connection=${GNB_CONNECTION}

    ${not_used}    ${current_suffix}    split string    ${sw_version}    _    max_split=1
    ${GNB_SW_TO_DOWNLOAD}    set variable if    '${GNB_SW_TO_DOWNLOAD}'==''    ${sw_version}    ${GNB_SW_TO_DOWNLOAD}
    ${not_used}    ${target_suffix}    split string    ${GNB_SW_TO_DOWNLOAD}    _    max_split=1

    ${c_prefix}    ${v1}    ${c_branch}    ${c_v2}    split string    ${sw_version}    _    max_split=3
    ${t_prefix}    ${v1}    ${t_branch}    ${t_v2}    split string    ${GNB_SW_TO_DOWNLOAD}    _    max_split=3

    ${reset_conf_needed}    run keyword if    '${c_V2[0]}' != '${t_v2[0]}'
    ...    set variable    ${True}    ELSE IF    '${c_prefix}' != '${t_prefix}'
    ...    set variable    ${True}    ELSE    set variable    ${False}

    ${SBTS21R1_RESTRICTION}    set variable if
    ...    (('${reset_conf_needed}' == '${True}') and (('${t_branch}' == '0000') and ('${t_prefix}' == 'SBTS22R1')))
    ...    ${True}    ${False}
    set suite variable     ${SBTS21R1_RESTRICTION}
    run keyword if    '${SBTS21R1_RESTRICTION}' == '${True}'    run keywords
    ...    log to console   \n${red}!!! The gNB Netconf Account will be deleted !!!${normal}    AND
    ...    log to console   \n${red}--- Please set the Netconf account manually via WebEM ---${normal}    AND
    ...    log to console   \n${red}--- Then Reset Site via WebEM and launch the robot test again ---${normal}    AND
    ...    log to console   \n${red}--- (without gNB SW downloading or SCF commissioning) ---${normal}

    ${NETCONF_CONFIG_NEEDED}    set variable if    '${t_prefix}' == 'SBTS22R1'
    ...     ${False}    ${True}

    set suite variable    ${NETCONF_CONFIG_NEEDED}

    ${sw_file}    set variable    ${GNB_SW_TO_DOWNLOAD}_release_BTSSM_downloadable.zip
    ${sw_file_server}    catenate    http://files.ute.nsn-rdnet.net/builds/enb/base/${GNB_SW_TO_DOWNLOAD}/${sw_file}

    run keyword if    '${reset_conf_needed}' == '${True}'
    ...    run keywords
    ###################################################################################################################
    ...        log to console    \nReset gNB configuration... May take few minutes    AND
    ###################################################################################################################
    ...        admin.reset_configuration    timeout=${900}
    ...                                     connection=${GNB_CONNECTION}    AND
    ...        sleep    30s    AND
    ...        wait until keyword succeeds    300s    30s    gnb check bts state    state=NotCommissioned

    run keyword if    '${current_suffix}' != '${target_suffix}'
    ...    run keywords
    ###################################################################################################################
    ...        log to console    \nRetrieve build ${GNB_SW_TO_DOWNLOAD} from server... May take few minutes    AND
    ###################################################################################################################
    ...        ssh.connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...                          username=${tl.core.default_ssh_connection_details.username}
    ...                          password=${tl.core.default_ssh_connection_details.password}
    ...                          alias=VM    AND
    ...        ssh.execute    command=wget ${sw_file_server} -nv -P /home/ute/Downloads
    ...                       connection=VM    AND
    ...        ssh.disconnect    connection=VM    AND
    ###################################################################################################################
    ...        log to console    \nUpdate gNB with build ${GNB_SW_TO_DOWNLOAD}... May take few minutes    AND
    ###################################################################################################################
    ...        admin.update_software    sw_package=/home/ute/Downloads/${sw_file}
    ...                                 timeout=${1800}
    ...                                 connection=${GNB_CONNECTION}    AND
    ###################################################################################################################
    ...        log to console   \nWait until the gNB detects the RU link failure    AND
    ###################################################################################################################
    ...        sleep    30s    AND
    ...        wait until keyword succeeds    1800s    30s    check cell state    state=Failed    AND
    ...        wait until keyword succeeds    900s    30s    check ru state    state=NotInstalled    AND
    ...        os.run    command=rm /home/ute/Downloads/${sw_file}    AND
    ...        sleep    10s    AND
    ...        admin.teardown    connection=${GNB_CONNECTION}    AND
    ...        ssh.disconnect    connection=${GNB_CONNECTION}    AND

    ...        ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                          username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                          password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                          alias=${GNB_CONNECTION}    AND
    ...        admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                            name=${GNB_CONNECTION}   AND
    ...        ssh.upload file    local_path=${CURDIR}/resources/swconfig.txt
    ...                           remote_path=/ffs/run/swconfig.txt
    ...                           timeout=${30}
    ...                           connection=${GNB_CONNECTION}    AND
    ...        ssh.execute        crasign /ffs/run/swconfig.txt
    ...                           connection=${GNB_CONNECTION}    AND
    ...        run keyword if    '${GNB_COMMISSIONING_REQ}' != '${True}'
    ...            log to console   Full gNB commissioning triggered afer gNB SW download...
    ...    ELSE
    ###################################################################################################################
    ...        log to console    \nBuild ${GNB_SW_TO_DOWNLOAD} already active in gNB
    ###################################################################################################################
    ${GNB_COMMISSIONING_REQ}    set variable if    '${current_suffix}' != '${target_suffix}'
    ...   ${True}    ${GNB_COMMISSIONING_REQ}


GNB Specific Delta Commissioning

    # Not used, SCF file updated/customized in Suite Setup For Orusim

    [Documentation]    GNB TL specific delta commissionning
    [Teardown]    run keywords
    ...    log to console    \nRelease gNB connection    AND
    ...    admin.teardown    connection=${GNB_CONNECTION}    AND
    ...    ssh.disconnect    connection=${GNB_CONNECTION}

    ###################################################################################################################
    log to console    \nConnection to gNB ongoing
    ###################################################################################################################
    ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${GNB_CONNECTION}
    admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 name=${GNB_CONNECTION}

    ###################################################################################################################
    log to console    \nApply TL specific gNB delta commissioning (vlan)
    ###################################################################################################################
    ${vlan}    convert to string    ${tl.gnbs[0].cu.x2c.vlan_id}
    ${tmp_file}    os.get file    ${CURDIR}/resources/vlan.json
    ${tmp_file}    replace string    ${tmp_file}    {vlan}    ${vlan}
    create file    ${RUN_RESULTS}/vlan_updated.json    content=${tmp_file}
    sleep    60s
    admin.perform_delta_recommissioning    delta_file=${RUN_RESULTS}/vlan_updated.json
    ...                                    timeout=${900}
    ...                                    connection=${GNB_CONNECTION}
    sleep    30s
    log to console   \nWait until the gNB detects the RU link failure
    wait until keyword succeeds    1800s    30s    check cell state    state=Failed
    wait until keyword succeeds    900s    30s    check ru state    state=NotInstalled


Egate Launch

    [Documentation]    Establish a ssh connection to the WTS machine
    ...                Launch Egate
    ...                Configure gfg file and setup X2 link

    ssh.connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...               username=${tl.core.default_ssh_connection_details.username}
    ...               password=${tl.core.default_ssh_connection_details.password}
    ...               alias=${WTS_CONNECTION}

    ###################################################################################################################
    comment    log to console    \nCheck if edaemon process is running
    ###################################################################################################################
    ssh.send_command    command=sudo netstat -anp | grep edaemon
    ...                 timeout=${10}
    ...                 connection=${WTS_CONNECTION}
    ${output}    ssh.read_output    connection=${WTS_CONNECTION}
    ${length}    get length    ${output}
    run keyword if    '${length}'=='${0}'
    ...    log to console    \nNo edaemon process found
    ...    ELSE    run keywords
    ...                ssh.send_command    command=sudo pkill edaemon
    ...                                    connection=${WTS_CONNECTION}    AND
    ...                log to console    \nOngoing edaemon process killed

    ###################################################################################################################
    comment    log to console    \nCheck if egate process is running
    ###################################################################################################################
    ssh.send_command    command=sudo netstat -anp | grep egate
    ...                 timeout=${10}
    ...                 connection=${WTS_CONNECTION}
    ${output}    ssh.read_output    connection=${WTS_CONNECTION}
    ${length}    get length    ${output}
    run keyword if    '${length}'=='${0}'
    ...    log to console    \nNo egate process found
    ...    ELSE    run keywords
    ...                ssh.send_command    command=sudo pkill egate
    ...                                    connection=${WTS_CONNECTION}    AND
    ...                log to console    \nOngoing egate process killed

    ###################################################################################################################
    log to console    \nLaunch edaemon process
    ###################################################################################################################
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS_CONNECTION}
    ...                                   directory_path=${tl.core.dir_path}
    ...                                   port=${EDAEMON_PORT}

    ###################################################################################################################
    log to console    \nLaunch egate process
    ###################################################################################################################
    wtsrunner.configure_wtsemu_egate    egate_ssh_alias=${WTS_CONNECTION}
    ...                                 directory_path=${tl.core.dir_path}
    ...                                 port=${EGATE_PORT}

    ###################################################################################################################
    log to console    \nLaunch egate console
    ###################################################################################################################
    wtsrunner.start_wtsemu    egate_console_ip=${tl.core.default_ssh_connection_details.addr}
    ...                       egate_port=${EGATE_PORT}

    ###################################################################################################################
    log to console    \nEGATE: Configure and check if STATE is CONFIGURED
    ###################################################################################################################
    wtsrunner.configure    file=${RUN_RESULTS}/oran.cfg

    wtsrunner.read_wtsemu_output_until_re    expected=CHANGE STATE: CONFIGURED
    ...                                      timeout=30

    log to console    \nEGATE: Start SimMode and check if STATE is ACTIVE
    wtsrunner.sim_start    version_check=off

    wtsrunner.read_wtsemu_output_until_re    expected=CHANGE STATE: ACTIVE - SimMode is ready now
    ...                                      timeout=30

    ###################################################################################################################
    log to console    \nEGATE: X2 setup and check if X2AP link to eNB is UP
    ###################################################################################################################
    wtsrunner.enb_x2_link_up    enb=1
    ...                         target=2
    wtsrunner.read_wtsemu_output_until_re    expected=is up
    ...                                      timeout=60

    sleep    2s


Egate Exit

    [Documentation]    Exit Egate and kill egate and edaemon processes

    run keyword and ignore error    wtsrunner.stop_wtsemu
    os.run    command=sudo pkill egate
    os.run    command=sudo pkill edaemon


Suite Setup For Orusim

    [Documentation]    Save initial gNB configuration and initialize suite variable
    [Teardown]    run keywords
    ...    log to console    \nRelease gNB connection    AND
    ...    os.run    command=sudo pkill egate    AND
    ...    os.run    command=sudo pkill edaemon    AND
    ...    admin.teardown    connection=${GNB_CONNECTION}    AND
    ...    ssh.disconnect    connection=${GNB_CONNECTION}

    ${date_beg}    get current date
    set suite variable    ${date_beg}

    ${normal}    evaluate    ${NORMAL}
    set suite variable    ${normal}
    ${green}    evaluate    ${GREEN}
    set suite variable    ${green}
    ${yellow}    evaluate    ${YELLOW}
    set suite variable    ${yellow}
    ${red}    evaluate    ${RED}
    set suite variable    ${red}
    ${blue}    evaluate    ${BLUE}
    set suite variable    ${blue}

    os.run    command=mkdir -p ${OUTPUT_DIR}/Tag_${DOCKER_TAG}
    ${RUN_RESULTS}    catenate    ${OUTPUT_DIR}/Tag_${DOCKER_TAG}
    set suite variable    ${RUN_RESULTS}
    os.run    command=rm -f ${RUN_RESULTS}/*

    ###################################################################################################################
    log to console    \nConnection to gNB ongoing
    ###################################################################################################################
    ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${GNB_CONNECTION}
    admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 name=${GNB_CONNECTION}

    ###################################################################################################################
    log to console    \nSave current gNB commissioning and swconfig
    ###################################################################################################################
    ${verdict}    ${tmp_file}    run keyword and ignore error    admin.get_scf
    ...            timeout=${30}
    ...            connection=${GNB_CONNECTION}
    run keyword if     '${verdict}'=='PASS'    create file    ${RUN_RESULTS}/gnb_scf_backup.xml
    ...            content=${tmp_file}    ELSE    log to console    \nCannot retrieve gNB commissioning
    ssh.download file    remote_path=/ffs/run/swconfig.txt
    ...                  local_path=${RUN_RESULTS}/gnb_swconfig_backup.txt
    ...                  timeout=${30}
    ...                  connection=${GNB_CONNECTION}

    ${build}    get latest ap build    branch=master_airphone
    ${WTS_SW_TO_DOWNLOAD}    set variable if    '${WTS_SW_TO_DOWNLOAD}' == 'None'    ${build}    ${WTS_SW_TO_DOWNLOAD}
    set suite variable    ${WTS_SW_TO_DOWNLOAD}

    ${build}    get latest gnb build    branch=SBTS00
    ${GNB_SW_TO_DOWNLOAD}    set variable if    '${GNB_SW_TO_DOWNLOAD}' == 'None'    ${build}    ${GNB_SW_TO_DOWNLOAD}
    set suite variable    ${GNB_SW_TO_DOWNLOAD}

    ${SM-type}    ssh.execute    command=chk sysversions | grep 'module product-code' | awk '{ print $7 }'
    ...                          connection=${GNB_CONNECTION}
    ${SM-type}    remove string    ${SM-type}    \r\n

    ### Identify the applicable gNB SW release that will be applied

    ${sw_version}    admin.get_sw_version    timeout=${30}
    ...                                      connection=${GNB_CONNECTION}

    ${GNB_SW_TO_DOWNLOAD}    set variable if    '${GNB_SW_TO_DOWNLOAD}'==''    ${sw_version}    ${GNB_SW_TO_DOWNLOAD}
    ${sw_version}    set variable if    '${GNB_DOWNLOADING_REQ}' == '${True}'    ${GNB_SW_TO_DOWNLOAD}    ${sw_version}
    ${branch}    ${not_used_1}    ${trunk}    ${not_used_2}    split string    ${sw_version}    _    max_split=3
    ${branch}    set variable if    '${trunk}' == '9999'    SBTS00     ${branch}

    ${EDAEMON_PORT}    convert to string    ${tl.core.edaemon_port}
    set suite variable    ${EDAEMON_PORT}
    ${EGATE_PORT}    convert to string    ${tl.core.egate_port}
    set suite variable    ${EGATE_PORT}

    ${tac_4g}    convert to string    ${tl.core.tac}

    ${scf}    set variable
    ...    ${CURDIR}/resources/Full_Configuration_scf_MRBTS_${branch}_${DOCKER_NB}_docker-${TEST_TYPE}.xml
    ${xml}    XML.parse xml    ${scf}
    ${CELL_NUM}    XML.get element count    ${xml}    xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${path}    set variable    .//managedObject[@distName\="MRBTS-1/EQM-1/APEQM-1/CABINET-1/SMOD-1"]
    XML.set element text    ${xml}    ${SM-type}    xpath=${path}/p[@name\="prodCodePlanned"]
    ${vlan}    convert to string    ${tl.gnbs[0].cu.x2c.vlan_id}
    ${path}    set variable    .//managedObject[@distName\="MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"]
    XML.set element text    ${xml}    ${vlan}    xpath=${path}/p[@name\="vlanId"]
    XML.save xml    ${xml}    ${RUN_RESULTS}/gnb_scf_new.xml

    ${gnb_cell}    set variable    \n
    FOR    ${index}    IN RANGE    ${CELL_NUM}
        ${cell}   evaluate    ${index} + 1
        ${path}    set variable    .//managedObject[@distName\="MRBTS-1/NRBTS-1/NRCELL-${cell}"]
        ${rat}    XML.get element text    ${xml}    ${path}/p[@name\="cellTechnology"]
        ${pci}    XML.get element text    ${xml}    ${path}/p[@name\="physCellId"]
        ${pci_div}    evaluate    ${pci} / 3
        ${pci_rem}    evaluate    ${pci} % 3
        ${pci}    set variable    ${pci_div}:${pci_rem}
        ${nrarfcn}    run keyword if    '${rat}' == 'TDD'
        ...    XML.get element text    ${xml}    ${path}/p[@name\="nrarfcn"]
        ${path}    set variable    .//managedObject[@distName\="MRBTS-1/NRBTS-1/NRCELL-${cell}/NRCELL_FDD-1"]
        ${nrarfcnUL}    run keyword if    '${rat}' == 'FDD'
        ...    XML.get element text    ${xml}    ${path}/p[@name\="nrarfcnUl"]
        ${nrarfcnDL}    run keyword if    '${rat}' == 'FDD'
        ...    XML.get element text    ${xml}    ${path}/p[@name\="nrarfcnDl"]
        ${nrarfcn}    setvariable if    '${rat}' == 'FDD'    ${nrarfcnUL}:${nrarfcnDL}    ${nrarfcn}:${nrarfcn}
        ${tdd}    set variable if    '${rat}' == 'FDD'    off    on
        ${gnb_cell}    catenate     ${gnb_cell}    set_cell id=${cell} gnb=2 nr_arfcn=${nrarfcn} eci=0x000021f
        ${gnb_cell}    catenate     ${gnb_cell}    pci=${pci_div}:${pci_rem} tac=4 nrci=0x3FFF
        ${gnb_cell}    catenate     ${gnb_cell}    tdd_cell=${tdd}\n
    END
    ${path}    set variable    .//managedObject[@class\="com.nokia.srbts.tnl:IPADDRESSV4"]
    ${gnb_x2_ip}    XML.get element text    ${xml}    ${path}/p[@name\="localIpAddr"]

    ${tmp_file}    os.get file    ${CURDIR}${/}${tl.core.cfg_filename}
    ${tmp_file}    replace string    ${tmp_file}    {edaemon_port}    ${EDAEMON_PORT}
    ${tmp_file}    replace string    ${tmp_file}    {mme_ip}    ${wts_conf['ip']['mme_s1']}
    ${tmp_file}    replace string    ${tmp_file}    {enb_s1_ip}    ${wts_conf['ip']['enb_s1']}
    ${tmp_file}    replace string    ${tmp_file}    {enb_x2_ip}    ${wts_conf['ip']['enb_x2']}
    ${tmp_file}    replace string    ${tmp_file}    {sgw_s1u_ip}    ${wts_conf['ip']['sgw_s1u']}
    ${tmp_file}    replace string    ${tmp_file}    {sgw_s11_ip}    ${wts_conf['ip']['sgw_s11']}
    ${tmp_file}    replace string    ${tmp_file}    {mcc_4g}    ${tl.core.mcc}
    ${tmp_file}    replace string    ${tmp_file}    {mnc_4g}    ${tl.core.mnc}
    ${tmp_file}    replace string    ${tmp_file}    {tac_4g}    ${tac_4g}
    ${tmp_file}    replace string    ${tmp_file}    {gnb_cell}    ${gnb_cell}
    ${tmp_file}    replace string    ${tmp_file}    {gnb_x2_ip}    ${gnb_x2_ip}
    create file    ${RUN_RESULTS}/oran.cfg    content=${tmp_file}

    orusim cleanup


Suite Cleanup For Orusim

    [Teardown]    run keyword and ignore error    ssh.disconnect    connection=${WTS_CONNECTION}

    FOR    ${index}    IN RANGE    ${DOCKER_NB}
        run keyword and ignore error    ssh.disconnect    connection=oru_connection_${index}
    END

    os.run    command=rm ${EXECDIR}/*.ims2
    os.run    command=rm ${EXECDIR}/*.log
    os.run    command=rm ${EXECDIR}/*.txt

    ${date_end}    get current date
    ${time_diff}    subtract date from date    ${date_end}    ${date_beg}    result_format=compact

    log to console    \nTEST COMPLETED (duration = ${blue}${time_diff}${normal})

    run keyword if    '${SBTS21R1_RESTRICTION}' == '${True}'    run keywords
    ...    log to console   \n${red}!!! Reminder: The gNB Netconf Account has been deleted !!!${normal}    AND
    ...    log to console   \n${red}--- Please set the Netconf account manually via WebEM ---${normal}    AND
    ...    log to console   \n${red}--- Then Reset Site via WebEM and launch the robot test again ---${normal}    AND
    ...    log to console   \n${red}--- (without gNB SW downloading or SCF commissioning) ---${normal}


ORUsim Cleanup

    [Documentation]    Kill ongoing orusim docker process
    ...                Remove existing orusim docker image
    ...                Check that the link towards the RU is broken

    ${images}    os.run    command=sudo docker ps -a -q
    os.run    command=sudo docker stop ${images}
    ${images}    os.run    command=sudo docker images -q
    os.run    command=sudo docker rmi ${images}

#    FOR    ${index}    IN RANGE    ${DOCKER_NB}
#        os.run    command=sudo docker kill ${TEST_TYPE}${index}
#    END
#
#    ${images}    os.run    command=sudo docker image ls | grep airphone-docker-local | awk '{ print $3 }'
#
#    @{images_list}  string.split string  ${images}
#    FOR  ${image}  IN  @{images_list}
#        log to console    \nRemove docker image ${image}
#        os.run    command=sudo docker image rm ${image}
#    END

    ###################################################################################################################
    log to console   \nWait until the gNB detects the RU link failure
    ###################################################################################################################
    wait until keyword succeeds    1800s    30s    check cell state    state=Failed
    wait until keyword succeeds    900s    30s    check ru state    state=NotInstalled


ORUsim Docker Image Exit And Cleanup

    [Documentation]    Exit the orusim docker image
    ...                Kill ongoing orusim docker process
    ...                Remove existing orusim docker image
    ...                Check that the link towards the RU is broken

    [Teardown]    run keywords
    ...    log to console    \nRelease gNB connection    AND
    ...    admin.teardown    connection=${GNB_CONNECTION}    AND
    ...    ssh.disconnect    connection=${GNB_CONNECTION}

    ###################################################################################################################
    log to console    \nConnection to gNB ongoing
    ###################################################################################################################
    ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${GNB_CONNECTION}
    admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 name=${GNB_CONNECTION}

    ###################################################################################################################
    log to console   \nExit docker process
    ###################################################################################################################
    FOR    ${index}    IN RANGE    ${DOCKER_NB}
        ssh.send command    command=exit
        ...                 timeout=${30}
        ...                 get_pty=${True}
        ...                 connection=oru_connection_${index}
        ${output}    ssh.read output    connection=oru_connection_${index}
    END

    orusim cleanup

ORUsim Docker Start

    [Arguments]    ${docker_idx}=${0}

    ${param}     set variable    ${EMPTY}
    FOR    ${index}    IN RANGE    len(${o_rus[${docker_idx}]['eth_link_list']})
        ${param}     set variable if    "${index}" == "${0}"
        ...    -i=${param}${o_rus[${docker_idx}]['eth_link_list'][${index}]}
        ...    ${param}, ${o_rus[${docker_idx}]['eth_link_list'][${index}]}
    END

    run keyword if    "${TEST_TYPE}" == "rusim"    rusim iphy.xml update
    ${param}    set variable if    "${TEST_TYPE}" == "rusim"    ${param} -x=${RUN_RESULTS}/iphy.xml    ${param}

    ${tmp_file}    os.get file    ${CURDIR}/resources/start_ORU.sh
    ${tmp_file}    replace string    ${tmp_file}    {name}    ${TEST_TYPE}${docker_idx}

    create file    ${RUN_RESULTS}/start_ORU_${docker_idx}.sh    content=${tmp_file}
    os.run    command=sudo chmod 777 ${RUN_RESULTS}/start_ORU_${docker_idx}.sh

    ###################################################################################################################
    log to console    \nSetup connection for docker
    ###################################################################################################################
    ssh.connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...               username=${tl.core.default_ssh_connection_details.username}
    ...               password=${tl.core.default_ssh_connection_details.password}
    ...               alias=oru_connection_${docker_idx}

    ###################################################################################################################
    log to console    \n${TEST_TYPE} docker image (tag=${DOCKER_TAG}) installation... May take few minutes
    ###################################################################################################################
    ${param}    catenate
    ...    ${param} airphone-docker-local.artifactory-espoo1.int.net.nokia.com/${DOCKER_BRANCH}:${DOCKER_TAG}
    ssh.send command    command=bash ${RUN_RESULTS}/start_ORU_${docker_idx}.sh ${param}
    ...                 timeout=${300}
    ...                 get_pty=${True}
    ...                 connection=oru_connection_${docker_idx}
    ssh.read output until    match=#
    ...                      timeout=${900}
    ...                      connection=oru_connection_${docker_idx}

    ${test}    os.run    command=sudo docker ps -l
    ${verdict}    run keyword and return status    should contain    ${test}    ${TEST_TYPE}${docker_idx}
    ${test}    fetch from right    ${test}    ${SPACE}
    should be equal    ${test}    ${TEST_TYPE}${docker_idx}

    ###################################################################################################################
    log to console    \nDocker image named "${TEST_TYPE}${docker_idx}" is alive
    ###################################################################################################################

    log to console   \nWait until the gNB detects the RU...
    wait until keyword succeeds    900s    30s    check ru state    state=Online    instance=${docker_idx}
    sleep    20s

    run keyword if    '${GNB_COMMISSIONING_REQ}' == '${True}'
    ...    run keywords
    ...        wait until keyword succeeds    1800s    30s    check ru state    state=NotInstalled
    ...            instance=${docker_idx}    AND
    ...        sleep    30s    AND
    ...        wait until keyword succeeds    900s    30s    check ru state    state=Online    instance=${docker_idx}

    ${sw_alarm}    check ru sw alarm    instance=${docker_idx}

    run keyword if    '${sw_alarm}' == '${True}'
    ...    run keywords
    ###################################################################################################################
    ...        log to console    \nRU software download and activate    AND
    ###################################################################################################################
    ...        admin.update_software    sw_package=/home/ute/orusim/NK-RU-POC----------1101.FGP.zip
    ...                                 should_reset_radios=${True}
    ...                                 timeout=${900}
    ...                                 connection=${GNB_CONNECTION}    AND
    ...        sleep    20s    AND
    ...        log to console   \nWait until the gNB detects the RU...    AND
    ...        wait until keyword succeeds    900s    30s    check ru state    state=Online    instance=${docker_idx}
    ...        AND    sleep    30s

    wait until keyword succeeds    900s    30s    check cell state    state=Offline    instance=${docker_idx}


ORUsim Docker Image Installation And Setup

    [Documentation]    Kill ongoing docker process
    ...                Remove existing docker image
    ...                Copy start_ORU.sh script from Robot to the VM
    ...                Setup a connection to the VM for the docker
    ...                Install the docker image with appropriate tag
    ...                Launch the docker image
    ...                Check the installation of the docker image
    ...                Update the RU software
    ...                TO BE IMPLEMENTED : orusim RU sw handling (stored locally in the VM, same whatever gNB load)

    [Teardown]    run keywords
    ...    log to console    \nRelease gNB connection    AND
    ...    admin.teardown    connection=${GNB_CONNECTION}    AND
    ...    ssh.disconnect    connection=${GNB_CONNECTION}

    ###################################################################################################################
    log to console    \nConnection to gNB ongoing
    ###################################################################################################################
    ssh.connect to    hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${GNB_CONNECTION}
    admin.connect_to    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 name=${GNB_CONNECTION}

    orusim cleanup

    ${ip_addr}    set variable    ${wts_conf['ip']}

    FOR    ${item}    IN    @{ip_addr}
        ${port}    os.run    command=ip a | grep ${IP_addr['${item}']} | awk '{ print $6 }'
        run keyword if    '${port}' == ''
        ...    os.run    command=sudo ip addr add ${IP_addr['${item}']}/24 dev ${wts_conf['eth']}
    END

    FOR    ${index}    IN RANGE    ${DOCKER_NB}
        ORUsim Docker Start    ${index}
    END

    wait until keyword succeeds    900s    30s    check cell state    state=Offline
