*** Settings ***
Documentation    TC__RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue
Variables    tc_variables/RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${UE1_CAPABILITIES}    None                   # For UE1 - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${UE2_CAPABILITIES}    None                   # For UE2 - label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
${TECHNO_UE1}    GSM                         # Specified techno used for UE1; possible values:"WCDMA", "LTE", "LTE_MASTER", "LTE_SLAVE", "GSM", "NR",
                                             # "SBTS_LTE"
${TECHNO_UE2}    LTE                         # Specified techno used for UE2; possible values:"WCDMA", "LTE", "LTE_MASTER", "LTE_SLAVE", "GSM", "NR",
                                             # "SBTS_LTE"
${UE1_call_type}    voice                     # Type of call to be performed on UE1. Possible values: data, voice
${UE2_call_type}    data                      # Type of call to be performed on UE2. Possible values: data, voice
${CELLS_LIST_UE1}    DEFAULT                 # Specify the cells list on which UE1 will be chekced; Possible values: "DEFAULT" - means that UE is
                                             # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                             # with space between Cells Id. For WCDMA - Global Cell Id is used, for LTE -  Eutran Cell Id is used,
                                             # for GSM - Cell CI is used, for NR - NRCellID is used.
${CELLS_LIST_UE2}    DEFAULT                 # Specify the cells list on which UE2 will be chekced; Possible values: "DEFAULT" - means that UE is
                                             # checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list
                                             # with space between Cells Id. For WCDMA - Global Cell Id is used, for LTE -  Eutran Cell Id is used,
                                             # for GSM - Cell CI is used, for NR - NRCellID is used.
${CALL_DURATION}    100                      # Duration of data/voice call for both UEs (in seconds); For voice call make sure to provide a value
                                             # greater than 10
${UE1_NUMBER_TO_CALL}    00104                # Number to which voice call will be performed for UE1
${UE2_NUMBER_TO_CALL}    00104                # Number to which voice call will be performed for UE2
${CALL_DIRECTION_UE1}    downlink            # Direction of data transfer call for UE1; possible values: "downlink", "uplink" and "uplink_downlink"
${CALL_DIRECTION_UE2}    downlink            # Direction of data transfer call for UE2; possible values: "downlink", "uplink" and "uplink_downlink"
${PROTOCOL_UE1}    udp                        # Data transfer protocol for UE1. e.q. udp, tcp, ftp
${PROTOCOL_UE2}    udp                        # Data transfer protocol for UE2. e.q. udp, tcp, ftp
${downlink_MAX_TPUT_UE1}    150 Mbits/sec    # DL Maximum acceptable t-put for UE1;acceptable values: e.q. LTE - 150 Mbits/sec; WCDMA - 10 Mbits/sec;
                                             # GSM - 400 Kbits/sec
${downlink_MIN_TPUT_UE1}    145 Kbits/sec    # DL Minmum acceptable t-put for UE1; acceptable values: e.q. LTE - 5 Mbits/sec; WCDMA - 350 Kbits/sec;
                                             # GSM - 150 Kbits/sec
${uplink_MAX_TPUT_UE1}    50 Mbits/sec       # UL Maximum acceptable t-put for UE1; acceptable values: e.q. LTE - 50 Mbits/sec; WCDMA - 8 Mbits/sec;
                                             # GSM - 300 Kbits/sec
${uplink_MIN_TPUT_UE1}    78 Kbits/sec       # UL Minimum acceptable t-put for UE1; acceptable values: e.q. LTE - 3 Mbits/sec; WCDMA - 350 Kbits/sec;
                                             # GSM - 80 Kbits/sec
${downlink_MAX_TPUT_UE2}    150 Mbits/sec    # DL Maximum acceptable t-put for UE2;acceptable values: e.q. LTE - 150 Mbits/sec; WCDMA - 10 Mbits/sec;
                                             # GSM - 400 Kbits/sec
${downlink_MIN_TPUT_UE2}    145 Kbits/sec    # DL Minmum acceptable t-put for UE2; acceptable values: e.q. LTE - 5 Mbits/sec; WCDMA - 350 Kbits/sec;
                                             # GSM - 150 Kbits/sec
${uplink_MAX_TPUT_UE2}    50 Mbits/sec       # UL Maximum acceptable t-put for UE2; acceptable values: e.q. LTE - 50 Mbits/sec; WCDMA - 8 Mbits/sec;
                                             # GSM - 300 Kbits/sec
${uplink_MIN_TPUT_UE2}    78 Kbits/sec       # UL Minimum acceptable t-put for UE2; acceptable values: e.q. LTE - 3 Mbits/sec; WCDMA - 350 Kbits/sec;
                                             # GSM - 80 Kbits/sec
${BANDWIDTH}    60 Mbits/sec                 # max bandwidth for UDP in bits (used for both UEs); acceptable values: e.q. LTE - 60 Mbits/sec;
                                             # WCDMA 10 Mbits/sec; GSM - 200 Kbits/sec
${DETACH_UE}    False                        # Specify whether to dettach the UEs after the test execution; Possible values: True/False.
                                             # Default value: False
${CHECK_ATTACH_ONLY}    False                 # Flag for skipping data transfer part and perform check of attach only;
                                             # Possible values:True/False. Default value: False

*** Keywords ***
TC__RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-25042
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test for performing data transfer/voice calls based on selected TECHNO variable: WCDMA, LTE, GSM, NR based on 2 UEs simultaneously,
    ...  using taf.ue solution
    ...
    ...
    ...  Below are described the variables that you can complete:
    ...
    ...  - UE1_CAPABILITIES, UE2_CAPABILITIES            ----  label used to identify a specific ue defined in yaml config (from yaml CAPABILITIES)
    ...
    ...  - UE1_call_type, UE2_call_type                  ----  Type of call to be performed on UE1/UE2. Possible values: data, voice
    ...
    ...  - TECHNO_UE1, TECHNO_UE2                        ----  Specified techno used; possible values: "WCDMA", "LTE", "GSM", "NR", "LTE_MASTER",
    ...  "LTE_SLAVE", "SBTS_LTE"
    ...
    ...  - CELLS_LIST_UE1, CELLS_LIST_UE2                ----  Specify the cells list on which UE will be chekced; Possible values: "DEFAULT" -
    ...  means that UE is checked if it is camped on a cell belonging to BTS; "30295 30294 30293" - User provides cells list with space between Cells
    ...  Id. For WCDMA - Global Cell Id is used, for LTE -  Eutran Cell Id is used, for GSM - Cell CI is used, for NR - NRCellID is used.
    ...
    ...  - CALL_DIRECTION_UE1, CALL_DIRECTION_UE2        ----  Direction of data transfer call; possible values: "downlink", "uplink" and
    ...  "uplink_downlink"
    ...
    ...  - CALL_DURATION                                 ----  Duration of data/voice call in seconds for both UEs
    ...
    ...  - downlink_MAX_TPUT_UE1, downlink_MAX_TPUT_UE2  ----  Downlink Maximum acceptable t-put; acceptable values: e.q. LTE - 150 Mbits/sec;
    ...  WCDMA - 10 Mbits/sec; GSM - 400 Kbits/sec
    ...
    ...  - downlink_MIN_TPUT_UE1, downlink_MIN_TPUT_UE2  ----  Downlink Minmum acceptable t-put; acceptable values: e.q. LTE - 5 Mbits/sec;
    ...  WCDMA - 350 Kbits/sec; GSM - 150 Kbits/sec
    ...
    ...  - uplink_MAX_TPUT_UE1, uplink_MAX_TPUT_UE2      ----  Uplink Maximum acceptable t-put; acceptable values: e.q. LTE - 50 Mbits/sec;
    ...  WCDMA - 8 Mbits/sec; GSM - 300 Kbits/sec
    ...
    ...  - uplink_MIN_TPUT_UE1, uplink_MIN_TPUT_UE2      ----  Uplink Minimum acceptable t-put; acceptable values: e.q. LTE - 3 Mbits/sec;
    ...  WCDMA - 350 Kbits/sec; GSM - 80 Kbits/sec
    ...
    ...  - PROTOCOL_UE1, PROTOCOL_UE2                    ----  Data transfer protocol. e.q. udp, tcp, ftp
    ...
    ...  - BANDWIDTH                                     ----  max bandwidth for UDP in bits/sec for both UEs; acceptable values:
    ...  e.q. LTE - 60 Mbits/sec; WCDMA 10 Mbits/sec; GSM - 200 Kbits/sec
    ...
    ...  - DETACH_UE                                     ---- Specify whether to dettach the UEs after the test execution;
    ...  Possible values: True/False. Default value: False
    ...
    ...  - CHECK_ATTACH_ONLY                             ----  Flag for skipping data transfer part and perform check of attach only;
    ...                                                  Possible values: True/False. Default value: False
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 30.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25042 - TC Delivery - RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue
    ...  - 14.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26310 - [Calls][P1]Check attach only option
    ...   RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue
    ...  - 05.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26535 - [Calls][P1]Attach only option in
    ...  RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue should only impact data transfer
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27394 - [Calls] Variable '${WCDMA_Count}' not found
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27216 - [Calls] Remove ute-ue call solution
    ...  - 30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27373 - Refactor RRM TCs after drop of legacy WCDMA and GSM - Argument Part
    ...  - 10.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27448 - Refactor - Remove mechanism based on NR, LTE, WCDMA, GSM Count variables
    ...  - 19.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27717 - [Cloud][RF5] Update robotws testcases - NRL, NR_NR, NR_SBTS, RRM, PM, LOGS
    ...  - 09.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29068 - increase Require UE timeout from 180s to 300s
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30631 - Broken interface for Get SBTS Cell Ids from admin,
    ...  Get GSM cell IDs from BSC and admin, and Get NR Cell Ids from admin keywords - update according to new interface
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25042_RRM__RFS__2UEs_Simultaneous_Data_Voice_Call_Taf_Ue.png


    Set Tags    CA-RRM    OWNER-oana.bonchis@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-CR1    SW-WBTS18, BTS18,
    ...    SBTS23R3    CABLING-RFS_01_UE

    Step 1: TC Parameter Check ${TECHNO_UE1} for UE 1
    Step 2: TC Parameter Check ${TECHNO_UE2} for UE 2
    Step 3: Get Cells List of ${TECHNO_UE1} for UE 1
    Step 4: Get Cells List of ${TECHNO_UE2} for UE 2
    Step 5: Perform Simultaneous call for both UEs
    Step 6: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: TC Parameter Check ${TECHNO} for ${ue_index}
    Log  Step ${index}: TC Parameter Check ${TECHNO} for ${ue_index}  console=True
    ${BTS_nb}=  Get Length  ${alias_list}
    Set Test Variable  ${BTS_nb}
    Run Keyword If  ('${TECHNO}' == 'LTE_MASTER' and '${MASTER['MASTER_TECH']}' == 'LTE')  Return From Keyword
    ...  ELSE IF  ('${TECHNO}' == 'LTE_MASTER' and '${MASTER['MASTER_TECH']}' != 'LTE')
    ...  Fail  Parameter TECHNO is set as LTE_MASTER but MASTER_TECH is ${MASTER['MASTER_TECH']}!
    Run Keyword If  ('${TECHNO}' == 'LTE_SLAVE' and '${SLAVE['SLAVE_TECH']}' == 'LTE')  Return From Keyword
    ...  ELSE IF  ('${TECHNO}' == 'LTE_SLAVE' and '${SLAVE['SLAVE_TECH']}' != 'LTE')
    ...  Fail  Parameter TECHNO is set as LTE_SLAVE but SLAVE_TECH is ${SLAVE['SLAVE_TECH']}!
    ${condition1}=  Create Long String  ('${TECHNO}' in ['NR', 'SBTS_LTE', 'LTE', 'WCDMA', 'GSM']) and ('${MASTER['MASTER_TECH']}' == 'SBTS' or
    ...  '${SLAVE['SLAVE_TECH']}' == 'SBTS')
    ${condition2}=  Create Long String  ('${TECHNO}' in ['NR', 'SBTS_LTE', 'LTE', 'WCDMA', 'GSM']) and ('${MASTER['MASTER_TECH']}' != 'SBTS' and
    ...  '${SLAVE['SLAVE_TECH']}' != 'SBTS')
    Run Keyword If  ${condition1}
    ...  Return From Keyword
    ...  ELSE IF  ${condition2}
    ...  Fail  Parameter TECHNO error ${TECHNO} not present in the configuration!

Step ${index}: Get Cells List of ${TECHNO} for UE ${ue_index}
    Log  Step ${index}: Get Cells List of ${TECHNO} for UE ${ue_index}  console=True
    ${cells_list}=  Run Keyword If  ${BTS_nb}==1
    ...  Get Cells list RF Split  TECHNO=${TECHNO}  CELLS_LIST_param=${CELLS_LIST_UE${ue_index}}
    ...  ELSE  Get Cells list  TECHNO=${TECHNO}  CELLS_LIST=${CELLS_LIST_UE${ue_index}}
    Log  ${TECHNO} cells list: ${cells_list}  console=True
    Run Keyword If  '${TECHNO}' == '${TECHNO_UE1}'
    ...  Set Test Variable  ${cells_list_UE1}  ${cells_list}
    ...  ELSE IF  '${TECHNO}' == '${TECHNO_UE2}'
    ...  Set Test Variable  ${cells_list_UE2}  ${cells_list}
    ${ue_list}=  Create List  oneSingleUe
    Set Test Variable  ${${TECHNO.lower()}_ues}  ${ue_list}
    ${timeout_defined}=  Run Keyword And Return Status  Variable Should Exist  ${timeout}
    Run Keyword If  not ${timeout_defined}  Set Test Variable  ${timeout}  0
    ${timeout_needed}=  Taf Ue Calculate call step timeout  call_duration=${CALL_DURATION}  call_type=${UE${ue_index}_call_type}
    ...  call_direction=${CALL_DIRECTION_UE${ue_index}}  cells_list=${cells_list}  techno=${TECHNO}  attenuator=NO
    ${timeout}=  Set Variable If  ${timeout_needed} > ${timeout}  ${timeout_needed}  ${timeout}

Step ${index}: Perform Simultaneous call for both UEs
    [Timeout]  ${timeout}
    Log  Step ${index}: Perform Simultaneous call for both UEs  console=True
    FOR  ${ue_index}  IN RANGE  1  3
        Run Keyword If  '${UE${ue_index}_call_type.upper()}' not in ['DATA','VOICE']
        ...  Fail  UE ${ue_index} call type not correctly defined. Expected: data/voice. Actual: ${UE${ue_index}_call_type}
        ...  ELSE  Log  UE${ue_index} will perform ${UE${ue_index}_call_type} call in accordance with TC inputs  console=True
    END
    Log  Attempting to reserve UEs to be handled by taf.ue library  console=True
    Set Test Variable  ${alias_UE1}  UE1_alias
    Set Test Variable  ${alias_UE2}  UE2_alias
    Taf Ue Require Single UE  ue_alias=${alias_UE1}  capabilities=${UE1_CAPABILITIES}  timeout=300
    Taf Ue Require Single UE  ue_alias=${alias_UE2}  capabilities=${UE2_CAPABILITIES}  timeout=300
    Log  Succesfully required both UEs with aliases: ${alias_UE1}, ${alias_UE2}  console=True
    Log  Attempting to attach UEs on expected cells  console=True
    ${wcdma_cell_id1}=  Set Variable if  '${TECHNO_UE1.lower()}'=='wcdma'  True  False
    ${wcdma_cell_id2}=  Set Variable if  '${TECHNO_UE2.lower()}'=='wcdma'  True  False
    ${UE1_IP}  ${UE1_serving_cell_id}=  Taf Ue Attach Single UE  ue_alias=${alias_UE1}  expected_serving_cell_list=${cells_list_UE1}
    ...  call_type=${UE1_call_type}  wcdma_cell_id=${wcdma_cell_id1}
    ${UE2_IP}  ${UE2_serving_cell_id}=  Taf Ue Attach Single UE  ue_alias=${alias_UE2}  expected_serving_cell_list=${cells_list_UE2}
    ...  call_type=${UE2_call_type}  wcdma_cell_id=${wcdma_cell_id2}
    Log  Succesfully attached both UEs on expected cells  console=True

    Start ${UE1_call_type} call on UE 1
    Start ${UE2_call_type} call on UE 2
    Await ${UE1_call_type} call finish on UE 1
    Await ${UE2_call_type} call finish on UE 2
    Stop and check ${UE1_call_type} call on UE 1
    Stop and check ${UE2_call_type} call on UE 2

    Run Keyword If  '${DETACH_UE}' == 'True'  Run Keywords
    ...  Taf Ue Detach Single UE  ue_alias=${alias_UE1}
    ...  AND  Taf Ue Detach Single UE  ue_alias=${alias_UE2}
    ...  AND  Log  Succesfully released usage of UEs  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Start ${call_type} call on UE ${ue_index}

    Run Keyword If  '${CHECK_ATTACH_ONLY}' == 'True' and '${call_type.upper()}' == 'DATA'  Run Keywords
    ...  Log  Data transfer part will be skipped on UE ${ue_index} due to CHECK_ATTACH_ONLY flag set to True!  console=True
    ...  AND  Return From Keyword

    Log  Attempting start ${call_type} call on UE ${ue_index}  console=True
    Run Keyword If  '${call_type.upper()}' == 'DATA'
    ...  Proceed to data transfer start on UE ${ue_index}
    ...  ELSE IF  '${call_type.upper()}' == 'VOICE'
    ...  Proceed to voice call start on UE ${ue_index}
    Log  Successfully started ${call_type} call on UE ${ue_index}  console=True

Proceed to data transfer start on UE ${ue_index}
    ${CALL_DIRECTION}=  Set Variable  ${CALL_DIRECTION_UE${ue_index}.lower()}
    ${PROTOCOL}=  Set Variable  ${PROTOCOL_UE${ue_index}.lower()}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    Run Keyword If  '${CALL_DIRECTION}' not in ['uplink', 'downlink', 'uplink_downlink']
    ...  Fail  Wrong call direction set ${CALL_DIRECTION}. Accepted values: uplink, downlink, uplink_downlink
    Translate Call Direction  ${CALL_DIRECTION}
    Run Keyword If  '${CALL_DIRECTION}' != 'ul_dl'
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_${CALL_DIRECTION}
    ...  call_duration=${CALL_DURATION}  call_direction=${CALL_DIRECTION}  throughput=${BANDWIDTH}  protocol=${PROTOCOL}
    ...  ELSE  Run Keywords
    ...  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_dl
    ...  call_duration=${CALL_DURATION}  call_direction=dl  throughput=${BANDWIDTH}  protocol=${PROTOCOL}
    ...  AND  Taf Ue Start Data Transfer Single UE  ue_alias=${alias_UE${ue_index}}  dt_name=data_transfer_UE_${ue_index}_ul
    ...  call_duration=${CALL_DURATION}  call_direction=ul  throughput=${BANDWIDTH}  protocol=${PROTOCOL}

Proceed to voice call start on UE ${ue_index}
    ${CALL_DURATION}=  Catenate  SEPARATOR=   ${CALL_DURATION}  s
    Taf Ue Start Voice Call Single UE  ue_alias=${alias_UE${ue_index}}  vc_name=voice_call_UE__${ue_index}
    ...  call_duration=${CALL_DURATION}  number_to_call=${UE${ue_index}_NUMBER_TO_CALL}

Await ${call_type} call finish on UE ${ue_index}

    Run Keyword If  '${CHECK_ATTACH_ONLY}' == 'True' and '${call_type.upper()}' == 'DATA'
    ...  Return From Keyword

    Log  Wait for the call operations to end on UE ${ue_index}  console=True
    Translate Call Direction  ${CALL_DIRECTION_UE${ue_index}}
    Run Keyword If  '${call_type.upper()}' == 'VOICE'  Run Keywords
    ...  Sleep  10s
    ...  AND  Taf Ue Await Voice Call Finish Single UE  vc_name=voice_call_UE__${ue_index}
    ...  AND  Log  Call operations ended successfully for UE ${ue_index}  console=True
    ...  AND  Return From Keyword
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Taf Ue Await Data Transfer Finish Single UE  dt_name=data_transfer_UE_${ue_index}_dl
    Log  Call operations ended successfully for UE ${ue_index}  console=True

Stop and check ${call_type} call on UE ${ue_index}

    Run Keyword If  '${CHECK_ATTACH_ONLY}' == 'True' and '${call_type.upper()}' == 'DATA'
    ...  Return From Keyword

    Log  Checking call results for UE ${ue_index}  console=True
    Translate Call Direction  ${CALL_DIRECTION_UE${ue_index}}
    Run Keyword If  '${call_type.upper()}' == 'VOICE'  Run Keywords
    ...  Taf Ue Stop Voice Call Single UE  vc_name=voice_call_UE__${ue_index}
    ...  AND  Log  Stop and check ${call_type} call for UE ${ue_index} finished succesfully! Please check execution logs for more details!
    ...  console=True
    ...  AND  Return From Keyword
    Run Keyword If  'dl' in '${CALL_DIRECTION}'  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_dl
    ...  tput_min=${downlink_MIN_TPUT_UE${ue_index}}  tput_max=${downlink_MAX_TPUT_UE${ue_index}}
    Run Keyword If  'ul' in '${CALL_DIRECTION}'  Run Keyword  Taf Ue Verify Average Throughput Single UE  dt_name=data_transfer_UE_${ue_index}_ul
    ...  tput_min=${uplink_MIN_TPUT_UE${ue_index}}  tput_max=${uplink_MAX_TPUT_UE${ue_index}}
    Log  Stop and check ${call_type} call for UE ${ue_index} finished succesfully! Please check execution logs for more details!  console=True

Translate Call Direction
    [Arguments]  ${direction}
    Run Keyword If  '${direction}' == 'uplink'  Set Test Variable  ${CALL_DIRECTION}  ul
    Run Keyword If  '${direction}' == 'downlink'  Set Test Variable  ${CALL_DIRECTION}  dl
    Run Keyword If  '${direction}' == 'uplink_downlink'  Set Test Variable  ${CALL_DIRECTION}  ul_dl

Get Cells list RF Split
    [Arguments]   ${TECHNO}  ${CELLS_LIST_param}
    ${get_bts_cells_list}=  Set Variable If  '${CELLS_LIST_param}' == 'DEFAULT'  ${True}  ${False}
    ${cells_list}=  Run Keyword If  '${CELLS_LIST_param}' != 'DEFAULT'  Split String  ${CELLS_LIST_param}
    Run Keyword If  not ${get_bts_cells_list}  Return From Keyword  ${CELLS_LIST_param}
    ${SBTS_LTE_cell_ids}=  Get Ids For All  LNCEL  alias=${alias_local}
    ${SBTS_WCDMA_cell_ids}=  Get Ids For All  WNCEL  alias=${alias_local}
    ${SBTS_GSM_cell_ids}=  Get Ids For All  GNCEL  alias=${alias_local}
    ${cells_list}=  Run Keyword If  '${TECHNO}'=='SBTS_LTE' and not ${SBTS_LTE_cell_ids}
    ...  Fail  TECHNO=${TEHNO} but no LTE cells present in this RF Split Config!
    ...  ELSE IF  '${TECHNO}'=='SBTS_LTE'  Get LTE Eutran Cell Ids from admin  ${alias_local}
    ...  ELSE  Set Variable  ${CELLS_LIST_param}
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${TECHNO}'=='WCDMA' and not ${SBTS_WCDMA_cell_ids}
    ...  Fail  TECHNO=${TEHNO} but no WCDMA cells present in this RF Split Config!
    ...  ELSE IF  '${TECHNO}'=='WCDMA'   Get SBTS Cell Ids from admin  Master  ${TECHNO}
    ...  ELSE  Set Variable  ${CELLS_LIST_param}
    ${BCF_ID}=  Run Keyword If  '${TECHNO}'=='GSM'  Get From Dictionary  ${${admin_alias.upper()}}  BCF_ID
    ${cells_list}  ${temp_cell_id_internal_id_mapping}=  Run Keyword If  '${TECHNO}'=='GSM' and not ${SBTS_GSM_cell_ids}
    ...  Fail  TECHNO=${TEHNO} but no GSM cells present in this RF Split Config!
    ...  ELSE IF  '${TECHNO}'=='GSM'  Get GSM cell IDs from BSC and admin  ${alias_local}  ${BCF_ID}
    ...  ELSE  Set Variable  ${CELLS_LIST_param}
    Sort List  ${cells_list}
    [Return]  ${cells_list}

Particular teardown
    Run Keyword If  '${DETACH_UE}' == 'True'
    ...  Run Keyword And Return Status  Taf Ue Detach All Used UEs  timeout=300

TC Setup
    Run Keyword And Continue On Failure  Common Test Setup  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown

