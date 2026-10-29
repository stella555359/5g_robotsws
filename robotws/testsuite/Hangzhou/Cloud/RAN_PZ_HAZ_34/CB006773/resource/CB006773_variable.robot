*** Settings ***

*** Variables ***
${cbam_addr}                    ${tl.cbam.addr}
${client_id}                ${tl.cbam.client_id}
${client_secret}                ${tl.cbam.client_secret}
${CBAM_VERSION}     cbam21
${NET_TYPE}         extnet
${FLAVOR_TYPE}         flavor
${VNF_REDUNDANT_TYPE}         gnb_cu_ha
${VNF_TYPE}         gnb_cu
${release}          5G21B
${VIM_TYPE}          VCP
${FLAVOR_NAME}          tl124_flavor_test
${NETWORK_NAME}          tl124_net_test
${VNF_NAME}          tl124_vnf_test
${FLAVOR_DESCRIPTION}    test to create flavor by robot
${NET_DESCRIPTION}    test to create net by robot
${VNF_DESCRIPTION}    test to create vnf by robot
${flaovr_modify_config_file}    ${CURDIR}/configutions/5G_modify_flavor_gui.json
${flavor_instantiate_config_file}    ${CURDIR}/configutions/5G_instantiate_flavors_gui.json
${vnf_modify_config_file}    ${CURDIR}/configutions/5G_modify_vnf_gui_redundant.json
${vnf_instantiate_config_file}    ${CURDIR}/configutions/5G_instantiate_vnf_gui.json

${net_modify_config_file}    ${CURDIR}/configutions/5G_modify_nets_gui.json
${net_instantiate_config_file}    ${CURDIR}/configutions/5G_instantiate_nets_gui.json
${vim_password}    HZnoki@123!
${terminate_type}    FORCEFUL
${graceful_terminate_type}    GRACEFUL
${package_link}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${download_path}    /home/ute/Downloads
${vnf_package_path}    ${download_path}/Addons/OSP/5G_VNF_redundancy_VCP.csar
${net_package_path}    ${download_path}/Addons/OSP/5G_nets_VCP.csar
${flavor_package_path}    ${download_path}/Addons/OSP/5G_flavors_VCP.csar
${redundant_package_path}    ${download_path}/Addons/OSP/5G_VNF_redundancy_VCP.csar
${vnf_vnfd_id}
${cloud_username}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.username}
${cloud_ip}          ${tl.gnbs[0].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.addr}
${cloud_passwd}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.password}
${version}
${package_name}    AirFrameVirtualized-${version}.qcow2
${image_name}      ${version}
${qcow2_path}    /home/nokiauser
${WEBUI_IP}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}