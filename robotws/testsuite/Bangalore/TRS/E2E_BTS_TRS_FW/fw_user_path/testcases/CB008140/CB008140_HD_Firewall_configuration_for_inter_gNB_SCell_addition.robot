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

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown

#Suite Setup     Setup Oamops
#Suite Teardown      Teardown Oamops


***Test Cases***
[1]CB008140-HD_Firewall configuration for inter_gNB SCell addition
     Pre-condition
    Perform Recommissioning     type=delta     delta_file=${delta_gnb1_ca}     timeout=300
    Sleep   60
     Setup Oamops     bts_host=${gNB2_Mplane_Ip}     alias=gNB2
    Perform Recommissioning     type=delta     delta_file=${delta_gnb2_ca}     timeout=300  alias=gNB2

    Sleep     300
    Traffic capture start           capture_device=bts    capture_filter=port 38412 or 38472 or 38462 or 38422 or 36422 or 49151
    Perform Recommissioning     type=param     param_path=MRBTS-1/NRBTS-1/NRDU-1:actInterGnbCa     operation=update
    ...        value=disabled     timeout=300
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
    Sleep    60
    Call Setup      5g=CB008140_v4:data    parallel=${False}    verify_attach=${False}   attach=${False}      ipv4_or_6=ipv4
    Sleep    120
    Configure UE       5g=CB008140_v4:data    command=enb_x2_link_up   enb=1   target=3
    Configure UE       5g=CB008140_v4:data    command=read_wtsemu_output_until    expected=X2AP Link with GNB-3 (10.0.1.3:36422[0]) is up
    ...   timeout=60
    Sleep   90

    ${xnlink}=   Query admin infomodel    query=get param //XNLINK_R-*:xnLinkStatus
    ${status}    Should Be True    '${xnlink}'=='available'
    ${xplink}=   Query admin infomodel    query=get param //XPIFREMOTE_R-*:xpLinkStatus
    ${status}    Should Be True    '${xplink}'=='available'

     ${xnlink}=   Query admin infomodel    query=get param //XNLINK_R-*:xnLinkStatus   alias=gNB2
     ${status}    Should Be True    '${xnlink}'=='available'
     ${xplink}=   Query admin infomodel    query=get param //XPIFREMOTE_R-*:xpLinkStatus    alias=gNB2
     ${status}    Should Be True    '${xplink}'=='available'

    Perform Recommissioning  type=param   param_path=${5gdynamic_firewall}   operation=update  value=true   timeout=300

    Configure UE    5g=CB008140_v4:data    command=read_wtsemu_output_until_prompt    timeout=10
    Configure UE    5g=CB008140_v4:data    command=ue_register  id=${ue_id}
    Configure UE    5g=CB008140_v4:data    command=read_wtsemu_output_until_re   expected=.*REGISTRATION COMPLETE.*
    ...        timeout=120
    Configure UE       5g=CB008140_v4:data    command=set_pdu_param   ue=${ue_id}   pdu=${pdu_id}   trf_type=internal
    Sleep   2
    Configure UE       5g=CB008140_v4:data    command=ue_pdu_session_setup  pdu=${pdu_id}  ue=${ue_id}  nwslice=1  gw=1
    Configure UE    5g=CB008140_v4:data    command=read_wtsemu_output_until   expected=rrcReconfigurationComplete  timeout=60
    Sleep   2
    FOR  ${i}    IN RANGE   1    8
         Configure UE       5g=CB008140_v4:data    command=trf_data_start  ue=${ue_id}  pdu=${pdu_id}  qfi=1  trf_id=${i}  dir=ul  mbps=175
         Configure UE       5g=CB008140_v4:data    command=trf_data_start  ue=${ue_id}  pdu=${pdu_id}  qfi=1  trf_id=${i}  dir=dl  mbps=175
         Sleep   10
    END
    Sleep    120
    Configure UE    5g=CB008140_v4:data    command=read_wtsemu_output_until_re   expected=SCellIndex 1 activated successfully
    ...        timeout=120
    Configure UE       5g=CB008140_v4:data    command=ue_stats_nr  id=1  scell=0-1  type=pdsch
    Configure UE       5g=CB008140_v4:data    command=read_wtsemu_output_until   expected=CellIndex-0   timeout=60
    ${output}=         Configure UE       5g=CB008140_v4:data    command=read_wtsemu_output_until_prompt  timeout=10
    Log To Console    ${output}
    Should Not Match Regexp    ${output}    CellIndex-1.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Match Regexp    ${output}    CellIndex-1.*\\d{3}.\\d{1}\\sMbps.*\\d{3}.\\d{1}\\sMbps.*\\d{3}.\\d{1}\\sMbps.*\\d{3}.\\d{1}\\sMbps
    Sleep    10

     Verify message flow for SA call
    [Teardown]    Call Teardown    5g=CB008140_v4:data

***Keywords***
Pre-condition
    Bringup simulated core ips on VM

Bringup simulated core ips on VM
    Run         sudo ip a a 10.0.1.121/24 dev eth3
    Run         sudo ip a a 10.0.1.200/24 dev eth3
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
