*** Settings ***
Documentation    791 TC AC7 FDD Resource file
...              AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...              AUTHOR (I&V):   Nadine Crasnier        nadine.crasnier@nokia.com
...              creation : 03/06/2021
...              update : 25/06/2021
...              Counter M55335C05006 is common in TDD and FDD. Test case AC7FDD will be performed in TDD.

Library           taf.analyzer.pmcounter
Library           ../../../resources/pm_analyze.py

Resource          ../../../resources/pm_collection.robot
Resource      ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource      ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource      keywords_791_common.robot


*** Keywords ***
791_AC_7_FDD_Suite_Setup
	# this is mandatory : retrieve testsuite variables for gNB
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=all   gnb=${gNB_id}
    keywords_791_common.Check gNB and Get reportingIntervalPm Value
    # prepare scf
    keywords_791_common.Perform PreCommissioning For 791-AC SA
    ${MeasPeriod_num}=              Replace String      ${MeasPeriod}       min     ${EMPTY}
    Set Suite Variable              ${MeasPeriod_num}
    ${pm_value_M55335C05006_tolerance}=       Evaluate                 80*${MeasPeriod_num}
    Set Suite Variable              ${pm_value_M55335C05006_tolerance}

791_AC_7_FDD_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=True   restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC000791_TC_AC7_FDD_SA
    [Documentation]    The purpose of this test case is to check counter value M55335C05006 is coherent with
    ...                frame structure
    ...              Frame structure 1070 is choosen for this test  with prachConfigurationIndex = 98
    ...              With frame structure 1070, there are 107 DL slots during 80ms, so :
    ...              Expected value in measurement period is  ((4X8 + 1x18 + 3x19) / 80) x 1000 x 60 x ${MeasPeriod_num}
    ...              Expected value in measurement period is 80250*${MeasPeriod_num}
    ...              Expected value in 5min is 401 250
    ...              No need  to establish a call
    ...
    ...              Test Steps Executions:
    ...                - Perform delta commissioning of the SCF
    ...                - Wait the next PM period
    ...                - Wait the end of a second the PM period to be sure to have a full PM period
    ...                - Collect the PM report files and store them in path
    ...                   ${OUTPUT_DIR}/${SUITE_NAME}/${TESTNAME}/gnb_pmcounters
    ...                - Check the value of counter M55335C05006 with expected value in last PM period file
    ...                - If the difference is greater than 70 , the test fails


    ${target_path}      Join path      ${OUTPUTDIR}     ${SUITENAME}       ${TESTNAME}
    Create directory    ${target_path}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=15
    ...        gnb=${gNB_id}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB_id}

    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testcase
    Log        last period pm file=${res}   console=${DEBUG_MODE_CONSOLE}

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable      ${PM_PATH}          ${res_path}
    Set Test Variable      ${PM_FILENAME}      ${res}

    #Retrieve the PM reports and check the counter value
    # ${pi_M55335C05006}=     pm_analyze.get_pi_value_from_file
    ${pi_M55335C05006}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55335C05006       file_name=${PM_FILENAME}     cell=1
    log                    M55335C05006 = ${pi_M55335C05006}      console=${DEBUG_MODE_CONSOLE}
    ${expected_value_M55335C05006}      Set Variable                 401250
    log                   M55335C05006 expected value = ${expected_value_M55335C05006}     console=${DEBUG_MODE_CONSOLE}
    ${tolerance}           Set Variable                   70
    log                    tolerance=${pm_value_M55335C05006_tolerance}         console=${DEBUG_MODE_CONSOLE}
    should be true         abs(${pi_M55335C05006} - ${expected_value_M55335C05006}) < ${pm_value_M55335C05006_tolerance}
