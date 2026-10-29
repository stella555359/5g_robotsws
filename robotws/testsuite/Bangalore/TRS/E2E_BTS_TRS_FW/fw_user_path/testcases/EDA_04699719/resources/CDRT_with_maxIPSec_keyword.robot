*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Library          taf.sbts.oam.coam.admin
Library		     ${CURDIR}/../../resources/egate_library.py
Resource         ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
Resource         ${CURDIR}/../../resources/common_keywords.robot
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Variables ***
${tc_variables}     testcase_variables.json
${profile}          /home/ute/SBTS00
${Build1}           SBTS00
${buildno}          9999_250618_000011
${index}            1
${length}           1

*** Keywords ***
Verify BTS Precondition
    Verify Netact Connection
    Verify Bts Status   should_be_onair=${True}
    Verify expected_unexpected_alarms
    Verify IP Certificates   ${IP_BTSCertp12 }
    Get Ipsec Status

Perform Software Upgrade
    Perform Software Download And Update        package=auto        wft_profile=${Build1}       activate_sw=True
    ...    timeout=2600     latest_build_num=${buildno}
    Sleep   400
    Verify Bts Status   should_be_onair=${True}
    Verify expected_unexpected_alarms
    Get Ipsec Status

Verify maxIPSec
    FOR    ${index}    IN RANGE    ${length}
        Log     IKEP, IPSECP Modifications
        Perform Recommissioning      type=delta     delta_file=${ikeAuthentication&EncryptionMethod}     timeout=300
        BuiltIn.Sleep    60
        Verify Alarm      faultid=61645      occurrences=8       should_exist=${True}      alarm_type=active
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Perform Recommissioning      type=delta     delta_file=${revert_ikeAuthentication&EncryptionMethod}     timeout=300
        BuiltIn.Sleep    60
        Get Ipsec Status
        Verify Bts Status   should_be_onair=${True}
        Verify expected_unexpected_alarms
        Perform Recommissioning      type=delta     delta_file=${ikep}     timeout=300
        BuiltIn.Sleep    60
        Verify Alarm      faultid=61645      occurrences=6       should_exist=${True}      alarm_type=active
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Perform Recommissioning      type=delta     delta_file=${revert_ikep}     timeout=300
        BuiltIn.Sleep    60
        Get Ipsec Status
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Perform Recommissioning      type=delta     delta_file=${ipsecp}     timeout=300
        BuiltIn.Sleep    60
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        BuiltIn.Sleep    20
        Perform Recommissioning      type=delta     delta_file=${revert_ipsecp}     timeout=300
        BuiltIn.Sleep    60
        Get Ipsec Status
        Verify Bts Status   should_be_onair=${True}
        Verify expected_unexpected_alarms
        Log     Create Multiple traffic selector
        Perform Recommissioning      type=delta     delta_file=${additionoftrafficSelector}     timeout=300
        BuiltIn.Sleep    60
        Log     Delete traffic selector
        Perform Recommissioning      type=delta     delta_file=${deletionoftrafficSelector}     timeout=300
        BuiltIn.Sleep    60
        Verify Bts Status   should_be_onair=${True}
        Verify expected_unexpected_alarms
        Get Ipsec Status
     END

Configure Virtual IPSec and verify the tunnel status
    Certificate Configure    operation=install_certificate    cert_file=${IP_BTSCertp12_4k}    cert_type=BtsTrustChain
    ...     cert_format=P12     password=${IP_BTSCertpass}
    taf.sbts.oam.coam.admin.Perform Commissioning       scf_file=${virtual_base_scf}   verify_bts_status=${False}
    ...     timeout=400     alias=default
    BuiltIn.Sleep    300
    Verify IP Certificates      ${IP_BTSCertp12}
    Get Ipsec Status
    Verify Bts Status   should_be_onair=${True}
    Verify expected_unexpected_alarms

Verify expected_unexpected_alarms
    Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
    BuiltIn.Sleep    60

Verify expected alarm
    Verify Alarm      faultid=61645      occurrences=2       should_exist=${True}      alarm_type=active

Get Ipsec Status
	[Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
     	${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
     	${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END
    @{child_tunnel_moc_list} =      Query Admin Infomodel	query=get list ${ipsec_sa_l_moc_path}	alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
     	${child_tunnel_stateInfo}=      Get From Dictionary	dictionary=${child_tunnel}	key=stateInfo
     	${child_tunnel_proceduralState}=        Get From Dictionary	dictionary=${child_tunnel_stateInfo}	key=proceduralState
     	Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END

Verify IP Certificates
    [Arguments]     ${certificate}
	Certificate Configure    operation=install_certificate    cert_file=${certificate}  	cert_type=BtsTrustChain
    ... 	cert_format=P12 	password=${IP_BTSCertpass}
    BuiltIn.Sleep    20

Verify Netact Connection
    Setup Ems       config_device=netact2       alias=lab_1042
    Cm Upload       config_device=netact2       alias=lab_1042

verify PM counters
    PM Counters Start      analysis=verify_ipsec_counters       counter_analysis_file=${counter_analysis_file_name}
    PM Counters Start      analysis=verify_secpol_counters      counter_analysis_file=${counter_analysis_file_name}
    Pm Counters Start	   analysis=verify_secpol_counters  	counter_analysis_file=${counter_analysis_file_name}

Verify AMF reachability
    Setup Remote Access    remote_device=bts
    ${amf_reachability}=    Remote Command Execute    command=ping -c 5 -I 10.58.142.153 10.78.154.9 -s 1500
    ${amf_reachability}=    Remote Command Execute    command=ping -c 5 -I 10.58.142.153 100.70.20.75 -s 1500
    Should Contain     ${amf_reachability}    5 packets transmitted, 5 received, 0% packet loss
    Teardown Remote Access

Make Backhaul port ETHIF1 down and verify tunnel status
    Configure Switch        device=eda_switch       command_profile=disable_ports
    Sleep  100
    Run Keyword And Ignore Error    Get Ipsec Status
    Verify Dpd alarm after Ethif1 is down
    Restore Backhaul port and Verify tunnel status

Verify Dpd alarm after Ethif1 is down
    Wait Until Keyword Succeeds    5 min    30      Verify Alarm        faultid=61030    occurrences=1      should_exist=${True}
    Wait Until Keyword Succeeds    3 min    30      Verify Alarm        faultid=61029       occurrences=1       should_exist=${True}

Restore Backhaul port and Verify tunnel status
    Configure Switch        device=eda_switch      command_profile=enable_ports
    Sleep   100
    Run Keyword And Ignore Error    Get Ipsec Status
    Verify Alarm        expected_alarms=${expected_alarms}      check_unexpected_alarms=True
