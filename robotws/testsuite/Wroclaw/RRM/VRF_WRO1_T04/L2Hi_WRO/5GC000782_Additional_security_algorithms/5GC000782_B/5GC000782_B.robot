*** Settings ***
Resource     ../../resources/common_keywords.robot
Resource     ../../resources/common_configuration.robot
Library      ../5GC000782_A/5GC000782_A.py
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_file_system
Library      ta5g_tshark
Library      ta5g_throughput
Library      ta5g_enb
Library      ta5g_iphy
Variables    ta5g_global_var
Documentation
...    author: Mariusz Waczynski
...    maintainer: Marek Niescioruk (marek.niescioruk@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Suite Setup     Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...    AND        Reach Onair    lua_cfg=${CURDIR}/config/egate_1c_sansa.lua
...    AND        Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=true
...    AND        Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Send Configuration ID To Scout

Suite Teardown    Run Keywords    Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=false
...    AND                        Check For An Unexpected Alarm
...    AND                        Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${FULL_COMMISSIONING}=       ${FALSE}
${RESET_TL}=                 ${FALSE}

*** Test Cases ***
5GC000782_B_9_Gnb_Selects_Snow3g_Algorithm_Ul_Dl_Zuc_Data
    [Tags]   CRT
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/deciphering of user data
    ...         Also verify that DL traffic is ciphered & deciphered at gNB and UE respectively
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_B/tc1_nea0_1_nea1_1_nea2_0_nea3_1.json
	Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
	...    dl_throughput=5mbps
	...    ul_throughput=5mbps
	...    filename=e1_f1_interfaces.pcap
	Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
	Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
	Assert That Nrrrc Ciphering Algorithm Equals Nea1            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea1.pcap
	[Teardown]    Run Keywords    Detach Ue    ue_id=11
	...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000782_B_8_Gnb_Selects_Snow3g_Algorithm_Dl_data
    [Tags]   CRT
    [Documentation]   This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that DL & UL traffic is not degrading due to enabling ZUC algorithm
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_B/tc2_nea0_1_nea1_4_nea2_2_nea3_3.json
    Perform SgNBAddition With Start Data Traffic And Capture Pcap
    ...    direction=dl
    ...    throughput=5mbps
    ...    filename=e1_f1_interfaces.pcap
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
	Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
	Assert That Nrrrc Ciphering Algorithm Equals Nea1            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea1.pcap
	Assert That E1ap Ciphering Algorithm Equals Nea1             output_dirpath=${OUTPUT_DIR}/Ciphering_E1ap_Algorithm_Equals_Nea1.pcap
	Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
	[Teardown]    Run Keywords    Detach Ue    ue_id=11
	...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000782_B_7_Gnb_Selects_Snow3g_Algorithm_Ul_Dl_data
    [Tags]   CRT
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
     ...          Also verify that DL & UL traffic is ciphered & diciphered at gNB & UE
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_B/tc3_nea0_0_nea1_0_nea2_0_nea3_6.json
	Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
	...    dl_throughput=5mbps
	...    ul_throughput=5mbps
	...    filename=e1_f1_interfaces.pcap
	Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
	Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
	Assert That Nrrrc Ciphering Algorithm Equals Nea1            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea1.pcap
    Assert That E1ap Ciphering Algorithm Equals Nea1             output_dirpath=${OUTPUT_DIR}/Ciphering_E1ap_Algorithm_Equals_Nea1.pcap
    Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
    [Teardown]    Run Keywords    Detach Ue    ue_id=11
	...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000782_B_6_Gnb_Selects_Snow3g_Algorithm_Ul_Data
    [Tags]   CRT
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that  UL traffic is ciphered & diciphered at gNB & UE
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_B/tc4_nea0_5_nea1_9_nea2_7_nea3_8.json
    Perform SgNBAddition With Start Data Traffic And Capture Pcap
    ...    direction=ul
    ...    throughput=5mbps
    ...    filename=e1_f1_interfaces.pcap
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
	Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
	Assert That Nrrrc Ciphering Algorithm Equals Nea1            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea1.pcap
	Assert That E1ap Ciphering Algorithm Equals Nea1             output_dirpath=${OUTPUT_DIR}/Ciphering_E1ap_Algorithm_Equals_Nea1.pcap
	Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
	[Teardown]    Run Keywords    Detach Ue    ue_id=11
	...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000782_B_5_Gnb_Selects_Snow3g_Algorithm_Dl_Data
    [Tags]   CRT
    [Documentation]    This TC verify that gNB selects SNOW3G ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that  UL&DL traffic is ciphered & diciphered at gNB & UE
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_B/tc5_nea0_1_nea1_4_nea2_2_nea3_3.json
    Perform SgNBAddition With Start Data Traffic And Capture Pcap
    ...    direction=ul
    ...    throughput=5mbps
    ...    filename=e1_f1_interfaces.pcap
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
	Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
	Assert That Nrrrc Ciphering Algorithm Equals Nea1            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea1.pcap
	Assert That E1ap Ciphering Algorithm Equals Nea1             output_dirpath=${OUTPUT_DIR}/Ciphering_E1ap_Algorithm_Equals_Nea1.pcap
	Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
	[Teardown]    Run Keywords    Detach Ue    ue_id=11
	...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000782_B_14_Gnb_Selects_Aes_Algorithm_Ul_Dl_data
    [Tags]   CRT
    [Documentation]  This TC verify that gNB selects AES ciphering algorithm for ciphering/diciphering of user data
    ...         Also verify that  UL&DL traffic is ciphered & diciphered at gNB & UE
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/5GC000782/5GC000782_B/tc6_nea0_1_nea1_2_nea2_9_nea3_3.json
	Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
	...    dl_throughput=5mbps
	...    ul_throughput=5mbps
	...    filename=e1_f1_interfaces.pcap
	Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=ul    selection_type=average
    Expected Throughput For Bearer Should Be Reached    ue_id=11    bearer_id=2    throughput=1    direction=dl    selection_type=average
    Assert That NRencryptionAlgorithms Are Supported             output_dirpath=${OUTPUT_DIR}/nRencryptionAlgorithms.pcap
    Assert That ReponseInformationSgNBReconfComp Exists          output_dirpath=${OUTPUT_DIR}/ReponseInformationSgNBReconfComp.pcap
	Assert That CUtoDURRCInformation Exists In Setup Request     output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Request.pcap
    Assert That CUtoDURRCInformation Exists In Setup Response    output_dirpath=${OUTPUT_DIR}/CUtoDURRCInformation_Exists_In_Setup_Response.pcap
	Assert That Nrrrc Ciphering Algorithm Equals Nea2            output_dirpath=${OUTPUT_DIR}/Ciphering_Nrrc_Algorithm_Equals_Nea2.pcap
    Assert That E1ap Ciphering Algorithm Equals Nea2             output_dirpath=${OUTPUT_DIR}/Ciphering_E1ap_Algorithm_Equals_Nea2.pcap
    Assert That Bearer Context Setup Response Exists             output_dirpath=${OUTPUT_DIR}/Bearer_Context_Setup_Response_Exists.pcap
    [Teardown]    Run Keywords    Detach Ue    ue_id=11
	...    AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Perform SgNBAddition With Start Data Traffic And Capture Pcap
    [Arguments]    ${direction}    ${throughput}    ${filename}
    Perform SgNBAddition And Capture Pcap    filename=${filename}
    Start Data Traffic    ues=11    bearer_id=2    direction=${direction}    throughput=${throughput}
    Sleep    10s

Perform SgNBAddition With Dl And Ul Data Traffic And Capture Pcap
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${filename}
    Perform SgNBAddition And Capture Pcap    filename=${filename}
    Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=${dl_throughput}
    Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=${ul_throughput}
    Sleep    10s

Perform SgNBAddition And Capture Pcap
    [Arguments]    ${filename}
    Start Capturing Pcap On E1 And F1 Interfaces    filename=${filename}
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    Sleep    5s    Waiting For All Packets To Be Captured
    Stop Capturing Pcap On E1 And F1 Interfaces    filename=${filename}

Stop Capturing Pcap On E1 And F1 Interfaces
    [Arguments]    ${filename}
    ${output}=    Execute Enb Command    cmd=ps -ef | grep ${filename} | awk '{print $2}' | awk 'NR==1'
    Execute Enb Command    cmd=kill -TERM ${output}
    Get File From Enb    source=/tmp/${filename}    destination=${OUTPUT_DIR}/${filename}
