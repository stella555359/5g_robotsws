*** Settings ***
Documentation    Scenario 3: Inter-gNB, measurement A3 with traffic
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
${source_gnb}     1
${source_cell}    1
${nrhoif_id}      1
${target_gnb}     0
${target_cell}    1

${sce_number}     5
${sce_name}       'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
${source_attenuator_id}    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuator_id']}
${target_attenuator_id}    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuator_id']}
${source_channels}         ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_channels']}
${target_channels}         ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_channels']}
${attenuations_min}        ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_min']}
${attenuations_max}        ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_max']}
${source_attenuations_a2}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_a2']}
${target_attenuations_a2}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_a2']}
${target_attenuations_ho_trigger}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_ho_trigger']}
${source_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_attach']}
${target_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_attach']}
# ${qxdm_log_file}   UETraces_706_S3.hdf


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    keywords_706_common.TestSuite_706_Preconditions
    # Check the HO algorithm configured in the source cell
    Check HO algorithm      A3
    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC000706_B_57
    [Documentation]    The purpose of this test case is to check that there is no downlink traffic disturbance
    ...                during the inter-gNB handover based on event A3.
    ...
    ...             Test Steps Executions:
    ...                - To check that event A3 is reported.
    ...                - To check that the HO Inter-gNB is successfull.
    ...                - To check that the external call flow on Xn and NG are as expected.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    ...                - To check the DL traffic after the HO is stable
    Check HO Decision A3
    Check HO IntergNB success
    Check external call flow
    Check no unexpected RRC message
    Check DL traffic


5GC000706_B_58
    [Documentation]    The purpose of this test case is to check there is no uplink traffic disturbance during
    ...                the inter-gNB handover based on event A3
    ...
    ...             Test Steps Executions:
    ...                - To check that event A3 is reported.
    ...                - To check that the HO Inter-gNB is successfull.
    ...                - To check that the external call flow on Xn and NG are as expected.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    ...                - To check the UL traffic after the HO is stable
    Check HO Decision A3
    Check HO IntergNB success
    Check external call flow
    Check no unexpected RRC message
    Check UL traffic
