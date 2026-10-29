*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ    CRT    SBTS24R3    PY39
...           CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    SBTS24R2    RAN_5G    RAN_5G_TDD    NoResUsage

Documentation    :copyright: Nokia
...              :authors: zhifuxu
...              :contact: zhifu.xu@nokia-sbell.com
...              Trigger ICS With Trace Start ：trace start IE on ICS
...              Start Subscriber Trace: will have special "NGAP trace start" message


Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource    CB007321_Keywords_And_Variables.robot
Library     CB007321.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Log_Collection.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Parameter_Operation.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/BTS_Operation.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${RESULT_DIR}/Suite_Setup_Logs
...            AND             Add Preferences To Wireshark Config
...            AND             Start Xn And Ng Interfaces
...            AND             Start Server Interface
...            AND             Stop Default Logging    output_dirpath=${RESULT_DIR}/Suite_Setup_Logs
...            AND             Common Suite Setup For RRM


Suite Teardown    Run Keywords    Clear Changes In Number Of Sa Ue In Lua
...                               lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
...               AND             Teardown PCMD

*** Test Cases ***
CB007321-A_B01-Streaming_E1_F1_from_gNB-CU-CP_in_MBA_Cell_Trace_session_for_SA_UE
    [Tags]    QC_32422     QCD_MN_RAN      QCP_RAN_ST    TCE1
    [Documentation]     This test case checks reporting of SA UE call associated E1AP and F1AP control plane messages
    ...                 in a MBA cell trace session activated in gNB-CU-CP.
    ...                5G_RAN_USR_COM_21679;5G_TC_2425;5G_TC_2468;5G_TC_2466;5G_TC_2465;5G_TC_2464;5G_TC_2463;
    ...               5G_TC_2462;5G_TC_2459;5G_TC_2458;5G_TC_2456;5G_TC_2453;5G_TC_2434;5G_TC_2444;5G_TC_2431;
    ...               5G_TC_2529;5G_TC_2440;5G_TC_2438;5G_TC_2448;5G_TC_2447;5G_TC_2445;
    ...                OM_GEN_SFS_TRACEMGMNT.4652
    ...                 author: zhifu Xu
    ...                 contact: zhifu.xu@nokia-sbell.com

    [Setup]    Run Keywords    Update Number Of Sa Ue In Lua   lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Reach OnAir    lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Start Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${RESULT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7321_on_MBA_True.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD

    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Parameter update for VONR
    wait until keyword succeeds   15min  30s    Verify All Cells Onair
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_7321_NIA_NEA.json
    Parameter update for NIA and NEA
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    ta5g_ue_mobility.Attach Ue    ue_id=2
    Establish Pdu Session With Traffic    ue_id=2    pdu_id=2    gw_id=2
    sleep    10s
    Deregister Ue    ue_id=2
    Verify Tcp Messages    packet_filter=${RRC_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${RRC_SETUP} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${NGAP_INITIAL_UE_MESSAGE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${DOWNLINK_INFORMATION_TRANSFER} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...    relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_DOWNLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...     relation_symbol= >=
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    ...     relation_symbol= >=
    Verify Tcp Messages
    ...    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages
    ...    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages
    ...    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
    Verify Tcp Messages
    ...    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
#    Verify Tcp Messages    packet_filter=${F1AP_UE_CONTEXT_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
#    Verify Tcp Messages    packet_filter=${F1AP_UE_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
#    Verify Tcp Messages    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}
#    Verify Tcp Messages    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}

    [Teardown]    Run Keywords    Teardown PCMD
    ...           AND             Stop Wireshark log
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${RESULT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7321_on_MBA_True.json
    ...           AND             Stop Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...           AND             Clear Changes In Number Of Sa Ue In Lua
    ...        lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Get SCF Internal Id By Scout    no_ute=False


CB007321-A_B02_Streaming_UE_E1-F1-messages_from_gNB-CU-CP_in_SBA_Trace_session
    [Tags]    QC_32421     QCD_MN_RAN      QCP_RAN_ST
    [Documentation]     This test scenario describes reporting of UE associated E1AP and F1AP control plane messages
    ...                in a SBA trace session (Subscriber Equipment Trace) activated in gNB-CU-CP via NGAP:Initial
    ...                Context Setup Request. Following messages are covered in this test case
    ...                5G_RAN_USR_COM_21680;5G_TC_2425, 5G_TC_2468, 5G_TC_2466, 5G_TC_2465, 5G_TC_2464, 5G_TC_2463,
    ...                5G_TC_2462, 5G_TC_2459, 5G_TC_2458, 5G_TC_2456, 5G_TC_2453, 5G_TC_2434, 5G_TC_2444, 5G_TC_2431,
    ...                5G_TC_2529, 5G_TC_2440, 5G_TC_2438, 5G_TC_2448, 5G_TC_2447, 5G_TC_2445
    ...                OM_GEN_SFS_TRACEMGMNT.4653
    ...                 author: zhifu Xu
    ...                 contact: zhifu.xu@nokia-sbell.com

    [Setup]    Run Keywords    Update Number Of Sa Ue In Lua   lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Reach OnAir    lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Start Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${RESULT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning
    ...    scfc_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Parameter update for VONR
    wait until keyword succeeds   15min  30s    Verify All Cells Onair
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_7321_NIA_NEA.json
    Parameter update for NIA and NEA
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    Trigger ICS With Trace Start    ue_id=2    tce_ip=10.0.1.1
    ta5g_ue_mobility.Attach Ue    ue_id=2
    Establish Pdu Session With Traffic    ue_id=2    pdu_id=2    gw_id=2
    Start Subscriber Trace    ue_id=2
    Deregister Ue    ue_id=2
    Verify Ngap Messages    packet_filter=${ICS_WITH_TRACE_ACTIVATION}
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages
    ...    packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Stop Subscriber Trace    ue_id=2
    ...           AND             Stop Wireshark log
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${RESULT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...           AND             Stop Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...           AND             Clear Changes In Number Of Sa Ue In Lua
    ...          lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB007321-A-7732-Streaming_UE_E1-F1_from_gNB-CU-CP_in_SBA_Trace_session
    [Tags]    QC_32423     QCD_MN_RAN      QCP_RAN_ST
    [Documentation]     This test scenario describes reporting of UE associated E1AP and F1AP control plane messages in
    ...                a SBA trace session (Subscriber Equipment Trace) activated in gNB-CU-CP via CB007732-5G-A-B0107 -
    ...                Activation of the Subscriber Trace content via feature flag in case of active UE.
    ...                5G_RAN_USR_COM_21680;
    ...                5G_TC_2467;5G_TC_2461;5G_TC_2458;5G_TC_2442;5G_TC_2449;5G_TC_2460
    ...                 author: zhifu Xu
    ...                 contact: zhifu.xu@nokia-sbell.com
    [Setup]    Run Keywords    Update Number Of Sa Ue In Lua   lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Reach OnAir    lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Start Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${RESULT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning
    ...    scfc_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Parameter update for VONR
    wait until keyword succeeds   15min  30s    Verify All Cells Onair
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_7321_NIA_NEA.json
    Parameter update for NIA and NEA
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    ta5g_ue_mobility.Attach Ue    ue_id=3
    Establish Pdu Session With Traffic    ue_id=3    pdu_id=3    gw_id=3
    Start Subscriber Trace   ue_id=3
    Deregister Ue    ue_id=3
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${NSETAPX_START_RECORDING_SESSION} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_TRACE_START} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UPLINK_NAS_TRANSPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NSETAPX_STOP_RECORDING_SESSION} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Stop Subscriber Trace    ue_id=3
    ...           AND             Stop Wireshark log
    ...           AND             Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=3
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${RESULT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_on_applyDefNrTceForAllSessions_true.json
    ...           AND             Stop Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...           AND             Clear Changes In Number Of Sa Ue In Lua
    ...    lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs
    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB007321-B_B01_Streaming_UE_associated_ControlPlane_Private_F1AP_messages_BUFFER_CRITERION_NOTIFICATION_in_MBA_Cell_Trace_session_for_SA_UE_calls
    [Tags]    QC_xxx     QCD_MN_RAN      QCP_RAN_ST
    [Documentation]     This test scenario describes reporting of UE associated E1AP and F1AP control plane messages in
    ...                a SBA trace session (Subscriber Equipment Trace) activated in gNB-CU-CP
    ...                5G_RAN_USR_COM_21680;
    ...                5G_TC_2467;5G_TC_2461;5G_TC_2458;5G_TC_2442;5G_TC_2449;5G_TC_2460
    ...                 author: zhifu Xu
    ...                 contact: zhifu.xu@nokia-sbell.com
    [Setup]    Run Keywords    Update Number Of Sa Ue In Lua   lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Reach OnAir    lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Start Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${RESULT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7321_CA_MBA.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Parameter update for VONR
    wait until keyword succeeds   15min  30s    Verify All Cells Onair
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_7321_NIA_NEA.json
    Parameter update for NIA and NEA
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    #Airphone Attach    ue_id=3    call_type=SA    pdu_id=3
    Ue Attch For 7321    ue_id=3    pdu_id=3    gw_id=3
    Send Throuput    ue_id=3    pdu_id=3
    sleep    10s
    Stop Throuput    ue_id=3    pdu_id=3
    sleep    10s
    Verify Tcp Messages    packet_filter=${RRC_SETUP_REQUEST} && ${NSETAPX_PROTOCOL} && ${NSETAPX_MBA}

    [Teardown]    Run Keywords    Stop Subscriber Trace    ue_id=3
    ...           AND             Stop Wireshark log
    ...           AND             Teardown PCMD
    ...           AND             Deregister Ue Without Confirmation    ue_id=3
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${RESULT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7321_CA_MBA.json
    ...           AND             Stop Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...           AND             Clear Changes In Number Of Sa Ue In Lua
    ...    lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

CB007321-A-Monitoring_of_Cell_trace_for_E1_and_F1_UeContextModification
    [Tags]    QC_xxx     QCD_MN_RAN      QCP_RAN_ST
    [Documentation]    This test scenario describes reporting of SA or NSA UE associated E1AP and F1AP control plane
    ...               messages in a MBA cell trace session activated in gNB-CU-CP. Following messages will be checked
    ...               in this test case:
    ...               UE CONTEXT MODIFICATION CONFIRM
    ...               UE CONTEXT MODIFICATION REFUSE
    ...               UE CONTEXT MODIFICATION REQUIRED
    ...               [1] 5G_RAN_USR_COM_21879;[2] 5G_TC_2443, 5G_TC_2441, 5G_TC_2439
    ...                author: ZhiFu xu
    ...                contact: zhifu.xu@nokia-sbell.com

    [Setup]    Run Keywords    Update Number Of Sa Ue In Lua   lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Reach OnAir    lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...        AND             Start Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...        AND             Get Scfc File    output_filepath=${RESULT_DIR}/initial_commissioning.xml
    ...        AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7732_0501.json
    ...        AND             Start Tcp Pcap
    ...        AND             Setup PCMD
    wait until keyword succeeds    3 min    10 sec    Airphone Verify bts status
    Parameter update for VONR
    wait until keyword succeeds   15min  30s    Verify All Cells Onair
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_7321_NIA_NEA.json
    Parameter update for NIA and NEA
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    Wait Until Keyword Succeeds    2x  100ms    ta5g_ue_mobility.Attach Ue    ue_id=9
    Establish Pdu Session With Traffic    ue_id=9    pdu_id=9    gw_id=9
    Start Subscriber Trace    ue_id=9
    Send Custom UE Measurement NR    event=A3  id=9  meas_id=1  phycell_id=51  nrsrp_nr=40  srsrp_nr=30
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...                              timeout=7
    Deregister Ue Without Confirmation    ue_id=9
    Verify Ngap Messages    packet_filter=${NGAP_TRACE_START}
    Verify Tcp Messages    packet_filter=${RRC_RECONFIGURATION} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}
    Verify Tcp Messages    packet_filter=${RRC_MEASUREMENT_REPORT} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA}

    [Teardown]    Run Keywords    Stop Subscriber Trace    ue_id=9
    ...           AND             Stop Wireshark log
    ...           AND             Teardown PCMD
    ...           AND             Stop Tcp Pcap
    ...           AND             Roll Delta Back
    ...                           initial_scf_filename=${RESULT_DIR}/initial_commissioning.xml
    ...                           delta_scf_filename=delta_7732_0501.json
    ...           AND             Stop Default Logging    output_dirpath=${RESULT_DIR}/${TEST_NAME}
    ...           AND             Clear Changes In Number Of Sa Ue In Lua
    ...                           lua_cfg=${CURDIR}/resources/egate_2c_tdd_2c_fdd_sansa.lua
    ...           AND             Stop Default Processes And Gather Logs And Compress Logs

*** Keywords ***
Start Collect Btslog
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}

Stop and Collect Btslog
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${0}
    Log To Console    \nSyslog log: ${local_file_path}

Parameter update for cipherPrefL
    &{staged_dict}    create dictionary   nea0=${9}  nea1_128=${1}   nea2_128=${1}   nea3_128=${1}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}
    @{para_list}      Create List   cipherPrefL
    @{mo_list}        Create List   MRBTS-1/NRBTS-1
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                    para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Parameter update for integrityProtPrefL
    &{staged_dict}    create dictionary   nia0=${9}  nia1_128=${1}   nia2_128=${1}   nia3_128=${1}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}
    @{para_list}      Create List   integrityProtPrefL
    @{mo_list}        Create List   MRBTS-1/NRBTS-1
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                    para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Verify All Cells Onair
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR

Full Commission SCF
    [Arguments]    ${path_of_commission_file}
    ${out}   Parameter Operation    operation=full_commission   product_type=gnb   scf_path=${path_of_commission_file}
    Log To Console    full commission result: ${out}
    wait until keyword succeeds   15min  30s    Verify All Cells Onair

Parameter update for VONR
    @{para_list}      Create List    actVoNR    actVoNR    actVoNR    actVoNR
    @{value_list}     Create List    true    true    true    true
    @{mo_list}        Create List    MRBTS-1/NRBTS-1/NRCELL-1    MRBTS-1/NRBTS-1/NRCELL-2
    ...                             MRBTS-1/NRBTS-1/NRCELL-3    MRBTS-1/NRBTS-1/NRCELL-4
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                     para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
   Log To Console     paramter update result: ${out}

Parameter update for NIA and NEA
    sleep    60s
    Parameter update for cipherPrefL
    wait until keyword succeeds   15min  30s    Verify All Cells Onair
    sleep    60s
    Parameter update for integrityProtPrefL
    wait until keyword succeeds   15min  30s    Verify All Cells Onair

Stop Wireshark log
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
