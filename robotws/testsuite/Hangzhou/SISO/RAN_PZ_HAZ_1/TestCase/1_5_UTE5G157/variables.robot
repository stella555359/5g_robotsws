*** Variables ***
&{5G_CB007605_3xUHIE_2xAHCA}=
...   peak_rate_config={"421":[133,33],"423":[65,33],"426":[100,30],"422":[133,33],"424":[133,33]}
...   site_mode=SA     ONAIR_TIME=300    HW_ID=UHIE
&{5G_CB007605_3xUHIE_3xAHCA_3xUHFA}=
...   peak_rate_config={"421":[100,31],"430":[133,31],"422":[133,33],"431":[133,31],"423":[65,33],"432":[133,31]}
...   site_mode=SA     ONAIR_TIME=300    HW_ID=UHFA;UHIE
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${TOP50}    True
${GLO_SCOUT_TESTLINE_NAME}    1_5_UTE5G157
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    LOS on SMOD-1, EIF4
${INIT_CONFIG_ID}      5G_CB007605_3xUHIE_3xAHCA_3xUHFA
${repetition}    10
${SUPPORTED_CALL}    False

