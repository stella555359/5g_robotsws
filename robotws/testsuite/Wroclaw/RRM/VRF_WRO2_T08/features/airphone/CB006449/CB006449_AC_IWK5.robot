*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310   NoResUsage    RF50

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB006449_Keywords.robot
Resource     ./resources/CB006449_Variables.robot
Library      ./resources/CB006449_Keywords.py
Library      ta5g_pm_counters
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_testline_management
Library      ta5g_delta

Suite Setup    Run Keywords    Custom Setup Testline
...                                iphy=iphy_6449_AB.xml
...                                scfc=IWK5_AC_scfc.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB006449_AA_B3.lua
...                                           mplane_cells=@{mplane_cells}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Config Back


*** Variables ***
@{mplane_cells}=    5    6    9    12
@{swconfig_flags}=    0x9D0001=1    0x9D0002=1    0x9D0006=55139
${ue_id}    1

${FIVE_QI_FILTER_ONE}    f1ap.flows_Mapped_To_DRB_List == 1 && f1ap.fiveQI == 6 && f1ap.qoS_Characteristics == 0 && f1ap.fiveQI == 6
${FIVE_QI_FILTER_TWO}    f1ap.flows_Mapped_To_DRB_List == 1 && f1ap.fiveQI == 1 && f1ap.qoS_Characteristics == 0 && f1ap.fiveQI == 1
${PROFILE_FILTER_ONE}    f1ap.UEContextModificationResponse_element && nr-rrc.milliSeconds == 7
${PROFILE_FILTER_TWO}    f1ap.UEContextModificationResponse_element && nr-rrc.milliSeconds == 5

*** Test Cases ***
USCB006449-AC#IWK5_DRX_profile2_activation_in_FR1_UL_TDD-TDD_CA_mode
    [Documentation]    This user scenario describes the successful configuration of "NRDRX Profile2"
    ...                when the UE is in FR1 TDD-TDD UL CA mode with a VoNR DRB and nonGBR DRBs,
    ...                as well the DRX profile reconfiguration from "NRDRX-Profile2" to "DRX profile1"
    ...                when the VoNR DRB is released.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Set UL CA Capabilties
    ...                           ue_nr_capabilities=UE_UL_CA_CAPA_BC2_BC3_BC4_n41c_n66_BC18_n41_n66_n77_n71
    ...                           ue_id=1

    Enable IMS Voice For AMF
    Modify QoS Flow

    Attach Ue With SgNB And Traffic    ue_id=${ue_id}
    Sleep    5s    reason=Wait for traffic to start

    Assert Dl Traffic On Every Scell    ue_id=${ue_id}    scells_amount=2    traffic=True
    Assert Ul Traffic On Every Scell    ue_id=${ue_id}    scells_amount=1    traffic=True

    Verify Tcpdump Log    packet_filter=${FIVE_QI_FILTER_ONE}
    ...                   number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${PROFILE_FILTER_ONE}
    ...                   number_of_messages=1    relation_symbol= >=

    # Establish VoNR DRB And Start Traffic
    Add QoSFlows To PDU Session

    Start Traffic On New QFIs

    Check Bearer Stats On New QFIs

    # Check if Profile has switched (ms10, ms6, ms10 after release)
    # Check VoNR (6,6; 1,1; 6,6 after release)
    Verify Tcpdump Log    packet_filter=${FIVE_QI_FILTER_TWO}
    ...                   number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${PROFILE_FILTER_TWO}
    ...                   number_of_messages=1    relation_symbol= >=

    # Release VoNR DRB
    Remove Added QoSFlows

    # Check Traffic, check if profile and VoNR switched back
    Assert Dl Traffic On Every Scell    ue_id=${ue_id}    scells_amount=2    traffic=True
    Assert Ul Traffic On Every Scell    ue_id=${ue_id}    scells_amount=1    traffic=True
    Verify Tcpdump Log    packet_filter=${FIVE_QI_FILTER_ONE}
    ...                   number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${PROFILE_FILTER_ONE}
    ...                   number_of_messages=1    relation_symbol= >=

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=1
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Add Scout External Execution ID To Reporting Portal

*** Keywords ***
Enable IMS Voice For AMF
    Execute Egate Command    cmd=amf_param id=1 ims_voice_3gpp=on

Modify QoS Flow
    Execute Egate Command    cmd=qosflow_modify qos_flow=3 priority=1

Set Voice Centric NR Usage For Ue
    Execute Egate Command    cmd=ue_param id=1 nr_usage_setting=voice_centric

Attach Ue With SgNB And Traffic
    [Arguments]    ${ue_id}
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session With Traffic
        ...    ue_id=${ue_id}
        ...    pdu_id=${ue_id}
        ...    nwslice=1
        ...    gw_id=${ue_id}
        ...    direction=both
        ...    throughput=100mbps

Add QoSFlows To PDU Session
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    Sleep    1s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 by=amf

Start Traffic On New QFIs
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl trf_id=1 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=ul trf_id=1 protocol=tcp
    Sleep    5s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=1 protocol=udp
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=1 protocol=udp
    Sleep    5s

Check Bearer Stats On New QFIs
    Assert Bearer Stats    qfi=2    dir=ul    ue_id=1
    Assert Bearer Stats    qfi=2    dir=dl    ue_id=1
    Assert Bearer Stats    qfi=3    dir=ul    ue_id=1
    Assert Bearer Stats    qfi=3    dir=dl    ue_id=1

Remove Added QoSFlows
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2 by=amf validation=off
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=3 by=amf validation=off
