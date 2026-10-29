# robocop: disable=not-allowed-char-in-name
*** Settings ***
Documentation
...  Author:        Maciej Cupial
...  Contact:       maciej.cupial@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Test cases defined as keywords


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008954/resources/keywords_CB008954.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008954/resources/keywords_CB008954.py   WITH NAME   kw8954

*** Variables ***
@{UE}           UE_1
${TPUT_TIME}    20sec
${THROUGHPUT}   1500Mbits/sec
${RMOD_CELL1}   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-4
${RMOD_CELL2}   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-5
@{RMOD4_CELL911}     ${17}    ${18}    ${19}    ${20}
@{RMOD5_CELL922}     ${21}    ${22}    ${23}    ${24}

# BWP_L = BWP3, BWP_M = BWP2, BWP_S = BWP1
${CB2_higher_than_zero}    M55166C00002,M55166C00004,M55308C28005,M55308C28006,M55308C29003,M55308C29004,M55308C28007,
...                        M55308C28008,M55308C28001,M55308C28002,M55308C29001,M55308C29002,M55308C28003,M55308C28004
${CB2_equals_zero}    M55166C00511,M55166C00512,M55308C00081,M55308C00082,M55308C00085,M55308C00086,M55308C00083,
...                   M55308C00084,M55166C00001,M55166C00003
${CB5_BWP_L}    M55139C02504,M55166C00512
${CB5_BWP_M}    M55139C02502,M55166C00004
${CB5_BWP_S}    M55139C02501,M55166C00003
${HANDOVER}     M55147C00001,M55145C00301,M55145C00302
${CB7}          M55166C00511,M55166C00512,M55308C00081,M55308C00082
${CB8_L}    M55166C00511,M55166C00512
${CB8_M}    M55166C00002,M55166C00004
${CB8_S}    M55166C00001,M55166C00003
${HO_NSA}   M55145C00111
${DB2_BWP_S}    M55115C02001,M55166C00001,M55110C00035,M55112C00020,M55112C00021,M55113C00011,M55113C00012
${DB2_BWP_S_zero}    M55110C00037
${H_IWK}  M55351C00001,M55351C00002,M55351C01001,M55351C01002



*** Keywords ***
[1]01A-B.1_Activation_of_3_BWPs_aligned_at_the_bottom_of_the_5G_TDD_cell_without_PRB_blanking with emergency call
    [Documentation]  The idea is to wait as long as user need to put EFS file onto a UE via PCAT interface.
    ...  If file is uploaded, then there is a confirmation in terminal provided by user by typing "ok"
    @{ALL_BWPS_TPUT_LIST}    Create List
    ${bwp}    Set Variable    L_100MHz  # -------------------------------- part: BWP_L (100MHz; BWP3)
    sleep    5s
    ${cplane_path}    Check And Add Average Tput To ALL_BWPS_TPUT_LIST    ${bwp}    ${ALL_BWPS_TPUT_LIST}
    Check Tput Dependencies    ${ALL_BWPS_TPUT_LIST}
    Check Throughput Statuses When Emergency Call
    Log  <h1>Test passed for ${bwp}</h1>     html=yes


[1]07C-B.5_Successful_Intra_Inter-frequency_Inter-gNB_handover_with_TDD_cells_by_RMOD_lock
    [Documentation]  This test case verifies Inter-frequency handover-inter gNB to 3rd dedicated BWP TDD cell.
    ...  Handover can be performed by RU reset or attenuator. The point is to check if data transfer is alive after HO
    ...  and if HO has been performed corectly:
    ...  M55147C00001 - A3 measurement and HO, M55145C00301 - attempt HO, M55145C00302 - success HO
    ...  Handover is performed from RMOD4 (cell_911) to RMOD5 (cell_922)
    @{BWPs}    Create List    L_100MHz
    ${AVG_TPUT}    Check Average Tput
    FOR    ${bwp}    IN    @{BWPs}
        sleep    5s
        Perform Many Attach Detach
        ${tput_cell}    Check Average Tput
        Attach UEs and start tput       ${UE}  udp  dl  300sec  res=off
        Sleep    5s
        Set attenuation and check       ${RMOD4_CELL911}     ${10}
        Check Data Transfer Is Alive    dt_name=DT_DL_UE_1
        sleep    5min
        run keyword and ignore error    Stop all datatransfers
        Log  <h1>Test passed for ${bwp}</h1>     html=yes
    END


[1]04C-B.2_Initial_Context_Setup_UE_configured_with_second_BWP_profile_with_counter_verification
    [Documentation]    This test case verifies BWP2 in 3 dedicated BWP configuration with TDD cell
    ...  Based on Test Plan there is only need to check Large Tput as pattern. Then perform tput for Medium and check
    ...  dependencies: Large Tput (L*0.8)+/-20% == Medium Tput. All dedicated counters for Medium (BWP2) should be
    ...  bigger than zero, and the rest counters should be equal zero.
    ${AVG_TPUT}    Check Average Tput
    ${bwp}    Set Variable    M_80MHz
    ${medium_tput}    Check Average Tput


[1]09C-B.6_RRC_connection_re-establishment_with_serving_cell_with_valid_UE_context_and_site_reset
    [Documentation]    Scenario describes the common gNB behaviour with regards to UE supporting only
    ...  small BWP re-establishes RRC Connection to the same cell the UE previously connected.
    ${AVG_TPUT}    Check Average Tput
    ${bwp}    Set Variable    S_50MHz
    ${medium_tput}    Check Average Tput
    FOR    ${i}    IN RANGE   ${2}
        Site Reset
        Verify if all cells are onair    interval=30sec
        Setup cplane tcpdump collector      name=cb6_${i}
        Start cplane logs
        Check Average Tput
        Stop cplane logs      log_dir=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/BWP_cplanes/
        ${cplane_path}  Set Variable  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/BWP_cplanes/cb6_${i}/cb6_${i}.pcap
    END


[1]10C-B.7_PRB_blanking_interaction_with_CB009915_and_VoNR
    [Documentation]    Scenario describes the common gNB behaviour with regards to UE context setup when UE supporting
    ...  large, dedicated BWP when PRB blanking is enabled
    ${bwp}    Set Variable    L_100MHz
    Log to console     bwp:${bwp}
    Perform commissioning 8954
    Attach UEs and start tput          ${UE}  udp  both  300sec  res=off
    Sleep    10s


[1]11C-B.8,10_Inter-DU_Xn_handover_by_blocking_cells_between_BWP1_of_20_MHz_and_BWP2_of_50_100_MHz_2-BWP cells_TDD_interaction with_CB006878
    [Documentation]  This test case verifies Inter-DU Xn handover by ANR between BWP1 of 50 MHz and BWP2 of 80 Mhz
    ...  and BWP3 of 100 MHz 2-BWP TDD cells_interaction with_CB006878.
    @{BWPs}    Create List    L_100MHz
    FOR    ${bwp}    IN    @{BWPs}
        Set attenuation and check       ${RMOD4_CELL911}     ${10}
        Sleep    5s
        Attach UEs and start tput          ${UE}  udp  both  480s  res=off
        Check Data Transfer Is Alive    dt_name=DT_DL_UE_1
        run keyword and ignore error    Stop all datatransfers
    END



[1]12D-B.2_Successful_EN-DC_with_small_BWP_and_interaction_with_Power_Saving_part_2_(CB010442&CB010443)
    [Documentation]  This user scenario describes the gNB behavior in a successful case when the UE supports
    ...  small dedicated BWP.
    ...  For TL 7_16_UTE5GCLOUDT151 Power Saving is already implemented. Just use specific params to activate
    ...  and deactivate Power Saving.
    Log to console      [1]12D-B.2_Successful_EN-DC_with_small_BWP_and_interaction_with_Power_Saving_part_2_(CB010442&CB010443)
    ${bwp}    Set Variable    S_50MHz
    Perform 10442/10443 Activation
    Attach UEs and start tput       ${UE}  udp  both  300sec
    Perform 10442/10443 Deactivation


[1]18E-B.4_NSA_CA_PSCell_with_1st_or_2nd_or_3rd_BWP.Scell_with_1st_or_2nd_or_3rd_BWP.Plus_PS_II_(TDD+TDD)
    [Documentation]  This user scenario describes the successful SCell addition for CarrierAggregation in case the UE is
    ...  supporting 1st (small) or 2nd or 3rd (large) dedicated BWP in PSCell. The user scenario applies to NSA mode.
    ...  User scenario will be performed using FDD-TDD CA and blind SCell  addition with error case covered.
    ...  This user scenario also tests if the DL and UL resource utilization and peak throughput are maximized for
    ...  the selected BWP. The gNB can assign DL and UL resources in the entire configured largest dedicated BWP,
    ...  if the UE supports.
    Log to console  [1]18E-B.4_NSA_CA_PSCell_with_1st_or_2nd_or_3rd_BWP.Scell_with_1st_or_2nd_or_3rd_BWP.Plus_PS_II_(TDD+TDD)]

[1]20H-IWK.1_Power_Saving_BWP_not_configured_along_small_BWP
    [Documentation]  This user scenario describes the interaction with 5GC000937, when selected dedicated BWP is smaller
    ...  or equal power saving BWP then power saving BWP should not be configured.
    @{BWPs}    Create List    L_100MHz    M_80MHz    S_50MHz
    FOR    ${bwp}    IN    @{BWPs}
        log    ${bwp}    level=TRACE
        Perform Many Attach Detach
        Attach UEs to cell     ${UE}
        Start ULDL for UEs  ${UE}     duration=180s    dl_throughput=5Mbits/sec    ul_throughput=5Mbits/sec
        sleep    180s
        run keyword and ignore error    Stop all datatransfers
        detach ues from cell    ${UE}
    END
