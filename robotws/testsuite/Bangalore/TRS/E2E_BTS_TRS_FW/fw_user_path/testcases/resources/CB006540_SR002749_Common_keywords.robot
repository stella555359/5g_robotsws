*** Settings ***
Documentation
	...		[Procedure]				"The test file is for common keywords of SR002749 feature "
	...		[Date]					"08-15-2021"
	...		[Author]				"Madhu Chinthakindi"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"RANSHARING"
	...   	[Feature_ID]         	"5GC001464","CB006540","SR002749"
	...  	   [Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5gSBTS_9047"
	...   	[Config] 				    "cfg file varible should with given as regEx metion, refer testcases_variable.json for the same"

Variables       ta_e2e_bts_trs_fw
Resource        common_keywords.robot
Resource        admin_oam_common_keywords.robot
Library   		egate_library.py
Library   		UexGateLibrary.py
Library			cus_execution_script.py

*** Variables ***
@{BtsIds}
@{gNBIds}
@{mcc_list}
@{mnc_list}
@{lteCplaneIpList}
@{mmeIpList}
@{tempBtslines}
@{tempmmelines}

*** Keywords ***
Read Ip and plmn deatils
   [Documentation]		This keyword is to read ip and ips and plmns details of SBTS
   [Arguments]    ${scenarioType}
	Get gNB Ip details
	Read cfg file 		${scenarioType}
	Get plmn details for 6 operators
   	Get traffic capture filter ips

Execute Call Script
    [Arguments]		${scnario}
	${Call_script}=    Set Variable If
		...    "${scnario}" == "${MeNBOut_DedX2CX2U_DedeNB}"     ${multiCall_script_MeNBOut_DedX2CX2U_DedeNB}
		...    "${scnario}" == "${MeNBOut_SharedS1U_SharedeNB}"  ${multiCall_script_MeNBOut_SharedS1U_SharedeNB}
		...    "${scnario}" == "${MeNBOut_DedS1U_SharedeNB}"     ${multiCall_script_MeNBOut_DedS1U_SharedeNB}
		...    "${scnario}" == "${MeNBIn_DedX2CX2U_DedeNB}"      ${multiCall_script_MeNBIn_DedX2CX2U_DedeNB}
		...    "${scnario}" == "${MeNBIn_DedS1U_SharedeNB}"      ${multiCall_script_MeNBIn_DedS1U_SharedeNB}
		...    ${scnario}    # default value if none of the conditions match
	Set Suite Variable      ${Call_script}        ${Call_script}
	Set Suite Variable      ${scnario}        ${scnario}


	Run Keyword If    "${scnario}" == "${MeNBOut_SharedS1U_SharedeNB}" or "${scnario}" == "${MeNBOut_DedS1U_SharedeNB}"
	...    or "${scnario}" == "${MeNBOut_DedX2CX2U_DedeNB}"
	...    Run Script on Egate    ${Call_script}


	Run Keyword If    "${scnario}" == "${MeNBIn_DedS1U_SharedeNB}"	 Run Keywords
	...    Execute Cus Command		config remote update tgr
	...	   AND	  Run Script on UexGate    ${Call_script}

	Run Keyword If    "${scnario}" == "${MeNBIn_DedX2CX2U_DedeNB}"    Run Keywords
	...    Run Script on Egate    ${Call_script}
	...	   AND	  Execute Cus Command		config remote update tgr
	...    AND    Run Script on UexGate    ${multiCall_script_MeNBIn_DedX2CX2U_DedeNB_uex}

Run Script on UexGate
	[Arguments]		${Call_scenario}
	${output}=  Run UexGate Script  ${Call_scenario}
    Log  ${output}

Run Script on Egate
	[Arguments]			${Call_scenario}
	Connect And Execute Egate	${telnet_port}  	${Call_scenario}

Read cfg file
	[Documentation]		This keyword is to read lte ips from cfg file
	[Arguments]		${fileName}
   	&{5g_profile}=         Get From Dictionary    dictionary=&{ue_devices}    key=5g
   	&{cfg_dict}=         Get From Dictionary    dictionary=&{5g_profile}    key=${fileName}
   	&{cfg_fileProfile}=         Get From Dictionary    dictionary=&{cfg_dict}    key=cfg_file
   	${cfgNameList}=         Get Dictionary Keys   	dictionary=${cfg_fileProfile}
   	${cfgName}=		set variable	@{cfgNameList}[0]
	${cfgfullfile}=	Get File	${cfgFilePath}${cfgName}
	@{list}=    Split to lines  ${cfgfullfile}
	FOR    ${line}   IN  @{list}
	   ${enb_ipAdd}=      Run Keyword and return status        Should Match Regexp      ${line}       ENB\\d+_S1_ADDR=".*"
   	   Run Keyword If     '${enb_ipAdd}'=='True'   Append to list      ${tempBtslines}       ${line}
	   ${mme_ipAdd}=      Run Keyword and return status        Should Match Regexp      ${line}       MME\\d_S1_ADDR=".*"
   	   Run Keyword If     '${mme_ipAdd}'=='True'   Append to list      ${tempmmelines}       ${line}
   	END
   	Get eNB ipAddress
   	Get MME ipAddress

Get eNB ipAddress
    [Documentation]    This keyword is to read lte enb ips from cfg file
    FOR    ${line}    IN    @{tempBtslines}
        ${tempValue}=    Split String From Right    ${line}    separator="
        ${ip}=    Remove String    ${tempValue}[1]    separator="
        Append To List    ${lteCplaneIpList}    ${ip}
    END
    Set Suite Variable    ${lteCplaneIpList}
    ${ipAddLen}=    Get Length    ${lteCplaneIpList}
    Run Keyword If    ${ipAddLen} == 1    Read eNB NonConfigured CfgAddress
    Log    ${lteCplaneIpList}
    Log    "lte Cplane list details..!! "
    FOR    ${i}    IN RANGE    ${ipAddLen}
        Log   @{lteCplaneIpList}[${i}]
    END

Read eNB NonConfigured CfgAddress
   [Documentation]		This keyword is to gnerate lte cplane ips for shared enb configuration
   FOR 	${i} 	IN RANGE   1   6
      Append to list    ${lteCplaneIpList}    @{lteCplaneIpList}[0]
   END

Get MME ipAddress
   [Documentation]		This keyword is to read mme ips from cfg file
    FOR    ${line}    IN    @{tempmmelines}
        ${tempValue}=    Split String From Right    ${line}    separator="
        ${ip}=    Remove String    ${tempValue}[1]    separator="
	   Append to list    ${mmeIpList}    ${ip}
	END
   	Set Suite Variable      ${mmeIpList}        ${mmeIpList}
   	${ipAddLen}=		Get Length		${mmeIpList}
   	Run Keyword If     ${ipAddLen} == 1      Read MME NonConfigured CfgAddress
   	Log      ${mmeIpList}
   	Log      "lte mmeips list details..!! "
   	${newipAddLen}=		Get Length		${mmeIpList}
   	Log      "List test "
   	FOR    ${i} 	   IN RANGE    ${newipAddLen}
   	    Log   @{mmeIpList}[${i}]
   	END



Read MME NonConfigured CfgAddress
   [Documentation]		This keyword is to gnerate lte mme ips for shared enb configuration
   FOR 	${i} 	IN RANGE   1   6
      Append to list    ${mmeIpList}    ${mmeIpList}[0]
   END


Get gNB Ip details
   [Documentation]		This keyword is to read gNB ip adress for 6 operatos
	Read IP Parameters for 6 Operaters		${x2CplanePath}
	@{x2CplaneIPs}=		Copy List	${ipv4_list}
	Read IP Parameters for 6 Operaters		${s1UplanePath}
	@{s1UplaneIPs}=		Copy List	${ipv4_list}
	Read IP Parameters for 6 Operaters		${x2UplanePath}
	@{x2UplaneIPs}=		Copy List	${ipv4_list}
	Set Suite Variable      ${x2CplaneIPs}        ${x2CplaneIPs}
	Set Suite Variable      ${s1UplaneIPs}        ${s1UplaneIPs}
	Set Suite Variable      ${x2UplaneIPs}        ${x2UplaneIPs}

Read LTE IP Parameters
	[Documentation]		This keyword is to read LTE ip adress for MenB with configuration
	${lte1_cplane1} = 	Get Parameter		param_path=${lte_cplane1_ipv4_moc_path}
	${mme_ip1} = 		Get Parameter		param_path=${lte_mme_ipv4_moc_path}
	Set Suite Variable	${lte1_cplane1}		${lte1_cplane1}
	Set Suite Variable	${mme_ip1}		${mme_ip1}

Read IP Parameters for 6 Operaters
   	[Documentation]		This keyword is to genate ip list for 6 operators for S1U/x2U/X2C adress
	[Arguments]		${Path}		${alias}=default
	@{ipv4_list}= 	 Create List
	@{x2Cplane}=	Get Parameter		rat=5g		param_path=${Path}
	FOR 	${item} 	IN 		@{x2Cplane}
		${ipv4}= 	Get From Dictionary  	${item}		key=ipV4AddressDN1
		@{ipif_list}=         Split String     string=${ipv4}    separator=IPIF_A-
		@{ipifIpaddr_value}=         Split String     string=${ipif_list}[1]    separator=/
		${ipifID}= 		Convert To Integer		@{ipifIpaddr_value}[0]
		Set Suite Variable      ${ipifID}        ${ipifID}
		@{ipAddr_list}=         Split String from Right     string=@{ipifIpaddr_value}[1]    separator=_A-
		${ipAddrID}= 		Convert To Integer		@{ipAddr_list}[1]
		Set Suite Variable      ${ipAddrID}        ${ipAddrID}
		${IpAddr}= 		Get Parameter		rat=5g		param_path=IPIF-${ipifID}/IPADDRESSV4-${ipAddrID}:localIpAddr		alias=${alias}
		Append To List   ${ipv4_list}  	${IpAddr}
	END
	Set Suite Variable      ${ipv4_list}        ${ipv4_list}

Get plmn details for 6 operators
   	[Documentation]		This keyword is read mcc and mnc values of 6 operators
	FOR 	${temp} 	IN RANGE   1   7
  		${mcc_var}=     Get Parameter       param_path=NRPLMN-${temp}:mcc
  		${mnc_var}=     Get Parameter       param_path=NRPLMN-${temp}:mnc
  		Append To List   ${mcc_list}  	${mcc_var}
  		Append To List   ${mnc_list}  	${mnc_var}
  	END
	Set Suite Variable      ${mcc_list}
   Set Suite Variable      ${mnc_list}

Verify RMOD is up
	Wait Until Keyword Succeeds	20 min	30 sec	RMOD is Enabled

RMOD is Enabled
    @{RMOD_list} =    Query Admin Infomodel    query=get list //RMOD_R-*  timeout=300
    @{rmod_ids}=    Create List
    FOR    ${rmod}    IN    @{RMOD_list}
        ${dist_name}=    Get From Dictionary    ${rmod}    dist_name
        ${rmod_id}=    Fetch From Right    ${dist_name}    /
        ${id_number}=    Split String From Right    ${rmod_id}    -    1
        Append To List    ${rmod_ids}    ${id_number}[1]
    END
	FOR 	${rmodId} 	IN   @{rmod_ids}
	 	${rmodInfo}=      Query Admin Infomodel    query=get object //RMOD_R-${rmodId}
     	${op_status}=       Get From Dictionary     ${rmodInfo}      operationalState
     	Should Be Equal    ${op_status}     enabled
    END

Verify attach for 6 operator
   [Documentation]		This keyword is verify 6 operatos parellal attach along with traffic
	Verify X2 link status
	FOR    ${i} 	IN RANGE	   0   6
		${mcc}=			Set Variable     @{mcc_list}[${i}]
		${mnc}=			Set Variable     @{mnc_list}[${i}]
   		${lteCplaneIp}=			Set Variable     @{lteCplaneIpList}[${i}]
		${mmeIp}=			Set Variable     @{mmeIpList}[${i}]
		Set Suite Variable      ${mcc}
  		Set Suite Variable      ${mnc}
		Set Suite Variable      ${lteCplaneIp}
   		Set Suite Variable      ${mmeIp}
		Analyse Pcap	pcap_filename=${pcap_file}		 analysis=verify_6opt_attach_req	filter_file_name=${traffic_filter_file_name}
		Analyse Pcap 	pcap_filename=${pcap_file}		 analysis=verify_6opt_attach_accept	filter_file_name=${traffic_filter_file_name}
		Analyse Pcap 	pcap_filename=${pcap_file}		 analysis=verify_6opt_attach_complete	filter_file_name=${traffic_filter_file_name}
		Analyse Pcap 	pcap_filename=${pcap_file}		 analysis=verify_6opt_Erab_Indication	filter_file_name=${traffic_filter_file_name}
		Analyse Pcap 	pcap_filename=${pcap_file}		 analysis=verify_6opt_Erab_Confirm	filter_file_name=${traffic_filter_file_name}
	END
	[Teardown]    Run Keyword And Ignore Error 		Run   sudo killall egate edaemon


Get Bts and gNB Ids
   [Documentation]		This keyword get BTS and gNB ids for 6 operatos
   [Arguments]       ${scnario_type}
   Run Keyword If    "${scnario_type}" == "${MeNBOut_DedX2CX2U_DedeNB}" or "${scnario_type}" == "${MeNBIn_DedX2CX2U_DedeNB}"
	...    Set Bts and Gnb default
	...    ELSE
	...    Set Bts and Gnb non-default


Set Bts and Gnb default
   [Documentation]		This keyword get BTS and gNB ids for dedicated enb configuration
   @{BtsIds}=		Copy List	${BtsIdsList}
   @{gNBIds}=		Copy List	${gNBIdsList}
   Set Suite Variable      ${BtsIds}        ${BtsIds}
   Set Suite Variable      ${gNBIds}        ${gNBIds}

Set Bts and Gnb non-default
   [Documentation]		This keyword get BTS and gNB ids for shared enb configuration
   FOR 	${i} 	IN RANGE   6
     Append To list      ${BtsIds}    @{BtsIdsList}[0]
     Append To list      ${gNBIds}    @{gNBIdsList}[0]
   END
   Set Suite Variable      ${BtsIds}        ${BtsIds}
   Set Suite Variable      ${gNBIds}        ${gNBIds}


GetLTEENBCount
   [Documentation]		This keywrod is to get number of bfds configured
    @{LTEENB_dict_list} =    Query Admin Infomodel    query=get list //LTEENB_R-*
#   *
    ${LteeNBCount}=    Get Length    ${LTEENB_dict_list}
    Set Suite Variable     ${LteeNBCount}

Verify X2 link status
   [Documentation]		This keyword verify x2link status
   GetLTEENBCount
	FOR 	${operator_str} 	IN RANGE   0   ${LteeNBCount}
	 	${X2_status}=      Query Admin Infomodel    query=get object //LTEENB_R-${operator_str}
     	${Xn_link_status}=       Get From Dictionary     ${X2_status}      x2LinkStatus
     	Should Be Equal    ${Xn_link_status}     available
    END

Verify DedX2CX2U configured
	${ips}=		Get Length		${x2UplaneIPs}
	${ipsRanage}=		Evaluate		${ips}-1
	FOR 	${i} 	IN RANGE   0   ${ipsRanage}
		${j}=		Evaluate		${i}+1
		Should Not Be Equal		  	@{x2UplaneIPs}[${i}]		@{x2UplaneIPs}[${j}]
	END
	${ips}=		Get Length		${x2CplaneIPs}
	${ipsRanage}=		Evaluate		${ips}-1
	FOR 	${i} 	IN RANGE   0   ${ipsRanage}
		${j}=		Evaluate		${i}+1
		Should Not Be Equal		  	@{x2CplaneIPs}[${i}]		@{x2CplaneIPs}[${j}]
	END

Get traffic capture filter ips
   ${l2_capture_filter_ips}=	Set Variable	host ${x2CplaneIPs}[0]
	FOR    ${address}    IN    @{x2CplaneIPs}
		${l2_capture_filter_ips}=	Set Variable	${l2_capture_filter_ips} or host ${address}
	END
	FOR    ${address}    IN    @{s1UplaneIPs}
		${l2_capture_filter_ips}=	Set Variable	${l2_capture_filter_ips} or host ${address}
	END
	FOR    ${address}    IN    @{x2UplaneIPs}
		${l2_capture_filter_ips}=	Set Variable	${l2_capture_filter_ips} or host ${address}
	END
	FOR    ${address}    IN    @{lteCplaneIpList}
		${l2_capture_filter_ips}=	Set Variable	${l2_capture_filter_ips} or host ${address}
	END
	FOR    ${address}    IN    @{mmeIpList}
		${l2_capture_filter_ips}=	Set Variable	${l2_capture_filter_ips} or host ${address}
	END
	Set Suite Variable 	${l2_capture_filter_ips} 		${l2_capture_filter_ips}

Trigger and verify 6 operators parallel calls
   	[Documentation]		This keyword to trigger 6 oprator parellal calls
	[Arguments]			${testSenario}=default
   	Set Suite Variable      ${testSenario}        ${testSenario}
	Run Keyword And Ignore Error   	Stop traffic and detach UE
	Traffic Capture Start   capture_device=vm_any_interface     capture_filter=(${l2_capture_filter_ips})    alias=${testSenario}
	Perform Call setup 		${testSenario}
	Execute Call Script 	${testSenario}
	${pcap_file}=       Traffic capture stop	alias=${testSenario}
	Verify Bts Status   	req_rat=5g 		should_be_onair=${True}
   	Set Suite Variable      ${pcap_file}        ${pcap_file}
	[Teardown]    Run Keyword And Ignore Error   	Stop traffic and detach UE

Perform Call setup
   [Arguments]    ${scenario_type}
	Call Setup      5g=${scenario_type}:data   parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4		timeout=600
	sleep  10

Verify And Retry On Attach Failure
	[Arguments]			${CallSenario}
	${status}=  Run Keyword And Return Status  Verify attach for 6 operator
	Run Keyword If  ${status}==False  Retry Attach	${CallSenario}

Retry Attach
	[Arguments]			${CallSenario}
	Execute Cus Command		config update
	Execute Cus Command		config remote update
	Wait Until Keyword Succeeds	15 min	30 min	RMOD is Enabled
	Traffic Capture Start   capture_device=vm_any_interface     capture_filter=(${l2_capture_filter_ips})    alias=${CallSenario}
	Perform Call setup       ${CallSenario}
	Execute Call Script 	${CallSenario}
	${pcap_file}=       Traffic capture stop	alias=${CallSenario}
	Verify attach for 6 operator
	Verify X2 link status
	[Teardown]    Run Keyword And Ignore Error   	Traffic capture stop	alias=${CallSenario}

Stop traffic and detach UE
	Run Keyword And Ignore Error      	Call Teardown      		5g=${testSenario}:data
	Run Keyword And Ignore Error		Traffic Capture Stop    alias=${testSenario}
	Run Keyword And Ignore Error		Run   sudo killall egate edaemon

Verify X2U traffic
	${ips}=		Get Length		${x2UplaneIPs}
	FOR 	${temp} 	IN RANGE   0   ${ips}
	   ${newx2UplaneIPs}=			Set Variable     @{x2UplaneIPs}[${temp}]
	   Set Suite Variable        ${newx2UplaneIPs}
	   Analyse Pcap        pcap_filename=${pcap_file}        analysis=verifyX2UTraffic      filter_file_name=${traffic_filter_file_name}
	END

Verify s1U traffic
	${ips}=		Get Length		${s1UplaneIPs}
	FOR 	${temp} 	IN RANGE   0   ${ips}
	   ${s1uIpAddr}=			Set Variable     @{s1UplaneIPs}[${temp}]
	   Set Suite Variable        ${s1uIpAddr}
	   Analyse Pcap        pcap_filename=${pcap_file}        analysis=verifyS1UTraffic      filter_file_name=${traffic_filter_file_name}
	END

Load BTS with Scenario Specific Configuration
	[Arguments]		${deltaConfi}
	Perform Recommissioning    		type=delta    	delta_file=${deltaConfi}        timeout=900
