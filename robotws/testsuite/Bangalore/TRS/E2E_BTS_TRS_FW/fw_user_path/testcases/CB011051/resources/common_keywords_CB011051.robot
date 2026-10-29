*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers rannic reset and pods recovery with ipsec configuration"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "-"
...     [Funtion_Hash_Tags]     "TRS"
...     [Feature_ID]            "CB011051"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

variables       ta_e2e_bts_trs_fw

*** Keywords ***
Perform Commissioning on vcu and vdu
    [Arguments]     ${SCFC_vCU}  ${SCFC_vDU}
    Setup Oamops    dut=vcu_465    alias=vcu_465
    Perform Commissioning   dut=vcu_465    scf_file=${SCFC_vCU}  verify_bts_status=False     alias=vcu_465
    Setup Oamops    dut=vdu_465    alias=vdu_465
    Perform Commissioning   dut=vdu_465    scf_file=${SCFC_vDU}  verify_bts_status=False     alias=vdu_465

Perform Concurrent ipsec configuration on vcu and vdu
    Perform Recommissioning     type=delta  delta_file=${CB011051_IPSEC_with_PSK_vCU}    skip_parameter_relation_errors=${True}
	...    dut=vcu_465    alias=vcu_465   timeout=4000
    Perform Recommissioning     type=delta  delta_file=${CB011051_IPSEC_with_PSK_vDU}    skip_parameter_relation_errors=${True}
	...    dut=vdu_465    alias=vdu_465   timeout=4000

Perform PSK Configuration on vcu and vdu
    Update Cu Psk Configuration 	password=Testing@12345	timeout=30  dut=vdu_465  alias=vdu_465
    Update Cu Psk Configuration     password=Testing@12345  timeout=30  dut=vcu_465  alias=vcu_465

Perform ipsec configuration for PSK on VM
    Run     sudo ip a a fc00::11:1/116 dev eth7
    Run     sudo ip a a fc00::12:1/116 dev eth8
    Run     sudo cp ${CURDIR}/resources/ipsec_PSK.secrets /etc/ipsec.secrets
    Run     sudo cp ${CURDIR}/resources/ipsec_PSK.conf /etc/ipsec.conf
    Run     sudo ipsec restart

Verify ipsec status
	Get TNL ID for cplane	vcu_465	cpif
	Set Suite Variable    ${TNLID_vcu_cplane}	${num}
	Get TNL ID for uplane	vcu_465	upue
	Set Suite Variable    ${TNLID_vcu_uplane}	${num}
	Verify vcu tunnelstate	vcu_465	${pod_c}	${pod_u}
	Get TNL ID for cplane	vdu_465	cprt
	Set Suite Variable    ${TNLID_vdu_cplane}	${num}
	Get TNL ID for uplane	vdu_465	l2nrt
	Set Suite Variable    ${TNLID_vdu_uplane}	${num}
	Verify vdu tunnelstate	vdu_465	${pod_c}    ${pod_u}

Verify vcu tunnelstate
	[Arguments]     ${dut}	${pod_c}	${pod_u}
	Verify tunnelstate  ${dut}  ${TNLID_vcu_cplane}     CPIF    ${pod_c}
	Verify tunnelstate  ${dut}  ${TNLID_vcu_uplane}     UPUE    ${pod_u}

Verify tunnelstate
	[Arguments]     ${dut}  ${TNL_ID}   ${pod_name}     ${pod_id}
	Setup Oamops    dut=${dut}    alias=${dut}
	Get policy IDs  ${TNL_ID}   ${dut}
	FOR    ${ID}    IN    @{policy_ids}
		${assoc}=   Get Ipsec Associations     policy_id=${ID}    tnl_pod_hostname=TNL-${TNL_ID}-${pod_name}_${pod_id}     dut=${dut}
		...		alias=${dut}    timeout=60
    	${inner_dict}=    Get From Dictionary    ${assoc}    ike_associations
    	${value_1}=   Get From List     ${inner_dict}     0
    	${value}=      Get From Dictionary     dictionary=${value_1}       key=status
    	Should Be Equal      ${value}   Established
    	${inner_dict}=    Get From Dictionary    ${assoc}    associations_infos
    	${value_1}=   Get From List     ${inner_dict}     0
    	${value}=      Get From Dictionary     dictionary=${value_1}       key=peer_state
    	Should Be Equal      ${value}   Installed
	END
	Teardown Oamops     dut=${dut}     alias=${dut}

Verify vdu tunnelstate
	[Arguments]     ${dut}	${pod_c}	${pod_u}
    Verify tunnelstate  ${dut}  ${TNLID_vdu_cplane}     CPRT    ${pod_c}
    Verify tunnelstate  ${dut}  ${TNLID_vdu_uplane}     L2HI    ${pod_u}

Get policy IDs
	[Arguments]      ${TNL_ID}  ${dut}
    ${policy_ids}    Create List
    Set Suite Variable  ${policy_ids}
    FOR   ${num}    IN RANGE   1   14
        Set Suite Variable    ${num}    ${num}
        Run Keyword And Ignore Error    Get policy  ${policy_ids}   ${TNL_ID}   ${dut}
    END
    Log     ${policy_ids}
Get policy
    [Arguments]     ${policy_ids}       ${TNL_ID}   ${dut}
    ${policy}=  Get Parameter  param_path=MRBTS-1/TNLSVC-1/TNL-${TNL_ID}/IPAPP-1/IPSECC-1/SECPOL-${num}:policyOrderNumber
	...		dut=${dut}  alias=${dut}
    Append To List     ${policy_ids}    ${policy}

Get TNL ID for cplane
	[Arguments]     ${dut}	${pod_name}
	Setup Remote Access     remote_device=${dut}.ocp	alias=${dut}
	${pod_c}=      Remote Command Execute     command=kubectl get pods -n ${cu_name} | grep ${pod_name} | cut -d ' ' -f 1
	...    continue_on_failure=${False}     alias=${dut}
	${ipaddr}=      Remote Command Execute
	...	 command=kubectl exec -it -n ${cu_name} ${pod_c} -c ctr-${cu_name}-nwmgmt -- ip a s| grep f1c | grep inet | cut -d ' ' -f 6 | cut -d '/' -f 1
	...	 continue_on_failure=${False}     alias=${dut}
    Set Suite Variable    ${ip_addresses}	${ipaddr}
	Set Suite Variable    ${pod_c}	${pod_c}
	Setup Oamops    dut=${dut}    alias=${dut}
	FOR   ${num}    IN RANGE   4   12
        Set Suite Variable    ${num}    ${num}
        Run Keyword And Ignore Error    Get TNL for cplane	${dut}
		Exit For Loop If    '${dest_IP}' == '${ip_addresses}'
    END

Perform Pods Restart
    [Arguments]     ${dut}
    Setup Remote Access     remote_device=${dut}.ocp    alias=${dut}
    ${pod_healing}=      Remote Command Execute     command=kubectl get pods -n trs-cran5 | grep healing-controller | cut -d ' ' -f 1
	...		continue_on_failure=${False}     alias=${dut}
    ${pod_ahm}=      Remote Command Execute     command=kubectl get pods -n trs-cran5 | grep ahm | cut -d ' ' -f 1
	...		continue_on_failure=${False}     alias=${dut}
    ${pod_cprt}=      Remote Command Execute     command=kubectl get pods -n trs-cran5 | grep cprt | cut -d ' ' -f 1
	...		continue_on_failure=${False}     alias=${dut}
    ${pod_l2nrt}=      Remote Command Execute     command=kubectl get pods -n trs-cran5 | grep l2nrt | cut -d ' ' -f 1
	...		continue_on_failure=${False}     alias=${dut}
    Remote Command Execute
	...	 command=kubectl exec -it -n ${cu_name} ${pod_healing} -c ${c_heal} -- curl -fsSX POST ${pod_restart} -d '{"name": "${pod_ahm}"}'
	...	 continue_on_failure=${False}     alias=${dut}
    Remote Command Execute
	...	 command=kubectl exec -it -n trs-cran5 ${pod_healing} -c ${c_heal} -- curl -fsSX POST ${pod_restart} -d '{"name": "${pod_cprt}"}'
	...	 continue_on_failure=${False}     alias=${dut}
    Remote Command Execute
	...	 command=kubectl exec -it -n trs-cran5 ${pod_healing} -c ${c_heal} -- curl -fsSX POST ${pod_restart} -d '{"name": "${pod_l2nrt}"}'
	...	 continue_on_failure=${False}     alias=${dut}

Get TNL ID for uplane
	[Arguments]     ${dut}	${pod_name}
	Setup Remote Access     remote_device=${dut}.ocp	alias=${dut}
	${pod_u}=      Remote Command Execute     command=kubectl get pods -n ${cu_name} | grep ${pod_name} | cut -d ' ' -f 1
	...		continue_on_failure=${False}     alias=${dut}
	${ipaddr}=      Remote Command Execute
	...	 command=kubectl exec -it -n ${cu_name} ${pod_u} -c ctr-trs-cran5-nwmgmt -- ip a s| grep f1u | grep inet | cut -d ' ' -f 6 | cut -d '/' -f 1
	...	 continue_on_failure=${False}     alias=${dut}
    Set Suite Variable    ${ip_addresses}	${ipaddr}
	Set Suite Variable    ${pod_u}	${pod_u}
	Setup Oamops    dut=${dut}    alias=${dut}
	FOR   ${num}    IN RANGE   4   12
        Set Suite Variable    ${num}    ${num}
        Run Keyword And Ignore Error    Get TNL for uplane	${dut}
		Exit For Loop If    '${dest_IP}' == '${ip_addresses}'
    END
	[Teardown]	Teardown Oamops     dut=${dut}     alias=${dut}

Get TNL for cplane
	[Arguments]     ${dut}
	Set Suite Variable    ${num}
	Set Suite Variable    ${dest_IP}	${num}
	Setup Oamops    dut=${dut}    alias=${dut}
    FOR   ${ipif_num}    IN RANGE   1   4
        ${dest_IP}=	Get Parameter    dut=${dut}
		...	 param_path=MRBTS-1/TNLSVC-1/TNL-${num}/IPNO-1/IPIF-${ipif_num}/IPADDRESSV4-1/IPADDRESSV4_R-1:localIpAddrAllocated     alias=${dut}
        Set Suite Variable    ${dest_IP}
        Exit For Loop If    '${dest_IP}' == '${ip_addresses}'
    END

Get TNL for uplane
	[Arguments]     ${dut}
	Set Suite Variable    ${num}
	Set Suite Variable    ${dest_IP}	${num}
	Setup Oamops    dut=${dut}    alias=${dut}
    FOR   ${ipif_num}    IN RANGE   1   4
        ${dest_IP}=	Get Parameter    dut=${dut}
		...	 param_path=MRBTS-1/TNLSVC-1/TNL-${num}/IPNO-1/IPIF-${ipif_num}/IPADDRESSV4-1/IPADDRESSV4_R-1:localIpAddrAllocated     alias=${dut}
        ${TNL}   Set Variable If    '${dest_IP}' == '${ip_addresses}'	${num}
       	Run Keyword If    '${dest_IP}' == '${ip_addresses}'	Set Suite Variable    ${TNL}      ${num}
        Log   ${TNL}
        Set Suite Variable    ${dest_IP}
        Exit For Loop If    '${dest_IP}' == '${ip_addresses}'
    END

Attach UE and send ul dl traffic
   	[Documentation]        This test case keyword is to trigger the calls
   	Configure UE    5g=5g_basic_setup_cfg:data        command=ue_register   id=1
   	Sleep     20
   	Configure UE    5g=5g_basic_setup_cfg:data        command=set_pdu_param     ue=1    pdu=1   trf_type=internal
   	Sleep     20
   	Configure UE    5g=5g_basic_setup_cfg:data        command=ue_pdu_session_setup  pdu=1   gw=1    ue=1
   	Sleep     20
   	Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=1    pdu=1   qfi=1   dir=dl  trf_id=1    mbps=1    protocol=tcp
   	Sleep     20
   	Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=1    pdu=1   qfi=1   dir=ul  trf_id=1    mbps=1    protocol=tcp
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

Send Traffic and Verify SentESP and ReceivedESP Counter
    Setup Oamops    dut=vcu_465      alias=vcu_465
    PM Counters Start   analysis=ESP_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB011051_counters_analysis.json
	...		pm_interval=5   dut=vcu_465      alias=vcu_465
    Verify Pm Counters  analysis=ESP_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB011051_counters_analysis.json
	...		pm_interval=5   dut=vcu_465      alias=vcu_465
    Setup Oamops    dut=vdu_465      alias=vdu_465
    PM Counters Start   analysis=ESP_TNL-${TNLID_vdu_uplane}_vDU         counter_analysis_file=CB011051_counters_analysis.json
	...		pm_interval=5   dut=vdu_465      alias=vdu_465
    Verify Pm Counters  analysis=ESP_TNL-${TNLID_vdu_uplane}_vDU         counter_analysis_file=CB011051_counters_analysis.json
	...		pm_interval=5   dut=vdu_465      alias=vdu_465