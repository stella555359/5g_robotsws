*** Settings ***
Documentation
...	[Procedure]	        	"Verificarion of Fast IP Rerouting by validating trigger and calls. Also includes EDA item regarding BFD timer."
...	[Date]		        	"27-05-2021"
...	[Author]	        	"Shivani Patil"
...	[QC Path]	        	"QC_Path in Test Plan"
...	[QC ID]		        	"QC_ID in Test Lab for reporting"
...	[Function_Hash_Tags]		"FIPR"
... 	[Feature_ID]            	"5GC000986"
... 	[Validation_status]     	"Validated and Passed"
... 	[Validated_TestLine]    	"420"
... 	[Config]                	"gNB should configured VLAN based configuration"



Variables         ta_e2e_bts_trs_fw
Resource         ${CURDIR}/../resources/Common_BFD.robot
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library            random


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Test Cases ***
TRS_5GC000986_Verification_of_FastIPRerouting
	 [Documentation]		This test case fast ip re routing with VLAN based configuration
	 Perform Commissioning 	  scf_file=${scf_FIPR}   timeout=600		verify_bts_status=False  	timeout=300
 	 Sleep   900
	 Read BFD Details
     Get Primary and Secondary BFDs for ipv4
	 Start Ping Test
	 Validation Of All Trigger Status
	 verify trace 		${primary_bfd_remote_ip}
	 Bring Down Primary Session
     Wait Until Keyword Succeeds		3 minute	10 s		Verify Alarm    faultid=61605     should_exist=True    alarm_type=active
	 sleep 	2
	 verify trigger state  	${primary_trigger_id}		${FALSE}
	 verify trigger state  	${secondary_trigger_id}		${TRUE}
	 verify trace 		${secondary_bfd_remote_ip}
	 Bring Up Primary Session
	 Wait Until Keyword Succeeds		3 minute	10 s		Verify Alarm    faultid=61605     should_exist=False    alarm_type=active
	 sleep 	2
	 verify trigger state  	${primary_trigger_id}		${TRUE}
	 verify trigger state  	${secondary_trigger_id}		${TRUE}
	 verify trace 		${primary_bfd_remote_ip}
	 Bring Down Secondary Session
	 Wait Until Keyword Succeeds		3 minute	10 s		Verify Alarm    faultid=61605     should_exist=True    alarm_type=active
	 sleep 	2
	 verify trigger state  	${primary_trigger_id}		${TRUE}
	 verify trigger state  	${secondary_trigger_id}		${FALSE}
	 verify trace 		${primary_bfd_remote_ip}
	 Bring Up Secondary Session
     Wait Until Keyword Succeeds		3 minute	10 s		Verify Alarm    faultid=61605     should_exist=False    alarm_type=active
	 sleep 	2
	 verify trigger state  	${primary_trigger_id}		${TRUE}
	 verify trigger state  	${secondary_trigger_id}		${TRUE}
	 verify trace 		${primary_bfd_remote_ip}
	 Stop ping
     Verify success rate
	 verify FIPR for Ipv6
	 [Teardown]	Run Keyword and Ignore Error		Terminate Testcase

*** Keywords ***
Read BFD Details
	GetBFDCount
	GetTriggerCount
	GetTriggerIds

Terminate Testcase
	Bring Up Primary Session
	Bring Up Secondary Session
	Stop ping
	Run Keyword And Ignore Error	Traffic Capture Stop		alias=primary_path
	Run Keyword And Ignore Error	Traffic Capture Stop		alias=secondary_path


Validation Of All Trigger Status
	FOR    ${temp}    IN     @{triggerids_list}
       GetTriggerDetails	${temp}
	  	GetTriggerStatus	${temp}
	  	Should be Equal		${triggerStatus}	${TRUE}
	END

verify FIPR for Ipv6
	Read BFD Details
	Get Primary and Secondary BFDs for ipv6
	Validation Of All Trigger Status
    Start Ping Test
    Traffic Capture Start    capture_device=l2_wireshark     alias=primary_path
	sleep 		5
	${pcap_name}=	Traffic Capture Stop		alias=primary_path
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=primary_path_remote_ip_echo    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=primary_path_remote_ip_reply    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=no_secondary_path_remote_ip   filter_file_name=${traffic_filer_file_name}
	Bring Down Primary Session
    Sleep       10
    Traffic Capture Start    capture_device=l2_wireshark    alias=secondary_path
	sleep 		5
	${pcap_name}=	Traffic Capture Stop		alias=secondary_path
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=secondary_path_remote_ip_echo    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=secondary_path_remote_ip_reply    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=no_primary_path_remote_ip    filter_file_name=${traffic_filer_file_name}
	Bring Up Primary Session
    Sleep       10
    Traffic Capture Start    capture_device=l2_wireshark    alias=primary_path
	sleep 		5
	${pcap_name}=	Traffic Capture Stop		alias=primary_path
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=primary_path_remote_ip_echo    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=primary_path_remote_ip_reply    filter_file_name=${traffic_filer_file_name}
	Analyse Pcap    pcap_filename=${pcap_name}    analysis=no_secondary_path_remote_ip   filter_file_name=${traffic_filer_file_name}
	Stop ping
	Verify success rate
    [Teardown]      Run Keyword And Ignore Error        Stop ping
