*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    VDU Online Change Parameters    ${MO_DN_LIST}    ${UPDATED_PARAS_DICT_LIST}
#...               AND    Copy WTS Config Files From Local    ${CONFIG_FILE_PATH}
#...               AND    Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD
#...                FR1    Owner_LiLiang     master_vDU     SBTS00
#
#Resource          ./../CUDU_L2_AIC/common_aic_setup_teardown.robot
#
#*** Variables ***
#${CONFIG_FILE_PATH}         ${CURDIR}/config
#${6086_VCU_SCFC_PATH}       vcu_scfc_6086.xml
#${6086_VDU_SCFC_PATH}       vdu_scfc_6086.xml
##${LOCAL_WTS_DIR}            ${CURDIR}/config
#${GNB_INDEX}                0
#${IPHY_PATH}                ${CURDIR}/config/iphy.xml
#${WTS_CFG}                  6086_basic_setup_hz.cfg
#${ENB_ID}                   1
#${UE_ID}                    1
#${PROFILE_ID}               1
#${PROFILE_ID1}              2
#${PROFILE_ID2}              20
#${SNIR_TARGET_SRS1}         300
#${SNIR_TARGET_SRS2}         -280
#${SNIR_TARGET_PUSCH1}       300
#${SNIR_TARGET_PUSCH2}       -280
#${SNIR_TARGET_PUCCH1}       100
#${SNIR_TARGET_PUCCH2}       100
#${SNIR_TARGET_PREMBLE1}     100
#${SNIR_TARGET_PREMBLE2}     100
#${GNB_ID}                   2
#${CELL_ID}                  1
#${PDU_ID}                   1
#${TRF_ID}                   1
#${DELTA_XML_FILE}           ${CURDIR}/Config/Delta.xml
#@{LOG_NAME_LIST}            btslog    snapshot    tcpdump    #tshark | sherpa | #pmcounter
#${CONST_FILE}               ${CURDIR}/Config/const_customizer.conf
#${UE_NR_CAP_TDD}            E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965954C043D6C10101070EF1C39061C001032
#...                         78FAB80027800E0009E00151B133582028680965954C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13758202868096
#...                         5954C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965954C043D6C10101070EF1C39061C00103278FA
#...                         A8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C001A0F8000000000000395340004000025965400D2AA
#...                         A0207000B000000040080118B130001020304050607080B101112131921252627284A0
#${EXPECTED_TPUT}            1
#${TCPDUMP_NAME}             testVM_Tcpdump
#${1_PORT_LAYER}             nr-rrc.nrofSRS_Ports == 0 && nr-rrc.maxMIMO_Layers == 1
#${2_PORT_LAYER}             nr-rrc.nrofSRS_Ports == 1 && nr-rrc.maxMIMO_Layers == 2
#@{1_2_PORT_LAYER_FILTER}    ${1_PORT_LAYER}    ${2_PORT_LAYER}
#${EGATE_PATH}               /opt/iphy/latest/egate_console.log
#@{PORTS_LIST}               port1    port1    ports2
#
#${MO_DN_1}                      MRBTS-1/NRBTS-1
#&{UPDATED_PARAS_DICT_1}         actCoverageNonCoherentUes=true
#${MO_DN_2}                      MRBTS-1/NRBTS-1/NRCELL-1
#&{UPDATED_PARAS_DICT_2}         ulPowerControlCommon/1/actUlOpenLoopPwrCtrl=false
#...    ulPowerControlCommon/1/p0NominalPucch=-80    ulPowerControlCommon/1/p0NominalPusch=-74
#@{MO_DN_LIST}    ${MO_DN_1}    ${MO_DN_2}
#@{UPDATED_PARAS_DICT_LIST}    ${UPDATED_PARAS_DICT_1}    ${UPDATED_PARAS_DICT_2}
#
#*** Test Cases ***
#CB006086_ET_006_Transition_From_Single_Tx_To_Rank2_Then_To_Single_Tx_Transmission_On_PUSCH_With_TDD_SA
#    ${UE_NR_CAP_TDD}    String.Replace String    ${UE_NR_CAP_TDD}    ${SPACE}    ${EMPTY}
#    NSA NR UE Param Set    ${UE_ID}    ${UE_NR_CAP_TDD}
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    50    ${TRF_ID}
#    SA UE Testmode NR Profile    ${PROFILE_ID1}    ${SNIR_TARGET_SRS1}    ${SNIR_TARGET_PUSCH1}    ${SNIR_TARGET_PUCCH1}    ${SNIR_TARGET_PREMBLE1}
#    SA UE Testmode NR Profile    ${PROFILE_ID2}    ${SNIR_TARGET_SRS2}    ${SNIR_TARGET_PUSCH2}    ${SNIR_TARGET_PUCCH2}    ${SNIR_TARGET_PREMBLE2}
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID1}
#    Sleep    60s    reason=Wait For UL Transmission
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    Sleep    60s    reason=Wait For UL Transmission
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID1}
#    Sleep    60s    reason=Wait For UL Transmission
#    SA UE Testmode NR Set    ${UE_ID}    ${PROFILE_ID2}
#    Sleep    60s    reason=Wait For UL Transmission
#    Check Egate Console Log    ${PORTS_LIST}
#
#*** Keywords ***
#NSA NR UE Param Set
#    [Arguments]    ${ue_id}    ${ue_nr_cap}
#    [Documentation]    This keyword is used to set UE NR capability before NSA L3 Call on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | ue_nr_cap | Yes | ue_nr_cap |
#    ...    Example:
#    ...    | NSA NR UE Param Set | 1 | 01000000010800040004D100018000000BC00000000000008A8000100000000010010AAC |
#    Log To Console    set UE NR capability...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_param id\=${ue_id} ue_nr_capabilities\=${ue_nr_cap}
#    Log To Console    set_UE_NR_capability_is_ok
#    Sleep    3s    reason=wait ue set nr capability is stable
#
#SA UE Testmode NR Profile
#    [Arguments]    ${ul_sinr_profile_index}    ${sinr_target_srs}    ${sinr_target_pusch}    ${sinr_target_pucch}    ${sinr_target_preamble}
#    [Documentation]    This keyword is used to set UE Testmode after NSA L3 Call on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
#    ...    | sinr_target_srs | Yes | sinr_target_srs |
#    ...    | sinr_target_pusch | Yes | sinr_target_pusch |
#    ...    | sinr_target_pucch | Yes | sinr_target_pucch |
#    ...    | sinr_target_preamble | Yes | sinr_target_preamble |
#    ...    Example:
#    ...    | SA UE Testmode NR Profile | 1 | 100 | 100 | 100 | 100 |
#    Log To Console    add UE testmode NR profile...
#    ${cmd}    Catenate    ul_sinr_testmode_nr profile_id=${ul_sinr_profile_index} sinr_target_srs=${sinr_target_srs}
#    ...    sinr_target_pusch=${sinr_target_pusch} sinr_target_pucch=${sinr_target_pucch} sinr_target_preamble=${sinr_target_preamble}
#    ${output}    ute_wtssim.Execute Egate Command    cmd=${cmd}
#    Should Not Contain    ${output}    UE may be OFF or killed
#    Log To Console    set_UE_Testmode_is_ok
#
#SA UE Testmode NR Set
#    [Arguments]    ${ue_id}    ${ul_sinr_profile_index}
#    [Documentation]    This keyword is used to set UE Testmode NR after NSA L3 Call on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | ul_sinr_profile_index | Yes | ulsinr profile index |
#    ...    Example:
#    ...    | SA UE Testmode Set | 1 | 1 |
#    Log To Console    set UE Testmode NR...
#    ${output}    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=${ul_sinr_profile_index}
#    Should Not Contain    ${output}    UE may be OFF or killed
#    Log To Console    set_UE_Testmode_is_ok
#
#Check Egate Console Log
#    [Arguments]    ${posts_list}
#    Save Egate Log    ${test_log_directory}
#    ${content}    OperatingSystem.Get File    ${test_log_directory}/egate_console.log
#    ${patt}    Set Variable    nrofSRS-Ports\\s+(?P<port>\\w+),
#    ${matches}    String.Get Regexp Matches    ${content}    ${patt}    port
#    Collections.Lists Should Be Equal    ${matches}    ${ports_list}
#
#Save Egate Log
#    [Arguments]    ${log_path}=${suite_log_directory}
#    [Documentation]    This keyword is to copy egate console log from /opt/iphy/latest/egate_console.log to ${log_path}
#    ...    after execute 'sim_log_set flush'
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    OperatingSystem.Copy Files    /opt/iphy/latest/egate_console.log*    ${log_path}
#
