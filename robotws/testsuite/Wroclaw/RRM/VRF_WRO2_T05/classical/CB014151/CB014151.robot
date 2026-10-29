*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library     ute_ue
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # connect to coam kw
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB014151/resources/keyword.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical//CB010659/keywords.robot  #Update Software If Necessary

*** Variables ***
${tput_DL_bandwith}     500 Mbits/sec
${tput_deviation}       20%
${tput_duration}        120s
${Packet_Size}          1200
@{cells_nsa_41_11}    23   24
@{cell_751_sdl}    21    22
${RED}    "\\033[31m"
${resource_path}      ${CURDIR}${/}resources

*** Keywords ***
CB014151-A#B6_Multiple_candidate_SDL_SCells_(2_candidates)
    ${red}=  Evaluate  ${RED}
    Set Test Variable  ${red}
    Log to console  ${red}Please make sure if UE_3 is in NSA mode. *#*#3646633#*#* and change NrConfiruge NetworkSelection
    ########
    #UEs types that support provided keyword: ['MtkUe', 'MediaTekUe']
    # Change deployment mode  UE_3  NSA
    #########
    Load scf for NR    ${resource_path}    SCFs    CB014151_A.xml  verify_cells_on_air=False
    Update Software If Necessary
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set attenuation and check   lines=@{cells_nsa_41_11}    value=0
    Set attenuation and check   lines=@{cell_751_sdl}    value=0
    Set test variable  ${test_name}  CB014151-A
    Prepare and start new DCAP    dcap_host=10.44.180.37    bts_mplane=10.44.137.26
    sleep  15s
    Attach Ue  UE_3
    Turn Mobile Data On  UE_3
    sleep  10s
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}  protocol=udp  packet_size=${Packet_Size}
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Await Data Transfer Finish                 DT_DL_SA
    Detach Ue  UE_3
    Verify physCellId in sCellTeoAddModList  directory_path=${OUTPUT_DIR}/DCAPs/${test_name}
    Stop syslog collection


CB014151-B#B5A1_SCell_release_due_to_SCell_RLQ_with_sCellExcludelistTimerFr1_disabled
    ${red}=  Evaluate  ${RED}
    Set Test Variable  ${red}
    Log to console  ${red}Please make sure if UE_3 is in NSA mode. *#*#3646633#*#* and change NrConfiruge NetworkSelection
    ########
    #UEs types that support provided keyword: ['MtkUe', 'MediaTekUe']
    # Change deployment mode  UE_3  NSA
    #########
    Load scf for NR    ${resource_path}    SCFs    CB014151_B.xml  verify_cells_on_air=False
    Update Software If Necessary
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set attenuation and check   lines=@{cells_nsa_41_11}    value=0
    Set attenuation and check   lines=@{cell_751_sdl}    value=0
    Set test variable  ${test_name}  CB014151-B
    Prepare and start new DCAP    dcap_host=10.44.180.37    bts_mplane=10.44.137.26
    sleep  15s
    Attach Ue  UE_3
    Turn Mobile Data On  UE_3
    sleep  10s
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}  protocol=udp  packet_size=${Packet_Size}
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA
    Set attenuation and check   lines=@{cell_751_sdl}    value=90
    sleep  5s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Await Data Transfer Finish                 DT_DL_SA
    Detach Ue  UE_3
    Verify sCellInactiveReason RLQ  directory_path=${OUTPUT_DIR}/DCAPs/${test_name}
    # Stop syslog collection

CB014151-C#B2_PSCell_Change_not_possible_(A1_triggered)
    ${red}=  Evaluate  ${RED}
    Set Test Variable  ${red}
    Log to console  ${red}Please make sure if UE_3 is in NSA mode. *#*#3646633#*#* and change NrConfiruge NetworkSelection
    ########
    #UEs types that support provided keyword: ['MtkUe', 'MediaTekUe']
    # Change deployment mode  UE_3  NSA
    #########
    Load scf for NR    ${resource_path}    SCFs    CB014151_C.xml  verify_cells_on_air=False
    Update Software If Necessary
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set attenuation and check   lines=@{cells_nsa_41_11}    value=0
    Set attenuation and check   lines=@{cell_751_sdl}    value=0
    Set test variable  ${test_name}  CB014151-C
    Prepare and start new DCAP    dcap_host=10.44.180.37    bts_mplane=10.44.137.26
    sleep  15s
    Attach Ue  UE_3
    Turn Mobile Data On  UE_3
    sleep  10s
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}  protocol=udp  packet_size=${Packet_Size}
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA
    sleep  10s
    Set attenuation and check   lines=@{cells_nsa_41_11}    value=90
    sleep  5s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Await Data Transfer Finish                 DT_DL_SA
    Detach Ue  UE_3
    Verify UE sends Measurement Report for SCell Addition A1 event   directory_path=${OUTPUT_DIR}/DCAPs/${test_name}
    Check UEContextModificationRequired RLF    directory_path=${OUTPUT_DIR}/DCAPs/${test_name}
