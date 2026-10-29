*** Settings ***
Documentation
...    Common KWs about optical swith (Calient)
...    Author:shasha.liu
...    contact:shasha.liu@nokia-sbell.com
...    squad group:SG_05

Library    taf.hw.optical_switch    WITH NAME    fiberswitch

*** Variables ***
#${vendor}        Calient
#${model}         S320
#${port}           80
#${Calient_ip}    10.57.243.58
#${Calient_usr}    admin
#${Calient_pwd}    pxc***

*** Keywords ***
Connect To Fiber Switch
    [Arguments]    ${switch_index}=0
    ...            ${vendor}=${tl.optical_switches[${switch_index}].__class__.__name__}
    ...            ${model}=${tl.optical_switches[${switch_index}].model}
    ...            ${addr}=${tl.optical_switches[${switch_index}].addr}
    ...            ${port}=${80}
    ...            ${user_name}=${tl.optical_switches[${switch_index}].username}
    ...            ${password}=${tl.optical_switches[${switch_index}].password}
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Setup optical switch before operating.
    ...  :param  optical_switch: optical switch device to create, it is assumed to represent a vendor
    ...  :param  model: model of optical_switch, eg. `S320`
    ...  :param  addr: ip address or hostname of Calient.
    ...  :param  user_name: username for http authentication
    ...  :param  password: password for http authentication
    ...  :param  port: port for connection with Calient api server, defaults to 80
    ...  :param  alias: alias to be used in keywords
    fiberswitch.setup_optical_switch    optical_switch=${vendor}
    ...                                 model=${model}
    ...                                 addr=${addr}
    ...                                 user_name=${user_name}
    ...                                 password=${password}
    ...                                 port=${port}
    ...                                 alias=${alias}

Get Fiber Switch Channels
    [Arguments]    ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Gets optical switch all groups' channels settings.
    ...  :param  optical_switch_device: <str> alias of configured optical switch
    ...  :return: dict, where key is "in" channnels and value "out" channels, example: {1:1, 2:4, 3:2, 4:1}
    ...           if Calient, key is input port id(from_id), value is output port id(to_id), example:
    ...               {
    ...                   "1.1.1": "4.1.2",
    ...                   "1.3.1": "4.2.2"
    ...                }
    ${all_chanl_conns}    fiberswitch.get_optical_switch_channels    optical_switch_device=${alias}
    [Return]    ${all_chanl_conns}

Get Fiber Switch Connection Details
    [Arguments]    ${connection}
    ...            ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Gets optical switch connection details of specific channel.
    ...  :param  connection: <str> connection identity, in Calient, use from_id-to_id as connection id, like "1.1.1-4.1.2"
    ...  :param  optical_switch_device: <str> alias of configured optical switch
    ...  :return: dict with details
    ${spec_chanl_conn}    fiberswitch.get_optical_switch_connection_details    connection=${connection}
    ...                                                                        optical_switch_device=${alias}
    [Return]    ${spec_chanl_conn}

#Set Fiber Switch Channels
#    [Arguments]     ${connection}
#    ...             ${switch_index}=0
#    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
#    [Documentation]  Sets optical switch channels settings.
#    ...  :param  settings: <str> dict where key is module number on which channel should be changed, value is channel number
#    ...          value is channel number, eg. {'1.1.1': '2.2.2'} on module 1.1.1 sets channel 2.2.2
#    ...          if Calient(S320): {'1.1.1': '2.2.2'}, '1.1.1' is fromid, '2.2.2' is toid
#    ...  :param  optical_switch_device: <str> alias of configured optical switch
#    fiberswitch.set_optical_switch_channels    settings=${connection}    optical_switch_device=${alias}

Turn Off Fiber Switch Channels
    [Arguments]     ${ru_index}
    ...             ${NumofChanls}
    ...             ${switch_index}=0
    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Trun off optical switch channels by removing specific optical channels.
    ...  :param  NumofChanls: <int> the total number of optical channels used in TL
    ...  :param  alias: <str> alias of configured optical switch
    ${inPortsList}    Create List
    ${outPortsList}    Create List
    FOR    ${n}    IN RANGE    ${NumofChanls}
         ${module_no}   set variable   ${tl.gnbs[0].dus[0].rus[${${ru_index}-1}].optical_switch_channels[${n}].switch_module.module_no}
         ${channel_no}   set variable   ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].channel_no}
         #${cross_conn}    Create Dictionary    ${module_no}=${channel_no}
         Append To List    ${inPortsList}   ${module_no}
         Append To List    ${outPortsList}   ${channel_no}
    END
    Remove Fiber Switch Connections    inPortsList=${inPortsList}
    ...                                outPortsList=${outPortsList}
    ...                                directional=bidirectional

Turn On Fiber Switch Channels
    [Arguments]     ${ru_index}
    ...             ${NumofChanls}
    ...             ${switch_index}=0
    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Trun on optical switch channels by setting input and output channel path.
    ...  :param  NumofChanls: <int> the total number of optical channels used in TL
    ...  :param  alias: <str> alias of configured optical switch
    FOR    ${n}    IN RANGE    ${NumofChanls}
         ${module_no}   set variable   ${tl.gnbs[0].dus[0].rus[${${ru_index}-1}].optical_switch_channels[${n}].switch_module.module_no}
         ${channel_no}   set variable   ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].channel_no}
         ${cross_conn}    Create Dictionary    ${module_no}=${channel_no}
#         Set Fiber Switch Channels    connection=${cross_conn}
         fiberswitch.set_optical_switch_channels    settings=${cross_conn}    optical_switch_device=${alias}
    END

Remove Fiber Switch Connections
    [Arguments]     ${inPortsList}
    ...             ${outPortsList}
    ...             ${directional}=bidirectional
    ...             ${switch_index}=0
    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  remove all the connections in which the ports are in specified in_ports or out_ports.
    ...  take Calient for example:
    ...       Calient(S320): any port in the bidirectional cross-connections', can be in the in_ports or out_ports parameter
    ...       cause the port in connection acts as in_port and out_port both
    ...       unbidirecotional cross-connections example '1.1.1>2.1.1',  '3.1.1>4.1.1'
    ...       bidirectional cross-connections example '1.2.2-2.2.2', '3.2.2-4.2.2'
    ...  :param in_ports: <list> input ports on which the optical connections are setup
    ...         e.g.
    ...         Calient(S320) to remove all cross-connections above, ['1.1.1', '3.1.1', '1.2.2', '3.2.2'] is sufficient
    ...  :param out_ports: <list> out ports on which the optical connections are setup
    ...         e.g.
    ...         Calient(S320) to remove all cross-connections above, ['2.1.1', '4.1.1', '1.2.2', '3.2.2'] is sufficient
    ...  :param  optical_switch_device: <str> alias of configured optical switch
    Run Keyword if    '${directional}'=='bidirectional'
    ...    fiberswitch.remove_optical_switch_connections    in_ports=${inPortsList}
    ...                                                     out_ports=${inPortsList}
    ...                                                     optical_switch_device=${alias}
    ...    ELSE IF    '${directional}'=='unbidirectional'
    ...    fiberswitch.remove_optical_switch_connections    in_ports=${inPortsList}
    ...                                                     out_ports=${outPortsList}
    ...                                                     optical_switch_device=${alias}
    ...    ELSE    log to console    please define the cross-connections as bidirectional or unbidirectional.

Disconnect To Fiber Switch
    [Arguments]    ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]   Closes connection with optical switch.
    ...  :param  optical_switch_device: alias of configured optical switch
    fiberswitch.teardown    optical_switch_device=${alias}
