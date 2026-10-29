*** Settings ***
Documentation
...		[Author]     		        "Pranitha & Shankar"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "26:10:2021"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB006563"
...     [Validated_TestLine]        "3297 NAT server IP - 10.45.138.174, Secgw ip - 10.43.255.224"


Variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource    	${CURDIR}/../resources/Admin_Common_Library.robot
Resource    	${CURDIR}/../resources/Common_IPSEC_Operations.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND	    Teardown Oamops


*** Variables ***

${SCf_3297_NAT}       /home/ute/fw_user_path/config/1/scfc_files/SCFC_3297_NAT_Scenario_1.xml
${SCf_3297_NAT_mixed}	/home/ute/fw_user_path/config/1/scfc_files/SCFC_3297_NAT_Scenario_Mixed_Scenario1&2.xml


*** Test Cases ***
[1][2.0] TRS_NAT-T Activation and Deactivation at runtime in NAT-T situation (actNatT and DPD)_CB006563
     Perform Commissioning       scf_file=${SCf_NAT}   verify_bts_status=False     timeout=400     alias=default
     Sleep  300
     Perform delta Commissioning - set flag to false
     Sleep  60
     Check Dpd alarms
	 Sleep  30
     enable NAT-T flag
     Sleep  20
     Check ipsec tunnel status
     check rekeying part
     verify NAT-D packets


*** Keywords ***
Perform delta Commissioning - set flag to false
    Perform Recommissioning     type=param     param_path=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1:actNatT
    ...  operation=update        value=false     timeout=300


Check ipsec tunnel status
    Verify Ipsec Tunnels Status

check rekeying part
#Step1
    ${numbers}=    Evaluate    random.sample(range(1, 7), 1)    random
    Execute command on ENodeB		 ipsec statusall | grep "conn${numbers}" | tail -3 | head -1 | awk '{ print $10 }''{ print $11 }'
    ${key_1}=		Set Variable	${stdout}
    Set Suite Variable      ${key_1}      ${key_1}
#Step2
    Sleep  200
    Execute command on ENodeB		 ipsec statusall | grep "conn${numbers}" | tail -3 | head -1 | awk '{ print $10 }''{ print $11 }'
    ${key_2}=		Set Variable	${stdout}
    Set Suite Variable      ${key_2}      ${key_2}
    Should Not Be Equal		${key_1}    		${key_2}

enable NAT-T flag
    Perform Recommissioning     type=param     param_path=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1:actNatT    operation=update
    ...        value=true     timeout=300


Check Dpd alarms
    [Arguments]		${occurrences}=7    	${alias}=default
	Verify Alarm		faultid=61030		occurrences=${occurrences}	alias=${alias}

verify NAT-D packets
    Traffic Capture Start        capture_device=oam_device    mode=file     measurement_point=Transport_Interface  uplane_capturing=True
    ...   timeout=180     alias=default
    Sleep	60
    ${pcap_file}=  Traffic Capture Stop    mode=file   alias=default
    Run  mv ${pcap_file} ${EXECDIR}/gtp.pcap
    Analyse Pcap  pcap_filename=${EXECDIR}/gtp.pcap  analysis=verify_isakmp_packets  filter_file_name=${filter_file_name}
    Analyse Pcap  pcap_filename=${EXECDIR}/gtp.pcap  analysis=verify_esp_packets  filter_file_name=${filter_file_name}
