*** Settings ***
Documentation
...		author: Kancham Reddy Madhuri Reddy, Sreekumar Narimuri Kumaran, Lekhashree S N
...		contact: kancham.reddy_madhuri_reddy@nokia.com
...		description:


Resource    ${CURDIR}/resources/CB011062_Keywords.robot

Suite Setup    Run Keywords      UTE_ORAN_TL_Bringup_Precondition
...    AND    Check fault 23 and fix
...    AND    Wait Until BTS is OnAir
...    AND    Set export yml    ${VM_IP}
...    AND    Copy swconfig to BTS    ${swconfig_path}
...    AND    Common Suite Setup

Suite Teardown      Common Suite Teardown
Test Setup      	Common Test Setup
Test Teardown   	Common Test Teardown




*** Test Cases ***
CB011062_CB005891_Automated_power_reset_via_NetAct
    ${out}    set variable
    ...   ${SUITE_PATH}CB011062TESTSUITE/CB011062_CB005891-Automated_power_reset_via_NetAct/
    set test variable    ${out}
    create directory     ${out}
    Check BTS is OnAir	   oam
	Perform Resets from Netact

TC_Diagnostic_check_started_for_the_single_BTS_via_NetAct
    ${out}    set variable
    ...   ${SUITE_PATH}CB011062TESTSUITE/TC_Diagnostic_check_started_for_the_single_BTS_via_NetAct/
    set test variable    ${out}
    create directory     ${out}
    Dcap Start Trace SA
    Preconditions
    Turn off RMOD to generate FID:10
    Run Diagnostic Check allow_service_impact=False
    Check if FaultID 4681 appeared on NetAct
    Turn on RMOD from pdu
    Run Diagnostic Check allow_service_impact=True
    Attach UE and start throughput   ${UE_alias}    ${direction_dl}    ${timeout}
    Dcap Stop Trace and Get results SA      ${testcase_name}

CB011062_CB007227_Activation_of_PCMD_measurements_for_U_Plane_gNB_CU_UP
    ${out}    set variable
	...   ${SUITE_PATH}CB011062TESTSUITE/CB011062_CB007227_Activation_of_PCMD_measurements_for_U_Plane_gNB_CU_UP/
    set test variable    ${out}
    create directory     ${out}
    Dcap Start Trace SA
	Attach UE and start throughput   ${UE_alias}    ${direction_dl}    ${timeout}
	Dcap Stop Trace and Get results SA      ${testcase_name}
	${file}=	Convert wireshark pcap File To Text    ${testcase_name}    ${filter_pcmd}
	validate wireshark logs    ${file}    cuUpRecordingSessionReportList    ${PCMD_cont}