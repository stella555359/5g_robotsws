*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#Suite Teardown    Run Keywords    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_rewu    SBTS00    SBTS24R1
#...               RAN_5G    RAN_5G_FDD     CDRT
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${SCF_FILE}          CB005934_ET_UPD02_SCF.xml
#${IPHY_FILE}         ${CURDIR}/Resource/wts/ta_40M30M20M10M_iphy_ute.xml
#${DELTA_FILE}        Delta_conf.json
#${DELTA_FILE_A1}     Delta_A1.json
#${RECOV_FILE}        Delta_recov.json
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           5934_5F_BC2_FS1FS2.cfg
#${SCF_PATH}          ./Resource/Config
#${UE_ID}             1
#${UE_ID_A1}          3
#${SCELLS_INFO}       ('1', '51', '25'), ('2', '53', '25'), ('3', '54', '66')
#${SCELLS_INFO_A1}    ('1', '50', '71'), ('2', '51', '25'), ('3', '53', '25')
#${EGATE_FILE}        /opt/iphy/latest/egate_console.log
#${PDU_ID}            1
#${SRSRP_NR}          102
#${PHYCELL_ID}        52
#${FSEI2_LAYERS_INFO}       ('1', '50', '4'), ('2', '51', '4'), ('3', '53', '4')
#
#*** Test Cases ***
#CB005934_ET_UPD02_FDD_DL_4CC_Blind_Scell_Addition_Interaction_With_CNI81817_enable_BC2
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
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    pcell    0    160
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    scell    1    120
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    pcell    2    150
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_A1}    dl    scell    3    480
#    Check FeatureSet BC2FSEI2 Selected    ${FSEI2_LAYERS_INFO}
#    SA Stop Data Traffic Internal    ${UE_ID_A1}    1    dl
#    SA Stop Data Traffic Internal    ${UE_ID_A1}    1    ul
#    [Teardown]    Run Keywords    Delta Commission With SCF File    ${RECOV_FILE}
#    ...    AND    Common Test Teardown
#
#*** Keywords ***
#Check FeatureSet BC2FSEI2 Selected
#    [Arguments]    ${layers_info}    ${egate_file}=/opt/iphy/latest/egate_console.log
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ${content}    OperatingSystem.Get File    path=${egate_file}
#    ${regexp}    Catenate    SEPARATOR=    sCellIndex\\s+(?P<sCellIndex>\\d+),[\\s\\S]*?physCellId\\s(?P<physCellId>\\d+),
#    ...    [\\s\\S]*?maxMIMO-Layers\\s(?P<maxMIMO_Layers>\\d+)
#    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellIndex    physCellId    maxMIMO_Layers
#    ${ret_str}=    Convert To String    ${ret}
#    ${ret}=    String.Replace String Using Regexp    ${ret_str}    u    ${EMPTY}
#    Log    ${ret}
#    Should Contain    ${ret}    ${layers_info}
#
