*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB012528    owner_suxu
#Resource          resources/CB012528_resource.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB012528_SCFC_6F2T_D008.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_2F_4T}               ${CURDIR}/Config/wts/iphy_6F_2T.xml
#${WTS_CFG}                  CB012528_D008.lua
#${SWCONFIG_PARAM_GNB}       0x580464=20
#${CELL1_UE_NUM}             21
#@{4CC_DL_TPUT_LIST}         5    5    10    10
#@{NON4CC_DL_TPUT_LIST}      5    0    0    0
#
#&{XML_PARAMS_DICT}          actTwoCoresL2DeploymentFddFr1=true
#&{VENDOR_CHANGE_DICT}       list_name=${EMPTY}
#...                         ref_value=${EMPTY}    params_dict=${XML_PARAMS_DICT}
#@{VENDOR_CHANGE_LIST}       ${VENDOR_CHANGE_DICT}
#
#*** Test Cases ***
#CB012528_ET_D_008_CA_UE_Num_Traffic_With_Pooling_OFF_ABIO
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    vendor_change_list=${VENDOR_CHANGE_LIST}
#    ...        iphy_file=${IPHY_2F_4T}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    Cell1_Ue_Attach
#    Cell1_Ue_Start_DL_UL_Traffic
#    Check_All_Ue_Tput
#    Capture Logs And Check TTitrace     1
#
#
#*** Keywords ***
#Cell1_Ue_Attach
#    FOR    ${ue_id}    IN RANGE    1    ${CELL1_UE_NUM}+1
#	\    Single Ue Attach    ${ue_id}
#
#Cell1_Ue_Start_DL_UL_Traffic
#    FOR    ${ue_id}    IN RANGE    1    ${CELL1_UE_NUM}+1
#    \    SA Start DL Traffic Internal    ${ue_id}    1    55    trf_id=1
#    \    SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
#    sleep    5s
#
#Check_All_Ue_Tput
#    [Documentation]    This keyword is to verify Active CA UE number can be set when Pooling feature is OFF:
#    ...    Max number of active CA UEs is still set to value defined in R&D parameter rdMaxActiveCaUe(0x580464=20)
#    ...    instead of NRBTS.bbPoolCapacity.maxNumOfCAUserL2SubPool=40 in vendor file when Pooling feature is OFF.
#    FOR    ${id}    IN RANGE    1    2
#    \    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-21 type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
#    \    Sleep    10s    reason=wait 10s for traffic statble
#    FOR    ${id}    IN RANGE    1    ${CELL1_UE_NUM}
#    \    Check UE DL All Pcell Scell TP On Target For Single UE    ${id}    ${4CC_DL_TPUT_LIST}    4
#    \    Check CA UE Pcell Scell Cell TPut On Target    ${id}    ul    pcell    0    2
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${CELL1_UE_NUM}    ${NON4CC_DL_TPUT_LIST}    4
#    Check CA UE Pcell Scell Cell TPut On Target    ${CELL1_UE_NUM}    ul    pcell    0    2
