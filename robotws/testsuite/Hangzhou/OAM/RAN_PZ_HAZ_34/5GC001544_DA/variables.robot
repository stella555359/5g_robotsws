*** Settings ***
Library	    OperatingSystem
Library     String
Library     Collections

*** Variables ***

${WEBUI_URL}=    			${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}=				Nemuadmin
${WEBUI_PASSWORD}=			nemuuser
${ASIK_IP}=					${tl.gnbs[0].cu.backhaul_site_oam_ip}
${ASIK_USERNAME}=		    toor4nsn
${ASIK_PASSWORD}=		    oZPS0POrRieRtu
#${TL_ID}=					MRBTS-${custom['TL_Number']}
${TL_ID}=					MRBTS-${tl.gnbs[0].instance_id}
${LOG_PATH}=				/tmp/snapshot
${download_dir}=			/tmp/snapshot
${ASIK_IP_LMP}              192.168.255.129
${COAM_ADMIN_PORT}          443
${COAM_ADMIN_username}      Nemuadmin
${COAM_ADMIN_password}      nemuuser
${FaultLMP}                 61649

#variable Netact
${tl_na_vm16_address}=          ${tl.nms.addr}
${tl_na_vm17_address}=          ${tl.nms.nom.ssh_connections_info.addr}
${tl_na_vm14_address}=          ${tl.nms.nom.https_user_mgmt_info.addr}
${tl_na_omc_user}=              ${tl.nms.nom.ssh_connections_info.username}
${tl_na_omc_password}=          ${tl.nms.nom.ssh_connections_info.password}
