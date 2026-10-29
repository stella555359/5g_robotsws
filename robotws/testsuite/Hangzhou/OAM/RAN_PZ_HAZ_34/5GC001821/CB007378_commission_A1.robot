# *** Settings ***
# Documentation
# ...   author: Jiang Johnny
# ...   contact: johnny.1.jiang@nokia-sbell.com
# 
# Resource   .${/}Resource${/}common.robot
# Resource   .${/}Resource${/}702.robot
# #Suite Setup   Suite Setup Steps
# #Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_Siso         CRT
# ...    PY36
# 
# *** Variables ***
# ${bts_id}        ${tl.gnbs[0].global_bts_id}
# ${instance_id}   ${tl.gnbs[0].instance_id}
# 
# *** Test Cases ***
# [1]CB007378_commission_A1
#     [Setup]     Case Setup for 842
#     Import SCF by Custom for 842
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/TL289_7378_3S_8DL4UL_${scfname}.xml
#     [Teardown]   Case Teardown for 842