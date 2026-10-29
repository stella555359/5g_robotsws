*** Settings ***
Documentation
...               Feature ID: CB007814
...               Author: Divyanshi.gupta@nokia.com
Resource          ./resources/CB007623_keywords.robot
Resource          ../../resources/robot/common_setup_teardown.robot
Resource          ../resources/Common_resource.robot
Library           Process
Library           String      WITH NAME   str
Library           ../../resources/python/ta_ultracaller/
Library           Collections
Library           DateTime
Library           taf.selenium.sbts    WITH NAME    soam
Library           taf.analyzer.sherpa    WITH NAME    sherpa_analyzer
Library           taf.collectors.pmcounters    WITH NAME    PM
Library           taf.analyzer.pmcounter    WITH NAME    analyser
Library           taf.selenium.sbts    WITH NAME    sbts
Library           taf.ccs.aashell     WITH NAME    cli
Library           taf.sw.dcap.rd     WITH NAME   dcap
Library           dcap_extract_file.py
Library           ./resources/validation.py

Test setup        CB007623_keywords.Admin Setup
Test Teardown     CB007623_keywords.Admin Teardown

*** Variables ***

${CELL_ID}          1
@{LOG_NAME_LIST}    btslog    snapshot
@{capabilities}    Legacy_1
@{throughput_dl}=   150
@{throughput_ul}=   100
@{dt_name}=   iperf_dl_test
@{UE_alias}=  UE_2
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
@{timeout}      180
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
${host}    10.41.209.116
${M_plane_ip}    10.58.239.174
${Retry_count}    		    2
${path1}     /tmp/testgetter/output_file/macro__dlStat.csv
${path2}      /tmp/testgetter/output_file/macro__dlMcPercentsStat.csv
${path3}     /tmp/testgetter/output_file/macro__ulStat.csv
${path4}     /tmp/testgetter/output_file/macro__ulMcsPercentStat.csv
${path5}      NDLSQ
${path6}      NULSQ
${s}           8
${t}           9
${counter_initial_value_3}     M55301C
${value3}                      18020
${counter_initial_value_4}     M55303C000
${value4}                      20
@{gnb_customfilter}    L2Ps_Sherpa      L2Lo_Sherpa     L2HiRlc_Sherpa     L2HiPdcp_Sherpa      condor5gSyslog     cp_5g
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture
${emil_profile}             ${emil_path}//profiles//5G                                              # Emil profile path in UE PC machine
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs                   # Path for Emil logs are copied in UE PC
${emil_path}                C://Program Files//Emil


*** Test Cases ***


CB007814_TC5
    Suite Setup Update GNB     scf_file=${DELTA_FILE}
    Full Commission With SCF File    ${scf_file}
    ${actORuBeamforming}		Get Current Parameter Value    ${dist_name}/NRCELL-1	     actORuBeamforming
    Run Keyword If       '${actORuBeamforming.upper()}'!= 'TRUE'		Parameter value change    ${dist_name}/NRCELL-1 		 actORuBeamforming		true
    ${actORuBeamforming}		Get Current Parameter Value    ${dist_name}/NRCELL-1	     actORuBeamforming
    Run Keyword If       '${actORuBeamforming.upper()}'!= 'FALSE'		Parameter value change    ${dist_name}/NRCELL-1 		 actORuBeamforming		false
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    CB007623_keywords.Check BTS is OnAir
    common_admin.Verify Coam Site Is Ready
    Set Environment Variable        TA_UE_CONFIG        ${CONFIG_PATH}
    Start DCAP log collection
    Set Environment Variable		TA_UE_CONFIG		/home/ute/testline_configuration_5G/Bangalore/debian10/ta_ue_config.yaml
    Data Transfer UDP
    Data Transfer TCP
    Stop DCAP log collection
    Set Suite Variable    ${Log_path}        ${OUTPUT_DIR}/${Folder}/DCAP_Logs
    Set Suite Variable    ${source_paths}      ${Log_path}/Extracted/
    create directory         ${source_paths}
    ${files}     OperatingSystem.List Files In Directory    ${Log_path}
    FOR    ${zip}    IN    @{files}
        unzip_and_extract_file_name    ${Log_path}/${zip}    ${source_paths}     /**/*Syslog*.LOG
        unzip_and_extract_file_name    ${Log_path}/${zip}    ${source_paths}/dcap_64qam     /**/*.pcap
    END
    Run Process    command=mergecap -a ${source_paths}/dcap_64qam/*.pcap -w ${source_paths}/dcap_64qam/output_file.pcap     shell=True
    @{check}   Create list     SgNBAdditionRequest
    Verify Emil logs    @{check}
    Convert pcap to sherpa csv
    Convert sherpa csv and validate
    Check Counter    ${counter_initial_value_3}    ${value3}    ${path5}    ${s}
    Check Counter    ${counter_initial_value_4}    ${value4}    ${path6}    ${t}



*** Keywords ***

Data Transfer UDP
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
    sleep    230
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}

    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_ul}
    sleep    230
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
    Log to console    \nWaiting for data transfer

Data Transfer TCP
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting data transfer
    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_dl}
    sleep    200
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}

    Run Keyword And Continue On Failure    ta_ultracaller.start_data_transfer  ${UE_alias}   ${tcpcalltype}    direction=${direction_ul}
    sleep    200
    Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
    Log to console    \nWaiting for data transfer
    Log to console    \nData transfer completed

Convert sherpa csv and validate
    sherpa_analyzer.setup reader    ${path1}
    ${result1}     sherpa_analyzer.get values for column    256QAM    regexfilter=None
    ${result2}     sherpa_analyzer.get values for column    MAX MCS    regexfilter=None
    ${result3}     sherpa_analyzer.get values for column    MAX PRB    regexfilter=52
    ${result4}    value     ${result2}
    Should Be True    ${result4}
    ${result5}    QAM_validation    ${result1}
    Should Not Be Empty     ${result5}
    Run Keyword And Continue On Failure     Should Not Be Empty     ${result3}
	sherpa_analyzer.setup reader    ${path3}
    ${result1}     sherpa_analyzer.get values for column    64QAM    regexfilter=None
    ${result2}     sherpa_analyzer.get values for column    MAX MCS    regexfilter=None
    ${result3}     sherpa_analyzer.get values for column    MAX PRB    regexfilter=52
    ${result4}    value     ${result2}
    Should Be True    ${result4}
    ${result5}    QAM_validation    ${result1}
    Should Not Be Empty     ${result5}
    Run Keyword And Continue On Failure     Should Not Be Empty     ${result3}

Start DCAP log collection
    dcap.connect_to  host=${host}   port=443    username=dcapuser   password=dcapadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g
    ${output}    dcap.start_trace     duration=25    bts=${bts1_info}
    ...    gnb_custom_profile=@{gnb_customfilter}
    LogToConsole    ${output}
    ${output}=    Set Suite Variable    ${output}
    sleep   100

Stop DCAP log collection
    ${trace_id} =   Get From Dictionary   ${output}   id
    Run Keyword And Continue On Failure    dcap.stop_trace    trace_id=${trace_id}
    LogToConsole    ${trace_id}
    ${dcap_dirname}    dcap.get_results    result_id=${trace_id}    target_dir=${OUTPUT_DIR}/${Folder}/DCAP_Logs    timeout=2000
    LogToConsole    ${dcap_dirname}
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname}

Convert pcap to sherpa csv
    sherpa.create sherpa converter
        ...    name=sherpa
        ...    file_path_pattern=${source_paths}/dcap_64qam/output_file.pcap
        ...    output_path=/tmp/testgetter
    sherpa.setup    sherpa
    sherpa.convert    sherpa
    sherpa.teardown    sherpa





