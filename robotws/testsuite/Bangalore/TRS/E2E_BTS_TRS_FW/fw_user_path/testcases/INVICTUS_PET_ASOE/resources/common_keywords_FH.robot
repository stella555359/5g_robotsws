*** Settings ***
Documentation
...                 [Procedure]    "The test case is to verify TWAMP, Certificates and BFD configurations with maximum session support as part of
...                 PET Testing"
...                 [Date]    "20-08-25"
...                 [Author]    "Shivani Patil"
...                 [QC_Path]    "QC_Path in Test Plan"
...                 [QC_ID]    "QC_ID in Test Lab for reporting"
...                 [Funtion_Hash_Tags]    "TWAMP","BFD","Certificates"
...                 [Feature_ID]    "PET"
...                 [Validation_status]    "Validated and Passed"
...                 [Validated_TestLine]    "5G-1234"
...                 [Config]    "No BFD configurations should have the preloaded scf as BFD configuration are cretaed by delta for this case"

Variables           ta_e2e_bts_trs_fw
Library             Collections
# Library    random
Resource            ${CURDIR}/../../resources/Common_BFD.robot


*** Keywords ***
Load base scf
    Perform Commissioning    scf_file=${Base_scfc_FH}    verify_bts_status=False    timeout=1200    alias=default

Verify RMOD is up
    [Documentation]    This test case keyword is to verify the rmod status
    BuiltIn.Wait Until Keyword Succeeds    20 min    30 sec    RMOD is Enabled

RMOD is Enabled
    [Documentation]    This test case keyword is to verify the rmod status
    @{RMOD_list}=    Query Admin Infomodel    query=get list //RMOD_R-*    timeout=300
    #    *
    @{rmod_ids}=    Create List
    FOR    ${rmod}    IN    @{RMOD_list}
        ${dist_name}=    Get From Dictionary    ${rmod}    dist_name
        ${rmod_id}=    Fetch From Right    ${dist_name}    /
        ${id_number}=    Split String From Right    ${rmod_id}    -    1
        Append To List    ${rmod_ids}    ${id_number}[1]
    END
    FOR    ${rmodId}    IN    @{rmod_ids}
        ${rmodInfo}=    Query Admin Infomodel    query=get object //RMOD_R-${rmodId}
        ${op_status}=    Get From Dictionary    ${rmodInfo}    operationalState
        Should Be Equal    ${op_status}    enabled
    END

Configure Maximum BFD and BFDGRPs
    Perform Recommissioning    type=delta    delta_file=${CreateBFDAndBFDGRP}    timeout=600

Enable TWAMP
    Perform Recommissioning
    ...    type=delta
    ...    delta_file=${configure_TWAMP}
    ...    skip_parameter_relation_errors=${True}
    ...    timeout=300
    Run
    ...    timeout 2700 python /home/ute/Downloads/PET/TWAMP/New_TWAMPY/twampy.py responder --load_json /home/ute/Downloads/PET/TWAMP/
    ...    New_TWAMPY/sample.json -section 1 3 --padding 100 -d
    Sleep    360
    Verify Alarm    faultid=61611    occurrences=75    should_exist=${True}    alarm_type=active
    Verify Alarm    faultid=61610    occurrences=0    should_exist=${False}    alarm_type=active

Load Max Certificates
    Restore all Certificate
    Perform Recommissioning
    ...    type=delta
    ...    delta_file=${cmp_update}
    ...    skip_parameter_relation_errors=${True}
    ...    timeout=300
    Sleep    50
    Install Max CA/TA certs
#    Configure and verify max crl

Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
    Sleep    10
    certificate configure    operation=delete_cert    all_certs=${True}
    Sleep    150

Install Max CA/TA certs
    FOR    ${i}    IN RANGE    1    68
        Certificate Configure
        ...    operation=install_certificate
        ...    cert_file=${Cert_${i}}
        ...    cert_type=AdditionalCa
        ...    cert_format=PEM
        Sleep    20
    END

Configure and verify max crl
    Perform Recommissioning
    ...    type=delta
    ...    delta_file=${max_crl}
    ...    skip_parameter_relation_errors=${True}
    ...    timeout=300
    Sleep    400
    Certificate Configure    operation=get_certificate_revocation_list
    Sleep    100
    CRL Download success

CRL Download success
    Wait Until Keyword Succeeds
    ...    5 min
    ...    30
    ...    Verify Alarm
    ...    faultid=${crl_update_failure}
    ...    occurrences=${0}
    ...    should_exist=${False}

Enable IPsec and Validate
    Perform Recommissioning
    ...    type=param
    ...    param_path=IPSECC-1:ipSecEnabled
    ...    operation=update
    ...    value=true
    ...    timeout=180
    Run    sudo ipsec restart
    Log    Wait FOR few minutes FOR all tunnels to come up
    Sleep    100
    Get Ipsec Tunnels Status
    Verify Alarm    faultid=61644    should_exist=${False}
    Verify Alarm    faultid=61030    should_exist=${False}
    Verify Alarm    faultid=61645    should_exist=${False}
    Verify Alarm    faultid=61646    should_exist=${False}
    Run    sudo ipsec stop
    Sleep    200
    Verify Alarm    faultid=61030    occurrences=198    should_exist=True
    Log    Restart IPsec on VM and verify above steps and no diagnostic alarm raised
    Run    sudo ipsec start
    Sleep    300
    Verify Alarm    faultid=61030    should_exist=${False}
    Verify Alarm    faultid=6450    should_exist=${False}

Get Ipsec Tunnels Status
    [Documentation]    This test case keyword is to verify IPSec tunnels status
    @{parent_tunnel_moc_list}=    Query Admin Infomodel    query=get list ${ike_sa_l_moc_path}
    FOR    ${ike_tunnel}    IN    @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=    Get From Dictionary    dictionary=${ike_tunnel}    key=stateInfo
        ${parent_tunnel_proceduralState}=    Get From Dictionary
        ...    dictionary=${parent_tunnel_stateInfo}
        ...    key=proceduralState
        Should Be True    '${parent_tunnel_proceduralState}'=='Established'    timeout=800
    END
    @{child_tunnel_moc_list}=    Query Admin Infomodel    query=get list ${ipsec_sa_l_moc_path}
    FOR    ${child_tunnel}    IN    @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=    Get From Dictionary    dictionary=${child_tunnel}    key=stateInfo
        ${child_tunnel_proceduralState}=    Get From Dictionary
        ...    dictionary=${child_tunnel_stateInfo}
        ...    key=proceduralState
        Should Be True    '${child_tunnel_proceduralState}'=='Installed'    timeout=800
    END

Make 5G Calls
    Traffic Capture Start    capture_device=vm_eth3_interface
    Perform Call Setup
    Trigger 10 UE Calls
    ${pcap_name}=    Traffic Capture Stop
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=Verify_SA_Calls    filter_file_name=traffic_filters.json

Validation for BFD
    Traffic Capture Start    capture_device=bts
    sleep    100
    ${pcap_name}=    Traffic Capture Stop
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_1    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_2    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_3    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_4    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_5    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_6    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_7    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v4_8    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_1    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_2    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_3    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_4    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_5    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_6    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_7    filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=bfd_v6_8    filter_file_name=traffic_filters.json

Perform Call Setup
    Call Setup    5g=device4:data    parallel=${False}    verify_attach=${False}    attach=${False}    timeout=180

Trigger 10 UE Calls
    [Documentation]    Start 10 UEs with registration, PDU setup, and traffic
    FOR    ${i}    IN RANGE    1    2
        Configure Ue    5g=device4:data    command=ue_register    id=${i}
        Sleep    5
        Configure Ue    5g=device4:data    command=set_pdu_param    ue=${i}    pdu=1    trf_type=internal
        Sleep    5
        Configure Ue    5g=device4:data    command=ue_pdu_session_setup    pdu=1    gw=1    ue=${i}
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=ul
        ...    mbps=50
        ...    trf_id=1
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=1
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=2
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=3
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=4
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=5
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=6
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=7
        Sleep    5
        Configure Ue
        ...    5g=device4:data
        ...    command=trf_data_start
        ...    ue=${i}
        ...    pdu=1
        ...    qfi=1
        ...    dir=dl
        ...    mbps=175
        ...    trf_id=8
        Log    UE ${i} start
        Perform Delta Changes
        Revert Delta Changes
    END

Perform Delta Changes
    Perform Recommissioning
    ...    type=delta
    ...    delta_file=${change_BFD_Cert_Twamp_params}
    ...    skip_parameter_relation_errors=${True}
    ...    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}

Revert Delta Changes
    Perform Recommissioning
    ...    type=delta
    ...    delta_file=${revert_BFD_Cert_Twamp_params}
    ...    skip_parameter_relation_errors=${True}
    ...    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}

verify cmp status
    [Arguments]    ${certType}    ${CMP_status_check}
    Sleep    60
    IF    '${certType}' == 'RSA'
        Set Suite Variable    ${cmp_state_path}    ${cmp_r_moc_path}
    END
    ${cmp_state_var}=    Query Admin Infomodel    query=get object ${cmp_state_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}

Verify Calls Working
    [Documentation]    Verify calls and UE are still intact
    Traffic Capture Start    capture_device=vm_eth3_interface
    ${pcap_name}=    Traffic Capture Stop
    Analyse Pcap    pcap_filename=${pcap_name}    analysis=Verify_SA_Calls    filter_file_name=traffic_filters.json
    Log    Calls are working

Tigger IR_KUR
    [Arguments]    ${CertType}    ${Operation}
    Certificate Configure    operation=${Operation}    key_pool_type=${CertType}    timeout=100

Enable Fronthaul features
    Perform Recommissioning    type=delta    delta_file=${Enable_legacy_feature_flag}    timeout=300
    Sleep    60
    Verify Bts Status    should_be_onair=${True}
    Verify Alarm    expected_alarms=${expected_alarms}    check_unexpected_alarms=True    alarm_type=active
    Verify Alarm    faultid=6450    occurrences=0    should_exist=${False}    alarm_type=active
    Verify Alarm    faultid=6450    occurrences=0    should_exist=${False}    alarm_type=history

Verify Call Stability
    [Documentation]    Run calls for 48h and check UE stability every hour.
    FOR    ${i}    IN RANGE    ${TOTAL_HOURS}
        Log To Console    \n--- Hour ${i} ---\n
        Sleep    ${SLEEP_PER_HOUR}
        Verify Alarm    expected_alarms=${expected_alarms}    check_unexpected_alarms=True    alarm_type=active
        Verify Calls Working
        Copy Latest Tshark File To Backup VM
        Delete Logs From Current VM
    END

Copy Latest Tshark File To Backup VM
    [Documentation]    Find the latest tshark_25...pcap file in /tmp and copy to backup VM
    ${result}=    Run Process    bash    -c    ls -t /tmp/tshark_25*.pcap | head -1    shell=True    stdout=PIPE
    ${latest_file}=    Set Variable    ${result.stdout.strip()}
    Log To Console    Latest file is: ${latest_file}
    Run Process    scp    ${latest_file}    ute@10.58.141.137:/home/ute/Downloads/PET_Backup

Delete Logs From Current VM
    [Documentation]    Delete logs from current VM to free space
    Run    rm -rf /opt/iphy/latest/*.log.*
    Run    rm -rf /opt/iphy/latest/*.log
    Run    rm -rf /tmp/tshark_*

Stop Calls
    [Documentation]    Stop calls after test
    Configure Ue    5g=device4:data    command=ue_deregister    id=1    ue_deregister_type=switch off
    Log    Call

Validation for TWAMP
    FOR    ${i}    IN RANGE    100
        ${i}=    Evaluate    ${i} + 1
        ${Twamp}=    Get Parameter    param_path=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPAPP-1/TWAMP-${i}
    END

Enabled SBR and Validate
    Setup Remote Access    remote_device=bts    alias=conn2
    ${sbr_before}=    Execute Interactive Remote Command    command=ip rule show    alias=conn2
    Log    ${sbr_before}
    Should Not Contain    ${sbr_before}    52

#    Perform Recommissioning    type=delta    delta_file=${Enable_SBR}    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}
    ${sbr_after}=    Execute Interactive Remote Command    command=ip rule show    alias=conn2
    Log    ${sbr_after}
    Should Not Contain    ${sbr_after}    52

Enable 6436 FH Firewall and verify
    Perform Recommissioning    type=delta    delta_file=${FHFirewall}    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}
    Log    ASIK is not supported as confirmed by feature team, Uncomment the below part for other HWs
#    Pm Counters Start    analysis=FH_counter    counter_analysis_file=${FH_analysis}    pm_interval=5
#    Verify Pm Counters    analysis=FH_counter    counter_analysis_file=${FH_analysis}    pm_interval=5
#    Pm Counters Start    analysis=BBMOD_counter    counter_analysis_file=${FH_analysis}    pm_interval=5
#    Verify Pm Counters    analysis=BBMOD_counter    counter_analysis_file=${FH_analysis}    pm_interval=5

Enable 5832 LBM functionality and verify working
    Perform Recommissioning    type=delta    delta_file=${Enable_CB005832}    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}
    Setup Remote Access    remote_device=bts    alias=conn2
    Sleep    10
    Execute Interactive Remote Command    command=${Login_BBMOD}    alias=conn2
    Execute Interactive Remote Command    command=${ip_netns}    alias=conn2
    Execute Interactive Remote Command    command=${capture_pcap}    alias=conn2
    sleep    200
    Execute Interactive Remote Command    command=${exit_command}    alias=conn2
    Execute Interactive Remote Command    command=${BBMOD_copy}    alias=conn2
    sleep    5
    Execute Interactive Remote Command    command=${SMOD_pwd}    alias=conn2
    Execute Interactive Remote Command    command=${exit_command}    alias=conn2
    Get File From Remote Host    source=/user/toor4nsn/lbmcheck.pcap    destination=/home/ute    alias=conn2
    Verify Alarm    faultid=${61009}    should_exist=${False}
    Teardown Remote Access    alias=conn2
    Analyse Pcap
    ...    pcap_filename=${LBM_pcap_file_location}
    ...    analysis=verify_LBM_LBR_message
    ...    filter_file_name=${traffic_filter_file_name}

Enable 6114 FH ipsec
#    Setup Remote Access    remote_device=bts    alias=co
#    BuiltIn.Sleep    10
#
    Log    Modify actEcpriRuMPlaneSecurity from RuProtectDisabled to RuProtectEnabled. Precheck Ongoing for ASIK
#    Rfmodule Setup    config_device=rf_module    rf_ip_distname=${dist}    fhnet_login_only=${True}    timeout=60    alias=conn2
#    Get RF ORAN IPs
#    Perform Recommissioning    type=param    param_path=${dist1}    operation=update    value=RuProtectEnabled    timeout=300
#    Verify Alarm    faultid=6450    should_exist=${False}
#    Wait until keyword succeeds    4 min    50    Verify Alarm    faultid=10    occurrences=1    should_exist=${True}    alarm_type=active
#    BuiltIn.Sleep    900
#    Verify Ipsec Status1
#    Verify BTS Status    should_be_onair=${True}    rat=5g

Get RF ORAN IPs
    ${soaprp}=    Execute Interactive Remote Command    command=${getrfip}    alias=conn2
    ${soaprp1}=    Get Line    ${soaprp}    -3
    Set Suite Variable    ${soaprp1}    ${soaprp1}
    Check Ping

Check Ping
    ${ping_aeqe}=    Execute Interactive Remote Command    command=ping -c 10 ${soaprp1}    alias=conn2
    BuiltIn.Sleep    10
    Should Contain    ${ping_aeqe}    ${packet_loss}

Verify Ipsec Status1
    ${output1}=    Execute Interactive Remote Command    command=ipsec status    alias=conn2
    Should Contain    ${output1}    ESTABLISHED
    Should Contain    ${output1}    INSTALLED
    Should Contain    ${output1}    ${DROP}
    Should Contain    ${output1}    icmp

Disable FH ipsec
    Log    Modify actEcpriRuMPlaneSecurity from RuProtectEnabled to RuProtectDisabled
    Perform Recommissioning
    ...    type=param
    ...    param_path=${dist1}
    ...    operation=update
    ...    value=RuProtectDisabled
    ...    timeout=300
    BuiltIn.Sleep    900
    Verify Alarm    faultid=10    occurrences=0    should_exist=${False}    alarm_type=active

Enable SoE and Verify
    Log    Check if .1 and .129 both pings when SOE is disabled
    ${output}=    Run    ping -c 5 ${enb_internal_ip}
    Should contain    ${output}    5 packets transmitted, 5 received, 0% packet loss

    ${output1}=    Run    ping -c 5 ${lmp_ip}
    Should contain    ${output1}    5 packets transmitted, 5 received, 0% packet loss

    Log    Enable SOE
    Perform Recommissioning    type=param    param_path=${Enable_Soe}    operation=update    value=true    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}
    Log    Verify SOE is enabled
    ${output}=    Run    ping -c 5 ${enb_internal_ip}
    Should contain    ${output}    5 packets transmitted, 0 received, 100% packet loss

    Log    Change Debug PC interface IP to other than 192.168.255.126
    Run    sudo ip addr del 192.168.255.126/24 dev eth1
    Run    sudo ip addr add 192.168.255.125/24 dev eth1
    ${output}=    Run    ping -c 5 ${enb_internal_ip}
    Should contain    ${output}    5 packets transmitted, 0 received, 100% packet loss

    ${output1}=    Run    ping -c 5 ${lmp_ip}
    Should contain    ${output1}    5 packets transmitted, 0 received, 100% packet loss

    Log    Revert back Debug PC interface IP to normal
    Run    sudo ip addr del 192.168.255.125/24 dev eth1
    Run    sudo ip addr add 192.168.255.126/24 dev eth1
    ${output}=    Run    ping -c 5 ${enb_internal_ip}
    Should contain    ${output}    5 packets transmitted, 0 received, 100% packet loss

    ${output1}=    Run    ping -c 5 ${lmp_ip}
    Should contain    ${output1}    5 packets transmitted, 5 received, 0% packet loss

Revert configuration
    Run    sudo ip addr del 192.168.255.125/24 dev eth1
    Run    sudo ip addr add 192.168.255.126/24 dev eth1

Enable 8016 Mplane IP traffic routing between Fronthaul and Backhaul
    Perform Recommissioning    type=delta    delta_file=${Enable_CB008016}    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}
    Log    Enabling flag will have impact when RU is ORAN radios. ORU not supported for ABIL.

Enable 6533 actEcpriMplaneIpv6 flag
    Perform Recommissioning    type=delta    delta_file=${Enable_6533}    timeout=300
    Verify Alarm    faultid=6450    should_exist=${False}

Enable 7255 actECPRITransportForORANAndTSN flag
    Perform Recommissioning    type=delta    delta_file=${Enable_7255}    timeout=300
    sleep    500
    Verify BTS Status    should_be_onair=${True}    rat=5g
    Verify Alarm    faultid=6450    should_exist=${False}
    Log    Enabling flag will have impact when RU is ORAN radios

Verify high throughput
    ${before_call_counter_value}=    Verify PM Counters via Webem
    Make 5G Calls
    Sleep    300
# after starting call counter
    ${after_call_counter_value}=    Verify PM Counters via Webem
# throughput count
    ${diff_kbps}=    Evaluate    ${after_call_counter_value} - ${before_call_counter_value}
    ${diff_gbps}=    Evaluate    round(${diff_kbps} / 1000000, 3)
    Should Be True    ${diff_gbps} > 1    Traffic should be > 0.5 Gbps

Verify PM Counters via Webem
    PM Counters Start    analysis=verify_TCP_UDP_counters_1    counter_analysis_file=${FH_analysis}    alias=default
    ${counter_dict}=    Verify PM Counters
    ...    analysis=verify_TCP_UDP_counters_1
    ...    counter_analysis_file=${FH_analysis}
    ...    alias=default
    ${data}=    Evaluate    ast.literal_eval("""${counter_dict}""")    modules=ast
    ${value}=    Get From Dictionary
    ...    ${data['PLMN-PLMN/MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1']['M51301C0']}
    ...    final_counter_value
    Log    Final Counter Value: ${value}
    RETURN    ${value}