*** Settings ***

Documentation
...   author: SG8
...   contact: SG8
...   Description: Test Suite for 5GC002060


Library     testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Library     taf.hw.rf_attenuator.attenuator  WITH NAME  at
Resource    ./resources/CB007623_keywords.robot
Resource    ../../resources/robot/reportingportal_Keywords.robot       ###
Resource    ../resources/Common_resource.robot    ###
Library     ute_reporting_portal     ##
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem
Library     ute_fsmaccess
#Library     ute_wtssim
Library     ta5g_pm_counters
Library     ta5g_setups_and_teardowns
Library    taf.sw.scout    WITH NAME    scout
Force Tags        CRT    SBTS24R2    FL00    QCD_MN_RAN    QCP_RAN_ST

Test Teardown     Test Teardown
Test Setup      Test Setup

*** Variables ***
&{CB007814_5GC002060_FR1_SA_call_with_DRX_LongCycle_640_ms}
...     QC_ID_FL00=QC_31504    QC_ID_SBTS24R2=QC_774138

@{UE_alias}=  UE1
@{capabilities}=    Legacy_1
${bts_ip}=     192.168.255.129
${TEST NAME}=    CDRX_640ms
${DELTA_FILE}    ./testsuite/Bangalore/ORAN/SG06/CB007814/resources/Delta_Conf_5GC002060.json
${OUT_LOG_PATH}    /home/ute/results
${local_moid}=      PLMN-PLMN/MRBTS-1236/NRBTS-1236/NRCELL-3
${counter_id}=    M55308C11001
${counter_id1}=    M55308C11002
${CONFIGURATION}		    10_2_CLOUD1236



*** Test Cases ***
CB007814_5GC002060_FR1_SA_call_with_DRX_LongCycle_640_ms

     step1: Setup
     step2: Start dcap
     step3: Attach UE
     step4: Stop dcap and Validate logs
	 step5: Counter Verification
     RP Settings
     Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
     Set QC_Tag


*** Keywords ***

Test Setup
     Log to console    \n--Test Setup--\n
     Admin Setup1


step1: Setup
     ${Branch}   Get Branch
     coam.lock    dist_name=MRBTS-1236/EQM-1/APEQM-1/RMOD-1    timeout=120    connection=${connection}
     sleep    1m
     Parameter value change     ${Cell3_dist}     actCDrx    true
     Run keyword if  "${Branch}"=="24R2"
     ...    COAM.perform_delta_recommissioning    ${DELTA_FILE}    skip_parameter_relation_errors=False    should_activate=True    timeout=300
	 ...    connection=${connection}
	 Log to console    \n--Parameter updated--\n

step2: Start dcap
     Dcap Start Trace 5GSA
     sleep    10s

step3: Attach UE
    Log to console    \n--Attach validation step starting--\n
	ta_ultracaller.require_ue    ${UE_alias}    ${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    sleep    5s
	ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Log to console    \n--Attach validation completed--\n
	sleep     10s



step4: Stop dcap and Validate logs
    Dcap Stop Trace and Get results SA
    Log to console   \n--DCAP traces stopped successfully--\n
    Log to console   \n--Emil validation in progress for drx config--\n
    @{check}	Create list		 DL RRC: rrcReconfiguration::drx-onDurationTimer milliSeconds : ms100,drx-LongCycleStartOffset ms640
	Verify Emil logs	@{check}

step5: Counter Verification
    Log to console   \n--starting Counter validation--\n
	Wait For Next Raw Pm Interval
	${PM_COUNTERS}=    get_latest_unpacked_raw_pm_counters_file
	Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${counter_id}
    ...    value=1    local_moid=${local_moid}    filepath=${PM_COUNTERS}
	Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${counter_id1}
    ...    value=1    local_moid=${local_moid}    filepath=${PM_COUNTERS}




Commission the site with SCF
    coam.perform_commissioning
    ...    bts_id=1236
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=500
    ...    connection=${connection}

Revert SCF to original one
    coam.perform_commissioning
    ...    bts_id=1236
    ...    scf_file=${scf_org_file}
    ...    skip_parameter_relation_errors=False
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${connection}


Admin Setup1
    [Documentation]     Create Coam connection to BTS, check BTS status, start watching alarms, create testcase folder and start BTS log
    COAM.setup_admin    bts_host=${gNB_IP}    alias=${connection}    admin_api_log_dir=/tmp
    ${BTS_details}      COAM.get_bts_info       connection=${connection}
    Log    ${BTS_details}
    ${current_sw}    COAM.get_sw_version    connection=${connection}
    Log to console      \nCurrent Active build in gnb : ${current_sw}
    Set Suite Metadata      Software version    ${current_sw}
	Set global variable    ${BTS_ID}     ${BTS_details['mrbtsID']}
    Set global variable    ${dist_name}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
	Set global variable    ${Cell3_dist}     MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-3
    ${cell_details}      COAM.get_cells_info       connection=${connection}
    ${cell_count}       Get Length      ${cell_details}
	@{FDD_cells}		Create List
	Set suite variable		@{FDD_cells}
	Set suite variable		${cell_count}
    Create dcap session
	Create testcase folder



Dcap Start Trace 5GSA
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
    ${bts_profiles}    rd.get_bts_profiles
    ${lte_profiles}    rd.get_lte_profiles
    &{bts_info}=  Create Dictionary    host=${BTS_M_plane_ip}    port=${port}    username=Nemuadmin    password=nemuuser
	${output}       rd.start_trace  duration=${Default_DCAP_duration}     bts=${BTS_INFO}
    ...    gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}    collection_timing=${collection_timing}
#    ...     bip_mirroring_time=300    wait_for_activation=True
    ...    wait_for_activation=True
    ${val}        Get Dictionary Values      ${output}

    Set Suite Variable          ${START_TRACE_ID}      ${val}[0]
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Test Teardown
    coam.unlock    dist_name=MRBTS-1236/EQM-1/APEQM-1/RMOD-1    timeout=120    connection=${connection}
    sleep    1m
    Run keyword and ignore error    Dcap Stop Trace and Get results SA
	coam.teardown_admin    ${connection}
    Log to console   \n--End Test--\n
    RP Settings
    Wait Until Keyword Succeeds    2min    10s      Link SCOUT SCF to Configuration ID for Reporting
    Set QC_Tag

Verify Emil logs
    [Arguments]    @{values}
    [Documentation]     Convert emil file and verify
    Convert Emil File To Csv
    FOR     ${check}    IN   @{values}
        ${result}       CNI_97916.Parse_Emil_Csv_File_For_Message     path=${OUTPUT_DIR}/DCAP_Logs/Extracted/      msg=${check}
        ...                                                 msg_col=${4}                      con_col=${19}
        Run keyword And Continue On Failure     Should Be True      ${result}
    END

Get Branch
    ${sw_version}    COAM.get_sw_version    connection=${connection}
    ${out}    Split String From Right    ${sw_version}    _    -1
    ${Branch}    Strip String    ${out}[0]    both    SBTS
    [Return]    ${Branch}




