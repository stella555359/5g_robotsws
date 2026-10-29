*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This resources contains keywords related to L3 call

Library     ta5g_egate
Library     ute_wtssim
Library     ta5g_ue_mobility
Library     ta_messaging
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot


*** Keywords ***
Stop Data Traffic And Release Multiple Ues
    [Documentation]
    ...    Stops data traffic for multiple UEs and then releses PDU sessions and UEs
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man.  | Description                                                          |
    ...    +========================+======+=======================================================================+
    ...    | ue_ids                 | Yes   | List of UE ids to be released.                                       |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_ids                | Yes   | List of PDU ids to be released.                                      |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_ids}    ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Execute Egate Command    cmd=trf_data_stop ue=${ue_ids}[${ue_index}] pdu=${pdu_ids}[${ue_index}]
        Release Ue    ue_id=${ue_ids}[${ue_index}]   pdu_id=${pdu_ids}[${ue_index}]
    END

Release Ue
    [Documentation]
    ...    Releses single PDU session and UE
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man. | Description                                                           |
    ...    +========================+======+=======================================================================+
    ...    | ue_id                  | Yes  | A UE id to be released.                                               |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_id                 | Yes  | A PDU id to be released.                                              |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_id}    ${pdu_id}
    Release UE PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister Ue    ue_id=${ue_id}

Attach Multiple UEs And Establish PDU Sessions
    [Documentation]
    ...    Attaches multiple UEs and established PDU sessions for the UEs
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man. | Description                                                           |
    ...    +========================+======+=======================================================================+
    ...    | ue_ids                 | Yes  | UE ids to be attached.                                                |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_ids                | Yes  | PDU ids to be set.                                                    |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | gw_ids                 | Yes  | Gateway ids.                                                          |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | cell_id                | Yes  | A cell id to attach UE.                                               |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | gnb_id                 | No   | A gNB id to attach UE.                                                |
    ...    |                        |      | Default value: 2.                                                     |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_ids}    ${pdu_ids}    ${gw_ids}    ${cell_id}    ${gnb_id}=2    ${gnb_ip}=10.0.1.2
    Create GNB Device With Alias 'gNB${gnb_id}' Identified By ip=${gnb_ip}
    Enable Internal Mirroring For Alias    gNB${gnb_id}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Create UE Alias    alias=UE${ue_ids}[${ue_index}]    ue_id=${ue_ids}[${ue_index}]    id_type=wts_5g
        Attach And Establish PDU Session For UE   ue_id=${ue_ids}[${ue_index}]    cell_id=${cell_id}    enb_id=${gnb_id}
        ...                                    pdu_id=${pdu_ids}[${ue_index}]    gw_id=${gw_ids}[${ue_index}]
    END

Release Multiple UEs
    [Documentation]
    ...    Releases mustiple UEs and PDU sessions
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man. | Description                                                           |
    ...    +========================+======+=======================================================================+
    ...    | ue_ids                 | Yes  | UE ids to be released.                                                |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_ids                | Yes  | PDU ids to be released.                                               |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_ids}   ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Release UE    ue_id=${ue_ids}[${ue_index}]   pdu_id=${pdu_ids}[${ue_index}]
    END

Attach And Establish PDU Session For UE
    [Documentation]
    ...    Attach UE and establish PDU session
    ...
    ...    | **Author:** wojciech.peciak@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter               	| Man. | Description                                                           |
    ...    +============================+======+=======================================================================+
    ...    | ue_id                      | Yes  | UE id to be attached.                                                 |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | cell_id                    | Yes  | Cell id to attach to.                                                 |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | enb_id                     | No   | gNB id to attach to.                                                  |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_id                     | No   | PDU id to be established.                                             |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | gw_id                      | No   | GW id to be used in PDU establishment.                                |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_session_setup_timeout  | No   | Timeout in seconds for PDU setup command.                             |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | nwslice                 	| No   | Network slice to be used in PDU setup command.                        |
    ...    +----------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=1    ${pdu_id}=1    ${gw_id}=1    ${pdu_session_setup_timeout}=15
    ...    ${nwslice}=1
    Attach UE    ue_id=${ue_id}    cell=${cell_id}    enb=${enb_id}
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    Set UE Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=${nwslice}
    ...    timeout=${pdu_session_setup_timeout}
    ...    pass_regexp=UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID=

Set UE Traffic Type To Internal
    [Documentation]
    ...    Configure PDU session with internal traffic
    ...
    ...    | **Author:** wojciech.peciak@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter               	| Man. | Description                                                           |
    ...    +============================+======+=======================================================================+
    ...    | ue_id                      | Yes  | UE id to be configured.                                               |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_id                     | Yes  | PDU id to be configured.                                              |
    ...    +----------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Release UE PDU Session
    [Documentation]
    ...    Release PDU session for given UE id
    ...
    ...    | **Author:** wojciech.peciak@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter               	| Man. | Description                                                           |
    ...    +============================+======+=======================================================================+
    ...    | ue_id                      | Yes  | UE id to have the session released.                                   |
    ...    +----------------------------+------+-----------------------------------------------------------------------+
    ...    | pdu_id                     | No   | PDU id to be released.                                                |
    ...    +----------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}
    ...    pass_regexp=Successfully released PDU Session with ID ${pdu_id}
    BuiltIn.Sleep    1s    reason=Alllow PDU Release process to finish
