*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB012733 step A
...               Test Case Scenario author   : axel.gouilly-frossard@nokia.com
...               Test Case Scenario contact  : axel.gouilly-frossard@nokia.com
...               Test Case automation author : axel.gouilly-frossard@nokia.com
...               Test Case automation contact: axel.gouilly-frossard@nokia.com
...               Creation Date               : 1-february-2026
...               Last Modified by            :
...               Modification:
...                       1-february-2026   | Creation
...

Library            taf.sbts.oam.coam.admin             WITH NAME      sbts_coam
Library            ../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter

Library            taf.wts.runner                          WITH NAME    wtsemu
Library            Dialogs

Resource          ../../../../resources/SWENG/robot/Connect.robot
Resource          ../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../resources/SWENG/robot/KPIs.robot

Resource          ../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../resources/SWENG/robot/TtiConvertInterface.robot
Resource          ../../../../resources/SWENG/robot/TtiAnalysisInterface.robot


*** Variables ***

${path_to_json}                      /home/ute/Downloads/TTI.json    # internal usage for decoding TTI pcap
${gnb_alias}                         gnb_under_test

${CB012733_constraints}          testsuite/Paris/RRM/ET/CB012733/config/CB012733_constraints.csv

${gp_duration}                       300

${egatelogoutput}       ${True}


*** Keywords ***

CB012733 Setup With Custom Config
    [Documentation]
    ...     Actions:     Apply customized configuration then launch cell setup.
    ...     Parameters:  SCF: customized SCF
    ...                  CFG: customized basic CFG file
    ...                  IPHY: airphone iphy file
    ...                  rdParam: list of RAD parameters
    ...                  vendorParam: list of vendor parameters
    ...     Return:      None
    [Arguments]              ${SCF}    ${CFG}=${EMPTY}
    # ...                      ${IPHY}=${EMPTY}     ${rdParam}=${EMPTY}    ${vendorParam}=${EMPTY}

    setup.Apply Custom Config
    ...      scfc=${SCF}
    ...      cfg=${CFG}
    # ...      iphy=${IPHY}
    # ...      rad_params=@{rdParam}
    # ...      vendor_params=@{vendorParam}

CB012733 Configuration SCF Delta
    [Documentation]               Dedicated KW to add use a delta commissioning file
    ...                           configure cell2 with specific parameters for CB012733-A test case

    [Arguments]                   ${12733_delta_file}     ${gnb_alias}

    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias}

    Dated Log New Line            delta_file=${12733_delta_file}
    # Apply delta scf
    coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${12733_delta_file}
    ...                           connection=${gnb_alias}

    OAM wait available
    sbts_coam.teardown            connection=${gnb_alias}

CB012733 Test Teardown

    [Documentation]     This is the common teardown for all test cases of CB012733-A. It will be executed after each test case.
    Get Snapshot
    setup.Suite Teardown

CB12733_LaunchWTS
    [Arguments]            ${luafile}

    Dated Log              Starting LaunchWTS
    ${alias}               SSH Wait For Connect                    host=${HOST_EPCSIM}
    # WTS Clear              #Stop WTSEmu, kill eDaemon and eGate processes, and purge WTS logs  toomuch already done on Restart.Restart TL
    WTS Start processes    telnet_egate_addr=${tl.core.default_ssh_connection_details.addr}

    Dated Log              LaunchWTS cfg file= ${luafile}
    wtsemu.sim_cfg         file=${luafile}
    ...                    entry=run_configuration(3600)
    Dated Log              LaunchWTS Waiting CHANGE STATE: ACTIVE - SimMode is ready now
    Flush Egate Console Buffer    # Flush the buffer to be sure to have all egate console log
    wtsemu.Read Wtsemu Output Until Re
	...                    expected=CHANGE STATE: ACTIVE - SimMode is ready now
	...                    timeout=300
	sleep                  30s

CB012733_A_Feature_activation_static

    [Documentation]     The purpose of this test case is to perform a basic check for feature actThreeSymbolPdcch
    ...                 with a simple configuration of Cell2 with 40MHz BW and 50 UEs, and to validate the workflow
    ...                 of capturing and analyzing TTI traces in CB012733 test case.


    Init Sequence           "CB012733_A_Feature_activation_static"

    # Dated Log New Line              ---> Restart TL
    # Critical Step               Restart TL

    Dated Log New Line              ---> WTS setup SA
    Critical Step          CB12733_LaunchWTS        luafile=${basic_cf_12733}

    Critical Step          CB012733 Check MIB SIB

    sleep                  20s

    Critical step            CB012733 LaunchTraffic

    Step                     CB012733 start TTI Capture       suffix=
    Traced Sleep             duration=10s                      msg=start DL UL traffic TTI capture...
    Step                     CB012733 stop TTI Capture        suffix=trace
    Traced Sleep             duration=30s                     msg=stop TTI waiting for 60seconds
	Step                     CB012733 TTI Post Processing   	TTIpcap=${TTIpcap}
    Step                     CB012733 Format and check TTI Trace
    Step                     CB012733 Format TTI Trace Combined DL UL   ${TTIcsv_decoded}

    Dated Log New Line     Step 3: Analyzing formatted TTI CSV file to check StartSymbol values for DL and UL
    Dated Log              TTI post processing completed. Formatted TTI CSV file: ${outputFilePath_full}
    Step                   CB012733 Count Unique StartSymbol Per SFN Slot Group    ${outputFilePath_full}
    #Dated Log              Unique_symbol to check SFN/slot ${analysis_result}

    @{sfn_slot_eq_3}=      CB012733 Get SFN Slot Where Count Equals    ${analysis_result}    3
    Dated Log              SFN;SLOT with value=3 : @{sfn_slot_eq_3}

    Step                   CB012733 Check StartSymbol Rules Per Slot    ${outputFilePath_full}

    ${zoi}                          ZOI Start
    ${zoi_end_remain}=              ZOI Remaining Sec           ${zoi}
    ${start_loop_remaining}=        Evaluate                    ${zoi_end_remain} - ${GP_DEF}


        # To be sure to have a GP fully filled with the same events inside every loop and avoid changing KPIs/counters:
        # If ZOI start is T0, ZOI end is T0 + ${GUARD_DELAY_DEF} + ${GP_DEF} + ${PM_AVAIL_DELAY_DEF}
        # So, test is started at the beginning of the GP before ZOI end, so:
        # ZOI End - ${GP_DEF}
        # Ex. 1: ZOI start is 10h02 => ZOI End is 10h02 + 40s (GUARD_DELAY_DEF) + 1 GP + 1 mn (PM_AVAIL_DELAY_DEF)
        #        => Time for next GP for ZOI End is 10h11, so test is started at 10h06 and KPIs retrieved at 10h11
        # Ex. 2: ZOI start is 10h14:40s => ZOI End is 10h14:40 + 40s (GUARD_DELAY_DEF) + 1 GP + 1 mn (PM_AVAIL_DELAY_DEF)
        #        => Time for next GP for ZOI End is 10h26 as gaurd delay excedd thenext GP frontier,
        #        so test is started at 10h21 and KPIs retrieved at 10h26
        # And, test duration must not exceed 1 GP - 1 mn per loop

    Traced Sleep                    ${start_loop_remaining} seconds
    ...                             msg=before starting scenario

    Dated Log New Line              **** Waiting for end of ZOI ****
    ZOI Wait End                     zoi=${zoi}

    ${pm_path}                      Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Step                            KPI Evaluate                    pmFile=${pm_path}
    ...                             constraintsFile=${CB012733_constraints}
    ...                             failOnError=${True}

    [Teardown]               Display diagnosis

CB012733 Check MIB SIB
    Dated Log              Waiting MIB-SIB
    wtsemu.script          file=${CURDIR}/../config/custom/multi_ue_sa_script_new.lua
    ...                    entry=check_CellSetup(1,4)
    Dated Log              Checking SIBs
    # Flush Egate Console Buffer    # Flush the buffer to be sure to have all egate console log
    # wtsemu.Read Wtsemu Output Until Re
	# ...                    expected= Cell Setup Check Script Complet
	# ...                    timeout=300

    FOR    ${cid}  IN RANGE    1    5
            Dated Log      Waiting Cell Setup Check Script Completion CellSetup(${cid})
            Run Keyword    wtsemu.Read Wtsemu Output Until Re
             ...            expected=Cell Setup for${cid}: Cell Setup Found    timeout=300
    END


CB012733 LaunchTraffic
    [Documentation]
    ...         Actions : Launch basic traffic with DTX
    ...         Params :  none
    ...         Return :  none
    [Arguments]
    CB012733_run_script_once     ${CURDIR}/../config/custom/eGate_macros_2.lua entry=run_test_50Ue_CELL2

CB012733_run_script_once
    [Documentation]        This KW start on egate command a script file=<path><file.sce> to perform egate commande
    ...                    recorded on a .sce file

    [Arguments]                    ${script_path_name}
    Dated Log                      Script sce used: ${script_path_name}

    wtsemu.script                  file=${script_path_name}
    ${output}                      wtsemu.read_wtsemu_output_until    PROCESSING    600
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${output}                      wtsemu.read_wtsemu_output_until_prompt    5
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wait until keyword succeeds    12hours    1s    CB012733_is_script_finished
    ${error_in_status}=            Run Keyword And Return Status    Should Contain    ${script_status}    error
    Dated Log                      output:${error_in_status}

CB012733_is_script_finished
    [Documentation]        This KW is a part of CB012733_run_script_once

    wtsemu.script_status
    ${output}                      wtsemu.read_wtsemu_output_until    ALL UE REGISTERED ON CELL2    600
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wtsemu.read_wtsemu_output_until_prompt    5
    should not match regexp        ${script_status}    ( active | paused )
    [Return]

CB012733 start TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # TTI capture configuration
    ${TTIdir}              Get TTI Trace Path    dir_suffix=${suffix}
    set Suite Variable     ${TTIdir}

    # Start TTI capture
    Dated Log New Line     ===> start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2



CB012733 stop TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # Stop TTI capture
    Dated Log New Line     ===> stop TTI traces capture
    ${TTIpcap}             Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=TTI_${suffix}
    set Suite Variable     ${TTIpcap}


CB012733 TTI Post Processing

    [Documentation]     The purpose of this test case is to analyze TTI traces captured during CB012733_A_SQUELETON
    ...                 test case to check that actThreeSymbolPdcch is activated (at least some pdch have start symbol
    ...                 equal to 2)
    ...                 First step is to convert TTI pcap to JSON using TtiConvertInterface,
    ...                 then decode JSON to CSV using TtitraceReaderEvtDec, and finally analyze the decoded
    ...                 traces with TtiAnalysisInterface to check the value of start symbol for pdsch.


    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> CB012733 TTI Post Processing Workflow
    Dated Log              Step 1: Converting TTI PCAP to JSON using TtiConvertInterface


    # STEP 1: CONVERT PCAP TO JSON
    # Uses TtiConvertInterface.Convert TTI capture which:
    # - Decodes PCAP file

    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    Dated Log              TTI conversion complete: ${TTIjson}

    # STEP 2: DECODE/EXTRACT TTI TRACES
    ${TTIcsv_decoded}      decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000
    Dated Log New Line     Step 2: JSON decoded and ready for analysis
    Dated Log              TTI json file : ${TTIjson}
    Dated Log              TTI csv file : ${TTIcsv_decoded}
    set global variable    ${path_to_json}    ${TTIjson}
    Set Suite Variable      ${TTIcsv_decoded}


CB012733_A_TEST_TTI

    [Documentation]     The purpose of this test case is to
    ...                 TBD


    ${TTIpcap}=               Set Variable     /home/ute/Downloads/TTI.pcap
    ${TTIcsv_decoded}=        Set Variable    /home/ute/Downloads/TTI_filtered.csv
    ${TTIjson}=               Set Variable    /home/ute/Downloads/TTI_filtered.json
	Dated Log New Line     ===> CB012733 TTI Post Processing Workflow
    Dated Log              Step 1: Converting TTI PCAP to JSON using TtiConvertInterface

    # STEP 1: CONVERT PCAP TO JSON
    # Uses TtiConvertInterface.Convert TTI capture which:
    # - Decodes PCAP file
    # - Adds required metadata (utcTimestampData, eventHeader, etc.)
    # - Creates properly formatted JSON for TtiAnalysisInterface
    @{list_events_to_filter}=         Create List        dlFdSchedData
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    #TtiConvertInterface.Convert TTI capture    pcap_file_path=${TTIpcap}
    #...                                                          events_list=${list_events_to_filter}
    Dated Log              TTI conversion complete: ${TTIjson}

    #dialogs.Execute Manual Step       wait keyboard

    # STEP 2: DECODE/EXTRACT TTI TRACES
    ${TTIcsv_decoded}      decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000
    Dated Log New Line     Step 2: JSON decoded and ready for analysis
    Dated Log              TTI json file : ${TTIjson}
    Dated Log              TTI csv file : ${TTIcsv_decoded}
    set global variable    ${path_to_json}    ${TTIjson}
    Set Suite Variable      ${TTIcsv_decoded}

    #dialogs.Execute Manual Step       wait keyboard
    ${TTI_LOG_PATH}      Set variable    /home/ute/Downloads/
    Set Suite Variable      ${TTI_LOG_PATH}
    CB012733 Format and check TTI Trace

   #dialogs.Execute Manual Step       wait keyboard
    ${outputFilePath_full}            CB012733 Format TTI Trace Combined DL UL   ${TTIcsv_decoded}
   #################################################################################
   ##### Analyze the formatted TTI CSV file to check that at least some pdsch have start symbol equal to 2 in DL and UL,
   ##### which means that actThreeSymbolPdcch is activated in DL and UL #####
   #################################################################################
    Dated Log New Line     Step 3: Analyzing formatted TTI CSV file to check StartSymbol values for DL and UL
    Dated Log              TTI post processing completed. Formatted TTI CSV file: ${outputFilePath_full}
    CB012733 Count Unique StartSymbol Per SFN Slot Group    ${outputFilePath_full}
    Dated Log              Unique_symbol pour checker les sfn/slot ${analysis_result}

    @{sfn_slot_eq_3}=   CB012733 Get SFN Slot Where Count Equals    ${analysis_result}    3
    Dated Log           SFN;SLOT avec valeur=3 : @{sfn_slot_eq_3}
   #################################################################################
   #################################################################################
    CB012733 Check StartSymbol Rules Per Slot    ${outputFilePath_full}
    Dated Log           Checks Done
    dialogs.Execute Manual Step       wait keyboard

    # # STEP 3: ANALYZE WITH TtiAnalysisInterface
    # # Creates TtiAnalyzer instance from the properly converted JSON
    # # The JSON contains all required metadata fields added by TtiConvertInterface
    # Dated Log New Line     Step 3: Creating TtiAnalyzer from converted JSON
    # #${my_instance} =       Create Tti Analyzer    ${TTIjson}    ${None}
    # Dated Log              TtiAnalyzer instance created successfully

    # # STEP 4: EXPORT SCHEDULING PARAMETERS
    # # Export top-level parameters that exist in the decoded TTI CSV
    # # The second parameter should be the OUTPUT path where the exported CSV will be saved
    # Dated Log New Line     Step 4: Exporting scheduling parameters to CSV


    # ${TTIcsv_exported}=                Evaluate       "${TTIcsv_decoded}".replace(".csv", "_exported.csv")
    # ${path_to_json}        Set Variable     ${TTIjson}

    # dialogs.Execute Manual Step       wait keyboard

    # Dated Log New Line     ===> CB012733 TTI Post Processing Complete
    # Dated Log              Results: CSV file ${TTIcsv_exported} contains exported parameters

CB012733 Format and check TTI Trace
    [Documentation]             1/ Filter all lines containing ulFdSchedData or dlFdSchedData
    ...                         2/ Only keep MSGID, SFN, and Format columns.
    ...                         then format the 2 colums SFN Slot in one column SFN.Slot
    ...                         then add first line header describing colums
    ...                         and redirect the output in a file named "TTI_5GC001013_TestCase#_Formatted.csv"


    ${inputFilePath}     Set variable    ${TTIcsv_decoded}

    ${pathOfOutput}	   ${fileName}          	Split Path	                   ${input_file_path}
    @{words} 	       Split String	  ${fileName}	        .csv
    ${output_file_path}           set variable      ${pathOfOutput}/${words[0]}

    ${outputFilePathDL}    Set variable    ${output_file_path}_DLFiltered.csv
    ${outputFilePathUL}    Set variable    ${output_file_path}_ULFiltered.csv

    # For DL file

    ${command}           Set variable
    ...                  grep -i -E "(dlFdSchedData)" <${inputFilePath} >${outputFilePathDL}
    ${returnCode}        Run And Return Rc    ${command}
    Should Be Equal As Integers    ${returnCode}    0
    Dated Log New Line     Filtered CSV File: ${outputFilePathDL}


    ${inputFilePathDL}     Set variable       ${outputFilePathDL}
    ${outputFilePathDL}  Set variable       ${output_file_path}_FormattedDL.csv
    ${metadataFileDL}    Set variable       ${output_file_path}_DL_metadata.txt
    ${command}           Catenate    SEPARATOR=
    ...                  awk -F';' '{dl_start="";
    ...                  for (i=1; i<=NF; i++) if ($i ~ /pdcchStartSymbol/)
    ...                  {dl_col=i+1; dl_start=$(i+1); break}
    ...                  if (dl_start != "") printf("%s %s %s %s \\n", $6, $8, $12, dl_start)}
    ...                  END {print "DL_START=" dl_col > "${metadataFileDL}"}' <${inputFilePathDL} |
    ...                  awk -F' ' '{print $1 ";" $2 ";" $3 ";" $4 }' |
    ...                  sed -e '1i\SFN ; SLOT ; RNTI ; StartSymbol' |
    ...                  grep -i -vwE "(INVALID)" >${outputFilePathDL}

    Dated Log New Line    -----> Commande Awk: ${command}

    ${returnCode}        Run And Return Rc    ${command}
    Should Be Equal As Integers    ${returnCode}    0
    ${metadata_dl}=      OperatingSystem.Get File    ${metadataFileDL}
    @{dl_meta_lines}=    Split To Lines    ${metadata_dl}
    ${dl_start}=         Set Variable    ${EMPTY}
    FOR    ${line}    IN    @{dl_meta_lines}
        ${is_dl}=    Run Keyword And Return Status    Should Start With    ${line}    DL_START=
        IF    ${is_dl}
            @{parts}=    Split String    ${line}    =
            ${dl_start}=    Set Variable    ${parts}[1]
            Set Suite Variable    ${dl_start}
        END
    END
    Dated Log New Line    DL_START column index: ${dl_start}

    # For UL file

    ${command}           Set variable
    ...                  grep -i -E "(ulFdSchedData)" <${inputFilePath} >${outputFilePathUL}
    ${returnCode}        Run And Return Rc    ${command}
    Should Be Equal As Integers    ${returnCode}    0
    Dated Log New Line     Filtered CSV File: ${outputFilePathUL}


    ${inputFilePathUL}   Set variable       ${outputFilePathUL}
    ${outputFilePathUL}  Set variable       ${output_file_path}_FormattedUL.csv
    ${metadataFileUL}    Set variable       ${output_file_path}_UL_metadata.txt
    ${command}           Catenate    SEPARATOR=
    ...                  awk -F';' '{ul_start="";
    ...                  for (i=1; i<=NF; i++) if ($i ~ /pdcchStartSymbol/)
    ...                  {ul_col=i+1; ul_start=$(i+1); break}
    ...                  if (ul_start != "") printf("%s %s %s %s \\n", $6, $8, $12, ul_start)}
    ...                  END {print "UL_START=" ul_col > "${metadataFileUL}"}' <${inputFilePathUL} |
    ...                  awk -F' ' '{print $1 ";" $2 ";" $3 ";" $4 }' |
    ...                  sed -e '1i\SFN ; SLOT ; RNTI ; StartSymbol' |
    ...                  grep -i -vwE "(INVALID)" >${outputFilePathUL}

    Dated Log New Line    -----> Commande Awk: ${command}

    ${returnCode}        Run And Return Rc    ${command}
    Should Be Equal As Integers    ${returnCode}    0
    ${metadata_ul}=      OperatingSystem.Get File    ${metadataFileUL}
    @{ul_meta_lines}=    Split To Lines    ${metadata_ul}
    ${ul_start}=         Set Variable    ${EMPTY}
    FOR    ${line}    IN    @{ul_meta_lines}
        ${is_ul}=    Run Keyword And Return Status    Should Start With    ${line}    UL_START=
        IF    ${is_ul}
            @{parts}=    Split String    ${line}    =
            ${ul_start}=    Set Variable    ${parts}[1]
            Set Suite Variable    ${ul_start}
        END
    END
    Dated Log New Line    UL_START column index: ${ul_start}
    Dated Log New Line     Formatted CSV File DL: ${outputFilePathDL}
    Dated Log New Line     Formatted CSV File UL: ${outputFilePathUL}

    # Use case example: retrieves the values from column 3 (RNTI) where column 4 (StartSymbol) = 2
    @{slot_listDL}=         CB012733 Get Values From CSV By Column Match
    ...                   csv_file_path=${outputFilePathDL}
    ...                   search_value=2
    ...                   search_column=4
    ...                   return_column=2
    ...                   delimiter=;

    @{slot_listUL}=         CB012733 Get Values From CSV By Column Match
    ...                   csv_file_path=${outputFilePathUL}
    ...                   search_value=2
    ...                   search_column=4
    ...                   return_column=2
    ...                   delimiter=;

    Dated Log New Line    List of slots DL with StartSymbol=2 : @{slot_listDL}
    Dated Log New Line    List of slots UL with StartSymbol=2 : @{slot_listUL}

    # Check that lists are not empty, which means that at least some pdsch have start symbol equal to 2 in DL and UL
    ${length_DL}=    Get Length    ${slot_listDL}
    ${length_UL}=    Get Length    ${slot_listUL}

    Should Not Be Equal As Integers    ${length_DL}    0
    ...    msg=ERROR: The slot_listDL is empty - no matches found for StartSymbol=2 in DL

    Should Not Be Equal As Integers    ${length_UL}    0
    ...    msg=ERROR: The slot_listUL is empty - no matches found for StartSymbol=2 in UL

    Dated Log New Line    ✓ Validation OK: ${length_DL} slots found in DL, ${length_UL} slots found in UL

CB012733 Get Values From CSV By Column Match
    [Documentation]     Finds a value in a column of a CSV file and returns
    ...                 the corresponding values from another column.
    ...
    ...                 Arguments:
    ...                 - csv_file_path: Path to the CSV file
    ...                 - search_value: Value to search for in the search column
    ...                 - search_column: Index of the column to search in (default: 4, base 1)
    ...                 - return_column: Index of the column to return (default: 2, base 1)
    ...                 - delimiter: CSV delimiter (default: ,)
    ...
    ...                 Returns: List of values from the return_column where search_column contains search_value
    ...
    ...                 Example:
    ...                 @{values}=    Get Values From CSV By Column Match    /path/to/file.csv    my_value    4    2

    [Arguments]    ${csv_file_path}    ${search_value}    ${search_column}=3    ${return_column}=1    ${delimiter}=,

    # Conversion des indices en base 0 pour Python
    ${search_idx}=    Evaluate    ${search_column} - 1
    ${return_idx}=    Evaluate    ${return_column} - 1

    # Lecture et filtrage du CSV avec Python (saute la première ligne = en-tête)
    ${py_expr}=    Catenate    SEPARATOR=
    ...    [row[${return_idx}].strip() for row in
    ...    [line.strip().split("${delimiter}") for line in open(r"${csv_file_path}", "r").readlines()[1:]]
    ...    if len(row) > max(${search_idx}, ${return_idx}) and row[${search_idx}].strip() == "${search_value}"]

    @{result_list}=    Evaluate    ${py_expr}

    ${list_length}=    Get Length    ${result_list}
    Dated Log New Line    Found ${list_length} correspondance(s) for the value '${search_value}' in column ${search_column}
    Run Keyword If    ${list_length} > 0    Dated Log New Line    Returned values: ${result_list}
    Run Keyword If    ${list_length} == 0    Dated Log New Line    WARNING: No matches found!

    [Return]    ${result_list}

CB012733 Format TTI Trace Combined DL UL
    [Documentation]     Format TTI traces in one csv file combining DL and UL.
    ...                 For DL/UL: searches for the field containing pdcchStartSymbol,
    ...                 then extracts the next column as StartSymbol.
    ...
    ...                 Arguments:
    ...                 - inputFilePath: Path to the decoded CSV file
    ...                 - output_file_path: Base path for the output file
    ...
    ...                 Returns: Path to the formatted CSV file

    [Arguments]    ${inputFilePath}

    ${pathOfOutput}	   ${fileName}          	Split Path	                   ${input_file_path}
    @{words} 	       Split String	  ${fileName}	        .csv
    ${output_file_path}           set variable      ${pathOfOutput}/${words[0]}


    ${outputFilePath_full}    Set variable    ${output_file_path}_Full_Formatted.csv
    ${metadataFile}           Set variable    ${output_file_path}_metadata.txt

    # Single pass with explicit row type split:
    # - rows starting with dlFdSchedData: find pdcchStartSymbol then take next field
    # - rows starting with ulFdSchedData: find pdcchStartSymbol then take next field
    # awk also writes dl_start and ul_start to metadata file for Robot access
    ${command}           Catenate    SEPARATOR=
    ...                  awk -F';' '{if (index(\$1,"dlFdSchedData")==1) {dl_start="";
    ...                  for (i=1; i<=NF; i++) if (\$i ~ /pdcchStartSymbol/) {dl_col=i+1; dl_start=\$(i+1); break}
    ...                  if (dl_start != "") printf("%s %s %s %s\\n",\$6,\$8,\$12,dl_start)}
    ...                  else if (index(\$1,"ulFdSchedData")==1) {ul_start="";
    ...                  for (i=1; i<=NF; i++) if (\$i ~ /pdcchStartSymbol/) {ul_col=i+1; ul_start=\$(i+1); break}
    ...                  if (ul_start != "") printf("%s %s %s %s\\n",\$6,\$8,\$12,ul_start)}}
    ...                  END {print "DL_START=" dl_col > "${metadataFile}";
    ...                  print "UL_START=" ul_col >> "${metadataFile}"}' <${inputFilePath} |
    ...                  awk -F' ' '{print \$1 ";" \$2 ";" \$3 ";" \$4 }' |
    ...                  sed -e '1i\\SFN ; SLOT ; RNTI ; StartSymbol' |
    ...                  grep -i -vwE "(INVALID)" >${outputFilePath_full}

    Dated Log New Line    -----> Commande Awk: ${command}

    ${returnCode}        Run And Return Rc    ${command}
    Should Be Equal As Integers    ${returnCode}    0
    Dated Log New Line     Formatted CSV File (DL + UL): ${outputFilePath_full}
    Set Suite Variable    ${outputFilePath_full}

    # Read metadata file and set Robot variables
    ${metadata}=         OperatingSystem.Get File    ${metadataFile}
    @{meta_lines}=       Split To Lines    ${metadata}
    FOR    ${line}    IN    @{meta_lines}
        ${is_dl}=    Run Keyword And Return Status    Should Start With    ${line}    DL_START=
        ${is_ul}=    Run Keyword And Return Status    Should Start With    ${line}    UL_START=
        IF    ${is_dl}
            @{parts}=    Split String    ${line}    =
            ${dl_start}=    Set Variable    ${parts}[1]
            Set Suite Variable    ${dl_start}
        ELSE IF    ${is_ul}
            @{parts}=    Split String    ${line}    =
            ${ul_start}=    Set Variable    ${parts}[1]
            Set Suite Variable    ${ul_start}
        END
    END

    Dated Log New Line    DL_START=${dl_start}    UL_START=${ul_start}

    [Return]    ${outputFilePath_full}

CB012733 Count Unique StartSymbol Per SFN Slot Group
    [Documentation]    Count unique StartSymbol (4th column) for each consecutive group
    ...                where column 1 and 2 are equal.

    [Arguments]    ${csv_file_path}

    ${py_expr}=    Catenate    SEPARATOR=
    ...    [(f"{k[0]};{k[1]}", len({r[3] for r in grp if len(r) >= 4 and r[3] and r[3].upper() != "INVALID"}))
    ...    for k, grp in __import__("itertools").groupby(
    ...        ([c.strip() for c in line.split(";")] for line in open(r"${csv_file_path}", "r").read().splitlines()[1:] if line.strip()),
    ...        key=lambda r: (r[0], r[1])
    ...    )]

    ${analysis_result}=    Evaluate    ${py_expr}

    Dated Log New Line    Analysis: Unique StartSymbol count per consecutive SFN;SLOT group
    FOR    ${item}    IN    @{analysis_result}
        ${key}=      Evaluate    $item[0]
        ${count}=    Evaluate    $item[1]
        # Dated Log    SFN;SLOT ${key}: ${count} unique StartSymbol value(s)
    END
    Set Suite Variable   ${analysis_result}

    [Return]   # ${analysis_result}


CB012733 Check StartSymbol Rules Per Slot
    [Documentation]    Validate StartSymbol values based on SLOT in a formatted CSV.
    ...                Rules:
    ...                - SLOT 2 or 12  -> StartSymbol must be 0
    ...                - SLOT 3 or 13  -> StartSymbol must be 1
    ...                - SLOT 4 or 14  -> StartSymbol must be 1 or 2
    ...                - SLOT 5 or 15  -> StartSymbol must be 0 or 2
    ...                - Any other SLOT -> StartSymbol can be 0 or 1 or 2
    ...                CSV format expected: SFN ; SLOT ; RNTI ; StartSymbol

    [Arguments]    ${csv_file_path}

    ${content}=    OperatingSystem.Get File    ${csv_file_path}
    @{lines}=    Split To Lines    ${content}
    ${line_count}=    Get Length    ${lines}
    Should Be True    ${line_count} > 1    msg=CSV file seems empty or missing data rows: ${csv_file_path}

    @{violations}=    Create List

    FOR    ${idx}    IN RANGE    1    ${line_count}
        ${line}=    Set Variable    ${lines}[${idx}]
        ${line}=    Strip String    ${line}
        Continue For Loop If    '${line}' == ''

        @{cols}=    Split String    ${line}    ;
        ${col_count}=    Get Length    ${cols}
        IF    ${col_count} < 4
            Append To List    ${violations}    invalid row format: ${line}
            Continue For Loop
        END

        ${slot_raw}=    Strip String    ${cols}[1]
        ${start_raw}=    Strip String    ${cols}[3]

        ${slot_is_int}=    Run Keyword And Return Status    Should Match Regexp    ${slot_raw}    ^[0-9]+$
        ${start_is_int}=    Run Keyword And Return Status    Should Match Regexp    ${start_raw}    ^[0-9]+$
        IF    not ${slot_is_int} or not ${start_is_int}
            Append To List    ${violations}    non-numeric slot/startSymbol: ${line}
            Continue For Loop
        END

        ${slot}=    Convert To Integer    ${slot_raw}
        ${is_valid}=    Set Variable    ${False}

        IF    ${slot} == 2 or ${slot} == 12
            ${is_valid}=    Run Keyword And Return Status    Should Match Regexp    ${start_raw}    ^0$
        ELSE IF    ${slot} == 3 or ${slot} == 13
            ${is_valid}=    Run Keyword And Return Status    Should Match Regexp    ${start_raw}    ^1$
        ELSE IF    ${slot} == 4 or ${slot} == 14
            ${is_valid}=    Run Keyword And Return Status    Should Match Regexp    ${start_raw}    ^[12]$
        ELSE IF    ${slot} == 5 or ${slot} == 15
            ${is_valid}=    Run Keyword And Return Status    Should Match Regexp    ${start_raw}    ^[02]$
        ELSE
            ${is_valid}=    Run Keyword And Return Status    Should Match Regexp    ${start_raw}    ^[012]$
        END

        IF    not ${is_valid}
            Append To List    ${violations}    invalid slot/startSymbol combination: ${line}
        END
    END

    ${violation_count}=    Get Length    ${violations}

    #Run Keyword If    ${violation_count} > 0    Dated Log New Line    Invalid slot/startSymbol combinations: ${violations}
    Should Be Equal As Integers    ${violation_count}    0
    ...    msg=StartSymbol rule validation failed. Invalid entries: ${violations}

    Dated Log New Line    StartSymbol rules validated successfully for file: ${csv_file_path}


CB012733 Get SFN Slot Where Count Equals
    [Documentation]    Retourne les SFN;SLOT dont la valeur associée est égale à target_value.
    [Arguments]    ${analysis_result}    ${target_value}=3

    @{matches}=    Create List
    FOR    ${item}    IN    @{analysis_result}
        ${key}=      Evaluate    $item[0]
        ${count}=    Evaluate    int($item[1])
        IF    ${count} == ${target_value}
            Append To List    ${matches}    ${key}
        END
    END
    Set Suite Variable   @{sfn_slot_eq_3}   ${matches}
    [Return]    ${matches}