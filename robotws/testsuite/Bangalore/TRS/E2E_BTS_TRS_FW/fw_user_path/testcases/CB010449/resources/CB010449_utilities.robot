*** Settings ***
Documentation
...		[Author]     	"P Dineshkumar"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

Library        taf.sw.scout    WITH NAME   scout
variables	ta_e2e_bts_trs_fw

*** Keywords ***
Perform IP Configuration on VM
    [Documentation]   Configures IP Addresses on VM required for Call Setup
    Run        sudo ip a a 10.0.1.131/24 dev eth3
    Run        sudo ip a a 10.0.1.133/24 dev eth3
	Run        sudo ip a a 10.0.1.134/24 dev eth3
	Run        sudo ip a a 10.0.1.135/24 dev eth3
	Run        sudo ip a a 10.0.1.136/24 dev eth3
	Run        sudo ip a a 10.0.1.121/24 dev eth3

Get System Module HW Variant
    [Documentation]   Query and save the SM HW variant in variable productName, which is subesquenty used by other keywords.
    ${runtime_system_module_info_dict} =     Query Admin Infomodel    query=get object //CABINET_R-*/SMOD_R-*
    Log    ${runtime_system_module_info_dict}
    Set Suite Variable      ${runtime_system_module_info_dict}
    ${productName} =      Get From Dictionary    ${runtime_system_module_info_dict}    productName
    Set Suite Variable      ${productName}

Configure and Verify NR FDD + LTE FDD split
    Perform Cell Configuration on AP iphy   g1
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=eth3_pcap_g1     timeout=120
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${G1_scf}   verify_bts_status=False     timeout=400     alias=default
    ...     skip_parameter_relation_errors=${True}
    BuiltIn.Sleep  400
    Call Setup  nr=CB010449_ABIQ_G1:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=300
    BuiltIn.Sleep   60
    Verify Bts Status   should_be_onair=${True}
    Verify Failure alarms
    Attach Call     G1
    BuiltIn.Sleep  10
    Detach Call     G1
    ${Msg_pcap}=   Traffic Capture Stop     alias=eth3_pcap_g1     timeout=120
    Analyse Pcap    pcap_filename=${Msg_pcap}   analysis=nr_registration_complete
    Analyse Pcap    pcap_filename=${Msg_pcap}   analysis=udp_packets
    Verify cell status by changing BW

Configure and Verify NR FDD + NR TDD split
    Perform Cell Configuration on AP iphy    g2
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=eth3_pcap_g2     timeout=120
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${G2_scf}   verify_bts_status=False     timeout=400     alias=default
    ...     skip_parameter_relation_errors=${True}
    BuiltIn.Sleep  400
    Call Setup  nr=CB010449_ABIQ_G2:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=300
   BuiltIn.Sleep   60
    Verify Bts Status   should_be_onair=${True}
    Verify Failure alarms
    Attach Call     G2
    BuiltIn.Sleep  10
    Detach Call     G2
    ${Msg_pcap}=   Traffic Capture Stop     alias=eth3_pcap_g2     timeout=120
    Analyse Pcap    pcap_filename=${Msg_pcap}   analysis=nr_registration_complete
    Analyse Pcap    pcap_filename=${Msg_pcap}   analysis=udp_packets

Configure and Verify LTE FDD + NR TDD split
    Perform Cell Configuration on AP iphy   g3
    Traffic Capture Start   capture_device=vm_eth3_interface    alias=eth3_pcap_g3     timeout=120
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${G3_scf}   verify_bts_status=False     timeout=400     alias=default
    ...     skip_parameter_relation_errors=${True}
    BuiltIn.Sleep  400
    Call Setup  nr=CB010449_ABIQ_G3:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=300
    BuiltIn.Sleep   60
    Verify Bts Status   should_be_onair=${True}
    Verify Failure alarms
    Attach Call     G3
    BuiltIn.Sleep  10
    Detach Call     G3
    ${Msg_pcap}=   Traffic Capture Stop     alias=eth3_pcap_g3     timeout=120
    Analyse Pcap    pcap_filename=${Msg_pcap}   analysis=nr_registration_complete
    Analyse Pcap    pcap_filename=${Msg_pcap}   analysis=udp_packets

Attach Call
    [Arguments]      ${split}
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=ue_register        id=1
    BuiltIn.Sleep   3
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=set_pdu_param        ue=1        pdu=1        trf_type=internal
    BuiltIn.Sleep   3
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=ue_pdu_session_setup        pdu=1        gw=1         ue=1    nwslice=1
    BuiltIn.Sleep   3
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=trf_data_start         ue=1         pdu=1        qfi=1        dir=dl        mbps=20
    BuiltIn.Sleep   3
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=trf_data_start        ue=1        pdu=1        qfi=1         dir=ul        mbps=20
    BuiltIn.Sleep   3

Detach Call
    [Arguments]      ${split}
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=trf_data_stop        ue=1        dir=dl
    BuiltIn.Sleep   3
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=trf_data_stop        ue=1        dir=ul
    BuiltIn.Sleep   3
    Configure UE    nr=CB010449_ABIQ_${split}:data        command=ue_deregister        id=1        ue_deregister_type=switch_off

Verify Failure alarms
    Verify Alarm    faultid=${NG_SCTP_setup_fail}   should_exist=${false}
	Verify Alarm    faultid=${gNB_CpRtCell_configuration_update_failure_alarm}   should_exist=${false}
	Verify Alarm    faultid=${Transport_layer_connection_failure_in_S1_interface}   should_exist=${false}

Perform Cell Configuration on AP iphy
    [Arguments]      ${conf}
	Setup Remote Access    remote_device=AP
    ${output}=     Remote Command Execute      command=ls -lrth /ffs/run/simmode
    ${output}=     Remote Command Execute      command=ln -fs /ffs/run/simmode/iphy_${conf}.xml /ffs/run/simmode/iphy.xml
    ${output}=     Remote Command Execute      command=ls -lrth /ffs/run/simmode
    Teardown remote Access

SFTP iphy files to AP
    ${status}	${output}=	Run Keyword And Ignore Error	Login to remote machine  sftp  192.168.200.129 toor4nsn oZPS0POrRieRtu  Password
    Run Keyword If	'${status}' == 'FAIL'	Login to remote machine  sftp  ${FSP1_IP}  ${FSP1_USER}  ${FSP1_PWD}  yes

Command to execute on board
        [Arguments]      ${command}
        Remote Command Execute      command=${command}

Keywords To Run At End
  teardown Emssim
    Run     cd /opt/iphy/latest/ ; sudo killall egate edaemon

Upgrade SW build
    Perform Software Download And Update    package=${Build}      activate_sw=True  update_timeout=1800
    Sleep   600
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${G1_scf}   verify_bts_status=False     timeout=400     alias=default
    ...     skip_parameter_relation_errors=${True}
    Sleep   240

Verify cell status by changing BW
	Perform Recommissioning    type=delta      delta_file=${delta_channel_BW_10Mhz}      skip_parameter_relation_errors=False   timeout=400
    Sleep   30
    Verify Bts Status   should_be_onair=${True}
    Perform Recommissioning    type=delta      delta_file=${delta_channel_BW_15Mhz}      skip_parameter_relation_errors=False   timeout=400
    Sleep   30
    Verify Bts Status   should_be_onair=${True}