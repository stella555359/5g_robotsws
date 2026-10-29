*** Settings ***
Documentation    Template for 706 TC Resource file, providing some examples that handle attenuator channels mgt
...              Author : Annie WOng          annie.wong@nokia.com
...                     : Florence Thepot     florence.thepot@nokia.com
...                     : Pape Diallo         pape.diallo@nokia.com
...              Last update : 03.02.2021
...
...   Before running this testcase, it is necessary to configure the A5Measurement report according to your lab
...   in the scf such as: MRBTS-#/NRBTS-#/NRCELL-#/NRHOIF-1 <a3HysteresisRsrp> <a3OffsetSsbRsrp> on each cell

Resource      ../../../resources/sg_radio_perf/robot/var_test_suite_handover_intra_gnb_A3.robot
Resource      ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource      ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource      keywords_706_common.robot


#*** Variables ***
# INTRA GNB HO A3 scenario variables, now defined in : var_test_suite_handover_intra_gnb_A3.robot
# ${source_attenuator_id}                ${custom['HO_Configuration'][0]['intra_gnb_A3']['source_attenuator_id']}
# ${target_attenuator_id}                ${custom['HO_Configuration'][0]['intra_gnb_A3']['target_attenuator_id']}
# ${source_channels}                     ${custom['HO_Configuration'][0]['intra_gnb_A3']['source_channels']}
# ${target_channels}                     ${custom['HO_Configuration'][0]['intra_gnb_A3']['target_channels']}
# ${attenuations_min}                    ${custom['HO_Configuration'][0]['intra_gnb_A3']['attenuations_min']}
# ${attenuations_max}                    ${custom['HO_Configuration'][0]['intra_gnb_A3']['attenuations_max']}
# ${source_attenuations_a2}              ${custom['HO_Configuration'][0]['intra_gnb_A3']['source_attenuations_a2']}
# ${target_attenuations_a2}              ${custom['HO_Configuration'][0]['intra_gnb_A3']['target_attenuations_a2']}
# ${source_attenuations_ho_trigger}  ${custom['HO_Configuration'][0]['intra_gnb_A3']['source_attenuations_ho_trigger']}
# ${target_attenuations_ho_trigger}  ${custom['HO_Configuration'][0]['intra_gnb_A3']['target_attenuations_ho_trigger']}
# ${source_attenuations_attach}          ${custom['HO_Configuration'][0]['intra_gnb_A3']['source_attenuations_attach']}
# ${target_attenuations_attach}          ${custom['HO_Configuration'][0]['intra_gnb_A3']['target_attenuations_attach']}

# ${ue_capability}, traffic thput and duration are defined in robot suite


*** Keywords ***
706_B33_B34_Suite_Setup
	# this is mandatory : retrieve testsuite variables for gNB
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=all
    keywords_706_common.Check gNB and Get reportingIntervalPm Value
    # prepare scf for event=A3
    Keywords_gNB.Create cOAM Session with alias     gnb_id=0    alias=coam_admin
    Recommission a3MeasRSRP a5MeasNone cell1 cell2         gNB=0     connection=coam_admin
    admin.get_current_scf_file      ${OUTPUTDIR}   scf_modified.xml   connection=coam_admin


706_B33_B34_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=True    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC000706_B_33
    [Documentation]    The purpose of this test case is to check that the traffic is not interrupted after intraDU HO
    ...                based on event A3 with downlink traffic.
     ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where the following values (expected value)
    ...                  should be greater than 0.

    Log        \nAttach UE / Launch DL traffic / Detach UE / Collect PM files     console=DEBUG_MODE_CONSOLE
    #  testcase variables ${PM_FILENAME_TC} and ${PM_PATH_TC} will be set
    Keywords_handover.HO Intra gNB scenario with call and traffic and Collect Pm to Targetpath
    ...           targetpath=testcase
    ...           traffic_direction=DL
    ...           tput_dl=${dl_throughput}
    ...           duration=${dl_time_s}
    ...           gNB=0
    ...           ue_index=0
    ...           ue_capabilities=${ue_capability}
    # ...           qxdm_log_name=5GC000706_B33_DL_Traffic_A3_qxdm.hdf

    # Retrieve PM report from TOT_INTER_FREQ_HO_DECISION_A3:
    ${cell1_M55147C00024}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55147C00024
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=1

    # For DL: Retrieve the PM report DATA_SLOT_PDSCH (30 sec traffic):
    ${cell1_M55308C00005}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55308C00005
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=1
    ${cell2_M55308C00005}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55308C00005
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=2

    # No RRC Release has to be sent after HO Cell 1
    ${cell1_M55124C00001}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55124C00001
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=1
    # to check No RRC Release has to be sent after HO Cell 2:
    ${cell2_M55124C00001}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55124C00001
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=2

    Log      PM report from TOT_INTER_FREQ_HO_DECISION_A3:     console=${DEBUG_MODE_CONSOLE}
    Log      Cell1 M55147C00024=${cell1_M55147C00024}          console=${DEBUG_MODE_CONSOLE}
    Log      PM report DATA_SLOT_PDSCH (30 sec traffic):       console=${DEBUG_MODE_CONSOLE}
    Log      Cell1 M55308C00005=${cell1_M55308C00005}          console=${DEBUG_MODE_CONSOLE}
    Log      Cell2 M55308C00005=${cell2_M55308C00005}          console=${DEBUG_MODE_CONSOLE}
    Log      RRC Release:                                      console=${DEBUG_MODE_CONSOLE}
    Log      Cell1 M55124C00001=${cell1_M55124C00001}          console=${DEBUG_MODE_CONSOLE}
    Log      Cell2 M55124C00001=${cell2_M55124C00001}          console=${DEBUG_MODE_CONSOLE}

    # Retrieve PM report from TOT_INTER_FREQ_HO_DECISION_A3:
    should be true     ${cell1_M55147C00024}==1
    # For DL: Retrieve the PM report DATA_SLOT_PDSCH (30 sec traffic):
    should be true     ${cell1_M55308C00005}>46125
    should be true     ${cell2_M55308C00005}>46125
    # No RRC Release has to be sent after HO Cell 1
    should be true     ${cell1_M55124C00001}==0
    # No RRC Release has to be sent after HO Cell 2
    should be true     ${cell2_M55124C00001}==0


5GC000706_B_34
    [Documentation]    The purpose of this test case is to check that the traffic is not interrupted after intraDU HO
    ...                based on event A3 with downlink traffic
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where the following value (expected value)
    ...                  should be greater than 0.

    Log         \nAttach UE / Launch UL traffic / Detach UE / Collect PM files     console=DEBUG_MODE_CONSOLE

    #  testcase variables ${PM_FILENAME_TC} and ${PM_PATH_TC} will be set
    Keywords_handover.HO Intra gNB scenario with call and traffic and Collect Pm to Targetpath
    ...           targetpath=testcase
    ...           traffic_direction=UL
    ...           tput_ul=${ul_throughput}
    ...           duration=${ul_time_s}
    ...           gNB=0
    ...           ue_index=0
    ...           ue_capabilities=${ue_capability}
    # ...           qxdm_log_name=5GC000706_B34_UL_Traffic_A3_qxdm.hdf

    # Retrieve PM report TOT_INTER_FREQ_HO_DECISION_A3:
    ${cell1_M55147C00024}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55147C00024
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=1

    # Retrieve  PM report DATA_SLOT_PUSCH (30 sec traffic):
    ${cell1_M55308C00006}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55308C00006
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=1
    ${cell2_M55308C00006}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55308C00006
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=2

    # No RRC Release has to be sent after HO Cell 1:
    ${cell1_M55124C00001}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55124C00001
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=1
    # No RRC Release has to be sent after HO Cell 2:
    ${cell2_M55124C00001}=    pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH_TC}
    ...             pi_name=M55124C00001
    ...             file_name=${PM_FILENAME_TC}
    ...             cell=2

    Log      PM report TOT_INTER_FREQ_HO_DECISION_A3:       console=${DEBUG_MODE_CONSOLE}
    Log      Cell1 M55147C00024=${cell1_M55147C00024}       console=${DEBUG_MODE_CONSOLE}
    Log      PM report DATA_SLOT_PUSCH (30 sec traffic):    console=${DEBUG_MODE_CONSOLE}
    Log      Cell1 M55308C00006=${cell1_M55308C00006}       console=${DEBUG_MODE_CONSOLE}
    Log      Cell2 M55308C00006=${cell2_M55308C00006}       console=${DEBUG_MODE_CONSOLE}
    Log      RRC Release sent after HO:                     console=${DEBUG_MODE_CONSOLE}
    Log      Cell1 M55124C00001=${cell1_M55124C00001}       console=${DEBUG_MODE_CONSOLE}
    Log      Cell2 M55124C00001=${cell2_M55124C00001}       console=${DEBUG_MODE_CONSOLE}

    # Retrieve PM report TOT_INTER_FREQ_HO_DECISION_A3:
    should be true     ${cell1_M55147C00024}==1
    # Retrieve  PM report DATA_SLOT_PUSCH (30 sec traffic):
    should be true     ${cell1_M55308C00006}>10510
    should be true     ${cell2_M55308C00006}>10510
    # No RRC Release has to be sent after HO Cell 1:
    should be true     ${cell1_M55124C00001}==0
    # No RRC Release has to be sent after HO Cell 2:
    should be true     ${cell2_M55124C00001}==0
