*** Settings ***
Documentation       :copyright: Nokia

Resource            ../../../../resources/airphone/scout_reporting/reporting_portal.robot
Resource            ../../../../resources/airphone/scripts/libraries_instances.robot
Resource            ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library             ../../../../resources/airphone/multignb_testlines_variables.py
Library             ../../CB009103/CB009103_Keywords.py
Library             ta5g_testline_management
Library             ta5g_cell_operations
Library             ta5g_ue_measurements
Library             ta5g_throughput
Library             ta5g_iphy
Library             ta5g_enb
Library             OperatingSystem
Library             String


*** Variables ***
@{REMOTE_HOSTS}=            ${EMPTY}
${WS_PERSONAL_CFG_PATH}=    /home/ute/.config/wireshark/
${NGAP_HO_REQ_1}=           ngap.HandoverRequest_element && nr-rrc.sourceSCG_NR_Config
${NGAP_HO_REQ_2}=           ngap.HandoverRequest_element && nr-rrc.sourceSCG_EUTRA_Config
${NGAP_HO_REQ_ACK}=         ngap.HandoverRequestAcknowledge_element && nr-rrc.mrdc_SecondaryCellGroupConfig == 0
${XNAP_HO_REQ}=             nokiaxnap.HandoverRequest_element && nr-rrc.sourceSCG_Configured
${XNAP_HO_REQ_ACK}=         nokiaxnap.HandoverRequestAcknowledge_element
${SCG_Config_HEX}=          0881CE5C40B1C632085FC61A0EC8C80F80409507884100892000741D0A731934D7B1F6C202F62E1\
...                         8000320B22E9BA80029C028806D00D6021E10000320EAE45D372A13000D6877BFED640C9DA25BC4\
...                         C58D6F1EDE45BCBB7996EA2A6134CDE0F0F0F0F0F0F0F0F483101D0049C80EA5D780101C00C9806\
...                         59174DC226E080600002010034E0144036806B010DB50001FF000000000106E18860000202C8408\
...                         0950026A6000018140D86A4330190C6562F8A3448E19722E9B9509808EB43BDFF6B2064ED12DE26\
...                         2C6B78F6F22DE5DBCCB7515309A666AA4BA808104420C2050000C034021B00D0106C03006045ED0\
...                         20117B014045ED904606824005745678000008000A6840080402591CA68A4000001801821C200DA\
...                         25BC4C58D6F1EDE45BCBB7996F9940E0000106F82000081000002200268E01C00C8654140188AA8\
...                         A000C00609D5000B08935605000000000E0BA0016581400000040100060B80061CB400016482422\
...                         8F1DFFFF07E068368D100164ACC228F1DFFFF07E068368E180164824228F1DFFFF07E068368F200\
...                         164AA4228F1DFFFF07E0683690280164AA4228F1DFFFF07E0683691300164AA4228F1DFFFF07E06\
...                         83692380164ACC228F1DFFFF07E0683693400164ACC228F1DFFFF07E06800


*** Keywords ***
Set SCG Active During Handover
    [Arguments]    ${ue_id}    ${gnb_id}    ${hex_scg_NR_Config}=None    ${hex_scg_EUTRA_Config}=None
    IF    '${hex_scg_NR_Config}' != 'None' and '${hex_scg_EUTRA_Config}' != 'None'
        Fail    Invalid arguments
    END

    IF    '${hex_scg_NR_Config}' != 'None'
        ${hex}=    Remove String    ${hex_scg_NR_Config}    ${SPACE}
        Execute Egate Command
        ...    cmd=ue_gnb_src_scg_cfg_param id=${ue_id} gnb=${gnb_id} include_source_scg_config=source_scg_nr_config
        ...    hex_scg_NR_Config=${hex}
    ELSE IF    '${hex_scg_EUTRA_Config}' != 'None'
        ${hex}=    Remove String    ${hex_scg_NR_Config}    ${SPACE}
        Execute Egate Command
        ...    cmd=ue_gnb_src_scg_cfg_param id=${ue_id} gnb=${gnb_id} include_source_scg_config=source_scg_eutra_config
        ...    hex_scg_Eutra_Config=${hex}
    ELSE
        Execute Egate Command
        ...    cmd=ue_gnb_src_scg_cfg_param id=${ue_id} gnb=${gnb_id} include_source_scg_config=source_scg_configured
    END

Set Uplink Data Flow Distribution In SCG
    [Arguments]    ${uec_id}    ${percent}
    Execute Egate Command    cmd=uec_param id=${uec_id} scg_ul_dist_percent=${percent}

Verify Message Sequence In CB014817_A_B1A1
    Verify Tcpdump Log    ${NGAP_HO_REQ_1}
    Verify Tcpdump Log    ${NGAP_HO_REQ_ACK}

Verify Message Sequence In CB014817_A_B1A2
    Verify Tcpdump Log    ${NGAP_HO_REQ_2}
    Verify Tcpdump Log    ${NGAP_HO_REQ_ACK}

Verify Message Sequence In CB014817_A_B2
    Verify Tcpdump Log    ${XNAP_HO_REQ}
    Verify Tcpdump Log    ${XNAP_HO_REQ_ACK}    number_of_messages=2

Add Custom VM IP Configuration
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NGC     ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN     ip_with_mask=10.0.1.5/24
    Start Vm Ethernet Interface    if_name=eth3:MME1_S1C     ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:SGW_S1U     ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:SGW_S11     ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:ENB1_X2U     ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:ENB1_S1     ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:ENB1_X2C     ip_with_mask=10.0.1.137/24

Delete Custom VM IP Configuration
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NGC     ip_with_mask=10.0.1.4/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN     ip_with_mask=10.0.1.5/24
    Stop Vm Ethernet Interface    if_name=eth3:MME1_S1C     ip_with_mask=10.0.1.131/24
    Stop Vm Ethernet Interface    if_name=eth3:SGW_S1U     ip_with_mask=10.0.1.133/24
    Stop Vm Ethernet Interface    if_name=eth3:SGW_S11     ip_with_mask=10.0.1.134/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB1_X2U     ip_with_mask=10.0.1.135/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB1_S1     ip_with_mask=10.0.1.136/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB1_X2C     ip_with_mask=10.0.1.137/24
