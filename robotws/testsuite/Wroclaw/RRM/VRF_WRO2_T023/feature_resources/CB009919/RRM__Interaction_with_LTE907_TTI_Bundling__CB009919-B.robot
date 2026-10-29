*** Settings ***
Documentation
...  contact: Szymon Startek

Library           ute_ue
Library           taf.converters.ttitracer
Library           taf.collectors.ttitrace_4g    WITH NAME  ttitrace_4g
Library           CB009919_keywords.py
Resource          ../../resources/ca_IWK.robot
Resource          ../../resources/ca_INTER_RAT.robot
Variables         testsuite/Wroclaw/RRM/VRF_WRO2_T023/testlines/TMO/resources/scenario.py


*** Variables ***
${GLOBAL_CELL_ID_LTE}                                  # Global cell ID of the tested LTE cell
${CAPABILITY_LTE_UE}          LTE_TRINITY              # Capability of UE used to LTE UL call
${ATTENUATION_LEVEL}                                   # Initial level of attenuation to invoke bundling mode
${SCF_PATH}                                            # Path to the SCF with initial config prepared
${REVERT_CHANGES}             True                     # Determines whether the initial configuration will to be restored
${ATTENUATED_CELL}                                     # Name of attenuated cell taken from ${TA_ATTENUATOR_CONFIG}
${LOCAL_CONNECTION}                                    # Alias of BTS. Value can be eNB or gNB
${CELL1_PATH}                                          # Path to qrxlevmin of cell used in the test
${CELL1_QRXLEVMIN}                                     # qrxlevmin to be set on cell used in the test
${CELL2_PATH}                                          # Path to qrxlevmin of cell not used in the test
${CELL2_QRXLEVMIN}                                     # qrxlevmin to be set on cell not used in the test


*** Keywords ***
TC__RRM__Interaction_with_LTE907_TTI_Bundling__CB009919-B
    Set Tags    CA-INTER_RAT    AUTHOR-tomasz.stawowczyk@nokia.com    OWNER-dawid.kurowski@nokia.com
    ...         MAINTAINER-tomasz.stawowczyk@nokia.com    PHASE-CRT   SW-SBTS23R3    FEATURE-CB009919    GROUP_IN_CHARGE-WRO_4_Vrf


    Preconditions
    Step 1: Start LTE UL Call
    Step 2: Set Attenuation And Check Bundling Mode
    Step 3: Turn Off Attenuation And Check Results


Preconditions
    Log   === Start Preconditions ===    console=True
    Set Test Variable  ${COMMISIONING_PERFORMED}  False
    ${lte_id}  Get BTS ID From ADMIN  alias=${LOCAL_CONNECTION}
    Set Test Variable  ${LTE_ID}  ${lte_id}
    Initial Config
    Set qrxlevmin Level  ${CELL1_PATH}  ${CELL1_QRXLEVMIN}  LTE
    Set qrxlevmin Level  ${CELL2_PATH}  ${CELL2_QRXLEVMIN}  LTE
    Check Parameters
    Require UE  LTE_UE  capabilities=${CAPABILITY_LTE_UE}
    Set Attenuation For All Cells  100%
    Attenuation Setting  0dB
    ${sw_version}=  Get SW Version  alias=${LOCAL_CONNECTION}
    Set Test Variable  ${SW_VERSION}  ${sw_version}
    Log  === Preconditions Finished ===  console=True


Step 1: Start LTE UL Call
    Log  ==== Step 1: Start LTE UL Call ====  console=True
    Log  = Prepare UE For Data Transfer =  console=True
    Prepare UE For Data Transfer  LTE_UE  ${GLOBAL_CELL_ID_LTE}  connection=${LOCAL_CONNECTION}
    Start Data Transfer  LTE_UL  LTE_UE  ul  duration=300s  protocol=tcp  buffer=32M  max_segment_size=1400
    Sleep  10s  reason=for call stabilization


Step 2: Set Attenuation And Check Bundling Mode
    Log  ==== Step 2: Set Attenuation And Check Bundling Mode ====  console=True
    ${current_attenuation}  Set Variable  ${ATTENUATION_LEVEL}
    FOR  ${loop_iteration}  IN RANGE  10
        Attenuation Setting  ${current_attenuation}
        Sleep  5s  reason=Waiting till UE adjust to radio conditions
        Collect TTI Traces  ${loop_iteration}
        ${bundling_mode_enabled}  Run Keyword And Return Status  Check Bundling Mode In TTI Traces  ${loop_iteration}
        Exit For Loop If  ${bundling_mode_enabled}
        ${current_attenuation}  Evaluate  str(int(${current_attenuation}[:-2]) + 1) + 'dB'
    END
    Should Be True  ${bundling_mode_enabled}  msg=UE does not reach bundling mode!


Step 3: Turn Off Attenuation And Check Results
    Log  ==== Step 3: Turn Off Attenuation And Check Results ====  console=True
    Attenuation Setting  0dB
    Sleep  5s  reason=To ensure proper prints in TTI Trace log
    Collect TTI Traces  Bundling_disabled
    Check Disabled Bundling Mode In TTI Traces  Bundling_disabled


Initial Config
    Log  === Perform Commissioning SCF With Required Parameters ===  console=True
    Set Test Variable  ${COMMISIONING_PERFORMED}  True
    Get Current Scf File  ${LOG_PATH}  scf_original.xml  connection=${LOCAL_CONNECTION}
    Perform Commissioning  ${LTE_ID}  ${SCF_PATH}  alias=${LOCAL_CONNECTION}  timeout=600
    Wait Until Keyword Succeeds  10m  1m  _Verify Bts States For Iwk Test Helper  alias=${LOCAL_CONNECTION}

    Start Wireshark Log Collection For IWK Test
    ...  options=-i any host ${GNB_OAM_IP} and not udp port 2152 -s 0 -W 1
    ...  replace_enb=False  replace_gnb=False


Attenuation Setting
    [Arguments]  ${attenuation_input}
    Log To Console   === Attenuation Setting ===
    Set Attenuation  ${ATTENUATED_CELL}  ${attenuation_input}
    Sleep  2  reason=Time for setup attenuation
    ${attenuation_level}  Read Attenuation  ${ATTENUATED_CELL}
    Sleep  2  reason=Time for read attenuation
    Log To Console    ${attenuation_level}


Collect TTI Traces
    [Arguments]  ${loop_iteration}
    Log  ==== Collecting TTI Traces ====  console=True
    Check Data Transfer Is Alive  LTE_UL
    Collect 4G TTI Trace  cell_id=${GLOBAL_CELL_ID_LTE}
    ...             trace_time=10 seconds
    ...             output_path=${LOG_PATH}/trace/${loop_iteration}
    Parse 4G TTI Trace  ${SW_VERSION}  UL  dict_path=${LOG_PATH}/trace/${loop_iteration}/ttitrace  duplex=tdd


Check Bundling Mode In TTI Traces
    [Arguments]  ${loop_iteration}
    Log  ==== Checking Bundling Mode In TTI Traces ====  console=True
    ${list_of_bundlingmode}  Get Column With Name  ${LOG_PATH}/trace/${loop_iteration}/ttitrace/lte_tti_UL.txt  ETtiTraceUlParUe_bundlingMode
    ${expected_values_bundlingMode}  Create List  NormalTti  FinalTti
    List Should Contain Sub List  ${list_of_bundlingmode}  ${expected_values_bundlingMode}
    ...  msg=bundlingMode column does not contain values NormalTti or FinalTti!
    ${list_of_bundleindex}  Get Column With Name  ${LOG_PATH}/trace/${loop_iteration}/ttitrace/lte_tti_UL.txt  ETtiTraceUlParUe_bundleIndex
    ${expected_values_bundleIndex}  Create List  1st TX  2nd TX  3rd TX  4th TX
    List Should Contain Sub List  ${list_of_bundleindex}  ${expected_values_bundleIndex}
    ...  msg=bundleIndex column does not contain values (1st TX or 2nd TX or 3rd TX or 4th TX)!


Check Disabled Bundling Mode In TTI Traces
    [Arguments]  ${path_to_traces}
    Log  ==== Check Disabled Bundling Mode In TTI Traces ====  console=True
    ${list_of_bundlingmode}  Get Column With Name  ${LOG_PATH}/trace/${path_to_traces}/ttitrace/lte_tti_UL.txt  ETtiTraceUlParUe_bundlingMode
    ${counter_bundlingmode}  Get Length  ${list_of_bundlingmode}
    Should Contain X Times  ${list_of_bundlingmode}  NoBundling  ${counter_bundlingmode}
    ...  msg=bundlingMode column contains values other than NoBundling!
    ${list_of_bundleindex}  Get Column With Name  ${LOG_PATH}/trace/${path_to_traces}/ttitrace/lte_tti_UL.txt  ETtiTraceUlParUe_bundleIndex
    ${counter_bundleindex}  Get Length  ${list_of_bundleindex}
    Should Contain X Times  ${list_of_bundleindex}  1st TX  ${counter_bundleindex}
    ...  msg=bundleIndex column contains values other than 1st TX!


Check Parameters
    Log  ==== Checking Parameters In SCF ====  console=True
    ${_}  ${path_to_changed_scf} =  Save And Parse SCF  SCF_changed  alias=${LOCAL_CONNECTION}
    Check Element In SCF  ${path_to_changed_scf}  LNCEL  LNCEL-${GLOBAL_CELL_ID_LTE}  /p[@name='actTtiBundling']
    ...  <p name="actTtiBundling">true</p>  dist_name_substring=True
    Check Element In SCF  ${path_to_changed_scf}  LNCEL  LNCEL-${GLOBAL_CELL_ID_LTE}  /p[@name='ttibOperMode']
    ...  <p name="ttibOperMode">sinrBasedTtibOnOffAllowed</p>  dist_name_substring=True
    Log  ==== Validation Of Parameters Completed Successfully ====  console=True


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  start_wireshark=False


TC Teardown
    Log  === TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfer  LTE_UL
    Detach UE  LTE_UE
    Stop Wireshark Log Collection For IWK Test
    Run Keyword If  ${COMMISIONING_PERFORMED} and ${REVERT_CHANGES}  Perform Commissioning
    ...  ${LTE_ID}  ${LOG_PATH}/scf_original.xml  alias=${LOCAL_CONNECTION}  timeout=600
    Wait Until Keyword Succeeds  10m  1m  _Verify Bts States For Iwk Test Helper  alias=${LOCAL_CONNECTION}
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True  stop_wireshark=False
