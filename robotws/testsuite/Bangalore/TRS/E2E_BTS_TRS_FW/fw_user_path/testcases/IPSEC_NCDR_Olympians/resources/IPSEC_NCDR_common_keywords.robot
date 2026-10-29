*** Settings ***
Documentation
...     [Procedure]     "Verify IPSEC NCDR"
...     [Author]        "Shankar Manurwar"
...     [Maintenance]   "TRS_VRF"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Function_Hash_Tags]    "IPSEC"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASIM HR"

***Keywords***

Preconditions

    Run   sh routes.sh

IPSEC and Strongswan Configuration

    Certificate Configure    operation=install_certificate    cert_file=${valid_ipsec_cert}     cert_type=BtsTrustChain
    ...     cert_format=P12     password=${valid_ipsec_cert_password}
    sleep     60
#    ----------- 04572591 implementation -----
#    Verify Ipsec Tunnels Status
#    Certificate Configure       operation=install_cmp_certificate       key_pool_type=RSA       timeout=300
#    sleep     30
#    Verify Ipsec Tunnels Status
#    Perform Recommissioning     type=delta    delta_file=${Disable_Ipsec}    timeout=600
#    sleep    15
#    Perform Recommissioning     type=delta    delta_file=${Enable_Ipsec}    timeout=600
#    sleep    400
#    Verify Ipsec Tunnels Status
#    Certificate Configure       operation=cmp_update_key       key_pool_type=RSA       timeout=300
#    sleep	 10
#    Run    sudo ipsec restart
#    sleep    500
#    Verify Ipsec Tunnels Status
#-------------------------04572591 END ---------------

Loop for Ipsec Enable Disable

    FOR    ${iter}    IN RANGE    0     ${iteration1}
        IPSEC Enable Disable
    END

IPSEC Enable Disable

    Perform Recommissioning     type=param  param_path=${IPSEC_END}    operation=update    value=true     timeout=300
    sleep    300
    ${AMF1_status}=      Get Parameter      param_path=MRBTS-1/NRBTS-1/SERVEDAMF-1:guAMI:guamiStatus
    Should Be Equal     ${AMF1_status}     available
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status
    Verify Alarm            faultid=6450    should_exist=${False}    occurrences=1   alarm_type=active
    sleep   5

    sleep    60

    Perform Recommissioning     type=param  param_path=${IPSEC_END}    operation=update    value=false     timeout=300
    sleep   250
    Verify BTS status   should_be_onair=${False}
    sleep    10
    Verify Alarm            faultid=6450    should_exist=${False}    occurrences=1   alarm_type=active
    sleep   5


M Plane test
    Ping Test

Ping Test
    ${output}=        Run     ping -c 50 10.0.1.2
    Should contain     ${output}        0% packet loss

Load SCFC according to Build Release

    25R1 SCFC
    25R2 SCFC
    24R3 SCFC
    24R2 SCFC


25R1 SCFC

    Perform Commissioning       scf_file=${25R1_SCFC}        verify_bts_status=False         timeout=600
    ...     alias=default

25R2 SCFC

    Perform Commissioning       scf_file=${25R2_SCFC}        verify_bts_status=False         timeout=600
    ...     alias=default

24R3 SCFC

    Perform Commissioning       scf_file=${24R3_SCFC}        verify_bts_status=False         timeout=600
    ...     alias=default

24R2 SCFC

    Perform Commissioning       scf_file=${24R2_SCFC}        verify_bts_status=False         timeout=600
    ...     alias=default



SW Download and Upgrade to Target Build

    Perform software download and update     wft_profile=sbtstrunk_00     package=auto
    ...     activate_sw=true    update_timeout=4500    alias=upgrade_mplane
    sleep   600
    Send Pre fragmented traffic and Verify traffic      ${traffic_2}

Initial checks on Baseline build

    Preconditions
    IPSEC and Strongswan Configuration
    Verify Ipsec Tunnels Status
    Bring up OnAir and verify AMF and BTS status
    Send Pre fragmented traffic and Verify traffic      ${traffic_1}


PM Counter Verification

    ETHIF Counter Verification
    ETHLK Counter Verification

SECPOL Modification scenarios

    SECPOL paramter Update
    SECPOL paramter Delete
    SECPOL paramter Addition
    SECPOL Multiple MOC Delete
    SECPOL Multiple MOC Addition

SECPOL paramter Update

    Perform Recommissioning     type=delta      delta_file=${Delta_SECPOL_MOC_update}     timeout=300
    sleep     60

    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

SECPOL paramter Delete

    Perform Recommissioning     type=delta      delta_file=${Delta_SECPOL_Parameter_delete}     timeout=300
    sleep     60

    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

SECPOL paramter Addition

    Perform Recommissioning     type=delta      delta_file=${Delta_SECPOL_MOC_Addition}     timeout=300
    sleep     60

    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status


SECPOL Multiple MOC Delete

    Perform Recommissioning     type=delta      delta_file=${Delta_Multiple_SECPOL_MOC_delete}     timeout=300
    sleep     60

    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

SECPOL Multiple MOC Addition

    Perform Recommissioning     type=delta      delta_file=${Delta_Multiple_SECPOL_MOC_Addition}     timeout=300
    sleep     60

    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

Verify Ipsec Tunnels Status

    [Arguments]    ${dut}=default
    @{parent_tunnel_moc_list} =    Query Admin Infomodel	query=get list ${ike_sa_l_moc_path}	alias=${dut}
    FOR    ${ike_tunnel}	IN      @{parent_tunnel_moc_list}
        ${parent_tunnel_stateInfo}=     Get From Dictionary	dictionary=${ike_tunnel}	key=stateInfo
        ${parent_tunnel_proceduralState}=    Get From Dictionary	dictionary=${parent_tunnel_stateInfo}
     ...    key=proceduralState
        Should Be True	'${parent_tunnel_proceduralState}'=='Established'
    END

    @{child_tunnel_moc_list} =      Query Admin Infomodel	query=get list ${ipsec_sa_l_moc_path}	alias=${dut}
    FOR    ${child_tunnel}    IN       @{child_tunnel_moc_list}
        ${child_tunnel_stateInfo}=      Get From Dictionary	dictionary=${child_tunnel}	key=stateInfo
        ${child_tunnel_proceduralState}=        Get From Dictionary	dictionary=${child_tunnel_stateInfo}
     ...    key=proceduralState
        Should Be True	'${child_tunnel_proceduralState}'=='Installed'
    END


Bring up OnAir and verify AMF and BTS status


    Call Setup     5g=Device_AP:data    parallel=${False}    attach=${False}      verify_attach=${false}    timeout=120
    Sleep   10
    Configure UE       5g=Device_AP:data     command=ue_register    id=1
    Sleep   5
    Configure UE       5g=Device_AP:data     command=set_pdu_param   ue=1     pdu=1    trf_type=internal
    Sleep   5
    Configure UE       5g=Device_AP:data     command=ue_pdu_session_setup     pdu=1    gw=1    ue=1
    Sleep   5
    Verify BTS status   should_be_onair=${True}
    Sleep     10

    ${AMF1_status}=      Get Parameter      param_path=MRBTS-1/NRBTS-1/SERVEDAMF-1:guAMI:guamiStatus
    Should Be Equal     ${AMF1_status}     available



Send Pre fragmented traffic and Verify traffic

    Perform Recommissioning     type=param  param_path=${Set_pre_fragmentation}    operation=update
    ...     value=Pre-fragmentation     timeout=300
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

#    Configure UE       5g=Device_AP:data     command=ue_register    id=1
#    Sleep   5
#    Configure UE       5g=Device_AP:data     command=set_pdu_param   ue=1     pdu=1    trf_type=internal
#    Sleep   5
#    Configure UE       5g=Device_AP:data     command=ue_pdu_session_setup     pdu=1    gw=1    ue=1
#    Sleep   5
    Configure UE       5g=Device_AP:data     command=trf_data_start   ue=1    pdu=1    qfi=1   dir=ul     trf_id=1
    ...     mbps=175    size=2000
    Sleep   5
    Configure UE       5g=Device_AP:data     command=trf_data_start   ue=1     pdu=1    qfi=1    dir=dl      trf_id=1
    ...     mbps=175   size=3000
    Sleep   420

    Point A Traffic capture and verify      ${traffic_1}
    Point B Traffic capture and verify for ESP Packets    ${traffic_2}

Stop Traffic

    Configure UE       5g=Device_AP:data    command=trf_data_stop   ue=1


Modify ARW and Re keying and check Tunnel status


    Perform Recommissioning     type=param  param_path=${ARW_modify}    operation=update    value=true     timeout=300
    sleep    90
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

    Perform Recommissioning     type=param  param_path=${ARW_modify}    operation=update    value=false     timeout=300
    sleep    90
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

    Perform Recommissioning     type=param  param_path=${sa_rekey_modify}    operation=update    value=36000
    ...     timeout=300
    sleep   90
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

    Perform Recommissioning     type=param  param_path=${sa_rekey_modify}    operation=update    value=60000
    ...     timeout=300
    sleep   90
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status


Loop for delta and snapshot collection

   FOR    ${iter}    IN RANGE    0     ${iteration}
        Delta Modification
        Snapshot collection
    END

Delta Modification


    Perform Recommissioning     type=delta      delta_file=${Delta_IPSEC_MOC}     timeout=300
    sleep     90
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status


Snapshot collection

    Collect Snapshot		timeout=2000

ETHIF Counter Verification

    Pm Counters Start     analysis=verify_tagged_untagged_counters
    ...     counter_analysis_file=${counter_analysis_file_name}
    sleep       30

    Set Suite Variable      ${Class1}               90..100
    Set Suite Variable      ${Class2}               0..10
    Set Suite Variable      ${Class3}               0..10
    Set Suite Variable      ${Class4}               0..10
    Set Suite Variable      ${Class5}               0..10
    Set Suite Variable      ${Value_out}               170000..210000
    Set Suite Variable      ${Value_in}            170000..220000

    Verify Pm Counters      analysis=verify_tagged_untagged_counters
    ...     counter_analysis_file=${counter_analysis_file_name}


ETHLK Counter Verification

    Pm Counters Start     analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}
    sleep       30

    Set Suite Variable      ${Class1}               0..10
    Set Suite Variable      ${Class2}               90..100
    Set Suite Variable      ${Class3}               0..10
    Set Suite Variable      ${Class4}               0..10
    Set Suite Variable      ${Class5}               0..10
    Set Suite Variable      ${Value_out}               170000..210000
    Set Suite Variable      ${Value_in}            170000..220000

    Verify Pm Counters      analysis=verify_Ethlk_counters       counter_analysis_file=${counter_analysis_file_name}


Verify Post fragmentation alarm

    Perform Recommissioning     type=param  param_path=${DL_Fragmentation}    operation=update    value=false
    ...     timeout=300
    sleep   260
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status
    Verify Alarm           faultid=61666    should_exist=${True}     occurrences=1    alarm_type=active
    sleep   20
    Perform Recommissioning     type=param  param_path=${DL_Fragmentation}    operation=update    value=true
    ...     timeout=300
    sleep   260
    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status
    Verify Alarm           faultid=61666    should_exist=${False}     occurrences=1    alarm_type=active
    sleep    30


Jumbo frame verification

    Run     sudo ip link set eth3 mtu 9000
    Run     sudo ip link set eth3.621 mtu 9000


    Configure UE       5g=Device_AP:data     command=trf_data_start   ue=1    pdu=1    qfi=1   dir=ul     trf_id=1
    ...     mbps=175    size=9000
    Sleep   5
    Configure UE       5g=Device_AP:data     command=trf_data_start   ue=1     pdu=1    qfi=1    dir=dl      trf_id=1
    ...     mbps=175   size=9000

    sleep       180

    Verify BTS status   should_be_onair=${True}
    Verify Ipsec Tunnels Status

    Point A Traffic capture and verify      ${traffic_3}
    Point B Traffic capture and verify for ESP Packets      ${traffic_4}

    Run     sudo ip link set eth3 mtu 1500
    Run     sudo ip link set eth3.621 mtu 1500


Point A Traffic capture and verify

    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated
    ...     uplane_capturing=True   timeout=120     alias=${pcap_1}
    sleep  360

    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}
    ...     analysis=UL_Traffic_check1
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}
    ...     analysis=DL_Traffic_check1


Point B Traffic capture and verify for ESP Packets

    [Arguments]     ${pcap_1}
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=Transport_Interface
    ...     uplane_capturing=True   timeout=120     alias=${pcap_1}

    sleep   360

    ${filename_A}=  Traffic Capture Stop   mode=file      alias=${pcap_1}      timeout=100

    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}    analysis=ESP
    Analyse Pcap    pcap_filename=${filename_A}     filter_file_name=${traffic_filter_file_name}     analysis=ESP
