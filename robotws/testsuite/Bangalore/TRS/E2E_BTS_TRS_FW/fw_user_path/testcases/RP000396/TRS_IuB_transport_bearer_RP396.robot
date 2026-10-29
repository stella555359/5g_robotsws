***Settings ***
Documentation
    ...     [Procedure]             "2G & 3G UE call automation"
    ...     [Date]                  "09-05-2025"
    ...     [Author]                "Dinesh"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Feature_ID             "TRS_VRF Improvement Action for 4611589"
    ...     [Validation_status]     "Validated and Passed"

Library			ute_fsmaccess
Library			SSHLibrary
Library         taf.sbts.oam.coam.admin
Library         taf.ul.trs_e2e_fw.lib.call_utils.call_interface
Library         taf.ul.trs_e2e_fw.lib.call_utils.call_utils
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot

variables       ta_e2e_bts_trs_fw

Suite Setup     Setup Oamops
Suite Teardown     Teardown Oamops

*** Test Cases ***
[1][2.0] TRS_IuB_transport_bearer_RP396
    Verify 3G UE call
####jira
    FOR    ${i}    IN RANGE    1    11
	    Backhaul link fluctuation
	    Verify 3G UE call
    END

***keywords***
Verify 3G UE call
    ${wcdma_uplane} =    Get Parameter    rat=common    param_path=${wcdma_uplane_ip_moc_path}
    Set Suite Variable    ${wcdma_uplane}    ${wcdma_uplane}
    Enable Airplane mode
    taf.ul.trs_e2e_fw.lib.traffic.traffic_interface.Traffic Capture Start        capture_device=oam_device   mode=file
    ...    measurement_point=NE_Terminated  uplane_capturing=True   timeout=120
    Initiate 3G Call and Verify UE IP
    Call Start      wcdma=device_1:data        profile=udp_10K_dl       iperf_section=device1
    Call Start      wcdma=device_1:data        profile=udp_10K_ul       iperf_section=device1
    BuiltIn.Sleep    20
    Call Stop       wcdma=device_1:data        profile=udp_10K_dl        iperf_section=device1
    Call Stop       wcdma=device_1:data        profile=udp_10K_ul        iperf_section=device1
    Call Teardown        wcdma=device_1:data
    ${3g_pcap}=   taf.ul.trs_e2e_fw.lib.traffic.traffic_interface.Traffic Capture Stop     mode=file     timeout=120
    Set Suite Variable      ${3g_pcap}
    taf.ul.trs_e2e_fw.lib.traffic.traffic_interface.Analyse Pcap    pcap_filename=${3g_pcap}        analysis=UDP_DL
    ...    filter_file_name=${3gcall_traffic}
    Verify Alarm    faultid=16    should_exist=${False}
    Verify Alarm    faultid=17    should_exist=${False}

Initiate 3G Call and Verify UE IP
    ${ue_ip_dict}=  Call Setup      wcdma=device_1:data    parallel=${False}         verify_attach=${False}
    ${ip}=    Get From Dictionary    ${ue_ip_dict}    ${3G_UE}
    Set Suite Variable    ${${3G_UE}}    ${ip}
    Log    UE IP for WCDMA set to: ${ip}
    BuiltIn.Should Match Regexp    ${ip}    ^(10|9a00)

Enable Airplane mode
    Setup Remote Access         remote_device=raspi           alias=default
    Remote Command Execute              command=adb -s RZCW918YZ1F shell cmd connectivity airplane-mode enable

Backhaul link fluctuation
    Configure Switch    link1    shutdown_te_interface
    BuiltIn.Sleep    10
    Verify Ping Should Fail	10.71.249.133
    Setup Remote Access    remote_device=bts    timeout=20    alias=bts
    Verify Ping Fails From BTS    10.63.24.204
    Verify Bts Status    req_rat=wcdma    should_be_onair=${False}    timeout=10    alias=default
    Configure Switch    link1    noshutdown_te_interface
    BuiltIn.Sleep   60
    Verify Ping Should Pass    10.71.249.133
    BuiltIn.Sleep   30
    Verify Ping Success    10.63.24.204
    Verify Bts Status    req_rat=wcdma    should_be_onair=${True}    timeout=10    alias=default

Verify Ping Should Fail
    [Arguments]    ${ip}
    ${rc}    ${out}=    Run And Return Rc And Output    ping -c 5 ${ip}
    Log    ${out}
    Should Not Be Equal As Integers    ${rc}    0

Verify Ping Should Pass
    [Arguments]    ${ip}
    ${rc}    ${out}=    Run And Return Rc And Output    ping -c 10 ${ip}
    Log    ${out}
    Should Be Equal As Integers    ${rc}    0
Verify Ping Fails From BTS
    [Arguments]    ${ip}
    ${out}=    Remote Command Execute
    ...    command=ping -c 5 ${ip}
    ...    alias=bts
    Log    ${out}
    Should Not Contain    ${out}    bytes from

Verify Ping Success
    [Arguments]    ${ip}
    ${output}=    Remote Command Execute
    ...    command=ping -c 5 ${ip}
    ...    alias=bts
    Log    ${output}
    Should Contain    ${output}    bytes from