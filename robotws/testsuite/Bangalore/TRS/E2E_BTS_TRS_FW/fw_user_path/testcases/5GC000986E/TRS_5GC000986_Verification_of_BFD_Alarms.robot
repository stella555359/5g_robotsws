*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to verify BFD configurations both Ipv4 and Ipv6 with maximum session support
    ...                              The second case to verify maximum alarm support"
    ...     [Date]                  "25-05-20"
    ...     [Author]                "Sahana TC"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "FIPR","BFD"
    ...     [Feature_ID]            "5GC000986"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "3908, 3927"
	...     [Config]    			"No BFD configurations should have the preloaded scf as BFD configuration are cretaed by delta for this case"

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown  Teardown Oamops

Variables         ta_e2e_bts_trs_fw
Resource          ${CURDIR}/../resources/Common_BFD.robot
Library           random

*** Test Cases ***
[1][1.0] TRS_5GC000986_Verification_of_BFD_Alarms
    [Documentation]		This test case validates maximum BFD Alarms
    Configure Maximum BFD and BFDGRPs
    Verify BTS Status         should_be_onair=${True}         rat=5g
    Read BFD Details
    Verification of Ingress Alarm
    Reload gNB and verify BFD status
    Modify and Configure Bounderay Values
    Verify BFD firewall rules
    [Teardown]    Roll Back

*** Keywords ***
expected alarms
    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
    ${pre_alarm_faultids}=  Create List
    ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
    Set Suite Variable  ${pre_alarm_faultids}   ${pre_alarm_faultids}

alarms after reset
    ${post_reset_alarms}=   Verify Alarm    alarm_type=active
    ${post_reset_length}=   Get Length  ${post_reset_alarms}
    ${post_alarm_faultids}=  Create List
    ${post_alarm_faultids}=  Create fault id List   ${post_reset_alarms}
    [return]    ${post_alarm_faultids}

verify alarm status
    [Arguments]    ${pre_alarm_faultids}
    ${alarm_state} =    alarms after reset
    Should be equal    ${alarm_state}    ${pre_alarm_faultids}


Create fault id List
    [Arguments]     ${list}
    ${length}=  Get Length  ${list}
    ${list1}=   Create List
    FOR     ${i}    IN RANGE    ${length}
        Append To List  ${list1}    ${list[${i}]['faultId']}
    END
    [return]    ${list1}

Verify BFD GRP details
    GetBFDGRPCount
    GetBFDGRPIds

Verify BFD firewall rules
    Setup Remote Access	    remote_device=bts
    ${nfttables}=   Run Keyword If           '${rule_type}'=='nftlist'      Remote Command Execute      command=nft list ruleset
    ${iptables}=    Run Keyword If             '${rule_type}'=='iptables'    Remote Command Execute      command=iptables -nvL
    Set Suite Variable      ${nfttables}
    Set Suite Variable      ${iptables}
    FOR    ${value}    IN    @{bfdindex_list}
        GetBFDDetails      ${value}
        ${output}=     Run Keyword And Return Status     Should Contain      ${bfdSrcIpAddr}	:
        Run Keyword If     ${output} == True      Set Suite Variable       ${ip}       ip6
        Run Keyword If     ${output} == False     Set Suite Variable       ${ip}       ip
        GetBFDFirwallChain          ${ip}       ${bfdSrcIpAddr}         ${bfdDestIpAddr}
    END
    [Teardown]    Teardown Remote Access

Configure and verify multihop BFD
    Perform Recommissioning    type=delta    delta_file=${MultihopBFDConfig}        timeout=600
    GetBFDDetails       1
    Traffic Capture Start    capture_device=l2_wireshark    capture_filter=vlan and (host ${bfdSrcIpAddr} or host ${bfdDestIpAddr})
    ...    alias=VerifyMultiHopBFDConfigurations
    BuiltIn.Sleep       30
    ${pcap_name}=    Traffic Capture Stop    alias=VerifyMultiHopBFDConfigurations
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=multihop_ingress    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=multihop_egress    filter_file_name=${traffic_filer_file_name}
    Perform Recommissioning    type=delta    delta_file=${DelMultihopBFDConfig}        timeout=600
    ${min_bfdID_value}=	    Convert to Integer      17
	${max_bfdID_value}=	    Convert to Integer      100
    ${modified_bfdID_value}=	    random.randint      ${min_bfdID_value}	    ${max_bfdID_value}
    Set Suite Variable       ${modified_bfdID_value}
    Run Keyword and Expect Error        *AdminApiProcedureFailureException*         type=delta      delta_file=${InvalidBFDIDConfig}
    ...        timeout=300
    [Teardown]      Revert BFD Singlehop BFD

Revert BFD Singlehop BFD
    Perform Recommissioning    type=delta    delta_file=${SinglehopBFDConfig}        timeout=600
    Run Keyword And Ignore Error         Traffic Capture Stop    alias=VerifyMultiHopBFDConfigurations

Configure Maximum BFD and BFDGRPs
    Perform Recommissioning    type=delta    delta_file=${CreateBFDAndBFDGRP}        timeout=600
    Setup Ems  config_device=netact   alias=lab1042
    Cm Upload   config_device=netact   alias=lab1042
    Configuration Manage    config_device=netact   config=bfd_netact.json    plan_name=bfd_update   delete_plan="True"   alias=lab1042
    Log     Maximum BFD and BFDGRP created successfully
    Teardown Ems    config_device=netact    alias=lab1042

Delete Maximum BFD and BFDGRPs
    Perform Recommissioning    type=delta    delta_file=${DeleteBFDAndBFDGRP}        timeout=600
    Log     Maximum BFD and BFDGRP deleted successfully

Verify BFD status and configurations
    Traffic Capture Start    capture_device=l2_wireshark    capture_filter=vlan and (${l2_capture_filter_bfdSrcAddr_ips})
    ...    alias=VerifyBFDConfigurations
    BuiltIn.Sleep       30
    ${pcap_name}=    Traffic Capture Stop    alias=VerifyBFDConfigurations
    Set Suite Variable       ${pcap_name}
    FOR    ${value}    IN    @{bfdindex_list}
        GetBFDDetails      ${value}
        ${output}=     Run Keyword And Return Status     Should Contain      ${bfdSrcIpAddr}	:
        Run Keyword If     ${output} == True     VerifyBfdIpv6Configuration        ${bfdAdminUpStatus}
        Run Keyword If     ${output} == False    VerifyBfdIpv4Configuration        ${bfdAdminUpStatus}
    END
    [Teardown]    Run Keyword And Ignore Error         Traffic Capture Stop    alias=VerifyBFDConfigurations

Reload gNB and verify BFD status
    Reset Bts	    should_be_onair=False
    BuiltIn.Sleep       900

Modify and Configure Bounderay Values
    Backup BFD Configuration        ${bfdindex_list}[0]
    Run Keyword and Expect Error    *AdminApiProcedureFailureException*     Perform Recommissioning		type=param
    ...	  param_path=BFD-${bfdindex_list}[0]:bfdDscp	  operation=update	  value=65
    BuiltIn.Sleep       10
    Run Keyword and Expect Error    *bfdSrcUdpPort*     Perform Recommissioning		type=param
    ...	  param_path=BFD-${bfdindex_list}[0]:bfdSrcUdpPort	  operation=update	  value=65536       skip_parameter_relation_errors=${False}
    BuiltIn.Sleep       10
    ${min_dscp_value}=	    Convert to Integer      0
	${max_dscp_value}=	    Convert to Integer      63
    ${modified_dscp_value}=	    random.randint      ${min_dscp_value}	    ${max_dscp_value}
    Perform Recommissioning		type=param	      	param_path=BFD-${bfdindex_list}[0]:bfdDscp	  operation=update	  value=${modified_dscp_value}
    BuiltIn.Sleep       10
    ${min_bfdSrcUdpPort_value}=	    Convert to Integer      49512
	${max_bfdSrcUdpPort_value}=	    Convert to Integer      65535
    ${modified_bfdSrcUdpPort_value}=	    random.randint      ${min_bfdSrcUdpPort_value}	    ${max_bfdSrcUdpPort_value}
    Perform Recommissioning		type=param	      	param_path=BFD-${bfdindex_list}[0]:bfdSrcUdpPort	  operation=update
    ...	  value=${modified_bfdSrcUdpPort_value}
    BuiltIn.Sleep       10
    Perform Recommissioning		type=param	      	param_path=BFD-${bfdindex_list}[0]:bfdAdminUp  operation=update	  value=false
    BuiltIn.Sleep       10
    GetBFDDetails   ${bfdindex_list}[0]
    [Teardown]      Restore BFD Configurations

Backup BFD Configuration
   [Arguments]      ${index}
   GetBFDDetails   ${index}
   ${bfdDscp_old}=         Set Variable	    ${bfdDscp}
   ${bfdSrcUdpPort_old}=         Set Variable	    ${bfdSrcUdpPort}
   Set Suite Variable           ${bfdDscp_old}
   Set Suite Variable           ${bfdSrcUdpPort_old}

Restore BFD Configurations
    Perform Recommissioning		type=param	      	param_path=BFD-${bfdindex_list}[0]:bfdDscp	  operation=update	  value=${bfdDscp_old}
    BuiltIn.Sleep       10
    Perform Recommissioning		type=param	      	param_path=BFD-${bfdindex_list}[0]:bfdSrcUdpPort	  operation=update	  value=${bfdSrcUdpPort_old}
    BuiltIn.Sleep       10
    Perform Recommissioning		type=param	      	param_path=BFD-${bfdindex_list}[0]:bfdAdminUp  operation=update	  value=true
    Run Keyword And Ignore Error         Traffic Capture Stop    alias=ModifyBfdValues

Read BFD Details
    GetBFDCount
    ${bfdSrcAddr_list}=     Get_BFD_Src_IPs
    Set Suite Variable  @{bfd1_srcip}   ${bfdSrcAddr_list}[0]
    Set Suite Variable  @{bfd2_srcip}   ${bfdSrcAddr_list}[1]
    Set Suite Variable  @{bfd3_srcip}   ${bfdSrcAddr_list}[2]
    Set Suite Variable  @{bfd4_srcip}   ${bfdSrcAddr_list}[3]
    Set Suite Variable  @{bfd5_srcip}   ${bfdSrcAddr_list}[4]
    Set Suite Variable  @{bfd6_srcip}   ${bfdSrcAddr_list}[5]
    Set Suite Variable  @{bfd7_srcip}   ${bfdSrcAddr_list}[6]
    Set Suite Variable  @{bfd8_srcip}   ${bfdSrcAddr_list}[7]
    Set Suite Variable  @{bfd9_srcip}   ${bfdSrcAddr_list}[8]
    Set Suite Variable  @{bfd10_srcip}   ${bfdSrcAddr_list}[9]
    Set Suite Variable  @{bfd11_srcip}   ${bfdSrcAddr_list}[10]
    Set Suite Variable  @{bfd12_srcip}   ${bfdSrcAddr_list}[11]
    Set Suite Variable  @{bfd13_srcip}   ${bfdSrcAddr_list}[12]
    Set Suite Variable  @{bfd14_srcip}   ${bfdSrcAddr_list}[13]
    Set Suite Variable  @{bfd15_srcip}   ${bfdSrcAddr_list}[14]
    Set Suite Variable  @{bfd16_srcip}   ${bfdSrcAddr_list}[15]
    ${bfdDestAddr_list}=    Get_BFD_Dest_IPs
    Log     ${bfdDestAddr_list}
    Set Suite Variable      @{bfd1_destip}      ${bfdDestAddr_list}[0]
    Set Suite Variable      @{bfd2_destip}      ${bfdDestAddr_list}[1]
    Set Suite Variable      @{bfd3_destip}      ${bfdDestAddr_list}[2]
    Set Suite Variable      @{bfd4_destip}      ${bfdDestAddr_list}[3]
    Set Suite Variable      @{bfd5_destip}      ${bfdDestAddr_list}[4]
    Set Suite Variable      @{bfd6_destip}      ${bfdDestAddr_list}[5]
    Set Suite Variable      @{bfd7_destip}      ${bfdDestAddr_list}[6]
    Set Suite Variable      @{bfd8_destip}      ${bfdDestAddr_list}[7]
    Set Suite Variable      @{bfd9_destip}      ${bfdDestAddr_list}[8]
    Set Suite Variable      @{bfd10_destip}      ${bfdDestAddr_list}[9]
    Set Suite Variable      @{bfd11_destip}      ${bfdDestAddr_list}[10]
    Set Suite Variable      @{bfd12_destip}      ${bfdDestAddr_list}[11]
    Set Suite Variable      @{bfd13_destip}      ${bfdDestAddr_list}[12]
    Set Suite Variable      @{bfd14_destip}      ${bfdDestAddr_list}[13]
    Set Suite Variable      @{bfd15_destip}      ${bfdDestAddr_list}[14]
    Set Suite Variable      @{bfd16_destip}      ${bfdDestAddr_list}[15]


Get_BFD_Dest_IPs
   [Documentation]      This keywrod is to get BFD destination ip address
   GetBFDIds
   @{bfdDestAddr_list}=   Create List
   FOR    ${value}    IN    @{bfdindex_list}
       GetBFDDetails      ${value}
       Append To List      ${bfdDestAddr_list}    ${bfdDestIpAddr}
   END
   Set Suite Variable      ${bfdDestAddr_list}    ${bfdDestAddr_list}
   ${l2_capture_filter_bfdDestAddr_ips}=    Set Variable    host {bfdDestAddr_list}[0]
   FOR    ${bfdIpAdr}    IN    @{bfdDestAddr_list}
       ${l2_capture_filter_bfdSrcAddr_ips}=    Set Variable    ${l2_capture_filter_bfdDestAddr_ips} or host ${bfdIpAdr}
   END
   Set Suite Variable       ${bfdDestAddr_list}
   Set Suite Variable       ${l2_capture_filter_bfdDestAddr_ips}
   [return]     ${bfdDestAddr_list}



VerifyBfdIpv6Configuration
    [Arguments]      ${AdminStatus}
    Run Keyword If     ${AdminStatus} == True     Analyse Pcap    pcap_filename=${pcap_name}    analysis=Bfdv6UpStatus
    ...    filter_file_name=${traffic_filer_file_name}
    Run Keyword If     ${AdminStatus} == False    Analyse Pcap    pcap_filename=${pcap_name}    analysis=Bfdv6DownStatus
    ...    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=Bfdv6Dscp    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=udpv6port    filter_file_name=${traffic_filer_file_name}

VerifyBfdIpv4Configuration
   [Arguments]      ${AdminStatus}
   Run Keyword If     ${AdminStatus} == True    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BfdUpStatus
   ...    filter_file_name=${traffic_filer_file_name}
   Run Keyword If     ${AdminStatus} == False    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BfdDownStatus
   ...    filter_file_name=${traffic_filer_file_name}
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=BfdDscp    filter_file_name=${traffic_filer_file_name}
   Analyse Pcap    pcap_filename=${pcap_name}    analysis=udpport    filter_file_name=${traffic_filer_file_name}


Verification of Egress Alarm
    VerifyNoBFDAndBFDGRPAlarm
    Block upd traffic of Egress BFD alarm
    BuiltIn.Sleep    20
    VerifyEgressAlarm       ${BfdCount}
    ${BfdAdminUPCount}=         Set Variable	${BfdCount}
    FOR    ${value}    IN    @{bfdindex_list}
       Perform Recommissioning		type=param	    		param_path=BFD-${value}:bfdActivation	  operation=update	  value=false
       BuiltIn.Sleep   10
       ${BfdAdminUPCount}=      Evaluate	${BfdAdminUPCount}-1
       Run Keyword If      ${BfdAdminUPCount}>=1      VerifyEgressAlarm   ${BfdAdminUPCount}
    END

    FOR    ${value}    IN    @{bfdindex_list}
       Perform Recommissioning		type=param	    		param_path=BFD-${value}:bfdActivation	  operation=update	  value=true
       BuiltIn.Sleep   10
       ${BfdAdminUPCount}=      Evaluate	${BfdAdminUPCount}+1
       VerifyEgressAlarm   ${BfdAdminUPCount}
    END
    UnBlock upd traffic of Egress BFD alarm
    BuiltIn.Sleep    10
    VerifyNoBFDAndBFDGRPAlarm

Verification of Ingress Alarm
    Block upd traffic of Ingress BFD alarm
    BuiltIn.Sleep    60
    VerifyIngressAlarm      ${BfdCount}
    ${BfdAdminUPCount}=         Set Variable	${BfdCount}
    FOR    ${value}    IN    @{bfdindex_list}
       Perform Recommissioning		type=param	         	param_path=BFD-${value}:bfdActivation	  operation=update	  value=false
       BuiltIn.Sleep   10
       ${BfdAdminUPCount}=      Evaluate	${BfdAdminUPCount}-1
       Run Keyword If      ${BfdAdminUPCount}>=1      VerifyIngressAlarm   ${BfdAdminUPCount}
    END

    FOR    ${value}    IN    @{bfdindex_list}
       Perform Recommissioning		type=param	      	param_path=BFD-${value}:bfdActivation	  operation=update	  value=true
       BuiltIn.Sleep   10
       ${BfdAdminUPCount}=      Evaluate	${BfdAdminUPCount}+1
       VerifyIngressAlarm      ${BfdAdminUPCount}
    END

    UnBlock upd traffic of Ingress BFD alarm
    BuiltIn.Sleep    60
    VerifyNoBFDAndBFDGRPAlarm

VerifyIngressAlarm
   [Arguments]      ${count}
    Verify Alarm    faultid=61605    occurrences=${count}    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61022    occurrences=${count}    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61606    occurrences=${0}    should_exist=${False}

VerifyEgressAlarm
   [Arguments]      ${count}
    Verify Alarm    faultid=61606    occurrences=${count}    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61022    occurrences=${count}    should_exist=True    alarm_type=active
    Verify Alarm    faultid=61605    occurrences=${0}    should_exist=${False}

VerifyNoBFDAndBFDGRPAlarm
    Verify Alarm    faultid=61605    occurrences=${0}    should_exist=${False}
    Verify Alarm    faultid=61022    occurrences=${0}    should_exist=${False}
    Verify Alarm    faultid=61606    occurrences=${0}    should_exist=${False}

Verification of both Egress and Ingress Alarms
    Block upd traffic of Ingress BFD alarm
    Block upd traffic of Egress BFD alarm
    BuiltIn.Sleep    60
    VerifyIngressAlarm      ${BfdCount}
    UnBlock upd traffic of Ingress BFD alarm
    UnBlock upd traffic of Egress BFD alarm
    BuiltIn.Sleep    60
    VerifyNoBFDAndBFDGRPAlarm

Block upd traffic of Egress BFD alarm
    Setup Remote Access	    remote_device=bts
    FOR    ${value}    IN    @{bfdindex_list}
        GetBFDDetails      ${value}
        ${output}=     Run Keyword And Return Status     Should Contain      ${bfdSrcIpAddr}	:
        Run Keyword If     ${output} == True     Remote Command Execute        command=ip6tables -I OUTPUT -s ${bfdSrcIpAddr}/128 -j DROP
        Run Keyword If     ${output} == False    Remote Command Execute        command=iptables -I OUTPUT -s ${bfdSrcIpAddr}/32 -j DROP
    END
    [Teardown]    Teardown Remote Access

UnBlock upd traffic of Egress BFD alarm
    Setup Remote Access	    remote_device=bts
    FOR    ${value}    IN    @{bfdindex_list}
        GetBFDDetails      ${value}
        ${output}=     Run Keyword And Return Status     Should Contain      ${bfdSrcIpAddr}	:
        Run Keyword If     ${output} == True      Remote Command Execute        command=ip6tables -D OUTPUT -s ${bfdSrcIpAddr}/128 -j DROP
        Run Keyword If     ${output} == False     Remote Command Execute        command=iptables -D OUTPUT -s ${bfdSrcIpAddr}/32 -j DROP
    END
    [Teardown]    Teardown Remote Access

Block upd traffic of Ingress BFD alarm
    Configure Switch    device=l2switch    command_profile=port2_shut

UnBlock upd traffic of Ingress BFD alarm
    Configure Switch    device=l2switch    command_profile=port2_no_shut

Roll Back
    Run Keyword And Ignore Error    UnBlock upd traffic of Ingress BFD alarm
    Run Keyword And Ignore Error    UnBlock upd traffic of Egress BFD alarm
    Run Keyword And Ignore Error    Delete Maximum BFD and BFDGRPs

Verify BFD Packets
    Traffic Capture Start        capture_device=bts          alias=bfd
    BuiltIn.Sleep   100
    ${pcap_name}=                Traffic Capture Stop    alias=bfd
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD1    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD2    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD3    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD4    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD5    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD6    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD7    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD8    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD9    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD10    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD11    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD12    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD13    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD14    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD15    filter_file_name=${traffic_filer_file_name}

    Traffic Capture Start        capture_device=bts          alias=bfd
    BuiltIn.Sleep   50
    ${pcap_name}=                Traffic Capture Stop    alias=bfd
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD1    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD2    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD3    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD4    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD5    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD6    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD7    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD8    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD9    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD10    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD11    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD12    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD13    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD14    filter_file_name=${traffic_filer_file_name}
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=BFD15    filter_file_name=${traffic_filer_file_name}
