*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_jshen
#...               SBTS00    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB009169_Ba1603_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Ba1603.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Ba1603.cfg
#${1T_3F_DL_DATA}                  200
#${1T_3F_UL_DATA}                  80
#@{1T_3F_EXP_DL_TPUT_LIST}         50    10    10    10
#@{1T_3F_EXP_UL_TPUT_LIST}         2    2
#@{4CC_PCELL_ID_LIST}              52    52    52    52
#@{4CC_SCELL_PHYSICALID}           50    53    54
#@{4CC_SCELL_PHYSICALID_LIST_1}    ${4CC_SCELL_PHYSICALID}    ${4CC_SCELL_PHYSICALID}    ${4CC_SCELL_PHYSICALID}    ${4CC_SCELL_PHYSICALID}
#@{2CC_SCELL_PHYSICALID_1}         55
#@{2CC_SCELL_PHYSICALID_LIST_1}    ${2CC_SCELL_PHYSICALID_1}
#@{4CC_UE_LIST}                    3    8    9    7
#@{GBR_UE_LIST}                    3    8    9
#@{QFI_ID_LIST}                    3    2    3
#${LOW_A1THRESHOLD}                95
#${HIGH_A1THRESHOLD}               105
#&{UE3_5QI_INFO_1}                 ue_id=3    qfi=2    qosflows_id_5qi=5
#&{UE3_5QI_INFO_2}                 ue_id=3    qfi=3    qosflows_id_5qi=1
#&{UE8_5QI_INFO}                   ue_id=8    qfi=4    qosflows_id_5qi=2
#&{UE9_5QI_INFO_1}                 ue_id=9    qfi=2    qosflows_id_5qi=5
#&{UE9_5QI_INFO_2}                 ue_id=9    qfi=3    qosflows_id_5qi=1
#@{UE_5QI_INFO_LIST}               ${UE3_5QI_INFO_1}    ${UE3_5QI_INFO_2}    ${UE8_5QI_INFO}    &{UE9_5QI_INFO_1}    &{UE9_5QI_INFO_2}
#
#*** Test Cases ***
#CB009169_ET_BA1603_T_F_MultiUE_Lch_ToSCellRestriction_Capability_VONR_And_NonGBR
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_1}    ${LOW_A1THRESHOLD}    4
#    Trigger 5QI Setup For Multi UE    ${UE_5QI_INFO_LIST}
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${1T_3F_DL_DATA}    ${1T_3F_UL_DATA}
#    Start Multi UE SA VONR GBR DL And UL Traffic    ${GBR_UE_LIST}    ${QFI_ID_LIST}    10    10
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST[0:2]}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST[3:4]}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    SA Check UE Cell TPut On Target    3    1    dl    2    3
#    SA Check UE Cell TPut On Target    8    1    dl    2    2
#    SA Check UE Cell TPut On Target    9    1    dl    2    3
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=9    dir=ul    cell_type=scell    scell_index=1
#    Should Be True    ${scell_ul_tp}==0
#    Trigger A1 Scell Addition    7    ${HIGH_A1THRESHOLD}    52
#    Check SA Scell PhysicalID With UE ID    7    55    4
#
#*** Keywords ***
#Start Multi UE SA VONR GBR DL And UL Traffic
#    [Arguments]    ${ue_id_list}    ${qfi_id_list}    ${dl_trf}    ${ul_trf}    ${pdu_id}=1
#    FOR    ${ue_id}    ${qfi_id}    IN ZIP    ${ue_id_list}    ${qfi_id_list}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu=${pdu_id} qfi\=${qfi_id} trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu=${pdu_id} qfi\=${qfi_id} trf_id=1 mbps\=${ul_trf} dir=ul protocol=udp
#    END
#    Sleep    5s    reason=wait DL/UL traffic is stable
