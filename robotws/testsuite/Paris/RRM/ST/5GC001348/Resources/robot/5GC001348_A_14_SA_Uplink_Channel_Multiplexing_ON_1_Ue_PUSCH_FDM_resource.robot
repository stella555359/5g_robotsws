*** Settings ***
Documentation    1348 A14 TC Resource file
...              Author : Annie Wong          annie.wong@nokia.com
...                     : Florence Thepot     florence.thepot@nokia.com
...                     : Pape Diallo         pape.diallo@nokia.com
...         Last update : 11.06.2021


Resource      ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource      ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource      keywords_1348_common.robot


*** Keywords ***
1348_A_14_Suite_Setup
    [Arguments]       ${gnb_id}=${0}
	# this is mandatory : retrieve testsuite variables for gNB
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=${gnb_id}
    keywords_1348_common.Check gNB and Get reportingIntervalPm Value       gNB=${gnb_id}
    # prepare scf
    Perform PreCommissioning For 1348-14

1348_A_14_Suite_Teardown
    [Arguments]       ${gnb_id}=${0}
    TestSuite Basic Teardown     restore_gnb_config=${True}     restore_type=scf      gnb=${gnb_id}
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin

Perform PreCommissioning For 1348-14
    [Arguments]    ${gNB_id}=${0}
    keywords_1348_common.Update parameter values with delta commissioning for 1348-14     gnb_id=${gNB_id}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB_id}      alias=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}     scf_commissioning_for_1348.xml    connection=coam_admin
    ${my_scf}     set variable     ${OUTPUTDIR}/scf_commissioning_for_1348.xml
    keywords_1348_common.Add tddFrameStructure 1208 to local scf     local_scf_path=${my_scf}
    Log        Do Commissioning with ${my_scf}:       console=${DEBUG_MODE_CONSOLE}
    Commissioning.Do Commissioning     ${my_scf}     gNB=${gNB_id}
    [Teardown]    Keywords_gNB.Teardown cOAM Session with alias     alias=coam_admin

5GC001348_TC_A14
    [Documentation]    The purpose of this test is to establish SA call with full UL Thr in good radio condition with
    ...                prachConfigurationIndex=98 ; Bandwidth 100 MHz ; UL to DL Data slot ratio: 1/4 FR1 1208 ;
    ...                framestructure=semiStatic. Full granularity is M55308C10004 & M55308C10002 is about 32580000:
    ...                (7 x (273) PRB + 1 x (261) PRB [273 -12 RACH PRBs] for 20 ms ; for 5 mn = 32580000).
    ...                Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where the following value (expected value)
    ...                  should be greater than 0.
    ...                  possible 2% loss can be expected = about 31928400
    [Arguments]       ${gnb_id}=${0}    ${ue_id}=${0}
    #  test suite variables ${PM_FILENAME} and ${PM_PATH} will be set :
    keywords_1348_common.1348 A14 A20 with call and UL traffic and Collect Pm in TestSuiteDir
    ...           tput_ul=${ul_throughput}
    ...           duration=${ul_time_s}
    ...           gNB=${gnb_id}
    ...           ue_index=${ue_id}
    ...           ue_capabilities=${ue_capability}

    # This counter provides the number of available PRB for PUSCH
    ${pi_M55308C10004}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH}      pi_name=M55308C10004      file_name=${PM_FILENAME}     cell=1
    log      M55308C10004=${pi_M55308C10004}       console=${DEBUG_MODE_CONSOLE}

    # This counter provides the number of used PRBs for PUSCH
    ${pi_M55308C10002}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH}      pi_name=M55308C10002      file_name=${PM_FILENAME}     cell=1
    log      M55308C10002=${pi_M55308C10002}       console=${DEBUG_MODE_CONSOLE}

    should be true     32600000>${pi_M55308C10004}>32540000
    # should be true     ${pi_M55308C10002}>32580000
    should be true     ${pi_M55308C10002}>31928400
