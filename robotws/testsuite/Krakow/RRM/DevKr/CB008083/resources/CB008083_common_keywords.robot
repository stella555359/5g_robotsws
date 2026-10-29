*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    ../../resources/verifiers.robot
Resource    ../../resources/yaml_config_paths.robot
Resource    CB008083_counters.robot

Library     ../../../resources/Python/live_guami_view.py
Library     ../../resources/python/mock_stop_egate.py
Library     message_verifier.py
Library     backup_amf_utils.py
Library     option_to_param_generators.py
Library     alarm_verifier.py

*** Variables ***

${AMF1_backups}   2,3
${AMF2_backups}   1
${AMF3_backups}   1
${AMF_default_yaml}=             ${CURDIR}/../config/yaml_config/set_default_3AMF.yaml
${AMF_default_2_amfs_yaml}=      ${CURDIR}/../config/yaml_config/set_default_2AMF.yaml
${setup_1AMF}=                   ${CURDIR}/../config/yaml_config/setup_1AMF.yaml
${setup_2AMF}=                   ${CURDIR}/../config/yaml_config/setup_2AMF.yaml
${setup_3AMF}=                   ${CURDIR}/../config/yaml_config/setup_3AMF.yaml
${setup_4AMF}=                   ${CURDIR}/../config/yaml_config/setup_4AMF.yaml
${ff_enable_yaml}=               ${CURDIR}/../config/yaml_config/ff_enable.yaml

${amfi_not_existing_value}=      1:1:1


@{selected_AMFs_list}
@{yaml_paths_to_configure}

*** Keywords ***
Run Setup
    [Arguments]
    ...      ${number_of_amfs}          ${reset_tl}=${False}     ${f1ap}=${False}     ${gnbcuname}=${None}
    ...      ${setup_aliases}=${True}   ${amfs_link_state}=unlocked     ${user_yaml}=${False}
    ...      ${ff_enable}=${False}
    Log To Console    Setup started
    Omit keyword when variable present
    ...     SKIP_EMSS
    ...     Reliable emss setup         bts_id=1
    ${run_update}    get variable value      ${configure}    "True"     # do not ever change that line!
    Run Keyword if  ${run_update} != ${False}
    ...    Reach onAir state
    ...    reset_tl=${reset_tl}
    ...    number_of_amfs=${number_of_amfs}
    ...    amfs_link_state=${amfs_link_state}
    ...    gnbcuname=${gnbcuname}
    ...    user_yaml=${user_yaml}
    ...    ff_enable=${ff_enable}
    Run Keyword if  ${run_update} != "True"
    ...    Setup egate  egate_port=20000  alias=default
    Run Keyword if  ${setup_aliases} == ${True}
    ...    Setup devices aliases
    Run Keyword if  ${f1ap} != ${False}
    ...    Enable internal mirroring for alias  gNB2
    Observe NG-C link messages and update database

Reach onAir state
    [Arguments]
    ...       ${number_of_amfs}       ${amfs_link_state}       ${reset_tl}=${False}       ${gnbcuname}=${None}
    ...       ${user_yaml}=${False}   ${ff_enable}=${False}
    Set         SERVEDAMF.administrativeState        ${amfs_link_state}
    Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${setup_${number_of_amfs}AMF}
    ...     AND     Log to console      Added configuration for ${number_of_amfs} AMFs
    Run Keyword if  '${user_yaml}' != '${False}'
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${user_yaml}
    ...     AND     Log to console      Added user yaml configuration : ${user_yaml}
    Run Keyword if  ${ff_enable} == ${True}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${ff_enable_yaml}
    ...     AND     Log to console      Enable FF by yaml ${ff_enable_yaml}
    Run Keyword if  ${gnbcuname} != ${None}
    ...     Run keywords
    ...     Configure   {'MOC': 'NRBTS', 'gNbCuName': ${gnbcuname}}
    ...     AND     Log to console      Applied gNBCuName config
    Configure      ${yaml_paths_to_configure}
    Run Keyword if  ${reset_tl} != ${False}
    ...     Run keywords
    ...  Trigger site reset
    ...  AND  Wait for testline ICMP Echo replies and SSH services
    ...  AND  Sleep  60
    ...  AND  Check radios availability
    Wait for gnb to reach configured state
    discover bts
    Log To Console    Before Reach OnAir
    Run keyword and ignore error      get_lua_for_topology
    ${LUA_CFG_FILE}=      get variable value          ${LUA}        ${LUA_CFG}
    reach onair with retries    lua_cfg=${LUA_CFG_FILE}
    Log To Console    After Reach OnAir
    Do not stop egate and daemon

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.11
    Create AMF device with alias 'AMF2' identified by ip=10.0.1.12
    Create AMF device with alias 'AMF3' identified by ip=10.0.1.13
    Create AMF device with alias 'AMF4' identified by ip=10.0.1.14

Run Test Teardown
    Detach and kill UE1


Observe NG-C link messages and update database
    Observe AMFConfigurationUpdate for indefinite time
    Observe NGSetupResponse for indefinite time
    Observe AMFStatusIndication for indefinite time

    Register callback
    ...     NGSetupResponse
    ...     save_guamis_and_types

    Register callback
    ...     AMFConfigurationUpdate
    ...     save_guamis_and_types

    Register callback
    ...     AMFStatusIndication
    ...     save_guamis_and_types

Lock NGAP links
    Omit keyword when variable present
    ...     SKIP_EMSS
    ...     Configure   {'MOC': 'SERVEDAMF', 'administrativestate': 'Locked'}       #
#    ...     Edit object attributes  SERVEDAMF  administrativestate=Locked
    Log to console     Locking all unlocked NG-C links

Unlock NGAP links
    Omit keyword when variable present
    ...     SKIP_EMSS
    ...     Configure   {'MOC': 'SERVEDAMF', 'administrativestate': 'Unlocked'}
#    ...     Edit object attributes  SERVEDAMF  administrativestate=Unlocked
    Log to console     Unlocking all locked NG-C links

Lock NGAP link to AMF${amf_id}
#    Omit keyword when variable present
#    ...     SKIP_EMSS
    Log to console     Lock NG-C link for AMF${amf_id}
    Edit object attributes  SERVEDAMF-${amf_id}  administrativestate=Locked

Unlock NGAP link to AMF${amf_id}
#    Omit keyword when variable present
#    ...     SKIP_EMSS
    Log to console     Unlock NG-C link for AMF${amf_id}
    Edit object attributes  SERVEDAMF-${amf_id}  administrativestate=Unlocked

Set AMF${amf_id:\d+} include_guami_type parameter to on
    Log to console      Set AMF${amf_id} include_guami_type parameter to on
    Execute egate command   cmd=amf_ng_setup_param id=${amf_id} include_guami_type=on

Set AMF${amf_id:\d+} include_guami_type parameter to off
    Execute egate command   cmd=amf_ng_setup_param id=${amf_id} include_guami_type=off

Configure actEnhancedNgRanSupport flag to ${value} value
    Log to console     Configure actEnhancedNgRanSupport flag to ${value} value
    Omit keyword when variable present
    ...     SKIP_EMSS
    ...     Configure   {'MOC': 'NRBTS', 'actEnhancedNgRanSupport': '${value}'}

Configure actNgcFlexSaMode flag to ${value} value
    Log to console     Configure actNgcFlexSaMode flag to ${value} value
    Omit keyword when variable present
    ...     SKIP_EMSS
    ...     Configure   {'MOC': 'NRBTS', 'actNgcFlexSaMode': '${value}'}

Restore AMF${amf_id:\d+} GUAMIs
     Execute egate command   cmd=amf_restore_guamis id=${amf_id} guami_index=all

Verify that NG link to AMF-${amf_id:\d+} is established
    Object Attributes Should Be   SERVEDAMF-${amf_id}   ngLinkStatus=ACTIVE

Verify that SERVEDAMF-${amf_id:\d+}.guAMI.guamiType is set to ${guamiType}
    Object Attributes Should Be   SERVEDAMF-${amf_id}   guamiType=${guamiType}

Send AMF Configuration Update from AMF${amf_id:\d+} with GUAMI${guami_value_1} and GUAMI${guami_value_2} on ServedGUAMIList
    Log to console    Send AMF Configuration Update from AMF${amf_id} with GUAMI${guami_value_1} and GUAMI${guami_value_2} on ServedGUAMIList
    EXPECT FLOW: AMF${amf_id} NGAP aMFConfigurationUpdate

    Execute egate command    cmd=amf_config_update id=${amf_id} amfi=1:2:${guami_value_1},1:2:${guami_value_2}

    PASS FLOW: AMF${amf_id} NGAP aMFConfigurationUpdate

    ${flow_alias}=  Get Flow Name
    ...     procedure=aMFConfigurationUpdate
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (gUAMI contains (aMFRegionID eq '0b00000001'))
    ...     message_alias=AMFConfigurationUpdate
    ...     flow_alias=${flow_alias}

Attach UE-${ue_id:\d+} to AMF${amf_id:\d+}:GUAMI:${guami}
    Log  UE${ue_id} send to AMF:${AMF${amf_id}_GUAMI${guami}}
    Execute egate command    cmd=ue_nr_rrc_setup_param id=${ue_id} registered_amf=${AMF${amf_id}_GUAMI${guami}}
    Execute egate command    cmd=amf_registration_param id=${amf_id} guami_index=${guami}
    Sleep  1
    Attach UE
    ...  ue_id=${ue_id}
    ...  pass_regexp=UE${ue_id}: UE performed UNKNOWN_ATTACH_TYPE

Expect that UE-${ue_id:\d+} is attached to AMF${amf_id:\d+}
    Expect message flow
    ...     AMF${amf_id}:NGAP_InitialContextSetupRequest
    ...     AMF${amf_id}:NGAP_InitialContextSetupResponse (Get AMF and RAN UE NGAP ID) as ICSResp
    ...     alias=UE${ue_id}_ICS_from_AMF${amf_id}
    ...     overall_timeout=10
    Sleep  2

Verify that in NGSetupResponse GUAMI-Type is set to ${guamiType}
    ${flow_alias_ngSetup}=  Get Flow Name
    ...     procedure=nGSetup
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (guamiType eq '${guamiType}')
    ...     message_alias=NGSetupResponse
    ...     flow_alias=${flow_alias_ngSetup}

Verify that ngap ${message} message contains mandatory IEs for AMF${amf_id:\d+}
    ${flow_alias_ngSetup}=  Get Flow Name
    ...     procedure=nGSetup
    ...     device=AMF${amf_id}

    verify_mandatory_fields_in_message
    ...     flow_alias=${flow_alias_ngSetup}
    ...     message_alias=${message}

AMF is configured with GUAMIs
    [Documentation]
        ...   AMF1
        ...   guami:1-1-1,guami_type:native,guami_status:available

    [Arguments]     ${amf_alias}      @{guamis_params}     &{keyword_options}
    set to dictionary  ${keyword_options}       amf_alias       ${amf_alias}
    verify guamis in database
    ...     @{guamis_params}
    ...     &{keyword_options}

Reach AMF guami configuration
    [Documentation]
        ...   AMF1
        ...   guami:1-1-1,guami_type:native

    [Arguments]     ${amf_alias}      @{guamis_params}
    Log to console    ${amf_alias} trying to reach @{guamis_params}
    ${amf_index}=    get_id_index_from_alias        ${amf_alias}
    ${is_guami_type_not_set}=           if_any_guami_guami_type_required_as_not_set
    ...      ${guamis_params}
    Run keyword if       '${is_guami_type_not_set}'== 'True'
    ...     Run keywords
    ...     Execute egate command   cmd=amf_config_update id=${amf_index} amfi=${amfi_not_existing_value}       AND
    ...     Log     Changed amfi to non-existing value: ${amfi_not_existing_value}      AND
    ...     Sleep     2
    ${amfi_value}=   get_wts_guami_parameter_from_input
    ...      ${guamis_params}
    ...      old_separator=-
    ...      new_separator=:
    ...      join_sep=,
    clear_updates_counter
    Execute egate command   cmd=amf_config_update id=${amf_index} amfi=${amfi_value}
    ${message_arrived}=     Run Keyword And Return Status
    ...       wait_for_number_of_updates
    ...       1
    ...       timeout=5
    ${skip_ngc_check}=          Evaluate   ${message_arrived}==${FALSE}
    verify guamis in database
    ...     @{guamis_params}
    ...     amf_alias=${amf_alias}
    ...     dont_match_guami_type=${TRUE}
    ...     skip_check_ngc_view=${skip_ngc_check}
    clear_updates_counter
    ${guami_indexes_and_types}=    get_wts_guami_index_guami_type_from_input
    ...     ${guamis_params}
    Log     amf_change_guami_type id=${amf_index} ${guami_indexes_and_types}
    Run keyword if       '${guami_indexes_and_types}'!= ''
    ...       Execute egate command   cmd=amf_change_guami_type id=${amf_index} ${guami_indexes_and_types}
    ${message_arrived}=     Run Keyword And Return Status
    ...       wait_for_number_of_updates
    ...       1
    ...       timeout=5
    ${skip_ngc_check}=          Evaluate   ${message_arrived}==${FALSE}
    verify guamis in database
    ...     @{guamis_params}
    ...     amf_alias=${amf_alias}
    ...     skip_check_ngc_view=${skip_ngc_check}
    clear updates counter


UE${ue_id:\d+} sends ${fields} and ${amf_alias:AMF\d+} is selected
    Execute egate command
    ...   cmd=ue_nr_rrc_setup_param id=${ue_id} include_nwslice=off if_contains=any action=none registered_amf=none
    ${ue_nr_rrc_setup_param_options}=    generate ue_nr_rrc_setup_param options
    ...     fields=${fields}
    ...     field_separator=,
    ${rrc_setup_verifier}=    generate nr rrc setup verifier
    ...     fields=${fields}
    ...     field_separator=,
    ${ue_register_options}=    generate_ue_register_options
    ...     fields=${fields}
    ...     field_separator=,
    Execute egate command   cmd=ue_nr_rrc_setup_param id=${ue_id} ${ue_nr_rrc_setup_param_options}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetupComplete with selected fields
    Observe InitialUEMessage for 1 occurrences for 5s
    Execute egate command   cmd=ue_register id=${ue_id} ${ue_register_options}
#    Execute egate command   cmd=ue_register id=${ue_id} nwslice=2
#    Execute egate command   cmd=ue_register id=${ue_id} nwslice=1
    Run And Teardown On Failed
    ...     Detach and kill UE${ue_id}
    ...     PASS FLOW[timeout\=10]: UE_${ue_id} NR-RRC RRCSetupComplete with selected fields
    Run And Teardown On Failed
    ...     Detach and kill UE${ue_id}
    ...     Verify that RRCSetupComplete contains fields
    ...     UE_${ue_id}
    ...     ${rrc_setup_verifier}
    Run And Teardown On Failed
    ...     Detach and kill UE${ue_id}
    ...     check_that_message_owner_is_matching_expected_owner
    ...     InitialUEMessage
    ...     ${amf_alias}
    ...     ${selected_AMFs_list}
#    EXPECT FLOW[timeout=10]: ${amf_alias} NGAP uEContextReleaseRequest,uEContextRelease
    Detach and kill UE${ue_id}
#    Run keyword and ignore error    PASS FLOW[timeout=10]: ${amf_alias} NGAP uEContextReleaseRequest,uEContextRelease
#    sleep    1

Clear selected AMFs list
    ${empty_list}=          Create List
    Set Global variable       \${selected_AMFs_list}     ${empty_list}

AMF${amf_id:\d+} is being occasionally selected
        Log to console     Check if AMF${amf_id} is being occasionally selected
        Should Contain       ${selected_AMFs_list}      AMF${amf_id}

AMF${amf_id:\d+} is never being selected
        Log to console     Check if AMF${amf_id} is never being selected
        Should Not Contain       ${selected_AMFs_list}      AMF${amf_id}

Verify that RRCSetupComplete contains fields
    [Arguments]     ${ue_alias}        ${query}
    ${flow_alias}=      get flow name
    ...     RRCSetupComplete
    ...     device=${ue_alias}
    ...     protocol=NR-RRC
    verify that message fulfills query
    ...    ${query}
    ...    message_alias=RRCSetupComplete
    ...    flow_alias=${flow_alias}

Trigger AMF to change guamiType
    [Arguments]     ${amf_alias}      @{guamis_id_with_type}
    Log to console    ${amf_alias} trying to reach @{guamis_id_with_type}
    ${amf_id}=  Strip String  ${amf_alias}  characters=AMF
    ${guami_indexes_and_types}=    get_wts_guami_index_guami_type_from_input
    ...     ${guamis_id_with_type}
    Log     amf_change_guami_type id=${amf_id} ${guami_indexes_and_types}
    EXPECT FLOW: ${amf_alias} NGAP aMFConfigurationUpdate
    Run keyword if       '${guami_indexes_and_types}'!= ''
    ...       Execute egate command   cmd=amf_change_guami_type id=${amf_id} ${guami_indexes_and_types}
    PASS FLOW: ${amf_alias} NGAP aMFConfigurationUpdate

Trigger AMF${amf_id:\d+} to send update with RelativeCapacity ${rel_cap:\d+}
    Log to console     Setting capacity to ${rel_cap} for AMF${amf_id}
    Execute egate command   cmd=amf_config_update id=${amf_id} relative_capacity=${rel_cap}

Verify SERVEDAMF-${amf_id:\d+} has RelativeCapacity set to ${rel_cap:\d+}
    ${capacity}=    Wait until keyword succeeds    15 s   1 s
    ...        Verify AMF capacity     ${amf_id}               ${rel_cap}
    Log to console     AMF${amf_id} capacity set to ${capacity}

Verify AMF capacity
    [Arguments]         ${servedamf_id}      ${capacity}
    &{disp_result}=   get parameters for object type      SERVEDAMF     relativeamfcapacity
    Should be true       int(${disp_result[1]['SERVEDAMF-${servedamf_id}']['relativeamfcapacity']})==int(${capacity})
    [Return]             ${disp_result[1]['SERVEDAMF-${servedamf_id}']['relativeamfcapacity']}

Trigger AMFstatusIndication for AMF${amf_id} with unavailable GUAMI index-${guami_index}
    EXPECT FLOW: AMF${amf_id} NGAP aMFStatusIndication
    Execute egate command  cmd=send_amf_status_indication id=${amf_id} guami_index=${guami_index} action=drop
    PASS FLOW: AMF${amf_id} NGAP aMFStatusIndication

Setup AMF${amf_id:\d+} as default AMF
    Log to console     Setup AMF${amf_id} as default AMF
    Set   SERVEDAMF-1.defaultAMF                false
    Set   SERVEDAMF-2.defaultAMF                false
    Set   SERVEDAMF-3.defaultAMF                false
    Set   SERVEDAMF-${amf_id}.defaultAMF        true
    Configure           ${AMF_default_yaml}

Setup AMF${amf_id:\d+} as default AMF with 2 amfs configured
    Log to console     Setup AMF${amf_id} as default AMF
    Set   SERVEDAMF-1.defaultAMF                false
    Set   SERVEDAMF-2.defaultAMF                false
    Set   SERVEDAMF-${amf_id}.defaultAMF        true
    Configure           ${AMF_default_2_amfs_yaml}

Verify SERVEDAMFs have no backup AMFs
    &{disp_result}=   get parameters for object type      SERVEDAMF     guami.backupamfname
    Should be true       len(${disp_result})==0

Verify AMF backup
    [Documentation]
    ...  Works on structure
    ...  {1: {'SERVEDAMF-3': {'guami': [{'backupamfname': 'amf1'},
    ...                                  {'backupamfname': 'amf1'}]}}}


    [Arguments]       ${servedamf_id}      ${backup}    ${guamis_number}=1
    &{disp_result}=   get parameters for object type      SERVEDAMF-${servedamf_id}     guami.backupamfname
    @{backup_amf_names}=      Set variable    ${disp_result[1]['SERVEDAMF-${servedamf_id}']['guami']}
    backupamfname_list_contains_same_name       ${backup_amf_names}         ${backup}     ${guamis_number}
    [Return]    ${backup_amf_names}

Verify SERVEDAMF-${servedamf_id} has backup AMF named '${backup}' for ${guami_num:\d+} guamis
    Log to console     Verify SERVEDAMF-${servedamf_id} has backup AMF named '${backup}' for ${guami_num} guamis
    ${backup}=    Wait until keyword succeeds    5 s   1 s
    ...        Verify AMF backup     ${servedamf_id}               ${backup}       guamis_number=${guami_num}
    Log to console     AMF${servedamf_id} backup set to ${backup} for ${guami_num} guamis

Trigger AMFConfigurationUpdate for AMF${amf_id} to send backupamf '${backup_name}' for guami ${guami}
    Fail       Should not be used as it overwrites guami_type and applies only backupamf name
    Log to console      Trigger AMFConfigurationUpdate for AMF${amf_id} to send backupamf '${backup_name}' for guami ${guami}
    Should Contain       ${guami}     :
    EXPECT FLOW: AMF${amf_id} NGAP aMFConfigurationUpdate
    Execute egate command  cmd=amf_config_update id=${amf_id} guami=311:489-${guami} backup_amf=${backup_name}
    PASS FLOW: AMF${amf_id} NGAP aMFConfigurationUpdate

Trigger AMFConfigurationUpdate for AMF${amf_id:\d+} to restore all guamis disabled by AMFStatusIndication
    Log to console      Trigger AMFConfigurationUpdate for AMF${amf_id} to restore all guamis disabled by AMFStatusIndication
    Execute egate command  cmd=amf_restore_guamis id=${amf_id}

Verify SERVEDAMF-${servedamf_id} has no backup AMFs
    &{disp_result}=   get parameters for object type      SERVEDAMF-${servedamf_id}     guami.backupamfname
    Should be true       len(${disp_result})==0

Configure gNbCuName to ${value}
    Configure   {'MOC': 'NRBTS', 'gNbCuName': '${value}'}

Configure actEnhancedNgRanSupport flag to ${flag} value and gNbCuName to ${gNbCuName}
    Log to console     Configure actEnhancedNgRanSupport flag to ${flag} value and gNbCuName to ${gNbCuName}
    Omit keyword when variable present
    ...     SKIP_EMSS
    ...     Configure   {'MOC': 'NRBTS', 'actEnhancedNgRanSupport': '${flag}', 'gNbCuName': '${gNbCuName}'}

Delete gNbCuName
    Edit object attributes    NRBTS-1    gNbCuName=""

Verify that NG Setup Request to AMF${amf_id:\d+} contains RANNodeName set to ${value}
    ${flow_alias}=  Get Flow Name
    ...     procedure=nGSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     RANNodeName eq '"${value}"'
    ...     message_alias=NGSetupRequest
    ...     flow_alias=${flow_alias}

Verify that RAN Configuration Update to AMF${amf_id:\d+} contains RANNodeName set to ${value}
    ${flow_alias}=  Get Flow Name
    ...     procedure=rANConfigurationUpdate
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     RANNodeName eq '"${value}"'
    ...     message_alias=RANConfigurationUpdate
    ...     flow_alias=${flow_alias}

Reset NG link to AMF${amf_id:\d+}
    Execute egate command  cmd=link_drop link=ng by=amf:${amf_id} to=gnb:2
    sleep  5
    Log To Console    resetting NG link to AMF${amf_id}

Verify that NG Setup Request to AMF${amf_id:\d+} does not contain RANNodeName
    ${flow_alias}=  Get Flow Name
    ...     procedure=nGSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     RANNodeName is not present
    ...     message_alias=NGSetupRequest
    ...     flow_alias=${flow_alias}

Configure maxNumOfNgSetupRequestRetries to ${value} value
    Configure   {'MOC': 'NRBTS', 'maxNumOfNgSetupRequestRetries': '${value}'}

Configure ngSetupRespTmr to ${value} value
    Configure   {'MOC': 'NRBTS', 'ngSetupRespTmr': '${value}'}

Set AMF${amf_id:\d+} to ignore NGSetupRequest from gNB for ${ntimes:\d+} ${time|times}
    Execute egate command   cmd=amf_ng_setup_param id=${amf_id} repeated_action=request_ignore num_of_repetitions=${ntimes}

Set AMF${amf_id:\d+} to force NG setup fail for ${ntimes:\d+} ${time|times}
    Execute egate command   cmd=amf_ng_setup_param id=${amf_id} repeated_action=request_fail num_of_repetitions=${ntimes}

Verify SERVEDAMF-${amf_id:\d+} has ${sst_sd:0x\w+-0x\w+} in snssaiAMFList
    ${sst_sd_tuple}=        map_sst_sd_values_to_int        ${sst_sd}
    ${snssaiamflist}=    Wait until keyword succeeds    15 s   1 s
    ...        Verify AMF snssaiAMFList     ${amf_id}        ${sst_sd_tuple}[0]      ${sst_sd_tuple}[1]
    Log to console     AMF${amf_id} has ${sst_sd} included in snssaiAMFList, full list ${snssaiamflist}

Verify SERVEDAMF-${amf_id:\d+} has ${mcc:\d+}:${mnc:\d+}:${mnc_length:\d+} in plmnSupportList
    ${plmnsupportlist}=    Wait until keyword succeeds    15 s   1 s
    ...        Verify AMF plmnSupportList     ${amf_id}        ${mcc}      ${mnc}   ${mnc_length}
    Log to console     AMF${amf_id} has properly set PLMN list in plmnSupportList, full list ${plmnsupportlist}

Verify AMF snssaiAMFList
    [Arguments]         ${servedamf_id}      ${sst_dec}     ${sd_dec}
    &{disp_result}=   get parameters for object type      NRPLMN_SUPPORT     snssaiamflist
    Should be true       {'sst':'${sst_dec}', 'sd':'${sd_dec}'} in ${disp_result[1]['NRPLMN_SUPPORT-${servedamf_id}-1']['snssaiamflist']}
    [Return]             ${disp_result[1]['NRPLMN_SUPPORT-${servedamf_id}-1']['snssaiamflist']}

Verify AMF plmnSupportList
    [Arguments]         ${servedamf_id}      ${mcc_val}     ${mnc_val}      ${mnc_length}
    &{result}=   get parameters for object type      SERVEDAMF     plmnsupportlist
    Should be true
    ...   {'mcc': '${mcc_val}', 'mnc': '${mnc_val}', 'mnclength': '${mnc_length}'} in ${result[1]['SERVEDAMF-${servedamf_id}']['plmnsupportlist']}
    [Return]             ${result[1]['SERVEDAMF-${servedamf_id}']['plmnsupportlist']}

Verify SERVEDAMF-${amf_id:\d+} has ${num:\d+} items in snssaiAMFList
    ${snssaiamflist}=    Wait until keyword succeeds    15 s   1 s
    ...        Verify AMF snssaiAMFList length     ${amf_id}        ${num}
    Log to console     AMF${amf_id} has ${num} items included in snssaiAMFList, full list ${snssaiamflist}

Verify SERVEDAMF-${amf_id:\d+} has ${num:\d+} items in plmnSupportList
    ${snssaiamflist}=    Wait until keyword succeeds    15 s   1 s
    ...        Verify AMF plmnSupportList length     ${amf_id}        ${num}
    Log to console     AMF${amf_id} has ${num} items included in plmnSupportList, full list ${snssaiamflist}

Verify AMF snssaiAMFList length
    [Arguments]         ${servedamf_id}   ${length}
    &{disp_result}=   get parameters for object type      SERVEDAMF     snssaiamflist
    Should be true       len(${disp_result[1]['SERVEDAMF-${servedamf_id}']['snssaiamflist']})==int(${length})
    [Return]             ${disp_result[1]['SERVEDAMF-${servedamf_id}']['snssaiamflist']}

Verify AMF plmnSupportList length
    [Arguments]         ${servedamf_id}   ${length}
    &{disp_result}=   get parameters for object type      SERVEDAMF     plmnSupportList
    Should be true       len(${disp_result[1]['SERVEDAMF-${servedamf_id}']['plmnsupportlist']})==int(${length})
    [Return]             ${disp_result[1]['SERVEDAMF-${servedamf_id}']['plmnsupportlist']}

Verify SERVEDAMF-${amf_id:\d+} has NGC link ${status:(Active|Inactive)}
    ${nglinkstatus}=    Wait until keyword succeeds    15 s   1 s
    ...        Verify AMF NGC link status     ${amf_id}        ${status}
    Log to console     AMF${amf_id} has NG-C link ${nglinkstatus}

Verify AMF NGC link status
    [Arguments]         ${servedamf_id}   ${status}
    &{disp_result}=   get parameters for object type      SERVEDAMF     nglinkstatus
    Should be true       str('${disp_result[1]['SERVEDAMF-${servedamf_id}']['nglinkstatus']}').lower()==str('${status}').lower()
    [Return]             ${disp_result[1]['SERVEDAMF-${servedamf_id}']['nglinkstatus']}

Lock NRCELL-${nrcell_id:\d+}
    Edit object attributes  NRCELL-${nrcell_id}  administrativestate=Locked

Unlock NRCELL-${nrcell_id:\d+}
    Edit object attributes  NRCELL-${nrcell_id}  administrativestate=unlocked

Remove NRCELL-1
    Configure           ${remove_cell_yaml}

Verify that NRCELL-${nrcell_id} operationalState is ${state:(enabled|disabled)}
    Wait For Object Attribute Value
    ...     object_name=NRCELL-${nrcell_id}
    ...     attribute_name=operationalState
    ...     value=${state}
    ...     timeout=30

Verify that NRCELL-${nrcell_id:\d+} barringStatus is ${barring_status:(barred|unbarred)}
    Wait For Object Attribute Value
    ...     object_name=NRCELL-${nrcell_id}
    ...     attribute_name=barringStatus
    ...     value=${barring_status}
    ...     timeout=30

LTE attach NR-UE${ue_id:\d+}
    Execute egate command
    ...    cmd=ue_attach id=${ue_id}
    ...    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Sleep  1s

Start gNB Addition Procedure for NSA NR-UE${ue_id:\d+} with NRCELL-${cell_id:\d+}
    Execute egate command
    ...    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=UE${ue_id}: Proxy.*eNB 2 cell ${cell_id}.*reported successful RA

Reconfigure pucchF3ModulationScheme to ${value} for NRCELL-${nrcell_id}
    Edit object attributes  NRCELL-${nrcell_id}  pucchF3ModulationScheme=${value}
