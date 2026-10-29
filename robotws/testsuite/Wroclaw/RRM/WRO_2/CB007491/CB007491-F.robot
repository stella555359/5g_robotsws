*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Resource     keywords_CB007491.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var
Library      ta5g_ue_mobility


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy}
...            AND             Find Scfc And Fix And Send Full Commissioning    ${scf}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval


Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***

${BASIC_SETUP}=       ${CURDIR}/config/wts_config.cfg
${scf}=         CB007491_scf.xml
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${GNB_ID}=      2
${PDU_ID_FDD}=    3
${GW_ID_FDD}=    3
${UE_ID_FDD}=    3
${UE_ID_TDD}=    6
${PDU_ID_TDD}=    6
${GW_ID_TDD}=    6
${CELL_FDD_ID}=  3
${CELL_TDD_ID}=  6
${A1_MEAS_ID}=    1
${iphy}=    ${CURDIR}/config/iphy_booloo.xml
${A6_meas_id}=   2

${LOCAL_MOID_PCELL}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
@{COUNTER_IDs_PCELL_P1}=    M55118C10501    M55138C03507
@{COUNTER_NAMEs_PCELL_P1}=    SCELL_SWAP_1_ATT_SA    GNB_SCELL_5_ADMI_SUCC_SA

${cmd_ue_resume_configuration}=
...  amf_ue_ics_param id=1 ue=${UE_ID_FDD} core_network_assistance_info=on ue_identity_index_value=3
...  ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100

${A6_cmd}=
...  id=${UE_ID_FDD} meas_id=${A6_meas_id} event=A6 srsrp_nr=70 srsrq_nr=70 scell=1 scell_rsrp=20 scell_rsrq=20
...  scell=2 scell_rsrp=20 scell_rsrq=20
...  scell=3 scell_rsrp=20 scell_rsrq=20
...  scell=4 scell_rsrp=20 scell_rsrq=20
...  scell=5 scell_rsrp=20 scell_rsrq=20
...  phycell_id=52 nrsrp_nr=90 nrsrq_nr=95


${train_cmd}=
...  ue_ta_nr profile_id=1
...  nb_reps_ta_sim=3
...  ue_speed=4 ue_p_delay_max=300
...  ue_p_delay_min=288
...  ue_p_delay_initial=290
...  ue_fo_velocity=FO_VELOCITY_APPROACHING_GNB_AT_350KMPH
...  ue_p_symbol_delay_initial=1


*** Test Cases ***
CB007491-F
    Attach UE And Establish PDU Session
    ...    ue_id=${UE_ID_FDD}
    ...    cell_id=${CELL_FDD_ID}
    ...    enb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_FDD}
    ...    gw_id=${GW_ID_FDD}
    Attach UE And Establish PDU Session
    ...    ue_id=${UE_ID_TDD}
    ...    cell_id=${CELL_TDD_ID}
    ...    enb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID_TDD}
    ...    gw_id=${GW_ID_TDD}
    Perfom HST    cmd=${train_cmd}
    Trigger A1 Measurement A6    ue_id=${UE_ID_FDD}    meas_id=${A1_MEAS_ID}
    Trigger A1 Measurement A6    ue_id=${UE_ID_TDD}    meas_id=${A1_MEAS_ID}
    Start Specific Data DL Traffic    ue_id=${UE_ID_FDD}   pdu_id=${PDU_ID_FDD}    last_trf_id=7
    Start Specific Data UL Traffic    ue_id=${UE_ID_FDD}   pdu_id=${PDU_ID_FDD}    first_trf_id=8
    Send Pdu Session Modify And Start VoNR      ue_id=${UE_ID_FDD}   pdu_id=${PDU_ID_FDD}
    Trigger A6 Measurement    A6_cmd=${A6_cmd}
    Perform UE Resume
    ...    UE_ID_6CC=${UE_ID_FDD}
    ...    SOURCE_CELL_ID=${CELL_FDD_ID}
    ...    GNB_ID=${GNB_ID}
    ...    cmd_ue_resume_configuration=${cmd_ue_resume_configuration}
    ...    A1_MEAS_ID=${A1_MEAS_ID}
    Trigger A2 Measurement    ue_id=${UE_ID_FDD}   meas_id=3    SCELL_INDEX=2
    Verify Pm Counters HST
    [Teardown]    Add Scout Data Info To Testcase
