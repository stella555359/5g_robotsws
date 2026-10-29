*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_LOO    Owner_rewu
#...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB009169_Ac202_blind_scfc.xml
#${DELTA_SCF_AC202}                Delta_CB009169_Ac202.json
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_Ac101.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB009169_Ac101.cfg
#${2CC_DL_DATA}                  520
#${2CC_UL_DATA}                  175
#${NONCA_DL_DATA}                100
#@{2CC_EXP_DL_TPUT_LIST}         50    50
#@{2CC_EXP_UL_TPUT_LIST}         10    10
#@{2CC_UE_LIST}                  81
#${NONCA_UE_ID}                  83
#@{2CC_SCELL_PHYSICALID_1}       52
#@{2CC_SCELL_PHYSICALID_LIST}    ${2CC_SCELL_PHYSICALID_1}
#@{2CC_PCELL_ID_LIST}            51
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
#*** Test Cases ***
#CB009169_ET_AC202_Handling_of_timingAdvanceOffset_n25600_per_L1_pool_when_FR1_TDD_FDD_UL_CA_with_DSS_as_Scell_is_co_existing_with_non_CA_DSS_cells
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure 4CELL DSS    30    100    20    70
#    Sleep    10s    reason=wair for egate is stable
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Sleep    30s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
#    SA Single UE Attach    ${NONCA_UE_ID}
#    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${NONCA_DL_DATA}
#    SA Start UL Traffic Internal    ${NONCA_UE_ID}    1    ${2CC_UL_DATA}
#    Sleep    30s
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_Ac${/}CB009169_Ac01_ul.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#    SA 5G Detach    ${2CC_UE_LIST[0]}
#    [Teardown]    Common Test Teardown
#
#CB009169_ET_AC201_Handling_of_timingAdvanceOffset_n39936_per_L1_pool_when_FR1_TDD_FDD_UL_CA_with_DSS_as_Scell_is_co_existing_with_non_CA_DSS_cells
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_AC202}
#	...    AND    Reboot TL And Check Configured
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure 4CELL DSS    30    100    20    70
#    Sleep    10s    reason=wair for egate is stable
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Sleep    30s    reason=wair for data is stable
#    Check Multi UE DLCA Cell L1 tput    ${2CC_UE_LIST}        ${2CC_EXP_DL_TPUT_LIST}    2
#    SA Single UE Attach    ${NONCA_UE_ID}
#    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${NONCA_DL_DATA}
#    SA Start UL Traffic Internal    ${NONCA_UE_ID}    1    ${2CC_UL_DATA}
#    Sleep    30s
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_Ac${/}CB009169_Ac202_ul.ini
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
#    ...    tgt_cell=${cell_id} dir=UL allocation_start_time=auto ul_allocated_prb_list=0,5|5,75|90,100 delay_if_auto=30
#    ute_wtssim.Execute Egate Command    ${command}
#    ${command}    Catenate    SEPARATOR=${SPACE}    enb_crm_periodic_resource_allocation enb=${enb_id} cell=${cell_id} tgt_enb=${gnb_id}
#    ...    tgt_cell=${cell_id} dir=UL periodicity=500 periodicity_and_load_indication=true loopback=on periodicity_messages_logged=500
#    ute_wtssim.Execute Egate Command    ${command}
#    ute_wtssim.Execute Egate Command    cmd=enb_crm_status enb=${enb_id} cell=${cell_id}    pass_regexp=Configured DSS partnership
