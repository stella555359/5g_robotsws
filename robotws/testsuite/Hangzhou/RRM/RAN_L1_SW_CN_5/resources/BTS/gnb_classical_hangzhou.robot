*** Settings ***
Library    String
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    DateTime
Library    XML
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library    taf.rfrl.common_resources.python.check_cap.CapPacket     WITH NAME    cap
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.hw.rf_attenuator    WITH NAME    attenuator


*** Variables ***
${ATTENUATOR_ADDR}             ${tl.attenuator.ip_addr}
${attenuation_port}            ${tl.attenuator.port}

*** Keywords ***
Get RU IP Address Via File FRIps
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]   ${ru_serial_number}    ${connection}=ASIK Master
    ${get_ru_ip_command}   Set Variable   cat /rom/config/FRIps.txt
    ${output}   csn.execute   command=${get_ru_ip_command}  connection=${connection}
    ${contained_ip_lines}   Get Lines Containing String   ${output}  ${ru_serial_number}   case-insensitive=${True}
    ${ru_ip_addr}  Set Variable    @{contained_ip_lines.split(';')}[2]
    [Return]   ${ru_ip_addr}

Get DHCP Allocated RU IP Address
    [Documentation]  Author: Lin Stella
    ...              Description: Get RU IP address In ASIK : /tmp/startup_BTSOM.log,
    ...                           It should be run after bts site restart
    [Arguments]    ${ru_index}=${1}  ${connection}=ASIK Master    ${logfolder}=0x1011_aasyslog
    ${ru_index}  Convert To Integer    ${ru_index}
    ${status}    run keyword and return status    csn.assert file exists    /tmp/startup_BTSOM.log    connection=${connection}
    ${comamnd}    set variable if    '${status}'=='True'    cat /tmp/startup_BTSOM.log|grep -i 'API_INET_DHCP_LEASE_IND_MSG'
    ...    '${status}'=='False'    xzcat /ffs/run/logs/${logfolder}/startup_BTSOM.log.xz|grep -i 'API_INET_DHCP_LEASE_IND_MSG'
    ${output}    csn.execute    command=${comamnd}    connection=${connection}
    ${filter_ip}   Get Regexp Matches   ${output}  ip\\s\\[(\\d\{1,3\}\\.\\d\{1,3\}\\.\\d\{1,3\}\\.\\d\{1,3\})\\]   1
    ${dhcp_ip}   Set Variable   ${filter_ip[${ru_index}-1]}
    Should Not Be Empty    ${dhcp_ip}
    [Return]    ${dhcp_ip}

Create RU temp file
    [Documentation]  Author: Ren xianlin
    ...              Description:  Create RU temp file ,
    ...                            In order to check RU has reset or not
    ...                            should be used with  keyword <Verify RU temp file disappeared>
    [Arguments]    ${ru_alias}=RU
    csn.execute    command=touch /tmp/ta.tag    connection=${ru_alias}
    ${ta_tag}    csn.execute    command=ls -l /tmp/ta.tag    connection=${ru_alias}
    [Return]    ${ta_tag}

Verify RU temp file disappeared
    [Documentation]  Author: Ren xianlin
    ...              Description:  Verify RU temp file not exist
    ...                            In order to check RU has reset or not
    ...                            should be used with  keyword <Create RU temp file>
    [Arguments]    ${last_ru_tag}    ${ru_alias}=RU
    ${ta_tag}    csn.execute    command=ls -l /tmp/ta.tag    connection=${ru_alias}
    should not contain    ${last_ru_tag}    ${ta_tag}

gnb_classical_hangzhouS
    [Documentation]    Author: Xu Huamin.1
    [Arguments]    ${port}=rlan0    ${connection}=ABIL Loner
    ${cmd_turn_up_port}    set variable    ifconfig ${port} up
    ${output}    csn.execute    ${cmd_turn_up_port}    connection=${connection}
    Should be empty    ${output}

Turn down CPRI port
    [Documentation]    Author: Xu Huamin.1
    [Arguments]    ${port}=rlan0    ${connection}=ABIL Loner
    ${cmd_turn_down_port}    set variable    ifconfig ${port} down
    ${output}    csn.execute    command=${cmd_turn_down_port}    connection=${connection}
    Should be empty    ${output}

Calculate UL Bler On Loner
    [Documentation]  Author: stella.lin@nokia-sbell.com
    ...              Description: Calculate UL Bler On Loner and compare it to expect value
    [Arguments]   ${expect_value}    ${connection}=ABIL Loner
    ${output}    csn.execute    command=fpga_rw ra 0xdf60c14c 2    connection=${connection}
    ${line1}   Get Line    ${output}    0
    ${line2}   Get Line    ${output}    1
    ${data_sum}    convert to number    ${line1.strip()}
    ${data_error}    convert to number    ${line2.strip()}
    ${Ul_bler}    Run Keyword If  ${data_sum}==${0}    Set Variable    ${0}
                  ...        ELSE    Evaluate    ${data_error}/${data_sum}
    ${expect_value}    convert to number    ${expect_value}
    Should Be True    ${Ul_bler}<=${expect_value}    msg=UL Bler ${Ul_bler} is not meet the requirement:<=${expect_value}

Reset UL Bler Counter On Loner
    [Documentation]  Author: stella.lin@nokia-sbell.com
    ...              Description: clear ul bler counter on loner.
    [Arguments]   ${connection}=ABIL Loner
    ${output}    csn.execute    command=fpga_rw wa 0xdf60c154 0x1    connection=${connection}
    Should Not Contain    ${output}    error    msg=reset ul bler counter failed     ignore_case=True

COAM Modify and Verify MIMO parameter of loner
    [Documentation]    Author: lei.jia@nokia-sbell.com SG6
    ...                It can verify and modify MIMO parameter on loner with 19A build
    ...                for exemaple1:rd_open_loop_scheme_2x2
    ...                for exemaple1:rd_open_loop_scheme_4x4
    [Arguments]    ${value}    ${MIMO_parameter}    ${alias}=ABIL Loner    ${asik_alias}=ASIK Master
    connection_alias_store.Connect to Common Unit Master
    connection_alias_store.Connect to Capacity Unit Loner
    ${verify_status} =    Run Keyword and Return Status    gnb_classical_hangzhou.Verify if MIMO parameter is updated successfully in COAM
    ...   value=${value}   MIMO_parameter=${MIMO_parameter}    alias=${alias}
    Run Keyword If    "${verify_status}"=="True"    Log to console    ${MIMO_parameter} value is already ${value}, no need to update.
    ...    ELSE    run keyword  gnb_classical_hangzhou.COAM Modify MIMO parameter of loner
    ...    value=${value}    MIMO_parameter=${MIMO_parameter}
    [Teardown]  run keywords
    ...    csn.disconnect    connection=${alias}    AND
    ...    csn.disconnect    connection=${asik_alias}

COAM Modify MIMO parameter of loner
    [Documentation]    Author: lei.jia@nokia-sbell.com SG6
    ...                It can modify MIMO parameter on loner with 19A build
    ...                for exemaple1:rd_open_loop_scheme_2x2
    ...                for exemaple1:rd_open_loop_scheme_4x4
    [Arguments]    ${value}    ${MIMO_parameter}    ${alias}=ABIL Loner    ${asik_alias}=ASIK Master
    ${default_value} =    csn.execute    command=cat /etc/5g-layer-1/const_customizer.conf | grep -i ${MIMO_parameter} | awk '{print $3}'
    ...                              connection=${alias}
    ${file} =    Set Variable    /ffs/run/boardcfg/1/C/mcu-aspa/boot
    ${stdout} =    csn.execute    command=find ${file}/const_customizer.conf   connection=${asik_alias}
    ${status} =    Run Keyword and Return Status    Should Not Contain    ${stdout}    No such file or directory
    Run Keyword If    "${status}"=="False"    Log to console    File is not exist, no need to delete
    ...    ELSE    Run Keywords
    ...               csn.execute    command=rm ${file}/const_customizer.conf   connection=${asik_alias}    AND
    ...               csn.send command    command=reboot    connection=${alias}    AND
    ...               Wait Until Keyword Succeeds    3 min    20 sec    gnb_classical_hangzhou.Check ABIL board is restarted    AND
    ...        Wait Until Keyword Succeeds    5 min    20 sec    connection_alias_store.Connect to Capacity Unit Loner
    csn.execute
    ...    command=bget 1:2 /etc/5g-layer-1/const_customizer.conf ${file}/
    ...    connection=${asik_alias}
    ${tmp_value} =    csn.execute    command=cat ${file}/const_customizer.conf | grep -i ${MIMO_parameter} | awk '{print $3}'
    ...                                  connection=${asik_alias}
    ${compare_value}    Replace String    ${tmp_value}   \r\n    ${EMPTY}
    Run Keyword If    ${compare_value}==${value}    Log to console    Default value is ${compare_value}, no need to update
    ...    ELSE
    ...      csn.execute    command=sed -i 's/^${MIMO_parameter}.*/${MIMO_parameter} = ${value}/g' ${file}/const_customizer.conf
    ...                     connection=${asik_alias}
    csn.send command    command=reboot    connection=${alias}
    Wait Until Keyword Succeeds    3 min    20 sec    gnb_classical_hangzhou.Check ABIL board is restarted
    Wait Until Keyword Succeeds    10 min    20 sec    gnb_classical_hangzhou.Verify if MIMO parameter is updated successfully in COAM
    ...                                                                         value=${value}
    ...                                                                         MIMO_parameter=${MIMO_parameter}
    ...                                                                         alias=${alias}
    [Return]    ${default_value}

Check ABIL board is restarted
    [Documentation]    Author: lei.jia@nokia-sbell.com SG6
    ...                It use to check ABIL board is restarted after reboot command.
    [Arguments]    ${asik_alias}=ASIK Master    ${alias}=ABIL Loner
    connection_alias_store.Connect to Common Unit Master
    ${stdout} =    csn.execute    command=bsh 1:2   connection=${asik_alias}
    Should Contain    ${stdout}    Connection timed out
    [Teardown]  run keyword and ignore error   csn.disconnect    connection=${asik_alias}

Verify if MIMO parameter is updated successfully in COAM
    [Documentation]    Author: lei.jia@nokia-sbell.com SG6
    ...                It use to verify MIMO parameter after modify
    ...                for exemaple1:rd_open_loop_scheme_2x2
    ...                for exemaple1:rd_open_loop_scheme_4x4
    [Arguments]    ${value}    ${MIMO_parameter}    ${alias}
    connection_alias_store.Connect to Capacity Unit Loner
    ${tmp_value} =    csn.execute    command=cat /etc/5g-layer-1/const_customizer.conf | grep -i ${MIMO_parameter} | awk '{print $3}'
    ...                              connection=${alias}
    ...                              timeout=10 s
    ${get_value}    Replace String    ${tmp_value}   \r\n    ${EMPTY}
    Should Be Equal    ${get_value}    ${value}

Get Initial Attenuation Values For RU
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is to get initial attenuation values based on channel port numbers get form testline config.
    ...                :param RU_id <str> : ru id which you want to operate
    ...                :param att_id <str> : <id> for example 0 or 1, if several attenuators used and RU id is not the same with att id.
    ...                                      ${None} as default, if more than one PAs and RUs defined in init.py.
    ...                                              please set RU id the same with Attenuator id in init.py,
    ...                                              even attenuator0 and attenuator1 has the same ip.
    ...                                              for example, RU0 use _attenuator_0(10.57.232.105, port 3&4)
    ...                                                           RU1 use _attenuator_1(10.57.232.105, port 7&8)
    ...                :Return initial_att_values<list> : previous attenuation values are returned for futher use.
    [Arguments]    ${RU_id}=0    ${vendor}=TopYoung    ${gnb_id}=0    ${att_id}=${None}
    ${attenuation_port_numbers} =     gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    ${channel_numbers}     Get Length       ${attenuation_port_numbers}
    ${att_obj_in_ru_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ...    model=${model}
    ${initial_att_values}    Create List
    FOR  ${index}  IN RANGE    ${channel_numbers}
       ${values}=    attenuator.read_attenuation     port=${attenuation_port_numbers[${index}]}    attenuator_device=${configured_attenuator}
       Append To List     ${initial_att_values}     ${values}
    END
    [Return]    ${initial_att_values}


Get Attenuation Channels For RU
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                To get channel ports  of attenuation which connect to RU.
    ...                :param RU_id <str> : ru id which get form Testline Configuration, default is 0
    ...                :Return attenuation_port_numbers<list> : eg [9:10]
    [Arguments]    ${RU_id}=0    ${gnb_id}=0
    ${attenuation_channels}     set variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports}
    @{attenuation_port_numbers}    create list
    ${channel_numbers}     Get Length       ${attenuation_channels}
    FOR  ${index}  IN RANGE   ${channel_numbers}
        ${channel_port}   set variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[${index}].port_no}
        Append To List     ${attenuation_port_numbers}    ${channel_port}
    END
    [Return]    ${attenuation_port_numbers}

Restore Attenuation Values For RU
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>>is to restore the initial values based on channel port numbers get form testline config.
    ...                Recommend to use this keywoed in SUITE TEARDOWN.
    ...                :param RU_id <str> : ru id which you want to operate
    ...                :param initial_att_values<list> : initial attenuation values.
    [Arguments]    ${initial_att_values}    ${RU_id}=0    ${vendor}=TopYoung    ${gnb_id}=0
    ${attenuation_port_numbers} =     gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ${channel_index}   Set Variable     ${0}
    FOR  ${item}  IN  @{initial_att_values}
      wait until keyword succeeds   5 min   5 sec    attenuator.set_attenuation    @{attenuation_port_numbers}[${channel_index}]    ${item}
      ${channel_index}=    Evaluate    ${channel_index}+${1}
    END

Modify Attenuation
    [Documentation]    Auther:stella.lin@nokia-sbell.com
    ...                <<Keyword>> is to modify values of attenuation which connect to RU.
    ...                :param channels_to_modify <dict>:channel ports and values which need to modify in programmable attenuation.
    ...                 for example: &{channels_to_modify}    create dictionary   9=20   10=20
    ...                 in this way, you want to set Port "9" to value "20".
    [Arguments]    ${channels_to_modify}    ${attenuator_device}=${None}    ${RU_id}=0    ${gnb_id}=0
    ${attenuation_port_numbers} =     gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    @{channelports_to_modify}    get dictionary keys      ${channels_to_modify}
    FOR    ${item}    IN    @{channelports_to_modify}
        ${item} =    convert to integer    ${item}
        ${channelport_value} =    convert to integer    ${channels_to_modify['${item}']}
        list should contain value    ${attenuation_port_numbers}    ${item}
        ${index} =    get index from list    ${attenuation_port_numbers}    ${item}
        wait until keyword succeeds   5 min   5 sec   attenuator.set_attenuation
        ...    port=${attenuation_port_numbers[${index}]}   value=${channelport_value}
        ...    attenuator_device=${attenuator_device}
        gnb_classical_hangzhou.Verify Attenuation Value is updated
        ...    port=${attenuation_port_numbers[${index}]}    value=${channelport_value}    attenuator_device=${attenuator_device}
    END

Modify All Attenuation Ports Value For Specific RU
    [Documentation]   lei.jia@nokia-sbell.com
    ...           Modify all atteuation ports for specific RU to some value.
    ...           :param RU_id <str> : ru id which you want to operate
    ...           :param att_id <str> : <id> for example 0 or 1, if several attenuators used and RU id is not the same with att id.
    ...                                ${None} as default, if more than one PAs and RUs defined in init.py.
    ...                                        please set RU id the same with Attenuator id in init.py,
    ...                                               even attenuator0 and attenuator1 has the same ip.
    ...                                         for example, RU0 use _attenuator_0(10.57.232.105, port 3&4)
    ...                                                      RU1 use _attenuator_1(10.57.232.105, port 7&8)
    ...           :param ${value}: <list> or <string>, it can be several values or only one.
    ...           for example:
    ...           if ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30.
    ...           if ${value} = 10, it will set all ports under RU to value 10.
    [Arguments]    ${value}    ${RU_id}=0    ${gnb_id}=0    ${att_id}=${None}
    ${all_channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    ${att_obj_in_ru_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${all_channels}
    ...    vendor=${vendor}
    ...    model=${model}
    ${value_type}    Evaluate    type(${value}).__name__
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{all_channels}
        ${index} =    get index from list    ${all_channels}    ${channel}
        ${value_dict}    set variable if    'list' in '${value_type}'    @{value}[${index}]    ${value}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value_dict}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}
    ...    RU_id=${ru_id}    gnb_id=${gnb_id}    attenuator_device=${configured_attenuator}

Verify Attenuation Value is updated
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is used to veirfy whether values of attenuation are updated successfully.
    [Arguments]   ${port}    ${value}    ${attenuator_device}=${None}
    ${new_value}=    attenuator.read_attenuation     port=${port}    attenuator_device=${attenuator_device}
    should be equal as integers     ${new_value}    ${value}    msg=Attenuation set failed.
    log to console    \n change attenuation to ${value}

Get program version based on stream version
    [Documentation]    Author: Ding Binmei
    ...                Description: Change the implementation to get program info from GNB.
    ...                Retrun with ${program_version}, valid output: 19A, 19B, 20B, master, ...
    ...                current master version is 21B, if changed then need to update
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    ${tmp_program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    ${program_version}    Set variable if    '${tmp_program_version}'=='22R1'    master    ${tmp_program_version}
    [Return]    ${program_version}
