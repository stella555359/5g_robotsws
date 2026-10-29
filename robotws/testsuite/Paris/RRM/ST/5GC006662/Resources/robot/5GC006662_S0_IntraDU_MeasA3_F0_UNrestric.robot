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
Resource          keywords_6662_common.robot


*** Variables ***
# Take note that variables defined here should be mandatory in most 706 testcase, and updated accordingly to
# intra_gnb or inter_gnb scenario choice
${source_gnb}                          0
${source_cell}                         1
${nrhoif_id}                           2
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

${scf_file_706_6662}            ${CURDIR}/../../scf/scf_CV112_6662_HO_TDD_F0_Restr_to_TDD_F0_Restr_V3.xml
${btsName706_6662}              CV112_SA_2ABIO_AEQN_AEHC_eCPRI_MIMO4x4_NPS_6662_F0_Restr_to_F0_Restr_V3


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC006662_Suite_Setup
    keywords_6662_common.TestSuite_6662_Preconditions

    # check btsName
    get btsNameScf from SCF        ${source_gnb}
    Log         btsNameSource=${btsNameScf}               console=${DEBUG_MODE_CONSOLE}
    Log         btsNameTarget=${btsName706_6662}                console=${DEBUG_MODE_CONSOLE}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log              Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}
    Run keyword if  '${btsName706_6662}' != '${btsNameScf}'         Do Commissioning            ${scf_file_706_6662}           gNB=${source_gnb}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log              End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

#    Recommission btsName CELL1                                 value=${btsNameT}              gNB=${source_gnb}      connection=coam_admin
#   Keywords_gNB.Check gNB State                                gNB=${source_gnb}

#
#
#    Recommission prachSequenceType           value=Unrestricted             gNB=${source_gnb}        cell=${source_cell}   connection=coam_admin
#    Keywords_gNB.Check gNB State
#
#    Recommission nrarfcn CELL1                                value=636666             gNB=${source_gnb}     connection=coam_admin
#    Keywords_gNB.Check gNB State
#
#    Recommission prachConfigurationIndex93 CELL1              gNB=${source_gnb}     connection=coam_admin
#    Keywords_gNB.Check gNB State

    Keywords_gNB.Create cOAM Session with alias                   gnb_id=${source_gnb}        alias=coam_admin
    Recommission prachSequenceType CELL1           value=Unrestricted           gNB=${source_gnb}            connection=coam_admin
    Keywords_gNB.Check gNB State

    Log         Applied prachSequenceType=Unrestricted on cell1              console=${DEBUG_MODE_CONSOLE}

    # Check the HO algorithm configured in the source cell
    Check HO algorithm      A3
    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO    gnb=${source_gnb}


5GC006662_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    Recommission prachSequenceType CELL1           value=RestrictedTypeA             gNB=${source_gnb}          connection=coam_admin
    Keywords_gNB.Check gNB State
    Log         Applied prachSequenceType=RestrictedTypeA on cell1              console=${DEBUG_MODE_CONSOLE}
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC006662_A_1
    [Documentation]    The purpose is to check the successful configuration of A2 measurement during initial call setup
    ...                during initial call setup
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where NRRCC_MEAS_A2_REC value
    ...                  should be equal to 1.
    Check Cell Counter   pid=M55124C02002   name=NRRCC_MEAS_A2_REC
    ...                  condition=>=1   gnb=${source_gnb}   cell=${source_cell}   type=source


5GC006662_B_30
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


5GC006662_B_33
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


5GC006662_B_34
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
    Check DL traffic
    Check UL traffic


5GC006662_J_242
    [Documentation]    The purpose of this test case is to check the PM counter ATT_IF_INTRA_DU_HO_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover (counter is M55145C00321)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where ATT_IF_INTRA_DU_HO_SA_PLMN value
    ...                  should be equal to 1.
    Check Cell Counter   pid=M55145C00321   name=ATT_IF_INTRA_DU_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source


5GC006662_J_243
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_IF_INTRA_DU_HO_SA_PLMN is pegged
    ...                during execution of an inter-frequency handover (counter is M55145C00322)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where SUCC_IF_INTRA_DU_HO_SA_PLMN value
    ...                  should be equal to 1.
    Check Cell Counter   pid=M55145C00322   name=SUCC_IF_INTRA_DU_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source


5GC006662_J_246
    [Documentation]    The purpose of this test case is to check the PM counter ATT_IF_GNB_INTRA_DU_HO_SLICE is pegged
    ...                during execution of an inter-frequency handover (counter is M55149C00550)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where ATT_IF_GNB_INTRA_DU_HO_SLICE value
    ...                  should be equal to 1.
    Check Counter   pid=M55149C00550   name=ATT_IF_GNB_INTRA_DU_HO_SLICE
    ...             condition===1   gnb=${source_gnb}


5GC006662_J_247
    [Documentation]    The purpose of this test case is to check the PM counter SUCC_IF_GNB_INTRA_DU_HO_SLICE is pegged
    ...                during execution of an inter-frequency handover (counter is M55149C00551)
    ...
    ...             Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where SUCC_IF_GNB_INTRA_DU_HO_SLICE value
    ...                  should be equal to 1.
    Check Counter   pid=M55149C00551   name=SUCC_IF_GNB_INTRA_DU_HO_SLICE
    ...             condition===1   gnb=${source_gnb}


