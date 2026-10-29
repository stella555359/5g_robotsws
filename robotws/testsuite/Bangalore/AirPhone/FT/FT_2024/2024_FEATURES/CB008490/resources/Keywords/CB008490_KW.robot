*** Settings ***
Documentation     This contains keywords used for CB008490 automation cases.

Library    BuiltIn
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    Process
Library    String
Library    Telnet
Library     XML
Library      taf.collectors.core    WITH NAME    core
Library      taf.gnb.oam.coam.admin    WITH NAME    CoamAdmin
Library      taf.gnb.oam.coam.cu    WITH NAME    coam_cu
Library      taf.sbts.oam.coam.admin         WITH NAME    admin
Library      taf.transport.ssh  WITH NAME  SSH
Library      taf.wts.runner    WITH NAME    wtsrunner
Library      ta5g_commissioning              WITH NAME    tcom
Library      ta5g_pm_counters
Library      ute_fsmaccess
Library      ute_wtssim
Library      ta5g_iphy
Library      ta5g_tshark
Variables       ta5g_global_var
Resource        ../Keywords/common_keywords.robot
Resource        ../Keywords/generic_kw.robot
Resource        ../Keywords/gnb_Keywords.robot
Resource        ../Keywords/ap_Keywords.robot
Resource        ../Keywords/HO_KW.robot
#Resource        ../Keywords/L3_pcap_keywords.robot
#Resource        ../ute/ute.robot
Library            traffic_varification.py

*** Variables ***
${TOPOLOGY}         	CLOUD_5G_I_LO_AP_LO
${gnb_scf}                   /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/CB008490/config/gnb_scf/
${AP_iphy}            /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/FT_2024/2024_FEATURES/CB008490/config/ap_iphy/
${pattern}     .*reported successful RA*.
${VLAN_ID}        ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${vlanif_distname}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${pdu_setup}    setup/reestablishment complete
${pdu_ses_mod_ind}     .*Received PDUSessionResourceModifyIndication*.
${unknown_old_XN_AP_ID}       "unknown-local-NG-RAN-node-UE-XnAP-ID"
${Error_Indication}           "Received Error Indication from gNB id-3"
${unknown_new_XN_AP_ID}       "inconsistent-remote-NG-RAN-node-UE-XnAP-ID"
${snode_rel_req}         "Message:xnap::SNodeReleaseRequired sent to GNB-2"
${snode_rel_req_1}       .*Message:xnap::SNodeReleaseRequired sent to GNB-2.*
${Log_Path}        /home/ute/logs
*** Keywords ***
Modifying GNB SWConfig
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 'echo "0x890098=0">/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 'crasign /ffs/run/swconfig.txt'

Start pcap collection in gNB
    [Arguments]    ${name}=gnbTcpdump    ${options}=-f sctp -i any -s0 -p    ${gnb_id}=0
    ${executor_oam_vm}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam_vm}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}

Stop pcap collection in gNB
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}

Start Tcpdump on wts
    [Arguments]    ${name}
    ${command}=     Set Variable    sudo tcpdump -i any -w ${name}.pcap > /dev/null 2>&1 &
    Run Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    [Return]       ${name}.pcap

Stop Tcpdump on wts
    [Arguments]    ${name}     ${Log_Path}
    ${command}=    Set Variable    sudo pkill tcpdump
    Run Process    ${command}    shell=True    stdout=stdout    stderr=stderr
    Run      cp ${name}.pcap ${Log_Path}/${name}.pcap
    [Return]       ${name}.pcap

Validate PCAP with fields
    [Arguments]     ${pcap_file_path}        ${filter}       ${field}
    ${rc}    ${tshark_output}    Run And Return Rc And Output    tshark -Y "${filter}" -T fields -e ${field} -r ${pcap_file_path}
    [Return]    ${tshark_output}

Validate PCAP
    [Arguments]     ${pcap_file_path}        ${filter}
    ${rc}    ${tshark_output}    Run And Return Rc And Output    tshark -Y "${filter}" -r ${pcap_file_path}
    [Return]    ${tshark_output}

Create IPHY dir
    Run     rm -rf /opt/iphy/
    Run     mkdir -p /opt/iphy/
    Run     cd /opt/iphy/
    Run Process    ln    -s    /opt/wts/latest    /opt/iphy/

Prepare for the MN Simulated case
    [Arguments]         ${Test_CaseNumber}
    ${Test_CaseNumber}=     Set Variable    ${Test_CaseNumber}
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    Create Interface for MN simulated
    Create IPHY dir
#    Modifying GNB SWConfig
    update_and_put_iphy_xml         ${AP_iphy}/8490_MN_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE   ${gnb_scf}/updated_8490_MN_Simulated_SCF.xml
#    Full Commission With SCF File For UTE   ${gnb_scf}/8490_MN_Simulated_SCF.xml
    sleep   300s
    Wait Coam Site to be Ready
    Start Tcpdump on wts    wts_tcpdump
    Start pcap collection in gNB
    Start UTE WTS    8490_MN_sim.cfg
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Prepare for the SN Simulated case
    [Arguments]         ${Test_CaseNumber}
    ${Test_CaseNumber}=     Set Variable    ${Test_CaseNumber}
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    Create Interface for MN simulated
    Create Interface for SN simulated
    Create IPHY dir
#    Modifying GNB SWConfig
    update_and_put_iphy_xml         ${AP_iphy}/SN_8490_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE   ${gnb_scf}/update_8490_SN_Simulated_SCF.xml
    sleep   300s
    Wait Coam Site to be Ready
    Start UTE WTS    nrdc_8490_SN_Sim.cfg
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Prepare for the MN Simulated case for 8490_EC8
    [Arguments]         ${Test_CaseNumber}
    ${Test_CaseNumber}=     Set Variable    ${Test_CaseNumber}
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    Create Interface for MN simulated
    update_and_put_iphy_xml         ${AP_iphy}/8490_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE   ${gnb_scf}/8490_MN_Simulated_SCF.xml
    sleep   300s
    Wait Coam Site to be Ready
#   ${pcap_file}=    Set Variable        Start Tcp Pcap on wts
    Start UTE WTS    8490_EC8.cfg
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

UE Register and verify for SA
    [Arguments]         ${UE_ID}=${UE_ID}
    wtsrunner.ue_register           id=${UE_ID}
    ${output}       Read WTS Output Until Pattern Matches           ${UE_register_complete_pattern}         ${Timeout_SA}
    Print Matching Lines from Output File          ${output}        ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister          ${output}

PDU Session setup
    [Arguments]         ${UE_ID}=${UE_ID}
    wtsrunner.set_pdu_param             ue=${UE_ID}                 pdu=${Pdu_session_ID}       trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup      pdu=${Pdu_session_ID}       ue=${UE_ID}                 nwslice=${nwslice_ID}   gw=${gw_ID}
    Read WTS Output For Pattern And Print matching Lines            ${pdu_setup}            ${Timeout_SA}

Prepare Sim gNB
     wtsrunner.gnb_nrdc_param     id=2      enable_dl_data_forwarding=off      t_reordering=100
...      serving_cell_index_range_scg_nrdc=1:31     direct_bearer_sn_addition_error=off
...      include_candidate_cell_info_list_mn=on    include_config_restrict_info=on
...      include_reestablish_pdcp=on      include_data_fwd_info_from_source=on
...      ue_sec_algo_first_bit_reserved=on      allowed_bc_list_mrdc=1:1
...      include_cgi_in_candidate_cell_info=off

Set gnb_endc
    [Arguments]     ${gnb_ID3}
    wtsrunner.gnb_endc_param      id=${gnb_ID3}      use_nr_ran_cont=on

Set Scg DL Dist Percent
    [Arguments]     ${gnb_ID2}   ${scg_dl_dist_percent}
    wtsrunner.gnb_endc_param     id=${gnb_ID2}    scg_dl_dist_percent=${scg_dl_dist_percent}

Set Scg UL Dist Percent
    [Arguments]     ${ue_id}   ${scg_ul_dist_percent}
    wtsrunner.uec_param      id=${ue_id}           scg_ul_dist_percent=${scg_ul_dist_percent}

UE Sending Measurment
    [Arguments]     ${ue_id}
    wtsrunner.ue_meas_param     id=${ue_id}      nr_neigh_cell=non_cfgd:52    nr_rsrp=127

Trigger NR-NR dual connectivity
     [Arguments]     ${ue_id}     ${gnb_ID3}=3      ${cell_id}=3
     Log to Console      Establishing NR_Dual connectivity\n
     wtsrunner.gnb_ue_nrdc_start    ue=${ue_id}     target_gnb=${gnb_ID3}     target_cells=${cell_id}    target_pdu_id_list=1
     sleep     60s
     ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${pattern}   timeout=15
     ${output}   Get Lines Matching Regexp    ${output}    ${pattern}      partial_match=${TRUE}
#    Read WTS Output For Pattern And Print matching Lines            ${pattern}            ${Timeout_SA}
     Log to Console    ${output}

Verifying the Counter for 8490 MN simulated
     Log to Console      Fetching the PM Counter\n
     Wait For Next Full Pm Interval
     ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
     Verify Last Counters In File
     ...     M55309C12001   >0     MAC_DTCH_CELL_THP_DL_MAX
     ...     M55309C12002   >0     MAC_DTCH_CELL_THP_UL_MAX
     ...     local_moid=MRBTS-1/NRBTS-3/NRCELL-2
     ...     file_path=${pm_counter_file}

Verifying the Counter for 8490 SN simulated
     Log to Console      Fetching the PM Counter\n
     Wait For Next Full Pm Interval
     ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
     Verify Last Counters In File
     ...     M55309C12001   >0     MAC_DTCH_CELL_THP_DL_MAX
     ...     M55309C12002   >0     MAC_DTCH_CELL_THP_UL_MAX
     ...     local_moid=MRBTS-1/NRBTS-2/NRCELL-1
     ...     file_path=${pm_counter_file}


Trigger A4 Measurement for 8490
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A4    nrsrp_nr=60      phycell_id=${phycell_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${pdu_ses_mod_ind}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    ${pdu_ses_mod_ind}       partial_match=${TRUE}
    Log to Console    ${output}

Trigger to corrupt MAC I
    [Arguments]      ${ue_id}
    Log to Console      \n This command shall introduce corrupted MAC I
    wtsrunner.ue_param     id=${ue_id}       integrityProt_macI_corruption=
Create Interface for MN simulated
    Run    sudo ip addr add 10.0.1.8/24 dev eth3
    Run    sudo ip addr add 10.0.1.9/24 dev eth3
    Run    sudo ip addr add 10.0.1.10/24 dev eth3

Delete Interface for MN simulated
    Run    sudo ip addr del 10.0.1.8/24 dev eth3
    Run    sudo ip addr del 10.0.1.9/24 dev eth3
    Run    sudo ip addr del 10.0.1.10/24 dev eth3

Create Interface for SN simulated
    Run    sudo ip addr add 10.0.1.6/24 dev eth3
    Run    sudo ip addr add 10.0.1.7/24 dev eth3

Delete Interface for SN simulated
    Run    sudo ip addr del 10.0.1.6/24 dev eth3
    Run    sudo ip addr del 10.0.1.7/24 dev eth3

Common test case tear down for MN Simulated
    Delete Basic Interface on UTE
    Delete Interface for MN simulated
#    Commision scf and iphy      scf=${gnb_scf}/8490_MN_Simulated_SCF.xml       iphy=${AP_iphy}/8490_iphy.xml
#    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
#    sleep   360s
#    Wait Coam Site to be Ready
     Stop pcap collection in gNB      gnbTcpdump     ${Log_Path}
     Stop Tcpdump on wts     wts_tcpdump    ${Log_Path}

Common test case tear down for SN Simulated
    Delete Basic Interface on UTE
    Delete Interface for SN simulated
    Delete Interface for MN simulated
#    Commision scf and iphy      scf=${gnb_scf}/realgnbMN_simSN_scf_n78_n261.xml     iphy=${AP_iphy}/SN_8490_iphy.xml
#    log to console         \n Rebooting GNB wait for 360s
#    GNB Reboot
#    sleep   360s
#   Wait Coam Site to be Ready

