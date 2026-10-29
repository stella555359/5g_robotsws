*** Settings ***
Documentation    Scenario 7: Intra-DU, interband n41->n7, measurement A3
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
${source_gnb}          0
${source_cell}         2
${source_cell_group}   1
${nrhoif_id}           1
${target_gnb}          0
${target_cell}         1
${target_cell_group}   0

${sce_number}          9
${sce_name}            'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
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
# ${qxdm_log_file}          UETraces_706_S7DRX.hdf


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    keywords_706_common.TestSuite_706_Preconditions
    # Check the CDRX configuration of the source and target cell
    Check Config CDRX Source and Target       source_cdrx=False   target_cdrx=True
    # Test execution
    Keywords_handover.HO scenario with traffic Collect Pm during period with HO and wait next period without traffic
    #...    traffic_direction=ULDL
    #...    tput_dl=300M
    #...    tput_ul=50M
    #...    duration=600
    ...    gnb=${source_gnb}


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False

5GC000706_C_381
    [Documentation]    The purpose of this test case is to check the successful intra-DU handover when the source
    ...                cell is configured with no DRX and the target cell is configured with DRX
    ...
    ...             Test Steps Executions:
    ...                - To check that the HO Intra-DU is successfull.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    ...                - To check the DL traffic after the HO is stable
    ...                - To check the UL traffic after the HO is stable
    ...                - To check that the CDRX is active after the HO
    Check HO IntraDU success
    Check no unexpected RRC message
    Check DL traffic
    Check UL traffic
    Check CDRX active
