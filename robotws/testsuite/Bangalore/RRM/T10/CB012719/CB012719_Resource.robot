*** Settings ***
Documentation       copyright : nokia
Variables    ta5g_global_var
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../../../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../../../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../../../resources/robot/Setup_Env.robot
Resource       ../../../resources/robot/common_log_collection.robot
Resource        ../../../resources/ECEcommon/common_file_operation.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ../../../resources/robot/TTI_Traces.robot
Resource         ../../../resources/robot/Iperf_Traffic.robot
Library          ../../../resources/python/ssh_command.py
Resource        ../../../resources/ECEcommon/common_deal_config_file.robot
Resource        ../../../resources/ECEcommon/common_file_operation.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          ../../../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../../../resources/python/BIP_Capture.py
Library          ../../../resources/python/CPRT_Capture.py
Library          ./python/only_measurement.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a
#Library          taf.sw.wtssim
Library    ./python/check_alarm.py
Library    ./python/increase_buffer_size.py
Library    ./python/utility.py
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout
Library         ./python/basic.py
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
*** Variables ***
${enhancedSkipUplink_pattern}    *enhancedSkipUplinkTxConfigured-r16*
${RD_PARAM}          0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;
${RD_PARAM_DIS}      0x5901C9=0;0x600012=0;0x5901CA=0;0x190297=0;
${UE_attach_pattern}    reported successful RA
${Bearer_ID2}          3
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${port}                    22
${NUM_UL_SYMB_IMPACT_RI}    M55194C00001
${DUR_UL_IMPACT_RI}    M55194C00002
${DUR_DL_SPCL_MUT_RIM_MITG}     M55194C00003
${NUM_MUT_SLOT_SCHD_HI_PRI_DATA}       M55194C00284
${PRB_USED_PDSCH_MUT_HI_PRI_DATA}            M55194C00283
${DUR_1ST_DL_MUT_RIM_MITG}     M55194C00281
${DUR_2ND_DL_MUT_RIM_MITG}       M55194C00282
${DUR_DL_SPCL_PWR_RED_RIM_MITG}     M55194C00287
${DUR_2ND_DL_PWR_RED_RIM_MITG}      M55194C00286
${DUR_1ST_DL_PWR_RED_RIM_MITG}      M55194C00285
${API_KEY}                         8f5ced1b-d771-454c-b619-5c006f372205
${TEMPLATE_ID}                     2852

*** Keywords ***
Configure Scout API
    [Documentation]      Intial Scout Configuration. Requires Scout api key available in scout.
    [Arguments]    ${testline_name}    ${api_key}
    scout.Setup Scout    scout_testline_name=${testline_name}    api_key=${api_key}    timeout=200    alias=scoutalias
    Log To Console    Scout API successfully configured for testline: ${testline_name}

Round Time To Next 15 Min
    [Arguments]    ${timestamp}

    ${dt}=    Evaluate    datetime.datetime.strptime($timestamp,"%Y-%m-%dT%H:%M:%S.%fZ")    modules=datetime
    ${add}=   Evaluate    (15 - $dt.minute % 15) % 15
    ${dt2}=   Evaluate    ($dt + datetime.timedelta(minutes=$add)).replace(second=0,microsecond=0)    modules=datetime
    ${rounded}=    Evaluate    $dt2.strftime("%Y-%m-%dT%H:%M:%S.000Z")

    RETURN    ${rounded}

Enable Kpi Pm Collection
    [Documentation]      Teardowns the scout connection
    [Arguments]    ${alias}=scoutalias
    Log To Console    Attempting to tear down Scout API connection for alias: ${alias}
    scout.Enable Full Kpi Pm Collection    alias=${alias}
    Log To Console    Scout API connection successfully torn down.

Generate Scout Kpi Report
    [Documentation]    Generates a KPI report in Scout for a specified testline.
    ...    This keyword requires an API_KEY to be provided during the library setup
    [Arguments]    ${report_name}    ${template_id}    ${start_time}    ${end_time}=${None}    ${alias}=scoutalias
    ${KPI_REPORT}=    scout.Generate Kpi Report
    ...    report_name=${report_name}
    ...    template_id=${template_id}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    alias=${alias}
    Create KPI Report JSON File     ${KPI_REPORT}   ${report_name}
    [Return]    ${KPI_REPORT}

Create KPI Report JSON File
    [Documentation]     Convert KPI report to JSON
    [Arguments]    ${KPI_REPORT}    ${filename}
    ${json_string}=    Evaluate    json.dumps($KPI_REPORT)    modules=json
    Create File    ${filename}    ${json_string}
    [Return]    ${json_string}



Round Time To Next 15 Min With Wait
    [Arguments]    ${timestamp}
    ${dt}=    Evaluate    datetime.datetime.strptime($timestamp,"%Y-%m-%dT%H:%M:%S.%fZ")    modules=datetime
    ${minutes_total}=    Evaluate    $dt.hour * 60 + $dt.minute
    ${seconds_total}=    Evaluate    $minutes_total * 60 + $dt.second
    ${microseconds_total}=    Evaluate    ${seconds_total} * 1000000 + $dt.microsecond
    ${interval_microseconds}=    Evaluate    15 * 60 * 1000000
    ${remainder}=    Evaluate    ${microseconds_total} % ${interval_microseconds}
    ${add_microseconds}=    Evaluate    0 if ${remainder} == 0 else ${interval_microseconds} - ${remainder}
    ${add_minutes}=    Evaluate    ${add_microseconds} // (60 * 1000000)
    ${add_seconds}=    Evaluate    (${add_microseconds} % (60 * 1000000)) // 1000000
    ${add_micro}=    Evaluate    ${add_microseconds} % 1000000
    ${dt2}=    Evaluate    $dt + datetime.timedelta(minutes=${add_minutes}, seconds=${add_seconds}, microseconds=${add_micro})    modules=datetime
    ${rounded}=    Evaluate    $dt2.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    ${wait_ms}=    Evaluate    int(($dt2 - $dt).total_seconds() * 1000)
    RETURN    ${rounded}    ${wait_ms}

Make connection
     coam.setup_admin    bts_host=${GNB.ip}     alias=${connection}    admin_api_log_dir=/tmp

Verify Counters modi
    [Arguments]  ${counters}    ${moc}    ${slices}=None
     ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
     ${counter_ids}=   Get Dictionary Keys    ${counters}
     ${counter_val}    Create Dictionary
     FOR   ${counter_id}  IN  @{counter_ids}
        ${e_value} =	Get From Dictionary	${counters}    ${counter_id}
        ${val}     Validate PM Counters_pcell_scell   ${PM_dir_1}    ${counter_id}    ${e_value}   ${moc}
        ${counter_val}    Run Keyword If     ${slices}!=None     update_slice_value    ${val}
     END

     [Return]    ${counter_val}


Get Total value of counter and compare
    [Arguments]   ${pm_files_location}     ${pi_id}    ${expected_value}    ${moc}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=PM*
    ${rc}       basic.get_total_cmp      ${PM_report_dict_list}     ${expected_value}    ${moc}
    Should Contain  ${rc}  PASS
    ${rest}	     ${val}     Split String From Right	    ${rc}    '#'

    [Return]    ${val}


Validate PM Counters_pcell_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
#    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
#    ...  pi_id=${PM_counter}    moc=${moc}
    ${val}    Get Total value of counter and compare   ${PM_dir}   ${PM_counter}   ${expected_value}    ${moc}
    [Return]    ${val}

Compare counters
    [Arguments]     ${slices}     ${counter_ctg1}     ${counter_ctg2}
    FOR    ${slice}    IN    @{slices}
        Return From Keyword If     ${counter_ctg1}[${slice}] != ${counter_ctg2}[${slice}]     Fail
    END
    [Return]    Pass


Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

Copy WTS Log Files
    ${egate_log_path}   Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/egate
    OperatingSystem.Run    mkdir ${egate_log_path}
    OperatingSystem.Run    cp ${WTS_DIR}/*.log.* ${egate_log_path}

Add RD Parameters To GNB Swconfig File
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB    ${path}

Get Swconfig File From GNB
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

Check MCShark Version
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${list_version}=    Split String    ${sw_version}    _
    ${rest}    ${last}=    Split String From Right    ${sw_version}    _    1
    ${new_version}=    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${sw_version}
    [Return]    ${new_version}

Get Tshark Version
    ${version}=    Run    tshark -v|grep TShark|grep -P v[0-9]+.[0-9]+ -o|cut -d "v" -f 2
    [Return]    ${version}

Download MCShark To UTE
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${sw_version}=    CB008927_resource.Check MCShark Version    ${sw_version}
    ${cmd}=    Set Variable    wget -r -np -nH ${MCSHARK_URL}/${sw_version}/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"    There is no MCShark downloaded! Please contact MCshark team!
    ${tashark_version}=    Get Tshark Version
    ${MCShark}=    Run    ls -1t ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${tashark_version}*buster.so
    ${MCShark_list}=    String.Split To Lines    ${MCShark}
    ${MCShark_newest}=    Set Variable    @{MCShark_list}[0]
    OperatingSystem.Run    sudo rm -f ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} ${MCSHARK_PLUGIN}/${tashark_version}/epan/
    Should Be True    "${rc}"=="0"    No MCSHark file is copied to the wireshark plugin folder

Copy Preference For MCShark
    [Arguments]    ${preference_file}
    #${preference_file}=    Set Variable    /home/ute/Downloads/preferences
    Run    sudo cp ${preference_file} /home/ute/.config/wireshark/preferences
    Run    sudo cp ${preference_file} /usr/share/wireshark/preferences


Convert PCAP to CSV
    [Arguments]    ${PcapFile}  ${filters}    ${event}    @{headers}
    ${files}      List Files In Directory	   ${PcapFile}
    ${files}    get pcap files only    ${files}
    ${JsonPath}    ConvertPcapToJson    ${PcapFile}/${files}[0]     ${filters}
    ${csv_file_path}    get_values    ${JsonPath}  ${event}    @{headers}
    [Return]    ${csv_file_path}

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |

    #${tashark_version}=    Get Tshark Version
    ${mcshark_file}    Run    find /home/ute/ -name mcshark-*buster.so
    #${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    Run Keyword If    '${res}'=='False'    CB008927_resource.Download MCShark To UTE
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Activate RI
    [Arguments]    ${noise}
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${noise}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${noise}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Deactivate RI
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=deactivate

Verify Fault Description
    [Arguments]    ${faultid}    ${faultname}    ${description}=None  ${cell}=NRCELL-1
    ${cellid}   Catenate    SEPARATOR=    MRBTS-1/NRBTS-1/${cell}
    ${result}    check_alarm.check_alarm_description     ${faultid}    ${faultname}    ${description}   ${cellid}
    run keyword and continue on failure   Run Keyword if   ${result}!=${True}   Fail   Alarm is not matching

Generate RS1
    [Arguments]    ${profile_id}=${1}	${propagation_delay}=${16}    ${rsNearFarConfig}=${0}    ${numRbForRs}=${48}
    ...       ${rsPattern1Period}=50    ${rsPattern2Period}=${-1}   ${repetitionRsType1}=${4}    ${factorRsSequence}=${1}
    ...       ${offsetRsSequence}=${1}    ${startRbForRs}=1,5,100,150    ${numRsType1SetId}=${65536}    ${config_mode}=standalone
	...		${aggressor_cell}=${1}    ${victim_cell}=${1}    ${rsSetId}=${11144}   ${numRsSetId}=${1}    ${rimRsType}=rsType1
    ...   ${rsType1NScId}=1,2,3,4,5,6,7,8    ${rimRsTxPower}=${-330}
    Builtin.Log     ${numRbForRs}
    Builtin.Log     ${numRsSetId}
    ${RS1_1}=   Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile_id} config_mode=${config_mode} aggressor_cell=${aggressor_cell} victim_cell=${victim_cell}
    ...  \ rsSetId=${rsSetId} rimRsTxPower=${rimRsTxPower} numRsSetId=1 rimRsType=${rimRsType} rsNearFarConfig=${rsNearFarConfig}
    ...  \ propagation_delay=${propagation_delay}
    ...  \ rsType1NScId=${rsType1NScId} numRbForRs=${numRbForRs} rsPattern1Period=${rsPattern1Period} rim_framework=framework_0
    ...  \ repetitionRsType1=${repetitionRsType1} factorRsSequence=${factorRsSequence} offsetRsSequence=${offsetRsSequence}
    ...  \ startRbForRs=${startRbForRs} numRsType1SetId=${numRsType1SetId}

    ${RS1_2}=      Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile_id} config_mode=${config_mode} aggressor_cell=${aggressor_cell} victim_cell=${victim_cell}
    ...  \ rsSetId=${rsSetId} rimRsTxPower=${rimRsTxPower} numRsSetId=1 rimRsType=${rimRsType} rsNearFarConfig=${rsNearFarConfig}
    ...  \ propagation_delay=${propagation_delay}
    ...  \ rsType1NScId=${rsType1NScId} numRbForRs=${numRbForRs} rsPattern1Period=${rsPattern1Period} rsPattern2Period=${rsPattern2Period}
    ...  \ rim_framework=framework_0 repetitionRsType1=${repetitionRsType1}
	...	 \ factorRsSequence=${factorRsSequence} offsetRsSequence=${offsetRsSequence} startRbForRs=${startRbForRs} numRsType1SetId=${numRsType1SetId}



    ${RS1}=    set variable if    ${rsPattern2Period}==${-1}     ${RS1_1}    ${RS1_2}

    Execute Egate Command     cmd=${RS1}
    sleep  5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile_id} action=activate

Generate RS1andRS2
    [Arguments]    ${profile_id}	${config_mode}	${victim_cell}    ${aggressor_cell}     ${rsSetId}    ${numRsSetId}    ${rimRsType}
    ...      ${rsNearFarConfig}    ${propagation_delay}    ${rsType1NScId}    ${rsType2NScId}    ${numRbForRs}    ${rsPattern1Period}
    ...      ${repetitionRsType1}   ${repetitionRsType2}    ${rim_framework}    ${factorRsSequence}    ${factorRsSequenceRS2}
    ...      ${offsetRsSequence}    ${offsetRsSequenceRS2}    ${numRsType1SetId}   ${numRsType2SetId}    ${rimRsTxPower}    ${rimRsTxPowerRS2}
    ...     ${globalF0ForRs}     ${startFreqOffsetForRs}    ${rsPattern2Period}=${-1}
    Builtin.Log     ${offsetRsSequenceRS2}
    Builtin.Log     ${rimRsTxPowerRS2}
    ${RS2_1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=${profile_id} config_mode=${config_mode} victim_cell=${victim_cell}
    ...     \ aggressor_cell=${aggressor_cell} rsSetId=${rsSetId} rimRsTxPower=${rimRsTxPower} rimRsTxPowerRS2=-330 numRsSetId=${numRsSetId}
    ...     \ rimRsType=${rimRsType} rsNearFarConfig=${rsNearFarConfig} propagation_delay=${propagation_delay} rsType1NScId=${rsType1NScId}
    ...     \ rsType2NScId=${rsType2NScId} numRbForRs=${numRbForRs} rsPattern1Period=${rsPattern1Period}
    ...     \ repetitionRsType1=${repetitionRsType1} repetitionRsType2=${repetitionRsType2} rim_framework=${rim_framework}
    ...     \ factorRsSequence=${factorRsSequence} factorRsSequenceRS2=${factorRsSequenceRS2} offsetRsSequence=${offsetRsSequence}
    ...     \ offsetRsSequenceRS2=${offsetRsSequence} numRsType1SetId=${numRsType1SetId} numRsType2SetId=${numRsType2SetId}
    ...     \ globalF0ForRs=${globalF0ForRs} startFreqOffsetForRs=${startFreqOffsetForRs}

    ${RS2_2}=    Catenate    SEPARATOR=
    ...    rimrs_testmode_nr profile_id=${profile_id} config_mode=${config_mode} victim_cell=${victim_cell}
    ...    \ aggressor_cell=${aggressor_cell} rsSetId=${rsSetId} rimRsTxPower=${rimRsTxPower} rimRsTxPowerRS2=-330 numRsSetId=${numRsSetId}
    ...    \  rimRsType=${rimRsType} rsNearFarConfig=${rsNearFarConfig} propagation_delay=${propagation_delay} rsType1NScId=${rsType1NScId}
    ...    \ rsType2NScId=${rsType2NScId} numRbForRs=${numRbForRs} rsPattern1Period=${rsPattern1Period} rsPattern2Period=${rsPattern2Period}
    ...    \  repetitionRsType1=${repetitionRsType1} repetitionRsType2=${repetitionRsType2} rim_framework=${rim_framework}
    ...    \  factorRsSequence=${factorRsSequence} factorRsSequenceRS2=${factorRsSequenceRS2} offsetRsSequence=${offsetRsSequence}
    ...    \ offsetRsSequenceRS2=${offsetRsSequence} numRsType1SetId=${numRsType1SetId} numRsType2SetId=${numRsType2SetId}
    ...    \ globalF0ForRs=${globalF0ForRs} startFreqOffsetForRs=${startFreqOffsetForRs}

    ${RS2}=    set variable if    ${rsPattern2Period}==${-1}     ${RS2_1}    ${RS2_2}

    Execute Egate Command     cmd=${RS2}
    sleep  5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile_id} action=activate

Deactivate RS1
    [Arguments]    ${profile}
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

Deactivate RS1andRS2
    [Arguments]    ${profile}
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

Introduce csi_override_cqi
    [Documentation]    This keyword introduces csi_override testmode command
#    [Arguments]    ${cqi}
    Execute Egate Command       cmd=csi_override_testmode_nr profile_id=2 cqi=6 cqi_mode=fixed
    Execute Egate Command       cmd=csi_override_testmode_nr profile_id=2
    sleep    5s

Activate csi_override_for_UE
    [Documentation]    This keyword activate csi_override testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Execute Egate Command       cmd=ue_testmode_set_nr id=${ue_idx} testmode=csi_override profile_id=2 action=activate
    END

Introduce advanced_bler_testmode
    [Arguments]    ${prof}
    Execute Egate Command
    ...    cmd=adv_bler_testmode_nr profile_id=${prof} target_bler_profile_id=1 target_bler=100,100,100,98,95 target_mcs=18 mcs_table=qam256
    sleep    5s

Activate advanced_bler_testmode
    [Documentation]    This keyword activate bler testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}       ${prof}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Execute Egate Command     cmd=ue_testmode_set_nr id=${ue_idx} testmode=adv_bler profile_id=${prof} action=activate
    END
Start TTI_TRACE custom
    [Arguments]    ${cell_id}=${50}
    Common Start Ttitrace With Streaming Mode_3 custom       pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ${nr_phy_cell_ids}=     Create List    ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate  map(int, ${nr_phy_cell_ids})
#    ${localIpAddr}=    Get localIpAddr Of GNB
#10.0.1.2 for ute
    ${localIpAddr}=    set variable    10.0.1.2
#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
