*** Settings ***
Documentation
...    author: y63li
...    contact: ying.15.li@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : CB006667

Library           BuiltIn
Library           OperatingSystem
Library           Collections
Library           String
Library           taf.pdu
Library           Process
Library           taf.config.scf    WITH NAME    scf
Library           get_pm_counter.py
Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           sigspark.SigSpark    WITH NAME    spark
Library           get_pm_counter.py
Library           taf.rfrl.common_resources.python.TTI_Trace    WITH NAME    tti
Library           taf.rfrl.common_resources.python.stream_manager
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/get_bts_info.py  WITH NAME    lib
Library           taf.hw.rf_attenuator    WITH NAME    att
Resource          common_log_analyzer.robot
Resource          common_lib_variable.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${DU_OAM_IP}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${bts_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${bts_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${host_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}    ${tl.test_pc.default_ssh_connection_details.username}
${host_password}    ${tl.test_pc.default_ssh_connection_details.password}
#${fsp_hostnames}    fsp-1a           #for 903
${fsp_hostnames}    asp-1b             #for 904
${tl_scf_dir_path}     ${commissionings_path}/HGZ/7_5_UTE5G402T904/CB006667/trunk
${5MHz_5G}     5MHz_5G.xml
${10MHz_5G}    10MHz_5G.xml
${15MHz_5G}    15MHz_5G.xml
${20MHz_5G}    20MHz_5G.xml
${30MHz_5G}    30MHz_5G.xml
${5MHz_5G_max_cell}      5MHz_5G_max_cell.xml
${10MHz_5G_max_cell}     10MHz_5G_max_cell.xml
${15MHz_5G_max_cell}     15MHz_5G_max_cell.xml
${20MHz_5G_max_cell}     20MHz_5G_max_cell.xml
${20MHz_5G_DSS}    20MHz_5G_DSS.xml
${20MHz_4G_DSS}    20MHz_4G_DSS.xml
${10MHz_5G_DSS}     10MHz_5G_DSS.xml
${10MHz_4G_DSS}     10MHz_4G_DSS.xml
${10MHz_5G_DSS_max_cell}     10MHz_5G_DSS_max_cell.xml
${15MHz_5G_DSS_max_cell}     15MHz_5G_DSS_max_cell.xml
${15MHz_4G_DSS}     15MHz_4G_DSS.xml
${scf_name}        scf_CB006667.xml
${tmp_log_dir}     /home/ute/log
${testline}        7_5_UTE5G402T904
###L3_call###
${UE_TYPE}          ${tl.ues[0].capabilities[-1]}
${data_tranfer}     20Mbits/sec
${ul_duration}     20
${dl_duration}     20
${dltp}     5
${ultp}     2
${NSA_UE_MODE}    NSA
${SA_UE_MODE}    SA
${NSA_attach_mode}    5G_NSA
${SA_attach_mode}    5G_SA
${NSA_nettype}    NSA
${SA_nettype}    SA+NSA
${apn_addr}    wap2.nokia.com
${GNB_COAM_ALIAS}        GNB_OAM
${SSH_FSP}    FSP Conn
${path}           /home/ute/log/
${cell1}    BTS/CELLS/NRCELL-1/NCELA
${cell2}    BTS/CELLS/NRCELL-2/NCELA


##PA##
${att_ipaddr}               ${tl.attenuator.ip_addr}
${att_ports_1}              ${5}
${att_ports_2}              ${6}
${att_ports_3}              ${7}
${att_ports_4}              ${8}
${att_ports_number}         ${5}
${att_api_port}             ${tl.attenuator.port}
${vendor}                   ${tl.attenuator.vendor}
${HBTE_max_value}           ${127}    ##no signal
@{att_value}                20    127   ##rank4  no signal



*** Keywords ***
#-----------Case----------------------#
Run CB006667_SA_Case
     [Arguments]  ${Patten}=non_DSS
     log to console      Run CB006667_Case
     Connect to DU via ssl
     Enable Counter collect
     #${actLteNrDss}    Get NIDD parameter value    class_name=NRBTS_A    pattern=actLteNrDss    connection=${GNB_COAM_ALIAS}
     run keyword if  '${Patten}'=='DSS'    Get parameter value of chBwDl and chBwUl for DSS
     ...    ELSE   Get parameter value of chBwDl and chBwUl
     Attach ${ue_num} SA UEs and Data Transfer
     Start Collect TTI log
     Stop ${ue_num} traffic and SA UEs Detach
#     Run keyword and continue on failure     Check target DL Per Slot Ue Numbers    tti_csv_dir=${path}
#     Run keyword and continue on failure     Check target UL Per Slot Ue Numbers    tti_csv_dir=${path}
#     Delete formated file in UTE
#     log to console      DL_PRB_check
#     @{Failed_DL_Slot_List}=    create list    Failed dl SFN and Slot list:
#     @{Failed_UL_Slot_List}=    create list    Failed ul SFN and Slot list:
#     Run keyword and continue on failure     Check numOfPrb Numbers of In Target File    tti_csv_dir=${path}    file_filter=${dl_filter}
#     ...    Expected_PRB=${Expected_DL_PRB}    csv_filter=_dl_    failed_slot_list=${Failed_DL_Slot_List}
#     log many    @{Failed_DL_Slot_List}
#     log to console      UL_PRB_check
#     Run keyword and continue on failure     Check numOfPrb Numbers of In Target File    tti_csv_dir=${path}    file_filter=${ul_filter}
#    ...    Expected_PRB=${Expected_UL_PRB}    csv_filter=_ul_    failed_slot_list=${Failed_UL_Slot_List}
#     log many    @{Failed_UL_Slot_List}
     Run Keyword if     '${Patten}'=='DSS'    Check Scheduled expected UEs per Slot    Cell_path=${cell1}
     ...    ELSE   Check Scheduled expected UEs per Slot    Cell_path=${cell2}


Run CB006667_NSA_Case
     [Arguments]  ${Patten}=non_DSS
     log to console      Run CB006667_Case
     Connect to DU via ssl
     Enable Counter collect
     #${actLteNrDss}    Get NIDD parameter value    class_name=NRBTS_A    pattern=actLteNrDss    connection=${GNB_COAM_ALIAS}
     run keyword if  '${Patten}'=='DSS'    Get parameter value of chBwDl and chBwUl for DSS
     ...    ELSE   Get parameter value of chBwDl and chBwUl
     Attach ${ue_num} NSA UEs and Data Transfer
     Start Collect TTI log
     Stop ${ue_num} traffic and NSA UEs Detach
     Run keyword and continue on failure     Check target DL Per Slot Ue Numbers    tti_csv_dir=${path}
     Run keyword and continue on failure     Check target UL Per Slot Ue Numbers    tti_csv_dir=${path}
     Delete formated file in UTE
     log to console      DL_PRB_check
     @{Failed_DL_Slot_List}=    create list    Failed dl SFN and Slot list:
     @{Failed_UL_Slot_List}=    create list    Failed ul SFN and Slot list:
     Run keyword and continue on failure     Check numOfPrb Numbers of In Target File    tti_csv_dir=${path}    file_filter=${dl_filter}
     ...    Expected_PRB=${Expected_DL_PRB}    csv_filter=_dl_    failed_slot_list=${Failed_DL_Slot_List}
     log many    @{Failed_DL_Slot_List}
     log to console      UL_PRB_check
     Run keyword and continue on failure     Check numOfPrb Numbers of In Target File    tti_csv_dir=${path}    file_filter=${ul_filter}
    ...    Expected_PRB=${Expected_UL_PRB}    csv_filter=_ul_    failed_slot_list=${Failed_UL_Slot_List}
     log many    @{Failed_UL_Slot_List}
     Run Keyword if     '${Patten}'=='DSS'    Check Scheduled expected UEs per Slot    Cell_path=${cell1}
     ...    ELSE   Check Scheduled expected UEs per Slot    Cell_path=${cell2}

#---------Common keyword--------------#
CB006667_Common Suite Setup for COAM
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    CB006667_COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}
    Admin Get MrbtsId And NrbtsId
    Run Keyword And Ignore Error    Delete CSV file in UTE

CB006667_Common Suite Teardown for COAM
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

CB006667_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to DU via ssl
    ${sw_version} =     admin_cli.get_sw_version    connection=${GNB_COAM_ALIAS}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Set Suite Variable    ${sw_version}
    Create directory    ${SUITE_LOG_PATH}

CB006667_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    CB006667_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Connect to DU via ssl
    [Arguments]  ${connection}=${GNB_COAM_ALIAS}    ${bts_host}=${DU_OAM_IP}
    ...    ${username}=${WEBUI_USER}
    ...    ${password}=${WEBUI_PASSWORD}
    admin_cli.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    admin_cli.teardown    connection=${GNB_COAM_ALIAS}

Admin Get MrbtsId And NrbtsId
    run keyword and ignore error    admin_cli.Teardown
    admin_cli.get_current_scf_file    local_dir_path=${epc_log_path}    file_name=${scf_name}    connection=${GNB_COAM_ALIAS}
    ${commission_file}    set variable    ${epc_log_path}/${scf_name}
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    ${BTS_NAME}   lib.Get_BTS_name    scf_path=${commission_file}
    Set Suite Variable     ${mrbtsId}
    Set Suite Variable     ${nrbtsId}
    Set Suite Variable     ${dist_name}    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Set Suite Variable     ${commission_file}
    Set Suite Variable     ${BTS_NAME}

Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=${GNB_COAM_ALIAS}
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Check X2 Status
    Log To Console     \n *** Check X2 Status
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${X2linkstatus}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-0
    ...    filter_param=X2C link status
    Should be equal    ${X2linkstatus}    available

Connect to cOAM as toor4nsn
    [Arguments]    ${alias}=${GNB_COAM_ALIAS}
    csn.Connect To    hostname=${DU_OAM_IP}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${alias}

eNB SCF Commission
    Log To Console     \n *** eNB SCF Commission
    [Arguments]  ${scf_file_path}    ${connection}=enblte    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    run keyword and continue on failure    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    BuiltIn.Log    Commission with scf file via rest API successfully.
    [Return]  ${result}

#-------------------------------Case_setup_and_teardown-------------------------------#
Case Setup
    Log To Console    \n *** Case Setup
    [Arguments]    ${chbw}
    Connect to DU via ssl
    #COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}/CB006667_${chbw}M.xml    timeout=500    is_pdl_checking_needed=${False}
    wait until keyword succeeds    30min    3min     Precondition: All cells can be on air
    #cell2
    Adjust HBTE ATT Value  value_1=${${att_value[0]}}  value_2=${${att_value[0]}}  value_3=${${att_value[1]}}  value_4=${${att_value[1]}}
    #wait Until Keyword Succeeds    5min    1min    Check X2 status
    Delete CSV file in UTE


Case Setup for DSS
    Log To Console    \n *** Case Setup for DSS
    [Arguments]    ${chbw}
    Connect to DU via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}/CB006667_${chbw}M.xml
    ...    timeout=500    is_pdl_checking_needed=${False}
	#Connect to eNB via ssl
    #eNB SCF Commission    scf_file_path=${tl_scf_dir_path}/CB006667_${chbw}M_eNB.xml    timeout=500    is_pdl_checking_needed=${False}
    wait until keyword succeeds    30min    3min     Precondition: All cells can be on air
    #wait Until Keyword Succeeds    5min    1min    Check X2 status
    #cell1
    Adjust HBTE ATT Value  value_1=${${att_value[1]}}  value_2=${${att_value[1]}}  value_3=${${att_value[0]}}  value_4=${${att_value[0]}}
    Delete CSV file in UTE

Case Teardown
    Log To Console    \n *** Case Teardown
    #Run keyword and ignore error     Stop ${ue_num} traffic and SA UEs Detach
    Compress the logs

Get parameter value of chBwDl and chBwUl
    log to Console    \n *** Get parameter value of chBwDl and chBwUl    console=yes
    ${chBwDl_list}    Create Dictionary    Band5=25    Band10=52
    ...    Band15=79    Band20=106
    ${chBwUl_list}    Create Dictionary    Band5=19    Band10=46
    ...    Band15=73    Band20=100
    ${chBwDl_UE_list}    Create Dictionary    Band5=8    Band10=8
    ...    Band15=10    Band20=12
    ${chBwUl_UE_list}    Create Dictionary    Band5=5    Band10=8
    ...    Band15=10    Band20=10
    ${chBwDl_UE_list_max_cell}    Create Dictionary    Band5=6    Band10=6
    ...    Band15=6    Band20=6
    ${chBwUl_UE_list_max_cell}    Create Dictionary    Band5=5    Band10=5
    ...    Band15=5    Band20=5
    ${ue_num}    Create Dictionary    Band5=10    Band10=10
    ...    Band15=12    Band20=12    Band30=12
    Connect to DU via ssl
    ${ChBwDl}    Get NIDD parameter value    class_name=NRCELL_FDD_A    pattern=chBwDl    connection=${GNB_COAM_ALIAS}
    ${ChBwUl}    Get NIDD parameter value    class_name=NRCELL_FDD_A    pattern=chBwUl    connection=${GNB_COAM_ALIAS}
    ${fddNrCellConfigTradeoff}    Get NIDD parameter value   class_name=BBMOD_A
    ...    pattern=fddNrCellConfigTradeoff    connection=${GNB_COAM_ALIAS}
    ${ChBwDl}    Fetch From Left     ${ChBwDl}    MHz
    ${ChBwUl}    Fetch From Left     ${ChBwUl}    MHz
    ${Expected_DL_PRB}=  Get From Dictionary    ${chBwDl_list}    Band${ChBwDl}
    ${Expected_UL_PRB}=  Get From Dictionary    ${chBwUl_list}    Band${ChBwUl}
    ${Expected_DL_UE_num}=  Run keyword if   '${fddNrCellConfigTradeoff}'=='max cells'
    ...    Get From Dictionary    ${chBwDl_UE_list_max_cell}   Band${ChBwDl}
    ...    ELSE    Get From Dictionary    ${chBwDl_UE_list}    Band${ChBwDl}
    ${Expected_UL_UE_num}=  Run keyword if   '${fddNrCellConfigTradeoff}'=='max cells'
    ...    Get From Dictionary    ${chBwUl_UE_list_max_cell}   Band${ChBwUl}
    ...    ELSE    Get From Dictionary    ${chBwUl_UE_list}    Band${ChBwUl}
    ${ue_num}    Get From Dictionary    ${ue_num}    Band${ChBwUl}
    Set Suite Variable    ${Expected_DL_PRB}
    Set Suite Variable    ${Expected_UL_PRB}
    Set Suite Variable    ${Expected_DL_UE_num}
    Set Suite Variable    ${Expected_UL_UE_num}
    Set Suite Variable    ${ue_num}
    [Teardown]     admin_cli.teardown    connection=${GNB_COAM_ALIAS}

Get parameter value of chBwDl and chBwUl for DSS
    log to Console    \n *** Get parameter value of chBwDl and chBwUl for DSS   console=yes
    ${chBwDl_list_DSS}    Create Dictionary    Band10=52
    ...    Band15=79    Band20=106
    ${chBwUl_list_DSS}    Create Dictionary    Band10=28
    ...    Band15=48    Band20=68
    ${chBwDl_UE_list_DSS}    Create Dictionary    Band10=4
    ...    Band15=8    Band20=8
    ${chBwUl_UE_list_DSS}    Create Dictionary    Band10=4
    ...    Band15=5    Band20=8
    ${chBwDl_UE_list_DSS_max_cell}    Create Dictionary    Band10=4
    ...    Band15=6    Band20=6
    ${chBwUl_UE_list_DSS_max_cell}    Create Dictionary    Band10=4
    ...    Band15=5    Band20=5
    ${ue_num}    Create Dictionary    Band10=10
    ...    Band15=12    Band20=12    Band30=12
    Connect to DU via ssl
    ${ChBwDl}    Get NIDD parameter value    class_name=NRCELL_FDD_A    pattern=chBwDl    connection=${GNB_COAM_ALIAS}
    ${ChBwUl}    Get NIDD parameter value    class_name=NRCELL_FDD_A    pattern=chBwUl    connection=${GNB_COAM_ALIAS}
    ${fddNrCellConfigTradeoff}    Get NIDD parameter value   class_name=BBMOD_A
    ...    pattern=fddNrCellConfigTradeoff    connection=${GNB_COAM_ALIAS}
    ${ChBwDl}    Fetch From Left     ${ChBwDl}    MHz
    ${ChBwUl}    Fetch From Left     ${ChBwUl}    MHz
    ${Expected_DL_PRB}=  Get From Dictionary    ${chBwDl_list_DSS}    Band${ChBwDl}
    ${Expected_UL_PRB}=  Get From Dictionary    ${chBwUl_list_DSS}    Band${ChBwDl}
    ${Expected_DL_UE_num}=  Run keyword if   '${fddNrCellConfigTradeoff}'=='max cells'
    ...    Get From Dictionary    ${chBwDl_UE_list_DSS_max_cell}   Band${ChBwDl}
    ...    ELSE    Get From Dictionary    ${chBwDl_UE_list_DSS}    Band${ChBwDl}
    ${Expected_UL_UE_num}=  Run keyword if   '${fddNrCellConfigTradeoff}'=='max cells'
    ...    Get From Dictionary    ${chBwUl_UE_list_DSS_max_cell}   Band${ChBwUl}
    ...    ELSE    Get From Dictionary    ${chBwUl_UE_list_DSS}    Band${ChBwUl}
    ${ue_num}    Get From Dictionary    ${ue_num}    Band${ChBwUl}
    Set Suite Variable    ${Expected_DL_PRB}
    Set Suite Variable    ${Expected_UL_PRB}
    Set Suite Variable    ${Expected_DL_UE_num}
    Set Suite Variable    ${Expected_UL_UE_num}
    Set Suite Variable    ${ue_num}
    [Teardown]     admin_cli.teardown    connection=${GNB_COAM_ALIAS}

Delete formated file in UTE
     csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute
     csn.send_command    command=rm -f ${path}/*SchedData.csv     connection=ute
     BuiltIn.Sleep   1s
     [Teardown]    csn.Disconnect    connection=ute

Delete CSV file in UTE
     csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute
     csn.send_command    command=rm -f ${path}/*.csv ${path}/*.tar.gz     connection=ute
     BuiltIn.Sleep   1s
     [Teardown]    csn.Disconnect    connection=ute

Compress the logs
    Log    \nCompress the logs    console=yes
    ${time}    Get current date    result_format=%Y%m%d%H%M%S
    csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute
    csn.send_command    command=tar -czvf ${path}/${time}.tar.gz ${path}/*.csv    connection=ute
    csn.send_command    command=rm -f ${path}/*.csv     connection=ute
    BuiltIn.Sleep   1s
    [Teardown]    csn.Disconnect    connection=ute
#--------------------------------UE operation----------------------------#

Attach ${ue_num} NSA UEs and Data Transfer
    Log    \nAttach ${ue_num} NSA UEs and Data Transfer    console=yes
    Attach Multi-UEs and Data Transfer    ue_num=${ue_num}    attach_mode=${NSA_attach_mode}   ue_mode=${NSA_UE_MODE}
    ...    nettpye=${NSA_nettype}    apn_address=${apn_addr}

Attach ${ue_num} SA UEs and Data Transfer
    Log    \nAttach ${ue_num} SA UEs and Data Transfer   console=yes
    Attach Multi-UEs and Data Transfer    ue_num=${ue_num}    attach_mode=${SA_attach_mode}   ue_mode=${SA_UE_MODE}
    ...    nettpye=${SA_nettype}    apn_address=${apn_addr}

Stop ${ue_num} traffic and NSA UEs Detach
    Log    \nStop ${ue_num} traffic and NSA UEs Detach    console=yes
    Run keyword and ignore error     stop traffic and ue detach    ue_num=${ue_num}     ue_mode=${NSA_UE_MODE}
	...    apn_address=${apn_addr}

Stop ${ue_num} traffic and SA UEs Detach
    Log    \nStop ${ue_num} traffic and SA UEs Detach    console=yes
    Run keyword and ignore error     stop traffic and ue detach    ue_num=${ue_num}     ue_mode=${SA_UE_MODE}
	...    apn_address=${apn_addr}

Attach Multi-UEs and Data Transfer
    [Arguments]    ${ue_num}    ${attach_mode}    ${ue_mode}    ${nettpye}   ${apn_address}
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console       Prepare ue${i}
       Run keyword and ignore error     power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}
       log to console       configure UE${i} mode
       Run keyword and ignore error      spark.Config 5G Deployment    nettype=${nettpye}    ue_alias=UE_${i}
       log to console       Attach UE${i} and Verify Status
       Run keyword and ignore error     Attach UE and verify Status  ue_index=${i}
        ...    attach_mode=${attach_mode}
       sleep    3s
       Run keyword and ignore error     Start and Check Traffic    ue_index=${i}
        ...     attach_mode=${attach_mode}    ue_mode=${ue_mode}    nettpye=${nettpye}   apn_address=${apn_address}
       sleep    10s
    END

Attach UE and Verify Status
    log to console       UE attach
    [Arguments]    ${attach_mode}   ${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}   attach_mode=${attach_mode}
    log to console       UE attach verify
    sleep   5s
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False

Start and Check Traffic
    log to console       Start Traffic
    [Arguments]    ${ue_index}    ${attach_mode}    ${ue_mode}    ${nettpye}   ${apn_address}
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul      apn_address=${apn_address}
    ...    throughput=${data_tranfer}    duration=4000    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
    sleep    3s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        ...   throughput=${data_tranfer}    duration=4000   ue_type=${UE_TYPE}    ue_mode=${ue_mode}
    sleep    3s
    log to console       Check Traffic
    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=${dltp}    ue_index=${ue_index}
#    power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=${ultp}    ue_index=${ue_index}

stop traffic and ue detach
    [Arguments]    ${ue_num}    ${ue_mode}   ${apn_address}
    log to console     Stop traffic    console = yes
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console      Stop traffic    console = yes
       Run keyword and ignore error     power_ue.Stop traffic    direction=dl    ue_index=${i}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
       Run keyword and ignore error     power_ue.Stop traffic    direction=ul    ue_index=${i}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
       log to console      UE Detach    console = yes
       Run keyword and ignore error     power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${i}
    END

#------------------------TTI_Capture_and_Checkpoint-------------------------------#
Start Collect TTI log
    log to console    start collect tti logs
    Connect to DU with OAM IP
    Connect to FSP with FSP hostname
    Start TTI trace log capturing     connection_for_abil=${SSH_FSP}
    Sleep    2s
    Stop TTI trace log capturing     connection_for_abil=${SSH_FSP}
    log     TS_CASE_LOG_PATH is ${TS_CASE_LOG_PATH}
    Convert TTI trace log and download combined csv logs to test pc
    ...    is_need_to_close_connection=${True}    connection_for_abil=${SSH_FSP}
    ...    connection_for_asik=${GNB_COAM_ALIAS}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${GNB_COAM_ALIAS}

Connect to DU with OAM IP
    csn.Connect to    hostname=${DU_OAM_IP}
    ...               username=${bts_username}
    ...               password=${bts_password}
    ...               alias=${GNB_COAM_ALIAS}

Disconnect ssh to DU
	  csn.disconnect    connection=${GNB_COAM_ALIAS}

Connect to FSP with FSP hostname
#    csn.send command    command=cat /etc/hosts |grep -E "fsp|asp" |grep icom   connection=${GNB_COAM_ALIAS}
#    ${tmp_output} =    csn.Read Output    connection=${GNB_COAM_ALIAS}
#    ${tmp_output}=     Fetch From Left   ${tmp_output}    \n
#    ${tmp_output}=     Fetch From Right   ${tmp_output}    icom
#    ${fsp_hostnames}   Strip String    ${tmp_output}
    csn.Connect to    hostname=${fsp_hostnames}
    ...               username=${bts_username}
    ...               password=${bts_password}
    ...               proxy=${GNB_COAM_ALIAS}
    ...               alias=${SSH_FSP}

Configure actAperCsi to true
    Log    \nConfigure prachConfigurationIndex to true    console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    parameter=actAperCsi
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS}

Configure actAperCsi to false
    Log    \nConfigure actAperCsi to false   console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    parameter=actAperCsi
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS}
#-------------------------Check_PRB----------------------------------#
Verify numOfPrb Numbers of In Target File
    [Arguments]    ${tti_csv_name}   ${Expected_PRB}    ${file_filter}    ${failed_slot_list}
    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
    ${full_patt}    Set Variable    ${file_filter},(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:${file_filter},(?P=sfn),(?P=slot).+\\n)*
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    @{result_list}    create list
    Remove From List    ${matches}    0
    Remove From List    ${matches}    -1
    FOR    ${item}    IN    @{matches}
        @{FdSchedData_list}    Get PRB list in one slot    FdSchedData_in_one_slot=${item}     file_filter=${file_filter}
        ${FdSchedData}    Split String     ${FdSchedData_list[0]}    ,
        Check the sum of PRB in one slot    PRB_list=@{PRB_list}
        ${SFN}    set variable  ${FdSchedData[1]}
        ${Slot}   set variable  ${FdSchedData[2]}
        ${Odd_SFN}    evaluate    int(math.fmod(int(${SFN}),2))    modules=math
        ${status}  run keyword and return status
        ...    Run Keyword If  ${Odd_SFN}==${1} and ${Slot}==${1} and '${file_filter}'=='${ul_filter}'
        ...    evaluate    ${Min_Expected_PRB_RA_Slot}<=${PRB_SUM}<=${Max_Expected_PRB_RA_Slot}
        ...    ELSE    Run keyword and continue on failure     Should Be Equal As Integers    ${PRB_SUM}    ${Expected_PRB}
        run keyword if  '${status}'=='False'    append to list  ${failed_slot_list}    ${SFN},${Slot},total PRB=${PRB_SUM};
        log to console     the Prb sum is ${PRB_SUM}
        Append To List    ${result_list}    ${status}
        ${check_result}     run keyword and return status    Collections.List Should Contain Value    ${result_list}   ${True}
    END
    [Return]    ${check_result}

Check numOfPrb Numbers of In Target File
    [Arguments]    ${tti_csv_dir}    ${file_filter}     ${Expected_PRB}    ${csv_filter}    ${failed_slot_list}
    ${out_file_name}    Set Variable    ${tti_csv_dir}${file_filter}.csv
    ${file_exist}   Run Keyword and Return Status   File Should Exist   ${out_file_name}
    Run Keyword If   ${file_exist}   remove file    ${out_file_name}
    ${result}    Set Variable    ${False}
    @{status_list}    create list
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *${csv_filter}*.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
        Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${file_filter}
        ${result}=    Verify numOfPrb Numbers of In Target File    tti_csv_name=${out_file_name}    Expected_PRB=${Expected_PRB}
        ...    file_filter=${file_filter}    failed_slot_list=${failed_slot_list}
        Append To List    ${status_list}    ${result}
    END
    Collections.List Should Contain Value    ${status_list}   ${True}

Check the sum of PRB in one slot
   [Arguments]    ${PRB_list}
   Set Suite Variable  ${PRB_SUM}    ${0}
   FOR    ${item}    IN    @{PRB_list}
   ${PRB_SUM}    Evaluate    ${PRB_SUM}+${item}
   Set Suite Variable    ${PRB_SUM}
   END

Get PRB list in one slot
    [Arguments]    ${FdSchedData_in_one_slot}    ${file_filter}
	 Set Suite Variable    @{PRB_list}    @{EMPTY}
    @{FdSchedData_list} =    Split String     ${FdSchedData_in_one_slot}    \n
    Remove Values From List    ${FdSchedData_list}    ${EMPTY}
    FOR    ${FdSchedData}    IN    @{FdSchedData_list}
    @{FdSchedData} =    Split String     ${FdSchedData}    ,
    Run keyword if    '${file_filter}'=='${dl_filter}'    Append To List    ${PRB_list}    ${FdSchedData[20]}
  	Run keyword if    '${file_filter}'=='${ul_filter}'   Append To List    ${PRB_list}    ${FdSchedData[20]}
    ${PRB_list}    Convert To List    ${PRB_list}
    Set Suite Variable    @{PRB_list}
	END
	[return]  @{FdSchedData_list}

#-------------------------Check_UE_Num----------------------------------#
Check target DL Per Slot Ue Numbers
    BuiltIn.Log To Console     Check target DL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}
    ${filters}    Set Variable    ${dl_filter}
    ${out_file_name}    Set Variable    ${tti_csv_dir}/${dl_filter}.csv
    ${result}    Set Variable    ${False}
    @{status_list}    create list
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    TA_Combine_dl*.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify DL Per Slot Ue Numbers In Target File    ${out_file_name}
    Append To List    ${status_list}    ${result}
    END
    Collections.List Should Contain Value    ${status_list}   ${True}

Verify DL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}
    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
    ${full_patt}    Set Variable    dlFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:dlFdSchedData,(?P=sfn),(?P=slot).+\\n)*
    ${rnti_patt}    Set Variable    dlFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    @{result_list}    create list
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be True    ${count}>=${4}
    log to console   DL Scheduled UEs is ${count}.
    Append To List    ${result_list}    ${check_result}
    ${status}     run keyword and return status    Collections.List Should Contain Value    ${result_list}   ${True}
    END
    [Return]    ${status}

Check target UL Per Slot Ue Numbers
    BuiltIn.Log To Console      Check target UL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}
    ${filters}    Set Variable    ${ul_filter}
    ${out_file_name}    Set Variable    ${tti_csv_dir}/${ul_filter}.csv
    ${result}    Set Variable    ${False}
    @{status_list}    create list
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    TA_Combine_ul*.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify UL Per Slot Ue Numbers In Target File    ${out_file_name}
    Append To List    ${status_list}    ${result}
    END
    Collections.List Should Contain Value    ${status_list}   ${True}

Verify UL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}
    [Documentation]    tti csv file contains only ulFdSchedData msg, please refer to tti_convert.py for more infos
    ${full_patt}    Set Variable    ulFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:ulFdSchedData,(?P=sfn),(?P=slot).+\\n)*
    ${rnti_patt}    Set Variable    ulFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    @{result_list}    create list
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    #${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${Expected_UL_UE_num}
    ${check_result}    Run Keyword And Return Status    Should Be True    ${count}>=${4}
    log to console   UL Scheduled UEs is ${count}.
    Append To List    ${result_list}    ${check_result}
    ${status}     run keyword and return status    Collections.List Should Contain Value    ${result_list}   ${True}
    END
    [Return]    ${status}

#-------------------------Check_CSI----------------------------------#
#Check target DL Report CSI
#    BuiltIn.Log To Console      Check target DL Report CSI
#    [Arguments]    ${tti_csv_dir}
#    ${filters}    Set Variable    ${csi_filter}
#    ${out_file_name}    Set Variable    ${tti_csv_dir}${csi_filter}.csv
#    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    TA_Combine_dl*.csv    ${True}
#    FOR    ${file}    IN    @{tti_csv_files}
#    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
#    ${result}    Verify DL CSI Report In Target File    ${out_file_name}
#    END
#
#Verify DL CSI Report In Target File
#    [Arguments]    ${tti_csv_name}
#    [Documentation]    tti csv file contains only csiSrReportData msg, please refer to tti_convert.py for more infos
#    ${full_patt}    Set Variable    ${csi_filter},(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:${csi_filter},(?P=sfn),(?P=slot).+\\n)*
#    ${csi_patt}    Set Variable     APERIODIC_CSI
#    ${content}    OperatingSystem.Get File    ${tti_csv_name}
#    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
#    ${csi_data}    String.Get Regexp Matches    str(${matches})    ${csi_patt}
#    ${count}    Evaluate    len(${csi_data})
#    ${speriodic_csi}    evaluate    int(math.fmod(int(${count}),${ue_num}))    modules=math
#    Run keyword and continue on failure     Should Be Equal As Integers    ${speriodic_csi}    0

###------------------------------Counter_Check-------------------###
Get BTS Counters from webUI
    [Arguments]    ${counter_id}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    COAM selenium logout
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}

Enable Counter collect
    Log    \nEnable Counter collect    console=yes
    admin_cli.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1
    ...    parameter=reportingIntervalPm
    ...    value=5min
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    ...    connection=${GNB_COAM_ALIAS}

Check Scheduled expected UEs per Slot
    [Arguments]    ${Cell_path}
    Log    \nCheck Scheduled target UEs per Slot   console=yes
#    sleep    5min
    run keyword and continue on failure   Check PM counter Result
    ...   full_path=${Cell_path}    counter_id=M55308C17002    Scheduled_UE_num=${Expected_DL_UE_num}
    run keyword and continue on failure   Check PM counter Result
    ...   full_path=${Cell_path}    counter_id=M55308C18002    Scheduled_UE_num=${Expected_UL_UE_num}

Check PM counter Result
    [Arguments]    ${counter_id}    ${full_path}    ${Scheduled_UE_num}
    ${counter_result}    Check PM counter    ${counter_id}    ${full_path}
    List Should Contain Value    ${counter_result}    ${${Scheduled_UE_num}}

Check PM counter
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to DU via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=${GNB_COAM_ALIAS}
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    AdminCli disconnection and Test teardown

##PA##
Adjust HBTE ATT Value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port_1}=${att_ports_1}    ${att_port_2}=${att_ports_2}
    ...    ${att_port_3}=${att_ports_3}    ${att_port_4}=${att_ports_4}    ${att_connection_port}=${att_ports_number}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port_1}    value=${value_1}
    att.set_attenuation     port=${att_port_2}    value=${value_2}
    att.set_attenuation     port=${att_port_3}    value=${value_3}
    att.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port_1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port_2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port_3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port_4}
    should be equal    ${value_port4}    ${value_4}

Adjust HBTE One ATT Value
     [Arguments]      ${value}    ${att_port}=${att_ports_1}    ${att_connection_port}=${att_ports_number}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    attenuation_port_numbers=${att_connection_port}
    ...    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port}    value=${value}
    ${value_port}    att.read_attenuation    port=${att_port}
    should be equal    ${value_port}    ${value}
