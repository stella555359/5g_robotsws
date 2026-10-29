*** Settings ***
Documentation       DSS VERDICT TEST. Author : Ch SAMSON

Library             OperatingSystem
Library             Collections
Library             DateTime

Library             ../TARF/python/tools.py           WITH NAME          nps_tarf_tools
Library             ../../../resources/DSS/python/robot_extension.py      WITH NAME          robot_extension
Library             ../python/CB013715_tools.py                           WITH NAME          CB013715_tools
Library             ../python/CB013715_validation.py                      WITH NAME          CB013715_validation
Library             ../python/ExpandcsvFile.py                            WITH NAME          ExpandcsvFile

Resource            ../TARF/robot/TARF-Keywords.robot

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

Calculate DL first_prb_non_blanking and last_prb_non_blanking for Cell${cell_id_:\d+}
    ${nbrOfBlankedPRBsHighEdgeDL}=            Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${cell_id_}
    ${nbrOfBlankedPRBsLowEdgeDL}=             Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL   CellId=${cell_id_}
    # to review !!!!
    IF     '${cell_id_}'=='1'
        ${total_prb_bw}=                          Set Variable      ${BW_Prb_cell1}
    ELSE
        ${total_prb_bw}=                          Set Variable      ${BW_Prb_cell2}
    END
    ${total_prb_bw_int}=                      Convert To Integer    ${total_prb_bw}
    ${rbgsize}=                               CB013715_tools.return_only_rbgsize_pdsch  chBW=${total_prb_bw_int}  ConfigType=${1}
    ${nbrOfBlankedPRBsHighEdgeDL_int}=        Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL_int}=         Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL}
    ${line}=    Catenate     **********************************************************************************
    Append To File   ${resultFile}   \n\t${line}\n\tCalculate DL first_prb_non_blanking and last_prb_non_blanking for Cell${cell_id_}\n\t${line}\n
    ${text}=    catenate     CellId=${cell_id_} nbrOfBlankedPRBsLowEdgeDL
    ${result}=  StringTool.getHeaderLine   ${text}   ${nbrOfBlankedPRBsLowEdgeDL}
    nps_tarf_tools.log_to_console_with_time_prefix      ${result}      level=INFO
    Append To File   ${resultFile}    \n\t===> ${result}\n
    ${text}=    catenate     CellId=${cell_id_} nbrOfBlankedPRBsHighEdgeDL
    ${result}=  StringTool.getHeaderLine   ${text}   ${nbrOfBlankedPRBsHighEdgeDL}
    nps_tarf_tools.log_to_console_with_time_prefix      ${result}     level=INFO
    Append To File   ${resultFile}    \t===> ${result}\n
    ${chBW}   ${rat0bitmap_full}  ${usablepdsch}   ${rat0bitmap}   CB013715_tools.cal_num_of_pdsch   chBW=${total_prb_bw_int}     ConfigType=${1}
    ...                                                                           nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL_int}
    ...                                                                           nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL_int}
    nps_tarf_tools.log_to_console_with_time_prefix        cal_num_of_pdsch : chBW=${chBW} ConfigType=1 full rat0bitmap_full=${rat0bitmap_full}
    ...    level=INFO
    Append To File   ${resultFile}    \tcal_num_of_pdsch : chBW=${chBW} ConfigType=Type1 full rat0bitmap=${rat0bitmap_full}\n
    nps_tarf_tools.log_to_console_with_time_prefix        ===> usablepdsch=${usablepdsch} rat0bitmap=${rat0bitmap}    level=INFO
    Append To File   ${resultFile}    \tusablepdsch=${usablepdsch} rat0bitmap=${rat0bitmap}\n
    # use of RBG must be applied in case of downlink
    # let manage first low edge
    FOR    ${nb_rbg}    IN RANGE    0    10
        ${first_prb_non_blanking}=              Evaluate    ${nb_rbg} * ${rbgsize}
        Exit For Loop If    ${nbrOfBlankedPRBsLowEdgeDL} <= ${first_prb_non_blanking}
    END
    # let manage high edge
    ${rbgsize_val}=                             Evaluate    ${total_prb_bw} % ${rbgsize}
    ${rbgsize_last}=    Run Keyword If    ${rbgsize_val} == 0    Set Variable    ${rbgsize}
    ...                             ELSE    Set Variable    ${rbgsize_val}
    ${nb_rbgprb}=    Run Keyword If    ${nbrOfBlankedPRBsHighEdgeDL} == 0    Set Variable    0
    ...                          ELSE           Set Variable    ${rbgsize_last}
    FOR    ${nb_rbg}    IN RANGE    1    10
        Exit For Loop If    ${nb_rbgprb} >= ${nbrOfBlankedPRBsHighEdgeDL}
        ${nb_rbgprb}=                           Evaluate    ${rbgsize_last} + (${nb_rbg} * ${rbgsize})
    END
    # take into account the last RBG(1PRB) when nbrOfBlankedPRBsHighEdgeDL=0
    ${nb_rbgprb}=         Set Variable If     '${nbrOfBlankedPRBsHighEdgeDL}'=='0'       0
    ...                                                                                  ${nb_rbgprb}
    ${last_prb_non_blanking}=                   Evaluate    ${total_prb_bw} - ${nb_rbgprb} - 1
    ${nb_prb_max}=                              Evaluate    ${total_prb_bw} - ${first_prb_non_blanking} - ${nb_rbgprb}
    # ${msg}=     catenate      DL blanking configuration is LowEdgeDL=
    # Dated Log    ===> ${msg}${nbrOfBlankedPRBsLowEdgeDL} and HighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL} for cellid=${cell_id_}
    ${msg}=     catenate     DL Test Acceptance Criteria is [cellid=${cell_id_} DL BlankedPRBs config] : max nbOfPrb=${nb_prb_max} and
    ...                         range nbOfPrb : ${first_prb_non_blanking} <= possible
    ...                         non-blanking prb <= ${last_prb_non_blanking}
    nps_tarf_tools.log_to_console_with_time_prefix    ===> ${msg}       level=INFO
    Append To File   ${resultFile}    \n\t===> ${msg}\n
    should be true      '${usablepdsch}' == '${nb_prb_max}'     msg=usablepdsch[=${usablepdsch}] must be == to nb_prb_max[=${nb_prb_max}]
    IF    '${usablepdsch}' == '${nb_prb_max}'
        Append To File   ${resultFile}    \t'usablepdsch[${usablepdsch}]' == 'nb_prb_max[${nb_prb_max}]'\t-----> PASS\n
    ELSE
        Append To File   ${resultFile}    \t'usablepdsch[${usablepdsch}]' != 'nb_prb_max[${nb_prb_max}]'\t-----> FAIL\n
    END
    [return]    ${first_prb_non_blanking}    ${last_prb_non_blanking}

Calculate UL first_prb_non_blanking and last_prb_non_blanking for Cell${cell_id_:\d+}
    ${nbrOfBlankedPRBsHighEdgeUL}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL   CellId=${cell_id_}
    ${nbrOfBlankedPRBsLowEdgeUL}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL   CellId=${cell_id_}
    IF     '${cell_id_}'=='1'
        ${total_prb_bw}=                          Set Variable      ${BW_Prb_cell1}
    ELSE
        ${total_prb_bw}=                          Set Variable      ${BW_Prb_cell2}
    END
    # BEWARE : to improve later : PUCCH SIZE = 8
    # ${first_prb_non_blanking}=                Set Variable    ${nbrOfBlankedPRBsLowEdgeUL}
    # ${first_prb_non_blanking}=                Evaluate    ${nbrOfBlankedPRBsLowEdgeUL} + 3
    # ${last_prb_non_blanking}=                 Evaluate    ${total_prb_bw} - ${nbrOfBlankedPRBsHighEdgeUL} - 1 - 3
    ${first_prb_non_blanking}=                Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}
    ${last_prb_non_blanking}=                 Evaluate    ${total_prb_bw} - ${nbrOfBlankedPRBsHighEdgeUL}

    ${msg}=     catenate      UL blanking configuration is LowEdgeUL=
    nps_tarf_tools.log_to_console_with_time_prefix
    ...    ${msg}${nbrOfBlankedPRBsLowEdgeUL} and HighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL} for cellid=${cell_id_}    level=INFO
    ${msg}=     catenate     [cellid=${cell_id_} UL BlankedPRBs config] :
    ...                         range nbOfPrb : ${first_prb_non_blanking} <= possible
    ...                         non-blanking prb <= ${last_prb_non_blanking}
    nps_tarf_tools.log_to_console_with_time_prefix    ===> ${msg}        level=INFO
    Append To File   ${resultFile}    \n\t===> ${msg}\n
    [return]    ${first_prb_non_blanking}    ${last_prb_non_blanking}

Get startPrbInitialUlBwp Parameters From BWP_PROFILE gNB
    [Arguments]      ${CellId}=1   ${listindex}=0     ${nodeType}=Classical    ${bwp_profile}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-5
    ${locationAndBandwidthDl_params_list}    Create List    cRbSizeDl    cRbStartDl
    # Get SCF File (SCF.xml) is performed in test setup
    ${scf_path}    set Variable      ${test_scf_file}
    ${locationAndBandwidthDl_params_list_result}    CB013715_tools.get_feature_parameters_from_scf    ${scf_path}
    ...    ${locationAndBandwidthDl_params_list}
    ...    ${bwp_profile}    locationAndBandwidthDl    index=${listindex}
    ${locationAndBandwidthUl_params_list}    Create List    cRbSizeUl    cRbStartUl
    ${locationAndBandwidthUl_params_list_result}    CB013715_tools.get_feature_parameters_from_scf    ${scf_path}
    ...    ${locationAndBandwidthUl_params_list}
    ...    ${bwp_profile}    locationAndBandwidthUl    index=${listindex}
    ${startPrbInitialUlBwp}=    Run Keyword If    '${locationAndBandwidthUl_params_list_result['cRbStartUl']}' == 'sameAsDl'
    ...              set Variable      ${locationAndBandwidthDl_params_list_result['cRbStartDl']}
    ...      ELSE    set Variable      ${locationAndBandwidthUl_params_list_result['cRbStartUl']}
   [Return]    ${startPrbInitialUlBwp}

Is ${direction:(Ul|Dl)} Fragmentation enabled for Cell ${cell_id_:\d+} with Syslog path ${syslogPath}
    # [Arguments]   ${syslogPath}=/tmp/btslog2
    ${commandToRun}     Catenate     cd ${syslogPath}; find . -name "*.LOG" -type f | sed -e 's/^\\.\\///g'
    ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
    ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
    ${Fragmentation Allowed}          set Variable    False
    FOR    ${syslog}    IN    @{sysLog_files}
         ${rc}    ${output}    Run And Return Rc And Output
         ...    command=cat ${syslogPath}/${syslog} | grep 'Fragmentation enabled \\[${direction}\\] = 1' | grep ${cell_id_}
         ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output}
         exit for loop if    ${status}
     END
    ${Fragmentation Allowed}=    set Variable if   '${status}'=='True'    True
    ...                                                                   False
    [Return]        ${Fragmentation Allowed}

Get bwpDN Parameters From gNB
    [Arguments]      ${CellId}=1   ${listindex}=0     ${nodeType}=Classical
    ${cellBwpList_params_list}    Create List    actPdcchCceFragmentControl    actUpperThrAckNackFiltering
    ...                                          actUpperThrAckNackHrFiltering    bwpDN    cellBwpId    pdcchResourcePreference
    # Get SCF File (SCF.xml) is performed in test setup
    ${scf_path}    set Variable      ${test_scf_file}
    ${cellBwpList_params_list_result}    CB013715_tools.get_feature_parameters_from_scf    ${scf_path}    ${cellBwpList_params_list}
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}    cellBwpList    index=${listindex}
   [Return]    ${cellBwpList_params_list_result}

get BW Prb
    [Arguments]    ${verify_with_scenario}
    ${scf_file}    Set Variable    ${configuration_directory}/scf_${verify_with_scenario}.xml
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
        ${chBwDl_cell1}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
        ${chBwDl_cell2}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1

    ${BW_Prb_cell1}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl_cell1}
    ${BW_Prb_cell2}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl_cell2}
    set test variable  ${BW_Prb_cell1}
    set test variable  ${BW_Prb_cell2}

    ${first_prb_non_blanking_cell1}  ${last_prb_non_blanking_cell1}
    ...               Calculate DL first_prb_non_blanking and last_prb_non_blanking for Cell${fdd_cell_1}
    ${first_prb_non_blanking_cell2}  ${last_prb_non_blanking_cell2}
    ...               Calculate DL first_prb_non_blanking and last_prb_non_blanking for Cell${fdd_cell_2}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell1}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL   CellId=${fdd_cell_1}
    ${end_prb_dedicated_bwp_cell1}=    Evaluate      ${nbrOfBlankedPRBsLowEdgeDL_Cell1} + ${BW_Prb_cell1}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell2}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL   CellId=${fdd_cell_2}
    ${end_prb_dedicated_bwp_cell2}=    Evaluate      ${nbrOfBlankedPRBsLowEdgeDL_Cell2} + ${BW_Prb_cell2}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell1}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell2}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell1_int}=         Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL_Cell1}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell1_int}=          Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL_Cell1}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell2_int}=         Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL_Cell2}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell2_int}=          Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL_Cell2}

    # BEWARE that these variables are needed for Acceptance criteria based on L1L2 pcap
    set test variable    ${first_prb_non_blanking_cell1}
    set test variable    ${last_prb_non_blanking_cell1}
    set test variable    ${first_prb_non_blanking_cell2}
    set test variable    ${last_prb_non_blanking_cell2}

Generate Test Verdict For Prb Blanking
    [Arguments]    ${FilePkl}    ${verify_with_scenario}   ${techno}=FDD    ${step}=${None}
    ${tm}=    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    ${step}=     Set Variable If    '${step}' == '${None}'     MAIN STEP
    ...                                                        ${step}

    ${scf_file}    Set Variable    ${configuration_directory}/scf_${verify_with_scenario}.xml
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    scf.load_scf    ${scf_file}
        ${chBwDl_cell1}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
        ${chBwDl_cell2}=    scf.get_value_from_scf    p_name=chBwDl    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1

    Append To File   ${resultFile}
    ...        \n**********************************\nTest Verdict PrbBlanking TtiTraces\n**********************************\n

    ${BW_Prb_cell1}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl_cell1}
    ${BW_Prb_cell2}=    CB013715_initial_commissioning.Get FDD Channel Bandwidth With PRB   chbw=${chBwDl_cell2}
    set test variable  ${BW_Prb_cell1}
    set test variable  ${BW_Prb_cell2}

    ${nrCellIdentity_cell1}=    TARF-Keywords.Get nrCellIdentity From coam ADMIN    cell_grp=0    cell_nr=1
    Dated Log      From COAM ADMIN nrCellIdentity=${nrCellIdentity_cell1}

    IF     '${techno}'=='TDD'
        ${DL_Frag_enable}=   Is Dl Fragmentation enabled for Cell ${nrCellIdentity_cell1} with Syslog path ${path_to_syslog_cellsetup_initial}
        # ${DL_Frag_enable}=      Is Dl Fragmentation enabled for Cell ${nrCellIdentity_cell1} with Syslog path /tmp/btslog2
    ELSE
        ${DL_Frag_enable}=    set variable     False
    END
    dated log      DL_Fragmentation_enable=${DL_Frag_enable} for cell${fdd_cell_1}
    Append To File   ${resultFile}    \n\n\tDL_Fragmentation_enable=${DL_Frag_enable} for cell${fdd_cell_1}\n
    robot_extension.Run Keyword And Warn On Failure     Should be True   ${DL_Frag_enable}
    ...                              msg=${consTraceColorRed}DL_Fragmentation should be enable for cell${fdd_cell_1}${defColor}
    declare Results in Test Results List     Type=SYSLOG: Check DL_Fragmentation_enable Cell${fdd_cell_1}     Result=${DL_Frag_enable}

    ${nrCellIdentity_cell2}=    TARF-Keywords.Get nrCellIdentity From coam ADMIN    cell_grp=1    cell_nr=2
    Dated Log      From COAM ADMIN nrCellIdentity=${nrCellIdentity_cell2}
    IF     '${techno}'=='TDD'
        ${DL_Frag_enable}=   Is Dl Fragmentation enabled for Cell ${nrCellIdentity_cell2} with Syslog path ${path_to_syslog_cellsetup_initial}
        # ${DL_Frag_enable}=      Is Dl Fragmentation enabled for Cell ${nrCellIdentity_cell2} with Syslog path /tmp/btslog2
    ELSE
        ${DL_Frag_enable}=    set variable     False
    END
    dated log      DL_Fragmentation_enable=${DL_Frag_enable} for cell2
    Append To File   ${resultFile}    \tDL_Fragmentation_enable=${DL_Frag_enable} for cell2\n
    robot_extension.Run Keyword And Warn On Failure     Should be True   ${DL_Frag_enable}
    ...                              msg=${consTraceColorRed}DL_Fragmentation should be enable for cell2${defColor}
    declare Results in Test Results List     Type=SYSLOG: Check DL_Fragmentation_enable Cell2     Result=${DL_Frag_enable}

    IF     '${techno}'=='TDD'
        ${UL_Frag_enable}=   Is Ul Fragmentation enabled for Cell ${nrCellIdentity_cell1} with Syslog path ${path_to_syslog_cellsetup_initial}
        # ${UL_Frag_enable}=      Is Ul Fragmentation enabled for Cell ${nrCellIdentity_cell1} with Syslog path /tmp/btslog2
    ELSE
        ${UL_Frag_enable}=    set variable     False
    END
    dated log      UL_Fragmentation_enable=${UL_Frag_enable} for cell${fdd_cell_1}
    Append To File   ${resultFile}    \tUL_Fragmentation_enable=${UL_Frag_enable} for cell${fdd_cell_1}\n
    robot_extension.Run Keyword And Warn On Failure     Should be True   ${UL_Frag_enable}
    ...                               msg=${consTraceColorRed}UL_Fragmentation should be enable for cell1${defColor}
    declare Results in Test Results List     Type=SYSLOG: Check UL_Fragmentation_enable Cell${fdd_cell_1}     Result=${UL_Frag_enable}

    IF     '${techno}'=='TDD'
        ${UL_Frag_enable}=      Is Ul Fragmentation enabled for Cell ${nrCellIdentity_cell2} with Syslog path /tmp/btslog2
    ELSE
        ${UL_Frag_enable}=    set variable     False
    END
    dated log      UL_Fragmentation_enable=${UL_Frag_enable} for cell${fdd_cell_2}
    Append To File   ${resultFile}    \tUL_Fragmentation_enable=${UL_Frag_enable} for cell2\n
    robot_extension.Run Keyword And Warn On Failure     Should be True   ${UL_Frag_enable}
    ...                              msg=${consTraceColorRed}UL_Fragmentation should be enable for cell2${defColor}
    declare Results in Test Results List     Type=SYSLOG: Check UL_Fragmentation_enable Cell${fdd_cell_2}     Result=${UL_Frag_enable}

    ${first_ul_prb_non_blanking_cell1}  ${last_ul_prb_non_blanking_cell1}
    ...              Calculate UL first_prb_non_blanking and last_prb_non_blanking for Cell${fdd_cell_1}
    ${first_ul_prb_non_blanking_cell2}  ${last_ul_prb_non_blanking_cell2}
    ...              Calculate UL first_prb_non_blanking and last_prb_non_blanking for Cell${fdd_cell_2}
    # add here check UL PRB BLANKING and UL fragmentation (CB008941) and check also prachPrboffset
    # case wo or w PS BWP : prachPrbOffset = msg1FrequencyStart + startPrbInitialUlBwp
    scf.load_scf    ${test_scf_file}
    ${msg1FrequencyStart}	 scf.get_value_from_scf   p_name=msg1FrequencyStart
    ...                                               dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=${fdd_cell_1}    listindex=0
    ${bwp_profile_bwpDN_cell1}=     set Variable     ${cellBwpList_params_list['bwpDN']}
    ${startPrbInitialUlBwp}=     Get startPrbInitialUlBwp Parameters From BWP_PROFILE gNB    CellId=${fdd_cell_1}
    ...                                                                                      bwp_profile=${bwp_profile_bwpDN_cell1}
    # manage the case crbxx
    ${startPrbInitialUlBwp}=    Remove String    ${startPrbInitialUlBwp}    crb
    ${startPrbInitialUlBwp}=    Convert To Integer    ${startPrbInitialUlBwp}
    ${msg1FrequencyStart}=      Convert To Integer    ${msg1FrequencyStart}
    ${prachPrboffset}=     Evaluate     ${msg1FrequencyStart} + ${startPrbInitialUlBwp}
    ${prachPrboffset_cell1}=      Set Variable     ${prachPrboffset}
    Append To File   ${resultFile}
    ...        \n\t[ CELL${fdd_cell_1} ] ===> msg1FrequencyStart=${msg1FrequencyStart} startPrbInitialUlBwp=${startPrbInitialUlBwp}\n
    Append To File   ${resultFile}    \t\t===> prachPrboffset_cell${fdd_cell_1}=${prachPrboffset_cell1}\n
    dated log      Checking UL Fragmentation with PrbBlanking Contraints for CELL${fdd_cell_1}...
    dated log      Checking also if prachPrboffset==${prachPrboffset} in CPRT cellSetup Pcap...
    IF     '${logs_and_traces_flags['CellSetupL2_L3Trace']}'=='True'
        ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${subcellId_fdd_cell_1}
        ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${subcellId_fdd_cell_1}
        ${subcellId_cellDss}=    set variable if   ${variable_exists} and not ${isEmpty}    ${subcellId_fdd_cell_1}    0
       Extract UL Fragmentation Info from cellSetup Pcap  File=${path_to_syscom_cellsetup_initial_pcap}  subcellId=${subcellId_cellDss}
       ...                                                prachPrboffset=${prachPrboffset}
    END
    ${msg1FrequencyStart}	 scf.get_value_from_scf   p_name=msg1FrequencyStart
    ...                                               dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${fdd_cell_2}
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=${fdd_cell_2}    listindex=0
    ${bwp_profile_bwpDN_cell2}=     set Variable     ${cellBwpList_params_list['bwpDN']}
    ${startPrbInitialUlBwp}=     Get startPrbInitialUlBwp Parameters From BWP_PROFILE gNB    CellId=${fdd_cell_2}
    ...                                                                                      bwp_profile=${bwp_profile_bwpDN_cell2}
    # manage the case crbxx
    ${startPrbInitialUlBwp}=    Remove String    ${startPrbInitialUlBwp}    crb
    ${startPrbInitialUlBwp}=    Convert To Integer    ${startPrbInitialUlBwp}
    ${msg1FrequencyStart}=      Convert To Integer    ${msg1FrequencyStart}
    ${prachPrboffset}=     Evaluate     ${msg1FrequencyStart} + ${startPrbInitialUlBwp}
    ${prachPrboffset_cell2}=      Set Variable     ${prachPrboffset}
    Append To File   ${resultFile}
    ...    \n\t[ CELL${fdd_cell_2} ] ===> msg1FrequencyStart=${msg1FrequencyStart} startPrbInitialUlBwp=${startPrbInitialUlBwp}\n
    Append To File   ${resultFile}    \t\t===> prachPrboffset_cell2=${prachPrboffset_cell2}\n
    dated log      Checking UL Fragmentation with PrbBlanking Contraints for CELL${fdd_cell_2}...
    dated log      Checking also if prachPrboffset==${prachPrboffset} in CPRT cellSetup Pcap...
    IF     '${logs_and_traces_flags['CellSetupL2_L3Trace']}'=='True'
        ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${subcellId_fdd_cell_2}
        ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${subcellId_fdd_cell_2}
        ${subcellId_cell2Dss}=    set variable if   ${variable_exists} and not ${isEmpty}    ${subcellId_fdd_cell_2}    1
        Extract UL Fragmentation Info from cellSetup Pcap  File=${path_to_syscom_cellsetup_initial_pcap}  subcellId=${subcellId_cell2Dss}
        ...                                                prachPrboffset=${prachPrboffset}
    END
    Run Keyword If    '${UL_Frag_enable}' == 'True'
    ...        Run Keywords    Run keyword and continue on failure    CB013715_validation.verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking
    ...               filecsv=${testCaseDir}/pcapprocessed_UL_Fragmentation_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId_cellDss}.csv
    ...               first_prb_non_blanking_cell=${first_ul_prb_non_blanking_cell1}
    ...               last_prb_non_blanking_cell=${last_ul_prb_non_blanking_cell1}
    ...           AND          Run keyword and continue on failure    set Test Variable      ${first_ul_prb_PUSCH_cell1}    ${FIRST_PUSCH_PRB}
    ...           AND          Run keyword and continue on failure    set Test Variable      ${last_ul_prb_PUSCH_cell1}     ${LAST_PUSCH_PRB}
    ...           AND          Run keyword and continue on failure    set Test Variable      ${PUCCH_SIZE_cell1}            ${PUCCH_SIZE}
    ...    ELSE    Run Keywords     set test variable    ${TestResult}    UL Fragmentation disable!!!
    ...       AND   Run keyword and continue on failure    set Test Variable  ${first_ul_prb_PUSCH_cell1}    ${first_ul_prb_non_blanking_cell1}
    ...       AND   Run keyword and continue on failure    set Test Variable  ${last_ul_prb_PUSCH_cell1}    ${last_ul_prb_non_blanking_cell1}

    declare Results in Test Results List    Type=CPRT->L2PS: verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking Cell${fdd_cell_1} for Step [${step}]
    ...                                     Result=${TestResult}
    Run Keyword If    '${UL_Frag_enable}' == 'True'
    ...        Run Keywords    Run keyword and continue on failure    CB013715_validation.verify_Cprt_Pcap_for_UL_Fragmentation_w_PRBBLANKING
    ...                               filecsv=${testCaseDir}/pcapprocessed_UL_Fragmentation_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId1.csv
    ...                               first_prb_non_blanking_cell=${first_ul_prb_non_blanking_cell2}
    ...                               last_prb_non_blanking_cell=${last_ul_prb_non_blanking_cell2}
    ...           AND          Run keyword and continue on failure   set Test Variable      ${first_ul_prb_PUSCH_cell2}    ${FIRST_PUSCH_PRB}
    ...           AND          Run keyword and continue on failure   set Test Variable      ${last_ul_prb_PUSCH_cell2}     ${LAST_PUSCH_PRB}
    ...           AND          Run keyword and continue on failure   set Test Variable      ${PUCCH_SIZE_cell2}            ${PUCCH_SIZE}
    ...      ELSE      Run Keywords    set test variable    ${TestResult}    UL Fragmentation disable!!!
    ...               AND   Run keyword and continue on failure  set Test Variable  ${first_ul_prb_PUSCH_cell2}    ${first_ul_prb_non_blanking_cell2}
    ...               AND   Run keyword and continue on failure  set Test Variable  ${last_ul_prb_PUSCH_cell2}     ${last_ul_prb_non_blanking_cell2}
    Run Keyword If    '${UL_Frag_enable}' == 'True'      declare Results in Test Results List
    ...                                    Type=CPRT->L2PS: verify_Cprt_Pcap_for_UL_Fragmentation_w_PrbBlanking Cell${fdd_cell_2} for Step [${step}]
    ...                                    Result=${TestResult}
    # End Of Check UL PRB BLANKING and UL fragmentation

    ${first_prb_non_blanking_cell1}  ${last_prb_non_blanking_cell1}
    ...                                                         Calculate DL first_prb_non_blanking and last_prb_non_blanking for Cell${fdd_cell_1}
    ${first_prb_non_blanking_cell2}  ${last_prb_non_blanking_cell2}
    ...                                                         Calculate DL first_prb_non_blanking and last_prb_non_blanking for Cell${fdd_cell_2}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell1}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL   CellId=${fdd_cell_1}
    ${end_prb_dedicated_bwp_cell1}=    Evaluate      ${nbrOfBlankedPRBsLowEdgeDL_Cell1} + ${BW_Prb_cell1}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell2}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL   CellId=${fdd_cell_2}
    ${end_prb_dedicated_bwp_cell2}=    Evaluate      ${nbrOfBlankedPRBsLowEdgeDL_Cell2} + ${BW_Prb_cell2}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell1}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell2}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell1_int}=         Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL_Cell1}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell1_int}=          Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL_Cell1}
    ${nbrOfBlankedPRBsHighEdgeDL_Cell2_int}=         Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL_Cell2}
    ${nbrOfBlankedPRBsLowEdgeDL_Cell2_int}=          Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL_Cell2}

    ${nbrOfBlankedPRBsLowEdgeUL_Cell1}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL   CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsLowEdgeUL_Cell2}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL   CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsHighEdgeUL_Cell1}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL  CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsHighEdgeUL_Cell2}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL  CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsHighEdgeUL_Cell1_int}=         Convert To Integer    ${nbrOfBlankedPRBsHighEdgeUL_Cell1}
    ${nbrOfBlankedPRBsLowEdgeUL_Cell1_int}=          Convert To Integer    ${nbrOfBlankedPRBsLowEdgeUL_Cell1}
    ${nbrOfBlankedPRBsHighEdgeUL_Cell2_int}=         Convert To Integer    ${nbrOfBlankedPRBsHighEdgeUL_Cell2}
    ${nbrOfBlankedPRBsLowEdgeUL_Cell2_int}=          Convert To Integer    ${nbrOfBlankedPRBsLowEdgeUL_Cell2}

    # BEWARE that these variables are needed for Acceptance criteria based on L1L2 pcap
    set test variable    ${first_prb_non_blanking_cell1}
    set test variable    ${last_prb_non_blanking_cell1}
    set test variable    ${first_prb_non_blanking_cell2}
    set test variable    ${last_prb_non_blanking_cell2}

    ${line}=    Catenate     *****************************************
    Append To File   ${resultFile}   \n\t${line}\n\tverify_TTITraces_for_DL_PRBBLANKING_CELL${fdd_cell_1}\n\t${line}\n
    # update here dll1spcells (list_of_subcells to analyze) and dll1spcells (list_of_non_subcells to remove from of the analysis)
    ${PhysicalCellId}=     Evaluate    ${50}+${fdd_cell_1}-${1}
    ${ret}   ${dll1spcells}    BuiltIn.Run Keyword And Warn On Failure   TARF-Keywords.Get dlsubcellid list for cellId by cell with COAM
    ...                                                                                          oam_alias=coam_gnb
    ...                                                                                          PhysicalCellId1=${PhysicalCellId}
    Set Suite Variable      ${dll1spcells}
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_1} subcell mapping ] list_of_subcells for Cell${fdd_cell_1}=${dll1spcells[0]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_1} subcell mapping ] list_of_non_subcells for Cell${fdd_cell_1}=${dll1spcells[1]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    Run keyword and continue on failure     CB013715_validation.verify_TTITraces_for_DL_PRBBLANKING_CELL1
    ...                                                                         bwpPrb=${BW_Prb_cell1}
    ...                                                                         first_prb_non_blanking_cell1=${first_prb_non_blanking_cell1}
    ...                                                                         last_prb_non_blanking_cell1=${last_prb_non_blanking_cell1}
    ...                                                                         nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL_Cell1_int}
    ...                                                                         nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL_Cell1_int}
    declare Results in Test Results List   Type=Ttitrace: verify_TTITraces_for_DL_PRBBLANKING_CELL${fdd_cell_1} (PDSCH) for Step [${step}]
    ...                                    Result=${TestResult}
    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${fdd_cell_1}
    ...                           connection=coam_gnb
    ${msg}=     catenate     DL Test Acceptance Criteria is [cellid=1 DL PS-BWP BlankedPRBs config] : max nbOfPrb=${BW_Prb_cell1} and
    ...                         range nbOfPrb : ${nbrOfBlankedPRBsLowEdgeDL_Cell1} <= possible
    ...                         non-blanking prb <= ${end_prb_dedicated_bwp_cell1}
    Run Keyword If  '${is_actPowerSavingBWP_enabled}'=='true'      Dated Log    ===> ${msg}
    Run Keyword If  '${is_actPowerSavingBWP_enabled}'=='true'
    ...      dated log     verify_TTITraces_for_DL_PRBBLANKING_BWP_CELL${fdd_cell_1} [PS or small BWP]
    Run Keyword If  '${is_actPowerSavingBWP_enabled}'=='true'      Run keyword and continue on failure
    ...                                     BuiltIn.log    [WARNING] : actPowerSavingBWP disabled
    ${result}      Set Variable If      '${is_actPowerSavingBWP_enabled}'=='true'       ${TestResult}
    ...                                                                                 WARN : actPowerSavingBWP disabled
    declare Results in Test Results List     Type=Ttitrace: verify_TTITraces_for_DL_PRBBLANKING_BWP_CELL${fdd_cell_1} (PDSCH) for Step [${step}]
    ...                                      Result=${result}
    ${line}=    Catenate     *****************************************
    Append To File   ${resultFile}   \n\t${line}\n\tverify_TTITraces_for_DL_PRBBLANKING_CELL${fdd_cell_2}\n\t${line}\n
    # update here dll1spcells (list_of_subcells to analyze) and dll1spcells (list_of_non_subcells to remove from of the analysis)
    ${PhysicalCellId}=     Evaluate    ${50}+${fdd_cell_2}-${1}
    ${ret}   ${dll1spcells_tmp}    BuiltIn.Run Keyword And Warn On Failure   TARF-Keywords.Get dlsubcellid list for cellId by cell with COAM
    ...                                                                                          oam_alias=coam_gnb
    ...                                                                                          PhysicalCellId1=${PhysicalCellId}


    Set Suite Variable      ${dll1spcells}
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_2} subcell mapping ] list_of_subcells for Cell${fdd_cell_2}=${dll1spcells[0]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_2} subcell mapping ] list_of_non_subcells for Cell${fdd_cell_2}=${dll1spcells[1]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    Run keyword and continue on failure     CB013715_validation.verify_TTITraces_for_DL_PRBBLANKING_CELL2
    ...                                                                         bwpPrb=${BW_Prb_cell2}
    ...                                                                         first_prb_non_blanking_cell2=${first_prb_non_blanking_cell2}
    ...                                                                         last_prb_non_blanking_cell2=${last_prb_non_blanking_cell2}
    ...                                                                         nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL_Cell2_int}
    ...                                                                         nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL_Cell2_int}
    declare Results in Test Results List   Type=Ttitrace: verify_TTITraces_for_DL_PRBBLANKING_CELL${fdd_cell_2} (PDSCH) for Step [${step}]
    ...                                    Result=${TestResult}
    ${is_actPowerSavingBWP_enabled}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=actPowerSavingBWP
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${fdd_cell_2}
    ...                           connection=coam_gnb
    ${msg}=     catenate     DL Test Acceptance Criteria is [cellid=${fdd_cell_2} DL PS-BWP BlankedPRBs config] : max nbOfPrb=${BW_Prb_cell2} and
    ...                         range nbOfPrb : ${nbrOfBlankedPRBsLowEdgeDL_Cell2} <= possible
    ...                         non-blanking prb <= ${end_prb_dedicated_bwp_cell2}
    Run Keyword If  '${is_actPowerSavingBWP_enabled}'=='true'     Dated Log    ===> ${msg}
    Run Keyword If  '${is_actPowerSavingBWP_enabled}'=='true'
    ...     dated log     verify_TTITraces_for_DL_PRBBLANKING_BWP_CELL${fdd_cell_2} [PS or small BWP]
    Run Keyword If  '${is_actPowerSavingBWP_enabled}'=='true'     Run keyword and continue on failure
    ...                                     BuiltIn.log    [WARNING] : actPowerSavingBWP disabled
    ${result}      Set Variable If      '${is_actPowerSavingBWP_enabled}'=='true'       ${TestResult}
    ...                                                                                 WARN : actPowerSavingBWP disabled
    declare Results in Test Results List     Type=Ttitrace: verify_TTITraces_for_DL_PRBBLANKING_BWP_CELL${fdd_cell_2} (PDSCH) for Step [${step}]
    ...                                        Result=${result}
    ${ret}    ${msg}=     Run Keyword And Ignore Error     catenate     UL Test Acceptance Criteria is [cellid=${fdd_cell_1}] :
    ...                         range nbOfPrb : ${first_ul_prb_PUSCH_cell1} <= possible
    ...                         non-blanking prb <= ${last_ul_prb_PUSCH_cell1}
    Run Keyword And Ignore Error    Dated Log    ===> ${msg}
    Append To File   ${resultFile}    \n\t===> ${msg}\n
    ${line}=    Catenate     *****************************************
    Append To File   ${resultFile}   \n\t${line}\n\tverify_TTITraces_for_UL_PRBBLANKING_CELL${fdd_cell_1}\n\t${line}\n
    ${ret}    ${msg}=     Run Keyword And Ignore Error     catenate     UL Test Acceptance Criteria is [cellid=${fdd_cell_2}] :
    ...                         range nbOfPrb : ${first_ul_prb_PUSCH_cell2} <= possible
    ...                         non-blanking prb <= ${last_ul_prb_PUSCH_cell2}
    Run Keyword And Ignore Error    Dated Log    ===> ${msg}
    Append To File   ${resultFile}    \t===> ${msg}\n
    # update here ull1spcells (list_of_subcells to analyze) and ull1spcells (list_of_non_subcells to remove from of the analysis)
    ${PhysicalCellId}=     Evaluate    ${50}+${fdd_cell_1}-${1}
    ${ret}   ${ull1spcells}    BuiltIn.Run Keyword And Warn On Failure   TARF-Keywords.Get ulsubcellid list for cellId by cell with COAM
    ...                                                                                          oam_alias=coam_gnb
    ...                                                                                          PhysicalCellId1=${PhysicalCellId}
    Set Suite Variable      ${ull1spcells}
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_1} subcell mapping ] list_of_subcells for Cell${fdd_cell_1}=${ull1spcells[0]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_1} subcell mapping ] list_of_non_subcells for Cell${fdd_cell_1}=${ull1spcells[1]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}
    Run keyword and continue on failure     CB013715_validation.verify_TTITraces_for_UL_PRBBLANKING_CELL1
    ...                                                  bwpPrb=${BW_Prb_cell1}
    ...                                                  first_prb_non_blanking_cell1=${first_ul_prb_PUSCH_cell1}
    ...                                                  last_prb_non_blanking_cell1=${last_ul_prb_PUSCH_cell1}
    ...                                                  nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_Cell1_int}
    ...                                                  nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_Cell1_int}
    declare Results in Test Results List     Type=Ttitrace: verify_TTITraces_for_UL_PRBBLANKING_CELL${fdd_cell_1} (PUSCH) for Step [${step}]
    ...                                      Result=${TestResult}
    ${line}=    Catenate     *****************************************
    Append To File   ${resultFile}   \n\t${line}\n\tverify_TTITraces_for_UL_PRBBLANKING_CELL${fdd_cell_2}\n\t${line}\n
    # update here ull1spcells (list_of_subcells to analyze) and ull1spcells (list_of_non_subcells to remove from of the analysis)
    ${PhysicalCellId}=     Evaluate    ${50}+${fdd_cell_2}-${1}
    ${ret}   ${ull1spcells}    BuiltIn.Run Keyword And Warn On Failure   TARF-Keywords.Get ulsubcellid list for cellId by cell with COAM
    ...                                                                                          oam_alias=coam_gnb
    ...                                                                                          PhysicalCellId1=${PhysicalCellId}
    Set Suite Variable      ${ull1spcells}
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_2} subcell mapping ] list_of_subcells for Cell${fdd_cell_2}=${ull1spcells[0]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_2} subcell mapping ] list_of_non_subcells for Cell${fdd_cell_2}=${ull1spcells[1]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}
    Run keyword and continue on failure     CB013715_validation.verify_TTITraces_for_UL_PRBBLANKING_CELL2
    ...                                                  bwpPrb=${BW_Prb_cell2}
    ...                                                  first_prb_non_blanking_cell2=${first_ul_prb_PUSCH_cell2}
    ...                                                  last_prb_non_blanking_cell2=${last_ul_prb_PUSCH_cell2}
    ...                                                  nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeDL_Cell2_int}
    ...                                                  nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeDL_Cell2_int}
    declare Results in Test Results List     Type=Ttitrace: verify_TTITraces_for_UL_PRBBLANKING_CELL${fdd_cell_2} (PUSCH) for Step [${step}]
    ...                                      Result=${TestResult}
    # check prachPrboffset with PRB Blanking contraints
    ${Cond1}=      Evaluate     ${prachPrboffset_cell1} >= ${first_ul_prb_PUSCH_cell1}
    ${Cond2}=      Evaluate     ${prachPrboffset_cell1} <= ${last_ul_prb_PUSCH_cell1}
    ${Cond3}=      Evaluate     ${prachPrboffset_cell2} >= ${first_ul_prb_PUSCH_cell2}
    ${Cond4}=      Evaluate     ${prachPrboffset_cell2} <= ${last_ul_prb_PUSCH_cell2}
    ${Cond}=       Evaluate     ${Cond1}==${True} and ${Cond2}==${True}
    Run keyword and continue on failure   should be True   ${Cond}==${True}    msg=ERR on prachPrboffset CELL${fdd_cell_1}
    declare Results in Test Results List     Type=check prachPrboffset with PRB Blanking contraints CELL${fdd_cell_1} for Step [${step}]
    ...  Result=${Cond}
    Append To File   ${resultFile}    \t\tprachPrboffset_cell${fdd_cell_1} = ${prachPrboffset_cell1}\n
    ${Cond}=       Evaluate     ${Cond3}==${True} and ${Cond4}==${True}
    Run keyword and continue on failure   should be True   ${Cond}==${True}    msg=ERR on prachPrboffset CELL${fdd_cell_2}
    declare Results in Test Results List     Type=check prachPrboffset with PRB Blanking contraints CELL${fdd_cell_2} for Step [${step}]
    ...  Result=${Cond}
    Append To File   ${resultFile}    \t\tprachPrboffset_cell${fdd_cell_2} = ${prachPrboffset_cell2}\n
    coam.get_current_scf_file      local_dir_path=${testCaseDir}    file_name=SCF_configurationAndRuntimeObjects_${tm}.xml
    ...                            connection=coam_gnb  timeout=${600}   export_type=configurationAndRuntimeObjects
    ...                            parameters_save_variant=actualValues
    scf.load_scf	 ${testCaseDir}/SCF_configurationAndRuntimeObjects_${tm}.xml
    ${pucchConfig_params_list}    Create List    pucchSize
    ${pucchConfig_params_list_dict}    CB013715_tools.get_feature_parameters_from_scf    ${testCaseDir}/SCF_configurationAndRuntimeObjects_${tm}.xml
    ...       ${pucchConfig_params_list}
    ...       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${fdd_cell_1}    pucchConfig
    dated log     ${pucchConfig_params_list_dict} for NRCELL-${fdd_cell_1}
    ${line}=    Catenate     *********
    Append To File   ${resultFile}   \n\t${line}\n\tpucchSize\n\t${line}\n
    Append To File   ${resultFile}    \t\t--------> ${pucchConfig_params_list_dict} for NRCELL-${fdd_cell_1}\n
    # add check of PUCCH size
    IF     '${UL_Frag_enable}' == 'True'
        ${Cond}=    Evaluate     '${pucchConfig_params_list_dict['pucchSize']}' == '${PUCCH_SIZE_cell1}'
        Run keyword and continue on failure   Should be True   '${pucchConfig_params_list_dict['pucchSize']}' == '${PUCCH_SIZE_cell1}'
        ...                              msg=${consTraceColorRed}PUCCH SIZE For Cell${fdd_cell_1} should be ${PUCCH_SIZE_cell1}${defColor}
        declare Results in Test Results List     Type=check PUCCH SIZE For Cell${fdd_cell_1} for Step [${step}]     Result=${Cond}
    ELSE
        declare Results in Test Results List     Type=check PUCCH SIZE For Cell${fdd_cell_1} for Step [${step}]
        ...                                      Result=NOT AVAILABLE! [ UL_Frag disable ]
    END
    ${pucchConfig_params_list_dict}    CB013715_tools.get_feature_parameters_from_scf    ${testCaseDir}/SCF_configurationAndRuntimeObjects_${tm}.xml
    ...       ${pucchConfig_params_list}
    ...       MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${fdd_cell_2}    pucchConfig
    dated log     ${pucchConfig_params_list_dict} for NRCELL-${fdd_cell_2}
    Append To File   ${resultFile}    \t\t--------> ${pucchConfig_params_list_dict} for NRCELL-${fdd_cell_2}\n
    # add check of PUCCH size
    IF     '${UL_Frag_enable}' == 'True'
        ${Cond}=    Evaluate     '${pucchConfig_params_list_dict['pucchSize']}' == '${PUCCH_SIZE_cell2}'
        Run keyword and continue on failure   Should be True   '${pucchConfig_params_list_dict['pucchSize']}' == '${PUCCH_SIZE_cell2}'
        ...                              msg=${consTraceColorRed}PUCCH SIZE For Cell${fdd_cell_2} should be ${PUCCH_SIZE_cell2}${defColor}
        declare Results in Test Results List     Type=check PUCCH SIZE For Cell${fdd_cell_2} for Step [${step}]     Result=${Cond}
    ELSE
        declare Results in Test Results List     Type=check PUCCH SIZE For Cell${fdd_cell_2} for Step [${step}]
        ...                                      Result=NOT AVAILABLE! [ UL_Frag disable ]
    END
    dated log     =====> CB013715_validation.verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL${fdd_cell_1} for CELL${fdd_cell_1}
    ${line}=    Catenate     ***********************************************
    Append To File   ${resultFile}   \n\t${line}\n\tverify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL${fdd_cell_1}\n\t${line}\n
    Append To File   ${resultFile}
    ...       \n\t=====> CB013715_validation.verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL${fdd_cell_1} for CELL${fdd_cell_1}\n
    ${firt_prb_non_blanking_csirs_cell1}=    Evaluate     ${nbrOfBlankedPRBsLowEdgeDL_Cell1_int} - ${1}
    ${last_prb_non_blanking_csirs_cell1}=    Evaluate    ${BW_Prb_cell1} - ${nbrOfBlankedPRBsHighEdgeDL_Cell1_int}
    # update here dll1spcells (list_of_subcells to analyze) and dll1spcells (list_of_non_subcells to remove from of the analysis)
    ${PhysicalCellId}=     Evaluate    ${50}+${fdd_cell_1}-${1}
    ${ret}   ${dll1spcells}    BuiltIn.Run Keyword And Warn On Failure   TARF-Keywords.Get dlsubcellid list for cellId by cell with COAM
    ...                                                                                          oam_alias=coam_gnb
    ...                                                                                          PhysicalCellId1=${PhysicalCellId}
    Set Suite Variable      ${dll1spcells}
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_1} subcell mapping ] list_of_subcells for Cell${fdd_cell_1}=${dll1spcells[0]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    ${msg}=    BuiltIn.Catenate    [ CELL${fdd_cell_1} subcell mapping ] list_of_non_subcells for Cell${fdd_cell_1}=${dll1spcells[1]}
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    Run keyword and continue on failure     CB013715_validation.verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL1
    ...                                                                         bwpPrb=${BW_Prb_cell1}
    ...                                                                         first_prb_non_blanking_cell1=${firt_prb_non_blanking_csirs_cell1}
    ...                                                                         last_prb_non_blanking_cell1=${last_prb_non_blanking_csirs_cell1}
    ...                                                                         nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL_Cell1_int}
    ...                                                                         nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL_Cell1_int}
    declare Results in Test Results List   Type=Ttitrace: verify_TTITraces_for_CSIRS_DL_PRBBLANKING_CELL${fdd_cell_1} (CSIRS) for Step [${step}]
    ...                                    Result=${TestResult}
    # wo actLongPucchResourceOpt
    # CELL1 : sr 1prb + harq 8 prb + pcsi 6 prb = 15 x 2 = 30 prb
    # CELL2 : sr 1prb + harq 8 prb + pcsi 1 prb = 10 x 2 = 20 prb
    # w actLongPucchResourceOpt
    # CELL1 : sr 1prb + harq 8 prb + pcsi 7 prb = 16 x 2 = 32 prb
    # CELL2 : sr 1prb + harq 8 prb + pcsi 1 prb = 10 x 2 = 20 prb


Extract UL Fragmentation Info from cellSetup Pcap
    [Arguments]                     ${File}      ${subcellId}=0     ${w_display}=False     ${prachPrboffset}=116
    [Documentation]                 Display Cell Mapping Info from CPRT -> L2PS in GNB_CPRT_NODE Pcap

    ${tm}=    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}
    Dated log                   Extract UL Fragmentation Info from CPRT -> L2PS in GNB_CPRT_NODE PCAP file ${File} for subcellId${subcellId}

    set test variable    ${pcapprocessed_Display_CPRT}    pcapprocessed_UL_Fragmentation_itf_l2_ps_cell_CellSetupReq_CPRT.txt
    set test variable    ${pcapprocessed_Display_CPRT_path}    ${testCaseDir}/${pcapprocessed_Display_CPRT}
    # -Y "icom_5g"
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && itf_l2_ps_cell_cellsetupreq" -e _ws.col.Info
    ...           -e itf_l2_ps_cell_CellSetupReq_t.physCellId -e 3gpp.subcellid
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr1Prb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr2Prb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartHarq1Prb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartHarq2Prb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartPcsi1Prb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartPcsi2Prb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumSrPrb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumHarqPrb
    ...           -e itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchNumPcsiPrb
    ...           -E header=y -E separator=';' > ${pcapprocessed_Display_CPRT_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   _ws.col.Info
    ${pattern}=     set variable     itf_l2_ps_cell_CellSetupReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/pcapprocessed_UL_Fragmentation_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...       ${testCaseDir}/pcapprocessed_UL_Fragmentation_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId}_${tm}.csv

    set test variable    ${pcapprocessed_Display_CPRT}    pcapprocessed_UL_Fragmentation_itf_l2_ps_cell_CellSetupReq_CPRT.txt
    set test variable    ${pcapprocessed_Display_CPRT_path}    ${testCaseDir}/${pcapprocessed_Display_CPRT}
    # -Y "icom_5g"
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && itf_l2_ps_cell_cellsetupreq" -e _ws.col.Info
    ...           -e itf_l2_ps_cell_CellSetupReq_t.physCellId -e 3gpp.subcellid
    ...           -e itf_l2_ps_cell_Bwp.cellBwpId
    ...           -e itf_l2_ps_cell_Bwp.bwpType
    ...           -e itf_l2_ps_cell_BwpDefinitionUl.bandwidth
    ...           -e itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item
    ...           -e itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item
    ...           -e itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item
    ...           -e itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item
    ...           -E header=y -E separator=';' > ${pcapprocessed_Display_CPRT_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   _ws.col.Info
    ${pattern}=     set variable     itf_l2_ps_cell_CellSetupReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/pcapprocessed_Read_Dynamic_PUSCH_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...      ${testCaseDir}/pcapprocessed_Read_Dynamic_PUSCH_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId}_${tm}.csv

    set test variable    ${pcapprocessed_Display_CPRT}    pcapprocessed_prachoffset_itf_l2_ps_cell_CellSetupReq_CPRT.txt
    set test variable    ${pcapprocessed_Display_CPRT_path}    ${testCaseDir}/${pcapprocessed_Display_CPRT}
    # -Y "icom_5g"
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && itf_l2_ps_RachConfig.prachPrbOffset == ${prachPrboffset}" -e _ws.col.Info
    ...           -e itf_l2_ps_cell_CellSetupReq_t.physCellId -e 3gpp.subcellid
    ...           -e itf_l2_ps_RachConfig.prachPrbOffset
    ...           -e itf_l2_ps_RachConfig.prachConfigurationIndex
    ...           -E header=y -E separator=';' > ${pcapprocessed_Display_CPRT_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   _ws.col.Info
    ${pattern}=     set variable     itf_l2_ps_cell_CellSetupReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   ${pattern}
    run keyword if  len($extract)==len($extract_col_info)     fail   ${pattern} not found because prachPrbOffset not OK (${prachPrboffset})
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/pcapprocessed_prachoffset_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...       ${testCaseDir}/pcapprocessed_prachoffset_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId}_${tm}.csv

    # display Dynamic PUSCH info
    dated log     ==========> display Dynamic PUSCH info
    ${long_pucch_start_dyn_pusch_prb}   ${long_pucch_num_dyn_pusch_prb}  CB013715_validation.display_dynamic_pusch
    ...                             ${testCaseDir}/pcapprocessed_Read_Dynamic_PUSCH_itf_l2_ps_cell_CellSetupReq_CPRT_subcellId${subcellId}.csv
    dated log      long_pucch_start_dyn_pusch_prb=${long_pucch_start_dyn_pusch_prb}
    dated log      long_pucch_num_dyn_pusch_prb=${long_pucch_num_dyn_pusch_prb}
    # add here check of longPucchStartDynPuschPrb_item with PRB Blanking contraints => to do later!!!

Generate Test Verdict For Prb Blanking L1l2 pcap with ${verify_with_scenario}
    ${step}=     Set Variable     MAIN STEP
    BuiltIn.log      scenario=${verify_with_scenario}
    return from keyword if     '${logs_and_traces_flags['BIPTrace']['L1L2BIPTrace']}'=='False'
    return from keyword if     '${w_check_l1l2_pcap_prb_contraint}'=='False'    PASS
    # get ${BW_Prb_cell1} and ${BW_Prb_cell2}
    get BW Prb    verify_with_scenario=${verify_with_scenario}
    dated log     pcap_full_paths=${pcap_full_paths}
    ${pcapFileNbr}=    get length    ${pcap_full_paths}
    run keyword if    '${pcapFileNbr}' != '1'     BuiltIn.Log   more than one l1l2 pcap file are present!!!  level=ERROR
    ${pcapFile}=   get From List   ${pcap_full_paths}  0

    Append To File   ${resultFile}
    ...        \n**********************************\nTest Verdict PrbBlanking L1l2 pcap\n**********************************\n

    ${nbrOfBlankedPRBsHighEdgeUL}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL   CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsLowEdgeUL}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL    CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsHighEdgeUL_int}=    Convert To Integer    ${nbrOfBlankedPRBsHighEdgeUL}
    ${nbrOfBlankedPRBsLowEdgeUL_int}=     Convert To Integer    ${nbrOfBlankedPRBsLowEdgeUL}
    ${nbrOfBlankedPRBsHighEdgeUL}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL   CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsLowEdgeUL}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL    CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}=      Convert To Integer    ${nbrOfBlankedPRBsHighEdgeUL}
    ${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}=       Convert To Integer    ${nbrOfBlankedPRBsLowEdgeUL}

    ${nbrOfBlankedPRBsHighEdgeDL}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsLowEdgeDL}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL    CellId=${fdd_cell_1}
    ${nbrOfBlankedPRBsHighEdgeDL_int}=    Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL_int}=     Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL}
    ${nbrOfBlankedPRBsHighEdgeDL}=    TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsLowEdgeDL}=     TARF-Keywords.Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL    CellId=${fdd_cell_2}
    ${nbrOfBlankedPRBsHighEdgeDL_int_Cell2}=      Convert To Integer    ${nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL_int_Cell2}=       Convert To Integer    ${nbrOfBlankedPRBsLowEdgeDL}

    # BEWARE : to improve LATER    subcellId <=> CellId relation
    ${list_of_ue_per_cell_to_be_attached}=    template.get_attach_list_per_cell  scenario_name=${verify_with_scenario}
    nps_tarf_tools.log_to_console_with_time_prefix    list_of_ue_per_cell_to_be_attached=${list_of_ue_per_cell_to_be_attached}    level=INFO
    ${cell2_exists}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${list_of_ue_per_cell_to_be_attached}    2
    IF    ${cell2_exists}
        ${is_CELL_2_exits_in_JSON}=    set variable    ${True}
        ${text}     set variable     is_CELL_2_exits_in_JSON=${is_CELL_2_exits_in_JSON} => analysis is NOT bypassed.
    ELSE
        ${is_CELL_2_exits_in_JSON}=    set variable    ${False}
        ${text}     set variable     is_CELL_2_exits_in_JSON=${is_CELL_2_exits_in_JSON} => analysis is bypassed!
    END
    nps_tarf_tools.log_to_console_with_time_prefix    ${text}        level=INFO
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${subcellId_fdd_cell_1}
    ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${subcellId_fdd_cell_1}
    ${subcellId_cellDss}=    set variable if   ${variable_exists} and not ${isEmpty}    ${subcellId_fdd_cell_1}    0
    ${UlData_PucchReceiveReq_not_present_Cell1}=     Extract UL PRB Blanking Info from L1L2 Pcap   File=${pcapFile}    subcellId=${subcellId_cellDss}
    IF    ${is_CELL_2_exits_in_JSON}
        ${UlData_PucchReceiveReq_not_present_Cell2}=     Extract UL PRB Blanking Info from L1L2 Pcap   File=${pcapFile}    subcellId=1
    END
    dated log       =====> CB013715_validation.verify_Pcap_for_pucchResources_UL_PRBBLANKING for CELL1
    Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_pucchResources_UL_PRBBLANKING for CELL1\n
    Run Keyword If     ${UlData_PucchReceiveReq_not_present_Cell1}==${False}     Run keyword and continue on failure
    ...                 CB013715_validation.verify_Pcap_for_pucchResources_UL_PRBBLANKING
    ...                 filecsv=${testCaseDir}/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId${subcellId_cellDss}.csv
    ...                 bwpPrb=${BW_Prb_cell1}
    ...                 nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int}
    ...                 nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int}
    ...     ELSE      dated log   =====> no pucchResources check because UlData_PucchReceiveReq not present in pcap For CELL1
    ${TestResult}=    Set Variable If     ${UlData_PucchReceiveReq_not_present_Cell1}==${True}    WARNING : UlData_PucchReceiveReq_not_present_Cell1
    ...                                                                                           ${TestResult}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_pucchResources_UL_PRBBLANKING Cell1 for Step [${step}]
    ...                                      Result=${TestResult}
    IF     ${is_CELL_2_exits_in_JSON}
        dated log       =====> CB013715_validation.verify_Pcap_for_pucchResources_UL_PRBBLANKING for CELL2
        Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_pucchResources_UL_PRBBLANKING for CELL2\n
        Run Keyword If     ${UlData_PucchReceiveReq_not_present_Cell2}==${False}     Run keyword and continue on failure
        ...               CB013715_validation.verify_Pcap_for_pucchResources_UL_PRBBLANKING
        ...                            filecsv=${testCaseDir}/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId1.csv
        ...                            bwpPrb=${BW_Prb_cell2}
        ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}
        ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}
        ...     ELSE      dated log   =====> no pucchResources check because UlData_PucchReceiveReq not present in pcap For CELL2
        ${TestResult}=   Set Variable If   ${UlData_PucchReceiveReq_not_present_Cell2}==${True}   WARNING : UlData_PucchReceiveReq_not_present_Cell2
        ...                                                                                          ${TestResult}
        declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_pucchResources_UL_PRBBLANKING Cell2 for Step [${step}]
        ...                                      Result=${TestResult}
    ELSE
        declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_pucchResources_UL_PRBBLANKING Cell2 for Step [${step}]
        ...                                      Result=CELL2 not present in JSON!
    END

    dated log       =====> CB013715_validation.verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING for CELL1
    Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING for CELL1\n
    Run keyword and continue on failure     CB013715_validation.verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId${subcellId_cellDss}_expand.csv
    ...                            bwpPrb=${BW_Prb_cell1}
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING Cell1 for Step [${step}]
    ...                                      Result=${TestResult}
    IF     ${is_CELL_2_exits_in_JSON}
        dated log       =====> CB013715_validation.verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING for CELL2
        Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING for CELL2\n
        Run keyword and continue on failure     CB013715_validation.verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING
        ...                            filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId1_expand.csv
        ...                            bwpPrb=${BW_Prb_cell2}
        ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}
        ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}
        declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING Cell2 for Step [${step}]
        ...                                      Result=${TestResult}
    ELSE
        declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_UlData_PuschReceiveReq_PRBBLANKING Cell2 for Step [${step}]
        ...                                      Result=CELL2 not present in JSON!
    END

    Extract DL PRB Blanking Info from L1L2 Pcap     File=${pcapFile}    subcellId=${subcellId_cellDss}
    IF     ${is_CELL_2_exits_in_JSON}
        Extract DL PRB Blanking Info from L1L2 Pcap     File=${pcapFile}    subcellId=1
    END

    # BEWARE that
    # first_prb_non_blanking_cell1, last_prb_non_blanking_cell1 are intialized in TtiTrace postprocess Kw
    # first_prb_non_blanking_cell2, last_prb_non_blanking_cell2 are intialized in TtiTrace postprocess Kw
    dated log       =====> CB013715_validation.verify_Pcap_for_DL_PRBBLANKING for CELL1
    Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_DL_PRBBLANKING for CELL1\n
    robot_extension.Run Keyword And Warn On Failure     CB013715_validation.verify_Pcap_for_DL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId${subcellId_cellDss}.csv
    ...                            bwpPrb=${BW_Prb_cell1}
    ...                            first_prb_non_blanking_cell=${first_prb_non_blanking_cell1}
    ...                            last_prb_non_blanking_cell=${last_prb_non_blanking_cell1}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_DL_PRBBLANKING Cell1 for Step [${step}]
    ...                                      Result=${TestResult}

    IF     ${is_CELL_2_exits_in_JSON}
        dated log       =====> CB013715_validation.verify_Pcap_for_DL_PRBBLANKING for CELL2
        Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_DL_PRBBLANKING for CELL2\n
        robot_extension.Run Keyword And Warn On Failure     CB013715_validation.verify_Pcap_for_DL_PRBBLANKING
        ...                            filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId1.csv
        ...                            bwpPrb=${BW_Prb_cell2}
        ...                            first_prb_non_blanking_cell=${first_prb_non_blanking_cell2}
        ...                            last_prb_non_blanking_cell=${last_prb_non_blanking_cell2}
        declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_DL_PRBBLANKING Cell2 for Step [${step}]
        ...                                      Result=${TestResult}
    ELSE
        declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_DL_PRBBLANKING Cell2 for Step [${step}]
        ...                                      Result=CELL2 not present in JSON!
    END

    dated log       =====> CB013715_validation.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl for CELL1
    Append To File   ${resultFile}    \n\t=====> CB013715_validation.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl for CELL1\n
    robot_extension.Run Keyword And Warn On Failure     CB013715_validation.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl
    ...                                  filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId${subcellId_cellDss}.csv
    ...                                  bwpPrb=${BW_Prb_cell1}
    ...                                  nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL_int}
    ...                                  nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL_int}
    declare Results in Test Results List     Type=L1L2Bip: run_PDSCH_prb_blanking_overlap_analysis_pcap_dl Cell1 for Step [${step}]
    ...                                      Result=${TestResult}
    IF     ${is_CELL_2_exits_in_JSON}
        dated log       =====> CB013715_validation.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl for CELL2
        Append To File   ${resultFile}    \n\t=====> CB013715_validation.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl for CELL2\n
        robot_extension.Run Keyword And Warn On Failure     CB013715_validation.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl
        ...                                         filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId1.csv
        ...                                         bwpPrb=${BW_Prb_cell2}
        ...                                         nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL_int_Cell2}
        ...                                         nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL_int_Cell2}
        declare Results in Test Results List     Type=L1L2Bip: run_PDSCH_prb_blanking_overlap_analysis_pcap_dl Cell2 for Step [${step}]
        ...                                      Result=${TestResult}
    ELSE
        declare Results in Test Results List     Type=L1L2Bip: run_PDSCH_prb_blanking_overlap_analysis_pcap_dl Cell2 for Step [${step}]
        ...                                      Result=CELL2 not present in JSON!
    END

    return from Keyword

    # CSIRS and TRS check only based on TtiTrace !!!! code below not tested!
    dated log       =====> CB013715_validation.verify_Pcap_for_csirssendreq_DL_PRBBLANKING for CELL1
    Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_csirssendreq_DL_PRBBLANKING for CELL1\n
    Run keyword and continue on failure    CB013715_validation.verify_Pcap_for_csirssendreq_DL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_csirssendreq_subcellId${subcellId_cellDss}.csv
    ...                            bwpPrb=${BW_Prb_cell1}
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeDL_int}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeDL_int}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_csirssendreq_DL_PRBBLANKING Cell1 for Step [${step}]
    ...                                      Result=${TestResult}

    dated log       =====> CB013715_validation.verify_Pcap_for_csirssendreq_DL_PRBBLANKING for CELL2
    Append To File   ${resultFile}    \n\t=====> CB013715_validation.verify_Pcap_for_csirssendreq_DL_PRBBLANKING for CELL2\n
    Run keyword and continue on failure    CB013715_validation.verify_Pcap_for_csirssendreq_DL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_csirssendreq_subcellId1.csv
    ...                            bwpPrb=${BW_Prb_cell2}
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeDL_int_Cell2}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeDL_int_Cell2}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_csirssendreq_DL_PRBBLANKING Cell2 for Step [${step}]
    ...                                      Result=${TestResult}

Extract DL PRB Blanking Info from L1L2 Pcap
    [Arguments]                     ${File}    ${subcellId}=0   ${w_display}=False
    [Documentation]                 Extract PRB Blanking Info from L1L2 Pcap

    ${tm}=    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}
    ${nb_packets}=     set variable     ${50000}
    Dated log     Extract DL PRB Blanking Info from L1L2 Pcap file ${File} for subcellId${subcellId} [first ${nb_packets} packets]

    set test variable    ${pcapprocessed_Display_l1l2}    pcapprocessed_PRB_Blanking_dldata_pdschsendreq.txt
    set test variable    ${pcapprocessed_Display_l1l2_path}    ${testCaseDir}/${pcapprocessed_Display_l1l2}
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && dldata_pdschsendreql1sw" -e _ws.col.Info
    ...           -e 3gpp.sfn -e 3gpp.slot -e 3gpp.subcellid
    ...           -e DlData_PdschGrantL1sw.startPrb
    ...           -e DlData_PdschGrantL1sw.numOfPrb
    ...           -e DlData_PdschGrantL1sw.rat0Bitmap
    ...           -e 3gpp.rnti
    ...           -e DlData_PdschGrantL1sw.rbgSize
    ...           -e DlData_PdschGrantL1sw.rbgSizeFirst
    ...           -E header=y -E separator=';' -c ${nb_packets} > ${pcapprocessed_Display_l1l2_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   _ws.col.Info
    ${pattern}=     set variable     DlData_PdschSendReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...                          ${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...         ${testCaseDir}/${postprocess_results}/pcapprocessed_PRB_Blanking_dldata_pdschsendreq_subcellId${subcellId}_${tm}.csv

    set test variable    ${pcapprocessed_Display_l1l2}    pcapprocessed_PRB_Blanking_dldata_csirssendreq.txt
    set test variable    ${pcapprocessed_Display_l1l2_path}    ${testCaseDir}/${pcapprocessed_Display_l1l2}

    # dldata_csirssendreql1sw
    # csiRsResources_item_0 (DlData_CsiRsResourceL1sw_t)
    # trsInfo (l1_common_csiRsTrsInfo_t): DISABLED (0)
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && dldata_csirssendreql1sw" -e _ws.col.Info
    ...           -e 3gpp.sfn -e 3gpp.slot -e 3gpp.subcellid
    ...           -e DlData_CsiRsResourceL1sw_t.startPrb
    ...           -e DlData_CsiRsResourceL1sw_t.numOfPrb
    ...           -e DlData_CsiRsResourceL1sw_t.trsInfo
    ...           -e 3gpp.rnti
    ...           -E header=y -E separator=';' -c ${nb_packets} > ${pcapprocessed_Display_l1l2_path}
    Run       ${cmd_mcshark}
    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   _ws.col.Info
    ${pattern}=     set variable     DlData_CsiRsSendReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...                          ${testCaseDir}/pcapprocessed_PRB_Blanking_dldata_csirssendreq_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...        ${testCaseDir}/${postprocess_results}/pcapprocessed_PRB_Blanking_dldata_csirssendreq_subcellId${subcellId}_${tm}.csv


Extract UL PRB Blanking Info from L1L2 Pcap
    [Arguments]                     ${File}    ${subcellId}=0   ${w_display}=False
    [Documentation]                 Extract UL PRB Blanking Info from L1L2 Pcap

    ${tm}=    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}
    ${nb_packets}=     set variable     ${50000}
    Dated log     Extract UL PRB Blanking Info from L1L2 Pcap file ${File} for subcellId${subcellId} [first ${nb_packets} packets]

    set test variable    ${pcapprocessed_Display_l1l2}    pcapprocessed_PRB_Blanking_uldata_puschreceivereq.txt
    set test variable    ${pcapprocessed_Display_l1l2_path}    ${testCaseDir}/${pcapprocessed_Display_l1l2}
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && uldata_puschreceivereq" -e _ws.col.Info
    ...           -e 3gpp.sfn -e 3gpp.slot -e 3gpp.subcellid
    ...           -e UlData_puschReceiveReqGrant_t.startPrb
    ...           -e UlData_puschReceiveReqGrant_t.numOfPrb
    ...           -e 3gpp.rnti
    ...           -E header=y -E separator=';' -c ${nb_packets} > ${pcapprocessed_Display_l1l2_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   _ws.col.Info
    ${pattern}=     set variable     UlData_PuschReceiveReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...                          ${testCaseDir}/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...        ${testCaseDir}/${postprocess_results}/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId${subcellId}_${tm}.csv

    ${pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId_expand}=    ExpandcsvFile.expand_file
    ...    ${testCaseDir}/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId${subcellId}.csv
    set suite variable     ${pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId_expand}

    set test variable    ${pcapprocessed_Display_l1l2}    pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq.txt
    set test variable    ${pcapprocessed_Display_l1l2_path}    ${testCaseDir}/${pcapprocessed_Display_l1l2}
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && uldata_pucchreceivereql1sw" -e _ws.col.Info
    ...           -e 3gpp.sfn -e 3gpp.slot -e 3gpp.subcellid
    ...           -e 3gpp.rnti
    ...           -e UlData_pucchReceiveReqSubcellL1sw_t.pucchResources.Length
    ...           -e UlData_pucchReceiveReqPucchResourceL1sw_t.pucchFormat
    ...           -e UlData_pucchReceiveReqPucchResourceL1sw_t.startPrb
    ...           -e UlData_pucchReceiveReqPucchResourceL1sw_t.numOfPrb
    ...           -e UlData_pucchReceiveReqPucchResourceL1sw_t.initialCyclicShift
    ...           -e UlData_pucchReceiveReqPucchResourceL1sw_t.nANPucch
    ...           -e UlData_eCpriPucchResourceAllocationStructureL1sw_t.startPrb
    ...           -e UlData_eCpriPucchResourceAllocationStructureL1sw_t.numPrb
    ...           -E header=y -E separator=';' -c ${nb_packets} > ${pcapprocessed_Display_l1l2_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   _ws.col.Info
    ${pattern}=     set variable     UlData_PucchReceiveReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   ${pattern}
    # run keyword if  len($extract)==0 and '${subcellId}'=='0'     fail   ${pattern} not found
    # run keyword if  len($extract)==0    robot_extension.Run Keyword And Warn On Failure    fail   ${pattern} not found for subcellId${subcellId}
    robot_extension.Run Keyword And Warn On Failure    should Not be True     len($extract)==0    msg=${pattern} not found for subcellId${subcellId}
    ${UlData_PucchReceiveReq_not_present}=        Evaluate      len($extract)==0
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...                          ${testCaseDir}/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...  ${testCaseDir}/${postprocess_results}/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId${subcellId}_${tm}.csv

    # extract prachprboffset from uldata_prachreceivereq
    set test variable    ${pcapprocessed_Display_l1l2}    pcapprocessed_prachoffset_uldata_prachreceivereq.txt
    set test variable    ${pcapprocessed_Display_l1l2_path}    ${testCaseDir}/${pcapprocessed_Display_l1l2}
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && uldata_prachreceivereq" -e _ws.col.Info
    ...           -e 3gpp.sfn -e 3gpp.slot -e 3gpp.subcellid
    ...           -e UlData_prachReceiveReqSubcell_t.prachPrbOffset
    ...           -e 3gpp.rnti
    ...           -E header=y -E separator=';' -c ${nb_packets} > ${pcapprocessed_Display_l1l2_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   _ws.col.Info
    ${pattern}=     set variable     UlData_PrachReceiveReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found for subcell${subcellId}
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...                          ${testCaseDir}/pcapprocessed_prachoffset_uldata_prachreceivereq_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...       ${testCaseDir}/${postprocess_results}/pcapprocessed_prachoffset_uldata_prachreceivereq_subcellId${subcellId}_${tm}.csv

    # extract startPrb and numOfPrb from uldata_pucchreceiveresppsl1sw
    # UlData_PucchReceiveRespPsL1sw_t
    # subcells_item_0 (UlData_pucchReceiveRespPsSubcellL1sw_t)
    # pucchResources_item_0 (UlData_pucchReceiveRespPsPucchResourceL1sw_t)
    set test variable    ${pcapprocessed_Display_l1l2}    pcapprocessed_uldata_pucchreceiveresppsl1sw.txt
    set test variable    ${pcapprocessed_Display_l1l2_path}    ${testCaseDir}/${pcapprocessed_Display_l1l2}
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && uldata_pucchreceiveresppsl1sw" -e _ws.col.Info
    ...           -e 3gpp.sfn -e 3gpp.slot -e 3gpp.subcellid
    ...           -e 3gpp.rnti
    ...           -e UlData_pucchReceiveRespPsPucchResourceL1sw_t.startPrb
    ...           -e UlData_pucchReceiveRespPsPucchResourceL1sw_t.numOfPrb
    ...           -e UlData_pucchReceiveRespPsPucchResourceL1sw_t.pucchFormat
    ...           -e UlData_pucchReceiveRespPsPucchResourceL1sw_t.initialCyclicShift
    ...           -e UlData_pucchReceiveRespPsPucchResourceL1sw_t.crc
    ...           -e UlData_pucchReceiveRespPsPucchResourceL1sw_t.dtx
    ...           -E header=y -E separator=';' -c ${nb_packets} > ${pcapprocessed_Display_l1l2_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   _ws.col.Info
    ${pattern}=     set variable     UlData_PucchReceiveRespPsL1sw
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found for subcell${subcellId}
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...                          ${testCaseDir}/pcapprocessed_uldata_pucchreceiveresppsl1sw_subcellId${subcellId}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...       ${testCaseDir}/${postprocess_results}/pcapprocessed_uldata_pucchreceiveresppsl1sw_subcellId${subcellId}_${tm}.csv

    # combine uldata_puschreceivereq and uldata_prachreceivereq
    set test variable    ${pcapprocessed_Display_l1l2}    pcapprocessed_PRB_Blanking_uldata_puschreceivereq_uldata_prachreceivereq.txt
    set test variable    ${pcapprocessed_Display_l1l2_path}    ${testCaseDir}/${pcapprocessed_Display_l1l2}
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "3gpp.subcellid == ${subcellId} && (uldata_puschreceivereq or uldata_prachreceivereq)" -e _ws.col.Info
    ...           -e 3gpp.sfn -e 3gpp.slot -e 3gpp.subcellid
    ...           -e UlData_puschReceiveReqGrant_t.startPrb
    ...           -e UlData_puschReceiveReqGrant_t.numOfPrb
    ...           -e UlData_prachReceiveReqSubcell_t.prachPrbOffset
    ...           -e 3gpp.rnti
    ...           -E header=y -E separator=';' -c ${nb_packets} > ${pcapprocessed_Display_l1l2_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   _ws.col.Info
    ${pattern}=     set variable     UlData_PuschReceiveReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_l1l2_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    ${filename}=    set variable    pcapprocessed_PRB_Blanking_uldata_puschreceivereq_uldata_prachreceivereq_subcellId${subcellId}
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...                          ${testCaseDir}/${filename}.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_l1l2_path}
    ...  ${testCaseDir}/${postprocess_results}/${filename}_${tm}.csv

    [Return]        ${UlData_PucchReceiveReq_not_present}

