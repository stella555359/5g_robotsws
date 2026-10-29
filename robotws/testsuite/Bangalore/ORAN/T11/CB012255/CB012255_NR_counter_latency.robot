*** Settings ***
Documentation
...               Feature ID: CB012255
Suite Setup       Run Keywords    Suite Setup Update GNB
##...               AND    Stop suite BTSlog
Suite Teardown    Run Keywords    Common Suite Teardown
...               AND    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is OnAir
Resource          ../resources/Common_resource.robot
Resource                  ../CB007814_114DCAP/resources/CB007623_keywords.robot
Resource                  ../../resources/robot/common_log_analyzer.robot
Resource            ../../resources/robot/common_setup_teardown.robot
#Library           ../../SG06/CNI_97916/resources/CNI_97916.py
Library           ../../T11/resources/CNI_97916.py
Library           OperatingSystem
Library           Process
Library           ../../resources/python/ta_ultracaller/
Library           String

Library            taf.file.pack
Library    taf.sw.dcap.rd     WITH NAME   dcap



Test setup        CB007623_keywords.Admin Setup
Test Teardown     CB007623_keywords.Admin Teardown

*** Variables ***

${CELL_ID}          1
@{LOG_NAME_LIST}    btslog    snapshot
${ASP_BOARD_TYPE}     ABIO0
${port_val_list}     9
${a}     1
${host}    10.41.209.114
${M_plane_ip}    10.63.48.81
${Retry_count}    		    2
${uepc_default_ip}          10.53.252.86                                        # Windows UE PC IP
${BTS_M_plane_ip}           10.63.48.81                                        # BTS M PLane IP
${DCAP_host}                10.41.209.90                                        # DCAP server IP
${uepc_default_username}    inbabtslabuser                                       # Windows UE PC username
${uepc_default_password}    BT5l@bus3rl0g1n                                      # Windows UE PC password
${emil_path}                C://Emil                                             # Emil path in UE PC machine
${gNB_IP}                   192.168.255.129                                      # gnb LMP IP
&{BTS_INFO}               host=${BTS_M_plane_ip}  port=${port}  username='Nemuadmin' password='nemuuser' credential_region_Id='DEFAULT_CREDENTIALS'
@{gnb_custom_filters}       condor5gSyslog     cp_5g    bip_interface_mirroring  # gnb custom filters for DCAP
@{bts_custom_filter}        immediateSnapshot    scf    ipCapture                # BTS custom filters for DCAP
@{collection_timing}        Immediate       TraceEnd                             # Snapshot collet option for DCAP
${Default_DCAP_duration}    10                                                   # DCAP log duration
${dcap_log_timeout}         1200                                                 # Timeout for DCAP log collection
${connection}               Active_Session                                       # Alias name
${emil_profile}             ${emil_path}//profiles//5G                           # Emil profile path in UE PC machine
#${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${at_vendor}                TOPYOUNG                                             # Attenuator Vendor
${at_model}                 TAS_16T16_0_2G6_90_1S_DEJS                           # Attenuator Model
${UE_file}                  ta_ue_config.yaml                                    # UE Configuration file name
${wait_for_transfer}    True
@{direction}                ul                                                   # Direction for data
@{throughput_dl}    100
@{deviation_dl}     100
${FILTER}         dldata_pdschsendreq
@{COLUMN_NAME}    DlData_PdschGrant.pdschBundleSize
@{capabilities}				Legacy_1											# UE capability
@{data_transfer_protocol}       UDP
${voice_call_TC}=    VONR_Server_Call
${bip_log}        		    5GBipL2L1_filtering_off.pcap
${dist1_name}     MRBTS-1236/NRBTS-1236
${dist2_name}     MRBTS-1236/NRBTS-1236/NRPMRNL-1
@{udpcalltype}  UDP
${Repetation_count}     1
@{timeout}  180
@{UE_alias}      UE1
@{LTE_cell}     0
@{NR_cell}      3
${GNB_ASIK.ip}    10.63.48.81

*** Test Cases ***
CB0012255_NR_Latency_counter
    Get Software Version
#    Dcap Start Trace SA
    Lock cells  ${LTE_cell}
    Lock NR cells  ${NR_cell}
    Parameter value change    ${dist1_name}		 actLatencyPmCount		true
	Parameter value change    ${dist2_name}		 miNrHighRlcLatNrpmqap		5min
	Parameter value change    ${dist2_name}		 miNrPdcpLatNrpmqap		5min
	Parameter value change    ${dist2_name}		 miNrCellUtilization		5min
	Parameter value change    ${dist2_name}		 miNrLowRlcReport		5min
	Parameter value change    ${dist2_name}		 miNrPDCPCell		5min
	Parameter value change    ${dist2_name}		 miNrHighRlcLatNrpmqap		5min
	Parameter value change    ${dist2_name}		 miNrUeStatNrpmqap		5min
	Parameter value change    ${dist1_name}		 actMacUserThpt		true
	${val_1}	Data Transfer 	@{udpcalltype}
#	Run keyword and continue on failure     tput_validation     ${val_1}     ${val_2}
#   Run keyword and continue on failure     Should Be True    ${t_put}
#    Dcap Stop Trace and Get results SA
#    Run keyword and continue on failure     Unlock cells    ${LTE_cell}
#    Run keyword and continue on failure     Unlock NRcells  ${NR_cell}
    Run keyword and Continue on Failure     Counter value ROHC    M55350C00023
#	Run keyword and Continue on Failure     Counter value ROHC    M55350C00025
	Run keyword and Continue on Failure     Counter value ROHC    M55350C00027
	Run keyword and Continue on Failure     Counter value PLTDQ    M55159C00001
#	Run keyword and Continue on Failure     Counter value PLTDQ    M55159C00003
	Run keyword and Continue on Failure     Counter value PLTDQ    M55159C00005
	Run keyword and Continue on Failure     Counter value PLTDQ    M55159C00007
	Run keyword and Continue on Failure     Counter value NLRLC    M55310C00002
    Run keyword and Continue on Failure     Counter value HRLTQ    M55158C00003
	Run keyword and Continue on Failure     Counter value NCELA    M55308C00057
	Run keyword and Continue on Failure     Counter value NCELA    M55308C00071
	Run keyword and Continue on Failure     Counter value NCELA    M55308C00080
	Run keyword and Continue on Failure     Counter value UESPQ    M55356C00004
#	Set Suite Variable    ${Log_path}        ${OUTPUT_DIR}/DCAP_Logs
#   Set Suite Variable    ${source_paths}      ${Log_path}/Extracted
#    create directory         ${source_paths}
#    ${files}     OperatingSystem.List Files In Directory    ${Log_path}
#    FOR    ${zip}    IN    @{files}
#        interface.Extract
#                         ...  path=${Log_path}/${zip}
#                         ...  output_dir=${source_paths}
#                         ...  .=*/*/5g/bip/*.zip
#                         ...  **/bip/*.zip=BTS*_*_*.zip
#                         ...  **/bip/*.zip/*.zip=*.pcap.xz
#                         ...  **/bip/*.zip/*.zip/*.pcap.xz=*
#
#    END
#	${result}=    Run Process
#    ...    shell=True
#	Run Keyword     BIP analysis




*** Keywords ***
Start DCAP log collection
    dcap.connect_to  host=${host}   port=443    username=utfuser   password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    ...            credential_region_Id='DEFAULT_CREDENTIALS'
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g
    #@{bts}      Create List     ${bts1_info}
    ${output}    dcap.start_trace     duration=-1    bts=${bts1_info}
    ...    gnb_trace_profile=Full tracing profile - Sherpa
    ...    bts_trace_profile=Full tracing profile     wait_for_activation=True
    LogToConsole    ${output}
    ${output}=    Set Suite Variable    ${output}

Stop DCAP log collection
    ${trace_id} =   Get From Dictionary   ${output}   id
    Run Keyword And Continue On Failure    dcap.stop_trace    trace_id=${trace_id}
    LogToConsole    ${trace_id}
#    Sleep   300s
    ${dcap_dirname}    dcap.get_results    result_id=${trace_id}    target_dir=/home/ute/logs    timeout=2000
    LogToConsole    ${dcap_dirname}
    ${dcap_dirname}    Set Test Variable    ${dcap_dirname}

Counter value ROHC
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}   Run keyword     Get Dictionary Values
    ...         ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['PDCPC']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}

Counter value NLRLC
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}   Run keyword     Get Dictionary Values
    ...         ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NLRLC']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}

Counter value UESPQ
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}   Run keyword     Get Dictionary Values
    ...         ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NRPMQAP-1']['UESPQ']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}


Counter value HRLTQ
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}   Run keyword     Get Dictionary Values
    ...         ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NRPMQAP-1']['HRLTQ']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}


Counter value NCELA
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}   Run keyword     Get Dictionary Values
    ...         ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NCELA']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}



Counter value PLTDQ
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}   Run keyword     Get Dictionary Values
    ...         ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NRPMQAP-1']['PDLTQ']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}

Data Transfer
    [Arguments]
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction}
	Log to console    \nWaiting for data transfer
    sleep    100
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    &{val_1}    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
    [Return]	${val_1}

BIP analysis
   Run Process     command=mergecap ${OUTPUT_DIR}/*mirroring* -w ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap    shell=True
    Copy Files      ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap  ${OUTPUT_DIR}/BIP
   Get BIP csv file
    ${value}    verify_Biplog    ${BIP_CSV_LOG}    ${COLUMN_NAME}   ${Repetation_count}
    Run keyword and continue on failure    Should be True    ${value}

Get BIP csv file
    Set Suite Variable    ${BIP_CSV_LOG}    ${OUTPUT_DIR}/BIP//bip_log.csv
    OperatingSystem.Run   sudo rm -rf /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/mcshark-*buster.so
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${bip_log}    ${BIP_CSV_LOG}    ${FILTER}    ${COLUMN_NAME}
    ${csv_content}    Get File    ${BIP_CSV_LOG}

Get Software Version
    ${coam_connection}    coam.Connect To    bts_host=${GNB_ASIK.ip}
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}    #5G21B_GNB_0000_000800_004084_0oeo9
    ${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    Set Suite Variable    ${ENB_BUILD}
    Run Keyword If    "${ENB_BUILD}"=="SBTS"    Get Software Version On Common Package
    ...    ELSE    Get Software Version On 5G Pacakge
    [Teardown]    coam.Teardown    ${coam_connection}

Get Software Version On 5G Pacakge
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | 0.800 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | 0.800.779 | total sw version |
    ...    | ${SW_BRANCH} | 5G20B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==0000
    ${version_0}    String.Get Regexp Matches    ${sw_list[2]}    [1-9]+[0-9]*    #return a list
    ${version_1}    String.Get Regexp Matches    ${sw_list[3]}    [1-9]+[0-9]*
    ${version_2}    String.Get Regexp Matches    ${sw_list[4]}    [1-9]+[0-9]*
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    0.${version_1[0]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${version_0[0]}.${version_1[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}
    ...    0.${version_1[0]}.${version_2[0]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${version_0[0]}.${version_1[0]}.${version_2[0]}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

Get Software Version On Common Package
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    SBTS00
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${sw_list[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}
    ...    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

