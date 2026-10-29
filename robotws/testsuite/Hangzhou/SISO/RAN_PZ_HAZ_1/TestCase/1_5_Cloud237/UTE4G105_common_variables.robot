*** Variables ***

&{BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB}=        peak_rate_config={"45":[1,1]}    site_mode=4G    ONAIR_TIME=30min
...    HW_ID=CB007605    NODES=TL2:BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB|TL3:BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB

&{BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB_noIPSEC}=        peak_rate_config={"45":[1,1]}
...    site_mode=4G    ONAIR_TIME=30min    HW_ID=CB007605
...    NODES=TL2:BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB_noIPSEC|TL3:BTS_CLOUD_RF_FCA_T_F_105_LTE5205_3eNB

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml

##${SW_CONFIG_PATH}     /home/ute/robotlte/config/Hangzhou/1_5_UTE4G157/swconfig.txt
#@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
#${INIT_CONFIG_ID}
#${EARFCN_CONFIG}    {'131': {'InRange': {'Dl':'394000'}, 'OutRange': {'Dl':'37900'}}}

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Failure in internal BTS connection or connection to 3rd party tool
...    Sanity Check Error    SRIO link outage    Diagnostic Files collected    Setup of X2 connectivity to gNB failed
...    Inter eNB communication failure    BTS reference clock missing    LMP access via port 443
...    Service account root access is enabled    Ethernet port security is disabled
...    BTS reference clock missing

### For UUF ###

#${RB_TO_TARGET}    YES    #YES|NO Rollback to UUF target build to run other cases
${YAFT}    YES

${SA_OR_NSA}
${TDD_OR_FDD}    FDD
${RU}    3FXED+3FRPA+3FZNI+3FRHF+3FRGT
${HW_ID}    3FSMF+4FBBC+2FBBA+3FXED+3FRPA+3FZNI+3FRHF+3FRGT

${TOP50}                             True    #True: reporting result to scout
#${GLO_SCOUT_TESTLINE_NAME}    1_5_UTE4G105

${RESET_CONFIG}    False

${parameters}    [
...    {"dist_name":"MRBTS-2284/LNBTS-2284/LNCEL-9/LNCEL_FDD-0","para_name":"prachConfIndex",
...    "para_value":"19","reset_tag":"online"},
...    {"dist_name":"MRBTS-2284/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"true","reset_tag":"site_reset"},
...    {"dist_name":"MRBTS-2284/LNBTS-2284/SCTP-1","para_name":"maxTimeSctpSetup",
...    "para_value":"100","reset_tag":"rat_reset"},
...    {"dist_name":"MRBTS-2288/LNBTS-2288/LNCEL-17/LNCEL_TDD-0","para_name":"prachConfIndex",
...    "para_value":"4","reset_tag":"online"},
...    {"dist_name":"MRBTS-2288/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"false","reset_tag":"site_reset"},
...    {"dist_name":"MRBTS-2288/LNBTS-2288/SCTP-1","para_name":"maxTimeSctpSetup",
...    "para_value":"100","reset_tag":"rat_reset"},
...    {"dist_name":"MRBTS-2316/LNBTS-2316/LNCEL-57/LNCEL_FDD-0","para_name":"prachConfIndex",
...    "para_value":"4","reset_tag":"online"},
...    {"dist_name":"MRBTS-2316/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"true","reset_tag":"site_reset"},
...    {"dist_name":"MRBTS-2316/LNBTS-2316/SCTP-1","para_name":"maxTimeSctpSetup",
...    "para_value":"100","reset_tag":"rat_reset"}
...    ]

${parameters_recover}    [
...    {"dist_name":"MRBTS-2284/LNBTS-2284/LNCEL-9/LNCEL_FDD-0","para_name":"prachConfIndex",
...    "para_value":"3","reset_tag":"online"},
...    {"dist_name":"MRBTS-2284/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"false","reset_tag":"site_reset"},
...    {"dist_name":"MRBTS-2284/LNBTS-2284/SCTP-1","para_name":"maxTimeSctpSetup",
...    "para_value":"130","reset_tag":"rat_reset"},
...    {"dist_name":"MRBTS-2288/LNBTS-2288/LNCEL-17/LNCEL_TDD-0","para_name":"prachConfIndex",
...    "para_value":"3","reset_tag":"online"},
...    {"dist_name":"MRBTS-2288/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"true","reset_tag":"site_reset"},
...    {"dist_name":"MRBTS-2288/LNBTS-2288/SCTP-1","para_name":"maxTimeSctpSetup",
...    "para_value":"130","reset_tag":"rat_reset"},
...    {"dist_name":"MRBTS-2316/LNBTS-2316/LNCEL-57/LNCEL_FDD-0","para_name":"prachConfIndex",
...    "para_value":"3","reset_tag":"online"},
...    {"dist_name":"MRBTS-2316/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"false","reset_tag":"site_reset"},
...    {"dist_name":"MRBTS-2316/LNBTS-2316/SCTP-1","para_name":"maxTimeSctpSetup",
...    "para_value":"130","reset_tag":"rat_reset"}
...    ]
