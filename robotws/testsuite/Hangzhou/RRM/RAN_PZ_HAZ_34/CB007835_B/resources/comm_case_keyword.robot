*** Settings ***
Documentation
...   author: shanshan.zhang@nokia-sbell.com
...   contact: shanshan.zhang@nokia-sbell.com

Library    taf.selenium.sbts       WITH NAME    selenium_coam
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../5GC001937_OTA/resources/5GC001937_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Library     taf.rfrl.common_resources.python.SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot




*** Variables ***
${DU_OAM_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}             ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}            ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}            ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}                  ${tl.gnbs[0].instance_id}
${NRBTS_ID}                ${tl.gnbs[0].instance_id}
${eNB_DU_OAM_IP}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_BTS_ID}              ${tl.enbs[0].instance_id}
${eNB_NRBTS_ID}            ${tl.enbs[0].instance_id}

${SW_build_path}    /home/ute/Downloads
${target_version}
${package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/
${package_version_1525-CA}    ${target_version}
${testpc_host}    ${host_addr}
${testpc_user}    ${host_username}
${testpc_pswd}    ${host_password}

*** Keywords ***
Get CU Type
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    [Teardown]   Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get SBTS Release Version
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    set suite variable    ${release_sbts}
    Get CU Type

Check All Cells in Cell Group Should Be on air
    [Arguments]  ${cell_grp_name}    ${bts_host}=${DU_OAM_IP}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${subCellsInfomation}    coam.get_subcells_status    connection=${connection}
    All cells in cell group should be onair    cell_from_cellgrp=${subCellsInfomation['${cell_grp_name}']}    connection=${connection}
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}

Check BTS Should Be Normal
    [Arguments]  ${bts_host}=${DU_OAM_IP}    ${cell_type}=nr    ${connection}=GNB_OAM
    Log To Console  Check BTS Should Be Normal
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    800s    10s    Verify all cells should be onair    cell_type=${cell_type}    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s    ${cell_type}=nr    ${connection}=GNB_OAM
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    cell_type=${cell_type}
    ...    connection=${connection}

Check Alarm after OAM opraetion
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    #Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

Reset BTS And Wait Until On Air
    [Arguments]  ${connection}=GNB_OAM
    Log To Console    Reset BTS And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    coam.reset_site    connection=${connection}
    Check BTS Should Be Normal
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get All RU Index list
    [Arguments]     ${bts_host}=${DU_OAM_IP}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    ${ru_index_list}    Get All RU Index
    [Return]  ${ru_index_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check cell should be disabled
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]  ${cell_id}   ${connection}=GNB_OAM
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=${connection}
    Cell Should Be Disabled   cell_idx=${cell_id}   cell_group_idx=${cellgrp_id}    connection=${connection}

Get BTS Alarm FaultID
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    Log To Console    get active alarm
    ${alarm_info}    coam.get_active_alarms    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Check fault id should be appear
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${check_fault_id}    ${connection}=GNB_OAM
    ${active_fault_list}    Get BTS Alarm FaultID     connection=${connection}
    run keyword and continue on failure    list should contain value      ${active_fault_list}     ${check_fault_id}

Connect to GNB with ssh
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${timeout}=240s    ${alias_gnb}=gnb_connect
    csn.Connect to    hostname=${DU_OAM_IP}    username=${ASIK_username}    password=${ASIK_password}
    ...    alias=${alias_gnb}    timeout=${timeout}

Disconnect SMOD with ssh
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]      ${alias_gnb}=gnb_connect
    csn.disconnect    connection=${alias_gnb}

Get SFPD ID
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${bbmod_number}    ${timeout}=240s   ${alias_gnb}=gnb_connect    ${loki}=2
    ${sfpd}    csn.Execute    command=bsh ${bbmod_number}:${loki} syscomctl stats list client | grep sfpd | cut -d " " -f 1
    ...    connection=${alias_gnb}    timeout=${timeout}
    ${sfpd}    Strip String    ${sfpd}
    ${sub_sfpd}    Get Substring    ${sfpd}    0    4
    [Return]     ${sub_sfpd}

Get TransceiverTXBiasCurrent value
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param switch: 1: turn off,  0: turn on
    ...                :param S_RF: 3: S_RF1,  4: S_RF2
    [Arguments]     ${sfpd}    ${S_RF}   ${bbmod_number}   ${timeout}=240s    ${alias_gnb}=gnb_connect    ${loki}=2
    ${Transceiver}    csn.Execute
    ...    command=bsh ${bbmod_number}:${loki} sfp_tester get_pti ${S_RF} ${sfpd} | grep Bias | grep TransceiverTXBiasCurrent |cut -d " " -f 2
    ...    connection=${alias_gnb}    timeout=${timeout}
    ${Transceiver}    Strip String    ${Transceiver}
    [Return]   ${Transceiver}

Change two optical transmission by command
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param switch: 1: turn off,  0: turn on
    ...                :param S_RF: 3: S_RF1,  4: S_RF2
    [Arguments]     ${bbmod_number}  ${sfpd}    ${alias_gnb}=gnb_connect
    ...    ${S_RF1}=3   ${S_RF2}=4   ${switch}=1     ${timeout}=240s   ${loki}=2
    csn.Execute    command=bsh ${bbmod_number}:${loki} sfp_tester set_tx ${S_RF1} 1 ${switch} ${sfpd}
    ...    connection=${alias_gnb}    timeout=${timeout}
    csn.Execute    command=bsh ${bbmod_number}:${loki} sfp_tester set_tx ${S_RF2} 1 ${switch} ${sfpd}
    ...    connection=${alias_gnb}    timeout=${timeout}
    sleep   3s
    ${Transceiver1}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF1}    bbmod_number=${bbmod_number}
    ${Transceiver2}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF2}    bbmod_number=${bbmod_number}
    run keyword if   '${switch}'=='0'    should be true    ${Transceiver1}>0    ELSE    should be true    ${Transceiver1}==0
    run keyword if   '${switch}'=='0'    should be true    ${Transceiver2}>0    ELSE    should be true    ${Transceiver2}==0

Change one optical transmission by command
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param switch: 1: turn off,  0: turn on
    ...                :param S_RF: 3: S_RF1,  4: S_RF2
    [Arguments]     ${bbmod_number}  ${sfpd}    ${alias_gnb}=gnb_connect
    ...    ${S_RF}=3     ${switch}=1     ${timeout}=240s   ${loki}=2
    csn.Execute    command=bsh ${bbmod_number}:${loki} sfp_tester set_tx ${S_RF} 1 ${switch} ${sfpd}
    ...    connection=${alias_gnb}    timeout=${timeout}
    sleep   3s
    ${Transceiver}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF}    bbmod_number=${bbmod_number}
    run keyword if   '${switch}'=='0'    should be true    ${Transceiver}>0    ELSE    should be true    ${Transceiver}==0

Poweroff On RU And Wait Until On Air
    [Arguments]    ${ru_index}=${0}    ${gnb_index}=0    ${connection}=GNB_OAM
    Log To Console    Poweroff On RU And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    log to console    \n***RF Index ${ru_index} in Testline File Power OFF***
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].pdu_port.pdu.vendor}
    sleep    10s
    log to console    \n***RF Index ${ru_index} in Testline File Power ON***
    Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].pdu_port.pdu.vendor}
    sleep    2s
    Check BTS Should Be Normal
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Cell Group Lock/Unlock And Wait Until On Air
    [Arguments]    ${cellgroup_idx}=${2}    ${connection}=GNB_OAM
    Log To Console    Cell Group Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock Cell Group
    coam.lock_cell_group    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP_A-${cellgroup_idx}
    ...    timeout=${60}    connection=${connection}
    sleep    10s
    Log To Console    Unlock Cell Group
    coam.unlock_cell_group    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP_A-${cellgroup_idx}
    ...    timeout=${60}    connection=${connection}
    Check BTS Should Be Normal
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

RU Lock/Unlock And Wait Until On Air
    [Arguments]    ${RMOD_idx}=${3}    ${connection}=GNB_OAM
    Log To Console    RU Lock/Unlock And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${connection}
    sleep    2s
    Log To Console    Lock RU
    coam.lock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    sleep    3s
    Log To Console    Ulock RU
    coam.unlock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    Check BTS Should Be Normal
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

X2Link lock/Unlock And Wait Until On Air
    [Arguments]  ${connection}=GNB_OAM
    Log To Console    X2Link lock/Unlock And Wait Until On Air
    sleep    2s
    Log To Console    Lock X2Link
    Modify X2Link Parameter    Actual_value=locked
    sleep    30s
    Log To Console    Unlock X2Link
    Modify X2Link Parameter    Actual_value=unlocked
    Check BTS Should Be Normal
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Modify X2Link Parameter
    [Arguments]    ${Actual_value}    ${LTE_idx}=${LTE_index}    ${alias}=enb    ${ENBMRBTS_ID}=${eNB_BTS_ID}    ${LNBTS_ID}=${eNB_NRBTS_ID}
    Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    ...    connection=${alias}
    ${dict}    create dictionary    parameterName=administrativeState    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${ENBMRBTS_ID}/LNBTS-${LNBTS_ID}/LNADJGNB-${LTE_idx}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=${alias}
    sleep    10s
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${alias}

Online Cell addition deletion
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]  ${addition_deletion_cell}=1  ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${cell_list}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${OUTPUT_DIR}
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
    ${cell_list_len}    get length    ${cell_list}
    FOR    ${index}    IN RANGE    ${cell_list_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
        ...    abbr=nrCellList    filter_param=List of NR cells assigned to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cell}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
        ...    abbr=nrCellList    filter_param=List of NR cells assigned to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air
    ${cell_list_delete}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    ${cell_list_len_delete}    get length    ${cell_list_delete}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${1}
    selenium_coam.add_element
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    abbr=nrCellList    filter_param=List of NR cells assigned to cell group
    ...    timeout=15
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    abbr=nrCellList    filter_param=List of NR cells assigned to cell group
    ...    new_value=${addition_deletion_cell}
    ...    node_index=${cell_list_len_delete}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    sleep    60s
    verify all cells should be onair
    ${cell_list_add}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    lists should be equal     ${cell_list_add}    ${cell_list}
    [Teardown]     selenium logout and close browser

#*** UUF4ALL Keywords ***
SWM supports provision SW build package via WebUI
    step1:Login WebUI
    step2:check current sw version 1
    step3:upgrade site with active
    step4:check SW version after upgrade
    step6:check site status

Classical gNB Software Rollback successfully via WebUI
    step1:Login WebUI
    step2:check current sw version 2
    step3:execute rollback
    step5:ENV recovery
    step6:check site status


step1:Login WebUI
    log to console    step1:Login WebUI
    Wait Until Keyword Succeeds    2min    10s    WEBUI Login    ${TRUE}

step2:check current sw version 1
    log to console   step2:check current sw version 1
    ${pre_active_version_1}    wait until keyword succeeds    1min    10s    check SW version    Active
    set suite variable    ${pre_active_version_1}
    sleep    5s

step2:check current sw version 2
    log to console    step2:check current sw version 2
    ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
    ${pre_active_version_2}    set variable    ${output}
    set suite variable    ${pre_active_version_2}
    ${pre_passive_version_2}    set variable    ${version}[Passive]
    set suite variable    ${pre_passive_version_2}
    sleep    5s

step3:upgrade site with active
    log to console    step3:upgrade site with active
    set suite variable    ${upgrade_package_path}    ${SW_build_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    ${upgrade_package_path}
    run keyword if  not ${status}     download_upgrade_package
    csn.disconnect    connection=TESTPC
    wait until keyword succeeds     5 min   10 sec
    ...     coam.connect to       bts_host=${asik_addr}     name=coam_admin
    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=coam_admin

download_upgrade_package
    log to console    SW package does not exist in ute server
    ${package_full_link}    Get link For Download from external value
    ${upgrade_package_path}    Download SW Build to VM     package_full_link=${package_full_link}

Get link For Download from external value
    @{result}    string.split string    string=${target_version}    separator=_
    ${result5}     convert to string    ${result}[-5]
    ${if_SBTS21B}     convert to string    ${result}[-3]
    set suite variable    ${result5}
    set suite variable    ${if_SBTS21B}
    ${package_full_link}    Set Variable    ${package_link}${result5}_packages/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${md5_file}     set variable    ${output}[0]
    ${md5_value}      OperatingSystem.get file    ${md5_file}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link} -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${upgrade_package_path}     set variable    ${output}[0]
    sleep    5min
    wait until keyword succeeds    10min    10s    check the download completed    ${upgrade_package_path}     ${md5_value}
    [Return]      ${upgrade_package_path}

step4:check SW version after upgrade
    log to console    step4:check SW version after upgrade
    wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully

Check if Airscal Upgrade Successfully
    ${If_SBTS00}    Run Keyword and Ignore Error    should contain    ${package_version_1525-CA}    SBTS00
    run keyword if     '${If_SBTS00[0]}' == 'PASS'       Check Common Load Version
    ...    ELSE      Check 21B Version
    csn.reset_cache

Check Common Load Version
    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    ${str}=	    Remove String	    ${package_version_1525-CA}    SBTS00
    should contain    ${result}    ${str}
    csn.reset_cache

Check 21B Version
    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    should contain    ${result}    ${package_version_1525-CA}
    csn.reset_cache

step5:ENV recovery
    log to console    step5:ENV recovery
    
step6:check site status
    log to console    step6:check site status
    Check BTS Should Be Normal
    run keyword and ignore error     selenium_coam.enable_screen_lock

step3:execute rollback
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${timeout}=10 min    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
    login    node_type=${node_type}    connection=${connection}    gnb_index=${index}    enb_index=${index}
    Log to console    1.check current version
    Get current version to check    connection=${connection}
    Log to console    2.rollback
    sleep    30s
    rollback_build    connection=${connection}
    sleep    1min
    Log to console    3. check version after rollback
    wait until keyword succeeds     40min    2min    Check if rollback Successfully    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    tearDown for logout    connection=${connection}

login
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb
    ...    ${enb_index}=${0}
    Run Keyword If    '${node_type}'=='gnb'
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE IF    '${node_type}'=='enb'
    ...    Connect to eNB coam via ssl    connection=${connection}    enb_index=${enb_index}

logout
    [Arguments]    ${connection}=GNB_OAM
    COAM Teardown gnb connections    connection=${connection}

Get current version to check
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${current_activate_version}    ${current_passive_version}    ${current_planned_version}    Get software versions
    ...    connection=${connection}
    Set Suite Variable    ${current_activate_version}
    Set Suite Variable    ${current_passive_version}
    Set Suite Variable    ${current_planned_version}
    [Teardown]    logout    connection=${connection}

Get software versions
    [Arguments]    ${connection}=GNB_OAM
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${passive_version}    Set Variable    ${software}[Passive SW version]
    ${planned_version}    Set Variable    ${software}[Planned SW version]
    [Return]    ${activate_version}    ${passive_version}    ${planned_version}

rollback_build
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    coam.rollback_software    timeout=2400    connection=${connection}
    [Teardown]    logout    connection=${connection}

Check if rollback Successfully
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${after_activate_version}    ${after_passive_version}    ${after_planned_version}    Get software versions
    ...    connection=${connection}
    Should Be Equal    ${current_passive_version}    ${after_activate_version}
    Should Be Equal    ${current_activate_version}    ${after_passive_version}
    [Teardown]    logout    connection=${connection}

tearDown for logout
    [Arguments]    ${connection}=GNB_OAM
    FOR    ${count}    IN RANGE    2
        logout    connection=${connection}
    END

step7:logout webui
    log to console    step7:logout webui
    run keyword and ignore error    WEBUI Logout    virtual_disable=${TRUE}

Common Case Teardown
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${is_save_snapshot}=True    ${is_save_snapshot_for_second_gnb}=False
    ...             ${connection}=GNB_OAM0    ${connection_for_second_gnb}=GNB_OAM1
    ...             ${timeout}=900    ${alais}=ASIK Master0    ${alais_for_second_gnb}=ASIK Master1
    Run Keyword If    ${is_save_snapshot}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    Connect to Common Unit Master    alias=${alais}    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api    connection=${connection}
    ...                                                                                                     timeout=${timeout}
    Run Keyword If    ${is_save_snapshot_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    Connect to Common Unit Master    alias=${alais_for_second_gnb}    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    ...                                                                  connection=${connection_for_second_gnb}
    ...                                                                  timeout=${timeout}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=ps -ef | grep admin_api |awk '{print $2}' | xargs kill -9
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais_for_second_gnb}    AND
    ...    csn.Reset Cache    AND    CI_interface.Common Case Teardown

check the download completed
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${sum}=        Set Variable     sha256sum ${upgrade_package_path}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.split string    ${output}
    should be equal    ${md5_value}    ${res}[0]

Connect to eNB coam via ssl
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${enb_index}=${0}
    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}
    Log to console    \nINFO:connect to eNB successfully

Get BTS Software Version
    [Arguments]    ${connection}=GNB_OAM
    login    connection=${connection}
    ${parameters}    coam.get_parameters_for_all    class_name=BTS    timeout=20s    connection=${connection}
    ${ActiveVersion}    set variable    ${parameters}[${0}][activeSoftwareVersion]
    ${PassiveVersion}    set variable    ${parameters}[${0}][passiveSoftwareVersion]
    log to console    ------BTS Software Build version------
    log to console    Active: ${ActiveVersion}
    log to console    Passive: ${PassiveVersion}
    [Teardown]    Run Keyword And Ignore Error    logout    connection=${connection}
