*** Settings ***
Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup
Test Teardown        SBTS Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot

Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_LTE}/General_SiSo_RU_module_reset_from_GUI_with_L3call.robot
Resource    CB009919_AEQP_keywords.robot

Documentation
...    Author: Qingqing Deng
...    Contact: qingqing.deng@nokia-sbell.com
...    squad group:SG_02
...    Feature CB009919


# refer to 《Microsoft Excel Worksheet》in 《CB009919 CP2.docx》.
# _15M_frame_1_5.xml
# DL:TM3  64  1 5  15M  PDCCH Symbol=1  peak=43.33
# UL:     64  1 5  15M                  peak=18.448

# _15M_20M_frame_1_7.xml
# DL:TM3  64  1 7  15M  PDCCH Symbol=1  peak=59.56
# UL:     64  1 7  15M                  peak=18.448


*** Variables ***
${target_throughput_dl_15M_1_5}    43
${target_throughput_ul_15M_1_5}    18
${target_throughput_dl_15M_1_7}    59
${target_throughput_ul_15M_1_7}    18


*** Test Cases ***
[3][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
    log to console    Commison scf
    ${SCF_3_cell_per_loki}    Replace String    ${Golden_SCF_Path}    .xml    _3_cell_per_loki.xml
    Commissioning SCF And Check On Air for Common   scf_path=${SCF_3_cell_per_loki}
    General_SiSo_Commissioning_BTS_Template_Commissioning


[1][2.0] General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification
    log to console    Commison scf
    ${SCF_15M_frame_1_7}    Replace String    ${Golden_SCF_Path}    .xml    _15M_frame_1_7.xml
    Commissioning SCF And Check On Air for Common   scf_path=${SCF_15M_frame_1_7}
    General_SiSo_Beamforming_calibration_Cal_Software_Component_Operation_Verification

[2][2.0] General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification
    log to console    Commison scf
    ${SCF_20M_frame_1_6}    Replace String    ${Golden_SCF_Path}    .xml    _20M_frame_1_6.xml
    Commissioning SCF And Check On Air for Common   scf_path=${SCF_20M_frame_1_6}
    General_SiSo_Beamforming_calibration_Cal_Software_Component_Operation_Verification
	
[2][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    log to console    Commison scf
    ${SCF_15M_frame_1_5}    Replace String    ${Golden_SCF_Path}    .xml    _15M_frame_1_5.xml
    Commissioning SCF And Check On Air for Common   scf_path=${SCF_15M_frame_1_5}
    ${lte_cell_id_list}    Get All Cell Id    cell_type=lte
    Simple UE L3 Call And Throughput    cell_list=${lte_cell_id_list}    
    ...    dl_tp=${target_throughput_dl_15M_1_5}    ul_tp=${target_throughput_ul_15M_1_5}
    ...    target_avg_percent=0.9   min_percent=0.8    scf_path=${SCF_15M_frame_1_5}
    ...    duration=${200}

[3][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    log to console    Commison scf
    ${SCF_15M_20M_frame_1_7}    Replace String    ${Golden_SCF_Path}    .xml    _15M_20M_frame_1_7.xml
    Commissioning SCF And Check On Air for Common   scf_path=${SCF_15M_20M_frame_1_7}
    ${lte_cell_id_list}    Get All Cell Id    cell_type=lte
    Simple UE L3 Call And Throughput    cell_list=${lte_cell_id_list}    
    ...    dl_tp=${target_throughput_dl_15M_1_7}    ul_tp=${target_throughput_ul_15M_1_7}
    ...    target_avg_percent=0.9   min_percent=0.8    scf_path=${SCF_15M_20M_frame_1_7}
    ...    duration=${200}

[1][1.0] General_SiSo_Auto_uDTX_verification
    log to console    Commison scf
    ${SCF_uDTX_Enable_15M_frame_1_7}    Replace String    ${Golden_SCF_Path}    .xml    _uDTX_Enable_15M_frame_1_7.xml
    Commissioning SCF And Check On Air for Common   scf_path=${SCF_uDTX_Enable_15M_frame_1_7}
    ${low_rmod_powers}    Get Average Rmod RealTime Power Measurement
    ${SCF_uDTX_Disable_15M_frame_1_7}    Replace String    ${Golden_SCF_Path}    .xml    _uDTX_Disable_15M_frame_1_7.xml
    Commissioning SCF And Check On Air for Common   scf_path=${SCF_uDTX_Disable_15M_frame_1_7}
    ${high_rmod_powers}    Get Average Rmod RealTime Power Measurement
    ${rmod_length}    Get Length    ${high_rmod_powers}
    FOR    ${i}    IN RANGE    ${rmod_length}
        Should Be True    ${high_rmod_powers[${i}]}>${low_rmod_powers[${i}]}
    END
