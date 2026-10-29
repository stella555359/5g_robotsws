*** Settings ***
Documentation    1301_AA_3 Resource file
...              AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...              creation : 20/01/2021
...              update : 10/02/2021  Nadine Crasnier  add compatibility for NSA or SA mode

Library           taf.analyzer.pmcounter
Library           ../../../resources/pm_analyze.py

Resource          ../../../resources/pm_collection.robot
Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
#Resource          ../../../resources_sg_radioPerf/robot/Keywords_UE.robot
Resource          keywords_1301_common.robot


*** Keywords ***

1301_Suite_Setup
    [Arguments]        ${gnb_index}=0
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=all   gnb=${gnb_index}
    keywords_1301_common.Check gNB and Get reportingIntervalPm Value
    # prepare scf
    keywords_1301_common.Perform PreCommissioning For 1301_AA_3
    ${MeasPeriod_num}=       Replace String      ${MeasPeriod}       min     ${EMPTY}
    Set Suite Variable              ${MeasPeriod_num}
    # determine NSA or SA mode
    scf.load_scf    file_path=${ORIG_SCF[0]}
    ${gNbCuType}=    scf.get_value_from_scf     dist_name=MRBTS-${MRBTS}/NRBTS-${NRBTS}    p_name=gNbCuType
    Log               NSA or SA mode=${gNbCuType}   console=${DEBUG_MODE_CONSOLE}
    Set suite variable       ${gNbCuType}

    keywords_1301_common.Make Call and ULDL Traffic and Collect Pm files in TestsuiteDir
    ...     gNB=${gNB_id}
    ...     ue_index=${UE_ID}
    ...     ue_capabilities=${capabilities_ms}


1301_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=True    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC001301_AA_3
    [Documentation]    The purpose of this test case is to check call establishment after on-line
    ...                modification of parameter sub6_preambleTransMax
    ...
    ...                Test Steps Executions:
    ...                - Perform delta commissioning of the SCF
    ...                - Establish a call with UL and DL traffic
    ...                - Wait the next PM period
    ...                - Wait the end of the PM period
    ...                - Collect the PM report files and store in path ${OUTPUT_DIR}/${SUITE_NAME}/gnb_pmcounters
    ...                - Check the value of counter M55310C0100x and M55310C0300x with expected value
    ...                  during the measurement period
    ...                - If the difference is greater than the tolerance , the test fails

    # create the path with test name for QC
    #${target_path}      Join path      ${OUTPUTDIR}     ${SUITENAME}       ${TESTNAME}
    #Create directory    ${target_path}

    run keyword if  '${gNbCuType}'=='NSA'   Check NSA Traffic Counter Value
    run keyword if  '${gNbCuType}'=='SA'    Check SA Traffic Counter Value

#    run keyword if  '${gNbCuType}'=='NSA'   Set Suite Variable   ${target_D}        ${target_D_NSA}
#    run keyword if  '${gNbCuType}'=='NSA'   Set Suite Variable   ${target_U}        ${target_U_NSA}
#    run keyword if  '${gNbCuType}'=='SA'    Set Suite Variable   ${target_D}        ${target_D_SA}
#    run keyword if  '${gNbCuType}'=='SA'    Set Suite Variable   ${target_U}        ${target_U_SA}
#    run keyword if  '${gNbCuType}'=='NSA'   Set Suite Variable   ${PM_counter_DL}   M55310C01009
#    run keyword if  '${gNbCuType}'=='NSA'   Set Suite Variable   ${PM_counter_UL}   M55310C03009
#    run keyword if  '${gNbCuType}'=='SA'    Set Suite Variable   ${PM_counter_DL}   M55315C01005
#    run keyword if  '${gNbCuType}'=='SA'    Set Suite Variable   ${PM_counter_UL}   M55315C03005
#
#     #Retrieve the PM reports and check the counter value
#     ${pi_${PM_counter_DL}}=     pm_analyze.get_pi_value_from_file
#     ...                     pi_dir=${PM_PATH}     pi_name=${PM_counter_DL}       file_name=${PM_FILENAME}
#     ${pi_${PM_counter_UL}}=     pm_analyze.get_pi_value_from_file
#     ...                     pi_dir=${PM_PATH}     pi_name=${PM_counter_UL}      file_name=${PM_FILENAME}
#     log                 DL ${PM_counter_DL} = ${pi_${PM_counter_DL}}      console=${DEBUG_MODE_CONSOLE}
#     log                 UL ${PM_counter_UL} = ${pi_${PM_counter_UL}}      console=${DEBUG_MODE_CONSOLE}
#     should be true       ${pi_${PM_counter_DL}} > ${target_U}
#     should be true       ${pi_${PM_counter_UL}} > ${target_D}


Check NSA Traffic Counter Value
    #Retrieve the PM reports and check the counter value
    ${pi_M55315C01009}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55315C01009       file_name=${PM_FILENAME}
    ${pi_M55315C03009}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55315C03009       file_name=${PM_FILENAME}
    log                 \n DL M55315C01009 = ${pi_M55315C01009}      console=${DEBUG_MODE_CONSOLE}
    log                 UL M55335C03009 = ${pi_M55315C03009}      console=${DEBUG_MODE_CONSOLE}
    should be true      ${pi_M55315C01009} > ${target_D_NSA}
    should be true      ${pi_M55315C03009} > ${target_U_NSA}


Check SA Traffic Counter Value
    #Retrieve the PM reports and check the counter value
    ${pi_M55310C01005}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55310C01005       file_name=${PM_FILENAME}
    ${pi_M55310C03005}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55310C03005       file_name=${PM_FILENAME}
    log                 DL M55310C01005 = ${pi_M55310C01005}      console=${DEBUG_MODE_CONSOLE}
    log                 UL M55335C03005 = ${pi_M55310C03005}      console=${DEBUG_MODE_CONSOLE}
    should be true       ${pi_M55310C03005} > ${target_U_SA}
    should be true       ${pi_M55310C01005} > ${target_D_SA}


