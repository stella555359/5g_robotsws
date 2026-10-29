*** Settings ***
Documentation    Keywords for complex procedures
...              which use a variety of BTS interfaces
...              Resource used by
...              RF Sharing TSR2 department tests

*** Variables ***
${Max_Equipment_level}    ${5}
@{ALL_DETAILED_EQUIPMENT_KEYS}   SHARED_RMOD_CPRI_enabled  SHARED_RMOD_ECPRI_enabled  SHARED_RMOD_ECPRI_NETCONF_enabled  SHARED_RMOD_OBSAI_enabled
    ...  SHARED_RMOD_CPRI_disabled  SHARED_RMOD_ECPRI_disabled  SHARED_RMOD_ECPRI_NETCONF_disabled  SHARED_RMOD_OBSAI_disabled
    ...  SHARED_RMOD_CPRI_reset  SHARED_RMOD_ECPRI_reset  SHARED_RMOD_ECPRI_NETCONF_reset  SHARED_RMOD_OBSAI_reset
    ...  SHARED_FHS_CPRI_enabled  SHARED_FHS_CPRI_disabled  SHARED_FHS_CPRI_reset
    ...  DEDICATED_RMOD_CPRI_enabled  DEDICATED_RMOD_ECPRI_enabled  DEDICATED_RMOD_ECPRI_NETCONF_enabled  DEDICATED_RMOD_OBSAI_enabled
    ...  DEDICATED_RMOD_CPRI_disabled  DEDICATED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled  DEDICATED_RMOD_OBSAI_disabled
    ...  DEDICATED_RMOD_CPRI_reset  DEDICATED_RMOD_ECPRI_reset  DEDICATED_RMOD_ECPRI_NETCONF_reset  DEDICATED_RMOD_OBSAI_reset
    ...  DEDICATED_FHS_CPRI_enabled  DEDICATED_FHS_CPRI_disabled  DEDICATED_FHS_CPRI_reset

@{ALL_EQUIPMENT_KEYS}  Equipment_enabled  Equipment_disabled  Equipment_reset

@{DETAILED_EQUIPMENT_PARAMETERS}  DN  SN  rules  connected_in  sync_link_lost  CB007447_eligible  CB010846_eligible  CB012446_eligible

*** Keywords ***
Get Testline equipment connected by Cablink
    [Documentation]
    ...  KW that returns RMODS and FHS from WHOLE TESTLINE which are connected to indicated source equipment
    ...  ${Source_equipment_id_dict} can contain Realtime DN of
    ...  BBMOD, SMOD, FHS, RMOD (any firstEndpointDN or secondEndpointDN of an optical fiber CABLINK)
    ...  KW will also return all equipment connected indirectly to source equipment (i.e. through other equipment)
    ...  Dictionary structure:
    ...  Equipment_enabled=[list of DNs] - equipment that is not reset, or disabled.
    ...  Equipment_disabled=[List of DNs] - equipment that is just disabled (1 of 2 M-plane links lost), not reset
    ...                                     (no impact on peer, if there is any peer BTS).
    ...  Equipment_reset=[List of DNS] - equipment that is reset
    ...                                  (impact on peer is expected depending on equipment type, if there is any peer BTS).
    ...
    ...  Level means number of intermediary equipment between source equipment and a certian detected equipment
    ...  Level 0 - directly connected (Source->x)
    ...  Level 1 - connected through other equipment (Source->FHS->x, Source->RMOD->x)
    ...  Level 2 - connected through 2 other equipments (Source->FHS-RMOD->x, Source->RMOD->RMOD->x)
    ...  etc
    ...
    ...  MAX_EQUIPMENT_LEVEL means how far the KW will go to detect equipment
    ...  connected to equipment from ${Source_equipment_id_dict}
    ...  The indicated level is the level at which teh algorithm stops
    ...  1 - only equipment dirrectly connected to equipment from ${Source_equipment_id_dict} is detected (level 0)
    ...  2 - 1 intermediary layer (FHS, or other RMOD). Eg. a chain of 2 RMOD (level 1) . The 3 rd RMOD in a chain will not be detected
    ...  3 - 2 intermediary layers (FHS, or other RMOD). Eg. a chain of 3 RMOD (level 2) . The 4 th RMOD in a chain will not be detected
    ...
    [Arguments]   ${Source_equipment_id_dict}  ${alias}  ${alias_list}  ${Max_equipment_level}=${Max_equipment_level}
    ...  ${Reset_dependency_rules}=${Reset_dependency_rules}  ${CPRI_SN_EXCEPTIONS}=&{Empty}  ${ECPRI_SN_EXCEPTIONS}=&{Empty}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}=&{Empty}  ${OBSAI_SN_EXCEPTIONS}=&{Empty}
    ...  ${CB007447_EXCEPTIONS}=&{Empty}  ${CB010846_EXCEPTIONS}=&{Empty}  ${CB012446_EXCEPTIONS}=&{Empty}

    ${TL_detailed_equipment_dict}=  Create Dictionary
    ${remaining_aliases}=  Copy List  ${alias_list}  ${True}
    Remove Values From List  ${remaining_aliases}  ${alias}

    ${Equipment_sync_link_lost}=  Create List
    Set Test Variable  ${Equipment_sync_link_lost}

    ${dependent_equipment_dict}  ${detailed_dependent_equipment_dict}=
    ...  Get BTS equipment connected by Cablink  Source_equipment_id_dict=${Source_equipment_id_dict}
    ...  alias=${alias}
    ...  Max_equipment_level=${Max_equipment_level}
    ...  Include_source_equipment=${False}
    ...  Reset_dependency_rules=${Reset_dependency_rules}
    ...  CPRI_SN_EXCEPTIONS=${CPRI_SN_EXCEPTIONS}  ECPRI_SN_EXCEPTIONS=${ECPRI_SN_EXCEPTIONS}
    ...  ECPRI_NETCONF_SN_EXCEPTIONS=${OBSAI_SN_EXCEPTIONS}
    ...  OBSAI_SN_EXCEPTIONS=${OBSAI_SN_EXCEPTIONS}  CB010846_EXCEPTIONS=${CB010846_EXCEPTIONS}
    ...  CB012446_EXCEPTIONS=${CB012446_EXCEPTIONS}
    Set To Dictionary  ${TL_detailed_equipment_dict}  ${alias}=${detailed_dependent_equipment_dict}

    ${expected_peer_BTS_enabled_shared_FHS_RMOD_sn_list}=  Get Combined List From Dictionary  ${dependent_equipment_dict}
    ...  Equipment_enabled_SN  Equipment_disabled_SN
    ${expected_peer_BTS_reset_shared_FHS_RMOD_sn_list}=  Get From Dictionary  ${dependent_equipment_dict}
    ...  Equipment_reset_SN

    FOR  ${peer_alias}  IN  @{remaining_aliases}
        ${_dummy_peer_BTS_RM_alias_connection_dict}  ${_dummy_peer_BTS_shared_RM_id_sn_dict}
        ...  ${_dummy_peer_BTS_dedicated_RM_id_sn_dict}  ${peer_BTS_shared_RM_sn_id_dict}
        ...  ${_dummy_peer_BTS_dedicated_RM_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  RMOD  ${peer_alias}

        ${_dummy_peer_BTS_FHS_alias_connection_dict}  ${_dummy_peer_BTS_shared_FHS_id_sn_dict}
        ...  ${_dummy_peer_BTS_dedicated_FHS_id_sn_dict}  ${peer_BTS_shared_FHS_sn_id_dict}
        ...  ${_dummy_peer_BTS_dedicated_FHS_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  FHS  ${peer_alias}

        ${impacted_peer_equipment_id_dict}=  Create peer impacted FHS RMOD id dict
        ...  ${expected_peer_BTS_enabled_shared_FHS_RMOD_sn_list}
        ...  ${expected_peer_BTS_reset_shared_FHS_RMOD_sn_list}
        ...  ${peer_BTS_shared_RM_sn_id_dict}
        ...  ${peer_BTS_shared_FHS_sn_id_dict}

        ${dependent_peer_equipment_dict}  ${detailed_dependent_peer_equipment_dict}=  Get BTS equipment connected by Cablink
        ...  Source_equipment_id_dict=${impacted_peer_equipment_id_dict}
        ...  alias=${peer_alias}
        ...  Max_equipment_level=${Max_equipment_level}
        ...  Include_source_equipment=${True}
        ...  Reset_dependency_rules=${Reset_dependency_rules}
        ...  CPRI_SN_EXCEPTIONS=${CPRI_SN_EXCEPTIONS}  ECPRI_SN_EXCEPTIONS=${ECPRI_SN_EXCEPTIONS}
        ...  ECPRI_NETCONF_SN_EXCEPTIONS=${ECPRI_NETCONF_SN_EXCEPTIONS}  OBSAI_SN_EXCEPTIONS=${OBSAI_SN_EXCEPTIONS}
        ...  CB007447_EXCEPTIONS=${CB007447_EXCEPTIONS}
        ...  CB010846_EXCEPTIONS=${CB010846_EXCEPTIONS}  CB012446_EXCEPTIONS=${CB012446_EXCEPTIONS}

        ${condition_include_alias_dictionary}=  Create Long String
        ...  ${dependent_peer_equipment_dict['Equipment_enabled']} or
        ...  ${dependent_peer_equipment_dict['Equipment_disabled']} or
        ...  ${dependent_peer_equipment_dict['Equipment_reset']}
        Run Keyword If  ${condition_include_alias_dictionary}
        ...  Set To Dictionary  ${TL_detailed_equipment_dict}  ${peer_alias}=${detailed_dependent_peer_equipment_dict}
    END
    [Return]  ${TL_detailed_equipment_dict}

Get BTS equipment connected by Cablink
    [Documentation]
    ...  KW that returns RMODS and FHS connected to indicated source equipment
    ...  ${Source_equipment_id_dict} can contain Realtime DN of
    ...  BBMOD, SMOD, FHS, RMOD (any firstEndpointDN or secondEndpointDN of an optical fiber CABLINK)
    ...  KW will also return all equipment connected indirectly to source equipment (i.e. through other equipment)
    ...  Dictionary structure:
    ...  Equipment_enabled=[list of DNs] - equipment that is not reset, or disabled.
    ...  Equipment_disabled=[List of DNs] - equipment that is just disabled (1 of 2 M-plane links lost), not reset
    ...                                     (no impact on peer, if there is any peer BTS).
    ...  Equipment_reset=[List of DNS] - equipment that is reset
    ...                                  (impact on peer is expected depending on equipment type, if there is any peer BTS).
    ...
    ...  Level means number of intermediary equipment between source equipment and a certian detected equipment
    ...  Level 0 - directly connected (Source->x)
    ...  Level 1 - connected through other equipment (Source->FHS->x, Source->RMOD->x)
    ...  Level 2 - connected through 2 other equipments (Source->FHS-RMOD->x, Source->RMOD->RMOD->x)
    ...  etc
    ...
    ...  MAX_EQUIPMENT_LEVEL means how far the KW will go to detect equipment
    ...  connected to equipment from ${Source_equipment_id_dict}
    ...  The indicated level is the level at which teh algorithm stops
    ...  1 - only equipment dirrectly connected to equipment from ${Source_equipment_id_dict} is detected (level 0)
    ...  2 - 1 intermediary layer (FHS, or other RMOD). Eg. a chain of 2 RMOD (level 1) . The 3 rd RMOD in a chain will not be detected
    ...  3 - 2 intermediary layers (FHS, or other RMOD). Eg. a chain of 3 RMOD (level 2) . The 4 th RMOD in a chain will not be detected
    ...
    ...  Include_source_equipment - means equipment from ${Source_equipment_id_dict}
    ...  will be identified as type, l3protocol, sharing type, and included in output dictionary as well as the
    ...  equipment connected to it
    ...
    ...  Example of rules in hardware_variables.py:
    ...  cablink_type_triggering_shared_CPRI_RMOD_disabled - linkModeConfiguration
    ...                                                      when connected to another disabled or reset equipment
    ...  cablink_type_triggering_shared_RMOD_CPRI_reset - linkModeSynchronisation
    ...                                                   when connected to another reset equipment
    ...  cablink_type_triggering_dedicated_RMOD_CPRI_reset - linkModeConfiguration or linkModeSynchronization
    ...                                                      when connected to another reset equipment
    ...  cablink_type_triggering_FHS_disabled - linkModeConfiguration
    ...                                         when connected to another reset equipment
    ...  cablink_type_triggering_FHS_reset - linkModeSynchronisation
    ...                                      when connected to another reset equipment
    ...
    ...  Eample of equipment detected for shared CPRI equipment:
    ...  Reset equipment (BTS, with impact on BTS peer - due to equipment reset)
    ...           - Source eq reset -> sync link eq1 -> sync link eq2
    ...  Enabled eqipment
    ...           - Source eq enabled -> sync link eq1 -> conf link eq2
    ...           - Source eq enabled -> data link eq1 -> conf link eq2
    ...  Disabled equipment (only 1 of 2 Mplane links is lost, no equiment reset)
    ...           - Source eq reset -> conf link eq1 -> conf link eq2
    ...           - Source eq disabled -> conf link eq1 -> conf link eq2
    ...
    ...  *AUTHOR* valentin.marian@nokia.com
    ...
    ...  | Parameter                 | Man. | Default  | Description                                                                           |
    ...  | Source_equipment_id_dict  | Yes  |          | Dictionary containing source equipment separated into states                          |
    ...  | alias                     | Yes  |          | alias of admin instance on own BTS                                                    |
    ...  | Max_equipment_level       | No   |    5     | Number of indirect connection level where detection will stop.                        |
    ...  |                           |      |          | Set high enough so all equipment of BTS will be detected                              |
    ...  | Include_source_equipment  | No   | ${False} | alias of admin instance on own BTS                                                    |
    ...
    ...  *RETURN*
    ...
    ...  | Parameter                        | Description                                                                                           |
    ...  | destination_eq_dict              | Dictionary containing lists of Realtime DNs of Equipemnt_enabled, Equipment_disabled, Equipment_reset |
    ...  | detailed_destination_eq_dict     | Dictionary containing lists of Realtime DNs and SNs of Equipment separated by FHS/RMOD,               |
    ...  |                                  | CPRI/ECPRI/ECPRI_NETCONF/OBSAI, Enabled/Disabled/Reset

    [Arguments]   ${Source_equipment_id_dict}  ${alias}  ${Max_equipment_level}=${Max_equipment_level}
    ...  ${Include_source_equipment}=${False}
    ...  ${Reset_dependency_rules}=${Reset_dependency_rules}  ${CPRI_SN_EXCEPTIONS}=&{Empty}  ${ECPRI_SN_EXCEPTIONS}=&{Empty}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}=&{Empty}  ${OBSAI_SN_EXCEPTIONS}=&{Empty}
    ...  ${CB007447_EXCEPTIONS}=&{Empty}  ${CB010846_EXCEPTIONS}=&{Empty}  ${CB012446_EXCEPTIONS}=&{Empty}

    ${Empty_list}=  Create List
    ${Equipment_sync_link_lost}=  Get Variable Value  ${Equipment_sync_link_lost}  ${Empty_list}
    Set Test Variable  ${Equipment_sync_link_lost}

    ${CABLINK_R_info}=  coam.Get Managed Objects  class_name=CABLINK_R  connection=${alias}
    ${eq_dict_from_level}=  Validate Input  ${Source_equipment_id_dict}

    ${destination_eq_dict}=  Create Dictionary
    ${detailed_destination_eq_dict}=  Create Dictionary
    ${DN_parameters_correspondence_dict}=  Create Dictionary

    ${BTS_RM_alias_connection_dict}  ${BTS_shared_RM_id_sn_dict}  ${BTS_dedicated_RM_id_sn_dict}  ${BTS_shared_RM_sn_id_dict}
    ...  ${BTS_dedicated_RM_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  RMOD  ${alias}

    ${BTS_FHS_alias_connection_dict}  ${BTS_shared_FHS_id_sn_dict}  ${BTS_dedicated_FHS_id_sn_dict}  ${BTS_shared_FHS_sn_id_dict}
    ...  ${BTS_dedicated_FHS_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  FHS  ${alias}

    ${BTS_Module_info}=  Create Dictionary
    ...  Shared_RMOD=${BTS_shared_RM_id_sn_dict}
    ...  Dedicated_RMOD=${BTS_dedicated_RM_id_sn_dict}
    ...  Shared_FHS=${BTS_shared_FHS_id_sn_dict}
    ...  Dedicated_FHS=${BTS_dedicated_FHS_id_sn_dict}

    FOR  ${index}  IN RANGE  ${Max_equipment_level}
        ${eq_dict_from_level}  ${DN_parameters_correspondence_dict}=
        ...  Create Equipment Lists  alias=${alias}  CABLINK_R_info=${CABLINK_R_info}  BTS_module_info=${BTS_module_info}
        ...  DN_parameters_correspondence_dict=${DN_parameters_correspondence_dict}  PreviousLevel_equipment=${eq_dict_from_level}
        ...  Dependency_rule_dict=${Reset_dependency_rules}  EqLevel=${index}  Include_source_equipment=${Include_source_equipment}
        ...  CPRI_SN_EXCEPTIONS=${CPRI_SN_EXCEPTIONS}  ECPRI_SN_EXCEPTIONS=${ECPRI_SN_EXCEPTIONS}
        ...  ECPRI_NETCONF_SN_EXCEPTIONS=${ECPRI_NETCONF_SN_EXCEPTIONS}  OBSAI_SN_EXCEPTIONS=${OBSAI_SN_EXCEPTIONS}
        ...  CB007447_EXCEPTIONS=${CB007447_EXCEPTIONS}  CB010846_EXCEPTIONS=${CB010846_EXCEPTIONS}  CB012446_EXCEPTIONS=${CB012446_EXCEPTIONS}
        ${destination_eq_dict}=  Update Result Dictionary  ${destination_eq_dict}  ${eq_dict_from_level}

        ${exit condition}=  Create Long String
        ...  not(@{eq_dict_from_level['Equipment_enabled']}
        ...  or @{eq_dict_from_level['Equipment_disabled']}
        ...  or @{eq_dict_from_level['Equipment_reset']})

        Exit For Loop If  ${exit_condition}
    END

    ${detailed_destination_eq_dict}=  Add RMOD parameters to detailed equipment dict
    ...  ${destination_eq_dict}  ${ALL_DETAILED_EQUIPMENT_KEYS}  ${DN_parameters_correspondence_dict}
    ${destination_eq_dict}=  Add SN lists to dict  ${ALL_EQUIPMENT_KEYS}  ${destination_eq_dict}  ${BTS_module_info}

    [Return]    ${destination_eq_dict}  ${detailed_destination_eq_dict}

Get Combined List From Dictionary
    [Documentation]
    ...  KW used to retrieve from a dictionary,
    ...  values (lists) corresponding to multiple keys, merged into one list
    ...
    ...  *AUTHOR* valentin.marian@nokia.com
    ...
    ...  | Parameter   | Man. | Default  | Description                                                   |
    ...  | Input_dict  | Yes  |          | Dictionary from where information is read                     |
    ...  | Key_list    | Yes  |          | List of keys for which values are grouped into result_list    |
    ...
    ...  *RETURN*
    ...
    ...  | Parameter                        | Description                                                           |
    ...  | result_list                      | List containing all elements of lists corresponding to all input keys |

    [Arguments]    ${Input_dict}  @{Key_list}

    ${result_list}=  Create List
    FOR  ${key}  IN  @{Key_list}
        Append To List  ${result_list}  @{Input_dict['${key}']}
    END
    [Return]    ${result_list}

Create Equipment Lists
    [Documentation]
    ...  Helper Keyword which parses CABLINKS and generates
    ...  lists with Equipment connected directly to Equipment indicated in ${PreviousLevel_equipment}
    ...  All equipment returned by this KW is at 'same level' compared to input equipment

    [Arguments]  ${alias}  ${CABLINK_R_info}  ${BTS_module_info}  ${DN_parameters_correspondence_dict}
    ...  ${PreviousLevel_equipment}=&{Empty}  ${Dependency_rule_dict}=${Empty}
    ...  ${EqLevel}=${0}  ${Include_source_equipment}=${False}
    ...  ${CPRI_SN_EXCEPTIONS}=&{Empty}  ${ECPRI_SN_EXCEPTIONS}=&{Empty}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}=&{Empty}  ${OBSAI_SN_EXCEPTIONS}=&{Empty}
    ...  ${CB007447_EXCEPTIONS}=&{Empty}
    ...  ${CB010846_EXCEPTIONS}=&{Empty}  ${CB012446_EXCEPTIONS}=&{Empty}

    ${PreviousLevel_equipment_enabled}=  Get From Dictionary  ${PreviousLevel_equipment}  Equipment_enabled
    ${PreviousLevel_equipment_disabled}=  Get From Dictionary  ${PreviousLevel_equipment}  Equipment_disabled
    ${PreviousLevel_equipment_reset}=  Get From Dictionary  ${PreviousLevel_equipment}  Equipment_reset

    ${Current_level_equipment_enabled}=  Create List
    ${Current_level_equipment_disabled}=  Create List
    ${Current_level_equipment_reset}=  Create List

    ${Current_level_return}=  Create Dictionary

    FOR  ${current_cablink}  IN  @{CABLINK_R_info}
        ${Include_source_equipment}=  Evaluate  ${Include_source_equipment} and ${EqLevel}==${0}

        ${Equipment_enabled}  ${Equipment_disabled}  ${Equipment_reset}
        ...  ${Source_equipment_enabled}  ${Source_equipment_disabled}  ${Source_equipment_reset}
        ...  ${Equipment_sync_link_lost}
        ...  ${DN_parameters_correspondence_dict}=
        ...  Calculate equipment dependency
        ...  ${alias}  ${Include_source_equipment}  ${current_cablink}  ${BTS_module_info}  ${Dependency_rule_dict}
        ...  ${DN_parameters_correspondence_dict}
        ...  ${PreviousLevel_equipment_enabled}  ${PreviousLevel_equipment_disabled}  ${PreviousLevel_equipment_reset}
        ...  ${Equipment_sync_link_lost}
        ...  ${CPRI_SN_EXCEPTIONS}  ${ECPRI_SN_EXCEPTIONS}
        ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}  ${OBSAI_SN_EXCEPTIONS}
        ...  ${CB007447_EXCEPTIONS}  ${CB010846_EXCEPTIONS}  ${CB012446_EXCEPTIONS}

        ${new_node_found}=  Create Long String
        ...  ${Equipment_enabled} or ${Equipment_disabled} or ${Equipment_reset} or
        ...  ${Source_equipment_enabled} or ${Source_equipment_disabled} or ${Source_equipment_reset}

        Run Keyword If  ${new_node_found}
        ...  Remove Values From List  ${CABLINK_R_info}  ${current_cablink}
        ...  ELSE  Continue For Loop

        ${condition_enabled}=  Run Keyword If  ${Equipment_enabled}  Create Long String
        ...  '${Equipment_enabled[0]}' not in ${Current_level_equipment_enabled}
        ...  and '${Equipment_enabled[0]}' not in ${Current_level_equipment_disabled}
        ...  and '${Equipment_enabled[0]}' not in ${Current_level_equipment_reset}
        ...  ELSE  Set Variable  ${False}

        ${condition_disabled}=  Run Keyword If  ${Equipment_disabled}  Create Long String
        ...  '${Equipment_disabled[0]}' not in ${Current_level_equipment_disabled}
        ...  and '${Equipment_disabled[0]}' not in ${Current_level_equipment_reset}
        ...  ELSE  Set Variable  ${False}

        ${condition_reset}=  Run Keyword If  ${Equipment_reset}  Create Long String
        ...  '${Equipment_reset[0]}' not in ${Current_level_equipment_reset}
        ...  ELSE  Set Variable  ${False}

        Run Keyword If  ${condition_enabled}
        ...  Append To List  ${Current_level_equipment_enabled}  @{Equipment_enabled}

        Run Keyword If  ${condition_disabled}  Run Keywords
        ...  Append To List  ${Current_level_equipment_disabled}  @{Equipment_disabled}
        ...  AND  Remove Values From List  ${Current_level_equipment_enabled}  @{Equipment_disabled}

        Run Keyword If  ${condition_reset}  Run Keywords
        ...  Append To List  ${Current_level_equipment_reset}  @{Equipment_reset}
        ...  AND  Remove Values From List  ${Current_level_equipment_enabled}  @{Equipment_reset}
        ...  AND  Remove Values From List  ${Current_level_equipment_disabled}  @{Equipment_reset}

        ${condition_enabled_source}=  Run Keyword If  ${Source_equipment_enabled}
        ...  Create Long String  '${Source_equipment_enabled[0]}' not in ${Current_level_equipment_enabled}
        ...  and '${Source_equipment_enabled[0]}' not in ${Current_level_equipment_disabled}
        ...  and '${Source_equipment_enabled[0]}' not in ${Current_level_equipment_reset}
        ...  ELSE  Set Variable  ${False}

        ${condition_disabled_source}=  Run Keyword If  ${Source_equipment_disabled}
        ...  Create Long String  '${Source_equipment_disabled[0]}' not in ${Current_level_equipment_disabled}
        ...  and '${Source_equipment_disabled[0]}' not in ${Current_level_equipment_enabled}
        ...  and '${Source_equipment_disabled[0]}' not in ${Current_level_equipment_reset}
        ...  ELSE  Set Variable  ${False}

        ${condition_reset_source}=  Run Keyword If  ${Source_equipment_reset}
        ...  Create Long String  '${Source_equipment_reset[0]}' not in ${Current_level_equipment_reset}
        ...  and '${Source_equipment_reset[0]}' not in ${Current_level_equipment_enabled}
        ...  and '${Source_equipment_reset[0]}' not in ${Current_level_equipment_disabled}
        ...  ELSE  Set Variable  ${False}

        Run Keyword If  ${condition_enabled_source}
        ...  Append To List  ${Current_level_equipment_enabled}  @{Source_equipment_enabled}

        Run Keyword If  ${condition_disabled_source}
        ...  Append To List  ${Current_level_equipment_disabled}  @{Source_equipment_disabled}

        Run Keyword If  ${condition_reset_source}
        ...  Append To List  ${Current_level_equipment_reset}  @{Source_equipment_reset}

        Set Test Variable  ${Equipment_sync_link_lost}

    END

    Set To Dictionary  ${Current_level_return}
    ...  Equipment_enabled=${Current_level_equipment_enabled}
    ...  Equipment_disabled=${Current_level_equipment_disabled}
    ...  Equipment_reset=${Current_level_equipment_reset}

    [Return]  ${Current_level_return}  ${DN_parameters_correspondence_dict}

Calculate equipment dependency
    [Documentation]
    ...  Helper Keyword which parses one CABLINK info
    ...  and decides whether secondEndpointDN indicates
    ...  a node which is enabled
    ...  disabled (one of 2 M-plane lost)
    ...  or reset (all m-plane lost or sync lost in some cases)
    ...  according to rules provided by  ${Dependency_rule_dict}
    ...  and to connection to previous level equipment
    ...  KW will decide whether node needs to be added to an equipment list,
    ...  or moved from an equipment list to another
    ...  It will also decide based on ${Include_source_equipment}
    ...  whether Equipment for source node is retrieved from CABLINK

    [Arguments]  ${alias}  ${Include_source_equipment}  ${Cablink}  ${BTS_module_info}  ${Dependency_rule_dict}
    ...  ${DN_parameters_correspondence_dict}
    ...  ${PreviousLevel_equipment_enabled}=@{Empty}  ${PreviousLevel_equipment_disabled}=@{Empty}
    ...  ${PreviousLevel_equipment_reset}=@{Empty}  ${Equipment_sync_link_lost}=@{Empty}
    ...  ${CPRI_SN_EXCEPTIONS}=&{Empty}  ${ECPRI_SN_EXCEPTIONS}=&{Empty}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}=&{Empty}  ${OBSAI_SN_EXCEPTIONS}=&{Empty}
    ...  ${CB007447_EXCEPTIONS}=&{Empty}  ${CB010846_EXCEPTIONS}=&{Empty}  ${CB012446_EXCEPTIONS}=&{Empty}

    ${rule_dictionary_sync_link_lost}=  Create Dictionary  linkModeSynchronization=True

    ${Equipment_enabled}=  Create List
    ${Equipment_disabled}=  Create List
    ${Equipment_reset}=  Create List

    ${Source_equipment_enabled}=  Create List
    ${Source_equipment_disabled}=  Create List
    ${Source_equipment_reset}=  Create List

    ${cablink_unuseful}=  Check Cablink Unuseful  ${Cablink}  ${BTS_module_info}
    Return From Keyword If  ${cablink_unuseful}
    ...  ${Equipment_enabled}  ${Equipment_disabled}  ${Equipment_reset}
    ...  ${Source_equipment_enabled}  ${Source_equipment_disabled}  ${Source_equipment_reset}
    ...  ${Equipment_sync_link_lost}
    ...  ${DN_parameters_correspondence_dict}

    ${equipmentDN}=  Set Variable  ${cablink['parameters']['secondEndpointDN']}
    ${parent_equipmentDN}=  Set Variable  ${cablink['parameters']['firstEndpointDN']}
    ${rule_dictionary_enabled_source}  ${rule_dictionary_disabled_source}  ${rule_dictionary_reset_source}
    ...  ${equipment_type_source}  ${sharing_source}   ${equipment_l3_protocol_source}  ${module_parameters}=
    ...  Run Keyword If  ${Include_source_equipment}
    ...  Select Dependency Rule  ${Cablink}  ${BTS_module_info}  ${Dependency_rule_dict}  ${alias}
    ...  ${CPRI_SN_EXCEPTIONS}  ${ECPRI_SN_EXCEPTIONS}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}  ${OBSAI_SN_EXCEPTIONS}
    ...  ${CB010846_EXCEPTIONS}  ${CB012446_EXCEPTIONS}

    ${condition_enabled_source}=  Evaluate
    ...  ('${equipmentDN}' in ${PreviousLevel_equipment_enabled} and ${Include_source_equipment})
    ${condition_disabled_source}=  Evaluate
    ...  ('${equipmentDN}' in ${PreviousLevel_equipment_disabled} and ${Include_source_equipment})
    ${condition_reset_source}=  Evaluate
    ...  ('${equipmentDN}' in ${PreviousLevel_equipment_reset} and ${Include_source_equipment})
    ${condition_sync_link_lost_source}=  Run Keyword If  ${Include_source_equipment}
    ...  Create Long String  (${condition_reset_source}) and
    ...  ${Include_source_equipment} and '${module_parameters}[SN]' in ${Equipment_sync_link_lost}
    ...  ELSE  Set Variable  ${False}

    Run Keyword If  ${Include_source_equipment} and ${condition_reset_source}
    ...  Append to list  ${Source_equipment_reset}  ${equipmentDN}
    ...  ELSE IF  ${Include_source_equipment} and ${condition_disabled_source}
    ...  Append to list  ${Source_equipment_disabled}  ${equipmentDN}
    ...  ELSE IF  ${Include_source_equipment} and ${condition_enabled_source}
    ...  Append to list  ${Source_equipment_enabled}  ${equipmentDN}

    IF  ${Include_source_equipment} and ${condition_sync_link_lost_source}
        Set To Dictionary  ${module_parameters}  sync_link_lost  True
        Append To List  ${Equipment_sync_link_lost}  ${module_parameters}[SN]
        Remove Duplicates  ${Equipment_sync_link_lost}
    END
    ${rule_dictionary_enabled}  ${rule_dictionary_disabled}  ${rule_dictionary_reset}
    ...  ${equipment_type}  ${sharing}  ${equipment_l3_protocol}  ${module_parameters}=
    ...  Select Dependency Rule  ${Cablink}  ${BTS_module_info}  ${Dependency_rule_dict}  ${alias}
    ...  ${CPRI_SN_EXCEPTIONS}  ${ECPRI_SN_EXCEPTIONS}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}  ${OBSAI_SN_EXCEPTIONS}  ${CB007447_EXCEPTIONS}
    ...  ${CB010846_EXCEPTIONS}  ${CB012446_EXCEPTIONS}
    ${condition_reset_link_type}=  Create Rule Expression  ${rule_dictionary_reset}  ${Cablink['parameters']}
    ${condition_enabled_link_type}=  Create Rule Expression  ${rule_dictionary_enabled}  ${Cablink['parameters']}
    ${condition_disabled_link_type}=  Create Rule Expression  ${rule_dictionary_disabled}  ${Cablink['parameters']}
    ${condition_sync_link_lost}=  Create Rule Expression  ${rule_dictionary_sync_link_lost}  ${Cablink['parameters']}

    ${condition_reset}=  Catenate  SEPARATOR=${SPACE}  ${condition_reset_link_type}  and
    ...  ('${parent_equipmentDN}' in ${PreviousLevel_equipment_reset})

    ${condition_enabled}=  Catenate  SEPARATOR=${SPACE}  ((${condition_enabled_link_type}  and
    ...  (('${parent_equipmentDN}' in ${PreviousLevel_equipment_enabled})
    ...  or ('${parent_equipmentDN}' in ${PreviousLevel_equipment_reset})
    ...  or ('${parent_equipmentDN}' in ${PreviousLevel_equipment_disabled})))
    ...  or (${condition_disabled_link_type}  and
    ...  ('${parent_equipmentDN}' in ${PreviousLevel_equipment_enabled}))
    ...  or (${condition_reset_link_type}  and
    ...  ('${parent_equipmentDN}' in ${PreviousLevel_equipment_enabled})))

    ${condition_disabled}=  Catenate  SEPARATOR=${SPACE}  (${condition_disabled_link_type}  and
    ...  ('${parent_equipmentDN}' in ${PreviousLevel_equipment_reset}
    ...  or '${parent_equipmentDN}' in ${PreviousLevel_equipment_disabled})
    ...  or (${condition_reset_link_type}  and
    ...  ('${parent_equipmentDN}' in ${PreviousLevel_equipment_disabled})))

    ${condition_sync_link_lost}=  Catenate  SEPARATOR=${SPACE}  ${condition_sync_link_lost}
    ...  and (${condition_enabled} or ${condition_disabled} or ${condition_reset})
    ...  and '${parent_equipmentDN}' in ${PreviousLevel_equipment_reset}

    Run Keyword If  ${condition_reset}  Run Keywords
    ...  Append to list  ${Equipment_reset}  ${equipmentDN}
    ...  AND  Remove Values From List  ${Source_equipment_enabled}  ${equipmentDN}
    ...  AND  Remove Values From List  ${Source_equipment_disabled}  ${equipmentDN}
    ...  ELSE IF  ${condition_disabled} and '${equipmentDN}' not in ${Source_equipment_reset}  Run Keywords
    ...  Append to list  ${Equipment_disabled}  ${equipmentDN}
    ...  AND  Remove Values From List  ${Source_equipment_enabled}  ${equipmentDN}
    ...  ELSE IF  ${condition_enabled} and '${equipmentDN}' not in ${Source_equipment_reset}  Run Keywords
    ...  Append to list  ${Equipment_enabled}  ${equipmentDN}
    ...  AND  Remove Values From List  ${Source_equipment_disabled}  ${equipmentDN}

    IF  ${condition_sync_link_lost} or '${module_parameters}[SN]' in ${Equipment_sync_link_lost}
        Set To Dictionary  ${module_parameters}  sync_link_lost  True
    END
    IF  ${condition_sync_link_lost}
        Append To List  ${Equipment_sync_link_lost}  ${module_parameters}[SN]
        Remove Duplicates  ${Equipment_sync_link_lost}
    END
    ${condition_save_module_details}=  Create Long String
    ...  ${condition_reset} or ${condition_disabled} or ${condition_enabled} or
    ...  ((${condition_reset_source} or ${condition_disabled_source} or ${condition_enabled_source})
    ...  and '${equipment_DN}' not in ${DN_parameters_correspondence_dict})
    IF  ${condition_save_module_details}
        Set To Dictionary  ${DN_parameters_correspondence_dict}  ${equipmentDN}=${module_parameters}
    END

    [Return]    ${Equipment_enabled}  ${Equipment_disabled}  ${Equipment_reset}
    ...  ${Source_equipment_enabled}  ${Source_equipment_disabled}  ${Source_equipment_reset}
    ...  ${Equipment_sync_link_lost}
    ...  ${DN_parameters_correspondence_dict}

Select Dependency Rule
    [Documentation]
    ...  Helper Keyword which selects from hardware_variables.py
    ...  the rule by which current equipment behavior is calculated (remain enabled,
    ...  become disabled for current BTS, or perform reset based on
    ...  linkModeConfiguration and linkModeSynchronization)
    ...  Kw will also return for current equipment
    ...  Equipment type - RMOD / FHS
    ...  Sharing type - SHARED / DEDICATED
    ...  L3 protocol in friendly name - CPRI, ECPRI, ECPRI_NETCONF, OBSAI
    ...  Rule - 1st element of dependency rule tuple which was applied

    [Arguments]  ${cablink}  ${BTS_module_info}  ${Dependency_rule_dict}  ${alias}
    ...  ${CPRI_SN_EXCEPTIONS}  ${ECPRI_SN_EXCEPTIONS}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}  ${OBSAI_SN_EXCEPTIONS}
    ...  ${CB007447_EXCEPTIONS}=${Empty}  ${CB010846_EXCEPTIONS}=${Empty}  ${CB012446_EXCEPTIONS}=${Empty}

    ${CB007447_exception_sns}=  Get Variable Value  ${CB007447_EXCEPTIONS['exception_for_CB007447_eligible']}  ${Space}
    ${CB010846_exception_sns}=  Get Variable Value  ${CB010846_EXCEPTIONS['exception_for_CB010846_eligible']}  ${Space}
    ${CB012446_exception_sns}=  Get Variable Value  ${CB012446_EXCEPTIONS['exception_for_CB012446_eligible']}  ${Space}

    ${equipmentDN}=  Set Variable  ${cablink['parameters']['secondEndpointDN']}
    ${equipmentDN_parts}=  Get Regexp Matches  ${equipmentDN}  /([A-Z]+)_  1
    ${equipment_type}=  Set Variable  ${equipmentDN_parts[-1]}

    ${source_equipment_list}=  Create List  BBMOD  FHS  RMOD
    ${module_connected_in}=  Set Variable  ${None}
    FOR  ${source}  IN  @{source_equipment_list}
        ${module_connected_in}=  Set Variable If  '${source}' in '${cablink['parameters']['firstEndpointDN']}'
        ...  ${source}  ${module_connected_in}
        Exit For Loop If  '${module_connected_in}' != '${None}'
    END

    ${dedicated_module_dict}=  Get From Dictionary  ${BTS_module_info}  Dedicated_${equipment_type}
    ${dedicated_module_DN_list}=  Get Dictionary Keys  ${dedicated_module_dict}
    ${sharing}=  Set Variable If  '${equipment_DN}' in ${dedicated_module_DN_list}  DEDICATED  SHARED

    ${protocol_friendly_name_dict}=  Create Dictionary  EthLink=ECPRI  CPRILink=CPRI  RP3_01Link=OBSAI
    ${l3protocol}=  Set Variable  ${protocol_friendly_name_dict['${cablink['parameters']['cablinkType']}']}
    ${l3protocol}=  Detect ORAN RMOD  ${alias}  ${equipmentDN}  ${l3protocol}
    ${rule_appendix_for_module_connected_in_fhs}=  Set Variable If  '${module_connected_in}' == 'FHS' and '${l3protocol}'=='CPRI'
    ...  _IN_${module_connected_in}  ${Empty}
    ${l3protocol_tuple}=  Evaluate  ('${l3protocol}${rule_appendix_for_module_connected_in_fhs}', )

    ${MOD_param_list}=  Get Parameters For  ${equipment_type}  ${equipmentDN}  alias=${alias}
    ${module_product_name}=  Set Variable  ${MOD_param_list['productName']}
    ${buildVersion_present}=  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${MOD_param_list}  buildVersion

    ${regexp}=  Set Variable  (([a-zA-Z]+[0-9]+)|([0-9]+[a-zA-Z]+))
    ${module_sw_strings}=  Run Keyword If  '${buildVersion_present}'=='True'
    ...  Get Regexp Matches  ${MOD_param_list['buildVersion']}  ${regexp}
    ...  ELSE  Create List  not_found
    ${module_variants_from_rules_dict}=  Get Dictionary Keys  ${Dependency_rule_dict['${sharing}_${equipment_type}']}

    FOR  ${key}  IN  @{module_variants_from_rules_dict}
        ${sw_string_found}=  Evaluate  any(t.lower() in ${key} for t in @{module_sw_strings})
        ${product_name_found}=  Evaluate  '${moduleProductName}' in ${key}
        Exit For Loop If  ${sw_string_found} or ${product_name_found}
    END
    ${l3protocol_tuple}=  Set Variable If  ${sw_string_found} or ${product_name_found}  ${key}  ${l3protocol_tuple}

    ${MOD_sn}=  Get Variable Value  ${MOD_param_list['serialNumber']}  ${None}

    ${CB007447_eligible}=  Create Long String
    ...  'RMOD' in '${equipmentDN}' and '${MOD_sn}' not in '${CB007447_exception_sns}'
    ...  and  '${l3protocol}' == 'CPRI'
    ${CB007447_eligible}=  Evaluate  ${CB007447_eligible}

    ${sw_string_found}=  Evaluate  any(t.upper() in ${RMOD_CB010846_exceptions} for t in @{module_sw_strings})
    ${CB010846_eligible}=  Create Long String
    ...  not ${sw_string_found} and 'RMOD' in '${equipmentDN}' and '${MOD_sn}' not in '${CB010846_exception_sns}'
    ...  and '${l3protocol}' in ['CPRI', 'ECPRI']
    ${CB010846_eligible}=  Evaluate  ${CB010846_eligible}

    ${sw_string_found}=  Evaluate  any(t.upper() in ${RMOD_CB012446_exceptions} for t in @{module_sw_strings})
    ${CB012446_eligible}=  Create Long String
    ...  not ${sw_string_found} and 'RMOD' in '${equipmentDN}' and '${MOD_sn}' not in '${CB012446_exception_sns}'
    ...  and  '${l3protocol}' in ['CPRI', 'ECPRI']
    ${CB012446_eligible}=  Evaluate  ${CB012446_eligible}

    # We set sync_link_lost to a default value, and update it in parent KW depending on cablink type
    ${sync_link_lost}=  Set Variable  ${False}

    ${rule_name}=  Select Dependency Rule If Forced By SN  ${MOD_SN}  ${CPRI_SN_EXCEPTIONS}  ${ECPRI_SN_EXCEPTIONS}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}  ${OBSAI_SN_EXCEPTIONS}
    ...  ${sharing}

    ${rule_list}=  Run Keyword If  ${rule_name}
    ...  Create List  ${sharing}_${equipment_type}  ${rule_name}
    ...  ELSE  Create List  ${sharing}_${equipment_type}  ${l3protocol_tuple}

    ${module_parameters}=  Create Dictionary
    ...  sharing=${sharing}
    ...  equipment_type=${equipment_type}
    ...  l3protocol=${l3protocol}
    ...  SN=${MOD_sn}
    ...  rules=${rule_list[${1}]}
    ...  connected_in=${module_connected_in}
    ...  CB007447_eligible=${CB007447_eligible}
    ...  CB010846_eligible=${CB010846_eligible}
    ...  CB012446_eligible=${CB012446_eligible}
    ...  sync_link_lost=${sync_link_lost}

    Return From Keyword
    ...  ${Dependency_rule_dict['${rule_list[${0}]}'][${rule_list[${1}]}]['enabled']}
    ...  ${Dependency_rule_dict['${rule_list[${0}]}'][${rule_list[${1}]}]['disabled']}
    ...  ${Dependency_rule_dict['${rule_list[${0}]}'][${rule_list[${1}]}]['reset']}
    ...  ${equipment_type}
    ...  ${sharing}
    ...  ${l3protocol}
    ...  ${module_parameters}

Create Rule Expression
    [Documentation]
    ...  Helper Keyword which creates a logical expressionfrom a rule dictionary
    ...  as provided in hardware_variables.py

    [Arguments]  ${rule_dictionary}  ${cablink_dictionary}

    Run Keyword If  not ${rule_dictionary}
    ...  Return From Keyword  ${False}

    ${rule_expression}=  Set Variable
    ${rule_dictionary_keys}=  Get Dictionary Keys  ${rule_dictionary}
    ${status}  ${relation}=  Run Keyword And Ignore Error  Get From Dictionary  ${rule_dictionary}  relation
    ${relation}=  Set Variable If  '${status}'=='PASS'  ${relation}  or
    Run Keyword If  '${status}'=='PASS'  Remove Values From List  ${rule_dictionary_keys}  relation

    FOR  ${key}  IN  @{rule_dictionary_keys}
        ${rule_expression}=  Catenate  SEPARATOR=  ${rule_expression}
        ...  '${cablink_dictionary['${key}']}'=='${rule_dictionary['${key}']}'
        ${rule_expression}=  Run Keyword If  '${key}'!='${rule_dictionary_keys[-1]}'
        ...  Catenate  SEPARATOR=  ${rule_expression}  ${SPACE}${relation}${SPACE}
        ...  ELSE  Set Variable  ${rule_expression}
    END
    ${rule_expression}=  Evaluate  ${rule_expression}
    [Return]  ${rule_expression}

Check Cablink Unuseful
    [Arguments]  ${cablink}  ${BTS_module_info}
    ${skip_cablink}=  Create Long String
    ...  '${cablink['parameters']['secondEndpointLabel']}'=='BACKPLANE'
    ...  or '${cablink['parameters']['firstEndpointLabel']}'=='BACKPLANE'
    ...  or '${cablink['parameters']['cablinkType']}'=='None'
    ...  or 'EXT' in '${cablink['parameters']['firstEndpointDN']}'
    Return From Keyword If  ${skip_cablink}  ${True}

    ${module_types}=  Get Dictionary Keys  ${BTS_module_info}
    ${cablink_endpoint_not_found}=  Set Variable  ${True}
    FOR  ${module_type}  IN  @{module_types}
        ${DNs}=  Get Dictionary Keys  ${BTS_module_info['${module_type}']}
        ${cablink_endpoint_not_found}=  Set Variable If  '${cablink['parameters']['secondEndpointDN']}' in ${DNs}
        ...  ${False}  ${cablink_endpoint_not_found}
        Exit For Loop If  not ${cablink_endpoint_not_found}
    END
    Return From Keyword If  ${cablink_endpoint_not_found}  ${True}

    [Return]  ${False}

Select Dependency Rule If Forced By SN
    [Arguments]    ${MOD_SN}  ${CPRI_SN_EXCEPTIONS}  ${ECPRI_SN_EXCEPTIONS}
    ...  ${ECPRI_NETCONF_SN_EXCEPTIONS}  ${OBSAI_SN_EXCEPTIONS}  ${sharing}

    ${cpri_sns}=  Get Dictionary Keys  ${CPRI_SN_EXCEPTIONS}
    ${ecpri_sns}=  Get Dictionary Keys  ${ECPRI_SN_EXCEPTIONS}
    ${ECPRI_NETCONF_sns}=  Get Dictionary Keys  ${ECPRI_SN_EXCEPTIONS}
    ${obsai_sns}=  Get Dictionary Keys  ${OBSAI_SN_EXCEPTIONS}
    ${protocol_from_forced}=  Create List
    Return From Keyword If  not (${cpri_sns} or ${ecpri_sns} or ${ECPRI_NETCONF_sns} or ${obsai_sns})  ${protocol_from_forced}

    FOR  ${key}  IN  @{cpri_sns}
       ${protocol_from_forced}=  Set Variable If  '${MOD_SN}' in '${key}' and '${sharing}' in '${CPRI_SN_EXCEPTIONS['${key}'][${0}]}'
       ...  ${CPRI_SN_EXCEPTIONS['${key}'][${1}]}  ${protocol_from_forced}
       Exit For Loop If  ${protocol_from_forced}
    END
    FOR  ${key}  IN  @{ecpri_sns}
       Exit For Loop If  ${protocol_from_forced}
       ${protocol_from_forced}=  Set Variable If  '${MOD_SN}' in '${key}' and '${sharing}' in '${ECPRI_SN_EXCEPTIONS['${key}'][${0}]}'
       ...  ${ECPRI_SN_EXCEPTIONS['${key}'][${1}]}  ${protocol_from_forced}
       Exit For Loop If  ${protocol_from_forced}
    END
    FOR  ${key}  IN  @{ECPRI_NETCONF_sns}
       Exit For Loop If  ${protocol_from_forced}
       ${protocol_from_forced}=  Set Variable If  '${MOD_SN}' in '${key}' and '${sharing}' in '${ECPRI_NETCONF_SN_EXCEPTIONS['${key}'][${0}]}'
       ...  ${ECPRI_NETCONF_SN_EXCEPTIONS['${key}'][${1}]}  ${protocol_from_forced}
       Exit For Loop If  ${protocol_from_forced}
    END
    FOR  ${key}  IN  @{obsai_sns}
       Exit For Loop If  ${protocol_from_forced}
       ${protocol_from_forced}=  Set Variable If  '${MOD_SN}' in '${key}' and '${sharing}' in '${OBSAI_SN_EXCEPTIONS['${key}'][${0}]}'
       ...  ${OBSAI_SN_EXCEPTIONS['${key}'][${1}]}  ${protocol_from_forced}
       Exit For Loop If  ${protocol_from_forced}
    END

    [Return]    ${protocol_from_forced}

Detect ORAN RMOD
    [Arguments]  ${alias}  ${equipmentDN}  ${l3protocol}
    ${is_oran_module}=  Set Variable  ${False}
    ${scf_exported}=  Set Variable  ${False}

    IF  'RMOD' in '${equipmentDN}' and '${l3protocol}'=='ECPRI'
        IF  not ${scf_exported}
            Get Current Scf File  local_dir_path=${BTSFiles}/SCF_temp  file_name=SCF_temp.xml  connection=${alias}
            ...  export_type=configurationAndRuntimeObjects  with_auto_configured_parameters=${TRUE}
            ${scf_exported}=  Set Variable  ${True}
        END
        ${RMOD_conf_dn}=  Get RMOD SCF Distinguished Name  ${equipmentDN}  ${alias}
        ${MOD_config_param_dict}  ${_}=  Get Object Attributes Values From Scf  scf_path=${BTSFiles}/SCF_temp/SCF_temp.xml
        ...  dist_name=${RMOD_conf_dn}  p_name=protocol
        ${is_oran_module}=  Run Keyword And Return Status  Should Be Equal  ${MOD_config_param_dict['protocol']}  O-RAN
    END
    ${result}=  Set Variable If  ${is_oran_module}  ECPRI_NETCONF  ${l3protocol}
    [Return]  ${result}

Add SN lists to dict
    [Arguments]  ${equipment_keys}  ${equipment_dict}  ${BTS_module_info}

    ${Shared_RMOD}=  Get From Dictionary  ${BTS_module_info}  Shared_RMOD
    ${Shared_FHS}=  Get From Dictionary  ${BTS_module_info}  Shared_FHS
    ${Dedicated_RMOD}=  Get From Dictionary  ${BTS_module_info}  Dedicated_RMOD
    ${Dedicated_FHS}=  Get From Dictionary  ${BTS_module_info}  Dedicated_FHS
    ${all_modules_info}=  Create Dictionary  &{Shared_RMOD}  &{Shared_FHS}  &{Dedicated_RMOD}  &{Dedicated_FHS}

    FOR  ${key}  IN  @{equipment_keys}
        ${SN_list}=  Create SN list  ${equipment_dict['${key}']}  ${all_modules_info}
        Set To Dictionary  ${equipment_dict}  ${key}_SN=${SN_list}
    END
    [Return]  ${equipment_dict}

Add RMOD parameters to detailed equipment dict
    [Arguments]  ${equipment_dict}  ${equipment_keys_list}  ${DN_parameters_correspondence_dict}  ${string_of_equipment_details}=${Empty}

    ${detailed_equipment_dict}=  Create Dictionary
    FOR  ${key}  IN  @{equipment_keys_list}
        ${detailed_equipment_dict}=  Create empty RMOD parameters lists for detailed Equipment Key
        ...  ${key}  ${detailed_equipment_dict}  ${string_of_equipment_details}
    END

    ${equipment_dict_keys}=  Get Dictionary Keys  ${equipment_dict}
    FOR  ${key}  IN  @{equipment_dict_keys}
        ${detailed_dictionary_partial}=  Create detailed equipment dict
        ...  ${key}  ${equipment_dict['${key}']}  ${DN_parameters_correspondence_dict}  ${string_of_equipment_details}
        ${detailed_equipment_dict}=  Update Result Dictionary  ${detailed_equipment_dict}  ${detailed_dictionary_partial}
    END
    [Return]    ${detailed_equipment_dict}

Create empty RMOD parameters lists for detailed Equipment Key
    [Arguments]    ${key}  ${detailed_equipment_dict}  ${string_of_equipment_details}=${Empty}

    FOR  ${parameter}  IN  @{DETAILED_EQUIPMENT_PARAMETERS}
       Continue For Loop If  '${string_of_equipment_details}' and '${parameter}' not in '${string_of_equipment_details}'
       ${new_list}=  Create List
       ${key_name_suffix}=  Set Variable If  '${parameter}'=='DN'  ${Empty}  _${parameter}
       Set To Dictionary  ${detailed_equipment_dict}  ${key}${key_name_suffix}=${new_list}
    END
    [Return]    ${detailed_equipment_dict}

Update Result Dictionary
    [Documentation]
    ...  Helper Keyword which updates the lists corresponding to each key
    ...  of a target dictionary, by adding elements from lists of a source dictionary
    ...  to them. In case a key is missing from target dictionary, it will be added together with
    ...  values list from source dictionary
    ...  Both dictionaries need to have the same desired key structure

    [Arguments]  ${Destination_dict}  ${Source_dict}

    ${source_keys}=  Get Dictionary Keys  ${Source_dict}
    FOR  ${key}  IN  @{source_keys}
       ${key_not_present}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${Destination_dict}  ${key}
       Run Keyword If  ${key_not_present}  Run Keywords
       ...  Set To Dictionary  ${Destination_dict}  ${key}=${Source_dict['${key}']}
       ...  AND  Continue For Loop
       ${Destination_dict}=  Add new data to dict
       ...  ${key}  ${Source_dict['${key}']}  ${Destination_dict}
    END
    [Return]  ${Destination_dict}

Add new data to dict
    [Arguments]  ${key_indicating_behavior}  ${Source_equipment_list}  ${Destination_equipment_dict}

    ${destination_eq_list}=  Pop From Dictionary  ${Destination_equipment_dict}  ${key_indicating_behavior}
    Append To List  ${destination_eq_list}  @{Source_equipment_list}

    Set To Dictionary  ${Destination_equipment_dict}
    ...  ${key_indicating_behavior}=${destination_eq_list}
    [Return]  ${Destination_equipment_dict}

Create SN list
    [Arguments]  ${DN_list}  ${all_modules_DN_SN_dict}

    ${SN_list}=  Create List
    FOR  ${DN_item}  IN  @{DN_list}
        Append To List  ${SN_list}  ${all_modules_DN_SN_dict['${DN_item}']}
    END
    [Return]    ${SN_list}

Create detailed equipment dict
    [Arguments]  ${Key}  ${DN_list}  ${DN_parameters_correspondence_dict}  ${string_of_equipment_details}=${Empty}

    ${list_names}=  Create List
    ${detailed_equipment_dictionary}=  Create Dictionary
    FOR  ${DN_item}  IN  @{DN_list}
        ${current_DN_item_parameters}=  Get From Dictionary  ${DN_parameters_correspondence_dict}  ${DN_item}
        ${sharing}=  Set Variable  ${current_DN_item_parameters['sharing']}
        ${equipment_type}=  Set Variable  ${current_DN_item_parameters['equipment_type']}
        ${l3protocol}=  Set Variable  ${current_DN_item_parameters['l3protocol']}

        ${equipment_expected_state}=  Fetch From Right  ${Key}  _
        ${DN_list_name}=  Set Variable  ${sharing}_${equipment_type}_${l3protocol}_${equipment_expected_state}
        ${DN_list_name2}=  Set Variable If  '${equipment_expected_state}'=='reset'
        ...  ${sharing}_${equipment_type}_${l3protocol}_disabled  ${None}

        ${Empty_DN_list}=  Create List
        ${DN_list}=  Pop From Dictionary  ${detailed_equipment_dictionary}  ${DN_list_name}  ${Empty_DN_list}
        Append To List  ${DN_list}  ${DN_item}
        Set To Dictionary  ${detailed_equipment_dictionary}  ${DN_list_name}=${DN_list}

        IF  '${equipment_expected_state}'=='reset'
            ${Empty_DN_list2}=  Create List
            ${DN_list2}=  Pop From Dictionary  ${detailed_equipment_dictionary}  ${DN_list_name2}  ${Empty_DN_list2}
            Append To List  ${DN_list2}  ${DN_item}
            Set To Dictionary  ${detailed_equipment_dictionary}  ${DN_list_name2}=${DN_list2}
        END
        ${detailed_equipment_dictionary}=  Create module lists based on module parameters
        ...  ${current_DN_item_parameters}  ${DN_list_name}  ${DN_list_name2}
        ...  ${detailed_equipment_dictionary}  ${equipment_expected_state}  ${string_of_equipment_details}

    END
    [Return]    ${detailed_equipment_dictionary}

Create module lists based on module parameters
    [Arguments]    ${current_DN_item_parameters}  ${DN_list_name}  ${DN_list_name2}
    ...  ${detailed_equipment_dictionary}  ${equipment_expected_state}  ${string_of_equipment_details}=${Empty}

    ${module_detail_list}=  Get Dictionary Keys  ${current_DN_item_parameters}
    Remove Values From List  ${module_detail_list}  sharing  equipment_type  l3protocol

    FOR  ${detail_key}  IN  @{module_detail_list}
        Continue For Loop If  '${string_of_equipment_details}' and '${detail_key}' not in '${string_of_equipment_details}'
        ${empty_detail_value_list}=  Create List
        ${empty_detail_value_list2}=  Create List
        ${detail_value}=  Get Variable Value  ${current_DN_item_parameters['${detail_key}']}  '${None}'
        ${detail_list_name}=  Set Variable  ${DN_list_name}_${detail_key}
        ${detail_list_name2}=  Set Variable  ${DN_list_name2}_${detail_key}
        ${detail_value_list}=  Pop From Dictionary  ${detailed_equipment_dictionary}  ${detail_list_name}  ${empty_detail_value_list}
        ${detail_value_list2}=  Pop From Dictionary  ${detailed_equipment_dictionary}  ${detail_list_name2}  ${empty_detail_value_list2}
        Append To List  ${detail_value_list}  ${detail_value}
        Append To List  ${detail_value_list2}  ${detail_value}
        Set To Dictionary  ${detailed_equipment_dictionary}  ${detail_list_name}=${detail_value_list}
        Run Keyword If  '${equipment_expected_state}'=='reset'
        ...   Set To Dictionary  ${detailed_equipment_dictionary}  ${detail_list_name2}=${detail_value_list2}
    END
    [Return]    ${detailed_equipment_dictionary}

Filter RMOD depending on feature
    [Arguments]    ${elements_to_be_filtered}  ${list1_containing_filtering_criteria_flags}
    ...  ${list2_containing_filtering_criteria_flags}=@{Empty}   ${list3_containing_filtering_criteria_flags}=@{Empty}

    ${result_list}=  Create List

    FOR  ${index}  ${item}  IN ENUMERATE  @{elements_to_be_filtered}
        ${element1}=  Get Variable Value  ${list1_containing_filtering_criteria_flags[${index}]}  ${True}
        ${element2}=  Get Variable Value  ${list2_containing_filtering_criteria_flags[${index}]}  ${True}
        ${element3}=  Get Variable Value  ${list3_containing_filtering_criteria_flags[${index}]}  ${True}

        Run Keyword If  ${element1} and ${element2} and ${element3}
        ...  Append To List  ${result_list}  ${item}
    END
    [Return]    ${result_list}

Validate Input
    [Documentation]
    ...  Helper Keyword which adds missing keys and empty lists for them
    ...  to input dictionary of KW  Get BTS equipment connected by Cablink

    [Arguments]  ${Source_equipment_id_dict}

    ${keys}=  Get Dictionary Keys  ${Source_equipment_id_dict}
    ${expected_keys}=  Create List  @{ALL_EQUIPMENT_KEYS}
    Remove Values From List  ${expected_keys}  @{keys}
    FOR  ${key}  IN  @{expected_keys}
        ${missing_list}=  Create List
        Set To Dictionary  ${Source_equipment_id_dict}  ${key}  ${missing_list}
    END
    [Return]    ${Source_equipment_id_dict}

Create peer impacted FHS RMOD id dict
    [Arguments]  ${expected_peer_BTS_enabled_shared_FHS_RMOD_sn_list}  ${expected_peer_BTS_reset_shared_FHS_RMOD_sn_list}
    ...  ${peer_BTS_shared_RM_sn_id_dict}  ${peer_BTS_shared_FHS_sn_id_dict}

    ${peer_BTS_shared_FHS_RM_sn_id_dict}=  Create Dictionary  &{peer_BTS_shared_RM_sn_id_dict}  &{peer_BTS_shared_FHS_sn_id_dict}
    ${peer_BTS_enabled_id_list}=  Create List
    FOR  ${item_sn}  IN  @{expected_peer_BTS_enabled_shared_FHS_RMOD_sn_list}
        ${item_present_in_peer}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${peer_BTS_shared_FHS_RM_sn_id_dict}  ${item_sn}
        Run Keyword If  ${item_present_in_peer}
        ...  Append To List  ${peer_BTS_enabled_id_list}  ${peer_BTS_shared_FHS_RM_sn_id_dict['${item_sn}']}
    END
    ${peer_BTS_reset_id_list}=  Create List
    FOR  ${item_sn}  IN  @{expected_peer_BTS_reset_shared_FHS_RMOD_sn_list}
        ${item_present_in_peer}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${peer_BTS_shared_FHS_RM_sn_id_dict}  ${item_sn}
        Run Keyword If  ${item_present_in_peer}
        ...  Append To List  ${peer_BTS_reset_id_list}  ${peer_BTS_shared_FHS_RM_sn_id_dict['${item_sn}']}
    END

    ${result_id_dict}=  Create Dictionary
    ...  Equipment_enabled=${peer_BTS_enabled_id_list}
    ...  Equipment_reset=${peer_BTS_reset_id_list}

    [Return]  ${result_id_dict}

Execute External KW
    [Documentation]
    ...  Helper KW to run an external KW from a specific resource
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man. | Description                                            |
    ...  | KW_resource_path | Yes  | Path to specific resource where external KW is defined |
    ...  | KW_name          | Yes  | External KW name to be run                             |
    ...  | KW_args          | No   | Dict containing external KW specific arguments         |
    ...
    ...  *RETURN*
    ...
    ...  | Parameter | Description                  |
    ...  | KW_status | External KW execution status |
    ...
    [Arguments]  ${KW_resource_path}  ${KW_name}  ${KW_args}=&{EMPTY}

    ${KW_resource_path_split}=  Split Path  ${KW_resource_path}
    ${KW_resource_info}=  Get From List  ${KW_resource_path_split}  -1
    ${KW_resource_info_split}=  Split Extension  ${KW_resource_info}
    ${KW_resource_name}=  Get From List  ${KW_resource_info_split}  0

    Import Resource  ${KW_resource_path}
    Modify Resource Search Order  ${KW_resource_name}

    ${KW_status}=  Execute KW  KW_name=${KW_name}  KW_args=&{KW_args}

    Restore Resource Search Order

    [Return]  ${KW_status}

Execute KW
    [Arguments]  ${KW_name}  ${KW_args}=&{EMPTY}

    FOR  ${arg_key}  ${arg_value}  IN  &{KW_args}

        Set Test Variable  ${${arg_key}}  ${arg_value}

    END

    ${KW_status}=  Run Keyword And Return Status  ${KW_name}

    [Return]  ${KW_status}