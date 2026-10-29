*** Settings ***
Documentation    Scenario 4: Inter-gNB, measurement A5
...              Author : Yves Gorjux          yves.gorjux@nokia.com
...                     : Jia Liao             jia.liao@nokia.com
...              last update : 17.05.2021

Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_Attenuation.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_handover.robot
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource          keywords_706_common.robot


*** Variables ***
# Take note that variables defined here should be mandatory in most 706 testcase, and updated accordingly to
# intra_gnb or inter_gnb scenario choice
${source_gnb}     0
${source_cell}    1
${nrhoif_id}      1
${target_gnb}     1
${target_cell}    1

${sce_number}     6
${sce_name}       'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
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
# ${qxdm_log_file}          UETraces_706_S4BW.hdf


${scf_file_706}                ${CURDIR}/../../scf/scf_CV112_ASOE_706_7827_V4_EM.xml
${btsName706}                  CV112_SA_ASOE_AEQN_AEHC_eCPRI_MIMO4x4_Paris_Saclay_706_7827_V4_EM

${scf_file_706_CV189}          ${CURDIR}/../../scf/scf_CV189_706_V2.xml
${btsName706_CV189}            CV189_706_SA_2ABIO_AEQN_eCPRI_AHLOA_FDD_V2



*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    keywords_706_common.TestSuite_706_Preconditions
    # Check that both source and target cell are using the same band
    Check Same Config Band Source and Target
    # Check the bandwidth configuration of the source and target cell
    Check Config Bandwidth Source and Target    100MHz      60MHz


    # check btsName CV112
    get btsNameScf from SCF    ${source_gnb}
    Log         btsNameSource=${btsNameScf}                console=${DEBUG_MODE_CONSOLE}
    Log         btsNameTarget=${btsName706}                console=${DEBUG_MODE_CONSOLE}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Run keyword if  '${btsName706}' != '${btsNameScf}'          Do Commissioning            ${scf_file_706}             gNB=${source_gnb}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log              End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    # check btsName CV189
    get btsNameScf from SCF    ${target_gnb}
    Log         btsNameSource=${btsNameScf}                console=${DEBUG_MODE_CONSOLE}
    Log         btsNameTarget=${btsName706_CV189}                console=${DEBUG_MODE_CONSOLE}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Run keyword if  '${btsName706_CV189}' != '${btsNameScf}'          Do Commissioning            ${scf_file_706_CV189}             gNB=${target_gnb}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log              End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}


    # Test execution
    Keywords_handover.HO scenario with call and traffic and Collect Pm during period with HO


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC000706_C_335
    [Documentation]    The purpose of this test case is to check successful handover when the source cell is
    ...                configured with a bandwidth of 100 MHz and the target cell is configured with a
    ...                bandwidth of 60 MHz
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
