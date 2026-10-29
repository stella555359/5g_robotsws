*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      -   <.@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Resource    ../../resources/verifiers.robot
Resource    ../../resources/yaml_config_paths.robot
Library     taf.ul.ue.sim.env_setup
Library     tnl_verification.py
Library     qosflow_verification.py
Library     ta5g_tshark
Library     ute_tshark

*** Variables ***
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=   1=1  2=2  3=3  4=4  71=5  72=6  76=7  212=9  5=11  6=12  7=13  8=14  9=15  128=16  170=17  254=18

${yaml_5qi_ulngutnl_qosflow_mod}=    ${CURDIR}/../config/yaml_config/CB008126_enable.yaml
${yaml_5QI_config}=                  ${CURDIR}/../config/yaml_config/5QI_1_2_3_4_71_72_76_128_170_212_254.yaml
${NRPMQAP_profiles_yaml_path}=       ${CURDIR}/../config/yaml_config/NRPMQAP_counter_profiles.yaml
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}    ${SIB_config_yaml_path}    ${gNBSim_path}
...                             ${yaml_5QI_config}    ${VoNR_GBR}    ${yaml_5qi_ulngutnl_qosflow_mod}
...                             ${NRPMQAP_profiles_yaml_path}
${DEFAULT_USE_ADMIN}=           ${False}
${NGU_ADDR}=     10.0.1.1
${ADDITIONAL_NGU_ADDR}=     10.0.1.200



*** Keywords ***
Run Setup
    [Arguments]    ${f1ap}=${False}     ${cell_messages}=${False}

    Log To Console    Setup started
#    Reliable emss setup    bts_id=1
    ${run_update}    Get variable value      ${configure}    True     # do not ever change that line!
    Run Keyword if  '${run_update}' == 'True'
    ...    Reach onAir state
    Setup devices aliases
    Setup egate  egate_port=20000  alias=default
    Run Keyword if  ${f1ap} != ${False}
    ...    Enable internal mirroring for alias  gNB2
    Run Keyword if  ${cell_messages} != ${False}
    ...    create cells alias       alias=NRCELL   cells_type=wts_5g
    save_initial_qosflow_configuration_from_egate

Reach onAir state
    [Arguments]
#    Run Keyword if  ${different_tacs} != ${False} and ${disable_ran_sharing} != ${False}
#    ...     Fail    Operation not permitted: conflict in yamls when disabling ran sharing and using different tac per cell
    ${cm_topology}     get_topology_label_from_multiple_ute_sources
    ${cm_variant}       get_variant_from_multiple_ute_sources
#    ${disable_ran_sharing_yaml_path_option}=        set variable if    '${cm_variant}'!='SANSA_FS_ECPRI_CMWV_TDD_TEMP'
#    ...      ${disable_ran_sharing_yaml_path_4_cells}
#    ...      ${disable_ran_sharing_yaml_path}
#    Run Keyword if  ${some_value} != ${False}
#    ...     Run keywords8
#    ...     append to list      ${yaml_paths_to_configure}       ${some_value_yaml}     AND
#    ...     Log to console      Applied some_value

    ${use_admin_val}    Get variable value      ${USE_ADMIN}    ${DEFAULT_USE_ADMIN}
    Configure       ${yaml_paths_to_configure}     use_admin=${use_admin_val}
    Wait for gnb to reach configured state
    Discover bts
    Run keyword and ignore error      get_lua_for_topology
    ${lua_cfg_arg}=      get variable value          ${RETURN_LUA_VAR_NAME}        ${LUA_CFG}
    Log To Console    Before Reach OnAir
    Add 5GC    config=${lua_cfg_arg}    edaemon_ports=10000
    Configure environment    rmod_detection_timeout=420s
    Log To Console    After Reach OnAir
    RTPM activate

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.30
    Create GNB device with alias 'gNB3_XN' identified by ip=10.0.1.31
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Verify that primary UL NG-U UP TNL address is configured for ${type:(initial|added)} PDU${pdu_id:\d+} for UE${ue_id:\d+}
    ${procedure}=    set variable if    '${type}' == 'initial'    initialContextSetup           pDUSessionResourceSetup
    ${msg}=          set variable if    '${type}' == 'initial'    InitialContextSetupRequest    PDUSessionResourceSetupRequest

    ${flow_alias}=     Get flow name
    ...     procedure=${procedure}
    ...     device=AMF1
    ${tnl}=    get_ul_tnl_ip_teid    ${flow_alias}    ${msg}    ${pdu_id}
    ${ul_ngu_ip}=    convert_to_bin_from_ip    ${NGU_ADDR}    with_format=True
    Should be equal      ${tnl}[transportLayerAddress]    ${ul_ngu_ip}
    Set test variable    ${old_tnl_UE${ue_id}_PDU${pdu_id}}    ${tnl}
    Set test variable    ${current_tnl_UE${ue_id}_PDU${pdu_id}}    ${tnl}

Verify that UL NG-U UP TNL ${what:(IP and TEID|TEID only)} is requested to be modified for PDU${pdu_id:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1
    ${tnl}=    get_ul_tnl_ip_teid    ${flow_alias}    PDUSessionResourceModifyRequest    ${pdu_id}
    ${ngu_ip}=    convert_to_bin_from_ip    ${NGU_ADDR}    with_format=True
    ${additional_ngu_ip}=    convert_to_bin_from_ip    ${ADDITIONAL_NGU_ADDR}    with_format=True
    Run keyword if    '${what}' == 'IP and TEID'
    ...                Should not be equal    ${tnl}[transportLayerAddress]    ${current_tnl_UE${ue_id}_PDU${pdu_id}}[transportLayerAddress]
    Run keyword if    '${what}' == 'IP and TEID'
    ...                Should be true    ${tnl}[transportLayerAddress] == ${ngu_ip} or ${tnl}[transportLayerAddress] == ${additional_ngu_ip}
    Run keyword if    '${what}' == 'TEID only'
    ...                Should be equal    ${tnl}[transportLayerAddress]   ${current_tnl_UE${ue_id}_PDU${pdu_id}}[transportLayerAddress]
    Run keyword if    '${what}' == 'TEID only'
    ...                should not be equal    ${tnl}[gTP-TEID]    ${current_tnl_UE${ue_id}_PDU${pdu_id}}[gTP-TEID]
    Set test variable    ${requested_tnl_UE${ue_id}_PDU${pdu_id}}    ${tnl}

Verify that gNB applies new UL NG-U UP TNL address for PDU${pdu_id:\d+} for UE${ue_id}
    ${flow_alias_ngap}=     Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1
    ${flow_alias_e1ap}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    verify_ul_tnl_address_modification_is_forwarded_to_cu_up    ${flow_alias_ngap}    ${flow_alias_e1ap}   ${pdu_id}
    verify_tnl_address_in_pdu_mod_response_is_the_same_as_in_request    ${flow_alias_ngap}    ${pdu_id}
    Set test variable    ${old_tnl_UE${ue_id}_PDU${pdu_id}}    ${current_tnl_UE${ue_id}_PDU${pdu_id}}
    Set test variable    ${current_tnl_UE${ue_id}_PDU${pdu_id}}    ${requested_tnl_UE${ue_id}_PDU${pdu_id}}

Verify that modification of UL NG-U UP TNL address for PDU${pdu_id:\d+} is rejected by CU-UP with cause '${cause}'
    ${flow_alias_ngap}=     Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1
    ${flow_alias_e1ap}=     Get flow name
    ...     procedure=bearerContextModificationFailure
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq "${cause}")
    ...     message_alias=BearerContextModificationFailure
    ...     flow_alias=${flow_alias_e1ap}

    verify_ul_tnl_address_modification_is_forwarded_to_cu_up    ${flow_alias_ngap}    ${flow_alias_e1ap}   ${pdu_id}

Verify that gNB rejects PDU${pdu_id:\d+} session modification with cause = '${cause}'
    ${flow_alias}=  get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     PDUSessionResourceFailedToModifyListModRes contains
    ...     (
    ...       (cause contains (radioNetwork eq "${cause}"))
    ...       and
    ...       (pDUSessionID eq ${pdu_id})
    ...     )
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow_alias}

Setup tshark for traffic verification
    setup_tshark    interface=eth3    alias=GTP_traffic    log_dir=${OUTPUT_DIR}   log_name=GTP_traffic.pcap

Capture traffic for ${time} seconds
    Start capturing  alias=GTP_traffic    capture_filter=udp and src 10.0.1.2
    sleep    ${time}
    Stop capturing  alias=GTP_traffic

Verify that UL traffic for PDU${pdu_id:\d+} QFI${qfi_id:\d+} UE${ue_id:\d+} is present only on ${which:(new|old)} UL NG-U UP TNL address
    ${old_ip}=      convert_to_ip_from_bin    ${old_tnl_UE${ue_id}_PDU${pdu_id}}[transportLayerAddress]    with_format=True
    ${new_ip}=      convert_to_ip_from_bin    ${requested_tnl_UE${ue_id}_PDU${pdu_id}}[transportLayerAddress]    with_format=True
    ${old_teid}=    Set variable    ${old_tnl_UE${ue_id}_PDU${pdu_id}}[gTP-TEID]
    ${new_teid}=    Set variable    ${requested_tnl_UE${ue_id}_PDU${pdu_id}}[gTP-TEID]

    ${new_ip_pass_citeria}=    Set Variable If  '${which}' == 'new'  >=20   ==0
    ${old_ip__pass_citeria}=    Set Variable If  '${which}' == 'new'  ==0   >=20

    verify tshark
    ...    alias=GTP_traffic
    ...    packet_filter=(gtp.teid==${new_teid} && ip.src == 10.0.1.2 && ip.dst == ${new_ip} && gtp.ext_hdr.pdu_ses_con.qos_flow_id == ${qfi_id})
    ...    pass_criteria= ${new_ip_pass_citeria}

    verify tshark
    ...    alias=GTP_traffic
    ...    packet_filter=(gtp.teid==${old_teid} && ip.src == 10.0.1.2 && ip.dst == ${old_ip} && gtp.ext_hdr.pdu_ses_con.qos_flow_id == ${qfi_id})
    ...    pass_criteria= ${old_ip_pass_citeria}

Verify in NGAP Qos flows modify for 5QIs [${5qis_all}] where [${5qis_suc}] succeed and [${5qis_fail}] fail for PDU${pdu_id:\d+} with cause=${cause}
    @{5qis_success_list}=    Split To List    ${5qis_suc}
    ${length_of_5qis_success_list}=  Get length    ${5qis_success_list}

    @{5qis_fail_list}=    Split To List    ${5qis_fail}
    ${length_of_5qis_fail_list}=  Get length    ${5qis_fail_list}

    @{5qis_all_list}=    Split To List    ${5qis_all}
    ${5qis_all_tuple}=   Split To Integers Tuple    ${5qis_all}
    ${length_of_5qis_all_list}=  Get length    ${5qis_all_list}

    ${flow_alias}=    Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (length(QosFlowAddOrModifyRequestList) eq ${length_of_5qis_all_list})
    ...     and
    ...     (fiveQI contains ${5qis_all_tuple})
    ...     message_alias=PDUSessionResourceModifyRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (pDUSessionID eq ${pdu_id})
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...    	(
    ...    	PDUSessionResourceModifyListModRes is present
    ...    	and
    ...    	PDUSessionResourceFailedToModifyListModRes is not present
    ...    	and
    ...    	(
    ...    		(qosFlowAddOrModifyResponseList is present
    ...    		and
    ...    		length(qosFlowAddOrModifyResponseList) eq ${length_of_5qis_success_list}
    ...    		)
    ...    		and
    ...    		(
    ...    		(qosFlowFailedToAddOrModifyList is present
    ...    		and
    ...    		length(qosFlowFailedToAddOrModifyList) eq ${length_of_5qis_fail_list}
    ...         and
    ...         cause contains (radioNetwork eq "${cause}")
    ...    		)
    ...    		or
    ...    		qosFlowFailedToAddOrModifyList is not present
    ...    		)
    ...    	)
    ...    	)
    ...     or
    ...    	(
    ...    	PDUSessionResourceFailedToModifyListModRes is present
    ...    	and
    ...    	PDUSessionResourceModifyListModRes is not present
    ...     and
    ...     cause contains (radioNetwork eq "${cause}")
    ...    	)
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration that qosflows=[${5qis}] are successfuly added or modified for UE${ue_id:\d+}
    @{5qis_list}=    Split To List    ${5qis}
    ${5qis_tuple}=   Split To Integers Tuple    ${5qis}
    ${length_of_5qis_list}=  Get length    ${5qis_to_add_list}

    ${flow_alias}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq ${length_of_5qis_list})
    ...     and
    ...     (mappedQoS-FlowsToAdd contains (${5qis_tuple}))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Set 5QI5 resType to nonGBR
    ${5qi_mod}=    Catenate    {'MOC': 'NRDRB', 'ID': '10', 'resType': 'nonGBR'},
    ...                        {'MOC': 'NRDRB_MAC', 'ID': '6', 'lcgid': '1'}
    Configure    [${5qi_mod}]

Set 5QI5 resType to nonGBR_Signaling
    ${5qi_mod}=    Catenate    {'MOC': 'NRDRB', 'ID': '10', 'resType': 'nonGBR_Signaling'},
    ...                        {'MOC': 'NRDRB_MAC', 'ID': '6', 'lcgid': '0'}
    Configure    [${5qi_mod}]

Set 5QI170 resType to GBR
    Configure    {'MOC': 'NRDRB', 'ID': '23', 'resType': 'GBR', 'nrDrbMacDN': 'MRBTS-1/NRBTS-1/NRDRB_MAC-5'}

Set 5QI170 resType to nonGBR
    Configure    {'MOC': 'NRDRB', 'ID': '23', 'resType': 'nonGBR', 'nrDrbMacDN': 'MRBTS-1/NRBTS-1/NRDRB_MAC-12'}

Set QoS ${qos_id:\d+}(5QI${5qi_id:\d+}) as default for UE${ue_id:\d+} PDU${pdu_id:\d+}
    Execute egate command    cmd=qosflow_modify qos_flow=${qos_id} ue=${ue_id} default=on

Perform successful PDU${pdu_id:\d+} session modification, QoS Flow=${qos_id:\d+}(${5qi}->5QI${5qi_id:\d+}) for QFI${qfi_id:\d+} for UE${ue_id:\d+}
    Trigger PDU session modification    ue_id=${ue_id}    pdu=${pdu_id}    qos_to_mod=${qos_id}(${5qi}->5QI${5qi_id})
    Verify in RRCReconfiguration that QFI${qfi_id} is configured with 5QI${5qi_id} for UE${ue_id} for PDU${pdu_id}
    Verify in RRCReconfiguration that setup bearers have higher IDs than released bearers for UE${ue_id}

Verify in RRCReconfiguration that QFI${qfi_id:\d+} is configured with 5QI${5qi_id:\d+} for UE${ue_id:\d+} for PDU${pdu_id:\d+}
    ${flow_alias}=     Get flow name
    ...    RRCReconfiguration
    ...    device=UE_${ue_id}
    ...    protocol=NR-RRC
    verify_that_correct_nrdrb_was_applied_for_drb
    ...    RRCReconfiguration    ${flow_alias}    ${pdu_id}    ${qfi_id}    ${5qi_id}

Verify in RRCReconfiguration that setup bearers have higher IDs than released bearers for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...    RRCReconfiguration
    ...    device=UE_${ue_id}
    ...    protocol=NR-RRC
    verify_that_ids_of_setup_bearers_are_higher_than_released
    ...    RRCReconfiguration    ${flow_alias}


