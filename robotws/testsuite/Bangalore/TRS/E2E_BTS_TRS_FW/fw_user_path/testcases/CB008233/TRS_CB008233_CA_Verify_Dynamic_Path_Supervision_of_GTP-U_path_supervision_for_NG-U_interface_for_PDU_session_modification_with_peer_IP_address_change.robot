*** Settings ***
Documentation
...		[Author]     		        "Megha Patil"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "20:05:2024"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB008233"
...     [Validated_TestLine]        "KVM53-TRSIV-TL012"
...		[Procedure]   		        "[1]TRS_CB008233_CA_Verify_Dynamic_Path_Supervision_of_GTP-U_path_supervision_for_NG-U_interface_for_
    ...     PDU_session_modification_with_peer_IP_address_change_ASIM"
...     [Precondition]              "ASIM + ASIM hardware is required with Airphone"
...     [Config_Comments]           "Verify Dynamic Firewall, Ingress Packet Filtering"
...     [Function_Hash_Tags]        "SANSA 10 Operator RAN Sharing, firewall rules check for UPlane and CPlane"


variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${profile}          2ASIM_A1_Telekom_Europe_AQQE_ARGA_FXED_FRHC
${routes}           ${CURDIR}/resources/routes.sh
${NRGTPU}           ${CURDIR}/resources/NRGTPU.xml
${vlanif_counter_analysis}    /home/ute/MN/UTE/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/CB008233/resources/
	...	  vlanif_counter_analysis.json
${7706 NR GTP-U Path Failure}       7706

*** Test Cases ***
[1]TRS_CB008233_CA_Verify_GTP-U_path_supervision_for_NG-U_interface_for_PDU_session_modification_with_peer_IP_address_change_ASIM
    Add Interfaces on VM
    Perform Commissioning       scf_file=${Configuration_3791_scf_basic}   verify_bts_status=False     timeout=300     alias=default
    Sleep       240
    Perform Recommissioning     type=delta    delta_file=${NRGTPU}      timeout=300
    Sleep   30
    Call Setup      5g=${profile}:data   parallel=${False}    verify_attach=${False}   attach=${False}
    Sleep   60
    Attach UE and send ul dl traffic
    Start the counters analysis
    Detach UE
    Verify GTP interface modification


*** Keywords ***
Add Interfaces on VM
    Run     sh ${routes}



Attach UE and send ul dl traffic
   [Documentation]       This test case keyword is to verify bts status to trigger calls
   ${bts_status}     Run Keyword And Return Status       Verify Bts Status      should_be_onair=${True}    req_rat=nr
   Log      ${bts_status}
   Traffic Capture Start    capture_device=vm_eth3_interface
   Run Keyword If       ${bts_status}      Trigger UE Calls_SA
   ${pcap_name}=    Traffic Capture Stop
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=CUSTOMER_GTP_X2_Uplane    filter_file_name=traffic_filters.json



Trigger UE Calls_SA
   [Documentation]        This test case keyword is to trigger the calls
   Configure UE    5g=${profile}:data        command=ue_register        id=1
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=ue_register        id=1
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=ue_pdu_session_setup       ue=1          pdu=1        gw=1
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=trf_data_start         ue=1         pdu=1        qfi=1        dir=dl        mbps=100
   BuiltIn.Sleep     3
   Configure UE    5g=${profile}:data        command=trf_data_start         ue=1        pdu=1        qfi=1         dir=ul        mbps=100
   BuiltIn.Sleep     3


Start the counters analysis
   [Documentation]       This test case keyword is to execute three operations
    Start PM counter analysis
    BuiltIn.sleep     100


Start PM counter analysis
   [Documentation]        This test case keyword is to start the counter
   PM Counters Start       analysis=verify_counters      counter_analysis_file=${vlanif_counter_analysis}

Verify GTP interface modification
    Traffic Capture Start    capture_device=vm_eth3_interface
    BuiltIn.Sleep       30
    Perform Recommissioning     type=param     param_path=MRBTS-3791/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr     operation=update
        ...        value=10.0.4.211     timeout=900
    Sleep   60
    Trigger UE Calls_SA
    ${pcap_name}=    Traffic Capture Stop
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=No_GTP_X2_Uplane    filter_file_name=traffic_filters.json


Detach UE
    Configure UE       5g=${profile}:data  command=ue_deregister  id=1  ue_deregister_type=switch_off
    BuiltIn.Sleep   10