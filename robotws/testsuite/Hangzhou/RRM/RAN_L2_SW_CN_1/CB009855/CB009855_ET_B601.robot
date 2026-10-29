*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    master_classicalbts_all    STATE_CONFIGURED
#...               CRT    RAN_5G    FR1    SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./Resources/CB009855_resource.robot
#
#*** Variables ***
#### Suite level ###
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF_CB009855_ET_B601}    Full_SCF_CB009855_ET_B601.xml
#${WTS_CFG}                      basic_B600.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${3T3F_IPHY}                    ${CURDIR}/Resources/wts/iphy_B600_3T_3F.xml
#@{UE_LIST_001}                  1    2
#@{5CC_SCELL_PCI_1}              50    51    52    53
#@{5CC_SCELL_PCI_2}              50    51    53    54
#${DL_DATA_001}                  1800
#${UL_DATA_001}                  100
#${5CC_NUM}                      5
#${BIP_CSV_NAME}                 5GBipL2L1_filtering_off.csv
#${FILTER}                       uldata_pucchreceiverespps || uldata_puschreceiverespharqd || uldata_puschreceiverespps
#@{COLUMN_NAME}                  3gpp.sfn    3gpp.slot    uci.pusch.part1bits    data.data    3gpp.rnti
#@{2CC_EXP_UL_TPUT_LIST_001}     10    2
#@{5CC_EXP_DL_TPUT_LIST_001}     50    2    10    10    2
#${PREFERENCE}                   preferences_A009_A013
#@{LOG_NAME_LIST}                snapshot    btsLog    sosreport
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009855-ET-B601_Verify_5CC_DL_CA_With_different_frame_structures_as_1_semistatic_7vs3_and_2_tdLte
#    [Tags]    Owner_y7li
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_ET_B601}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Start Gnb BIP Log
#    SA 5G CA Attach    ue_id=1
#    SA 5G CA Attach    ue_id=2
#    Check SA All Scell PhysicalID With UE ID    1    ${5CC_SCELL_PCI_1}    ${5CC_NUM}
#    Check SA All Scell PhysicalID With UE ID    2    ${5CC_SCELL_PCI_2}    ${5CC_NUM}
#    SA Multi UE Start DL And UL Traffic    ${UE_LIST_001}    ${DL_DATA_001}    ${UL_DATA_001}
#    Override All UE RI For TDD Pcell 4Layer    ${UE_LIST_001}
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Wait Until Keyword Succeeds    30s    5sec    Check Multi UE DLCA Cell L1 Tput    ${UE_LIST_001}    ${5CC_EXP_DL_TPUT_LIST_001}    ${5CC_NUM}
#    Wait Until Keyword Succeeds    30s    5sec    Check Multi UE ULCA Cell L1 Tput    ${UE_LIST_001}    ${2CC_EXP_UL_TPUT_LIST_001}    ${5CC_NUM}
#    SA Multi UE Stop DL Traffic    ${UE_LIST_001}
#    SA Multi UE Stop UL Traffic    ${UE_LIST_001}
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    A2A Check CSI Bundling Bits And Harq Bits On PUSCH
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#A2A Check CSI Bundling Bits And Harq Bits On PUSCH
#    ${UE1_CRNTI}=    Get Crnti From Egate Log    1
#    Set Suite Variable    ${UE1_CRNTI}
#    ${UE2_CRNTI}=    Get Crnti From Egate Log    2
#    Set Suite Variable    ${UE2_CRNTI}
#    Check Log With Au2anlysis    ${CURDIR}/A2A/CB009855_B/B601_a2a.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
