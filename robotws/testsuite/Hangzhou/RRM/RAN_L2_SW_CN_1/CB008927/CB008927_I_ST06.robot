*** Settings ***
Documentation    CB008927
...              \n Please do not edit the existing keywords in this file without testing.

Suite Teardown    Common Suite Teardown    debug
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_resource.robot
Resource          ./../CUDU_L2/common_CA.robot

*** Variables ***
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                        CB008927_06_ST_scfc.xml
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${IPHY_FILE}                        ${WTS_LOCAL}/iphy_8927_I_ST06.xml
${WTS_CFG}                        CB008927_06_ST.cfg
${RD}                                   0x580839=1;0x580345=1;0x58090b=1;0x58057b = 2097152;0x5808ff = 2;0x580954=0x1
${ttiPath0}                           ttitrace0
${ttiPath1}                           ttitrace1
${ttiPath2}                           ttitrace2
${ttiPath3}                           ttitrace3
${ttitraceFilter}                    generate_ttitrace_profile_CB008927.txt
${bip_csv}           bip_gnb.csv
${filter}          (dldata_ssblocksendreql1sw||dldata_csirssendreql1sw||(3gpp.rnti == 65535 and dldata_pdschsendreql1sw))and(3gpp.subcellid == 1)
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB008927_06_2CC_CA_TDD_PCELL_PRB_blank
    [Documentation]
    ...    Precondition:
    ...      TDD is RAT1,FDD is RAT0,256qam enable in TDD,256QAM disable in FDD.
    ...      dlDMRSAdditionalPosition=0 in TDD,dlDMRSAdditionalPosition =1 in FDD.
    ...      ueConnectionEstablishmentMode = dedicated,act beamforming,2200 is enable.
    ...    Test Steps:
    ...      Step1: attach 3 UEs, start FULL DL/UL traffic.
    ...      Step2: trigger A1 for UE1, for scell addition.
    ...      Step3: trigger Pcell change for UE1.(After pcell change, FDD Cell as pcell)
    ...      Step4: trigger A1 for UE1.
    ...      Step5: trigger scell release.
    ...    Check point:
    ...      1. check UE prb number and start prb.
    ...      2. Check RAT1 PM counters.
    [Tags]    case_I_ST06    TA_Susie    Manual_Mike
    [Setup]    Prepare TL w gNB_xml '${FULL_SCF}' AP_xml '${IPHY_FILE}' AP_cfg'${WTS_CFG}'
    #step1
    ${bip}    Capture BIP for'1s' to logDir'BIP_GNB'and convert to csv'${bip_csv}' with filter'${filter}' and'${column_name}'
    UE '1'-'3' Attach to Cell '4' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '1'-'3' PDU ID '1' TRF ID '1' QFI ID '1' with '175'mbps
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '100'mbps on UE '1' of PDU ID '1'
    ${tti1}    Capture Ttitrace for duration '1s' to log dir '${ttiPath0}'
    #step2
    Start capture Ttitrace
    Trigger A1 Scell Addition
    Sleep    2s    wait ttitracelog
    ${tti2}    Stop capture Ttitrace and convert to Excelcsv to log dir '${ttiPath1}'
    Check Whether UE In CA Mode
    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path '${ttiPath1}'
    #step3
    A2 triggered Pcell Change
    #step4
    Start capture Ttitrace
    Trigger A1 Scell Addition    ue_id=1    meas_id=4
    Sleep    1s    reason=wait for ttitrace log
    Stop capture Ttitrace and convert to Excelcsv to log dir '${ttiPath2}'
    Check Whether UE In CA Mode
    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path '${ttiPath2}'
    #step5
    A2 triggered Scell Release
    Start capture Ttitrace
    Sleep    2s    wait ttitracelog
    Stop capture Ttitrace and convert to Excelcsv to log dir '${ttiPath3}'
    Run Keyword And Continue On Failure    Verify ttitrace bler should not high than '0.01' in path '${ttiPath3}'
    #Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti1}'
    #Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti2}'
    [Teardown]    run keywords      run keyword and ignore error    SA 5G UE '1'-'2' Detach
    ...      AND    Common Test Teardown    debug

*** Keywords ***
Trigger A1 Scell Addition
   [Arguments]    ${ue_id}=1    ${meas_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=100
    ...    pass_regexp=SCellIndex 1 activated successfully

A2 triggered Pcell Change
    [Arguments]    ${ue_id}=1    ${meas_id}=3
    ${command}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=80 srsrq_nr=66 scell=1 scell_rsrp=115 scell_rsrq=100
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

A2 triggered Scell Release
    [Arguments]    ${ue_id}=1    ${meas_id}=5
    ${command}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=80 srsrq_nr=66 scell=1 scell_rsrp=115 scell_rsrq=100
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

Check Whether UE In CA Mode
    [Arguments]    ${ca_num}=2
    ${output1}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=1 type=pdsch scell=0-3    pass_regexp=EGATE
    Log    ${output1}
    Should Contain X Times    ${output1}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode
    ${output2}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=2 type=pdsch scell=0-3    pass_regexp=EGATE
    Log    ${output2}
    ${output3}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=3 type=pdsch scell=0-3    pass_regexp=EGATE
    Log    ${output3}

Verify PRB schedule as expected in log bip '${bip}' and ttitrace '${tti}'
    ${Data}    Generate Data From Bip'${bip}' TTitrace'${tti}' FrameType'1208' physCellId'53' when ignoreNotFullBufferSlot'Y'
    Check PrbNum'==101' Should not Lower Percentage'0.9' on SlotType'D' in Data'${Data}'
    Check PrbNum'==101' Should not Lower Percentage'0.9' on SlotType'S' in Data'${Data}'
    Check PrbNum'>=93' Should not Lower Percentage'0.9' on SlotType'SIB/OSI' in Data'${Data}'
    Check PrbNum'>=80' Should not Lower Percentage'0.9' on SlotType'SSB' in Data'${Data}'
    Check PrbNum'==101' Should not Lower Percentage'0.3' on SlotType'TRS' in Data'${Data}'

