*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case is planned to check Ipsec tunnel status and corresponding alarms are rasied and cleared as expected"
...     [Date]      "20-03-24"
...     [Author]        "Chiranjeevi V "
...     [QC_Path]   "Root\Test_Sets\Trunk\VRF_BLR2\BB_TRS_VRF_ET\CRT\NF_Automated_Regression\TRSIV_NFTR_vRAN4.0"
...     [QC_ID]     "347014"
...     [Funtion_Hash_Tags] "SWN CLOUD"
...     [Feature_ID]            "CB010265"
...     [Validated_TestLine]    "trs-cran1 vCU"
...     [Requirements]  "WBTS_SEC_55225;WBTS_SEC_61952"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010265_common_keyword.robot


Suite Setup     Setup Oamops    dut=vcu_user    alias=vcu
Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_user      alias=vcu   AND     Collect Snapshot
...     dut=vcu_user  operation_timeout=300   alias=vcu   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vcu_user     alias=vcu



*** Test Cases ***
[1][1.0] RP000749_1_Automation_Verification of IKEv2 reuathentication trigger using different connection establishment modes

    Perform Commissioning      scf_file=${vcu_CB010265_base_scf_1}      timeout=600      dut=vcu_user    alias=vcu

    Triger CMP IR to install certificates on vCU    RSA     ECDSA

   Restore default certificates and check ipsec status

    Verify alarms should not exist in vCU

    Triger CMP IR to install certificates on vCU    RSA     ECDSA

    Check Ipsec tunnel status in vCU

    Enable the reauth flag and timer as 300s

    Check the ipsec tunnels after reauth triggered from enb

    Make BTS as responder

    Check the ipsec tunnels established after bts as responder




*** keywords ***


Verify_Traffic_capture_check

    traffic_capture_start   capture_device=vCU     capture_type=pod    plane_type=['cplane']     pod_names=['po-cpif-0']
    ...  measurement_point=NE_Terminated    timeout=260    alias=vcu

    Sleep   400

    traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcu   keep_alias=True
    Sleep   30
        generate_capture_files     capture_device=vCU        timeout=180    alias=vcu
        Sleep   90
    Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['cplane']     local_path=/home/ute/
    ...    timeout=180  alias=vcu

    Get downloaded pcaps of vCU

    Verify ike_auth

Get downloaded pcaps of vCU
    ${cplane_pcap}=     Run     ls /home/ute/ | grep gNB_vCU_1_po-cpif-0
    set suite variable  ${cplane_pcap}  ${cplane_pcap}


Verify ike_auth
    Analyse Pcap    pcap_filename=/home/ute/${cplane_pcap}        analysis=ike_reauth_cplane_300     filter_file_name=traffic_filters.json




Check the ipsec tunnels after reauth 300
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=ipsec_after_reauthenticationsw_pcap
    Sleep   400
    ${ipsec_after_reauthenticationsw_pcap}=       Traffic Capture Stop
    ...  alias=ipsec_after_reauthenticationsw_pcap
    Analyse pcap            pcap_filename=${ipsec_after_reauthenticationsw_pcap}      analysis=wo_vlan_tagging
    ...      filter_file_name=${ipsec_reauthentication_filter_file}
    Check Ipsec tunnel status in vCU

Enable the reauth flag and timer as 300s
    Perform Commissioning      scf_file=${Enable_Reauthentication_flag_v4_300}      timeout=600      dut=vcu_user    alias=vcu

Enable ipsec on enb and sw
    Enable Ipsec on SecureGW
    Enable Ipsec on Admin


Check the ipsec tunnels after reauth triggered from sw
    Check Ipsec tunnel status in vCU
    Traffic Capture Start   capture_device=vCU     capture_type=pod    plane_type=['cplane']    pod_names=['po-trs-cran1-cpif-0']
    ...     measurement_point=Transport_Interface    timeout=180    alias=vcu
    Sleep   120
    Traffic Capture Stop       capture_device=vCU      timeout=180     alias=vcu   keep_alias=True
    Sleep   20
    Generate Capture Files     capture_device=vCU        timeout=180    alias=vcu   dut=vcu_user
    Sleep   20
    ${ikev2_fragmentation}=     Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['cplane']
    ...       local_path=${pcap_dir}    timeout=180   alias=vcu   dut=vcu_user    keep_alias=False
    Set Suite Variable      ${ikev2_fragmentation}      ${ikev2_fragmentation}
    Verify in wireshark whether IKE_AUTH message exchange is successful and whether IKE SA is established on BTS and secgw

Verify in wireshark whether IKE_AUTH message exchange is successful and whether IKE SA is established on BTS and secgw
        Analyse pcap            pcap_filename=${ikev2_fragmentation}[0]      analysis=vCU_ikeauth_successful_IR_policy${i}
        ...     filter_file_name=${ikev2_fragmentation_filter_file}
        Analyse pcap            pcap_filename=${ikev2_fragmentation}[0]      analysis=vCU_ikeauth_successful_RR_policy${i}
        ...     filter_file_name=${ikev2_fragmentation_filter_file}


        ${ikePeerState_status}=     Get Parameter       param_path=MRBTS-1/TNLSVC-1/TNL-5/IPAPP-1/IPSECC-1/IKEP-${i}/IKEP_R-${i}:ikePeerState
        ...     timeout=180    alias=vcu    alias=vcu   dut=vcu_user
        Should Be True     '${ikePeerState_status}'=='ESTABLISHED'

    Check Ipsec tunnel status in vCU



Check the ipsec tunnels after reauth triggered from enb
    Perform Commissioning      scf_file=${Enable_Reauthentication_flag_v4_300}      timeout=600      dut=vcu_user    alias=vcu
    Sleep   400
    Verify_Traffic_capture_check
    Check Ipsec tunnel status in vCU


Check the ipsec tunnels established after bts as responder
    Check Ipsec tunnel status in vCU


Make BTS as responder
       Perform Commissioning      scf_file=${bts_responder}      timeout=600      dut=vcu_user    alias=vcu
        Sleep   400
