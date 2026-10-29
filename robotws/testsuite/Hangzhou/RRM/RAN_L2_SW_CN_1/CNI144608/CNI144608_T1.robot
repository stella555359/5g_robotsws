*** Settings ***
Documentation    author：Changsheng chen
...              contact: c
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource    ./../CUDU_L2/common_SA_ue_command.robot
Resource    ./../CB008927/Resources/CB008927_resource.robot
Test Teardown    Common Test Teardown 2
Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00

*** Variables ***
${UE_ID}               1
${PDU_ID}              1
${Egatelog_path}       ${CURDIR}
${LOCAL_WTS_DIR}       ${CURDIR}/Config
${SCF_DIR}             ${CURDIR}/Config

${IPHY_CNI_144608_1}            ${LOCAL_WTS_DIR}/iphy_CNI_144608_1.xml
${SCF_CNI_144608_1}             ${SCF_DIR}/SCF_CNI_144608_1.xml
${WTS_CFG_CNI_144608_1}         basic_setup_CNI_144608_1.cfg
${RD}                     0x4B000F=1
${force_reboot}           ${True}

*** Test Cases ***
CNI_144608_TDD_multi_Bear_with_256QamMcs_table_counter_update
    [Documentation]
    ...    Precondition:
    ...      CNI_144608 is very mcs counter update
    ...    Check point:
    ...      1. In step1, Cell is on air without alarm.
    ...      2. In step2, PDU session for 5QI6
    ...      3. In step3, start small data for NONGBR call
    ...      4. In step4, PDU session for 5QI1
    ...      5. In step5, start data for voice data
    ...      6. Check counter update

    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CNI_144608_1}
    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_CNI_144608_1}    iphy_file=${IPHY_CNI_144608_1}
    ...               swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Common Test Setup 2
    L3 Call With SA     1    1
    Sleep    5s
    SA Start DL 5QI6_1   1
    Sleep    5s
    SA 5G Add 5QI5    1
    Sleep    1s
    SA 5G Add 5QI1    1
    Sleep    5s
    SA Start DL 5QI1    1
    Sleep    5s
    SA Start DL 5QI6_2    1
    Sleep    5s
    wait until keyword succeeds    20min    5min    Check PM Counter after call

*** Keywords ***

L3 Call With SA
    [Arguments]    ${ue_id}     ${pdu_id}
    SA 5G Attach    ${ue_id}
    SA Set Traffic Type To Internal    ${ue_id}    ${pdu_id}
    SA 5G PDU Session Setup    ${ue_id}    ${pdu_id}

SA 5G Add 5QI5
    [Arguments]    ${ue_id}
    Log To Console    start 5G 5QI5 setup...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    partial_match=${true}
    Log To Console    ${output}

SA 5G Add 5QI1
    [Arguments]    ${ue_id}
    Log To Console    start 5G 5QI1 setup...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Pdu Session Resource Modify Response Message with RAN UE NGAP ID \\d+ handled successfully    partial_match=${true}
    Log To Console    ${output}

SA Start DL 5QI1
  [Arguments]    ${ue_id}
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=dl rtp_codec=amr_12_2 trf_id=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes
SA Start DL 5QI6_1
  [Arguments]    ${ue_id}
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=5 trf_id=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes

SA Start DL 5QI6_2
  [Arguments]    ${ue_id}
  ${command}    Set Variable    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    timeout=3minutes

Check PM Counter after call
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55304C06026    MRBTS-1/NRBTS-1/NRCELL-1/NMPDU     1
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55304C06027    MRBTS-1/NRBTS-1/NRCELL-1/NMPDU     1
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55304C06025    MRBTS-1/NRBTS-1/NRCELL-1/NMPDU     1
    Run Keyword And Continue On Failure    Check PM Counter Latest Value From Admin    M55304C06024    MRBTS-1/NRBTS-1/NRCELL-1/NMPDU     1