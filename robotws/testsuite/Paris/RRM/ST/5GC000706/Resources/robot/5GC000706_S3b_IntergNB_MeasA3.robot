*** Settings ***
Documentation    Scenario 3b: Inter-gNB, measurement A3 without traffic
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
${source_cell}   1
${nrhoif_id}     1
${target_gnb}    0
${target_cell}   1

${sce_number}    5
${sce_name}      'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
${source_attenuator_id}    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuator_id']}
${target_attenuator_id}    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuator_id']}
${source_channels}         ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_channels']}
${target_channels}         ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_channels']}
${attenuations_min}        ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_min']}
${attenuations_max}        ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_max']}
${source_attenuations_a2}    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_a2']}
${target_attenuations_a2}    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_a2']}
${target_attenuations_ho_trigger}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_ho_trigger']}
${source_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_attach']}
${target_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_attach']}
# ${qxdm_log_file}         UETraces_706_S3b.hdf


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    keywords_706_common.TestSuite_706_Preconditions
    # Check the HO algorithm configured in the source cell
    Check HO algorithm      A3
    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO    traffic_direction=none


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC000706_B_40
    [Documentation]    The purpose of this test case is to check the PM counter TOT_INTER_FREQ_HO_DECISION_A3 is pegged
    ...                during execution of an inter-frequency handover (counter is M55147C00024)
    ...
    ...             Test Steps Executions:
    ...                - To check that event A3 is reported.
    Check HO Decision A3


5GC000706_B_55
    [Documentation]    The purpose of this test case is to check that the gNB sends the UE RRC Reconfiguration to
    ...                the UE when event A3 is reported
    ...
    ...             Test Steps Executions:
    ...                - To check that event A3 is reported.
    ...                - To check that the HO Inter-gNB is successfull.
    Check HO Decision A3
    Check HO IntergNB success


5GC000706_J_260
    [Documentation]    The purpose of this test case is to check the PM counter ATT_OG_IF_INTER_GNB_HO_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover  (counter is M55145C00351)
    ...
    ...         Test Steps Executions:
    ...         - Retrieve the PM reports from Suite Setup, where ATT_OG_IF_INTER_GNB_HO_SA_PLMN value (expected value)
    ...           should be equal to 1 on source gNB and 0 on the target gNB.
    Check Cell Counter   pid=M55145C00351   name=ATT_OG_IF_INTER_GNB_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Cell Counter   pid=M55145C00351   name=ATT_OG_IF_INTER_GNB_HO_SA_PLMN
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}   type=target


5GC000706_J_261
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_OG_IF_INTERGNB_HO_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover  (counter is M55145C00352)
    ...
    ...         Test Steps Executions:
    ...         - Retrieve the PM reports from Suite Setup, where SUCC_OG_IF_INTERGNB_HO_SA_PLMN value (expected value)
    ...           should be equal to 1 on source gNB and 0 on the target gNB.
    Check Cell Counter   pid=M55145C00352   name=SUCC_OG_IF_INTERGNB_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Cell Counter   pid=M55145C00352   name=SUCC_OG_IF_INTERGNB_HO_SA_PLMN
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}   type=target


5GC000706_J_262
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_IC_INTER_GNB_HOP_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover  (counter is M55145C00361)
    ...
    ...         Test Steps Executions:
    ...         - Retrieve the PM reports from Suite Setup, where SUCC_IC_INTER_GNB_HOP_SA_PLMN value (expected value)
    ...           should be equal to 1 on target gNB and 0 on the source gNB.

    Check Cell Counter   pid=M55145C00361   name=SUCC_IC_INTER_GNB_HOP_SA_PLMN
    ...                  condition===0   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Cell Counter   pid=M55145C00361   name=SUCC_IC_INTER_GNB_HOP_SA_PLMN
    ...                  condition===1   gnb=${target_gnb}   cell=${target_cell}   type=target


5GC000706_J_263
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_IC_INTER_GNB_HO_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover (counter is M55145C00362)
    ...
    ...          Test Steps Executions:
    ...          - Retrieve the PM reports from Suite Setup, where SUCC_IC_INTER_GNB_HO_SA_PLMN value (expected value)
    ...            should be equal to 1 on target gNB and 0 on the source gNB.

    Check Cell Counter   pid=M55145C00362   name=SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...                  condition===0   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Cell Counter   pid=M55145C00362   name=SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...                  condition===1   gnb=${target_gnb}   cell=${target_cell}   type=target


5GC000706_J_264
    [Documentation]    The purpose of this test case is to check the PM counter ATT_IF_INTER_GNB_HO_SLICE is pegged
    ...                during execution of an inter-frequency handover  (counter is M55149C00570)
    ...
    ...          Test Steps Executions:
    ...          - Retrieve the PM reports from Suite Setup, where ATT_IF_INTER_GNB_HO_SLICE value (expected value)
    ...            should be equal to 1 on source gNB

    Check Counter   pid=M55149C00570   name=ATT_IF_INTER_GNB_HO_SLICE
    ...             condition===1   gnb=${source_gnb}

