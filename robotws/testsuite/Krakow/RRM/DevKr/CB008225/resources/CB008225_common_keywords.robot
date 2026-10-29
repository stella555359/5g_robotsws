*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
#Library     ./ta_messaging_WA.py        # must be first import in global resources!!!
Resource    ../../../resources/Robot/common_settings.robot
Resource    ../../resources/verifiers.robot
Resource    ../../resources/yaml_config_paths.robot
Resource    ta_messaging/single_message_observer.robot
Library     ./custom_LocationControlEncoder.py
Library     ./AMF_RAN_IDS.py
Library     ./verify_timestamp.py
Library     ../../resources/python/mock_stop_egate.py
Resource    CB008225_LocationReportVerifiers.robot
Library     taf.ul.ue.sim.env_setup

*** Variables ***
${CB008225_enable_yaml_path}                        ${CURDIR}/../config/yaml_config/CB008225_enable.yaml
${CB008225_enable_custom_ranac_yaml_path}           ${CURDIR}/../config/yaml_config/CB008225_enable_configurable_ranac.yaml
${CB008225_ransharing_off_custom_ranac_yaml_path}   ${CURDIR}/../config/yaml_config/CB008225_ranac_configurable_ransharing_disabled.yaml
${CB008225_interaction_with_CB006597_yaml_path}     ${CURDIR}/../config/yaml_config/CB008225_interaction_with_CB006597.yaml
${different_tacs_on_cells_yaml_path}                ${CURDIR}/../config/yaml_config/setup_nwslice.yaml
${different_tacs_on_cells_yaml_path_4_cells}        ${CURDIR}/../config/yaml_config/setup_nwslice_4_cells.yaml
${gnbid_32_bits_yaml_path}                          ${CURDIR}/../config/yaml_config/gnbid_32_bits.yaml
${gnbid_only_nrrels_32_bits_yaml_path}              ${CURDIR}/../config/yaml_config/gnbid_in_nrrels_32_bits.yaml

${nRCellIdentity_1_cell}    16385
${nRCellIdentity_1_cell_32_bit}    17
${nRCellIdentity_2_cell}    16386
${nRCellIdentity_2_cell_32_bit}    18
${nRCellIdentity_3_cell}    16387
${nRCellIdentity_3_cell_32_bit}    19

&{nrcell_ids}       NRCELL-1=${nRCellIdentity_1_cell}
...                 NRCELL-2=${nRCellIdentity_2_cell}
...                 NRCELL-3=${nRCellIdentity_3_cell}

&{nrcell_ids_32_bit}       NRCELL-1=${nRCellIdentity_1_cell_32_bit}
...                        NRCELL-2=${nRCellIdentity_2_cell_32_bit}
...                       NRCELL-3=${nRCellIdentity_3_cell_32_bit}

${tac_1_cell}    200
${tac_1_cell_hex}    0x0000C8
${tac_2_cell}    201
${tac_2_cell_hex}    0x0000C9
${tac_3_cell}    300
${tac_3_cell_hex}    0x00012C


&{tacs}             ${tac_1_cell}=${tac_1_cell_hex}
...                 ${tac_2_cell}=${tac_2_cell_hex}
...                 ${tac_3_cell}=${tac_3_cell_hex}



${rannodeid_1}   1
${rannodeid_1_bin_32}    00000000000000000000000000000001
${rannodeid_2}   2
${rannodeid_2_bin_32}    00000000000000000000000000000010

&{nodeids}             ${rannodeid_1}=${rannodeid_1_bin_32}
...                    ${rannodeid_2}=${rannodeid_2_bin_32}


@{yaml_paths_to_configure}=   ${disable_ciphering_yaml_path}    ${SIB_config_yaml_path}    ${intra_gNB_handover}
${USE_EGATE}=           ${True}
${DEFAULT_USE_ADMIN}=           ${False}
${RESUME_FROM_F1AP}=            ${False}

${timestamp_toleration}=    3

&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  1=1   4=4    5=5    8=8    9=9
${ON_FAILURE}=           CONTINUE
${GNB_ID_LENGTH_32}=     ${False}
${FAIL_TIM_DEFULT}=       6
${FAIL_TIM}=             ${FAIL_TIM_DEFULT}
${TRAFFIC_CHECK}=        ${True}
${USE_TAF_ENV}=          ${True}

*** Keywords ***
Set resume procedure FAIL timeout to ${tim:\d+}
    set suite variable    ${FAIL_TIM}     ${tim}

Restore default resume procedure FAIL timeout
    set suite variable    ${FAIL_TIM}     ${FAIL_TIM_DEFULT}

Run Setup
    [Arguments]    ${f1ap}=${False}     ${cell_messages}=${False}     ${custom_ranac}=${None}
    ...            ${different_tacs}=${False}       ${32_bit_long_gnb_id}=${False}
    ...            ${disable_ran_sharing}=${False}    ${custom_cell_level_ranac}=${None}

    Log To Console    Setup started
    Reliable emss setup    bts_id=1
    ${run_update}    Get variable value      ${configure}    True     # do not ever change that line!
    Run Keyword if  ${32_bit_long_gnb_id} != ${False}
    ...       set suite variable    ${GNB_ID_LENGTH_32}         ${True}

    Run Keyword if  '${run_update}' == 'True'
    ...    Reach onAir state
    ...    custom_ranac=${custom_ranac}
    ...    different_tacs=${different_tacs}
    ...    32_bit_long_gnb_id=${32_bit_long_gnb_id}
    ...    disable_ran_sharing=${disable_ran_sharing}
    ...    custom_cell_level_ranac=${custom_cell_level_ranac}
    Run Keyword if  '${run_update}' != 'True'
    ...    Setup egate  egate_port=20000  alias=default

    Setup devices aliases
    Run Keyword if  ${f1ap} != ${False}
    ...    Enable internal mirroring for alias  gNB2
    Run Keyword if  ${cell_messages} != ${False}
    ...    create cells alias       alias=NRCELL   cells_type=wts_5g

Set ranac values in yaml variables
    [Arguments]         ${ranac_values}
    @{ranac_list}=      split to list       ${ranac_values}
    Set         NRPLMNSET_SA-1.ranAC            ${ranac_list}[0]
    Set         NRPLMNSET_SA-2.ranAC            ${ranac_list}[1]

Set cell level ranac values in yaml variables
    [Arguments]         ${ranac_values}
    @{ranac_list}=      split to list       ${ranac_values}
    Set         NRCELL-1.ranAC            ${ranac_list}[0]
    Set         NRCELL-2.ranAC            ${ranac_list}[1]


Reach onAir state
    [Arguments]    ${custom_ranac}=${None}     ${different_tacs}=${False}    ${32_bit_long_gnb_id}=${False}
    ...            ${disable_ran_sharing}=${False}     ${custom_cell_level_ranac}=${None}
    Run Keyword if  ${different_tacs} != ${False} and ${disable_ran_sharing} != ${False}
    ...     Fail    Operation not permitted: conflict in yamls when disabling ran sharing and using different tac per cell
    ${cm_topology}     get_topology_label_from_multiple_ute_sources
    ${cm_variant}       get_variant_from_multiple_ute_sources
    ${disable_ran_sharing_yaml_path_option}=        set variable if    '${cm_variant}'!='SANSA_FS_ECPRI_CMWV_TDD_TEMP'
    ...      ${disable_ran_sharing_yaml_path_4_cells}
    ...      ${disable_ran_sharing_yaml_path}
    ${different_tacs_on_cells_yaml_path_option}=    set variable if    '${cm_variant}'!='SANSA_FS_ECPRI_CMWV_TDD_TEMP'
    ...      ${different_tacs_on_cells_yaml_path_4_cells}
    ...      ${different_tacs_on_cells_yaml_path}
    Run Keyword if  ${custom_ranac} == ${None}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${CB008225_enable_yaml_path}       AND
    ...     Log to console      Applied default ranac values [1,1]
    Run Keyword if  ${different_tacs} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${different_tacs_on_cells_yaml_path_option}     AND
    ...     Log to console      Applied different tacs per cells
    Run Keyword if  ${custom_ranac} != ${None}
    ...     Run keywords
    ...     Set ranac values in yaml variables          ${custom_ranac}     AND
    ...     append to list      ${yaml_paths_to_configure}       ${CB008225_enable_custom_ranac_yaml_path}      AND
    ...     Log to console      Applied custom ranac values: ${custom_ranac}
    Run Keyword if  ${32_bit_long_gnb_id} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${gnbid_32_bits_yaml_path}      AND
    ...     Log to console      Applied 32 bits gNBId length to NRBTS and NRREL
    Run Keyword if  ${custom_cell_level_ranac} != ${None}
    ...     Run keywords
    ...     Set cell level ranac values in yaml variables          ${custom_cell_level_ranac}     AND
    ...     append to list      ${yaml_paths_to_configure}       ${CB008225_ransharing_off_custom_ranac_yaml_path}   AND
    ...     Log to console      Applied custom NRCELL ranac values: ${custom_ranac}
    Run Keyword if  ${disable_ran_sharing} != ${False}
    ...     Run keywords
    ...     append to list      ${yaml_paths_to_configure}       ${disable_ran_sharing_yaml_path_option}     AND
    ...     Log to console      Applied disabling of ransharing (removed NRPLMNSET* values)

    ${use_admin_val}    Get variable value      ${USE_ADMIN}    ${DEFAULT_USE_ADMIN}
    Configure       ${yaml_paths_to_configure}     use_admin=${use_admin_val}

    Wait for gnb to reach configured state
    Discover bts

    Run Keyword if  ${32_bit_long_gnb_id} != ${False}
    ...     Run keywords
    ...     Configure       ${gnbid_only_nrrels_32_bits_yaml_path}     use_admin=${use_admin_val}      AND
    ...     Log to console      Applied 32 bits gNBId length NRREL once more

    Run keyword and ignore error      get_lua_for_topology
    ${LUA_CFG_FILE}=      get variable value          ${LUA}        ${LUA_CFG}

    Log To Console    Before Reach OnAir
    Run Keyword if  ${USE_TAF_ENV} == ${False}
    ...    Reach OnAir with retries    lua_cfg=${LUA_CFG_FILE}
    Run Keyword if  ${USE_TAF_ENV} == ${True}
    ...   TAF ENV reachonAir         lua_cfg_arg=${LUA_CFG_FILE}
    Log To Console    After Reach OnAir
#    Do not stop egate and daemon

TAF ENV reachonAir
    [Arguments]     ${lua_cfg_arg}
    Add 5GC    config=${lua_cfg_arg}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Setup egate  egate_port=20000  alias=default    save_egate=${True}

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Enable RRC Inactive state transitions on gNB
    ${use_admin_val}    Get variable value      ${USE_ADMIN}    ${DEFAULT_USE_ADMIN}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'actRrcInactState': 'intra-gNB'}    use_admin=${use_admin_val}

Enable interaction CB008225-G with 5GC000770
    ${use_admin_val}    Get variable value      ${USE_ADMIN}    ${DEFAULT_USE_ADMIN}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'true', 'actLocationReportingSA': 'true'}    use_admin=${use_admin_val}

Disable CB008225-G with enabled 5GC000770
    ${use_admin_val}    Get variable value      ${USE_ADMIN}    ${DEFAULT_USE_ADMIN}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'false', 'actLocationReportingSA': 'true'}    use_admin=${use_admin_val}

Enable interaction CB008225 with CB006597
    ${use_admin_val}    Get variable value      ${USE_ADMIN}    ${DEFAULT_USE_ADMIN}
    Configure  ${CB008225_interaction_with_CB006597_yaml_path}

Disable interaction CB008225-G with 5GC000770
    ${use_admin_val}    Get variable value      ${USE_ADMIN}    ${DEFAULT_USE_ADMIN}
    Configure  {'MOC': 'NRBTS', 'ID': '1', 'rrcInactLocationReportEnabled': 'false', 'actLocationReportingSA': 'false'}    use_admin=${use_admin_val}

Configure Areas of Interest as 2 cells
    Execute Egate Command    cmd=area_of_interest_configuration object_id=1 plmn_cellid=311:489 nrcellidentitylist=${nRCellIdentity_1_cell}
    # area_of_interest_configuration object_id=1 plmn_cellid=311:489 nrcellidentitylist=16385
    Execute Egate Command    cmd=area_of_interest_configuration object_id=2 plmn_cellid=311:489 nrcellidentitylist=${nRCellIdentity_2_cell}
    # area_of_interest_configuration object_id=1 plmn_cellid=311:489 nrcellidentitylist=16386

Configure Areas of Interest as 2 tacs
    Execute Egate Command    cmd=area_of_interest_configuration object_id=1 plmn_tai=311:489 taclist=${tac_1_cell}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=2 plmn_tai=311:489 taclist=${tac_2_cell}


Configure 8 Areas of Interest with nrcelllist and tacs and rannodeids
    ${1_cell}=   Set variable if   ${GNB_ID_LENGTH_32}==${True}     ${nrcell_ids_32_bit}[NRCELL-1]     ${nrcell_ids}[NRCELL-1]
    ${2_cell}=   Set variable if   ${GNB_ID_LENGTH_32}==${True}     ${nrcell_ids_32_bit}[NRCELL-2]     ${nrcell_ids}[NRCELL-2]
    ${3_cell}=   Set variable if   ${GNB_ID_LENGTH_32}==${True}     ${nrcell_ids_32_bit}[NRCELL-3]     ${nrcell_ids}[NRCELL-3]
    Execute Egate Command    cmd=area_of_interest_configuration object_id=1 plmn_cellid=311:489 nrcellidentitylist=${1_cell}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=2 plmn_cellid=311:489 nrcellidentitylist=${2_cell}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=3 plmn_cellid=311:489 nrcellidentitylist=${3_cell}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=4 plmn_tai=311:489 taclist=${tac_1_cell}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=5 plmn_tai=311:489 taclist=${tac_2_cell}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=6 plmn_tai=311:489 taclist=${tac_3_cell}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=7 plmn_ran_node_id=311:489 globalrannodeid=${rannodeid_1}
    Execute Egate Command    cmd=area_of_interest_configuration object_id=8 plmn_ran_node_id=311:489 globalrannodeid=${rannodeid_2}


Configure Areas of Interest for third non-exsting cell
    Execute Egate Command    cmd=area_of_interest_configuration object_id=3 plmn_cellid=311:489 nrcellidentitylist=${nRCellIdentity_3_cell}
    # area_of_interest_configuration object_id=3 plmn_cellid=311:489 nrcellidentitylist=16387

Wait until UE${ue_id:\d+} goes to RRC_INACTIVE by drbRrcInactInactivityTimerSA
    EXPECT FLOW[timeout=30]: gNB2 E1AP bearerContextInactivityNotification
    EXPECT FLOW[timeout=30]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=30]: gNB2 F1AP uEContextRelease
    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease

    PASS FLOW[timeout=30]: gNB2 E1AP bearerContextInactivityNotification
    PASS FLOW[timeout=30]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=30]: gNB2 F1AP uEContextRelease
    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease

    ${bearer_ctx_inact_notify}=     Get Flow Name
    ...     procedure=bearerContextInactivityNotification
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     uE-Activity eq 'not-active'
    ...     message_alias=BearerContextInactivityNotification
    ...     flow_alias=${bearer_ctx_inact_notify}

    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (suspendConfig is present) and (ran-NotificationAreaInfo is present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${rrc_release}

Wait until UE${ue_id:\d+} goes to RRC_INACTIVE by UAI
    EXPECT FLOW[timeout=30]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=30]: gNB2 F1AP uEContextRelease
    EXPECT FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease

    Trigger UE${ue_id} to send UAI with RRC preferred state of inactive

    PASS FLOW[timeout=30]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=30]: gNB2 F1AP uEContextRelease
    PASS FLOW[timeout=30]: UE_${ue_id} NR-RRC RRCRelease

    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (suspendConfig is present) and (ran-NotificationAreaInfo is present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${rrc_release}

Wait until UE${ue_id:\d+} goes to RRC_INACTIVE by UAI with timeout ${tim:\d+}
    EXPECT FLOW[timeout=${tim}]: gNB2 E1AP bearerContextModification
    EXPECT FLOW[timeout=${tim}]: gNB2 F1AP uEContextRelease
    EXPECT FLOW[timeout=${tim}]: UE_${ue_id} NR-RRC RRCRelease

    Trigger UE${ue_id} to send UAI with RRC preferred state of inactive with timeout ${tim}

    PASS FLOW[timeout=${tim}]: gNB2 E1AP bearerContextModification
    PASS FLOW[timeout=${tim}]: gNB2 F1AP uEContextRelease
    PASS FLOW[timeout=${tim}]: UE_${ue_id} NR-RRC RRCRelease

    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (suspendConfig is present) and (ran-NotificationAreaInfo is present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${rrc_release}


Setup CoreNetworkAssistanceInformationForInactive to be included in InitialContextSetupRequest
    ${command}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=yes
    ...                       ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min
    ...                       plmn_id=311:489 tac_id=200
    # amf_ue_ics_param id=1 core_network_assistance_info=yes ue_identity_index_value=1 ue_specific_drx=64
    # periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute egate command    cmd=${command}

Send LocationReportingControl for UE${ue_id:\d+} with eventType=${event_type:(direct|change-.*-cell|stop-change.*-cell|cancel-.*-ue)}
    ${event_type_IE}    Set Variable If 	'${event_type}' == 'change-of-serving-cell'       change-of-serve-cell        ${event_type}
    ${event_type_IE}    Set Variable If 	'${event_type}' == 'stop-change-of-serving-cell'  stop-change-of-serve-cell   ${event_type_IE}
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReportingControl
    Run Keyword if  ${USE_EGATE} == ${False}
    ...    Send LocationReportingControl HEX with last AMF and RAN IDs     ${event_type_IE}
    Run Keyword if  ${USE_EGATE} != ${False}
    ...    Execute egate command    cmd=ue_send_location_reporting_control ue=${ue_id} event_type=${event_type}

    PASS FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${location_reporting_control}=  Get Flow Name
    ...         procedure=locationReportingControl
    ...         device=AMF1

    Verify That Message Fulfills Query
    ...     eventType eq '${event_type_IE}'
    ...     message_alias=LocationReportingControl
    ...     flow_alias=${location_reporting_control}

Send LocationReportingControl for UE${ue_id:\d+} with eventType=ue-presence-in-area-of-interest for NRCELL-${cell_id:[1-3]}
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${command}    Catenate    ue_send_location_reporting_control ue=${ue_id} event_type=ue-presence-in-area-of-interest
    ...                       object_id=${cell_id} location_reporting_reference_id=${cell_id}

    ${bin_cell_value}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-${cell_id}]     36
    Run Keyword if  ${USE_EGATE} == ${False}
    ...    Send LocationReportingControl HEX with last AMF and RAN IDs
    ...     ue-presence-in-area-of-interest
    ...     ${bin_cell_value}:${cell_id}
    Run Keyword if  ${USE_EGATE} != ${False}
    ...    Execute egate command    cmd=${command}
    PASS FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${location_reporting_control}=  Get Flow Name
    ...         procedure=locationReportingControl
    ...         device=AMF1

    Verify That Message Fulfills Query
    ...     (eventType eq 'ue-presence-in-area-of-interest') and
    ...     (length(areaOfInterestList) eq 1) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq ${cell_id})) and
    ...     (areaOfInterestList contains (nRCellIdentity eq "0b${bin_cell_value}"))
    ...     message_alias=LocationReportingControl
    ...     flow_alias=${location_reporting_control}

Send LocationReportingControl for UE${ue_id:\d+} with eventType=ue-presence-in-area-of-interest for both cells
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${command}    Catenate    ue_send_location_reporting_control ue=${ue_id} event_type=ue-presence-in-area-of-interest
    ...                       object_id=1 location_reporting_reference_id=1
    ...                       object_id=2 location_reporting_reference_id=2
    ${bin_cell1_value}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-1]     36
    ${bin_cell2_value}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-2]     36

    Run Keyword if  ${USE_EGATE} == ${False}
    ...    Send LocationReportingControl HEX with last AMF and RAN IDs
    ...     ue-presence-in-area-of-interest
    ...     ${bin_cell1_value}:1,${bin_cell2_value}:2
    Run Keyword if  ${USE_EGATE} != ${False}
    ...    Execute egate command    cmd=${command}
    PASS FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${location_reporting_control}=  Get Flow Name
    ...         procedure=locationReportingControl
    ...         device=AMF1

    Verify That Message Fulfills Query
    ...     (eventType eq 'ue-presence-in-area-of-interest') and
    ...     (length(areaOfInterestList) eq 2) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 1 and nRCellIdentity eq "0b${bin_cell1_value}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 2 and nRCellIdentity eq "0b${bin_cell2_value}"))
    ...     message_alias=LocationReportingControl
    ...     flow_alias=${location_reporting_control}

Send LocationReportingControl for UE${ue_id:\d+} with eventType=ue-presence-in-area-of-interest for cells and tacs and rannodeids
    Configure 8 Areas of Interest with nrcelllist and tacs and rannodeids
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${command}    Catenate    ue_send_location_reporting_control ue=${ue_id} event_type=ue-presence-in-area-of-interest
    ...                       object_id=1 location_reporting_reference_id=1
    ...                       object_id=2 location_reporting_reference_id=2
    ...                       object_id=3 location_reporting_reference_id=3
    ...                       object_id=4 location_reporting_reference_id=4
    ...                       object_id=5 location_reporting_reference_id=5
    ...                       object_id=6 location_reporting_reference_id=6
    ...                       object_id=7 location_reporting_reference_id=7
    ...                       object_id=8 location_reporting_reference_id=8

    ${1_cell}=   Set variable if   ${GNB_ID_LENGTH_32}==${True}     ${nrcell_ids_32_bit}[NRCELL-1]     ${nrcell_ids}[NRCELL-1]
    ${2_cell}=   Set variable if   ${GNB_ID_LENGTH_32}==${True}     ${nrcell_ids_32_bit}[NRCELL-2]     ${nrcell_ids}[NRCELL-2]
    ${3_cell}=   Set variable if   ${GNB_ID_LENGTH_32}==${True}     ${nrcell_ids_32_bit}[NRCELL-3]     ${nrcell_ids}[NRCELL-3]


    ${bin_cell1_value_non_32}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-1]     36
    ${bin_cell1_value_32_bit}=      get_bin_value_from_dec      ${nrcell_ids_32_bit}[NRCELL-1]     36
    ${bin_cell1_value}=     set variable if         ${GNB_ID_LENGTH_32}==${True}        ${bin_cell1_value_32_bit}  ${bin_cell1_value_non_32}

    ${bin_cell2_value_non_32}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-2]     36
    ${bin_cell2_value_32_bit}=      get_bin_value_from_dec      ${nrcell_ids_32_bit}[NRCELL-2]     36
    ${bin_cell2_value}=     set variable if         ${GNB_ID_LENGTH_32}==${True}        ${bin_cell2_value_32_bit}  ${bin_cell2_value_non_32}

    ${bin_cell3_value_non_32}=      get_bin_value_from_dec      ${nrcell_ids}[NRCELL-3]     36
    ${bin_cell3_value_32_bit}=      get_bin_value_from_dec      ${nrcell_ids_32_bit}[NRCELL-3]     36
    ${bin_cell3_value}=     set variable if         ${GNB_ID_LENGTH_32}==${True}        ${bin_cell3_value_32_bit}  ${bin_cell3_value_non_32}

    Run Keyword if  ${USE_EGATE} == ${False}
    ...    Send LocationReportingControl HEX with last AMF and RAN IDs
    ...     ue-presence-in-area-of-interest
    ...     ${bin_cell1_value}:1,${bin_cell2_value}:2
    Run Keyword if  ${USE_EGATE} != ${False}
    ...    Execute egate command    cmd=${command}
    PASS FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${location_reporting_control}=  Get Flow Name
    ...         procedure=locationReportingControl
    ...         device=AMF1


    Verify That Message Fulfills Query
    ...     (eventType eq 'ue-presence-in-area-of-interest') and
    ...     (length(areaOfInterestList) eq 8) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 1 and nRCellIdentity eq "0b${bin_cell1_value}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 2 and nRCellIdentity eq "0b${bin_cell2_value}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 3 and nRCellIdentity eq "0b${bin_cell3_value}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 4 and tAC eq "${tac_1_cell_hex}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 5 and tAC eq "${tac_2_cell_hex}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 6 and tAC eq "${tac_3_cell_hex}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 7 and gNB-ID contains (gNB-ID eq "0b${rannodeid_1_bin_32}"))) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 8 and gNB-ID contains (gNB-ID eq "0b${rannodeid_2_bin_32}")))
    ...     message_alias=LocationReportingControl
    ...     flow_alias=${location_reporting_control}


Send LocationReportingControl for UE${ue_id:\d+} with eventType=ue-presence-in-area-of-interest for tacs
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${command}    Catenate    ue_send_location_reporting_control ue=${ue_id} event_type=ue-presence-in-area-of-interest
    ...                       object_id=1 location_reporting_reference_id=1
    ...                       object_id=2 location_reporting_reference_id=2

    Run Keyword if  ${USE_EGATE} == ${False}
    ...    Send LocationReportingControl HEX with last AMF and RAN IDs
    ...     ue-presence-in-area-of-interest
    ...     ${bin_cell1_value}:1,${bin_cell2_value}:2
    Run Keyword if  ${USE_EGATE} != ${False}
    ...    Execute egate command    cmd=${command}
    PASS FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${location_reporting_control}=  Get Flow Name
    ...         procedure=locationReportingControl
    ...         device=AMF1

    Verify That Message Fulfills Query
    ...     (eventType eq 'ue-presence-in-area-of-interest') and
    ...     (length(areaOfInterestList) eq 2) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 1 and tAC eq "${tac_1_cell_hex}")) and
    ...     (areaOfInterestList contains (locationReportingReferenceID eq 2 and nRCellIdentity eq "${tac_2_cell_hex}"))
    ...     message_alias=LocationReportingControl
    ...     flow_alias=${location_reporting_control}

Send LocationReportingControl for UE${ue_id:\d+} with eventType=stop-ue-presence-in-area-of-interest for area ${area_id:[1-8]}
    EXPECT FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${command}    Catenate    ue_send_location_reporting_control ue=${ue_id} event_type=stop-ue-presence-in-area-of-interest
    ...                       location_reporting_reference_id_to_be_cancelled=${area_id}

    Execute egate command    cmd=${command}
    PASS FLOW[timeout=10]: AMF1 NGAP locationReportingControl

    ${location_reporting_control}=  Get Flow Name
    ...         procedure=locationReportingControl
    ...         device=AMF1

    Verify That Message Fulfills Query
    ...     (eventType eq 'stop-ue-presence-in-area-of-interest') and
    ...     (locationReportingReferenceIDToBeCancelled eq ${area_id})
    ...     message_alias=LocationReportingControl
    ...     flow_alias=${location_reporting_control}

Trigger NGAP: PAGING for UE${ue_id:\d+}
    EXPECT FLOW[timeout=20]: AMF1 NGAP paging
    EXPECT FLOW[timeout=20]: gNB2 NGAP initialContextSetup
    EXPECT FLOW[timeout=20]: gNB2 NGAP pDUSessionResourceSetup

    Execute egate command    cmd=amf_paging_start id=1 ue=${ue_id}

    PASS FLOW[timeout=20]: AMF1 NGAP paging
    PASS FLOW[timeout=20]: gNB2 NGAP initialContextSetup
    PASS FLOW[timeout=20]: gNB2 NGAP pDUSessionResourceSetup

Trigger UE${ue_id:\d+} to send UAI with RRC preferred state of ${UAI_session_type:(idle|inactive|connected|outOfConnected)}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC UEAssistanceInformation
    Execute egate command   cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${UAI_session_type}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC UEAssistanceInformation

Trigger UE${ue_id:\d+} to send UAI with RRC preferred state of inactive with timeout ${timeout:\d+}
    EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC UEAssistanceInformation
    Execute egate command   cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=inactive
    PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC UEAssistanceInformation


Change for UE${ue_id:\d+} target cell of resume procedure to ${cell_id:\d+} with cause ${cause}
    [Documentation]  Not allowed in ue_nr_rrc_resume_request_param use only location or only cause, need use both!!
    Execute egate command   cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}

UE${ue_id:\d+} triggers RRCResume procedure to NRCELL-${cell_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Execute egate command   cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mt_Access
    Execute egate command   cmd=ue_nr_rrc_resume id=${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Verify that UE${ue_id} sends ResumeRequest with cause=mt-Access
    On failure
    ...     Verify that UE${ue_id} resume procedure was successfull via sending traffic

UE${ue_id:\d+} triggers RRCResume procedure to NRCELL-${cell_id:\d+} without traffic check
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Execute egate command   cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=mt_Access
    Execute egate command   cmd=ue_nr_rrc_resume id=${ue_id}
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Verify that UE${ue_id} sends ResumeRequest with cause=mt-Access



UE${ue_id:\d+} triggers RRCResume procedure to NRCELL-${cell_id:\d+} via PDUSessionModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Add to UE${ue_id} PDU1 session QoS flows with 5QI from list [9] and delete QoS flows with 5QI from list [] via amf
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    On failure
    ...     Verify that UE${ue_id} resume procedure was successfull via sending traffic



EXPECT UE${ue_id:\d+} rrcResume successfull procedure ending in CONNECTED state
    EXPECT FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    EXPECT FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCSetupRequest will not happen
    EXPECT FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCSetup will not happen

PASS UE${ue_id:\d+} rrcResume successfull procedure ending in CONNECTED state
    PASS FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    FAIL FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCSetupRequest will not happen
    FAIL FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCSetup will not happen


FAIL UE${ue_id:\d+} rrcResume procedure remaining in inactive state
    FAIL FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCResumeRequest1
    FAIL FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    FAIL FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCSetupRequest will not happen
    FAIL FLOW[timeout=${FAIL_TIM}]: UE_${ue_id} NR-RRC RRCSetup will not happen

Observe NG-C ICS messages and update database
    Observe InitialContextSetupResponse for indefinite time
    Register callback
    ...     InitialContextSetupResponse
    ...     save_ids

Send LocationReportingControl HEX with last AMF and RAN IDs
    [Arguments]     ${event_type}       ${area_cells}=${None}
    ${ids}=    get last ids
    ${ids_len}=             Evaluate    len(${ids})>0
    Run keyword if    ${ids_len}!=${TRUE}
    ...               wait_for_number_of_updates      1
    ${amf_id}=    Get From List    ${ids}    0   #${ids}[0]
    ${ran_id}=    Get From List    ${ids}    1   #${ids}[1]
    ${hex}=       build_LRC
    ...           ${amf_id}
    ...           ${ran_id}
    ...           ${event_type}
    ...           ${area_cells}

    Execute egate command    cmd=send_hex source=amf:1 target=gnb:2 hex=${hex}
    clear updates counter

Verify that AreaCodeList contains AreaCode equal ${area_code:\d+} for UE_${ue_id:\d+}
    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ran-AreaCodeList contains (${area_code})
    ...     message_alias=RRCRelease
    ...     flow_alias=${rrc_release}

Trigger RRCResume procedure for UE${ue_id:\d+} by running ${direction:(UL|DL)} traffic towards NRCELL-${cell_id:[1-3]}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
#    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete

    Execute egate command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} cell=${cell_id} gnb=2 cause=mt_Access
    Run 5Mbps ${direction} traffic-1 on UE${ue_id} PDU1 QFI1 and wait 15 seconds

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
#    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Verify that UE${ue_id} sends ResumeRequest with cause=mt-Access
#    On failure
#    ...     Verify that UE${ue_id} resume procedure was successfull via sending traffic

Trigger RRCResume procedure for UE${ue_id:\d+} by running RNA update towards NRCELL-${cell_id:[1-3]}
    ${t380_active}      Get variable value      ${VIA_T380}            ${False}
    ${timeout}=         Set variable if      ${t380_active}==${False}       10     320
    EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete

    Execute egate command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} cell=${cell_id} gnb=2 cause=rna_Update
    Run Keyword if  ${t380_active}==${False}
    ...               Execute egate command    cmd=ue_nr_rrc_resume id=${ue_id}

    PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=${timeout}]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Verify that UE${ue_id} sends ResumeRequest with cause=rna-Update
    ${rrc_release}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...     (suspendConfig is present) and (ran-NotificationAreaInfo is present)
    ...     message_alias=RRCRelease
    ...     flow_alias=${rrc_release}

Trigger RRCResume procedure for UE${ue_id:\d+} by running RNA update towards NRCELL-${cell_id:[1-3]} with fallback to RRCSetup
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup,RRCSetupComplete
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCRelease
    EXPECT FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete

    Execute egate command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} cell=${cell_id} gnb=2 cause=rna_Update
    Execute egate command    cmd=ue_nr_rrc_resume id=${ue_id}

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCResumeRequest1
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCSetup,RRCSetupComplete
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCRelease
    FAIL FLOW[timeout=5]: UE_${ue_id} NR-RRC RRCResume,RRCResumeComplete
    Verify that UE${ue_id} sends ResumeRequest with cause=rna-Update
    On failure
    ...     Verify that UE${ue_id} resume procedure was successfull via sending traffic

Verify that UE${ue_id:\d+} sends ResumeRequest with cause=${cause:\S+}
    ${resume_from_f1}      Get variable value      ${RESUME_FROM_F1AP}           ${False}
    ${flow_alias_f1}=
    ...     Get flow name
    ...     procedure=initialULRRCMessageTransfer
    ...     device=gNB2
    ...     protocol=F1AP
    ${flow_alias_ue}=
    ...     Get flow name
    ...     RRCResumeRequest1
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC
    ${flow_alias}=         Set variable if      ${resume_from_f1}==${True}    ${flow_alias_f1}    ${flow_alias_ue}
    ${msg_name}=           Set variable if      ${resume_from_f1}==${True}   InitialULRRCMessageTransfer     RRCResumeRequest1

    Verify That Message Fulfills Query
    ...     resumeCause eq '${cause}'
    ...     message_alias=${msg_name}
    ...     flow_alias=${flow_alias}

Verify that UE${ue_id:\d+} resume procedure was successfull via sending traffic
    Return From Keyword If     ${TRAFFIC_CHECK}==${False}           ${True}
    Run 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 15 seconds
    Verify 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Stop 5Mbps UL and DL traffic on UE${ue_id} PDU1 QFI1

Set UE${ue_id:\d+} paging response delay to ${value:\d+}s
    Execute egate command    cmd=ue_nr_rrc_setup_param id=${ue_id} pagingdelay=${value}s

Set UE${ue_id:\d+} to ${param:(drop|use)} ResumeRequest message
    ${egate_val}=       Set variable if      '${param}'=='drop'    drop    none
    Execute egate command    cmd=ue_rrc_resume_param id=${ue_id} if_contains=any action=${egate_val}

Change UE${ue_id:\d+} location to cell ${value:\d+}
    Execute egate command    cmd=ue_change_location id=${ue_id} enb=2 cell=${value}
