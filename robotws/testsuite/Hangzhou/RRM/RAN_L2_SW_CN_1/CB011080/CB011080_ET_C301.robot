*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF_CB011080_UlSlotMuting}    iphy_file=${CB011080_UTEcloud_IPHY}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_lua}
#...               AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_lua}
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_zhacao
#
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Suite level ###
#${SCF_PATH}                          ${CURDIR}/Config/SBTS24R3/SCF
#${FULL_SCF_CB011080_UlSlotMuting}    Full_SCF_CB011080_slotMuting_TC1_UTEcloud_modified.xml
#${WTS_lua}                           basic_CB011080_IWK_UlSlotMuting.lua
#${LOCAL_WTS_DIR}                     ${CURDIR}/Config/wts/
#${CB011080_UTEcloud_IPHY}            ${CURDIR}/Config/wts/iphy_CB011080_UTEcloud.xml
#@{LOG_NAME_LIST}                     snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}         snapshot
#
#@{L2STREAM_COMPONENT_CONFIG}         &{TTITRACE_CONFIG_L2PS}
#
#${PhysicalCellId}                    55
#
#&{TTITRACE_CONFIG_L2PS}              up_sw=L2Ps    trace_type=Component    nr_phy_cell_ids=55
#
#${UE2}                               2
#@{Pcell_UE_LIST}                     2
#@{SCELL_PHYSICALID_LIST}             50    51    52    53    56
#${6CC_DL_TRF}                        2500
#${6CC_UL_TRF}                        170
#${2CC_DL_TRF}                        600
#${2CC_UL_TRF}                        170
#@{6CC_EXP_DL_TPUT_LIST}              400    500    100    200    300    400
#@{6CC_EXP_UL_TPUT_LIST}              10    100
#
#${6CC_NUM}                           6
#
#${scell_index0}                      0
#${scell_index1}                      1
#${scell_index2}                      2
#${scell_index3}                      3
#${scell_index4}                      4
#${scell_index5}                      5
#
#
#${pdu_id}                            1
#${srsrp_nr}                          110
#*** Test Cases ***
#CB011080_ET_C301_Verify_6CC_Pcell_Tdlte_Framestructure_IWK_With_UL_Slot_Muting
#    [Tags]    Owner_zhacao
#    [Setup]    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    UE Attach and 6CC DLUL Tput Check
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-6    actInfTddFrameMuting    true
#    Sleep    80s    reason=waiting for Cell6 onair
#    UE Attach and TDD 2CC Tput Check
#    Capture Ttitrace And Check
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#UE Attach and 6CC DLUL Tput Check
#    SA 5G CA Attach    ${UE2}    ${pdu_id}
#    Send A1 report    ${UE2}    ${srsrp_nr}    ${PhysicalCellId}
#    SA Multi UE Start DL And UL Traffic    ${Pcell_UE_LIST}    ${6CC_DL_TRF}    ${6CC_UL_TRF}
#    Sleep    15s    reason=stable Tput
#	${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id\=${UE2} type\=pdsch,pusch scell\=0-5    pass_regexp=CellIndex
#    Wait Until Keyword Succeeds    5min    30sec    Check Multi UE DLCA And 2CCULCA L1 Cell tput     ${Pcell_UE_LIST}
#    ...    ${6CC_EXP_UL_TPUT_LIST}    ${6CC_EXP_DL_TPUT_LIST}   ${6CC_NUM}
#
#UE Attach and TDD 2CC Tput Check
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    SA 5G CA Attach    ${UE2}    ${pdu_id}
#    Send A1 report    ${UE2}    ${srsrp_nr}    ${PhysicalCellId}
#    SA Multi UE Start DL And UL Traffic    ${Pcell_UE_LIST}    ${2CC_DL_TRF}    ${2CC_UL_TRF}
#    Sleep    15s    reason=stable Tput
#	${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id\=${UE2} type\=pdsch,pusch scell\=0-5    pass_regexp=CellIndex
#    Run Keyword And Continue On Failure      Check T_T 2CC Config
#    Run Keyword And Continue On Failure      Check CA UE Pcell Scell Cell TPut On Target     ${UE2}    dl    pdsch    ${scell_index0}    150
#    Run Keyword And Continue On Failure      Check CA UE Pcell Scell Cell TPut On Target     ${UE2}    dl    pdsch    ${scell_index1}    300
#
#Capture Ttitrace And Check
#    Capture Convert Format Ttitrace With Streaming Mode    2s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming2/
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB011080_Tti_NackRatio.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB0011080_Tti_ULMut.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming2
#
#Check T_T 2CC Config
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB011080_IWK_UlSlotMuting.ini
#    ...    p    save_log_directory=${TEST_LOG_DIRECTORY}/
