*** Settings ***
Force Tags    5GC000480  5GC000480-K
...           STATE_CONFIGURED
...           CRT      CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_GMC
...           RAN_5G   RAN_5G_TDD      RAN_5G_FDD
...           SBTS00


Documentation   This is a Robot Test Suite for subfeature 5GC000480-K 'Average, Holding time and Peak counters
...             for NSA calls with Radio Admission Control' testing
...             5GC000480-K sub-feature affects only counters.
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
#-------------------------------------------------------------------------------------------------------------
Library         taf.config.wts    WITH NAME    wts
Resource        ../keywordbook-480.robot
Resource        ../../../resources/Common/reporting.robot


Suite Setup     Suite Setup 5GC000480-K
Suite Teardown  Suite Teardown 5GC000480-K

*** Variables ***

${cell1_distName}          NRCELL-1

${TCPDUMP_RUNNING}         false


*** Test Cases ***

5GC000480_K_Avg_Peak_number_and_holding_time_counters_for_RAC_are_displayed_with_correct_value
    [Documentation]    This Test Scenario verifies the counters M55114C00008, M55114C00009, M55114C00010,
    ...                M55114C00011, M55114C00012, M55114C00013, M55114C00036, M55131C00001

    [Setup]    Perform Preconditions of Test Scenario 480-A-B-K

    prepare counters and expected values
    update parameter values with delta commissioning


    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    attach and detach multiple UEs

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values
    Verify wireshark

    [Teardown]    Perform Postconditions of Test Scenario 5GC000480-K



*** Keywords ***
Suite Setup 5GC000480-K
    [Documentation]    [PRIVATE]    suite setup for 480-K
    ...       :Autor: Sylvia Schneider
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Store Current WTS Config
    update sw config to trace missing pm counter
    Update wts file for TC480K
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_480K.cfg


Perform Postconditions of Test Scenario 5GC000480-K
    [Documentation]    [PRIVATE]    postconditions for 5GC000480-K
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop tcpdump trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown 5GC000480-K
    Reload Stored WTS Config


update sw config to trace missing pm counter
    [Documentation]    [PRIVATE]    update sw config to trace missing pm counter
    ...       :Autor: Sylvia Schneider
    Log To Console    \n\n/ffs/run/swconfig.txt on gNB update flags for tracing pm counter
    Log To Console    \#BSTAT
    Log To Console    0x340001=1 \#enable BStat core flag
    Log To Console    0x340002=1 \#enable BStat PM flag
    Log To Console    0x340006=55131 \#Debug flag for M55131
    Log To Console    0x34000A=1 \#ArrAggrCollectionService
    @{list_add_flags}   create list
    ...       0x340001=1
    ...       0x340002=1
    ...       0x340006=55131
    ...       0x34000A=1
    ...       0x590072=1
    ...       0x1003f=1
    Update SW Config file on System Module   param_list=@{list_add_flags}


Update wts file for TC480K
    [Documentation]    [PRIVATE]    update wts cfg file
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate wts cfg
    ${wtsconfig}   Get WTS Config    target_dir=${resultBaseDir}
    wts.Load wts cfg             ${wtsconfig}
    wts.Clone and Modify    set_ue simulated id=12           id=13 imsi=311:489:21645402
    wts.Clone and Modify    ue_param id=12                   id=13
    wts.Clone and Modify    set_bearer id=2 ue=12            ue=13 ip=4.7.254.3
    wts.Save wts cfg        ${resultBaseDir}/basic_wts_480K.cfg
    Log To Console    \nwts cfg saved as ${resultBaseDir}/basic_wts_480K.cfg


Start tcpdump trace
    [Documentation]    [PRIVATE]    start tcpdump trace
    ...       :Autor: Sylvia Schneider
    Log To Console    \ntcpdump started
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Set suite variable      ${TCPDUMP_RUNNING}    true


Stop tcpdump trace
    [Documentation]    [PRIVATE]    stop tcpdump trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${TCPDUMP_RUNNING}'=='false'   RETURN
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Run Keyword And Continue On Failure  Move File    ${tcpdump_file}    ${wireshark_store}
    Log To Console    \ntcpdump stopped
    Set suite variable      ${TCPDUMP_RUNNING}    false


attach and detach multiple UEs
    [Documentation]    [PRIVATE]    start tcpdum, attach and detach UEs, stop tcpdump
    ...       :Autor: Sylvia Schneider
    Start tcpdump trace

    sleep     2s
    ${call_data_dict_temp}    Attach UEs   @{list_of_used_UEs}
    sleep    45s
    ${call_data_dict_temp}    Detach UEs   @{list_of_used_UEs}    &{call_data_dict_temp}
    sleep     2s

    Stop tcpdump trace

    Set Test Variable    ${call_data_dict}    ${call_data_dict_temp}


prepare counters and expected values
    [Documentation]    [PRIVATE]    prepare counters and expected values
    ...       :Autor: Sylvia Schneider
    set test variable    @{list_of_used_UEs}          11    12    13
    set test variable    @{M55114C00008}    AVE_NUMBER_OF_NSA_USERS           call_duration*3                 cell1   RACCU
    set test variable    @{M55114C00009}    AVE_NUMBER_OF_NSA_USERS_DENOM     measurement_period_in_min*60    cell1   RACCU
    set test variable    @{M55114C00010}    PEAK_NUMBER_OF_NSA_USERS          3                               cell1   RACCU
    set test variable    @{M55114C00011}    AVE_NSA_USER_HOLDING_TIME         call_duration*3*0.9             cell1   RACCU
    set test variable    @{M55114C00012}    AVE_NSA_USER_HOLDING_TIME_DEN     3                               cell1   RACCU
    set test variable    @{M55114C00013}    PEAK_NSA_USER_HOLDING_TIME        call_duration*0.9               cell1   RACCU
    set test variable    @{M55114C00036}    PEAK_NUMBER_OF_NSA_USERS_GR       3                               cell1   RACCU
    set test variable    @{M55131C00001}    PEAK_NUMBER_OF_NSA_USERS_CU       3                               bts     NTRAF


update parameter values with delta commissioning
    [Documentation]    [PRIVATE]    update parameter values with delta commissioning
    ...       :Autor: Sylvia Schneider
    set test variable    ${measurement_period_in_min}      5

    ${d_reportingIntervalPm}      create dictionary
    ...    dist_name    ${pmcadm_distName}
    ...    parameter    reportingIntervalPm
    ...    value        5min
    ${d_miNrRacCu}      create dictionary
    ...    dist_name    ${bts_distName}/NRPMRNL-1
    ...    parameter    miNrRacCu
    ...    value        5min
    ${d_miNrRacDu}      create dictionary
    ...    dist_name    ${bts_distName}/NRPMRNL-1
    ...    parameter    miNrRacDu
    ...    value        5min
    ${d_miNrNTRAF}      create dictionary
    ...    dist_name    ${bts_distName}/NRPMRNL-1
    ...    parameter    miNrNTRAF
    ...    value        5min
    ${param_list}     Create List
    ...    ${d_reportingIntervalPm}
    ...    ${d_miNrRacCu}
    ...    ${d_miNrRacDu}
    ...    ${d_miNrNTRAF}
    json delta commissioning coam         ${param_list}


Attach UEs
    [Documentation]    [PRIVATE]    attach UEs contained in the list and save the attach time in a dictionary
    ...       :Autor: Sylvia Schneider
    [Arguments]    @{list_of_used_UEs}
    &{dict}    create dictionary
    FOR    ${actual_UE}    IN    @{list_of_used_UEs}
        Attach UE    ${actual_UE}
        @{gNB_addition_time}    get time    year month day hour min sec
        ${addition_time}    set variable    ${gNB_addition_time[0]}-${gNB_addition_time[1]}-
        ${addition_time}    set variable    ${addition_time}${gNB_addition_time[2]} ${gNB_addition_time[3]}:
        ${addition_time}    set variable    ${addition_time}${gNB_addition_time[4]}:${gNB_addition_time[5]}
        set to dictionary    ${dict}    ue${actual_UE}    ${addition_time}
        sleep    3s
    END
    RETURN    ${dict}


Detach UEs
    [Documentation]    [PRIVATE]    detach UEs contained in the list and save the detach time in a dictionary
    ...       :Autor: Sylvia Schneider
    [Arguments]    @{list_of_used_UEs}    &{dict}
    FOR    ${actual_UE}    IN    @{list_of_used_UEs}
        Detach UE    ${actual_UE}
        @{detach_time}    get time    year month day hour min sec
        ${call_end}       set variable    ${detach_time[0]}-${detach_time[1]}-${detach_time[2]} ${detach_time[3]}
        ${call_end}       set variable    ${call_end}:${detach_time[4]}:${detach_time[5]}
        ${start_time}     get from dictionary    ${dict}    ue${actual_UE}
        set to dictionary    ${dict}    ue${actual_UE}    ${start_time};${call_end}
        sleep    6s
    END
    RETURN    ${dict}


get call duration
    [Documentation]    [PRIVATE]    calculate the duration in secs for the 1st UE
    ...       :Autor: Sylvia Schneider
    [Arguments]    @{list_of_used_UEs}    &{call_data_dict}
    ${ue_data}   get from dictionary    ${call_data_dict}    ue11
    @{data_list}    split string    ${ue_data}    ;
    ${start_time}   set variable    ${data_list[0]}
    ${end_time}   set variable    ${data_list[1]}

    ${time_diff_in_secs}    DateTime.subtract date from date    ${end_time}    ${start_time}
    RETURN    ${time_diff_in_secs}


collect pm file and verify counter values
    [Documentation]    [PRIVATE]    upload pm file and verify the counter values
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters

    ${parsed_xml}    parse xml    ${pmCounter_xml_file}

    &{dict}    Create Dictionary    M55114C00009    ${M55114C00009}    M55114C00010    ${M55114C00010}
    ...                             M55114C00011    ${M55114C00011}    M55114C00012    ${M55114C00012}    M55114C00013    ${M55114C00013}
    ...                             M55114C00036    ${M55114C00036}    M55131C00001    ${M55131C00001}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    ${call_duration_in_secs}          get call duration    @{list_of_used_UEs}   &{call_data_dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}    ${call_duration_in_secs}
          ...               ${measurement_period_in_min}
    END
    Verify Counter M55114C00008        ${parsed_xml}    ${call_duration_in_secs}


Verify Counter
    [Documentation]    [PRIVATE]    for a single counter, verify value and report
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${counterName}    ${counterList}    ${parsed_PmFile}
    ...            ${call_duration_in_secs}    ${measurement_period_in_min}
    ${counter_text}    Set Variable    ${counterList}[0]
    ${counter_calc}    Set Variable    ${counterList}[1]
    ${counter_dist}    Set Variable    ${counterList}[2]
    # next variable will raise a linter warning I0920 but is used in KW 'Replace Variables'!
    ${counter_meastype}    Set Variable    ${counterList}[3]
    ${counter_distName}    IF   '${counter_dist}'=='cell1'    Set Variable    PLMN-PLMN/${bts_distName}/${cell1_distName}
    ...                    ELSE             Set Variable    PLMN-PLMN/${bts_distName}
    ${call_duration}    Convert To String    ${call_duration_in_secs}
    ${expectedValue_string}    Replace String    ${counter_calc}    measurement_period_in_min    ${measurement_period_in_min}
    ${expectedValue_string}    Replace String    ${expectedValue_string}    call_duration    ${call_duration}
    ${counter_expectedValue}           Evaluate     ${expectedValue_string}

    ${xpath_param}    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    replace variables    ${xpath_param}
    ${counter_value_from_pm_xml}    get element text     ${parsed_PmFile}        xpath=${xpath_param}
    ${operation}    IF   '${counterName}'=='M55114C00011'    Set Variable    <=
    ...             ELSE IF          '${counterName}'=='M55114C00013'    Set Variable    <=
    ...             ELSE              Set Variable    ==
    ${result}   Set Variable If   ${counter_expectedValue}${operation}${counter_value_from_pm_xml}   Passed   Failed

    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for object ${counter_distName}
    ${msg2}         Set Variable      expectedValue ${counter_expectedValue} ${operation} pm file value ${counter_value_from_pm_xml}\n
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}
    report pm counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify Counter M55114C00008
    [Documentation]    [PRIVATE]    for M55114C00008 counter, verify value and report
    ...       :Autor: Sylvia Schneider
   [Arguments]        ${parsed_PmFile}   ${call_duration_in_secs}
    ${counter_text}    Set Variable    ${M55114C00008}[0]
    ${counter_calc}    Set Variable    ${M55114C00008}[1]
    # next 2 variables will raise a linter warning I0920 but are used in KW 'Replace Variables'!
    ${counter_dist}    Set Variable    ${M55114C00008}[2]
    ${counter_meastype}    Set Variable    ${M55114C00008}[3]
    ${counter_distName}    Set Variable    PLMN-PLMN/${bts_distName}/${cell1_distName}
    ${counterName}    Set Variable    M55114C00008
    ${xpath_param}    get from dictionary    ${xpath_vars_pmCounter}    counter_pmFile_coam
    ${xpath_param}    replace variables    ${xpath_param}
    ${counter_value_from_pm_xml}    get element text     ${parsed_PmFile}        xpath=${xpath_param}
    ${call_duration}    Convert To String    ${call_duration_in_secs}
    ${expectedValue_string}    Replace String    ${counter_calc}    call_duration    ${call_duration}
    ${counter_expectedValue}           Evaluate     ${expectedValue_string}
    ${counter_expectedValue_min}           Evaluate     ${counter_expectedValue}*0.95
    ${counter_expectedValue_max}           Evaluate     ${expectedValue_string}*1.05
    ${result}   Set Variable If   ${counter_expectedValue_min} <= ${counter_value_from_pm_xml} <= ${counter_expectedValue_max}   Passed   Failed
    ${msg1}         Set Variable      \ncounter ${counterName} "${counter_text}" for object ${counter_distName}
    ${msg2}         Set Variable      min.expectedValue ${counter_expectedValue_min} <= pm fileValue ${counter_value_from_pm_xml}\n
    ${msg3}         Set Variable      and pm fileValue ${counter_value_from_pm_xml} <= max.expectedValue ${counter_expectedValue_max}\n
    IF    '${result}'=='Passed'    Log To Console    ${msg1} passed: ${msg2}${msg3}
    ...   ELSE    Run Keyword And Continue On Failure    Fail    ${msg1} failed: ${msg2}${msg3}
    report pm counter
    ...   id=${counterName}
    ...   value=${counter_value_from_pm_xml}
    ...   result=${result}


Verify wireshark
    [Documentation]    [PRIVATE]    Verify wireshark contained messages
    ...       :Autor: Sylvia Schneider
    ${addReq}        get from dictionary    ${x2ap}    SgNBAddReq_and_SgNBAddReqAck
    ${relReq}        get from dictionary    ${x2ap}    SgNBrelReq_and_SgNBRelReqAck
    ${contextRel}    get from dictionary    ${x2ap}    UEContRel
    ${filter}           set variable      (${addReq} || ${relReq} || ${contextRel}) && ip.src==${enb_ip}

    setup tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${resultDir}/X2_part.xml
    ...   packet_filter=${filter}
    ...   output_type=pdml
    ...   pcap_file_path=${resultDir}/wireshark.pcap
    ${pdml_xml}    parse xml    ${resultDir}/X2_part.xml

    FOR   ${message}   IN    SgNBAdditionRequest   SgNBReleaseRequest   UEContextRelease
       Log to console    \nverify 3 ${message} present
       ${xpath_param}       get from dictionary    ${xpath_vars_wireshark}    ${message}
       ${numberOfMsgs}    Get Element Count      ${pdml_xml}    xpath=${xpath_param}
       Run Keyword And Continue On Failure   Should Be Equal As Integers    ${numberOfMsgs}    ${3}
       ...     Wrong number of ${message} messages
    END
    [Teardown]    teardown tshark
