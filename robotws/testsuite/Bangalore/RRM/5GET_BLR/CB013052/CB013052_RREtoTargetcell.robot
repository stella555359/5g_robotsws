*** Settings ***

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors: Prerana N S
...              :contact: prerana.n_s@nokia.com
...              :Requirement ID: 5G_RAN_USR_RRM_26013
...              :Description:This user scenario describes the interaction with inter-gNB RRC Reestablishment during handover.
...               RRC Reestablishment to handover target cell during inter-gNB handover via NG.

Resource         ./basic_resource.robot
Resource         ../resources/robot/wts_sim_keywords.robot


Suite Setup         Run keywords      Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with tc12.json
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Configure UTE ETH3 IPs
...                 AND    Start wts application and load CFG      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib

Suite Teardown      Run Keywords    Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Teardown    Run Keywords       Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/CB013052_tc12.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID1}        1
${UE_ID2}        2
${UE_ID3}        3
${nwslice_ID}   1
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
${SCFC}=              ${CURDIR}/config/SBTS25R1/tc12.xml
${AP_XML}=            ${CURDIR}/config/xnho_iphy.xml
${epc_log_path}    /tmp/
${XnHo_success}     NR RRC Reestablishment sucessfully completed

*** Test Cases ***
[1]CB013052-A_B12_TC11_ Interaction_with_Inter_gNB_RRC_Reestablishment_during_Handover_to_target_cell
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt
    ute_wtssim.execute_egate_command        cmd=amf_ue_ng_handover_request_param id=1
    Configure mrl1
 	ute_wtssim.execute_egate_command        cmd=amf_ue_ng_handover_request_param id=1 mobility_restriction_list_id=1
 	ue location change custom
    ute_wtssim.execute_egate_command        cmd=ue_gnb_ho_param id=1 gnb=2
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
    Verify message custom     ${path2}[cprt]/NODECPRT_GNB.pcap    e1ap.nG_RAN_BearerContextSetupRequest      e1ap    d143a5   1
     ${Counters}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${1}
    ...         ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${1}        ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${0}

    Wait until the next Measurement Period starts
    sleep    300s
    Verify Counters modi   ${Counters}    NRCELL-1
