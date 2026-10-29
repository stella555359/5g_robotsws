*** Settings ***

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors: Prerana N S
...              :contact: prerana.n_s@nokia.com
...              :Requirement ID: 5G_RAN_USR_RRM_26013
...              :Requirement ID: 5G_RAN_USR_RRM_26070
...              :Requirement ID:5G_RAN_USR_RRM_25479 ; OM_GEN_SFS_TRACEMGMNT.4881
...              :Description(TC1):This user scenario describes the interaction with inter-gNB RRC Reestablishment during handover.
...               RRC Reestablishment to handover target cell during inter-gNB handover via NG.
...              :Description(TC2):This test case validates the interaction with RRC Inactive State transitions under same gNB (SA mode)
...               and verifies that during the RRC Resume, the stored default S-NSSAI shall be used and no need to do the switch again
...              :Description(TC3):This TC verifies the incoming XN handover sceanrios and outgoing HO scenario with Slice switch to
...              default slice

Resource         ./basic_resource.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library        SSHLibrary

Suite Setup         Run keywords      Suite setup from scratch
...                 AND          download_scf     ./
...                 AND     Update bsr package
...                 AND    Add RadParam to swconfig     "0x890073=0"      IP=192.168.255.129
...                 AND       Add routes

Suite Teardown    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu
${wts_cfg_file}     ${CURDIR}/config/wts/CB013052_tc12.cfg
${wts_cfg_file1}     ${CURDIR}/config/wts/rrc_res_slice_basic_setup_3PLMN.cfg
${wts_cfg_file2}     ${CURDIR}/config/wts/slice_basic_setup_multi_ue_Xn_HO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}        3
${nwslice_ID}   1
&{nwslice_ID1}   ${1}=1    ${2}=2     ${3}=3     ${4}=14     ${5}=15    ${6}=16
${gw_ID1}     1
${gw_ID2}     2
${gw_ID3}     3
${Pdu_session_ID1}       1
${Pdu_session_ID2}       2
${QFI_ID1}     1
${QFI_ID2}    2
${QFI_ID3}    3
${TRF_ID1}    1
${TRF_ID2}    2
${Q_O_ADD1}    1
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${SCFC}=              ${CURDIR}/config/SBTS25R1/rrc_resume_scfc.xml
${AP_XML}=            ${CURDIR}/config/new_iphy_rrc_resume.xml
${IPHY_FILE}            ${CURDIR}/config/xnho_iphy.xml
${epc_log_path}    /tmp/
${XnHo_success}     NR RRC Reestablishment sucessfully completed
${XnHo_success1}     rrcReconfigurationComplete
${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip

*** Test Cases ***
[1]CB013052-A_B13_TC13_Interaction_with_RRC_Inactive_State_transitions_under_same_gNB
    [Documentation]   This scenario verifies rrc resume procedure after the slice switch for 3 UEs pdu sessions

#    upload_scf      ./def_scf.xml
#    sleep    300
    Perform SCF Delta Commissioning with snssai_lock.json
    Perform SCF Delta Commissioning with A_B13_T13.json
    Start wts application and load CFG     ${wts_cfg_file1}
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts

#UE1
    set amf paramter    1     311:489
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    1    1    pdu_id=1    nw_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Start Log     cprt
    setup 2 pdu session with supported slice id for ue1 and send data
    ${path1}    Stop Log      cprt      test_scenario=pdu_ue1

#UE2
    set amf paramter    2     311:490
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    2    2    pdu_id=1    nw_id=2
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Start Log     cprt
    setup 3 pdu session with unsupported slice id for ue2 and send data
    ${path1}    Stop Log      cprt      test_scenario=pdu_ue2

#UE3
    set amf paramter    3     311:491
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    3    3    pdu_id=1    nw_id=3
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Start Log     cprt
    setup 1 pdu session with supported and 4 with unsupported slice id for ue3 and send data
    ${path1}    Stop Log      cprt      test_scenario=pdu_ue3

    Stop traffic for all
    sleep      120s
    Start Log     cprt
    Trigger rrcresume dl      1
    Trigger rrcresume dl      2
    Trigger rrcresume dl      3
    ${path1}    Stop Log      cprt      test_scenario=resume_ue
    Trigger traffic for all bearers
    sleep       300s
    Wait until the current Measurement Period stops
    wts_sim_keywords.MultiUE Deregister should be Successful      1    3
    Verify 13052 counters
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1]CB013052-A_B12_TC11_ Interaction_with_Inter_gNB_RRC_Reestablishment_during_Handover_to_target_cell
    upload_scf      ./def_scf.xml
    sleep    300

    Perform SCF Delta Commissioning with snssai_lock.json
    Perform SCF Delta Commissioning with tc12.json
    gnb.Perform gNB reboot
    Sleep   360s    reason=wait for RMOD to comeup
    Start wts application and load CFG      ${wts_cfg_file}
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt
    execute_egate_command        cmd=amf_ue_ng_handover_request_param id=1
    Configure mrl1
 	execute_egate_command        cmd=amf_ue_ng_handover_request_param id=1 mobility_restriction_list_id=1
 	ue location change custom
    execute_egate_command        cmd=ue_gnb_ho_param id=1 gnb=2
	Set security configuration
    Perform Precondition of Test Scenario
    Configure ReestablishmentInfo For NG Handover
    wts_sim_keywords.MultiUE Register should be Successful    1    1    pdu_id=1    nw_id=5
    Sleep    2s
    ${path1}    Stop Log      cprt      test_scenario=ue_register
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Start Log     cprt
    Set UE RRC Reestablishment During RRCReconfiguration
    ...  ue_id=1  gnb_id=2  cell_id=1  cause=handoverFailure  crnti=source

    Trigger NGHO from simulator to real     1       1       50
    ${path2}    Stop Log      cprt      test_scenario=ho_sim_to_real
    wts_sim_keywords.MultiUE Deregister should be Successful      1    1
    Verify message custom     ${path2}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a6   1
     ${Counters}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${1}
    ...         ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${0}        ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${0}

    Wait until the next Measurement Period starts
    sleep    300s
    Verify Counters modi   ${Counters}    NRCELL-1
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CNI121217_CB013052-A_B3_TC7_Graceful_handling_during_Inter-gNB_Xn_based_handover_for_SA
    upload_scf      ./def_scf.xml
    sleep    300

    Perform SCF Delta Commissioning with snssai_lock.json
    Perform SCF Delta Commissioning with slice_xnho.json

    gnb.Perform gNB reboot
    Sleep   360s    reason=wait for RMOD to comeup
    Start wts application and load CFG     ${wts_cfg_file2}
    sleep    60
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt
    Configure mrl
    configure mrl override     311:489
#    Start_Dcap_Ipcapture
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    1    1    pdu_id=1    nw_id=1
    Sleep    2s
    ${path1}    Stop Log      cprt      test_scenario=ue_register
    set test variable    ${path1}    ${path1}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Sleep    10s
    Start Log    cprt
    Make emergency call    ${4}    ${1}
    Trigger VONR custom data    ${4}    ul    1    1    2       custom
    Trigger VONR custom data    ${4}    dl    1    1    2      custom
    sleep    60s
    validate traffic for ue1 and ue4

    Trigger XnHO from real to simulator     4       3       52      311:489|0x01
    ${cprt_log}     Stop Log  cprt  test_scenario=UE_${4}_${1}_eme_ho_real_to_sim
    set test variable    ${cprt_log}    ${cprt_log}
    Start Log     cprt
    Trigger XnHO from simulator to real     4       2       50      311:489|0x01
    ${path2}    Stop Log      cprt      test_scenario=UE_${4}_${1}_eme_ho_sim_to_real
    set test variable    ${path2}    ${path2}
    setup 2 pdu session with supported slice id for ue1 and send data
    Start Log     cprt
    Trigger XnHO from real to simulator     1       3       52      311:489|0x01
    ${path3}    Stop Log      cprt      test_scenario=ho_real_to_sim
    set test variable    ${path3}    ${path3}
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     1       2       50      311:489|0x01
    ${path4}    Stop Log      cprt      test_scenario=ho_sim_to_real
    set test variable    ${path4}    ${path4}
    sleep     60s
    validate traffic for ue1 and ue4

    configure mrl override     311:490
    Start Log     cprt
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    2    2    pdu_id=1    nw_id=2
    Sleep    2s
    ${path5}    Stop Log      cprt      test_scenario=ue_register_2
    set test variable    ${path5}    ${path5}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Sleep    10s
    Start Log     cprt
    setup 3 pdu session with unsupported slice id for ue2 and send data
    ${path8}    Stop Log      cprt      test_scenario=ue_2_pdu_2
    set test variable    ${path8}    ${path8}
    Make emergency call    ${5}    ${1}
    Trigger VONR custom data    ${5}    ul    1    1    2       custom
    Trigger VONR custom data    ${5}    dl    1    1    2       custom
    sleep    60s
    validate traffic for ue2 and ue5
    execute_egate_command    cmd=ue_history_information_list id=1 action=reset
    execute_egate_command    cmd=ue_history_information_list id=2 action=reset

    Start Log     cprt
    Trigger XnHO from real to simulator     5       3       52      311:490|0x01
    ${path6}    Stop Log      cprt      test_scenario=ue_5_1_eme_ho_real_to_sim
    set test variable    ${path6}    ${path6}
    Start Log     cprt
    Trigger XnHO from simulator to real     5       2       50      311:490|0x01
    ${path7}    Stop Log      cprt      test_scenario=ho_sim_to_real_2
    set test variable    ${path7}    ${path7}
    Start Log     cprt
    Trigger XnHO from real to simulator     2       3       52      311:490|0x01
    ${path9}    Stop Log      cprt      test_scenario=ho_real_to_sim_2
    set test variable    ${path9}    ${path9}
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     2       2       50      311:490|0x01
    ${path10}    Stop Log      cprt      test_scenario=ho_sim_to_real_2
    set test variable    ${path10}    ${path10}
    sleep    60s
    validate traffic for ue2 and ue5
    configure mrl override     311:491
    Start Log     cprt
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    3    3    pdu_id=1    nw_id=3
    Sleep    2s
    ${path11}    Stop Log      cprt      test_scenario=ue_register_3
    set test variable    ${path11}    ${path11}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Sleep    10s
    Start Log     cprt
    setup 1 pdu session with supported and 3 with unsupported slice id for ue3 and send data
    ${path12}    Stop Log      cprt      test_scenario=ue3_pdu3
    Start Log     cprt

    Trigger XnHO from real to simulator     3       3       52      311:490|0x01
    ${path13}    Stop Log      cprt      test_scenario=ho_real_to_sim_3
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     3       2       50      311:490|0x01
    ${path14}    Stop Log      cprt      test_scenario=ho_sim_to_real_3
    sleep    60s
    validate traffic for ue3

    Make emergency call    ${6}    ${1}
    Trigger VONR custom data    ${6}    ul    1    1    2       custom
    Trigger VONR custom data    ${6}    dl    1    1    2       custom
    sleep     60s
    wts_sim_keywords.Validate DL Traffic For SA    ${6}    0.025    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${6}    0.025    1    2
    Start Log     cprt
    Trigger XnHO from real to simulator     6       3       52      311:490|0x01
    ${path15}    Stop Log      cprt      test_scenario=ho_real_to_sim_3
    sleep   5s
    Start Log     cprt
    Trigger XnHO from simulator to real     6       2       50      311:490|0x01
    ${path16}    Stop Log      cprt      test_scenario=ho_sim_to_real_3
#    Stop_and_Collect_Dcap_IpCapture			${LOG_PATH}
    wts_sim_keywords.Validate DL Traffic For SA    ${6}    0.025    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${6}    0.025    1    2
    verify pcap messages from log
#    verify_pcmd_traces_on_tce     pcap_filepath=${LOG_PATH}     pcap_file=ipCapture.pcap  pdml_file=ipCapture_pcmd.pdml
    ${Counters}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${18}
    ...     ${NRRCC_RRC_STPREQ_EMERGENCY}=${3}    ${NRRCC_RRC_STPSUCC_EMERGENCY}=${3}    ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${12}
    ...     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${12}
    Wait until the next Measurement Period starts
    sleep    300s
    Verify Counters modi   ${Counters}    NRCELL-1
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Trigger traffic for all bearers
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    3    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    3    Traffic_rate=mbps     ul_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    3    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    3    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    3    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    3    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    3    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    3    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=6    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=6    trf_id=1       qfi_id=1

Verify 13052 counters
     ${Counter_fallback}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${7}
    ${Counter_fallback_pmqap1}    Create Dictionary     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${0}
    ${Counter_fallback_ho_pmqap1}    Create Dictionary     ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${0}
    ${Counter_fallback_pmqap2}    Create Dictionary     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${3}
    ${Counter_fallback_ho_pmqap2}    Create Dictionary     ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${0}
    ${Counter_fallback_pmqap3}    Create Dictionary     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${4}
    ${Counter_fallback_ho_pmqap3}    Create Dictionary     ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${0}
    ${Counters_resume_att}    Create Dictionary     ${NRRCC_RRC_RESUME_REQUEST1}=${3}
    ${Counters_resume_succ}    Create Dictionary     ${NRRCC_RRC_RESUME_SUCC}=${3}
    Verify Counters modi   ${Counter_fallback}    NRCELL-4
    Verify Counters modi   ${Counter_fallback_pmqap1}    NRCELL-4/PLMN-PLMN/NRPMQAP-51
    Verify Counters modi   ${Counter_fallback_ho_pmqap1}    NRCELL-4/PLMN-PLMN/NRPMQAP-51
    Verify Counters modi   ${Counter_fallback_pmqap2}    NRCELL-4/PLMN-PLMN/NRPMQAP-52
    Verify Counters modi   ${Counter_fallback_ho_pmqap2}    NRCELL-4/PLMN-PLMN/NRPMQAP-52
    Verify Counters modi   ${Counter_fallback_pmqap3}    NRCELL-4/PLMN-PLMN/NRPMQAP-53
    Verify Counters modi   ${Counter_fallback_ho_pmqap3}    NRCELL-4/PLMN-PLMN/NRPMQAP-53
    Verify Counters modi   ${Counters_resume_att}    NRCELL-4
    Verify Counters modi   ${Counters_resume_succ}    NRCELL-4
set amf paramter
    [Arguments]     ${ue_id}    ${plmn}
    ${amf_param1}	SET VARIABLE	amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ${amf_param2}	SET VARIABLE	periodic_registration_update_timer=5:1min plmn_id=${plmn} tac_id=200
    execute_egate_command        ${amf_param1} ${amf_param2}

Trigger rrcresume
    FOR     ${ue_id}   IN RANGE    1    4
    execute_egate_command    cmd=qfi_stats_clear ue=${ue_id} pdu=1
    sleep      1s
    execute_egate_command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} cause=mo_Data
    sleep      1s
    execute_egate_command    cmd=ue_nr_rrc_resume id=${ue_id}
    END

Trigger rrcresume dl
    [Arguments]     ${ue_id}
    execute_egate_command    cmd=qfi_stats_clear ue=${ue_id} pdu=1
    sleep      1s
    execute_egate_command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    sleep      1s

Stop traffic for all

     execute_egate_command    cmd=trf_data_stop ue=1 pdu=1
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=1 pdu=2
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=1 pdu=3
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=2 pdu=1
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=2 pdu=2
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=2 pdu=3
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=2 pdu=4
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=3 pdu=1
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=3 pdu=2
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=3 pdu=3
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=3 pdu=4
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=3 pdu=5
     sleep      1s
     execute_egate_command    cmd=trf_data_stop ue=3 pdu=6


setup 2 pdu session with supported slice id for ue1 and send data
    execute_egate_command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
     ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=4 ue=1 nwslice=1
    ${output1}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=1 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=5 ue=1 nwslice=1
    ${output2}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1

setup 1 pdu session with supported and 4 with unsupported slice id for ue3 and send data
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=2 trf_type=internal
    ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=9 ue=3 nwslice=16
    ${output1}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=10 ue=3 nwslice=16
    ${output2}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=4 trf_type=internal
    ${pdu_setup_cmd3}	SET VARIABLE	ue_pdu_session_setup pdu=4 gw=11 ue=3 nwslice=16
    ${output3}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd3}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=5 trf_type=internal
    ${pdu_setup_cmd4}	SET VARIABLE	ue_pdu_session_setup pdu=5 gw=12 ue=3 nwslice=16
    ${output4}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd4}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
	sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=6 trf_type=internal
    ${pdu_setup_cmd4}	SET VARIABLE	ue_pdu_session_setup pdu=6 gw=14 ue=3 nwslice=6
    ${output4}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd4}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=6    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=6    trf_id=1       qfi_id=1


Add routes
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3

verify pcap messages from log
    Verify message custom    ${path1}[cprt]//NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a5    1
    Verify message custom    ${cprt_log}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a5    1
    Verify message custom    ${path2}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a5    1
    Verify message custom    ${path3}[cprt]/NODECPRT_GNB.pcap     xnap.HandoverRequest_element      xnap    d143a5    1    ic=${1}
    Verify message custom    ${path4}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    d143a5    1    ic=${1}
    Verify message custom    ${path5}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    2    1
    Verify message custom    ${path8}[cprt]/NODECPRT_GNB.pcap    e1ap.sD      e1ap    2    1
    Verify message custom    ${path6}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    f    1    ic=${1}
    Verify message custom    ${path7}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    2    1    ic=${1}    sd2=${1}
    ...    sd3=${1}    sd4=${1}
    Verify message custom    ${path9}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    2    1    ic=${1}    sd2=${1}
    ...    sd3=${1}    sd4=${1}
    Verify message custom    ${path10}[cprt]/NODECPRT_GNB.pcap    xnap.HandoverRequest_element      xnap    2    1    ic=${1}    sd2=${1}
    ...    sd3=${1}    sd4=${1}
    Verify message custom    ${path11}[cprt]/NODECPRT_GNB.pcap    e1ap.sD      e1ap    3    1

validate traffic for ue3
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    1    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    1    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    2    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    2    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    3    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    3    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    4    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    4    1
    wts_sim_keywords.Validate DL Traffic For SA    ${3}    5    5    1
    wts_sim_keywords.Validate UL Traffic For SA    ${3}    5    5    1

validate traffic for ue2 and ue5
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    1    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    1    1
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    2    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    2    1
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    3    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    3    1
    wts_sim_keywords.Validate DL Traffic For SA    ${2}    5    4    1
    wts_sim_keywords.Validate UL Traffic For SA    ${2}    5    4    1
    wts_sim_keywords.Validate DL Traffic For SA    ${5}    0.025    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${5}    0.025    1    2
validate traffic for ue1 and ue4
    wts_sim_keywords.Validate DL Traffic For SA    ${1}    5    1    1
    wts_sim_keywords.Validate UL Traffic For SA    ${1}    5    1    1
    wts_sim_keywords.Validate DL Traffic For SA    ${4}    0.0251    1    2
    wts_sim_keywords.Validate UL Traffic For SA    ${4}    0.0251    1    2
Verify message all_files
    [Arguments]     ${file_list}
    FOR    ${file}  IN RANGE    @{file_list}
        Verify message custom     ${file}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap
    END
Make emergency call
    [Arguments]    ${ue_id}    ${pdu_id}    ${ics_wo_pdu}=${-1}
    ${Initial_context_setup_pattern}    setvariable if    ${ics_wo_pdu}==${1}
    ...      Pdu Session Resource Setup Response Message with RAN UE NGAP ID    ${Initial_context_setup_pattern}
    execute_egate_command    cmd=ue_param id=${ue_id} nr_usage_setting=voice_centric
    execute_egate_command    cmd=amf_param id=1 ims_voice_3gpp=On
    execute_egate_command    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    execute_egate_command    cmd=qosflow_modify qos_flow=1 priority=1
    execute_egate_command    cmd=qosflow_modify qos_flow=2 priority=1
    execute_egate_command    cmd=smf_param id=1 additional_qosflows_to_activate=2
    execute_egate_command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${cmd}        Set variable    ue_register id=${ue_id} registration_type=EmergencyRegistration
    ${output}  Execute Egate Command And Wait For Data  ${cmd}
	...		pass_regexp=(\?\:${UE_register_complete_pattern})        timeout=10s
#    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    ${gw_id}     Evaluate    ${ue_id}+${pdu_id}
    ${gw_id}     Set variable if    ${1}==${pdu_id}   ${pdu_id}    ${gw_id}

#    ute_wtssim.execute_egate_command     cmd=u
#    ...
#    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${tmp_var}    set variable     request_type=initial-emergency-request

    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_ID1}[${ue_id}] gw=${gw_id} ${tmp_var}

    ${output2}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s

	execute_egate_command    cmd=smf_param id=1 reset

setup 3 pdu session with unsupported slice id for ue2 and send data
    execute_egate_command    cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
     ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=6 ue=2 nwslice=15
    ${output1}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=2 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=7 ue=2 nwslice=15
    ${output2}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=2 pdu=4 trf_type=internal
      ${pdu_setup_cmd3}	SET VARIABLE	ue_pdu_session_setup pdu=4 gw=8 ue=2 nwslice=15
    ${output3}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd3}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
setup 1 pdu session with supported and 3 with unsupported slice id for ue3 and send data
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=2 trf_type=internal
    ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=9 ue=3 nwslice=16
    ${output1}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=10 ue=3 nwslice=16
    ${output2}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=4 trf_type=internal
    ${pdu_setup_cmd3}	SET VARIABLE	ue_pdu_session_setup pdu=4 gw=11 ue=3 nwslice=16
    ${output3}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd3}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    execute_egate_command    cmd=set_pdu_param ue=3 pdu=5 trf_type=internal
    ${pdu_setup_cmd4}	SET VARIABLE	ue_pdu_session_setup pdu=5 gw=12 ue=3 nwslice=6
    ${output4}  Execute Egate Command And Wait For Data  ${pdu_setup_cmd4}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=5    trf_id=1       qfi_id=1
Trigger XnHO from real to simulator
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}     ${nrcgi}
    ${history}     SET VARIABLE    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=${nrcgi} time_ue_stayed_in_cell=100
    execute_egate_command    ${history}
    execute_egate_command    cmd=ue_history_information_list action=commit id=1
    execute_egate_command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    execute_egate_command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${tmp2}    set variable    nrsrp_nr=30 nrsrq_nr=20
    ${msr}      SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} ${tmp2}
    Execute Egate Command And Wait For Data      ${msr}     pass_regexp=${XnHo_success1}      timeout=30s
Configure mrl
    ${reset}    SET VARIABLE    amf_mobility_restriction_list_param reset id=1
    execute_egate_command    ${reset}
    ${msr}     SET VARIABLE      amf_mobility_restriction_list_param id=1 sa_plmn=311:489 sa_plmn=311:490 sa_plmn=311:491
    execute_egate_command        ${msr}
    ${set_mrl}      SET VARIABLE      amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1
    ${cmd1}     SET VARIABLE    trace_activation=on trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=minimum
	${cmd2}		SET VARIABLE	ifaces_to_trace=E1,F1-C,Uu,Xn-C,NG-C tce_ip=10.0.1.1 core_network_assistance_info=on ue_identity_index_value=1
	${cmd3}		SET VARIABLE	ue_specific_drx=64 periodic_registration_update_timer=1:1min plmn_id=311:489 tac_id=200
    execute_egate_command    ${set_mrl} ${cmd1} ${cmd2} ${cmd3}
configure mrl override
    [Arguments]     ${plmn}
    execute_egate_command        cmd=gnb_param id=3 ignore_MRL_during_HO=on mrl_override_serving_plmn=${plmn}
Trigger XnHO from simulator to real
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}     ${nrcgi}

    ${history}     SET VARIABLE      ue_history_information_list_add_ngran id=2 gnb_id=2 cell_type=medium nrcgi=${nrcgi} time_ue_stayed_in_cell=100
    execute_egate_command    ${history}
    execute_egate_command    cmd=ue_history_information_list action=commit id=2
    execute_egate_command    cmd=ue_enb_param id=${ue_id} ue_history_list=2
    execute_egate_command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${tmp2}    set variable    nrsrp_nr=30 nrsrq_nr=20
    ${msr}      SET VARIABLE    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} ${tmp2}
    Execute Egate Command And Wait For Data      ${msr}     pass_regexp=${XnHo_success1}      timeout=30s

Trigger VONR custom data
	[Arguments]    ${ue_id}     ${dir}		${pdu_id}     ${trf_id}		${qfi}			${rtp_codec}
    [Documentation]    This keyword starts the vonr data
    Log to Console    \nRunning Traffic
	${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} trf_id=${trf_id} rtp_codec=${rtp_codec}
    Execute Egate Command And Wait For Data		${data_cmd}		timeout=${EGATE_COMMAND_TIMEOUT}

Update_tce_ip_in_delta_file
    [Arguments]     ${file_path}
    ${command}     Set Variable     sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${eth0_ip}      Run     ${command}
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=TCE_VM_IP    replace_with=${eth0_ip}
	Set Global Variable			${eth0_ip}		${eth0_ip}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Verify_pcmd_traces_on_tce
    [Arguments]    ${pcap_filepath}     ${pcap_file}    ${pdml_file}
    Extract_trace_message_from_pcap_on_tce_port     pcap_filepath=${pcap_filepath}    pcap_file=${pcap_file}    pdml_file=${pdml_file}
	...		filter="nsetapx.data == 0"
    ${attrib_value}    analyzer.get_shownames        pdmlFile=${pcap_filepath}/${pdmlFile}
    ...                                                packetName=nsetapx.pduSessionResourceInfoRecord
    ...                                                path=nsetapx.result
    ...                                                endPacket=-${1}
    Should contain Match      ${attrib_value}     *defaultSnssaiFallback*
    Should Contain X Times      ${attrib_value}     result: defaultSnssaiFallback (3)   18

Extract_trace_message_from_pcap_on_tce_port
    [Arguments]    ${pcap_filepath}     ${filter}   ${pcap_file}    ${pdml_file}
    ${options}  Set variable  -o ntrstr.defragment:TRUE -o ntrstr.port:49148
    ${result}    Run    tshark ${options} -Y ${filter} -r ${pcap_filepath}/${pcap_file} -T pdml > ${pcap_filepath}/${pdml_file}

Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    @{RRU_TYPE}    ${RRU_type_list}[0]
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}


Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage:Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}     ${IP}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
        SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
