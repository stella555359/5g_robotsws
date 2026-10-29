*** Settings ***
Documentation    Description: This is common keywords for fiber switcha
...    And must use keyword "Get Current Connections" for backup after you connected to fiberswitch
...    Please do not modify the file without notification to author
...    author: Chen jun
...    Contact: jun.8.chen@nokia-sbell.com
...    Squard: HZ SG6

Library    String
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    taf.hw.optical_switch    WITH NAME    fiberswitch

*** Variables ***
${switch_name}    calient
${fiberswitch_type}    S320
${fiberswitch_ip}    10.57.243.58
${fiberswitch_username}    admin
${fiberswitch_password}    pxc***

*** Keywords ***
Connect To Fiber Switch
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ...                 Description: Connect To Fiber Switch
    ...                 2021-05-24: Jia Lei add arguments like vendor, alias, model, addr and port.
    ...                 ${optical_switch}: like Leoni, Calient, Mitron, Viavi
    ...                 Currently, supported devices are:
    ...                 vendor `Calient`, model `S320`
    ...                 vendor `Mitron`, model `OXC1000-32X32-SM-1356-DD-50-LP`
    [Arguments]    ${optical_switch_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    ...             ${optical_switch}=${tl.optical_switches[${optical_switch_id}].__class__.__name__}
    ...             ${model}=${tl.optical_switches[${optical_switch_id}].model}
    ...             ${addr}=${tl.optical_switches[${optical_switch_id}].addr}
    ...             ${port}=4001
    ...             ${user_name}=${fiberswitch_username}
    ...             ${password}=${fiberswitch_password}
    Run Keyword If    'Mitron' in '${optical_switch}'
    ...    fiberswitch.setup_optical_switch    optical_switch=${optical_switch}
    ...                                        model=${model}
    ...                                        addr=${addr}
    ...                                        alias=${alias}
    ...                                        port=${port}
    ...    ELSE IF    'Calient' in '${optical_switch}'
    ...    fiberswitch.setup_optical_switch    optical_switch=${optical_switch}
    ...                                        model=${model}
    ...                                        addr=${addr}
    ...                                        alias=${alias}
    ...                                        user_name=${user_name}
    ...                                        password=${password}

Disconnect To Fiber Switch
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ...               Description: Disconnect To Fiber Switch
    [Arguments]    ${optical_switch_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    fiberswitch.teardown    optical_switch_device=${alias}

Get Current Connections
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ...               Description: Get Current Connections of fiber switch for the user what you login,
    ...               return: Optical switch groups’ channels settings in dict, example: {1:1, 2:4, 3:2, 4:1}
    ...               if Calient, key is input port id(from_id), value is output port id(to_id), example:{"1.1.1": "4.1.2"}
    ...               if Mitron, key is input port, value is output port, example:{"01": "01","02": "02"}
    [Arguments]    ${optical_switch_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    &{all_connections} =    fiberswitch.get_optical_switch_channels    optical_switch_device=${alias}
    [Return]    ${all_connections}

Set New Connection
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ...               Description: Set New Connection
    ...               ${connection} dict where key is module number on which channel should be changed,eg. {'1.8.1':'2.3.1'}
    ...               if port 1.8.1 and port 2.3.1 are available, will add a new connection.
    ...               If have one connection {'1.8.1':'2.4.1'} is exist, so this connection will be changed to {'1.8.1':'2.3.1'}
    ...               And the port 2.4.1 will be available
    ...               if Calient(S320): {'1.1.1': '2.2.2'}, '1.1.1' is fromid, '2.2.2' is toid
    ...               if Mitron(OXC1000-32X32-SM-1356-DD-50-LP): e.g. {'01': '02'}
    ...               ${alias}: alias of configured optical switch
    [Arguments]    ${connection}
    ...             ${optical_switch_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    fiberswitch.set_optical_switch_channels    settings=${connection}    optical_switch_device=${alias}

Verify Connection Whether Is Aleady Exist
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ...               Description: Verify Connection Whether Is Aleady Exist
    ...               ${connection} shoule be dictionary
    ...               ${connection}={'1.8.1':'2.3.1'}
    [Arguments]    ${connection}
    ...             ${optical_switch_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    ${all_connections} =   Get Current Connections      alias=${alias}
    Dictionary Should Contain Sub Dictionary    ${all_connections}    ${connection}

Switch RU And Verify Connection State
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ...               Description: Switch RU And Verify Connection Works after switch.
    ...               2021-05-24: Jia Lei add arguments and documentation.
    ...               ${connection} shoule be dictionary
    ...               ${connection}={'1.8.1':'2.3.1'}
    [Arguments]    ${connection}
    ...             ${optical_switch_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    ...             ${optical_switch}=${tl.optical_switches[${optical_switch_id}].__class__.__name__}
    ...             ${model}=${tl.optical_switches[${optical_switch_id}].model}
    ...             ${addr}=${tl.optical_switches[${optical_switch_id}].addr}
    Connect To Fiber Switch    alias=${alias}    optical_switch=${optical_switch}    model=${model}    addr=${addr}
    ${backup_list} =   Get Current Connections      alias=${alias}
    ${status} =    Run Keyword And Return Status    Set New Connection    connection=${connection}    alias=${alias}
    sleep      2s
    Run Keyword If    ${status}==${False}    Set New Connection    connection=${connection}    alias=${alias}
    Verify Connection Whether Is Aleady Exist    connection=${connection}    alias=${alias}
    Disconnect To Fiber Switch    alias=${alias}

Get Fiberswitch Channel Number For RU
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Get all fiber swtich channel numbers for given RU
    [Arguments]    ${ru_id}=0    ${gnb_id}=0    ${du_id}=0
    ${fiberswitch_channels}     set variable    ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${${ru_id}}].optical_switch_channels}
    ${channel_numbers}     Get Length       ${fiberswitch_channels}
    [Return]    ${channel_numbers}

Set Fiber Switch Into linkup For RU
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Connects to optical switch and sets switch into operational position for given radio.
    [Arguments]    ${optical_switch_id}=0
    ...             ${ru_id}=0
    ...             ${gnb_id}=0
    ...             ${du_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    ...             ${optical_switch}=${tl.optical_switches[${optical_switch_id}].__class__.__name__}
    ...             ${model}=${tl.optical_switches[${optical_switch_id}].model}
    ...             ${addr}=${tl.optical_switches[${optical_switch_id}].addr}
    ${channel_numbers}    Get Fiberswitch Channel Number For RU    ru_id=${ru_id}    gnb_id=${gnb_id}    du_id=${du_id}
    &{linkup_setting}    create dictionary
    FOR    ${n}    IN RANGE    ${channel_numbers}
         ${module_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].switch_module.module_no}
         ${channel_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].channel_no}
         ${in_port}    Convert To String    ${module_no}
         ${out_port}    Convert To String    ${channel_no}
         Set To Dictionary    ${linkup_setting}    ${in_port}=${out_port}
    END
    Switch RU And Verify Connection State    connection=${linkup_setting}
    ...                                      optical_switch_id=${optical_switch_id}
    ...                                      alias=${alias}
    ...                                      optical_switch=${optical_switch}
    ...                                      model=${model}
    ...                                      addr=${addr}

Set Fiber Switch Into link_failure For RU on Mitron
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                 Connects to optical switch and sets switch into link failure position for given radio.
    [Arguments]    ${optical_switch_id}=0
    ...             ${ru_id}=0
    ...             ${gnb_id}=0
    ...             ${du_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    ...             ${optical_switch}=${tl.optical_switches[${optical_switch_id}].__class__.__name__}
    ...             ${model}=${tl.optical_switches[${optical_switch_id}].model}
    ...             ${addr}=${tl.optical_switches[${optical_switch_id}].addr}
    ...             ${dummy_output_channel}=00
    ${channel_numbers}    Get Fiberswitch Channel Number For RU    ru_id=${ru_id}    gnb_id=${gnb_id}    du_id=${du_id}
    &{link_failure_settings}    create dictionary
    FOR    ${n}    IN RANGE    ${channel_numbers}
         ${module_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].switch_module.module_no}
         ${in_port}    Convert To String    ${module_no}
         Set To Dictionary    ${link_failure_settings}    ${in_port}=${dummy_output_channel}
    END
    Switch RU And Verify Connection State    connection=${link_failure_settings}
    ...                                      optical_switch_id=${optical_switch_id}
    ...                                      alias=${alias}
    ...                                      optical_switch=${optical_switch}
    ...                                      model=${model}
    ...                                      addr=${addr}

Set Fiber Switch Into link_failure For RU On Calient
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...                 Connects to optical switch and sets switch into link failure position for given radio.
    [Arguments]     ${dummy_output_channel}
    ...             ${optical_switch_id}=0
    ...             ${ru_id}=0
    ...             ${gnb_id}=0
    ...             ${du_id}=0
    ...             ${alias}=fiberswitch_${optical_switch_id}
    ...             ${optical_switch}=${tl.optical_switches[${optical_switch_id}].__class__.__name__}
    ...             ${model}=${tl.optical_switches[${optical_switch_id}].model}
    ...             ${addr}=${tl.optical_switches[${optical_switch_id}].addr}
    ${channel_numbers}    Get Fiberswitch Channel Number For RU    ru_id=${ru_id}    gnb_id=${gnb_id}    du_id=${du_id}
    #@{dummy_output_channel_list}    create list  ${dummy_output_channel}
    &{link_failure_settings}    create dictionary
    FOR    ${n}    IN RANGE    ${channel_numbers}
         ${module_no}    set variable     ${tl.gnbs[${gnb_id}].dus[${du_id}].rus[${ru_id}].optical_switch_channels[${n}].switch_module.module_no}
         ${in_port}    Convert To String    ${module_no}
         Set To Dictionary    ${link_failure_settings}    ${in_port}=${dummy_output_channel[${n}]}
    END
    Switch RU And Verify Connection State    connection=${link_failure_settings}
    ...                                      optical_switch_id=${optical_switch_id}
    ...                                      alias=${alias}
    ...                                      optical_switch=${optical_switch}
    ...                                      model=${model}
    ...                                      addr=${addr}