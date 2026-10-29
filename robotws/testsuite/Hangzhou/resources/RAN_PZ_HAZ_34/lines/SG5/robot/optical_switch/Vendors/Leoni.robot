*** Settings ***
Documentation
...    Common KWs about optical swith (Leoni)
...    Author:shasha.liu
...    contact:shasha.liu@nokia-sbell.com
...    squad group:SG_05

Library    taf.hw.optical_switch    WITH NAME    fiberswitch

*** Variables ***
#${optical_switch}    Leoni
#${model}             mol 6x(2x6)
#${port}               23

*** Keywords ***
Connect To Fiber Switch
    [Arguments]    ${switch_index}=0
    ...            ${vendor}=${tl.optical_switches[${switch_index}].__class__.__name__}
    ...            ${model}=${tl.optical_switches[${switch_index}].model}
    ...            ${addr}=${tl.optical_switches[${switch_index}].addr}
    ...            ${port}=${23}
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Setup optical switch before operating.
    ...  :param  optical_switch: optical switch device to create, it is assumed to represent a vendor
    ...  :param  model: model of optical_switch, eg. 'mol 6x(2x6)'
    ...  :param  addr: ip address or hostname of Leoni
    ...  :param  port: port for connection with Leoni service, defaults to 23
    ...  :param  alias: alias to be used in keywords
    fiberswitch.setup_optical_switch    optical_switch=${vendor}
    ...                                 model=${model}
    ...                                 addr=${addr}
    ...                                 port=${port}
    ...                                 alias=${alias}

Get Fiber Switch Channels
    [Arguments]    ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Gets optical switch all groups' channels settings.
    ...  :param  optical_switch_device: <str> alias of configured optical switch
    ...  :return: dict, where key is "in" channnels and value "out" channels, example: {1:2, 2:4}
    ...           if Leoni, key is input port, value is output port, example:
    ...               {
    ...                   "1": "2",
    ...                   "2": "4"
    ...                }
    ${all_chanl_conns}    fiberswitch.get_optical_switch_channels    optical_switch_device=${alias}
    [Return]    ${all_chanl_conns}

Get Fiber Switch Connection Details
    [Arguments]    ${connection}
    ...            ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Gets optical switch connection details of specific channel.
    ...  :param  connection: <str> connection identity, in Leoni, use input_id-output_id as connection id, like "1-2"
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
#    ...          if Leoni(mol 6x(2x6)): e.g. {'1': '2'} or {1: 2},
#    ...          '1' is input port, '2' is output port
#    ...  :param  optical_switch_device: <str> alias of configured optical switch
#    fiberswitch.set_optical_switch_channels    settings=${connection}    optical_switch_device=${alias}

Turn Off Fiber Switch Channels
    [Arguments]     ${ru_index}
    ...             ${NumofChanls}
    ...             ${switch_index}=0
    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Trun off optical switch channels by removing specific optical channels (or setting to dummy position).
    ...  :param  NumofChannels: <int> the total number of optical channels used in TL
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
    ...  :param  NumofChannels: <int> the total number of optical channels used in TL
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
    ...             ${switch_index}=0
    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  remove the all the connections in which the ports are in specified in_ports or out_ports
    ...  if Leoni(mol 6x(2x6)): e.g. {'1': '2'} or {1: 2},
    ...  '01' is input port, '02' is output port, i.e. in_ports is list {'1'}, out_ports is list {'2'}
    ...  :param in_ports: <list> input ports on which the optical connections are setup
    ...  :param out_ports: <list> out ports on which the optical connections are setup
    ...  :param  optical_switch_device: <str> alias of configured optical switch
    fiberswitch.remove_optical_switch_connections    in_ports=${inPortsList}
    ...                                              out_ports=${outPortsList}
    ...                                              optical_switch_device=${alias}

Disconnect To Fiber Switch
    [Arguments]    ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]   Closes connection with optical switch.
    ...  :param  optical_switch_device: alias of configured optical switch
    fiberswitch.teardown    optical_switch_device=${alias}
