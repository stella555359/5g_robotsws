*** Settings ***
Documentation    791 TC AC2FDD AC4FDD AC5TDD AC6TDD Resource file
...              AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...              AUTHOR (I&V):   Nadine Crasnier        nadine.crasnier@nokia.com
...              creation : 03/06/2021
...              update : 25/06/2021
...              TC AC2FDD AC4FDD AC5TDD AC6TDD will be performed in TDD; the 4 counters are common in TDD and FDD
...              update : 05/05/2022 ; Nadine Crasnier   Update DL counters values M55335C03008 and M55335C500 for test
...              with SCF with 4 DL layers and 4 beams as the lab CV45 is now cabled with 4 DL layers
...              update : 13/01/2023 ; Add EDA 02406062 test to 5GC000791_TC_AC6_TDD test

Library           taf.analyzer.pmcounter
Library           ../../../resources/pm_analyze.py

Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_e2e/coam_selenium.robot
#Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          keywords_791_common.robot


*** Keywords ***

791_AC2FDD_AC4FDD_AC5TDD_AC6TDD_Suite_Setup
    [Arguments]        ${gnb_index}=0
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=all   gnb=${gnb_index}
    keywords_791_common.Check gNB and Get reportingIntervalPm Value
    # prepare scf
    keywords_791_common.Perform PreCommissioning For 791-AC NSA
    ${MeasPeriod_num}=       Replace String      ${MeasPeriod}       min     ${EMPTY}
    Set Suite Variable              ${MeasPeriod_num}
    ${pm_value_M55335C03004_tolerance}=       Evaluate                 500*${MeasPeriod_num}
    ${pm_value_M55335C03009_tolerance}=       Evaluate                 300*${MeasPeriod_num}
    ${pm_value_M55335C05003_tolerance}=       Evaluate                 40*${MeasPeriod_num}
    ${pm_value_M55335C05004_tolerance}=       Evaluate                 80*${MeasPeriod_num}
    Set Suite Variable              ${pm_value_M55335C03004_tolerance}
    Set Suite Variable              ${pm_value_M55335C03009_tolerance}
    Set Suite Variable              ${pm_value_M55335C05003_tolerance}
    Set Suite Variable              ${pm_value_M55335C05004_tolerance}

    keywords_791_common.Make Call and ULDL Traffic and Collect Pm files in TestsuiteDir
    ...     gNB=${gNB_id}
    ...     ue_index=${UE_ID}
    ...     ue_capabilities=${capabilities_ms}


791_AC2FDD_AC4FDD_AC5TDD_AC6TDD_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=True    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC000791_TC_AC2_FDD
    [Documentation]    The purpose of this test case is to check counter value M55335C03004 is coherent with frame
    ...                structure.
    ...                Frame structure 1070 is choosen for this test  with prachConfigurationIndex = 98
    ...                actPrachMultiplexing parameter is deactivated by commissioning
    ...                With frame structure 1070, there are 11 UL slots during 20ms, so :
    ...                Expected value in measurement period is (11 / 20) x 1000 x 60 x ${MeasPeriod_num}
    ...                Expected value in measurement period is 33000*${MeasPeriod_num}
    ...                Expected value in 5min is 165 000
    ...
    ...                Test Steps Executions:
    ...                - Perform delta commissioning of the SCF
    ...                - Establish a call with full UL and DL traffic
    ...                - Wait the next PM period
    ...                - Wait the end of the PM period
    ...                - Collect the PM report files and store in path ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    ...                - Check the value of counter M55335C03004 with expected value calculated during the measurement
    ...                  period
    ...                - If the difference is greater than the tolerance , the test fails

    # create the path with test name for QC
    #${target_path}      Join path      ${OUTPUTDIR}     ${SUITENAME}       ${TESTNAME}
    #Create directory    ${target_path}

    #Retrieve the PM reports and check the counter value
    ${pi_M55335C03004}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55335C03004       file_name=${PM_FILENAME}
    log                    M55335C03004 = ${pi_M55335C03004}      console=${DEBUG_MODE_CONSOLE}
    ${expected_value_M55335C03004}          Evaluate                 33000*${MeasPeriod_num}
    log                  M55335C03004 expected value = ${expected_value_M55335C03004}     console=${DEBUG_MODE_CONSOLE}
    log                  tolerance=${pm_value_M55335C03004_tolerance}          console=${DEBUG_MODE_CONSOLE}
    should be true       abs(${pi_M55335C03004} - ${expected_value_M55335C03004}) < ${pm_value_M55335C03004_tolerance}

5GC000791_TC_AC4_FDD
    [Documentation]    The purpose of this test case is to check counter value M55335C03009 is coherent with frame
    ...                structure.
    ...             Frame structure 1070 is choosen for this test  with prachConfigurationIndex = 98
    ...             actPrachMultiplexing parameter is deactivated by commissioning
    ...             With frame structure 1070, with 2 DL layers and 1 single beam,there are 107 DL slots during 80ms,so:
    ...             Expected value in measurement period is  ((4X8 + 1x18 + 3x19) / 80) x 1000 x 60 x ${MeasPeriod_num}
    ...             Expected value in measurement period is 80250*${MeasPeriod_num}
    ...             Expected value in 5min is 401 250
    ...             Update 05/05/2022
    ...             With frame structure 1070, with 4 DL layers and 4 beams,there are 102 DL slots during 80ms,so:
    ...             Expected value in measurement period is  (102 / 80) x 1000 x 60 x ${MeasPeriod_num}
    ...             Expected value in measurement period is 76500*${MeasPeriod_num}
    ...             Expected value in 5min is 382 500
    ...
    ...              Test Steps Executions:
    ...               - Perform delta commissioning of the SCF
    ...               - Establish a call with full UL and DL traffic
    ...               - Wait the next PM period
    ...               - Wait the end of the PM period
    ...               - Collect the PM report files and store in path ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    ...               - Check the value of counter M55335C03009 with expected value calculated during the measurement
    ...                  period
    ...               - If the difference is greater than the tolerance , the test fails

    #Retrieve the PM reports and check the counter value
    ${pi_M55335C03009}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55335C03009       file_name=${PM_FILENAME}
    ${pi_M55335C03011}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55335C03011       file_name=${PM_FILENAME}
    log                   M55335C03009 = ${pi_M55335C03009}      console=${DEBUG_MODE_CONSOLE}
#   ${expected_value_M55335C03009}      Evaluate                 80250*${MeasPeriod_num}
    ${expected_value_M55335C03009}      Evaluate                 76500*${MeasPeriod_num}
    log                   M55335C03009 expected value = ${expected_value_M55335C03009}     console=${DEBUG_MODE_CONSOLE}
    log                   tolerance=${pm_value_M55335C03009_tolerance}         console=${DEBUG_MODE_CONSOLE}
    should be true        abs(${pi_M55335C03009} - ${expected_value_M55335C03009}) < ${pm_value_M55335C03009_tolerance}


5GC000791_TC_AC5_TDD
    [Documentation]    The purpose of this test case is to check counter value M55335C05003 is coherent with frame
    ...                structure.
    ...                Frame structure 1070 is choosen for this test  with prachConfigurationIndex = 98
    ...                actPrachMultiplexing parameter is deactivated by commissioning
    ...                With frame structure 1070, there are 11 UL slots during 20ms, so :
    ...                Expected value in measurement period is (11 / 20) x 1000 x 60 x ${MeasPeriod_num}
    ...                Expected value in measurement period is 33000*${MeasPeriod_num}
    ...                Expected value in 5min is 165 000
    ...
    ...                Test Steps Executions:
    ...                - Perform delta commissioning of the SCF
    ...                - Establish a call with full UL and DL traffic
    ...                - Wait the next PM period
    ...                - Wait the end of the PM period
    ...                - Collect the PM report files and store in path ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    ...                - Check the value of counter M55335C05003 with expected value calculated during the measurement
    ...                  period
    ...                - If the difference is greater than the tolerance , the test fails

    #Retrieve the PM reports and check the counter value
    ${pi_M55335C05003}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55335C05003       file_name=${PM_FILENAME}
    log                    M55335C05003 = ${pi_M55335C05003}      console=${DEBUG_MODE_CONSOLE}
    ${expected_value_M55335C05003}      Evaluate                33000*${MeasPeriod_num}
    log                   M55335C05003 expected value = ${expected_value_M55335C05003}     console=${DEBUG_MODE_CONSOLE}
    log                   tolerance=${pm_value_M55335C05003_tolerance}        console=${DEBUG_MODE_CONSOLE}
    should be true        abs(${pi_M55335C05003} - ${expected_value_M55335C05003}) < ${pm_value_M55335C05003_tolerance}


5GC000791_TC_AC6_TDD
    [Documentation]    The purpose of this test case is to check counter value M55335C05004 is coherent with frame
    ...                structure.
    ...             Frame structure 1070 is choosen for this test  with prachConfigurationIndex = 98
    ...             actPrachMultiplexing parameter is deactivated by commissioning
    ...             With frame structure 1070, with 2 DL layers and 1 single beam,there are 107 DL slots during 80ms,so:
    ...             Expected value in measurement period is  ((4X8 + 1x18 + 3x19) / 80) x 1000 x 60 x ${MeasPeriod_num}
    ...             Expected value in measurement period is 80250*${MeasPeriod_num}
    ...             Expected value in 5min is 401 250
    ...             Update 05/05/2022
    ...             With frame structure 1070, with 4 DL layers and 4 beams,there are 102 DL slots during 80ms,so:
    ...             Expected value in measurement period is  (102 / 80) x 1000 x 60 x ${MeasPeriod_num}
    ...             Expected value in measurement period is 76500*${MeasPeriod_num}
    ...
    ...             Test Steps Executions:
    ...               - Perform delta commissioning of the SCF
    ...               - Establish a call with full UL and DL traffic
    ...               - Wait the next PM period
    ...               - Wait the end of the PM period
    ...               - Collect the PM report files and store in path ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    ...               - Check the value of counter M55335C05004 with expected value calculated during the measurement
    ...                  period
    ...               - If the difference is greater than the tolerance , the test fails


    #Retrieve the PM reports and check the counter value
    ${pi_M55335C05004}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55335C05004       file_name=${PM_FILENAME}
    log                    M55335C05004 = ${pi_M55335C05004}      console=${DEBUG_MODE_CONSOLE}
#   ${expected_value_M55335C05004}      Evaluate                 80250*${MeasPeriod_num}
    ${expected_value_M55335C05004}      Evaluate                 76500*${MeasPeriod_num}
    log                   M55335C05006 expected value = ${expected_value_M55335C05004}     console=${DEBUG_MODE_CONSOLE}
    log                   tolerance=${pm_value_M55335C05004_tolerance}        console=${DEBUG_MODE_CONSOLE}
    should be true        abs(${pi_M55335C05004} - ${expected_value_M55335C05004}) < ${pm_value_M55335C05004_tolerance}


    #EDA 02406062 test
    #The purpose of this EDA is to delete in SCF, the list name "coresetdedicated" where is defined the coresetId = 1,
    #in the MRBTS-45/NRBTS-23123/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1 , and then activate from Web EM this
    #incorrect SCF in order to check that this activation is rejected.
    # prepare scf and check the error message when trying scf activation for EDA 02406062
    keywords_791_common.Perform Commissioning And Check For EDA 02406062 NSA
