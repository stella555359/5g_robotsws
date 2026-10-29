*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Library     taf.analyzer.pcap        WITH NAME    pcap
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.hw.rf_attenuator    WITH NAME    attenuator
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/py_script.py
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005822/Resources/read_pdml_5822.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/data_analysis.py
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005822/Resources/CB005822_B_variables.py
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005822/Resources/CB005822_Common_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot

Documentation
...   author: yulu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${tshark_path}    /usr/bin/tshark

${puschreceivereq_msg}     \"uldata_puschreceivereq\"
${command_template_puschreceivereq_msg}      {tshark_path} -r {pcap_file} -Y ${puschreceivereq_msg} -T pdml
${modulationOrder_xpath}       .//UlData_puschReceiveReqGrant_t.modulationOrder

${command_template_ue_attach_log}     {tshark_path} -r {pcap_file} -T pdml
${filter_expression_ue}      !f1ap.initiatingMessage_element
${maxNumberSRS-Ports-PerResource}      nr-rrc.maxNumberSRS_Ports_PerResource
${nrofSRS-Ports}            nr-rrc.nrofSRS_Ports

${srsreceivereq_msg}      \"uldata_srsreceivereq\"
${command_template_srsreceivereq_msg}      {tshark_path} -r {pcap_file} -Y ${srsreceivereq_msg} -T pdml
${srsBmEnable_filed_name}    UlData_srsReceiveReqSubcell_t.srsBmEnable
${patternIdMin_value}      UlData_eCpriConfigStruct_t.patternId_item

${pdschsendreq_msg}        \"dldata_pdschsendreq\"
${command_template_pdschsendreq_msg}      {tshark_path} -r {pcap_file} -Y ${pdschsendreq_msg} -T pdml
${pdsch_patternIdMin_value}     DlData_PdschGrant.patternId_item

${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    1400M
${UL_EXPECT_30M}    50
${DL_EXPECT_30M}    340

${paths_file}        /mnt/factory/configs/unit/paths.txt

*** Keywords ***
5822 Coam Suite Setup
    [Arguments]    ${asik_addr_temp}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...            ${asik_username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...            ${asik_password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    SISO Coam Suite Setup
    ${version}     get software version for 5822
    Load Case SCF and Commission SCF for 5822       scf_file=commissionings/HGZ/7_5_UTE5G402T980/SCF_${version}_980.xml
    Add RU file on RU    file_path=${paths_file}   file_content=${PATHS_CONTENT}
    log to console    \n update /ffs/run/swconfig.txt
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${BASE_PATH}     Get Substring  ${CURDIR}  0  -57
    log to console    ${BASE_PATH}
    ${swconfig_path}   Set Variable    ${BASE_PATH}/commissionings/HGZ/7_5_UTE5G402T980/swconfig.txt
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${swconfig_path}
    Run Keyword And Ignore Error    OperatingSystem.Run    sudo rm /root/.ssh/known_hosts
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass -p ${asik_password} scp ${swconfig_path} ${asik_username}@${asik_addr_temp}:/ffs/run/   shell=yes
    csn.connect_to    ${asik_addr_temp}    ${asik_username}    ${asik_password}    alias=OAM
    csn.execute    command=chmod 777 /ffs/run/swconfig.txt    connection=OAM
    ${swconfig_output}    csn.execute    command=cat /ffs/run/swconfig.txt    connection=OAM
    log to console    \n ${swconfig_output}
    csn.execute    command=crasign /ffs/run/swconfig.txt    connection=OAM
    [Teardown]  run keywords  COAM Teardown gnb connections    AND    csn.disconnect    connection=OAM

Clear the cache and reconnect
    Run keyword and ignore error    ssh.Reset cache
    Connect to gnb coam via ssl
    Connect to Common Unit Master

_Get_parameter_values
    [Arguments]    ${dist_name}    ${filter_param}  ${abbr}
    ${parameter_values}       selenium_coam.get_parameter_value    dist_name=${dist_name}
                              ...                                  filter_param=${filter_param}
                              ...                                  abbr=${abbr}
    [Return]  ${parameter_values}

Check Actual Value on webEM
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${frameStructureType}       _Get_parameter_values       dist_name=${GET_FRAMESTRUCTURETYPE[0]}[dist_name]
    ...                                                    filter_param=${GET_FRAMESTRUCTURETYPE[0]}[filter_param]
    ...                                                    abbr=${GET_FRAMESTRUCTURETYPE[0]}[abbr]
    Should Be Equal     ${frameStructureType}      tdLte
    ${guardPeriodLength}       _Get_parameter_values       dist_name=${GET_GUARDPERIODLENGTH[0]}[dist_name]
    ...                                                    filter_param=${GET_GUARDPERIODLENGTH[0]}[filter_param]
    ...                                                    abbr=${GET_GUARDPERIODLENGTH[0]}[abbr]
    Should Be Equal     ${guardPeriodLength}      4Symbols
    ${lteToNrFrameShift}       _Get_parameter_values       dist_name=${GET_LTETONRFRAMESHIFT[0]}[dist_name]
    ...                                                    filter_param=${GET_LTETONRFRAMESHIFT[0]}[filter_param]
    ...                                                    abbr=${GET_LTETONRFRAMESHIFT[0]}[abbr]
    Should Be Equal     ${lteToNrFrameShift}      3ms
    ${ulDlDataSlotRatio}       _Get_parameter_values       dist_name=${GET_ULDLDATASLOTRATIO[0]}[dist_name]
    ...                                                    filter_param=${GET_ULDLDATASLOTRATIO[0]}[filter_param]
    ...                                                    abbr=${GET_ULDLDATASLOTRATIO[0]}[abbr]
    Should Be Equal     ${ulDlDataSlotRatio}      1/4
    ${manualFrameTimingAdjustment}       _Get_parameter_values       dist_name=${GET_MANUALFRAMETIMINGADJUSTMENT[0]}[dist_name]
    ...                                                    filter_param=${GET_MANUALFRAMETIMINGADJUSTMENT[0]}[filter_param]
    ...                                                    abbr=${GET_MANUALFRAMETIMINGADJUSTMENT[0]}[abbr]
    Should Be Equal     ${manualFrameTimingAdjustment}      2302.34 (microseconds)
    ${prachConfigurationIndex}       _Get_parameter_values       dist_name=${GET_PRACHCONFIGURATIONINDEX[0]}[dist_name]
    ...                                                    filter_param=${GET_PRACHCONFIGURATIONINDEX[0]}[filter_param]
    ...                                                    abbr=${GET_PRACHCONFIGURATIONINDEX[0]}[abbr]
    Should Be Equal     ${prachConfigurationIndex}      7
    COAM selenium logout

Check actUl256Qam Value on webEM
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${actUl256Qam}       _Get_parameter_values       dist_name=${GET_ACTUL256QAM[0]}[dist_name]
    ...                                                    filter_param=${GET_ACTUL256QAM[0]}[filter_param]
    ...                                                    abbr=${GET_ACTUL256QAM[0]}[abbr]
    Should Be Equal     ${actUl256Qam}      true
    COAM selenium logout

Check bip log is QAM256
    Check L2L1 BIp Log by Luashark for 5822     bip_log=${bip_log_path}

Capture L2L1 BIP log and download for 5822
    [Arguments]     ${duration}=3s
    Start Bip Logs Capture for 5822
    Sleep    ${duration}
    ${log_path_local}    Stop Bip Logs Capture and Download Logs for 5822    log_path=${OUTPUT_DIR}
    set test variable    ${bip_log_path}    ${log_path_local}

Start Bip Logs Capture for 5822
    ${5822_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Test Variable    ${5822_timestamp}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${5822_timestamp}

Stop Bip Logs Capture and Download Logs for 5822
    [Arguments]    ${log_path}
    ${bip_log_local}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${5822_timestamp}
    set test variable    ${bip_log}    ${bip_log_local}[0]
    [Return]    ${bip_log}

Check L2L1 BIp Log by Luashark for 5822
    [Arguments]     ${bip_log}
    ${packets_pusch}    Load BIP with Luashark for 5822    bip_file=${bip_log}
    ...                    command_template=${command_template_puschreceivereq_msg}
    ...                    alias=pusch_5822
    ${modulationOrder_value_list}    pcap.get_field_value_by_xpath    xpath=${modulationOrder_xpath}
    ...      pcap_parser=pusch_5822
    Should Contain       ${modulationOrder_value_list}      8

Load BIP with Luashark for 5822
    [Arguments]     ${bip_file}      ${command_template}     ${alias}
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template=${command_template}
    ...                                 alias=${alias}
    [Return]   ${packets}

Get value from Attenuator
    [arguments]    ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    ${PA_value}      create list
    FOR      ${n}      IN RANGE      ${port_num}
        ${value}    attenuator.read_attenuation
         ...      port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${n}]}    attenuator_device=${vender}
        append to list      ${PA_value}      ${value}
    END
    [Return]      ${PA_value}

UE Attach and Start traffic for 5822
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${UL_THROUGHPUT}     duration=6000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${DL_THROUGHPUT}     duration=6000

UE Check Tput and Curve for 5822
    [Arguments]    ${target_throughput_ul}    ${target_throughput_dl}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog

UE Dettach and Stop traffic for 5822
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Modidy Attenuator by step
    [Arguments]    ${target_value}      ${port_num}
    ${PA_original_value}=      Get value from Attenuator      port_num=${port_num}
    ${Step}=      Run keyword If      ${target_value}>=${PA_original_value}[0]      Evaluate
    ...      (${target_value}-${PA_original_value}[0])/2
    ...      ELSE      Evaluate      (${PA_original_value}[0]-${target_value})/2
    FOR      ${i}      IN RANGE      ${Step}
          ${value}      Evaluate      2+2*${i}+${PA_original_value}[0]
          @{modify_list}      Create List      ${value}      ${value}      ${value}      ${value}
          Modify attenuator value      modify_list=@{modify_list}      port_num=4
          Run keyword if      ${value}>=${target_value}      Exit For Loop
    END

Modify attenuator value
    [arguments]    ${modify_list}      ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${n}]}
          ...      value=${${modify_list}[${n}]}
          ...      attenuator_device=${vender}
    END

Modidy Attenuator by decrease steps
    [Arguments]    ${target_value}      ${port_num}
    ${PA_original_value}=      Get value from Attenuator      port_num=${port_num}
    ${Step}=      Run keyword If      ${target_value}[0]<=${PA_original_value}[0]      Evaluate
    ...      (${PA_original_value}[0]-${target_value}[0])/2
    ...      ELSE      Evaluate      (${target_value}[0]-${PA_original_value}[0])/2
    FOR      ${i}      IN RANGE      ${Step}
          ${value}      Evaluate      ${PA_original_value}[0]-2-2*${i}
          @{modify_list}      Create List      ${value}      ${value}      ${value}      ${value}
          Modify attenuator value      modify_list=@{modify_list}      port_num=4
          Run keyword if      ${value}<=${target_value}[0]      Exit For Loop
    END

Verify DTX and CRC in HarqU message
    [Arguments]    ${package}     ${end_sfn}=0
    ${crc_list}      pcap.get_field_value_by_name     pdml_list=${package}
    ...      field_name=UlData_UePuschReceiveRespHarqU_t.crc
    ${dtx_list}      pcap.get_field_value_by_name     pdml_list=${package}
    ...      field_name=UlData_UePuschReceiveRespHarqU_t.dtx
    ${id_list}      pcap.get_field_value_by_name     pdml_list=${package}
    ...      field_name=UlData_UePuschReceiveRespHarqU_t.harqProcessIndex
    ${sfn_list}    pcap.get_field_value_by_name     pdml_list=${package}
    ...      field_name=frame.number
    ${sfn_lengh}    Get Length    ${sfn_list}
    FOR    ${sfn_idx}    IN RANGE    ${sfn_lengh}
        Run Keyword If    ${sfn_list[${sfn_idx}]}>=${end_sfn}    Exit For Loop
    END
    ${bad_msg_cnt}    set variable    ${0}
    ${bad_msg_cnt}    Dtx Crc Analysis    crc_list=${crc_list}     dtx_list=${dtx_list}    id_list=${id_list}     sfn_idx=${sfn_idx}
    Should be True    ${bad_msg_cnt}<50

Check CRPT file
    ${xz_file}    Download File From ASIB for 5822   log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
	Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
	Run    ${unxz_command}
	Check item on crpt file for 5822    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=-138    check_item="gainCorrection":(\\S\\d*)
	Check item on crpt file for 5822    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=true    check_item="pSRSact":(\\w{4,10})
	Check item on crpt file for 5822    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=86    check_item="occasionDelay":(\\d{1,10})
	Check item on crpt file for 5822    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=8    check_item="ruNumOfTrxInRow":(\\d)
	Check item on crpt file for 5822    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=2    check_item="ruNumOfTrxInColumn":(\\d)
	Check item on crpt file for 5822    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=NUMBEROFCOLTRX_8    check_item=erOfColTRX":"(\\w{8,20})
	Check item on crpt file for 5822    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=NUMBEROFROWTRX_2    check_item=erOfRowTRX":"(\\w{8,20})

Download File From ASIB for 5822
    [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=ASIK Master
    Connect to Common Unit Master
	@{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folde
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    [Return]    ${list_log_path_local}

Check item on crpt file for 5822
    [Arguments]    ${check_value}    ${check_item}    ${file_path}=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	${output}    get_value_from_log_file    file_path=${file_path}    check_item=${check_item}
	Should Contain    ${output}    ${check_value}

UE call and check ue attach log
    log to console      "UE_attach"
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
#    Start capture UE attach log      filename=UE_attach_CPIFLOG.pcap
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
#    stop and download UE attach log      filename=UE_attach_CPIFLOG.pcap
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${UL_THROUGHPUT}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${DL_THROUGHPUT}     duration=2000
    sleep    3s
    Capture L2L1 BIP log and download for 5822
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    log to console      "UE_check_Tput"
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${UL_EXPECT_30M}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${DL_EXPECT_30M}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul
#    Check ue attach Log by Luashark       filename=UE_attach_CPIFLOG.pcap

Start capture UE attach log
    [Arguments]   ${filename}
    ssh.Connect To   hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...              username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...              password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...              alias=GNB_OAM
    ssh.send command    command=lxc-attach -n 0x1514    connection=GNB_OAM
    sleep   3s
    csn.send command    command=tcpdump -i any -w /tmp/${filename} &>/dev/null &    connection=GNB_OAM
    sleep   3s

stop and download UE attach log
    [Arguments]     ${filename}
    ssh.Connect To   hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...              username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...              password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...              alias=GNB_OAM
    ssh.execute        command=ps -ef|grep -i tcpdump     connection=GNB_OAM
    ssh.send command        command=ps -ef|grep tcpdump|grep -v grep| awk '{print $2}' |xargs kill -2     connection=GNB_OAM
    ssh.download_file   remote_path=/tmp/${filename}    local_path=${TS_CASE_LOG_PATH}/${filename}   connection=GNB_OAM
    sleep    2s
    ssh.send command    command=sudo rm /tmp/${filename}    connection=GNB_OAM
    ssh.disconnect    connection=GNB_OAM

Check ue attach Log by Luashark
    [Arguments]   ${filename}
    ${packets_srs}    Load BIP with Luashark for 5822    bip_file=${TS_CASE_LOG_PATH}/${filename}
    ...                    command_template=${command_template_ue_attach_log}
    ...                    alias=${None}
    Filter Packets By Expression       filter_expression=${filter_expression_ue}
    ${maxNumberSRS-Ports-PerResource_list}    Get value from Bip Log    field_name=${maxNumberSRS-Ports-PerResource}
#    ${nrofSRS-Ports_list}     Get value from Bip Log      field_name=${nrofSRS-Ports}
    Should Contain    ${maxNumberSRS-Ports-PerResource_list}      1

Check L2L1 Bip log
    Check L2L1 BIp Log by Luashark for 1086     bip_log=${bip_log_path}

Check L2L1 BIp Log by Luashark for 1086
    [Arguments]     ${bip_log}
    ${packets_srs}    Load BIP with Luashark for 5822    bip_file=${bip_log}
    ...                    command_template=${command_template_srsreceivereq_msg}
    ...                    alias=srs_5822
    ${srsBmEnable_value_list}    pcap.get_field_value_by_name    pdml_list=${packets_srs}
    ...      field_name=${srsBmEnable_filed_name}
    ...      pcap_parser=srs_5822
    Should Contain       ${srsBmEnable_value_list}      1
    ${packets_pusch}    Load BIP with Luashark for 5822    bip_file=${bip_log}
    ...                  command_template=${command_template_puschreceivereq_msg}
    ...                  alias=pusch_5822
    ${patternIdMin_value_list}    pcap.get_field_value_by_name    pdml_list=${packets_pusch}
    ...      field_name=${patternIdMin_value}
    ...      pcap_parser=pusch_5822
    Sort List         ${patternIdMin_value_list}
    Should Be True      ${patternIdMin_value_list}[0] > 1024

Check PDSCH for 5822
    [Arguments]     ${bip_log}
    ${packets_pdsch}    Load BIP with Luashark for 5822    bip_file=${bip_log}
    ...                  command_template=${command_template_pdschsendreq_msg}
    ...                  alias=pdsch_5822
    ${patternIdMin_value_list}    pcap.get_field_value_by_name    pdml_list=${packets_pdsch}
    ...      field_name=${pdsch_patternIdMin_value}
    ...      pcap_parser=pdsch_5822
    Sort List         ${patternIdMin_value_list}
    Should Be True      ${patternIdMin_value_list}[0] > 1024

UE Call and Check PDSCH by Bip log
    log to console      "UE_attach"
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${UL_THROUGHPUT}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${DL_THROUGHPUT}     duration=2000
    sleep    3s
    Capture L2L1 BIP log and download for 5822
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056323
    log to console      "UE_check_Tput"
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${UL_EXPECT_30M}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${DL_EXPECT_30M}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul
    Check PDSCH for 5822       bip_log=${bip_log_path}

UE Attach and collect biplog
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    Capture L2L1 BIP log and download for 5822
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ${list_of_cell_ids}    Create list    16056321
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul
