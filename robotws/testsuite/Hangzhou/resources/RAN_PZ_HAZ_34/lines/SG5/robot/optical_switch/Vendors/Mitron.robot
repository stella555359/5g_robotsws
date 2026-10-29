*** Settings ***
Documentation
...    Common KWs about optical swith (Mitron)
...    Author:shasha.liu
...    contact:shasha.liu@nokia-sbell.com
...    squad group:SG_05

Library    taf.hw.optical_switch    WITH NAME    fiberswitch

*** Variables ***
#${vendor}     Mitron
#${model}      OXC1000-32X32-SM-1356-DD-50-LP
#${port}        4001

*** Keywords ***
Connect To Fiber Switch
    [Arguments]    ${switch_index}=0
    ...            ${vendor}=${tl.optical_switches[${switch_index}].__class__.__name__}
    ...            ${model}=${tl.optical_switches[${switch_index}].model}
    ...            ${addr}=${tl.optical_switches[${switch_index}].addr}
    ...            ${port}=${4001}
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Setup optical switch before operating.
    ...  :param  optical_switch: optical switch device to create, it is assumed to represent a vendor.
    ...  :param  model: model of optical_switch, eg. 'OXC1000-32X32-SM-1356-DD-50-LP'.
    ...  :param  addr: ip address or hostname of Mitron.
    ...  :param  port: port for connection with Mitron service, defaults to 4001.
    ...  :param  alias: alias to be used in keywords.
    fiberswitch.setup_optical_switch    optical_switch=${vendor}
    ...                                 model=${model}
    ...                                 addr=${addr}
    ...                                 port=${port}
    ...                                 alias=${alias}

Get Fiber Switch Channels
    [Arguments]    ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Gets optical switch all groups' channels settings.
    ...  :param  alias: <str> alias of configured optical switch
    ...  :return: dict, where key is "in" channnels and value "out" channels, example: {1:1, 2:4}
    ...           if Mitron, key is input port, value is output port, example:
    ...               {
    ...                   "01": "01",
    ...                   "02": "04"
    ...                }
    ${all_chanl_conns}    fiberswitch.get_optical_switch_channels    optical_switch_device=${alias}
    [Return]    ${all_chanl_conns}

Get Fiber Switch Connection Details
    [Arguments]    ${connection}
    ...            ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Gets optical switch connection details of specific channel.
    ...  :param  connection: <str> connection identity, in Mitron, use input_id-output_id as connection id, like "01-01"
    ...  :param  alias: <str> alias of configured optical switch
    ...  :return: dict with details
    ${spec_chanl_conn}    fiberswitch.get_optical_switch_connection_details    connection=${connection}
    ...                                                                        optical_switch_device=${alias}
    [Return]    ${spec_chanl_conn}

#Set Fiber Switch Channels
#    [Arguments]     ${connection}
#    ...             ${switch_index}=0
#    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
#    [Documentation]  Sets optical switch channels settings.
#    ...  :param  connection: dict where key is module number on which channel should be changed, value is channel number
#    ...          if Mitron(OXC1000-32X32-SM-1356-DD-50-LP): e.g. {'01': '02'} or {'1': '2'} or {1: 2},
#    ...          '01' is input port, '02' is output port
#    ...  :param  alias: <str> alias of configured optical switch
#    fiberswitch.set_optical_switch_channels    settings=${connection}    optical_switch_device=${alias}

Turn Off Fiber Switch Channels
    [Arguments]     ${ru_index}
    ...             ${NumofChanls}
    ...             ${switch_index}=0
    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  Trun off optical switch channels by setting output channel to '0' or '00'.
    ...  :param  NumofChannels: <int> the total number of optical channels used in TL
    ...  :param  alias: <str> alias of configured optical switch
    FOR    ${n}    IN RANGE    ${NumofChanls}
         ${module_no}   set variable   ${tl.gnbs[0].dus[0].rus[${${ru_index}-1}].optical_switch_channels[${n}].switch_module.module_no}
         #${channel_no}   set variable   ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[${n}].channel_no}
         #${cross_conn}    Create Dictionary    ${module_no}=${channel_no}
         ${cross_conn}    Create Dictionary    ${module_no}=0
         fiberswitch.set_optical_switch_channels    settings=${cross_conn}    optical_switch_device=${alias}
#         Set Fiber Switch Channels    connection=${cross_conn}   optical_switch_device=${alias}
         #${all_chanl_conns_new}    Get Fiber Switch Channels
    END

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
         fiberswitch.set_optical_switch_channels    settings=${cross_conn}    optical_switch_device=${alias}
#         Set Fiber Switch Channels    connection=${cross_conn}   optical_switch_device=${alias}
         #${all_chanl_conns_new}    Get Fiber Switch Channels
    END

Remove Fiber Switch Connections
    [Arguments]     ${inPortsList}
    ...             ${outPortsList}
    ...             ${switch_index}=0
    ...             ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]  remove the all the connections in which the ports are in specified in_ports or out_ports
    ...  if Mitron(OXC1000-32X32-SM-1356-DD-50-LP): e.g. {'01': '02'} or {'1': '2'} or {1: 2},
    ...  '01' is input port, '02' is output port, i.e. in_ports is list {'01'}, out_ports is list {'02'}
    ...  :param  inPortsList: <list> input ports on which the optical connections are setup
    ...  :param  outPortsList: <list> out ports on which the optical connections are setup
    ...  :param  alias: <str> alias of configured optical switch
    fiberswitch.remove_optical_switch_connections    in_ports=${inPortsList}
    ...                                              out_ports=${outPortsList}
    ...                                              optical_switch_device=${alias}

Disconnect To Fiber Switch
    [Arguments]    ${switch_index}=0
    ...            ${alias}=${tl.optical_switches[${switch_index}].__class__.__name__}_${switch_index}
    [Documentation]   Closes connection with optical switch.
    ...  :param  alias: alias of configured optical switch
    fiberswitch.teardown    optical_switch_device=${alias}
