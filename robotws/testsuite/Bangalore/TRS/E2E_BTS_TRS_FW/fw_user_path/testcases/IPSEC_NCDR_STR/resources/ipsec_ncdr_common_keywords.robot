*** Settings ***
Documentation
...     [Date]                      "22-03-2024"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Procedure]                 "Ipsec Max Tunnels long run profile"
...     [Function_Hash_Tags]        "Ipsec"



Variables       ta_e2e_bts_trs_fw
Library		   ${CURDIR}/../../resources/egate_library.py
Resource        ${CURDIR}/../../resources/common_keywords.robot


*** Keywords ***
Perform Software Upgrade
   [Documentation]       This test case keyword is to upgrade SW build
   Fetch the uptime
   Perform Software Download And Update       package=${profile}      activate_sw=true      update_timeout=3000



Configure 8128 configuration and verify no IPsec failure alarms are present
	[Documentation]   On existing IPSEC configuration add DNS and FQDN configuration should be up to test 8128 configuration.
	Perform Recommissioning     type=delta        delta_file=8128_ipv6_tunnels_with_ikep_fqdn.xml
    ...        skip_parameter_relation_errors=${True}      timeout=300
	Verify Alarm        expected_alarms=${expected_alarms}       check_unexpected_alarms=True



Verify CB009246 feature and check for alarms
	[Documentation]   on existing IPSEC configuration and add 9246 configuration.
	Perform Recommissioning     type=delta        delta_file=${9246_configuration_false}
    Run     ping ${local_IP_1} -I ${remote_IP_1} -s 4000 -c 10
	Run     ping ${local_IP_1} -I ${remote_IP_1} -s 4000 -c 10
	Run     ping ${local_IP_1} -I ${remote_IP_1} -s 4000 -c 10
	Run     ping ${local_IP_1} -I ${remote_IP_1} -s 4000 -c 10
    Verify Alarm        faultid=61666     should_exist=${True}  occurrences=1
	Perform Recommissioning     type=delta        delta_file=${9246_configuration_true}
	Sleep   60
	Verify Alarm	faultid=61666	should_exist=${False}


Attach UE and send ul dl traffic
   [Documentation]       This test case keyword is to verify bts status to trigger calls
   ${bts_status}     Run Keyword And Return Status       Verify Bts Status      should_be_onair=${True}    req_rat=nr
   Log      ${bts_status}
   Run Keyword If       ${bts_status}      Trigger OnAir Calls
   ...    ELSE     Make setup on OnAir



Perform three operation loop after every 5 mins
   [Documentation]       This test case keyword is to execute three operations
   FOR    ${iter}    IN RANGE    0     ${iter}
     Delta Modification
     Counter analysis
     Sleep     100
     Wait Until Keyword Succeeds    15 min    30  Check for alarms
     Wait Until Keyword Succeeds    15 min    30 	Get Ipsec Tunnels Status
     Run Script on Egate    /home/ute/abhi/Throughput_Commands.lua
     Fetch the uptime
     Convert To Integer    ${count}
     ${count}=  Evaluate    int(${count}) + int(1)
     Log       Value: ${count}
     ${result}=  Evaluate    int(${count}) % int(6)
     Run Keyword If     ${result} == 0    Verify the counters
   END

Fetch the uptime
    [Documentation]       This test case keyword is to capture the uptime
    Setup Remote Access     remote_device=bts     timeout=30     alias=default
    ${uptime_value}=     Remote Command Execute       command=uptime
    Set Suite Variable     ${uptime_value}
    Teardown Remote Access     alias=default
    Log    ${uptime_value}

Delta Modification
    [Documentation]        This test case keyword is to perform delta commissioning
    Perform Recommissioning     type=delta     delta_file=${ipsecc_modification}         timeout=1600
    Sleep    60
    Perform Recommissioning     type=delta     delta_file=${ipsecp_secpol_modification}       timeout=1600
    Sleep    60
    Perform Recommissioning     type=delta     delta_file=${ikep_modification}       timeout=1600
    Sleep    60
    Perform Recommissioning    type=delta      delta_file=${create_file}     skip_parameter_relation_errors=${True}     timeout=300
    Sleep     60
    Perform Recommissioning    type=delta      delta_file=${delete_file}     skip_parameter_relation_errors=${True}     timeout=300
    Sleep     60



Counter analysis
   [Documentation]        This test case keyword is to start the counter
   ETHLK Counter Verification
   VLAN Counter Verification


ETHLK Counter Verification
   [Documentation]        This test case keyword is to start the counter
    Pm Counters Start     analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file}
    sleep       30

    Set Suite Variable      ${Class1}               0..10
    Set Suite Variable      ${Class2}               90..100
    Set Suite Variable      ${Class3}               0..10
    Set Suite Variable      ${Class4}               0..10
    Set Suite Variable      ${Class5}               0..10
    Set Suite Variable      ${Value_out}            400000..500000
    Set Suite Variable      ${Value_in}            200000..250000

    Verify Pm Counters      analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file}

VLAN Counter Verification
   PM Counters Start       analysis=verify_counters      counter_analysis_file=${counter_analysis_file}
   Sleep  10
   Verify Pm Counters      analysis=verify_counters       counter_analysis_file=${counter_analysis_file}

Run Script on Egate
	[Arguments]			${Call_scenario}
	Connect And Execute Egate	${telnet_port}  	${Call_scenario}
	Sleep   10

Check for alarms
   [Documentation]        This test case keyword is to verify alarms
    Sleep   10
   	Verify Alarm        expected_alarms=${expected_alarms}       check_unexpected_alarms=True


Verify the counters
   [Documentation]        This test case keyword is to verify counter and ue stats
   Verify PM Counters      analysis=verify_counters      counter_analysis_file=${counter_analysis_file}
   Fetch the uptime

Get Ipsec Tunnels Status
	[Documentation]		This test case keyword is to verify IPSec tunnels status for 6 operators x2c list
	@{parent_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ike_sa_l_moc_path}
	FOR 	${ike_tunnel}	IN 	@{parent_tunnel_moc_list}
		${parent_tunnel_stateInfo}=	Get From Dictionary		dictionary=${ike_tunnel}		key=stateInfo
		${parent_tunnel_proceduralState}=	Get From Dictionary		dictionary=${parent_tunnel_stateInfo}		key=proceduralState
		Should Be True	'${parent_tunnel_proceduralState}'=='Established'
	END

	@{child_tunnel_moc_list} = 	Query Admin Infomodel		query=get list ${ipsec_sa_l_moc_path}
	FOR 	${child_tunnel}	IN 	@{child_tunnel_moc_list}
		${child_tunnel_stateInfo}=	Get From Dictionary		dictionary=${child_tunnel}		key=stateInfo
		${child_tunnel_proceduralState}=	Get From Dictionary		dictionary=${child_tunnel_stateInfo}		key=proceduralState
		Should Be True	'${child_tunnel_proceduralState}'=='Installed'
	END


Make setup on OnAir
   [Documentation]        This test case keyword is to make the setup on On-Air and trigger the calls
   Call Setup    5g=device_SA:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=600
   Verify Bts Status       should_be_onair=${True}      req_rat=nr
   Trigger OnAir Calls


Trigger OnAir Calls
   [Documentation]        This test case keyword is to trigger the calls
   Configure UE    5g=device_SA:data        command=ue_register        id=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_pdu_session_setup       ue=1          pdu=1        gw=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_register        id=2
   Sleep     3
   Configure UE    5g=device_SA:data        command=set_pdu_param        ue=2        pdu=1        trf_type=internal
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_pdu_session_setup       ue=2          pdu=1        gw=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_register        id=3
   Sleep     3
   Configure UE    5g=device_SA:data        command=set_pdu_param        ue=3        pdu=1        trf_type=internal
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_pdu_session_setup       ue=3          pdu=1        gw=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start
   ...       ue=1      pdu=1        qfi=1        dir=dl     trf_id=1     mbps=100     protocol=tcp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data
   ...      command=trf_data_start       ue=1      pdu=1        qfi=1        dir=ul   trf_id=2      mbps=100     protocol=tcp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start
   ...    ue=2      pdu=1        qfi=1        dir=dl    trf_id=3     mbps=175     protocol=udp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data
   ...      command=trf_data_start       ue=2      pdu=1        qfi=1        dir=ul  trf_id=4       mbps=100     protocol=udp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start
   ...         ue=3      pdu=1        qfi=1        dir=dl    trf_id=5     mbps=175     protocol=udp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data        command=bearer_stats         ue=1      pdu=1        qfi=1        dir=dl | grep -i "Average data rate"
   Sleep     3
   Configure UE    5g=device_SA:data        command=bearer_stats         ue=1      pdu=1        qfi=1        dir=ul | grep -i "Average data rate"
   Sleep     3
   Configure UE    5g=device_SA:data        command=bearer_stats         ue=1      pdu=1        qfi=1        dir=dl | grep -i "Average data rate"
   Sleep     3
   Configure UE    5g=device_SA:data        command=bearer_stats         ue=1      pdu=1        qfi=1        dir=ul | grep -i "Average data rate"
   Sleep     3
   Configure UE    5g=device_SA:data        command=bearer_stats         ue=1      pdu=1        qfi=1        dir=dl | grep -i "Average data rate"
   Sleep     3
   Configure UE    5g=device_SA:data        command=bearer_stats         ue=1      pdu=1        qfi=1        dir=ul | grep -i "Average data rate"
   Sleep     3

Stop traffic and detach UE
   [Documentation]        This test case keyword is to stop the Calls
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=1        dir=dl
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=1        dir=ul
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=2        dir=dl
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=2        dir=ul
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_deregister        id=2        ue_deregister_type=switch_off
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=3        dir=dl
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=3        dir=ul
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_deregister        id=3        ue_deregister_type=switch_off
   Sleep     3

RDI_23955 coverage gap to check ESN 64 bit
   [Documentation]   Configuration coverage gap to check ESN 64 bit as regression execution_ASIL
   Attach and start calls with ESA 32 bit
   Get Ipsec Tunnels Status
   Perform Recommissioning     type=delta        delta_file=ESN_64_bit.xml
   ...        skip_parameter_relation_errors=${True}      timeout=300
   Get Ipsec Tunnels Status
   Dettach and Attach calls after changing ESN 64 bit
   Get Ipsec Tunnels Status
   Stop traffic and detach UE

Attach and start calls with ESA 32 bit
   Configure UE    5g=device_SA:data        command=ue_register        id=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_pdu_session_setup       ue=1          pdu=1        gw=1
   Configure UE    5g=device_SA:data        command=trf_data_start
   ...       ue=1      pdu=1        qfi=1        dir=dl     trf_id=1     mbps=100     protocol=tcp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data
   ...      command=trf_data_start       ue=1      pdu=1        qfi=1        dir=ul   trf_id=2      mbps=100     protocol=tcp     size=5000
   Sleep     3

Dettach and Attach calls after changing ESN 64 bit
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=1        dir=dl
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_stop        ue=1        dir=ul
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
   Sleep     120
   Configure UE    5g=device_SA:data        command=ue_register        id=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_pdu_session_setup       ue=1          pdu=1        gw=1
   Configure UE    5g=device_SA:data        command=trf_data_start
   ...       ue=1      pdu=1        qfi=1        dir=dl     trf_id=1     mbps=100     protocol=tcp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data
   ...      command=trf_data_start       ue=1      pdu=1        qfi=1        dir=ul   trf_id=2      mbps=100     protocol=tcp     size=5000
   Sleep     3

Configure IPsec and verify status
    Delete All Certificates
    Install RAN sharing ipsec certs
    Wait Until Keyword Succeeds    10 min    30     Get Ipsec Tunnels Status
    Certificate Configure       operation=install_cmp_certificate       key_pool_type=RSA       timeout=300
    Certificate Configure       operation=cmp_update_key       key_pool_type=RSA       timeout=300
    IPSec restart
    Get Ipsec Tunnels Status

Delete All Certificates
    certificate configure    operation=restore_vendor_certificate
    Sleep       10
    Run Keyword And Ignore Error        certificate configure    operation=delete_cert  all_certs=${True}

Install RAN sharing ipsec certs
    [Documentation]     This test case keyword is to install ipsec operator certificate
    Certificate Configure    operation=install_certificate    cert_file=/home/ute/abhi/lte_3065_ded_man_enbca3.p12  cert_type=BtsTrustChain
    ...     cert_format=P12     password=nokia
    IPSec restart

IPSec restart
    Perform Recommissioning         type=param      param_path=${ipSecEnabled}      value=false     operation=update     timeout=1600
    sleep   120
    Perform Recommissioning         type=param      param_path=${ipSecEnabled}      value=true      operation=update    timeout=1600
    sleep   240

Toggle IPSec and check tunnel status
    FOR    ${IPSec_toggle}    IN RANGE    0     ${IPSec_toggle}
         Perform Recommissioning     type=param  param_path=IPSECC-1:ipSecEnabled    value=${False}       operation=update
         Sleep  100
         Perform Recommissioning     type=param  param_path=IPSECC-1:ipSecEnabled    value=${True}       operation=update
        Sleep   100
        Get Ipsec Tunnels Status
    END


Verify ARW functionality
	Perform Recommissioning 	type=param 	param_path=IPSECP-1:antiReplayEnabled	value=${False}		 operation=update        timeout=120
    Get Ipsec Tunnels Status
	Perform Recommissioning 	type=param 	param_path=IPSECP-1:antiReplayEnabled	value=${True}		 operation=update        timeout=120
    Get Ipsec Tunnels Status
	Perform Recommissioning     type=delta        delta_file=update_10.xml
    ...        skip_parameter_relation_errors=${True}      timeout=300


Check the ipsec tunnels after ike and sa rekey
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=ike_rekey_pcap
    Sleep    600
    ${ike_rekey_pcap}=       Traffic Capture Stop        alias=ike_rekey_pcap
    Analyse pcap            pcap_filename=${ike_rekey_pcap}      analysis=ike_rekey_cplane      filter_file_name=${ipsec_reauthentication_filter_file}
    Analyse pcap            pcap_filename=${ike_rekey_pcap}      analysis=ike_rekey_uplane      filter_file_name=${ipsec_reauthentication_filter_file}
    Get Ipsec Tunnels Status


jumbo OnAir Calls
   [Documentation]        This test case keyword is to trigger the calls
   Configure UE    5g=device_SA:data        command=ue_register        id=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
   Sleep     3
   Configure UE    5g=device_SA:data        command=ue_pdu_session_setup       ue=1          pdu=1        gw=1
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start       ue=1      pdu=1        qfi=1
   ...        dir=dl    trf_id=3     mbps=175     protocol=udp     size=9000
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start       ue=1      pdu=1        qfi=1
   ...        dir=ul  trf_id=4       mbps=100     protocol=udp     size=9000
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start       ue=1      pdu=1        qfi=1
   ...        dir=dl     trf_id=1     mbps=175     protocol=tcp     size=5000
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start       ue=1      pdu=1        qfi=1
   ...        dir=ul   trf_id=2      mbps=30     protocol=tcp     size=5000
   Sleep     3


Jumbo frame verification

   Run     sudo ip link set eth3 mtu 9000
   Run     sudo ip link set eth3.870 mtu 9000
   Configure UE    5g=device_SA:data        command=trf_data_start       ue=1      pdu=1        qfi=1
   ...        dir=dl     trf_id=1     mbps=100       size=9000
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start       ue=1      pdu=1        qfi=1
   ...        dir=ul   trf_id=2      mbps=30       size=9000
   Sleep     3
   Configure UE    5g=device_SA:data        command=trf_data_start       ue=1      pdu=1        qfi=1
   ...        dir=dl     trf_id=2     mbps=100       size=9000
   sleep       10
   Point A Traffic capture and verify      ${traffic_5}
   Point B Traffic capture and verify for ESP Packets      ${traffic_6}
   Run     sudo ip link set eth3 mtu 1500
   Run     sudo ip link set eth3.870 mtu 1500



Point A Traffic capture and verify
    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated   uplane_capturing=True
    ...   timeout=120     alias=${pcap_1}
    sleep   320
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${ipsec_reauthentication_filter_file}    analysis=UL_Traffic_check1


Point B Traffic capture and verify for ESP Packets
    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=Transport_Interface   uplane_capturing=True
    ...    timeout=120     alias=${pcap_1}
    sleep   60
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${ipsec_reauthentication_filter_file}    analysis=ESP


M Plane test
    Ping Test

Ping Test
    ${output}=        Run     ping -c 10 10.0.1.2
    Should contain     ${output}        0% packet loss


Send Pre fragmented traffic and Verify traffic
    Perform Recommissioning     type=param  param_path=${Set_pre_fragmentation}    operation=update    value=Pre-fragmentation     timeout=300
    Point A Traffic capture and verify      ${traffic_3}
    Point B Traffic capture and verify for ESP Packets      ${traffic_4}

Verify Post fragmented traffic
    Perform Recommissioning     type=param  param_path=${Set_pre_fragmentation}    operation=update    value=Post-fragmentation     timeout=300
    Point A Traffic capture and verify Post fragmentation    ${traffic_1}
    Point B Traffic capture and verify for ESP Packets    ${traffic_2}

Point A Traffic capture and verify Post fragmentation
    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=vm_eth3_interface   mode=file   measurement_point=NE_Terminated
    ...    uplane_capturing=True   timeout=120     alias=${pcap_1}
    sleep   400
    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${ipsec_reauthentication_filter_file}    analysis=PreFragmented_Traffic_check