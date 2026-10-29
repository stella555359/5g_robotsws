*** Settings ***
Documentation
...               Feature ID: CB007814
...               Author: Divyanshi.gupta@nokia.com
Resource          ./testsuite/Bangalore/ORAN/SG04/CB007814/resourcefile/CB007623_keywords.robot
Resource          ./testsuite/Bangalore/ORAN/resources/robot/common_setup_teardown.robot
Library           Process
#Library           String      WITH NAME   str
Library           ./testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library           Collections
Library           DateTime
Library           taf.selenium.sbts    WITH NAME    soam
Library           taf.analyzer.sherpa    WITH NAME    sherpa_analyzer
Library           taf.collectors.pmcounters    WITH NAME    PM
Library           taf.analyzer.pmcounter    WITH NAME    analyser
Library           taf.selenium.sbts    WITH NAME    sbts
Library           taf.ccs.aashell     WITH NAME    cli
Library           taf.sw.dcap.rd     WITH NAME   dcap
Library           ./testsuite/Bangalore/ORAN/SG04/resources/dcap_extract_file.py
Library           ./testsuite/Bangalore/ORAN/SG04/CB007814/resourcefile/validation.py
Library           ./testsuite/Bangalore/ORAN/SG04/CB007814/resourcefile/interface.py
Force Tags        TRUNK_7814    24R3	25R1    7814_SG06    FL00    QCD_MN_RAN    QCP_RAN_VRF

#Suite Setup       Run Keywords    Suite Setup Update GNB
#Suite Teardown    Run Keywords    Admin Teardown
#...               AND    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is OnAir

Test setup        Admin Setup
Test Teardown     Admin Teardown

*** Variables ***
&{CB007814_TC5}
...     QC_ID_FL00=QC_31648   QC_ID_SBTS24R3=QC_852875    QC_ID_SBTS25R1=QC_79006

${CELL_ID}          1
@{LOG_NAME_LIST}    btslog    snapshot
@{capabilities}    Legacy_3
@{throughput_dl_udp}=   300
@{throughput_ul_udp}=   100
@{throughput_dl_tcp}=   300
@{throughput_ul_tcp}=   100
@{dt_name}=   iperf_dl_test
@{UE_alias}=  UE3
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
#@{timeout}      180
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
@{deviation_dl}=  90
@{deviation_ul}=  90
${packet_size}=  1400
${tput}=   400Mbits/sec
${ASP_BOARD_TYPE}     ABIO0
${SCF_PATH}         ${CURDIR}/resources/
${DELTA_FILE}       ${CURDIR}/resources/Configuration_scf_MRBTS-990.xml
${scf_file}=        ${DELTA_FILE}
${port_val_list}     9
${counter_initial_value_1}      M55301C
${value1}    18020
${a}     1
${host}    10.41.209.115
${M_plane_ip}    10.58.239.169
${Retry_count}    		    1
${path1_sherpa}     /tmp/testgetter/output_file/macro__dlStat.csv
${path3_sherpa}     /tmp/testgetter/output_file/macro__ulStat.csv
${path5}      NDLSQ
${path6}      NULSQ
${s}           8
${t}           9
@{gnb_customfilter}    L2Ps_Sherpa      L2Lo_Sherpa     cp_5g       #  L2HiRlc_Sherpa     L2HiPdcp_Sherpa      cp_5g
@{bts_custom_filter}        immediateSnapshot    scf
${emil_profile}             ${emil_path}//profiles//5G                                              # Emil profile path in UE PC machine
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs                   # Path for Emil logs are copied in UE PC
${wait_for_transfer}        True
${timeout}      300
@{LTE_cell}     5   6011
@{NR_cell}      3
${lteCell_dist}     /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-970/LNCEL_R
${NRCell_dist1}     /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-970/NRCELL_R
@{NRCELL2}  2
${gNB2_IP}                   10.58.239.89                                         # gnb LMP IP
${connection1}               Active_Session1                                          # Alias name
*** Test Cases ***


CB007814_TC5
#    [Tags]    TRUNK_7814    24R3    25R1    7814_NSA
#    Suite Setup Update GNB     scf_file=${DELTA_FILE}
#    Full Commission With SCF File    ${scf_file}

     Block LTERAT
     Lock cells  ${LTE_cell}
     Lock NR cells  ${NR_cell}
    ${actORuBeamforming}       Get Current Parameter Value    ${dist_name}/NRCELL-2         actORuBeamforming
    Run Keyword If       '${actORuBeamforming.upper()}'!= 'FALSE'      Parameter value change    ${dist_name}/NRCELL-2
    ...    actORuBeamforming      false
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    Check BTS is OnAir
    Set Suite variable	${OUTPUT_DIR}	${testdir}
    common_admin.Verify Coam Site Is Ready
    #Start DCAP log collection
    Data Transfer UDP
    Data Transfer TCP
    #Stop DCAP log collection
    Set Suite Variable    ${Log_path}        ${OUTPUT_DIR}/DCAP_Logs
    Set Suite Variable    ${source_paths}      ${Log_path}/Extracted/
    create directory         ${source_paths}
    ${files}     OperatingSystem.List Files In Directory    ${Log_path}
    FOR    ${zip}    IN    @{files}
         interface.Extract
                         ...  path=${Log_path}/${zip}
                         ...  output_dir=${source_paths}
                         ...  .=*/*/*.pcap
    END
    ${result}=    Run Process
    ...    find ${source_paths} -type f \\\( -name "*sherpa.pcap" \\\) -exec cp '{}' ${OUTPUT_DIR} \\\;
    ...    shell=True
    Run Process    command=mergecap -a ${OUTPUT_DIR}/*sherpa.pcap -w ${OUTPUT_DIR}/output_file.pcap     shell=True
    @{check}   Create list     SgNBAdditionRequest
    #Run Keyword And Continue On Failure     Verify Emil logs    @{check}
    #Run Keyword And Continue On Failure     Convert pcap to sherpa csv
    #Run Keyword And Continue On Failure     Convert sherpa csv and validate
   ${count_1}      Counter value for DL       M55301C17020
   ${count_2}      Counter value for DL       M55301C17021
   ${count_3}      Counter value for DL       M55301C17022
   ${count_4}      Counter value for DL       M55301C17023
   ${count_5}      Counter value for DL       M55301C17024
   ${count_6}      Counter value for DL       M55301C17025
   ${count_7}      Counter value for DL       M55301C17026
   ${count_8}      Counter value for DL       M55301C17027
   ${countul_1}      Counter value for UL       M55303C00020
   ${countul_2}      Counter value for UL       M55303C00021
   ${countul_3}      Counter value for UL       M55303C00022
   ${countul_4}      Counter value for UL       M55303C00023
   ${countul_5}      Counter value for UL       M55303C00024
   ${countul_6}      Counter value for UL       M55303C00025
   ${countul_7}      Counter value for UL       M55303C00026
   ${countul_8}      Counter value for UL       M55303C00027
   ${countul_9}      Counter value for UL       M55303C00028
   ${countul_9}      Counter value for UL       M55303C00029
   Unlock cells    ${LTE_cell}
   Unlock NRcells  ${NR_cell}
   Unblock LTERAT
   RP Settings
   Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Test Teardown
   Unlock cells    ${LTE_cell}
   Unlock NRcells  ${NR_cell}
   Unblock LTERAT

Data Transfer UDP
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=@{direction_dl}
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl_udp}    deviation=${deviation_dl}

    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=@{direction_ul}
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul_udp}    deviation=${deviation_ul}
    Log to console    \nWaiting for data transfer

Data Transfer TCP
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting data transfer
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_dl}
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl_tcp}    deviation=${deviation_dl}

    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_ul}
     Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_ul}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul_tcp}    deviation=${deviation_ul}
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed

Convert sherpa csv and validate
    sherpa_analyzer.setup reader    ${path1_sherpa}
    ${result1}     sherpa_analyzer.get values for column    256QAM    [^0]+
    ${result2}     sherpa_analyzer.get values for column    MAX MCS    27
    ${result3}     sherpa_analyzer.get values for column    MAX PRB    106
    ${result4}    value     ${result2}
    Should Be True    ${result4}
    ${result5}    QAM_validation    ${result1}
    Should Not Be Empty     ${result5}
    Run Keyword And Continue On Failure     Should Not Be Empty     ${result3}
    sherpa_analyzer.setup reader    ${path3_sherpa}
    ${result1}     sherpa_analyzer.get values for column    64QAM    [^0]+
    ${result2}     sherpa_analyzer.get values for column    MAX MCS   27
    ${result3}     sherpa_analyzer.get values for column    MAX PRB    96
    ${result4}    value     ${result2}
    Should Be True    ${result4}
    ${result5}    QAM_validation    ${result1}
    Should Not Be Empty     ${result5}
    Run Keyword And Continue On Failure     Should Not Be Empty     ${result3}

Start DCAP log collection
    dcap.connect_to  host=${host}   port=443    username=utfuser   password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g
    ${output}    dcap.start_trace     duration=600    bts=${bts1_info}
    ...    gnb_custom_profile=@{gnb_customfilter}
    LogToConsole    ${output}
    ${output}=    Set Suite Variable    ${output}
    sleep   100

Stop DCAP log collection
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    Run Keyword And Continue On Failure    dcap.stop_trace    trace_id=${trace_id}
    LogToConsole    ${trace_id}
    ${dcap_dirname}    dcap.get_results    result_id=${trace_id}    target_dir=${OUTPUT_DIR}/DCAP_Logs    timeout=2000
    LogToConsole    ${dcap_dirname}
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname}

Convert pcap to sherpa csv
    Create Directory        /tmp/testgetter
    sherpa.create sherpa converter
        ...    name=sherpa
        ...    file_path_pattern=${OUTPUT_DIR}/output_file.pcap
        ...    output_path=/tmp/testgetter
    sherpa.setup    sherpa
    sherpa.convert    sherpa
    sherpa.teardown    sherpa




Counter value for DL
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=300    connection=${connection}
    log    ${result}
#    ${values}   Run keyword if  "${Branch}"!="24R3"     Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-2']['NDLSQ']['${counter_name}']}
#    ...          ELSE    Run keyword     Get Dictionary Values    ${result['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-2']['NDLSQ']['${counter_name}']}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-2']['NDLSQ']['${counter_name}']}
#    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-2']['NDLSQ']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Counter value for DLcell2
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    couter_ids=${counter_name}    timeout=120    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-2']['NDLSQ']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}


Get value of Counter
    [Arguments]    ${Counter_value}
    [Documentation]     Get total value from list
    FOR    ${a}    IN    @{Counter_value}
        ${i}    Evaluate    ${i} + ${a}
    END
    [Return]    ${i}

Counter value for UL
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=300    connection=${connection}
    log    ${result}
#    ${values}    Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-2']['NULSQ']['${counter_name}']}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-2']['NULSQ']['${counter_name}']}
#   ${values}   Run keyword if  "${Branch}"!="24R3"     Get Dictionary Values    ${result['BTS']['CELLS']['NRCELL-2']['NULSQ']['${counter_name}']}
#   ...          ELSE    Run keyword     Get Dictionary Values    ${result['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-2']['NULSQ']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Counter value for ULcell2
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    couter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-970']['NRBTS-970']['NRCELL-2']['NULSQ']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Unpack log files
    [Arguments]    ${dcap_dirname}
   ${unzip_files}    unpack   path=${dcap_dirname}
    ${result}=    Run Process
     ...    find ${dcap_dirname} -type f \\\( -name "*.htm*" -o -name "*.js*" -o -name "*.txt" -o -name "*.LOG" -o -name "*.pcap" \\\)
	 ...    -exec cp '{}' ${OUTPUT_DIR} \\\;    shell=True

Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${lteCell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${lteCell_dist}-${cell}            locking_status=locked
        ...                                                                         operational_status=disabled     usage_status=Idle
        ...                                                                         blocking_status=Unblocked
    END

Lock NR cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${nrcell_list}
    FOR    ${cell}    IN    @{nrcell_list}
        Log to console      \nLocking cell : ${cell}
        COAM.lock           dist_name=${NRCell_dist1}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${NRCell_dist1}-${cell}            locking_status=locked
        ...                                                                         operational_status=disabled     usage_status=Idle
        ...                                                                         blocking_status=Unblocked
    END

Unlock cells
    [Arguments]     ${cell_list}
    [Documentation]     Unlock specified cell
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
        COAM.unlock    dist_name=${lteCell_dist}-${cell}       timeout=180     connection=${connection}
    END
#    Wait Until Keyword Succeeds    10 times    30    CB007623_keywords.Check cell status

Unlock NRcells
    [Documentation]     Unlock specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nUnlocking cell : ${cell}
        COAM.unlock         dist_name=${NRCell_dist1}-${cell}      timeout=180     connection=${connection}
    END
    Log to console                  \nWaiting for cell to be onAir
    Wait Until Keyword Succeeds     30 times    10      Check cell details      ${NRCell_dist1}-${cell}

Block LTERAT
	COAM.setup_admin    bts_host=${gNB2_IP}    alias=${connection1}    admin_api_log_dir=/tmp
	Wait until keyword succeeds   1min   2s    COAM.block_rat    rat=LTE    connection=${connection1}

Unblock LTERAT
    Wait until keyword succeeds   1min   2s    COAM.unblock_rat    rat=LTE    connection=${connection1}
    COAM.teardown_admin    connection=${connection1}
