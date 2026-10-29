*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/messaging.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/verify_ta_messaging/verify_common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/verify_ta_messaging/verify_F1AP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/verify_ta_messaging/verify_E1AP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/verify_ta_messaging/verify_RRC.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/verify_ta_messaging/verify_XNAP.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/verify_ta_messaging/verify_NGAP.robot
Resource    taf/rfrl/bts/robot/common/gnb_cell.robot
Resource    ta_messaging/flow.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/verify_ta_messaging/verify_messages_flow/ta_messaging_flow.robot

Library     taf.hw.pdu
Library     OperatingSystem
Library     DateTime
Library     Telnet
Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_aashell
Library     ta5g_throughput
Library     ta5g_ue_mobility
Library     ta5g_cell_operations
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_egate
Library     ta5g_tshark
Library     ta5g_iperf_traffic
Library     ta5g_testline_management
Library     ta5g_commissioning
Library     ta5g_file_system
Library     ta5g_pm_counters
Library     ta_messaging
Library     taf.sbts.oam.coam.admin     WITH NAME   admin
Library     taf.transport.ssh     WITH NAME   ssh
Library     ta5g_ue_measurements
Variables    feature_variables.py

*** Variables ***
${WTS_DIR}                      /opt/wts/latest
${PDU_MODEL}=                   ${tl.pdus[0].__class__.__name__}
${PDU_IP}=                      ${tl.pdus[0].addr}
${PDU_PORT_AP}=                 ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_PORT}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
@{swconfig_8717_rdFlag}=        0x890057=0 # rdActNrDualConnectivity - Parameter set to 0 implies intraGnb NR-DC enabled in all cells
@{REMOTE_HOSTS}=                ${EMPTY}

*** Keywords ***
Create GNB alias
    Create GNB device with alias 'gNB' identified by ip=10.0.1.2
    Enable internal mirroring for alias    gNB

Setup devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.3
    Enable internal mirroring for alias  gNB2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

On failure
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_on_failure}=   get variable value        ${ON_FAILURE}         CONTINUE

    Run Keyword if  '${if_on_failure}' == 'CONTINUE'
    ...         Run Keyword And Continue On Failure
    ...         @{keyword_name_with_args}

    Run Keyword if  '${if_on_failure}' == 'IGNORE'
    ...         Run Keyword and ignore error
    ...         @{keyword_name_with_args}

Waiting For PDU Session Establishment
    Sleep    2s

Waiting For Message Flow To Set Up
    [Arguments]    ${time}=2s
    Sleep    ${time}

Wait ${x:\d+}s For ${reason}
    Sleep    ${x}s    ${reason}

Setup multigNB devices aliases
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.3
    Enable internal mirroring for alias  gNB2
    Enable internal mirroring for alias  gNB3
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Establish X2 Link
    [Arguments]    ${enb}    ${gnb}
    Execute Egate Command And Wait For Data
    ...     cmd=enb_x2_link_up enb=${enb} target=${gnb}
    ...     timeout=60
    ...     pass_regexp=X2AP Link with GNB-${gnb}

Establish Xn Link
    [Arguments]    ${source_gnb_id}    ${target_gnb_id}
    Execute Egate Command    cmd=gnb_param id=${source_gnb_id} xn_listening_socket=1 send_xn_setup=1
    Execute Egate Command And Wait For Data
    ...    cmd=gnb_xn_link_up gnb=${source_gnb_id} target=${target_gnb_id}
    ...    timeout=60
    ...    pass_regexp=XnAP Link with GNB-${target_gnb_id}

Verify If Proper Cells Are In Service State In Unlocked Two Cells And Added Two Cells Scenario
    Verify Tcpdump Log    ${F1AP_CELL_STATE_IN_SERVICE}    number_of_messages=6

Trigger RRC SCGFailureInformation By Random Access Problem
    [Arguments]    ${ue_id}=1
     Execute Egate Command   cmd=ue_dc_rlf ue=${ue_id} failure_type=random_access_problem at=gnb

Trigger RRC SCGFailureInformation With FailureType Set To T310-Expiry
    [Arguments]    ${ue_id}=1
     Execute Egate Command   cmd=ue_dc_rlf ue=${ue_id} failure_type=T310_expiry at=gnb

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} With PDU${pdu_id:\d+} And QoS Flow ID Eq ${qosflows:\d+}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

Set ICS Flow
    Set expected message flow    iniCtxSet=1

Verify ICS Flow
     Verify expected message flow    iniCtxSet=1

Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Set expected message flow   ue_id=${ue_id}    gnb_id=${gnb_id}    sNnodeAddPrep=1    bearerCtxMod=2    uECtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1    rrcReconf=1    rrcReconfCompl=1    sNnodeReconfCompl=1     pduSessResModInd=1

Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    gnb_id=${gnb_id}    sNnodeAddPrep=1    bearerCtxMod=2    uECtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1    rrcReconf=1    rrcReconfCompl=1    sNnodeReconfCompl=1     pduSessResModInd=1

Set Expected Message Flow For ICS And A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Set expected message flow   ue_id=${ue_id}    gnb_id=${gnb_id}    iniCtxSet=1    sNnodeAddPrep=1    bearerCtxMod=2    uECtxMod=2
    ...    xnUAddressInd=1    sNStatusTransfer=1    rrcReconf=3    rrcReconfCompl=3    sNnodeReconfCompl=1     pduSessResModInd=1

Verify Expected Message Flow For ICS And A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Verify expected message flow   ue_id=${ue_id}    gnb_id=${gnb_id}    iniCtxSet=1    sNnodeAddPrep=1    bearerCtxMod=2    uECtxMod=2
    ...    xnUAddressInd=1    sNStatusTransfer=1    rrcReconf=3    rrcReconfCompl=3    sNnodeReconfCompl=1     pduSessResModInd=1

Set Expected Message Flow For Rejection Of A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Set expected message flow    ue_id=${ue_id}    gnb_id=${gnb_id}   uECtxMod=4
        ...     rrcReconf=2    rrcReconfCompl=2     F1APprivateMSg=2

Verify Expected Message Flow For Rejection Of A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    gnb_id=${gnb_id}   uECtxMod=4
        ...     rrcReconf=2    rrcReconfCompl=2     F1APprivateMSg=2

Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
     Set expected message flow    ue_id=${ue_id}    gnb_id=${gnb_id}    sNnodeAddPrep=1    bearerCtxSet=1   bearerCtxMod=1    uECtxSet=1
        ...     sNnodeReconfCompl=1    xnUAddressInd=1    sNStatusTransfer=1

Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
     Verify expected message flow    ue_id=${ue_id}    gnb_id=${gnb_id}    sNnodeAddPrep=1    bearerCtxSet=1    bearerCtxMod=1    uECtxSet=1
        ...     sNnodeReconfCompl=1    xnUAddressInd=1    sNStatusTransfer=1

Set Expected Message Flow For Takeback On MN Side
     Set expected message flow    SNodeReleaseRequest=1    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2    rrcReconf=1     rrcReconfCompl=1
        ...     pduSessResModInd=1     SCGFailureInfo=1

Verify Expected Message Flow For Takeback On MN Side
     Verify expected message flow    SNodeReleaseRequest=1    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2      rrcReconf=1    rrcReconfCompl=1
        ...     pduSessResModInd=1     SCGFailureInfo=1

Set Expected Message Flow For Takeback On MN Side After PDU Session Modification
     Set expected message flow    SNodeReleaseRequest=1    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2    rrcReconf=1     rrcReconfCompl=1
        ...     pduSessResModInd=1    pduSessResMod=1

Verify Expected Message Flow For Takeback On MN Side After PDU Session Modification
     Verify expected message flow    SNodeReleaseRequest=1    bearerCtxMod=2    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    uECtxMod=2      rrcReconf=1    rrcReconfCompl=1
        ...     pduSessResModInd=1    pduSessResMod=1

Set Expected Message Flow For Takeback On MN Side For RLC By SN DTX Detection
     [Arguments]    ${ue_id}=${ue_id}
     Set expected message flow    ue_id=${ue_id}    sNnodeReleaseRequired=1    bearerCtxMod=2    sNStatusTransfer=1
        ...     XNAPuECtxRelease=1    uECtxMod=2    rrcReconf=1     rrcReconfCompl=1    pduSessResModInd=1

Verify Expected Message Flow For Takeback On MN Side For RLC By SN DTX Detection
     [Arguments]    ${ue_id}=${ue_id}
     Verify expected message flow    ue_id=${ue_id}    sNnodeReleaseRequired=1    bearerCtxMod=2    sNStatusTransfer=1
        ...     XNAPuECtxRelease=1    uECtxMod=2      rrcReconf=1    rrcReconfCompl=1    pduSessResModInd=1

Set Expected Message Flow For Takeback On SN Side
     Set expected message flow    gnb_id=3    SNodeReleaseRequest=1    bearerCtxMod=2    uECtxMod=1  xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    bearerCtxRelease=1    F1APuECtxRelease=1

Verify Expected Message Flow For Takeback On SN Side
     Verify expected message flow    gnb_id=3    SNodeReleaseRequest=1    bearerCtxMod=2    uECtxMod=1    xnUAddressInd=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    bearerCtxRelease=1    F1APuECtxRelease=1

Set Expected Message Flow For Takeback On SN Side For RLC By SN DTX Detection
    [Arguments]    ${ue_id}=${ue_id}
     Set expected message flow    ue_id=${ue_id}    gnb_id=3    uECtxModReq=1    sNnodeReleaseRequired=1    bearerCtxMod=2    uECtxMod=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    bearerCtxRelease=1    F1APuECtxRelease=1

Verify Expected Message Flow For Takeback On SN Side For RLC By SN DTX Detection
     [Arguments]    ${ue_id}=${ue_id}
     Verify expected message flow    ue_id=${ue_id}    gnb_id=3    uECtxModReq=1    sNnodeReleaseRequired=1    bearerCtxMod=2    uECtxMod=1
        ...     sNStatusTransfer=1     XNAPuECtxRelease=1    bearerCtxRelease=1    F1APuECtxRelease=1

Get Values From GTP_Tunnel In ICS To Compare Later
    ${Ngap_transport_layer_adress}=    Get value of parameter from message
    ...    procedure=initialContextSetup     message=InitialContextSetupRequest    num_of_message=1
    ...    all=1    protocol=NGAP    device=AMF1    parameter=transportLayerAddress
    ${Ngap_gTP_TEID}=    Get value of parameter from message
    ...    procedure=initialContextSetup     message=InitialContextSetupRequest    num_of_message=1
    ...    all=1    protocol=NGAP    device=AMF1    parameter=gTP-TEID
    Set Test Variable    ${Ngap_transport_layer_adress}
    Set Test Variable    ${Ngap_gTP_TEID}

Set Expected Message Flow For A4 Measurement Configuration And Deconfiguration
    Set expected message flow    gnb_id=2     rrcReconf=3    rrcReconfCompl=3

Verify Expected Message For A4 Measurement Configuration And Deconfiguration
    Verify expected message flow    gnb_id=2     rrcReconf=3    rrcReconfCompl=3

Verify A4 Measurement Configuration With MeasId=${meas_id:\d+}, MeasObjectId=${object_id:\d+} and reportConfigId=${report_id:\d+} For UE${ue:\d+}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That measIdToAddModList Contains measId Set To ${meas_id} For UE${ue}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That measIdToAddModList Contains measObjectId Set To ${object_id} For UE${ue}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That measIdToAddModList Contains reportConfigId Set To ${report_id} For UE${ue}
Verify A4 Measurement Deconfiguration With MeasId=${meas_id:\d+} For UE${ue:\d+}
    Verify In RRC RRCReconfiguration_3 Out Of 3 That measIdToRemoveList Has ${meas_id} For UE${ue}

Start Vm Ethernet Interfaces For Simulated gNB
    Start Vm Ethernet Interface    if_name=eth3:GNB1_NG_ADDR    ip_with_mask=10.0.1.8/24
    Start Vm Ethernet Interface    if_name=eth3:GNB1_XN_ADDR    ip_with_mask=10.0.1.9/24

Prepare Sim gNB
    ${prepare_command}=    Catenate
    ...                    gnb_nrdc_param id=3 enable_dl_data_forwarding=off t_reordering=100 serving_cell_index_range_scg_nrdc=1:31
    ...                    direct_bearer_sn_addition_error=off include_candidate_cell_info_list_mn=on include_reestablish_pdcp=on
    ...                    include_data_fwd_info_from_source=on ue_sec_algo_first_bit_reserved=on allowed_bc_list_mrdc=1:1
    ...                    include_cgi_in_candidate_cell_info=off
    Execute Egate Command
    ...    cmd=${prepare_command}

Attach UE${ue_id:\d+} And Establish PDU Session On Simulated GNB${gnb_id:\d+} With ${x:\d+} Qos Flow/s
    Attach Ue    ue_id=${ue_id}    enb=${gnb_id}    cell=9
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=1
    Prepare Sim gNB
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Run Keyword If    '${x}' > '1'    Trigger PDU Session Modify Procedure For UE${ue_id} and QoS Flow ID eq 2

UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    [Arguments]    ${ue_id}=1    ${phycell_id}=52    ${target_gnb}=2    ${target_cells}=1    ${nr_rsrp}=127     ${tar_pdu_id}=1
    Execute Egate Command    cmd=ue_meas_param id=${ue_id} nr_neigh_cell=non_cfgd:${phycell_id} nr_rsrp=${nr_rsrp}
    Execute Egate Command    cmd=gnb_ue_nrdc_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} target_pdu_id_list=${tar_pdu_id}

Delay RRC Reconfiguration Complete During NR-DC Setup For UE${ue_id:\d+}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=4000

Reset Site And Verify That Counters Were Reset
    [Arguments]     ${counter_id_list}    ${local_moid}    ${remote_host}=None
    Trigger Site Reset    remote_host=${remote_host}
    Wait For Testline Icmp Echo Replies And Ssh Services
    Verify If Counters Were Not Incremented    counter_id_list=${counter_id_list}    local_moid=${local_moid}    remote_host=${remote_host}

Verify If Counters Were Not Incremented
    [Arguments]    ${counter_id_list}    ${local_moid}    ${remote_host}=None
        ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File    remote_host=${remote_host}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
            ...    counter_id_list=${counter_id_list}
            ...    value=0
            ...    local_moid=${local_moid}
            ...    filepath=${pm_counter_file}

Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Set expected message flow   ue_id=${ue_id}    gnb_id=${gnb_id}    uECtxMod=8    rrcReconf=3   rrcReconfCompl=3     sNnodeAddPrep=1
    ...   bearerCtxMod=2   xnUAddressInd=1    sNStatusTransfer=1      pduSessResModInd=1

Verify Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Addition On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Verify expected message flow   ue_id=${ue_id}    gnb_id=${gnb_id}    uECtxMod=8    rrcReconf=3    rrcReconfCompl=3     sNnodeAddPrep=1
    ...   bearerCtxMod=2   xnUAddressInd=1    sNStatusTransfer=1      pduSessResModInd=1

Enable Skipping QoS Validation For The UE${ue_id:\d+}
     Execute Egate Command   cmd=amf_ue_pdu_modify_indication_param id=1 ue=${ue_id} action=skip_qosflow_validation

Get Values From APIDs In SNnodeAddPrep
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB2
    ...     protocol=XNAP

    ${id-S-NG-RANnodeUEXnAPID}=    Get Value From Message By Index
    ...     flow_alias=${flow_alias}    message_alias=SNodeAdditionRequestAcknowledge    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1

    ${id-M-NG-RANnodeUEXnAPID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}    message_alias=SNodeAdditionRequestAcknowledge    parameter_name=NG-RANnodeUEXnAPID    index_of_value=0
    Set Suite Variable    ${id-M-NG-RANnodeUEXnAPID}
    Set Suite Variable    ${id-S-NG-RANnodeUEXnAPID}

Check Values From APIDs In SNodeReleaseRequest
    [Arguments]    ${id-S-NG-RANnodeUEXnAPID}=${id-S-NG-RANnodeUEXnAPID}    ${id-M-NG-RANnodeUEXnAPID}=${id-M-NG-RANnodeUEXnAPID}
    ...    ${all}=1    ${num_of_message}=1
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB2
    ...     protocol=XNAP
    ${suffix}=    Set variable if    ${all}==1    ${EMPTY}    _${num_of_message}

    ${id-S-NG-RANnodeUEXnAPID-SnodeRelease}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}    message_alias=SNodeReleaseRequest${suffix}    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1

    ${id-M-NG-RANnodeUEXnAPID-SnodeRelease}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}    message_alias=SNodeReleaseRequest${suffix}    parameter_name=NG-RANnodeUEXnAPID    index_of_value=0

     Should Be True    ${id-S-NG-RANnodeUEXnAPID-SnodeRelease}==${id-S-NG-RANnodeUEXnAPID}
     Should Be True    ${id-M-NG-RANnodeUEXnAPID-SnodeRelease}==${id-M-NG-RANnodeUEXnAPID}

Check Values From APIDs In SNodeReleaseRequired
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB2
    ...     protocol=XNAP
    ${id-S-NG-RANnodeUEXnAPID-SNodeRelease}=    Get Value From Message By Index
      ...    flow_alias=${flow_alias}    message_alias=SNodeReleaseRequired    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1
    ${id-M-NG-RANnodeUEXnAPID-SNodeRelease}=    Get Value From Message By Index
      ...    flow_alias=${flow_alias}    message_alias=SNodeReleaseRequired    parameter_name=NG-RANnodeUEXnAPID    index_of_value=0
     Should Be True    ${id-S-NG-RANnodeUEXnAPID-SNodeRelease}==${id-S-NG-RANnodeUEXnAPID}
     Should Be True    ${id-M-NG-RANnodeUEXnAPID-SNodeRelease}==${id-M-NG-RANnodeUEXnAPID}

Check Values From APIDs In XnUAddressIndication
    [Arguments]    ${id-newNG-RANnodeUEXnAPID}=1    ${id-oldNG-RANnodeUEXnAPID}=0
    ${flow_alias}=     Get flow name
    ...     procedure=xnUAddressIndication
    ...     device=gNB2
    ...     protocol=XNAP
    ${NG-RANnodeUEXnAPID_value_0}=    Get Value From Message By Index
      ...    flow_alias=${flow_alias}    message_alias=XnUAddressIndication    parameter_name=NG-RANnodeUEXnAPID    index_of_value=0
    ${NG-RANnodeUEXnAPID_value_1}=    Get Value From Message By Index
      ...    flow_alias=${flow_alias}    message_alias=XnUAddressIndication    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1
    Should Be True    ${NG-RANnodeUEXnAPID_value_0}==${id-newNG-RANnodeUEXnAPID}
    Should Be True    ${NG-RANnodeUEXnAPID_value_1}==${id-oldNG-RANnodeUEXnAPID}

Check Values From APIDs In XnAP ActivityNotification
    [Arguments]    ${id-M-NG-RANnodeUEXnAPID}=1    ${id-S-NG-RANnodeUEXnAPID}=0
    ${flow_alias}=     Get flow name
    ...     procedure=activityNotification
    ...     device=gNB2
    ...     protocol=XNAP
    ${NG-RANnodeUEXnAPID_value_0}=    Get Value From Message By Index
      ...    flow_alias=${flow_alias}    message_alias=ActivityNotification    parameter_name=NG-RANnodeUEXnAPID    index_of_value=0
    ${NG-RANnodeUEXnAPID_value_1}=    Get Value From Message By Index
      ...    flow_alias=${flow_alias}    message_alias=ActivityNotification    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1
    Should Be True    ${NG-RANnodeUEXnAPID_value_0}==${id-M-NG-RANnodeUEXnAPID}
    Should Be True    ${NG-RANnodeUEXnAPID_value_1}==${id-S-NG-RANnodeUEXnAPID}

Check Values From APIDs In XNUeContextRelease
    [Arguments]    ${id-S-NG-RANnodeUEXnAPID}=${id-S-NG-RANnodeUEXnAPID}    ${id-M-NG-RANnodeUEXnAPID}=${id-M-NG-RANnodeUEXnAPID}
    ...    ${all}=1    ${num_of_message}=1
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextRelease
    ...     device=gNB2
    ...     protocol=XNAP
    ${suffix}=    Set variable if    ${all}==1    ${EMPTY}    _${num_of_message}

    ${id-sourceNG-RANnodeUEXnAPID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}    message_alias=UEContextRelease${suffix}    parameter_name=NG-RANnodeUEXnAPID    index_of_value=0

    ${id-targetNG-RANnodeUEXnAPID}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}    message_alias=UEContextRelease${suffix}    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1

     Should Be True    ${id-sourceNG-RANnodeUEXnAPID}==${id-S-NG-RANnodeUEXnAPID}
     Should Be True    ${id-targetNG-RANnodeUEXnAPID}==${id-M-NG-RANnodeUEXnAPID}

Perform Command To Drop RRC Reconfiguration Complete Message
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=drop

Set Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On MN Side
    Set expected message flow     gnb_id=2      pduSessResRel=1        SNodeReleaseRequest=1       XNAPuECtxRelease=1
        ...     rrcReconf=1     rrcReconfCompl=0     NGAPueCtxReleaseReq=1        uECtxMod=1
        ...     bearerCtxMod=1     NGAPueCtxRelease=1     F1APuECtxRelease=1    bearerCtxRelease=1     rrcRelease=1

Verify Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On MN Side
     Verify expected message flow     gnb_id=2      pduSessResRel=1        SNodeReleaseRequest=1       XNAPuECtxRelease=1
        ...     rrcReconf=1     rrcReconfCompl=0     NGAPueCtxReleaseReq=1        uECtxMod=1
        ...     bearerCtxMod=1     NGAPueCtxRelease=1     F1APuECtxRelease=1    bearerCtxRelease=1     rrcRelease=1

Set Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On SN Side
    Set expected message flow     gnb_id=3      SNodeReleaseRequest=1        uECtxMod=1
        ...     bearerCtxMod=1     XNAPuECtxRelease=1    F1APuECtxRelease=1     bearerCtxRelease=1

Verify Expected Message Flow For PDU Session Release Without RRC Reconfiguration Complete Message On SN Side
     Verify expected message flow     gnb_id=3      SNodeReleaseRequest=1     uECtxMod=1
        ...     bearerCtxMod=1     XNAPuECtxRelease=1    F1APuECtxRelease=1     bearerCtxRelease=1

Send Command To Delay SNodeReleaseRequestAcknowledge Message
    [Arguments]    ${ue_id}=1    ${gnb_id}=3    ${delay_time}=3000
    Execute egate command   cmd=ue_gnb_snode_release_request_param id=${ue_id} gnb_id=${gnb_id} action=delayed_rsp delay=${delay_time}

Setup devices aliases for realMN simSN
    Create UEs alias    alias=UE   id_type=wts_5g
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create GNB device with alias 'gNB3' identified by ip=10.0.1.3
    Enable internal mirroring for alias  gNB2
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Check Values From APIDs in XnapUEContextRelease
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB2
    ...     protocol=XNAP

    ${source-RANnodeUEXnAPID-UEContextRelease}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}    message_alias=UEContextRelease    parameter_name=NG-RANnodeUEXnAPID    index_of_value=0

    ${target-RANnodeUEXnAPID-UEContextRelease}=    Get Value From Message By Index
    ...    flow_alias=${flow_alias}    message_alias=UEContextRelease    parameter_name=NG-RANnodeUEXnAPID    index_of_value=1

     Should Be True    ${source-RANnodeUEXnAPID-UEContextRelease}==${id-S-NG-RANnodeUEXnAPID}
     Should Be True    ${target-RANnodeUEXnAPID-UEContextRelease}==${id-M-NG-RANnodeUEXnAPID}

Delay RRCReconfigurationComplete
    [Arguments]    ${ue_id}=1    ${delay_time}=10000
    Execute Egate Command     cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=${delay_time}

Trigger Radio Link Failure On Sim gNB
    [Arguments]    ${cause}    ${ue_id}=1    ${target_gnb}=3
    Execute Egate Command    cmd=gnb_ue_nrdc_release ue=${ue_id} cause=${cause} target_gnb=${target_gnb}

Perform Command To Delay Snode Release Request
    [Arguments]    ${ue_id}=1    ${gnb_id}=2    ${action}=delayed_rsp     ${delay_time}=2000
    Execute egate command   cmd=ue_gnb_snode_release_request_param id=${ue_id} gnb_id=${gnb_id} action=${action} delay=${delay_time}

Perform Command To Release Ue By AMF
    [Arguments]    ${ue_id}=1
    Execute egate command   cmd=ue_deregister id=${ue_id} by=amf

Perform RLF By GNB DU SN DTX Detection
    [Arguments]    ${ue_id}=1    ${profile}=6    ${cell_group}=SCG    ${timeout}=60
    Execute Egate Command
    ...     cmd=rlf_testmode_nr profile_id=${profile} num_stop_csi_report=1000 num_stop_dlharq_tx=2000
    ...     timeout=${timeout}
    Execute Egate Command
    ...     cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=${profile} cell_group=${cell_group}
    ...     timeout=${timeout}
    Wait 5s For NRDC Takeback

Perform Command To Trigger Snode Release Confirm Param
    [Arguments]    ${gnb_id}=3    ${action}=skip_sending
    Execute egate command   cmd=gnb_snode_release_confirm_param id=${gnb_id} action=${action}

Perform Command To Configure Behavior Of AMF During RAN Initiated PDU Session Modification Procedure
    [Arguments]    ${ue_id}=1    ${action}=skip_qosflow_validation
    Execute egate command   cmd=amf_ue_pdu_modify_indication_param id=1 ue=${ue_id} action=${action}

Perform Commnad To Configure SMF Parameters
    [Arguments]    ${qos_id}=1
    Execute egate command   cmd=smf_param id=1 additional_qosflows_to_activate=${qos_id}

Trigger UPF Sim to send GTP-U Error Indication to gNB
    [Arguments]    ${ue_id}=1    ${pdu_id}=2
    Execute egate command   cmd=upf_ue_pdu_inject_error_ind id=1 ue=${ue_id} pdu=${pdu_id}

Change XNAP:XnUAddressIndication
    [Arguments]    ${gnb_id}=3    ${action}=override_ie    ${other_parameter}=old_xnap_ue_id    ${other_parameter_value}=1111
    Execute Egate Command
        ...    cmd=gnb_xnu_address_indication_param id=${gnb_id} action=${action} ${other_parameter}=${other_parameter_value}

Send Command To Not Send SNodeModificationConfirm Message
    [Arguments]     ${gnb_id}=3
    Execute egate command   cmd=gnb_nrdc_modify_param id=${gnb_id} action=do_not_send_confirm
    Sleep  5s    Wait Measurement To Configure
