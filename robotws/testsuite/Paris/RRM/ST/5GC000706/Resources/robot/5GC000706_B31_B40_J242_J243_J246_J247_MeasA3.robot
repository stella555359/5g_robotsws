*** Settings ***
Documentation    Template for 706 TC Resource file, providing some examples that handle attenuator channels mgt
...              Author : Annie WOng          annie.wong@nokia.com
...                     : Florence Thepot     florence.thepot@nokia.com
...                     : Pape Diallo         pape.diallo@nokia.com
...              last update : 03.02.2021     add traffic in call scenario
...
...   Before running this testcase, it is necessary to configure the A5Measurement report according to your lab
...   in the scf such as: MRBTS-#/NRBTS-#/NRCELL-#/NRHOIF-1 <a3HysteresisRsrp> <a3OffsetSsbRsrp> on each cell


Resource          ../../../resources/sg_radio_perf/robot/var_test_suite_handover_intra_gnb_A3.robot
Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource          keywords_706_common.robot


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

# ${ue_capability} is defined in robot suite


*** Keywords ***
706_B31_B40_J242_J243_J246_J247_Suite_Setup
	# this is mandatory : retrieve testsuite variables for gNB
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=all
    keywords_706_common.Check gNB and Get reportingIntervalPm Value
	# prepare scf for event=A3
    Keywords_gNB.Create cOAM Session with alias     gnb_id=0    alias=coam_admin
    Recommission a3MeasRSRP a5MeasNone cell1 cell2        gNB=0     connection=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}    scf_modified.xml    connection=coam_admin
    # Launch call, some UL traffic, and Trigger A3 measurement:
    # testsuite variable ${PM_FILENAME} and ${PM_PATH} will be set:
    Keywords_handover.HO Intra gNB scenario with call and traffic and Collect Pm to Targetpath
    ...         targetpath=testsuite
    ...         gNB=0
    ...         ue_index=0
    ...         ue_capabilities=${ue_capability}
    ...         traffic_direction=UL
    ...         tput_ul=${ul_throughput}
    ...         duration=${ul_time_s}
    # ...         qxdm_log_name=5GC000706_B31_B40_J242_J243_J246_J247_A3_qxdm.hdf


706_B31_B40_J242_J243_J246_J247_Suite_Teardown
    TestSuite Basic Teardown     restore_gnb_config=True    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC000706_B_31
    [Documentation]    The purpose of this test case is to check the PM counter TOT_INTER_FREQ_HO_DECISION_A3 is pegged
    ...                during execution of a UE attach (counter is M55147C00024), with contention based configuration
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where :
    ...                  M55147C00024 value should be greater than 0
    ...                  M55306C03001 value should be greater than 0
    ${pi_M55147C00024}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55147C00024       file_name=${PM_FILENAME}
    # For contention based by default
    ${pi_M55306C03001}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55306C03001       file_name=${PM_FILENAME}
    # For contention free: none
    ${pi_M55306C05001}=     pm_analyze.get_pi_value_from_file
    ...             pi_dir=${PM_PATH}     pi_name=M55306C05001       file_name=${PM_FILENAME}

    log       M55147C00024(TOT_INTER_FREQ_HO_DECISION_A3)=${pi_M55147C00024}   console=${DEBUG_MODE_CONSOLE}
    log       M55306C03001=${pi_M55306C03001}   console=${DEBUG_MODE_CONSOLE}
    log       M55306C05001=${pi_M55306C05001}   console=${DEBUG_MODE_CONSOLE}

    should be true     ${pi_M55147C00024}==1
    # For contention based by default
    should be true     ${pi_M55306C03001}>0
    # For contention free: none
    should be true     ${pi_M55306C05001}==0


5GC000706_B_40
    [Documentation]    The purpose of this test case is to check the PM counter TOT_INTER_FREQ_HO_DECISION_A3 is pegged
    ...                during execution of a UE attach (counter is M55147C00024)
    ...
    ...            Test Steps Executions:
    ...           - Retrieve the PM reports from Suite Setup, where TOT_INTER_FREQ_HO_DECISION_A3 value
    ...                  should be greater than 0.
    ${pi_M55147C00024}=     pm_analyze.get_pi_value_from_file
    ...                     pi_dir=${PM_PATH}     pi_name=M55147C00024       file_name=${PM_FILENAME}
    log       M55147C00024(TOT_INTER_FREQ_HO_DECISION_A3)=${pi_M55147C00024}   console=${DEBUG_MODE_CONSOLE}
    should be true     ${pi_M55147C00024}==1


5GC000706_J_242
    [Documentation]    The purpose of this test case is to check the PM counter ATT_IF_INTRA_DU_HO_SA_PLMN is pegged
    ...                during execution of a UE attach (counter is M55145C00321)
    ...             Test Steps Executions:
    ...             - Retrieve the PM reports from Suite Setup, where ATT_IF_INTRA_DU_HO_SA_PLMN value
    ...                  should be greater than 0.
    keywords_706_common.J242_Check_M55145C00321      pi_dir=${PM_PATH}    file_name=${PM_FILENAME}


5GC000706_J_243
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_IF_INTRA_DU_HO_SA_PLMN is pegged
    ...                following execution of a UE attach (counter is M55145C00322)
    ...         Test Steps Executions:
    ...           - Retrieve the PM reports from Suite Setup, where SUCC_IF_INTRA_DU_HO_SA_PLMN value
    ...                  should be greater than 0
    keywords_706_common.J243_Check_M55145C00322_And_Others     pi_dir=${PM_PATH}    file_name=${PM_FILENAME}


5GC000706_J_246
    [Documentation]   The purpose of this test case is to check the PM counter ATT_IF_GNB_INTRA_DU_HO_SLICE is pegged by
    ...                5G-CP-UE during execution of a UE attach (counter is M55149C00550)
    ...           Test Steps Executions:
    ...             - Retrieve the PM reports from Suite Setup, where ATT_IF_GNB_INTRA_DU_HO_SLICE value
    ...               should be greater than 0
    keywords_706_common.J246_Check_M55149C00550_And_Others     pi_dir=${PM_PATH}    file_name=${PM_FILENAME}


5GC000706_J_247
    [Documentation]  The purpose of this test case is to check the PM counter SUCC_IF_GNB_INTRA_DU_HO_SLICE is pegged by
    ...                5G-CP-UE during execution of a UE attach (counter is M55149C00551)
    ...            Test Steps Executions:
    ...              - Retrieve the PM reports from Suite Setup, where SUCC_IF_GNB_INTRA_DU_HO_SLICE value
    ...                should be greater than 0.
    keywords_706_common.J247_Check_M55149C00551_And_Others     pi_dir=${PM_PATH}    file_name=${PM_FILENAME}
