*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Keywords for CB008305
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         taf.ue
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.hw.mcs  WITH NAME   MCSS
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008305/resources/TTI_8305.py   WITH NAME  tti_8305


*** Variables ***
${GNB_ALIAS}        cOAM
${MRBTS_5G_ID}=     ${tl.gnbs[0].instance_id}
${SCF_8305}=        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008305/resources/8305_SCF.xml
${parser_path}      testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008305/resources/tti_parser_8305.js

*** Keywords ***
Perform commissioning 8305
    Log to console                      __Performing 8305 SCF commissioning
    coam.connect to                     name=${GNB_ALIAS}
    ${release}                          coam.Get sw release name  connection=${GNB_ALIAS}
    coam.Teardown                       connection=${GNB_ALIAS}
    coam.connect_to                     name=${GNB_ALIAS}         release=${release}
    coam.perform commissioning          ${MRBTS_5G_ID}   ${SCF_8305}   ${True}   ${True}   600   ${GNB_ALIAS}
    Wait until keyword succeeds         10min   1min   Verify all cells are onair with admin
    coam.teardown  ${GNB_ALIAS}

Perform delta 8305
    Log to console                       __Perform delta commissioning
    Initialise delta store
    coam.Connect to                      name=${GNB_ALIAS}
    ${nrdlmumimo_path}                   Set variable    MRBTS-50560/NRBTS-50560/NRCELL-1/NRDLMUMIMO-1
    add param to delta        ${nrdlmumimo_path}     dlMuMaxNumLayerPerMuRbg       value=4
    ${delta}                             Collect delta store
    Recommission with delta from admin   ${delta}

Perform commissioning 8305-C
    Log to console                       __Perform delta commissioning for CB008305-C
    Initialise delta store
    Connect with runtime release
    add param to delta        MRBTS-51778/NRBTS-1/NRCELL-78101     actDlSrsBm       true
    add param to delta        MRBTS-51778/NRBTS-1/NRCELL-78101/NRDLMUMIMO-1    dlMuMaxNumLayerPerMuRbg       8
    ${delta}                             Collect delta store
    Recommission with delta from admin   ${delta}

Check Alarms For 8305-C
    log to console    Setting allowed alarms and comparing with actives.
    coam.connect to
    coam.add allowed alarm    parameters=faultId=61649
    coam.add allowed alarm    parameters=faultId=4655
    coam.add allowed alarm    parameters=faultId=4654
    coam.add allowed alarm    parameters=faultId=61524
    coam.add allowed alarm    parameters=faultId=61652
    coam.assert no unexpected active alarms

Setup phaseshifter
    [Documentation]  Set Phase Shifter ports using exported csv file. The configuration file is prepared manually in a
    ...              MCS application.
    Setup MCS
    ${att_list}    parser.get_att_output_channel   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/PhaseShifter_csv/8305_8701.csv
    ${phase_list}   parser.get_phase_output_channel   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/PhaseShifter_csv/8305_8701.csv
    Create output channels lists  ${att_list}   ${phase_list}
    ${length}=    Get Length    ${att_B1}
    Update attenuations   ${length}
    Update phases   ${length}

Parse and check tti PS CB008305
    [Arguments]    @{pcap_files}
    l2_trace.decode pcap file   CB008305   json
    @{pcap_files}=  List Directory   testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008305/resources  *.json  True
    FOR   ${item}   IN   @{pcap_files}
        ${out}  run keyword and ignore error  tti_8305.verify_TTI_Traces  ${item}
        Exit For Loop If    '${out[0]}' == 'PASS'
    END
    Run keyword if    '${out[0]}' != 'PASS'    Fail
