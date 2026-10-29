*** Settings ***
Documentation   This is a Robot Test Suite for feature
...             CB008325-SR-B_Mobility_SA_Intra_inter_frequency_intra_inter_gNB_mobility
...             Team: 'MN RAN Pz ULM 1 SG'
...             Email: 'I_PZ_ULM_SQD_62@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    XML
Library    OperatingSystem
Library    Collections
Library    String

Library    taf.ue
Library    taf.sbts.oam.coam.admin          WITH NAME   admin
Library    taf.config.scf                   WITH NAME   scf
Library    taf.hw.rf_attenuator             WITH NAME   attenuator

Library    ute_tshark
Library    ute_ue

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    ../../resources/Common/pmcounters.robot

Resource    ../resources/attenuator_scenario.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/Mediatek.robot
Resource    ../resources/hanging_resources.robot
Resource    ../resources/bts_log_analysis.robot
Resource    ../resources/scf_info.robot

Suite Setup     Prepare TL for Testing
Suite Teardown  Save all Logs and Teardown TL
Test Teardown    Combined Test Teardown


*** Variables ***
${DL_THROUGHPUT}                 2 Mbits/sec
${UL_THROUGHPUT}                 1 Mbits/sec
${TPUT_DEVIATION}                10%
${INITIAL_SCF_FILE_ACTIVATION}   true
${UE_ALIAS_1}                    UE_1
${WITH_PMCOUNTER_CHECK}          true
${SOURCE_CELL}                   1
${SOURCE_CELL_2}                 3
${TARGET_CELL}                   1
${SOURCE_NODE_ID}                0
${TARGET_NODE_ID}                1
${SOURCE_NODE_TYPE}              gnb
${TARGET_NODE_TYPE}              gnb



*** Test Cases ***
SA_Intra-Frequency_NG_based_handover
    [Documentation]    This test covers intra frequency handover via NG to a cell in a neighbor gNB.
    ...                09.04.2024  because of PR761498/03580966 behavior of SW was changed. Therefore the scenario needs to be adapted.
    ...                1. Step: default configuration with 2 PLMN set for NRADJNRCELL
    ...	               2. Step: delete second PLMN set from NRADJNRCELL - succcessful ng based HO
    ...                3. Step: failure scenarion for ng based HO
    [Tags]             CB008806  CB008325  CNI84033  8806_intra  intra
    [Setup]            Perform Preconditions of Test Scenario

#    Execute TC and analyse results  scenario=SEN1  ru_id_source=${ru_id_source}  step=step1

    Commissioning source gNB step2
    Commissioning target gNB step2

    Execute TC and analyse results  scenario=SEN1  source_cell=${SOURCE_CELL}  step=step2


SA_Inter_Frequency_NG_based_handover
    [Documentation]    This test covers inter frequency handover via NG to a cell in a neighbor gNB.
    [Tags]             CB008806  CB008325  CNI84033  8806_inter  inter
    [Setup]            Perform Preconditions of Test Scenario

#    Execute TC and analyse results  scenario=SEN2  ru_id_source=${ru_id_source_2}  step=step1

    Commissioning source gNB step2
    Commissioning target gNB step2

    Execute TC and analyse results  scenario=SEN2  source_cell=${SOURCE_CELL_2}  step=step2


*** Keywords ***
Prepare TL for Testing
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    attenuator_scenario.register all attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=0
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=1

Perform Preconditions of Test Scenario
    testline.Create testcase log directory
    syve_testline.Testline Setup for CCRT
    gnb.Wait Until Node To Be Onair State   node_id=${SOURCE_NODE_ID}
    gnb.Wait Until Node To Be Onair State   node_id=${TARGET_NODE_ID}
    ${nrbts_id_1}  scf_info.Get NRBTS-Id  ${TARGET_NODE_ID}
    set test variable  ${NRBTS_id_${TARGET_NODE_ID}}  ${nrbts_id_1}
    ${nrbts_id_0}  scf_info.Get NRBTS-Id  ${SOURCE_NODE_ID}
    set test variable  ${NRBTS_ID_${SOURCE_NODE_ID}}  ${nrbts_id_0}
    ${configSuiteDir}=    testline.Get test suite config directory
    gnb.Get SCF from gNB    gnb_id=${SOURCE_NODE_ID}    target_dir=${configSuiteDir}
    gnb.Get SCF from gNB    gnb_id=${TARGET_NODE_ID}    target_dir=${configSuiteDir}
    Copy File   ${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU.xml  ${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_initial.xml
    Copy File   ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU.xml  ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_initial.xml
    gnb.Get swconfig from gNB  gnb_id=${SOURCE_NODE_ID}    target_dir=${configSuiteDir}
    gnb.Get swconfig from gNB  gnb_id=${TARGET_NODE_ID}    target_dir=${configSuiteDir}
    attenuator.Set Attenuator to Max Value
    Commissioning source gNB
    Commissioning target gNB
    setup tshark    eth1
    taf.ue.Require Ue  ${UE_ALIAS_1}  capabilities=REAL_MTK_UE

Execute TC and analyse results
    [Documentation]    This test covers inter frequency handover via NG to a cell in a neighbor gNB.
    [Arguments]    ${scenario}  ${source_cell}  ${step}
    IF  'intra' in ${TEST TAGS}
        attenuator_scenario.Set cell attenuation  globalcellid=${source_cell}  value=${20}
        ...  node_id=${SOURCE_NODE_ID}
    ELSE IF  'inter' in ${TEST TAGS}
        attenuator_scenario.Set cell attenuation  globalcellid=${source_cell_2}  value=${20}
        ...  node_id=${SOURCE_NODE_ID}
    END
    taf.ue.Detach Ue   ${UE_ALIAS_1}
    Run Keyword And Ignore Error  taf.ue.reboot  UE_1
    Get resources before test for all nodes
    tcpdump.Start Tcpdump on TestPc    options=-i eth3 sctp  collector=HO_gnb1_gnb2_${step}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  pmcounters.Wait until the next Measurement Period starts  gnb_id=${SOURCE_NODE_ID}
    taf.ue.Attach Ue   UE_1
    taf.ue.Detach Ue   ${UE_ALIAS_1}
    taf.ue.Attach Ue   UE_1
    Start UL and DL Traffic  DL_throughput=${DL_THROUGHPUT}  UL_throughput=${UL_THROUGHPUT}  step=${step}
    Set gNB ids  target_node_id=${TARGET_NODE_ID}  source_node_id=${SOURCE_NODE_ID}  source_cell=${source_cell}  target_cell=${TARGET_CELL}
    Set gNB cell attenuation scenario for gNB  scenario=${scenario}
    ${tcp_file}  tcpdump.Stop Tcpdump on TestPc  collector=HO_gnb1_gnb2_${step}
    set test variable  ${TCP_FILE}  ${tcp_file}

    Verify qc test case  ${step}
    Set gNB ids  target_node_id=${SOURCE_NODE_ID}  source_node_id=${TARGET_NODE_ID}  source_cell=${TARGET_CELL}  target_cell=${source_cell}
    tcpdump.Start Tcpdump on TestPc    options=-i eth3 sctp  collector=HO_gnb2_gnb1_${step}
    sleep  10s  reason=wait for traffic
    Set gNB cell attenuation scenario for gNB  scenario=${scenario}
    sleep  10s  reason=wait for traffic
    ${tcp_file}  tcpdump.Stop Tcpdump on TestPc  collector=HO_gnb2_gnb1_${step}
    set test variable  ${TCP_FILE}  ${tcp_file}

    Verify qc test case  ${step}

    Stop DL and UL Traffic and check throughput  Tput_deviation=${TPUT_DEVIATION}  step=${step}
    Set gNB ids  target_node_id=${SOURCE_NODE_ID}  source_node_id=${TARGET_NODE_ID}  source_cell=${TARGET_CELL}  target_cell=${source_cell}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'  Run Keyword And Continue On Failure
    ...  Check Performance counter for ng based HO  ${step}
    taf.ue.Detach Ue   UE_1
    sleep  10s  reason=wait release of resources
    Get resources after test for all nodes
    no check of resource nbOfFreeCRNTI
    Verify resource usage for all nodes
    attenuator.Set Attenuator to Max Value

Set gNB ids
    [Arguments]    ${target_node_id}  ${source_node_id}  ${source_cell}  ${target_cell}
    [Documentation]     set test vairable for target and source ids
    set test variable  ${TARGET_NODE_ID}    ${target_node_id}
    set test variable  ${SOURCE_NODE_ID}    ${source_node_id}
    set test variable  ${TARGET_NODE_TYPE}  gnb
    set test variable  ${SOURCE_NODE_TYPE}  gnb
    set test variable  ${SOURCE_CELL}       ${source_cell}
    set test variable  ${TARGET_CELL}       ${target_cell}
    Log to console  set gNB IDs

Start UL and DL Traffic
    [Arguments]    ${DL_throughput}  ${UL_throughput}  ${step}
    [Documentation]     start DL/UL Traffic on default PDU and second PDU
    taf.ue.Start Data Transfer    DT_11_${step}    UE_1    DL    duration=1800s    throughput=${DL_throughput}    protocol=udp  packet_size=1000
    ...  port=${tl.appserver.iperf_details.ports[0]}
    taf.ue.Start Data Transfer    DT_12_${step}    UE_1    UL    duration=1800s    throughput=${UL_throughput}    protocol=udp  packet_size=1000
    ...  port=${tl.appserver.iperf_details.ports[1]}
#    taf.ue.connect_additional_pdn  ue_alias=UE_1  pdn=${tl.core.pdns[0].apn}
#    Run Keyword And Continue On Failure  taf.ue.Create Bearer Alias    alias=PDU2C    qci=1    pdn=${tl.core.pdns[0].apn}
#    taf.ue.Start Data Transfer    DT_21_${step}    UE_1    DL    bearer_alias=PDU2C    packet_size=1000
#    ...    duration=1800s    throughput=${DL_throughput}    protocol=udp  port=${tl.appserver.iperf_details.ports[2]}
#    taf.ue.Start Data Transfer    DT_22_${step}    UE_1    UL    bearer_alias=PDU2C    packet_size=1000
#    ...    duration=1800s    throughput=${UL_throughput}    protocol=udp  port=${tl.appserver.iperf_details.ports[3]}

Stop DL and UL Traffic and check throughput
    [Arguments]    ${Tput_deviation}  ${step}
    [Documentation]     Stop DL/UL Traffic and check throughput with given deviation
    taf.ue.Stop Data Transfer    DT_11_${step}
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  DT_11_${step}  tput=${DL_throughput}  deviation=${Tput_deviation}
    taf.ue.Stop Data Transfer    DT_12_${step}
    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
    ...  DT_12_${step}  tput=${UL_throughput}  deviation=${Tput_deviation}
#    taf.ue.Stop Data Transfer    DT_21_${step}
#    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
#    ...  DT_21_${step}  tput=${DL_throughput}  deviation=${Tput_deviation}
#    taf.ue.Stop Data Transfer    DT_22_${step}
#    Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation
#    ...  DT_22_${step}  tput=${UL_throughput}  deviation=${Tput_deviation}

Set gNB cell attenuation scenario for gNB
    [Arguments]    ${scenario}=SEN1
    [Documentation]    starts predifined attenuation scnearion
    ${resultSuiteBaseDir}=    Get test suite result base directory
    ${template}=  Get File  ${CURDIR}/attenuator_scenario_CB008806.txt
    ${message}=  Replace Variables  ${template}
    Create File  ${resultSuiteBaseDir}/attenuator_scenario_tl.txt  ${message}
    run attenuator scenario by cell  att_file=${resultSuiteBaseDir}/attenuator_scenario_tl.txt    scenario=${scenario}

Get globalCellID from target and source Cell
    [Documentation]     get the mrbtsId for the testscenario
    ${globalCellIDTarget}=    Evaluate  ${NRBTS_ID_${TARGET_NODE_ID}}*${16384}+${TARGET_CELL}
    ${globalCellIDTarget}  Convert To Hex  ${globalCellIDTarget}  lowercase=yes
    set test variable  ${GLOBALCELLIDTARGET}
    ${globalCellIDSource}=    Evaluate  ${NRBTS_ID_${SOURCE_NODE_ID}}*${16384}+${SOURCE_CELL}
    ${globalCellIDSource}  Convert To Hex  ${globalCellIDSource}  lowercase=yes
    set test variable  ${GLOBALCELLIDSOURCE}

Commissioning source gNB
    [Documentation]    Commissioning of gnb for TC07 CB8309

    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for source gnb
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU.xml

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRCELL-${SOURCE_CELL}/NRREL-4\$:handoverAllowedSA=XnHoNotAllowed
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRCELL-${SOURCE_CELL}/NRREL-4\$:handoverAllowedSARedCap=forbidden
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRCELL-${SOURCE_CELL_2}/NRREL-4\$:handoverAllowedSA=XnHoNotAllowed
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRCELL-${SOURCE_CELL_2}/NRREL-4\$:handoverAllowedSARedCap=forbidden
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}\$:actIntraNrNgHo=sourceAndTarget
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}\$:tNgRelocExecDeltN=3000
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}\$:tNgRelocPrepN=2000
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}\$:tNgRelocOverallN=10000
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}\$:tNgRelocCancelN=2000
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/SERVEDAMF-2\$:administrativeState=Locked
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRPMRNL-1\$:miNrRelReportCu=5min
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRPMRNL-1\$:miNrNGCC=5min
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRPMRNL-1\$:miNrSlicingCuCp=5min
    ...  add:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}:suppCnPartialAdNgHo=false
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRCELL-1\$:actSib1ForNsaCell=false
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRCELL-2\$:actSib1ForNsaCell=false
    ...  modify:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRCELL-3\$:actSib1ForNsaCell=false

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_delta.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${SOURCE_NODE_ID}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

Commissioning source gNB step2
    [Documentation]    Commissioning of gnb for TC07 CB8309

    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for source gnb step 2
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU.xml

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  delete:NRBTS-${NRBTS_ID_${SOURCE_NODE_ID}}/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-2

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_mod_step2.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_mod_step2.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_delta_step2.xml

    ${oam_alias}=   connect.Setup OAM http session   node_id=${SOURCE_NODE_ID}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_delta_step2.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${SOURCE_NODE_ID}_DU_delta_step2.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

Commissioning target gNB
    [Documentation]    Commissioning of gnb for TC07 CB8309

    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for target gnb
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU.xml

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRCELL-${TARGET_CELL}/NRREL-3\$:handoverAllowedSA=XnHoNotAllowed
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRCELL-${TARGET_CELL}/NRREL-3\$:handoverAllowedSARedCap=forbidden
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRCELL-${TARGET_CELL}/NRREL-5\$:handoverAllowedSA=XnHoNotAllowed
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRCELL-${TARGET_CELL}/NRREL-5\$:handoverAllowedSARedCap=forbidden
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}\$:actIntraNrNgHo=sourceAndTarget
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}\$:tNgRelocExecDeltN=3000
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}\$:tNgRelocPrepN=2000
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}\$:tNgRelocOverallN=10000
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}\$:tNgRelocCancelN=2000
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/SERVEDAMF-2\$:administrativeState=Locked
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRPMRNL-1\$:miNrRelReportCu=5min
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRPMRNL-1\$:miNrNGCC=5min
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRPMRNL-1\$:miNrSlicingCuCp=5min
    ...  add:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}:suppCnPartialAdNgHo=false
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRCELL-1\$:actSib1ForNsaCell=false
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRCELL-2\$:actSib1ForNsaCell=false
    ...  modify:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRCELL-3\$:actSib1ForNsaCell=false

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_mod.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_mod.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta.xml

    ${delta_size}=  Get File Size  ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta.xml
    IF  ${delta_size} <= 2   RETURN

    ${oam_alias}=   connect.Setup OAM http session   node_id=${TARGET_NODE_ID}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

Commissioning target gNB step2
    [Documentation]    Commissioning of gnb for TC07 CB8309

    ${configSuiteDir}=    testline.Get test suite config directory
    Log to Console  Start commissioning for gnb
    scf.load_scf  file_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU.xml

    @{GNB_PARAMS_IN_SCF}   create list
    #  parameter changes
    ...  delete:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-2
    ...  delete:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRADJNRCELL-2/ADJ_NRPLMNSET_SA-2
    ...  delete:NRBTS-${NRBTS_ID_${TARGET_NODE_ID}}/NRADJNRCELL-3/ADJ_NRPLMNSET_SA-2

    scf.perform_scf_modification    modification_strings=${GNB_PARAMS_IN_SCF}
    scf.save_scf  ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_mod_step2.xml

    scf.calculate delta scf
    ...  target_scf_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_mod_step2.xml
    ...  actual_scf_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU.xml
    ...  delta_scf_path=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta_step2.xml

    ${delta_size}=  Get File Size  ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta_step2.xml
    IF  ${delta_size} <= 2   RETURN

    ${oam_alias}=   connect.Setup OAM http session   node_id=${TARGET_NODE_ID}
    ${file1}=  get file  ${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta_step2.xml
    IF  ${file1} != []
    ...  admin.Perform_Delta_Recommissioning    delta_file=${configSuiteDir}/SCFC_gNB${TARGET_NODE_ID}_DU_delta_step2.xml
    ...  skip_parameter_relation_errors=${True}
    ...  connection=${oam_alias}

Verify qc test case
   [Arguments]   ${step}

   run keyword  Verify qc test case ${step}

Verify qc test case step1
    [Documentation]   Check ng based HO for source and target gNB
    testline.Get testcase log directory
    Get globalCellID from target and source Cell
    ${failed} =  Run Keyword And Return Status  Check HandoverRequired  tcp_file=${TCP_FILE}
    Should Be Equal As Strings  ${failed}  False

Verify qc test case step2
    [Documentation]   Check ng based HO for source and target gNB
    testline.Get testcase log directory
    Get globalCellID from target and source Cell
    Check HandoverRequired  tcp_file=${TCP_FILE}
####under clarification with testlab support because message comes in wrong order
#    Check HandoverRequest  tcp_file=${TCP_FILE}
    Check HandoverCommand  tcp_file=${TCP_FILE}
    Check HandoverRequestAcknowledge  tcp_file=${TCP_FILE}
    Check HandoverNotify  tcp_file=${TCP_FILE}
    Check DownlinkRANStatusTransfer  tcp_file=${TCP_FILE}
    Check UplinkRANStatusTransfer  tcp_file=${TCP_FILE}
    Check HandoverRequired for source nRCellIdentity  tcp_file=${TCP_FILE}
    Check HandoverRequired for target nRCellIdentity  tcp_file=${TCP_FILE}

Verify qc test case step3
    [Documentation]   Check ng based HO for source and target gNB
    testline.Get testcase log directory
    Get globalCellID from target and source Cell
    Check HandoverRequired  tcp_file=${TCP_FILE}
####under clarification with testlab support because message comes in wrong order
#    Check HandoverRequest  tcp_file=${TCP_FILE}
    Check HandoverCommand  tcp_file=${TCP_FILE}
    Check HandoverRequestAcknowledge  tcp_file=${TCP_FILE}
    Check HandoverNotify  tcp_file=${TCP_FILE}
    Check DownlinkRANStatusTransfer  tcp_file=${TCP_FILE}
    Check UplinkRANStatusTransfer  tcp_file=${TCP_FILE}
    Check HandoverRequired for source nRCellIdentity  tcp_file=${TCP_FILE}
    Check HandoverRequired for target nRCellIdentity  tcp_file=${TCP_FILE}

Check Performance counter for ng based HO
   [Arguments]   ${step}

   run keyword  Check Performance counter for ng based HO ${TEST TAGS[0]} ${step}

Check Performance counter for ng based HO 8806_intra step1
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${SOURCE_NODE_ID}
    ${PM_dir_gnb_source}=     pmcounters.Collect PM Counter    gnb_id=${SOURCE_NODE_ID}    collector_alias=pm_counters_gnb${SOURCE_NODE_ID}
    ${PM_dir_gnb_target}=     pmcounters.Collect PM Counter    gnb_id=${TARGET_NODE_ID}    collector_alias=pm_counters_gnb${TARGET_NODE_ID}

   ${pm_counter_reference_table}=   Create List
    ...   M55125C07502  ==  0  NG based Intra-freq HO prep att on the source cell (miNrNGCC)
    ...   M55125C07514  ==  0  NG based Intra-freq HO exec att on the source cell (miNrNGCC)
    ...   M55125C07523  ==  0  Successful NG-based intra-frequency handover execution attempts on the source cell (miNrNGCC)
    ...   M55125C07503  ==  0  NG based HO resource allocation req on the target cell miNrNGCC (miNrNGCC)
    ...   M55125C07504  ==  0  Number of successful NG-based HO resource allocation requests on target cell (miNrNGCC)
    ...   M55125C07512  ==  0  successful NG based HO prep att on the source cell (miNrNGCC)
    ...   M55125C07520  ==  0  Num of NGAP: HANDOVER NOTIFY messages sent from target cell during NG-based handover (miNrNGCC)

##   ${pm_counter_reference_table_t}=   Create List
##    ...   M55153C00501  ==  1  HO prep att on the source cell for NG based HO per neighbor cell relation (miNrRelReportCu)
##    ...   M55149C03001 NG-based intra-freq HO prep att on the source cell, per PLMN per slice miNrSlicingCuCp
##    ...  M55149C03002 NG-based intra-freq HO exec att on the source cell per PLMN per slice miNrSlicingCuCp
##    ...   M55153C00502  ==  1  HO exec att on the source cell for NG based HO per neighbor cell relation (miNrRelReportCu)
##    ...   M55125C07525  ==  1  Mean time of requested HO exec att for NG based HO (miNrNGCC)
##    ...   M55125C07526  ==  1  Mean time of requested HO exec att for NG based HO (miNrNGCC)
##    ...   M55153C00503  ==  1  Successful NG-based handover execution attempts on the source cell per neighbor cell relation (miNrRelReportCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb_source}
    ...                                             distname_suffix=NRCELL-${SOURCE_CELL}

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb_target}
    ...                                             distname_suffix=NRCELL-${TARGET_CELL}

Check Performance counter for ng based HO 8806_intra step2
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${SOURCE_NODE_ID}
    ${PM_dir_gnb_source}=     pmcounters.Collect PM Counter    gnb_id=${SOURCE_NODE_ID}    collector_alias=pm_counters_gnb${SOURCE_NODE_ID}
    ${PM_dir_gnb_target}=     pmcounters.Collect PM Counter    gnb_id=${TARGET_NODE_ID}    collector_alias=pm_counters_gnb${TARGET_NODE_ID}

   ${pm_counter_reference_table}=   Create List
    ...   M55125C07502  ==  1  NG based Intra-freq HO prep att on the source cell (miNrNGCC)
    ...   M55125C07514  ==  1  NG based Intra-freq HO exec att on the source cell (miNrNGCC)
    ...   M55125C07523  ==  1  Successful NG-based intra-frequency handover execution attempts on the source cell (miNrNGCC)
    ...   M55125C07503  ==  1  NG based HO resource allocation req on the target cell miNrNGCC (miNrNGCC)
    ...   M55125C07504  ==  1  Number of successful NG-based HO resource allocation requests on target cell (miNrNGCC)
    ...   M55125C07512  ==  1  successful NG based HO prep att on the source cell (miNrNGCC)
    ...   M55125C07520  ==  1  Num of NGAP: HANDOVER NOTIFY messages sent from target cell during NG-based handover (miNrNGCC)

##   ${pm_counter_reference_table_t}=   Create List
##    ...   M55153C00501  ==  1  HO prep att on the source cell for NG based HO per neighbor cell relation (miNrRelReportCu)
##    ...   M55149C03001 NG-based intra-freq HO prep att on the source cell, per PLMN per slice miNrSlicingCuCp
##    ...  M55149C03002 NG-based intra-freq HO exec att on the source cell per PLMN per slice miNrSlicingCuCp
##    ...   M55153C00502  ==  1  HO exec att on the source cell for NG based HO per neighbor cell relation (miNrRelReportCu)
##    ...   M55125C07525  ==  1  Mean time of requested HO exec att for NG based HO (miNrNGCC)
##    ...   M55125C07526  ==  1  Mean time of requested HO exec att for NG based HO (miNrNGCC)
##    ...   M55153C00503  ==  1  Successful NG-based handover execution attempts on the source cell per neighbor cell relation (miNrRelReportCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb_source}
    ...                                             distname_suffix=NRCELL-${SOURCE_CELL}

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb_target}
    ...                                             distname_suffix=NRCELL-${TARGET_CELL}

Check Performance counter for ng based HO 8806_inter step2
    [Documentation]   Check PM counter on source and target gNB
    pmcounters.Wait until the current Measurement Period stops   gnb_id=${SOURCE_NODE_ID}
    ${PM_dir_gnb_source}=     pmcounters.Collect PM Counter    gnb_id=${SOURCE_NODE_ID}    collector_alias=pm_counters_gnb${SOURCE_NODE_ID}
    ${PM_dir_gnb_target}=     pmcounters.Collect PM Counter    gnb_id=${TARGET_NODE_ID}    collector_alias=pm_counters_gnb${TARGET_NODE_ID}

   ${pm_counter_reference_table}=   Create List
    ...   M55125C07502  ==  0  NG based Intra-freq HO prep att on the source cell (miNrNGCC)
    ...   M55125C07514  ==  0  NG based Intra-freq HO exec att on the source cell (miNrNGCC)
    ...   M55125C07523  ==  0  Successful NG-based intra-frequency handover execution attempts on the source cell (miNrNGCC)
    ...   M55125C07503  ==  1  NG based HO resource allocation req on the target cell miNrNGCC (miNrNGCC)
    ...   M55125C07504  ==  1  Number of successful NG-based HO resource allocation requests on target cell (miNrNGCC)
    ...   M55125C07512  ==  1  successful NG based HO prep att on the source cell (miNrNGCC)
    ...   M55125C07520  ==  1  Num of NGAP: HANDOVER NOTIFY messages sent from target cell during NG-based handover (miNrNGCC)

##   ${pm_counter_reference_table_t}=   Create List
##    ...   M55153C00501  ==  1  HO prep att on the source cell for NG based HO per neighbor cell relation (miNrRelReportCu)
##    ...   M55149C03001 NG-based intra-freq HO prep att on the source cell, per PLMN per slice miNrSlicingCuCp
##    ...  M55149C03002 NG-based intra-freq HO exec att on the source cell per PLMN per slice miNrSlicingCuCp
##    ...   M55153C00502  ==  1  HO exec att on the source cell for NG based HO per neighbor cell relation (miNrRelReportCu)
##    ...   M55125C07525  ==  1  Mean time of requested HO exec att for NG based HO (miNrNGCC)
##    ...   M55125C07526  ==  1  Mean time of requested HO exec att for NG based HO (miNrNGCC)
##    ...   M55153C00503  ==  1  Successful NG-based handover execution attempts on the source cell per neighbor cell relation (miNrRelReportCu)

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb_source}
    ...                                             distname_suffix=NRCELL-${SOURCE_CELL_2}

    pmcounters.Verify PM Counter Reference Table    reference_table=${pm_counter_reference_table}
    ...                                             pm_dir=${PM_dir_gnb_target}
    ...                                             distname_suffix=NRCELL-${TARGET_CELL}


Check HandoverRequired
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${handovertype}  get elements    ${output}    .//field[@name='ngap.HandoverRequired_element']//field[@name='ngap.HandoverType']
    FOR  ${i}  IN   @{handovertype}
       ${rn}  Get element attribute  ${i}  showname
       IF  '${rn}' == 'HandoverType: intra5gs (0)'   BREAK
    END
    Should Contain  ${rn}  intra5gs

Check HandoverCommand
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${HandoverType}  get elements    ${output}    .//field[@name='ngap.HandoverCommand_element']//field[@name='ngap.HandoverType']
    FOR  ${i}  IN   @{HandoverType}
       ${rn}  Get element attribute  ${i}  showname
       IF  '${rn}' == 'HandoverType: intra5gs (0)'   BREAK
    END
    Should Contain  ${rn}  intra5gs

Check HandoverRequest
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 13    output_type=pdml    pcap_file_path=${tcp_file}
    ${handovertype}  get elements    ${output}    .//field[@name='ngap.HandoverRequest_element']//field[@name='ngap.HandoverType']
    FOR  ${i}  IN   @{handovertype}
       ${rn}  Get element attribute  ${i}  showname
       IF  '${rn}' == 'HandoverType: intra5gs (0)'   BREAK
    END
    Should Contain  ${rn}  intra5gs

Check HandoverRequestAcknowledge
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 13    output_type=pdml    pcap_file_path=${tcp_file}
    ${HandoverRequestAcknowledge}    Get Element count    ${output}    .//field[@name='ngap.HandoverRequestAcknowledge_element']
    should be true  ${HandoverRequestAcknowledge} > ${0}

Check HandoverNotify
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 11    output_type=pdml    pcap_file_path=${tcp_file}
    ${HandoverNotify}    Get Element count    ${output}    .//field[@name='ngap.HandoverNotify_element']
    should be true  ${HandoverNotify} > ${0}

Check DownlinkRANStatusTransfer
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 7    output_type=pdml    pcap_file_path=${tcp_file}
    ${DownlinkRANStatusTransfer}    Get Element count    ${output}    .//field[@name='ngap.DownlinkRANStatusTransfer_element']
    should be true  ${DownlinkRANStatusTransfer} > ${0}

Check UplinkRANStatusTransfer
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 49    output_type=pdml    pcap_file_path=${tcp_file}
    ${UplinkRANStatusTransfer}    Get Element count    ${output}    .//field[@name='ngap.UplinkRANStatusTransfer_element']
    should be true  ${UplinkRANStatusTransfer} > ${0}

Check HandoverRequired for source nRCellIdentity
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${RCellIdentity}  get elements    ${output}    .//field[@name='ngap.LastVisitedCellItem_element']//field[@name='ngap.NRCellIdentity']
    FOR  ${i}  IN   @{RCellIdentity}
       ${rn}  Get element attribute  ${i}  showname
       IF  '''${GLOBALCELLIDSOURCE}''' in '''${rn}'''   BREAK
    END
    Should Contain  ${rn}  ${GLOBALCELLIDSOURCE}  ignore_case=True

Check HandoverRequired for target nRCellIdentity
    [Arguments]    ${tcp_file}
    ${output}    ute_tshark.read pcap    packet_filter=ngap.procedureCode == 12    output_type=pdml    pcap_file_path=${tcp_file}
    ${RCellIdentity}  get elements    ${output}    .//field[@name='ngap.targetCell_ID']//field[@name='ngap.NRCellIdentity']
    FOR  ${i}  IN   @{RCellIdentity}
       ${rn}  Get element attribute  ${i}  value
       IF  '''${GLOBALCELLIDTARGET}''' in '''${rn}'''   BREAK
    END
    Should Contain  ${rn}  ${GLOBALCELLIDTARGET}  ignore_case=True

Perform Postconditions of Test Scenario
    teardown tshark
    attenuator.Set Attenuator to Max Value
    Save current loads
    ${resultSuiteBaseDir}=    Get test suite result base directory
    Run Keyword And Ignore Error  Move Files   ${OUTPUT_DIR}/iperf*.txt  ${resultSuiteBaseDir}/Logs
    Run Keyword And Ignore Error  Move Files   ${OUTPUT_DIR}/moler*.log  ${resultSuiteBaseDir}/Logs
    Run Keyword And Ignore Error  Move Files   ${OUTPUT_DIR}/pyro_server*.log  ${resultSuiteBaseDir}/Logs

Combined Test Teardown
    [Documentation]
    ...    Performs the postconditions of each TC and adds a CCRT.

    Perform Postconditions of Test Scenario
    IF  '${INITIAL_SCF_FILE_ACTIVATION}' == 'true'  Testline Teardown for CCRT
    CCRT Test Cases Teardown

Save all Logs and Teardown TL
    ${suiteBaseDirectory}=  testline . Get test suite result base directory
    Run Keyword And ignore Error  filter logs for all gNBs  btslogpath=${suiteBaseDirectory}
    print filtered btslog in log file
    connect.Disconnect all available ssh connections
