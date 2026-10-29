*** Settings ***
Documentation    ...
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./Resource/5GC000918_keyword.robot
#Suite Setup        Common Suite Setup 2
##Test Teardown      Common Test Teardown 2
##Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_LO_AP_LO    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD
#
#*** Variables ***
#${UE_ID}            1
#*** Test Cases ***
#5GC000918_B_13_Verify_32_SSB_beamSetFR2_8888_1P_87_114_successfully_during_L3call_setup
#    [Documentation]
#    ...    Precondition:
#    ...    SA+FR2
#    ...    Test Steps:
#    ...      Step1: enable 2p beamset and check onair
#    ...      Step2: SA UE attach to beam0
#    ...      Step3: beam switch to beam5
#    ...      Step4: Release call.
#    ...    Check Points:
#    ...      1)After step1, Verify 32 SSB ok
#    ...      2)After step2, check the pdcch used beam is beam0
#    ...      3)After step3, check the pdcch used beam is beam5
#    ...      4)After step4, UE release
#    [Tags]     case_B013    Manual_suqian    TA_suqian   CRT
#    #setp1
#    ${json_file}=    Change Delta XML File To Delta Json File    ${CURDIR}/Delta_918.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Capture Bip For 918    B13_tcpdumpL2L1_filtering_off.pcap0
#	Convert BIP To CSV By MCShark For DlData_SsBlockSendReq    B13_tcpdumpL2L1_filtering_off.pcap0
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/B013.ini    ${LOG_PATH}/ssblock.csv
#    #step2
#    UE Beamforming Profile And Association For 32 Beams    ${UE_ID}
#    SA Single UE Attach    ${UE_ID}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    500
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    100
#    Capture Bip For 918    B13_tcpdumpL2L1_traffic.pcap0
#    Convert BIP To CSV By MCShark For DlData_PdschSendReq    B13_tcpdumpL2L1_traffic.pcap0
#    A2A_Check_CSV_Table   ${CURDIR}/Resource/B13_pdsch.ini    ${LOG_PATH}/pdsch.csv
#    #step3
#    UE Beamforming Switch    ${UE_ID}    ${PROFILE_ID_2}
#    Sleep    10s    reason=Wait the beam switch stable...
#    Capture Bip For 918    B13_tcpdumpL2L1_switch.pcap0
#    Convert BIP To CSV By MCShark For DlData_PdschSendReq    B13_tcpdumpL2L1_switch.pcap0
#    A2A_Check_CSV_Table   ${CURDIR}/Resource/B13_switch.ini    ${LOG_PATH}/pdsch.csv
#    #step4
#    SA 5G Detach    ${UE_ID}
#
#*** Keywords ***
#
