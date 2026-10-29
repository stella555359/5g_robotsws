*** Settings ***
Documentation
    ...     [Procedure]             "EDA_GSM_Wcdma"
    ...     [Date]                  "17-06-25"
    ...     [Author]                "Nethra"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Wcdma"
    ...     [Feature_ID]            "RP000366,5G000265"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2204"

Library		      ${CURDIR}/../../resources/egate_library.py
Resource          ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
Resource          ${CURDIR}/../../resources/common_keywords.robot
#Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Variables ***
${tc_variables}     testcase_variables.json
${profile}          /home/ute/SBTS00/SBTS00_ENB_9999_250731_000006_release_BTSSM_downloadable_A54.zip
${Build1}           SBTS00
${buildno}          9999_250731_000006
${index}                    1
${length}                   1

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

Make 2G Calls Ipv4
    Start Ip traffic capture point A file mode       oam_device
    Call Setup    gsm=device_1:data    verify_attach=${False}    attach=${True}
    BuiltIn.Sleep    60
    Call Start    gsm=device_1:data    profile=udp_100M_ul    iperf_section=device_1
    Call Start    gsm=device_1:data    profile=udp_100M_dl    iperf_section=device_1
    BuiltIn.Sleep    120
    Run keyword And Ignore Error    Call Stop     gsm=device_1:data    profile=udp_100M_ul
    Run keyword And Ignore Error    Call Stop     gsm=device_1:data    profile=udp_100M_dl
    Call Teardown    gsm=device_1:data
    Stop Ip traffic capture in file mode
    Verify GSM Traffic related Counters
    Verify GSM error related Counters

Make 2G Calls Ipv6
    Start Ip traffic capture point A file mode       oam_device
    Call Setup    gsm=device_1:data    verify_attach=${False}    attach=${True}
    BuiltIn.Sleep    60
    Call Start    gsm=device_1:data    profile=udp_100M_ul    iperf_section=device_1
    Call Start    gsm=device_1:data    profile=udp_100M_dl    iperf_section=device_1
    BuiltIn.Sleep    120
    Run keyword And Ignore Error    Call Stop     gsm=device_1:data    profile=udp_100M_ul
    Run keyword And Ignore Error    Call Stop     gsm=device_1:data    profile=udp_100M_dl
    Call Teardown    gsm=device_1:data
    Stop Ip traffic capture in file mode
    Verify GSM Traffic related Counters
    Verify GSM error related Counters

Make 3G Calls Ipv4
    Start Ip traffic capture point A file mode       oam_device
    Call Setup    wcdma=device_1:data    verify_attach=${False}    attach=${True}
    BuiltIn.Sleep    60
    Call Start    wcdma=device_1:data    profile=udp_100M_ul    iperf_section=device_1
    Call Start    wcdma=device_1:data    profile=udp_100M_dl    iperf_section=device_1
    BuiltIn.Sleep    120
    Run keyword And Ignore Error    Call Stop     wcdma=device_1:data    profile=udp_100M_ul
    Run keyword And Ignore Error    Call Stop     wcdma=device_1:data    profile=udp_100M_dl
    Call Teardown    wcdma=device_1:data
    Stop Ip traffic capture in file mode
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=wcdma_udp_ul
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=wcdma_udp_dl
    Verify WCDMA Error related Counters
    Verify WCDMA Traffic related Counters

Make 3G Calls IPv6
    Start Ip traffic capture point A file mode       oam_device
    Call Setup    wcdma=device_1:data    verify_attach=${False}    attach=${True}
    BuiltIn.Sleep    60
    Call Start    wcdma=device_1:data    profile=udp_100M_ul    iperf_section=device_1
    Call Start    wcdma=device_1:data    profile=udp_100M_dl    iperf_section=device_1
    BuiltIn.Sleep    120
    Run keyword And Ignore Error    Call Stop     wcdma=device_1:data    profile=udp_100M_ul
    Run keyword And Ignore Error    Call Stop     wcdma=device_1:data    profile=udp_100M_dl
    Call Teardown    wcdma=device_1:data
    Stop Ip traffic capture in file mode
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=wcdma_udp_ul_v6
    Analyse Pcap    pcap_filename=${pcap_file}   analysis=wcdma_udp_dl_v6
    Verify WCDMA Traffic related Counters IPv6


Start Ip traffic capture point A file mode
    [Arguments]       ${capture_device}
    Traffic Capture Start     capture_device=${capture_device}    mode=file     measurement_point=NE_Terminated
    BuiltIn.Sleep   10

Stop Ip traffic capture in file mode
    [Arguments]        ${alias}=default
    ${pcap_file}=  Traffic Capture Stop   mode=file   alias=${alias}  timeout=120
    Set Suite Variable     ${pcap_file}


Verify WCDMA Error related Counters
    Setup Remote Access     remote_device=bts    alias=bts
    ${output}=  Execute Interactive Remote Command      command=${counter_command}     alias=bts
    ${lines}=   Split To Lines       ${output}
    Log  ${lines}
    FOR     ${counter}  IN  @{wcdma_error_counters}
        ${val}    ${counter_value}  Should match Regexp  ${output}  ${counter}\\D*(\\d+)
        ${bool}    Evaluate     ${counter_value}==0
        Should Be True    ${bool}
    END
    Teardown Remote Access      alias=bts


Verify WCDMA Traffic related Counters
    Setup Remote Access     remote_device=bts    alias=bts
    ${output}=  Execute Interactive Remote Command      command=${counter_command}     alias=bts
    ${lines}=   Split To Lines       ${output}
    Log  ${lines}
    FOR     ${counter}  IN  @{wcdma_traffic_counters}
        ${val}    ${counter_value}  Should match Regexp  ${output}  ${counter}\\D*(\\d+)
        ${bool}    Evaluate     ${counter_value}!=0
        Should Be True    ${bool}
    END
    Teardown Remote Access      alias=bts


Verify WCDMA Traffic related Counters IPv6
    Setup Remote Access     remote_device=bts    alias=bts
    ${output}=  Execute Interactive Remote Command      command=${counter_command}     alias=bts
    ${lines}=   Split To Lines       ${output}
    Log  ${lines}
    FOR     ${counter}  IN  @{wcdma_traffic_counters_v6}
        ${val}    ${counter_value}  Should match Regexp  ${output}  ${counter}\\D*(\\d+)
        ${bool}    Evaluate     ${counter_value}!=0
        Should Be True    ${bool}
    END
    Teardown Remote Access      alias=bts


Verify GSM error related Counters
    Setup Remote Access     remote_device=bts    alias=bts
    ${output}=  Execute Interactive Remote Command      command=${counter_command_gsm}     alias=bts
    ${lines}=   Split To Lines       ${output}
    Log  ${lines}
    FOR     ${counter}  IN  @{gsm_error_counters}
        ${val}    ${counter_value}  Should match Regexp  ${output}  ${counter}\\D*(\\d+)
        ${bool}    Evaluate     ${counter_value}== 0
        Should Be True    ${bool}
    END
    Teardown Remote Access      alias=bts


Verify GSM Traffic related Counters
    Setup Remote Access     remote_device=bts    alias=bts
    ${output}=  Execute Interactive Remote Command      command=${counter_command_gsm}     alias=bts
    ${lines}=   Split To Lines       ${output}
    Log  ${lines}
    FOR     ${counter}  IN  @{gsm_traffic_counters}
        ${val}    ${counter_value}  Should match Regexp  ${output}  ${counter}\\D*(\\d+)
        ${bool}    Evaluate     ${counter_value}!=0
        Should Be True    ${bool}
    END
    Teardown Remote Access      alias=bts

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
