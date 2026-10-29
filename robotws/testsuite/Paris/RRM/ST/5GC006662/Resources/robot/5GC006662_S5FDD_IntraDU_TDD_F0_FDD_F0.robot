*** Settings ***
Documentation    Scenario 5: Intra-DU, TDD->FDD, measurement A5
...              Author : Yves Gorjux          yves.gorjux@nokia.com
...                     : Jia Liao             jia.liao@nokia.com
...              last update : 17.05.2021

Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_Attenuation.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource          keywords_6662_common.robot


*** Variables ***
# Take note that variables defined here should be mandatory in most 706 testcase, and updated accordingly to
# intra_gnb or inter_gnb scenario choice
${source_gnb}    1
${source_cell}   1
${nrhoif_id}     2
${target_gnb}    1
${target_cell}   2

${sce_number}    7
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
# ${qxdm_log_file}          UETraces_706_S5FDD.hdf

${scf_file_706_6662}            ${CURDIR}/../../scf/scf_CV189_6662_HO_TDD_F0_Restr_to_FDD_F1_Restr_V2.xml
${btsName706_6662}              CV189_SA_2ABIO_AEQN_eCPRI_AHLOA_NPS_6662_TDD_F0_Restr_to_FDD_F1_Restr_V2

*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC006662_Suite_Setup
     keywords_6662_common.TestSuite_6662_Preconditions

    # check btsName
    get btsNameScf from SCF     ${source_gnb}
    Log         btsNameSource=${btsNameScf}               console=${DEBUG_MODE_CONSOLE}
    Log         btsNameTarget=${btsName706_6662}                console=${DEBUG_MODE_CONSOLE}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log              Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Run keyword if  '${btsName706_6662}' != '${btsNameScf}'         Do Commissioning            ${scf_file_706_6662}           gNB=${source_gnb}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log              End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Keywords_gNB.Create cOAM Session with alias                   gnb_id=${source_gnb}        alias=coam_admin

    Log       Applied FDD AHLOA cell2 Format 0 at prachConfigurationIndex=12               console=${DEBUG_MODE_CONSOLE}
    Recommission prachConfigurationIndex CELL2        value=12          gNB=${source_gnb}         connection=coam_admin
    Keywords_gNB.Check gNB State

    # Check the techno configured on source cell and target cell
    Check Config Techno Source and Target       TDD     FDD

    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO    gnb=${source_gnb}



5GC006662_Suite_Teardown
    Log       Applied FDD AHLOA cell2 Format 1 at prachConfigurationIndex=36               console=${DEBUG_MODE_CONSOLE}
    Recommission prachConfigurationIndex CELL2        value=36          gNB=${source_gnb}          connection=coam_admin
    Keywords_gNB.Check gNB State

    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC006662_C_321
    [Documentation]    The purpose of this test case is to check the successful handover when the source cell is
    ...                configured in TDD and the target cell is configured in FDD.
    ...
    ...             Test Steps Executions:
    ...                - To check that the HO Intra-DU is successfull.
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    ...                - To check the DL traffic after the HO is stable
    ...                - To check the UL traffic after the HO is stable
    Check HO IntraDU success
    Check no unexpected RRC message
    Check DL traffic
    Check UL traffic
