*** Settings ***
Suite Setup       Case Suite Setup
Suite Teardown    Swconfig modification or comissioning     swconfig_template_path=${default_swconfig_path}

Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_ASIBR_ABIOB1_AWHQE_ENB    STATE_SW_UPLOADED
...   PY36

Documentation    author：shanshan zhang
...              contact: shanshan.zhang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          ../5GC001937_Classical/Resources/5GC001937_classical_keywords.robot
Resource          ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
Resource          ../CB007608_B-573/Resources/5GC000573_common_keyword.robot
Resource          ./Resources/5GC008423_common_keyword.robot
Library           taf.hw.rf_attenuator        WITH NAME       att
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library           ./Resources/5GC008423_common.py
Variables         ./Resources/5GC008423_modify_para_trunk.py

*** Variables ***
${default_swconfig_path}       ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T7372/swconfig.txt
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${enb_id}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${port1}                  51000
${port2}                  51003
${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${ue1_ul_port}                   ${tl.ues[0].iperf_details.ports[0]}
${ue1_dl_port}                   ${tl.ues[0].iperf_details.ports[1]}
${ue2_ul_port}                   ${tl.ues[1].iperf_details.ports[2]}
${ue2_dl_port}                   ${tl.ues[1].iperf_details.ports[3]}
${duration}             ${360}
${ul_tput_udp}          100M
${dl_tput_udp}          2048M
${ue_number}            ${1}
${log_time}             30s
${luashark_path}        /opt/luashark/luashark.lua
${FORMAT_2}             FORMAT_2
${expect_list}          0  2
${filter_SgNBAdditionRequest}       x2ap.procedureCode == 27 && x2ap.X2AP_PDU == 1
${filter_biplog}                    dldata_csirssendreq
${filter_biplog_04}                 uldata_prachreceivereq
${expect_iniDeltaCqi_id}            INI_DELTA_CQI
${expect_iniDeltaSinr_id}           INI_DELTA_SINR
${expect_laIniDelta_update}         UPDATE
${expect_laIniDelta_skip}           SKIP
${expect_TransmissionPeriodicity}        ms2p5 (5)
${Test_Case_Name}         CB008423-2056
${att_ipaddr}                ${tl.attenuator.ip_addr}
${att_api_port}              ${tl.attenuator.port}
${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}

${LOG_PATH}                   ${OUTPUT DIR}
${CURDIR_path_2056}           ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T7372
${other_bts_ip}               ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${instance_id1}              MRBTS-${tl.enbs[1].instance_id}/
${global_bts_id1}            NRBTS-${tl.enbs[1].global_bts_id}


*** Test Cases ***
[1]CB008423-2056-01-1070_Single_UE_scheduling_with_DBF_in_FR1-n78-100MHz_with_GP2Symbols_with_B4_prach_149_and_1ssb
    [Tags]      CRT_TRUNK      CRT_22R2
#    [Setup]     Block cell and Unblock cell
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_01}    gNB_ip=${gNB_ip}
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
#    Expected_dl_Tput=1218    Expected_ul_Tput=99
    ${Dl_path}   ${Ul_path}   ${bip_log_path}    Attach power ue and Capture TTI and Bip and Wireshark log     Bip_flag=${False}
    ...       Expected_dl_Tput=1200    Expected_ul_Tput=95    wireshark_filename=gnb_tcpdump_01    dl_throughput=1300M
#    ${expect_list}     create list     1    3
#    run keyword and continue on failure     Check TTI Trace type ulPucchReceiveRespPsData column pucchFormat
#    ...    file_path=${Dl_path}    ulPucch_list=${expect_list}
#    run keyword and continue on failure     Check TTI Trace type ulPucchReceiveRespPsData column nANPucch      file_path=${Dl_path}
    BIP Log Convert Pcap To Text    source=${wireshark_path_ute}    target=wireshak_01.txt    filter=${filter_SgNBAdditionRequest}
    run keyword and continue on failure    Check ulDlDataSlotRatio message is right for 01
    ...    filename=${OUTPUT_DIR}/wireshak_01.txt     expect_Symbols=${12}
    Check message in Wireshark log common    expect_prachCfIndex=${149}    filename=${OUTPUT_DIR}/wireshak_01.txt
    [Teardown]    Run keyword and ignore error     case teardown      wireshark_filename=gnb_tcpdump_01

[1]CB008423-2056-02-1116_access_and_data_traffic_ in_digital_BF_system_aligned_with_TD_LTE_config2_ SSF_ starting_from_subframe3_in_SFN0
    [Tags]      CRT_TRUNK      CRT_22R2
#    [Setup]   Block cell and Unblock cell
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_02}    gNB_ip=${gNB_ip}
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
#    Expected_dl_Tput=1420    Expected_ul_Tput=54
    ${Dl_path}   ${Ul_path}   ${bip_log_path}    Attach power ue and Capture TTI and Bip and Wireshark log    Bip_flag=${False}
    ...    Expected_dl_Tput=1400     Expected_ul_Tput=50    wireshark_filename=gnb_tcpdump_02
#    ${expect_list}     create list   1  3
#    run keyword and continue on failure     Check TTI Trace type ulPucchReceiveRespPsData column pucchFormat
#    ...    file_path=${Dl_path}    ulPucch_list=${expect_list}
#    run keyword and continue on failure     Check TTI Trace type ulPucchReceiveRespPsData column nANPucch    file_path=${Dl_path}
    BIP Log Convert Pcap To Text    source=${wireshark_path_ute}    target=wireshak_02.txt    filter=${filter_SgNBAdditionRequest}
    run keyword and continue on failure    Check ulDlDataSlotRatio message is right     filename=${OUTPUT_DIR}/wireshak_02.txt
    ...    expect_Uplink_Slots=${2}     expect_Symbols=${10}    expect_Downlink_Slots=${7}
    Check message in Wireshark log common    expect_prachCfIndex=${160}    filename=${OUTPUT_DIR}/wireshak_02.txt
    [Teardown]    Run keyword and ignore error     case teardown      wireshark_filename=gnb_tcpdump_02

[1]CB008423-2056-03-1208_access_and_data_traffic_ in_digital_BF_system_aligned_with_ the_semiStatic_TDD_frame_structure_1_4
    [Tags]      CRT_TRUNK      CRT_22R2
#    [Setup]   Block cell and Unblock cell
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_03}    gNB_ip=${gNB_ip}
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
#    Expected_dl_Tput=1450    Expected_ul_Tput=63
    ${Dl_path}   ${Ul_path}   ${bip_log_path}    Attach power ue and Capture TTI and Bip and Wireshark log    Bip_flag=${False}
    ...    Expected_dl_Tput=1400     Expected_ul_Tput=60    wireshark_filename=gnb_tcpdump_03
#    ${expect_list}     create list   1  3
#    run keyword and continue on failure    Check TTI Trace type ulPucchReceiveRespPsData column pucchFormat
#    ...    file_path=${Dl_path}     ulPucch_list=${expect_list}
#    run keyword and continue on failure    Check TTI Trace type ulPucchReceiveRespPsData column nANPucch    file_path=${Dl_path}
    BIP Log Convert Pcap To Text    source=${wireshark_path_ute}    target=wireshak_03.txt    filter=${filter_SgNBAdditionRequest}
    run keyword and continue on failure    Check ulDlDataSlotRatio message is right     filename=${OUTPUT_DIR}/wireshak_03.txt
    ...    expect_Uplink_Slots=${1}     expect_Symbols=${12}    expect_Downlink_Slots=${3}
    Check message in Wireshark log common    expect_prachCfIndex=${98}   filename=${OUTPUT_DIR}/wireshak_03.txt
    [Teardown]    Run keyword and ignore error     case teardown        wireshark_filename=gnb_tcpdump_03

[1]CB008423-2056-04-1301_Call_setup_ with_frame_structure_1208_prach_config_index_190_NSA
    [Tags]      CRT_TRUNK      CRT_22R2
#    [Setup]     Block cell and Unblock cell
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_04}    gNB_ip=${gNB_ip}
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
#    Expected_dl_Tput=1450    Expected_ul_Tput=69
    ${Dl_path}   ${Ul_path}   ${bip_log_path}    Attach power ue and Capture TTI and Bip and Wireshark log    TTI_flag=${False}
    ...    Expected_dl_Tput=100     Expected_ul_Tput=10    wireshark_filename=gnb_tcpdump_04
    BIP Log Convert Pcap To Text    source=${wireshark_path_ute}    target=wireshak_04.txt    filter=${filter_SgNBAdditionRequest}
    run keyword and continue on failure    Check ulDlDataSlotRatio message is right     filename=${OUTPUT_DIR}/wireshak_04.txt
    ...    expect_Uplink_Slots=${1}     expect_Symbols=${12}    expect_Downlink_Slots=${3}
    run keyword and continue on failure     Check prach-ConfigurationIndex in wireshark log
    ...    expect_prachCfIndex=${190}   filename=${OUTPUT_DIR}/wireshak_04.txt
    run keyword and continue on failure     check BIP LOG for slot    biplog_list=${bip_log_path}
    check BIP LOG for sfn    biplog_list=${bip_log_path}
    [Teardown]    Run keyword and ignore error     case teardown       wireshark_filename=gnb_tcpdump_04

[1]CB008423-2056-05-1304_Activation_and_deactivation_of_Random_access_procedure_with_PRACH_format_B4
    [Tags]      CRT_TRUNK      CRT_22R2
#    [Setup]    Block cell and Unblock cell
    5GC008423_common_keyword.Block Cell
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_05_B4}    gNB_ip=${gNB_ip}
    UnBlock Cell
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
    Start wireshark capture from gNB or Enb     filename=gnb_tcpdump_05-1    gnb=${True}    alias=gnb
    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
    Stop wireshark capture from gNB or Enb      filename=gnb_tcpdump_05-1    gnb=${True}    alias=gnb
    5GC001937_mmw4_common_keyword.detach multi power ue    ue_num=${1}
    5GC008423_common_keyword.Block Cell
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_05_B4_2}    gNB_ip=${gNB_ip}
    Run Keyword And Expect Error    *5G RACH still not success after retry*
    ...    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
    5GC001937_mmw4_common_keyword.detach multi power ue    ue_num=${1}
    UnBlock Cell
    Wait Until Keyword Succeeds   15min   30s     Check BTS Cell On Air
    Start wireshark capture from gNB or Enb     filename=gnb_tcpdump_05-2    gnb=${True}    alias=gnb
    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
    Stop wireshark capture from gNB or Enb      filename=gnb_tcpdump_05-2    gnb=${True}    alias=gnb
    5GC001937_mmw4_common_keyword.detach multi power ue    ue_num=${1}
    5GC008423_common_keyword.Block Cell
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_05_A2}    gNB_ip=${gNB_ip}
    Run Keyword And Expect Error    *5G RACH still not success after retry*
    ...    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
    5GC001937_mmw4_common_keyword.detach multi power ue    ue_num=${1}
    UnBlock Cell
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
    Start wireshark capture from gNB or Enb     filename=gnb_tcpdump_05-3    gnb=${True}    alias=gnb
    Wait Until Keyword Succeeds   12min   3min    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
    Stop wireshark capture from gNB or Enb      filename=gnb_tcpdump_05-3    gnb=${True}    alias=gnb
    5GC001937_mmw4_common_keyword.detach multi power ue    ue_num=${1}
    Check prach-ConfigurationIndex for 05
    [Teardown]   Run keyword and ignore error    case teardown for 05

[1]CB008423-2056-10-1389-Evaluation_ST_TO_estimations_provided_PUCCH
    [Tags]      CRT_TRUNK      CRT_22R2
#    [Setup]    Block cell and Unblock cell
    Swconfig modification or comissioning     swconfig_template_path=${default_swconfig_path}
    Reset Site with admin
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
#    Expected_dl_Tput=1450    Expected_ul_Tput=63
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_10}    gNB_ip=${gNB_ip}
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
    ${Dl_path}   ${Ul_path}   ${biplog_list}     Attach power ue and Capture TTI and Bip and Wireshark log    Wireshark_flag=${False}
    ...    Expected_dl_Tput=1400     Expected_ul_Tput=60
    run keyword and continue on failure    check BIP LOG    biplog_list=${biplog_list}
    run keyword and continue on failure    check BIP LOG for sfn    biplog_list=${biplog_list}    filter=${filter_biplog}
    Swconfig modification or comissioning       swconfig_modify=${swconfig_modify_10}    swconfig_template_path=${default_swconfig_path}
    Reset Site with admin
    Wait Until Keyword Succeeds   5min   30s    Check BTS Cell On Air
    ${Dl_path2}   ${Ul_path2}   ${biplog_list2}     Attach power ue and Capture TTI and Bip and Wireshark log    Wireshark_flag=${False}
    ...    Expected_dl_Tput=1450     Expected_ul_Tput=62
    run keyword and continue on failure    check BIP LOG    biplog_list=${biplog_list2}
    run keyword and continue on failure    check BIP LOG for sfn    biplog_list=${biplog_list}    filter=${filter_biplog}
    ${pucchFormat_list}    get_csiSrReportData_pucchFormat_dlChannel_19B    file_path=${Dl_path}
#    ${FORMAT_2}    create list     ${FORMAT_2}
#    run keyword and continue on failure    lists should be equal    ${pucchFormat_list}    ${FORMAT_2}
#    ${pucchFormat_list2}    get_csiSrReportData_pucchFormat_dlChannel_19B    file_path=${Dl_path2}
#    run keyword and continue on failure    lists should be equal    ${pucchFormat_list2}    ${FORMAT_2}
#    ${expect_list}     create list   0  2
#    run keyword and continue on failure    Check TTI Trace type ulPucchReceiveRespPsData column pucchFormat
#    ...    file_path=${Dl_path}    ulPucch_list=${expect_list}
#    run keyword and continue on failure    Check TTI Trace type ulPucchReceiveRespPsData column pucchFormat
#    ...    file_path=${Dl_path2}    ulPucch_list=${expect_list}
    [Teardown]    Run keyword and ignore error    case teardown with swconfig


*** Keywords ***
Case Suite Setup
    CI_interface.Common Suite Setup
    Suite Setup for 2056

Suite Setup for 2056
    Setup Commission SCF for 2056
    5GC000573_common_keyword.Modify Common parameter via Coam      input_list=${GNB_Common_Parameter}    gNB_ip=${gNB_ip}
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air
#    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
#    Switch UE to NSA model
#    [Teardown]      5GC001937_mmw4_common_keyword.detach multi power ue    ue_num=${1}

Capture BIP log
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts    bb_slot_1=${false}
    sleep    2s
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Csn.Disconnect    connection=ASIK Master

check BIP LOG
    [Arguments]    ${biplog_list}   ${filter}=${filter_biplog}   ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh     alias=${connection}
    ...     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}
    ${num}    set variable    0
    ${True_flag}     set variable    0
    ${Status_flag}     set variable    0
    FOR   ${biplog}    IN    @{biplog_list}
        Log To Console    Convert pcap to text
        csn.execute
        ...    command=tshark -V -r ${LOG_PATH}/${biplog} -T text -Y '${filter}' > ${LOG_PATH}/biplog_${num}.txt
        ...    connection=${connection}
        csn.await execution end    connection=${connection}    timeout=30min
        ${startSymbol_list}     run keyword and continue on failure    get_value_from_biplog_divided_Frame
        ...     file_name=${LOG_PATH}/biplog_${num}.txt
        remove values from list     ${startSymbol_list}    ${EMPTY}
        ${startSymbol_length}    get length     ${startSymbol_list}
        ${True_flag}     Run keyword if    ${startSymbol_length}!=${0}     Evaluate    ${True_flag}+1   ELSE    set variable    ${True_flag}
        ${Flag}     Run keyword if    ${startSymbol_length}!=${0}     set variable    ${True}   ELSE    set variable    ${False}
        ${status}     Run Keyword And Return Status    Run keyword if   ${Flag}     check_list_is_Periodic    list_name=${startSymbol_list}
        ${Status_flag}     Run keyword if    ${status}!=${True}     Evaluate    ${Status_flag}+1   ELSE    set variable    ${Status_flag}
        ${num}    Evaluate    ${num}+1
    END
    run keyword and continue on failure    should be true     ${Status_flag}<${3}     msg=The list of checks is not periodic more than twice
    should be true     ${True_flag}>${0}     msg=startSymbol list is empty
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

check BIP LOG for slot
    [Arguments]    ${biplog_list}   ${Expected_slot}=${19}   ${filter}=${filter_biplog_04}   ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh     alias=${connection}
    ...     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}
    ${num}    set variable    0
    ${True_flag}     set variable    0
    FOR   ${biplog}    IN    @{biplog_list}
        Log To Console    Convert pcap to text
        csn.execute
        ...    command=tshark -V -r ${LOG_PATH}/${biplog} -T text -Y '${filter}' > ${LOG_PATH}/biplog_${num}.txt
        ...    connection=${connection}
        csn.await execution end    connection=${connection}    timeout=30min
        csn.Send Command      connection=${connection}
        ...    command=cat ${LOG_PATH}/biplog_${num}.txt | grep 'slot (Uint8)'|cut -d ':' -f 2|awk '{print}'|sed 's/^[ \t]*//g'|sort -n|uniq
        ${slot_data}    csn.Read Output    connection=${connection}
        ${slot_data}    strip_string    ${slot_data}
        ${slot_data_list}    Split String    ${slot_data}   \n
        remove values from list     ${slot_data_list}    ${EMPTY}
        ${slot_length}    get length     ${slot_data_list}
        ${True_flag}     Run keyword if    ${slot_length}!=${0}     Evaluate    ${True_flag}+1   ELSE    set variable    ${True_flag}
        ${Flag}     Run keyword if    ${slot_length}!=${0}     set variable    ${True}   ELSE    set variable    ${False}
        Run keyword if   ${Flag}    run keyword and continue on failure    should be equal as strings   ${slot_data}   ${Expected_slot}
        ${num}    Evaluate    ${num}+1
    END
    should be true     ${True_flag}>${0}    msg=slot_data list is empty
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

check BIP LOG for sfn
    [Arguments]    ${biplog_list}   ${Expected_slot}=${19}   ${filter}=${filter_biplog_04}   ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh     alias=${connection}
    ...     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}
    ${num}    set variable    0
    ${True_flag}     set variable    0
    FOR   ${biplog}    IN    @{biplog_list}
        Log To Console    Convert pcap to text
        csn.execute
        ...    command=tshark -V -r ${LOG_PATH}/${biplog} -T text -Y '${filter}' > ${LOG_PATH}/biplog_${num}.txt
        ...    connection=${connection}
        csn.await execution end    connection=${connection}    timeout=30min
        csn.Send Command      connection=${connection}
        ...    command=cat ${LOG_PATH}/biplog_${num}.txt | grep 'sfn (Uint16)'|cut -d ':' -f 2|awk '{print}'|sed 's/^[ \t]*//g'|uniq
        ${sfn_data}    csn.Read Output    connection=${connection}
        ${sfn_data}    strip_string    ${sfn_data}
        ${sfn_data}    Split String    ${sfn_data}    \n
        remove values from list     ${sfn_data}    ${EMPTY}
        ${sfn_length}    get length     ${sfn_data}
        ${True_flag}     Run keyword if    ${sfn_length}!=${0}     Evaluate    ${True_flag}+1   ELSE    set variable    ${True_flag}
        ${Flag}     Run keyword if    ${sfn_length}!=${0}     set variable    ${True}   ELSE    set variable    ${False}
        ${status}     Run Keyword And Return Status    Run keyword if    ${Flag}     Check data is Arithmetic sequence    check_list=${sfn_data}
        Exit For Loop If     ${status}==${True}
        ${num}    Evaluate    ${num}+1
    END
    run keyword and continue on failure    should be true     ${status}==${True}
    should be true     ${True_flag}>${0}    msg=sfn data list is empty
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check data is Arithmetic sequence
    [Arguments]   ${check_list}    ${expect_time_interval}=${8}
    ${check_list_length}    get length     ${check_list}
    FOR   ${num}    IN RANGE    ${0}    ${check_list_length}-1
        ${next_num}    Evaluate    ${num}+1
        ${time_interval}    Evaluate    ${check_list}[${next_num}]-${check_list}[${num}]
        Continue For Loop If    ${time_interval} < ${0}
        should be true    ${time_interval}==${expect_time_interval}
    END

Attach power ue and Capture TTI and Bip and Wireshark log
    [Arguments]    ${Expected_dl_Tput}    ${Expected_ul_Tput}   ${wireshark_filename}=gnb_tcpdump
    ...    ${if_gnb}=${True}         ${TTI_flag}=${True}    ${Bip_flag}=${True}    ${Wireshark_flag}=${True}
    ...    ${target_avg_percent}=0.98    ${min_percent}=0     ${alias}=gnb    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${ul_throughput}=100M    ${dl_throughput}=2048M
    ${cell_id}     COAM Get nrcellid with the lcrid    bts_host=${gNB_ip}    lcrid=${1}
    ${cell_id}     Create List    ${cell_id}
    Run keyword if   ${Wireshark_flag}    Start wireshark capture from gNB or Enb
    ...    filename=${wireshark_filename}      gnb=${if_gnb}     alias=${alias}
    5GC001937_mmw4_common_keyword.attach multi power ue    ue_num=${1}
    ${connection}    Run keyword if   ${Bip_flag}    Start Capture BIP log
    5GC001937_mmw4_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
    ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}     protocol=udp     ##后续看情况加长
    sleep   3s
    log to console   Stop Capture BIP log Return file path
    ${biplog_list}     Run keyword if   ${Bip_flag}      Stop Capture BIP log and download file      connection=${connection}
    log to console   Stop wireshark capture from gNB or Enb
    ${log_full_path_ute}    Run keyword if   ${Wireshark_flag}     Stop wireshark capture from gNB or Enb
    ...    filename=${wireshark_filename}      gnb=${if_gnb}     alias=${alias}
    log to console      Start TTI Trace and Return file path
    ${Dl_path}   ${Ul_path}    Run keyword if   ${TTI_flag}    Start TTI Trace and Return file path
    log    \n start check throughput    console=yes
    ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=100s    ignore_time=10s
    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=dl   min_percent=${min_percent}
    ...    log=${log_path}     cells=${cell_id}    target_throughput=${Expected_dl_Tput}    target_avg_percent=${target_avg_percent}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=ul   min_percent=${min_percent}
    ...    log=${log_path}     cells=${cell_id}    target_throughput=${Expected_ul_Tput}    target_avg_percent=${target_avg_percent}
    set test variable    ${wireshark_path_ute}    ${log_full_path_ute}
    5GC001937_mmw4_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
    [Teardown]   5GC001937_mmw4_common_keyword.detach multi power ue     ue_num=${1}
    [Return]    ${Dl_path}   ${Ul_path}   ${biplog_list}

Attach power ue and Capture TTI log
    [Arguments]      ${if_gnb}=${True}   ${ul_throughput}=100M    ${dl_throughput}=300M
    ...       ${alias}=gnb    ${if_ul}=${True}    ${if_dl}=${True}    ${bts_log_name}=bts_log.tgz
    log to console     Prepare UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    BTSLOG Start btslog on local machine
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    5GC001937_mmw4_common_keyword.start multi power ue traffic ul and dl    ue_num=${1}   if_ul=${if_ul}    if_dl=${if_dl}
    ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}     protocol=udp
    sleep    5s
    BTSLOG Collect btslog      bts_log_name=${bts_log_name}
    Teardown gNB cOAM SSL Connection
    5GC001937_mmw4_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${if_ul}    if_dl=${if_dl}
    [Teardown]    5GC001937_mmw4_common_keyword.detach multi power ue     ue_num=${1}

Start TTI Trace and Return file path
    start tti trace for 2056
    log to console    start tti trace
    sleep    5s
    Stop TTI trace log capturing
    ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
    ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
    ${Dl_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    DL
    ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
    [Return]    ${Dl_path}   ${Ul_path}

start tti trace for 2056
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    log to console  start capture tti trace
    Create default connection    hw_slot=${hw_slot}
    Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}

Start Wireshark log and Return file path
    [Arguments]    ${filename}
    Start wireshark capture from gNB or Enb      filename=${filename}    alias=enb1
    log to console    start wireshark capture
    sleep    2s
    Stop wireshark capture from gNB or Enb        filename=${filename}   alias=enb1

Start Capture BIP log Return file path
    [Arguments]    ${bb_slot_1}=${False}    ${bb_slot_5}=${True}
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts    capturing_time_seconds=60s    sleep_time=5s    bb_slot_1=${bb_slot_1}    bb_slot_5=${bb_slot_5}
    sleep    10s
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    interface=ethbp1    log_prefix=tcpdump_L2L1
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Csn.Disconnect    connection=ASIK Master
    [Return]    ${bip_log_path}

Check TTI Trace type ulPucchReceiveRespPsData column pucchFormat
    [Arguments]    ${file_path}     ${ulPucch_list}
    ${pucchFormat_list}    get_ulPucchReceiveRespPsData_pucchFormat_dlChannel_19B    file_path=${file_path}
    sort list      ${pucchFormat_list}
    run keyword and continue on failure    lists should be equal    ${pucchFormat_list}    ${ulPucch_list}

Check TTI Trace type ulPucchReceiveRespPsData column nANPucch
    [Arguments]    ${file_path}
    ${nANPucch_list}    get_ulPucchReceiveReqData_nANPucch_dlChannel_19B    file_path=${file_path}
    run keyword and continue on failure    should not be empty    ${nANPucch_list}

Check ulDlDataSlotRatio message is right
    [Arguments]   ${filename}    ${expect_Downlink_Slots}   ${expect_Uplink_Slots}    ${expect_Symbols}
    ${data_Downlink_Slots}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofDownlinkSlots | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${data_Uplink_Slots}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofUplinkSlots | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${data_Downlink_Symbols}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofDownlinkSymbols | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${data_Uplink_Symbols}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofUplinkSymbols | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${Sum_Symbols}    Evaluate     int(${data_Downlink_Symbols})+int(${data_Uplink_Symbols})
    run keyword and continue on failure    should be true      ${data_Downlink_Slots}==${expect_Downlink_Slots}
    run keyword and continue on failure    should be true      ${data_Uplink_Slots}==${expect_Uplink_Slots}
    run keyword and continue on failure    should be true      ${Sum_Symbols}==${expect_Symbols}

Check ulDlDataSlotRatio message is right for 01
    [Arguments]   ${filename}      ${expect_Symbols}
    ${TransmissionPeriodicity1}    Get wireshark log data     file_path=${filename}
    ...    command=grep dl-UL-TransmissionPeriodicity | cut -d ':' -f 2 |tail -1
    ${TransmissionPeriodicity2}    Get wireshark log data     file_path=${filename}
    ...    command=grep dl-UL-TransmissionPeriodicity | cut -d ':' -f 2 |head -1
    ${data_Downlink_Slots1}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofDownlinkSlots | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${data_Downlink_Slots2}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofDownlinkSlots | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|head -1
    ${data_Downlink_Slots}     create list       ${data_Downlink_Slots1}    ${data_Downlink_Slots2}
    ${data_Uplink_Slots1}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofUplinkSlots | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${data_Uplink_Slots2}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofUplinkSlots | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|head -1
    ${data_Uplink_Slots}     create list       ${data_Uplink_Slots1}    ${data_Uplink_Slots2}
    ${data_Downlink_Symbols}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofDownlinkSymbols | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${data_Uplink_Symbols}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofUplinkSymbols | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|tail -1
    ${data_Downlink_Symbols1}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofDownlinkSymbols | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|head -1
    ${data_Uplink_Symbols1}    Get wireshark log data     file_path=${filename}
    ...    command=grep nrofUplinkSymbols | cut -d ':' -f 2 |awk '{print}'|sed 's/^[ \t]*//g'|head -1
    ${Sum_Symbols}    Evaluate     int(${data_Downlink_Symbols})+int(${data_Uplink_Symbols})
    ${Sum_Symbols1}    Evaluate     int(${data_Downlink_Symbols1})+int(${data_Uplink_Symbols1})
    run keyword and continue on failure    list should contain value      ${data_Downlink_Slots}    2
    run keyword and continue on failure    list should contain value      ${data_Downlink_Slots}    3
    run keyword and continue on failure    list should contain value      ${data_Uplink_Slots}      2
    run keyword and continue on failure    list should contain value      ${data_Uplink_Slots}      1
    run keyword and continue on failure    should be true      ${Sum_Symbols}==${expect_Symbols}
    run keyword and continue on failure    should be true      ${Sum_Symbols1}==${expect_Symbols}
    run keyword and continue on failure    Should Be Equal As Strings      ${TransmissionPeriodicity1}   ${expect_TransmissionPeriodicity}
    run keyword and continue on failure    Should Be Equal As Strings      ${TransmissionPeriodicity2}   ${expect_TransmissionPeriodicity}

Check prach-ConfigurationIndex in wireshark log
    [Arguments]   ${filename}    ${expect_prachCfIndex}
    ${actual_prachCfIndex}    Get wireshark log data     file_path=${filename}
    ...    command=grep prach-ConfigurationIndex | cut -d ':' -f 2 |awk '{print}'|head -1
    run keyword and continue on failure    should be true    ${actual_prachCfIndex}==${expect_prachCfIndex}

Check prachCfIndex in wireshark log due to parameter
    [Arguments]   ${filename}
    ${actual_prachCfIndex}    Get wireshark log data     file_path=${filename}
    ...    command=grep 'p0-NominalWithGrant'|cut -d ':' -f 2|cut -d ' ' -f 2|awk '{print}'|head -1
    ${bts_prachCfIndex}    Get parameter from BTS WEBUI
    ${prach_list}    Split String    ${bts_prachCfIndex}
    run keyword and continue on failure    should be true      ${prach_list}[0]==${actual_prachCfIndex}

Check ContentionResolutionTimer in wireshark log
    [Arguments]   ${filename}    ${expect_CRTimer}
    ${actual_CRTimer}    Get wireshark log data     file_path=${filename}
    ...    command=grep ra-ContentionResolutionTimer |cut -d ':' -f 2 |cut -d ' ' -f 2|awk '{print}'|head -1
    run keyword and continue on failure    should be equal as strings     ${actual_CRTimer}    ${expect_CRTimer}

Check BearerIdentity in wireshark log
    [Arguments]   ${filename}    ${expect_BearerID}
    ${actual_BearerID}    Get wireshark log data     file_path=${filename}
    ...    command=grep eps-BearerIdentity|cut -d ':' -f 2 |awk '{print}'|tail -1
    run keyword and continue on failure    should be true    ${actual_BearerID}==${expect_BearerID}

Check message in Wireshark log common
    [Arguments]    ${expect_prachCfIndex}    ${filename}=${OUTPUT_DIR}/wireshak.txt    ${expect_CRTimer}=sf64   ${expect_BearerID}=5
    Check wireshark log data not empty for 8423    filename=${filename}    command=grep 'ssb-PositionsInBurst: mediumBitmap (1)'
    Check prach-ConfigurationIndex in wireshark log    filename=${filename}     expect_prachCfIndex=${expect_prachCfIndex}
    Check prachCfIndex in wireshark log due to parameter    filename=${filename}
    Check ContentionResolutionTimer in wireshark log    filename=${filename}    expect_CRTimer=${expect_CRTimer}
    Check BearerIdentity in wireshark log     filename=${filename}    expect_BearerID=${expect_BearerID}

Check TTI message iniDeltaCqi or iniDeltaSinr for dl
    [Arguments]     ${filename}     ${expect_laIniDelta_event}    ${expect_laIniDelta_id}
    ${laIniDelta_event}    get_laIniDelta_event_dlChannel_19B    file_path=${filename}
    ${laIniDelta_id}    get_laIniDelta_id_dlChannel_19B    file_path=${filename}
    run keyword and continue on failure    should be equal as strings    ${laIniDelta_event}[0]    ${expect_laIniDelta_event}
    run keyword and continue on failure    should be equal as strings    ${laIniDelta_id}[0]       ${expect_laIniDelta_id}

Check prach-ConfigurationIndex for 05
    BIP Log Convert Pcap To Text    source=${OUTPUT_DIR}/gnb_tcpdump_05-1.pcap    target=gnb_tcpdump_05-1.txt
    ...    filter=${filter_SgNBAdditionRequest}
    BIP Log Convert Pcap To Text    source=${OUTPUT_DIR}/gnb_tcpdump_05-2.pcap    target=gnb_tcpdump_05-2.txt
    ...    filter=${filter_SgNBAdditionRequest}
    BIP Log Convert Pcap To Text    source=${OUTPUT_DIR}/gnb_tcpdump_05-3.pcap    target=gnb_tcpdump_05-3.txt
    ...    filter=${filter_SgNBAdditionRequest}
    run keyword and continue on failure    Check prach-ConfigurationIndex in wireshark log
    ...    filename=${OUTPUT_DIR}/gnb_tcpdump_05-1.txt      expect_prachCfIndex=${160}
    run keyword and continue on failure    Check prach-ConfigurationIndex in wireshark log
    ...    filename=${OUTPUT_DIR}/gnb_tcpdump_05-2.txt      expect_prachCfIndex=${148}
    run keyword and continue on failure    Check prach-ConfigurationIndex in wireshark log
    ...    filename=${OUTPUT_DIR}/gnb_tcpdump_05-3.txt      expect_prachCfIndex=${98}

BTSLOG Start btslog on local machine
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    Log To Console    start BTSlog
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

BTSLOG Collect btslog
    [Arguments]    ${bts_log_name}=bts_log.tgz    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    stop BTSlog
    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    bts_log_name=${bts_log_name}    bts_logs_dir=${bts_logs_dir}

__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_log_name}=bts_log.tgz     ${bts_logs_dir}=/tmp/btslog2
	Run  mkdir ${OUTPUT_DIR}/${TEST_NAME}
	Run  mkdir ${OUTPUT_DIR}/${Test_Case_Name}
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/${bts_log_name}
    Run  rm ${bts_logs_dir}/*

Teardown gNB cOAM SSL Connection
    [Arguments]    ${connection}=GNB_OAM
    coam.teardown    connection=GNB_OAM

check BTSlog with message
    [Arguments]     ${message}    ${expect_status}   ${bts_log_name}=bts_log.tgz   ${bts_log}=bts_log.log   ${connection}=TESTPC
    csn.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=${connection}
    csn.execute    command=tar zxvf ${OUTPUT_DIR}/${TEST_NAME}/${bts_log_name} -C ${OUTPUT_DIR}/${Test_Case_Name}/    connection=${connection}
	csn.execute    command=mv ${OUTPUT_DIR}/${Test_Case_Name}/*.LOG ${OUTPUT_DIR}/${Test_Case_Name}/${bts_log}   connection=${connection}
	sleep   5s
	${update_or_skip_status}    Wait Until Keyword Succeeds    2min   10s     check btslog     bts_log=${bts_log}     message=${message}
    run keyword and continue on failure    should be true      ${update_or_skip_status}[0]==${expect_status}
    [Teardown]    Csn.Disconnect	connection=${connection}

check btslog
    [Arguments]   ${bts_log}     ${message}
    ${update_or_skip_status}     get_update_or_skip_message     file_name=${OUTPUT_DIR}/${Test_Case_Name}/${bts_log}    message=${message}
    should not be empty    ${update_or_skip_status}
    [Return]    ${update_or_skip_status}

Adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_1}    ${vendor}=HBTE
    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}    ${max_attenuation_value}=${127}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    att.set_attenuation     port=${att_port3}    value=${value_3}
    att.set_attenuation     port=${att_port4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value_4}

Block cell and Unblock cell
    [Arguments]    ${unblock_cell_dist_name}=${gnb7372_cell_dist_name}    ${block_cell_dist_name}=${gnb737_cell_dist_name}
    UnBlock Cell      dist_name=${unblock_cell_dist_name}
    Block other Cell        dist_name=${block_cell_dist_name}
    Wait Until Keyword Succeeds   15min   30s    Check BTS Cell On Air

case teardown
    [Arguments]   ${ue_num}=${1}    ${wireshark_filename}=gnb_tcpdump   ${if_gnb}=${True}   ${alias}=gnb
    run keyword and continue on failure     5GC001937_mmw4_common_keyword.stop multi power ue traffic ul and dl     ue_num=${ue_num}
    run keyword and continue on failure     5GC001937_mmw4_common_keyword.detach multi power ue     ue_num=${ue_num}
    run keyword and continue on failure     Stop Wireshark PID     filename=${wireshark_filename}     alias=${alias}
    run keyword and continue on failure     coam.teardown    connection=GNB_connection
    CI_interface.Common Case Teardown

case teardown with swconfig
    [Arguments]   ${ue_num}=${1}    ${wireshark_filename}=gnb_tcpdump   ${if_gnb}=${True}   ${alias}=gnb
    run keyword and continue on failure     5GC001937_mmw4_common_keyword.stop multi power ue traffic ul and dl     ue_num=${ue_num}
    run keyword and continue on failure     5GC001937_mmw4_common_keyword.detach multi power ue     ue_num=${ue_num}
    run keyword and continue on failure     coam.teardown    connection=GNB_connection
    Swconfig modification or comissioning     swconfig_template_path=${default_swconfig_path}
    CI_interface.Common Case Teardown

case teardown for 05
    [Arguments]   ${ue_num}=${1}    ${wireshark_filename}=gnb_tcpdump   ${if_gnb}=${True}   ${alias}=gnb
    run keyword and continue on failure     5GC001937_mmw4_common_keyword.detach multi power ue     ue_num=${ue_num}
    run keyword and continue on failure     Stop Wireshark PID      filename=gnb_tcpdump_05-1       alias=${alias}
    run keyword and continue on failure     Stop Wireshark PID      filename=gnb_tcpdump_05-2       alias=${alias}
    run keyword and continue on failure     Stop Wireshark PID      filename=gnb_tcpdump_05-3       alias=${alias}
    run keyword and continue on failure     coam.teardown    connection=GNB_connection
    CI_interface.Common Case Teardown
