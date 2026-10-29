*** Settings ***
Documentation    ...
#Documentation
#Resource    ./Resources/CB008927_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CUDU_L2/common_SA_ue_command.robot
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    Pz4_12
#...                RAN_5G    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PDU_ID}              1
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/Config
#${SCF_DIR}             ${CURDIR}/Config
#
#${IPHY_I01}            ${LOCAL_WTS_DIR}/iphy_8927_I_robustness.xml
#${IPHY_E14}            ${LOCAL_WTS_DIR}/iphy_8927_I_E14.xml
#${SCF_I01}             ${SCF_DIR}/SCF_8927_I_robustness.xml
#${SCF_E14}             ${SCF_DIR}/SCF_8927_I_E14.xml
#${WTS_CFG_I01}         basic_setup_8927_I_robustness.cfg
#${WTS_CFG_E14}         basic_setup_8927_I_E14.cfg
#${RD}                  0x4B000F=1;0x580345=1;0x58090b=1;0x580954=1
#${force_reboot}        ${True}
#${rat0bitmap_list}       [0.0]
#
#*** Test Cases ***
#
#CB008927_37_TDD_RAT1_CELL_lock_unlock_Robustness
#    [Documentation]
#    ...    Precondition:
#    ...      CB008927 is enabled: NRBTS/NRCELL.actRat1Alloc = true
#    ...      NRBTS/actFdmScheduling = true, NRBTS/NRCELL/actFdmSchedulingInitialBWP = true, NRBTS/NRCELL/minRbReservedForNonSiPaging = 6
#    ...      NRBTS/NRCELL/raMsg2TargetRate = MCS0_SF0
#    ...      Enable PRB blanking, BBPooling and multiBWP features
#    ...    Test Steps:
#    ...      Step1: UE attach to Cell-1.
#    ...      Step2: Start full DL and UL traffic.
#    ...    Check point:
#    ...      1. In step1,UE is attached to Cell-1, resourceAllocationType1 is reported in egateconsole log pdsch-Config setup message.
#    ...      2. Check PCell and SCell Tput.
#    ...      3. Check RAT1 and RAT0 PM counters.
#    [Tags]    case_I_rt01    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_I01}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_I01}    iphy_file=${IPHY_I01}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#
#    FOR   ${index}   IN RANGE   10
#        Lock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
#        Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actRat1Alloc    true
#        Unlock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
#        Wait Until Keyword Succeeds    3min    15sec    Verify BTS Is OnAir
#        UE Register With RAT    RAT=1
#        Start SA UE Big DL Traffic Internal    ue_id=${UE_ID}    mbps=800
#        Start SA UE Big UL Traffic Internal    ue_id=${UE_ID}    mbps=100
#        Log To Console    5 min Traffic Ongoing
#        Wait Until PM Counter Update    5min    0
#        Sleep    300s    reason=wait until there have 5min full traffic
#        Check PM Counter For RAT1
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=500
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=ul    cell_type=pcell    scell_index=0    target_tp=60
#        SA 5G Detach    ue_id=1
#
#        Lock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
#        Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actRat1Alloc    false
#        Unlock Cell    cell_name=MRBTS-1/NRBTS-1/NRCELL-1
#        Wait Until Keyword Succeeds    3min    15sec    Verify BTS Is OnAir
#        UE Register With RAT    RAT=0
#        Start SA UE Big DL Traffic Internal    ue_id=${UE_ID}    mbps=800
#        Start SA UE Big UL Traffic Internal    ue_id=${UE_ID}    mbps=100
#        Log To Console    5 min Traffic Ongoing
#        Wait Until PM Counter Update    5min    0
#        Sleep    300s    reason=wait until there have 5min full traffic
#        Check PM Counter For RAT0
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=500
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=ul    cell_type=pcell    scell_index=0    target_tp=60
#        SA 5G Detach    ue_id=1
#    END
#
#
#CB008927_36_TDD_RAT1_HO_between_RAT1_cell_and_RAT0_cell_Robustness
#    [Documentation]
#    ...    Precondition:
#    ...      CB008927 is enabled: NRBTS/NRCELL.actRat1Alloc = true
#    ...      NRBTS/actFdmScheduling = true, NRBTS/NRCELL/actFdmSchedulingInitialBWP = true
#    ...    Test Steps:
#    ...      Step1: UE attach to Cell-3 with full DL and UL traffic.
#    ...      Step2: CBRA HO to Cell-1.
#    ...      Step3: CBRA HO back to Cell-3
#    ...      Step4: Do HO between Cell-3 and Cell-1 several times.
#    ...    Check point:
#    ...      1. In step1,UE is attached to Cell-1, resourceAllocationType1 is reported in egateconsole log pdsch-Config setup message.
#    ...      2. Check PCell and SCell Tput.
#    ...      3. Check RAT1 and RAT0 PM counters.
#    [Tags]    case_I_rt02    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_E14}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_E14}    iphy_file=${IPHY_E14}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#
#    SA Single UE Attach    ue_id=1
#    Start SA UE Big DL Traffic Internal    ue_id=${UE_ID}    mbps=800
#    Start SA UE Big UL Traffic Internal    ue_id=${UE_ID}    mbps=100
#    Sleep    10s
#
#    FOR   ${index}   IN RANGE   20
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=120
#        ${meas_id_A2_50}    _Get Measurement Id From Egate Log    A2
#        ${cmd_A2_50}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id_A2_50} event=A2 srsrp_nr=11 srsrq_nr=11
#        ute_wtssim.Execute Egate Command    cmd=${cmd_A2_50}
#        ${meas_id_A3_50}    _Get Measurement Id From Egate Log    A3
#        ${cmd_A3_50}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id_A3_50} event=A3 srsrp_nr=10 phycell_id=50 nrsrp_nr=120
#        ${output_50}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd_A3_50}
#        ...                pass_regexp=handover from EXT_ENB-2.3 to EXT_ENB-2.1 performed    timeout=3minutes
#        Should Contain    ${output_50}    ResourceAllocationType: RESOURCEALLOCATIONTYPE1
#        Sleep    10s
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=500
#
#        ${meas_id_A2_52}    _Get Measurement Id From Egate Log    A2
#        ${cmd_A2_52}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id_A2_52} event=A2 srsrp_nr=11 srsrq_nr=11
#        ute_wtssim.Execute Egate Command    cmd=${cmd_A2_52}
#        ${meas_id_A3_52}    _Get Measurement Id From Egate Log    A3
#        ${cmd_A3_52}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id_A3_52} event=A3 srsrp_nr=10 phycell_id=52 nrsrp_nr=120
#        ${output_52}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd_A3_52}
#        ...                pass_regexp=handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed    timeout=3minutes
#        Should Contain    ${output_52}    ResourceAllocationType: RESOURCEALLOCATIONTYPE0
#        Sleep    10s
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=120
#    END
#
#    SA 5G Detach    ue_id=1
#
#*** Keywords ***
#UE Register With RAT
#    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${RAT}=1
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
#    Log To Console    start 5G PDU Session Setup...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
#
#    ${RAT_patten}    Set Variable    resourceAllocation resourceAllocationType${RAT},(.|\r|\n)*?rbg-Size config1
#    Should Match Regexp    ${output}    ${RAT_patten}
#
#Lock Cell
#    [Arguments]    ${cell_name}
#    Setup Admin
#    Block Cell    dist_name=${cell_name}
#    Sleep    30s    reason=wait for cell lock
#    Teardown Admin
#
#Unlock Cell
#    [Arguments]    ${cell_name}
#    Setup Admin
#    UnBlock Cell    dist_name=${cell_name}
#    Sleep    30s    reason=wait for cell unlock
#    Teardown Admin
#
#Check PM Counter For RAT1
#    Wait Until PM Counter Update    5min    0
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55308C20001    CELLS/NRCELL-1/NCELA    100    102
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55308C00092    CELLS/NRCELL-1/NCELA    100    102
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55308C00093
#    ...    CELLS/NRCELL-1/NCELA    32000000    41000000
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55365C00011
#    ...    CELLS/NRCELL-1/PDCCH2    410000    510000
#    ${M55308C10001_value}    Get PM Counter Latest Value From Admin    M55308C10001    CELLS/NRCELL-1/NCELA    1
#    ${M55308C00093_value}    Get PM Counter Latest Value From Admin    M55308C00093    CELLS/NRCELL-1/NCELA    1
#    Should Be True    ${M55308C00093_value} == ${M55308C10001_value}
#
#Check PM Counter For RAT0
#    Wait Until PM Counter Update    5min    0
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55308C20001    CELLS/NRCELL-1/NCELA    97    99
#    #Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55308C00092    CELLS/NRCELL-1/NCELA    -1    1
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55308C00092    CELLS/NRCELL-1/NCELA    -1    4
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55308C00093    CELLS/NRCELL-1/NCELA    -1    1
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55365C00011    CELLS/NRCELL-1/PDCCH2    -1    1
