*** Settings ***
Documentation    ...
#Suite Setup        Run Keywords    Common Suite Setup
#...                AND    Prepare QT LOLO Enviroment    TYPE=TDD_NSA
##Suite Teardown    Common Suite Teardown
#Test Setup         Create Test Directory
#Test Teardown      Common Test Teardown
#Force Tags         Classical    IPV4    IPV6    FR1    Owner_suqian    PRI-High
#...                CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    RAN_5G_TDD
#...                5GC000918    RAN_5G    SBTS00    SBTS23R1    SBTS22R4
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./Resource/5GC000918_keyword.robot
#*** Variables ***
#${DST_FOR_BTS}    MRBTS-1/NRBTS-1
#${DST_FOR_FRM}    MRBTS-1/NRBTS-1/NRCELL-1
#${DST_FOR_GROUP}    MRBTS-1/NRBTS-1/NRCELLGRP-0
#${DST_FOR_PMCADM}    MRBTS-1/MNL-1/PMCADM-1
#${beamset1}    beamSetAbf_32C
#${beamset2}    beamSetFR2_6_6_4_2P
#${beamset3}    beamSetFR2_8_8_8_8_1P
#${EdgeAngle1}    40
#${EdgeAngle2}    90
#${EdgeAngle3}    60
#${lowerEdgeAngle1}    108
#${lowerEdgeAngle2}    130
#${lowerEdgeAngle3}    114
#${upperEdgeAngle1}    72
#${upperEdgeAngle2}    90
#${upperEdgeAngle3}    87
#*** Test Cases ***
#5GC000918_A_09_Verify_Basic_Beam_set_as_BemaSetAbf_32C_during_cell_setup
#    [Tags]    case1    CRT
#    ${json_file}=    Change Delta XML File To Delta Json File    ${CURDIR}/918.xml
#    Delta Commission With SCF File    ${json_file}
#	Reboot Testline and Check 918 Cell Onair
#    capture bip    A09_tcpdumpL2L1_filtering_off.pcap0
#	#Download MCShark To UTE    ${SW_VERSION_TOTAL}
#    Convert BIP To CSV By MCShark For DlData_SsBlockSendReq    A09_tcpdumpL2L1_filtering_off.pcap0
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/A009.ini    ${LOG_PATH}/ssblock.csv
#
#*** Keywords ***
#
#Set SCF Parameter For 918
#    [Arguments]    ${beamset}    ${EdgeAngle}    ${lowerEdgeAngle}    ${upperEdgeAngle}
#    ${delta_file}    Set Variable    ${CURDIR}/Delta_OE_918.json
#    @{old_params_list}    Create List    "basicBeamSet": "[0-9a-zA-Z_]+"    "leftEdgeAngle": "[0-9]+"    "rightEdgeAngle": "[0-9]+"
#    ...    "lowerEdgeAngle": "[0-9]+"    "upperEdgeAngle": "[0-9]+"
#    @{new_params_list}    Create List    "basicBeamSet": "${beamset}"    "leftEdgeAngle": "${EdgeAngle}"    "rightEdgeAngle": "${EdgeAngle}"
#    ...    "lowerEdgeAngle": "${lowerEdgeAngle}"    "upperEdgeAngle": "${upperEdgeAngle}"
#    Modify Text File    ${delta_file}    ${old_params_list}    ${new_params_list}
#    Delta Commission Json File With Admin    ${delta_file}
