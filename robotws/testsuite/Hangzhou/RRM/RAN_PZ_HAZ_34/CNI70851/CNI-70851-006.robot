# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: liujia
# # #...    contact:jia-rebecca.liu@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : CNI70851
# # #
# # #
# # #
# # #Suite Setup    Run Keywords
# # #...    Run Keyword And Ignore Error     Common Suite Setup for COAM     AND
# # #...    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'
# # #...    Run Keyword And Ignore Error    Common UE Detach
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #
# # #Resource       ../5GC002200/Resources/5GC002200_coam_common_keywords.robot
# # #Variables      ../5GC002200/Resources/variables.py
# # #Variables      ../5GC002200/Resources/Stream_parameter.py
# # #
# # #*** Variables ***
# # ##${tl_scf_dir_path}              /opt/workspace/SCF/70851/
# # #${SBTS21B_scf_70851}            TL362_GNB_70851_006.xml
# # #${Trunk_scf_70851}              TL365_GNB_70851_006.xml
# # #${SBTS22R1_scf_70851}           TL370_GNB_70851_006.xml
# # #${eNB_scf_file}                 TL370_ENB_SCF.xml
# # #${TL362_scf_70851_TMP}           TL362_GNB_70851_Enable_006_TMP.xml
# # #${swconfig}                     /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #@{21B_dl_enable}             1000
# # #@{Trunk_dl_enable}            700
# # #@{22R1_dl_enable}             700
# # #${70851_nglog_1}            70851_wireshark_006_1.pcap
# # #${70851_nglog_2}            70851_wireshark_006_2.pcap
# # #${ASKEY_DL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${ASKEY_UL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# # #@{att_value_21B}             25    55    75    127
# # #@{att_value_Trunk}            5    55    75    127
# # #@{att_value_22R1}            20    50    70    127
# # #${enbx2_dist_Trunk}       MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# # #${enbx2_dist_21B}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
# # #${enbx2_dist_22R1}        MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
# # #${ue_num}                    1
# # #
# # ###21B test on TL362##
# # ###TRUNK test on TL365##
# # ###22R1 test on TL370##
# # #
# # #*** Test Cases ***
# # #[1]CNI-70851_006_CSIRS_reconfiguration_with_maxCsirsNumber=4_long_PUCCH_when_DRX_on_duration_is_small_Qualcomm_UE_NSA_mode
# # #    [Documentation]
# # #    ...    Purpose of this case is to validate the CSIRS number reconfigured to Qualcomm UE which support simultaneousCSI-ReportsPerC=4 when
# # #    ...    DRX on duration is not long enough to allocate 4CSIRS without overlapping the CSI related resources in NSA mode. CSIRS will degrade
# # #    ...    to 2CSIRS or 1CSIRS and reconfigure to UE at last.
# # #    [Tags]      classical
# # #    [Timeout]    1 hour
# # #    [Setup]
# # #    Case variable set for 70851_006
# # #    Set nrcellid suit varaible    cellid=${${nrcellid}}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    70851_006 on trunk
# # #    ...    ELSE    70851_006 askey
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #70851_006 askey
# # #    ASKEY UE parameter setup
# # #    Trigger ASKEY UE reboot
# # #    Common Case TestLine Setup    ModifySCF_Beforecommission=True    gnb_type=NSA    golden_scf_name=${golden_scf_name_22R2}
# # #    ...                           ListParamterToModify=${CNI70851_2200_modify_list_T362}
# # #    ...                           ParamterToModify=${CNI70851_modify_para_T362}
# # #    Modify the COAM parameter with admin API    parameters=${LOCK_GNB1_CELL1}
# # #    Connect and Modify the parameter on enblte    dist_name=${TL362_enb_dist}
# # #    ...    parameter=${defaultgnbcell}    value=1
# # #    MCS SET    att_value=${@{${att_value}}[0]}
# # #    Power UE Precondition
# # #    Start To Capture Wireshark Logs on ASIB    filename=${70851_nglog_1}
# # #    Power UE Attach and Verify attach for askey     4g_check=True
# # #    Stop and download wireshark Logs on ASIB    logname=${70851_nglog_1}
# # #    Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    DL Tput check with nrcellid    cellid=${${nrcellid}}    dlexpect_tp=${@{${Expect_dl_enable}}[0]}
# # #    Askey UE stop dl traffic on appserver and detach
# # #    Modify the COAM parameter with admin API     parameters=${${DRX_onduration}}
# # #    sleep    10s
# # #    Start To Capture Wireshark Logs on ASIB    filename=${70851_nglog_2}
# # #    Power UE Attach and Verify attach for askey     4g_check=True
# # #    Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    Stop and download wireshark Logs on ASIB    logname=${70851_nglog_2}
# # #    DL Tput check with nrcellid    cellid=${${nrcellid}}    dlexpect_tp=${@{${Expect_dl_enable}}[0]}
# # #    Askey UE stop dl traffic on appserver and detach
# # #    MCS teardown    mcs_alias=${mcs_alias}
# # #    Analysis 70851
# # #
# # #70851_006 on trunk
# # ##    Prepare testline to cell onair for NSA    localFilePath=${swconfig}    tl_scf_filename=${${scf_70851_006}}    enbx2_dist=${${enbx2_dist}}
# # #    Common Case TestLine Setup    ModifySCF_Beforecommission=True    gnb_type=NSA    golden_scf_name=${golden_scf_name_Trunk}
# # #    ...                           ListParamterToModify=${CNI70851_modify_list_Trunk}
# # #    MCS SET    att_value=${@{${att_value}}[0]}
# # #    Start To Capture Wireshark Logs on ASIB    filename=${70851_nglog_1}
# # #    Multi-UEs attach    ue_num=${ue_num}    attach_mode=${NSA_attach_mode}    ue_mode=${NSA_UE_MODE}    nettpye=${NSA_nettype}
# # #    ...    apn_address=${NSA_apn_addr}
# # #    Stop and download wireshark Logs on ASIB    logname=${70851_nglog_1}
# # #    power_ue.Start traffic    ue_index=${0}    direction=dl
# # #    ...    apn_address=${NSA_apn_addr}    throughput=${Multi_dl_throughput}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${NSA_UE_MODE}
# # #    DL Tput check with nrcellid    cellid=${${nrcellid}}    dlexpect_tp=${@{${Expect_dl_enable}}[0]}
# # #    Multi UE Detach And Stop Traffic
# # #    Modify the COAM parameter with admin API     parameters=${${DRX_onduration}}
# # #    sleep    10s
# # #    Start To Capture Wireshark Logs on ASIB    filename=${70851_nglog_2}
# # #    Multi-UEs attach    ue_num=${ue_num}    attach_mode=${NSA_attach_mode}    ue_mode=${NSA_UE_MODE}    nettpye=${NSA_nettype}
# # #    ...    apn_address=${NSA_apn_addr}
# # #    Stop and download wireshark Logs on ASIB    logname=${70851_nglog_2}
# # #    power_ue.Start traffic    ue_index=${0}    direction=dl
# # #    ...    apn_address=${NSA_apn_addr}    throughput=${Multi_dl_throughput}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${NSA_UE_MODE}
# # #    DL Tput check with nrcellid    cellid=${${nrcellid}}    dlexpect_tp=${@{${Expect_dl_enable}}[0]}
# # #    Multi UE Detach And Stop Traffic
# # #    MCS teardown    mcs_alias=${mcs_alias}
# # #    Analysis 70851
# # #
# # #MCS SET
# # #    [Arguments]    ${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    TOPYONG MCS ON TL362     att_value=${att_value}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    HAOJIN MCS ON TL365    att_value=${att_value}
# # #
# # #TOPYONG MCS ON TL362
# # #    [Arguments]    ${att_value}
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT TO LOCK AZQO
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${0}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-28}    mcs_alias=TPY
# # #    Set TOPYOUNG ATT    att_value=${att_value}
# # #
# # #HAOJIN MCS ON TL365
# # #    [Arguments]    ${att_value}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${13}    end_output_port=${14}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-8}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    3s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${15}    end_output_port=${16}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${8}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    3s
# # #    Set HAOJIN Port13 to Port16 ATT    att_value=${att_value}
# # #    MCS.get_phase    input_port=${1}     output_port=${1}     mcs_device=HJ
# # #
# # #HBTE MCS ON TL370
# # #    [Arguments]    ${att_value}
# # #    HBTE MCS Setup    ip=${HBTE_ip_370}
# # #    Set HBTE horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    input_group_id=${None}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-13}    vertical_distance=${1.4}    horizontal_distance=${0.5}    mcs_alias=FC
# # #    Set HBTE horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    input_group_id=${None}
# # #    ...    vertical_angle=${96}    horizontal_angle=${-3}    vertical_distance=${1.4}    horizontal_distance=${0.5}    mcs_alias=FC
# # #    Set HBTE ATT    att_value=${att_value}
# # #
# # #Analysis 70851
# # #    ${nrofPorts_1}=    Get CSIRS_nrofPorts from CPIF    file_path=${epc_log_path}${70851_nglog_1}
# # #    should contain x times    ${nrofPorts_1}    p8    4
# # #    ${cdm_Type_1}=    Get CSIRS_cdm_Type from CPIF    file_path=${epc_log_path}${70851_nglog_1}
# # #    should contain    ${cdm_Type_1}    2
# # #    ${density_1}=    Get CSIRS_density from CPIF    file_path=${epc_log_path}${70851_nglog_1}
# # #    should contain    ${density_1}    1
# # #    ${n1_n2_1}=    Get CSIRS_n1_n2 from CPIF    file_path=${epc_log_path}${70851_nglog_1}
# # #    should contain    ${n1_n2_1}    1
# # #    ${longpucch_1}=    Get LongPucch_format from CPIF    file_path=${epc_log_path}${70851_nglog_1}
# # #    ${longpucch_1_result}=    Evaluate     '1' in ${longpucch_1} and '3' in ${longpucch_1}
# # #    should be true    ${longpucch_1_result}
# # #    ${nrofPorts_2}=    Get CSIRS_nrofPorts from CPIF    file_path=${epc_log_path}${70851_nglog_2}
# # #    should contain x times    ${nrofPorts_2}    p8    2
# # #    ${density_2}=    Get CSIRS_density from CPIF    file_path=${epc_log_path}${70851_nglog_2}
# # #    should contain    ${density_2}    1
# # #    ${n1_n2_2}=    Get CSIRS_n1_n2 from CPIF    file_path=${epc_log_path}${70851_nglog_2}
# # #    should contain    ${n1_n2_2}    1
# # #    ${longpucch_2}=    Get LongPucch_format from CPIF    file_path=${epc_log_path}${70851_nglog_2}
# # #    ${longpucch_2_result}=    Evaluate     '1' in ${longpucch_2} and '3' in ${longpucch_2}
# # #    should be true    ${longpucch_2_result}
# # #    SSB_report should in DRX    wriesharklog=${70851_nglog_1}
# # #    CQI_report should in DRX    wriesharklog=${70851_nglog_1}
# # #    CSIRS_slot should in DRX    wriesharklog=${70851_nglog_1}
# # #    SSB_report should in DRX    wriesharklog=${70851_nglog_2}
# # #    CQI_report should in DRX    wriesharklog=${70851_nglog_2}
# # #    CSIRS_slot should in DRX    wriesharklog=${70851_nglog_2}
# # #
# # #SSB_report should in DRX
# # #    [Arguments]      ${wriesharklog}
# # #    ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${bm_report}=     Get SSB_Reportslot from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${cqi_report}=     Get CQI_Reportslot from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
# # #    ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
# # #    ${DRX_period}=     Get DRX_LongCycle from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${DRX_LongCycle}=    String.Remove String    ${DRX_period}    ms
# # #    FOR    ${n}    IN RANGE    0    5
# # #       ${SSB_report}=    Evaluate    ${bm_report}+${DRX_LongCycle}*${n}
# # #       ${status_1}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${SSB_report} <= ${drx_onduration_endslot}
# # #       Exit For Loop If    '${status_1}' == 'PASS'
# # #    END
# # #
# # #CQI_report should in DRX
# # #    [Arguments]      ${wriesharklog}
# # #    ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${bm_report}=     Get SSB_Reportslot from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${cqi_report}=     Get CQI_Reportslot from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
# # #    ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
# # #    ${DRX_period}=     Get DRX_LongCycle from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${DRX_LongCycle}=    String.Remove String    ${DRX_period}    ms
# # #    FOR    ${n}    IN RANGE    0    5
# # #       ${SSB_report}=    Evaluate     ${bm_report}+${DRX_LongCycle}*${n}
# # #       ${status_2}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${SSB_report} <= ${drx_onduration_endslot}
# # #       Exit For Loop If    '${status_2}' == 'PASS'
# # #    END
# # #
# # #CSIRS_slot should in DRX
# # #    [Arguments]      ${wriesharklog}
# # #    ${drx_startoffset}=    Get DRX_StarOffset from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_slotoffset}=    Get DRX_slotoffset from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_onduration}=    Get DRX_onduration timer from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${drx_onduration_startslot}    Evaluate    (${drx_startoffset}+${drx_slotoffset})*2
# # #    ${drx_onduration_endslot}    Evaluate    ${drx_onduration_startslot}+${drx_onduration}*2-1
# # #    ${csirs_slot}=    Get CSIRS_StartOffset from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${csirs_period_0}=    Get CSIRS_periodicity from CPIF    file_path=${epc_log_path}${wriesharklog}
# # #    ${csirs_period}=    String.Remove String    ${csirs_period_0}    slots
# # #    FOR    ${n}    IN RANGE    0    5
# # #       ${csirs_slot}=    Evaluate    ${csirs_slot}+${csirs_period}*${n}
# # #       ${status_3}=    Run Keyword And Return Status    ${drx_onduration_startslot} <= ${csirs_slot} <= ${drx_onduration_endslot}
# # #       Exit For Loop If    '${status_3}' == 'PASS'
# # #    END
# # #
# # #set true
# # #    Set Suite Variable    ${var}      true
# # #set false
# # #    Set Suite Variable    ${var}      false
# # #
# # #Tests Recover
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    Connect to TestPc    alias=ute
# # #    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    Multi UE Detach And Stop Traffic
# # #    ...    ELSE    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'
# # #    ...    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    MCS teardown    mcs_alias=${mcs_alias}
# # #    run keyword if    '${release_info}' == 'SBTS21B_ENB_0000' or '${release_info}' == 'SBTS22R2_ENB_0000'    MCS tear
# ...down    mcs_alias=${mcs_alias
# # }
# # #    clear cli process
# # #    disconect all connections
