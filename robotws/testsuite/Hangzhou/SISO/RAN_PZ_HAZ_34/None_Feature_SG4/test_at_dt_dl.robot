# *** Settings ***
# Library          taf.ue    WITH NAME    ute_ue
# 
# *** Test Cases ***
# Data_Transfer_DL_UL_Protocol_UDP
#     [Setup]  ute_ue.Require Ue    ue_alias=UE_0    capabilities=REAL_ASKEY_UE1
# #    ute_ue.Attach Ue    ue_alias=UE_0
# #    sleep  30
#     ute_ue.start_data_transfer    dt_name=DT_0    ue_alias=UE_0    direction=DL    duration=30s
#     ...    throughput=20Mbits/sec    protocol=udp    packet=1400B
#     ute_ue.Stop Data Transfer    DT_1
# #    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    50Mbits/sec    30%
# #    [Teardown]    ute_ue.Detach Ue    ue_alias=UE_0
