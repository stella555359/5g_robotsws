*** Settings ***
Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Emilia Godlewska-Lipka
...             :contact: emilia.godlewska-lipka@nokia.com

Resource       ../feature_keywords.robot

Suite Setup        Run Keywords
...                Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         Set VM Ethernet Interfaces for Simulated gNB
...    AND         Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}


Suite Teardown     Run Keywords    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SCFC_GNB_MN}=             scf_MN_n66A_n25A_n41C.xml
${SCFC_GNB_SN}=             scf_SN_8CC_n258.xml
${IPHY}=                    ${CURDIR}/config/iphy_CB12328_MN_n66A_n25A_n41C_SN_n258M.xml
${cfg}=                     ${CURDIR}/config/cfg_CB12328_MN_n66A_n25A_n41C_SN_n258M.cfg
${amf_id}=                  1
${ue1}=                     1
${ue2}=                     2
${MN_Cell}=                 1
${REMOTE_HOSTS}=            None
@{COUNTERS_LIST}=           M55116C00074    M55116C00073

*** Test Cases ***
CB012328_X_VONR_Call_Setup_While_UE_Is_In_NRDC_And_Check_Mobility_Meas_After_VoNR_Release
    [Setup]    Run Keywords     Start Default Logging And Mark New Test
    Verify If Counters Were Not Incremented On MN GNB Before Test
    Wait For Next Full Pm Interval
    Set Traffic Params For UE1
    Add Aditional QoS Flow To Activate     ue_id=${ue1}     qosflows_to_act=3
    Attach Ue    ue_id=${ue1}
    Wait 2s For The Environment To Stabilize
    Establish PDU Session    ue_id=${ue1}    pdu_id=2    gw_id=3    nwslice=2
    Reset SMF
    Establish PDU Session    ue_id=${ue1}    pdu_id=1    gw_id=1
    Start Data Traffic For All PDUs For UE1
    Modify Pdu Session       ue_id=${ue1}  pdu_id=2    qos_to_del=2
    Wait 15s For The Environment To Stabilize

    Start Tcpdump On Remote Interface     log_dirpath=${OUTPUT_DIR}/tshark/sn_add_flow  alias=sn_add_flow
    Wait 3s For The Environment To Stabilize
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=13    phycell_id=61    nrsrp_nr=60     event=A4
    Verify Secondary Node Addition Flow
    Stop Tcpdump On Remote Interface
    Wait 3s For The Environment To Stabilize
    Start Tcpdump On Remote Interface    log_dirpath=${OUTPUT_DIR}/tshark/vonr_sn_takeback  alias=vonr_sn_takeback
    Wait 3s For The Environment To Stabilize
    Modify Pdu Session       ue_id=${ue1}    pdu_id=2    qos_to_add=2
    Verify NR-DC Takeback Procedure and VoNR QoS Flow Establish
    Stop Tcpdump On Remote Interface

    Wait 2s For The Environment To Stabilize
    Modify Pdu Session       ue_id=${ue1}  pdu_id=2    qos_to_del=2
    Wait 2s For The Environment To Stabilize
    Verify RRC MeasConfig Events
    Reset SMF

    ${pm_counter_file_after_test}=    Get Next Unpacked Raw Pm Counters File
    Set Suite Variable    ${pm_counter_file_after_test}
    Verify That New Counters Are Incremented After Test On MN Side

   [Teardown]    Run Keywords       Deregister UE    ue_id=${ue1}
    ...          AND                Add Scout Scf Id To Test Data
    ...          AND                Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

