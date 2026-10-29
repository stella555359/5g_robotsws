*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library     ute_ue
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/cloud/CB008055/resources/keyword.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Test Setup      Run keyword
...    Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1

Test Teardown   Run Keyword
...    Detach Ue     UE_1

*** Variables ***
${tput_DL_bandwith}     500 Mbits/sec
${tput_UL_bandwith}     30 MBits/sec
${tput_deviation}       20%
${tput_duration}        120s
${Packet_Size}          1200

*** Variables ***
@{lines_251}    9    10    11    12
@{lines_711}    13   14    15    16
@{lines_713}    9    10    11    12
@{trace_profile}    controlPlane5gVdu
*** Test Cases ***
CB008055-CR-D#B4A1_A2_based_SCell_Release_for_6CC_DL_CA_FDD_PCell_and_5_FDD_SCells

    Setup attenuators
    Set attenuation and check   lines=@{lines_251}    value=0
    Set attenuation_2 and check   lines=@{lines_711}    value=0
    Set attenuation_2 and check   lines=@{lines_713}    value=0
    Set test variable  ${test_name}  CB008055-CRvDU
    Set test variable  ${test_name1}  CB008055-CRvCU
    Prepare and start new DCAP    dcap_host=10.44.180.37    bts_mplane=10.45.186.185    vdu_custom_profile=controlPlane5gVdu
    ...    password=Nokia@123
    Prepare and start new DCAP    dcap_host=10.44.180.37    bts_mplane=10.44.249.57    vcu_custom_profile=controlPlane5gVcu
    ...    password=Nokia@123  connection=vCU
    Sleep    5s
    Attach Ue     UE_1
    Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_NSA
    Check Data Transfer Is Alive               DT_UL_NSA
    Set attenuation_2 and check   lines=@{lines_711}    value=80
    Set attenuation_2 and check   lines=@{lines_713}    value=80
    Set attenuation and check   lines=@{lines_251}    value=50
    Sleep    10s
    Set attenuation_2 and check   lines=@{lines_711}    value=0
    Set attenuation_2 and check   lines=@{lines_713}    value=0
    Set attenuation and check   lines=@{lines_251}    value=0
    Sleep    10s
    Set attenuation_2 and check   lines=@{lines_711}    value=80
    Set attenuation_2 and check   lines=@{lines_713}    value=80
    Set attenuation and check   lines=@{lines_251}    value=50
    Sleep    10s
    Set attenuation_2 and check   lines=@{lines_711}    value=0
    Set attenuation_2 and check   lines=@{lines_713}    value=0
    Set attenuation and check   lines=@{lines_251}    value=0
    Sleep    10s
    Set attenuation_2 and check   lines=@{lines_711}    value=80
    Set attenuation_2 and check   lines=@{lines_713}    value=80
    Set attenuation and check   lines=@{lines_251}    value=50
    Sleep    10s
    Set attenuation_2 and check   lines=@{lines_711}    value=0
    Set attenuation_2 and check   lines=@{lines_713}    value=0
    Set attenuation and check   lines=@{lines_251}    value=0
    Sleep    10s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Stop new DCAP trace and download logs json    subdir=${test_name1}  connection=vCU
    Verify messages for CB008055-CR  directory_path=${OUTPUT_DIR}/DCAPs/${test_name}
    Verify Measurement Report for A2 SCell Release  directory_path=${OUTPUT_DIR}/DCAPs/${test_name1}
    Verify DUtoCURRCInformation  directory_path=${OUTPUT_DIR}/DCAPs/${test_name}
    Await Data Transfer Finish                 DT_DL_NSA
	Await Data Transfer Finish                 DT_UL_NSA



#- Monitored message sequence includes:
#                  [UE -> gNB-CU] RRC: Measurement Report for A2 SCell Release event
#                  [gNB-DU <- gNB-CU-CP] F1AP: UeContextModificationRequest includes saCell#6 in SCell-ToBeRemoved-List
#                  [gNB-DU -> gNB-CU-CP] F1AP: UeContextModificationResponse includes
#                                    DUtoCURRCInformation.cellGroupConfig.sCellToReleaseList with saCell#6
#                  [gNB-DU <- gNB-CU-CP] F1AP: DlRrcMessageTransfer
#                  [UE <- gNB-DU] RRC: RRCReconfiguration includes:
#                                    measConfig IE.measIdToRemoveList IE set to the value being a combination
# of measObjectId and reportConfigId corresponding to A2 SCell Release measurements for saCell#6.
#                  [UE -> gNB-DU] RRC: RRCReconfigurationComplete
