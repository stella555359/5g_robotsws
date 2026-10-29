*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   Description:   Feature CB012439

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_8409.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012439/resources/test_specyfic_keywords_CB012439.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources/test_specific_keywords_9059.robot
Library        taf.ue
Library        taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012439/resources/test_specific_keywords_CB012439.py


Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py


*** Variables ***
${UE_ALIAS_12439}             UE_12439
${UE_CAPA_12439}              REAL_UE_SA
@{cells_to_be_locked_12439}=        1    2   5    6    7    8    9
${CellFilter}           1
@{counter_ids_CB012439}     M55190C00001     M55190C00002     M55187C00001    M55187C00002    M55188C00001
                    ...     M55147C00024     M55145C00322
@{counter_ids_CB012439_B_C}      M55190C00001     M55190C00002     M55187C00001    M55187C00002     M55188C00001
                    ...          M55187C00003     M55187C00004     M55187C00003    M55188C00002     M55157C00033
${starting_attenuation_2ndCell}     90
${cell1_ID_RU}     0
${cell2_ID_RU}     4
${1st_log}              cell_3_counters
${2nd_log}              cell_4_counters
${auto_responder}       +555800903300998
${VC_ALIAS}              callVoNR
${handover_off}         0
${tput}           200 Mbits/sec

${path}         /home/ute/logs_3/counters/cell_3_counters



*** Keywords ***
[1]CB012439_handover_with_5QI9_5QI1_test
	[Documentation]   This test case is for CB012439 feature with VoNR and Data traffic
	AdminUtils.unlock_all_cells
    preparing_for_handover_CB012439
    AdminUtils.Lock Cells     ${cells_to_be_locked_12439}
    Handover_attenuation_preparing_CB012439
    Setup cplane tcpdump collector
    Start cplane Logs
    Wait for next counter interval 8409
    Attach Ue            ${UE_ALIAS_12439}
    Data Transfer procedure     ${UE_ALIAS_12439}
    taf.ue.Start voice call     vc_alias=${VC_ALIAS}   ue_alias=${UE_ALIAS_12439}    to=${auto_responder}   duration=1000s
    Check data transfer procedure
    handover_attenuation_loop_CB012439        ${cell1_ID_RU}  ${cell2_ID_RU}
    Check data transfer procedure
    taf.ue.Stop Voice Call    ${VC_ALIAS}
    Stop cplane logs
    Wait for next counter interval 8409
    Detach Ue                  ${UE_ALIAS_12439}
    Verify counters with complicated name     ${counter_ids_CB012439}     ${1st_log}


[1]CB012439_VoNR_CA_checking_counters
	[Documentation]   This test case is for CB012439 feature with VoNR and CA
	AdminUtils.unlock_all_cells
    preparing_for_handover_CB012439     ${handover_off}
    AdminUtils.Lock Cells     ${cells_to_be_locked_12439}
    Handover_attenuation_preparing_CB012439     ${handover_off}
    Setup cplane tcpdump collector
    Start cplane Logs
    Wait for next counter interval 8409
    Attach Ue            ${UE_ALIAS_12439}
    taf.ue.Start voice call     vc_alias=${VC_ALIAS}   ue_alias=${UE_ALIAS_12439}    to=${auto_responder}   duration=1000s
    Data Transfer procedure 12439     ${UE_ALIAS_12439}     ${tput}
    Check data transfer procedure
    BuiltIn.Sleep   60s
    taf.ue.Stop Voice Call    ${VC_ALIAS}
    Stop cplane logs
    Wait for next counter interval 8409
    Detach Ue                  ${UE_ALIAS_12439}
    Verify counters with complicated name part C    ${counter_ids_CB012439_B_C}     ${2nd_log}
