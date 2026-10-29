*** Settings ***
Documentation    Scenario 0: Intra-DU, interband n78->n41, measurement A3
...              Author : Anne Dutheillet          anne.dutheillet@nokia.com
...              last update : 18.07.2022

Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_Attenuation.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource          keywords_6662_common.robot


*** Variables ***
# Take note that variables defined here should be mandatory in most 706 testcase, and updated accordingly to
# intra_gnb or inter_gnb scenario choice
${source_gnb}                          0
${source_cell}                         1
${nrhoif_id}		                   1
${target_gnb}                          0
${target_cell}                         2

${sce_name}							   'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
${sce_number}						   2

${source_attenuator_id}            ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuator_id']}
${target_attenuator_id}            ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuator_id']}
${source_channels}                 ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_channels']}
${target_channels}                 ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_channels']}
${attenuations_min}                ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_min']}
${attenuations_max}                ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_max']}
${source_attenuations_a2}          ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_a2']}
${target_attenuations_a2}          ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_a2']}
${target_attenuations_ho_trigger}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_ho_trigger']}
${source_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_attach']}
${target_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_attach']}
# ${qxdm_log_file}                   UETraces_706_S0.hdf


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
CB006662_Suite_Setup
    keywords_6662_common.TestSuite_6662_Preconditions
    # Check the HO algorithm configured in the source cell
    Check HO algorithm      A3
    # prepare scf
    keywords_6662_common.Perform PreCommissioning For 6662_1_2
    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO    gnb=${source_gnb}


CB006662_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


CB006662_T_R
    [Documentation]    The purpose is to check the successful configuration of A2 measurement during initial call setup
    ...                during initial call setup
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where NRRCC_MEAS_A2_REC value
    ...                  should be equal to 1.
    Check Cell Counter   pid=M55124C02002   name=NRRCC_MEAS_A2_REC
    ...                  condition=>=1   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check HO Decision A3
    Check HO IntraDU success
    Check no unexpected RRC message
    Check DL traffic
    Check UL traffic
    Check Cell Counter   pid=M55145C00321   name=ATT_IF_INTRA_DU_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Cell Counter   pid=M55145C00322   name=SUCC_IF_INTRA_DU_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Counter   pid=M55149C00550   name=ATT_IF_GNB_INTRA_DU_HO_SLICE
    ...             condition===1   gnb=${source_gnb}
    Check Counter   pid=M55149C00551   name=SUCC_IF_GNB_INTRA_DU_HO_SLICE
    ...             condition===1   gnb=${source_gnb}
