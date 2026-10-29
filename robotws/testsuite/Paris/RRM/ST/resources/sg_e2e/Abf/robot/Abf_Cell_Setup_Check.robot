*** Settings ***
Documentation   Suite description
Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime
Library         taf.transport.ssh                           WITH NAME   ssh

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/Abf_Cell_Setup.robot


*** Keywords ***
Abf_Cell_Setup_Check
    [Documentation]     The purpose of this test is to check the Analog
    ...             Beamforming activation at OAM level only.

    [Arguments]      ${beamset}=beamsetFR2_16_8_8_1P_N45_45_N15_5    ${testMode}=False    ${BeamOffset}=0

    # Check if beamSetFR2_16_8_8_1P_N45_45_N15_5 and beam already configured.

    #Get beamSet infos
    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bs}       Split String    @{lines}[0]    separator=;

    configuration.Save SCF  SCF_pre_check.xml
    # get first the number of the cells
    ${cmd}   Set variable   grep -i "class=\\"com.nokia.srbts.nrbts:NRCELL\\"" ${scf_path}/SCF_pre_check.xml -c
    ${num}     Run    ${cmd}
    ${num}     convert to integer      ${num}
    ${num}     evaluate    6*${num}

    ${cmd}   Set variable   grep -i "<p name=\\"actBeamforming\\">true</p>" ${scf_path}/SCF_pre_check.xml -c
    ${a}     Run    ${cmd}
    ${a}     convert to integer      ${a}
    ${cmd}   Set variable   grep -i "<p name=\\"basicBeamSet\\">@{bs}[1]</p>" ${scf_path}/SCF_pre_check.xml -c
    ${b}     Run    ${cmd}
    ${b}     convert to integer      ${b}
    ${cmd}   Set variable   grep -i "<p name=\\"leftEdgeAngle\\">@{bs}[3]</p>" ${scf_path}/SCF_pre_check.xml -c
    ${c}     Run    ${cmd}
    ${c}     convert to integer      ${c}
    ${cmd}   Set variable   grep -i "<p name=\\"rightEdgeAngle\\">@{bs}[4]</p>" ${scf_path}/SCF_pre_check.xml -c
    ${d}     Run    ${cmd}
    ${d}     convert to integer      ${d}
    ${cmd}   Set variable   grep -i "<p name=\\"upperEdgeAngle\\">@{bs}[5]</p>" ${scf_path}/SCF_pre_check.xml -c
    ${e}     Run    ${cmd}
    ${e}     convert to integer      ${e}
    ${cmd}   Set variable   grep -i "<p name=\\"lowerEdgeAngle\\">@{bs}[6]</p>" ${scf_path}/SCF_pre_check.xml -c
    ${f}     Run    ${cmd}
    ${f}     convert to integer      ${f}


    ${res}   Evaluate     ${a}+${b}+${c}+${d}+${e}+${f}

    Run keyword if      ${res}<${num}    Abf_Cell_Setup     ${beamset}    ${testMode}    ${BeamOffset}
