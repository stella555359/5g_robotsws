# *** Settings ***
# Documentation
# ...   author: Jiang Johnny
# ...   contact: johnny.1.jiang@nokia-sbell.com
# 
# Resource   .${/}Resource${/}common.robot
# Resource   .${/}Resource${/}702.robot
# Suite Setup   Suite Setup Steps
# #Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_Siso         CRT
# ...    PY36
# 
# *** Variables ***
# ${bts_id}        ${tl.gnbs[0].global_bts_id}
# ${instance_id}   ${tl.gnbs[0].instance_id}
# 
# *** Test Cases ***
# [1]5GC002540_commission_configuration_4DL
#     [Tags]    AUTHOR_johnny.1.jiang@nokia-sbell.com
#     [Setup]   COAM WEBUI LOGIN
#     ${dist_name}   set variable    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
#     ${cell_type}  selenium_coam.get_parameter_value   dist_name=${dist_name}    filter_param=NR Cell type
#     run keyword if  ${cell_type.count('4DL4UL')} <= 0    Change CellType by perform SCF    celltype=4DL4UL
#     ...   ELSE    log to console    gnb already is 4DL4UL!
#     [Teardown]   COAM WEBUI LOGOUT
# 
# 
# 
