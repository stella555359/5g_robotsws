*** Settings ***
Documentation    Keywords using optical_switch library and working with Calient Optical Switch
...              Resource used by RF Sharing Vrf tribe
...              Author: Horea Olar
...              Contact: horea.olar@nokia.com

Library    taf.hw.optical_switch

*** Keywords ***
Optical Switch Setup
    [Documentation]
    ...  Establish the connection to Optical Switch
    ...
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                                                                             |
    ...  | switch vendor    | No    | Calient | The vendor of Optical Switch                                                            |
    ...  | switch model     | No    | S320    | The model of Optical Switch                                                             |
    ...  | switch ip        | Yes   |         | The IP of Optical Switch                                                                |
    ...  | switch username  | Yes   |         | The Username of Optical Switch                                                          |
    ...  | switch password  | Yes   |         | The Password of Optical Switch                                                          |
    ...  | alias            | No    | default | The alias of configured Optical Switch                                                  |
    ...  | port             | No    | 80      | The port for connection to Optical Switch  de adaugat port 22 [pt tl1 protocol          |
    ...                                       | Available values: "80"(default Calient setup), "22"(setup used for tl1 protocol)        |
    ...  | protocol         | No    | http    | The protocol for connection to Optical Switch                                           |
    ...                                       | Available values: "http"(default Calient setup), "tl1"(setup used for link_flapping KW) |
    ...
    [Arguments]  ${switch_ip}  ${switch_username}  ${switch_password}  ${port}=80  ${switch_vendor}=Calient  ${switch_model}=S320  ${alias}=default
    ...  ${protocol}=http

    setup_optical_switch                optical_switch=${switch_vendor}
    ...                                 model=${switch_model}
    ...                                 addr=${switch_ip}
    ...                                 user_name=${switch_username}
    ...                                 password=${switch_password}
    ...                                 alias=${alias}
    ...                                 port=${port}
    ...                                 protocol=${protocol}

Get All Cross Connections
    [Documentation]
    ...  This kw return all created cross connections
    ...
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                          |
    ...  | alias                | No    | default   | alias of configured optical switch   |
    ...
    ...  *RETURN*
    ...  | Parameter           | Description                                                                  |
    ...  | all connections     | The list of created cross connections as dictionary ex [u'1.1.3': u'5.5.3']  |
    ...
    ...  *EXAMPLE*
    ...  For Calient: ${all_connections}={u'1.1.3': u'5.5.3', u'1.1.2': u'5.5.2', u'1.1.4': u'1.1.8', u'1.1.7': u'5.5.7'}
    ...
    [Arguments]  ${alias}=default

    &{all_connections} =  get_optical_switch_channels  optical_switch_device=${alias}
    [Return]    ${all_connections}

Create Cross Connections
    [Documentation]
    ...  Set new cross connections. Single or multiple cross connections can be created by this keyword
    ...
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                              |
    ...  | new connections      | Yes   |           | A dictionary formed by in and out ports  |
    ...  | alias                | No    | default   | alias of configured optical switch       |
    ...
    ...  *EXAMPLE*
    ...  For Calient: ${new_connections}={'1.8.1':'2.3.1'}
    ...  ${new_connections} if port 1.8.1 and port 2.3.1 are available, will add a new connection.
    ...  if 1.8.1 build already another cross connect, the old one is deleted and the new one will be overwriten with the gived ports
    ...
    [Arguments]    ${new_connections}  ${alias}=default

    set_optical_switch_channels    settings=${new_connections}  optical_switch_device=${alias}

Remove Cross Connection
    [Documentation]
    ...   Remove a cross connection formed by a port
    ...
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                                          |
    ...  | port                 | Yes   |           | Port who form cross connect that want to be deleted  |
    ...  | alias                | No    | default   | alias of configured optical switch                   |
    ...
    ...  *EXAMPLE*
    ...  For Calient: ${port} = 1.3.5
    ...
    [Arguments]  ${port}  ${alias}=default

    @{port_list} =  Create List  ${port}
    remove_optical_switch_connections  in_ports=${port_list}  optical_switch_device=${alias}

Get Cross Connection details
    [Documentation]
    ...  Get details about a given active cross connection
    ...
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                           |
    ...  | connection_id        | Yes   |           | The id of connection as string        |
    ...  | alias                | No    | default   | alias of configured optical switch    |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                               |
    ...  | connection details     | Details about the gived cross connection  |
    ...
    ...  *EXAMPLE*
    ...   For Calient: ${connection_id}='1.8.1-2.3.1'
    ...   For Calient: ${connection_details}={u'group': u'SYSTEM', u'name': u'1.3.3-1.3.7', u'half1': {u'outp': u'-90.00', u'loss': u'-90.00',
    ...                                       u'inp': u'-90.00', u'alarm': u'CL', u'oc': u'FAIL', u'as': u'UMA', u'os': u'RDY',
    ...                                       u'conn': u'1.3.3>1.3.7'},
    ...                                       u'deadreckon': False, u'band': u'SBAND',
    ...                                       u'half2': {u'outp': u'-90.00', u'loss': u'-90.00', u'alarm': u'CL', u'oc': u'FAIL', u'as': u'UMA',
    ...                                       u'in': u'-90.00', u'os': u'RDY', u'conn': u'1.3.7>1.3.3'},
    ...                                       u'connid': u'1.3.3-1.3.7', u'nolight': False, u'autofocus': True, u'dir': u'BI'}
    ...
    [Arguments]  ${connection_id}  ${alias}=default

    ${connection_details}=  get_optical_switch_connection_details  connection=${connection_id}  optical_switch_device=${alias}

    [Return]  ${connection_details}

Teardown Optical Switch
    [Documentation]
    ...  Close the connection to Optical Switch
    ...
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                           |
    ...  | alias                | No    | default   | alias of configured optical switch    |
    ...
    [Arguments]  ${alias}=default

    taf.hw.optical_switch.teardown  optical_switch_device=${alias}

Create Cross Connections by Id
    [Documentation]
    ...  Create cross connections from a given list of Cross Connections ids in format <port_nb>-<port_nb>
    ...
    ...  *AUTHOR*
    ...  bogdan.hurduzeu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                      | Man.  | Default   | Description                               |
    ...  | list_cross_connections         | Yes   |           | list of cross-connections ids             |
    ...  | alias                          | No    | default   | alias of configured optical switch        |
    ...
    ...  *EXAMPLE*
    ...  For Calient: ${list_cross_connections}=['1.3.3-1.3.7','1.3.1-1.6.1']
    ...
    [Arguments]  ${list_cross_connections}  ${alias}=default

    ${new_connection}=  Create Dictionary
    FOR  ${connection}  IN  @{list_cross_connections}
        ${pre}  ${post}=  Split String  ${connection}  -
        Set To Dictionary  ${new_connection}  ${pre}=${post}
    END
    Create Cross Connections  new_connections=${new_connection}  alias=${alias}

Create Cross Connection with Options by Id
    [Documentation]
    ...  Creates a connection given as id in format <port_nb>-<port_nb>
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default   | Description                                   |
    ...  | new_connection   | Yes   |           | cross-connection id                         |
    ...  | group            | No    |   EMPTY   | group name                                    |
    ...  | conn             | No    |   EMPTY   | connection name, in-out formatted by default  |
    ...  | dir              | No    |   EMPTY   | direction, [bi|uni], 'bi' by default          |
    ...  | band             | No    |   EMPTY   | band, [C|O|L|S|W], 'C' by default             |
    ...  | nolight          | No    |   EMPTY   | boolean, False by default                     |
    ...  | deadreckon       | No    |   EMPTY   | boolean, False by default                     |
    ...  | alias            | No    |  default  | alias of configured optical switch            |
    ...
    ...  *EXAMPLE*
    ...  For Calient: ${new_connection}='1.1.2-5.5.2'
    ...
    [Arguments]  ${new_connection}  ${group}=${EMPTY}  ${conn}=${EMPTY}  ${dir}=${EMPTY}  ${band}=${EMPTY}  ${nolight}=${EMPTY}
    ...  ${deadreckon}=${EMPTY}  ${alias}=default

    ${pre_port}  ${post_port}=  Split String  ${new_connection}  -
    ${settings}=  Create Dictionary  in=${pre_port}  out=${post_port}   group=${group}  conn=${conn}  dir=${dir}  band=${band}  nolight=${nolight}
    ...  deadreckon=${deadreckon}
     FOR  ${key}  IN  @{settings}
       Run keyword if  '${settings['${key}']}' == '${EMPTY}'  Remove From Dictionary  ${settings}  ${key}
     END

    Set Optical Switch Channel  settings=${settings}  optical_switch_device=${alias}

Remove Cross Connection By Id
    [Documentation]
    ...  Removes a connection given as id in format <port_nb>-<port_nb>
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man.  | Default   | Description                               |
    ...  | connection         | Yes   |           | cross-connection id                       |
    ...  | alias              | No    | default   | alias of configured optical switch        |
    ...
    ...  *EXAMPLE*
    ...  For Calient: ${connection}='1.1.4-1.1.8'
    ...
    [Arguments]  ${connection}  ${alias}=default

    ${pre_port}  ${post_port}=  Split String  ${connection}  -
    @{port_list} =  Create List  ${pre_port}
    Remove Optical Switch Connections  in_ports=${port_list}  optical_switch_device=${alias}

Get Cross Connection Status by Id
    [Documentation]
    ...  Verifies that a given cross connection exists
     ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man.  | Default   | Description             |
    ...  | cross_connection_id    | Yes   |           | cross-connection id     |
    ...  | status                 | No    | default   | returned boolean        |
    ...
    ...  *EXAMPLE*
    ...  For Calient: ${cross_connection_id}='1.1.7-5.5.7'
    ...
    [Arguments]  ${cross_connection_id}  ${status}= default

    ${all_connections}=  Get All Cross Connections
    ${pre_port}  ${post_port}=  Split String  ${cross_connection_id}  -
    ${status}=  Set Variable If  ('${pre_port}' in @{all_connections.keys()}) and ('${post_port}' in @{all_connections.values()})  True  False
    [Return]  ${status}

Get Cross Connection Id
    [Documentation]
    ...  Search for cross connection between any two ports and returns cross connection id.
    ...  If cross connection does not exist between those ports the keyword will fail
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man.  | Default   | Description                |
    ...  | first_port             | Yes   |           | cross-connection in port   |
    ...  | second_port            | Yes   |           | cross-connection out port  |
    ...
    ...  *EXAMPLE*
    ...  For Optical Switch: ${first_port}='1.1.7'  ${second_port}='5.5.7'
    ...

    [Arguments]  ${first_port}  ${second_port}

	${all_connections}=  Get All Cross Connections
	${dictionary_keys}=  Get Dictionary Keys  ${all_connections}

    FOR  ${key}  IN  @{dictionary_keys}
        Run Keyword If  '${key}' == '${first_port}' and '${all_connections['${key}']}' == '${second_port}'
        ...  Return From Keyword  ${first_port}-${second_port}
        ...  ELSE IF  '${key}' == '${second_port}' and '${all_connections['${key}']}' == '${first_port}'
        ...  Return From Keyword  ${second_port}-${first_port}
	END
    Log  Cross connection does not exist in Optical Switch!  level=ERROR
    Fail  Cross connection does not exist in Optical Switch!

Set Short Link Break by Ports List
    [Documentation]
    ...  Keyword helper for entering micro-pauses based on ports list from Calient
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man.  | Default     | Description                                            |
    ...  | ports                  | Yes   |             | Ports list separated by space used by cross connection |
    ...  | lowperiod              | No    |   EMPTY     | lowperiod duration in ms e.g. 20ms                     |
    ...  | highperiod             | No    |   EMPTY     | highperiod duration in ms, e.g. 40ms                   |
    ...  | repeat                 | No    |   EMPTY     | repeat count, between 1 and 30                         |
    ...  | duration               | No    |   EMPTY     | duration in ms, e.g. 40ms                              |
    ...  | period                 | No    |   EMPTY     | priod in ms, e.g. 40ms                                 |
    ...  | frequency              | No    |   EMPTY     | frequency, e.g. 25Hz - 0.00027777Hz                    |
    ...  | optical_switch_device  | No    |  default    | alias of configured optical switch                     |
    ...
    ...  *EXAMPLE*
    ...  Set Short Link Break by Ports List  ports=[1.2.2]  lowperiod=1000  highperiod=1000  repeat=1
    ...  Set Short Link Break by Ports List  ports=[1.2.2, 1.2.4]  lowperiod=1000  highperiod=1000  repeat=1
    ...

     [Arguments]  ${ports}=${ports}  ${lowperiod}=${EMPTY}  ${highperiod}=${EMPTY}  ${repeat}=${EMPTY}
     ...  ${duration}=${EMPTY}  ${period}=${EMPTY}  ${frequency}=${EMPTY}  ${optical_switch_device}=default

     set_link_flapping  ports=${ports}  lowperiod=${lowperiod}  highperiod=${highperiod}  repeat=${repeat}
     ...  duration=${duration}  period=${period}  frequency=${frequency}  optical_switch_device=${optical_switch_device}

Set Short Link Break by Connection ID
    [Documentation]
    ...  Keyword helper for entering micro-pauses based on connection ID from Calient
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man.  | Default     | Description                              |
    ...  | connection_id          | Yes   |             | connection_id define in Calient          |
    ...  | lowperiod              | No    |   EMPTY     | lowperiod duration in ms e.g. 20ms       |
    ...  | highperiod             | No    |   EMPTY     | highperiod duration in ms, e.g. 40ms     |
    ...  | repeat                 | No    |   EMPTY     | repeat count, between 1 and 30           |
    ...  | duration               | No    |   EMPTY     | duration in ms, e.g. 40ms                |
    ...  | period                 | No    |   EMPTY     | priod in ms, e.g. 40ms                   |
    ...  | frequency              | No    |   EMPTY     | frequency, e.g. 25Hz - 0.00027777Hz      |
    ...  | optical_switch_device  | No    |  default    | alias of configured optical switch       |
    ...
    ...  *EXAMPLE*
    ...  Set Short Link Break by Connection ID  connection_id=1.2.2>1.2.4  lowperiod=1000  highperiod=1000  repeat=1
    ...  Set Short Link Break by Connection ID  connection_id=1.2.2-1.2.4  lowperiod=1000  highperiod=1000  repeat=1
    ...
    [Arguments]  ${connection_id}  ${lowperiod}=${EMPTY}  ${highperiod}=${EMPTY}  ${repeat}=${EMPTY}
    ...  ${duration}=${EMPTY}  ${period}=${EMPTY}  ${frequency}=${EMPTY}  ${optical_switch_device}=default

    ${connection_id}=  Replace String	${connection_id}  >  -
    ${first_port}  ${second_port}=  Split String  ${connection_id}  -
    @{port_list}=  Create List  ${first_port}  ${second_port}
    set_link_flapping  ports=${port_list}  lowperiod=${lowperiod}  highperiod=${highperiod}  repeat=${repeat}
    ...  duration=${duration}  period=${period}  frequency=${frequency}  optical_switch_device=${optical_switch_device}

Create Multiple Cross Connections
    [Documentation]
    ...  Set multiple cross connections. Allows the user to make multiple connections on an arbitrary batch of connections.
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man. | Default | Description                                                            |
    ...  | connection_list       | Yes  |         | List of connections to be set; Example: ["1.1.1-2.2.2", "3.4.1>3.3.3"] |
    ...  | optical_switch_device | No   | default | alias of configured optical switch                                     |
    ...
    [Arguments]  ${connection_list}  ${optical_switch_device}=default

    set_multiple_cross_connections  connection_list=${connection_list}  optical_switch_device=${optical_switch_device}