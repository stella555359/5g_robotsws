*** Settings ***
Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_TDD
    ...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation
    ...             This test case is to verify Frame Structure and TPut with enabled 5GC002516;
    ...             Source Frame Structure: Semi 14, 10-2-2;
    ...             Interfering  Frame Structure: tdLte 3ms, 6-4-4.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Resource         ../CB012719/CB012719_Resource.robot
Resource         ../../../resources/robot/PM_Counters.robot
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout
Library    ute_admin_infomodel
Resource     ./CB013100_resouce.robot
Resource          5GC002516_Expected_slot_type.robot
Resource          common_ue_command.robot

Suite Teardown   Run Keyword and Ignore Error    Get Sos Report


*** Variables ***
${TLConfig.isUTE}   True
${wts_cfg_file_01}       ${CURDIR}/config/wts/basic_setup_5GC002516_TDD_NSA_TC6.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${r&d_parameter}       0x58000E=0x00020;0x580017=2;0x10041=5
${kpi_txt}            ${CURDIR}/python/req_kpi.txt
&{ue_to_qos_map}    ${1}=2,3    ${2}=20,21,22    ${3}=2,3,4    ${4}=22,5
${DELTA_SCFC_PATH}      ${CURDIR}/config/SBTS26R1/energysaving_cellswitchoff.json
${Pdu_session_ID}       1
${nwslice_ID}           1
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${RUNTIME_NRCELL_1_IM_PATH}    //NRCELL_R-1
${RUNTIME_NRCELL_2_IM_PATH}    //NRCELL_R-2
${__LOCAL_BTS_IP__}    192.168.255.129
${expected_dl_TC6}         59.5
${expected_ul_TC6}         17.8
@{slot_type_TC6}           @{slottype_list_5GC002516_TC6}
${UE_ID}               101
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${COUNT}               0

*** Test Cases ***
[1][2.0]TC6_5GC002516_A-d_VerifyMutingSlot_Scenario34
    [tags]      TC2516
    [Setup]         Run keywords    run keyword and ignore error     Suite setup from scratch
    ...                 AND    sleep     1s
    ...                 AND    Perform SCF Delta Commissioning with Dl_Muting.json
    ...                 AND    sleep     30s
    ...                 AND    Perform SCF Delta Commissioning with TC6_Delta_Conf_5GC002516-TDD_NSA_2.json
    ...                 AND    sleep     30s
    ...                 AND    Update GNB R&D Parameter    ${LOG_PATH}   ${r&d_parameter}
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
    ...                 AND    Configure eth3 IP
    ...                 AND    Start wts application and load CFG    ${wts_cfg_file_01}

    Log To console  ConfigLoaded

    Set test variable      ${LOG_PATH}
    NSA X2AP Link Should be UP     1     2

    Start log       btslog
    5GC002516_Coordination_of_TDD_Deployment    ${expected_dl_TC6}    ${expected_ul_TC6}
    Stop log       btslog      test_scenario=5GC002516_Result

    Verify 5GC002516 SYSLOG    ${slot_type_TC6}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Run Keyword and Ignore Error    Clean edaemon and egate
    ...         AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...         AND        Stop Log    snapshot     sosreport
    ...         AND        Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
validat custom dl traffic
    wts_sim_keywords.Validate DL Traffic For MultiUE SA     1     1     35     1    1
    wts_sim_keywords.Validate DL Traffic For MultiUE SA     2     2     35     1    2
    wts_sim_keywords.Validate DL Traffic For MultiUE SA     3     3     35     1    1
    wts_sim_keywords.Validate DL Traffic For MultiUE SA     3     3     35     1    4
    wts_sim_keywords.Validate DL Traffic For MultiUE SA     4     4     35     1    2
    wts_sim_keywords.Validate DL Traffic For MultiUE SA     4     4     35     1    3

Collect meaurement and check
    [Arguments]     ${pre}     ${after_pre}
    Wait until the next Measurement Period starts
    sleep     120s
    only_measurement_by_file.download_measurements    ${LOG_PATH}/    ${pre}.zip
    sleep    1800s
    only_measurement_by_file.download_measurements    ${LOG_PATH}/    ${after_pre}.zip
    clean_target    ${LOG_PATH}/${pre}/PERFMON_FILES/     ${LOG_PATH}/${after_pre}/PERFMON_FILES/
    ${aft}    only_measurement_by_file.read_file_list    ${LOG_PATH}/${after_pre}/PERFMON_FILES/   ${kpi_txt}    NR_5114b    NRCELL-1

Set current time values in delta file and push delta
    [Arguments]    ${file}
    ${datestring}=    GET CURRENT DATE    time_zone=UTC    result_format=%a %H %M
    @{date}=    SPLIT STRING    ${datestring}
    ${WEEKDAY}    ${HOUR}    ${MINUTE}=    SET VARIABLE    ${date}
    ${HOUR}=    CONVERT TO INTEGER    ${HOUR}
    ${MINUTE}=    CONVERT TO INTEGER    ${MINUTE}
    update_delta_upload    ${DELTA_SCFC_PATH}    ${WEEKDAY}    ${HOUR}    ${MINUTE}    60
    Log to Console      ${file}

Connect Info Model
    ute_admin_infomodel.setup_infomodel    address=${__LOCAL_BTS_IP__}    port=443    admin_api_log_dir=${LOG_PATH}/    alias=default
    ute_admin_infomodel.connect_infomodel    alias=default
Wait for switching off procedure to trigger on first cell

    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [energySavingState=switchingOff]    timeout=350
    ute_admin_infomodel.query_infomodel    ${RUNTIME_NRCELL_1_IM_PATH} is [operationalState=enabled]    timeout=350


Basic 20 percentage load

    ${rnti_list}    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1     ${1}     ${4}
    MultiUE PDU Modfication should be Successful selective    1    ${ue_to_qos_map}

    #UE1 5qi 6,5,1    lcid 4, 5,6
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=35     pdu_id=1
    ...     trf_id=1       qfi_id=1
    Trigger VONR custom data    ${1}    ul    1    1    3    kbps   25.1    custom
    Trigger VONR custom data    ${1}    dl    1    1    3    kbps   25.1    custom

    #UE2    7 8 9
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=35     pdu_id=1
    ...     trf_id=1       qfi_id=2

    #UE3 6,5,1,2
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=35     pdu_id=1
    ...     trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=60      pdu_id=1
    ...     trf_id=1       qfi_id=1

    Trigger VONR custom data    ${1}    ul    3    3    3    kbps   25.1    custom
    Trigger VONR custom data    ${1}    dl    3    3    3    kbps   25.1    custom
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=35     pdu_id=1
    ...     trf_id=1       qfi_id=4
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=30      pdu_id=1
    ...     trf_id=1       qfi_id=4
    #UE4
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    4    4    Traffic_rate=mbps     dl_rate=35     pdu_id=1
    ...     trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    4    4    Traffic_rate=mbps     ul_rate=10      pdu_id=1
    ...     trf_id=1       qfi_id=2
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    4    4    Traffic_rate=mbps     dl_rate=35     pdu_id=1
    ...     trf_id=1       qfi_id=3
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    4    4    Traffic_rate=mbps     ul_rate=30      pdu_id=1
    ...     trf_id=1       qfi_id=3

    sleep     60s

    Validate DL Traffic For SA custom    1    4    1    1

    Start TTI_TRACE custom_13100    ${51}
    sleep     1s
    ${low_load}     Stop Log     ttitrace         test_scenario=20_percentage
    Decode TTI Trace    20_percentage


Validate DL Traffic For SA custom
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}    ${end_ue}     ${pdu_id}     ${qfi_id}
#    Builtin.Log     ${dl_rate}
    FOR    ${i}    IN RANGE    ${ue_id}    ${end_ue}+${1}
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${i} pdu=${pdu_id} qfi=${qfi_id} dir=dl
    ${bearer_stat_dl}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}
    ...     pass_regexp=Average packet interval
    ...                     timeout=30
    END
    #wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    #Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

MultiUE PDU Modfication should be Successful selective
    [Arguments]     ${pdu_id}      ${ue_to_qos_map}

    ${ue_list}     Get Dictionary Keys    ${ue_to_qos_map}

	FOR     ${ue_idx}   IN      @{ue_list}
	${qosflows_to_add}     Get From Dictionary	${ue_to_qos_map}	${ue_idx}
    Add Qos flows one by one    ${ue_idx}    ${pdu_id}    ${qosflows_to_add}
    END
    BuiltIn.Log       All_ue_added_an_extra_qosflow_successfully
	Log to Console    All_ue_added_an_extra_qosflow_successfully


Add Qos flows one by one
    [Arguments]     ${ue_idx}     ${pdu_id}      ${qosflows_to_add}
    ${qosflows_to_add}    Split String	${qosflows_to_add}    ,
    FOR     ${qosflow}    IN    @{qosflows_to_add}
        ${pdu_modify}	SET VARIABLE	ue_pdu_session_modify ue=${ue_idx} pdu=${pdu_id} qosflows_to_add=${qosflow} by=amf
        ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${pdu_modify}		pass_regexp=${Pdu_session_qos_patten}
        ...     timeout=${Timeout_SA}
        BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows_to_add} added
        Log to Console            ue=${ue_idx} qosflow=${qosflows_to_add} added
    END
MultiUE Trigger DL Traffic for SA on qfi
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl ${Traffic_rate}=${dl_rate}
    ...     trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=Started Downlink Internal traffic*
    ...     timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

UE Register should be Successful sim
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file

    ${ue_reg_cmd}   SET VARIABLE        ue_register id=${ue_id}
    ute_wtssim.Execute Egate Command    ${ue_reg_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

UE Deregister should be Successful sim
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the completion of UE deregistration in the output file
    ${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_id} ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command    ${deregister_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}

Trigger VONR custom data
	[Arguments]    ${ue_id}     ${dir}		${pdu_id}     ${trf_id}		${qfi}		${Traffic_unit}		${traffic_rate}		${rtp_codec}
    [Documentation]    This keyword starts the vonr data
    Builtin.Log     ${Traffic_unit}
    Builtin.Log     ${traffic_rate}
    Log to Console    \nRunning Traffic
	${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} trf_id=${trf_id} rtp_codec=${rtp_codec}
    ute_wtssim.Execute Egate Command And Wait For Data		${data_cmd}		timeout=${EGATE_COMMAND_TIMEOUT}
Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgS4SsiuoeE23c8C -P ${CURDIR}/BSR
    coam.setup admin
     ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
     coam.teardown admin

Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB008246
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin


Verify 5GC002516 SYSLOG
    [Documentation]     This keyword performs the verification of actual frame structure extracted
	...                 from GNB_Syslog VS the expected one defined under slot_type.
    [Arguments]    ${slot_type}		${Full_Path}=${LOG_PATH}/${TEST_NAME}/gNB/btslog/5GC002516_Result
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    tar -xzvf ${Full_Path}/Gnb_syslog.tar.gz --directory ${Full_Path}
    ${grep_command}    Catenate    sed -n -r 's#SlotTypeSelectorBase#SlotTypeSelectorBase#g; t found; d; :found s#.*(Slot:)
    ...    +([0-9]+),.*(SLOT_TYPE_.+), k1:.*#\\1\\2 \\3#g; t processed; d; :processed p;' ${Full_Path}/${output} > ${Full_Path}
    ${rc}    ${line}    OperatingSystem.Run And Return Rc And Output    ${grep_command}
    FOR    ${sub}    IN    @{slot_type}
        Log to console    ${sub}
        ${line.strip()}    Evaluate    ${line.strip()}+1
        ${rc}     ${content}    OperatingSystem.Run And Return Rc And Output
        ...     sed -n '${line.strip()}p' ${Full_Path}/gnb_syslog.log
        ${match_result}    Run Keyword and Ignore Error        Should Match Regexp    ${content}    ${sub}
    END

5GC002516_Coordination_of_TDD_Deployment
    [Documentation]     This keyword performs UE attach, start DL/UL data and verify the expected TPut
    [Arguments]    ${expected_dl}    ${expected_ul}
    common_ue_command.NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    common_ue_command.NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    common_ue_command.NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
    ${dl_tp}=    common_ue_command.NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    dl
    ${ul_tp}=    common_ue_command.NSA Get UE Average Traffic    ${UE_ID}    ${BEARER_ID}    ul
    common_ue_command.NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    ${expected_dl}
    common_ue_command.NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    ${expected_ul}
    common_ue_command.NSA LTE Detach    ${UE_ID}

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is True if you want to set  False then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}

Trigger traffc gradually
    [Arguments]      ${st_ue}      ${en_ue}
    FOR      ${i}     IN RANGE    ${st_ue}     ${en_ue}      #${1}
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${i}       ${i}    Traffic_rate=mbps     dl_rate=100     pdu_id=1
    ...     trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${i}       ${i}    Traffic_rate=mbps     ul_rate=50     pdu_id=1
    ...     trf_id=1       qfi_id=1
    sleep     1s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${i+1}       ${i+1}    Traffic_rate=mbps     dl_rate=15     pdu_id=1
    ...     trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${i+1}       ${i+1}    Traffic_rate=mbps     ul_rate=15     pdu_id=1
    ...     trf_id=1       qfi_id=1
    sleep     1s
    END
