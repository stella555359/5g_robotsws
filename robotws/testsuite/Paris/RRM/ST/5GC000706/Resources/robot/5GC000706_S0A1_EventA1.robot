*** Settings ***
Documentation    Scenario 0: Event A1, Intra-DU HO attempt
...              Author : Yves Gorjux          yves.gorjux@nokia.com
...                     : Jia Liao             jia.liao@nokia.com
...              last update : 31.08.2020

Library           String
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
${nrhoif_id}                           2
${target_gnb}                          0
${target_cell}                         2

${sce_number}                          2
${sce_name}                            'gnb${source_gnb}cell${source_cell}_gnb${target_gnb}cell${target_cell}'
${source_attenuator_id}                ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuator_id']}
${target_attenuator_id}                ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuator_id']}
${source_channels}                     ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_channels']}
${target_channels}                     ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_channels']}
${attenuations_min}                    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_min']}
${attenuations_max}                    ${custom['HO_Configuration'][${sce_number}][${sce_name}]['attenuations_max']}
${source_attenuations_a1}       ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_a1']}
#${source_attenuations_a2}       ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_a2']}
${source_attenuations_a2}       480,480
${target_attenuations_a2}       ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_a2']}
${target_attenuations_ho_trigger}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_ho_trigger']}
${source_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['source_attenuations_attach']}
${target_attenuations_attach}   ${custom['HO_Configuration'][${sce_number}][${sce_name}]['target_attenuations_attach']}
# ${qxdm_log_file}                       UETraces_706_S0A1.hdf

#source_attenuations_a2:   '580,580'

${scf_file_706}          ${CURDIR}/../../scf/scf_CV112_706_7827_V4.xml
${btsName706}            CV112_SA_2ABIO_AEQN_AEHC_eCPRI_MIMO4x4_Paris_Saclay_706_7827_V3
${gnb_id}                0


*** Keywords ***
#here, define the Test Suite setup and teardown Sequence, and testcase setup/teardown if any
5GC000706_Suite_Setup
    keywords_706_common.TestSuite_706_Preconditions

    # check btsName
    get btsNameScf from SCF
    Log         btsNameSource=${btsNameScf}                console=${DEBUG_MODE_CONSOLE}
    Log         btsNameTarget=${btsName706}                console=${DEBUG_MODE_CONSOLE}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Run keyword if  '${btsName706}' != '${btsNameScf}'          Do Commissioning            ${scf_file_706}             gNB=${gnb_id}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log              End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    # Test execution
    Keywords_handover.Trigger event A1 then event A2 and Collect Pm   gnb=${source_gnb}


5GC000706_Suite_Teardown
    # you can choice to restore ori saved config (scf, or/and swconfig)
    preconditions.TestSuite Basic Teardown     restore_gnb_config=False


5GC000706_B_70
    [Documentation]    The purpose of this test case is to check that on the reception of event A1 from the UE,
    ...                the configuration of inter-frequency A3/A5 measurements and A1 measurements are removed.
    ...
    ...             Test Steps Executions:
    ...                - To check that the event A1 is received
    ...                - To check that the event A2 is received
    ...                - To check that there is at least two RRC Reconfiguration message received
    ...                - To check that there is no unexpected RRC messages on the target after the HO
    Check Cell Counter   pid=M55124C02003   name=NRRCC_MEAS_A1_REC
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Cell Counter   pid=M55124C02002   name=NRRCC_MEAS_A2_REC
    ...                  condition=>=1   gnb=${source_gnb}   cell=${source_cell}   type=source
    Check Cell Counter   pid=M55124C03001  name=NRRCC_RRC_RECONF_SENT
    ...                  condition=>=2  gnb=${source_gnb}   cell=${source_cell}    type=source   period_id=1
    Check no unexpected RRC message


5GC000706_F_109
    [Documentation]    The purpose of this test case is to check that the configuration of A2 measurement during
    ...                initial call setup is done accordingly to the set of parameters related to SA mode.
    ...
    ...             Test Steps Executions:
    ...                - To check that the parameter a2MeashoEnabled is equal to 'none'
    ...                - To check that the parameter a2MeashoEnabledSA is not equal to 'none'
    ...                - To check that the event A2 is received
    Check cell config       parameter=a2MeashoEnabled   gnb=${source_gnb}   cell=${source_cell}     value=none
    Check cell config not equal    parameter=a2MeashoEnabledSA   gnb=${source_gnb}   cell=${source_cell}     value=none

    Check Cell Counter   pid=M55124C02002   name=NRRCC_MEAS_A2_REC
    ...                  condition=>=1   gnb=${source_gnb}   cell=${source_cell}   type=source


5GC000706_F_129
    [Documentation]    The purpose of this test case is to check that the configuration of A1 measurement during
    ...                initial call setup is done accordingly to the set of parameters related to SA mode.
    ...
    ...             Test Steps Executions:
    ...                - To check that the parameter a1MeashoEnabled is equal to 'none'
    ...                - To check that the parameter a1MeashoEnabledSA is not equal to 'none'
    ...                - To check that the event A1 is received
    Check cell config       parameter=a1MeashoEnabled   gnb=${source_gnb}   cell=${source_cell}     value=none
    Check cell config not equal   parameter=a1MeashoEnabledSA   gnb=${source_gnb}   cell=${source_cell}     value=none

    Check Cell Counter   pid=M55124C02003   name=NRRCC_MEAS_A1_REC
    ...                  condition=>=1   gnb=${source_gnb}   cell=${source_cell}   type=source

