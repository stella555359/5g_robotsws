*** Settings ***
Documentation        common keywords for 1348
...                  Author:     Annie Wong         annie.wong@nokia.com
...                              Florence Thepot    florence.thepot@nokia.com
...                              Pape Diallo        pape.diallo@nokia.com
...                 Last update : 27.05.21  change ue ip retrieval for airmosaic ue
...                                         use new keywords from Keywords_UE.robot
...                               31/05.21  add J003 J004 and J005 code
...                               11/06/21  update tti containerization

Library          OperatingSystem
Library          Collections
Library          String

Library           taf.config.scf             WITH NAME    scf
Library           ../python/gnb_logs_capture_csv.py
Library           ../../../resources/scf_parameters.py
Library           ../../../resources/pm_analyze.py        WITH NAME      pm_analyze
Library           ../../../resources/Tti_Trace.py

Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot


*** Keywords ***
Check gNB and Get reportingIntervalPm Value
    [Arguments]           ${gNB}=0
    Keywords_gNB.Check gNB State      gNB=${gNB}    cell_id=301
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[${gNB}]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}


Get reportingIntervalPm Value
    [Arguments]           ${gNB}=0
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[${gNB}]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}


Do json delta commissioning coam
    [Documentation]      delta commissioning coam
    ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
    [Arguments]     ${param_list}    ${gNB}=${0}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB}      alias=gnb
    Log      \ndelta commissioning started        console=${DEBUG_MODE_CONSOLE}
    ${update_status}    ${delta_store_file}    Update List of SCF parameters
    ...    parameters=${param_list}    timeout=600    alias=gnb
    Keywords_gNB.Teardown cOAM Session with alias     alias=gnb
    Log      \ndelta commissioning finished       console=${DEBUG_MODE_CONSOLE}
    #the keyword is only defined for gNB0 ! (either comment the code?)
    run keyword if    '${gnb}'=='0'     keywordbook-480.synchronize gnb radio
    wait gNB to be onair state and cells enabled     gnb_id=${gNB}


wait gNB to be onair state and cells enabled
    [Documentation]     on classical gnb check and wait, that all created cells are enabled
    [Arguments]         ${gnb_id}=${0}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gnb_id}      alias=gnb
    ${scf_content}     admin.get_current_scf_content    connection=gnb       timeout=${30}
    ${list_cells}      string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}    collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait until keyword succeeds     1200 sec      20 sec
    ...     keywordbook-480.Compare number of enabled cells with number of cells with coam     ${num_of_cells}
    [Teardown]   Keywords_gNB.Teardown cOAM Session with alias     alias=gnb


5GCounters_b with call and UL traffic and L1L2 traces and Collect Pm in TestSuiteDir
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - Start traffic UL
    ...                 - Wait at least 1 full meas period
    ...                 - detach UE
    ...                 - collect PM files at end of current meas period
    ...   Please take note that test suite variable ${PM_FILENAME} and ${PM_PATH} are set

    [Arguments]    ${tput_ul}=400M    ${duration}=3000    ${gNB}=0    ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    ${ue_model}=    Keywords_UE.Setup UE    ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    ${passed}    Run Keyword and return status    Keywords_UE.Attach UE known Type    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run Keyword If    ${passed}    Keywords_UE.Attach UE known Type    ue_type_model=${ue_model}  ue_index=${ue_index}

    Sleep   10s

    ${ip_ue}=    run keyword if    '${ue_model}'=='QCT'    ue_addr.Get UE IP address    ${ULserver_ip}    ${ULserver_login}    ${ULserver_pwd}

    Start Process TrafficUL UE known Type
    ...    distantip=${ip_ue}
    ...    duration=${duration}
    ...    tput=${tput_ul}
    ...    ue_type_model=${ue_model}
    ...    ueid=${ue_index}

    Sleep   2s

    ${current_time}=    OperatingSystem.run    date
    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    log    TimeStamp=${timeStamp}    console=${DEBUG_MODE_CONSOLE}

    ${timeStamp}=    Convert Date    ${timeStamp}    datetime
    ${meas_period_in_min}    remove string    ${MeasPeriod}    min
    ${minutes}=    Evaluate    int(${timeStamp.minute}/${meas_period_in_min})
    ${remaining_min}=    Evaluate    (${minutes}+1)*${meas_period_in_min} - ${timeStamp.minute}
    ${l1l2_trace_duration}=    Evaluate    (${remaining_min}+${meas_period_in_min})*60 + 30

    Log    L1L2 Trace Duration (seconds)= ${l1l2_trace_duration}    console=${DEBUG_MODE_CONSOLE}
    # After the cell is up, start L1L2 traces during l1l2_trace_duration seconds
    gnb_logs_capture_csv.start_trace   ${GNB_AIRSCALE_IP[${gNB}]}   ${l1l2_trace_duration}

    Sleep    5s

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/gnb${gNB}_pmcounters
    ${res_file}=    Collect PM Files And Get Last Period Filename
    ...    oam_type=coam
    ...    name=gnb${gNB}_pmcounters
    ...    scope=testsuite
    ...    gnb_id=${gNB}

    Log    last period pm file gNB${gNB}=${res_file}   console=${DEBUG_MODE_CONSOLE}
    Log    PM Meas Period in Minutes=${meas_period_in_min}

    Set Suite Variable    ${PM_PATH}    ${res_path}
    Set Suite Variable    ${PM_FILENAME}    ${res_file}
    @{last_pm_file_endTime}   Split String    ${res_file}  .
    ${pm_file_endTime}    catenate    ${last_pm_file_endTime}[2].${last_pm_file_endTime}[3]

    Sleep    5s
    ${pcap_res_files}=    gnb_logs_capture_csv.pcap_collect
    Sleep    5s

    Keywords_UE.Stop TrafficUL UE known Type    ue_type_model=${ue_model}    ueid=${ue_index}

    Keywords_UE.Release UE known Type    ue_type_model=${ue_model}    ue_index=${ue_index}

    Sleep    5s

    #loop on each L1L2 pcap file
    ${varTmp}=    Set Variable    0

    ${hasUlDftSOfdm}    hasUlDftSOfdm    NRCELL=${nrcellid_1}
    ${frameStructureType}    getFrameStructureType        NRCELL=${nrcellid_1}
    @{slots}    gnb_logs_capture_csv.get_fs_slots    ${frameStructureType}

    @{numMcs_64QAM}    Create List    0    0
    @{numMcs_256QAM}    Create List    0    0
    @{sumMcs_64QAM}    Create List    0    0
    @{sumMcs_256QAM}    Create List    0    0
    FOR    ${pcap_file}   IN   @{pcap_res_files}
        Log    Begin convert pcap file:${pcap_file}    console=${DEBUG_MODE_CONSOLE}
        ${output_CSV_file}    catenate    ${pcap_file}_uplink.csv

        ${cmd1}    Set Variable    tshark -r ${pcap_file} -E header=y -E separator=';'
        ${cmd2}=    catenate
        ...    -t ud -T fields
        ...    -e _ws.col.cls_time -e 3gpp.sfn -e 3gpp.slot -e 3gpp.rnti
        ...    -e UlData_UePuschReceiveRespPs_t.sinr_item -e UlData_UePuschReceiveRespPs_t.dtx  -e UlData_UePuschReceiveRespPs_t.crc
        ...    -e UlData_puschReceiveReqGrant_t.numOfPrb -e UlData_puschReceiveReqGrant_t.mcs -e UlData_puschReceiveReqGrant_t.mcsTable
        ...    -e UlData_puschReceiveReqGrant_t.rvIndex -e UlData_srsReceiveRespPsUes_t.ulRank -e UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr
        ...    -e _ws.col.info
        ${cmd}    catenate    ${cmd1}    ${cmd2}    >${output_CSV_file}
        OperatingSystem.Run    ${cmd}

        ${varTmp}=    gnb_logs_capture_csv.countNumPuschPrb  ${output_CSV_file}    ${pm_file_endTime}    ${meas_period_in_min}
        ${M55308C10002}    Evaluate    ${M55308C10002} + ${varTmp}

        ${varTmp}=    gnb_logs_capture_csv.count_UlDataSlot  ${output_CSV_file}  ${pm_file_endTime}    ${meas_period_in_min}
        ${M55308C00006}    Evaluate    ${M55308C00006} + ${varTmp}

        ${varTmp}=    gnb_logs_capture_csv.count_sinr_rank2  ${output_CSV_file}  ${pm_file_endTime}    ${meas_period_in_min}
        ${M55303C06001}    Evaluate    ${M55303C06001} + ${varTmp}[0]
        ${M55303C06002}    Evaluate    ${M55303C06002} + ${varTmp}[1]

        ${varTmp}=    gnb_logs_capture_csv.count_sinr_rank1  ${output_CSV_file}  ${pm_file_endTime}    ${meas_period_in_min}
	#todo varTmp size instead of 26
	FOR  ${i}  IN RANGE    1    26
	    ${treedigit}    Evaluate    '${i}'.zfill(3)
	    ${l1l2_name}    Catenate    SEPARATOR=    M55303C05    ${treedigit}
	    ${tmp}    Evaluate    ${${l1l2_name}} + ${varTmp}[${i}]
	    Set Suite Variable    ${${l1l2_name}}    ${tmp}
	END

        #first slots
        log    first slot=${slots}[0]    console=${DEBUG_MODE_CONSOLE}
        ${varTmp}=   gnb_logs_capture_csv.count_pusch_trns_by_ul_slots  ${output_CSV_file}  ${pm_file_endTime}  ${meas_period_in_min}   ${slots}[0]
        ${M55308C00123}    Evaluate    ${M55308C00123} + ${varTmp}
        log    l1l2_M55308C00123=${M55308C00123}    console=${DEBUG_MODE_CONSOLE}

        #sencond slots
        ${varTmp}=   gnb_logs_capture_csv.count_pusch_trns_by_ul_slots  ${output_CSV_file}  ${pm_file_endTime}  ${meas_period_in_min}   ${slots}[1]
        ${M55308C00124}    Evaluate    ${M55308C00124} + ${varTmp}
        log    M55308C00124=${M55308C00124}    console=${DEBUG_MODE_CONSOLE}

        ${varTmp}=  gnb_logs_capture_csv.count_pusch_trns_f_by_ul_slots  ${output_CSV_file}  ${pm_file_endTime}  ${meas_period_in_min}   ${slots}[0]
        ${M55308C00125}    Evaluate    ${M55308C00125} + ${varTmp}
        log    M55308C00125=${M55308C00125}    console=${DEBUG_MODE_CONSOLE}

        ${varTmp}=   gnb_logs_capture_csv.count_pusch_trns_f_by_ul_slots  ${output_CSV_file}  ${pm_file_endTime}  ${meas_period_in_min}  ${slots}[1]
        ${M55308C00126}    Evaluate    ${M55308C00126} + ${varTmp}
        log    M55308C00126=${M55308C00126}    console=${DEBUG_MODE_CONSOLE}

        #${M55308C00127}=   gnb_logs_capture_csv.count_pusch_vonr_trns_by_ul_slots  ${output_CSV_file}  ${pm_file_endTime}
	#...   ${meas_period_in_min}   ${slots}[0]
        #${M55308C00128}=   gnb_logs_capture_csv.count_pusch_vonr_trns_by_ul_slots  ${output_CSV_file}  ${pm_file_endTime}
	#...   ${meas_period_in_min}   ${slots}[1]

        @{avgMcsSlot0_64QAM}=    gnb_logs_capture_csv.get_avg_mcs_pusch_by_ul_slots    ${output_CSV_file}    ${pm_file_endTime}
	...    ${meas_period_in_min}    ${slots}[0]    0
        @{avgMcsSlot1_64QAM}=    gnb_logs_capture_csv.get_avg_mcs_pusch_by_ul_slots    ${output_CSV_file}    ${pm_file_endTime}
	...    ${meas_period_in_min}    ${slots}[1]    0
        @{avgMcsSlot0_256QAM}=    gnb_logs_capture_csv.get_avg_mcs_pusch_by_ul_slots    ${output_CSV_file}    ${pm_file_endTime}
	...    ${meas_period_in_min}    ${slots}[0]    1
        @{avgMcsSlot1_256QAM}=    gnb_logs_capture_csv.get_avg_mcs_pusch_by_ul_slots    ${output_CSV_file}    ${pm_file_endTime}
	...    ${meas_period_in_min}    ${slots}[1]    1

        #64QAM slot 0
        ${varTmp}    Evaluate    ${sumMcs_64QAM[0]} + ${avgMcsSlot0_64QAM[0]}
        Set List Value    ${sumMcs_64QAM}    0    ${varTmp}
        ${varTmp}    Evaluate    ${numMcs_64QAM[0]} + ${avgMcsSlot0_64QAM[1]}
        Set List Value    ${numMcs_64QAM}    0    ${varTmp}

        #64QAM slot 1
        ${varTmp}    Evaluate    ${sumMcs_64QAM[1]} + ${avgMcsSlot1_64QAM[0]}
        Set List Value    ${sumMcs_64QAM}    1    ${varTmp}
        ${varTmp}    Evaluate    ${numMcs_64QAM[1]} + ${avgMcsSlot1_64QAM[1]}
        Set List Value    ${numMcs_64QAM}    1    ${varTmp}

        #256QAM slot 0
        ${varTmp}    Evaluate    ${sumMcs_256QAM[0]} + ${avgMcsSlot0_256QAM[0]}
        Set List Value    ${sumMcs_256QAM}    0    ${varTmp}
        ${varTmp}    Evaluate    ${numMcs_256QAM[0]} + ${avgMcsSlot0_256QAM[1]}
        Set List Value    ${numMcs_256QAM}    0    ${varTmp}

        #256QAM slot 1
        ${varTmp}    Evaluate    ${sumMcs_256QAM[1]} + ${avgMcsSlot1_256QAM[0]}
        Set List Value    ${sumMcs_256QAM}    1    ${varTmp}
        ${varTmp}    Evaluate    ${numMcs_256QAM[1]} + ${avgMcsSlot1_256QAM[1]}
        Set List Value    ${numMcs_256QAM}    1    ${varTmp}

        #${all_slots}    Combine Lists    ${slots}[0]    ${slots}[1]
        #${M55308CRD54015}  gnb_logs_capture_csv.get_sinr_ul_by_slots_from_raw  ${raw_path}  ${pm_file_endTime}  ${meas_period_in_min}  ${all_slots}
        #${M55308CRD54016}  gnb_logs_capture_csv.get_sinr_ul_by_slots_from_raw  ${raw_path}  ${pm_file_endTime}  ${meas_period_in_min}  ${slots}[0]
        #${M55308CRD54017}  gnb_logs_capture_csv.get_sinr_ul_by_slots_from_raw  ${raw_path}  ${pm_file_endTime}  ${meas_period_in_min}  ${slots}[1]
    END

    IF    ${hasUlDftSOfdm} == ${True}
          ${M55308C00133}    Set Variable    0
          ${M55308C00134}    Set Variable    0
    ELSE
          ${M55308C00133}=   Evaluate    ${sumMcs_64QAM[0]} / ${numMcs_64QAM}[0] if ${numMcs_64QAM}[0] > 0 else 0
          ${M55308C00134}=   Evaluate    ${sumMcs_64QAM[1]} / ${numMcs_64QAM}[1] if ${numMcs_64QAM}[1] > 0 else 0
    END

    ${M55308C00135}=    Evaluate    ${sumMcs_256QAM}[0] / ${numMcs_256QAM}[0] if ${numMcs_256QAM}[0] > 0 else 0
    ${M55308C00136}=    Evaluate    ${sumMcs_256QAM}[1] / ${numMcs_256QAM}[1] if ${numMcs_256QAM}[1] > 0 else 0

    ${M55308C00137}=    Set Variable If    ${hasUlDftSOfdm} == ${False}    0    ${M55308C00133}
    ${M55308C00138}=    Set Variable If    ${hasUlDftSOfdm} == ${False}    0    ${M55308C00134}

   # ${M55308C00133}=    Set Variable If    ${hasUlDftSOfdm} == ${True}    0
   # ${M55308C00134}=    Set Variable If    ${hasUlDftSOfdm} == ${True}    0

    &{l1l2_M55301xx}     Create Dictionary
    Set Suite Variable    &{l1l2_M55301xx}

    ${prefix}=    set variable    M55303C05
    FOR  ${i}  IN RANGE    1    26
        ${i}=    Evaluate    '${i}'.zfill(3)
        ${l1l2_name}=    Catenate    SEPARATOR=  ${prefix}  ${i}
	Set To Dictionary    ${l1l2_M55301xx}    ${l1l2_name}     ${${l1l2_name}}
    END

    ${prefix}=    set variable    M55308C00
    FOR  ${i}  IN RANGE    123    139
        ${i}=    Evaluate    '${i}'.zfill(3)
        ${l1l2_name}=    Catenate    SEPARATOR=  ${prefix}  ${i}
	Set To Dictionary    ${l1l2_M55301xx}    ${l1l2_name}     ${${l1l2_name}}
    END

    # counter without screening
    @{l1l2_list}=    Create List    M55308C10002    M55303C06001    M55308C00006
    FOR    ${l1l2_name}    IN    @{l1l2_list}
	Set To Dictionary    ${l1l2_M55301xx}    ${l1l2_name}     ${${l1l2_name}}
    END


5GCounters_c with call and DL traffic and L1L2 traces and Collect Pm in TestSuiteDir
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - Start traffic DL
    ...                 - Wait at least 1 full meas period
    ...                 - detach UE
    ...                 - collect PM files at end of current meas period
    ...   Please take note that test suite variable ${PM_FILENAME} and ${PM_PATH} are set

    [Arguments]         ${tput_dl}=600M     ${duration}=3000
    ...                 ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    #Setup UE            ue_index=${ue_index}    ue_capabilities=${ue_capabilities}
    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    #Run keyword unless     ${passed}     Keywords_UE.Attach UE known Type
    Run keyword if     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    Sleep   10s

    ${ip_ue}=     run keyword if   '${ue_model}'=='QCT'       ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log        UE ip = ${ip_ue}      console=${DEBUG_MODE_CONSOLE}

    Start Process TrafficDL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_dl}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}

    Sleep   2s

    # Compute Trace duration for L1L2 capture, check current date time and next PM Collection period
    ${current_time}=   OperatingSystem.run   date
    ${timeStamp}=   DateTime.Get current date   exclude_millis=True   result_format=%Y:%m:%d %H:%M:%S
    log   TimeStamp=${timeStamp}   console=${DEBUG_MODE_CONSOLE}
    ${timeStamp}=     Convert Date     ${timeStamp}    datetime
    ${meas_period_in_min}    remove string   ${MeasPeriod}   min
    ${minutes}=   Evaluate   int(${timeStamp.minute}/${meas_period_in_min})
    ${remaining_min}=   Evaluate   (${minutes}+1)*${meas_period_in_min} - ${timeStamp.minute}
    ${l1l2_trace_duration}=   Evaluate   (${remaining_min}+${meas_period_in_min})*60 + 30
    Log    L1L2 Trace Duration (seconds)= ${l1l2_trace_duration}   console=${DEBUG_MODE_CONSOLE}


    # After the cell is up, start L1L2 traces during l1l2_trace_duration seconds
    Log    Start L1L2 capture           console=${DEBUG_MODE_CONSOLE}
    gnb_logs_capture_csv.start_trace  ${GNB_AIRSCALE_IP[${gNB}]}   ${l1l2_trace_duration}
    Log    Wait 5s           console=${DEBUG_MODE_CONSOLE}
    Sleep                   5s
    Log    Stop and collect L1L2 traces           console=${DEBUG_MODE_CONSOLE}
    ${pcap_res_files}=   gnb_logs_capture_csv.pcap_collect
    Sleep   5s

    Keywords_UE.Stop TrafficDL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    #Release UE          ue_index=${ue_index}
    Keywords_UE.Release UE known Type     ue_type_model=${ue_model}     ue_index=${ue_index}

    Sleep   5s

    ${res_path}=   set variable     ${OUTPUTDIR}/${SUITENAME}/gnb${gNB}_pmcounters
    ${res_file}=    Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb${gNB}_pmcounters
    ...          scope=testsuite
    ...          gnb_id=${gNB}
    Log       last period pm file gNB${gNB}=${res_file}   console=${DEBUG_MODE_CONSOLE}
    Log       PM Meas Period in Minutes=${meas_period_in_min}
    Set Suite Variable      ${PM_PATH}         ${res_path}
    Set Suite Variable      ${PM_FILENAME}     ${res_file}
    @{last_pm_file_endTime}   Split String    ${res_file}  .
    ${pm_file_endTime}   catenate    ${last_pm_file_endTime}[2].${last_pm_file_endTime}[3]

    #loop on each L1L2 pcap file
    ${varTmp}=    Set Variable   0

    FOR    ${pcap_file}   IN   @{pcap_res_files}
        Log    Begin convert pcap file:${pcap_file}
        ${output_CSV_file}   catenate   ${pcap_file}_M55301C010xx.csv
        #${output_file_M55308C10001}   catenate   ${pcap_file}_M55308C10001.csv
        #${output_file_M55308C00005}   catenate   ${pcap_file}_M55308C00005.csv
        #${output_file_M55308C00015}   catenate   ${pcap_file}_M55308C00015.csv

        ${cmd1}    Set Variable    tshark -r ${pcap_file} -E header=y -E separator=';'
        ${cmd2}=    catenate
        ...    -t ud -T fields
        ...    -e _ws.col.cls_time -e 3gpp.sfn -e 3gpp.slot -e 3gpp.rnti
        ...    -e DlData_PdschGrant.numOfPrb -e DlData_PdschGrant.numOfLayers -e DlData_PdschGrant.mcs
        ...    -e _ws.col.info

        ${cmd}   catenate   ${cmd1}   ${cmd2}   >${output_CSV_file}
        OperatingSystem.Run   ${cmd}
        ${varTmp}=   gnb_logs_capture_csv.count_pdsch_rank2_tx  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
	FOR  ${i}  IN RANGE  32
	    ${treedigit}    Evaluate    '${i}'.zfill(3)
	    ${l1l2_name}    Catenate    SEPARATOR=   M55301C01  ${treedigit}
	    ${tmp}    Evaluate    ${${l1l2_name}} + ${varTmp}[${i}]
	    Set Suite Variable    ${${l1l2_name}}    ${tmp}
	END

        ${varTmp}=   gnb_logs_capture_csv.count_pdsch_rank3_tx  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
	FOR  ${i}  IN RANGE  32
	    ${treedigit}    Evaluate    '${i}'.zfill(3)
	    ${l1l2_name}    Catenate    SEPARATOR=   M55301C17  ${treedigit}
	    ${tmp}    Evaluate    ${${l1l2_name}} + ${varTmp}[${i}]
	    Set Suite Variable    ${${l1l2_name}}    ${tmp}
	END

        ${varTmp}=   gnb_logs_capture_csv.countNumPdschPrb  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
        ${M55308C10001}   Evaluate    ${M55308C10001} + ${varTmp}

        ${varTmp}=   gnb_logs_capture_csv.count_DlDataSlot  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
        ${M55308C00005}   Evaluate    ${M55308C00005} + ${varTmp}

        ${varTmp}=   gnb_logs_capture_csv.count_SsbSlotWithPDSCH  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
        ${M55308C00015}   Evaluate    ${M55308C00015} + ${varTmp}
        ${M55308C00016}   Evaluate    500*${M55308C00015}
    END

    &{l1l2_M55301xx}     Create Dictionary
    Set Suite Variable   &{l1l2_M55301xx}

    #Add Range To Dict    &{l1l2_M55301xx}    M55301C01    0    32
    ${prefix}=    set variable    M55301C01
    FOR  ${i}  IN RANGE  0   32
        ${i}=  Evaluate    '${i}'.zfill(3)
        ${l1l2_name} =  Catenate    SEPARATOR=  ${prefix}  ${i}
	Set To Dictionary    ${l1l2_M55301xx}    ${l1l2_name}     ${${l1l2_name}}
    END

    ${prefix}=    set variable    M55301C17
    FOR  ${i}  IN RANGE  0   32
        ${i}=  Evaluate    '${i}'.zfill(3)
        ${l1l2_name} =  Catenate    SEPARATOR=  ${prefix}  ${i}
	Set To Dictionary    ${l1l2_M55301xx}    ${l1l2_name}     ${${l1l2_name}}
    END

    @{l1l2_list}=     Create List    M55308C10001    M55308C00005    M55308C00015    M55308C00016
    FOR  ${l1l2_name}  IN   @{l1l2_list}
	Set To Dictionary    ${l1l2_M55301xx}    ${l1l2_name}     ${${l1l2_name}}
    END


getFrameStructureType
    [Arguments]    ${gNB}=0    ${NRCELL}=1

    ${dist_name}    Set Variable     MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${NRCELL}

    ${frameStructureType}    getParamFromSCF    dist_name=${dist_name}    p_name=frameStructureType    list_name=tddFrameStructure
    Return From Keyword If    '${frameStructureType}' == 'semiStatic'    5GC001070

    ${lteToNrFrameShift}    getParamFromSCF    dist_name=${dist_name}    p_name=lteToNrFrameShift    list_name=tddFrameStructure
    Return From Keyword If    '${lteToNrFrameShift}' == '0ms'    5GC001116_0ms

    [Return]    5GC001116_3ms


hasUlDftSOfdm
    [Arguments]    ${gNB}=0    ${NRCELL}=1
    ${val}    getParamFromSCF    dist_name=MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${NRCELL}    p_name=actUlDftSOfdm
    Return From Keyword    Convert To Title Case   ${val}


getParamFromSCF
    [Arguments]    ${dist_name}=${EMPTY}    ${p_name}=${EMPTY}    ${list_name}=${EMPTY}
    Log    getting ${p_name} from ${dist_name}

    scf.load_scf     ${ORIG_SCF[0]}
    ${param}    scf.get_value_from_scf   dist_name=${dist_name}    p_name=${p_name}    list_name=${list_name}
    [return]    ${param}


get btsNameScf from SCF
    [Arguments]           ${gNB}=0
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${ORIG_SCF[0]}
    ${dist_name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}
    scf.load_scf     ${current_scf_fullname}
    # MRBTS-1
    ${btsNameScf}     scf.get_value_from_scf   p_name=btsName
    ...              dist_name=${dist_name}
    set suite variable             ${btsNameScf}

get prachConfigurationIndex from SCF
    [Arguments]           ${gNB}=0        ${NRCELL}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${ORIG_SCF[0]}
    ${dist_name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${NRCELL}
    scf.load_scf     ${current_scf_fullname}
    # MRBTS-1
    ${pRachConfigId}     scf.get_value_from_scf   p_name=prachConfigurationIndex
    ...              dist_name=${dist_name}
    set suite variable             ${pRachConfigId}

get dlModulation from SCF
    [Arguments]           ${gNB}=0        ${NRCELL}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${ORIG_SCF[0]}
    ${dist_name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${NRCELL}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1
    ${isDl256QAM}	 scf.get_value_from_scf   p_name=actDl256Qam
    ...              dist_name=${dist_name}
    set suite variable 			${isDl256QAM}
