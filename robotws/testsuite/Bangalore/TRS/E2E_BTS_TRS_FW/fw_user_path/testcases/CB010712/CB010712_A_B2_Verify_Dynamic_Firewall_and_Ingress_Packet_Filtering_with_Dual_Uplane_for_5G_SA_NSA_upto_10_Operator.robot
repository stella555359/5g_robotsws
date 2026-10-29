*** Settings ***
Documentation
...		[Author]     		        "Shreya C"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "20:05:2024"
...		[QC_Path]                   "QC_Path in Test Plan"
...		[QC_ID]			            "QC_ID in Test Lab for reporting"
...		[Feature_ID] 		        "CB010712, CB006557, CB006540"
...     [Validated_TestLine]        "KVM53-TRSIV-TL012"
...		[Procedure]   		        "TRS_CB010712_A_B2_Verify_Dynamic_Firewall_and_Ingress_Packet_Filtering_with_Dual_Uplane_for_5G_SA_NSA_
...                                  upto_10_Operator"
...     [Precondition]              "ASIM + ASIM hardware is required with Airphone"
...     [Config_Comments]           "Verify Dynamic Firewall, Ingress Packet Filtering"
...     [Function_Hash_Tags]        "SANSA 10 Operator RAN Sharing, firewall rules check for UPlane and CPlane"

Resource        ${CURDIR}/resources/CB010712_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Variables ***
${profile}               Ingress_Packet_Filtering_ipv4
*** Test Cases ***
[1]CB010712_A_B2_Verify_Dynamic_Firewall_and_Ingress_Packet_Filtering_with_Dual_Uplane_for_5G_SA_NSA_upto_10_Operator
	Perform Commissioning       scf_file=${Configuration_3791_scf_basic}    verify_bts_status=False     timeout=400     alias=default
    Sleep    240
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_dual_u_plane_1_operator}      timeout=180
    Sleep   60
    Check and Verify firewall rules before enabling RAN sharing flag
    Perform Recommissioning		type=delta	  delta_file=${Configuration_delta_dual_u_plane_6_operator}      timeout=180
    Sleep   60
    Check and Verify firewall rules after enabling 6 Operator RAN sharing
    Perform Recommissioning     type=delta    delta_file=${Configuration_delta_dual_u_plane_10_operator}      timeout=240
    Sleep   60
    Check and Verify firewall rules after enabling 10 Operator RAN sharing
    Perform Recommissioning		type=param	  param_path=NRBTS-1:actDynamicFirewall   operation=update   value=true  timeout=300
	Check and Verify firewall rules after enabling 10 Operator RAN sharing
    [TEARDOWN]    Keyword to Run at end


*** Keywords ***
Check and Verify firewall rules before enabling RAN sharing flag
    Setup Remote Access      remote_device=bts      alias=session
    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 38412 | grep 38412-38412 | awk '{print $1}'
    ...    alias=session
    @{ngcplane_ids}=     Split String         ${stdout}
    ${no_of_ngcplane_ids}=      Get Length      ${ngcplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_ngcplane_ids}    	${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 38422 | grep 38422-38422 | awk '{print $1}'
    ...   alias=session
    @{xncplane_ids}=     Split String         ${stdout}
    ${no_of_xncplane_ids}=      Get Length      ${xncplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_xncplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 36422 | grep 36422-36422 | awk '{print $1}'
    ...   alias=session
    @{x2cplane_ids}=     Split String         ${stdout}
    ${no_of_x2cplane_ids}=      Get Length      ${x2cplane_ids}
    ${expected_value}=    Convert to Integer    2
    Should Be Equal       ${no_of_x2cplane_ids}       ${expected_value}

    ${stdout}=    Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 36412 | grep 36412-36412 | awk '{print $1}'
    ...   alias=session
    @{s1cplane_ids}=     Split String         ${stdout}
    ${no_of_s1cplane_ids}=      Get Length      ${s1cplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_s1cplane_ids}       ${expected_value}
    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 38412 | grep 38412-38412 | awk '{print $1}'
    ...   alias=session
    @{ngcplane_ids}=     Split String         ${stdout}
    ${no_of_ngcplane_ids}=      Get Length      ${ngcplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_ngcplane_ids}     ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 38422 | grep 38422-38422 | awk '{print $1}'
    ...   alias=session
    @{xncplane_ids}=     Split String         ${stdout}
    ${no_of_xncplane_ids}=      Get Length      ${xncplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_xncplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 36422 | grep 36422-36422 | awk '{print $1}'
    ...   alias=session
    @{x2cplane_ids}=     Split String         ${stdout}
    ${no_of_x2cplane_ids}=      Get Length      ${x2cplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_x2cplane_ids}       ${expected_value}

    ${stdout}=    Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 36412 | grep 36412-36412 | awk '{print $1}'
    ...  alias=session
    @{s1cplane_ids}=     Split String         ${stdout}
    ${no_of_s1cplane_ids}=      Get Length      ${s1cplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_s1cplane_ids}       ${expected_value}
    [TEARDOWN]         Teardown Remote Access       alias=session

Check and Verify firewall rules after enabling 6 Operator RAN sharing
    Setup Remote Access      remote_device=bts      alias=session
    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 38412 | grep 38412-38412 | awk '{print $1}'
    ...  alias=session
    @{ngcplane_ids}=     Split String         ${stdout}
    ${no_of_ngcplane_ids}=      Get Length      ${ngcplane_ids}
    ${expected_value}=    Convert to Integer    6
    Should Be Equal       ${no_of_ngcplane_ids}     ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 38422 | grep 38422-38422 | awk '{print $1}'
    ...  alias=session
    @{xncplane_ids}=     Split String         ${stdout}
    ${no_of_xncplane_ids}=      Get Length      ${xncplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_xncplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 36422 | grep 36422-36422 | awk '{print $1}'
    ...   alias=session
    @{x2cplane_ids}=     Split String         ${stdout}
    ${no_of_x2cplane_ids}=      Get Length      ${x2cplane_ids}
    ${expected_value}=    Convert to Integer    7
    Should Be Equal       ${no_of_x2cplane_ids}       ${expected_value}

    ${stdout}=    Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 36412 | grep 36412-36412 | awk '{print $1}'
    ...   alias=session
    @{s1cplane_ids}=     Split String         ${stdout}
    ${no_of_s1cplane_ids}=      Get Length      ${s1cplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_s1cplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 38412 | grep 38412-38412 | awk '{print $1}'
    ...   alias=session
    @{ngcplane_ids}=     Split String         ${stdout}
    ${no_of_ngcplane_ids}=      Get Length      ${ngcplane_ids}
    ${expected_value}=    Convert to Integer    6
    Should Be Equal       ${no_of_ngcplane_ids}     ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 38422 | grep 38422-38422 | awk '{print $1}'
    ...   alias=session
    @{xncplane_ids}=     Split String         ${stdout}
    ${no_of_xncplane_ids}=      Get Length      ${xncplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_xncplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 36422 | grep 36422-36422 | awk '{print $1}'
    ...   alias=session
    @{x2cplane_ids}=     Split String         ${stdout}
    ${no_of_x2cplane_ids}=      Get Length      ${x2cplane_ids}
    ${expected_value}=    Convert to Integer    7
    Should Be Equal       ${no_of_x2cplane_ids}       ${expected_value}

    ${stdout}=    Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 36412 | grep 36412-36412 | awk '{print $1}'
    ...  alias=session
    @{s1cplane_ids}=     Split String         ${stdout}
    ${no_of_s1cplane_ids}=      Get Length      ${s1cplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_s1cplane_ids}       ${expected_value}
    [TEARDOWN]         Teardown Remote Access       alias=session

Check and Verify firewall rules after enabling 10 Operator RAN sharing
    Setup Remote Access      remote_device=bts      alias=session
    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 38412 | grep 38412-38412 | awk '{print $1}'
    ...  alias=session
    @{ngcplane_ids}=     Split String         ${stdout}
    ${no_of_ngcplane_ids}=      Get Length      ${ngcplane_ids}
    ${expected_value}=    Convert to Integer    10
    Should Be Equal       ${no_of_ngcplane_ids}     ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 38422 | grep 38422-38422 | awk '{print $1}'
    ...  alias=session
    @{xncplane_ids}=     Split String         ${stdout}
    ${no_of_xncplane_ids}=      Get Length      ${xncplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_xncplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 36422 | grep 36422-36422 | awk '{print $1}'
    ...   alias=session
    @{x2cplane_ids}=     Split String         ${stdout}
    ${no_of_x2cplane_ids}=      Get Length      ${x2cplane_ids}
    ${expected_value}=    Convert to Integer    7
    Should Be Equal       ${no_of_x2cplane_ids}       ${expected_value}

    ${stdout}=    Remote Command Execute     command=${firewall_rule_check_cmd_v4} | grep 36412 | grep 36412-36412 | awk '{print $1}'
    ...  alias=session
    @{s1cplane_ids}=     Split String         ${stdout}
    ${no_of_s1cplane_ids}=      Get Length      ${s1cplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_s1cplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 38412 | grep 38412-38412 | awk '{print $1}'
    ...  alias=session
    @{ngcplane_ids}=     Split String         ${stdout}
    ${no_of_ngcplane_ids}=      Get Length      ${ngcplane_ids}
    ${expected_value}=    Convert to Integer    10
    Should Be Equal       ${no_of_ngcplane_ids}     ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 38422 | grep 38422-38422 | awk '{print $1}'
    ...  alias=session
    @{xncplane_ids}=     Split String         ${stdout}
    ${no_of_xncplane_ids}=      Get Length      ${xncplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_xncplane_ids}       ${expected_value}

    ${stdout}=   Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 36422 | grep 36422-36422 | awk '{print $1}'
    ...   alias=session
    @{x2cplane_ids}=     Split String         ${stdout}
    ${no_of_x2cplane_ids}=      Get Length      ${x2cplane_ids}
    ${expected_value}=    Convert to Integer    7
    Should Be Equal       ${no_of_x2cplane_ids}       ${expected_value}

    ${stdout}=    Remote Command Execute     command=${firewall_rule_check_cmd_v6} | grep 36412 | grep 36412-36412 | awk '{print $1}'
    ...  alias=session
    @{s1cplane_ids}=     Split String         ${stdout}
    ${no_of_s1cplane_ids}=      Get Length      ${s1cplane_ids}
    ${expected_value}=    Convert to Integer    1
    Should Be Equal       ${no_of_s1cplane_ids}       ${expected_value}
    [TEARDOWN]         Teardown Remote Access       alias=session

Check and Verify firewall rules after enabling RAN sharing flag
	Execute command on ENodeB      /opt/trs/bin/./vtc l4clfr ipv4 show | grep 5G_uplane | awk '{print $1}'
    @{5G_uplane_process_ids}=     Split String         ${stdout}
    ${no_of_uplane_process}=      Get Length      ${5G_uplane_process_ids}
    ${expected_value1}=    Convert to Integer    14
    Should Be Equal       ${no_of_uplane_process}    	${expected_value1}

	Execute command on ENodeB      /opt/trs/bin/./vtc l4clfr ipv4 show | grep 38412 | awk '{print $1}'
    @{5G_ngCplane_process_ids}=     Split String         ${stdout}
    ${no_of_ngCplane_process}=      Get Length      ${5G_ngCplane_process_ids}
    ${expected_value2}=    Convert to Integer    6
    Should Be Equal       ${no_of_ngCplane_process}    	${expected_value2}

    Execute command on ENodeB      /opt/trs/bin/./vtc l4clfr ipv4 show | grep 38422 | awk '{print $1}'
    @{5G_XnCplane_process_ids}=     Split String         ${stdout}
    ${no_of_XnCplane_process}=      Get Length      ${5G_XnCplane_process_ids}
    ${expected_value3}=    Convert to Integer    6
    Should Be Equal       ${no_of_XnCplane_process}      ${expected_value3}


Keyword to Run at end
    Run     sudo killall edaemon egate
    Delete Interfaces