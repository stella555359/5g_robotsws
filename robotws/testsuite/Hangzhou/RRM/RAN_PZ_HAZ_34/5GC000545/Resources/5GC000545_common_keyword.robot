*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Library           taf.ul.parser.pcap        WITH NAME    pcap
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/data_analysis.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
#7782 case check filter
${ulDmrsMappingType_filter}    UlData_puschReceiveReqGrant_t.ulDmrsMappingType
${ulDmrsTypeAPos_filter}    UlData_puschReceiveReqGrant_t.ulDmrsTypeAPos
${ulDmrsAddPos_filter}    UlData_puschReceiveReqGrant_t.ulDmrsAddPos
${ulPtrsFlag_filter}    UlData_puschReceiveReqGrant_t.ulPtrsFlag
${ulPtrsTimeDensity_filter}    UlData_puschReceiveReqGrant_t.ulPtrsTimeDensity
${ulPtrsFrequencyDensity_filter}    UlData_puschReceiveReqGrant_t.ulPtrsFrequencyDensity
${numOfLayers_filter}    UlData_puschReceiveReqGrant_t.numOfLayers
${xpath_pusch_mcs_filed_name}    .//UlData_puschReceiveReqGrant_t.mcs



*** Keywords ***
Test Case Setup
    robot_common_operations.Common Case Setup
    COAM Create log directory
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    COAM Get active alarms
    Set test variable    ${exist_fault}
    Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}
    ${current_scf}=    Get Current SCF file    dir=${log_path}
    Set test variable    ${current_scf}
    ${date}    Evaluate    datetime.datetime.now().strftime('%Y-%m-%d')    datetime
    Run keyword and ignore Error    Btslog Setup    name=btslog_${date}    path=/opt/ute/tools/btslog/btslog
    ...    launcher_path=/opt/ute/tools/btslog/btslog_launcher    log_folder=/tmp/btslog2
    Set test variable    ${date}
    @{modify_list}      Create List      20      20      20      20
    Modify attenuator value      modify_list=@{modify_list}      port_num=4


Test Case Teardown
    robot_common_operations.Common Case Teardown
    Modify attenuator value      modify_list=@{Original_Value}      port_num=4
    Remove Files    ${OUTPUT_DIR}/*.pdml
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    Run keyword And Ignore Error    Btslog Teardown    name=btslog_${date}
    Run keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

Get Current SCF file
    [Arguments]    ${dir}    ${file_name}=SCF_backup.xml    ${timeout}=600s    ${connection}=GNB_OAM
    ${file}    coam.get_current_scf_file
    ...      local_dir_path=${dir}    file_name=${file_name}    timeout=${timeout}    connection=${connection}
    [Return]    ${file}

Btslog Setup
    [Arguments]    ${name}      ${path}    ${launcher_path}    ${log_folder}
    ${executor_test_vm}=      Create Dictionary
    ...    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...    user=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    btslog_path=${path}
    ...    btslog_launcher_path=${launcher_path}
    ...    executor=${executor_test_vm}
    ...    log_dir=${log_folder}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    btslog.Set Suite Alias     ${name}

Btslog Teardown
    [Arguments]    ${name}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}
    core.teardown_collectors    names=${name}

UE Attach and Start traffic
    [Arguments]     ${4G_check_needed}=False    ${TPut}=150M
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Wait Until Keyword Succeeds    5 min    30 sec    power_ue.Verify attach
    ...    ue_type=${ue_type}      4G_check=${4G_check_needed}     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic
    ...      ue_type=${ue_type}     direction=ul     throughput=${TPut}     duration=1200     iperf_port=${ul_port}

UE Dettach and Stop traffic
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    iperf_port=51026
    power_ue.UE Detach     ue_type=${ue_type}

Load BIP with Luashark
    [Arguments]     ${bip_file}      ${command_template}
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template=${command_template}
    [return]    ${packets}

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

Modify attenuator value
    [arguments]    ${modify_list}      ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${n}]}
          ...      value=${${modify_list}[${n}]}
          ...      attenuator_device=${vender}
    END

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

Enable mirror port on Loki
    [Arguments]     ${mirror_port}=eths2    ${backplane_port}=C1B1(2)    ${slot_id}=1    ${asik_alias}=ASIK Master
    ${command1}=      Catenate      /usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL
                 ...      -b "${backplane_port}" -s ${slot_id} -l ${mirror_port} -v 303
    ${command2}=      Catenate      /usr/bin//lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL
                 ...      -b "${backplane_port}" -s ${slot_id} -l ${mirror_port} -v 303
    csn.Execute     command=${command1}      connection=${asik_alias}
    csn.Execute     command=${command2}      connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -p xgmac97 -r
    ...             connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -d netdriver -p xgmac97
    ...             connection=${asik_alias}


Start Bip Log Capture
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    5GC000545_common_keyword.Enable mirror port on Loki    mirror_port=${mirror_port}
    csn.Send command     command=tcpdump -i ${mirror_port} -w /tmp/tcpdump_L2L1.pcap
    ...                  connection=${asik_alias}

Captue Bip log on Loki
    Connect to Common Unit Master
    Start Bip Log Capture

Check MSG Status
    [Arguments]      ${result_all}      ${dtx}      ${crc}      ${id}
    ${status}     Run Keyword If     ${dtx}==0 and ${crc}==0     Set Variable     OK
    ...            ELSE      Set Variable     NOK
    ${cnt}     Get Length     ${result_all}
    ${flag}     Run Keyword If     ${cnt}!=0     _Check New ID or NOT      result=${result_all}     id=${id}     cnt=${cnt}
    ...         ELSE     Set Variable     NEW
    &{result}      Create Dictionary      ID=${id}      STATUS=${status}      COUNTER=${0}
    Run Keyword If      '${flag}'=='NEW'      Append To List      ${result_all}      ${result}
    ${result_all}      Run Keyword If      '${flag}'=='OLD'      _Update Status Dictionary      result=${result_all}      id=${id}
    ...     status=${status}      cnt=${cnt}
    ...         ELSE      Set Variable      ${result_all}
    [Return]      ${result_all}

_Check New ID or NOT
    [Arguments]      ${result}      ${id}      ${cnt}
    ${flag}      Set Variable      NEW
    FOR      ${i}      IN RANGE      ${cnt}
        Exit For Loop If      '${flag}'=='OLD'
        ${flag}      Run Keyword If      ${result[${i}]}[ID]==${id}      Set Variable      OLD
        ...         ELSE      Set Variable      NEW
    END
    [Return]      ${flag}

_Update Status Dictionary
    [Arguments]      ${result}      ${id}      ${status}      ${cnt}
    FOR      ${i}      IN RANGE      ${cnt}
        Continue For Loop If      ${result[${i}]}[ID]!=${id}
        Run Keyword If      '${result[${i}]}[STATUS]'=='${status}'
        ...      Set To Dictionary      ${result[${i}]}      COUNTER      ${${result[${i}]}[COUNTER]+1}
        Run Keyword If      '${result[${i}]}[STATUS]'!='${status}'
        ...      Set To Dictionary      ${result[${i}]}      COUNTER      ${0}
        Set To Dictionary      ${result[${i}]}      STATUS      ${status}
    END
    [Return]      ${result}

_Check no dtx and crc lost
    [Arguments]      ${result}
    ${flag}    set variable    Succ
    ${i}    set variable    ${0}
    ${steps}=      Get Length      ${result}
    FOR      ${result_list}      IN RANGE      ${steps}
        ${counter}=      Get Dictionary Values      ${result}[${result_list}]
        ${status}=     Run keyword If      ${counter}[0]>=4 and '${counter}[2]'=='NOK'      Set Variable      False
        ...     ELSE      Set Variable      True
        Run keyword If    ${status}==False    set variable    ${flag}    Fail
        Run keyword If    ${status}==False    Set To Dictionary      ${result[${i}]}      COUNTER     ${0}
        Run keyword If    ${status}==False    Set To Dictionary      ${result[${i}]}      STATUS     OK
        Exit For Loop If    ${status}==False
        Set Test Variable    ${i}    ${${i}+1}
    END
    [Return]    ${flag}    ${result}

Verify DTX and CRC in HarqU message
    [Arguments]    ${package}     ${end_sfn}=0
    ${crc_list}      pcap.get_field_value_by_name    pdml_list=${package}
    ...      field_name=UlData_UePuschReceiveRespHarqUL1sw_t.crc
    ${dtx_list}      pcap.get_field_value_by_name    pdml_list=${package}
    ...      field_name=UlData_UePuschReceiveRespHarqUL1sw_t.dtx
    ${id_list}      pcap.get_field_value_by_name    pdml_list=${package}
    ...      field_name=UlData_UePuschReceiveRespHarqUL1sw_t.harqProcessIndex
    ${sfn_list}    pcap.get_field_value_by_name   pdml_list=${package}
    ...      field_name=frame.number
    ${sfn_lengh}    Get Length    ${sfn_list}
    FOR    ${sfn_idx}    IN RANGE    ${sfn_lengh}
        Run Keyword If    ${sfn_list[${sfn_idx}]}>=${end_sfn}    Exit For Loop
    END
    #${cnt}      Get Length      ${crc_list}
    #${check_result}      Create List
    ${bad_msg_cnt}    set variable    ${0}
    ${bad_msg_cnt}    Dtx Crc Analysis    crc_list=${crc_list}     dtx_list=${dtx_list}    id_list=${id_list}     sfn_idx=${sfn_idx}
	#FOR      ${i}      IN RANGE      ${sfn_idx}    ${cnt}
    #    ${check_result}        Check MSG Status      result_all=${check_result}       dtx=@{dtx_list}[${i}]
    #    ...       crc=@{crc_list}[${i}]       id=@{id_list}[${i}]
    #    ${status}    ${check_result}    _Check no dtx and crc lost      result=${check_result}
    #    Run keyword if     '${status}'=='fail'    Set Test Variable    ${bad_msg_cnt}    ${${bad_msg_cnt}+1}
    #END
    #${full_steps}=      Get Length    ${check_result}
    #FOR    ${result}    IN RANGE       ${full_steps}
    #    ${value}=      Get Dictionary Values      ${check_result}[${result}]
    #    Run Keyword If      '${value}[2]'=='NOK'      Set Test Variable    ${bad_msg_cnt}    ${${bad_msg_cnt}+1}
    #END
    Run keyword and Ignore Error     Should be True    ${bad_msg_cnt}<50
    #Run keyword if    ${cnt}==0    Fail    crc lost

Commissioning with Template Commission
    [Arguments]    ${scf_file}     ${g_type}='NSA'
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf_file}    timeout=600
    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type=${g_type}

Check UL DMRS enable
    Connect to gnb coam via ssl
    ${actUl256Qam}    5GC000545_common_keyword.Get_parameter_value
    ...                abbr=actUl256Qam
    ...                filter_param=Activate 256QAM in UL
    ${mcs_threshold}    Run Keyword If    '${actUl256Qam}'=='true'    5GC000545_common_keyword.Get_parameter_value
    ...            abbr=ulDataDmrsFdmThres256QamMcs
    ...            filter_param=Uplink data and DMRS FDM threshold 256QAM MCS
    ...       ELSE     5GC000545_common_keyword.Get_parameter_value
    ...                   abbr=ulDataDmrsFdmThres64QamMcs
    ...                   filter_param=Uplink data and DMRS FDM threshold 64QAM MCS
    Filter Packets By Expression      filter_expression=${uldmrsflag_filed_name}==1
    ${mcs_value}    Get value from Bip Log by xpath     xpath=${xpath_pusch_mcs_filed_name}
    ${uldmrsflag_value}    Get value from Bip Log    field_name=${uldmrsflag_filed_name}
    ${unexpected_value}    Count Values In List    ${uldmrsflag_value}    2
    ${start_index}    Set Variable    ${0}
    FOR    ${i}   IN RANGE    ${unexpected_value}
        ${index}    Get Index From List    ${uldmrsflag_value}    2    start=${start_index}
        ${remove_index}    Evaluate    ${index}-${i}
        ${rm_value}    Remove From List    ${mcs_value}    ${remove_index}
        Log to console    ${rm_value}
        ${start_index}    Evaluate    ${index}+1
    END
    ${mcs_value}     Remove Duplicates    ${mcs_value}
    ${length}    Get Length    ${mcs_value}
    Should Be True    ${length}>${0}
    FOR    ${i}    IN RANGE    ${length}
        Should Be True    ${mcs_value}[${i}]>=${mcs_threshold}
    END
    ${uldmrs_filter}=      Run Keyword                                         Catenate    ${uldmrsflag_filed_name}==0x02
    ...                                                                        and UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag == 0
    ...                                                                        and UlData_puschReceiveReqGrant_t.mcs !=9
    ...                                                                        and UlData_puschReceiveReqGrant_t.ulDmrsAddPos!=2
    ${filtered_packets}    pcap.filter_packets_by_expression
    ...      filter_expression=${uldmrs_filter}
    ${uldmrsflag}    Get value from Bip Log by xpath    xpath=${xpath_pusch_mcs_filed_name}
    ${545_uldmrsflage_list}     Remove Duplicates    ${uldmrsflag}
    ${length}    Get Length    ${545_uldmrsflage_list}
    Should Be True    ${length}>${0}
    FOR    ${i}    IN RANGE    ${length}
        Should Be True    ${545_uldmrsflage_list}[${i}]<${mcs_threshold} or ${545_uldmrsflage_list}[${i}]<=28
    END

Check 7782 case keypoints
    [Documentation]    case1/2/3 value as follow
    ...                ulDmrsMappingType=TypeA(0)/A/A
    ...                ulDmrsTypeAPos=3/3/2
    ...                ulDmrsAddPos=0/1/0
    ...                ulPtrsFlag=0/0/1
    ...                ulPtrsTimeDensity=1/1/1
    ...                ulPtrsFrequencyDensity=4/4/2
    ...                numOfLayers=1/1/2
    [Arguments]    ${ulDmrsMappingType}
    ...            ${ulDmrsTypeAPos}    ${ulDmrsAddPos}
    ...            ${ulPtrsFlag}    ${ulPtrsTimeDensity}
    ...            ${ulPtrsFrequencyDensity}    ${numOfLayers}
    Filter Packets By Expression      filter_expression=${uldmrsflag_filed_name}==1
    Check the fix value from bip
    ...                         type_filter=${ulDmrsMappingType_filter}
    ...                         plan_value=${ulDmrsMappingType}
    Check the fix value from bip
    ...                         type_filter=${ulDmrsTypeAPos_filter}
    ...                         plan_value=${ulDmrsTypeAPos}
    Check the fix value from bip
    ...                         type_filter=${ulDmrsAddPos_filter}
    ...                         plan_value=${ulDmrsAddPos}
    Check the fix value from bip
    ...                         type_filter=${ulPtrsFlag_filter}
    ...                         plan_value=${ulPtrsFlag}
    Check the fix value from bip
    ...                         type_filter=${ulPtrsTimeDensity_filter}
    ...                         plan_value=${ulPtrsTimeDensity}
    Check the fix value from bip
    ...                         type_filter=${ulPtrsFrequencyDensity_filter}
    ...                         plan_value=${ulPtrsFrequencyDensity}
    Run keyword And Ignore Error    Check the fix value from bip
    ...                         type_filter=${numOfLayers_filter}
    ...                         plan_value=${numOfLayers}

Get_parameter_value
    [Arguments]    ${abbr}    ${filter_param}
    Connect to gnb coam via ssl
    ${current_scf}=    Get Current SCF file    dir=${log_path}
    ${mrbtsid}    ${nrbtsid}    ${nrcellid}    get_mrbtsid_from_scf    file_path=${current_scf}
    ${dist_name}    set variable    MRBTS-${mrbtsid}/NRBTS-${nrbtsid}/NRCELL-${nrcellid}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${value}    selenium_coam.get_parameter_value
    ...                                          abbr=${abbr}
    ...                                          filter_param=${filter_param}
    ...                                          dist_name=${dist_name}
    [Return]    ${value}
    [teardown]    COAM selenium logout


Check the fix value from bip
    [Documentation]    get the value from bip and contrast with the planned value
    [Arguments]    ${type_filter}    ${plan_value}
    ${get_bip_value}    Get value from Bip Log    field_name=${type_filter}
    ${get_bip_value}     Remove Duplicates    ${get_bip_value}
    ${length}    Get Length    ${get_bip_value}
    Should Be True    ${length}>${0}
    Should Be True    ${get_bip_value}[0]==${plan_value}

Verify puschTransformPrecode status in BIP
    [Arguments]    ${packets}      ${expect_staus}
    ${numofprb_list}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...      field_name=UlData_puschReceiveReqGrant_t.numOfPrb
    ${puschTransformPrecoderFlag_values}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...      field_name=UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag
    ${spatialmode_value}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...      field_name=UlData_puschReceiveReqGrant_t.spatialMode
    ${sfn_list}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...       field_name=frame.number
    ${mcs_list}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...       field_name=UlData_puschReceiveReqGrant_t.mcs
    ${numofDMRS}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...       field_name=UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
    ${uldmrsaddpos_lis}      pcap.get_field_value_by_name    pdml_list=${packets}
    ...       field_name=UlData_puschReceiveReqGrant_t.ulDmrsAddPos
    ${rnti_list}    pcap.get_field_value_by_name    pdml_list=${packets}
    ...      field_name=_3gpp.rnti
    ${list}    Get start and end index in PuschReceiveReq
    ...    DFT_status_list=${puschTransformPrecoderFlag_values}
    ...    spatialmode_list=${spatialmode_value}
    ...    mcs_list=${mcs_list}
    ...    numofDMRS=${numofDMRS}
    ...    uldmrsaddpos=${uldmrsaddpos_lis}
    ${start_index}=    Set Variable    ${list}[0]
    Set Test Variable    ${start_index}
    ${end_index}=    Set Variable    ${list}[1]
    Set Test Variable    ${end_index}
    ${numofprb_length}=    Get Length    ${mcs_list}
    ${end_sfn}=    Set Variable    ${sfn_list[${end_index}]}
    Set Test Variable    ${end_sfn}

    ${puschTransformPrecoderFlag_values_list}      Get Slice From List      ${puschTransformPrecoderFlag_values}
    ...      ${start_index-1}      ${end_index}
    ${new_puschTransformPrecoderFlag_values_list}      Remove Duplicates      ${puschTransformPrecoderFlag_values_list}
    @{target_list}=    Create List      0
    Should Be Equal    ${new_puschTransformPrecoderFlag_values_list}    ${target_list}
    ${status}=    Run keyword If     ${expect_staus}=='enable'    Set Variable    1
    ...    ELSE    Set Variable     0
    Should Be Equal    ${puschTransformPrecoderFlag_values[${end_index+1}]}    ${status}
    Run keyword       Check pingpong by mcs    DFT_status_list=${puschTransformPrecoderFlag_values}
    ...                                                                        spatialmode_list=${spatialmode_value}
    ...                                                                        mcs_list=${mcs_list}
    ...                                                                        uldmrsaddpos=${uldmrsaddpos_lis}
    ...                                                                        rnti_list=${rnti_list}

Check pingpong by mcs
    [Arguments]     ${DFT_status_list}    ${spatialmode_list}     ${mcs_list}      ${uldmrsaddpos}    ${rnti_list}
    ${length}=    Get Length    ${mcs_list}
    @{list}    create list    0
    FOR     ${i}    IN RANGE    ${end_index+1}    ${length-1}
        Continue For Loop If    ${rnti_list}[${i}] != ${rnti}
        FOR     ${j}    IN RANGE    ${i+1}    ${length-1}
            Continue For Loop If    ${rnti_list}[${j}] != ${rnti}
            ${next_dft_status}    Set Variable    ${DFT_status_list}[${j}]
            Exit For Loop
        END
        ${status}    Run keyword If
        ...    ${uldmrsaddpos}[${i}]== 2 and ${DFT_status_list}[${i}]==0 and ${spatialmode_list}[${i}]==0 and ${next_dft_status}==1
        ...    Set Variable      False      ELSE      Set Variable      True
        Run keyword If    ${status}==False    Append To List    ${list}    1    ELSE    Append To List    ${list}    0
    END
    Remove Values From List    ${list}    0
    ${length}=     Get length     ${list}
    Run keyword If     ${length}>2     Fail     Failed,pingpong more than twice


Check pingpong by prb
    [Arguments]     ${DFT_status_list}    ${spatialmode_list}     ${prb_list}
    ${length}=    Get Length    ${prb_list}
    @{list}    create list    0
    FOR     ${i}    IN RANGE    ${end_index+1}    ${length-1}
        ${status}    set variable if
        ...    ${prb_list}[${i}]==12 and ${DFT_status_list}[${i}]==0 and ${spatialmode_list}[${i}]==0   and ${DFT_status_list}[${i}]==1
        ...    Set Variable      False      ELSE      Set Variable      True
        Run keyword If    ${status}==False    Append To List    ${list}    1    ELSE    Append To List    ${list}    0
    END
    Remove Values From List    ${list}    0
    ${length}=     Get length     ${list}
    Run keyword If     ${length}>2     Fail     Failed,pingpong more than twice

Start Bip Log
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=${None}
    ...            ${gnb_index}=0
    ...            ${timeout}=900
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Run Keyword       Collect Interface Mirroring Bip Collector
    ...                                target_file_name=${target_file_name}
    ...                                nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                gnb_index=${gnb_index}
    ...                                timeout=${timeout}
    ...                                interface=${interface}
    ...                                destination=${destination}
    ...                                host_ip=${host_ip}
    ...                                username=${username}
    ...                                password=${password}

Stop Bip Log
    [Arguments]      ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap    ${target_dir}=${TS_CASE_LOG_PATH}
    sleep    90s
    ${full_log_path}    Run Keyword      Get Bip Log Via Interface Mirroring Collector
    ...                                                                    target_file_name=${target_file_name}
    ...                                                                    pattern=${pattern}
    ...                                                                    target_dir=${target_dir}
    [Return]    ${full_log_path}

Get start and end index in PuschReceiveReq
    [Arguments]    ${DFT_status_list}    ${spatialmode_list}     ${mcs_list}     ${numofDMRS}      ${uldmrsaddpos}

    ${index}=    Run Keyword      Get start and end index in PuschReceiveReq by mcs
    ...                                                             DFT_status_list=${DFT_status_list}
    ...                                                             spatialmode_list=${spatialmode_list}
    ...                                                             numofDMRS=${numofDMRS}
    ...                                                             mcs_list=${mcs_list}
    ...                                                             uldmrsaddpos=${uldmrsaddpos}
    [Return]      ${index}

Get start and end index in PuschReceiveReq by mcs
    [Arguments]    ${DFT_status_list}    ${spatialmode_list}     ${mcs_list}   ${numofDMRS}      ${uldmrsaddpos}
    ${length}=      Get Length      ${mcs_list}
    @{list}    create list
    FOR      ${i}      IN RANGE     ${length-2}
        ${status}=    Run Keyword If
        ...    ${uldmrsaddpos}[${i}]== 2 and ${DFT_status_list}[${i}]==0 and ${spatialmode_list}[${i}]==0 and ${numofDMRS}[${i}]==2
        ...    Set Variable    True    ELSE    Set Variable    False
        Run Keyword If    ${status}==True    append to list    ${list}    ${i}
    END
    @{list_new}    create list
    log to console    ${list}
    FOR     ${i}    IN     @{list}
            ${list}=      Get end index by mcs
            ...            DFT_status_list=${DFT_status_list}
            ...            mcs_list=${mcs_list}
            ...            list_new=${list_new}
            ...            index=${i}
            ...            numofDMRS=${numofDMRS}
    END
    log to console    ${list_new}
    [return]  ${list_new}

Get end index by mcs
    [Arguments]  ${DFT_status_list}    ${mcs_list}    ${list_new}    ${numofDMRS}    ${index}
    ${length}=      Get Length      ${mcs_list}
    FOR    ${j}    IN RANGE    ${index}    ${length-2}
            ${status}=    Run Keyword If
            ...    ${DFT_status_list}[${j}]==1 and ${DFT_status_list}[${j-1}]==0 and ${numofDMRS}[${j-1}]==2
            ...    Set Variable    True    ELSE     Set Variable    False
            RUN Keyword If    ${status}==True    append to list     ${list_new}     ${index}    ${j}
            Exit for Loop If    ${status}==True
#            Exit for Loop If    ${DFT_status_list}[${j}]==0 and ${uldmrsaddpos}[${j}]==2 and ${numofDMRS}[${j}]==2
    END
    [return]  ${list_new}

Get start and end index in PuschReceiveReq by prb
    [Arguments]    ${DFT_status_list}    ${spatialmode_list}     ${prb_list}   ${numofDMRS}
    ${length}=      Get Length      ${mcs_list}
    @{list}    create list
    FOR      ${i}      IN RANGE     ${length-2}
        ${status}=    Run Keyword If
        ...    ${prb_list}[${i}]== 12 and ${DFT_status_list}[${i}]==0 and ${spatialmode_list}[${i}]==0 and ${numofDMRS}[${i}]==2
        ...    Set Variable    True    ELSE    Set Variable    False
        Run Keyword If    ${status}==True    append to list    ${list}    ${i}
    END
    @{list_new}    create list
    log to console    ${list}
    FOR     ${i}    IN     @{list}
            ${list}=      Get end index by mcs
            ...            DFT_status_list=${DFT_status_list}
            ...            mcs_list=${mcs_list}
            ...            list_new=${list_new}
            ...            index=${i}
            ...            numofDMRS=${numofDMRS}
    END
    log to console    ${list_new}
    [return]  ${list_new}

Get end index by prb
    [Arguments]  ${DFT_status_list}    ${prb_list}    ${list_new}    ${numofDMRS}    ${index}
    ${length}=      Get Length      ${mcs_list}
    FOR    ${j}    IN RANGE    ${index}    ${length-2}
            ${status}=    Run Keyword If
            ...    ${prb_list}[${j}]!=12 and ${DFT_status_list}[${j}]==1 and ${DFT_status_list}[${j-1}]==0 and ${numofDMRS}[${j-1}]==2
            ...    Set Variable    True    ELSE     Set Variable    False
            RUN Keyword If    ${status}==True    append to list     ${list_new}     ${index}    ${j}
            Exit for Loop If    ${status}==True
            Exit for Loop If    ${prb_list}[${j}]!=12 and ${DFT_status_list}[${j}]==0
    END
    [return]  ${list_new}
