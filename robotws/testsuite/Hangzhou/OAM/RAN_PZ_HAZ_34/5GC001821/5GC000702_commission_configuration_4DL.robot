# *** Settings ***
# Documentation
# ...   author: Jiang Johnny
# ...   contact: johnny.1.jiang@nokia-sbell.com
# 
# Resource   ./Resource/common.robot
# Resource   ./Resource/702.robot
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
# [1]5GC000702_commission_configuration_4DL
#     [Setup]     Case Setup for 842
#     wait until keyword succeeds   5x   10s    Import SCF by Custom for 842
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_4DL4UL.xml
#     [Teardown]   Case Teardown for 842
# 
# *** Keywords ***
# Commission configuration 4DL
#     ${nrbts_node}   Set Variable   MRBTS-${bts_id}/NRBTS-${instance_id}
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=Activate Beamforming   new_value=true
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=NR Cell type   new_value=4DL4UL
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=Downlink MIMO Mode
#     ...   new_value=4x4 or 4x2 Open Loop Spatial Multiplexing
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-2   filter_param=Activate Beamforming   new_value=true
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-2   filter_param=NR Cell type   new_value=4DL4UL
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-2   filter_param=Downlink MIMO Mode
#     ...   new_value=4x4 or 4x2 Open Loop Spatial Multiplexing
#     #cell 1 channel remove
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1
#     ...   filter_param=Direction of the channel   new_value=RX
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2
#     ...   filter_param=Direction of the channel   new_value=RX
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-5
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-6
#     #cell 2 channel remove
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1
#     ...   filter_param=Direction of the channel   new_value=RX
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2
#     ...   filter_param=Direction of the channel   new_value=RX
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-5
#     selenium_coam.remove_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-6
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}
#     wait until keyword succeeds   10m   30s    COAM WEBUI Login
#     COAM WEBUI Whether Close Start Up View Window
#     wait until keyword succeeds   15m   30s   COAM Check All Cells Onair
#     [Teardown]    COAM LOGOUT
