*** Settings ***
Documentation    This is a robot framework library comprising keywords that are used in the MORAN testing related TC implementations of CSV ULM.
...    | Team:         |  CSV Ulm                                     |
...    | Contact:      |  I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com    |
...    | Description:  |  Common Keywords used in MORAN testcases     |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    String
Library    Collections
Library    OperatingSystem
Library    Process

Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.ue
Library    ute_tshark
Library  XML  use_lxml=True

Library    ../../../../../Ulm/resources/Common/python/reporting.py   WITH NAME    reporting
Resource   ../../../../../Ulm/resources/Common/git_handling.robot
Resource   ../../../../../Ulm/resources/Common/gnb.robot
Resource   ../../../../../Ulm/resources/Common/pmcounters.robot
Resource   ../../../../../Ulm/resources/Common/reporting.robot
Resource   ../../../../../Ulm/resources/Common/tcpdump.robot
Resource   ../../../../../Ulm/resources/Common/testline.robot
Resource   ../../../../../Ulm/resources/Common/ute_workarounds.robot
Resource   ../../../../../Ulm/resources/Common/wts_ue.robot
Resource   ../../../../../Ulm/SyVe/resources/attenuator.robot
Resource   ../../../../../Ulm/SyVe/resources/syve_testline.robot
Resource   ../../../../../Ulm/SyVe/resources/UEs_handler.robot

Library    ../../../../../Ulm/SyVe/CSV/libraries/common_tools.py
Library    ../../../../../Ulm/SyVe/CSV/libraries/verification_tools.py
Resource   ../../../../../Ulm/SyVe/CSV/resources/tracing_keywords.robot
Resource   ../../../../../Ulm/SyVe/CSV/resources/BTS_Cells_Handler.robot
#Resource   ../../../../../Ulm/SyVe/CB006139/CB006139_verification.robot


*** Variables ***
${WITH_PM_COUNTERS}               ${TRUE}    # [INFO] ${TRUE} or ${FALSE}
${consolewidth}=                140
${barwidth}=                    130
${REBOOT_UE}=                   ${True}


*** Keywords ***
MORAN VoIP call
    [Documentation]   This keyword implements the execution of a VoIP call in a MORAN site with either LTE (VoLTE) or NR (VoNR) as RAT in use.
    [Arguments]   ${target_mno}=DTAG         ${target_rat}=LTE         ${call_type}=MO          ${MO_UE_id}=${1}        ${MT_UE_id}=${2}
    ...           ${preferred_net_mode}=LTE  ${technology_in_use}=FDD  ${call_duration}=1 min   ${answer_timeout}=10s

    ${ru_idx}=    BTS_Cells_Handler.Set Active NRRU As Variable Based On Technology In Use    technology_in_use=${technology_in_use}
    ${long_log_string}=   builtin.Catenate   Choosing RMOD with index ${ru_idx}, i.e. '${tl.gnbs[${0}].dus[${0}].rus[${ru_idx}].radio_type}'
    ...   with serial number '${tl.gnbs[${0}].dus[${0}].rus[${ru_idx}].serial_number}' for performing the following test ...
    builtin.Log To Console   ${long_log_string}
    builtin.Log To Console   Setting digital attenuation of all antenna ports of RMOD with index ${ru_idx} to minimal value of 0 dB ...
    attenuator.Set gNB all ports attenuation    value_in_db=${0}    ru_id=${ru_idx}
    builtin.Log To Console   \ Done!

    ${oam_alias}=    connect.Setup OAM http session    node_type=gnb    node_id=${0}
    builtin.Log To Console   Blocking all cells provided by the same RMOD with index ${ru_idx}, which shall not be visible to UEs under test ...
    FOR  ${cell_to_block}  IN  @{CELLS_TO_BLOCK_LIST}
        admin.Block Cell    dist_name=${cell_to_block}    connection=${oam_alias}   timeout=120
    END
    builtin.Log To Console   \ Done with blocking all unused cells provided by the same RMOD with index ${ru_idx}!

    builtin.Log To Console  \ Begin of KW 'MORAN VoIP call'\ \   format=°^${{int(int($consolewidth*1))-6}}

    builtin.Log To Console   The KW is called with following parameters: MO_UE_id=${MO_UE_id}, MT_UE_id=${MT_UE_id}
    builtin.Log To Console   \ \ preferred_net_mode=${preferred_net_mode}, technology_in_use=${technology_in_use}

    ${MO_UE_idx}=        builtin.Set Variable   ${MO_UE_id - 1}
    ${MO_UE_info_str}=   Get from UEidx the UE Info Log String For VoIP calls   UE_idx=${MO_UE_idx}
    ${MO_UE_ALIAS}=      builtin.Set Variable   UE_${MO_UE_id}
    ${VC_ALIAS}=         builtin.Set Variable   ${target_mno}_Vo${target_rat}_${call_type}_Call

    IF        '${call_type}' == 'MT'
        ${MT_UE_idx}=             builtin.Set Variable   ${MT_UE_id - 1}
        ${MT_UE_ALIAS}=           builtin.Set Variable   UE_${MT_UE_id}
        ${MT_UE_mno}=             builtin.Set Variable   ${target_mno}
        ${MO_UE_mno}=             builtin.Set Variable If   '${target_mno}' == 'DTAG'   TEF${SPACE}    DTAG${SPACE}
        ${MT_UE_info_str}=        Get from UEidx the UE Info Log String For VoIP calls   UE_idx=${MT_UE_idx}
        ${target_phone_number}=   builtin.Set Variable   ${tl.ues[${MT_UE_idx}].phone_number}
        ${call_target_str}=       builtin.Set Variable   '${MT_UE_ALIAS}' with phone number '${target_phone_number}'
    ELSE IF   '${call_type}' == 'MO'
        ${MT_UE_info_str}=        builtin.Set Variable   VoIP Call test number from SRN core with phone number 0105
        ${MO_UE_mno}=             builtin.Set Variable   ${target_mno}${SPACE}
        ${MT_UE_mno}=             builtin.Set Variable   ${EMPTY}
        ${target_phone_number}=   builtin.Set Variable   0105
        ${call_target_str}=       builtin.Set Variable   auto-answering phone number '0105'
    ELSE IF   '${call_type}' == 'EC'
        ${MT_UE_info_str}=        builtin.Set Variable   VoIP Emergency Call test number from SRN core for (SOS) with phone number 911
        ${MO_UE_mno}=             builtin.Set Variable   ${target_mno}${SPACE}
        ${MT_UE_mno}=             builtin.Set Variable   ${EMPTY}
        ${target_phone_number}=   builtin.Set Variable   911
        ${call_target_str}=       builtin.Set Variable   SOS phone number '911'
    END

    builtin.Log To Console  ${EMPTY}
    builtin.Log To Console  ${EMPTY}   format==<${{int(int($consolewidth*1))-6}}
    builtin.Log To Console  | ***** Performing ${VC_ALIAS} *****
    builtin.Log To Console  ${EMPTY}   format=-<${{int(int($consolewidth*1))-6}}
    builtin.Log To Console  |\ \ FROM:\ \ \ \ ${MO_UE_mno}${MO_UE_info_str}
    builtin.Log To Console  |\ \ TO:\ \ \ \ \ \ ${MT_UE_mno}${MT_UE_info_str}
    builtin.Log To Console  |\ \ MSISDN:\ \ ${target_phone_number}
    builtin.Log To Console  ${EMPTY}   format==<${{int(int($consolewidth*1))-6}}
    builtin.Log To Console  ${EMPTY}


    Log To Console    Calling 'Require UE' KW for ${MO_UE_ALIAS} (where the call originates) ...
    ${MO_UE_NAME}=    taf.ue.Require UE    ${MO_UE_ALIAS}    capabilities=${MO_UE_ALIAS}
    Log To Console    \ Done! ${MO_UE_ALIAS} has following UE object name: ${MO_UE_NAME}

    Log To Console    Attaching ${target_mno} ${MO_UE_ALIAS} to ${target_rat} cell ...
    taf.ue.Attach UE   ${MO_UE_ALIAS}   validation=${False}
    Log To Console    \ Done!

    moran_tc_kw_lib.Get and Print Ue Info   ${MO_UE_ALIAS}  PHASE_DESCRIPTION_STRING=\ (where the call originates)

    IF  '${call_type}' == 'MT'
        Log To Console    Calling 'Require UE' KW for ${MT_UE_ALIAS} (where the call terminates) ...
        ${MT_UE_NAME}=    taf.ue.Require UE    ${MT_UE_ALIAS}    capabilities=${MT_UE_ALIAS}
        Log To Console    \ Done! ${MT_UE_ALIAS} has following UE object name: ${MT_UE_ALIAS}

        Log To Console    Attaching ${MT_UE_ALIAS} to ${target_rat} cell ...
        taf.ue.Attach UE   ${MT_UE_ALIAS}   validation=${False}
        Log To Console    \ Done!

        moran_tc_kw_lib.Get and Print Ue Info   ${MT_UE_ALIAS}  PHASE_DESCRIPTION_STRING=\ (where the call terminates)
    END

    builtin.Log To Console  ${EMPTY}
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth*1))-30}}
    builtin.Log To Console  Starting voice call '${VC_ALIAS}' from '${MO_UE_ALIAS}' to ${call_target_str} and ${call_duration} duration ...
    taf.ue.Start Voice Call   vc_alias=${VC_ALIAS}   ue_alias=${MO_UE_ALIAS}   to=${target_phone_number}   duration=${call_duration}
    ## Below lines produce: Exception: exception|Could not start recording: Could not create path to file: '/storage/emulated/0/ue_manager/vcrec.3gp'
    # builtin.Log To Console  Starting to record voice on '${MO_UE_ALIAS}' ...
    # taf.ue.Start Recording Voice    ue_alias=${MO_UE_ALIAS}
    builtin.Log To Console  ${EMPTY}   format=+<${{int(int($consolewidth*1))-30}}
    builtin.Log To Console  \ Done!



    IF  '${call_type}' == 'MT'
       builtin.Log To Console  Awaiting on '${MT_UE_ALIAS}' the incoming voice call '${VC_ALIAS}' from '${MO_UE_ALIAS}' ...
       taf.ue.Await Incoming Voice Call   vc_alias=${VC_ALIAS}    ue_alias=${MT_UE_ALIAS}    action=answer   timeout=${answer_timeout}
    END

    builtin.Log To Console  Awaiting voice call '${VC_ALIAS}' to finish after configured ${call_duration} duration has passed ...
    taf.ue.Await Voice Call Finish    vc_alias=${VC_ALIAS}
    ## Below lines produce: Exception: exception|Could not start recording: Could not create path to file: '/storage/emulated/0/ue_manager/vcrec.3gp'
    # builtin.Log To Console  Stopping to record voice on '${MO_UE_ALIAS}' and saving recording at path:${\n}${SPACE}'${P_resultSuiteBaseDir}' ...
    # taf.ue.Stop Recording Voice    ue_alias=${MO_UE_ALIAS}    dump_to=${P_resultSuiteBaseDir}
    builtin.Log To Console  \ Done!

    Log To Console    Detaching and entering AIRPLANE mode on ${MO_UE_ALIAS} (where the call originated)
    taf.ue.Detach UE   ${MO_UE_ALIAS}   validation=${False}   force_change_mode=${True}
    builtin.Log To Console  \ Done!

    IF  '${call_type}' == 'MT'
        Log To Console    Detaching and entering AIRPLANE mode on ${MT_UE_ALIAS} (where the call terminated)
        taf.ue.Detach UE   ${MT_UE_ALIAS}   validation=${False}   force_change_mode=${True}
        builtin.Log To Console  \ Done!
    END

    builtin.Log To Console  \ End of KW 'MORAN VoIP call'\ \   format=°^${{int(int($consolewidth*1))-6}}


Get from UEidx the UE Info Log String For VoIP calls
    [Arguments]  ${UE_idx}=${0}
    ${long_log_string}=  builtin.Catenate   UE with serial
    ...   serial number '${tl.ues[${UE_idx}].serial_number}',
    ...   SIM card with IMSI '${tl.ues[${UE_idx}].imsi}' and
    ...   phone number '${tl.ues[${UE_idx}].phone_number}'
    RETURN   ${long_log_string}


MORAN L3 call with TCP Data Transfer
    [Documentation]   This test case is aimed at verifying the counters that are introduced as part of Data Transfer Testing to monitor DL Per CC UE
    ...   Throughput Counters and UL Per CC UE Throughput Counters in SA mode.
    [Arguments]    ${UE_id}=${1}   ${UNUSED_UE_id}=${2}   ${preferred_net_mode}=5G preferred   ${technology_in_use}=FDD

    #Log To Console    ${\n}Data Transfer Testing
    #Log To Console    ${\n}Lock cells to avoid RF interference.
    #Log To Console    Technology to use is: ${technology_in_use}

    ${oam_alias}=    connect.Setup OAM http session    node_type=gnb    node_id=${0}
    Set Test Variable  ${oam_alias}
    FOR  ${cell_to_block}  IN  @{CELLS_TO_BLOCK_LIST}
        admin.Block Cell    dist_name=${cell_to_block}    connection=${oam_alias}   timeout=120
    END

    ${NRRU}=    BTS_Cells_Handler.Set Active NRRU As Variable Based On Technology In Use    technology_in_use=${technology_in_use}
    Log To Console    ${\n}Open attenuation for serving cell...
    attenuator.Set gNB all ports attenuation    value_in_db=${0}    ru_id=${NRRU}

    ${reservedUE}    moran_tc_kw_lib.Initialize UE and optionally start background user data transfer   UE_id=${UE_id}   UNUSED_UE_id=${UNUSED_UE_id}
    ...   preferred_net_mode=${preferred_net_mode}   with_bg_user_data=${False}
    Set Test Variable    ${reservedUE}

    #-------------------------------------------------------------------------------------------------------------------------------------------------

    IF    ('NoKPI' in ${ENABLED_LOGS})
        Set Test Variable    ${WITH_PM_COUNTERS}    ${False}
    ELSE
        Set Test Variable    ${WITH_PM_COUNTERS}    ${True}
    END

    IF    ${WITH_PM_COUNTERS}    pmcounters.Wait Until The Next Measurement Period Starts

    moran_tc_kw_lib.Start iPerf3 TCP Data Transfer UL DL    ue_alias=${reservedUE}    duration=200s    parallel_thread=1

    Sleep    30sec
    ${1_DL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_DL}_${reservedUE}
    ${1_UL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_UL}_${reservedUE}

    Log To Console  ${\n}TPut after 30 Sec. for ${reservedUE}:${\n}DL: ${1_DL_AverageThroughput} [kbits/sec] UL: ${1_UL_AverageThroughput} [kbits/sec]

    Sleep    30sec
    ${2_DL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_DL}_${reservedUE}
    ${2_UL_AverageThroughput}    taf.ue.Get Average Throughput    dt_name=TCP_${DT_UL}_${reservedUE}

    Log To Console  ${\n}TPut after 60 Sec. for ${reservedUE}:${\n}DL: ${2_DL_AverageThroughput} [kbits/sec] UL: ${2_UL_AverageThroughput} [kbits/sec]

    taf.ue.Await Data Transfer Finish     TCP_${DT_DL}_${reservedUE}
    taf.ue.Await Data Transfer Finish     TCP_${DT_UL}_${reservedUE}
    taf.ue.Stop Data Transfer             TCP_${DT_DL}_${reservedUE}
    taf.ue.Stop Data Transfer             TCP_${DT_UL}_${reservedUE}

    # After the L3 call with the TCP user data transfer has been completted, putting now the UE that was used for the test to AIRPLANE MODE
    Log To Console    ${\n}L3 call with TCP throughput completed! Putting now the UE that was used for the test to AIRPLANE MODE: ${reservedUE}
    Log To Console    \ Detaching ${reservedUE}
    taf.ue.Detach UE   ${reservedUE}   validation=${False}   force_change_mode=${True}
    Log To Console    \ \ Done!${\n}

    taf.ue.Get Data Transfer Statistics   TCP_${DT_DL}_${reservedUE}
    taf.ue.Get Data Transfer Statistics   TCP_${DT_UL}_${reservedUE}

    IF    ${WITH_PM_COUNTERS}
        pmcounters.Wait Until The Next Measurement Period Starts
        ${pm_counters_dir}=   moran_tc_kw_lib.Collect And Convert PMCs And Calculate KPIs

        ${kpi_calc_status_UL}   ${calculated_kpi_list_UL}=    Run Keyword And Warn On Failure
        ...   verification_tools.Get KPIs Info From KPI CSV    ${pm_counters_dir}    throughput_UL
        ${calculated_kpi_list_UL}=    Set Variable If    '${kpi_calc_status_UL}'=='PASS'    ${calculated_kpi_list_UL}    ${EMPTY}

        ${kpi_calc_status_DL}   ${calculated_kpi_list_DL}=    Run Keyword And Warn On Failure
        ...   verification_tools.Get KPIs Info From KPI CSV    ${pm_counters_dir}    throughput_DL
        ${calculated_kpi_list_DL}=    Set Variable If    '${kpi_calc_status_DL}'=='PASS'    ${calculated_kpi_list_DL}    ${EMPTY}
    ELSE
        ${pm_counters_dir}=           Set Variable   ${EMPTY}
        ${calculated_kpi_list_UL}=    Set Variable   ${EMPTY}
        ${calculated_kpi_list_DL}=    Set Variable   ${EMPTY}
    END

    #-------------------------------------------------------------------------------------------------------------------------------------------------
    # Verify UL throughput and prepare reporting of related KPI_RESULTS by writing ${ul_tput_dict}
    #-------------------------------------------------------------------------------------------------------------------------------------------------

    ${expected_kpi_value_UL}    ${deviation_in_percentages_UL}=     Get Expected KPI Value and Deviation    kpi=throughput_UL
    ${taf_ue_return}=   Run Keyword And Continue On Failure   taf.ue.Verify Average Throughput With Deviation
    ...                                                          dt_name=TCP_${DT_UL}_${reservedUE}
    ...                                                          tput=${expected_kpi_value_UL} Mbits/sec
    ...                                                          deviation=${deviation_in_percentages_UL}%

    ${UL_AverageThroughput}=   taf.ue.Get Average Throughput    dt_name=TCP_${DT_UL}_${reservedUE}
    ${ul_tput_dict}=           common_tools.Find Actual Average TPut    taf_ue_output_string=Actual average tput=${UL_AverageThroughput} [kbits/sec]



    ${device_model}=       Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['device_model']}       ${EMPTY}
    ${imei}=               Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['imei']}               ${EMPTY}
    ${signal_strength}=    Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['signal_strength']}    ${EMPTY}
    ${sinr}=               Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['sinr']}               ${EMPTY}
    ${build_version}=      Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['build_version']}      ${EMPTY}
    ${imsi}=               Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['imsi']}               ${EMPTY}
    ${pci}=                Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['pci']}                ${EMPTY}
    ${serial}=             Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['serial']}             ${EMPTY}
    ${description_ul_catenated}=   builtin.Catenate
    ...    \[ue_type=${device_model}, serial=${serial}, imei=${imei}, imsi=${imsi}, ue_sw_version=${build_version}, phyCellId=${pci},
    ...    signal_strength=${signal_strength}dBm, sinr=${sinr}dB\]
    ...    ${calculated_kpi_list_UL}
    #...    ${\n}${{$calculated_kpi_list_UL.replace(' | ', '\r\n')}}
    ${description_ul}=        Set Variable If    '${device_model}'!='${EMPTY}'
    ...    ${description_ul_catenated}   ${calculated_kpi_list_UL}
    #...    ${description_ul_catenated}   ${{$calculated_kpi_list_UL.replace(' | ', '\r\n')}}
    ${expected_kpi_value_in_kbps_UL}=   Evaluate    int(${expected_kpi_value_UL}) * 1000
    Set To Dictionary    ${ul_tput_dict}    description=${description_ul}
    ...                                     name=throughput_UL
    ...                                     target=${expected_kpi_value_in_kbps_UL}

    #-------------------------------------------------------------------------------------------------------------------------------------------------
    # Verify DL throughput and prepare reporting of related KPI_RESULTS by writing ${dl_tput_dict}
    #-------------------------------------------------------------------------------------------------------------------------------------------------

    ${expected_kpi_value_DL}    ${deviation_in_percentages_DL}=      Get Expected KPI Value and Deviation    kpi=throughput_DL
    ${taf_ue_return}=   Run Keyword And Continue On Failure    taf.ue.Verify Average Throughput With Deviation
    ...                                                           dt_name=TCP_${DT_DL}_${reservedUE}
    ...                                                           tput=${expected_kpi_value_DL} Mbits/sec
    ...                                                           deviation=${deviation_in_percentages_DL}%

    ${DL_AverageThroughput}=   taf.ue.Get Average Throughput    dt_name=TCP_${DT_DL}_${reservedUE}
    ${dl_tput_dict}=           common_tools.Find Actual Average TPut    taf_ue_output_string=Actual average tput=${DL_AverageThroughput} [kbits/sec]

    ${device_model}=       Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['device_model']}       ${EMPTY}
    ${imei}=               Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['imei']}               ${EMPTY}
    ${signal_strength}=    Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['signal_strength']}    ${EMPTY}
    ${sinr}=               Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['sinr']}               ${EMPTY}
    ${build_version}=      Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['build_version']}      ${EMPTY}
    ${imsi}=               Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['imsi']}               ${EMPTY}
    ${pci}=                Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['pci']}                ${EMPTY}
    ${serial}=             Get Variable Value    ${${reservedUE}_IDENTITY_DICTIONARY['serial']}             ${EMPTY}
    ${description_dl_catenated}=   builtin.Catenate
    ...    \[ue_type=${device_model}, serial=${serial}, imei=${imei}, imsi=${imsi}, ue_sw_version=${build_version}, phyCellId=${pci},
    ...    signal_strength=${signal_strength}dBm, sinr=${sinr}dB\]
    ...    ${calculated_kpi_list_DL}
    #...    ${\n}${{$calculated_kpi_list_DL.replace(' | ', '\r\n')}}
    ${description_dl}=        Set Variable If    '${device_model}'!='${EMPTY}'
    ...    ${description_dl_catenated}   ${calculated_kpi_list_DL}
    #...    ${description_dl_catenated}   ${{$calculated_kpi_list_DL.replace(' | ', '\r\n')}}
    ${expected_kpi_value_in_kbps_DL}    Evaluate    int(${expected_kpi_value_DL}) * 1000
    Set To Dictionary    ${dl_tput_dict}    description=${description_dl}
    ...                                     name=throughput_DL
    ...                                     target=${expected_kpi_value_in_kbps_DL}

    #-------------------------------------------------------------------------------------------------------------------------------------------------
    # Summarize UL and DL KPI_RESULTS and aggregate them for reporting
    #-------------------------------------------------------------------------------------------------------------------------------------------------

    ${KPI_RESULTS}    Create List    ${ul_tput_dict}    ${dl_tput_dict}
    Set Suite Variable    ${KPI_RESULTS}



MORAN Test Case Setup Keyword
    [Documentation]   This is the keyword implementing the steps to be preformed during "Test Setup" phase of MORAN TC executions.

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   Running "MORAN Test Case Setup Keyword" ...   format=\ <${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}

    # getting current active alarms on the SBTS MORAN site and displaying them on the console
    gnb.Get Current Alarms From Node    node_type=gnb

    builtin.Log To Console    Setting the RF attenuation for the antenna signals of all cells to maximum value ...
    attenuator.Attenuate All Cells In Testline    off_value=${127}    is_sran_tl=${True}


MORAN Test Case Teardown Keyword
    [Documentation]   This is the keyword implements the steps to be performed during "Test Case Teardown" phase of MORAN TC executions

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   Running "MORAN Test Case Teardown Keyword" ...   format=\ <${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.67)-6}}
    builtin.Log To Console   ${EMPTY}

    Log To Console    Killing all iPerf processes that might be still running on APP_SERV or UC_CTRL_PC hosts ...
    Run Keyword And Continue On Failure    iperf_processes.Kill All iPerf Processes On Appserver And UE PC

    Log To Console    Unblocking again all cells that have been blocked before the previous test execution has started ...
    @{CELLS_TO_BLOCK_LIST}=   Get Variable Value    @{CELLS_TO_BLOCK_LIST}        ${{ [] }}
    ${oam_alias}=    connect.Setup OAM http Session    node_type=gnb    node_id=${0}
    FOR   ${cell_to_block}    IN    @{CELLS_TO_BLOCK_LIST}
      admin.Unblock Cell    dist_name=${cell_to_block}    connection=${oam_alias}   timeout=120
    END
    admin.Teardown   connection=${oam_alias}
    Log To Console    Done with unblocking all cells!

    # performing online reporting of test result
    commonKeywords.CSV Online Reporting To ReP

    #builtin.Log To Console    ${\n}taf.ue.Stop Data Transfers For All Ues.
    #taf.ue.Stop Data Transfers For All UEs

    #Log To Console    ${\n}The Phone ${reservedUE} will be detached...
    #taf.ue.Detach UE    ${reservedUE}


MORAN Test Suite Setup Keyword
    [Documentation]   This is the keyword implements the steps to be performed during "Test Suite Setup" phase of MORAN TC executions

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   Running "MORAN Test Suite Setup Keyword" ...   format=\ <${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}

    commonKeywords.Restart UEPROXY service on UEPC

    testline.Set Console Output

    # preparing folder path for log files
    testline.Create Test Suite Log Folders
    ${ts_log_dir}=    testline.Get Test Suite Log Directory
    Set Suite Variable    ${ts_log_dir}

    builtin.Log To Console   The logs of this test run will be available at: ${P_resultSuiteBaseDir}
    commonKeywords.Identify the list of unique SMODs and associated primary SBTS nodes of the testline   log_to_console=${True}

    builtin.Log To Console    ${\n}Waiting until all cells of SRAN BTS with MORAN site configuration are in 'OnAir' state ...
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=gnb    node_id=${0}    timeout=30s
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=enb    node_id=${0}    timeout=30s

    ${gnb_sw_version}=    Get gNB SW version    gnb_id=${0}
    Log to console    INFO: GNB SW Version is: ${gnb_sw_version}
    ${current_oru_fw_version}=    commonKeywords.Get Running ORAN RU FW version if applicable

    testline.Check TL Infos
    syve_testline.Save current loads

    # starting syslog collection, in case it is enabled
    IF    ('syslog' in ${ENABLED_LOGS})    Start syslog collection for CCRTS
    # starting tcpdump collection, in case it is enabled
    IF   'tcpdump' in ${ENABLED_LOGS}
       commonKeywords.Start tcpdump trace via eth3 interface connected to the monitoring port of testline switch
    END

    git_handling.Save Current Workspace Info

    #${capacityUnitType}=     testline.Get Capacity Unit Type    gnb_id=${0}
    #Set Suite Variable    ${capacityUnitType}
    #Log To Console    ${\n}Identified Capacity Unit Type: ${capacityUnitType}

    #scf_info.Collect and Validate the Current SCF file
    scf_info.Store original config files
    #gnb.Store Current SCF from gNB   gnb_id=${gnb_id}  target_dir=${configSuiteDir}/revert_scf

    commonKeywords.Get CSV TL customer mapping from TL name and set it as Suite Variable CUSTOMERS_LIST
    commonKeywords.Get CURRENT_SW_BRANCH And Set It As Suite Variable
    commonKeywords.Identify the list of unique SMODs and associated primary SBTS nodes of the testline   log_to_console=${True}

    IF   'FSMF' in ${{ [ value['hardware_type'] for key, value in $PRIMARY_TL_NODES_DICT.items() ] }}
    ...   builtin.Import Variables   ${CURDIR}/../E2E_RAT_Tests/qc_mapping_fsm3.yaml

    #Log Variables


MORAN Test Suite Teardown Keyword
    [Documentation]   This is the keyword implements the steps to be performed during "Test Suite Teardown" phase of MORAN TC executions

    builtin.Log To Console   ${EMPTY}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   Running "MORAN Test Suite Teardown Keyword" ...   format=\ <${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}   format=-<${{int(int($consolewidth)*0.80)-6}}
    builtin.Log To Console   ${EMPTY}

    Log To Console    Storing log files at path: '${ts_log_dir}'

    #taf.ue.Stop Data Transfers For All Ues

    # stopping syslog collection, in case it is enabled
    IF    ('syslog' in ${ENABLED_LOGS})    Stop syslog collection for CCRTS

    IF    ('snapshot' in ${ENABLED_LOGS})
        Log To Console    ${\n}Snapshot files under: ${\n}${ts_log_dir}
        snapshot.Get snapshot for node     node_type=gNB    node_id=${0}    target_dir=${ts_log_dir}
    END

    IF   'tcpdump' in ${ENABLED_LOGS}
        # stop and collect tcpdump
        ${pcap_file_path}=  commonKeywords.Stop and collect tcpdump trace via eth3 interface connected to the monitoring port of testline switch
        ...   target_dir=${P_resultSuiteBaseDir}

        # convert collected tcpdump from pcap to pdml
        Log To Console   Converting tcpdump trace that was recorded from eth3 monitoring interface of testline VM ...
        moran_tc_kw_lib.Convert PCAP File to PDML Format   ${pcap_file_path}
        Log To Console   \ Done!
    END

    # [TODO]: check in which cases the below line is really needed; will try to teardown alias named 'enb-0-OAM-http-session', when called
    #admin.Teardown All Aliases For Admin


Convert PCAP File to PDML Format
    [Documentation]    Convert tracing file from pcap to pdml
    [Arguments]    ${full_path_to_pcap_file}
    ${full_path_to_pdml_file}=   builtin.Set Variable    ${{$full_path_to_pcap_file.replace('.pcap','.pdml')}}
    ute_tshark.Setup Tshark   eth3   # calling this setup function prior to cally any other KW from this lib seems to be required
    ute_tshark.Read Pcap And Save To File    output_type=pdml  pcap_file_path=${full_path_to_pcap_file}   filename=${full_path_to_pdml_file}
    ute_Tshark.Teardown Tshark       # calling teardown of lib when done
    RETURN   ${full_path_to_pdml_file}


Initialize UE and optionally start background user data transfer
    [Documentation]   This keyword perform UE setup via UE_id and returns the UE_ALIAS. with the boolean parameter \${with_bg_user_data} it can be
    ...    specified, whether or not the keyword shall also start a backgorund user data transfer of 1Mbps in DL.
    [Arguments]   ${UE_id}=${1}   ${UNUSED_UE_id}=${2}   ${APN_name}=data_apn   ${preferred_net_mode}=LTE preferred   ${with_bg_user_data}=${False}

#    Get PIP LIST For taf-ue    UE_id=${UE_id}    # note: this command does not work and break the console output formatting
    ${ALIAS_UE}=           Set Variable    UE_${UE_id}
    ${ALIAS_UNUSED_UE}=    Set Variable    UE_${UNUSED_UE_id}

    ${APN_name}=   common_tools.Get default APN of UE from TL config   ${ALIAS_UE}
    Set Test Variable    ${APN_name}

    IF  "${ALIAS_UE}" not in "${REGISTERED_UES}"
        Log To Console    ${\n}Call 'Require UE' KW for the UE that is planned TO BE USED in this test: ${ALIAS_UE}
        ${UE_name}        taf.ue.Require UE    ${ALIAS_UE}    capabilities=${ALIAS_UE}
        Log To Console    The UE with alias '${ALIAS_UE}' has following UE name: ${UE_name}
        Append To List    ${REGISTERED_UES}   ${ALIAS_UE}
    ELSE
        Log    ${\n}The UE with alias '${ALIAS_UE}' is ALREADY REGISTERED...  level=WARN
        IF  "${PREV_TEST_NAME}" != "${EMPTY}"
            Log To Console    ... But, at the end of Test is deregistered.
            ${UE_name}    taf.ue.Require UE    ${ALIAS_UE}    capabilities=${ALIAS_UE}
            Log To Console    The UE with alias '${ALIAS_UE}' is again registered with following UE_name: ${UE_name}
        END
    END

    IF  "${ALIAS_UNUSED_UE}" not in "${REGISTERED_UES}"
        Log To Console    ${\n}Call 'Require UE' KW for the UE that is planned NOT TO BE USED in this test: ${ALIAS_UNUSED_UE}
        ${UNUSED_UE_name}    taf.ue.Require UE    ${ALIAS_UNUSED_UE}    capabilities=${ALIAS_UNUSED_UE}
        Log To Console         The UNUSED_UE with alias '${ALIAS_UNUSED_UE}' has following UE name: ${UNUSED_UE_name}
        Append To List    ${REGISTERED_UES}   ${ALIAS_UNUSED_UE}
    ELSE
        Log    ${\n}The UE with alias '${ALIAS_UNUSED_UE}' is ALREADY REGISTERED...   level=WARN
        IF  "${PREV_TEST_NAME}" != "${EMPTY}"
            Log To Console    ... But, at the end of Test is deregistered.
            ${UNUSED_UE_name}    taf.ue.Require UE    ${ALIAS_UNUSED_UE}    capabilities=${ALIAS_UNUSED_UE}
            Log To Console    The UE with alias '${ALIAS_UNUSED_UE}' is again registered with following UE_name:  ${UNUSED_UE_name}
        END
    END

    # reboot the UE that is USED in this test prior to executing the test, in case this functionality is enabled
    IF   ${REBOOT_UE}
        Log To Console    ${\n}Rebooting the UE that is USED in this test prior to executing the test: ${ALIAS_UE}
        taf.ue.Reboot UE    ue_alias=${ALIAS_UE}   timeout=120
        Log To Console    \ \ Done!
    END

    # making sure that the UNSUSED_UE that is NOT PLANNED to be used in this test, is in AIRPLANE MODE
    Log To Console    ${\n}Making sure that the UNSUSED_UE that is NOT PLANNED to be used in this test, is in AIRPLANE MODE: ${ALIAS_UNUSED_UE}
    Log To Console    \ Detaching ${ALIAS_UNUSED_UE}
    taf.ue.Detach UE   ${ALIAS_UNUSED_UE}   validation=${False}   force_change_mode=${True}
    Log To Console    \ \ Done!${\n}

    # making sure thath the UE that is USED in this test has the right preferred_net_mode setting (RAT-based cell search order)
    Get and Set the "preferred_net_mode" of the Android UE that is used for the test   ALIAS_UE=${ALIAS_UE}   preferred_net_mode=${preferred_net_mode}

    Log To Console    ${\n}Detaching ${ALIAS_UE}
    taf.ue.Detach UE    ${ALIAS_UE}

    builtin.Sleep  3s   Waiting 3 seconds before the actual test procedure will start ...

#    Run Keyword And Warn On Failure    CB010636_Workbench_KW.Start Tcpdump On gNB Trace   UE_id=${UE_id}
    Log To Console    ${\n}Attaching ${ALIAS_UE}
    taf.ue.Attach UE    ${ALIAS_UE}
#    Stop Tcpdump on gNB trace   UE_id=${UE_id}

    Run Keyword And Warn On Failure    taf.ue.Log UE Info    ${ALIAS_UE}

    ${get_UE_Info_Status}  ${get_UE_Info_Dictionary}  Run Keyword And Warn On Failure    taf.ue.Get UE Info    ${ALIAS_UE}

    Set Test Variable    ${${ALIAS_UE}_IDENTITY_DICTIONARY}    ${EMPTY}

    IF  '${get_UE_Info_Status}' == 'PASS'
        ${UE_IDENTITY_DICTIONARY} =    Create Dictionary
        FOR    ${Keys}  IN  @{get_UE_Info_Dictionary}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    device_model       ${get_UE_Info_Dictionary['device_model']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    commercial_name    ${get_UE_Info_Dictionary['commercial_name']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    build_version      ${get_UE_Info_Dictionary['build_version']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    serial             ${get_UE_Info_Dictionary['serial']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    imei               ${get_UE_Info_Dictionary['imei']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    imsi               ${get_UE_Info_Dictionary['imsi']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    pci                ${get_UE_Info_Dictionary['pci']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    signal_strength    ${get_UE_Info_Dictionary['signal_strength']}
            Set To Dictionary    ${UE_IDENTITY_DICTIONARY}    sinr               ${get_UE_Info_Dictionary['sinr']}
        END
        Set Test Variable    ${${ALIAS_UE}_IDENTITY_DICTIONARY}    ${UE_IDENTITY_DICTIONARY}

        ${UE_INFO_DICT_pretty_str}=    builtin.Evaluate   pprint.pformat(${${ALIAS_UE}_IDENTITY_DICTIONARY})   modules=pprint
        Log To Console    ${\n}UE device information about '${ALIAS_UE}' used for this test:${\n}${UE_INFO_DICT_pretty_str}

    ELSE
        Log    Cannot print the UE device information about '${ALIAS_UE}' used for this test, as the "taf.ue.Get UE Info" KW call has failed!
        ...   level=WARN
    END

#    ${contains_correct_APN}    IPS Contains APN Name    UE_id=${ALIAS_UE}    APN_name=${APN_name}
#
#    IF    ${contains_correct_APN} == False
#        Log To Console    ${\n}The UE_${UE_id} APN is not set to "${APN_name}"... try to set it automatically...
#        Log To Console    OR, Please set the APN manually. (KW not working for all UEs Type)${\n}
#        Switch APN    UE_id=${UE_id}    APN_name=${APN_name}
#    END

    IF   ${with_bg_user_data}
        Log To Console    ${\n}Start DL background traffic. (1MBit/sec)
        Run Keyword and Continue on Failure   taf.ue.Start Data Transfer
        ...    dt_name=DL_Background_${ALIAS_UE}
        ...    ue_alias=${ALIAS_UE}
        ...    direction=dl
        ...    throughput=1 Mbits/sec
        ...    protocol=udp
        ...    packet=1330
        ...    bearer_alias=UeAutomatic
        ...    parallel=1
        ...    apn=${APN_name}      # apn shall not be specified here if already interface_name is specified in TafUeDataTransferProtocol()
    END

    RETURN     ${ALIAS_UE}


Get and Set the "preferred_net_mode" of the Android UE that is used for the test
    [Arguments]    ${ALIAS_UE}=UE_1   ${preferred_net_mode}=NR Only   ${fail_if_unsuccessful}=${True}
    # checking on Android UEs the "preferred_net_mode" setting prior to performing any action on the UE
    # NOTE: It needs to be assured, that the UE is not in Airplane mode when calling 'Get UE info', othewise the reported data is partly invalid.
    Run Keyword And Ignore Error    taf.ue.Attach UE    ${ALIAS_UE}   timeout=10   validation=${False}
    ${get_UE_Info_Status}   ${get_UE_Info_Dictionary}   Run Keyword And Warn On Failure    taf.ue.Get UE Info    ${ALIAS_UE}
    IF  '${get_UE_Info_Status}' == 'PASS'
       IF    'android_ver' in ${get_UE_Info_Dictionary}
            ${get_net_mode_kw_status}   ${UEs_preferred_net_mode_setting}=    Run Keyword And Ignore Error
            ...    taf.ue.Get Preferred Network Mode    ${ALIAS_UE}
            ...    network_mode_handler_type=secretcode
            #...    network_mode_handler_type=keyevents    path_to_network_mode_type="Mobile networks/Network mode"
            IF  '${get_net_mode_kw_status}' == 'PASS'
                IF  '${UEs_preferred_net_mode_setting}' not in ['${preferred_net_mode}']
                    ${long_log_message}=   builtin.Catenate   The 'Preferred Network Mode' (RAT) setting on ${ALIAS_UE} is currently configured\
                    ...   to value '${UEs_preferred_net_mode_setting}', which is different from the expected value '${preferred_net_mode}'!\n
                    ...   Therefore, changing now UE's 'preferred_net_mode' setting to '${preferred_net_mode}'!
                    builtin.Log   ${long_log_message}   level=WARN

                    ${change_net_mode_kw_status}  ${change_net_mode_ret_val_none}=   Run Keyword And Warn On Failure
                    ...   taf.ue.Change Network Mode    ${ALIAS_UE}   ${preferred_net_mode}   network_mode_switch_method=secretcode

                    IF  '${change_net_mode_kw_status}' == 'FAIL'

                        ${long_log_message}=   builtin.Catenate   The attempt to switch the 'Preferred Network Mode' (RAT) setting on ${ALIAS_UE}
                        ...   to value '${preferred_net_mode}' was not successful!\n
                        ...   Therefore, retrying one more time after the UE has been rebooted'!
                        builtin.Log   ${long_log_message}   level=WARN

                        # reboot the UE and retry if the previous attempt to switch the preferred_net_mode was not successful
                        taf.ue.Reboot UE    ue_alias=${ALIAS_UE}   timeout=120

                        ${change_net_mode_kw_status}  ${change_net_mode_ret_val_none}=   Run Keyword And Warn On Failure
                        ...   taf.ue.Change Network Mode    ${ALIAS_UE}   ${preferred_net_mode}   network_mode_switch_method=secretcode

                        IF   '${change_net_mode_kw_status}' == 'FAIL'
                            IF   ${fail_if_unsuccessful}
                                ${long_log_message}=   builtin.Catenate   Also the 2nd attmpt to switch the 'Preferred Network Mode' (RAT) setting on
                                ...   ${ALIAS_UE} to value '${preferred_net_mode}' was still not successful!\n
                                ...   Therefore giving up and aborting test execution here!
                                builtin.Fail   ${long_log_message}
                            ELSE
                                ${long_log_message}=   builtin.Catenate   Also the 2nd attmpt to switch the 'Preferred Network Mode' (RAT) setting on
                                ...   ${ALIAS_UE} to value '${preferred_net_mode}' was still not successful!\n
                                builtin.Log To Console   ${long_log_message}
                            END
                        END

                    END

                    # Run Keyword And Continue on Failure    taf.ue.Change Network Mode    ${ALIAS_UE}   ${preferred_net_mode}
                    # #Run Keyword And Ignore Error    taf.ue.Change Network Mode    ${ALIAS_UE}   ${preferred_net_mode}
                    # #...    network_mode_switch_method=keyevents    path_to_network_mode_type="Mobile networks/Network mode"
                    # ...    network_mode_switch_method=secretcode
                ELSE
                    builtin.Log To Console
                    ...  The used ${ALIAS_UE} is already configured to the required 'preferred_net_mode' (${preferred_net_mode}) for this test.
                END
            ELSE
                builtin.Log   Failed to get the The 'Preferred Network (RAT) Type' setting on ${ALIAS_UE}!   ERROR   console=${True}
            END
        END
    END


Collect And Convert PMCs And Calculate KPIs
    ${ts_log_dir}=    testline.Get Test Suite Log Directory
    Set Suite Variable    ${ts_log_dir}
    ${return}    Run Keyword And Ignore Error    pmcounters.Collect PM Counter    target_dir=${ts_log_dir}/pmc_${TEST_NAME}
    ${pm_counters_dir}    Set Variable If    '${return[0]}'=='PASS'    ${return[1]}    ${EMPTY}
    Run Keyword And Ignore Error    common_tools.Zip Older PM Files To Save Conversion Time    directory=${pm_counters_dir}
    ...                                                                                        keep_recent=2
    ...                                                                                        zip_name=archived_PM_files.zip
    ...                                                                                        file_name_filter=PM.BTS
    ${return}    Run Keyword And Ignore Error    pmcounters.Convert PM Files To CSV    file_path=${pm_counters_dir}
    ${pm_counters_csv_filepath}    Set Variable If    '${return[0]}'=='PASS'    ${return[1]}    ${EMPTY}
    ${KPIs}    Run Keyword And Ignore Error    verification_tools.Get KPIs From PMCounters    ${pm_counters_csv_filepath}    PMKPI_SBTS25R3_5G.json
    ...   list_of_kpi_ids_to_skip=${{['NR_5597b', 'NR_5598b', 'NR_6232a', 'NR_6233a', 'NR_713a', 'NR_714a']}}
    RETURN    ${pm_counters_csv_filepath}


Start PING
    [Arguments]    ${ue_alias}=UE_1    ${direction}=ul    ${duration}=60s   ${allowed_packet_loss}=0   ${ping_count}=10
    Log To Console    ${\n}PING in ${direction} for ${ue_alias}...
    taf.ue.Start Data Transfer
    ...    dt_name=${direction}_PING_${ue_alias}
    ...    ue_alias=${ue_alias}
    ...    direction=${direction}
    ...    protocol=icmp
    ...    duration=${duration}
    ...    ping_host_ip=10.47.194.237      # DEUL5Gappsrv37.ulm.nsn-rdnet.net
    ...    ping_count=${ping_count}
    ...    apn=${APN_name}                # apn shall not be specified here if already interface_name is specified in TafUeDataTransferProtocol()
    ...    allowed_packet_loss=${allowed_packet_loss}


Start iPerf3 TCP Data Transfer UL DL
    [Arguments]    ${ue_alias}=UE_1   ${duration}=60s   ${parallel_thread}=8   # ${port_value}=${None}

    Log To Console    ${\n}Starting iperf3 TCP Data Transfer in UL for ${duration} using ${ue_alias}...
    taf.ue.Start Data Transfer
    ...    dt_name=TCP_${DT_UL}_${ue_alias}
    ...    ue_alias=${ue_alias}
    ...    direction=ul                    # one of: ‘ul’, ‘dl’ or ‘simultaneous_ul_dl’
    ...    duration=${duration}            # Data transfer duration in Robot time string format. e.g. ‘1 minutes 42 seconds’ or ‘1min 42s’.
    #...    throughput=100Mbits/sec        # 100 Mbps seems to be the default setting
    #...    bearer_alias=UeAutomatic       # “UeAutomatic” is default reserved value - it means UE decides which bearer it will use (depends on load)
    ...    protocol=tcp                    # one of: ‘udp’ or ‘tcp’ or ‘icmp’ or ‘http’ or ‘ftp’
    ...    apn=${APN_name}                # apn shall not be specified here if already interface_name is specified in TafUeDataTransferProtocol()
    ...    version=3                       # iperf version to be used
    ...    parallel_thread=${parallel_thread}   # The number of simultaneous connections to make to the server. Default is 1
    ...    max_segment_size=1380           # should not be higher than 1460 for ethernet MTU 1500 - 40 TCP header, with IPsec even less
    #...    packet=1400B                   # set read/write buffer size (TCP) - default seems to be 8K
    #...    port=${port_value}             # this option seems to be obsolete ${port_value}=None

    Log To Console    \ Done!


    Log To Console    ${\n}Starting iperf3 TCP Data Transfer in DL for ${duration} using ${ue_alias}...

    taf.ue.Start Data Transfer
    ...    dt_name=TCP_${DT_DL}_${ue_alias}
    ...    ue_alias=${ue_alias}
    ...    direction=dl                    # one of: ‘ul’, ‘dl’ or ‘simultaneous_ul_dl’
    ...    duration=${duration}            # Data transfer duration in Robot time string format. e.g. ‘1 minutes 42 seconds’ or ‘1min 42s’.
    #...    throughput=100Mbits/sec        # 100 Mbps seems to be the default setting
    #...    bearer_alias=UeAutomatic       # “UeAutomatic” is default reserved value - it means UE decides which bearer it will use (depends on load)
    ...    protocol=tcp                    # one of: ‘udp’ or ‘tcp’ or ‘icmp’ or ‘http’ or ‘ftp’
    ...    apn=${APN_name}                # apn shall not be specified here if already interface_name is specified in TafUeDataTransferProtocol()
    ...    version=3                       # iperf version to be used
    ...    parallel_thread=${parallel_thread}   # The number of simultaneous connections to make to the server. Default is 1
    ...    max_segment_size=1380           # should not be higher than 1460 for ethernet MTU 1500 - 40 TCP header, with IPsec even less
    #...    packet=1400B                   # set read/write buffer size (TCP) - default seems to be 8K
    #...    port=${port_value}             # this option seems to be obsolete ${port_value}=None

    Log To Console    \ Done!


Get and Print Ue Info
    [Documentation]   This keyword gets the UE Info dictionary and prints it to the console
    [Arguments]       ${ALIAS_UE}     ${PHASE_DESCRIPTION_STRING}=${EMPTY}

    ${get_UE_Info_Status}   ${get_UE_Info_Dictionary}   Run Keyword And Warn On Failure    taf.ue.Get UE Info   ${ALIAS_UE}
    IF  '${get_UE_Info_Status}' == 'PASS'
        ${UE_INFO_DICT_pretty_str}=    builtin.Evaluate   pprint.pformat(${get_UE_Info_Dictionary})   modules=pprint
        Log To Console    ${\n}${ALIAS_UE} device information${PHASE_DESCRIPTION_STRING}:${\n}${UE_INFO_DICT_pretty_str}
    ELSE
        Log    Cannot print the ${ALIAS_UE} device information${PHASE_DESCRIPTION_STRING}, as the "taf.ue.Get UE Info" KW call has failed!
        ...   level=WARN
    END


