*** Settings ***
Documentation    Suite description

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/Emil_processing_keywords.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.py  WITH NAME  messg
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.py

*** Variables ***
${Emil_keywords}=    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/Emil_processing_keywords.py
${tes_emil}=         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/2640_emil.robot
${tes_emil_2}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/2640_emil_AC.robot

*** Keywords ***
Set initial attenuation for 8140-JA
    Log to Console    Attenuation set
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0

Set initial attenuation for 8140-CD
    Log to Console    Attenuation set
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AHLOA_1}    value=0
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}     value=0
    Sleep  3s
    Log to Console  >Attenuators have been set for 8140-CD.<

Perform SCell Release for 8140-CD
    Set attenuation for 8533-AB11-1x-interGNB and check_2     lines=@{lines_gNB_186_AEHC_1}    value=20
    Sleep  2s
    Set attenuation for 8533-AB11-1x-interGNB and check_2     lines=@{lines_gNB_186_AEHC_1}     value=30
    Sleep  2s
    Set attenuation for 8533-AB11-1x-interGNB and check_2     lines=@{lines_gNB_186_AEHC_1}     value=40
    Sleep  2s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=@{lines_gNB_186_AEHC_1}     value=50
    Sleep  2s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=@{lines_gNB_186_AEHC_1}     value=60
    Log to Console  >SCell has been released.<
    Sleep    15s

Verify PM Counters 8140-CD
    Sleep  150s
    log to console      Verify PM counters values
    ${counters}                 Read Counters Value 8140-CD
    ${A2MEAS_REL1DLSCELL_ATT_SA}    Get Counter Value From Single Cell      ${counters}     1    M55118C06501
    ${A2MEAS_REL1DLSCELL_SUCC_SA}   Get Counter Value From Single Cell      ${counters}     1    M55118C06502
    ${NRRCC_RRC_RECONF_SENT}        Get Counter Value From Single Cell      ${counters}     1    M55124C03001
    ${NRRCC_RRC_RECONF_CMP_RECD}    Get Counter Value From Single Cell      ${counters}     1    M55124C03002
    ${UE_PCELL_2_CONF_SCELL_DL_SA}  Get Counter Value From Single Cell      ${counters}     1    M55118C07001
    ${UE_PCELL_3_CONF_SCELL_DL_SA}  Get Counter Value From Single Cell      ${counters}     1    M55118C09501
    Should Be True      1<=${A2MEAS_REL1DLSCELL_ATT_SA}
    Should Be True      1<=${A2MEAS_REL1DLSCELL_SUCC_SA}
    Should Be True      1<=${NRRCC_RRC_RECONF_SENT}
    Should Be True      1<=${UE_PCELL_2_CONF_SCELL_DL_SA}
    Should Be True      1<=${UE_PCELL_3_CONF_SCELL_DL_SA}

Read counters value 8140-CD
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list  M55118C06501  M55118C06502  M55124C03001  M55124C03002  M55118C07001  M55118C09501
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify CSV file from DCAP
    [Arguments]    ${expected_messages}=${messages_8140}
    ${CSV_verification}  messg.check_messages_in_csv  exp_mesgs=${expected_messages}  path=${OUTPUT_DIR}/DCAPs/${test_name}.csv
    Should be true    ${CSV_verification}

Verify PM Counters 8140-CB
    [Arguments]  ${cell}=1
    Log to console   Waiting for counters to appear, please wait...
    Sleep   300s
    ${counters}                         Read Counters Values 8140-CB
    ${NR_RLC_PDU_DL_VOL_CA_PCELL}       Get Counter Value From Single Cell        ${counters}     ${cell}    M55310C20001
    ${PSCELL_UE_3_ACT_SCELL_DL}         Get Counter Value From Single Cell        ${counters}     ${cell}    M55316C03003
    ${MAX_PSCELL_UE_3_ACT_SCELL_DL}     Get Counter Value From Single Cell        ${counters}     ${cell}    M55316C05003
    ${IGNB_CA_ATT_SA_REL}               Get Counter Value From Single Cell        ${counters}     ${cell}    M55118C11008
    Should Be True   1<=${NR_RLC_PDU_DL_VOL_CA_PCELL}
    Should Be True   1<=${PSCELL_UE_3_ACT_SCELL_DL}
    Should Be True   1<=${MAX_PSCELL_UE_3_ACT_SCELL_DL}
    Should Be True   1<=${IGNB_CA_ATT_SA_REL}

Verify PM Counter 8140-CB External GNB
    log to console    Verify PM counter values External GNB
    ${counters}       Read Counter Value 8140-CB Ext
    ${IGNB_CA_ADD_REQ_SA_ADJ}            Verify 8140 BTS counter                 ${counters}    M55199C00001    260
    ${IGNB_SCELL_ADMI_REQ_SA1}           Get Counter Value From Single Cell       ${counters}     1    M55138C03501
    ${IGNB_SCELL_ADMI_REQ_SA4}           Get Counter Value From Single Cell       ${counters}     4    M55138C03501
    ${IGNB_SCELL_ADMI_REQ_SA14}          Get Counter Value From Single Cell       ${counters}     14   M55138C03501
    ${IGNB_SCELL_ADMI_SUCC_SA1}          Get Counter Value From Single Cell        ${counters}    1    M55138C03502
    ${IGNB_SCELL_ADMI_SUCC_SA4}          Get Counter Value From Single Cell        ${counters}    4    M55138C03502
    ${IGNB_SCELL_ADMI_SUCC_SA14}         Get Counter Value From Single Cell        ${counters}    14   M55138C03502
    Should Be True      1<=${IGNB_CA_ADD_REQ_SA_ADJ}
    Should Be True      1<=${IGNB_SCELL_ADMI_REQ_SA1}
    Should Be True      1<=${IGNB_SCELL_ADMI_REQ_SA4}
    Should Be True      1<=${IGNB_SCELL_ADMI_REQ_SA14}
    Should Be True      1<=${IGNB_SCELL_ADMI_SUCC_SA1}
    Should Be True      1<=${IGNB_SCELL_ADMI_SUCC_SA4}
    Should Be True      1<=${IGNB_SCELL_ADMI_SUCC_SA14}

Read Counters Values 8140-CB
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list    M55310C20001    M55316C03003    M55316C05003    M55118C11008
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read Counter Value 8140-CB Ext
    ${counters_values}=   Create List
    Collect counters ext gnb   n_last=8
    ${stream_name}=     Get stream name
    @{counters}=    Create list  M55199C00001    M55138C03501    M55138C03502
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Set attenuation for CA first gNB
    Log to Console    >Attenuation set to 0dB for RMODs: 1-AHLOA, 4,5-AEHC, 8-AHFIB Others: -90dB.<
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Sleep  3s
    Log to Console  >Attenuators have been set for first gNB.<

Set attenuation for CA second gNB
    Set attenuation for 8533-AB11-1x-interGNB and check_2   lines=${lines_gNB_186_AHLOA_1}    value=0
    Sleep  3s
    Set attenuation for 8533-AB11-1x-interGNB and check_2    lines=${lines_gNB_186_AEHC_1}    value=0
    Sleep  3s
    Log to Console  >Attenuators have been set for second gNB.<

Verify additional msgs drb 8140
    ${CSV_verification}  messg.check_drb_messages_in_csv  exp_mesgs=${messages_8140_CB}  path=${OUTPUT_DIR}/DCAPs/${test_name}.csv
    Should be true    ${CSV_verification}

Prepare and start delay with RUDE tool
    [Arguments]    ${delay}=4000
    Connect to RUDE
    Initialize RUDE
    Sleep  10s
    Reset rule on RUDE
    Start rule on RUDE
    Set delay on RUDE    delay_value=${delay}

Verify PM Counter 8140-CF
    log to console      Verify PM counters values
    Sleep               150s
    ${counters}                 Read Counters Value 8140-CF
    ${IGNB_SCELL_DEACT_XPU_LNK_UUSBL}    Get Counter Value From Single Cell      ${counters}     1    M55316C15003
    Should Be True      1<=${IGNB_SCELL_DEACT_XPU_LNK_UUSBL}

Read counters value 8140-CF
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list  M55316C15003
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8140-FA Prime GNB
    log to console    Verify PM counters values Prime GNB
    Sleep             300s
    ${counters}       Read Counters Value 8140-FA
    ${GNB_DU_SCELL_3_ADMI_REQ_SA}     Get Counter Value From Single Cell      ${counters}     1    M55139C03001
    ${IGNB_CA_ATT_3_SCELL_SA}         Get Counter Value From Single Cell      ${counters}     1    M55118C11003
    ${IGNB_CA_ATT_1_SCELL_SA_SUCC}    Get Counter Value From Single Cell      ${counters}     1    M55118C11004
    ${GNB_DU_SCELL_1_ADMI_SUCC_SA}    Get Counter Value From Single Cell      ${counters}     1    M55139C01004
    Should Be True      1<=${GNB_DU_SCELL_3_ADMI_REQ_SA}
    Should Be True      1<=${IGNB_CA_ATT_3_SCELL_SA}
    Should Be True      1<=${IGNB_CA_ATT_1_SCELL_SA_SUCC}
    Should Be True      1<=${GNB_DU_SCELL_1_ADMI_SUCC_SA}

Read Counters Value 8140-FA
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list  M55139C03001    M55118C11003    M55118C11004    M55139C01004
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8140-FA External GNB
    [Arguments]       ${hostname}=10.44.137.49
    log to console    Verify PM counters values External GNB
    ${counters}       Read Counters Value 8140-FA Ext    ${hostname}
    ${stream_name}=     Get stream name
    ${IGNB_CA_ADD_REQ_SA_NRADJ}=         Verify 8140 BTS counter                 ${counters}     M55199C00001    260
    ${IGNB_CA_SCELL_ADMI_REQ_SA}         Get Counter Value From Single Cell      ${counters}     1      M55138C03501
    ${IGNB_CA_SCELL_ADMI_SUCC_SA}        Get Counter Value From Single Cell      ${counters}     1      M55138C03502
    ${GNB_DU_SCELL_ADMI_REQ_SA}          Get Counter Value From Single Cell      ${counters}     1      M55139C01001
    ${GNB_DU_SCELL_ADMI_SUCC_SA}         Get Counter Value From Single Cell      ${counters}     1      M55139C01002
    ${IGNB_CA_SCELL_ADMI_REQ_SA}         Get Counter Value From Single Cell      ${counters}     4      M55138C03501
    ${IGNB_CA_SCELL_ADMI_UNSUCC_SA}      Get Counter Value From Single Cell      ${counters}     4      M55138C03503
    ${IGNB_CA_SCELL_ADMI_REQ_SA_14}      Get Counter Value From Single Cell      ${counters}     14     M55138C03501
    ${IGNB_CA_SCELL_ADMI_UNSUCC_SA_14}   Get Counter Value From Single Cell      ${counters}     14     M55138C03503
    Should Be True      1<=${IGNB_CA_ADD_REQ_SA_NRADJ}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_REQ_SA}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_SCELL_ADMI_REQ_SA}
    Should Be True      1<=${GNB_DU_SCELL_ADMI_SUCC_SA}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_REQ_SA}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_UNSUCC_SA}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_REQ_SA_14}
    Should Be True      1<=${IGNB_CA_SCELL_ADMI_UNSUCC_SA_14}

Read Counters Value 8140-FA Ext
    [Arguments]       ${hostname}
    ${counters_values}=   Create List
    Collect counters ext gnb    8     ${hostname}
    ${stream_name}=     Get stream name
    @{counters}=    Create list    M55199C00001  M55138C03501  M55138C03502  M55139C01001  M55139C01002
    ...    M55138C03501    M55138C03503
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8140-JA Prime GNB
    log to console    Verify PM counters values Prime GNB
    Sleep             300s
    ${counters}       Read Counters Value 8140-JA
    ${F1_DU_P_RESET_RCV}             Verify 8140 BTS counter     ${counters}      M55117C01512           1
    ${F1_DU_P_RESET_ACK_SENT}        Verify 8140 BTS counter     ${counters}      M55117C01513           1
    ${E1_RESET_SENT_CUCP}            Verify 8140 BTS counter     ${counters}      M55121C00501           50857
    ${E1_RESET_ACK_RECD_CUCP}        Verify 8140 BTS counter     ${counters}      M55121C00502           50857
    ${XN_RESET_REQUEST_SENT}         Verify 8140 BTS counter     ${counters}      M55126C00012           50857
    ${XN_RESET_RESPONSE_RECEIVED}    Verify 8140 BTS counter     ${counters}      M55126C00013           50857
    Should Be True      2<=${F1_DU_P_RESET_RCV}
    Should Be True      2<=${F1_DU_P_RESET_ACK_SENT}
    Should Be True      2<=${E1_RESET_SENT_CUCP}
    Should Be True      2<=${E1_RESET_ACK_RECD_CUCP}
    Should Be True      2<=${XN_RESET_REQUEST_SENT}
    Should Be True      2<=${XN_RESET_RESPONSE_RECEIVED}

Read Counters Value 8140-JA
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list  M55117C01512    M55117C01513    M55121C00501    M55121C00502    M55126C00012
    ...                        M55126C00013
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM counters 8140-JA ext gnb
    [Arguments]       ${hostname}=10.44.137.49
    log to console    Verify PM counters values External GNB
    ${counters}       Read Counters Value 8140-JA Ext    ${hostname}
    ${F1_DU_P_RESET_RCV}            Verify 8140 BTS counter    ${counters}    M55117C01512    1
    ${F1_DU_P_RESET_ACK_SENT}       Verify 8140 BTS counter    ${counters}    M55117C01513    1
    ${XN_RESET_REQUEST_RECEIVED}    Verify 8140 BTS counter    ${counters}    M55126C00010    51004
    ${XN_RESET_RESPONSE_SENT}       Verify 8140 BTS counter    ${counters}    M55126C00011    51004
    Should Be True      1<=${F1_DU_P_RESET_RCV}
    Should Be True      1<=${F1_DU_P_RESET_ACK_SENT}
    Should Be True      1<=${XN_RESET_REQUEST_RECEIVED}
    Should Be True      1<=${XN_RESET_RESPONSE_SENT}


Read Counters Value 8140-JA Ext
    [Arguments]    ${hostname}
    ${counters_values}=   Create List
    Collect counters ext gnb    8     ${hostname}
    @{counters}   Create list    M55117C01512  M55117C01513  M55126C00010  M55126C00011
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Start Tshark UDP monitoring
    [Arguments]  ${filename}=test.pcap
    ...          ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=ASIK
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}
    Wait until keyword succeeds    5 min    1 min
    ...    ssh.send_command    command=dbgrrc mirror sport 4 dport 2 e b && dbgrrc mirror sport 5 dport 2 e b  connection=${alias}
    Wait until keyword succeeds    5 min    1 min
    ...    ssh.send_command    command=tcpdump -i etha01 udp port 32742 -w ${filename}   connection=${alias}
    sleep  3s

Verify PM Counters 8140-JD Prime GNB
    log to console    Verify PM counters values Prime GNB
    Sleep             300s
    ${counters}       Read Counters Value 8140-JD
    ${XN_RESET_REQUEST_SENT}             Verify 8140 BTS counter     ${counters}      M55126C00012           50857
    ${XN_RESET_RESPONSE_RECEIVED}        Verify 8140 BTS counter     ${counters}      M55126C00013           50857
    ${XN_SHUTDOWN_LOCKED}                Verify 8140 BTS counter     ${counters}      M55126C00008           50857
    ${F1_DU_P_RESET_RCV}                 Verify 8140 BTS counter     ${counters}      M55117C01512           1
    ${F1_DU_P_RESET_ACK_SENT}            Verify 8140 BTS counter     ${counters}      M55117C01513           1
    ${E1_RESET_SENT_CUCP}                Verify 8140 BTS counter     ${counters}      M55121C00501           50857
    ${E1_RESET_ACK_RECD_CUCP}            Verify 8140 BTS counter     ${counters}      M55121C00502           50857
    ${NG_CU_RESET_REQ_SENT}              Verify 8140 BTS counter     ${counters}      M55119C00011           50857
    ${NG_CU_RESET_ACK_RCV}               Verify 8140 BTS counter     ${counters}      M55119C00014           50857
    Should Be True      1<=${XN_RESET_REQUEST_SENT}
    Should Be True      1<=${XN_RESET_RESPONSE_RECEIVED}
    Should Be True      1<=${XN_SHUTDOWN_LOCKED}
    Should Be True      1<=${F1_DU_P_RESET_RCV}
    Should Be True      1<=${F1_DU_P_RESET_ACK_SENT}
    Should Be True      1<=${E1_RESET_SENT_CUCP}
    Should Be True      1<=${E1_RESET_ACK_RECD_CUCP}
    Should Be True      1<=${NG_CU_RESET_REQ_SENT}
    Should Be True      1<=${NG_CU_RESET_ACK_RCV}

Read Counters Value 8140-JD
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list    M55126C00012    M55126C00013    M55126C00008    M55117C01512
    ...          M55117C01513    M55121C00501    M55121C00502    M55119C00011    M55119C00014
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM counters 8140-JD ext gnb
    [Arguments]       ${hostname}=10.44.137.49
    log to console    Verify PM counters values External GNB
    ${counters}       Read Counters Value 8140-JD Ext    ${hostname}
    ${XN_RESET_REQUEST_RECEIVED}         Verify 8140 BTS counter    ${counters}    M55126C00010    51004
    ${XN_RESET_RESPONSE_SENT}            Verify 8140 BTS counter    ${counters}    M55126C00011    51004
    ${XN_SHUTDOWN_DETECTED}              Verify 8140 BTS counter    ${counters}    M55126C00002    51004
    ${F1_DU_P_RESET_RCV}                 Verify 8140 BTS counter    ${counters}    M55117C01512    1
    ${F1_DU_P_RESET_ACK_SENT}            Verify 8140 BTS counter    ${counters}    M55117C01513    1
    ${E1_RESET_SENT_CUCP}                Verify 8140 BTS counter    ${counters}    M55121C00501    51004
    ${E1_RESET_ACK_RECD_CUCP}            Verify 8140 BTS counter    ${counters}    M55121C00502    51004
    ${NG_CU_RESET_REQ_SENT}              Verify 8140 BTS counter    ${counters}    M55119C00011    51004
    ${NG_CU_RESET_ACK_RCV}               Verify 8140 BTS counter    ${counters}    M55119C00014    51004
    Should Be True      1<=${XN_RESET_REQUEST_RECEIVED}
    Should Be True      1<=${XN_RESET_RESPONSE_SENT}
    Should Be True      1<=${XN_SHUTDOWN_DETECTED}
    Should Be True      1<=${F1_DU_P_RESET_RCV}
    Should Be True      1<=${F1_DU_P_RESET_ACK_SENT}
    Should Be True      1<=${E1_RESET_SENT_CUCP}
    Should Be True      1<=${E1_RESET_ACK_RECD_CUCP}
    Should Be True      1<=${NG_CU_RESET_REQ_SENT}
    Should Be True      1<=${NG_CU_RESET_ACK_RCV}

Read Counters Value 8140-JD Ext
    [Arguments]    ${hostname}
    ${counters_values}=   Create List
    Collect counters ext gnb     8       ${hostname}
    @{counters}   Create list    M55126C00010    M55126C00011    M55126C00002    M55117C01512
    ...          M55117C01513    M55121C00501    M55121C00502    M55119C00011    M55119C00014
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 8140-JF Prime GNB
    log to console    Verify PM counters values Prime GNB
    Sleep             240s
    ${counters}       Read Counters Value 8140-JF
    ${DL_RLC_VOL_TX_SEC_QOS_GRP_03}        Verify 8140 BTS counter      ${counters}    M55311C44003     1
    ${DL_RLC_VOL_TX_SEC_QOS_GRP_17}        Verify 8140 BTS counter      ${counters}    M55311C44017     1
    ${DL_RLC_PDU_TX_SEC_QOS_GRP_03}        Verify 8140 BTS counter      ${counters}    M55311C45003     1
    ${DL_RLC_PDU_TX_SEC_QOS_GRP_17}        Verify 8140 BTS counter      ${counters}    M55311C45017     1
    Should Be True      1<=${DL_RLC_VOL_TX_SEC_QOS_GRP_03}
    Should Be True      1<=${DL_RLC_VOL_TX_SEC_QOS_GRP_17}
    Should Be True      1<=${DL_RLC_PDU_TX_SEC_QOS_GRP_03}
    Should Be True      1<=${DL_RLC_PDU_TX_SEC_QOS_GRP_17}

Read Counters Value 8140-JF
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list    M55311C44003    M55311C44017    M55311C45003    M55311C45017
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM counters 8140-JF ext gnb
    [Arguments]       ${hostname}=10.44.137.49
    log to console    Verify PM counters values External GNB
    ${counters}       Read Counters Value 8140-JF Ext    ${hostname}
    ${NR_RLC_PDU_DL_VOL_CA_SCELL1}       Get Counter Value From Single Cell        ${counters}     1      M55310C20000
    ${NR_RLC_PDU_DL_VOL_CA_SCELL2}       Get Counter Value From Single Cell        ${counters}     561    M55310C20000
    ${IGNB_PDU_DL_VOL_CA_SCELL1}         Get Counter Value From Single Cell        ${counters}     1      M55310C01021
    ${IGNB_PDU_DL_VOL_CA_SCELL2}         Get Counter Value From Single Cell        ${counters}     561    M55310C01021
    Should Be True      1<=${NR_RLC_PDU_DL_VOL_CA_SCELL1}
    Should Be True      1<=${NR_RLC_PDU_DL_VOL_CA_SCELL2}
    Should Be True      1<=${IGNB_PDU_DL_VOL_CA_SCELL1}
    Should Be True      1<=${IGNB_PDU_DL_VOL_CA_SCELL2}

Read Counters Value 8140-JF Ext
    [Arguments]    ${hostname}
    ${counters_values}=   Create List
    Collect counters ext gnb     8       ${hostname}
    @{counters}   Create list    M55310C20000    M55310C01021
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   8  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify additional msgs xplink 8140-JE
    unpack collected syslog
    check if exist in syslog    f1ap::IgnbCaXpSetupRequest   f1ap::IgnbCaXpSetupRequest
    check if exist in syslog    XpConnectionStatus::available   XpConnectionStatus::available
    check if exist in syslog    XpConnectionStatus::unavailable   XpConnectionStatus::unavailable

Change ip relation for JE case
    [Arguments]  ${ip_add_path}=MRBTS-50857/MNL-1/MNLENT-1/XPAP-1/XPIF-2/XPIFREMOTE-1
    Initialise delta store
    Add param to delta       ${ip_add_path}       ipAddress           value=8.8.8.8
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}

Fix ip relation for JE case
    [Arguments]  ${ip_add_path}=MRBTS-50857/MNL-1/MNLENT-1/XPAP-1/XPIF-2/XPIFREMOTE-1
    Initialise delta store
    Add param to delta       ${ip_add_path}       ipAddress           value=10.44.137.49
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}
