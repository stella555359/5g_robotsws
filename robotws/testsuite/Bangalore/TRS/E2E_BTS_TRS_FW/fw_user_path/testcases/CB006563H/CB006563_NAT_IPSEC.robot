*** Settings ***
Documentation
...		[Author]     		        "Sahana TC"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "26:10:2021"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB006563"
...     [Validated_TestLine]        "3908 NAT server IP - 10.43.82.55"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


***Test Cases***
[1][1.0] TRS_NAT-T situation with IPv4 when both BTS and Peer are behind NAT devices_CB006563

     Configure Switch    device=l2switch    command_profile=port_en
     Run Keyword And Ignore Error    certificate configure    operation=delete_cert  all_certs=${True}
     Perform Commissioning       scf_file=${SCf_3908_NAT}   verify_bts_status=False     timeout=400     alias=default
     BuiltIn.Sleep  600
     Install BTS Certificates
     Peform delta Commissioning - set flag to false
     BuiltIn.Sleep  100
     Check Dpd alarms
     enable NAT-T flag
     BuiltIn.Sleep  40
     Check ipsec tunnel status
     Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
     Configure Switch    device=l2switch    command_profile=port_dis

*** Keywords ***
Perform Commissioning - full scf with NAT-T flag false
    Perform Commissioning       scf_file=${SCf_3908_NAT}   verify_bts_status=False     timeout=400     alias=default
    BuiltIn.Sleep    300


Peform delta Commissioning - set flag to false
    Perform Recommissioning     type=param     param_path=${actnatt}    operation=update        value=false     timeout=300

Install BTS Certificates
    Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${IP_BTSCertpass}
    BuiltIn.Sleep    20

Check ipsec tunnel status
    Verify Ipsec Tunnels Status

check rekeying part
    Log     Step1
    Execute command on ENodeB		 ipsec statusall | grep "conn[1]" | tail -3 | head -1 | awk '{ print $10 }''{ print $11 }'
    ${key_1}=		Set Variable	${stdout}
    Set Suite Variable      ${key_1}      ${key_1}
    Log     Step2
    BuiltIn.Sleep  200
    Execute command on ENodeB		 ipsec statusall | grep "conn[1]" | tail -3 | head -1 | awk '{ print $10 }''{ print $11 }'
    ${key_2}=		Set Variable	${stdout}
    Set Suite Variable      ${key_2}      ${key_2}
    Should Not Be Equal		${key_1}    		${key_2}

enable NAT-T flag
    Perform Recommissioning     type=param     param_path=${actnatt}    operation=update        value=true     timeout=300

Check Dpd alarms
    [Arguments]		${occurrences}=1    	${alias}=default
	Verify Alarm		faultid=61030		occurrences=${occurrences}	alias=${alias}

verify NAT-D packets
    Traffic Capture Start        capture_device=oam_device    mode=file     measurement_point=Transport_Interface
    ...     uplane_capturing=True   timeout=180     alias=default
    BuiltIn.Sleep	60
    ${pcap_file}=  Traffic Capture Stop    mode=file   alias=default
    Run  mv ${pcap_file} ${EXECDIR}/gtp.pcap
    Analyse Pcap  pcap_filename=${EXECDIR}/gtp.pcap  analysis=verify_isakmp_packets  filter_file_name=${filter}
    Analyse Pcap  pcap_filename=${EXECDIR}/gtp.pcap  analysis=verify_esp_packets  filter_file_name=${filter}
