*** Settings ***
Documentation    Author:jia-rebecca.liu@nokia-sbell.com


Resource      ./CB008247_keywords.robot
Variables     ../TestData/modify_parameter.py
Variables     ../TestData/modify_swconf.py
Variables     ../TestData/8247_Split_parameter.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Library       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002200/Resources/tput_output.py
Library       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002200/Resources/csv_analysis_mumimo.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/dingli_multiUE.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py     WITH NAME    nrdim
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${golden_scf_24R1}          MRBTS-10175_TL365_golden_scf.xml
${golden_scf_23R4}          MRBTS-11006_TL374_golden_SCF.xml

${golden_scf_23R3}          MRBTS-10175_TL365_golden_scf_23R3.xml
${golden_scf_24R1_374}      MRBTS-11006_TL374_golden_SCF_24R1.xml
${golden_scf_23R3_374}      MRBTS-11006_TL374_golden_SCF_23R3.xml
${golden_scf_23R4_365}      MRBTS-10175_TL365_golden_scf_23R4.xml
${golden_scf_24R2_374}      MRBTS-11006_TL374_golden_SCF_24R2.xml
${golden_scf_24R3_365}      MRBTS-10175_TL365_golden_scf_24R3.xml
${golden_scf_24R3_374}      MRBTS-11006_TL374_golden_SCF_24R3.xml
${golden_scf_25R1_365}      MRBTS-10175_TL365_golden_scf_25R1.xml
${golden_scf_25R1_374}      MRBTS-11006_TL374_golden_SCF_25R1.xml

${golden_scf_24R2_CA}         MRBTS-11006_TL374_golden_SCF_24R2_CA.xml

${nrcellid_cell1}           1
${nrcellid_cell2}           2
${bipscript_path}           /opt/workspace/biplog_script/
${luashark_path}            /opt/workspace/luashark/generated_luashark/luashark.lua
${MRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${NRBTS_ID}                 ${tl.gnbs[0].instance_id}
${enb_dist_LNCEL1_cellBarred}            MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1/SIB-0
${enbcell_dist}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_cellBarred}           cellBarred        #administrativeState
${swconfig_paths}           /opt/workspace/SCF/8247/swconfig.txt
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/
${enb_instance}             ${tl.enbs[0].instance_id}
${Empty_Para}                    'NULL'
${TestPC_addr}                  ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}              ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}              ${tl.test_pc.default_ssh_connection_details.password}
${WEBUI_COAM}               https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}                ${tl.gnbs[0].cu.oam_http_connection_details.password}
@{gnb_ips_h}                ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
@{ALLOWED_FAULT_ID}          1250    1300    1000    200     1200     1470    4681
@{allow_fault_list}          7107    4681
@{gnb_list}                        ${0}
##multiUE##
${NSA_UE_MODE}              NSA
${SA_UE_MODE}               SA
${NSA_attach_mode}          5G_NSA
${SA_attach_mode}           5G_SA
${NSA_nettype}              NSA
${SA_nettype}               AUTO
${NSA_apn_addr}             dxdata1
${SA_apn_addr}              wap2.nokia.com
${ue_type_0}                ${tl.ues[0].capabilities[0]}
${ue_type_1}                ${tl.ues[0].capabilities[1]}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
${Multi_dl_throughput}      850Mbits/sec
${dl_tput_multiue_10175}          850M
${dl_tput_multiue_3741199999}          1100M
${dl_throughput}            1350M
${DL_TIME}                  9999
${DL_LENGTH}                1024B
${beamweight_path}               /ffs/run/config/
${beamweight_name_cloud}          CP_beamSet_6_10318_169050114.json
${bpf_path}                      /tmp/bpf/
${bpf_name_cloud}                 475294A_AE_QV.gz
${ungzip_bpf_name_cloud}          475294A_AE_QV
${bpf_name_xml_cloud}             AE_QV.xml
${aa_sys_addr_10175}               0xA39EFE2
${aa_sys_addr_3741199999}               0x0A39EFD8
${aa_sys_addr_cloud}             0xA39821B

*** Keywords ***
Common Suite Setup for COAM 8247
    [Arguments]    ${ModifySCF_Beforecommission}=True
    ...            ${ParamterToModify}='NULL'
    ...            ${Is_Swconfig}=True
    Common Suite Setup for COAM
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    ${physical_cellid}    Get physCellId from SCF     golden_scf_name=MRBTS-${MRBTS_ID}_${release_info}.xml
    ...                                               gnb_index=${0}
    ...                                               cell_index=${37401}
    ...                                               scf_path=/opt/workspace/SCF/
    set suite variable    ${physical_cellid}
    Common Case TestLine Setup
    ...                            ModifySCF_Beforecommission=${ModifySCF_Beforecommission}
    ...                            golden_scf_name=MRBTS-${MRBTS_ID}_${release_info}.xml
    ...                            ParamterToModify=${ParamterToModify}
    ...                            Is_Swconfig=${Is_Swconfig}
    ...                            swconfig_file=${swconfig_paths}
    ...                            swconfig_modify=${add_new_flags}

Get patternIdDict From CPRT Logs for special tl
    [Documentation]   Author: liu jia
    ...                Desription: Get patternIdDict from cprt log.
    ...                PREDEFINED beam, PMI beam and DFT beam.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=CellParametersReq
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfoList From CPRT Logs
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    set variable
    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n.*CellParametersReq(.*?)ruSupportsExtType6
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1    2
    ${patternIdInfoList_len}    get length    ${patternIdInfoList_log}
    ${patternIdInfoList_log2}    Run Keyword If    ${patternIdInfoList_len} == ${0}
    ...    Fetch PatternIdInfoList From CPRT Logs    cell_idx=${cell_idx}    connection=${connection}
    ${patternIdInfoList_log}    set variable if    ${patternIdInfoList_len} == ${0}   ${patternIdInfoList_log2}    ${patternIdInfoList_log}
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
    ${cprtPatternIdDict}    Fetch patternId Of Different Beams From Output for special tl    patternIdInfoList_log=${patternIdInfoList_log}
    [Return]    ${cprtPatternIdDict}

Fetch patternId Of Different Beams From Output for special tl
    [Documentation]   Author: liujia
    ...                Desription: Get patternIdInfoList from cprt log.
    [Arguments]    ${patternIdInfoList_log}    ${predefined_beam}=PREDEFINED    ${PMI_beam}=DYNAMIC    ${DFT_beam}=DFTNORMAL
    &{cprtPatternIdDict}    Create Dictionary
    ${beamSetType_list}    create list    ${predefined_beam}    ${PMI_beam}    ${DFT_beam}
    FOR  ${beamSetType}  IN  @{beamSetType_list}
     ${patternIdMin_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.:(\\d+)
     ${patternIdMax_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.*?patternIdMax.:(\\d+)
     ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
     ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
     ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
     ${patternId_list}    Remove Duplicates    ${patternId_list}
     Set To Dictionary    ${cprtPatternIdDict}    ${beamSetType}    ${patternId_list}
    END
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} == ${0}     Fetch patternId For DFT Beam for special tl
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} == ${0}    Fetch patternId For PMI Beam
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch patternId For DFT Beam for special tl
    [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}.*<LOG.*>ernIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}.*<LOG.*>ernIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    [Return]    ${cprtPatternIdDict}

Check after online_modify_parameter GNB cell not restart
    [Arguments]    ${PARA_Modify_online}    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${cell_type}=nr
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    COAM Update Several Parameters Via Rest Api    connection=${connection}
    ...                                            parameters_to_update_via_api=${PARA_Modify_online}
    Verify all cells should be onair    cell_type=${cell_type}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

attach UE and capture wiresharklog
    [Arguments]    ${wiresharklog}    ${ue_num}=${1}    ${attach_mode}=${SA_attach_mode}    ${ue_mode}=${SA_UE_MODE}    ${nettpye}=${SA_nettype}
    ...     ${apn_address}=${SA_apn_addr}    ${4G_check}=False
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    Run Keyword And Continue On Failure
    ...     UE attach with Diff TL    ue_num=${ue_num}    attach_mode=${attach_mode}    ue_mode=${ue_mode}    nettpye=${nettpye}
    ...                               apn_address=${apn_address}    4G_check=${4G_check}
    sleep    1s
    ${cpif_log_path}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

UE attach with Diff TL
    [Arguments]    ${ue_num}=${None}    ${attach_mode}=${SA_attach_mode}    ${ue_mode}=${SA_UE_MODE}   ${nettpye}=${SA_nettype}
    ...    ${apn_address}=${SA_apn_addr}    ${ue_index}=${0}    ${4G_check}=False
    Run Keyword If    '${MRBTS_ID}' == '10175'    Multi-UE attach and Verify    ue_num=${ue_num}    attach_mode=${attach_mode}
    ...                                           ue_mode=${ue_mode}    nettpye=${nettpye}    apn_address=${apn_address}    UE_TYPE=${ue_type_1}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...    UE attach for QCOM and verify with retry    ue_type=${ue_type_0}    ue_index=${ue_index}    4G_check=${4G_check}

UE start DLData Traffic with Diff TL
    [Arguments]    ${ue_num}=${None}    ${ue_mode}=${None}    ${apn_address}=${None}
    ...            ${ue_index}=${0}
    Run Keyword If    '${MRBTS_ID}' == '10175'    Multi-UEs start DLData Traffic    ue_num=${ue_num}    ue_mode=${ue_mode}
    ...    apn_address=${apn_address}    throughput=${Multi_dl_throughput}    ue_type=${ue_type_1}    duration=${DL_TIME}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${DL_PORT}    ue_index=${ue_index}    process_num=${1}    ue_type=${ue_type_0}

UE prepare with Power UE
    [Arguments]     ${ue_type}=${ue_type_0}    ${ue_index}=${0}    ${reset_sol}=none
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...      power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    reset_sol=${reset_sol}
    Run Keyword If    '${MRBTS_ID}' == '10175'     Prepare MultiUE with client


Start Traffic And Capture Biplog
    [Arguments]     ${apn_address}=${SA_apn_addr}    ${ue_mode}=${SA_UE_MODE}    ${dl_throughput}=${dl_throughput}
    ...    ${dlexpect_tp}=${Expect_dl_enable}    ${ue_num}=1    ${duration}=1m    ${target_dir}=${epc_log_path}
    ...    ${target_file_name}=l1l2bip
    Start UE traffic and check tput sg3    apn_address=${apn_address}    throughput=${dl_throughput}    ue_mode=${ue_mode}
    ...                                    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}    ue_num=${ue_num}    duration=${duration}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    target_dir=${target_dir}    target_file_name=${target_file_name}
    [Return]     ${bip}

Start UE traffic and check tput sg3
    [Arguments]     ${ue_num}=1     ${apn_address}=${SA_apn_addr}
    ...    ${ue_mode}=${SA_UE_MODE}
    ...    ${cellid}=${nrcellid}    ${dlexpect_tp}=@{Expect_dl_enable[0]}    ${duration}=1m
    ...    ${nr_phy_cell_ids}=51    ${target_dir}=${TS_CASE_LOG_PATH}
    UE start DLData Traffic with Diff TL    ue_num=${ue_num}    ue_mode=${ue_mode}    apn_address=${apn_address}
    sleep    30s
    log to console    check tput with nrcellid
    ${tput_status}=    Run Keyword And Return Status
    ...    Check Dl traffic with nrcellid in Diff    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}    duration=${duration}
    Run Keyword If     '${tput_status}' == '${False}'    capture and save TTItrace
    ...                                                  nr_phy_cell_ids=${nr_phy_cell_ids}    target_dir=${target_dir}
    Should Be True     '${tput_status}' == '${True}'

capture and save TTItrace
    [Arguments]    ${nr_phy_cell_ids}=51    ${target_dir}=${TS_CASE_LOG_PATH}
    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_1
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    target_dir=${target_dir}

Check DL traffic and return status
    [Arguments]     ${dlexpect_tp}    ${cellid}=${nrcellid}    ${duration}=1m
    Run Keyword and return status    Check Dl traffic with nrcellid in Diff    dlexpect_tp=${dlexpect_tp}    cellid=${cellid}    duration=${duration}

Check Dl traffic with nrcellid in Diff
    [Arguments]     ${dlexpect_tp}    ${cellid}=${nrcellid}    ${duration}=1m
    Run Keyword If    '${MRBTS_ID}' == '10175'
    ...    DL Tput collect and check with nrcellid    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}    duration=${duration}    ue_type=${ue_type_1}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...    DL Tput collect and check with nrcellid    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}    duration=${duration}    ue_type=${ue_type_0}

Multi-UEs start DLData Traffic
    [Arguments]    ${ue_num}    ${ue_mode}    ${apn_address}    ${throughput}    ${ue_type}    ${duration}
    FOR    ${i}    IN RANGE    ${ue_num}
        log to console      Start ue${i} traffic    console = yes
        power_ue.Start traffic    ue_index=${i}    direction=dl    apn_address=${apn_address}
        ...                       throughput=${throughput}    duration=${duration}    ue_type=${ue_type}    ue_mode=${ue_mode}
    END

Attach Commercial UE and capture wiresharklog
    [Arguments]    ${wiresharklog}     ${4g_check}=${False}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    Power UE Attach and Verify attach for Commercial    4g_check=${4g_check}
    sleep    1s
    ${cpif_log_path}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}
    [Return]     ${cpif_log_path}

Power UE Attach and Verify attach for Commercial
    [Arguments]    ${4g_check}    ${gnb_index}=${0}    ${ue_type}=${ue_type_1}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${gnb_index}
    ...                       4G_check=${4g_check}    5Gstatus=PASS

Power UE Detach for Commercial
    [Arguments]    ${ue_type}=${ue_type_1}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE check throughput with nrcellid
    [Arguments]    ${dlexpect}    ${ue_type}=${ue_type_0}   ${cellid}=${nrcellid}
#    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${dl_tp_l2l0}    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    cellid=${cellid}    sleep_time=${20}
    [Return]     ${dl_tp_l2l0}

Capture biplog and download
    [Arguments]     ${target_dir}=${epc_log_path}    ${target_file_name}=l1l2bip    ${capture_time}=15s
    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${target_dir}
    ...                                                      target_file_name=${target_file_name}
    ...                                                      times=5s
    sleep     ${capture_time}
    ${tmpbip}=      Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${target_dir}
    ...                                                                     target_file_name=${target_file_name}
    Set Test Variable    ${tmpbip}    ${tmpbip[0]}
    [Return]     ${tmpbip}



Capture BIPlog with gnb_logs and Download
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=2
    ...            ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    Capture Logs With gNB_logs_exe File    bbmod_slots=${bbmod_slots}      duration=${duration}
    ...            gnb_logs_script_path=${gnb_logs_script_path}
    ...            gnb_index=${gnb_index}       du_index=${du_index}      log_type=${log_type}
    ${biplogs}    Get Captured BIP File from UTE    gnb_logs_script_path=${gnb_logs_script_path}
    ...            target_dir=${epc_log_path}     gnb_index=${gnb_index}     du_index=${du_index}      log_type=${log_type}
    [Return]     ${biplogs[0]}

modify the parameters for case
    [Arguments]    ${parameters}    ${is_x2_check_from_enb_needed}=${False}     ${gnb_type}='SA'
    Common Case TestLine Setup    ModifySCF_Aftercommission=True
    ...                           Modify_Para_Online=${parameters}
    ...                           gnb_type=${gnb_type}
    ...                           is_x2_check_from_gnb_needed=${is_x2_check_from_enb_needed}


stop traffic and detach UE
    [Arguments]     ${ue_num}=1
    Run Keyword If    '${MRBTS_ID}' == '10175'
    ...                Multi UE Detach And Stop Traffic    ue_num=${ue_num}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...                Power UE stop dl traffic and detach    dl_port=${DL_PORT}    ue_type=${ue_type_0}    ue_index=${0}


Detach UE without traffic
    [Arguments]     ${ue_num}=1    ${ue_index}=${0}
    Run Keyword If    '${MRBTS_ID}' == '10175'    Multi UE Detach    ue_num=${ue_num}    ue_type=${ue_type_1}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...    Power UE ODetached     ue_type=${ue_type_0}    ue_index=${ue_index}

Power UE ODetached
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

stop traffic and MCS teardown
    [Arguments]    ${mcs_type}    ${ue_num}=1
    Run Keyword And Ignore Error    stop traffic and detach UE    ue_num=${ue_num}
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}

########----------- new way for multiue ------------########

attach UE and capture wiresharklog with new way
    [Arguments]    ${wiresharklog}    ${UE_mode}=${SA_attach_mode}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    MultiUE one Attach with client    UE_mode=${UE_mode}
    [Teardown]       Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

Start Traffic And Capture Biplog with new way
    [Arguments]     ${dlexpect_tp}=${Expect_dl_enable}    ${target_dir}=${epc_log_path}    ${aa_sys_addr}=${aa_sys_addr}
    ...             ${dl_throughput}=${dl_tput_multiue}    ${target_file_name}=l1l2bip
    ...     ${duration}=3m    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...     ${nr_phy_cell_ids}=51    ${target_dir}=${epc_log_path}
    Start UE traffic and check tput with new way    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}
    ...                                             aa_sys_addr=${aa_sys_addr}      dl_throughput=${dl_throughput}
    ...                                             nr_phy_cell_ids=${nr_phy_cell_ids}    target_dir=${TS_CASE_LOG_PATH}
    ...    duration=${duration}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    target_dir=${target_dir}    target_file_name=${target_file_name}
    [Return]     ${bip}

Start UE traffic and check tput with new way
    [Arguments]     ${cellid}=${nrcellid}    ${dlexpect_tp}=@{Expect_dl_enable[0]}    ${aa_sys_addr}=${aa_sys_addr}
    ...             ${dl_throughput}=${dl_tput_multiue}
    ...     ${duration}=3m    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${nr_phy_cell_ids}=51    ${target_dir}=${TS_CASE_LOG_PATH}
    Start MUE dltraffic with appserver      ue_addr=${upd_info}[Param][IP]     dl_port=${DL_PORT}    dl_throughput=${dl_throughput}
    sleep    30s
    log to console    \n *** check tput with nrcellid *** \n
    ${tput_status}=    Run Keyword And Return Status
    ...    Check Dl traffic with nrcellid in Diff with new way    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}     aa_sys_addr=${aa_sys_addr}
    ...    duration=${duration}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    Run Keyword If     '${tput_status}' == '${False}'    capture and save TTItrace
    ...                                                  nr_phy_cell_ids=${nr_phy_cell_ids}    target_dir=${target_dir}
    Should Be True     '${tput_status}' == '${True}'

Check Dl traffic with nrcellid in Diff with new way
    [Arguments]     ${dlexpect_tp}    ${cellid}=${nrcellid}    ${aa_sys_addr}=${aa_sys_addr}
    ...    ${gnb_index}=0    ${du_index}=0    ${host}=${EMPTY}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${duration}=3m    ${target_avg_percent}=0.95    ${min_percent}=0.85
    Check one multiUE traffic with aasyslog    target_throughput=${dlexpect_tp}    cellid=${cellid}
    ...      duration=${duration}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    Run Keyword And Ignore Error
    ...    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    ...                      aa_sys_addr=${aa_sys_addr}
    ...                      host=${host}
    ...                      username=${username}
    ...                      password=${password}

stop traffic and detach UE with new way
    [Arguments]    ${ue}=${uegroup}[0]
    Stop traffic with appserver    iperf_port=${DL_PORT}
    sleep    1s
    Detach MultiUE and stoplog    ue=${ue}

stop traffic and detach UE without stop log
    [Arguments]    ${ue}=${uegroup}[0]
    Stop traffic with appserver    iperf_port=${DL_PORT}
    sleep    1s
    Detach MultiUE    ue=${ue}

stop traffic and MCS teardown with new way
    [Arguments]    ${mcs_type}
    Run Keyword And Ignore Error    stop traffic and detach UE with new way
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}

Detach UE without traffic with new way
    Detach MultiUE    ue=${uegroup}[0]

attach multiUEs and capture wiresharklog
    [Arguments]    ${wiresharklog}    ${UE_mode}=${SA_attach_mode}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    MultiUEs Attach with client    UE_mode=${UE_mode}
    sleep    5s
    [Teardown]       Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

Start multiUEs Traffic And Capture Biplog
    [Arguments]     ${dl_tput_multiue}=${dl_tput_multiue}    ${UE_define}=NULL    ${bbmod_slots}=1
    Start multiUEs traffic with appserver    dl_tput_multiue=${dl_tput_multiue}    UE_define=${UE_define}
    log to console    start to cpature biplog
    ${bip}=    Capture BIPlog with gnb_logs and Download    bbmod_slots=${bbmod_slots}
    [Return]     ${bip}

#####-------------------MCS---------------------#######
HAOJIN MCS change UE Position
    [Arguments]     ${mcs_type}    ${begin_output_port_1}    ${end_output_port_2}    ${vertical_angle_1}    ${horizontal_angle_1}
    ...    ${begin_output_port_3}    ${end_output_port_4}
    ...    ${vertical_angle_2}     ${horizontal_angle_2}
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_1}    end_output_port=${end_output_port_2}     input_group_id=${0}
    ...    vertical_angle=${vertical_angle_1}
    ...    horizontal_angle=${horizontal_angle_1}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    mcs_common.Set Phases According To Angles For Input And Output Groups    mcs_type=${mcs_type}
    ...    begin_output_port=${begin_output_port_3}    end_output_port=${end_output_port_4}     input_group_id=${0}
    ...    vertical_angle=${vertical_angle_2}
    ...    horizontal_angle=${horizontal_angle_2}    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}


HAOJIN MCS SETUP AND SET ATT for UE0
    [Arguments]    ${mcs_type}    ${P1_out}    ${P2_out}    ${vertical_1}    ${horizontal_1}    ${P3_out}    ${P4_out}
    ...    ${horizontal_2}    ${vertical_2}    ${att_value}
    ...    ${vertical_distance}=${2.1}    ${horizontal_distance}=${0.5}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    HAOJIN MCS change UE Position    mcs_type=${mcs_type}    begin_output_port_1=${P1_out}    end_output_port_2=${P2_out}
    ...    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_3=${P3_out}    end_output_port_4=${P4_out}
    ...    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    ...    vertical_distance=${vertical_distance}    horizontal_distance=${horizontal_distance}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${13}    end_output_port=${16}

HAOJIN MCS SETUP AND SET ATT for MultiUE
    [Arguments]    ${mcs_type}    ${att_value_UE0}    ${att_value_UE1}
    ...    ${P1_out}    ${P2_out}    ${P3_out}    ${P4_out}    ${vertical_1}    ${horizontal_1}    ${horizontal_2}    ${vertical_2}
    ...    ${P5_out}    ${P6_out}    ${P7_out}    ${P8_out}    ${vertical_3}    ${horizontal_3}    ${horizontal_4}    ${vertical_4}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HAOJIN
    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P1_out}    end_output_port_2=${P2_out}    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_3=${P3_out}    end_output_port_4=${P4_out}    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    HAOJIN MCS change UE Position    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P5_out}    end_output_port_2=${P6_out}    vertical_angle_1=${vertical_3}    horizontal_angle_1=${horizontal_3}
    ...    begin_output_port_3=${P7_out}    end_output_port_4=${P8_out}    vertical_angle_2=${vertical_4}    horizontal_angle_2=${horizontal_4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0}
    ...    begin_output_port=${13}    end_output_port=${16}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1}
    ...    begin_output_port=${9}    end_output_port=${12}

HBTE MCS SETUP AND SET ATT for MultiUE
    [Arguments]    ${mcs_type}    ${att_value_UE0}    ${att_value_UE1}
    ...    ${horizontal_angle_1}    ${horizontal_angle_2}
    ...    ${horizontal_angle_3}    ${horizontal_angle_4}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    vendor=HBTE
    HBTE MCS change UE Phases     mcs_type=${mcs_type}
    ...    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${horizontal_angle_1}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${horizontal_angle_2}
    HBTE MCS change UE Phases     mcs_type=${mcs_type}
    ...    vertical_angle=${96}
    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${horizontal_angle_3}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${horizontal_angle_4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE0}
    ...    begin_output_port=${1}    end_output_port=${4}
    mcs_common.Set Odd And Even ATT For Output Port    mcs_type=${mcs_type}    att_value=${att_value_UE1}
    ...    begin_output_port=${5}    end_output_port=${8}

TOPYOUNG MCS SETUP AND SET ATT
    [Arguments]    ${mcs_type}    ${att_value}    ${P1_out}    ${P2_out}    ${vertical_1}    ${horizontal_1}    ${P3_out}    ${P4_out}
    ...    ${vertical_2}    ${horizontal_2}    ${ATT_begin}=${1}    ${ATT_end}=${4}
    mcs_common.Setup MCS    mcs_type=${mcs_type}
    TOPYOUNG MCS change UE position    mcs_type=${mcs_type}
    ...    begin_output_port_1=${P1_out}    end_output_port_1=${P2_out}    vertical_angle_1=${vertical_1}    horizontal_angle_1=${horizontal_1}
    ...    begin_output_port_2=${P3_out}    end_output_port_2=${P4_out}    vertical_angle_2=${vertical_2}    horizontal_angle_2=${horizontal_2}
    mcs_common.Set Odd And Even ATT By Output_port    mcs_type=${mcs_type}    att_value=${att_value}
    ...    begin_output_port=${ATT_begin}    end_output_port=${ATT_end}



Set suite variable for ${case_key}
    Set Suite Variable    ${TestLine_ID}    BTS_${MRBTS_ID}
    ${release_info}    Get sagnb release
    Run Keyword And Ignore Error    Set Suite Variable    ${golden_scf}     ${8247_store['${case_key}']['${TestLine_ID}']['golden_scf']}
    Run Keyword And Ignore Error    Set Suite Variable    ${golden_scf}     ${8247_store['${case_key}']['${release_info}']['golden_scf']}
    Run Keyword And Ignore Error    set suite variable    ${ParamterToModify}     ${8247_store['${case_key}']['${TestLine_ID}']['ParamterToModify']}
    Run Keyword And Ignore Error    set suite variable    ${ParamterToModify}     ${8247_store['${case_key}']['${release_info}']['ParamterToModify']}
    Run Keyword And Ignore Error    set suite variable    ${ParameterToDelete}    ${8247_store['${case_key}']['${TestLine_ID}']['ParameterToDelete']}
    Run Keyword And Ignore Error    set suite variable    ${ParameterToDelete}
    ...                                                   ${8247_store['${case_key}']['${release_info}']['ParameterToDelete']}
    Run Keyword And Ignore Error    set suite variable    ${ListToAdd}             ${8247_store['${case_key}']['${TestLine_ID}']['ListToAdd']}
    Run Keyword And Ignore Error    set suite variable    ${ListToAdd}             ${8247_store['${case_key}']['${release_info}']['ListToAdd']}
    Run Keyword And Ignore Error    set suite variable    ${enb_dist_name}           ${8247_store['${case_key}']['${TestLine_ID}']['enb_dist_name']}
    Run Keyword And Ignore Error    set suite variable    ${enb_dist_name}           ${8247_store['${case_key}']['${release_info}']['enb_dist_name']}
    Run Keyword And Ignore Error    set suite variable    ${dlexpect_tp}            ${8247_store['${case_key}']['${TestLine_ID}']['dlexpect_tp']}
    Run Keyword And Ignore Error    set suite variable    ${dlexpect_tp}            ${8247_store['${case_key}']['${release_info}']['dlexpect_tp']}
    Run Keyword And Ignore Error    set suite variable    ${cellid}              ${8247_store['${case_key}']['${TestLine_ID}']['cellid']}
    Run Keyword And Ignore Error    set suite variable    ${cellid}              ${8247_store['${case_key}']['${release_info}']['cellid']}
    Run Keyword And Ignore Error    set suite variable    ${att_value}              ${8247_store['${case_key}']['${TestLine_ID}']['att_value']}
    Run Keyword And Ignore Error    set suite variable    ${ListParamterToModify}
    ...                                                   ${8247_store['${case_key}']['${TestLine_ID}']['ListParamterToModify']}
    Run Keyword And Ignore Error    set suite variable    ${ListParamterToModify}
    ...                                                   ${8247_store['${case_key}']['${release_info}']['ListParamterToModify']}
    Run Keyword And Ignore Error    set suite variable    ${end_output_port}
    ...                                                   ${8247_store['${case_key}']['${TestLine_ID}']['end_output_port']}
    Run Keyword And Ignore Error    set suite variable    ${begin_output_port}
    ...                                                   ${8247_store['${case_key}']['${TestLine_ID}']['begin_output_port']}
    Run Keyword And Ignore Error    set suite variable    ${swconfig_modify}
    ...                                                   ${8247_store['${case_key}']['${TestLine_ID}']['swconfig_modify']}
    Run Keyword And Ignore Error    set suite variable    ${swconfig_modify}
    ...                                                   ${8247_store['${case_key}']['${release_info}']['swconfig_modify']}
    Run Keyword And Ignore Error    set suite variable    ${online_modify}
    ...                                                   ${8247_store['${case_key}']['${TestLine_ID}']['online_modify']}
    Run Keyword And Ignore Error    set suite variable    ${PARA_modify}
    ...                                                   ${8247_store['${case_key}']['${TestLine_ID}']['PARA_modify']}
    Run Keyword And Ignore Error    set suite variable    ${typeUE}              ${8247_store['${case_key}']['${TestLine_ID}']['typeUE']}
    Run Keyword And Ignore Error    set suite variable    ${aa_sys_addr}         ${8247_store['${case_key}']['${TestLine_ID}']['aa_sys_addr']}
    Run Keyword And Ignore Error    set suite variable    ${dl_tput_multiue}     ${8247_store['${case_key}']['${TestLine_ID}']['dl_tput_multiue']}


Get BeampatternIdDict From CPRT Logs new version
    [Documentation]
    ...                Desription: before get pattern ID info, the text data is simplified.
    ...                PREDEFINED beam, PMI beam and DFT beam.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=CellParametersReq    ${patternIdList_index}=${0}
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfoList From CPRT Logs
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_delete_info}    set variable    </LOG_SCRAM_68>\\r\\r\\n(.*?)CellParametersReq..<LOG_SCRAM_68>
    ${pattern_delete}    get regexp matches    ${patternIdInfoList_log}    ${percell_delete_info}
    FOR    ${n}    IN    @{pattern_delete}
      ${pattern_new}    Remove String    ${patternIdInfoList_log}    ${n}
      set test variable    ${patternIdInfoList_log}    ${pattern_new}
    END
    ${percell_patternIdInfoList_exp}    set variable
    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)..ruMaxRemasks*
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}
    ${patternIdInfoList_len}    get length    ${patternIdInfoList_log}
    ${cprtPatternIdDict}    Fetch patternId Of Different Beams From Output
    ...    patternIdInfoList_log=${patternIdInfoList_log}[${patternIdList_index}]
    [Return]    ${cprtPatternIdDict}

Get BeampatternIdDict From CPRT Logs
    [Documentation]
    ...                Desription: Get patternIdDict from cprt log.
    ...                PREDEFINED beam, PMI beam and DFT beam.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=CellParametersReq
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfoList From CPRT Logs
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    set variable
    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n.*CellParametersReq(.*?)ruMaxRemasks*
#    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n.*CellParametersReq(.*?)\\r\\r\\n.*CellParametersReq(.*?)ruMaxRemasks*
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1    2
    ${patternIdInfoList_len}    get length    ${patternIdInfoList_log}
    ${patternIdInfoList_log2}    Run Keyword If    ${patternIdInfoList_len} == ${0}
    ...    Fetch PatternIdInfoList From CPRT Logs    cell_idx=${cell_idx}    connection=${connection}
    ${patternIdInfoList_log}    set variable if    ${patternIdInfoList_len} == ${0}   ${patternIdInfoList_log2}    ${patternIdInfoList_log}
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
    ${cprtPatternIdDict}    Fetch BeampatternId Of Different Beams From Output    patternIdInfoList_log=${patternIdInfoList_log}
    [Return]    ${cprtPatternIdDict}


Fetch BeampatternId Of Different Beams From Output
    [Documentation]   Author: Liu jia
    ...                Desription: Get patternIdInfoList from cprt log.
    [Arguments]    ${patternIdInfoList_log}    ${predefined_beam}=PREDEFINED    ${PMI_beam}=DYNAMIC    ${DFT_beam}=DFTNORMAL
    ...    ${DFT_muted_beam}=DFTNORMALMUTED    ${DFT_TAPERING_beam}=DFTTAPERING    ${PMI_muted_beam}=DYNAMICMUTED
    &{cprtPatternIdDict}    Create Dictionary
    ${beamSetType_list}    create list    ${predefined_beam}    ${PMI_beam}    ${DFT_beam}    ${DFT_muted_beam}
    ...    ${DFT_TAPERING_beam}    ${PMI_muted_beam}
    FOR  ${beamSetType}  IN  @{beamSetType_list}
     ${patternIdMin_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.:(\\d+)
     ${patternIdMax_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.*?patternIdMax.:(\\d+)
     ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
     ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
     ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
     ${patternId_list}    Remove Duplicates    ${patternId_list}
     Set To Dictionary    ${cprtPatternIdDict}    ${beamSetType}    ${patternId_list}
    END
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch BeampatternId For DFT Beam
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch BeampatternId For PMI Beam
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    ${TAPERINGbeam_len}    get length    ${cprtPatternIdDict['${DFT_TAPERING_beam}']}
    Run Keyword If    ${TAPERINGbeam_len} < ${2}    Fetch BeampatternId For TAPERING Beam
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_TAPERING_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For TAPERING Beam
    [Documentation]    Author: zhang qingqing
    ...                Desription: Get patternId for TAPERING beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${DFT_beam}=DFTTAPERING
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}...patternIdM</LOG.*>in.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}...patternIdM.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}    ${patternId_list}
    ${TAPERINGbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${TAPERINGbeam_len} < ${2}    Fetch BeampatternId For TAPERING Beam again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For TAPERING Beam again
    [Documentation]    Author: zhang qingqing
    ...                Desription: Get patternId for TAPERING beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${DFT_beam}=DFTTAPERING
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin</LOG.*>.*?>.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}    ${patternId_list}
    ${TAPERINGbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${TAPERINGbeam_len} < ${2}    Fetch BeampatternId For TAPERING Beam again and again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For TAPERING Beam again and again
    [Documentation]    Author: zhang qingqing
    ...                Desription: Get patternId for TAPERING beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${DFT_beam}=DFTTAPERING
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin.</LOG.*>.*?>:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}...patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}    ${patternId_list}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For DFT Beam
    [Documentation]   Author: Liu jia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}...patternIdMi.*<LOG.*>..(\\d+)..patternIdMax
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}...patternIdMi.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}    Fetch BeampatternId For DFT Beam again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For DFT Beam again
       [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}.*<LOG.*>.*Min.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}.*<LOG.*>.*Min.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}    Fetch BeampatternId For DFT Beam CLOUD again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For PMI Beam
    [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...${PMI_beam}.*<LOG.*>in.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${PMI_beam}.*<LOG.*>in.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch BeampatternId For PMI Beam again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For PMI Beam again
    [Documentation]   Author: Liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...${PMI_beam}...patternIdMi.*<LOG.*>.*?(\\d+)..patternIdMax
    ${patternIdMax_exp}    set variable    beamSetType...${PMI_beam}...patternIdMi.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch BeampatternId For PMI Beam CLOUD
    ...    patternIdInfoList_log=${patternIdInfoList_log}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Get BestBeamPowerOffset from pdschsendreq
    [Arguments]    ${file_path}     ${filter}=dldata_pdschsendreql1sw    ${bestbeam_xpath}=DlData_PdschGrantL1sw.bestBeamPowerOffset
    ${filter_illegal_value}    Catenate    3gpp.rnti != 65535 &&
    ...                                    3gpp.rnti != 65534
    ${BestBeamPowerOffset}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=${filter_illegal_value}
    ...    xpath=.//${bestbeam_xpath}
    ${BestBeamPowerOffset}    Remove Duplicates    ${BestBeamPowerOffset}
    [Return]    ${BestBeamPowerOffset}

Get csiBestBeamPowerOffset from csirssendreq
    [Arguments]    ${file_path}     ${csirs_filter}= DlData_CsiRsResourceL1sw_t.csiRsConfig    ${csirs_config}=4     ${filter}=dldata_csirssendreql1sw
    ...            ${csirs_xpath}=DlData_CsiRsResourceL1sw_t.csiBestBeamPowerOffset
    ...            ${pci_id}=${pci_id}
    ${pci_filter_name}    run keyword if    '${release_info}' == 'SBTS25R1_ENB_0000' or '${release_info}' == 'SBTS24R3_ENB_0000'
    ...    set variable    DlData_CsiRsResource_t.csiRsScramblingSequenceInt
    ...    ELSE    set variable     DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt
    ${csiBestBeamPowerOffset}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=${csirs_filter} == ${csirs_config} and ${pci_filter_name} == ${pci_id}
    ...    xpath=.//${csirs_xpath}
    ${csiBestBeamPowerOffset}    Remove Duplicates    ${csiBestBeamPowerOffset}
    [Return]    ${csiBestBeamPowerOffset}

Check bestbeampoweroffset
    [Arguments]    ${file_path}     ${csirsresoure_filter}= DlData_CsiRsResourceL1sw_t.csiRsConfig    ${csirs_filter}=dldata_csirssendreql1sw
    ...            ${csirs_xpath}=DlData_CsiRsResourceL1sw_t.csiBestBeamPowerOffset
    ...            ${bestbeam_xpath}=DlData_PdschGrantL1sw.bestBeamPowerOffset
    ...            ${bestbeam_filter}=dldata_pdschsendreql1sw
    ...            ${pci_id}=51
    ${BestBeamPowerOffset}=    Get BestBeamPowerOffset from pdschsendreq    file_path=${file_path}    filter=${bestbeam_filter}
    ...                                                                     bestbeam_xpath=${bestbeam_xpath}
    ${csiBestBeamPowerOffset}=    Get csiBestBeamPowerOffset from csirssendreq    file_path=${file_path}    csirs_filter=${csirsresoure_filter}
    ...                                                                           filter=${csirs_filter}    csirs_xpath=${csirs_xpath}
    ...                                                                           pci_id=${pci_id}
    Should Be True    '${BestBeamPowerOffset[0]}' > '${0}' and '${BestBeamPowerOffset[0]}' < '${61}'
    Should Be True    '${csiBestBeamPowerOffset[0]}' > '${0}' and '${csiBestBeamPowerOffset[0]}' < '${61}'

Get PM counter for 10602
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_sum}       Set Variable          0
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${counter_value}[0]
        run keyword if     '${counter_value_sum}' > '${0}'     exit for loop
    END
    [Teardown]    COAM Teardown gnb connections

Check PM counter for 10602
    [Arguments]    ${counter_id}    ${counter_dic_path}    ${gnb_index}=${0}
    wait until keyword succeeds    10min    30s    Get PM counter for 10602    counter_id=${counter_id}
    ...    dic_path=${counter_dic_path}    gnb_index=${gnb_index}

Get CSIRS_nrofPorts from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_nrofPorts_0}    Check Target Item Value on CPIF Tcpdump Cloud UTE
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ...            attribute_name=showname
    ${num}     get length    ${CSIRS_nrofPorts_0}
    ${CSIRS_nrofPorts}=    Create List
    FOR    ${i}    IN RANGE    ${num}
       ${CSIRS_nrofPorts_1}=    String.Split String    ${CSIRS_nrofPorts_0[${i}]}    :${SPACE}
       ${CSIRS_nrofPorts_2}=    String.Split String    ${CSIRS_nrofPorts_1[1]}    ${SPACE}(
       Append To List    ${CSIRS_nrofPorts}    ${CSIRS_nrofPorts_2[0]}
    END
    [Return]    ${CSIRS_nrofPorts}

Get CSIRS_cdm_Type from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_cdm_Type}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.cdm_Type
    [Return]    ${CSIRS_cdm_Type}

Get CSIRS_n1_n2 from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_n1_n2}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.n1_n2
    [Return]    ${CSIRS_n1_n2}

Get CSIRS_density from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_density}    Check Target Item Value on CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.density
    [Return]    ${CSIRS_density}

Get LongPucch_format from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.pucch_Config == 1
    ${LongPucch_format}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.format
    [Return]    ${LongPucch_format}

Get DRX_StarOffset from CPIF
    [Arguments]    ${file_path}
    ${DRX_LongCycle}=    Get DRX_LongCycle from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${DRX_StarOffset_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_LongCycleStartOffset/nr-rrc.${DRX_LongCycle}
    [Return]    ${DRX_StarOffset_0[0]}

Get DRX_LongCycle from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${DRX_LongCycle_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_LongCycleStartOffset
    ...            attribute_name=showname
    ${DRX_LongCycle_1}=    String.Split String    ${DRX_LongCycle_0[0]}    :${SPACE}
    ${DRX_LongCycle_2}=    String.Split String    ${DRX_LongCycle_1[1]}    ${SPACE}(
    [Return]    ${DRX_LongCycle_2[0]}

Get DRX_slotoffset from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${drx_slotoffset_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_SlotOffset
    ...            attribute_name=showname
    ${drx_slotoffset_1}=    String.Split String    ${drx_slotoffset_0[0]}    :${SPACE}
    ${drx_slotoffset_2}=    String.Split String    ${drx_slotoffset_1[1]}    ${SPACE}(
    ${drx_slotoffset}=    String.Remove String    ${drx_slotoffset_2[0]}    ms
    [Return]    ${drx_slotoffset}

Get DRX_onduration timer from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${milliSeconds_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_onDurationTimer/nr-rrc.milliSeconds
    ...            attribute_name=showname
    ${milliSeconds_1}=    String.Split String    ${milliSeconds_0[0]}    :${SPACE}
    ${milliSeconds_2}=    String.Split String    ${milliSeconds_1[1]}    (
    ${milliSeconds}=    String.Remove String    ${milliSeconds_2[0]}    ms
    [Return]    ${milliSeconds}

Get CSIRS_StartOffset from CPIF
    [Arguments]    ${file_path}
    ${CSIRS_periodicity}=    Get CSIRS_periodicity from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_Offset_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.periodicityAndOffset/nr-rrc.${CSIRS_periodicity}
    [Return]    ${CSIRS_Offset_0[0]}

Get CSIRS_periodicity from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_periodicity_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.periodicityAndOffset
    ...            attribute_name=showname
    ${CSIRS_periodicity_1}=    String.Split String    ${CSIRS_periodicity_0[0]}    :${SPACE}
    ${CSIRS_periodicity_2}=    String.Split String    ${CSIRS_periodicity_1[1]}    ${SPACE}(
    [Return]    ${CSIRS_periodicity_2[0]}

Get SSB_Reportslot from CPIF
    [Arguments]    ${file_path}
    ...    ${periodic_element}=_[2]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element
    ${SSB_Reportperiodicity}=    Get CQI_Reportperiodicity from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${SSB_Reportslot_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...    xpath=.//${periodic_element}/nr-rrc.reportSlotConfig/nr-rrc.${SSB_Reportperiodicity}
    [Return]    ${SSB_Reportslot_0[0]}

Get CQI_Reportperiodicity from CPIF
    [Arguments]    ${file_path}
    ...    ${periodic_element}=_[1]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CQI_Reportperiodicity_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//${periodic_element}/nr-rrc.reportSlotConfig
    ...            attribute_name=showname
    ${CQI_Reportperiodicity_1}=    String.Split String    ${CQI_Reportperiodicity_0[0]}    :${SPACE}
    ${CQI_Reportperiodicity_2}=    String.Split String    ${CQI_Reportperiodicity_1[1]}    ${SPACE}(
    [Return]    ${CQI_Reportperiodicity_2[0]}

Get CQI_Reportslot from CPIF
    [Arguments]    ${file_path}
    ...    ${periodic_element}=_[1]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element
    ${CQI_Reportperiodicity}=    Get CQI_Reportperiodicity from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CQI_Reportslot_0}    Check Target Item Value On CPIF Tcpdump
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...    xpath=.//${periodic_element}/nr-rrc.reportSlotConfig/nr-rrc.${CQI_Reportperiodicity}
    [Return]    ${CQI_Reportslot_0[0]}



##COMMON CHECK POINTS##
Check beamweight for CNI74278
    [Arguments]     ${beamweight_name}    ${connection}    ${beamset_num}
    csn.Connect To    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    csn.download_file    remote_path=${beamweight_path}${beamweight_name}    local_path=/tmp/beamset.txt    connection=${connection}
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    csn.send command    cat /tmp/beamset.txt    connection=ute
    ${beamweight}=    ssh.read_output   connection=ute
    ${elem_lines}=    Get Lines Containing String    ${beamweight}    elements
    ${num}=    Get Line Count    ${elem_lines}
    Should Be Equal As Integers    ${num}    ${beamset_num}


Check beamweight size for CNI65655
    [Arguments]     ${beamweight_name}    ${connection}     ${bpf_name}     ${ungzip_bpf_name}    ${bpf_name_xml}
    csn.Connect To    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gnb
    csn.download_file    remote_path=${beamweight_path}${beamweight_name}
    ...    local_path=${TS_CASE_LOG_PATH}${beamweight_name}    connection=${connection}
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    ${values}    read_beam_weight_size    ${TS_CASE_LOG_PATH}${beamweight_name}
    ${max_im}    Set Variable    ${values}[0]
    ${min_im}    Set Variable    ${values}[1]
    ${max_re}    Set Variable    ${values}[2]
    ${min_re}    Set Variable    ${values}[3]
    ${eCPRI_fomat_max}    ${eCPRI_fomat_min}    GET eCPRI fomat from bpf
    ...    bpf_name=${bpf_name}    ungzip_bpf_name=${ungzip_bpf_name}    bpf_name_xml=${bpf_name_xml}
    Should Be True    ${max_im} <= ${eCPRI_fomat_max}
    Should Be True    ${min_im} >= ${eCPRI_fomat_min}
    Should Be True    ${max_re} <= ${eCPRI_fomat_max}
    Should Be True    ${min_re} >= ${eCPRI_fomat_min}

GET eCPRI fomat from bpf
    [Arguments]      ${bpf_name}=*_AE_QV.gz     ${ungzip_bpf_name}=475294A_AE_QV     ${bpf_path}=/tmp/bpf/
    ...     ${connection}=GNB_OAM      ${bpf_name_xml}=AE_QV.xml
    Connect to gnb coam via ssl
    ${fsm_type}=    coam_gnb_classical.COAM Get FSM Type    connection=${connection}
    ${alias}    set variable if    '${fsm_type}'=='ASIB'    ASIK Slave    ASIK Master
    Run Keyword If    '${fsm_type}'=='ASIB'    Connect to Common Unit Master    alias=${alias}
    ...    ELSE    Connect to Common Unit Slave    alias=${alias}
    ${ungzip_bpf}     csn.execute    command=gzip -d ${bpf_path}${bpf_name}     connection=${alias}
    csn.download_file    remote_path=${bpf_path}${ungzip_bpf_name}
    ...    local_path=${TS_CASE_LOG_PATH}${bpf_name_xml}    connection=${alias}
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    ${eCPRI_format_exp}      set variable     (?<=>eCPRI<).*?(?=</p>)
    ${eCPRI_format_output}     csn.execute     command=cat ${TS_CASE_LOG_PATH}${bpf_name_xml}| grep -oP '${eCPRI_format_exp}'   connection=ute
    ${eCpri_format_1}=    String.Split String    ${eCPRI_format_output}    (
    ${eCpri_format_2}=    String.Split String    ${eCpri_format_1[1]}    )
    ${eCpri_format_3}=    String.Split String    ${eCpri_format_2[0]}    \.
    ${eCPRI_fomat}=     Evaluate     ${eCpri_format_3[2]}
    ${eCPRI_fomat_max}     Evaluate     2**${eCPRI_fomat}
    ${eCPRI_fomat_min}     Evaluate     -(2**${eCPRI_fomat})
    [Return]     ${eCPRI_fomat_max}    ${eCPRI_fomat_min}

#-----CLOUD UTE------#
GET_CLOUD_UTE_SCF_PATH
    [Documentation]
    ${scf_full_path}    Get Variable Value    ${scf_full_path}
    return from keyword if    '${scf_full_path}' != 'None'
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${testline_name}  Get Variable Value    ${testline_name}
    ${TL_NAME}   set variable if    '${testline_name}' == 'None' or '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_pre}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename_p}   Set Variable    7_5${TLNAME_pre}[0]
    set suite variable    ${scf_full_path}    ${SCF_PATH}commissionings/HGZ/${testlinename_p}
    [return]    ${scf_full_path}

SUITE SETUP FOR UTE
    [Documentation]    only used for cloud ute case
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable    ${stream}
    ${Golden_SCF_Path}    GET_CLOUD_UTE_SCF_PATH
    set suite variable      ${Golden_SCF_Path}
    ${mcs_type}     mcs_common.Get MCS Type
    set suite variable    ${mcs_type}
    NRCellid Set suit varaible    cellid=${nrcellid_cell2}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

SUITE TEARDOWN FOR UTE
    CI_interface.Common Case Teardown
    Common Suite Teardown for COAM    log_path=${OUTPUT_DIR}

attach UE and capture wiresharklog for CLOUD UTE
    [Arguments]    ${wiresharklog}    ${4G_check}=False    ${ue_index}=${0}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    ${attach_status}=    Run Keyword And Return Status
    ...    UE attach for QCOM and verify with retry    ue_type=${ue_type_0}    ue_index=${ue_index}    4G_check=${4G_check}
    sleep    1s
    ${cpif_log_path}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${TS_CASE_LOG_PATH}
    Should Be True    '${attach_status}' == 'True'
    [Return]     ${cpif_log_path}

Start Traffic And Capture Biplog for CLOUD UTE
    [Arguments]    ${biplog_name}    ${dlexpect_tp}=${Expect_dl_enable}     ${duration}=1m     ${ue_index}=${0}
    ...            ${dl_throughput}=${dl_throughput}
    Start UE traffic and check tput for CLOUD UTE    throughput=${dl_throughput}     cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}
    ...                                               duration=${duration}    ue_index=${ue_index}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download with WEBUI    biplog_name=${biplog_name}     target_dir=${TS_CASE_LOG_PATH}/
    [Return]     ${bip}

Start UE traffic and check tput for CLOUD UTE
    [Arguments]    ${throughput}=${dl_throughput}    ${cellid}=${nrcellid}    ${dlexpect_tp}=@{Expect_dl_enable[0]}    ${duration}=1m
    ...    ${ue_index}=${0}
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${DL_PORT}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type_0}
    sleep    30s
    log to console    check tput with nrcellid
    ${tput_status}=    Run Keyword And Return Status
    ...    DL Tput collect and check with nrcellid    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}    duration=${duration}    ue_type=${ue_type_0}
    Run Keyword If     '${tput_status}' == '${False}'    capture and save TTItrace
    Run Keyword And Continue On Failure     should be true     '${tput_status}' == '${True}'

Start UE traffic and check stream for CLOUD UTE
    [Arguments]    ${throughput}=${dl_throughput}    ${dlexpect_tp}=@{Expect_dl_enable[0]}    ${ue_index}=${0}
    ...    ${cellid}=${nrcellid}
    Power UE Start DL traffic    dl_throughput=${throughput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${DL_PORT}    ue_index=${ue_index}    process_num=${3}    ue_type=${ue_type_0}
    sleep    10s
    power_ue.Check throughput    ue_type=${ue_type_0}    direction=dl    throughput=${dlexpect_tp}    cellid=${cellid}

Capture biplog and download with WEBUI
    [Arguments]    ${biplog_name}    ${target_dir}=${epc_log_path}    ${nr_phy_cell_ids}=${cloud_phy_cell_ids}
    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${target_dir}    target_file_name=${biplog_name}    times=2s
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}
    sleep     15s
    ${tmpbip}=    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${target_dir}    target_file_name=${biplog_name}
    Set Test Variable    ${tmpbip}    ${tmpbip[0]}
    [Return]     ${tmpbip}

Get BeampatternIdDict From CPRT Logs for CLOUD
    [Documentation]
    ...                Desription: for CLOUD UTE Get patternIdDict from cprt log.
    ...                PREDEFINED beam, PMI beam and DFT beam.
    [Arguments]    ${cell_idx}=1    ${connection}=GNB_OAM    ${grep_info}=CellParametersReq
    ${patternIdInfoList_log}    ${nrcellid}    Get PatternIdInfoList From CPRT Logs
    ...    cell_idx=${cell_idx}   connection=${connection}    grep_info=${grep_info}
    ${percell_patternIdInfoList_exp}    set variable
    ...    nrCellIdentity..${nrcellid}..patternIdInfoList..(.*?)\\r\\r\\n.*CellParametersReq(.*?)\\r\\r\\n.*CellParametersReq(.*?)ruMaxRemasks*
    ${patternIdInfoList_log} =    get regexp matches    ${patternIdInfoList_log}   ${percell_patternIdInfoList_exp}    1    2
    ${patternIdInfoList_len}    get length    ${patternIdInfoList_log}
    ${patternIdInfoList_log2}    Run Keyword If    ${patternIdInfoList_len} == ${0}
    ...    Fetch PatternIdInfoList From CPRT Logs    cell_idx=${cell_idx}    connection=${connection}
    ${patternIdInfoList_log}    set variable if    ${patternIdInfoList_len} == ${0}   ${patternIdInfoList_log2}    ${patternIdInfoList_log}
    ${patternIdInfoList_log}    Convert To String    ${patternIdInfoList_log}
    ${cprtPatternIdDict}    Fetch BeampatternId Of Different Beams From Output for CLOUD    patternIdInfoList_log=${patternIdInfoList_log}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId Of Different Beams From Output for CLOUD
    [Documentation]   Author: Liu jia
    ...                Desription: Get patternIdInfoList from cprt log.
    [Arguments]    ${patternIdInfoList_log}    ${predefined_beam}=PREDEFINED    ${PMI_beam}=DYNAMIC    ${DFT_beam}=DFTNORMAL
    &{cprtPatternIdDict}    Create Dictionary
    ${beamSetType_list}    create list    ${predefined_beam}    ${PMI_beam}    ${DFT_beam}
    FOR  ${beamSetType}  IN  @{beamSetType_list}
     ${patternIdMin_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.:(\\d+)
     ${patternIdMax_exp}    set variable    beamSetType...${beamSetType}...patternIdMin.*?patternIdMax.:(\\d+)
     ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
     ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
     ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
     ${patternId_list}    Remove Duplicates    ${patternId_list}
     Set To Dictionary    ${cprtPatternIdDict}    ${beamSetType}    ${patternId_list}
    END
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch BeampatternId For DFT Beam CLOUD
    ...    patternIdInfoList_log=${patternIdInfoList_log}    DFT_beam=${DFT_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch BeampatternId For PMI Beam CLOUD
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For DFT Beam CLOUD
    [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially with CLOUD UTE.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...${DFT_beam}...patternId</LOG.*>Min.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...${DFT_beam}...patternId</LOG.*>Min........patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch BeampatternId For DFT Beam CLOUD again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For DFT Beam CLOUD again
    [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially with CLOUD UTE.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...DFT</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DFT</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch BeampatternId For DFT Beam CLOUD again and again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For DFT Beam CLOUD again and again
    [Documentation]   Author: liujia
    ...                Desription: Get patternId for DFT beam specially with CLOUD UTE.
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...DFTNOR</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DFTNOR</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch BeampatternId For DFT Beam CLOUD again and again and again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For DFT Beam CLOUD again and again and again
    [Documentation]   Author: xiaodan li
    ...                Desription: Get patternId for DFT beam specially with close 2200
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...DFTN</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DFTN</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    ${DFTbeam_len}    get length    ${cprtPatternIdDict['${DFT_beam}']}
    Run Keyword If    ${DFTbeam_len} < ${2}     Fetch BeampatternId For DFT Beam CLOUD again and again and again and again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For DFT Beam CLOUD again and again and again and again
    [Documentation]   Author: xiaodan li
    ...                Desription: Get patternId for DFT beam specially with close 2200
    [Arguments]    ${patternIdInfoList_log}   ${cprtPatternIdDict}    ${DFT_beam}=DFTNORMAL
    ${patternIdMin_exp}    set variable    beamSetType...DFTNO</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DFTNO</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}   ${patternIdMax_exp}    1
    ${patternIdMin}    Remove Duplicates    ${patternIdMin}
    ${patternIdMax}    Remove Duplicates    ${patternIdMax}
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${DFT_beam}   ${patternId_list}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For PMI Beam CLOUD
    [Documentation]   Author: Liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...DYN</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DYN</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch BeampatternId For PMI Beam CLOUD again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For PMI Beam CLOUD again
    [Documentation]   Author: Liujia
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...DYNAMI</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DYNAMI</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch BeampatternId For PMI Beam CLOUD again and again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For PMI Beam CLOUD again and again
        [Documentation]   Author: xiaodan
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...DYNA</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DYNA</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    ${PMIbeam_len}    get length    ${cprtPatternIdDict['${PMI_beam}']}
    Run Keyword If    ${PMIbeam_len} < ${2}    Fetch BeampatternId For PMI Beam CLOUD again and again and again
    ...    patternIdInfoList_log=${patternIdInfoList_log}    PMI_beam=${PMI_beam}    cprtPatternIdDict=${cprtPatternIdDict}
    [Return]    ${cprtPatternIdDict}

Fetch BeampatternId For PMI Beam CLOUD again and again and again
        [Documentation]   Author: xiaodan
    ...                Desription: Get patternId for DFT beam specially if CPRT log are seperated in two lines.
    [Arguments]    ${patternIdInfoList_log}    ${cprtPatternIdDict}    ${PMI_beam}=DYNAMIC
    ${patternIdMin_exp}    set variable    beamSetType...DYNAM</LOG.*>.*?patternIdMin.:(\\d+)
    ${patternIdMax_exp}    set variable    beamSetType...DYNAM</LOG.*>.*?patternIdMin.*?patternIdMax.:(\\d+)
    ${patternIdMin} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMin_exp}    1
    ${patternIdMax} =    get regexp matches    ${patternIdInfoList_log}    ${patternIdMax_exp}    1
    ${patternId_list}    Combine Lists    ${patternIdMin}    ${patternIdMax}
    Set To Dictionary    ${cprtPatternIdDict}    ${PMI_beam}    ${patternId_list}
    [Return]    ${cprtPatternIdDict}

Check TAS SRS Is Used in RRC Message Cloud UTE
    [Documentation]
    ...                  used for 1086 on + 8274 on
    [Arguments]    ${file_path}
    ${SRSusageList}    Get SRSResourceSet From CPIF Log Cloud UTE    file_path=${file_path}    srs_ResourceSetToAddModList=2
    Should Contain    ${SRSusageList[0]}    codebook    msg=Codebook SRS resource is not Assigned in RRC Message!
    Should Contain    ${SRSusageList[1]}    antennaSwitching    msg=TAS SRS resource is not Assigned in RRC Message!

Get SRSResourceSet From CPIF Log Cloud UTE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${file_path}    ${srs_ResourceSetToAddModList}=2
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.resourceType == 2 &&
    ...                                         nr-rrc.srs_ResourceSetToAddModList == ${srs_ResourceSetToAddModList}
    ${SRSusageList}    Check Target Item Value on CPIF Tcpdump Cloud UTE
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.SRS_ResourceSet_element/nr-rrc.usage
    ...            attribute_name=showname
    [Return]    ${SRSusageList}


Check Target Item Value on CPIF Tcpdump Cloud UTE
    [Documentation]       Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=f1ap||nr-rrc||ngap
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert CPIF Pcap To Pdml    file_path=${file_path}
    ...                          tshark_path=${tshark_path}
    ...                          filter=${filter}
    ...                          command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}

Check CSIRS UE specific Used Cloud UTE
    [Arguments]     ${file_path}    ${nrofports}=p4
    ${CSIRS_nrofPorts}    Get CSIRS nrofPorts from RRC Message Cloud UTE    file_path=${file_path}
    Should Be Equal    ${CSIRS_nrofPorts[0]}    ${nrofports}


Get CSIRS nrofPorts from RRC Message Cloud UTE
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_nrofPorts_0}    Check Target Item Value on CPIF Tcpdump Cloud UTE
    ...            file_path=${file_path}
    ...            filter=nr-rrc
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ...            attribute_name=showname
    ${num}     get length    ${CSIRS_nrofPorts_0}
    ${CSIRS_nrofPorts}=    Create List
    FOR    ${i}    IN RANGE    ${num}
       ${CSIRS_nrofPorts_1}=    String.Split String    ${CSIRS_nrofPorts_0[${i}]}    :${SPACE}
       ${CSIRS_nrofPorts_2}=    String.Split String    ${CSIRS_nrofPorts_1[1]}    ${SPACE}(
       Append To List    ${CSIRS_nrofPorts}    ${CSIRS_nrofPorts_2[0]}
    END
    [Return]    ${CSIRS_nrofPorts}

Check alarm and save snapshot
    [Arguments]     ${gnb_list}=${gnb_list}     ${ALLOWED_FAULT}=${ALLOWED_FAULT}     ${log_path}=${epc_log_path}
    ${alarm_check}    Run Keyword And Return Status    Check Unexpect Alarm whether exist    ALLOWED_FAULT=${ALLOWED_FAULT}
    Run Keyword If    '${alarm_check}' == 'False'
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}

Check CSIRS used PMI beam when CELL specific used with mcshark for cloud ute
    [Arguments]    ${file_path}    ${filter}=dldata_csirssendreq    ${csirs_expression}=DlData_CsiRsResource_t
    ${cprtPatternIdList}    ${bipPatternIdList}    Get PatternidList From CPRT and BIP with mcshark
    ...    file_path=${file_path}    beamSetType=DYNAMIC
    ${CSIRSpatternidlist}    Get CSIRS_patternId From BIP Log with mcshark for cloud ute    file_path=${file_path}
    ...    filter=${filter}    csirs_expression=${csirs_expression}
    ${CSIRS_compare_status}    run keyword and return status    should be true
    ...    ${cprtPatternIdList[0]} <= ${CSIRSpatternidlist[0]} <= ${cprtPatternIdList[1]}
    Run Keyword If   ${CSIRS_compare_status}!= ${True}    FAIL    "CSIRS PMI Beam is not used!"

Get CSIRS_patternId From BIP Log with mcshark for cloud ute
    [Documentation]
    ...                This keyword is used to get patternId from bip log, filter dldata_pdcchsendreq
    [Arguments]    ${file_path}    ${filter}=dldata_csirssendreql1sw    ${csirs_expression}=DlData_CsiRsResourceL1sw_t
    ${csirsPatternIdList0}    Get Item Value From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=${csirs_expression}.csiRsConfig == 8
    ...    xpath=.//nr_l1dl_l2ps_dldata_csirsresourcel1sw_t[1]/_[2]/DlData_CsiRsResourceL1sw_t.patternId_item[1]
    ${csirsPatternIdList1}    Get XpatternId From BIP Log with mcshark    file_path=${file_path}    filter=${filter}
    ...    filter_expression=${csirs_expression}.csiRsConfig == 8
    ...    xpath=.//nr_l1dl_l2ps_dldata_csirsresourcel1sw_t[1]/_[2]/DlData_CsiRsResourceL1sw_t.patternId_item[3]
    ${csirsPatternIdList}    Combine Lists    ${csirsPatternIdList0}    ${csirsPatternIdList1}
    ${csirsPatternIdList}    Remove Duplicates    ${csirsPatternIdList}
    run keyword if     '${csirsPatternIdList1[0]}'=='0'     ${csirsPatternIdList}     ${csirsPatternIdList0}
    [Return]    ${csirsPatternIdList}
