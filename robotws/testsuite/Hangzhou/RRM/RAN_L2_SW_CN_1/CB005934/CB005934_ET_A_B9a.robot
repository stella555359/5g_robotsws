*** Settings ***
Documentation    ...
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown    debug
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_minmluo    SBTS00    SBTS24R1
...               RAN_5G    RAN_5G_FDD
Resource          ../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${SCF_PATH}         ${CURDIR}/Config/
${SCF_FILE}         CB005934_ET_A_B9a.xml
${IPHY_FILE}        ${CURDIR}/Config/wts/ta_40M30M20M10M_iphy_ute.xml
${LOCAL_WTS_DIR}    ${CURDIR}/Config/wts
${WTS_CFG}          5934_5F_B9a.cfg
#${SCF_PATH}         ./Config
${UE_ID}            1
${SCELLS_INFO}      ('1', '51', '25'), ('2', '53', '25'), ('3', '54', '66')
${EGATE_FILE}       /opt/iphy/latest/egate_console.log
${PDU_ID}           1
${SRSRP_NR}         102
@{SCELL_LIST1}      1    2    3
@{SCELL_LIST2}      2    3
@{SCELL_LIST3}      3
&{COUNTER1_INFO}    counter_id=M55118C06501    counter_path=CELLS/NRCELL-1/NCAC    min_value=2    max_value=4
&{COUNTER2_INFO}    counter_id=M55118C06502    counter_path=CELLS/NRCELL-1/NCAC    min_value=2    max_value=4
&{COUNTER3_INFO}    counter_id=M55124C03001    counter_path=CELLS/NRCELL-1/NRRCC    min_value=3    max_value=8
&{COUNTER4_INFO}    counter_id=M55124C03002    counter_path=CELLS/NRCELL-1/NRRCC    min_value=3    max_value=8
&{COUNTER5_INFO}    counter_id=M55118C07001    counter_path=CELLS/NRCELL-1/NCAC    min_value=0    max_value=8
&{COUNTER6_INFO}    counter_id=M55118C09501    counter_path=CELLS/NRCELL-1/NCAC    min_value=1    max_value=300
@{COUNTER_LIST}     ${COUNTER1_INFO}    ${COUNTER2_INFO}    ${COUNTER3_INFO}    ${COUNTER4_INFO}    ${COUNTER5_INFO}    ${COUNTER6_INFO}
@{LOG_NAME_LIST}    btslog    egatelog

*** Test Cases ***
CB005934_ET_A_B9a_01_A2_Scell_Release_For_4CC_DL_CA_With_FDD_Pcell_And_3FDD_Scells
    Wait Until PM Counter Update
    SA 5G CA Attach    ${UE_ID}
    Trigger A1 Scell Addition And Check Scell Infos
    Start DL And UL Traffic And Check TPut
    Trigger A2 Scell Release    ${UE_ID}    1    70    51    2
    Check Scell Is Released    1
    Check Pcell Scell TPut    ${UE_ID}    ${SCELL_LIST2}
    Trigger A2 Scell Release    ${UE_ID}    2    70    53    3
    Check Scell Is Released    2
    Check Pcell Scell TPut    ${UE_ID}    ${SCELL_LIST3}
    Trigger A2 Scell Release    ${UE_ID}    3    70    54    4
    Check Scell Is Released    3
    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    Pcell    0    10
    Trigger A1 Scell Addition And Check Scell Infos
    Check Multi PM Counters

*** Keywords ***
Start DL And UL Traffic And Check TPut
    SA Start DL Traffic Internal    ${UE_ID}    ${PDU_ID}    800    1
    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    100    1
    Check Pcell Scell TPut    ${UE_ID}    ${SCELL_LIST1}

Check Multi PM Counters
    Wait Until PM Counter Update    5min
    Wait Until Keyword Succeeds     2min     10s      Check Multi PM Counters Latest Value From Admin    ${COUNTER_LIST}

Trigger A1 Scell Addition And Check Scell Infos
    Trigger A1 Scell Addition    1    ${SRSRP_NR}    50
    Get And Check Scell Infos    ${SCELLS_INFO}    ${EGATE_FILE}

Check Pcell Scell TPut
    [Arguments]    ${ue_id}    ${scell_list}
    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    Pcell    0    10
    FOR    ${scell_id}    IN    @{scell_list}
        Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    scell    ${scell_id}    10
    END

Check Scell Is Released
    [Arguments]    ${scell_index}
    Sleep    3s
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    path=${EGATE_FILE}
    ${releaseidregex}=    Set Variable    sCellToReleaseList[\\s\\S]{1,35}(\\d{1,2})
    ${release_id_list}=    String.Get Regexp Matches    ${content}    ${releaseidregex}    1
    ${sCellToRelease_id}=    Set Variable    ${release_id_list}[-1]
    Should Be True    "${sCellToRelease_id}"== "${scell_index}"
