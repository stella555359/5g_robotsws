*** Settings ***
Documentation    ...
#Resource          ./CB006137_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Library           ../5GC001817/csv_bit_to_qci.py
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup 2
#Test Teardown     Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM2    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}                  1
#${PROFILE_ID}             1
#${GNB_ID}                 2
#${CELL_ID}                1
#${BEARER_ID}              2
#${Egatelog_path}          ${CURDIR}
#${SCF_DIR}                ${CURDIR}/config
#${LOCAL_IPHY_DIR}         ${CURDIR}/config
#${SCF_PATH}               ${CURDIR}/config
#${6137_C_IWK2101_SCF}     ${SCF_PATH}/SCF_C_IWK2101.xml
#${6137_C_IWK1102_SCF}     ${SCF_PATH}/SCF_C_IWK1102.xml
#${6137_C_IWK1503_SCF}     ${SCF_PATH}/SCF_C_IWK1503.xml
#${WTS_CFG_C_1503}         basic_setup_BOO_5cell_C_1503.cfg
#${WTS_CFG_C_2101}         basic_setup_BOO_5cell_C_2101.cfg
#${WTS_CFG_C_1102}         basic_setup_BOO_5cell_C_1102.cfg
#${iphy_2T3F_C}            iphy_2T3F_LOO.xml
##RD parameters: 0x58067c=0x1 (6137-C enabling)
#${6137_C_B4_COMMON_RD}    0x58067c=0x1
#
#*** Test Cases ***
#CB006137-ET-C-IWK2101_Verify_IWK_with_SrsBased_DLUL_BF_5GC002516_without_BilateralAgreement_local_5GC001208_remote_5GC001116_0ms
#    [Tags]    caseC2101    Manual_JohnyYe    TA_AbbyWang
#    [Setup]    Setup TL For C_B4 Each Case    ${6137_C_IWK2101_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C_2101}
#    Verify Coam Site Is Ready
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C_2101}
#    Basic L3 Call and Traffic
#    Check TP On Target    ${UE_ID}    0    1    dl    300
#    Check TP On Target    ${UE_ID}    0    1    ul    95
#    Start Gnb BIP Log
#    Sleep    5s    reason=wait for log collection...
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    @{slot_nums_2101}    Create List    5  9  15  19
#    Check Mute Slots From Gnb_syslog    @{slot_nums_2101}
#    Check Srs From BIP
#
#CB006137-ET-C-IWK1102_Verify IWK with 5GC002516-A-B2 bilateral agreement on SCell with souce 5GC001208 and interfering 5GC001116 3ms
#    [Tags]    caseC1102    TA_Susie
#    [Setup]    Setup TL For C_B4 Each Case    ${6137_C_IWK1102_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C_1102}
#    Verify Coam Site Is Ready
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C_1102}
#    Start Gnb BIP Log
#    Basic L3 Call and Traffic
#    Sleep    10s    reason=wait for log collection...
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/
#    @{slot_nums_1102}    Create List    5  15
#    Check Mute Slots From Gnb_syslog    @{slot_nums_1102}
#    Check TP On Target    ${UE_ID}    0    1    dl    300
#    Check TP On Target    ${UE_ID}    0    1    ul    85
#
#CB006137-ET-C-IWK1503_Verify_IWK_with_adaptive_retransmission_in_UL_with_256QAM_and_default_target_and_min_PctResourceReservedMcsUl
#    [Tags]    caseC1503    TA_Wangxin
#    [Setup]    Setup TL For C_B4 Each Case    ${6137_C_IWK1503_SCF}    ${iphy_2T3F_C}    ${WTS_CFG_C_1503}
#    Verify Coam Site Is Ready
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_C_1503}
#    SA 5G Attach    ue_id=3
#    SA Set Traffic Type To Internal    ue_id=3    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=3
#    Start SA Internal Traffic    ue_id=3    pdu_id=1    dir=dl    mbps=70    trf_id=1    seconds=3000
#    Start SA Internal Traffic    ue_id=3    pdu_id=1    dir=ul    mbps=175    trf_id=2    seconds=3000
#    Trigger PHR To GNB    profile_id=2    phr_start=0    ue_id=3    cell_id=0
#    Add UL Bler For Pcell
#    Start Ttitrace With Streaming Mode
#    sleep    5s    reason=wait for log collection...
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1503
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1503
#    #Check ResMCS From TTI    ${TEST_LOG_DIRECTORY}/ttitrace/1503
#
#*** Keywords ***
#Setup TL For C_B4 Each Case
#    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}
#    Verify Coam Site Is Ready
#    Create Test Directory
#    Set Test Variable    ${6137_C_B4_RD}    ${6137_C_B4_COMMON_RD}
#    Add RD Parameters To GNB Swconfig File    ${6137_C_B4_RD}
#    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
#    Full Commission With SCF File    ${scf_file}
#    Reboot TL And Check Configured
#    Set WTS Files Name For Each Cases    ${wts_cfg_name}
#
#Check Mute Slots From Gnb_syslog
#    [Arguments]    @{slot_info}
#    Log To Console    Check Mute Slots slot from Gnb...
#    ${real_muted_nums}    Set Variable    0
#    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
#    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cd ${TEST_LOG_DIRECTORY};tar -xzvf ${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
#    Log    ${output}
#    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
#    ${content_num}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "SLOT_TYPE_MUTED"|wc -l
#    Should Be True    ${content_num}>1
#    ${content}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "SLOT_TYPE_MUTED"
#    ${slot_items}    Get Length    ${slot_info}
#    FOR    ${index}    IN RANGE    0    ${slot_items}
#        ${slot_nums}    Set Variable    0
#        ${slot}    Get Regexp Matches    ${content}    (Slot=${slot_info}[${index}])    1
#        ${slot_nums}    Get Length    ${slot}
#        Should Be True    ${slot_nums}>=1
#        ${real_muted_nums}    Evaluate    ${real_muted_nums}+${slot_nums}
#    END
#    Should Be True    ${content_num} == ${real_muted_nums}
#
#Check Srs From BIP
#    Log To Console    Check SRS on SCell...
#    Convert BIP To CSV By MCShark For CB006137-C-IWK2101
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_c_2101.ini    ${OUTPUT_DIR}/csv_srs.csv
#
#Convert BIP To CSV By MCShark For CB006137-C-IWK2101
#    ${filter}=    Set Variable    uldata_srsreceivereq||(uldata_puschreceivereq && (3gpp.slot == 6||3gpp.slot ==1))
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_puschReceiveReqGrant_t.numOfPuschSymbols
#    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}   5GBipL2L1_filtering*.pcap    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_srs.csv    ${filter}    ${csv_title_list}
#    END
#
#Convert BIP To CSV By MCShark
#    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
#    ${tashark_version}=    Get Tshark Version
#    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
#    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
#    Run Keyword If    '${res}'=='False'    Download MCShark To UTE
#    ${csv_title}=    Set Variable
#    FOR    ${column}   IN    @{csv_title_list}
#        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
#    END
#    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
#    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
#    OperatingSystem.Run    ${cmd}
#    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!
#
#A2A_Check_CSV_Table
#    [Arguments]    ${ini_file}    ${check_csv_file}    ${log_path}=${OUTPUT_DIR}
#    ${path_name}	${file_name}=    OperatingSystem.Split Path    ${check_csv_file}
#    ${backup_file}=    OperatingSystem.Join Path    ${path_name}    backup_${file_name}
#    OperatingSystem.Copy File    ${check_csv_file}    ${backup_file}
#    CSV_PRE_DEAL.Delete Blank Space For Mcshark Sencond Column    ${backup_file}
#    ...    ${check_csv_file}
#    ta_a2a.Check Log With Au2anlysis    ${ini_file}    i    ${check_csv_file}
#    ...    save_log_directory=${log_path}
#
#Add UL Bler For Pcell
#    ute_wtssim.Execute Egate Command
#    ...    cmd=bler_testmode_nr profile_id=4 ul_bler=900
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_testmode_set_nr id=3 scell=0 testmode=bler profile_id=4 action=activate
#
#Check ResMCS From TTI
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_adpt_retrans.ini    output_ul.csv    ${csv_file_path}
#
#Trigger PHR To GNB
#    [Arguments]    ${profile_id}    ${phr_start}    ${phr_min}=0    ${phr_max}=30    ${phr_step_size}=5
#    ...    ${phr_period}=10    ${pc_max}=23    ${phr_mode}=Fixed    ${ue_id}=1    ${cell_id}=0
#    Log To Console    start send Power Headroom Report to gnb...
#    ${cmd1}    Catenate    phr_override_testmode_nr profile_id=${profile_id} phr_mode=${phr_mode} phr_start=${phr_start}
#    ...    phr_min=${phr_min} phr_max=${phr_max} phr_step_size=${phr_step_size} phr_period=${phr_period} pc_max=${pc_max}
#    ute_wtssim.Execute Egate Command    ${cmd1}
#    ${cmd2}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate
#    ...     profile_id=${profile_id} scell=${cell_id}
#    ute_wtssim.Execute Egate Command    ${cmd2}
#
#Basic L3 Call and Traffic
#    [Arguments]    ${ue_id}=${UE_ID}    ${ul_tp}=120    ${dl_tp}=175
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${ue_id}
#    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=1    seconds=3000
#    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=2    seconds=3000
#    Start SA Internal Traffic    ue_id=${ue_id}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1    seconds=3000
#    Sleep    30s    reason=wait traffic is stable
#
#Start SA Internal Traffic
#    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}=1    ${seconds}=60
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    Log To Console    start Internal traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir\=${dir} mbps\=${mbps} trf_id\=${trf_id} seconds\=${seconds}
#    Sleep    5s    reason=wait traffic is stable
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Configure UTE ETH For GNB3
#
#Configure UTE ETH For GNB3
#    [Documentation]    This keyword is to configure VM interfaces.
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4
#
#Check TP On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${dir}    ${target_sum_tp}
#    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    ${dir}    pcell    ${pcell_index}
#    Log To Console    Pcell's ${dir} Troughput is ${pcell_TP}    console=True
#    Should Be True    ${pcell_TP}>0
#    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    ${dir}    scell    ${scell_index}
#    Log To Console    Scell's ${dir} Troughput is ${scell_TP}    console=True
#    Should Be True    ${scell_TP}>0
#    ${sum_tp}    evaluate    ${pcell_TP}+${scell_TP}
#    Log To Console    ${dir} total throughput is ${sum_tp}    console=True
#    Should Be True    ${sum_tp}>=${target_sum_tp}
