*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    FR1    Owner_rewu    SBTS00    SBTS23R1    SBTS22R4    RAN_5G
#...               RAN_5G_FDD
#Resource          ./5GC001167_Resource.robot
#Variables         ./5GC001167_H.yaml
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Resource/Config
#${SCF_FILE}         6cell_scfc.xml
#${IPHY_FILE}        ${CURDIR}/Resource/wts/ta_6cell_iphy_ute.xml
#${LOCAL_WTS_DIR}    ${CURDIR}/Resource/wts
#${WTS_CFG}          1167_full_config.cfg
#${WTS_AP_XML}       case10AirPhoneConfig_l1by_fdd_sa_cmw_3CC_8366.xml
#${SCF_PATH}         ./Resource/Config
#
#
#*** Test Cases ***
#5GC001167_ET_A010_Pass_Scenario_For_Changing_Scell_From_Cell5_To_Cell2
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${A010['DELTA_FILE']}
#    ...               AND    Reboot TL And Check Configured
#    ...               AND    Suite Setup Start WTS And Check OnAir
#    ...               AND    Common Test Setup
#    CA UE Noramlly Attach And Data Transmit
#    Check 2CC Scell On EGate Console Log    ${egate_path}
#    Delta Commission With SCF File    ${A010['SCF_FILE_CHANGESCF']}
#    Sleep    120s    reason=wait online changed succssfully
#    CA UE Noramlly Attach And Data Transmit
#    ${physCellId_list}    Get PhysCellId From Egate Log    ${A010['SCELLINDEX']}    ${egate_path}
#    Should Not Be Equal    ${physCellId_list[0]}    ${physCellId_list[1]}
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${A010['RECOV_FILE']}
#    ...         AND    Common Test Teardown
#
#5GC001167_ET_A008_FDD_2CC_Intra_Band_CA
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${A008['DELTA_FILE']}
#    ...               AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...               AND    Suite Setup Start WTS And Check OnAir With Workaround
#    ...               AND    Common Test Setup
#    Set Test Variable    ${ue_id}    ${A008['UE_ID']}
#    SA UE Register    ${UE_ID}
#    SA Start DL Traffic EGate    ${UE_ID}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${UE_ID}    ${pdu_id}    10
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${UE_ID}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${UE_ID}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 2CC Traffic Bigger Than Target EGate    ${UE_ID}    dl    ${expected_tput_dl}
#    SA Stop DL Traffic EGate    ${UE_ID}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${UE_ID}    ${pdu_id}
#    SA Check 2CC Traffic Bigger Than Target EGate    ${UE_ID}    dl    ${expected_tput_dl}
#    Check Intraband From Egate Log    ${egate_path}
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${A008['RECOV_FILE']}
#    ...         AND    Common Test Teardown
#
#
#5GC001167_ET_A004_Activation_Validation_With_SCellAdditionMethod_Blind_And_SCellActivationMethod_Blind
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${A004['DELTA_FILE']}
#    ...               AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...               AND    Suite Setup Start WTS And Check OnAir With Workaround
#    ...               AND    Common Test Setup
#    Set Test Variable    ${ue_id}    ${A004['UE_ID']}
#    SA UE Register    ${ue_id}
#    SA Start DL Traffic EGate    ${ue_id}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 2CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${expected_tput_dl}
#    SA Stop DL Traffic EGate    ${ue_id}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${ue_id}    ${pdu_id}
#    Check 2CC Scell On EGate Console Log    ${egate_path}
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${A004['RECOV_FILE']}
#    ...         AND    Common Test Teardown
#
#*** Keywords ***
#Check Intraband From Egate Log
#    [Arguments]    ${egate_path}
#    ${content}    OperatingSystem.Get File    ${egate_path}
#    ${patt}    Set Variable    frequencyBand: 66
#    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
#    Should Be Equal    ${matches[0]}    ${matches[1]}    ${matches[2]}    ${matches[3]}
#
#CA UE Noramlly Attach And Data Transmit
#    Set Test Variable    ${ue_id}    ${A010['UE_ID']}
#    SA UE Register    ${UE_ID}
#    SA Start DL Traffic EGate    ${UE_ID}    ${pdu_id}    150
#    SA Start UL Traffic EGate    ${UE_ID}    ${pdu_id}    10
#    Sleep    30s    reason=Wait For Data Transmission
#    SA Check Average Traffic Bigger Than Target EGate    ${UE_ID}    ${pdu_id}    dl    ${expected_tput_dl}
#    SA Check Average Traffic Bigger Than Target EGate    ${UE_ID}    ${pdu_id}    ul    ${expected_tput_ul}
#    SA Check 2CC Traffic Bigger Than Target EGate    ${UE_ID}    dl    ${expected_tput_dl}
#    SA Stop DL Traffic EGate    ${UE_ID}    ${pdu_id}
#    SA Stop UL Traffic EGate    ${UE_ID}    ${pdu_id}
#    Run Keyword And Ignore Error    SA 5G Detach    ${UE_ID}
#
#Suite Setup Start WTS And Check OnAir With Workaround
#     ${KW_status}    ${BTSonair_status}    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir
#     Run Keyword If    '${KW_status}'=='FAIL'    Not OnAir Workaround
#
#Not OnAir Workaround
#    Reboot TL And Check Configured
#    Run Keyword And Ignore Error    Clean Edaemon And Egate
#    Suite Setup Start WTS And Check OnAir