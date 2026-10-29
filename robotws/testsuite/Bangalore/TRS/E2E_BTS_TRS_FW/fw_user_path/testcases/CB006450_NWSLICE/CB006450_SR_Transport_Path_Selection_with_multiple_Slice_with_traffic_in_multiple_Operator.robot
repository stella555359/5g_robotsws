***Settings ***
Documentation
    ...     [Procedure]             "To Validate Transport Path Selection with multiple-Slice with traffic in single-Operator"
    ...     [Date]                  "06-04-2020"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID]            "CB006450"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "SBTS3737"
Force Tags     CA_E2ET_BTSTRSPZ        SBTS00        [SBTS21A]     4G_FDD               CRT
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Suite Setup      Setup Oamops
Suite Teardown   Teardown Oamops

*** Test Cases ***
[1]CB006450-SR_Transport Path Selection with multiple-Slice with traffic in multiple-Operator
    Precondition
	Call Setup  lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data    parallel=${False}    verify_attach=${False}       attach=${False}
    Sleep    100
    Verify Bts Status
    Verify MME Status
	Pm Counters Start     analysis=IPIF_multiple_slice_counters     counter_analysis_file=${counter_analysis_file_name}
	Check for No reboot
	Verify Bts Status
	Verify Alarm    faultid=6150	 should_exist=${False}
	Perform SLice specific call
	Check wireshark for Slice Traffic when Flag enabled
	Verify Pm Counters      analysis=IPIF_multiple_slice_counters       counter_analysis_file=${counter_analysis_file_name}
	Perform Recommissioning     type=delta		  delta_file=add_qci.xml        skip_parameter_relation_errors=${False}     timeout=300
	Check wireshark for Slice Traffic when Flag enabled
	Perform Recommissioning     type=delta		  delta_file=delete_qci.xml        skip_parameter_relation_errors=${False}      timeout=300
	Check wireshark for Slice Traffic when qci deleted
	Run Keyword And Expect Error		*NWSLICE have operatorSpecificQciList list-unique*
    ...     Perform Recommissioning     type=delta		  delta_file=duplicate_qci.xml        skip_parameter_relation_errors=${False}
    ...      timeout=300
    Run Keyword And Expect Error        *NRNWSLICE_NSA have operatorSpecificQCIList list-unique*
    ...     Perform Recommissioning     type=delta        delta_file=duplicate_qci.xml        skip_parameter_relation_errors=${False}
    ...      timeout=300

***Keywords***
Precondition
    Perform Commissioning       scf_file=${Base_scf_6450_multi_slice}   verify_bts_status=False     timeout=400     alias=default
    sleep   300
	${interface_adddress_last_octet}=        Set Variable        1
	${vlan_ids}=							 Set Variable		 200
	${SGW_S11_ADDR}=						 Set Variable  		 134
    FOR        ${i}        IN RANGE    0      77
           ${interface_adddress_last_octet}=           Run Keyword IF      ${i}==64             Set Variable        1
           ...     ELSE                Set Variable            ${interface_adddress_last_octet}
           ${broadcast_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+2
           Run     sudo ip link add link eth3 name eth3.${vlan_ids} type vlan id ${vlan_ids}
#    	   Run Keyword IF
#            ...     ${i}<64     Run     sudo ip addr add 10.0.3.${interface_adddress_last_octet}
#                                ...      brd 10.0.3.${broadcast_adddress_last_octet} dev eth3.${vlan_ids}
#           ...         ELSE
#                       ...  Run     sudo ip addr add 10.0.4.${interface_adddress_last_octet}/30
#                            ...      brd 10.0.4.${broadcast_adddress_last_octet} dev eth3.${vlan_ids}
    		Run     sudo ip link set dev eth3.${vlan_ids} up
           ${interface_adddress_last_octet}=       Evaluate        ${interface_adddress_last_octet}+4
           ${vlan_ids}=                            Evaluate        ${vlan_ids}+1
    END
    sleep       60
    Get IP Address
    ${No_of_SGW}=     Get Length       ${GTP_Sgw_ip_addr}
    FOR    ${i}        IN RANGE        0       ${No_of_SGW}
           Run     sudo ip a a ${GTP_Sgw_ip_addr}[${i}]/24 dev eth3
           Run     sudo ip a a 10.0.1.${SGW_S11_ADDR}/24 dev eth3
           ${SGW_S11_ADDR}=                        Evaluate        ${SGW_S11_ADDR}+1
    END
    ${No_of_MME}=         Get Length       ${MME_ip_addr}
    FOR    ${i}        IN RANGE        0       ${No_of_MME}
           ${interface_index}=         Evaluate        ${i}+1
           Run     sudo ifconfig eth3:${interface_index} ${MME_ip_addr}[${i}] netmask 255.255.255.0
    END
	sleep		1000

Verify MME Status
    FOR   ${i}        IN RANGE        0       6
           ${status}=     Get Parameter           param_path=LNMME-${i}:s1LinkStatus
           Should Be True      '${status}'=='available'
    END

Get IP Address
    @{GTP_Sgw_ip_addr}=         Create List
    @{NWSLICE_SGW}=             Create List
    @{NW_SLICE_ip}=             Create List
    @{MME_ip_addr}=             Create List
    @{NRNWSLICE_NSA_ip}=        Create List
    @{Sgw_ip_addr_list}=     Get Parameter           param_path=${GTPU_address}
    FOR    ${Sgw_ip}         IN      @{Sgw_ip_addr_list}
           ${Sgw_ip_address}=      Get From Dictionary             dictionary=${Sgw_ip}             key=sgwIpAddress
           Append To List      ${GTP_Sgw_ip_addr}          ${Sgw_ip_address}
    END
    FOR            ${i}        IN RANGE            1           7
           ${NSA_NWSLICE_IP}=          Get Parameter           param_path=NRNWSLICE_NSA-${i}:s1Uplane:ipV4AddressDN1:localIpAddr
           Append To List      ${NRNWSLICE_NSA_ip}          ${NSA_NWSLICE_IP}
    END
    ${MME_DICT}=     Get Parameter           param_path=${MME}
    ${MME_value}=           Get Dictionary Values       ${MME_DICT}
    FOR            ${i}        IN      @{MME_value}
           ${MMEIp}=      Get From Dictionary      ${i}     ipAddrPrim
           Append To List      ${MME_ip_addr}          ${MMEIp}
    END
    Set Suite Variable      @{GTP_Sgw_ip_addr}          @{GTP_Sgw_ip_addr}
    Set Suite Variable      @{NWSLICE_SGW}              @{NWSLICE_SGW}
    Set Suite Variable      @{NW_SLICE_ip}              @{NW_SLICE_ip}
    Set Suite Variable      @{MME_ip_addr}              @{MME_ip_addr}
    Set Suite Variable      @{NRNWSLICE_NSA_ip}         @{NRNWSLICE_NSA_ip}
Check for No reboot
	${stdout}=      Run     ping -c 50 192.168.255.129
Perform SLice specific call
    Execute cmd on Egate        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  cmd=ue_mme_param id=1 sgw_id=7
	Configure UE        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  command=ue_attach id=1 selected_plmn=234:77 cell=11
    Sleep   10
	Configure UE        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  command=bearer_add ue=1 qci=128  #4g call
    Sleep   10
	Configure UE        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  command=trf_data_start ue=1 qci=128 dir=ul kbps=1000 protocol=udp
    Sleep   10
    Execute cmd on Egate        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  cmd=ue_mme_param id=3 sgw_id=10
    Sleep   10
    Configure UE        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  command=ue_attach id=3 selected_plmn=555:10 cell=11
    Sleep   10
    Configure UE        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  command=bearer_add ue=3 qci=131
    Sleep   10
    Configure UE        lte=CB006450_IPv4_multiple_operaror_20slice_cfg:data  command=trf_data_start ue=3 qci=131 dir=ul kbps=1000 protocol=udp
Detach Slice calls
	[Arguments]			${range}
	FOR			${i}		IN RANGE		1		${range}
		Configure UE        lte=CB006450_IPv4_single_operaror_20slice_cfg:data  command=ue_detach id=${i}    timeout=60
	END
Wireshark check
	[Arguments]			${uplane}			${pdn}				${Wireshark_file} 		${analysis}
    Set Suite Variable          ${uplane_addr}          ${uplane}
	Set Suite Variable			${PDN_IP}				${pdn}
    Analyse Pcap        pcap_filename=${Wireshark_file}            analysis=${analysis}       filter_file_name=${pcap_file}

Check wireshark for Slice Traffic when Flag enabled
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    sleep   10
Check wireshark for Slice Traffic when qci deleted
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=eth3_pcap
    sleep		10
    ${Wireshark_file}=       Traffic Capture Stop        alias=eth3_pcap
