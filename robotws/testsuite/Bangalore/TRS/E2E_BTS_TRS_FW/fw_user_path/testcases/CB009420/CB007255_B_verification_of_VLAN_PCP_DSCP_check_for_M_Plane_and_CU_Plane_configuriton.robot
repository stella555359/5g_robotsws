*** Settings ***
Documentation
...		[Author]     		        "Shreya Choudhary"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "10:05:2023"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB009420"
...     [Validated_TestLine]        "KVM87-TRSIV-TL006"
...		[Procedure]   		        "CB007255-B_verification of VLAN, PCP & DSCP check for M-Plane & CU-Plane configuriton"
...     [Precondition]              "ASIM + ABIO with ORU APoDocker hardware is required"
...     [Config_Comments]           "Verification of CB007255 functionality in CB009420 Feature"
...     [Function_Hash_Tags]        "ORAN"


Resource    	${CURDIR}/../resources/common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1][1.0] CB007255-B_verification of VLAN, PCP & DSCP check for M-Plane & CU-Plane configuriton.
	Perform Commissioning       scf_file=${Configuration_VLAN_DSCP_PCP}   verify_bts_status=False     timeout=300
    Sleep    180
	Check Operational and Procedural state of ORU
    Change VLAN, PCP and DSCP Value for MPLANEFHNW
    Check Operational and Procedural state of ORU
    Get Configured ORU IP
    Verify VLAN, PCP and DSCP Value for MPLANEFHNW

*** Keywords ***
Check Operational and Procedural state of ORU
	${Operational_State}=     Query Admin Infomodel    query=get param ${op_state_query}
	Should be Equal     ${Operational_State}      enabled
	${Mplane_Link_State}=     Query Admin Infomodel    query=get param ${mplane_link_status_query}
	Should be Equal     ${Mplane_Link_State}      Connected
	${Procedural_State}=     Query Admin Infomodel    query=get param ${procedural_state_query}
	Should be Equal     ${Procedural_State}      configured

Change VLAN, PCP and DSCP Value for MPLANEFHNW
	${dscp_value}=  Evaluate	random.randrange(${min_dscp_value},${max_dscp_value})	random
	${pcp_value}=   Evaluate	random.randrange(${min_pcp_value},${max_pcp_value})	random
	${vlan_id}=     Evaluate	random.randrange(${min_vlan_value},${max_vlan_value})	random
	${cur_delta_vlan_dscp_pcp}=     Copy File    ${delta_dir}/${delta_vlan_dscp_pcp}      ${cur_delta_vlan_dscp_pcp}
	Run    sed -i -- 's/{{dscp_value}}/${dscp_value}/g' ${cur_delta_vlan_dscp_pcp}
	Run    sed -i -- 's/{{pcp_value}}/${pcp_value}/g' ${cur_delta_vlan_dscp_pcp}
	Run    sed -i -- 's/{{vlan_id}}/${vlan_id}/g' ${cur_delta_vlan_dscp_pcp}
	Perform Recommissioning     type=delta    delta_file=${cur_delta_vlan_dscp_pcp}     timeout=300
	sleep   180
	Set Suite Variable    ${dscp_value}    ${dscp_value}
	Set Suite Variable        ${pcp_value}        ${pcp_value}
	Set Suite Variable        ${vlan_id}        ${vlan_id}

Get Configured ORU IP
    Setup Remote Access      remote_device=bts      alias=session
	Execute Interactive Remote Command       command=ssh toor4nsn@fsp5s1icom      alias=session
    Execute Interactive Remote Command       command=oZPS0POrRieRtu      alias=session
	Execute Interactive Remote Command       command=ip netns exec radions bash      alias=session
	${stdout}=    Execute Interactive Remote Command       command=ip a s | grep -i "global rfoe0.${vlan_id}" | awk '{print $2}'  alias=session
	Teardown Remote Access      alias=session
	${stdout}=     Split String    ${stdout}    \r\n
	${ORU_IP_Configured}=  Get from List    ${stdout}    1
	${ORU_IP_Configured}=      Split String    ${ORU_IP_Configured}    /
	${ORU_IP_IF}=     Get from List    ${ORU_IP_Configured}    0
    ${ORU_IP_List}=   Split String   ${ORU_IP_IF}   .
    ${ORU_IP_INT}=     Evaluate    ${ORU_IP_List}[3]+1
	${ORU_IP}=   Set Variable      ${ORU_IP_List}[0].${ORU_IP_List}[1].${ORU_IP_List}[2].${ORU_IP_INT}
	Set Suite Variable     ${ORU_IP}    ${ORU_IP}

Verify VLAN, PCP and DSCP Value for MPLANEFHNW
	Setup Remote Access      remote_device=bts      alias=session
	Execute Interactive Remote Command       command=ssh toor4nsn@fsp5s1icom      alias=session
    Execute Interactive Remote Command       command=oZPS0POrRieRtu      alias=session
	Execute Interactive Remote Command       command=ip netns exec radions bash      alias=session
	Execute Interactive Remote Command       command=timeout 20 tcpdump -i rfoe0 -w modified_values.pcap      alias=session
	Execute Interactive Remote Command       command=exit      alias=session
	Execute Interactive Remote Command       command=scp modified_values.pcap toor4nsn@192.168.255.253:/user/toor4nsn      alias=session
	Execute Interactive Remote Command       command=oZPS0POrRieRtu      alias=session
	Execute Interactive Remote Command       command=exit      alias=session
	Execute Interactive Remote Command       command=exit      alias=session
	Run     scp toor4nsn@192.168.255.129:modified_values.pcap ${CURDIR}
	Teardown Remote Access      alias=session
	Analyse Pcap        pcap_filename=${pcap_file}        analysis=verify_vlan_pcp_dscp         filter_file_name=${traffic_filter_file_name}