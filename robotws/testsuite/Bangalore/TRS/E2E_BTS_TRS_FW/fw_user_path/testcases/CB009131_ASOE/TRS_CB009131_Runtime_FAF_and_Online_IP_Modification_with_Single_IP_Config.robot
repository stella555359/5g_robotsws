*** Settings ***
Documentation
    ...     [Author]     	       "Hrudya V N"
    ...	    [Maintenance]	       "TRS I&V Tools Bangalore Team"
    ...	    [Date] 		           "19:05:2021"
    ...	    [QC_Path]              "QC_Path in Test Plan"
    ...	    [QC_ID]		           "QC_ID in Test Lab for reporting"
    ...	    [Feature_ID]           "CB009131"
    ...     [Validated_TestLine]   "KVM53-TRSIV-TL006"
    ...	    [Procedure]            "TRS_CB009131_Runtime_FAF_and_Online_IP_Modification_with_Single_IP_Config"
    ...     [Precondition]         "ASIB and ASIB hardware is required"
    ...     [Config_Comments]      "Shared VLAN NG-U NG-C Xn-U and Xn-C IPs for 6 Operators_IPv4"
    ...     [Function_Hash_Tags]   "SA 6 Operator RAN Sharing, Dual Stack, verify 6 operator call with Airphone"
variables       ta_e2e_bts_trs_fw
Resource    	${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/admin_oam_common_keywords.robot
Resource        ${CURDIR}/resources/CB009131_common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops
***Test Cases***
[1][1.0] TRS_CB009131_Runtime_FAF_and_Online_IP_Modification_with_Single_IP_Config
    Run Keyword And Ignore Error  Perform Commissioning       scf_file=${basic_scf}   verify_bts_status=False
    ...		timeout=600
    Perform Recommissioning         type=param       param_path=${actDynamicFirewall_param_path}    value=true
    ...     timeout=300   operation=update
    Run     sudo killall egate edaemon
    Sleep    30
    Perform 5G call for uplink traffic      mtu_value=1500
    Verify Alarm    expected_alarms=${expected_alarms}
    Perform Recommissioning        type=delta             delta_file=${add_IP}          timeout=600
    Sleep   80
    Perform Recommissioning        type=delta             delta_file=${modify_IPs}          timeout=600
    Sleep   10
    Perform 5G call for uplink traffic for modified IP      mtu_value=1500