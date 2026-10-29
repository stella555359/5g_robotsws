*** Variables ***
${peak_rate1}      "301":[140,80],"302":[140,80],"303":[140,80],"304":[140,80],"305":[140,80],"306":[140,80]
${peak_rate2}      "307":[67,37],"308":[67,37],"309":[140,80],"310":[140,80],"311":[140,80],"312":[67,37]
${peak_rate3}      "313":[67,37],"314":[67,37],"315":[67,37]
${peak_rate4}      "401":[147,30],"402":[147,30],"404":[147,30],"405":[147,30],"407":[147,30],"408":[147,30],"409":[147,30]
${peak_rate5}      "406":[70,14.7],"410":[147,30],"411":[147,30],"413":[70,14.7],"414":[68,14.7],"415":[68,14.7],"415":[68,14.7]
&{CB010746_B2}=    HW_ID=CB010746_b2    site_mode=5G    ONAIR_TIME=15 min
...                peak_rate_config={${peak_rate1},${peak_rate2},${peak_rate3},${peak_rate4},${peak_rate5}}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}    CB010746_B2
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    System information broadcast parameters overflow
...    NgGnbInitFullReset    NgGnbInitPartialReset    No module fan detected
${online_commissioning}    [['MRBTS-37126/NRBTS-37126/NRCELL-1/NRCELL_FDD-1',['chBwDI','10MHz']],
...                         ['MRBTS-37126/NRBTS-37126/NRCELL-1/NRCELL_FDD-1',['chBwUI','10MHz']]]
