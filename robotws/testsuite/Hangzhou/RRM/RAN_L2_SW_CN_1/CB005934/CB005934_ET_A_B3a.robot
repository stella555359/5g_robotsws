*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#Suite Teardown    Run Keywords    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CIT    FR1    Owner_rewu    SBTS00    SBTS24R1
#...               RAN_5G    RAN_5G_FDD     CDRT
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${SCF_FILE}          CB005934_ET_A_B3a.xml
#${IPHY_FILE}         ${CURDIR}/Resource/wts/ta_40M30M20M10M_iphy_ute.xml
#${DELTA_FILE}        Delta_conf.json
#${DELTA_FILE_A1}     Delta_A1.json
#${RECOV_FILE}        Delta_recov.json
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           5934_5F.cfg
#${SCF_PATH}          ./Resource/Config
#${UE_ID}             1
#${UE_ID_A1}          3
#${SCELLS_INFO}       ('1', '51', '25'), ('2', '53', '25'), ('3', '54', '66')
#${SCELLS_INFO_A1}    ('1', '50', '71'), ('2', '51', '25'), ('3', '53', '25')
#${EGATE_FILE}        /opt/iphy/latest/egate_console.log
#${PDU_ID}            1
#${SRSRP_NR}          102
#${PHYCELL_ID}        52
#
#*** Test Cases ***
#CB005934_ET_A_B3a_01_Single_FDD_4CCUE_Call_Blind_Scell_addition
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${ue_id}
#    Get And Check Scell Infos    ${SCELLS_INFO}    ${EGATE_FILE}
#    SA Start DL Traffic Internal    ${ue_id}    ${PDU_ID}    1000    1
#    SA Start UL Traffic Internal    ${ue_id}    ${PDU_ID}    100    1
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Get UE Average Traffic Internal    ${ue_id}    ${PDU_ID}    dl    1
#    SA Get UE Average Traffic Internal    ${ue_id}    ${PDU_ID}    ul    1
#    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    pcell    0    76
#    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    scell    1    160
#    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    scell    2    280
#    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    scell    3    380
#    SA Stop Data Traffic Internal    ${ue_id}    1    dl
#    SA Stop Data Traffic Internal    ${ue_id}    1    ul
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${RECOV_FILE}
#    ...    AND    Common Test Teardown
#
#CB005934_ET_A_B3a_02_Single_FDD_4CCUE_Call_BasedA1_Scell_addition
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_FILE_A1}
#    ...    AND    Reboot TL And Check Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID_A1}
#    Trigger A1 Scell Addition    ${UE_ID_A1}    ${SRSRP_NR}    ${PHYCELL_ID}
#    Get And Check Scell Infos    ${SCELLS_INFO_A1}    ${EGATE_FILE}
#    SA Start DL Traffic Internal    ${UE_ID_A1}    ${PDU_ID}    1000    1
#    SA Start UL Traffic Internal    ${UE_ID_A1}    ${PDU_ID}    100    1
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Get UE Average Traffic Internal    ${UE_ID_A1}    ${PDU_ID}    dl    1
#    SA Get UE Average Traffic Internal    ${UE_ID_A1}    ${PDU_ID}    ul    1
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    pcell    0    180
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    scell    1    76
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    pcell    2    176
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    scell    3    280
#    SA Stop Data Traffic Internal    ${UE_ID_A1}    1    dl
#    SA Stop Data Traffic Internal    ${UE_ID_A1}    1    ul
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${RECOV_FILE}
#    ...    AND    Common Test Teardown
