*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB
#...               AND    Suite Setup Copy WTS Config Files From QT
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
#...               SBTS00    CN1_SQ6    CB009169
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
##Common
#${WTS_LOCAL}                  ${CURDIR}/Resources/wts
#${IPHY_FILE_1}                ${WTS_LOCAL}/iphy_3T_2F.xml
#${IPHY_FILE_2}                ${WTS_LOCAL}/iphy_3F_2T.xml
#${IPHY_FILE_3}                ${WTS_LOCAL}/iphy_3T_2F_2.xml
#${IPHY_FILE_4}                ${WTS_LOCAL}/iphy_3F_2T.xml
#${SCF_PATH}                   ${CURDIR}/Config
##CB009169-ET-BD007
#${SCF_FILE_1}                 SCF_BD_PRB_Pooling_5GC002426_CB008847.xml
#${RD_PARAM_1}                 0x590072=1;0x1003F=1
#&{VENDOR_PARAMS_DICT_1}       maxNumPucchF3PCSIPerSlotL1Pool=2
#${LIST_NAME_1}                bbPoolCapacity
#${REF_VALUE_1}                ABIO\\d+TDDhalf_mode
#&{VENDOR_CHANGE_DICT_1}       params_dict=&{VENDOR_PARAMS_DICT_1}    list_name=${LIST_NAME_1}    ref_value=${REF_VALUE_1}
#@{VENDOR_CHANGE_LIST_1}       ${VENDOR_CHANGE_DICT_1}
#${WTS_CFG_1}                  CB009169_3F_3T_BD007.cfg
##CB009169-ET-BD012
#${RD_PARAM_2}                 0x580692=1
#${SCF_FILE_2}                 SCF_BD_PRB_Pooling_CB008847_CB001227.xml
#&{VENDOR_PARAMS_DICT_2}       maxNumScheUePuschL1Pool=15
#${LIST_NAME_2}                bbPoolCapacity
#${REF_VALUE_2}                ABIO\\d+FDDhalf_mode
#&{VENDOR_CHANGE_DICT_2}       params_dict=&{VENDOR_PARAMS_DICT_2}    list_name=${LIST_NAME_2}    ref_value=${REF_VALUE_2}
#@{VENDOR_CHANGE_LIST_2}       ${VENDOR_CHANGE_DICT_2}
#${WTS_CFG_2}                  CB009169_3F_3T_BD012.cfg
#@{COUNTER_ID_LIST_2}          ${COUNTER_1}    ${COUNTER_2}
#&{COUNTER_1}                  counter_id=M55308C18001    counter_path=CELLS/NRCELL-1/NCELA    min_value=0    max_value=3000000
#&{COUNTER_2}                  counter_id=M55308C18002    counter_path=CELLS/NRCELL-1/NCELA    min_value=0    max_value=9
#${A1THRESHOLD_2}              75
#@{2CC_UE_LIST}                1    2    3    4    5    6    7    8    9
#@{2CC_PCELL_ID_LIST}          52    52    52    52    52    52    52    52    52
#@{UE_LIST_1}                  11    12    13    14    15    16    17    18    19
#@{UE_LIST_2}                  21    22    23    24    25    26    27    28    29
#@{SCELL_PHYSICALID_LIST_2}    ${SCELL_PHYSICALID_1}    ${SCELL_PHYSICALID_2}    ${SCELL_PHYSICALID_3}
#...                           ${SCELL_PHYSICALID_4}    ${SCELL_PHYSICALID_5}    ${SCELL_PHYSICALID_6}    ${SCELL_PHYSICALID_7}
#...                           ${SCELL_PHYSICALID_8}    ${SCELL_PHYSICALID_9}
#@{SCELL_PHYSICALID_1}         50
#@{SCELL_PHYSICALID_2}         50
#@{SCELL_PHYSICALID_3}         50
#@{SCELL_PHYSICALID_4}         50
#@{SCELL_PHYSICALID_5}         50
#@{SCELL_PHYSICALID_6}         50
#@{SCELL_PHYSICALID_7}         50
#@{SCELL_PHYSICALID_8}         50
#@{SCELL_PHYSICALID_9}         50
#@{2CC_EXP_UL_TPUT_LIST}       1    1
##CB009169-ET-BD013
#${RD_PARAM_3}                 0x580612=0;0x58076E=0
#${SCF_FILE_3}                 SCF_BD_PRB_Pooling_5CB007113.xml
#&{VENDOR_PARAMS_DICT_3}       maxNumLayerPrbL1Sp=1092    maxNumStreamPrbL1Sp=500    maxNumWbStreamPrbL1Sp=1092
#${LIST_NAME_3}                bbL1SpPrbInitCapacity
#${REF_VALUE_3}                ABIO64ULNR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
#&{VENDOR_CHANGE_DICT_3}       params_dict=&{VENDOR_PARAMS_DICT_3}    list_name=${LIST_NAME_3}    ref_value=${REF_VALUE_3}
#@{VENDOR_CHANGE_LIST_3}       ${VENDOR_CHANGE_DICT_3}
#${WTS_CFG_3}                  CB009169_3F_3T_BD013.cfg
#@{EXP_UL_TPUT_LIST_3}         5    0
##CB009169-ET-BD014
#${RD_PARAM_4}                 0x580612=0;0x58076E=0
#${SCF_FILE_4}                 SCF_BD_PRB_Pooling_5GC001227_CB009158.xml
#&{VENDOR_PARAMS_DICT_4}       maxNumLayerPrbDlL1Sp=424    maxNumLayerPrbUlL1Sp=424    maxNumStreamPrbDlL1Sp=424
#...                           maxNumStreamPrbUlL1Sp=318
#${LIST_NAME_4}                bbL1SpPrbCapacity
#${REF_VALUE_4}                ABIO\\d+FDD64
#&{VENDOR_CHANGE_DICT_4}       params_dict=&{VENDOR_PARAMS_DICT_4}    list_name=${LIST_NAME_4}    ref_value=${REF_VALUE_4}
#@{VENDOR_CHANGE_LIST_4}       ${VENDOR_CHANGE_DICT_4}
#${WTS_CFG_4}                  CB009169_3F_3T_BD014.cfg
#
#*** Test Cases ***
#CB009169-ET-BD007_Multi_UEs_UL_CA_Call_with_Baseband_pooling_of_RRC_connected_user_with_L1_pCSI_limitation
#    [Tags]    Owner_y7li
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCF_FILE_1}    vendor_change_list=${VENDOR_CHANGE_LIST_1}
#    ...    swconfig_param=${RD_PARAM_1}    iphy_file=${IPHY_FILE_1}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_1}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_1}
#    Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    SA 5G CA Attach    1
#    SA 5G CA Attach    2
#    SA 5G CA Attach    3
#    SA 5G CA Attach    4
#    Trigger A1 Scell Addition    1    75    52
#    Trigger A1 Scell Addition    2    75    52
#    Trigger Scell Addition With CoverbaseA1 But Failed    3    75    52
#    Sleep    10s    reason=capture syslog
#    ${syslog}    Stop And Collect GNB Syslog    log_dir=${TEST_LOG_DIRECTORY}
#    ${nr_usr_limit_tag}    Grep File    ${syslog}    Csi number RAC in l1 pool failed for SCell: 16385
#    Should Not Be Empty    ${nr_usr_limit_tag}
#
#CB009169-ET-BD012_Multi_UEs_UL_CA_Call_with_baseband_pooling_of_scheduled_UE_per_slot
#    [Tags]    Owner_y7li
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCF_FILE_2}    vendor_change_list=${VENDOR_CHANGE_LIST_2}
#    ...    swconfig_param=${RD_PARAM_2}    iphy_file=${IPHY_FILE_2}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_2}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_2}
#    Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    SA Multi NonCA UE Attach    ${UE_LIST_1}
#    Multi UE GBR And VONR Establishment And ULDL Tput    11    17    1    2
#    SA Multi Continuous UE Start DL And UL Traffic    18    19    1    10
#    SA Multi NonCA UE Attach    ${UE_LIST_2}
#    Multi UE GBR And VONR Establishment And ULDL Tput    21    27    1    2
#    SA Multi Continuous UE Start DL And UL Traffic    28    29    1    10
#    SA Multi UE Attach With Scell A1 Addition    ${2CC_UE_LIST}    ${2CC_PCELL_ID_LIST}
#    ...    ${SCELL_PHYSICALID_LIST_2}    ${A1THRESHOLD_2}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    1    10
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    ${time}    Evaluate     300+${time}
#    Sleep    ${time}    reason=wait for counter
#    Check Multi PM COUNTERs Latest Value From Admin    ${COUNTER_ID_LIST_2}
#
#CB009169-ET-BD013_GBR_and_nonGBR_UL_CA_Call_with_baseband_pooling_of_PRBs_for_TDD
#    [Tags]    Owner_y7li
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCF_FILE_3}    vendor_change_list=${VENDOR_CHANGE_LIST_3}
#    ...    swconfig_param=${RD_PARAM_3}    iphy_file=${IPHY_FILE_3}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_3}
#    SA 5G CA Attach    1
#    Trigger A1 Scell Addition    1    75    52
#    SA Start DL Traffic Internal    1    1    30    1
#    SA Start UL Traffic Internal    1    1    90    1
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    1    ${EXP_UL_TPUT_LIST_3}    2
#	SA 5G CA Attach    2
#    UE GBR And VONR Establishment And ULDL Tput    2    10    60
#    SA UE Check Throughput    2    5    5    3
#    SA 5G CA Attach    7
#    UE GBR And VONR Establishment And ULDL Tput    7    10    60
#    SA UE Check Throughput    7    5    5    3
#    Capture Convert Format Ttitrace With Streaming Mode    3s
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD013.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#CB009169-ET-BD014_GBR_and_nonGBR_UL_CA_Call_with_baseband_pooling_of_UL_PRBs_for_FDD
#    [Tags]    Owner_y7li
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCF_FILE_4}    vendor_change_list=${VENDOR_CHANGE_LIST_4}
#    ...    swconfig_param=${RD_PARAM_4}    iphy_file=${IPHY_FILE_4}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_4}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_4}
#    Start GNB Syslog    ${TEST_LOG_DIRECTORY}
#    SA 5G CA Attach    1
#    Trigger A1 Scell Addition    1    75    52
#    SA Start DL Traffic Internal    1    1    30    1
#    SA Start UL Traffic Internal    1    1    90    1
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    1    30    2
#    SA 5G CA Attach    6
#    UE GBR And VONR Establishment And ULDL Tput    6    10    60
#    SA UE Check Throughput    6    5    5    3
#    Capture Convert Format Ttitrace With Streaming Mode    3s
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD014.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#*** Keywords ***
#Trigger Scell Addition With CoverbaseA1 But Failed
#    [Arguments]    ${ue_id}    ${rsrp}    ${pcell_id}
#    ${cmd}    Set Variable
#    ...    ue_measurement_send_nr id\=${ue_id} meas_id=1 event\=A1 srsrp_nr\=${rsrp} phycell_id\=${pcell_id}
#    ${output}    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}
#    ...    pass_regexp=rrcReconfigurationComplete    timeout=10s
#    Should Contain    ${output}    FAIL
#    Save Egate Log
#
#UE GBR And VONR Establishment And ULDL Tput
#    [Arguments]    ${UE_ID}    ${dl_trf}    ${ul_trf}
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${UE_ID} pdu\=1 qosflows_to_add\=2 by\=amf
#    Sleep    1s    reason=wait PDU session modify success
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${UE_ID} pdu\=1 qosflows_to_add\=3 by\=amf
#    Sleep    1s    reason=wait PDU session modify success
#    Log To Console    Start VONR DL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi=3 trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
#    Log To Console    Start VONR UL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu\=1 qfi=3 trf_id=1 mbps\=${ul_trf} dir=ul protocol=udp
#    Sleep    5s    reason=wait DL/UL traffic is stable
#
#Multi UE GBR And VONR Establishment And ULDL Tput
#    [Arguments]    ${start_ue_num}    ${end_ue_num}    ${dl_trf}    ${ul_trf}
#    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
#    UE GBR And VONR Establishment And ULDL Tput    ${UE_ID}    ${dl_trf}    ${ul_trf}
#    END
