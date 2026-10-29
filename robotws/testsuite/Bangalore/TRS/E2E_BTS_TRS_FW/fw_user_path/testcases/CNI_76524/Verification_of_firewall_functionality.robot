*** Settings ***
Documentation
...	    [Procedure]			"The test case is planned to validate firewall rate limit for mplane packet"
...	    [Date]				"25-05-2022"
...     [Author]            "Pooja CK"
...     [Feature_ID]        "CNI-76524"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...	    [Funtion_Hash_Tags]	"FIREWALL, COUNTERS"
...   	[Validated_TestLine]"TL001 and TL002"
...     [Precondition]      "Primary and secondary core's should be in sync"

Resource    ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007162_Common_Keywords.robot

Suite setup    Run Keywords    setup oamops
...            AND    Setup Oamops     dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Teardown oamops

*** Test Cases ***
[1][1.0] Verification of firewall functionality
    Run Keywords        Suite Setup Preconditions
    Continue Keyword Execution On Failure     ${True}
	Get parameter values
#primary
    PM Counters Start   analysis=verify_ingress_rate_limit_packet_drop   counter_analysis_file=${counter_analysis_file_name}    alias=default
	Send Packets    ${proto}    mplane_rate_limit_drop			#Invalid packets ports with expected drop
	${rate_limit_counters_list}= 	Verify PM Counters	analysis=verify_ingress_rate_limit_packet_drop
	...             	counter_analysis_file=${counter_analysis_file_name}     alias=default
    Set Suite Variable      ${rate_limit_counters_list}     ${rate_limit_counters_list}
    Verify Rate Limit
#secondary
    Sleep    60
    Send Packets        ${proto}        mplane_rate_limit_drop          #Invalid packets ports with expected drop
    ${rate_limit_counters_list}=    Verify PM Counters		analysis=verify_ingress_rate_limit_packet_drop
    ...                counter_analysis_file=${counter_analysis_file_name}     alias=secondary
	Set Suite Variable		${rate_limit_counters_list}		${rate_limit_counters_list}
	Verify Rate Limit
#primary
    Sleep    60
    PM Counters Start       analysis=verify_ingress_rate_limit_packet_drop_all_other      counter_analysis_file=${counter_analysis_file_name}
    ...                       alias=default
    Send Packets        ${proto}        not_mplane_rate_limit_drop_v4            #Invalid packets ports with expected drop
    ${rate_limit_counters_list}=        Verify PM Counters      analysis=verify_ingress_rate_limit_packet_drop_all_other
    ...                                 counter_analysis_file=${counter_analysis_file_name}        alias=default
    Set Suite Variable      ${rate_limit_counters_list}     ${rate_limit_counters_list}
    Verify Rate Limit for not mplane IP
#secondary
    Sleep    60
    Send Packets        ${proto}        not_mplane_rate_limit_drop_v4            #Invalid packets ports with expected drop
    ${rate_limit_counters_list}=        Verify PM Counters      analysis=verify_ingress_rate_limit_packet_drop_all_other
    ...                                 counter_analysis_file=${counter_analysis_file_name}        alias=secondary
    Set Suite Variable      ${rate_limit_counters_list}     ${rate_limit_counters_list}
    Verify Rate Limit for not mplane IP
#ICMP
    Get IPs
    Perform Recommissioning     type=param  param_path=IPNO-1:icmpResponseEnabled   value=true  timeout=300   operation=update
    Verify ping test success
    Sleep   100
    Perform Recommissioning     type=param  param_path=IPNO-1:icmpResponseEnabled   value=false     timeout=300   operation=update
    PM Counters Start       analysis=verify_ingress_rate_limit_packet_drop_icmp      counter_analysis_file=${counter_analysis_file_name}
    Verify ping test failure
    Verify PM Counters      analysis=verify_ingress_rate_limit_packet_drop_icmp      counter_analysis_file=${counter_analysis_file_name}
#secondary
    Sleep    60
    Verify ping test failure
    Verify PM Counters      analysis=verify_ingress_rate_limit_packet_drop_icmp      counter_analysis_file=${counter_analysis_file_name}
    ...                      alias=secondary
#defaultconfig
     Perform Recommissioning     type=param  param_path=IPNO-1:icmpResponseEnabled   value=true  timeout=300   operation=update
