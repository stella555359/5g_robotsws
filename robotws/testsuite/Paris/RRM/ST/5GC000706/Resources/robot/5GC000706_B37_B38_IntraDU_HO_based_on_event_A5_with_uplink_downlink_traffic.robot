*** Settings ***
Documentation    Template for 706 TC Resource file, providing some examples that handle attenuator channels mgt
...              Author : Annie WOng          annie.wong@nokia.com
...                     : Florence Thepot     florence.thepot@nokia.com
...                     : Pape Diallo         pape.diallo@nokia.com
...              last update : 03.02.2021
...
...   Before running this testcase, it is necessary to configure the A5Measurement report according to your lab
...   in the scf such as: MRBTS-#/NRBTS-#/NRCELL-#/NRHOIF-1 <a5HysteresisRsrp> <a5Threshold1SsbRsrp> on each cell

Resource          ../../../resources/sg_radio_perf/robot/var_test_suite_handover_intra_gnb_A5.robot
Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource          keywords_706_common.robot


# *** Variables ***
# INTRA GNB HO A5 scenario variables, now defined in : var_test_suite_handover_intra_gnb_A5.robot
# ${source_attenuator_id}                ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuator_id']}
# ${target_attenuator_id}                ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuator_id']}
# ${source_channels}                     ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_channels']}
# ${target_channels}                     ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_channels']}
# ${attenuations_min}                    ${custom['HO_Configuration'][1]['intra_gnb_A5']['attenuations_min']}
# ${attenuations_max}                    ${custom['HO_Configuration'][1]['intra_gnb_A5']['attenuations_max']}
# ${source_attenuations_a2}              ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuations_a2']}
# ${target_attenuations_a2}              ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuations_a2']}
# ${source_attenuations_ho_trigger}   ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuations_ho_trigger']}
# ${target_attenuations_ho_trigger}   ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuations_ho_trigger']}
# ${source_attenuations_attach}          ${custom['HO_Configuration'][1]['intra_gnb_A5']['source_attenuations_attach']}
# ${target_attenuations_attach}          ${custom['HO_Configuration'][1]['intra_gnb_A5']['target_attenuations_attach']}
# ${ue_capability}, traffic thput and duration are defined in robot suite


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
706_B37_B38_Suite_Setup
	# this is mandatory : retrieve testsuite variables for gNB
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=all
    keywords_706_common.Check gNB and Get reportingIntervalPm Value
    # prepare scf for event=A5
    Keywords_gNB.Create cOAM Session with alias     gnb_id=0    alias=coam_admin
    Recommission a3MeasNone a5MeasRSRP cell1 cell2        gNB=0     connection=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}   scf_modified.xml   connection=coam_admin


706_B37_B38_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=True    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC000706_B_37
    [Documentation]    The purpose of this test case is to check that the traffic is not interrupted after intraDU HO
    ...                based on event A5 with downlink traffic.
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where the following values (expected value)
    ...                  should be greater than 0.

    Log             Attach UE / Launch DL traffic / Detach UE / Collect PM files     console=DEBUG_MODE_CONSOLE
    #  testcase variables ${PM_FILENAME_TC} and ${PM_PATH_TC} will be set
    Keywords_handover.HO Intra gNB scenario with call and traffic and Collect Pm to Targetpath
    ...           targetpath=testcase
    ...           traffic_direction=DL
    ...           tput_dl=${dl_throughput}
    ...           duration=${dl_time_s}
    ...           gNB=0
    ...           ue_index=0
    ...           ue_capabilities=${ue_capability}
    # ...           qxdm_log_name=5GC000706_B37_DL_Traffic_A5.hdf

    log       PM_FILENAME_TC=${PM_FILENAME_TC}     console=${DEBUG_MODE_CONSOLE}
    log       PM_PATH_TC=${PM_PATH_TC}             console=${DEBUG_MODE_CONSOLE}

    keywords_706_common.B37_Check_M55147C00025_And_Others
    ...          pi_dir=${PM_PATH_TC}    file_name=${PM_FILENAME_TC}


5GC000706_B_38
    [Documentation]    The purpose of this test case is to check that the traffic is not interrupted after intraDU HO
    ...                based on event A5 with downlink traffic
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where the following value (expected value)
    ...                  should be greater than 0.

    Log             Attach UE / Launch UL traffic / Detach UE / Collect PM files     console=DEBUG_MODE_CONSOLE
    #  testcase variables ${PM_FILENAME_TC} and ${PM_PATH_TC} will be set
    Keywords_handover.HO Intra gNB scenario with call and traffic and Collect Pm to Targetpath
    ...           targetpath=testcase
    ...           traffic_direction=UL
    ...           tput_ul=${ul_throughput}
    ...           duration=${ul_time_s}
    ...           gNB=0
    ...           ue_index=0
    ...           ue_capabilities=${ue_capability}
    # ...           qxdm_log_name=5GC000706_B38_UL_Traffic_A5.hdf

    log       PM_FILENAME_TC=${PM_FILENAME_TC}     console=${DEBUG_MODE_CONSOLE}
    log       PM_PATH_TC=${PM_PATH_TC}             console=${DEBUG_MODE_CONSOLE}

    keywords_706_common.B38_Check_M55147C00025_And_Others
    ...          pi_dir=${PM_PATH_TC}    file_name=${PM_FILENAME_TC}
