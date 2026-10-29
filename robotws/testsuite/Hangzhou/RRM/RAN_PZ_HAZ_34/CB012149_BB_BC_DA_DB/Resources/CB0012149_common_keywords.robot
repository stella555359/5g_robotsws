*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB0012149
Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149_BB_BC_DA_DB/Resources/CB0012149_common_keywords.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/capture_logs_via_gnb_logs_tool.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/upgrade_rollback_keywords.py
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149_BB_BC_DA_DB/Resources/CB012149_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${enb_instance}     ${tl.enbs[0].instance_id}

${scf_path}    /opt/workspace/CRT/Master/SCF_file/

${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

${download_link}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/

${case_logs_path}    /opt/workspace/CRT/Master/Case_Logs/
${CB012149_72a_to_72e_json_file_name}    CB012149_72a_to_72e.json

*** Keywords ***
###BTS keyword###
Setup for Env cell on-air for 2 gnb
    [Arguments]    ${is_commission}=True    ${is_commission_for_second_gnb}=True    ${tl_scf_file_name}=${tl_scf_file_name1}
    Common Case TestLine Setup    is_commission=${is_commission}    is_commission_for_second_gnb=${is_commission_for_second_gnb}
    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name}    golden_scf_name_gnb2=${tl_scf_file_name2}
#    ${rc}    ${output}=    run and return rc and output    cd /opt/workspace/Tool/;./modify_numpy_version.sh

COAM Save snapshot
    FOR    ${index}    IN   @{GNB_INDEX_list_snapshot}
        get gnb snapshot    gnb_index=${index}
    END

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

check cell on-air status
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    Wait until keyword succeeds    1m    10s    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

get required value of parameter
    [Arguments]    ${Abbreviation}    ${class_name}=NRCELL    ${gnb_index}=${0}    ${distname_id}=${0}    ${connection}=GNB_OAM
    ${parameter_value}=    get parameter value    class_name=${class_name}    Abbreviation=${Abbreviation}
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}    connection=${connection}
    [Return]    ${parameter_value}

get parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    ${distname_id}=${1}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    sleep    2s
    @{MOs_a}    coam.get_managed_objects    class_name=${class_name}_A    connection=${connection}
    ${MO_ID}=    get_corresponding_mo_id    parameter_list=${MOs_a}    distname_id=${distname_id}
    &{dict_Abbreviation}     coam.get_parameters    dist_name=${MOs_a[${MO_ID}]['distName']}
    ...    pattern=${Abbreviation}    connection=${connection}
    sleep    5
    [Return]    ${dict_Abbreviation['${Abbreviation}']}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

online add list parameter
    [Arguments]    ${parameters}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter
    ...    parameters=${parameters}    operation=update    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online update list parameter model
    [Arguments]    ${parameters}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter
    ...    parameters=${parameters}    operation=update    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online delete list parameter
    [Arguments]    ${parameters}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter
    ...    parameters=${parameters}    operation=delete    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online recover delete and add list parameter
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter    parameters=${LIST_PARAM_RECOVER_DELETE_gnb1_04444966}    operation=delete
    COAM Wait for gnb ready and cell setup
    online operate list parameter    parameters=${LIST_PARAM_RECOVER_gnb1_04444966}    operation=update
    [Teardown]    COAM Teardown gnb connections

#online change list parameters
#    [Arguments]    ${gnb_index}=${0}
#    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    online operate list parameter
#    ...    parameters=${PARAM_12149_gnb1_DB_01_delete_CELL_700}    operation=delete
#    ...    skip_parameter_relation_errors=${True}
#    ...    should_activate=${False}
#    online operate list parameter
#    ...    parameters=${PARAM_12149_gnb1_DB_01_delete_CELL_701}    operation=delete
#    ...    skip_parameter_relation_errors=${True}
#    ...    should_activate=${False}
#    online operate list parameter
#    ...    parameters=${PARAM_12149_gnb1_DB_01_change_frame_CELL_700_1}    operation=update
#    ...    skip_parameter_relation_errors=${True}
#    ...    should_activate=${False}
#    online operate list parameter
#    ...    parameters=${PARAM_12149_gnb1_DB_01_change_frame_CELL_700_2}    operation=update
#    ...    skip_parameter_relation_errors=${True}
#    ...    should_activate=${False}
#    online operate list parameter
#    ...    parameters=${PARAM_12149_gnb1_DB_01_change_frame_CELL_701_1}    operation=update
#    ...    skip_parameter_relation_errors=${True}
#    ...    should_activate=${False}
#    online operate list parameter
#    ...    parameters=${PARAM_12149_gnb1_DB_01_change_frame_CELL_701_2}    operation=update
#    ...    skip_parameter_relation_errors=${True}
#    ...    should_activate=${True}
#    [Teardown]    COAM Teardown gnb connections

online operate list parameter
    [Documentation]    This keyword is used to operate list parameter from the gNB
    ...    Author: ming.shi@nokia-sbell.com
    [Arguments]
    ...    ${parameters}
    ...    ${operation}=update
    ...    ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${True}
    ...    ${timeout}=${300}
    ...    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning
    ...    dist_name=${parameters}[dist_name]    parameter=${parameters}[parameter]    operation=${operation}
    ...    value=${parameters}[value]    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}    timeout=${timeout}    connection=${connection}

check cell on air status
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_${gnb_index}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    Wait until keyword succeeds    ${300}    ${10}    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Block unblock cell on BTS
    [Arguments]    ${dist_name}    ${connection}=GNB_OAM    ${timeout}=600    ${detailed_output}=${False}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    coam.block_cell    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}
    coam.unblock_cell    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}
    ...    detailed_output=${detailed_output}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

###PA keyword###
PA one cell 0 on and set other cell value
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    Change Attenuation value    cell=5Gcell${cellid}    value=${set_value}
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        run keyword if    '${cellid}'!='${cellnum}'    Change Attenuation value    cell=5Gcell${cellnum}    value=${127}
    END
    Change Attenuation value    cell=4Gcell1    value=${127}

change scf file
    [Arguments]    ${scf_path}    ${scf_name}    ${new_scf_path}
    ${file_path}    Join Path    ${scf_path}    ${scf_name}
    scf.load_scf    file_path=${file_path}
    FOR    ${delete}    IN    @{LIST_12149_gnb1_DB_01_delete}
        scf.remove_element_from_scf
        ...    dist_name=${delete}[dist_name]
        ...    list_name=${delete}[list_name]
        ...    p_name=${delete}[p_name]
        ...    index=${delete}[index]
    END
    FOR    ${add}    IN    @{LIST_12149_gnb1_DB_01_add}
        scf.add_item_to_list
        ...    dist_name=${add}[dist_name]
        ...    list_name=${add}[list_name]
        ...    elements=${add}[elements]
    END
    FOR    ${update_list}    IN    @{LIST_12149_gnb1_DB_01_change_frame_Structure}
        ${result}=    Evaluate    ${update_list}.get('elements')
        IF    ${result} != ${None}
            ${eles}=    Set Variable    ${update_list}[elements]
            FOR    ${ele}    IN    @{eles}
                scf.modify_scf_element
                ...    value=${ele}[value]
                ...    dist_name=${update_list}[dist_name]
                ...    p_name=${ele}[p_name]
                ...    list_name=${update_list}[list_name]
                ...    index=${ele}[index]
            END
        ELSE
            scf.modify_scf_element
            ...    value=${update_list}[value]
            ...    dist_name=${update_list}[dist_name]
            ...    list_name=${update_list}[list_name]
        END
    END
    FOR    ${update_paras}    IN    @{PARAM_12149_gnb1_DB_01_change_frame_Structure}
        scf.modify_scf_element
        ...    value=${update_paras}[value]
        ...    dist_name=${update_paras}[dist_name]
        ...    p_name=${update_paras}[p_name]
    END
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${new_file_path}    Join Path    ${new_scf_path}    ${timestamp}_updated.xml
    scf.save_scf    file_path=${new_file_path}
    [Return]    ${new_file_path}

PA one cell 0 on and set other cell value 4 port
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    IF    ${cellid} == 4
        Change Attenuation value    cell=5Gcells${cellid}    value=${set_value}
    ELSE
        Change Attenuation value 4 port    cell=5Gcells${cellid}    value=${set_value}
    END
    FOR  ${index}    IN RANGE    ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    '${cellid}'!='${cellnum}'
            IF    ${cellnum} == 4
                Change Attenuation value    cell=5Gcells${cellnum}    value=${127}
            ELSE
                Change Attenuation value 4 port    cell=5Gcells${cellnum}    value=${127}
            END
        END
    END
    Change Attenuation value 4 port    cell=4Gcells1    value=${127}

Change Attenuation value
    [Arguments]    ${cell}    ${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Run Keyword If    '${cell}' == '5Gcell3'    Run Keywords
    ...    Set Programmable Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    ...    AND    Set Programmable Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Change Attenuation value 4 port
    [Arguments]    ${cell}    ${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT3}    value=${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT4}    value=${value}

Set Programmable Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    atten.set_attenuation     port=${ports}    value=${value}

PA one cell 0 on and set other cell value 4 port for T348
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${6}
    IF    '${cellid}' == '5' or '${cellid}' == '6'
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr_1}
    ELSE
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr}
    END
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' == '5' or '${cellnum}' == '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr_1}
        ELSE IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' != '5' or '${cellnum}' != '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr}
        END
    END

Change Attenuation value 4 port for multi PAs
    [Arguments]    ${cell}    ${value}    ${ip_addr}=${att_ipaddr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT1}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT2}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT3}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT4}    value=${value}    ip_addr=${ip_addr}

Set Programmable Attenuation Value for multi PAs
    [Arguments]    ${ports}    ${value}    ${ip_addr}=${att_ipaddr}
    atten.setup_attenuator    ip_addr=${ip_addr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    atten.set_attenuation     port=${ports}    value=${value}

###UE keyword###
Get all X70 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1385
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

Switch QCOM APN to muti DRB
    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
    Get all X70 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    [Teardown]    csn.disconnect    connection=cygwin

Start only DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Connect to control pc via cygwin    ue_index=${ue_index}
    Get Commercial UE IP with first UE    ue_index=${ue_index}
    # ue ip get from keyword 'Get Commercial UE IP with first UE'
    mtk m80 make traffic    ue_ip=${UE_IP}    direction=${direction}    ue_index=${ue_index}
    ...    dl_throughput=${dl_throughput}    duration=${duration}    dl_port=${dl_port}
    sleep    15s
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

Start only UL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}    ${ul_port}=${UL_PORT}    ${duration}=${600}
    mtk m80 make traffic    direction=${direction}    ue_index=${ue_index}    ul_throughput=${ul_throughput}
    ...    duration=${duration}    ul_port=${ul_port}
    sleep    15s
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

mtk m80 make traffic
    [Arguments]
    ...            ${direction}
    ...            ${ue_ip}=127.0.0.1
    ...            ${ue_index}=${0}
    ...            ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${ul_port}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...            ${ul_throughput}=100M
    ...            ${dl_throughput}=2000M
    ...            ${duration}=600
    ...            ${buffer_size}=1400B
    ...            ${appserver}=APPserver
    ...            ${protocol}=udp
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    Run Keyword If    '${direction}' == 'DL'
    ...    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${ue_ip}
    ...                                                          dl_time=${duration}
    ...                                                          dl_port=${dl_port}
    ...                                                          dl_throughput=${dl_throughput}
    ...                                                          dl_length=${buffer_size}
    ...                                                          appserver=${appserver}
    ...                                                          protocol=${protocol}
    ...                                                          ue_index=${ue_index}
    Run Keyword If    '${direction}' == 'UL'
    ...    traffic_via_iperf.Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                             ul_time=${duration}
    ...                                                             ul_port=${ul_port}
    ...                                                             ul_throughput=${ul_throughput}
    ...                                                             ul_length=${buffer_size}
    ...                                                             appserver=${appserver}
    ...                                                             protocol=${protocol}
    ...                                                             iperf_path=${ue_iperf_path}

Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL
    Log    ${ue_type}
#    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}
    Run Keyword If    '${direction}' == 'DL'
    ...    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword If    '${direction}' == 'UL'
    ...    Run Keyword And Ignore Error    Close the iperf process on android ue
    ...    ue_index=${ue_index}    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}

Start only DL traffic and check tput common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    ...    dl_port=${dl_port}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}

Start only UL traffic and check tput common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}    ${ul_port}=${UL_PORT}    ${duration}=${600}
    ...    ${iperf_type}=via_app
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    ...    ul_port=${ul_port}    iperf_type=${iperf_type}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

Stop DL or UL traffic common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    ...    ${iperf_type}=via_app
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}
    ...    iperf_type=${iperf_type}

Make a VoNR call(+6688) on mtk80
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 259 1954 342 1059    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on SDX80
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

QCM UE Recover Detach
    [Arguments]     ${ue_index}=${0}    ${status}=${0}    ${ue_type}=${ue_type}
    QCM UE hang up VONR call    ue_index=${ue_index}
    check voice call status    ue_index=${ue_index}    status=${status}
    UE.UE Detach     ue_type=${ue_type}     ue_index=${ue_index}

QCM UE hang up VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cpc_${ue_index}
    sleep      5s
    csn.disconnect      connection=cpc_${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    should contain    ${result}    mCallState=${status}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

mtk ue attach on 348
    [Arguments]    ${scf_name}=gNB1_Golden_SCF.xml
    ${ssRsrp_output}=    reboot ue to attach    ue_index=${1}
    verify ue attach success via ssRsrp    ssRsrp_output=${ssRsrp_output}    dist_name=${NRCELL2name}    p_name=physCellId
    ...    scf_name=${scf_name}

reboot ue to attach
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${cpc_alias}=cpc_${ue_index}
    UE Reboot with adb command    ue_index=${ue_index}
    wait until keyword succeeds    3min    2s    Connect to control pc enhanced    ue_index=${ue_index}
    sleep    30s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry | grep -i "ssRsrp"    connection=${cpc_alias}
    ${ssRsrp_output}   csn.read_output    connection=${cpc_alias}
    [Teardown]    csn.disconnect    connection=${cpc_alias}
    [Return]    ${ssRsrp_output}

verify ue attach success via ssRsrp
    [Arguments]    ${ssRsrp_output}    ${dist_name}    ${p_name}    ${scf_name}=gNB1_Golden_SCF.xml
    ${mPci_value}=    get_mPci_value_from_adb_command_output    output=${ssRsrp_output}
    ${value}=    Get value of parameter from SCF file    golden_scf_name=${scf_name}    dist_name=${dist_name}    p_name=${p_name}
    Should Be Equal As Strings    ${mPci_value}    ${value}

Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
    Check UE device exist    ue_index=${ue_index}
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}

Step4: Detach UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

enable airplane mode on mtk m80 dujac
    [Arguments]    ${ue_index}=${0}
    ${result} =    Check airplane mode status on    ue_index=${ue_index}
    IF    '${result}'=='${False}'
        click airplane mode once on mtk m80 dujac    ue_index=${ue_index}
    END

click airplane mode once on mtk m80 dujac
    [Documentation]
    ...    Author: ming.shi@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${mtk_m80_home_button}=    Set Variable    82
    ${mtk_m80_swipe_unlock}=    Set Variable    777 1791 777 608
    ${mtk_m80_swipe_top_settings}=    Set Variable    592 598 592 1931
    ${mtk_m80_airplane}=    Set Variable    933 1167
    Connect to control pc via cygwin    ue_index=${ue_index}
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${mtk_m80_home_button}    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${mtk_m80_swipe_unlock}    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=cygwin
    sleep   2s
    ${output}   csn.read_output    connection=cygwin
    # top_settings
    FOR    ${i}    IN RANGE    ${3}
        csn.send_command    command=adb -s ${serial_number} shell input swipe ${mtk_m80_swipe_top_settings}    connection=cygwin
    END
    Sleep    2s
    #####Tap the airplane mode switch to enable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${mtk_m80_airplane}    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

###Common keyword###
add or delete 5QI via npc dynamic rule
    [Arguments]    ${imsi}    ${rule}
    ${return_code}    ${return_result}    dynamic rule submit    imsi=${imsi}    rule=${rule}
    run keyword if    '${return_result}' == 'Success'    run keywords
    ...    log    ${rule} operate Success!
    ...    AND    log to console    ${rule} operate Success!
    ...    ELSE    run keywords
    ...    log    ${rule} operate Failed!
    ...    AND    log to console    ${rule} operate Failed!
    ...    AND    fail    msg=need to check on SRN CHINA web page

###PM counter###
Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

get required kpi values via pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=CB008246_E_006_KPI.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_kpis_of_kpi_file_via_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}


get kpi from pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=CB008246_E_006_KPI.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_dict_kpis_from_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}

check required KPI value via pm file
    [Arguments]    ${KPI_name_list}    ${check_field}    ${dict_kpi_get}
    ...    ${equal_specfied}=${0}    ${larger_specfied}=${0}    ${less_specfied}=${0.011}    ${greater_than_or_equal_specfied}=${0}
    FOR    ${KPI_name}    IN    @{KPI_name_list}
        Run Keyword IF    '${check_field}' == 'equal_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] == ${equal_specfied}
        ...    ELSE IF    '${check_field}' == 'larger_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] > ${larger_specfied}
        ...    ELSE IF    '${check_field}' == 'less_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] < ${less_specfied}
        ...    ELSE IF    '${check_field}' == 'greater_than_or_equal_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] >= ${greater_than_or_equal_specfied}
    END

###TTI###
get logs from gnb_logs folder
    [Arguments]    ${tool_download_path}    ${tool_path}=${tool_download_path}/gnb_logs
    ...    ${type}=tti_packed
    ${get_log_name_command}    catenate    cd ${tool_path};ls -l | grep BTS | awk '{print $9}'
    ${rc}    ${output}    run and return rc and output    command=${get_log_name_command}
    should be equal as integers    ${rc}    0
    ${output}     strip string    ${output}
    ${log_name}    ${ext_name}=    split extension    path=${output}
#    @{log_name_list}    split string    ${output}    .
#    @{log_type_list}    split string    @{log_name_list}[0]    _
    ${rc}    run and return rc    command=cd ${tool_path};unzip ${output}
    should be equal as integers    ${rc}    0
    ${rc}    run and return rc    command=cd ${tool_path};rm -rf ${output}
    should be equal as integers    ${rc}    0
#    ${rc}    run and return rc    command=cd ${tool_path}/${log_name}/${type}
    ${fsp_folder}    list directories in directory    path=${tool_path}/${log_name}/${type}
    ${log_files}    run keyword if    '${type}' == 'tti_packed'
    ...    list files in directory    path=${tool_path}/${log_name}/${type}/${fsp_folder}[0]     pattern=*.csv
    ...    ELSE    list files in directory    path=${tool_path}/${log_name}/${type}
    ${current_time}=    get current date    result_format=%Y%m%d%H%M%S
    create directory    path=${epc_log_path}/${current_time}
    directory should exist    path=${epc_log_path}/${current_time}
    ${rc}    ${output}    run keyword if    '${type}' == 'tti_packed'
    ...    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/${fsp_folder}[0]/* ${epc_log_path}/${current_time}
#    ...    copy files    source=${tool_path}/${log_name}/${type}/${fsp_folder}[0]/*    destination=${epc_log_path}/${current_time}
#    ...    ELSE    copy files    source=${tool_path}/${log_name}/${type}/*    destination=${epc_log_path}/${current_time}
    ...    ELSE    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
    [Teardown]    run keywords
    ...    run    command=cd ${tool_path};rm -rf ${log_name}
    ...    AND    directory should not exist    path=${tool_path}/${log_name}
    [Return]    ${log_files}    ${current_time}

get logs from gnb_logs folder from v2.67
    [Arguments]    ${tool_download_path}    ${tool_path}=${tool_download_path}/gnb_logs
    ...    ${gnb_index}=${0}
    ...    ${type}=tti    ${distname_id}=${0}
    ${get_log_name_command}    catenate    cd ${tool_path};ls -l | grep BTS | awk '{print $9}'
    ${rc}    ${output}    run and return rc and output    command=${get_log_name_command}
    should be equal as integers    ${rc}    0
    ${output}     strip string    ${output}
    ${log_name}    ${ext_name}=    split extension    path=${output}
    ${rc}    run and return rc    command=cd ${tool_path};unzip ${output}
    should be equal as integers    ${rc}    0
    ${rc}    run and return rc    command=cd ${tool_path};rm -rf ${output}
    should be equal as integers    ${rc}    0
    ${nrCellIdentity}=    get required value of parameter
    ...    Abbreviation=nrCellIdentity    gnb_index=${gnb_index}    distname_id=${distname_id}
    ${l2_num}=    return_l2_num_from_gnb_logs_tool_log    gnb_logs_tool_path=${tool_path}    log_folder=${log_name}
    ...    nrCellIdentity=${nrCellIdentity}
    ${log_files}    run keyword if    '${type}' == 'tti'
    ...    list files in directory    path=${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace     pattern=*.csv
    ...    ELSE    list files in directory    path=${tool_path}/${log_name}/${type}
    ${current_time}=    get current date    result_format=%Y%m%d%H%M%S
    create directory    path=${epc_log_path}/${current_time}
    directory should exist    path=${epc_log_path}/${current_time}
    ${rc}    ${output}    run keyword if    '${type}' == 'tti'
    ...    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace/* ${epc_log_path}/${current_time}
    ...    ELSE    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
    [Teardown]    run keywords
    ...    run    command=cd ${tool_path};rm -rf ${log_name}
    ...    AND    directory should not exist    path=${tool_path}/${log_name}
    [Return]    ${log_files}    ${current_time}

get logs from gnb_logs folder from v2.67 with multi cells
    [Arguments]    ${tool_download_path}    ${tool_path}=${tool_download_path}/gnb_logs
    ...    ${gnb_index}=${0}
    ...    ${type}=tti    ${distname_id}=${0}
    ${get_log_name_command}    catenate    cd ${tool_path};ls -l | grep BTS | awk '{print $9}'
    ${rc}    ${output}    run and return rc and output    command=${get_log_name_command}
    should be equal as integers    ${rc}    0
    ${output}     strip string    ${output}
    ${log_name}    ${ext_name}=    split extension    path=${output}
    ${rc}    run and return rc    command=cd ${tool_path};unzip ${output}
    should be equal as integers    ${rc}    0
    ${rc}    run and return rc    command=cd ${tool_path};rm -rf ${output}
    should be equal as integers    ${rc}    0
    ${log_files_list}    Create List
    ${folders_name}    Create List
    FOR    ${id}    IN    @{distname_id}
        ${nrCellIdentity}=    get required value of parameter    Abbreviation=nrCellIdentity    gnb_index=${gnb_index}    distname_id=${id}
        ${l2_num}=    return_l2_num_from_gnb_logs_tool_log    gnb_logs_tool_path=${tool_path}    log_folder=${log_name}
        ...    nrCellIdentity=${nrCellIdentity}
        ${log_files}    run keyword if    '${type}' == 'tti'
        ...    list files in directory    path=${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace     pattern=*.csv
        ...    ELSE    list files in directory    path=${tool_path}/${log_name}/${type}
        ${current_time}=    get current date    result_format=%Y%m%d%H%M%S
        create directory    path=${epc_log_path}/${current_time}
        directory should exist    path=${epc_log_path}/${current_time}
        ${rc}    ${output}    run keyword if    '${type}' == 'tti'
        ...    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace/* ${epc_log_path}/${current_time}
        ...    ELSE    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
        Append To List    ${log_files_list}    ${log_files}
        Append To List    ${folders_name}    ${current_time}
    END
    [Teardown]    run keywords
    ...    run    command=cd ${tool_path};rm -rf ${log_name}
    ...    AND    directory should not exist    path=${tool_path}/${log_name}
    [Return]    ${log_files_list}    ${folders_name}

get_required_tti_file_name
    [Arguments]    ${files_list}    ${required_file_name}=dl__all.csv
    FOR    ${file}    IN    @{files_list}
        ${status}    run keyword and return status    should contain    ${file}    ${required_file_name}
        exit for loop if    '${status}' == 'True'
        set test variable    ${file}
    END
    [Return]    ${file}

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[-1]


###performance###
get_expect_throughput
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_file_name}    ${cell_id}
    ${dl_expected_throughput}    ${ul_expected_throughput}=    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${tl_scf_dir_path}${tl_scf_file_name}    cell_id=${cell_id}
    [Return]    ${dl_expected_throughput}    ${ul_expected_throughput}

Check_throughput with CA
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL    ${duration}=30s
    ...    ${scellid}=1   ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${1}    ${ue_type}=${ue_type}
    ...    ${ue_index}=${0}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${gnb_index_CA}    Create list    ${gnb_prime}    ${gnb_external}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index_CA}
    run keyword If    '${tput_dl_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}[0]    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    run keyword If    '${tput_dl_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log}[1]    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}
    run keyword If    '${tput_ul_pcell}'!='NULL'
    ...    Get average UL through and check    log=${tput_log}[0]    list_of_cell_ids=${nrcellid_pcell}
    ...    tput_ul_pcell=${tput_ul_pcell}
    Run Keyword And Continue On Failure    run keyword If    '${tput_ul_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_scell}    log=${tput_log}[1]    ue_type=${ue_type}
    ...    target_throughput=${tput_ul_scell}

Get average UL through and check
    [Arguments]    ${log}    ${list_of_cell_ids}    ${tput_ul_pcell}
    ${tput_result}    ${record}    aastp.get_aasyslog_throughput
    ...                            direction=ul    log=${log}    cells=${list_of_cell_ids}
    ${real_ul_tput}    set variable    ${tput_result[0]['average']}
    Run Keyword And Continue On Failure    Should Be True    ${real_ul_tput} > ${tput_ul_pcell}*0.355




###MTK M80###
Prepare UE
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    Enable Mobile Data    ue_index=${ue_index}
    ${status}    Run Keyword and Return Status    Wait Until Keyword Succeeds    3 times    5 sec
    ...    Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}    cpc_alias=${cpc_alias}
    Run Keyword If    ${status}==${False}    Run Keywords
    ...    Sleep    2min    AND
    ...    ADB Reboot UE And Verify Device    ue_index=${ue_index}    AND
    ...    Sleep    6min    AND
    ...    Wait Until Keyword Succeeds    2 times    5 sec    Precondition for MTK ue attach    ue_index=${ue_index}
    ...                                                                                                             cap_index=${cap_index}
    ...                                                                                                             cpc_alias=${cpc_alias}
    Do UE Detach    ue_index=${ue_index}
    Sleep    2 sec

Prepare UE For MTK80
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    Enable Mobile Data    ue_index=${ue_index}
    ${mtk_prepare}      run keyword and return status     Wait Until Keyword Succeeds    3 times    5 sec
    ...                 Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare}==${False}    UE Reboot with adb command    ue_index=${ue_index}
    sleep    60s
    ${mtk_prepare_1}    Run Keyword If    ${mtk_prepare}==${False}       run keyword and return status
    ...                 Wait Until Keyword Succeeds    3 times    5 sec
    ...                 Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare_1}==${False}      Reset UE Control PC    ue_index=${ue_index}
    sleep    60s
    Run Keyword If    ${mtk_prepare_1}==${False}    Wait Until Keyword Succeeds    3 times    5 sec
    ...               Precondition for MTK ue attach     ue_index=${ue_index}    cap_index=${cap_index}
    ...               cpc_alias=${cpc_alias}

Do UE Attach
    [Arguments]    ${ue_index}=${0}    ${UE_alias}=UE_${ue_index}
    ute_ue.Register    ${UE_alias}
    Sleep    5 sec

Do UE Detach
    [Arguments]    ${ue_index}=${0}    ${UE_alias}=UE_${ue_index}
    Log to console      MTK detach starts...
    ute_ue.detach_ue    ${UE_alias}

Verify UE Attach Success
    [Arguments]    ${expected_message}=5GMM_REGISTRATION_COMPLETE
    ${attach_expected_messages}    Create list    ${expected_message}
    mtk.expect_messages_in_flow    awaited_messages=${attach_expected_messages}    flow_alias=MTK_OTA_MESSAGE

Start L3 Call
    [Arguments]    ${ue_ip}
    ...            ${ul_data_transfer}=100M
    ...            ${dl_data_transfer}=2000M
    ...            ${duration}=600
    ...            ${ue_index}=0
    ...            ${buffer_size}=1400B
    ...            ${appserver}=APPserver
    ...            ${protocol}=udp
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${ue_ul_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Set Test Variable    ${DL_PORT}    ${ue_dl_port}
    Set Test Variable    ${UL_PORT}    ${ue_ul_port}
    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${ue_ip}
    ...                                                          dl_time=${duration}
    ...                                                          dl_port=${DL_PORT}
    ...                                                          dl_throughput=${dl_data_transfer}
    ...                                                          dl_length=${buffer_size}
    ...                                                          appserver=${appserver}
    ...                                                          protocol=${protocol}
    ...                                                          ue_index=${ue_index}
    traffic_via_iperf.Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                             ul_time=${duration}
    ...                                                             ul_port=${UL_PORT}
    ...                                                             ul_throughput=${ul_data_transfer}
    ...                                                             ul_length=${buffer_size}
    ...                                                             appserver=${appserver}
    ...                                                             protocol=${protocol}
    ...                                                             iperf_path=${ue_iperf_path}

Stop L3 Call
    [Documentation]
    ...                Description: used to stop dl/ul traffic
    [Arguments]    ${ue_index}=0
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}

Collect Throughput
    [Arguments]     ${ue_index}=0
    ...             ${duration}=180
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${ignore_time}=1min
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${tput_file}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}   du_index=${du_index}
    ...             duration=${duration}    ignore_time=${ignore_time}

Start UE Attach With MTK
    [Documentation]
    ...                this keyword perform MTK attach and verify 5g rach success.
    [Arguments]    ${wireshark_log_prefix}=x2_log_attach
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${connection}=ASIK Master
    ...            ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${enb_index}=${0}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=10 sec
    ...            ${coam_connection}=GNB_OAM
    ...            ${mode}=SA
    ...            ${filter_ports}=((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
    ...            ${wireshark_capture_interface}=-i any '((sctp) and ${filter_ports})' -s 0
    ...            ${is_do_require_ue}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword If    ${is_do_require_ue}    Prepare UE    ue_index=${ue_index}
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=${wireshark_log_name}
    ...                                                                          asik_connection_alias=${connection}
    ...                                                                          gnb_index=${gnb_index}
    ...                                                                          du_index=${du_index}
    ...                                                                          options=${wireshark_capture_interface}
    Run Keyword If    '${mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    Sleep    ${sleep_interval}
    Do UE Attach    ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    Sleep    ${sleep_interval}
    ${wireshark_log_path_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=${wireshark_log_name}    target_dir=${log_dir_ute}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                          target_dir=${log_dir_ute}
    ${attach_cell_index}    Get Attach Cell Index From Wireshark    cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${mode}
    ${attach_info}    Run Keyword If    '${mode}'=='NSA'    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                                          attach_cell_index=${attach_cell_index}
    ...                                                                          enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}

Get UE Airmode status and Turnon Airplane Mode
    [Documentation]
    ...              Description: get ue airplane mode and turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}
    Check UE device exist    ${ue_index}
    ${airplane_mode}    Get UE Airmode status    ue_index=${ue_index}
    run keyword if    '${airplane_mode}'=='0'    Turn On Airplane Mode    ue_index=${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Get UE Airmode status and Turnoff Airplane Mode
    [Documentation]
    ...              Description: get ue airplane mode and turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}
    Check UE device exist    ${ue_index}
#    ADB Reboot UE    ue_index=${ue_index}
#    sleep    30s
#    Connect to control pc enhanced    ${ue_index}
#    csn.send_command   command=adb devices    connection=cpc_${ue_index}
#    csn.send_command   command=adb -s ${serial_number} root    connection=cpc_${ue_index}
#    Check UE device exist    ${ue_index}
    ${airplane_mode}    Get UE Airmode status    ue_index=${ue_index}
    run keyword if    '${airplane_mode}'=='1'    Turn Off Airplane Mode    ue_index=${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Turn On Airplane Mode
    [Documentation]
    ...              Description: turn on airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    Csn.Send Command    adb -s ${serial_number} shell "su 0 settings put global airplane_mode_on 1"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    csn.send command    adb -s ${serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    ${result} =    csn.read_output    connection=cpc_${ue_index}
    Should contain    ${result}    result=0
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Turn Off Airplane Mode
    [Documentation]
    ...              Description: turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.Send Command    adb -s ${serial_number} shell "su 0 settings put global airplane_mode_on 0"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    csn.send command    adb -s ${serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    5s
    ${result} =    csn.read_output    connection=cpc_${ue_index}
    Should contain    ${result}    result=0
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Enable Mobile Data
    [Documentation]
    ...              Description: enable mobile data for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command   command=adb -s ${serial_number} shell svc data enable    connection=cpc_${ue_index}
    Sleep    1s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

ADB Reboot UE And Verify Device
    [Documentation]
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

#--- WA: Clear ELT tmp file---#
Clear Temp File Of ELT For MTK
    [Documentation]
    ...              Description: WA: Clear ELT tmp file to insure UE PC can't full space.
    ...              ELT software must install in specific directory: "C:\MTK\ELT_software"
    ${ue_length}    Get Length    ${tl.ues}
    FOR    ${ue_index}    IN RANGE    ${ue_length}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Run Keyword If    '${ue_type}'=='mtk'    Run Keywords
        ...    Kill ELT process on ue control pc if exists    ue_index=${ue_index}    cpc_alias=cpc_${ue_index}    AND
        ...    Clear ELT Temp File    ue_index=${ue_index}
    END

Clear ELT Temp File
    [Documentation]
    ...              Description: WA: Clear ELT tmp file to insure UE PC can't full space.
    ...              ELT software must install in specific directory: "C:\MTK\ELT_software"
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${cmd}    Catenate    powershell "reg QUERY hkcu\\SOFTWARE\\MediaTek\\EvolvedLoggingTool\\ELT\\ /v LastExecutablePath"
    ...    |grep -i ELT.exe |tail -n 1| awk '{print $3}'
    ${tmp_path}    csn.execute    command=${cmd}    connection=cpc_${ue_index}
    ${path_str}    Set Variable    ${tmp_path.split('C:')[-1].split('ELT.exe')[0]}
    ${path_str}    Replace String    ${path_str}    \\    /
    ${output}    csn.execute    command=cd /cygdrive/c/${path_str}TEMP;ls -l    connection=cpc_${ue_index}
    ${tmp_file_str}    Get Regexp Matches    ${output}    (\\S+).tmp
    FOR    ${tmp_file_str}    IN    @{tmp_file_str}
        ${output}    csn.execute    command=cd /cygdrive/c/${path_str}TEMP;rm -rf ${tmp_file_str}    connection=cpc_${ue_index}
        Should Be Empty   ${output}
    END
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}


get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=False     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=20
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.9      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}

recommission for 72a to 72e
    [Arguments]
    ...    ${json_file}=${CURDIR}/CB012149_72a_to_72e_parameters_recommission.json
    ...    ${gnb_index}=${0}
    ...    ${skip_parameter_relation_errors}=True
    ...    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    coam.perform_delta_recommissioning    delta_file=${json_file}    timeout=${300}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

check UL switchedUl scell additon successful on wireshark on 25R1
    [Arguments]    ${puschMappingType}=TypeA
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name}    p_name=physCellId    scf_path=${scf_path}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name}    p_name=physCellId    scf_path=${scf_path}
    END
    # RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    (((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.startSymbolAndLength == 55)) && (nr-rrc.physCellId == ${physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr_rrc_k2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.k2
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_k2_list_25R1}    ${nr_rrc_k2}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_k2_list_typeB}    ${nr_rrc_k2}[0:8]
    ${nr_rrc_mappingType}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.mappingType
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_25R1}    ${nr_rrc_mappingType}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_typeB}    ${nr_rrc_mappingType}[0:8]
    ${nr_rrc_startSymbolAndLength}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.startSymbolAndLength
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_25R1}    ${nr_rrc_startSymbolAndLength}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_typeB}    ${nr_rrc_startSymbolAndLength}[0:8]
    ${nr_rrc_uplinkTxSwitchingOption_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingOption_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingOption_r16}[0]    0
    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingPowerBoosting-r16
    Should Be Empty    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}
    ###FOR TDD SCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    2
    ${nr_rrc_srs_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.srs_ResourceId
    Should Be Equal    ${nr_rrc_srs_ResourceId}[0]    0
    ${nr_rrc_nrofSRS_Ports}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.nrofSRS_Ports
    Should Be Equal    ${nr_rrc_nrofSRS_Ports}[0]    1
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    0
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    False
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    1
    ###FOR FDD PCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    1
    ${nr_rrc_tp_pi2BPSK}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.tp_pi2BPSK
    Should Be Equal    ${nr_rrc_tp_pi2BPSK}[0]    0
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    1
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    True
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    0
    ${nr_rrc_pucch_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.pucch_ResourceId
    ${nr_rrc_startingSymbolIndex}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.startingSymbolIndex
    ${nr_rrc_nrofSymbols}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.nrofSymbols
    ${nr_rrc_startingSymbolIndex_list}    Create List
    ${nr_rrc_nrofSymbols_list}    Create List
    FOR    ${index}    ${item}    IN ENUMERATE    @{nr_rrc_pucch_ResourceId}
        RUN KEYWORD IF    0<=${item}<=5    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    6<=${item}<=7    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
        ...    ELSE IF    10<=${item}<=11    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    ${item}==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==14    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
    END
    Should Be Equal    ${nr_rrc_startingSymbolIndex_list}    ${nr_rrc_startingSymbolIndex}
    Should Be Equal    ${nr_rrc_nrofSymbols_list}    ${nr_rrc_nrofSymbols}

check UL switchedUl scell additon successful on wireshark on 24R3
    [Arguments]    ${puschMappingType}=TypeA
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name}    p_name=physCellId    scf_path=${scf_path}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name}    p_name=physCellId    scf_path=${scf_path}
    END
    # RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    (((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.startSymbolAndLength == 55)) && (nr-rrc.physCellId == ${physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr_rrc_k2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.k2
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_k2_list_24R3}    ${nr_rrc_k2}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_k2_list_typeB}    ${nr_rrc_k2}[0:8]
    ${nr_rrc_mappingType}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.mappingType
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_24R3}    ${nr_rrc_mappingType}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_mappingType_list_typeB}    ${nr_rrc_mappingType}[0:8]
    ${nr_rrc_startSymbolAndLength}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationList//nr-rrc.PUSCH_TimeDomainResourceAllocation_element//nr-rrc.startSymbolAndLength
    Run Keyword If    '${puschMappingType}' == 'TypeA'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_24R3}    ${nr_rrc_startSymbolAndLength}[0:8]
    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_typeB}    ${nr_rrc_startSymbolAndLength}[0:8]
    ${nr_rrc_uplinkTxSwitchingOption_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingOption_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingOption_r16}[0]    0
    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingPowerBoosting-r16
    Should Be Empty    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}
    ###FOR TDD SCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    2
    ${nr_rrc_srs_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.srs_ResourceId
    Should Be Equal    ${nr_rrc_srs_ResourceId}[0]    0
    ${nr_rrc_nrofSRS_Ports}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.nrofSRS_Ports
    Should Be Equal    ${nr_rrc_nrofSRS_Ports}[0]    1
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    0
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    False
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    1
    ###FOR FDD PCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    1
    ${nr_rrc_tp_pi2BPSK}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.tp_pi2BPSK
    Should Be Equal    ${nr_rrc_tp_pi2BPSK}[0]    0
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    1
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    True
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    0
    ${nr_rrc_pucch_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.pucch_ResourceId
    ${nr_rrc_startingSymbolIndex}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.startingSymbolIndex
    ${nr_rrc_nrofSymbols}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.nrofSymbols
    ${nr_rrc_startingSymbolIndex_list}    Create List
    ${nr_rrc_nrofSymbols_list}    Create List
    FOR    ${index}    ${item}    IN ENUMERATE    @{nr_rrc_pucch_ResourceId}
        RUN KEYWORD IF    0<=${item}<=5    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    6<=${item}<=7    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
        ...    ELSE IF    10<=${item}<=11    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    ${item}==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==14    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
    END
    Should Be Equal    ${nr_rrc_startingSymbolIndex_list}    ${nr_rrc_startingSymbolIndex}
    Should Be Equal    ${nr_rrc_nrofSymbols_list}    ${nr_rrc_nrofSymbols}

check CB012149 UERadioCapabilityInfoIndication on wireshark
    # check NGAP：UERadioCapabilityInfoIndication
    # supportedBandCombinationList-UplinkTxSwitch-r16: 1 item contain N1+N78
    # nr-rrc.supportedBandCombinationList_UplinkTxSwitch_r16
    ${UERadioCapabilityInfoIndication_filter}    Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 44)
    ${UERadioCapabilityInfoIndication_packets}    cap.filter_packets_by_expression
    ...    filter_expression=${UERadioCapabilityInfoIndication_filter}
    ${supportedBandCombinationList_1}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...                                                xpath=.//nr-rrc.BandCombination_UplinkTxSwitch_r16_element//nr-rrc.bandNR
    ${supportedBandCombinationList_2}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...                                                xpath=.//nr-rrc.BandCombination_UplinkTxSwitch_r16_element//nr-rrc.ca_BandwidthClassDL_NR
    ${supportedBandCombinationList_3}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...                                                xpath=.//nr-rrc.BandCombination_UplinkTxSwitch_r16_element//nr-rrc.ca_BandwidthClassUL_NR
#    IF    ${enb_instance} == ${enb_id}[0]     #TL348
#        Should Contain    ${supportedBandCombinationList_1}    1
#        Should Contain    ${supportedBandCombinationList_1}    78
#        ${length}=    Get Length    ${supportedBandCombinationList_1}
#        Should Be Equal As Integers    ${length}    4
#        Should Be Equal    ${supportedBandCombinationList_2}[0]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[1]    1
#        Should Be Equal    ${supportedBandCombinationList_2}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[3]    2
#        ${length}=    Get Length    ${supportedBandCombinationList_2}
#        Should Be Equal As Integers    ${length}    4
#        Should Be Equal    ${supportedBandCombinationList_3}[0]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[1]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[3]    0
#        ${length}=    Get Length    ${supportedBandCombinationList_3}
#        Should Be Equal As Integers    ${length}    4
#    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
#        Should Contain    ${supportedBandCombinationList_1}    71
#        Should Contain    ${supportedBandCombinationList_1}    41
#        ${length}=    Get Length    ${supportedBandCombinationList_1}
#        Should Be Equal As Integers    ${length}    5
#        Should Be Equal    ${supportedBandCombinationList_2}[0]    2
#        Should Be Equal    ${supportedBandCombinationList_2}[1]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[3]    0
#        Should Be Equal    ${supportedBandCombinationList_2}[4]    0
#        ${length}=    Get Length    ${supportedBandCombinationList_2}
#        Should Be Equal As Integers    ${length}    5
#        Should Be Equal    ${supportedBandCombinationList_3}[0]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[1]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[2]    0
#        Should Be Equal    ${supportedBandCombinationList_3}[3]    0
#        ${length}=    Get Length    ${supportedBandCombinationList_3}
#        Should Be Equal As Integers    ${length}    4
#    END
    ${uplinkTxSwitching_OptionSupport_r16}=    cap.Get Field Value By Xpath    pdml_list=${UERadioCapabilityInfoIndication_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitching_OptionSupport_r16
    Should Be Equal    ${uplinkTxSwitching_OptionSupport_r16}[0]    0

check UL switchedUl scell additon successful on wireshark
    [Arguments]    ${puschMappingType}=TypeA
    Log    ${puschMappingType}
    IF    ${enb_instance} == ${enb_id}[0]     #TL348
        ${physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name}    p_name=physCellId    scf_path=${scf_path}
    ELSE IF    ${enb_instance} == ${enb_id}[1]     #TL383
        ${physCellId}=    Get value of parameter from SCF file    golden_scf_name=${tl_gnb1_scf_${sw_version}}
        ...    dist_name=${NRCELL700name}    p_name=physCellId    scf_path=${scf_path}
    END
    # RRC Reconfiguration
    ${RRC_Reconfiguration_filter}    Catenate
    ...    (((f1ap.F1AP_PDU == 0) && (f1ap.procedureCode == 12)) && (nr-rrc.startSymbolAndLength_r16 == 55)) && (nr-rrc.physCellId == ${physCellId})
    ${RRC_Reconfiguration_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}
    ${nr_rrc_k2}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationListDCI_0_1_r16//nr-rrc.PUSCH_TimeDomainResourceAllocation_r16_element//nr-rrc.k2_r16
#    Run Keyword If    '${puschMappingType}' == 'TypeA'
#    ...    Should Be Equal    ${nr_rrc_k2_list}    ${nr_rrc_k2}[0:8]
#    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
#    ...    Should Be Equal    ${nr_rrc_k2_list_typeB}    ${nr_rrc_k2}[0:8]
    ${nr_rrc_mappingType}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationListDCI_0_1_r16//nr-rrc.PUSCH_TimeDomainResourceAllocation_r16_element//nr-rrc.mappingType_r16
#    Run Keyword If    '${puschMappingType}' == 'TypeA'
#    ...    Should Be Equal    ${nr_rrc_mappingType_list}    ${nr_rrc_mappingType}[0:8]
#    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
#    ...    Should Be Equal    ${nr_rrc_mappingType_list_typeB}    ${nr_rrc_mappingType}[0:8]
    ${startSymbolAndLength}=    Catenate    nr-rrc.startSymbolAndLength_r16
    ${nr_rrc_startSymbolAndLength}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.pusch_TimeDomainAllocationListDCI_0_1_r16//nr-rrc.PUSCH_TimeDomainResourceAllocation_r16_element//${startSymbolAndLength}
#    Run Keyword If    '${puschMappingType}' == 'TypeA'
#    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list}    ${nr_rrc_startSymbolAndLength}[0:8]
#    ...    ELSE IF    '${puschMappingType}' == 'TypeB'
#    ...    Should Be Equal    ${nr_rrc_startSymbolAndLength_list_typeB}    ${nr_rrc_startSymbolAndLength}[0:8]
    ${nr_rrc_uplinkTxSwitchingOption_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingOption_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingOption_r16}[0]    0
    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.uplinkTxSwitchingPowerBoosting-r16
    Should Be Empty    ${nr_rrc_uplinkTxSwitchingPowerBoosting-r16}
    ###FOR TDD SCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    2
    ${nr_rrc_srs_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.srs_ResourceId
    Should Be Equal    ${nr_rrc_srs_ResourceId}[0]    0
    ${nr_rrc_nrofSRS_Ports}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.nrofSRS_Ports
    Should Be Equal    ${nr_rrc_nrofSRS_Ports}[0]    1
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    0
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    False
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    1
    ###FOR FDD PCELL###
    ${nr_rrc_maxRank}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.maxRank
    Should Be Equal    ${nr_rrc_maxRank}[0]    1
    ${nr_rrc_tp_pi2BPSK}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.tp_pi2BPSK
#    Should Be Equal    ${nr_rrc_tp_pi2BPSK}[0]    0
    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingPeriodLocation_r16
#    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    1
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingPeriodLocation_r16}[0]    True
    ${nr_rrc_uplinkTxSwitchingCarrier_r16}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.uplinkTxSwitching_r16//nr-rrc.uplinkTxSwitchingCarrier_r16
    Should Be Equal    ${nr_rrc_uplinkTxSwitchingCarrier_r16}[0]    0
    ${nr_rrc_pucch_ResourceId}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.pucch_ResourceId
    ${nr_rrc_startingSymbolIndex}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.startingSymbolIndex
    ${nr_rrc_nrofSymbols}=    cap.Get Field Value By Xpath    pdml_list=${RRC_Reconfiguration_packets}
    ...    xpath=.//nr-rrc.spCellConfig_element//nr-rrc.bwp_Dedicated_element//nr-rrc.resourceToAddModList//nr-rrc.nrofSymbols
    ${nr_rrc_startingSymbolIndex_list}    Create List
    ${nr_rrc_nrofSymbols_list}    Create List
    FOR    ${index}    ${item}    IN ENUMERATE    @{nr_rrc_pucch_ResourceId}
        RUN KEYWORD IF    0<=${item}<=5    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    6<=${item}<=7    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
        ...    ELSE IF    10<=${item}<=11    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    ${item}==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    4
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    7
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==8    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    3
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    8
        ...    ELSE IF    (${item}==9 or 18<=${item}<=28) and ${nr_rrc_nrofSymbols}[${index}]==14    Run Keywords
        ...    Append To List    ${nr_rrc_startingSymbolIndex_list}    0
        ...    AND    Append To List    ${nr_rrc_nrofSymbols_list}    14
    END
    Should Be Equal    ${nr_rrc_startingSymbolIndex_list}    ${nr_rrc_startingSymbolIndex}
    Should Be Equal    ${nr_rrc_nrofSymbols_list}    ${nr_rrc_nrofSymbols}
