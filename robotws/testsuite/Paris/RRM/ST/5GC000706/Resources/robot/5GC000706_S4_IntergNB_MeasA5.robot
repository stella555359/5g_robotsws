*** Settings ***
Documentation    Scenario 4: Inter-gNB, measurement A5
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
${source_gnb}    0
${source_cell}   1
${nrhoif_id}     1
${target_gnb}    1
${target_cell}   1

${sce_number}    6
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
# ${qxdm_log_file}          UETraces_706_S4.hdf


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    keywords_706_common.TestSuite_706_Preconditions
    # Check the HO algorithm configured in the source cell
    Check HO algorithm      A5
    # Check the contention free or based configuration of the target cell before running the test
    Check Config Contention Target      n64
    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC000706_B_41
    [Documentation]    The purpose of this test case is to check the PM counter TOT_INTER_FREQ_HO_DECISION_A5 is pegged
    ...                during execution of a UE attach (counter is M55147C00025)
    ...
    ...             Test Steps Executions:
    ...                - To check that event A5 is reported.
    Check HO Decision A5


5GC000706_B_50
    [Documentation]    The purpose of this test case is to check that the gNB sends the UE RRC Reconfiguration to
    ...                the UE when event A5 is reported.
    ...
    ...             Test Steps Executions:
    ...                - To check that event A5 is reported.
    ...                - To check that the HO Inter-gNB is successfull.
    ...                - To check that the external call flow on Xn and NG are as expected.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    Check HO Decision A5
    Check HO IntergNB success
    Check external call flow
    Check no unexpected RRC message


5GC000706_B_51
    [Documentation]    The purpose of this test case is to check that the contention-based RACH procedure is
    ...                successful during inter-gNB handover based on event A5.
    ...
    ...             Test Steps Executions:
    ...                - Same checks that B_50 test.
    ...                - To check that contention based RACH procedure is successful.
    5GC000706_B_50
    Check contention based HO


5GC000706_B_53
    [Documentation]    The purpose of this test case is to check that there is no downlink traffic disturbance
    ...                during the inter-gNB handover based on event A5
    ...
    ...             Test Steps Executions:
    ...                - Same checks that B_51 test.
    ...                - To check the DL traffic after the HO is stable
    5GC000706_B_51
    Check DL traffic


5GC000706_B_54
    [Documentation]    The purpose of this test case is to check that there is no uplink traffic disturbance
    ...                during the inter-gNB handover based on event A5
    ...
    ...             Test Steps Executions:
    ...                - Same checks that B_51 test.
    ...                - To check the UL traffic after the HO is stable
    5GC000706_B_51
    Check UL traffic
