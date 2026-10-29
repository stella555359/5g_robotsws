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


*** Variables ***
${l1l2_M55301C01000}   0
${l1l2_M55301C01001}   0
${l1l2_M55301C01002}   0
${l1l2_M55301C01003}   0
${l1l2_M55301C01004}   0
${l1l2_M55301C01005}   0
${l1l2_M55301C01006}   0
${l1l2_M55301C01007}   0
${l1l2_M55301C01008}   0
${l1l2_M55301C01009}   0
${l1l2_M55301C01010}   0
${l1l2_M55301C01011}   0
${l1l2_M55301C01012}   0
${l1l2_M55301C01013}   0
${l1l2_M55301C01014}   0
${l1l2_M55301C01015}   0
${l1l2_M55301C01016}   0
${l1l2_M55301C01017}   0
${l1l2_M55301C01018}   0
${l1l2_M55301C01019}   0
${l1l2_M55301C01020}   0
${l1l2_M55301C01021}   0
${l1l2_M55301C01022}   0
${l1l2_M55301C01023}   0
${l1l2_M55301C01024}   0
${l1l2_M55301C01025}   0
${l1l2_M55301C01026}   0
${l1l2_M55301C01027}   0
${l1l2_M55301C01028}   0
${l1l2_M55301C01029}   0
${l1l2_M55301C01030}   0
${l1l2_M55301C01031}   0
${l1l2_M55301C16000}   0
${l1l2_M55301C16001}   0
${l1l2_M55301C16002}   0
${l1l2_M55301C16003}   0
${l1l2_M55301C16004}   0
${l1l2_M55301C16005}   0
${l1l2_M55301C16006}   0
${l1l2_M55301C16007}   0
${l1l2_M55301C16008}   0
${l1l2_M55301C16009}   0
${l1l2_M55301C16010}   0
${l1l2_M55301C16011}   0
${l1l2_M55301C16012}   0
${l1l2_M55301C16013}   0
${l1l2_M55301C16014}   0
${l1l2_M55301C16015}   0
${l1l2_M55301C16016}   0
${l1l2_M55301C16017}   0
${l1l2_M55301C16018}   0
${l1l2_M55301C16019}   0
${l1l2_M55301C16020}   0
${l1l2_M55301C16021}   0
${l1l2_M55301C16022}   0
${l1l2_M55301C16023}   0
${l1l2_M55301C16024}   0
${l1l2_M55301C16025}   0
${l1l2_M55301C16026}   0
${l1l2_M55301C16027}   0
${l1l2_M55301C16028}   0
${l1l2_M55301C16029}   0
${l1l2_M55301C16030}   0
${l1l2_M55301C16031}   0
${l1l2_M55308C10002}   0
${l1l2_M55308C10001}   0
${l1l2_M55308C00005}   0
${l1l2_M55308C00006}   0
${l1l2_M55308C00015}   0
${l1l2_M55308C00016}   0

${l1l2_M55303C06001}   0
${l1l2_M55303C06002}   0

${l1l2_M55303C05001}   0
${l1l2_M55303C05002}   0
${l1l2_M55303C05003}   0
${l1l2_M55303C05004}   0
${l1l2_M55303C05005}   0
${l1l2_M55303C05006}   0
${l1l2_M55303C05007}   0
${l1l2_M55303C05008}   0
${l1l2_M55303C05009}   0
${l1l2_M55303C05010}   0
${l1l2_M55303C05011}   0
${l1l2_M55303C05012}   0
${l1l2_M55303C05013}   0
${l1l2_M55303C05014}   0
${l1l2_M55303C05015}   0
${l1l2_M55303C05016}   0
${l1l2_M55303C05017}   0
${l1l2_M55303C05018}   0
${l1l2_M55303C05019}   0
${l1l2_M55303C05020}   0
${l1l2_M55303C05021}   0
${l1l2_M55303C05022}   0
${l1l2_M55303C05023}   0
${l1l2_M55303C05024}   0
${l1l2_M55303C05025}   0


*** Keywords ***
Check gNB and Get reportingIntervalPm Value
    [Arguments]           ${gNB}=0
    Keywords_gNB.Check gNB State      gNB=${gNB}
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


1348 A14 A20 with call and UL traffic and Collect Pm in TestSuiteDir
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - Start traffic UL
    ...                 - Wait at least 1 full meas period
    ...                 - detach UE
    ...                 - collect PM files at end of current meas period
    ...   Please take note that test suite variable ${PM_FILENAME} and ${PM_PATH} are set

    [Arguments]         ${tput_ul}=200M     ${duration}=3000
    ...                 ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    #Setup UE            ue_index=${ue_index}    ue_capabilities=${ue_capabilities}
    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    #${passed}       Run Keyword and return status        Start UE attach     ue_index=${ue_index}
    #Run keyword unless      ${passed}      Start UE attach     ue_index=${ue_index}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword if     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    sleep   40s
    # sleep   10s

    # add by Namory 01/10/2021
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=-10
    ...        gnb=${gNB}

    ${ip_ue}=     run keyword if   '${ue_model}'=='QCT'       ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log        UE ip = ${ip_ue}      console=${DEBUG_MODE_CONSOLE}

    #Start Process TrafficUL    distantip=${ip_ue}   tput=${tput_ul}   duration=${duration}   ueid=${ue_index}
    Start Process TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_ul}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}

    Sleep   20s

    # modified time 70s / 310s by Namory 01/10/2021
    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=30
    ...        gnb=${gNB}

    Keywords_UE.Stop TrafficUL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}

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
    Set Suite Variable      ${PM_PATH}         ${res_path}
    Set Suite Variable      ${PM_FILENAME}     ${res_file}

5GCounters_b with call and UL traffic and L1L2 traces and Collect Pm in TestSuiteDir
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - Start traffic UL
    ...                 - Wait at least 1 full meas period
    ...                 - detach UE
    ...                 - collect PM files at end of current meas period
    ...   Please take note that test suite variable ${PM_FILENAME} and ${PM_PATH} are set

    [Arguments]         ${tput_ul}=200M     ${duration}=3000
    ...                 ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    #Setup UE            ue_index=${ue_index}    ue_capabilities=${ue_capabilities}
    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword If     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    Sleep   10s

    ${ip_ue}=     run keyword if   '${ue_model}'=='QCT'       ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log        UE ip = ${ip_ue}      console=${DEBUG_MODE_CONSOLE}

    Start Process TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_ul}
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
    gnb_logs_capture_csv.start_trace   ${GNB_AIRSCALE_IP[${gNB}]}   ${l1l2_trace_duration}
    Log    Wait 5s           console=${DEBUG_MODE_CONSOLE}
    Sleep                   5s
    Log    Stop and collect L1L2 traces           console=${DEBUG_MODE_CONSOLE}
    ${pcap_res_files}=   gnb_logs_capture_csv.pcap_collect
    Sleep   5s

    Keywords_UE.Stop TrafficUL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}

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
    ${output_CSV_file}   catenate   ${pcap_file}_uplink.csv

    ${cmd1}    Set Variable    tshark -r ${pcap_file} -E header=y -E separator=';'
    ${cmd2}=    catenate
    ...    -t ud -T fields
    ...    -e _ws.col.Time -e 3gpp.sfn -e 3gpp.slot -e 3gpp.rnti
    ...    -e UlData_UePuschReceiveRespPs_t.sinr_item -e UlData_puschReceiveReqGrant_t.numOfPrb
    ...    -e UlData_srsReceiveRespPsUes_t.ulRank -e UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr
    ...    -e _ws.col.Info
    ${cmd}   catenate   ${cmd1}   ${cmd2}   >${output_CSV_file}
    OperatingSystem.Run   ${cmd}

    ${varTmp}=    gnb_logs_capture_csv.countNumPuschPrb  ${output_CSV_file}   ${pm_file_endTime}   ${meas_period_in_min}
    ${l1l2_M55308C10002}        Evaluate    ${l1l2_M55308C10002} + ${varTmp}

    ${varTmp}=   gnb_logs_capture_csv.count_UlDataSlot  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
    ${l1l2_M55308C00006}   Evaluate    ${l1l2_M55308C00006} + ${varTmp}

    ${varTmp}=   gnb_logs_capture_csv.count_sinr_rank2  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
    ${l1l2_M55303C06001}   Evaluate    ${l1l2_M55303C06001} + ${varTmp}[0]
    ${l1l2_M55303C06002}   Evaluate    ${l1l2_M55303C06002} + ${varTmp}[1]

    ${varTmp}=   gnb_logs_capture_csv.count_sinr_rank1  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
    ${l1l2_M55303C05001}   Evaluate    ${l1l2_M55303C05001} + ${varTmp}[1]
    ${l1l2_M55303C05002}   Evaluate    ${l1l2_M55303C05002} + ${varTmp}[2]
    ${l1l2_M55303C05003}   Evaluate    ${l1l2_M55303C05003} + ${varTmp}[3]
    ${l1l2_M55303C05004}   Evaluate    ${l1l2_M55303C05004} + ${varTmp}[4]
    ${l1l2_M55303C05005}   Evaluate    ${l1l2_M55303C05005} + ${varTmp}[5]
    ${l1l2_M55303C05006}   Evaluate    ${l1l2_M55303C05006} + ${varTmp}[6]
    ${l1l2_M55303C05007}   Evaluate    ${l1l2_M55303C05007} + ${varTmp}[7]
    ${l1l2_M55303C05008}   Evaluate    ${l1l2_M55303C05008} + ${varTmp}[8]
    ${l1l2_M55303C05009}   Evaluate    ${l1l2_M55303C05009} + ${varTmp}[9]
    ${l1l2_M55303C05010}   Evaluate    ${l1l2_M55303C05010} + ${varTmp}[10]
    ${l1l2_M55303C05011}   Evaluate    ${l1l2_M55303C05011} + ${varTmp}[11]
    ${l1l2_M55303C05012}   Evaluate    ${l1l2_M55303C05012} + ${varTmp}[12]
    ${l1l2_M55303C05013}   Evaluate    ${l1l2_M55303C05013} + ${varTmp}[13]
    ${l1l2_M55303C05014}   Evaluate    ${l1l2_M55303C05014} + ${varTmp}[14]
    ${l1l2_M55303C05015}   Evaluate    ${l1l2_M55303C05015} + ${varTmp}[15]
    ${l1l2_M55303C05016}   Evaluate    ${l1l2_M55303C05016} + ${varTmp}[16]
    ${l1l2_M55303C05017}   Evaluate    ${l1l2_M55303C05017} + ${varTmp}[17]
    ${l1l2_M55303C05018}   Evaluate    ${l1l2_M55303C05018} + ${varTmp}[18]
    ${l1l2_M55303C05019}   Evaluate    ${l1l2_M55303C05019} + ${varTmp}[19]
    ${l1l2_M55303C05020}   Evaluate    ${l1l2_M55303C05020} + ${varTmp}[20]
    ${l1l2_M55303C05021}   Evaluate    ${l1l2_M55303C05021} + ${varTmp}[21]
    ${l1l2_M55303C05022}   Evaluate    ${l1l2_M55303C05022} + ${varTmp}[22]
    ${l1l2_M55303C05023}   Evaluate    ${l1l2_M55303C05023} + ${varTmp}[23]
    ${l1l2_M55303C05024}   Evaluate    ${l1l2_M55303C05024} + ${varTmp}[24]
    ${l1l2_M55303C05025}   Evaluate    ${l1l2_M55303C05025} + ${varTmp}[25]
        #log    l1l2_M55303C05001=${l1l2_M55303C05001}   console=${DEBUG_MODE_CONSOLE}
    END

    &{l1l2_M55301xx}     Create Dictionary    M55303C05001     ${l1l2_M55303C05001}
    ...                                       M55303C05002     ${l1l2_M55303C05002}
    ...                                       M55303C05003     ${l1l2_M55303C05003}
    ...                                       M55303C05004     ${l1l2_M55303C05004}
    ...                                       M55303C05005     ${l1l2_M55303C05005}
    ...                                       M55303C05006     ${l1l2_M55303C05006}
    ...                                       M55303C05007     ${l1l2_M55303C05007}
    ...                                       M55303C05008     ${l1l2_M55303C05008}
    ...                                       M55303C05009     ${l1l2_M55303C05009}
    ...                                       M55303C05010     ${l1l2_M55303C05010}
    ...                                       M55303C05011     ${l1l2_M55303C05011}
    ...                                       M55303C05012     ${l1l2_M55303C05012}
    ...                                       M55303C05013     ${l1l2_M55303C05013}
    ...                                       M55303C05014     ${l1l2_M55303C05014}
    ...                                       M55303C05015     ${l1l2_M55303C05015}
    ...                                       M55303C05016     ${l1l2_M55303C05016}
    ...                                       M55303C05017     ${l1l2_M55303C05017}
    ...                                       M55303C05018     ${l1l2_M55303C05018}
    ...                                       M55303C05019     ${l1l2_M55303C05019}
    ...                                       M55303C05020     ${l1l2_M55303C05020}
    ...                                       M55303C05021     ${l1l2_M55303C05021}
    ...                                       M55303C05022     ${l1l2_M55303C05022}
    ...                                       M55303C05023     ${l1l2_M55303C05023}
    ...                                       M55303C05024     ${l1l2_M55303C05024}
    ...                                       M55303C05025     ${l1l2_M55303C05025}
    ...                                       M55308C10002     ${l1l2_M55308C10002}
    ...                                       M55308C00006     ${l1l2_M55308C00006}
    ...                                       M55303C06001     ${l1l2_M55303C06001}
    Set Suite Variable   &{l1l2_M55301xx}


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
    Run keyword If     ${passed} == ${False}     Keywords_UE.Attach UE known Type
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
        ...    -e _ws.col.Time -e 3gpp.sfn -e 3gpp.slot -e 3gpp.rnti
        ...    -e DlData_PdschGrant.numOfPrb -e DlData_PdschGrant.modulationOrder
        ...    -e DlData_PdschGrant.numOfLayers -e DlData_PdschGrant.mcs
        ...    -e _ws.col.Info

        ${cmd}   catenate   ${cmd1}   ${cmd2}   >${output_CSV_file}
        OperatingSystem.Run   ${cmd}
        ${varTmp}=   gnb_logs_capture_csv.count_pdsch_rank2_tx  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}

        #log    varTmp=${varTmp}   console=${DEBUG_MODE_CONSOLE}

        ${l1l2_M55301C01000}   Evaluate    ${l1l2_M55301C01000} + ${varTmp}[64QAM][0]
        ${l1l2_M55301C01001}   Evaluate    ${l1l2_M55301C01001} + ${varTmp}[64QAM][1]
        ${l1l2_M55301C01002}   Evaluate    ${l1l2_M55301C01002} + ${varTmp}[64QAM][2]
        ${l1l2_M55301C01003}   Evaluate    ${l1l2_M55301C01003} + ${varTmp}[64QAM][3]
        ${l1l2_M55301C01004}   Evaluate    ${l1l2_M55301C01004} + ${varTmp}[64QAM][4]
        ${l1l2_M55301C01005}   Evaluate    ${l1l2_M55301C01005} + ${varTmp}[64QAM][5]
        ${l1l2_M55301C01006}   Evaluate    ${l1l2_M55301C01006} + ${varTmp}[64QAM][6]
        ${l1l2_M55301C01007}   Evaluate    ${l1l2_M55301C01007} + ${varTmp}[64QAM][7]
        ${l1l2_M55301C01008}   Evaluate    ${l1l2_M55301C01008} + ${varTmp}[64QAM][8]
        ${l1l2_M55301C01009}   Evaluate    ${l1l2_M55301C01009} + ${varTmp}[64QAM][9]
        ${l1l2_M55301C01010}   Evaluate    ${l1l2_M55301C01010} + ${varTmp}[64QAM][10]
        ${l1l2_M55301C01011}   Evaluate    ${l1l2_M55301C01011} + ${varTmp}[64QAM][11]
        ${l1l2_M55301C01012}   Evaluate    ${l1l2_M55301C01012} + ${varTmp}[64QAM][12]
        ${l1l2_M55301C01013}   Evaluate    ${l1l2_M55301C01013} + ${varTmp}[64QAM][13]
        ${l1l2_M55301C01014}   Evaluate    ${l1l2_M55301C01014} + ${varTmp}[64QAM][14]
        ${l1l2_M55301C01015}   Evaluate    ${l1l2_M55301C01015} + ${varTmp}[64QAM][15]
        ${l1l2_M55301C01016}   Evaluate    ${l1l2_M55301C01016} + ${varTmp}[64QAM][16]
        ${l1l2_M55301C01017}   Evaluate    ${l1l2_M55301C01017} + ${varTmp}[64QAM][17]
        ${l1l2_M55301C01018}   Evaluate    ${l1l2_M55301C01018} + ${varTmp}[64QAM][18]
        ${l1l2_M55301C01019}   Evaluate    ${l1l2_M55301C01019} + ${varTmp}[64QAM][19]
        ${l1l2_M55301C01020}   Evaluate    ${l1l2_M55301C01020} + ${varTmp}[64QAM][20]
        ${l1l2_M55301C01021}   Evaluate    ${l1l2_M55301C01021} + ${varTmp}[64QAM][21]
        ${l1l2_M55301C01022}   Evaluate    ${l1l2_M55301C01022} + ${varTmp}[64QAM][22]
        ${l1l2_M55301C01023}   Evaluate    ${l1l2_M55301C01023} + ${varTmp}[64QAM][23]
        ${l1l2_M55301C01024}   Evaluate    ${l1l2_M55301C01024} + ${varTmp}[64QAM][24]
        ${l1l2_M55301C01025}   Evaluate    ${l1l2_M55301C01025} + ${varTmp}[64QAM][25]
        ${l1l2_M55301C01026}   Evaluate    ${l1l2_M55301C01026} + ${varTmp}[64QAM][26]
        ${l1l2_M55301C01027}   Evaluate    ${l1l2_M55301C01027} + ${varTmp}[64QAM][27]
        ${l1l2_M55301C01028}   Evaluate    ${l1l2_M55301C01028} + ${varTmp}[64QAM][28]
        ${l1l2_M55301C01029}   Evaluate    ${l1l2_M55301C01029} + ${varTmp}[64QAM][29]
        ${l1l2_M55301C01030}   Evaluate    ${l1l2_M55301C01030} + ${varTmp}[64QAM][30]
        ${l1l2_M55301C01031}   Evaluate    ${l1l2_M55301C01031} + ${varTmp}[64QAM][31]

        ${l1l2_M55301C16000}   Evaluate    ${l1l2_M55301C16000} + ${varTmp}[256QAM][0]
        ${l1l2_M55301C16001}   Evaluate    ${l1l2_M55301C16001} + ${varTmp}[256QAM][1]
        ${l1l2_M55301C16002}   Evaluate    ${l1l2_M55301C16002} + ${varTmp}[256QAM][2]
        ${l1l2_M55301C16003}   Evaluate    ${l1l2_M55301C16003} + ${varTmp}[256QAM][3]
        ${l1l2_M55301C16004}   Evaluate    ${l1l2_M55301C16004} + ${varTmp}[256QAM][4]
        ${l1l2_M55301C16005}   Evaluate    ${l1l2_M55301C16005} + ${varTmp}[256QAM][5]
        ${l1l2_M55301C16006}   Evaluate    ${l1l2_M55301C16006} + ${varTmp}[256QAM][6]
        ${l1l2_M55301C16007}   Evaluate    ${l1l2_M55301C16007} + ${varTmp}[256QAM][7]
        ${l1l2_M55301C16008}   Evaluate    ${l1l2_M55301C16008} + ${varTmp}[256QAM][8]
        ${l1l2_M55301C16009}   Evaluate    ${l1l2_M55301C16009} + ${varTmp}[256QAM][9]
        ${l1l2_M55301C16010}   Evaluate    ${l1l2_M55301C16010} + ${varTmp}[256QAM][10]
        ${l1l2_M55301C16011}   Evaluate    ${l1l2_M55301C16011} + ${varTmp}[256QAM][11]
        ${l1l2_M55301C16012}   Evaluate    ${l1l2_M55301C16012} + ${varTmp}[256QAM][12]
        ${l1l2_M55301C16013}   Evaluate    ${l1l2_M55301C16013} + ${varTmp}[256QAM][13]
        ${l1l2_M55301C16014}   Evaluate    ${l1l2_M55301C16014} + ${varTmp}[256QAM][14]
        ${l1l2_M55301C16015}   Evaluate    ${l1l2_M55301C16015} + ${varTmp}[256QAM][15]
        ${l1l2_M55301C16016}   Evaluate    ${l1l2_M55301C16016} + ${varTmp}[256QAM][16]
        ${l1l2_M55301C16017}   Evaluate    ${l1l2_M55301C16017} + ${varTmp}[256QAM][17]
        ${l1l2_M55301C16018}   Evaluate    ${l1l2_M55301C16018} + ${varTmp}[256QAM][18]
        ${l1l2_M55301C16019}   Evaluate    ${l1l2_M55301C16019} + ${varTmp}[256QAM][19]
        ${l1l2_M55301C16020}   Evaluate    ${l1l2_M55301C16020} + ${varTmp}[256QAM][20]
        ${l1l2_M55301C16021}   Evaluate    ${l1l2_M55301C16021} + ${varTmp}[256QAM][21]
        ${l1l2_M55301C16022}   Evaluate    ${l1l2_M55301C16022} + ${varTmp}[256QAM][22]
        ${l1l2_M55301C16023}   Evaluate    ${l1l2_M55301C16023} + ${varTmp}[256QAM][23]
        ${l1l2_M55301C16024}   Evaluate    ${l1l2_M55301C16024} + ${varTmp}[256QAM][24]
        ${l1l2_M55301C16025}   Evaluate    ${l1l2_M55301C16025} + ${varTmp}[256QAM][25]
        ${l1l2_M55301C16026}   Evaluate    ${l1l2_M55301C16026} + ${varTmp}[256QAM][26]
        ${l1l2_M55301C16027}   Evaluate    ${l1l2_M55301C16027} + ${varTmp}[256QAM][27]
        ${l1l2_M55301C16028}   Evaluate    ${l1l2_M55301C16028} + ${varTmp}[256QAM][28]
        ${l1l2_M55301C16029}   Evaluate    ${l1l2_M55301C16029} + ${varTmp}[256QAM][29]
        ${l1l2_M55301C16030}   Evaluate    ${l1l2_M55301C16030} + ${varTmp}[256QAM][30]
        ${l1l2_M55301C16031}   Evaluate    ${l1l2_M55301C16031} + ${varTmp}[256QAM][31]

        ${varTmp}=   gnb_logs_capture_csv.countNumPdschPrb  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
        ${l1l2_M55308C10001}   Evaluate    ${l1l2_M55308C10001} + ${varTmp}

        ${varTmp}=   gnb_logs_capture_csv.count_DlDataSlot  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
        ${l1l2_M55308C00005}   Evaluate    ${l1l2_M55308C00005} + ${varTmp}

        ${varTmp}=   gnb_logs_capture_csv.count_SsbSlotWithPDSCH  ${output_CSV_file}  ${pm_file_endTime}   ${meas_period_in_min}
        ${l1l2_M55308C00015}   Evaluate    ${l1l2_M55308C00015} + ${varTmp}
        ${l1l2_M55308C00016}   Evaluate    500*${l1l2_M55308C00015}
    END

    &{l1l2_M55301xx}     Create Dictionary    M55301C01000     ${l1l2_M55301C01000}
    ...                                       M55301C01001     ${l1l2_M55301C01001}
    ...                                       M55301C01002     ${l1l2_M55301C01002}
    ...                                       M55301C01003     ${l1l2_M55301C01003}
    ...                                       M55301C01004     ${l1l2_M55301C01004}
    ...                                       M55301C01005     ${l1l2_M55301C01005}
    ...                                       M55301C01006     ${l1l2_M55301C01006}
    ...                                       M55301C01007     ${l1l2_M55301C01007}
    ...                                       M55301C01008     ${l1l2_M55301C01008}
    ...                                       M55301C01009     ${l1l2_M55301C01009}
    ...                                       M55301C01010     ${l1l2_M55301C01010}
    ...                                       M55301C01011     ${l1l2_M55301C01011}
    ...                                       M55301C01012     ${l1l2_M55301C01012}
    ...                                       M55301C01013     ${l1l2_M55301C01013}
    ...                                       M55301C01014     ${l1l2_M55301C01014}
    ...                                       M55301C01015     ${l1l2_M55301C01015}
    ...                                       M55301C01016     ${l1l2_M55301C01016}
    ...                                       M55301C01017     ${l1l2_M55301C01017}
    ...                                       M55301C01018     ${l1l2_M55301C01018}
    ...                                       M55301C01019     ${l1l2_M55301C01019}
    ...                                       M55301C01020     ${l1l2_M55301C01020}
    ...                                       M55301C01021     ${l1l2_M55301C01021}
    ...                                       M55301C01022     ${l1l2_M55301C01022}
    ...                                       M55301C01023     ${l1l2_M55301C01023}
    ...                                       M55301C01024     ${l1l2_M55301C01024}
    ...                                       M55301C01025     ${l1l2_M55301C01025}
    ...                                       M55301C01026     ${l1l2_M55301C01026}
    ...                                       M55301C01027     ${l1l2_M55301C01027}
    ...                                       M55301C01028     ${l1l2_M55301C01028}
    ...                                       M55301C01029     ${l1l2_M55301C01029}
    ...                                       M55301C01030     ${l1l2_M55301C01030}
    ...                                       M55301C01031     ${l1l2_M55301C01031}
	...                                       M55301C16000     ${l1l2_M55301C16000}
	...                                       M55301C16001     ${l1l2_M55301C16001}
    ...                                       M55301C16002     ${l1l2_M55301C16002}
    ...                                       M55301C16003     ${l1l2_M55301C16003}
    ...                                       M55301C16004     ${l1l2_M55301C16004}
    ...                                       M55301C16005     ${l1l2_M55301C16005}
    ...                                       M55301C16006     ${l1l2_M55301C16006}
    ...                                       M55301C16007     ${l1l2_M55301C16007}
    ...                                       M55301C16008     ${l1l2_M55301C16008}
    ...                                       M55301C16009     ${l1l2_M55301C16009}
    ...                                       M55301C16010     ${l1l2_M55301C16010}
    ...                                       M55301C16011     ${l1l2_M55301C16011}
    ...                                       M55301C16012     ${l1l2_M55301C16012}
    ...                                       M55301C16013     ${l1l2_M55301C16013}
    ...                                       M55301C16014     ${l1l2_M55301C16014}
    ...                                       M55301C16015     ${l1l2_M55301C16015}
    ...                                       M55301C16016     ${l1l2_M55301C16016}
    ...                                       M55301C16017     ${l1l2_M55301C16017}
    ...                                       M55301C16018     ${l1l2_M55301C16018}
    ...                                       M55301C16019     ${l1l2_M55301C16019}
    ...                                       M55301C16020     ${l1l2_M55301C16020}
    ...                                       M55301C16021     ${l1l2_M55301C16021}
    ...                                       M55301C16022     ${l1l2_M55301C16022}
    ...                                       M55301C16023     ${l1l2_M55301C16023}
    ...                                       M55301C16024     ${l1l2_M55301C16024}
    ...                                       M55301C16025     ${l1l2_M55301C16025}
    ...                                       M55301C16026     ${l1l2_M55301C16026}
    ...                                       M55301C16027     ${l1l2_M55301C16027}
    ...                                       M55301C16028     ${l1l2_M55301C16028}
    ...                                       M55301C16029     ${l1l2_M55301C16029}
    ...                                       M55301C16030     ${l1l2_M55301C16030}
    ...                                       M55301C16031     ${l1l2_M55301C16031}
    ...                                       M55308C10001     ${l1l2_M55308C10001}
    ...                                       M55308C00005     ${l1l2_M55308C00005}
    ...                                       M55308C00015     ${l1l2_M55308C00015}
    ...                                       M55308C00016     ${l1l2_M55308C00016}
    Set Suite Variable   &{l1l2_M55301xx}

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
    [Arguments]           ${gNB}=0
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${ORIG_SCF[0]}
    ${dist_name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    scf.load_scf     ${current_scf_fullname}
    # MRBTS-1
    ${pRachConfigId}     scf.get_value_from_scf   p_name=prachConfigurationIndex
    ...              dist_name=${dist_name}
    set suite variable             ${pRachConfigId}
