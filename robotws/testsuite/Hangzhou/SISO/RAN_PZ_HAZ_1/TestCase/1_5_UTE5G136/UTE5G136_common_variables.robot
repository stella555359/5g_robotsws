*** Variables ***
&{5G_BTS10380}=        HW_ID=CB007605        site_mode=SA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1],"50":[1,1],"51":[1,1],"52":[1,1]}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
##${SW_CONFIG_PATH}     /home/ute/robotlte/config/Hangzhou/1_5_UTE4G157/swconfig.txt
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}      NgGnbInitFullReset      BTS Reset Cause
#${INIT_CONFIG_ID}
#${EARFCN_CONFIG}    {'131': {'InRange': {'Dl':'394000'}, 'OutRange': {'Dl':'37900'}}}

### For UUF ###
#${RB_TO_TARGET}    NO    #YES|NO Rollback to UUF target build to run other cases
${YAFT}    NO

${SA_OR_NSA}    SA
${TDD_OR_FDD}    TDD
${RU}    3AEQP+3AKQJ
${HW_ID}    ASIL+1ABIO+3AEQP+3AKQJ

${TOP50}                             True    #True: reporting result to scout
${GLO_SCOUT_TESTLINE_NAME}    1_5_UTE5G136
#${GLO_PERFORM_SAVE_LOG}              FAIL    # possible settings: FAIL, ALWAYS, NONE

${RESET_CONFIG}    False

${parameters}    [
...    {"dist_name":"MRBTS-10380/NRBTS-10380/NRCELL-1","para_name":"prachConfigurationIndex",
...    "para_value":"93","reset_tag":"online"},
#...    {"dist_name":"MRBTS-10380/NRBTS-10380/NRCELL-1","para_name":"chBw","para_value":"100MHz",
#...    "reset_tag":"rat_reset"},
...    {"dist_name":"MRBTS-10380/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"true","reset_tag":"site_reset"}
...    ]

${parameters_recover}    [
...    {"dist_name":"MRBTS-10380/NRBTS-10380/NRCELL-1","para_name":"prachConfigurationIndex",
...    "para_value":"98","reset_tag":"online"},
#...    {"dist_name":"MRBTS-10380/NRBTS-10380/NRCELL-1","para_name":"chBw","para_value":"60MHz",
#...    "reset_tag":"rat_reset"},
...    {"dist_name":"MRBTS-10380/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"false","reset_tag":"site_reset"}
...    ]
