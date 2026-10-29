*** Settings ***
Documentation
...                  common keywords for 5GC008172 testcases


Library           ../../../resources/pm_analyze.py        WITH NAME      pm_analyze
Library           ../config/config_paths.py
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_iperf_prisma.robot


*** Keywords ***
Compare number of enabled cells with number of cells with coam
    [Documentation]    [PRIVATE]   on classical gnb verify if all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    [Arguments]     ${num_of_cells}
    @{cell_status}=     admin.get_cells_info     connection=gnb
    ${num_of_enabled_cells}    set variable   ${0}
    FOR    ${index}    IN RANGE    ${num_of_cells}
        &{temp}    set variable  ${cell_status}[${index}]
        &{temp1}    get from dictionary    ${temp}    status
        Dictionary should contain item    ${temp1}    operationalState      enabled
        ${num_of_enabled_cells}    Evaluate             ${num_of_enabled_cells}+1
    END
    Should Be True   '${num_of_cells}'=='${num_of_enabled_cells}'    msg=${num_of_enabled_cells} Cell(s) of ${num_of_cells} Enabled


TestSuite_8172_Common_Preconditions
    preconditions.Setup Testline Suite Variables
    preconditions.TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf    gnb=${source_gnb}
    Keywords_gNB.Check gNB State      gNB=${source_gnb}
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[${source_gnb}]}
    set suite variable       ${MeasPeriod}


Run Call and Traffic on UE List and save PM files
    [Arguments]     ${list_of_ues}    ${traffic_direction}    ${traffic_duration}    ${tput_dl}    ${tput_ul}   ${gNB}
    # keyword dedicated to prisma at the moment (remind that prisma sce call duration must be long enough)
    # the PM files are saved in path ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    # ${source_gnb}, ${MeasPeriod} must be set in testsuite

    Log     Involve UE Index=${list_of_ues}      console=${DEBUG_MODE_CONSOLE}

    Keywords_UE.Multi UEs Call with Traffic and Collect Traffic Period PMfiles in TestcaseDir
    ...                      list_of_ues=${list_of_ues}
    ...                      traffic_duration=${traffic_duration}
    ...                      traffic_direction=${traffic_direction}
    ...                      tput_dl=${tput_dl}
    ...                      tput_ul=${tput_ul}
    ...                      gNB=${gNB}


Compare Counters in PM file to Targets
    #[Arguments]      ${pmfile}    ${target_M55601C00002}
    #[Arguments]      ${pmfile}    ${target_M55601C00002}    ${gnb_id}
    #...                           ${target_M55315C03009}   ${target_M55335C03003}   ${target_M55308C10002}
    #...                           ${target_M55308C18001}   ${target_M55310C01009}   ${target_M55335C03008}
    #...                           ${target_M55308C10001}   ${target_M55308C17001}
    # latest pmfile is ${PM_FILENAME}, and n-2 period pmfile shall be : ${pmfile}
    Log    Get Pi Value From File:       console=${DEBUG_MODE_CONSOLE}
    ${pi_value_M55601C00002}=   pm_analyze.Get Pi Value From File
    ...          pi_dir=${PM_PATH}       pi_name=M55601C00002      file_name=${pmfile}
    #${pi_value_M55315C03009}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55315C03009      file_name=${pmfile}
    #${pi_value_M55335C03003}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55335C03003      file_name=${pmfile}
    #${pi_value_M55308C10002}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55308C10002      file_name=${pmfile}
    #${pi_value_M55308C18001}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55308C18001      file_name=${pmfile}
    #${pi_value_M55310C01009}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55310C01009      file_name=${pmfile}
    #${pi_value_M55335C03008}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55335C03008      file_name=${pmfile}
    #${pi_value_M55308C10001}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55308C10001      file_name=${pmfile}
    #${pi_value_M55308C17001}=   pm_analyze.Get Pi Value From File
    #...          pi_dir=${PM_PATH}       pi_name=M55308C17001      file_name=${pmfile}
    #Log     M55601C00002=${pi_value_M55601C00002}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55315C03009=${pi_value_M55315C03009}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55335C03003=${pi_value_M55335C03003}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55308C10002=${pi_value_M55308C10002}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55308C18001=${pi_value_M55308C18001}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55310C01009=${pi_value_M55310C01009}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55335C03008=${pi_value_M55335C03008}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55308C10001=${pi_value_M55308C10001}     console=${DEBUG_MODE_CONSOLE}
    #Log     M55308C17001=${pi_value_M55308C17001}     console=${DEBUG_MODE_CONSOLE}
    #should be true      ${pi_value_M55601C00002} == ${target_M55601C00002}
    #example:  should be true      ${pi_value_M55315C01009} > ${target_M55315C01009}


Get N-1 PERIOD FILENAME
    # ${PM_PATH} is a testcase variable set through keyword: Run Call and Traffic on UE List and save PM files
    #-----   get last 2 PM filename
    ${cmd}=   set variable     cd "${PM_PATH}";ls -dr1 *PM*.xml |head -2
    ${filename}     Run     ${cmd}
    log      Last 2 pmfiles = ${filename}        console=${DEBUG_MODE_CONSOLE}
    @{lines}    Split To Lines      ${filename}
    log      pmfile0 = ${lines}[0]               console=${DEBUG_MODE_CONSOLE}
    log      pmfile1 = ${lines}[1]               console=${DEBUG_MODE_CONSOLE}
    Return From Keyword     ${lines}[1]


Set Swconfig from archive templates
   [Arguments]        ${swconf_name}       ${gNB}
   ${templates_full_path}      config_paths.Get Template Fullname      ${swconf_name}
   Log       swconfig template fullpath=${templates_full_path}         console=${DEBUG_MODE_CONSOLE}
   Commissioning.Set Swconfig        swconf_name=${templates_full_path}     gNB=${gNB}


wait gNB to be onair state and cells enabled
    [Documentation]     on classical gnb check and wait, that all created cells are enabled
    [Arguments]         ${gnb_id}=${0}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gnb_id}      alias=gnb
    ${scf_content}     admin.get_current_scf_content    connection=gnb       timeout=${30}
    ${list_cells}      string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}    collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait until keyword succeeds     1200 sec      20 sec
    ...     Compare number of enabled cells with number of cells with coam     ${num_of_cells}
    [Teardown]   Keywords_gNB.Teardown cOAM Session with alias     alias=gnb


Update parameter values with delta commissioning for feature activate
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    Log         MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/actSpatialStreamPooling    console=${DEBUG_MODE_CONSOLE}
    ${d_actSpatialStreamPooling_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actSpatialStreamPooling
    ...    value        true

