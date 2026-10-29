*** Settings ***
Documentation    MantaRay integration for regression
...              Please do not modify the file without notification to author
...              Author: Sebastian Mikos

Library            taf.nms.netact    WITH NAME    nms
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.mantaray.mantaray.MantarayScripts

*** Variables ***

${bts_id}=       ${tl.gnbs[0].global_bts_id}
${mplane_ip}=    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0]}
${host_ip}=      ${tl.test_pcs[0].default_ssh_connection_details.addr}
&{counter_data}       technology=NRBTS-Nokia AirScale BTS 5G
...                   measurement=NR Cell Availability
...                   netact_counters=ALL
...                   filter_by=MRBTS
...                   mo_names=MRBTS-${bts_id}
...                   object_aggregation=NRCEL
...                   time_aggregation=RAW
...                   time_filter=realtime
...                   look_back_period=${90}

*** Keywords ***

Mantaray Get PM Counters
    ${counters}  get_netact_counters    &{counter_data}
