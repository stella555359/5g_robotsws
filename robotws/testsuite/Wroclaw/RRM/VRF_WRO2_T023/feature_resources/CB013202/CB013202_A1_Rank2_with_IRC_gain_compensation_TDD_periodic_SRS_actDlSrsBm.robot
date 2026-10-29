*** Settings ***
Documentation
...   contact: Magdalena Swierbutowicz

Library    SSHLibrary
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    taf.config.scf
Library    ute_ue
Library    ../../resources/TTI_reader.py


*** Variables ***
${NR_UE_ALIAS_TESTER}               # UE that attaches to the test NR SA cell
${NR_UE_ALIAS_INTERFERER}           # UE that attaches to the interfering NR SA cell
${APN}                              # APN name
${NR_TESTER_CELL_ID}                # NR cell ID on which the feature is tested
${NR_INTERFERER_CELL_ID}            # NR cell ID that causes interference on the test cell


*** Keywords ***
TC__CB013202_A1_Rank2_with_IRC_gain_compensation_TDD_periodic_SRS_actDlSrsBm
    Set Tags    AUTHOR, MAINTAINER-magdalena.swierbutowicz@nokia.com    OWNER-anna.konior@nokia.com
    ...  PHASE-CRT   SW-SBTS25R3    FEATURE-CB013202_A1    GROUP_IN_CHARGE-WRO_2_Vrf

    Preconditions
    Step 1: Start UL Data Transfer On Tester UE
    Step 2: Check If RANK2 Was Reached On_Tester_UE
    Step 3: Start UL Data Transfer On Interferer UE
    Step 4: Check If RANK1 Was Reached With_Interferer_UE
    Step 5: Activate Rank Selection
    Step 6: Check If RANK2 Was Reached When_enhRankSelectIrcGain_Enabled
    Step 7: Stop Data Transfers And Detach UEs


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Test Variable  ${FEATURE_ACTIVATED}  False
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    ${global_nr_tester_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_TESTER_CELL_ID}
    Set Test Variable  ${NR_TESTER_CELL_GLOBAL_ID}  ${global_nr_tester_cell_id}
    ${global_nr_interferer_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_INTERFERER_CELL_ID}
    Set Test Variable  ${NR_INTERFERER_CELL_GLOBAL_ID}  ${global_nr_interferer_cell_id}
    Require Ue  UE_TESTER  ${NR_UE_ALIAS_TESTER}
    Require Ue  UE_INTERFERER  ${NR_UE_ALIAS_INTERFERER}
    Set Attenuation  ${CELL_ALIAS_INTERFERER}  0dB
    Set Attenuation For Tested Cell  ${CELL_TESTER_PORTS_ALIAS_WITH_ATTENUATION}
    Setup TTI Decoder
    Prepare UE For Data Transfer  UE_INTERFERER  ${NR_INTERFERER_CELL_GLOBAL_ID}  connection=gNB

    Log  = Preconditions passed =  console=True

Set Attenuation For Tested Cell
    [Arguments]    ${cell_port_alias_with_attenuation_dict}
    FOR  ${cell_port_alias}    IN    @{cell_port_alias_with_attenuation_dict.keys()}
        Set Attenuation  cell_alias=${cell_port_alias}  value=${cell_port_alias_with_attenuation_dict["${cell_port_alias}"]}
    END

Step ${index}: Start UL Data Transfer On Tester UE
    Log  \n==== Step ${index}: Start UL Data Transfer On Tester UE ====  console=True

    Prepare UE For Data Transfer  UE_TESTER  ${NR_TESTER_CELL_GLOBAL_ID}  connection=gNB
    Log  Start NR DL data transfer in cell NR-${NR_TESTER_CELL_ID} on UE.  console=True
    Start Data Transfer  DT_UL_TESTER  UE_TESTER  ul  throughput=200Mbits/sec  protocol=tcp  packet_size=1400
    ...  duration=500s  apn=${APN}
    Sleep  30s  reason=Wait for the t-put to stabilize.


Step ${index}: Check If ${rank} Was Reached ${phase}
    Log  \n==== Step ${index}: Check If ${rank} Was Reached ${phase} ====  console=True

    Check Reached Rank  ${rank}  ${phase}


Step 3: Start UL Data Transfer On Interferer UE
    Log  \n==== Step 3: Start UL Data Transfer On Interferer UE ====  console=True

    Log  Start NR DL data transfer in cell NR-${NR_INTERFERER_CELL_ID} on UE.  console=True
    Start Data Transfer  DT_UL_INTERFERER  UE_INTERFERER  ul  throughput=800Mbits/sec  protocol=tcp  packet_size=1400
    ...  duration=500s  apn=${APN}
    Sleep  30s  reason=Wait for the t-put to stabilize.


Step 5: Activate Rank Selection
    Log  \n==== Step 5: Activate Rank Selection ====  console=True

    Log  Feature activation.  console=True
    Set Test Variable  ${FEATURE_ACTIVATED}  True
    Perform Delta Recommissioning    ${CURDIR}/delta/delta_feature.json    alias=gNB
    Wait Until Keyword Succeeds  2m  30s  _verify bts states for iwk test helper  alias=gNB


Step 7: Stop Data Transfers And Detach UEs
    Log  \n==== Step 7: Stop Data Transfers And Detach UEs ====  console=True

    Stop Data Transfer  DT_UL_TESTER
    Stop Data Transfer  DT_UL_INTERFERER


Check Reached Rank
    [Arguments]    ${expected_rank}  ${file_name}
    Collect NR TTI Trace General  ${NR_TESTER_CELL_ID}  ${GNB_VM_IP}  tti_output_dir=${LOG_PATH}/trace/NR_TTI
    ...  output_filename=NR_TTI_${file_name}  release=${RELEASE_LOCAL}  collecting_time=5s
    ${list_of_rank_values}  Read Column Values
    ...  ${LOG_PATH}/trace/NR_TTI/NR_TTI_${file_name}_ul.csv  ulFdSchedData.numOfLayers
    ${total_amount} =  Get Length  ${list_of_rank_values}
    ${specific_amount} =  Count Values In List  ${list_of_rank_values}  ${expected_rank}
    ${occurence_ratio} =  Evaluate  ${specific_amount} / ${total_amount}
    ${result} =  Evaluate  ${occurence_ratio} > 0.5
    Should Be True  ${result}
    ...  msg=The number of samples with the expected number of layers ${expected_rank} is too small.
    Log  === Reached Rank Has Expected Value ===  console=True


Save Original SCF
    Log  = Save original SCF =  console=True
    ${scf_path_gnb}  ${_} =  Save And Parse SCF  SCF_gNB  alias=gNB
    Set Test Variable  ${ORIGINAL_SCF_PATH}  ${scf_path_gnb}
    Log  Saved SCF under: ${ORIGINAL_SCF_PATH}  console=True


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True
    Save Original SCF


TC Teardown
    Log  === TC Teardown ===  console=True
    Run Keyword And Ignore Error  Stop Data Transfer  DT_UL_TESTER
    Run Keyword And Ignore Error  Stop Data Transfer  DT_UL_INTERFERER
    Run Keyword And Ignore Error  Detach UE  UE_TESTER
    Run Keyword And Ignore Error  Detach UE  UE_INTERFERER
    Run Keyword If  ${FEATURE_ACTIVATED}  Perform Delta Recommissioning
    ...  ${CURDIR}/delta/delta_revert.json  connection=gNB
    Wait Until Keyword Succeeds  2m  30s  _verify bts states for iwk test helper  alias=gNB
    IWK Test Teardown  local_enb_connection=False  single_bts=True
