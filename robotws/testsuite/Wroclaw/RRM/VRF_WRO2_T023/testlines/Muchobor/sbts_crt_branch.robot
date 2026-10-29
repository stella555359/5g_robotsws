*** Settings ***
Documentation
...   contact: Oleksandr Kulieshov

Library     taf.config.scf
Library     taf.sw.scout  WITH NAME  scout
Library     taf.sw.reporting_portal
Resource    ../../feature_resources/AAFIA/RRM__Guardband_NB-IoT_cell_handling_block_unblock.robot
Resource    ../../feature_resources/AAFIA/RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition.robot
Resource    ../../feature_resources/AAFIA/RRM__LTE_data_transfer_switching_TM4_TM9.robot
Resource    ../../feature_resources/AAFIA/RRM__Configuration_change_sector_type_NBIoT_used__LTE4852_LTE4529_CB007256.robot
Resource    ../../feature_resources/DEV/DEV__Emil_env_preparation.robot
Resource    ../../resources/attenuator.robot

Suite Setup  Set CRT Suite Variables

*** Keywords ***
Set CRT Suite Variables
    Set Suite Variable  ${LTE_CELL_ID}                  201
    Set Suite Variable  ${SINGLE_SECTOR}                False
    Set Suite Variable  ${SCOUT_TL_NAME}                7_16_UTE5GCLOUDU005
    Set Suite Variable  ${UE_SERIAL_PORT}               40
    Set Suite Variable  ${AT_SCRIPT_PATH}               C:/Users/sranwro2/Desktop/at_send_command.py
    Set Suite Variable  ${CLOUD}                        False
    ${ftp_iot}=    Create Dictionary    IP=10.44.184.246    username=syslab    password=Pass4System!
    Set Suite Variable  ${FTP_IOT}    ${ftp_iot}
    ${pc_iot}=    Create Dictionary    IP=10.44.72.47    username=sranwro2    password=Ru1eTheAir!2
    Set Suite Variable  ${PC_IOT}    ${pc_iot}
    Set Suite Variable  ${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUDU005/ta_ue_config.yaml
    Set Suite Variable  ${VIRTUALENV_DIR}    /home/ute/test_repo

Attenuator Setup
    Log  \n== Attenuator Setup ==  console=True
    Load Attenuation Config And Require Attenuator Setup  ${ABSTRACT_LIB_CONFIG}

Attenuator Teardown
    Log  \n== Attenuator Teardown ==  console=True
    Set Attenuation For All Cells  100%

Check Sector Type
    [Documentation]
    ...  KW used to check if sector type for specified LTE cell is the same as expected.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to check if sector type for specified LTE cell is the same as expected.
    ...  It returns True if the sector is correct and False if it is incorrect.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                     |
    ...  +========================+======+=================================================================+
    ...  | parsed_scf             | Yes  | SCF parsed with 'XML.Parse XML'.                                |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | sector_type            | Yes  | Sector Type for mMimo. Possible values: 'Single Sector',        |
    ...  |                        |      | 'Dual Sector'.                                                  |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | lncel_id               | Yes  | ID of LTE cell used for sector type checking.                   |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${_}  ${parsed_scf} =  Save And Parse SCF  SCF1
    ...     Check Sector Type  ${parsed_scf}  Single Sector  1

    [Arguments]  ${parsed_scf}  ${sector_type}  ${lncel_id}

    ${sector_string} =  Set Variable If  "${sector_type}" == "Single Sector"
    ...  SingleSectorBFProf\\(0 degree\\)  DualSectorBFProf\\([-+]30 degree\\)
    ${correct_sector_type} =  Run Keyword And Return Status  Check Element In SCF  ${parsed_scf}  LNCEL_FDD  LNCEL-${lncel_id}/
        ...  /p[@name='mMimoHorizontalSectorBFProf']  <p name="mMimoHorizontalSectorBFProf">${sector_string}</p>
        ...  is_regexp=True

    [Return]  ${correct_sector_type}


Recommission To Single Sector
    [Documentation]
    ...  KW used to perform recommissioning to single sector.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW used to perform recommissioning to single sector. It sets glabal test suite
    ...  variable ${SINGLE_SECTOR} to True. It also returns path to delta json
    ...  which can revert changes made by this KW.
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                     |
    ...  +========================+======+=================================================================+
    ...  | scf_path               | Yes  | Absolute path to SCF file.                                      |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | additional_changes     | Yes  | List of additional changes needed in delta.                     |
    ...  |                        |      | Syntax should be the same as for perform_scf_modification       |
    ...  |                        |      | from taf.config.scf library. Default value: @{EMPTY}            |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     ${_}  ${parsed_scf} =  Save And Parse SCF  SCF1
    ...     Check Sector Type  ${parsed_scf}  Single Sector  1

    [Arguments]  ${scf_path}  ${additional_changes}=@{EMPTY}

    Log  Creating delta for recommissioning...  console=True
    ${lnbts_id} =  Get BTS ID From ADMIN
    Load SCF  ${scf_path}
    Remove MO With Descendant MOs  MRBTS-${lnbts_id}/LNBTS-${lnbts_id}/LNCEL-204
    Remove MO With Descendant MOs  MRBTS-${lnbts_id}/LNBTS-${lnbts_id}/LNCEL-4
    Remove MO With Descendant MOs  MRBTS-${lnbts_id}/LNBTS-${lnbts_id}/LNCEL-14
    Remove MO With Descendant MOs  MRBTS-${lnbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-4
    Remove MO With Descendant MOs  MRBTS-${lnbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-14
    Remove MO With Descendant MOs  MRBTS-${lnbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-204
    ${modifications_list} =  Create List  modify:LNCEL-1/LNCEL_FDD-0:mMimoHorizontalSectorBFProf=SingleSectorBFProf(0 degree)
    ...  modify:LNCEL-11/LNCEL_FDD-0:mMimoHorizontalSectorBFProf=SingleSectorBFProf(0 degree)
    Run Keyword If  '${additional_changes}' != ''  Append To List  ${modifications_list}  @{additional_changes}
    Perform SCF Modification  ${modifications_list}
    Save SCF  ${LOG_PATH}/misc_logs/modified_SCF_testsuite.xml
    ${delta_path}  ${delta_revert} =  Calculate Delta Between SCFs
    ...  ${scf_path}
    ...  ${LOG_PATH}/misc_logs/modified_SCF_testsuite.xml
    ...  single_sector_reconfiguration

    Log  Performing delta recommissioning...  console=True
    Set Suite Variable  ${SINGLE_SECTOR}  True
    Perform Delta Recommissioning  ${delta_path}
    Wait Until Keyword Succeeds  1m  10s  _verify bts states for iwk test helper

    [Return]  ${delta_revert}


Revert To Previous SCF
    [Documentation]
    ...  KW used to revert changes made to SCF based on passed delta json file.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  KW
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                     |
    ...  +========================+======+=================================================================+
    ...  | delta_revert           | Yes  | Absolute path to delta reverting SCF modifications.             |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Revert To Previous SCF  ${LOG_PATH}/misc_logs/delta_revert.json

    [Arguments]  ${delta_revert}

    Log  Performing delta recommissioning...  console=True
    Perform Delta Recommissioning  ${delta_revert}
    Wait Until Keyword Succeeds  1m  10s  _verify bts states for iwk test helper
    Log  Revert finished.  console=True


*** Test Cases ***

RRM__Guardband_NB-IoT_cell_handling_block_unblock_Dual_Sector
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation  TM4_TM9_LTE_CELL_1  0dB
    ...  AND  Set Library Search Order  RRM__Guardband_NB-IoT_cell_handling_block_unblock  admin
    ...  AND  Set Test Variable  ${NB_IOT_CELL_ID_HEX}  001F7BC9
    ...  AND  Set Test Variable  ${NB_IOT_GLOBAL_CELL_ID}  201
    ...  AND  Set Test Variable  ${LTE_CELL_ID}  1
    ...  AND  Set Test Variable  ${DUAL_OR_SINGLE}  Dual Sector
    ...  AND  Set Test Variable  ${TIME_FOR_IDLE}  10
    ...  AND  Set Test Variable  ${LOOPS_COUNT}  4
    ...  AND  TC Setup

    ${lnbts_id} =  Get BTS ID From ADMIN
    Set Test Variable  ${QRX_CHANGED}  True
    Perform Parameter Recommissioning    MRBTS-${lnbts_id}/LNBTS-${lnbts_id}/LNCEL-204/SIB-0    qrxlevmin   update  -44
    Wait Until Keyword Succeeds  30s  5s  _verify bts states for iwk test helper

    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_testsuite
    ${single_sector} =  Check Sector Type  ${parsed_scf}  Dual Sector  lncel_id=1
    Should Be True  ${single_sector}  msg=Incorrect sector type. Expected dual sector.
    Run keyword  TC__RRM__Guardband_NB-IoT_cell_handling_block_unblock

    [Teardown]  Run Keywords
    ...  Run Keyword If  ${QRX_CHANGED}  Perform Parameter Recommissioning  MRBTS-${lnbts_id}/LNBTS-${lnbts_id}/LNCEL-204/SIB-0
    ...  qrxlevmin  update  -148
    ...  AND  Run Keyword If  ${QRX_CHANGED} and not ${CELL_BLOCKED}  Wait Until Keyword Succeeds  30s  5s
    ...  _verify bts states for iwk test helper
    ...  AND  TC Teardown
    ...  AND  Map Testcase  [1][1.0] RRM__Guardband_NB-IoT_cell_handling_block_unblock__LTE4852_LTE4529


RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition__LTE4852_LTE4529
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation  TM4_TM9_LTE_CELL_1  0dB
    ...  AND  Set Library Search Order  RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition  admin
    ...  AND  Set Test Variable  ${EXPECTED_M8204C0}    900
    ...  AND  Set Test Variable  ${M8204C3_MIN_VALUE}    2450000
    ...  AND  Set Test Variable  ${M8204C6_MIN_VALUE}    122500
    ...  AND  Set Test Variable  ${EXPECTED_M8204C7}    2700000
    ...  AND  TC Setup
    Run keyword  TC__RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition
    [Teardown]  TC Teardown


RRM__Guardband_NB-IoT_cell_handling_block_unblock_Single_Sector
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation  TM4_TM9_LTE_CELL_1  0dB
    ...  AND  Set Library Search Order  RRM__Guardband_NB-IoT_cell_handling_block_unblock  admin
    ...  AND  Set Test Variable  ${NB_IOT_CELL_ID_HEX}  001F7BC9
    ...  AND  Set Test Variable  ${NB_IOT_GLOBAL_CELL_ID}  201
    ...  AND  Set Test Variable  ${LTE_CELL_ID}  1
    ...  AND  Set Test Variable  ${DUAL_OR_SINGLE}  Single Sector
    ...  AND  Set Test Variable  ${TIME_FOR_IDLE}  10
    ...  AND  Set Test Variable  ${LOOPS_COUNT}  4
    ...  AND  Set Test Variable  ${REVERT_CHANGES}  False
    ...  AND  TC Setup

    ${scf_path}  ${parsed_scf} =  Save And Parse SCF  SCF_testsuite
    ${single_sector} =  Check Sector Type  ${parsed_scf}  Single Sector  lncel_id=1
    IF  not ${single_sector}
        ${delta_revert} =  Recommission To Single Sector  ${scf_path}
    END
    ${single_sector} =  Run Keyword If  ${single_sector}  Set Variable  ${single_sector}
    ...  ELSE  Check Sector Type  ${parsed_scf}  Single Sector  lncel_id=1
    Should Be True  ${single_sector}  msg=Incorrect sector type. Expected single sector.
    Run keyword  TC__RRM__Guardband_NB-IoT_cell_handling_block_unblock

    [Teardown]  Run Keywords  Run Keyword If  ${SINGLE_SECTOR} and ${REVERT_CHANGES}  Revert To Previous SCF  ${delta_revert}
    ...  AND  TC Teardown
    ...  AND  Map Testcase  [1][1.0] RRM__Guardband_NB-IoT_cell_handling_block_unblock__LTE4852_CB007256


RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition__LTE4852_CB007256
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Attenuator Setup
    ...  AND  Set Attenuation  TM4_TM9_LTE_CELL_1  0dB
    ...  AND  Set Library Search Order  RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition  admin
    ...  AND  Set Test Variable  ${EXPECTED_M8204C0}    900
    ...  AND  Set Test Variable  ${M8204C3_MIN_VALUE}    2450000
    ...  AND  Set Test Variable  ${M8204C6_MIN_VALUE}    122500
    ...  AND  Set Test Variable  ${EXPECTED_M8204C7}    2700000
    ...  AND  TC Setup
    Run keyword  TC__RRM__Guardband_NB-IoT__cell_reconfiguration_non_anchor_carrier_addition
    [Teardown]  TC Teardown


RRM__LTE_data_transfer_switching_TM4_TM9_Dual_Sector
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  RRM__LTE_data_transfer_switching_TM4_TM9  admin
    ...  AND  Import Variables    ${ABSTRACT_LIB_CONFIG}
    ...  AND  Attenuator Setup
    ...  AND  Set Test Variable  ${LTE_CELL_ID1}       1
    ...  AND  Set Test Variable  ${DUAL_OR_SINGLE}     Dual Sector
    ...  AND  Set Test Variable  ${LTE_UE_CAPABILITY}  LTE_LOCKED
    ...  AND  Set Test Variable  ${MNC}  01
    ...  AND  Set Test Variable  ${MCC}  001
    ...  AND  Set Test Variable  ${MIN_ATTENUATION}  10
    ...  AND  Set Test Variable  ${MAX_ATTENUATION}  55
    ...  AND  Set Test Variable  ${LTE_CELL_ID2}     4
    ...  AND  Set Test Variable  ${NB_IOT_GLOBAL_CELL_ID}  204
    ...  AND  Set Test Variable  ${MAX_DCAP_LOGS_DELAY}  120
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}   15
    ...  AND  Set Test Variable  ${WINDOWS_SACK_PARENT_PATH}  C:/Users/sranwro2/Documents/EmilSacks
    ...  AND  Set Test Variable  ${WINDOWS_PATH_TO_EMIL_EXE}  C:/Program Files/Emil/EMIL
    ...  AND  Set Test Variable  ${WINDOWS_TEMP_LOGS_DIR}     C:/temp/dcap_logs
    ...  AND  Set Test Variable  ${INSTALL_EMIL}     False
    ...  AND  Set Test Variable  ${DOWNLOAD_SACK}    True
    ...  AND  Set Test Variable  ${UPLOAD_SACK_TO_WIN_PC}  True
    ...  AND  Set Test Variable  ${SACK_DIR_ON_LINUX}      /tmp/Sacks
    ...  AND  Set Test Variable  ${USER_SW_VERSION}        ${EMPTY}
    ...  AND  Set Test Variable  ${SACK_DIR_ON_WINDOWS}    /cygdrive/c/Users/sranwro2/Documents/EmilSacks
    ...  AND  Set Test Variable  ${CREATE_CSV}             False
    ...  AND  Set Test Variable  ${PERFORM_COMMISSIONING}  True
    ...  AND  Set Test Variable  ${APN}                    n26wro
    ...  AND  Set Test Variable  ${SCF_PATH}  /home/ute/testline_configuration/7_16_UTE5GCLOUDU005/AAFIA_SCFs/branch/DS_TM4_TM9.xml
    ...  AND  TC Setup

    ${lnbts_id} =  Get BTS ID From ADMIN
    Run Keyword If  ${PERFORM_COMMISSIONING}  Run Keywords  Perform Commissioning  ${lnbts_id}  ${SCF_PATH}  timeout=600
    ...  AND  Wait Until Keyword Succeeds  5min  10s  _verify bts states for iwk test helper
    ${_}  ${parsed_scf} =  Save And Parse SCF  SCF_testsuite
    ${dual_sector} =  Check Sector Type  ${parsed_scf}  Dual Sector  lncel_id=1
    Should Be True  ${dual_sector}  msg=Incorrect sector type. Expected dual sector.
    TC__DEV__Emil_env_preparation
    TC__RRM__LTE_data_transfer_switching_TM4_TM9

    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Map Testcase  [1][1.0] RRM__LTE_data_transfer_switching_TM4_TM9__LTE5151_CB007256


RRM__LTE_data_transfer_switching_TM4_TM9_Single_Sector
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  RRM__LTE_data_transfer_switching_TM4_TM9  admin
    ...  AND  Attenuator Setup
    ...  AND  Set Test Variable  ${LTE_CELL_ID1}       1
    ...  AND  Set Test Variable  ${DUAL_OR_SINGLE}     Single Sector
    ...  AND  Set Test Variable  ${LTE_UE_CAPABILITY}  LTE_LOCKED
    ...  AND  Set Test Variable  ${MNC}  01
    ...  AND  Set Test Variable  ${MCC}  001
    ...  AND  Set Test Variable  ${MIN_ATTENUATION}  0
    ...  AND  Set Test Variable  ${MAX_ATTENUATION}  50
    ...  AND  Set Test Variable  ${LTE_CELL_ID2}     ${NONE}
    ...  AND  Set Test Variable  ${NB_IOT_GLOBAL_CELL_ID}  ${NONE}
    ...  AND  Set Test Variable  ${MAX_DCAP_LOGS_DELAY}  120
    ...  AND  Set Test Variable  ${DCAP_IP}          10.42.239.116
    ...  AND  Set Test Variable  ${DCAP_PORT}        443
    ...  AND  Set Test Variable  ${COUNTER_PERIOD}   15
    ...  AND  Set Test Variable  ${WINDOWS_SACK_PARENT_PATH}  C:/Users/sranwro2/Documents/EmilSacks
    ...  AND  Set Test Variable  ${WINDOWS_PATH_TO_EMIL_EXE}  C:/Program Files/Emil/EMIL
    ...  AND  Set Test Variable  ${WINDOWS_TEMP_LOGS_DIR}     C:/temp/dcap_logs
    ...  AND  Set Test Variable  ${INSTALL_EMIL}     False
    ...  AND  Set Test Variable  ${DOWNLOAD_SACK}    True
    ...  AND  Set Test Variable  ${UPLOAD_SACK_TO_WIN_PC}  True
    ...  AND  Set Test Variable  ${SACK_DIR_ON_LINUX}      /tmp/Sacks
    ...  AND  Set Test Variable  ${USER_SW_VERSION}        ${EMPTY}
    ...  AND  Set Test Variable  ${SACK_DIR_ON_WINDOWS}    /cygdrive/c/Users/sranwro2/Documents/EmilSacks
    ...  AND  Set Test Variable  ${CREATE_CSV}             False
    ...  AND  Set Test Variable  ${PERFORM_COMMISSIONING}  True
    ...  AND  Set Test Variable  ${SCF_PATH}  /home/ute/testline_configuration/7_16_UTE5GCLOUDU005/AAFIA_SCFs/branch/SS_TM4_TM9.xml
    ...  AND  TC Setup

    ${lnbts_id} =  Get BTS ID From ADMIN
    Run Keyword If  ${PERFORM_COMMISSIONING}  Run Keywords  Perform Commissioning  ${lnbts_id}  ${SCF_PATH}  timeout=600
    ...  AND  Wait Until Keyword Succeeds  5min  10s  _verify bts states for iwk test helper
    ${scf_path}  ${parsed_scf} =  Save And Parse SCF  SCF_testsuite
    ${single_sector} =  Check Sector Type  ${parsed_scf}  Single Sector  lncel_id=1
    Should Be True  ${single_sector}  msg=Incorrect sector type. Expected single sector.
    TC__DEV__Emil_env_preparation
    TC__RRM__LTE_data_transfer_switching_TM4_TM9

    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Map Testcase  [1][1.0] RRM__LTE_data_transfer_switching_TM4_TM9__LTE5151_CB007256


RRM__Configuration_change_sector_type_NBIoT_used__LTE4852_LTE4529_CB007256
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Library Search Order  RRM__Configuration_change_sector_type_NBIoT_used__LTE4852_LTE4529_CB007256  admin
    ...  AND  Set Test Variable  ${DUAL_SECTOR_WITH_NBIOT_SCF_PATH}
    ...  /home/ute/testline_configuration/7_16_UTE5GCLOUDU005/AAFIA_SCFs/branch/1_DS_NB_LTE4852_LTE4529.xml
    ...  AND  Set Test Variable  ${SINGLE_SECTOR_WITH_NBIOT_SCF_PATH}
    ...  /home/ute/testline_configuration/7_16_UTE5GCLOUDU005/AAFIA_SCFs/branch/3_SS_NB_LTE4852_CB007256.xml
    ...  AND  Set Test Variable  @{CHANGED_SECTOR_LNCEL_LIST}  1  11
    ...  AND  Set Test Variable  @{DUAL_SECTOR_NBIOT_LNCEL_LIST}  201  204
    ...  AND  Set Test Variable  @{SINGLE_SECTOR_NBIOT_LNCEL_LIST}  201
    ...  AND  Set Test Variable  ${REVERT_TO_ORIGNAL}  True
    ...  AND  Set Test Variable  ${LOOPS_COUNT}  3
    ...  AND  TC Setup
    Run keyword  TC__${TEST_NAME}
    [Teardown]  Run Keywords  TC Teardown
    ...  AND  Map Testcase  [1][1.0] ${TEST_NAME}
