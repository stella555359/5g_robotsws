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
# [1]5GC000702_commission_configuration_8DL
#     [Setup]     Case Setup for 842
#     wait until keyword succeeds   5x   10s    Import SCF by Custom for 842
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_8DL4UL.xml
#     [Teardown]   Case Teardown for 842
# 
# *** Keywords ***
# Commission configuration 8DL
#     ${nrbts_node}   Set Variable   MRBTS-${bts_id}/NRBTS-${instance_id}
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=Activate Beamforming   new_value=true
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=NR Cell type   new_value=8DL4UL
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=Downlink MIMO Mode
#     ...   new_value=4x4 or 4x2 Closed Loop Spatial Multiplexing
# #    selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-1   filter_param=Basic Beam Set
# #    ...   new_value=beamSet_8
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-2   filter_param=Activate Beamforming   new_value=true
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-2   filter_param=NR Cell type   new_value=8DL4UL
#     selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-2   filter_param=Downlink MIMO Mode
#     ...   new_value=4x4 or 4x2 Closed Loop Spatial Multiplexing
# #    selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELL-2   filter_param=Basic Beam Set
# #    ...   new_value=beamSet_8
# #    selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELLGRP-0   filter_param=Number of transmitted Synchronization Signal Blocks
# #    ...   new_value=8 beams
# #    selenium_coam.set_parameter_value   dist_name=${nrbts_node}/NRCELLGRP-1   filter_param=Number of transmitted Synchronization Signal Blocks
# #    ...   new_value=8 beams
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1
#     ...   filter_param=Direction of the channel   new_value=TX
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2
#     ...   filter_param=Direction of the channel   new_value=RX
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=3   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3
#     ...   filter_param=Direction of the channel   new_value=TX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/PHYANT-1
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=4   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4
#     ...   filter_param=Direction of the channel   new_value=RX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/PHYANT-1
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=5   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-5
#     ...   filter_param=Direction of the channel   new_value=TX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-5
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/PHYANT-1
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=6   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-6
#     ...   filter_param=Direction of the channel   new_value=TX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-6
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-1/PHYANT-1
#     sleep   10s
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1
#     ...   filter_param=Direction of the channel   new_value=TX
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-2
#     ...   filter_param=Direction of the channel   new_value=RX
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=3   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3
#     ...   filter_param=Direction of the channel   new_value=TX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-3
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/PHYANT-1
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=4   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4
#     ...   filter_param=Direction of the channel   new_value=RX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-4
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/PHYANT-1
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=5   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-5
#     ...   filter_param=Direction of the channel   new_value=TX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-5
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/PHYANT-1
#     selenium_coam.add_object   object_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2   object_class_name=CHANNEL
#     ...   plan_to_copy_from=CURRENT_BTS_CONF-1   copy_from=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-1
#     ...   include_subobject=${true}   id_value=6   is_load_default_values=${false}
#     selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-6
#     ...   filter_param=Direction of the channel   new_value=TX
# #    selenium_coam.set_parameter_value   dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-6
# #    ...   filter_param=Distinguished Name of resource   new_value=MRBTS-${bts_id}/EQM-1/APEQM-1/RMOD-2/PHYANT-1
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}
#     wait until keyword succeeds   10m   30s    COAM WEBUI Login
#     COAM WEBUI Whether Close Start Up View Window
#     wait until keyword succeeds   15m   30s   COAM Check All Cells Onair
#     [Teardown]    COAM WEBUI LOGOUT
# 
