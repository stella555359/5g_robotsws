*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers source based routing with different algorithms"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "--"
...     [Funtion_Hash_Tags]     "TRS -SBR"
...     [Feature_ID]            "CB010453"
...     [Requirement ID]        ""
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf"

*** Keywords ***
Modify Routing table and verify modified value
    Perform Recommissioning    type=delta       delta_file=${modify_iprt}
    ${preference}=    Get Parameter     param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-2:staticRoutes:preference
    Should Be Equal As Integers     ${preference}   10
    ${preSrcIpv4Addr}=    Get Parameter     param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-2:staticRoutes:preSrcIpv4Addr
    Should be equal     ${preSrcIpv4Addr}    10.0.3.210
    ${routeIpMtu}=    Get Parameter     param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-2:staticRoutes:routeIpMtu
    Should Be Equal As Integers     ${routeIpMtu}    200
    ${preference}=    Get Parameter     param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-2:staticIpv6Routes:preference
    Should Be Equal As Integers     ${preference}    20
    ${preSrcIpv6Addr}=    Get Parameter      param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-2:staticIpv6Routes:preSrcIpv6Addr
    Should be equal     ${preSrcIpv6Addr}    fc00::3:23
    ${routeIpMtu}=    Get Parameter     param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-2:staticIpv6Routes:routeIpMtu
    Should Be Equal As Integers     ${routeIpMtu}    9500

Delete Routing table and verify deleted value
    Perform Recommissioning    type=delta       delta_file=${delete_table}
    Run Keyword and expect error    *InfoModelQueryTimeoutException:*    Get Parameter
    ...    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-2:staticRoutes
    Run Keyword and expect error    *InfoModelQueryTimeoutException:*    Get Parameter
    ...    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-2:staticIpv6Routes

Verify persistent routing tables
    Get Parameter    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-1:staticRoutes
    Run Keyword and expect error    *InfoModelQueryTimeoutException:*    Get Parameter
    ...    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-2:staticRoutes
    Get Parameter    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-3:staticRoutes
    Get Parameter    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1:staticIpv6Routes
    Run Keyword and expect error    *InfoModelQueryTimeoutException:*    Get Parameter
    ...    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-2:staticIpv6Routes
    Get Parameter    param_path=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-3:staticIpv6Routes

Adding a source based routing policy fails due to no routing table
    Run Keyword and expect error     *AdminApiProcedureFailureException:*    Perform Recommissioning   type=delta    delta_file=${create_rtpol}

Sends the Egress packet with matching route policy
    ${IPIF_2_localIpAddr}=   Get Parameter  param_path=IPIF-2/IPADDRESSV4-1:localIpAddr
    ${IPRT_2_Gateway}=   Get Parameter  param_path=IPRT-2:staticRoutes:gateway
    ${IPRT_2_destIpAddr}=   Get Parameter  param_path=IPRT-2:staticRoutes:destIpAddr
    Execute Trace Route     ${IPRT_2_Gateway}   ${IPRT_2_destIpAddr}    ${IPIF_2_localIpAddr}

Sends the Egress packet without matching route policy
    Perform Recommissioning    type=delta       delta_file=${Delete_policy}
    ${IPRT_1_Gateway}=   Get Parameter  param_path=IPRT-1:staticRoutes:gateway
    ${IPIF_2_localIpAddr}=   Get Parameter  param_path=IPIF-2/IPADDRESSV4-1:localIpAddr
    ${IPRT_2_destIpAddr}=   Get Parameter  param_path=IPRT-2:staticRoutes:destIpAddr
    Execute Trace Route     ${IPRT_1_Gateway}   ${IPRT_2_destIpAddr}    ${IPIF_2_localIpAddr}

Sends the Egress packet with matching route policy with route
    Perform Recommissioning    type=delta       delta_file=${longest_prefix}
    ${IPIF_3_localIpAddr}=   Get Parameter  param_path=IPIF-3/IPADDRESSV4-1:localIpAddr
    ${IPRT_3_destIpAddr}=   Get Parameter  param_path=IPRT-3:staticRoutes:destIpAddr
    Execute Trace Route     ${IPRT_3_Gateway}   ${IPRT_3_destIpAddr}    ${IPIF_3_localIpAddr}

Sends the Egress packet with matching route policy without route
    Perform Recommissioning    type=delta       delta_file=${delete_route}
    ${IPRT_1_Gateway}=   Get Parameter  param_path=IPRT-1:staticRoutes:gateway
    ${IPIF_4_localIpAddr}=   Get Parameter  param_path=IPIF-4/IPADDRESSV4-1:localIpAddr
    Execute Trace Route     ${IPRT_1_Gateway}   ${IPRT_4_destIpAddr}    ${IPIF_4_localIpAddr}

Execute Trace Route
    [Arguments]     ${Gateway}  ${destination_ip}  ${source_ipaddress}
    Execute command on GNB      ip route get ${destination_ip} from ${source_ipaddress}
    ${response}    Set Variable    via ${Gateway} dev
    Should Contain      ${stdout}       ${response}

Perform Commissioning on vcu and vdu
    Setup Oamops    dut=cbts    alias=vcu
	Perform Commissioning	dut=cbts	scf_file=${Basic_SCFC_vCU}	verify_bts_status=False     alias=vcu
    Teardown Oamops     dut=cbts    alias=vcu
    Setup Oamops    dut=dbts    alias=vdu
    Perform Commissioning	dut=dbts	scf_file=${Basic_SCFC_vDU}	verify_bts_status=False     alias=vdu
    Teardown Oamops     dut=dbts    alias=vdu

Perform SBR configuration
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${SBR_VCU}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu	timeout=400
	Teardown Oamops     dut=cbts    alias=vcu
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${SBR_VCU}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu	timeout=400
	Teardown Oamops     dut=dbts    alias=vdu

Verifying alarm during Creation of deletion of conflicting IPRT and routing table for VCU
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${Conflict_Route}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu
    ...    timeout=400
	Sleep	30
	Verify Alarm       dut=cbts       faultid=61665        should_exist=${True}      timeout=120
	Verify Alarm       dut=cbts       faultid=61664        should_exist=${True}      timeout=120
	Perform Recommissioning     type=delta  delta_file=${Conflict_DELETE}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu
    ...    timeout=400
	Sleep	30
	Verify Alarm       dut=cbts       faultid=61665        should_exist=${False}      timeout=200
	Verify Alarm       dut=cbts       faultid=61664        should_exist=${False}      timeout=200

Verifying alarm during Creation of deletion of conflicting IPRT and routing table for VDU
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${Conflict_Route}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu
    ...    timeout=400
	Sleep	30
	Verify Alarm       dut=dbts       faultid=61665        should_exist=${True}      timeout=120
	Verify Alarm       dut=dbts       faultid=61664        should_exist=${True}      timeout=120
	Perform Recommissioning     type=delta  delta_file=${Conflict_DELETE}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu
    ...    timeout=400
	Sleep	30
	Verify Alarm       dut=cbts       faultid=61665        should_exist=${False}      timeout=200
	Verify Alarm       dut=cbts       faultid=61664        should_exist=${False}      timeout=200

Check SBR Routing And Gateway CPIF
    Setup Oamops    dut=vcu_465
    Setup Remote Access    remote_device=${dut}.ocp    alias=${dut}
    Execute Interactive Remote Command
    ...    command=kubectl exec -it -n trs-cran5 po-cpif-0 -c ctr-nwmgmt -- bash
    ...    alias=${dut}
    ${rules}=    Execute Interactive Remote Command    command=ip rule show    alias=${dut}
    @{lines}=    Split To Lines    ${rules}
    @{lookups}=    Create List
    FOR    ${line}    IN    @{lines}
        Run Keyword If    "lookup" not in """${line}"""    Continue For Loop
        Run Keyword If    "from all" in """${line}"""      Continue For Loop
        ${id}=    Fetch From Right    ${line}    lookup
        ${id}=    Strip String    ${id}
        Append To List    ${lookups}    ${id}
    END
    @{wrong_gateways}=    Create List
    FOR    ${id}    IN    @{lookups}
	${routes}=    Execute Interactive Remote Command    command=ip r s t ${id}    alias=${dut}
	${clean_routes}=    Replace String Using Regexp    ${routes}    \x1B\\[[0-9;]*[A-Za-z]    ${EMPTY}
	${gw}=    Get Regexp Matches    ${clean_routes}    via (\d+\.\d+\.\d+\.\d+)    1
	Run Keyword If    '${id}' not in ${EXPECTED_GATEWAYS_CPIF}    Continue For Loop
	${expected}=    Get From Dictionary    ${EXPECTED_GATEWAYS_CPIF}    ${id}
	Run Keyword If    ${gw}    Should Be Equal As Strings    ${gw[0]}    ${expected}
            END
    Execute Interactive Remote Command    command=exit    alias=${dut}

Check SBR Routing And Gateway UPUE
    Setup Oamops    dut=vdu_465
    Setup Remote Access    remote_device=${dut}.ocp    alias=${dut}
    Execute Interactive Remote Command
    ...    command=kubectl exec -it -n trs-cran5 po-upue-0 -c ctr-nwmgmt -- bash
    ...    alias=${dut}
    ${rules}=    Execute Interactive Remote Command    command=ip rule show    alias=${dut}
    @{lines}=    Split To Lines    ${rules}
    @{lookups}=    Create List
    FOR    ${line}    IN    @{lines}
        Run Keyword If    "lookup" not in """${line}"""    Continue For Loop
        Run Keyword If    "from all" in """${line}"""      Continue For Loop
        ${id}=    Fetch From Right    ${line}    lookup
        ${id}=    Strip String    ${id}
        Append To List    ${lookups}    ${id}
    END
    @{wrong_gateways}=    Create List
    FOR    ${id}    IN    @{lookups}
	${routes}=    Execute Interactive Remote Command    command=ip r s t ${id}    alias=${dut}
	${clean_routes}=    Replace String Using Regexp    ${routes}    \x1B\\[[0-9;]*[A-Za-z]    ${EMPTY}
	${gw}=    Get Regexp Matches    ${clean_routes}    via (\d+\.\d+\.\d+\.\d+)    1
	Run Keyword If    '${id}' not in ${EXPECTED_GATEWAYS_UPUE}    Continue For Loop
	${expected}=    Get From Dictionary    ${EXPECTED_GATEWAYS_UPUE}    ${id}
	Run Keyword If    ${gw}    Should Be Equal As Strings    ${gw[0]}    ${expected}
            END
    Execute Interactive Remote Command    command=exit    alias=${dut}

Check SBR Routing And Gateway CPRT
    Setup Oamops    dut=vdu_465
    Setup Remote Access    remote_device=${dut1}.ocp    alias=${dut1}
    Execute Interactive Remote Command
    ...    command=kubectl exec -it -n trs-cran5 po-cprt-0 -c ctr-nwmgmt -- bash
    ...    alias=${dut1}
    ${rules}=    Execute Interactive Remote Command    command=ip rule show    alias=${dut1}
    @{lines}=    Split To Lines    ${rules}
    @{lookups}=    Create List
    FOR    ${line}    IN    @{lines}
        Run Keyword If    "lookup" not in """${line}"""    Continue For Loop
        Run Keyword If    "from all" in """${line}"""      Continue For Loop
        ${id}=    Fetch From Right    ${line}    lookup
        ${id}=    Strip String    ${id}
        Append To List    ${lookups}    ${id}
    END
    @{wrong_gateways}=    Create List
    FOR    ${id}    IN    @{lookups}
	${routes}=    Execute Interactive Remote Command    command=ip r s t ${id}    alias=${dut1}
	${clean_routes}=    Replace String Using Regexp    ${routes}    \x1B\\[[0-9;]*[A-Za-z]    ${EMPTY}
	${gw}=    Get Regexp Matches    ${clean_routes}    via (\d+\.\d+\.\d+\.\d+)    1
	Run Keyword If    '${id}' not in ${EXPECTED_GATEWAYS_CPRT}    Continue For Loop
	${expected}=    Get From Dictionary    ${EXPECTED_GATEWAYS_CPRT}    ${id}
	Run Keyword If    ${gw}    Should Be Equal As Strings    ${gw[0]}    ${expected}
            END
    Execute Interactive Remote Command    command=exit    alias=${dut1}

Check SBR Routing And Gateway L2NRT
    Setup Oamops    dut=vdu_465
    Setup Remote Access    remote_device=${dut1}.ocp    alias=${dut}
    Execute Interactive Remote Command
    ...    command=kubectl exec -it -n trs-cran5 po-l2nrt-0 -c ctr-nwmgmt -- bash
    ...    alias=${dut1}
    ${rules}=    Execute Interactive Remote Command    command=ip rule show    alias=${dut1}
    @{lines}=    Split To Lines    ${rules}
    @{lookups}=    Create List
    FOR    ${line}    IN    @{lines}
        Run Keyword If    "lookup" not in """${line}"""    Continue For Loop
        Run Keyword If    "from all" in """${line}"""      Continue For Loop
        ${id}=    Fetch From Right    ${line}    lookup
        ${id}=    Strip String    ${id}
        Append To List    ${lookups}    ${id}
    END
    @{wrong_gateways}=    Create List
    FOR    ${id}    IN    @{lookups}
	${routes}=    Execute Interactive Remote Command    command=ip r s t ${id}    alias=${dut1}
	${clean_routes}=    Replace String Using Regexp    ${routes}    \x1B\\[[0-9;]*[A-Za-z]    ${EMPTY}
	${gw}=    Get Regexp Matches    ${clean_routes}    via (\d+\.\d+\.\d+\.\d+)    1
	Run Keyword If    '${id}' not in ${EXPECTED_GATEWAYS_L2NRT}    Continue For Loop
	${expected}=    Get From Dictionary    ${EXPECTED_GATEWAYS_L2NRT}    ${id}
	Run Keyword If    ${gw}    Should Be Equal As Strings    ${gw[0]}    ${expected}
            END
    Execute Interactive Remote Command    command=exit    alias=${dut1}

Setup access
    Setup Oamops    dut=cbts    alias=vcu
    Setup Oamops    dut=dbts    alias=vdu

Attach UE and send ul dl traffic
   [Documentation]        This test case keyword is to trigger the calls
   Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
   Sleep	60
   Configure UE    5g=5g_basic_setup_cfg:data        command=ue_register   id=1
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=set_pdu_param     ue=1    pdu=1   trf_type=internal
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=ue_pdu_session_setup  pdu=1   gw=1    ue=1
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=1    pdu=1   qfi=1   dir=dl  trf_id=1    mbps=20    protocol=tcp
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=1    pdu=1   qfi=1   dir=ul  trf_id=1    mbps=20    protocol=tcp
   Sleep     20

Stop traffic and detach UE
   [Documentation]        This test case keyword is to stop the Calls
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_stop        ue=1        dir=dl
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_stop        ue=1        dir=ul
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
   Sleep     20
   Call Teardown      5g=5g_basic_setup_cfg:data

Get downloaded pcaps of vDU
    ${uplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-l2nrt-0
    ${cplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-cprt-0
    set suite variable  ${uplane_pcap}  ${uplane_pcap}
    set suite variable  ${cplane_pcap}  ${cplane_pcap}

Analyse downloaded pcaps of vDU
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_Uplane_l2nrt_ul     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_Uplane_l2nrt_ul     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cplane_pcap}        analysis=traffic_cplane_cprt_ul     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cplane_pcap}        analysis=traffic_cplane_cprt_dl     filter_file_name=traffic_filters.json

Get downloaded pcaps of vCU
    ${uplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-upue-0
    ${cplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-cpif-0
    set suite variable  ${uplane_pcap}  ${uplane_pcap}
    set suite variable  ${cplane_pcap}  ${cplane_pcap}

Analyse downloaded pcaps of vCU
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_ul_vcu     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_dl_vcu     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cplane_pcap}        analysis=traffic_cplane     filter_file_name=traffic_filters.json

Start traffic Capture for VCU and analyze
    Setup access
	traffic_capture_start   capture_device=vCU     capture_type=plane    plane_type=['cplane','uplane','mplane']
    ...    pod_names=['po-trs-cran5-cpif-0','po-trs-cran5-upue-0','po-trs-cran5-oamext-0']    measurement_point=NE_Terminated    timeout=180
    ...    alias=vcu
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Stop traffic and detach UE
    Call Teardown      5g=5g_basic_setup_cfg:data
    traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcu   keep_alias=True
    Sleep   30
    generate_capture_files     capture_device=vCU        timeout=180    alias=vcu
    Sleep   60
    Run     rm -r ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['cplane','uplane','mplane']
    ...    local_path=${pcaps_dir}    timeout=180  alias=vcu
    Get downloaded pcaps of vCU
    Analyse downloaded pcaps of vCU

Start traffic Capture for VDU and analyze
    traffic_capture_start   capture_device=vDU     capture_type=plane    plane_type=['cplane','uplane','mplane']
    ...    pod_names=['po-trs-cran5-cprt-0','po-trs-cran5-cprt-0']    measurement_point=NE_Terminated    timeout=180    alias=vdu_1
    Sleep   100
    traffic_capture_stop   capture_device=vDU      timeout=180  alias=vdu_1   keep_alias=True
    Sleep   30
    generate_capture_files     capture_device=vDU        timeout=180    alias=vdu_1
    Sleep   60
    Run     rm -r ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vDU      capture_type=plane      plane_type=['cplane','uplane','mplane']
    ...    local_path=${pcaps_dir}    timeout=180  alias=vdu_1
    Get downloaded pcaps of vDU
    Analyse downloaded pcaps of vDU

Verify Maximum configuration for CPIF
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${Maximum_IPRT_CPIF}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu
    ...    timeout=500
    Teardown Oamops     dut=cbts    alias=vcu
	Sleep	60
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${Maximum_RTPOL_CPIF}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu
    ...    timeout=500
    Teardown Oamops     dut=cbts    alias=vcu

Verify Maximum configuration for UPUE
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${Maximum_IPRT_UPUE}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu
    ...    timeout=500
    Teardown Oamops     dut=cbts    alias=vcu
	Sleep	60
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${Maximum_RTPOL_UPUE}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu
    ...    timeout=500
    Teardown Oamops     dut=cbts    alias=vcu

Verify Maximum configuration for CPRT
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${Maximum_IPRT_CPRT}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu
    ...    timeout=500
    Teardown Oamops     dut=dbts    alias=vdu
	Sleep	60
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${Maximum_RTPOL_CPRT}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu
    ...    timeout=500
    Teardown Oamops     dut=dbts    alias=vdu

Verify Maximum configuration for L2NRT
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${Maximum_IPRT_L2NRT}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu
    ...    timeout=500
    Teardown Oamops     dut=dbts    alias=vdu
	Sleep	60
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${Maximum_RTPOL_L2NRT}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu
    ...    timeout=500
    Teardown Oamops     dut=dbts    alias=vdu

Modify and Verify ipmtu on VCU
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${ipmtu_VCU}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu   timeout=500
    Setup Remote Access    remote_device=${dut}.ocp    alias=${dut}
    Execute Interactive Remote Command
    ...    command=kubectl exec -it -n trs-cran5 po-cpif-0 -c ctr-nwmgmt -- bash
    ...    alias=${dut}
	${cmd}=    Set Variable    ip -o link show | grep -E 'f1c|xnc|x2c|ngc' | tr -s ' ' | cut -d' ' -f2,5
	${output}=    Execute Interactive Remote Command    command=${cmd}    alias=${dut}
	Should Match Regexp   ${output}    (?s)f1c@extc: ${EXPECTED_MTU}.*xnc@extc: ${EXPECTED_MTU}.*x2c@extc: ${EXPECTED_MTU}.*ngc@extc: ${EXPECTED_MTU}
    Execute Interactive Remote Command	command=exit	alias=${dut}

    Setup Remote Access    remote_device=${dut}.ocp    alias=${dut}
    Execute Interactive Remote Command
    ...    command=kubectl exec -it -n trs-cran5 po-upue-0 -c ctr-nwmgmt -- bash
    ...    alias=${dut}
	${cmd}=    Set Variable
	...    ip -o link show | grep -E 'f1u|xnu|x2u|ngu' | cut -d' ' -f2,5
	${output}=    Execute Interactive Remote Command    command=${cmd}    alias=${dut}
	Should Contain    ${output}    f1u@extu: ${EXPECTED_MTU_1}
	Should Contain    ${output}    xnu@extu: ${EXPECTED_MTU_1}
	Should Contain    ${output}    x2u@extu: ${EXPECTED_MTU_1}
	Should Contain    ${output}    ngu@extu: ${EXPECTED_MTU_1}

Modify and Verify ipmtu on VDU
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${ipmtu_VDU}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu   timeout=500
	Setup Remote Access    remote_device=${dut1}.ocp    alias=${dut}
	Execute Interactive Remote Command
	...    command=kubectl exec -it -n trs-cran5 po-cprt-0 -c ctr-nwmgmt -- bash
	...    alias=${dut}
	${cmd}=    Set Variable    ip -o link show | grep -w 'f1cplane' | tr -s ' ' | cut -d' ' -f2,5
	${output}=    Execute Interactive Remote Command    command=${cmd}    alias=${dut}
	Should Contain    ${output}    f1cplane@f1c: 1280
	Execute Interactive Remote Command    command=exit    alias=${dut}

	Setup Remote Access    remote_device=${dut1}.ocp    alias=${dut}
	Execute Interactive Remote Command
	...    command=kubectl exec -it -n trs-cran5 po-l2nrt-0 -c ctr-nwmgmt -- bash
	...    alias=${dut}
	${cmd}=    Set Variable    ip -o link show | grep -w 'f1uplane' | tr -s ' ' | cut -d' ' -f2,5
	${output}=    Execute Interactive Remote Command    command=${cmd}    alias=${dut}
	Should Contain    ${output}    f1uplane@f1: ${EXPECTED_MTU_1}

Test Routing After SBR Removal
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${Delete_Route}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu
    ...    timeout=500
    ${dut}=    Set Variable    vcu_465
    Setup DUT SSH    ${dut}
    Verify SBR Rules Removed    ${dut}
    ${dest}=    Set Variable    100.100.100.100
    ${src}=     Set Variable    10.0.1.10
    Verify Routing Uses Main Table    ${dut}    ${dest}    ${src}
    Verify Route Unreachable When No Route In Main Table    ${dut}    ${dest}    ${src}

Setup DUT SSH
    [Arguments]    ${dut}
    Setup Oamops    dut=${dut}
    Setup Remote Access    remote_device=${dut}.ocp    alias=${dut}
    Execute Interactive Remote Command
    ...    command=kubectl exec -it -n trs-cran5 po-cpif-0 -c ctr-nwmgmt -- bash
    ...    alias=${dut}

Verify SBR Rules Removed
    [Arguments]    ${dut}
    ${rules}=    Execute Interactive Remote Command    command=ip rule show    alias=${dut}
    Should Not Contain    ${rules}    lookup 52
    Should Not Contain    ${rules}    lookup 53
    Should Not Contain    ${rules}    lookup 54

Verify Routing Uses Main Table
    [Arguments]    ${dut}    ${destination_ip}    ${source_ip}

    ${main_gw}=    Get Main Table Default Gateway    ${dut}
    ${out}=    Execute Interactive Remote Command
    ...    command=ip route get ${destination_ip} from ${source_ip}
    ...    alias=${dut}
    # Remove color escape sequences in output
    ${clean_out}=    Replace String Using Regexp
    ...    ${out}
    ...    \x1b\[[0-9;]*m
    ...    ${EMPTY}
    Should Contain    ${clean_out}    via ${main_gw}

Verify Route Unreachable When No Route In Main Table
    [Arguments]    ${dut}    ${destination_ip}    ${source_ip}

    ${cmd}=    Set Variable    ip route get ${destination_ip} from ${source_ip}
    ${out}=    taf.ul.trs_e2e_fw.lib.remote_connection.remote_connection_interface.Execute Interactive Remote Command
    ...    command=${cmd}    alias=${dut}
    ${clean_out}=    Replace String Using Regexp    ${out}    \x1b\[[0-9;]*m    ${EMPTY}
    Log    Clean output:\n${clean_out}
    # NEW EXPECTATION — check default gateway only
    Should Contain    ${clean_out}    via 172.21.8.1

Get Main Table Default Gateway
    [Arguments]    ${dut}
    ${main}=    Execute Interactive Remote Command
    ...    command=ip route show table main
    ...    alias=${dut}
    ${line}=    Get Lines Containing String    ${main}    default via
    ${gw}=    Fetch From Right    ${line}    via
    ${gw}=    Fetch From Left    ${gw}    dev
    ${gw}=    Strip String    ${gw}
    # Remove ANSI colors (must provide replacement argument!)
    ${gw}=    Replace String Using Regexp    ${gw}    \x1b\[[0-9;]*m    ${EMPTY}
    [Return]    ${gw}

Order Number Outside Valid Range
	Run Keyword And Expect Error    *Plan validation failed*orderNumber*not in required range*    Perform Recommissioning    type=delta
    ...    delta_file=${Invalid_OrderNumber_Policy}    skip_parameter_relation_errors=${True}    dut=cbts    alias=vcu

Deletion of default route should not be allowed
	Run Keyword And Expect Error    *Operation*failed*Plan validation failed*    Perform Recommissioning    type=delta    delta_file=${Default_Route}
    ...    skip_parameter_relation_errors=${True}    dut=cbts    alias=vcu