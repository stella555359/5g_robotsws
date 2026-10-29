*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of flow control"
	...		[Date]					"7-9-2020"
	...		[Author]				"Manohar KR"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"IPSEC","RANSHARING"
	...   	[Feature_ID]         	"5GC001464"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5G_9049"
	...   	[Config] 				"NRBTS-1 need to configured with 6 x2clist"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/CB006540_SR002749_Common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Test Cases ***
TRS_CB006540_Verification_of_mulitple_fstsch_flowcl_for_eachopearator.
	[Documentation]		"The test case to verify Maximum flowctrl support and flowctrl counter verification"
	Perform Commissioning             verify_bts_status=${False}		timeout=900
	Verify RMOD is up
	Load BTS with Scenario Specific Configuration 		${deltaOnbaseConfig_flowctl_fstschConfig}
	Pm Counters Start     analysis=verify_firstlevel_counters       counter_analysis_file=${counter_analysis_file_name}
	Get fstch details
	Get gateway for fstsch_flowcl        ${fstschId_ipaddr}
	Perform ping test        ${fstschId_ipaddr}
	Get flowcl details
	Get gateway for fstsch_flowcl        ${flowclSrc_ipaddr}
	Perform ping test        ${flowclSrc_ipaddr}
	Verify Pm Counters      analysis=verify_firstlevel_counters       counter_analysis_file=${counter_analysis_file_name}
	Configure maximum fstsch
	verify additional fstsch

***Keywords***
Perform ping test
    [Arguments]        ${ipAddr}
    Setup Remote Access    remote_device=bts
    ${output}=    Remote Command Execute    command=ping -I ${ipAddr} ${gw_ip} -c 20
    [Teardown]    Teardown Remote Access
    Check Ping Success Rate    ${output}

Check Ping Success Rate
    [Arguments]    ${ping_output}
	${transmitted} =  String.Get Regexp Matches  ${ping_output}  \\d+(?=\\s+packets transmitted)
	${received} =  String.Get Regexp Matches  ${ping_output}  \\d+(?=\\s+received)
    Log    Transmitted: ${transmitted}
    Log    Received: ${received}
    ${success_rate} =    Evaluate    float(${received[0]}) / float(${transmitted[0]}) * 100
    Should Be True    ${success_rate} >= 98    msg=The success rate is less than 98%


Configure maximum fstsch
	Perform Recommissioning    		type=delta    	delta_file=${MaxFSTCHConfig}        timeout=600

verify additional fstsch
    # Need to check the stability with value is too big error type.
    Run Keyword And Expect Error    ${VALUE_IS_TOO_BIG_err}
    ...    Perform Recommissioning    type=delta    delta_file=${MaxfstchConfig_Additional}    timeout=600

Get fstch details
	${fstch_moc_list} = 	Query Admin Infomodel		query=get param //FSTSCH_A-1:ipIfDN
	${fstch_moc_list}=		Convert to string	 	${fstch_moc_list}
	@{ipif_list}=         Split String     string=${fstch_moc_list}    separator=IPIF_A-
	@{ipif_list_id}=         Split String     string=@{ipif_list}[-1]	    separator='
	${ipif_id}=         Set Variable        @{ipif_list_id}[0]
	${fstschId_ipaddr} = 	Query Admin Infomodel		query=get param //IPIF_A-${ipif_id}/${IPADDRESSV4_A-1}:localIpAddr
	Set Suite Variable			${fstschId_ipaddr}		${fstschId_ipaddr}

Get flowcl details
	${flowclSrc_ipaddr} = 	Query Admin Infomodel		query=get param //FLOWCL_A-1:ruleSet:srcIpAddr
	Set Suite Variable			${flowclSrc_ipaddr}		${flowclSrc_ipaddr}

Get gateway for fstsch_flowcl
    [Arguments]        ${ipAddr}
	@{address_split}=         Split String From Right    string=${ipAddr}		separator=.  	max_split=1
	${gw_ip}= 		Catenate    SEPARATOR=	@{address_split}[0]	.1
	Set Suite Variable			${gw_ip}		${gw_ip}

Revert Configuration
	Run Keyword And Ignore Error        Perform Recommissioning    		type=delta    	delta_file=${MaxFSTCHConfig}        timeout=600
