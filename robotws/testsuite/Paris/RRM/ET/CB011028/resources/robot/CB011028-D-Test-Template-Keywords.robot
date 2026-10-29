*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   CB011028-D-Test-Template-Common-Keywords
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : christophe.samson@nokia.com
...               Creation Date               : 09-12-2023
...               Modified Date               : 09-12-2023
...               Last Modified by            : christophe.samson@nokia.com
...               Version   Date          Author                                   Notes
...               0.1       09-12-2023    christophe.samson@nokia.com              Creation
# --------------------------------------------------------------------------------------------------------------------------------------------------

*** Variables ***

*** Keywords ***

TC CB011028
    [Documentation]
    ...     test template for CB011028
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_11028_PARAMS}=${NIDD_9890_Q_L_PARAMS}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009890
    ...                     ${kw Check SCF parameters}=verify_SCF_Paramaters
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${Kw TestLine Preparation}=TL_Preparation_CB009890_SCF_CB006915_CFG_1
    ...                     ${Json test configuration}=${EMPTY}

    Init Sequence           ${param}
    Create Header Csv Tput Test result
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_11028_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009890 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Step         Run Keyword     ${kw Set RAD Params}

    # Set NIDD PARAM If Needed
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}'        ${kw NIDD Set}   list=${NIDD_11028_PARAMS}
    # return from Keyword

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_11028_PARAMS}

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...           Critical Step    CB011028-D-Keywords.Deploy Vendor File Config     vendor_param=${vendor_custom}
    # ...                                                                            is_perform_full_commissioning=${False}
    ...                                                                              is_perform_full_commissioning=${True}
    ...   ELSE    run Keywords     Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    # ...               AND          My Restart Gnb Classical    isOAMRebooted=False     F1waitTime=4min
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB011028-D-Keywords.Set Reset Loop Counter

    # return from Keyword
    Display NRRIM_PROFILE-1 NIDD param

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB011028-D-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Check l1Subpool Assignment in Syslogs

    # Prepare the delta files
    ${originalScfFile}      OAM Get SCF File    file=SCF-original.xml
    ${deltaCreateFile}      Replace String      ${originalScfFile}    original    create
    ${deltaDeleteFile}      Replace String      ${originalScfFile}    original    delete

    # Configure new ue's dynamically
    ${initial_NbOfUe}       get length          ${dict_ues}
    Run Keyword If          ${initial_NbOfUe} < ${param.totalNbOfUe}    Configure New Ues         ${dict_ues}
    ...                                                                                           ${initial_NbOfUe}
    ...                                                                                           ${param.totalNbOfUe}
    ...                                                                                           ${dict_settings_ue_default}

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_11028_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB011028-Common-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'         Step      Captures CB009890 Init   prefix=CellSetup.Attach.SA.Traffic
    Run Keyword if   '${w_generic_capture}' == 'True'         Step      Captures Start      actionCORE=${isCaptureCORE}
    ...                                                                                     actionCPRT=${isCaptureCPRT}
    ...                                                                                     actionL1L2=${isCaptureL1L2}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}
    Run Keyword if    ${w_Basic_Call_to_Setup_Wtsemu} == ${True}      Modify Ue Capa for WTS    ue_nr_capa_value=${ue_nr_capabilities_SRS_w_VOIP_SA}

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    set test variable    ${dll1spcells[0]}
    set test variable    ${dll1spcells[1]}
    set test variable    ${ull1spcells[0]}
    set test variable    ${ull1spcells[1]}

    ${num_of_cells_string}=    Convert to String    ${num_of_cells}
    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}    UE Cell Setup Check       nbCell=${num_of_cells_string}
    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB011028-Common-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009890 Stop

    ${tti_trace_path}    ${tti_trace_dict}=    run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ...               Process TTI Traces    Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}

    ${FilePkl}=           run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle   ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${L1L2_Pcap_File}=   run Keyword if     '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0'    Get L1L2 traces
    ...                                                                                 time=${GetL1L2TraceTime}
    ...                                                                                 prefix=L1L2Bip.wDLTput
    ...                                                                                 msg=take BIP L1L2 traces with DL Tput
    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

    # add here Specific Check based on L1l2Bip pcap
    run Keyword if   '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0' and '${kw Specific Check}'!='${EMPTY}'
    ...          Step      ${kw Specific Check}     pcapFilename=${L1L2_Pcap_File}.pcap
    ...                                             depends=CallSetup.Launch PDU Session

    # Generate Verdict...
    run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'      Step      Generate Test Verdict
    ...                                                                                                         ${FilePkl}   ${vendor_custom}
    ...                                                                                                         ${dictExpectedValues}
    ...                                                                                                         ${kw Check SCF parameters}

    # Capture Sherpa
    set test variable   ${TEST NAME OK}   ${TEST NAME}
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    ${TEST NAME}     Catenate      SherpaTraces-${GetSherpaTraceTime}-${tm}
    set test variable     ${TEST NAME}
    Run Keyword If    '${enable_sherpa}' == 'True'         Run Keywords    Step      Activate Sherpa
    ...    AND        Step                      Sleep with duration "${GetSherpaTraceTime}"s and msg "Sherpa pcap Traces"
    ...    AND        Step                      Private Deactivate Sherpa and Stop Collect     desired_storage_directory=${testCaseDir}
    ...                                                                                        keep_pcap_file=${True}
    ...    AND        Run Keyword And Ignore Error      Upload and decode sherpa pcap files    Sherpa_logs_local_path=${testCaseDir}
    ...                                                                                keep_pcap_file=${True}     duration=0
    ...    AND        Run Keyword And Ignore Error      Calling Panda Extract Csv For PRB Pooling
    set Test variable   ${TEST NAME}    ${TEST NAME OK}
    Run Keyword If    '${enable_sherpa}' == 'True'      set test variable     ${path_traces_Sherpa}    ${sherpa_output_path}

    # Generate Verdict...
    Run Keyword If    '${enable_sherpa}' == 'True'   Step      Generate Test Verdict Using Sherpa
    ...                                                                 path_traces_Sherpa=${path_traces_Sherpa}
    ...                                                                 depends=Private Deactivate Sherpa and Stop Collect

    # if  '${ENABLE_CHECK_COUNTERS}'=='1' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait 15 min
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${ENABLE_CHECK_COUNTERS}'=='1'
    robot_extension.Run Keyword And Warn On Failure      CB009890-A-Common-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Teardow Kw

TC CB011078 D
    [Documentation]
    ...     test template for CB009890
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_11028_PARAMS}=${EMPTY}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009890
    ...                     ${kw Check SCF parameters}=verify_SCF_Paramaters
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${Kw TestLine Preparation}=TL_Preparation_CB009890_SCF_CB006915_CFG_1
    ...                     ${Json test configuration}=${EMPTY}

    Init Sequence           ${param}
    Create Header Csv Tput Test result
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_11028_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009890 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}

    # Set NIDD PARAM If Needed
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}'        ${kw NIDD Set}   list=${NIDD_11028_PARAMS}
    # return from Keyword

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_11028_PARAMS}

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword
    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    ...           Critical Step    CB011028-D-Keywords.Deploy Vendor File Config     vendor_param=${vendor_custom}
    # ...                                                                            is_perform_full_commissioning=${False}
    ...                                                                              is_perform_full_commissioning=${True}
    ...   ELSE    run Keywords     Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    # ...               AND          My Restart Gnb Classical    isOAMRebooted=False     F1waitTime=4min
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB011028-D-Keywords.Set Reset Loop Counter
    # return from Keyword

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB011028-D-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Check l1Subpool Assignment in Syslogs

    # Prepare the delta files
    ${originalScfFile}      OAM Get SCF File    file=SCF-original.xml
    ${deltaCreateFile}      Replace String      ${originalScfFile}    original    create
    ${deltaDeleteFile}      Replace String      ${originalScfFile}    original    delete

    # Configure new ue's dynamically
    ${initial_NbOfUe}       get length          ${dict_ues}
    Run Keyword If          ${initial_NbOfUe} < ${param.totalNbOfUe}    Configure New Ues         ${dict_ues}
    ...                                                                                           ${initial_NbOfUe}
    ...                                                                                           ${param.totalNbOfUe}
    ...                                                                                           ${dict_settings_ue_default}

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_11028_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB011028-Common-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'         Step      Captures CB009890 Init   prefix=CellSetup.Attach.SA.Traffic
    Run Keyword if   '${w_generic_capture}' == 'True'         Step      Captures Start      actionCORE=${isCaptureCORE}
    ...                                                                                     actionCPRT=${isCaptureCPRT}
    ...                                                                                     actionL1L2=${isCaptureL1L2}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}
    Run Keyword if   ${w_Basic_Call_to_Setup_Wtsemu} == ${True}      Modify Ue Capa for WTS    ue_nr_capa_value=${ue_nr_capabilities_SRS_w_VOIP_SA}
    # Run Keyword if   ${w_Basic_Call_to_Setup_Wtsemu} == ${True}      Modify Ue Capa for WTS
    # ...                                                                       ue_nr_capa_value=${ue_nr_capabilities_SRS_w_VOIP_SA_w_PUSCH_OneLayer}

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    set test variable    ${dll1spcells[0]}
    set test variable    ${dll1spcells[1]}
    set test variable    ${ull1spcells[0]}
    set test variable    ${ull1spcells[1]}

    ${num_of_cells_string}=    Convert to String    ${num_of_cells}
    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}    UE Cell Setup Check       nbCell=${num_of_cells_string}
    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB011028-Common-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009890 Stop

    ${tti_trace_path}    ${tti_trace_dict}=    run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ...               Process TTI Traces    Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}

    ${FilePkl}=           run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for CB011028
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${L1L2_Pcap_File}=   run Keyword if     '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0'    Get L1L2 traces
    ...                                                                                 time=${GetL1L2TraceTime}
    ...                                                                                 prefix=L1L2Bip.wDLTput
    ...                                                                                 msg=take BIP L1L2 traces with DL Tput
    # add here Specific Check based on L1l2Bip pcap
    run Keyword if   '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0' and '${kw Specific Check}'!='${EMPTY}'
    ...          Step      ${kw Specific Check}     capture=${L1L2_Pcap_File}.pcap
    ...                                             depends=CallSetup.Launch PDU Session
    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap
    # Generate Verdict...
    run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'      Step      Generate Test Verdict
    ...                                                                                                         ${FilePkl}   ${vendor_custom}
    ...                                                                                                         ${dictExpectedValues}
    ...                                                                                                         ${kw Check SCF parameters}

    # Capture Sherpa
    set test variable   ${TEST NAME OK}   ${TEST NAME}
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    ${TEST NAME}     Catenate      SherpaTraces-${GetSherpaTraceTime}-${tm}
    set test variable     ${TEST NAME}
    Run Keyword If    '${enable_sherpa}' == 'True'         Run Keywords    Step      Activate Sherpa
    ...    AND        Step                      Sleep with duration "${GetSherpaTraceTime}"s and msg "Sherpa pcap Traces"
    ...    AND        Step                      Private Deactivate Sherpa and Stop Collect     desired_storage_directory=${testCaseDir}
    ...                                                                                        keep_pcap_file=${True}
    ...    AND        Run Keyword And Ignore Error      Upload and decode sherpa pcap files    Sherpa_logs_local_path=${testCaseDir}
    ...                                                                                keep_pcap_file=${True}     duration=0
    ...    AND        Run Keyword And Ignore Error      Calling Panda Extract Csv For PRB Pooling
    set Test variable   ${TEST NAME}    ${TEST NAME OK}
    Run Keyword If    '${enable_sherpa}' == 'True'      set test variable     ${path_traces_Sherpa}    ${sherpa_output_path}

    # Generate Verdict...
    Run Keyword If    '${enable_sherpa}' == 'True'   Step      Generate Test Verdict Using Sherpa
    ...                                                                 path_traces_Sherpa=${path_traces_Sherpa}
    ...                                                                 depends=Private Deactivate Sherpa and Stop Collect

    # if  '${ENABLE_CHECK_COUNTERS}'=='1' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait 15 min
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${ENABLE_CHECK_COUNTERS}'=='1'
    robot_extension.Run Keyword And Warn On Failure      CB011028-D-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Teardow Kw

TC CB011028-D PS BWP switch scenario
    [Documentation]
    ...     test template for CB011028
    ...     Conditions:     it is based on the arguments ${param}  ${dictParam}  ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for multi-ues on different cells with DL traffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${dictParam}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}
    ...                     ${kw Set RAD Params}=${EMPTY}
    ...                     ${kw NIDD Set}=${EMPTY}
    ...                     ${kw NIDD Check}=${EMPTY}
    ...                     ${kw Set TestMode}=${EMPTY}
    ...                     ${kw Specific Set TestMode Before Attach}=${EMPTY}
    ...                     ${kw Specific Set TestMode After Attach}=${EMPTY}
    ...                     ${NIDD_11028_PARAMS}=${EMPTY}
    ...                     ${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}=Convert TTI trace from csv to dict CB009890
    ...                     ${kw Check SCF parameters}=verify_SCF_Paramaters
    ...                     ${kw Specific Check}=${EMPTY}
    ...                     ${Kw TestLine Preparation}=TL_Preparation_CB009890_SCF_CB006915_CFG_1
    ...                     ${Json test configuration}=${EMPTY}

    Init Sequence           ${param}
    Create Header Csv Tput Test result
    Run Keyword If    '${Json test configuration}'!='${EMPTY}'    load Json test data   ${Json test configuration}   ${dict_ues}
    ...                                                                                 ${vendor_custom}   ${param}
    StringTool.printLineWithTitle     title=Display NIDD PARAMETERS of the Test TO SET
    FOR    ${item}    IN    @{NIDD_11028_PARAMS}
         continue for loop if     'list_name' in ${item}
         ${msg_display}=    StringTool.getHeaderLine    ${item}[dist_name]/${item}[pname]     ${item}[value]
         dated log      ${msg_display}
         # dated log    dist_name=${item}[dist_name] pname=${item}[pname] value=${item}[value]
    END
    StringTool.printLineWithTitle     title=-
    Step         Init CB009890 Test Variables    vendor_custom=${vendor_custom}    dict_ues=${dict_ues}    totalNbOfUe=${param.totalNbOfUe}
    Run Keyword If    '${kw Set RAD Params}'!='${EMPTY}'     Step         Run Keyword     ${kw Set RAD Params}

    # Set NIDD PARAM If Needed
    Run Keyword If    '${kw NIDD Set}'!='${EMPTY}'        ${kw NIDD Set}   list=${NIDD_11028_PARAMS}
    # return from Keyword

    # Check if NIDD PARAM are as expected
    Run Keyword If    '${kw NIDD Check}'!='${EMPTY}'      ${kw NIDD Check}  list=${NIDD_11028_PARAMS}

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1' and '${UPDATE_SCF}'=='1'
    ...                          Run Keywords       ${Kw TestLine Preparation}      output_scf=${test_scf_file}
    ...                              AND            Set Suite Variable              ${test_scf_file}
    # return from Keyword

    # iPHY gscn update depending of chBwDl
    # get gscn for CELL1 from SCF
    ${gscn_cell1}          coam_parameter.get_single_value_from_scf_file
    ...                           parameter=gscnOrSsPbchArfcn
    ...                           dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                           connection=coam_gnb
    Dated Log      iPHY gscn update with ${gscn_cell1} for CELL1
    Step           CB011028-D-Keywords.Set Context_AP IPHY gscn Cell1 with ${gscn_cell1}

    ${filter}     set Variable    bbHwVariant=ASOE&&csSize=48&&direction=DL&&l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Symm
    @{PARAMS_IN_VENDOR}    Create List
    ...     bbL1SpPrbInitCapacity:maxNumLayerPrbL1Sp=${vendor_custom.maxNumLayerPrbL1Sp}|${filter}
    ...     bbL1SpPrbInitCapacity:maxNumStreamPrbL1Sp=${vendor_custom.maxNumStreamPrbL1Sp}|${filter}
    set test variable     ${PARAMS_IN_VENDOR}

    ${DeployVendorFileKwName}=     Set Variable If    '${w_Delta_apply_vendorFile}'=='0'
    ...                                                           CB011028-D-Keywords.Deploy Vendor File Config
    ...                                                           CB011028-D-Keywords.Deploy Vendor File to activate CB011028
    ${vendor_custom_to_apply}=     Set Variable If    '${w_Delta_apply_vendorFile}'=='0'      ${vendor_custom}
    ...                                                                                       ${PARAMS_IN_VENDOR}

    Run Keyword if     '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='1'
    # ...           Critical Step    CB011028-D-Keywords.Deploy Vendor File Config     vendor_param=${vendor_custom}
    # ...                                                                              is_perform_full_commissioning=${True}
    ...           Critical Step    ${DeployVendorFileKwName}     vendor_param=${vendor_custom_to_apply}
    ...                                                          is_perform_full_commissioning=${True}
    ...   ELSE    run Keywords     Dated Log new line       ${consTraceColorRed}BEWARE that Deploy Vendor File Config is already DONE!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=4min
    ...                                                     GNBCallback=CB011028-D-Keywords.Set Reset Loop Counter
    # return from Keyword

    ${ret}   ${bts_status}=  run Keyword and ignore Error     get bts status with COAM     oam_alias=coam_gnb
    dated log    get bts status with COAM return is ${ret.lower()} with bts_status=${bts_status.lower()}
    Run Keyword If     '${ret.lower()}'=='pass' and '${bts_status.lower()}'!='configured'   Run Keywords
    ...         Dated Log new line       ${consTraceColorRed}bts status is not Configured [current state is ${bts status}]!!! ${defColor}
    ...               AND          Dated Log                ${consTraceColor}=== Restart TL === ${defColor}
    ...               AND          Restart TL               isOAMRebooted=False     F1waitTime=10min
    ...                                                     GNBCallback=CB011028-D-Keywords.Set Reset Loop Counter

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER Commissioning / TL Restart${defColor}
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs
    robot_extension.Run Keyword And Warn On Failure         Check l1Subpool Assignment in Syslogs

    robot_extension.Run Keyword And Warn On Failure        coam.download_vendor_file
    ...                                                            target_file_name=${testCaseDir}/vendor_5g_used_for_11028_test.xml
    ...                                                            connection=coam_gnb

    robot_extension.Run Keyword And Warn On Failure        Display NRRIM_PROFILE-1 NIDD param
    robot_extension.Run Keyword And Warn On Failure        Display PRB POOLING NIDD param

    # Prepare the delta files
    ${originalScfFile}      OAM Get SCF File    file=SCF-original.xml
    ${deltaCreateFile}      Replace String      ${originalScfFile}    original    create
    ${deltaDeleteFile}      Replace String      ${originalScfFile}    original    delete

    # Configure new ue's dynamically
    ${initial_NbOfUe}       get length          ${dict_ues}
    Run Keyword If          ${initial_NbOfUe} < ${param.totalNbOfUe}    Configure New Ues         ${dict_ues}
    ...                                                                                           ${initial_NbOfUe}
    ...                                                                                           ${param.totalNbOfUe}
    ...                                                                                           ${dict_settings_ue_default}

    # save some test parameters as vendor file or Ue settings into ${testCaseDir}
    nps_11028_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${vendor_custom}    filename=data_test.json

    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Configure the setting for the ${param.totalNbOfUe} UEs
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        Set To Dictionary             ${current_ueSetting}          trf_id              1
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}
        Set To Dictionary             ${current_ueSetting}          size                ${dict_ues[${current_id}].packet_size}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
        Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
        Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
        Set To Dictionary             ${current_ueSetting}          protocol               ${dict_ues[${current_id}].protocol}

        Append To List                ${listOfUes}                  ${current_ueSetting}

        # save some test parameters as vendor file or Ue settings into ${testCaseDir}
        add_dictionary_to_json       ${testCaseDir}     'Ue_${current_ue}'   ${current_ueSetting}    data_test.json
    END
    # Dated Log New Line                UE_List=${listOfUes}
    display_list_parameters_w_name      ${listOfUes}   name=Ue   msg=Display Of listOfUes
    CB011028-Common-Keywords.Check Multi Ues Setting In List        multiUesList=${listOfUes}

    set test Variable     ${listOfUes}
    Run Keyword if   '${w_generic_capture}' == 'True'         Step      Captures CB009890 Init   prefix=CellSetup.Attach.SA.Traffic
    Run Keyword if   '${w_generic_capture}' == 'True'         Step      Captures Start      actionCORE=${isCaptureCORE}
    ...                                                                                     actionCPRT=${isCaptureCPRT}
    ...                                                                                     actionL1L2=${isCaptureL1L2}

    # ${kw Set TestMode} is a robot Kw that allow to modify cfg file
    Run Keyword If    '${kw Set TestMode}'!='${EMPTY}'       ${kw Set TestMode}
    Run Keyword if   ${w_Basic_Call_to_Setup_Wtsemu} == ${True}      Modify Ue Capa for WTS    ue_nr_capa_value=${ue_nr_capabilities_SRS_w_VOIP_SA}
    # Run Keyword if   ${w_Basic_Call_to_Setup_Wtsemu} == ${True}      Modify Ue Capa for WTS
    # ...                                                                       ue_nr_capa_value=${ue_nr_capabilities_SRS_w_VOIP_SA_w_PUSCH_OneLayer}

    # to take Emil CPLANE traces
    robot_extension.Run Keyword And Warn On Failure     CB011028-D-Keywords.Start collect log by gnb tool    command=./gnb_logs 192.168.255.1 -E -f0

    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}
    ...         Critical Step           Basic Call to Setup Wtsemu SA           nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${True}
    # ...                                                             Kw_TM=${kw Set TestMode}
    ...   ELSE
    ...         Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             nbCell=${param.totalNbOfCell}
    ...                                                             bypassX2Setup=${True}
    ...                                                             shouldUseLua=${True}
    ...                                                             list_of_UE_tobe_created=${listOfUes}
    ...                                                             bypassSIB=${False}

    dated log      ${consTraceColorBgYellow}${consTraceColorBlack}------> Display Bbrm info from SysLogs AFTER CellSetup${defColor}
    robot_extension.Run Keyword And Warn On Failure         Check l1Subpool Assignment in Syslogs
    robot_extension.Run Keyword And Warn On Failure         Display Bbrm configuration from Syslogs

    ${num_of_cells}=    Get Cell Number
    Critical Step       Wait gNB cells 5g On air    ${num_of_cells}

    ${ret}   ${dll1spcells}    robot_extension.Run Keyword And Warn On Failure         Get dlsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    ${ret}   ${ull1spcells}    robot_extension.Run Keyword And Warn On Failure         Get ulsubcellid for cellId by spool with COAM
    ...                                                                                                                 oam_alias=coam_gnb
    Set Suite Variable      ${dll1spcells}
    Set Suite Variable      ${ull1spcells}
    dated log   dlsubcellSpool0List=${dll1spcells[0]}
    dated log   dlsubcellSpool1List=${dll1spcells[1]}
    dated log   ulsubcellSpool0List=${ull1spcells[0]}
    dated log   ulsubcellSpool1List=${ull1spcells[1]}
    # set test variable    ${dll1spcells[0]}
    # set test variable    ${dll1spcells[1]}
    # set test variable    ${ull1spcells[0]}
    # set test variable    ${ull1spcells[1]}

    ${num_of_cells_string}=    Convert to String    ${num_of_cells}
    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${True}    UE Cell Setup Check       nbCell=${num_of_cells_string}
    Run Keyword if      ${w_Basic_Call_to_Setup_Wtsemu} == ${False}   Step                      CallSetup.WTS Set X2 Link

    Run Keyword If      '${kw Specific Set TestMode Before Attach}'!='${EMPTY}'
    ...                                                    Step   Run specific keywords before attach : ${kw Specific Set TestMode Before Attach}

    Step      Set SSB Beam

    # Register and launch PDU for all the ue's except for which define on the deleted cell
    FOR    ${current_elem}    IN    @{listOfUes}
        # Run Keyword If      ${current_elem.target_cells} != ${nrCell}    Run Keywords
        Run Keywords
        ...                 Critical Step       CallSetup UE register UeId "${current_elem.ue}" on Target cell "${current_elem.target_cells}"
        ...                                     depends=CallSetup.Setup Wtsemu SA
        ...    AND
        ...                 Critical Step     CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                                   depends=CallSetup UE register UeId
    END

    Run Keyword If    '${kw Specific Set TestMode After Attach}'!='${EMPTY}'
    ...                                                   Step   Run specific keywords after attach : ${kw Specific Set TestMode After Attach}

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput} > ${0}    DL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.DL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.DL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session

        ${dir}=   set Variable If    ${current_elem.UL_throughput} > ${0}    UL
        ...                                                                  NONE
        ${kw to run}=   Catenate   ${dir} Traffic SA Not Stopped with "${current_elem.UL_throughput}"Mbps "${param.duration}"s duration
        ...                        and "${param.deviation}" percent deviation with "${current_elem.protocol}" protocol
        Run Keyword If      ${current_elem.UL_throughput} > ${0}
        ...      Critical Step     ${kw to run}       depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=   CB011028-Common-Keywords.Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If    ${current_elem.DL_throughput_GBR} > ${0}    Run Keywords
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
        ...    AND
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                                  depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        set test variable   ${current_elem}
        ${dir}=   set Variable If    ${current_elem.DL_throughput_GBR} > ${0}    DL
        ...                                                                      NONE
        ${kw to run}=   Catenate    ${dir} Traffic GBR SA Not Stopped with "${current_elem.DL_throughput_GBR}"Mbps "${param.duration}"s duration
        ...                         and "${param.deviation}" percent deviation
        Run Keyword If      '${current_elem.DL_throughput_GBR}' != '0'
        ...    Critical Step   ${kw to run}    depends=CallSetup.Launch PDU Session
    END

    Run Keyword if   '${w_generic_capture}' == 'True'       Step        Captures CB009890 Stop

    # add switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1
    Step      Run DL traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1

    # to force Ue Tput display for Ue1 !!!
    Set To Dictionary             ${listOfUes[0]}          DL_throughput      100k

    Wait '10s' for stability

    Step      Set SSB Beam Recovery for UE1
    # add switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE1
    Step      Run DL traffic then run smaller traffic to switch to PS-BWP for UE1

    robot_extension.Run Keyword And Warn On Failure    CB011028-D-Keywords.Stop collect log by gnb tool

    # to take Emil CPLANE traces with Tput
    robot_extension.Run Keyword And Warn On Failure     CB011028-D-Keywords.Start collect log by gnb tool    command=./gnb_logs 192.168.255.1 -E -f0
    Wait '10s' for stability
    robot_extension.Run Keyword And Warn On Failure    CB011028-D-Keywords.Stop collect log by gnb tool

    ${tti_trace_path}    ${tti_trace_dict}=    run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ...               Process TTI Traces    Kw_Convert_TtiTrace_From_csv_to_Dict=${Kw_Convert_TtiTrace_From_csv_to_Dict_Test}

    ${FilePkl}=           run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ...      Run keyword and continue on failure      Convert TTI Traces to Dataframe and store as pickle for CB011028
    ...                                                                                                     ttitraceFilename=ttitrace_streaming.pcap
    ...                                                                                                     ttitracepath=${tti_trace_path}

    ${L1L2_Pcap_File}=   run Keyword if     '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0'
    ...      Run keyword and continue on failure      Get L1L2 traces      time=${GetL1L2TraceTime}
    ...                                                                    prefix=L1L2Bip.wDLTput
    ...                                                                    msg=take BIP L1L2 traces with DL Tput
    # add here Specific Check based on L1l2Bip pcap
    run Keyword if   '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0' and '${kw Specific Check}'!='${EMPTY}'
    ...          Step      ${kw Specific Check}     capture=${L1L2_Pcap_File}.pcap
    ...                                             depends=CallSetup.Launch PDU Session
    run Keyword if   '${L1L2_Pcap_File}' != 'None'      Run Keywords     Dated log    gzip -f ${L1L2_Pcap_File}.pcap
    ...                                                         AND      Run    gzip -f ${L1L2_Pcap_File}.pcap

   # Generate Verdict...
    run Keyword if   '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'      Step      Generate Test Verdict
    ...                                                                                                         ${FilePkl}   ${vendor_custom}
    ...                                                                                                         ${dictExpectedValues}
    ...                                                                                                         ${kw Check SCF parameters}

    Step       Check PRB Assignment CB011028-D FdSched NbrPrb Based TtiTrace        FilePcap=ttitrace_streaming.pcap
    ...                                                                             ttitracepath=${tti_trace_path}

    # Capture Sherpa
    set test variable   ${TEST NAME OK}   ${TEST NAME}
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    ${TEST NAME}     Catenate      SherpaTraces-${GetSherpaTraceTime}-${tm}
    set test variable     ${TEST NAME}
    Run Keyword If    '${enable_sherpa}' == 'True'         Run Keywords    Step      Activate Sherpa
    ...    AND        Step                      Sleep with duration "${GetSherpaTraceTime}"s and msg "Sherpa pcap Traces"
    ...    AND        Step                      Private Deactivate Sherpa and Stop Collect     desired_storage_directory=${testCaseDir}
    ...                                                                                        keep_pcap_file=${True}
    ...    AND        Run Keyword And Ignore Error      Upload and decode sherpa pcap files    Sherpa_logs_local_path=${testCaseDir}
    ...                                                                                keep_pcap_file=${True}     duration=0
    ...    AND        Run Keyword And Ignore Error      Calling Panda Extract Csv For PRB Pooling
    set Test variable   ${TEST NAME}    ${TEST NAME OK}
    Run Keyword If    '${enable_sherpa}' == 'True'      set test variable     ${path_traces_Sherpa}    ${sherpa_output_path}

    # Generate Verdict...
    Run Keyword If    '${enable_sherpa}' == 'True'   Step      Generate Test Verdict Using Sherpa
    ...                                                                 path_traces_Sherpa=${path_traces_Sherpa}
    ...                                                                 depends=Private Deactivate Sherpa and Stop Collect

    # if  '${ENABLE_CHECK_COUNTERS}'=='1' => 'Display PDSCH and PUSCH ue_stats_nr for UEList' allow to Wait 15 min
    Run Keyword And Ignore Error     Display PDSCH and PUSCH ue_stats_nr for UEList   UEsList=${listOfUes}    file=${csv_file_tput_results}

    # Collect PM only if  '${ENABLE_CHECK_COUNTERS}'=='1'
    robot_extension.Run Keyword And Warn On Failure      CB011028-D-Keywords.Collect PM Counters and process throughput using PM counters

    # to bypass UE Deregister if needed
    @{listOfUes}    run Keyword if    '${w_ue_detach}' == 'False'    Create List
    ${len}=   Get Length   ${listOfUes}
    run Keyword if    '${len}' != '${0}'    Step    Traced Sleep   duration=3s   msg=deregistering     depends=CallSetup.UE Register
    # Deregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END
    [Teardown]   Teardow Kw

# ------------------------------------------------------------------------------------------------------------------------------------


