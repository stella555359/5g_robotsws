*** Settings ***
Documentation    Scenario 0: Intra-DU, interband n78->n41, measurement A3
...              Author : Yves Gorjux          yves.gorjux@nokia.com
...                     : Jia Liao             jia.liao@nokia.com
...              last update : 31.08.2020

Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_Attenuation.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource          keywords_706_common.robot


*** Variables ***
# Take note that variables defined here should be mandatory in most 706 testcase, and updated accordingly to
# intra_gnb or inter_gnb scenario choice
${source_gnb}                          0
${source_cell}                         1
${nrhoif_id}		               2
${target_gnb}                          0
${target_cell}                         2

${sce_name}                            'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
${sce_number}                          2

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

${scf_file_706}         ${CURDIR}/../../scf/scf_CV112_706_7827_V4.xml
${btsName706}           CV112_SA_2ABIO_AEQN_AEHC_eCPRI_MIMO4x4_Paris_Saclay_706_7827_V4


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    [Arguments]       ${gnb_id}=${0}
    keywords_706_common.TestSuite_706_Preconditions
    Setup Testline Suite Variables
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=${gnb_id}
    keywords_706_common.Check gNB and Get reportingIntervalPm Value
    Keywords_gNB.Create cOAM Session with alias                   gnb_id=${gnb_id}        alias=coam_admin
    keywords_706_common.get btsNameScf from SCF
    Run keyword if  '${btsName706}' != '${btsNameScf}'         Do Commissioning          ${scf_file_706}            gNB=${gnb_id}

    # Check the HO algorithm configured in the source cell
    Check HO algorithm      A3
    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO    gnb=${source_gnb}


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC000706_A_1
    [Documentation]    The purpose is to check the successful configuration of A2 measurement during initial call setup
    ...                during initial call setup
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where NRRCC_MEAS_A2_REC value
    ...                  should be equal to 1.
    Check Cell Counter   pid=M55124C02002   name=NRRCC_MEAS_A2_REC
    ...                  condition=>=1   gnb=${source_gnb}   cell=${source_cell}   type=source


5GC000706_B_30
    [Documentation]    The purpose of this test case is to check that the gNB sends the UE RRC Reconfiguration
    ...                to the UE when event A3 is reported.
    ...
    ...             Test Steps Executions:
    ...                - To check that event A3 is reported.
    ...                - To check that the HO Intra-DU is successfull.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    Check HO Decision A3
    Check HO IntraDU success
    Check no unexpected RRC message


5GC000706_B_33
    [Documentation]    The purpose of this test case is to check that there is no downlink traffic disturbance
    ...                during the intra-DU handover based on event A3
    ...
    ...             Test Steps Executions:
    ...                - To check that event A3 is reported.
    ...                - To check that the HO Intra-DU is successfull.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    ...                - To check the DL traffic after the HO is stable
    Check HO Decision A3
    Check HO IntraDU success
    Check no unexpected RRC message
    Check DL traffic


5GC000706_B_34
    [Documentation]    The purpose of this test case is to check that there is no uplink traffic disturbance
    ...                during the intra-DU handover based on event A3
    ...
    ...             Test Steps Executions:
    ...                - To check that event A3 is reported.
    ...                - To check that the HO Intra-DU is successfull.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    ...                - To check the UL traffic after the HO is stable
    Check HO Decision A3
    Check HO IntraDU success
    Check no unexpected RRC message
    Check UL traffic


5GC000706_J_242
    [Documentation]    The purpose of this test case is to check the PM counter ATT_IF_INTRA_DU_HO_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover (counter is M55145C00321)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where ATT_IF_INTRA_DU_HO_SA_PLMN value
    ...                  should be equal to 1.
    Check Cell Counter   pid=M55145C00321   name=ATT_IF_INTRA_DU_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source


5GC000706_J_243
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_IF_INTRA_DU_HO_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover (counter is M55145C00322)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where SUCC_IF_INTRA_DU_HO_SA_PLMN value
    ...                  should be equal to 1.
    Check Cell Counter   pid=M55145C00322   name=SUCC_IF_INTRA_DU_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source


5GC000706_J_246
    [Documentation]    The purpose of this test case is to check the PM counter ATT_IF_GNB_INTRA_DU_HO_SLICE is pegged
    ...                during execution of an inter-frequency handover (counter is M55149C00550)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where ATT_IF_GNB_INTRA_DU_HO_SLICE value
    ...                  should be equal to 1.
    Check Counter   pid=M55149C00550   name=ATT_IF_GNB_INTRA_DU_HO_SLICE
    ...             condition===1   gnb=${source_gnb}


5GC000706_J_247
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_IF_GNB_INTRA_DU_HO_SLICE is pegged
    ...                during execution of an inter-frequency handover (counter is M55149C00551)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where SUCC_IF_GNB_INTRA_DU_HO_SLICE value
    ...                  should be equal to 1.
    Check Counter   pid=M55149C00551   name=SUCC_IF_GNB_INTRA_DU_HO_SLICE
    ...             condition===1   gnb=${source_gnb}
