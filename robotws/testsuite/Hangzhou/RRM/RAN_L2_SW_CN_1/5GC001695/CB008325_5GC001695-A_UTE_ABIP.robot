*** Settings ***
Documentation    ...
#Suite Setup        Common Suite Setup
#Test Setup         Create Test Directory
##Test Teardown      Common Test Teardown
#Force Tags         Classical    IPV4    IPV6    FR1    Owner_suqian    PRI-High
#...                CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    RAN_5G_TDD
#...                5GC001695    RAN_5G    SBTS00    SBTS23R1    SBTS22R4
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./Resources/5GC001695_keyword.robot
#Library            ./../CUDU_L2/scripts/python/check_cap.py
#Library            check_cap.CapPacket     WITH NAME    my_cap
#*** Variables ***
#${beamset5}    beamSet_5_1
#${EdgeAngle1}    60
#${numberOfTransmittedSsBlocks2}    6 beams
#
#*** Test Cases ***
#5GC001695-ET-A013 Verify Beam tracking successfully on 2 row and 6 SSB for 2x8x2 RRU
#    [Tags]    case1    CRT
#    Set SCF Parameter For ABIN 1695    ${beamset5}    ${EdgeAngle1}    ${numberOfTransmittedSsBlocks2}
#    Reboot Testline and Check 1695 Cell Onair
#    Caputre and Check log for angle 120 for switch
#    NSA LTE Detach    ue_id=11
#
#*** Keywords ***
#Set SCF Parameter For ABIN 1695
#    [Arguments]    ${beamset}    ${EdgeAngle}    ${numberOfTransmittedSsBlocks}
#    ${delta_file}    Set Variable    ${CURDIR}/Delta_1695_ABIP.json
#    @{old_params_list}    Create List    "basicBeamSet": "[0-9a-zA-Z_]+"    "leftEdgeAngle": "[0-9]+"    "rightEdgeAngle": "[0-9]+"
#    ...    "value": "[0-9] beams"
#    @{new_params_list}    Create List    "basicBeamSet": "${beamset}"    "leftEdgeAngle": "${EdgeAngle}"    "rightEdgeAngle": "${EdgeAngle}"
#    ...    "value": "${numberOfTransmittedSsBlocks}"
#    Modify Text File    ${delta_file}    ${old_params_list}    ${new_params_list}
#    Delta Commission Json File With Admin    ${delta_file}    600
#
#Caputre and Check log for angle 120 for switch
#    capture bip    A013_120_tcpdumpL2L1_filtering_off.pcap0
#    #Download MCShark To UTE    ${SW_VERSION_TOTAL}
#    Convert BIP To CSV By MCShark For DlData_SsBlockSendReq    A013_120_tcpdumpL2L1_filtering_off.pcap0
#    A2A_Check_CSV_Table    ${CURDIR}/Resources/A013.ini    ${LOG_PATH}/ssblock.csv
#    NSA LTE Attach    ue_id=11    profile_id=1
#    UE Beamforming Profile And Association For 6 Beams    ${UE_ID}
#    5G Attach and Get Throughput
#    capture bip    A013_120_traffic_tcpdumpL2L1_filtering_off.pcap0
#    Convert BIP To CSV By MCShark For DlData_PdcchSendReq    A013_120_tcpdumpL2L1_filtering_off.pcap0
#    A2A_Check_CSV_Table    ${CURDIR}/Resources/traffic.ini    ${LOG_PATH}/pdcch.csv
#    UE Beamforming Switch    ${UE_ID}    ${PROFILE_ID_2}
#    Sleep    10s    reason=Wait the beam switch stable...
#    capture bip    A013_120_switch_tcpdumpL2L1_filtering_off.pcap0
#    Convert BIP To CSV By MCShark For DlData_PdcchSendReq    A013_120_tcpdumpL2L1_filtering_off.pcap0
#    A2A_Check_CSV_Table    ${CURDIR}/Resources/switch.ini    ${LOG_PATH}/pdcch.csv