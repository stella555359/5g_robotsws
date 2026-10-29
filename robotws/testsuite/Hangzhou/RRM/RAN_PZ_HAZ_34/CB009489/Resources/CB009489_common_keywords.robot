*** Settings ***
Documentation    author: keyun.ma
...              contact: keyun.ma@nokia.com
...              squad group: SG_03
...              feature : CB009489
Library     DateTime
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.analyzer.pcap    WITH NAME    cap
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009489/Resources/CB009489_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

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

*** Keywords ***

###### UE #########
Prepare UE and detach UE
    [Arguments]    ${ue_type}=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}

MultiUE.Prepare UE
    [Arguments]    ${ue_num}=${5}
    FOR   ${ue_index}   IN RANGE    ${0}    ${ue_num}
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    detach_request=${True}    power_reset=True    get_spark_license=False
        sleep    10s
    END

MultiUE.Attach
    [Arguments]    ${ue_index}=${0}
    ${res}    run keyword and ignore error   power_ue.UE Attach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=true
    sleep    10s
    log    ${res}
    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
    ...    Basic.ThroughExceptionWithMsg    msg=Attach UE_${ue_index} Failed
    ${res}    run keyword and ignore error   power_ue.Verify attach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    4G_check=False
    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
    ...     Basic.ThroughExceptionWithMsg    msg=Check Attach UE_${ue_index} Failed
    log to console   UE attach completed

MultiUE.Detach
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach
    ...   ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=True

MultiUE.Start DL Traffic
    [Arguments]    ${throughput_for_DL}=5   ${direction}=dl   ${ue_index}=${0}    ${duration}=600    ${protocol}=UDP
     ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}    ${APN}=dxdata1    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    power_ue.Start traffic
        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
        ...    throughput=${throughput_for_DL}MKbits/sec
        ...    duration=${duration}
        ...    apn_address=${APN}
        ...    ue_mode=SA
        ...    iperf_port=${iperf_port}
        ...    multidrb_QoS_dest=${None}
        ...    protocol=${protocol}

MultiUE.Start UE DLUL traffic
    [Arguments]    ${dl_throughput}=${Send_Tput_DL_MultiUE}    ${ul_throughput}=${Send_Tput_UL_MultiUE}
    ...    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${duration}=600    ${ue_index}=${7}    ${APN}=dxdata1
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${dl_throughput}   duration=${duration}
    ...   APN=${APN}    iperf_port=${iperf_port}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${ul_throughput}   duration=${duration}    direction=ul
    ...   APN=${APN}    iperf_port=${iperf_port}

MultiUE.Stop DL Traffic
    [Arguments]    ${direction}=dl   ${ue_index}=${0}
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    power_ue.Stop traffic
        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
        ...    apn_address=dxdata1
        ...    iperf_port=${tl.ues[0].iperf_details.port}

MultiUE.Start DLUL traffic and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul}    ${tput_ul_scell}=NULL    ${dl_port}=${DL_PORT_387}
    ...    ${gnb_prime}=${0}    ${gnb_external}=${1}    ${dl_throughput}=${Send_Tput_DL_MultiUE}    ${APN}=dxdata1
    ...    ${ul_throughput}=${Send_Tput_UL}    ${protocol}=${protocol_UDP}    ${ue_index}=${7}    ${duration}=600
    Run keyword If    '${protocol}'=='tcp'
    ...    Start UE DLUL TCP traffic    ELSE
    ...    MultiUE.Start UE DLUL traffic    ue_index=${ue_index}    dl_throughput=${dl_throughput}
    ...    ul_throughput=${ul_throughput}    duration=${duration}    APN=${APN}    iperf_port=${dl_port}
    sleep    60s
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    scellid=${scellid}    pcellid=${pcellid}
    ...    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}

MultiUE.Start DL traffic parallel and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul}    ${dl_port_mdrb}=${DL_PORT_387}    ${gnb_prime}=${0}
    ...    ${gnb_external}=${1}    ${Send_Tput_DL_DRB7}=${Send_Tput_DL_DRB7}    ${Send_Tput_DL_DRB9}=${Send_Tput_DL_DRB9}
    ...    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${7}    ${duration}=600    ${APN}=dxdata1
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${Send_Tput_DL_DRB9}   duration=${duration}
    ...   APN=${APN}    iperf_port=${dl_port_mdrb}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${Send_Tput_DL_DRB7}   duration=${duration}
    ...   APN=${APN}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${ul_throughput}   duration=${duration}    direction=ul
    ...   APN=${APN}    iperf_port=${dl_port_mdrb}
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    scellid=${scellid}    pcellid=${pcellid}    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}

MultiUE.Stop DLUL traffic
    [Arguments]    ${ue_index}=${0}   ${APN}=dxdata1    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${iperf_port_mdrb}=NULL
    power_ue.Stop traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    apn_address=${APN}
        ...    iperf_port=${iperf_port}
    run keyword If    '${iperf_port_mdrb}'!='NULL'
    ...    power_ue.Stop traffic
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
    ...    apn_address=${APN}
    ...    iperf_port=${iperf_port_mdrb}
    power_ue.Stop traffic
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
    ...    apn_address=${APN}
    ...    iperf_port=${iperf_port}
Basic.ThroughExceptionWithMsg
    [Arguments]     ${msg}
    Fail    ${msg}
###BTS keyword###
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
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=${connection}
    Wait until keyword succeeds    1m    10s    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

get required value of parameter
    [Arguments]    ${Abbreviation}    ${class_name}=NRCELL    ${gnb_index}=${0}    ${distname_id}=${0}
    ...    ${connection}=GNB_OAM
    ${parameter_value}=    get parameter value    class_name=${class_name}    Abbreviation=${Abbreviation}
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}    connection=${connection}
    [Return]    ${parameter_value}

get parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    ${distname_id}=${1}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=${connection}
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
    ...    parameters=${parameters}    operation=update
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online update list parameter model
    [Arguments]    ${parameters}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter
    ...    parameters=${parameters}    operation=update
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online delete list parameter
    [Arguments]    ${parameters}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter
    ...    parameters=${parameters}    operation=delete
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online recover delete and add list parameter
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter    parameters=${LIST_PARAM_RECOVER_DELETE_gnb1_04444966}    operation=delete
    COAM Wait for gnb ready and cell setup
    online operate list parameter    parameters=${LIST_PARAM_RECOVER_gnb1_04444966}    operation=update
    [Teardown]    COAM Teardown gnb connections

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
    Change Attenuation value    cell=5Gcel${cellid}    value=${set_value}
    FOR  ${index}  IN RANGE   ${total_cell}
        ${celnum} =    evaluate    ${index}+1
        run keyword if    '${cellid}'!='${celnum}'    Change Attenuation value    cell=5Gcel${celnum}    value=${127}
    END
    Change Attenuation value    cell=4Gcell1    value=${127}

PA one cell 0 on and set other cell value 4 port
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${4}
    IF    ${cellid} == 4
        Change Attenuation value    cell=5Gcels${cellid}    value=${set_value}
    ELSE
        Change Attenuation value 4 port    cell=5Gcels${cellid}    value=${set_value}
    END
    FOR  ${index}    IN RANGE    ${total_cell}
        ${celnum} =    evaluate    ${index}+1
        IF    '${cellid}'!='${celnum}'
            IF    ${celnum} == 4
                Change Attenuation value    cell=5Gcels${celnum}    value=${127}
            ELSE
                Change Attenuation value 4 port    cell=5Gcels${celnum}    value=${127}
            END
        END
    END
    Change Attenuation value 4 port    cell=4Gcells1    value=${127}

Change Attenuation value
    [Arguments]    ${cell}    ${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set Programmable Attenuation Value    ports=${${cell}_ANT2}    value=${value}
    Run Keyword If    '${cell}' == '5Gcel3'    Run Keywords
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

PA one cell 0 on and set other cell value 4 port for T2467
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${6}
    IF    '${cellid}' == '5' or '${cellid}' == '6'
        Change Attenuation value 4 port for PA    cell=5Gcel${cellid}    value=${set_value}    ip_addr=${att_ipadr1}
    ELSE
        Change Attenuation value 4 port for PA    cell=5Gcel${cellid}    value=${set_value}    ip_addr=${att_ipaddr}
    END
    FOR  ${index}  IN RANGE   ${total_cell}
        ${celnum} =    evaluate    ${index}+1
        IF    ('${cellid}' != '${celnum}') and ('${celnum}' == '5' or '${celnum}' == '6')
            Change Attenuation value 4 port for PA    cell=5Gcel${celnum}    value=${127}    ip_addr=${att_ipadr1}
        ELSE IF    ('${cellid}' != '${celnum}') and ('${celnum}' != '5' or '${celnum}' != '6')
            Change Attenuation value 4 port for PA    cell=5Gcel${celnum}    value=${127}    ip_addr=${att_ipaddr}
        END
    END

Change Attenuation value 4 port for PA
    [Arguments]    ${cell}    ${value}    ${ip_addr}=${att_ipaddr}
    Set Programmable Attenuation Value for PA    ports=${${cell}_ANT1}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for PA    ports=${${cell}_ANT2}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for PA    ports=${${cell}_ANT3}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for PA    ports=${${cell}_ANT4}    value=${value}    ip_addr=${ip_addr}

Set Programmable Attenuation Value for PA
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
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}
        ...    ue_index=${ue_index}    close_task=${close_task}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}
        ...    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command
    ...    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
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
    csn.send_command
	...    command=
	...    adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
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

Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL
    Log    ${ue_type}
    Run Keyword If    '${direction}' == 'DL'
    ...    Run Keyword And Ignore Error    Close the iperf process on APPserver
    ...    port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword If    '${direction}' == 'UL'
    ...    Run Keyword And Ignore Error    Close the iperf process on android ue
    ...    ue_index=${ue_index}    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}

Start only DL traffic and check tput common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}
    ...    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}
    ...    duration=${duration}
    ...    dl_port=${dl_port}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}
    ...    list_of_cell_ids=${nrcellid_cell}    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}

Start only UL traffic and check tput common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}
    ...    ${gnb_index}=${0}    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}    ${ul_port}=${UL_PORT}
    ...    ${duration}=${600}    ${iperf_type}=via_app
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}
    ...    duration=${duration}    ul_port=${ul_port}    iperf_type=${iperf_type}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}}
    ...    list_of_cell_ids=${nrcellid_cell    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

Stop DL or UL traffic common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp
    ...    ${iperf_port}=default    ${iperf_type}=via_app
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}
    ...    iperf_port=${iperf_port}    iperf_type=${iperf_type}

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

reboot ue to attach
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${cpc_alias}=cpc_${ue_index}
    UE Reboot with adb command    ue_index=${ue_index}
    wait until keyword succeeds    3min    2s    Connect to control pc enhanced    ue_index=${ue_index}
    sleep    30s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry | grep -i "ssRsrp"
    ...    connection=${cpc_alias}
    ${ssRsrp_output}   csn.read_output    connection=${cpc_alias}
    [Teardown]    csn.disconnect    connection=${cpc_alias}
    [Return]    ${ssRsrp_output}

verify ue attach success via ssRsrp
    [Arguments]    ${ssRsrp_output}    ${dist_name}    ${p_name}    ${scf_name}=gNB1_Golden_SCF.xml
    ${mPci_value}=    get_mPci_value_from_adb_command_output    output=${ssRsrp_output}
    ${value}=    Get value of parameter from SCF file    golden_scf_name=${scf_name}    dist_name=${dist_name}
    ...    p_name=${p_name}
    Should Be Equal As Strings    ${mPci_value}    ${value}

Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
    Check UE device exist    ue_index=${ue_index}
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}

Step4: Detach UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}


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
    ...    run and return rc and output
    ...    command=cp -r ${tool_path}/${log_name}/${type}/${fsp_folder}[0]/* ${epc_log_path}/${current_time}
    ...    ELSE    run and return rc and output
    ...    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
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
    ...    run and return rc and output
    ...    command=cp -r ${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace/* ${epc_log_path}/${current_time}
    ...    ELSE    run and return rc and output
    ...    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
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
        ${nrCellIdentity}=    get required value of parameter    Abbreviation=nrCellIdentity    gnb_index=${gnb_index}
        ...    distname_id=${id}
        ${l2_num}=    return_l2_num_from_gnb_logs_tool_log    gnb_logs_tool_path=${tool_path}    log_folder=${log_name}
        ...    nrCellIdentity=${nrCellIdentity}
        ${log_files}    run keyword if    '${type}' == 'tti'
        ...    list files in directory    path=${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace     pattern=*.csv
        ...    ELSE    list files in directory    path=${tool_path}/${log_name}/${type}
        ${current_time}=    get current date    result_format=%Y%m%d%H%M%S
        create directory    path=${epc_log_path}/${current_time}
        directory should exist    path=${epc_log_path}/${current_time}
        ${rc}    ${output}    run keyword if    '${type}' == 'tti'
        ...    run and return rc and output
        ...    command=cp -r ${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace/* ${epc_log_path}/${current_time}
        ...    ELSE    run and return rc and output
        ...    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
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
    ${tput_log}    power_ue.Collect Tput    duration=${duration}    ignore_time=0s    ue_type=${ue_type}
    ...    gnb_index=${gnb_index_CA}
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


ADB Reboot UE And Verify Device
    [Documentation]
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...    serial_number=${tl.ues[${ue_index}].serial_number}
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