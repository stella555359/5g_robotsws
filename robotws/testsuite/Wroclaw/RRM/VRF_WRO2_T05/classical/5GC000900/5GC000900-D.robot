*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

# Library         taf.ue
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot

*** Variables ***
${subfeature_name900D}           5GC000900-D
${resource_path_900}         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/
${tput_DL_bandwith_900D}     10 Mbits/sec
${tput_UL_bandwith_900D}     2 MBits/sec
${tput_deviation}       20%
${tput_duration_900D}        150s
${Packet_Size}          1200
@{lines_gNB_157_AHCA_1}        1   2   3   4
@{lines_gNB_157_AHCA_2}        5   6   7   8
@{lines_gNB_157_AHCA_3}        9   10   11   12
@{lines_LTE_157}               21    22
@{lines_gNB_159_AHCA_1}        13   14   15   16
@{lines_gNB_159_AHCA_2}        17   18
@{lines_gNB_159_AHCA_3}        19   20
@{lines_LTE_159}               23    24

*** Keywords ***
[1]5GC000900-D_43_Measurement_configuration_for_NSA_and_SA_users_in_NSA+SA_cell
    [Documentation]  The purpose of this test is to verify that gNB operating in mixed mode can successfully use the
    ...              configured measurement related parameters to build the measurement configuration in the RRC Reconfiguration message.
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=0
    Log to console  attenuate Set
    sleep  5s
    Connect to Coam
    Connect To LTE
    Start Tshark
    Attach UE NSA For test
    Attach UE SA For test
    Stop Tshark and download logs
    Check measurements in NSA SA cell   cell_id_before_ho=53

[1]5GC000900-D_44_Measurement_configuration_for_NSA_user_when_SA_neighbours_are_blacklisted
    [Documentation]  The purpose of this test is to verify that gNB can handle measurement report configuration
    ...              for NSA UE when there's a scope for blacklisting and measurement report processing for NSA UE.
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=0
    Log to console  attenuate Set
    sleep  5s
    Connect to Coam
    Connect To LTE
    Start Tshark
    Attach UE NSA For test
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_2}   value=0
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=50
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    sleep  60s
    Stop Tshark and download logs
    Check measurements   cell_measurement=151  cell_id_before_ho=53

[1]5GC000900-D_45_Measurement_configuration_for_SA_user_when_NSA_neighbours_are_blacklisted
    [Documentation]  The purpose of this test is to verify that gNB can handle measurement report configuration
    ...              for SA UE when there's a scope for blacklisting and measurement report processing for SA UE.
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=0
    Log to console  attenuate Set
    sleep  5s
    Connect to Coam
    Connect To LTE
    Start Tshark
    Attach UE SA For test
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=0
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=50
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    sleep  60s
    Stop Tshark and download logs
    Check measurements   cell_measurement=150  cell_id_before_ho=53

[1]5GC000900-D_46_Successful_intra-frequency_intra-gNB_handover_from_NSA_cell_to_NSA-SA_cell_and_back
    [Documentation]  The purpose of this test is to verify that gNB can handle intra-frequency intra-gNB
    ...              handover between NSA only and NSA+SA cells.
    Connect to Coam
    Connect To LTE
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=0
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=90
    Start Tshark
    Attach UE NSA For test
    Start ULDL UDP NSA     ${tput_DL_bandwith_900D}   ${tput_UL_bandwith_900D}   ${tput_duration_900D}
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    sleep  2s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=20
    sleep  10s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=90
    sleep  2s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=0
    sleep  60s
    Stop Tshark and download logs
    Check_handover_intra_freq_inter_gnb   cell_id_before_ho=50  cell_id_after_ho=51
    Verify ULDL UDP NSA   ${tput_DL_bandwith_900D}   ${tput_UL_bandwith_900D}

[1]5GC000900-D_47_Successful_intra-frequency_inter-gNB_handover_from_NSA_cell_to_NSA-SA_cell_and_back
    [Documentation]  The purpose of this test is to verify that gNB can handle intra-frequency inter-gNB
    ...              handover between NSA only and NSA+SA cells.
    Connect To LTE
    Wait until keyword succeeds    5 min    30s      X2-C is available
    Run Keyword And Ignore Error  Check adb devices
    Adjust proper scf to current stream    ${resource_path_900}    ${subfeature_name900D}
    Wait until keyword succeeds    20 min    30s    Verify all cells are onair with admin
    Wait until keyword succeeds     5 min    30s    Start Tshark
    Attach UE NSA For test
    Start ULDL UDP NSA   ${tput_DL_bandwith_900D}   ${tput_UL_bandwith_900D}   ${tput_duration_900D}
    sleep  5s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=40
    sleep  1s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=30
    sleep  1s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=0
    sleep  1s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=5
    Sleep  1s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=7
    sleep  1s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=10
    sleep  1s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=15
    sleep  60s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=10
    Sleep  1s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=8
    sleep  1s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=5
    sleep  1s
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=0
    sleep  10s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=5
    Sleep  1s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=10
    Sleep  1s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=12
    Sleep  1s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=14
    Sleep  1s
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=20
    sleep  15s
    Stop Tshark and download logs
    Check_handover_intra_freq_inter_gnb  cell_id_before_ho=50  cell_id_after_ho=152
    Verify ULDL UDP NSA   ${tput_DL_bandwith_900D}   ${tput_UL_bandwith_900D}
