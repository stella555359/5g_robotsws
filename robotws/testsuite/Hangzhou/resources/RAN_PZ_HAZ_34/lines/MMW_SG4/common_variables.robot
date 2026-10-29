*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ssh_username}           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_password}           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TL_BTS_ID}                  ${tl.gnbs[0].instance_id}
${TL_NRBTS_ID}                ${tl.gnbs[0].global_bts_id}
${att_ipaddr}                  ${tl.attenuator.ip_addr}
${att_api_port}                ${tl.attenuator.port}
${att_connection_port}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${control_pc}                 ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}            ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}            ${tl.ues[0].ssh_connection_details.password}
@{Cell_unblock_status}        Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}          Unlocked    disabled    Idle    configured    Blocked
@{Cell_unlock_status}         Unlocked    enabled    Active    configured    Unblocked
@{Cell_lock_status}           Locked      disabled    Idle    initialization required    Unblocked
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_disable_status}        Unlocked    disabled    Idle    configured    Unblocked
@{Cell_enable_status}         Unlocked    enabled    Active    configured    Unblocked
${package_link}               https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
@{allowed_alarm_list}         ${4655}    ${61524}    ${61652}    ${61649}    ${4654}    ${4592}    ${61675}
@{empty_list}