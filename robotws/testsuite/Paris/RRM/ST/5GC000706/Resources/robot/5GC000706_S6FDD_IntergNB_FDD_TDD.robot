*** Settings ***
Documentation    Scenario 6: Inter-gNB, FDD->TDD, measurement A3
...              Author : Yves Gorjux          yves.gorjux@nokia.com
...                     : Jia Liao             jia.liao@nokia.com
...              last update : 17.05.2021

Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_Attenuation.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource          keywords_706_common.robot


*** Variables ***
# Take note that variables defined here should be mandatory in most 706 testcase, and updated accordingly to
# intra_gnb or inter_gnb scenario choice
${source_gnb}    1
${source_cell}   2
${nrhoif_id}     2
${target_gnb}    0
${target_cell}   2

${sce_number}    8
${sce_name}      'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
${source_attenuator_id}     ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuator_id']}
${target_attenuator_id}     ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuator_id']}
${source_channels}          ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_channels']}
${target_channels}          ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_channels']}
${attenuations_min}         ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_min']}
${attenuations_max}         ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_max']}
${source_attenuations_a2}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_a2']}
${target_attenuations_a2}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_a2']}
${target_attenuations_ho_trigger}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_ho_trigger']}
${source_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_attach']}
${target_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_attach']}
# ${qxdm_log_file}              UETraces_706_S6FDD.hdf


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    keywords_706_common.TestSuite_706_Preconditions
    # Check the techno configured on source cell and target cell
    Check Config Techno Source and Target       FDD     TDD
    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC000706_C_325
    [Documentation]    The purpose of this test case is to check the successful handover when the source cell
    ...                is configured in FDD and the target cell is configured in TDD.
    ...
    ...             Test Steps Executions:
    ...                - To check that the HO Inter-gNB is successfull.
    ...                - To check that the external call flow on Xn and NG are as expected.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    ...                - To check the DL traffic after the HO is stable
    ...                - To check the UL traffic after the HO is stable
    Check HO IntergNB success
    Check external call flow
    Check no unexpected RRC message
    Check DL traffic
    Check UL traffic
