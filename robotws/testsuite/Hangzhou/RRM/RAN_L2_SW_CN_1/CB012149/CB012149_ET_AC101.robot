*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_jshen
#...               SBTS00    CB012149    RAN_5G    RAN_5G_TDD    CRT
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB012149_Ac101_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_Ac101.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB012149_Ac101.cfg
#${2CC_DL_DATA}                  520
#${2CC_UL_DATA}                  175
#@{2CC_EXP_DL_TPUT_LIST}         50    50
#@{2CC_EXP_UL_TPUT_LIST}         10    10
#@{2CC_UE_LIST}                  81
#@{2CC_SCELL_PHYSICALID_1}       52
#@{2CC_SCELL_PHYSICALID_LIST}    ${2CC_SCELL_PHYSICALID_1}
#@{2CC_PCELL_ID_LIST}            51
#${A1THRESHOLD}                  110
#${ENBID}                        2
#${GNBID}                        1
#${CELL3_ID}                     3
#${ANTP_NUM}                     2
#${MBSFN_SUBFRAME}               110000110000110000110000
#${NORMAL_SUBFRAME}              0011101010-0111100110-0011101010-0111100110-0011101010-0111100110-0011101010-0111100110
#${UL_PRB_LST1}                  0,5|5,45|50,70
#${UL_PRB_LST2}                  0,5|5,25|30,50
#${UL_PRB_LST3}                  0,5|5,10|15,20
#${UL_PRB_LST4}                  0,5|5,5|15,5
#@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2PS}
#
#
#*** Test Cases ***
#CB012149_ET_AC101_UL_Tx_Switching_With_Enable_DSS_In_FDD_Cell_And_Active_ActLteNrDssFastAlloc_With_TimingAdvanceOffset_N39936
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure 4CELL DSS    30    100    20    70
#    Sleep    10s    reason=wair for egate is stable
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Capture Convert Format Ttitrace With Streaming Mode    2s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB012149_Ac${/}CB012149_Ac01_ul.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#    SA 5G Detach    ${2CC_UE_LIST[0]}
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Configure 4CELL DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
#	Setup XP LINK    ${ENBID}    ${GNBID}
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL3_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL3_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#	Cell Allocation    ${NORMAL_SUBFRAME}    ${UL_PRB_LST1}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    Cell Allocation Of Ac101    ${MBSFN_SUBFRAME}    ${NORMAL_SUBFRAME}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#	UE SIB Decoding Should Be Successful
#
#Cell Allocation Of Ac101
#    [Arguments]    ${mbsfn_subframe}    ${nor_subframe}    ${enb_id}=2    ${gnb_id}=1    ${cell_id}=1
#    [Documentation]    This keyword is used to allocate cell resource.
#    ...    | Input Parameters | Man. | Description |
#    ...    | nor_subframe | Yes | The dl allocated normal subframes |
#    ...    | prb_list | Yes | It shows the info of startprb and amount of prbs. e.g. 1,30 1:startprb    30:amount of prbs.|
#    ...    Example:
#    ...    | Cell Allocation | 0010000000-0000001000-0000000000-0000000000-0000000000-0000001000-0000000000-0000000000 | 1,30 |
#    ${command}    Catenate    SEPARATOR=${SPACE}    enb_crm_periodic_allocation_pattern enb=${enb_id} cell=${cell_id} tgt_enb=${gnb_id}
#    ...    tgt_cell=${cell_id} allocation_start_time=20:50 allocated_mbsfn_subframes=${mbsfn_subframe} dir=DL
#    ...    dl_allocated_normal_subframes=${nor_subframe} dl_allocation_priority=10 dl_prb_area_allocation_list=1:1,3|5,3+2:20,2
#    ute_wtssim.Execute Egate Command    ${command}
#    ${command}    Catenate    SEPARATOR=${SPACE}    enb_crm_periodic_resource_allocation enb=${enb_id} cell=${cell_id} tgt_enb=${gnb_id}
#    ...    tgt_cell=${cell_id} dir=DL periodicity=500 periodicity_and_load_indication=true loopback=on periodicity_messages_logged=500
#    ute_wtssim.Execute Egate Command    ${command}
#    ${command}    Catenate    SEPARATOR=${SPACE}    enb_crm_periodic_allocation_pattern enb=${enb_id} cell=${cell_id} tgt_enb=${gnb_id}
#    ...    tgt_cell=${cell_id} dir=UL allocation_start_time=auto ul_allocated_prb_list=0,5|5,35|50,100 delay_if_auto=30
#    ute_wtssim.Execute Egate Command    ${command}
#    ${command}    Catenate    SEPARATOR=${SPACE}    enb_crm_periodic_allocation_pattern enb=${enb_id} cell=${cell_id} tgt_enb=${gnb_id}
#    ...    tgt_cell=${cell_id} dir=UL allocation_start_time=auto ul_allocated_prb_list=0,5|5,60|90,100 delay_if_auto=30
#    ute_wtssim.Execute Egate Command    ${command}
#    ${command}    Catenate    SEPARATOR=${SPACE}    enb_crm_periodic_resource_allocation enb=${enb_id} cell=${cell_id} tgt_enb=${gnb_id}
#    ...    tgt_cell=${cell_id} dir=UL periodicity=500 periodicity_and_load_indication=true loopback=on periodicity_messages_logged=500
#    ute_wtssim.Execute Egate Command    ${command}
#    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=${enb_id} cell=${cell_id}    pass_regexp=Configured DSS partnership
