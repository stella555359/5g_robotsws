*** Settings ***


*** Variables ***



*** Keywords ***
Modify airphone l1bypass
    [Arguments]    ${H0}    ${V0}    ${H1}    ${V1}    ${srsNumCountSwitchProfile}=16    ${extra_modify}=@{EMPTY}
    Download original airphone l1bypass
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${list1}    create list
    ...    text|${H0}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${H0}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${V0}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${V0}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${H1}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${H1}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${V1}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${V1}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${srsNumCountSwitchProfile}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ${modify_list}    Combine Lists    ${list1}    ${extra_modify}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}
    TAF_SSH.connect to    ${AP_ASIK_IP}    ${GNB_USERNAME}    ${GNB_PASSWORD}    alias=iphy
    TAF_SSH.upload file    ${original_xml}    /ffs/run/logs/L1ByPTestModeConfiguration.xml   connection=iphy
    ${ret}    TAF_SSH.execute    ls /ffs/run/logs    connection=iphy

Modify airphone l1bypass coma value for two ue
    [Arguments]    ${p1u0_h}    ${p1u0_v}    ${p2u0_h}    ${p2u0_v}
    ...    ${p1u1_h}    ${p1u1_v}    ${p2u1_h}    ${p2u1_v}
    ...    ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0
    ...    ${p1_rank}=1    ${p2_rank}=1    ${p1_sinr}=33    ${p2_sinr}=33    ${extra_modify}=@{EMPTY}
    Download original airphone l1bypass
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${list1}    create list
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//SrsTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//SrsTestParams//UlRank
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//PuschTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//PuschTestParams//UlRank
    ...    text|${p1_sinr}|//*[@TestProfile\="Profile-1"]//PuschTestParams//Sinr
    ...    text|${p2_sinr}|//*[@TestProfile\="Profile-2"]//PuschTestParams//Sinr
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
    ${modify_list}    Combine Lists    ${list1}    ${extra_modify}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}
    TAF_SSH.connect to    ${AP_ASIK_IP}    ${GNB_USERNAME}    ${GNB_PASSWORD}    alias=iphy
    TAF_SSH.upload file    ${original_xml}    /ffs/run/logs/L1ByPTestModeConfiguration.xml   connection=iphy
    ${ret}    TAF_SSH.execute    ls /ffs/run/logs    connection=iphy

Modify airphone l1bypass coma value for four ue
    [Arguments]    ${p1u0_h}    ${p1u0_v}    ${p2u0_h}    ${p2u0_v}
    ...    ${p1u1_h}    ${p1u1_v}    ${p2u1_h}    ${p2u1_v}
    ...    ${p1u2_h}    ${p1u2_v}    ${p2u2_h}    ${p2u2_v}
    ...    ${p1u3_h}    ${p1u3_v}    ${p2u3_h}    ${p2u3_v}
    ...    ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0
    ...    ${p1_rank}=1    ${p2_rank}=1    ${p1_sinr}=33    ${p2_sinr}=33    ${extra_modify}=@{EMPTY}
    Download original airphone l1bypass
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${list1}    create list
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//SrsTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//SrsTestParams//UlRank
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//PuschTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//PuschTestParams//UlRank
    ...    text|${p1_sinr}|//*[@TestProfile\="Profile-1"]//PuschTestParams//Sinr
    ...    text|${p2_sinr}|//*[@TestProfile\="Profile-2"]//PuschTestParams//Sinr
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u2_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u2_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u2_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u2_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u2_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u2_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u2_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u2_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u3_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u3_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u3_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u3_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u3_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u3_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u3_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u3_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
    ${modify_list}    Combine Lists    ${list1}    ${extra_modify}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}
    TAF_SSH.connect to    ${AP_ASIK_IP}    ${GNB_USERNAME}    ${GNB_PASSWORD}    alias=iphy
    TAF_SSH.upload file    ${original_xml}    /ffs/run/logs/L1ByPTestModeConfiguration.xml   connection=iphy
    ${ret}    TAF_SSH.execute    ls /ffs/run/logs    connection=iphy

Modify airphone l1bypass coma value for eight ue
    [Arguments]    ${p1u0_h}    ${p1u0_v}    ${p2u0_h}    ${p2u0_v}
    ...    ${p1u1_h}    ${p1u1_v}    ${p2u1_h}    ${p2u1_v}
    ...    ${p1u2_h}    ${p1u2_v}    ${p2u2_h}    ${p2u2_v}
    ...    ${p1u3_h}    ${p1u3_v}    ${p2u3_h}    ${p2u3_v}
	...    ${p1u4_h}    ${p1u4_v}    ${p2u4_h}    ${p2u4_v}
	...    ${p1u5_h}    ${p1u5_v}    ${p2u5_h}    ${p2u5_v}
	...    ${p1u6_h}    ${p1u6_v}    ${p2u6_h}    ${p2u6_v}
	...    ${p1u7_h}    ${p1u7_v}    ${p2u7_h}    ${p2u7_v}
    ...    ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0
    ...    ${p1_rank}=1    ${p2_rank}=1    ${p1_sinr}=33    ${p2_sinr}=33    ${extra_modify}=@{EMPTY}
    Download original airphone l1bypass
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${list1}    create list
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//SrsTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//SrsTestParams//UlRank
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//PuschTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//PuschTestParams//UlRank
    ...    text|${p1_sinr}|//*[@TestProfile\="Profile-1"]//PuschTestParams//Sinr
    ...    text|${p2_sinr}|//*[@TestProfile\="Profile-2"]//PuschTestParams//Sinr
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u2_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u2_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u2_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u2_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u2_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u2_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u2_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u2_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u3_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u3_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u3_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u3_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u3_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u3_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u3_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u3_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u4_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u4_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u4_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u4_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u4_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u4_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u4_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u4_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u5_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u5_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u5_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u5_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u5_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u5_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u5_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u5_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u6_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u6_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u6_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u6_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u6_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u6_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u6_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u6_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u7_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u7_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u7_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u7_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u7_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u7_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u7_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u7_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
    ${modify_list}    Combine Lists    ${list1}    ${extra_modify}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}
    TAF_SSH.connect to    ${AP_ASIK_IP}    ${GNB_USERNAME}    ${GNB_PASSWORD}    alias=iphy
    TAF_SSH.upload file    ${original_xml}    /ffs/run/logs/L1ByPTestModeConfiguration.xml   connection=iphy
    ${ret}    TAF_SSH.execute    ls /ffs/run/logs    connection=iphy

Modify airphone l1bypass coma value for four profile eight ue
    [Arguments]    ${p1u0_h}    ${p1u0_v}    ${p2u0_h}    ${p2u0_v}    ${p3u0_h}    ${p3u0_v}    ${p4u0_h}    ${p4u0_v}
    ...    ${p1u1_h}    ${p1u1_v}    ${p2u1_h}    ${p2u1_v}    ${p3u1_h}    ${p3u1_v}    ${p4u1_h}    ${p4u1_v}
    ...    ${p1u2_h}    ${p1u2_v}    ${p2u2_h}    ${p2u2_v}    ${p3u2_h}    ${p3u2_v}    ${p4u2_h}    ${p4u2_v}
    ...    ${p1u3_h}    ${p1u3_v}    ${p2u3_h}    ${p2u3_v}    ${p3u3_h}    ${p3u3_v}    ${p4u3_h}    ${p4u3_v}
	...    ${p1u4_h}    ${p1u4_v}    ${p2u4_h}    ${p2u4_v}    ${p3u4_h}    ${p3u4_v}    ${p4u4_h}    ${p4u4_v}
	...    ${p1u5_h}    ${p1u5_v}    ${p2u5_h}    ${p2u5_v}    ${p3u5_h}    ${p3u5_v}    ${p4u5_h}    ${p4u5_v}
	...    ${p1u6_h}    ${p1u6_v}    ${p2u6_h}    ${p2u6_v}    ${p3u6_h}    ${p3u6_v}    ${p4u6_h}    ${p4u6_v}
	...    ${p1u7_h}    ${p1u7_v}    ${p2u7_h}    ${p2u7_v}    ${p3u7_h}    ${p3u7_v}    ${p4u7_h}    ${p4u7_v}
    ...    ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0    ${srsNumCountSwitchProfile3}=0    ${srsNumCountSwitchProfile4}=0
    ...    ${p1_rank}=1    ${p2_rank}=1    ${p3_rank}=1    ${p4_rank}=1
	...    ${p1_sinr}=33    ${p2_sinr}=33    ${p3_sinr}=33    ${p4_sinr}=33
	...    ${extra_modify}=@{EMPTY}
    Download original airphone l1bypass
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${list1}    create list
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//SrsTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//SrsTestParams//UlRank
    ...    text|${p1_rank}|//*[@TestProfile\="Profile-1"]//PuschTestParams//UlRank
    ...    text|${p2_rank}|//*[@TestProfile\="Profile-2"]//PuschTestParams//UlRank
    ...    text|${p1_sinr}|//*[@TestProfile\="Profile-1"]//PuschTestParams//Sinr
    ...    text|${p2_sinr}|//*[@TestProfile\="Profile-2"]//PuschTestParams//Sinr
    ...    text|${p3_rank}|//*[@TestProfile\="Profile-3"]//SrsTestParams//UlRank
    ...    text|${p4_rank}|//*[@TestProfile\="Profile-4"]//SrsTestParams//UlRank
    ...    text|${p3_rank}|//*[@TestProfile\="Profile-3"]//PuschTestParams//UlRank
    ...    text|${p4_rank}|//*[@TestProfile\="Profile-4"]//PuschTestParams//UlRank
    ...    text|${p3_sinr}|//*[@TestProfile\="Profile-3"]//PuschTestParams//Sinr
    ...    text|${p4_sinr}|//*[@TestProfile\="Profile-4"]//PuschTestParams//Sinr
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u0_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u0_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u0_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u0_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u1_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u1_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u1_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u1_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u2_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u2_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u2_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u2_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u2_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u2_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u2_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u2_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p1u3_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u3_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u3_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u3_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u3_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u3_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u3_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u3_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u4_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u4_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u4_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u4_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u4_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u4_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u4_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u4_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u5_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u5_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u5_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u5_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u5_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u5_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u5_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u5_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u6_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u6_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u6_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u6_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u6_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u6_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u6_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u6_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p1u7_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p1u7_h}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p1u7_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p1u7_v}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p2u7_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p2u7_h}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p2u7_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p2u7_v}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p3u0_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u0_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u0_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u0_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u0_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u0_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u0_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u0_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="0"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p3u1_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u1_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u1_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u1_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u1_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u1_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u1_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u1_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="1"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p3u2_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u2_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u2_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u2_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u2_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u2_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u2_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u2_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="2"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p3u3_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u3_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u3_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u3_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u3_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u3_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u3_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u3_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="3"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p3u4_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u4_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u4_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u4_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u4_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u4_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u4_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u4_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="4"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p3u5_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u5_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u5_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u5_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u5_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u5_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u5_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u5_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="5"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p3u6_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u6_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u6_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u6_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u6_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u6_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u6_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u6_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="6"]//NrRxBfCumulSpatialCovMatVNegative45
	...    text|${p3u7_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p3u7_h}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p3u7_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p3u7_v}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${p4u7_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${p4u7_h}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${p4u7_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${p4u7_v}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="7"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
	...    text|${srsNumCountSwitchProfile3}|//*[@TestProfile\="Profile-3"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile4}|//*[@TestProfile\="Profile-4"]//srsNumCountSwitchProfile
    ${modify_list}    Combine Lists    ${list1}    ${extra_modify}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}
    TAF_SSH.connect to    ${AP_ASIK_IP}    ${GNB_USERNAME}    ${GNB_PASSWORD}    alias=iphy
    TAF_SSH.upload file    ${original_xml}    /ffs/run/logs/L1ByPTestModeConfiguration.xml   connection=iphy
    ${ret}    TAF_SSH.execute    ls /ffs/run/logs    connection=iphy