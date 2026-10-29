*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_w13li
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${SCFC_FILE}             C201_SCF.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts/
#${WTS_DIR}               /opt/iphy/latest
#${IPHY_XML}              ${CURDIR}/Config/wts/iphy_CB011080_A501.xml
#${WTS_CFG}               basic_CB011080_A501.lua
#${SWCONFIG_PARAM}        0x890071=1
#${UE_2}                  2
#${UE_8}                  8
#${MCC}                   311
#${MNC}                   489
#${AMF1_REGION}           1:2:2
#${AMF2_REGION}           2:3:3
#${PDU_ID}                1
#${6CC_NUM}               6
#@{6CC_DL_TPUT_LIST}      320    274    63    274    200    393
#@{2CC_UL_TPUT_LIST}      20    66
#@{6CC_SCELL_PCI_2T4F}    50    51    52    53    56
#
#*** Test Cases ***
#CB011080_ET_C201_Verify_6CC_A1_Based_Scell_Addition_IWK_With_ReEstablishment
#    [Setup]    Run Keywords    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
#    ...    AND    Configure IP For UEC2
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...    AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    Two Ue Attach And Check Tput
#    Trigger Reestablishment On UE    ${UE_2}    6
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}
#    ...    ${6CC_DL_TPUT_LIST}    1
#    Wait Until Keyword Succeeds    30s    5s    Check CA UE Pcell Scell Cell TPut On Target    ${UE_2}    ul    pcell    0    ${2CC_UL_TPUT_LIST}[0]
#    Trigger A1 RsrpCombain Scell Addition    ${UE_2}    100    70    55
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_8}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_2}    ${2CC_UL_TPUT_LIST}    2
#    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_8}    ${2CC_UL_TPUT_LIST}    2
#
#*** Keywords ***
#Trigger Reestablishment On UE
#    [Arguments]    ${ue_id}    ${cell_id}    ${gnb}=2    ${cause}=reconfigurationFailure
#    [Documentation]    This keyword is to trigger A2 scell release
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | yes | the id of ue |
#    ...    | cell_id | yes | the id of cell |
#    ...    | gnb | yes | the value of gnb |
#    ...    | cause | yes | Reestablishment cause |
#    ...
#    ...    Examples:
#    ...    | Trigger Reestablishment On UE | 1 | 1 | 1 | 51 |
#    ...
#    ${cmd}    Catenate    SEPARATOR=${SPACE}    ue_rrc_reestablish id=${ue_id} gnb=${gnb} cell=${cell_id}
#    ...    cause=${cause}
#    ${ret1}=    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=rrcReconfigurationComplete
#    ...    timeout=3minutes
#
#Two Ue Attach And Check Tput
#    UE Attach And A1 Addition    ${UE_2}    ${AMF1_REGION}
#    UE Attach And A1 Addition    ${UE_8}    ${AMF2_REGION}
#	Start SA UE Big DL Traffic Internal    ${UE_2}    1900
#    Start SA UE Big DL Traffic Internal    ${UE_8}    1900
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#    Wait Until Keyword Succeeds    600s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_8}
#    ...    ${6CC_DL_TPUT_LIST}    ${6CC_NUM}
#    Start SA UE Big UL Traffic Internal    ${UE_2}    300
#	Start SA UE Big UL Traffic Internal    ${UE_8}    300
#    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_2}    ${2CC_UL_TPUT_LIST}    2
#    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_8}    ${2CC_UL_TPUT_LIST}    2
#
#UE Attach And A1 Addition
#    [Arguments]    ${ue_id}    ${amf_region}=1:2:2
#    Single Ue Attach    ${ue_id}    ${amf_region}
#    Trigger A1 RsrpCombain Scell Addition    ${ue_id}    100    70    55    meas_id=1
#    Sleep    1s    reason=wait it take effect
#
#Trigger A2 Release
#    [Arguments]    ${ue_id}    ${scell_id}=1    ${scell_rsrp}=36    ${phycell_id}=51    ${meas_id}=${EMPTY}
#    [Documentation]    This keyword is to trigger A2 scell release
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | yes | the id of ue |
#    ...    | scell_id | yes | the id of scell |
#    ...    | scell_rsrp | yes | the value of scell_rsrp |
#    ...    | phycell_id | yes | phycell id for scell |
#    ...
#    ...    Examples:
#    ...    | Trigger A2 Scell Release | 1 | 1 | 1 | 51 |
#    ...
#    ${cmd}    Catenate    SEPARATOR=${SPACE}    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
#    ...    scell=${scell_id} scell_rsrp=${scell_rsrp} phycell_id=${phycell_id}
#    ${ret1}=    ute_wtssim.Execute Egate Command    cmd=${cmd}    pass_regexp=rrc(Connection)?ReconfigurationComplete
#
#Configure IP For UEC2
#    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
#    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
#
#Trigger A1 RsrpCombain Scell Addition
#    [Arguments]    ${ue_id}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}    ${meas_id}=${EMPTY}
#    [Documentation]    This keyword is to trigger A1 scell added.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | the id of ue |
#    ...    | srsrp_nr | Yes | the value of srsrp_nr |
#    ...    | phycell_id | Yes | phycell id of the cell |
#    ...
#    ...    Examples:
#    ...    | Trigger A1 Scell Addition | 1 | 70 | 50 |
#    ...
#    ${meas_id_from_egate}    Get Measurement Id From Egate Log    A1    ${ue_id}
#    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} phycell_id=${phycell_id}
#    ...    pass_regexp=rrc(Connection)?ReconfigurationComplete
