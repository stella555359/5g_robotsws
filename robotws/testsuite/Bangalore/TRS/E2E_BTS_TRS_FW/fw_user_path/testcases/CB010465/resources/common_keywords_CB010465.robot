*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers ipsec failure counter verification for vdu and vcu with certificate"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "TRS_CB010465_5GC002215_ipsec_failure_counterVerification_for_vdu_and_vcu"
...     [Funtion_Hash_Tags]     "TRS - Security"
...     [Feature_ID]            "CB010465"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

Resource          ${CURDIR}/../../resources/common_keywords.robot
Resource          ${CURDIR}/../../resources/Admin_Common_Library.robot

*** Keywords ***
Perform ipsec configuration on vcu and vdu
    Setup Oamops    dut=vcu_465    alias=vcu_465
    Perform Recommissioning     type=delta  delta_file=${CB010465_IPSEC_with_CERT_vCU}    skip_parameter_relation_errors=${True}
    ...     dut=vcu_465    alias=vcu_465   timeout=4000
    Setup Oamops    dut=vdu_465    alias=vdu_465
    Perform Recommissioning     type=delta  delta_file=${CB010465_IPSEC_with_CERT_vDU}    skip_parameter_relation_errors=${True}
    ...     dut=vdu_465    alias=vdu_465   timeout=4000

Perform Concurrent ipsec configuration on vcu and vdu
    Perform Recommissioning     type=delta  delta_file=${CB010465_IPSEC_with_PSK_vCU}    skip_parameter_relation_errors=${True}
    ...     dut=vcu_465    alias=vcu_465   timeout=4000
    Perform Recommissioning     type=delta  delta_file=${CB010465_IPSEC_with_PSK_vDU}    skip_parameter_relation_errors=${True}
    ...     dut=vdu_465    alias=vdu_465   timeout=4000

Perform PSK Configuration on vcu and vdu
    Update Cu Psk Configuration 	password=Testing@12345	timeout=30  dut=vdu_465  alias=vdu_465
    Update Cu Psk Configuration     password=Testing@12345  timeout=30  dut=vcu_465  alias=vcu_465
    Run     sudo ipsec restart

Certificate Configuration on vcu and vdu
    [Arguments]     ${keypoolType}      ${dut_vdu}  ${dut_vcu}
    Triger IR to install certificate    ${keypoolType}      ${dut_vdu}
    Triger IR to install certificate    ${keypoolType}      ${dut_vcu}
    Verify cmp certificate state   ${dut_vdu}
    Verify cmp certificate state   ${dut_vcu}

Perform ipsec configuration for PSK on VM
    Run     sudo ip a a fc00::11:1/116 dev eth7
    Run     sudo ip a a fc00::12:1/116 dev eth8
    Run     sudo cp ${CURDIR}/resources/ipsec_PSK.secrets /etc/ipsec.secrets
    Run     sudo cp ${CURDIR}/resources/ipsec_PSK.conf /etc/ipsec.conf
    Run     sudo ipsec restart

Perform ipsec configuration on VM
    Run	    sudo scp ${CURDIR}/resources/ipsec.secrets /etc
	Run	    sudo scp ${CURDIR}/resources/ipsec.conf /etc
    Run 	sudo scp ${CURDIR}/resources/BTSCert.pem /etc/ipsec.d/certs/
	Run	    sudo scp ${CURDIR}/resources/private-key.pem /etc/ipsec.d/private/
    Run	    sudo ipsec restart

Triger IR to install certificate
    [Arguments]     ${keypoolType}      ${dut}
    Setup Oamops    dut=${dut}      alias=${dut}
    Certificate Configure   dut=${dut}     operation=restore_vendor_certificate  alias=${dut}
    Sleep   60
    Certificate Configure   dut=${dut}     operation=set_certificate_automatic_management
    ...     reference_number=16092  preshared_key=this_is_very_secret   key_pool_type=${keypoolType}   alias=${dut}
    Sleep   60
    Certificate Configure   dut=${dut}    operation=install_cmp_certificate     timeout=300
    ...     key_pool_type=${keypoolType}  alias=${dut}
    Sleep   90

Verify cmp certificate state
    [Arguments]     ${dut}
    ${CMP_state}=     Get Parameter     param_path=${cmp_r_moc_path}        dut=${dut}      alias=${dut}
    Should Be Equal     ${CMP_state}       CMP_InitializationOK


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
    ...     alias=${dut}    timeout=60
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
    ${policy}=  Get Parameter
    ...    param_path=MRBTS-1/TNLSVC-1/TNL-${TNL_ID}/IPAPP-1/IPSECC-1/SECPOL-${num}:policyOrderNumber     dut=${dut}      alias=${dut}
    Append To List     ${policy_ids}    ${policy}

Get TNL ID for cplane
	[Arguments]     ${dut}	${pod_name}
	Setup Remote Access     remote_device=${dut}.ocp	alias=${dut}
	${pod_c}=      Remote Command Execute     command=kubectl get pods -n ${cu_name} | grep ${pod_name} | cut -d ' ' -f 1
    ...  continue_on_failure=${False}     alias=${dut}
	${ipaddr}=      Remote Command Execute
    ...  command=kubectl exec -it -n ${cu_name} ${pod_c} -c ctr-${cu_name}-nwmgmt -- ip a s| grep f1c | grep inet | cut -d ' ' -f 6 | cut -d '/' -f 1
    ...  continue_on_failure=${False}     alias=${dut}
    Set Suite Variable    ${ip_addresses}	${ipaddr}
	Set Suite Variable    ${pod_c}	${pod_c}
	Setup Oamops    dut=${dut}    alias=${dut}
	FOR   ${num}    IN RANGE   4   12
        Set Suite Variable    ${num}    ${num}
        Run Keyword And Ignore Error    Get TNL for cplane	${dut}
	Exit For Loop If    '${dest_IP}' == '${ip_addresses}'
    END
	[Teardown]	Run at End	${dut}

Run at End
	[Arguments]     ${dut}
	Run Keyword And Ignore Error	Teardown Oamops     dut=${dut}     alias=${dut}
	Run Keyword And Ignore Error	Teardown Remote Access  alias=${dut}

Get TNL ID for uplane
	[Arguments]     ${dut}	${pod_name}
	Setup Remote Access     remote_device=${dut}.ocp	alias=${dut}
	${pod_u}=      Remote Command Execute     command=kubectl get pods -n ${cu_name} | grep ${pod_name} | cut -d ' ' -f 1
    ...     continue_on_failure=${False}     alias=${dut}
	${ipaddr}=      Remote Command Execute
    ...  command=kubectl exec -it -n ${cu_name} ${pod_u} -c ctr-${cu_name}-nwmgmt -- ip a s| grep f1u | grep inet | cut -d ' ' -f 6 | cut -d '/' -f 1
    ...  continue_on_failure=${False}     alias=${dut}
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
	#Setup Oamops    dut=${dut}    alias=${dut}
    FOR   ${ipif_num}    IN RANGE   1   4
        ${dest_IP}=	Get Parameter    dut=${dut}
        ...   param_path=MRBTS-1/TNLSVC-1/TNL-${num}/IPNO-1/IPIF-${ipif_num}/IPADDRESSV4-1/IPADDRESSV4_R-1:localIpAddrAllocated     alias=${dut}
        Set Suite Variable    ${dest_IP}
        Exit For Loop If    '${dest_IP}' == '${ip_addresses}'
    END

Get TNL for uplane
	[Arguments]     ${dut}
	Set Suite Variable    ${num}
	Set Suite Variable    ${dest_IP}	${num}
	#Setup Oamops    dut=${dut}    alias=${dut}
    FOR   ${ipif_num}    IN RANGE   1   4
        ${dest_IP}=	Get Parameter    dut=${dut}
        ...   param_path=MRBTS-1/TNLSVC-1/TNL-${num}/IPNO-1/IPIF-${ipif_num}/IPADDRESSV4-1/IPADDRESSV4_R-1:localIpAddrAllocated     alias=${dut}
       # ${TNL}   Set Variable If    '${dest_IP}' == '${ip_addresses}'	${num}
       # Run Keyword If    '${dest_IP}' == '${ip_addresses}'	Set Suite Variable    ${TNL}      ${num}
      #  Log   ${TNL}
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

Create Discard Policy and Verify setPacketMatchDiscPol and receivedPacketMatchDiscPol Counter
    Setup Oamops    dut=vcu_465      alias=vcu_465
    Perform Recommissioning     type=delta  delta_file=${discpol_vCU}    skip_parameter_relation_errors=${True}   dut=vcu_465
    ...     alias=vcu_465   timeout=4000
    Sleep   60
    PM Counters Start   analysis=Discpol_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465        alias=vcu_465
    Verify Pm Counters  analysis=Discpol_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465      alias=vcu_465
    Perform Recommissioning     type=delta  delta_file=${revert_discpol_vCU}    skip_parameter_relation_errors=${True}   dut=vcu_465
    ...     alias=vcu_465   timeout=4000

Create Bypass Policy and Verify sentPacketMatchBypassPol and receivedPacketMatchBypassPol Counter
    Setup Oamops    dut=vcu_465      alias=vcu_465
    PM Counters Start   analysis=Bypass_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465        alias=vcu_465
    Verify Pm Counters  analysis=Bypass_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465      alias=vcu_465
    Setup Oamops    dut=vdu_465      alias=vdu_465
    PM Counters Start   analysis=Bypass_TNL-${TNLID_vdu_uplane}_vDU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=1   dut=vdu_465      alias=vdu_465
    Verify Pm Counters  analysis=Bypass_TNL-${TNLID_vdu_uplane}_vDU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=1   dut=vdu_465      alias=vdu_465

Send ESP packets with different SPI value and Verify ipsecSaNotFound counter
    Setup Oamops    dut=vcu_465      alias=vcu_465
    Traffic Setup   device=scapy_esp
    Pm Counters Start       analysis=ipsecSaNotFound_TNL-${TNLID_vcu_uplane}_vCU     counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465        alias=vcu_465
    Run     expect ${CURDIR}/Send_ESP_Packets.exp
    Verify Pm Counters      analysis=ipsecSaNotFound_TNL-${TNLID_vcu_uplane}_vCU     counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465        alias=vcu_465

Send Unencrypted packets and Verify recvUnprotPacketMatchProtPol counter
    Setup Oamops    dut=vcu_465      alias=vcu_465
    Pm Counters Start       analysis=UnprotPacket_TNL-${TNLID_vcu_uplane}_vCU     counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465        alias=vcu_465
    Run     expect ${CURDIR}/Send_unprotect.exp
    Verify Pm Counters      analysis=UnprotPacket_TNL-${TNLID_vcu_uplane}_vCU     counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465        alias=vcu_465

Verify failedSAEstablishments counter
    Setup Oamops    dut=vcu_465      alias=vcu_465
    Perform Recommissioning     type=delta  delta_file=${failedSA_vCU}    skip_parameter_relation_errors=${True}   dut=vcu_465
    ...     alias=vcu_465   timeout=4000
    Sleep   60
    PM Counters Start   analysis=failedSA_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465        alias=vcu_465
    Verify Pm Counters  analysis=failedSA_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json
    ...     pm_interval=5       dut=vcu_465      alias=vcu_465
    Perform Recommissioning     type=delta  delta_file=${revert_failedSA_vCU}    skip_parameter_relation_errors=${True}   dut=vcu_465
    ...     alias=vcu_465   timeout=4000

Send Traffic and Verify SentESP and ReceivedESP Counter
    Setup Oamops    dut=vcu_465      alias=vcu_465
    PM Counters Start   analysis=ESP_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json  pm_interval=5
    ...     dut=vcu_465      alias=vcu_465
    Verify Pm Counters  analysis=ESP_TNL-${TNLID_vcu_uplane}_vCU         counter_analysis_file=CB010465_counters_analysis.json  pm_interval=5
    ...     dut=vcu_465      alias=vcu_465
    Setup Oamops    dut=vdu_465      alias=vdu_465
    PM Counters Start   analysis=ESP_TNL-${TNLID_vdu_uplane}_vDU         counter_analysis_file=CB010465_counters_analysis.json  pm_interval=5
    ...     dut=vdu_465      alias=vdu_465
    Verify Pm Counters  analysis=ESP_TNL-${TNLID_vdu_uplane}_vDU         counter_analysis_file=CB010465_counters_analysis.json  pm_interval=5
    ...     dut=vdu_465      alias=vdu_465

Verify IPSEC Alarms
    Verify DPD alarm by stoping ipsec on peer end
    Verify IKE authentication failure alarm
    Verify IKE SA failure alarm
    Verify IPSec SA failure alarm

Verify DPD alarm by stoping ipsec on peer end
    Run     sudo ipsec stop
    Sleep   60
    Verify Alarm        faultid=61030   occurrences=4   should_exist=${True}    dut=vcu_465     alias=vcu_465
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${Disable_ipsec}    timeout=400     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61030   occurrences=2   should_exist=${True}    dut=vdu_465     alias=vdu_465
    Run     sudo ipsec restart
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${Enable_ipsec}    timeout=400     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61030   should_exist=${False}    dut=vcu_465     alias=vcu_465
    Verify Alarm        faultid=61030   should_exist=${False}    dut=vdu_465     alias=vdu_465

Verify IKE authentication failure alarm
    Update Cu Psk Configuration     password=Nokia@123  timeout=30  dut=vdu_465     alias=vdu_465
    Update Cu Psk Configuration     password=Nokia@456  timeout=30  dut=vcu_465     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61644   occurrences=2    dut=vdu_465     alias=vdu_465
    Verify Alarm        faultid=61644   occurrences=6    dut=vcu_465     alias=vcu_465
    Update Cu Psk Configuration     password=Testing@12345  timeout=30  dut=vdu_465     alias=vdu_465
    Update Cu Psk Configuration     password=Testing@12345  timeout=30  dut=vcu_465     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61644   should_exist=${False}    dut=vcu_465     alias=vcu_465
    Verify Alarm        faultid=61644   should_exist=${False}    dut=vdu_465     alias=vdu_465

Verify IKE SA failure alarm
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${Create_IKE_failure}    timeout=400     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61645   occurrences=2    dut=vdu_465     alias=vdu_465
    Verify Alarm        faultid=61645   occurrences=6    dut=vcu_465     alias=vcu_465
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${Remove_IKE_failure}    timeout=400     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61645   should_exist=${False}    dut=vcu_465     alias=vcu_465
    Verify Alarm        faultid=61645   should_exist=${False}    dut=vdu_465     alias=vdu_465

Verify IPSec SA failure alarm
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${Create_SA_failure}    timeout=400     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61646   occurrences=1    dut=vdu_465     alias=vdu_465
    Verify Alarm        faultid=61646   occurrences=2    dut=vcu_465     alias=vcu_465
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${Remove_SA_failure}    timeout=400     alias=vcu_465
    Sleep   60
    Verify Alarm        faultid=61646   should_exist=${False}    dut=vcu_465     alias=vcu_465
    Verify Alarm        faultid=61646   should_exist=${False}    dut=vdu_465     alias=vdu_465

Perform PMTU Discovery Configuration on vcu and vdu
    Setup Oamops    dut=vcu_465    alias=vcu_465
    Setup Oamops    dut=vdu_465    alias=vdu_465
    Perform Recommissioning    dut=vdu_465  type=delta  delta_file=${PMTU_Discovery_vDU}    timeout=400     alias=vdu_465
    Sleep   60
    Verify PMTU Discovery vdu
    Perform Recommissioning    dut=vdu_465  type=delta  delta_file=${PMTU_Discovery_vDU_Delete}    timeout=400     alias=vdu_465
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${PMTU_Discovery_vCU_F1}    timeout=400     alias=vcu_465
    Sleep   60
    Verify PMTU Discovery vcu
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${PMTU_Discovery_vCU_Delete}    timeout=400     alias=vcu_465
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${PMTU_Discovery_vCU_NG}    timeout=400     alias=vcu_465
    Sleep   60
    Verify PMTU Discovery vcu
    Perform Recommissioning    dut=vcu_465  type=delta  delta_file=${PMTU_Discovery_vCU_Delete}    timeout=400     alias=vcu_465

Verify PMTU Discovery vdu
    Setup Oamops    dut=vdu_465    alias=vdu_465
    Verify pathmtu Result   ${TNLID_vdu_cplane}     vdu_465
    Verify pathmtu Result   ${TNLID_vdu_uplane}     vdu_465

Verify PMTU Discovery vcu
    Setup Oamops    dut=vcu_465    alias=vcu_465
    Verify pathmtu Result   ${TNLID_vcu_cplane}     vcu_465
    Verify pathmtu Result   ${TNLID_vcu_uplane}     vcu_465

Verify pathmtu Result
    [Arguments]     ${TNL_ID}   ${dut}
    ${path_Mtu_Result}=     Get Parameter
    ...  param_path=MRBTS-1/TNLSVC-1/TNL-${TNL_ID}/IPNO-1/PATHMTUDISCOVERREQ-1/PATHMTUDISCOVERRES-1:pathMtuDiscoverResult      dut=${dut}
    ...  alias=${dut}
    Should Be Equal     ${path_Mtu_Result}      OK

Perform Commissioning on vcu and vdu
    Setup Oamops    dut=cbts    alias=vcu
	Perform Commissioning	dut=cbts	scf_file=${Basic_SCFC_vCU}	verify_bts_status=False     alias=vcu
    Teardown Oamops     dut=cbts    alias=vcu
    Setup Oamops    dut=dbts    alias=vdu
    Perform Commissioning	dut=dbts	scf_file=${Basic_SCFC_vDU}	verify_bts_status=False     alias=vdu
    Teardown Oamops     dut=dbts    alias=vdu

Perform IPSEC PSK configuration on vcu and vdu
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning     type=delta  delta_file=${IPSEC_VCU}    skip_parameter_relation_errors=${True}	dut=cbts	alias=vcu	timeout=400
	Sleep	60
	Teardown Oamops		dut=cbts	alias=vcu
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning     type=delta  delta_file=${IPSEC_VDU}    skip_parameter_relation_errors=${True}	dut=dbts	alias=vdu	timeout=400
    Sleep	60
	Teardown Oamops		dut=dbts	alias=vdu

Verify DPD Optimization
	Setup Oamops    dut=cbts    alias=vcu
	Disable Ipsec on SecureGW
	Sleep    20
	Verify Alarm    faultid=61030    should_exist=${False}	occurrences=2    dut=cbts    alias=vcu
	Wait Until Keyword Succeeds		20 sec	3 sec	Verify Alarm    faultid=61030    should_exist=${True}	occurrences=2    dut=cbts    alias=vcu
	Wait Until Keyword Succeeds		400 sec	60 sec	Verify Alarm    faultid=61030    should_exist=${True}	occurrences=4    dut=cbts    alias=vcu
	Enable Ipsec on SecureGW