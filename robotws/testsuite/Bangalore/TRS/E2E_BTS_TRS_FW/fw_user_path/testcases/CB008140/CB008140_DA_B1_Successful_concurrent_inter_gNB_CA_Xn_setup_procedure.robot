*** Settings ***
Documentation
...     [Procedure]     "Verify SA call with actintergnbCa enabled"
...     [Author]        "Nandini P"
...     [Maintenance]   "TRS_VRF"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Function_Hash_Tags]    "CA"
...     [Validation_status]     "Validated"
...     [Validated_TestLine]    "ASIB+ASIB(gNB CA setup)"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Setup Oamops
Suite Teardown    Teardown Oamops

#Suite Setup       Pre-conditions for testsuite
#Suite Teardown    Post-conditions for testteardown


***Test Cases***
[1]CB008140_DA_B1_Successful_concurrent_inter_gNB_CA_Xn_setup_procedure
    Pre-condition
    Perform Commissioning       scf_file=/home/ute/Downloads/Base_SCF/rat_5g_basic_gnb1.xml       verify_bts_status=False       timeout=600
    Sleep   300
    Setup Oamops     bts_host=${gNB2_Mplane_Ip}     alias=gNB2
    Perform Commissioning       scf_file=/home/ute/Downloads/Base_SCF/rat_5g_basic_gnb2.xml       verify_bts_status=False       timeout=600
    Sleep   400
    Perform Recommissioning     type=delta     delta_file=${delta_gnb1_ca_sim_gnb}     timeout=300
    Sleep   60
    Setup Oamops     bts_host=${gNB2_Mplane_Ip}     alias=gNB2
    Perform Recommissioning     type=delta     delta_file=${delta_gnb2_ca}     timeout=300  alias=gNB2
    Sleep     300
    Traffic capture start           capture_device=bts    capture_filter=port 38412 or 38472 or 38462 or 38422 or 36422 or 49151
    Call Setup      5g=CB008140_v4_sim:data    parallel=${False}    verify_attach=${False}   attach=${False}      ipv4_or_6=ipv4
    Sleep    120
    Configure UE       5g=CB008140_v4_sim:data    command=enb_x2_link_up   enb=1   target=3
    Configure UE       5g=CB008140_v4_sim:data    command=read_wtsemu_output_until    expected=X2AP Link with GNB-3 (10.0.1.3:36422[0]) is up
    ...   timeout=60
    Sleep   60
    Configure UE     5g=CB008140_v4_sim:data   command=sim_trace  enb=4  protocol=xp,xn on
    Configure UE     5g=CB008140_v4_sim:data   command=enb_xp_param  xp_peers=2  id=4
    Sleep    120
    Perform Recommissioning     type=param     param_path=MRBTS-1/NRBTS-1/NRDU-1:actInterGnbCa
    ...     operation=update        value=disabled     timeout=300
    Sleep   60
    Setup Oamops     bts_host=${gNB2_Mplane_Ip}     alias=gNB2
    Perform Recommissioning     type=param     param_path=MRBTS-2/NRBTS-2/NRDU-1:actInterGnbCa     operation=update
    ...        value=disabled     timeout=300  alias=gNB2
    Sleep   60
    Perform Recommissioning     type=param     param_path=MRBTS-1/NRBTS-1/NRDU-1:actInterGnbCa     operation=update
    ...        value=DLOnly     timeout=300
    Setup Oamops     bts_host=${gNB2_Mplane_Ip}     alias=gNB2
    Perform Recommissioning     type=param     param_path=MRBTS-2/NRBTS-2/NRDU-1:actInterGnbCa     operation=update
    ...        value=DLOnly     timeout=300  alias=gNB2
    Sleep   120

        ${xnlink}=   Query admin infomodel    query=get param //XNLINK_R-*:xnLinkStatus
        ${xnlink}=   Get Dictionary Values   ${xnlink}
        ${xnlink_1}=   Get From List   ${xnlink}   0
        ${xnlink_1}=   Get Dictionary Values   ${xnlink_1}
        ${xnlink_1}=   Get From List   ${xnlink_1}   0
        Should Be True    '${xnlink_1}'=='available'
        ${xnlink_2}=   Get From List   ${xnlink}   1
        ${xnlink_2}=   Get Dictionary Values   ${xnlink_2}
        ${xnlink_2}=   Get From List   ${xnlink_2}   0
        Should Be True    '${xnlink_2}'=='available'


        ${xplink}=   Query admin infomodel    query=get param //XPIFREMOTE_R-*:xpLinkStatus
        ${xplink}=   Get Dictionary Values   ${xplink}
        ${xplink_1}=   Get From List   ${xplink}   0
        ${xplink_1}=   Get Dictionary Values   ${xplink_1}
        ${xplink_1}=   Get From List   ${xplink_1}   0
        Should Be True    '${xplink_1}'=='available'
        ${xplink_2}=   Get From List   ${xplink}   1
        ${xplink_2}=   Get Dictionary Values   ${xplink_2}
        ${xplink_2}=   Get From List   ${xplink_2}   0
        Should Be True    '${xplink_2}'=='available'


     ${xnlink}=   Query admin infomodel    query=get param //XNLINK_R-*:xnLinkStatus   alias=gNB2
     ${status}    Should Be True    '${xnlink}'=='available'
     ${xplink}=   Query admin infomodel    query=get param //XPIFREMOTE_R-*:xpLinkStatus    alias=gNB2
     ${status}    Should Be True    '${xplink}'=='available'

***Keywords***
Pre-condition
    Bringup simulated core ips on VM
Bringup simulated core ips on VM
    Run         sudo ip a a 10.0.1.121/24 dev eth3
    Run         sudo ip a a 10.0.1.125/24 dev eth3
    Run         sudo ip a a 10.0.1.124/24 dev eth3
    Run         sudo ip a a 10.0.1.200/24 dev eth3
    Run         sudo ip a a 10.0.2.90/24 dev eth4

    FOR  ${i}  IN RANGE   1  8
           Run         sudo ip a a 10.0.1.13${i}/24 dev eth3
    END

    Run     sudo ifconfig eth3 inet6 add fc00::1/116
    Run     sudo ifconfig eth3 inet6 add fc00::121/116
    FOR  ${i}  IN RANGE   1  7
           Run     sudo ifconfig eth3 inet6 add fc00::13${i}/116
    END

Verify message flow for SA call
     ${pcap_file}=       Traffic capture stop
     Set Suite Variable          ${pcap_file}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=ignb_ca_setup_request         filter_file_name=${CB008140_traffic_filter}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=ignb_ca_setup_response        filter_file_name=${CB008140_traffic_filter}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=f1ap_trs_addr                 filter_file_name=${CB008140_traffic_filter}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=ignb_add_req                   filter_file_name=${CB008140_traffic_filter}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=ignb_ca_ue_con_mod_req         filter_file_name=${CB008140_traffic_filter}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=ignb_ca_ue_con_mod_resp        filter_file_name=${CB008140_traffic_filter}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=ignb_ca_mod_req                filter_file_name=${CB008140_traffic_filter}
     Analyse pcap    pcap_filename=${pcap_file}      analysis=ignb_ca_mod_resp               filter_file_name=${CB008140_traffic_filter}
