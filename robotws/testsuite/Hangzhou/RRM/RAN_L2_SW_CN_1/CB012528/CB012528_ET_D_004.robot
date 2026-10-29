*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG06_SM1    CB012528    owner_qiaren
#Resource          resources/CB012528_resource.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB0012528_SCFC_12_2T.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_2F_4T}               ${CURDIR}/Config/wts/iphy_12F_2T.xml
#${SWCONFIG_PARAM_GNB}       0x58083A=1
#${WTS_CFG}                  12cell40ueprecell_3F_2T.lua
#
#@{5CC_CELL1_DL_TP}          5    4    5    9    9
#@{5CC_CELL12_DL_TP}         7    4    4    9    9
#&{XML_PARAMS_DICT}          actTwoCoresL2DeploymentFddFr1=true
#&{VENDOR_CHANGE_DICT}       list_name=${EMPTY}
#...                         ref_value=${EMPTY}    params_dict=${XML_PARAMS_DICT}
#@{VENDOR_CHANGE_LIST}       ${VENDOR_CHANGE_DICT}
#
#*** Test Cases ***
#CB012528_ET_D_004_40UE_Attach_ABIO
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    vendor_change_list=${VENDOR_CHANGE_LIST}
#    ...        iphy_file=${IPHY_2F_4T}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    40Ues_Attach
#    40Ues_Start_DL_UL_Traffic
#    Check_All_Ue_Tput
#    Capture Logs And Check TTitrace     1
#
#*** Keywords ***
#40Ues_Attach
#  ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report=true    pass_regexp=EGATE>
#    FOR    ${ue_id}    IN RANGE    1    11
#        Single Ue Attach    ${ue_id}
#        Sleep    2s    Reason=wait for PDU session completed
#    END
# 	FOR    ${ue_id}    IN RANGE    441    451
#        Single Ue Attach    ${ue_id}
#        Sleep    2s    Reason=wait for PDU session completed
#    END
#    FOR    ${ue_id}    IN RANGE    11     21
#        Single Ue Attach    ${ue_id}
#        Sleep    2s    Reason=wait for PDU session completed
#    END
#	FOR    ${ue_id}    IN RANGE    451    461
#        Single Ue Attach    ${ue_id}
#        Sleep    2s    Reason=wait for PDU session completed
#    END
#
#40Ues_Start_DL_UL_Traffic
#    FOR    ${ue_id}    IN RANGE    1    21
#        SA Start DL Traffic Internal    ${ue_id}    1    60    trf_id=1
#        SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
#        Sleep    2s    Reason=wait for traffic stable
#    END
#    FOR    ${ue_id}    IN RANGE    441    461
#        SA Start DL Traffic Internal    ${ue_id}    1    60    trf_id=1
#        SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
#        Sleep    2s    Reason=wait for traffic stable
#    END
#
#
#Check_All_Ue_Tput
#    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-20 type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
#    Sleep    10s    Reason=wait for command finish
#	  ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=121-140 type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
#    Sleep    10s    Reason=wait for command finish
#    FOR    ${id}    IN RANGE    1    21
#        Wait Until Keyword Succeeds    1min    2s     Check UE DL All Pcell Scell TP On Target For Single UE    ${id}    ${5CC_CELL1_DL_TP}    5
#        Wait Until Keyword Succeeds    1min    2s     Check CA UE Pcell Scell Cell TPut On Target    ${id}    ul    pcell    0    1
#    END
#    FOR    ${id}    IN RANGE    441    461
#        Wait Until Keyword Succeeds    1min    2s     Check UE DL All Pcell Scell TP On Target For Single UE    ${id}    ${5CC_CELL12_DL_TP}    5
#        Wait Until Keyword Succeeds    1min    2s     Check CA UE Pcell Scell Cell TPut On Target    ${id}    ul    pcell    0    1
#    END
#
