*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/CB008950-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/CB008950-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/CB008950-D.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010741/CB010741-D-B4.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # Beucause of Connect to coam kw, will
# be moved to common_keywords.robot
Library     ta5g_file_system


Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASILL_ABIOB1_1xAVQL

Suite Setup     Run keywords
...             Set Suite variables CB008950    AND
...             Wait Until Keyword Succeeds    5x    60 sec    Setup attenuators with pdu power reset  AND
#...             Prepare and check TL multirat  AND
...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1  AND  #0123456789ABCDEF
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2  AND  #F2138
...             Require Ue    UE_3    capabilities=REAL_ANDROID_UE_3       #MTK2

Test Setup      Run Keywords
...             Turn off attenuation  AND
...             Turn off attenuation_2  AND
...             Run Keyword and Ignore Error  Start syslog collection    AND
...             Connect To Coam

Test Teardown   Run keywords
...             Make snapshot in case of error    AND
...             Disconnect coam    AND
...             ute_ue.Detach Ue  UE_1    AND
...             ute_ue.Detach Ue  UE_2    AND
...             ute_ue.Detach Ue  UE_3    AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Run Keyword and Ignore Error   Verify Crash occurrence In Syslog  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Sleeping cell test    AND
...             Compress test logs    AND
...             Delete active DCAP trace for BTS  ${mrbts_id}


*** Test Cases ***

[1]CB008950-A#B3_SCell_selection_during_A1_measurement_based_SCell_Addition_for_SA_UE_equal_SCellprio
    [Documentation]    All UEs COM19, COM20, COM27 must be in SA mode.
    ...                AT commands to set SA in ELT: AT+ERAT=15  AT+E5GOPT=3
    ...                ALL UEs bands n71, n66, n41, n25
    ...                mediatek M80 Figeac secret codes: *#*#3646633#*#*, *#*#4636#*#*
    [1]CB008950-A#B3_SCell_selection_during_A1_measurement_based_SCell_Addition_for_SA_UE_equal_SCellprio

[1]CB008950-A#B4_SCell_selection_during_A1_measurement_based_SCell_Addition_for_SA_UE_different_SCellprio
    [Documentation]    All UEs COM19, COM20, COM27 must be in SA mode.
    ...                AT commands to set SA in ELT: AT+ERAT=15  AT+E5GOPT=3
    ...                ALL UEs bands n71, n66, n41, n25
    ...                mediatek M80 Figeac secret codes: *#*#3646633#*#*, *#*#4636#*#*
    [1]CB008950-A#B4_SCell_selection_during_A1_measurement_based_SCell_Addition_for_SA_UE_different_SCellprio

[1]CB008950-C-B1 SCell selection during A1 measurement based SCell Addition for NSA UE
    [Documentation]    All UEs COM19, COM20, COM27 must be in NSA mode.
    ...                AT commands to set NSA in ELT: AT+ERAT=19 AT+E5GOPT=5
    ...                ALL UEs bands n71, n66, n41, n25
    ...                mediatek M80 Figeac secret codes: *#*#3646633#*#*, *#*#4636#*#*
    [1]CB008950-C-B1 SCell selection during A1 measurement based SCell Addition for NSA UE

[1]CB008950-D#B5_SCell_swap_is_executed_only_if_the_number_of_active_outgoing_CA_relations_towards_the_target_SCell_does_not_exceed_the_limit
    [Documentation]    All UEs COM19, COM20, COM27 must be in SA mode.
    ...                AT commands to set SA in ELT: AT+ERAT=15  AT+E5GOPT=3
    ...                COM19 set n66 and n71 bands (pcell 114, CA scell 101)
    ...                COM20 set n66, n41 bands (cell 114, CA scell 108)
    ...                COM27 set n66, n25 bands (cell 114, CA scell 105)
    ...                mediatek M80 Figeac secret codes: *#*#3646633#*#*, *#*#4636#*#*
    [1]CB008950-D#B5_SCell_swap_is_executed_only_if_the_number_of_active_outgoing_CA_relations_towards_the_target_SCell_does_not_exceed_the_limit

[1]CB008950-D-B201 FR1 CA is setup only if the number of active incoming CA relations in the SCells does not exceed the limit
    [Documentation]    UEs COM19 and COM20 must be in SA mode. COM27 must be in NSA mode.
    ...                AT commands to set SA in ELT: AT+ERAT=15  AT+E5GOPT=3. AT commands to set NSA in ELT: AT+ERAT=19 AT+E5GOPT=5
    ...                COM19 set n25 and n41 bands (pcell 106, CA scell 108)
    ...                COM20 set n66, n41 bands (cell 116, CA scell 108)
    ...                COM27 set b2, n41, n71 bands (attach LTE 214, NSA with pcell 101 and CA scell 108)
    ...                mediatek M80 Figeac secret codes: *#*#3646633#*#*, *#*#4636#*#*
    [1]CB008950-D-B201 FR1 CA is setup only if the number of active incoming CA relations in the SCells does not exceed the limit

[1]CB010741_D_B4_2_Retest_of_CB010741-A#B4_with_one-shot_buffer_based_SCell_Addition
    [1]CB010741_D_B4_2_Retest_of_CB010741-A#B4_with_one-shot_buffer_based_SCell_Addition
