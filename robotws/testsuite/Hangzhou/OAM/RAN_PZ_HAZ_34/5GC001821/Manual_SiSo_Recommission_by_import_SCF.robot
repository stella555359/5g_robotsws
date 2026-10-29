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
# [1]Manual_SiSo_Recommission_by_import_SCF
#     [Setup]     Case Setup for 842
#     wait until keyword succeeds   2x   10m    Import SCF by Custom for 842
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}.xml
#     [Teardown]   Case Teardown for 842