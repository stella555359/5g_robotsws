*** Settings ***
Documentation     CB012149 cases
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
Suite Teardown    Common Suite Teardown    debug
Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_jshen
...               SBTS00    CB012149    RAN_5G    RAN_5G_TDD    CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${SWCONFIG_PARAM}               0x590072=1;0x890001=1;0x890003=1;0x890004=1
${SCF_PATH}                     ${CURDIR}/Config
${FULL_SCF}                     CB012149_BA303_A1A2_scfc.xml
${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_AB.xml
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${WTS_CFG}                      CB012149_BA301.cfg
${3CC_DL_DATA}                  1000
${3CC_UL_DATA}                  170
${NONCA_DL_DATA}                1100
${NONCA_UL_DATA}                100
${UE_ID}                        1
${EXP_DL_TPUT}                  140
${EXP_UL_TPUT}                  16
${NON_ULCA_EXP_TPUT}            80
@{3CC_EXP_DL_TPUT_LIST}         140    40    215
@{2CC_EXP_UL_TPUT_LIST}         34    9
@{2CC_EXP_UL_TPUT_LIST_2}       15    9
@{3CC_UE_LIST}                  1    2
@{3CC_UE_LIST_1}                6
@{3CC_UE_LIST_2}                8
@{PCELL_ID_LIST}                55    55
@{3CC_SCELL_PHYSICALID_1}       50    52
@{3CC_SCELL_PHYSICALID_2}       50    52
@{3CC_SCELL_PHYSICALID_LIST}    ${3CC_SCELL_PHYSICALID_1}    ${3CC_SCELL_PHYSICALID_2}
${A1THRESHOLD}                  105
@{2CC_UL_TPUT_LIST}             15    60
${3CC}                          3

*** Test Cases ***
CB012149_ET_BA302_Connection_Setup_With_2F_2T_UL_Tx_Switching_SingleUE_With_A1_Scell_Addition
    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup
    SA 5G CA Attach    ${UE_ID}    1
    Send A1 report    ${UE_ID}    100    50
    SA Start DL Traffic Internal    ${UE_ID}    1    ${NONCA_DL_DATA}
    SA Start UL Traffic Internal    ${UE_ID}    1    ${NONCA_UL_DATA}
    Check Scell activated
	Check 3CCDL 2CCUL Pcell Scell TP
	After Send A2 report check Scell release status and UE Tput    ${UE_ID}    2    3
	After Send A1 report check Scell status and UE Tput     ${UE_ID}
	After Send A2 report check Scell release status and UE Tput    ${UE_ID}    5    6
	After Send A1 report check Scell status and UE Tput     ${UE_ID}
    SA Stop Data Traffic Internal    ${UE_ID}    1
    Check Scell Released
    Check NONCA Pcell TP
	Send A1 report    ${UE_ID}    100    50
	SA Start DL Traffic Internal    ${UE_ID}    1    ${NONCA_DL_DATA}
    SA Start UL Traffic Internal    ${UE_ID}    1    ${NONCA_UL_DATA}
    Check Scell activated
    Check 3CCDL 2CCUL Pcell Scell TP
	SA Stop Data Traffic Internal    ${UE_ID}    1
    Check Scell Released
    Check NONCA Pcell TP
    [Teardown]    Common Test Teardown    debug

*** Keywords ***
After Send A1 report check Scell status and UE Tput
    [Arguments]    ${UE_ID}
    Log To Console    UE${UE_ID} Start Send A1 reprot
    Send A1 report    ${UE_ID}    100    50
	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    SCellIndex 1 activated successfully
	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    SCellIndex 2 activated successfully
	Sleep    60s    reason=wair for data is stable
	Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    ${3CC}
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    80
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    1    80
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    2    440
	Log To Console    UE${ue_id} A1 reprot End

After Send A2 report check Scell release status and UE Tput
    [Arguments]    ${UE_ID}    ${MEAS_ID_1}    ${MEAS_ID_2}
    Log To Console    UE${UE_ID} Start Send A2 reprot
    Trigger A2 Scell Release    ${UE_ID}    1    20    55    ${MEAS_ID_1}
	Trigger A2 Scell Release    ${UE_ID}    2    20    52    ${MEAS_ID_2}
	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    sCellToReleaseList
	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    sCellToReleaseList
	Sleep    60s    reason=wair for data is stable
	Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    90
	Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    ul    pcell    0    30
	Log To Console    UE${UE_ID} A2 reprot End

Check 3CCDL 2CCUL Pcell Scell TP
    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    ${3CC}
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    75
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    1    75
    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    2    440

Check NONCA Pcell TP
	Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    0
	Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    ul    pcell    0    0

Check Scell activated
    Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    SCellIndex 1 activated successfully
	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    SCellIndex 2 activated successfully
	Sleep    30s    reason=wair for data is stable

Check Scell Released
	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    sCellToReleaseList
	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    sCellToReleaseList
	Sleep    30s    reason=wair for data is stable