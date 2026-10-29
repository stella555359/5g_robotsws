*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    FR1    Owner_minmluo    SBTS00    SBTS24R1
#...               RAN_5G    RAN_5G_FDD     CDRT
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${SCF_FILE}          CB005934_ET_UPD001.xml
#${IPHY_FILE}         ${CURDIR}/Resource/wts/4F_5934_UPD.xml
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${WTS_CFG}           5934_4F_UPD.cfg
#${SCF_PATH}          ./Resource/Config
#${UE_ID}             1
#${UE_ID_003}             2
#${SCELLS_INFO}       ('1', '51', '25'), ('2', '53', '25'), ('3', '54', '66')
#${EGATE_FILE}        /opt/iphy/latest/egate_console.log
#${PDU_ID}            1
#${PHYCELL_ID}        52
#${FSEI2_LAYERS_INFO}       ('1', '51', '4'), ('2', '53', '4'), ('3', '54', '4')
#${BC2FSEI2_LAYERS_INFO}    ('1', '51', '4'), ('2', '53', '4'), ('3', '54', '2')
#
#*** Test Cases ***
#CB005934_ET_UPD01_FDD_DL_4CC_Blind_Scell_Addition_Interaction_With_Optimal_BC_And_FeatureSet_Selected_Based_On_Estimated_Real_Throughput
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
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
#    Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    dl    scell    3    300
#    Check FeatureSet FSEI2 Selected    ${FSEI2_LAYERS_INFO}
#    SA Stop Data Traffic Internal    ${ue_id}    1    dl
#    SA Stop Data Traffic Internal    ${ue_id}    1    ul
#    [Teardown]   Common Test Teardown
#
#CB005934_ET_UPD03_FDD_DL_4CC_A1based_Scell_Addition_Interaction_With_CNI81817_enable_BC1BC2
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID_003}
#    Get And Check Scell Infos    ${SCELLS_INFO}    ${EGATE_FILE}
#    SA Start DL Traffic Internal    ${UE_ID_003}    ${PDU_ID}    1200    1
#    SA Start UL Traffic Internal    ${UE_ID_003}    ${PDU_ID}    100    1
#    Sleep    100s    reason=Wait For Data Transmission
#    SA Get UE Average Traffic Internal    ${UE_ID_003}    ${PDU_ID}    dl    1
#    SA Get UE Average Traffic Internal    ${UE_ID_003}    ${PDU_ID}    ul    1
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_003}    dl    pcell    0    130
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_003}    dl    scell    1    310
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_003}    dl    scell    2    310
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID_003}    dl    scell    3    350
#    Check FeatureSet FSEI2 Selected    ${BC2FSEI2_LAYERS_INFO}
#    SA Stop Data Traffic Internal    ${UE_ID_003}    1    dl
#    SA Stop Data Traffic Internal    ${UE_ID_003}    1    ul
#    [Teardown]   Common Test Teardown
#*** Keywords ***
#Check FeatureSet FSEI2 Selected
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
