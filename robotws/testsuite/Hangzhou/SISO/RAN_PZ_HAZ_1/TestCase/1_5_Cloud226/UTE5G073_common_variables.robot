*** Variables ***
&{5G_BTS11193}=        HW_ID=CB007605        site_mode=SA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1]}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml

### For UUF ###
#${RB_TO_TARGET}    YES    #YES|NO Rollback to UUF target build to run other cases
${YAFT}    NO

${SA_OR_NSA}    SA
${TDD_OR_FDD}    TDD
${RU}    3AEQN
${HW_ID}    ASIK+3ABIL+3AEQN

${TOP50}                             True    #True: reporting result to scout
${GLO_SCOUT_TESTLINE_NAME}    1_5_UTE5G073
#${GLO_PERFORM_SAVE_LOG}              FAIL    # possible settings: FAIL, ALWAYS, NONE


### For case - SISO Delta Commissioning Kpi ###
${parameters}    [
...    {"dist_name":"MRBTS-11193/NRBTS-11193/NRCELL-1","para_name":"prachConfigurationIndex",
...    "para_value":"93","reset_tag":"online"},
#...    {"dist_name":"MRBTS-11193/NRBTS-11193/NRCELL-1","para_name":"chBw","para_value":"60MHz",
#...    "require_reset":"rat_reset"},
...    {"dist_name":"MRBTS-11193/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"true","reset_tag":"site_reset"}
...    ]

${parameters_recover}    [
...    {"dist_name":"MRBTS-11193/NRBTS-11193/NRCELL-1","para_name":"prachConfigurationIndex",
...    "para_value":"98","reset_tag":"online"},
#...    {"dist_name":"MRBTS-11193/NRBTS-11193/NRCELL-1","para_name":"chBw","para_value":"100MHz",
#...    "require_reset":"rat_reset"},
...    {"dist_name":"MRBTS-11193/MNL-1/MNLENT-1/SYNC-1/CLOCK-1","para_name":"holdOverModeUsed",
...    "para_value":"false","reset_tag":"site_reset"}
...    ]
