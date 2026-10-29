*** Settings ***
Library     ta5g_tshark
Library     ta5g_pm_counters

Documentation
...    This file contains general keywords used for testing Feature CB013206.

*** Variables ***
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008
${a3_params}=    event=A3 srsrp_nr=11 srsrq_nr=11 ssinr_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30

*** Keywords ***
Enable Minrneighborltenrcunsa
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_miNrNeighborLteNrCuNsa.json

Enable In Session Counters And Set Pmqap Profiles
    Configure                   ${DELTA_FILES_PATH}/Pm_counters/delta_nsa_pmqap.yaml
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_insession_counters.json

Enable In Session Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_enable_insession_counters.json

Enable NSA HO
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_NSA_mobility.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_IntraMeNBMobility.json

Perform Abnormal Releases Initiated By Sgnb
    Execute Egate Command    cmd=ue_dc_rlf ue=11 failure_type=scg_reconfig_failure

Add Nr Cappa
    [Arguments]   ${ue_id}
    Execute Egate Command   cmd=ue_param id=${ue_id} ue_nr_capabilities=${UE_NR_CAPA}
    Execute Egate Command   cmd=ue_param id=${ue_id} ue_eutra_nr_capabilities=${UE_EUTRA_NR_CAPA}

Trigger Handover To Second Cell
    [Arguments]   ${ue_id}
    Execute Egate Command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 ${a3_params}

Start Data Traffic For Nsa Ue
    [Arguments]    ${ue_id}    ${bearer}    ${direction}    ${mbps}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} id=${bearer} dir=${direction} mbps=${mbps}

Wait For Normal Ue Release Initiated By MenB
    [Arguments]   ${ue_id}
    Execute Egate Command    cmd=enb_ue_dc_release ue=${ue_id} by=enb cause=RN_user_inactivity

Wait For Abnormal Ue Release Initiated By MenB
    [Arguments]   ${ue_id}
    Execute Egate Command    cmd=enb_ue_dc_release ue=${ue_id} by=enb cause=RN_CauseRadioNetwork_unspecified

Check In Session Status
    [Arguments]    ${status}
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    packet_filter=itf_l2_hi_cu_user_BearerDeleteResp_t.inSession == ${status} && itf_l2_hi_cu_user_BearerDeleteResp_t.drbIdentity == 4

Check Pm Counters For Abnormal Releases Initiated By Sgnb
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNOR_SGNB_NRREL}
    ...    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NX2CC_RAB_REL_ABNRM_SGNB_INSES}
    ...    value=1    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}

Start Dl And Ul Data Traffic And Display Bearer Stats
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=120mbps
    Start Data Traffic  ues=11    bearer_id=2    direction=ul    throughput=120mbps
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2