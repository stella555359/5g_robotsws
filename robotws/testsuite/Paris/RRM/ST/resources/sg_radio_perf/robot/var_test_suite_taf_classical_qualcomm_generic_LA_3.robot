
*** Variables ***

# About LA
# TEST Description
${LA_TESTNAME}=					TDL1
${LA_PROFILE}=					AWGNdl
${LA_TRAFICTYPE}=				DL						 
${LA_CAPTUREDURATION}=			10
${LA_TYPEATTEN}=	     		Pwr
${LA_IATTEN}=					30
${LA_FATTEN}=					35
${LA_STEP}=						1
${LA_TIMESTABILASATION}=		2
${LA_NBLOOP}=					1
${LA_ALLERRETOUR}=				A
${LA_TRACETYPE}=			    TQ
${LA_HDF2TXT}=					Y
${LA_TIME_STAMP}=				_2020_0402


# SCF/swconfig
${LA_SCF_LOAD}=			 		N
${LA_SWC_LOAD}=			 		N
${LA_RESET_gNB}=			 	N
${LA_SCF_PATH}=					/home/localuser/AUTOMATION/LA/SCF/
${LA_SCF_FILE}=					scf_default.xml
${LA_SCF_BACKUP_FILE}=			scf_backup_orig.xml
${LA_SWC_PATH}=					/home/localuser/AUTOMATION/LA/SWC/
${LA_SWC_FILE}=					swconfig_default.txt
${LA_SWC_BACKUP_FILE}=			swconfig_backup_orig.txt

#VM Test
${VM_PATH}=						/home/localuser/AUTOMATION/LA/TESTS/
${VM_PATH_TST}=					${VM_PATH}${LA_TRAFICTYPE}_${LA_TESTNAME}


#About gNB0 configuration
${MRBTS_NB[0]}=                	${custom['MRBTS']}
${NRBTS_NB[0]}=                	${custom['GNB_nr_bts']}
${ASIK_ADDR[0]}=               	${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_USERNAME[0]}=           	${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PASSWORD[0]}=           	${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${GNB_ABIL0_IP}=               	${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${RU_ADDR[0]}=                 	${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${RU_USERNAME[0]}=             	${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${RU_PASSWORD[0]}=             	${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${GN_WEBUI[0]}=                	${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER[0]}=           	${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PWD[0]}=            	${tl.gnbs[0].cu.oam_http_connection_details.password}
${GN_WEBUI_PORT[0]}=           	${tl.gnbs[0].cu.oam_http_connection_details.port}



#About eNB configuration
${ASIA_ADDR}=					${custom['eNB LMP IP Address']}
${ASIA_USERNAME}=				${custom['eNB Username']}
${ASIA_PASSWORD}=				${custom['eNB Password']}

# About Spirent
${SPIRENT_PC_IP}=				${custom['spirent_pc_ip']}
${SPIRENT_PC_LOGIN}=			${custom['spirent_pc_login']}
${SPIRENT_PC_PASSWD}=			${custom['spirent_pc_passwd']}
${SPIRENT_IP}=					${custom['spirent_ip']}
${SPIRENT_PORT}=				${custom['spirent_port']}

# PC UE
${PC_UE_IP}=					${custom['iPerf_VM_UL_ipaddress']}
${PC_UE_LOGIN}=					${custom['iPerf_VM_UL_login']}
${PC_UE_PASSWD}=				${custom['iPerf_VM_UL_passwd']}


#About scripts to enable the L1L2 mirroring
${ASIK_SCRIPT_MIRROR}=			${custom['asik_mirroring_script']}
${LONER_SCRIPT_MIRROR}=			${custom['loner_mirroring_script']}


#About Blade configured to capture L1L2 traces
${L1L2_AIRFRAME_IPADDRESS}=		${custom['l1l2_airframe_ipaddress']}
${L1L2_AIRFRAME_USERNAME}=		${custom['l1l2_airframe_login']}
${L1L2_AIRFRAME_PASSWORD}=		${custom['l1l2_airframe_passwd']}
${L1L2_AIRFRAME_INTERFACE}=		${custom['l1l2_airframe_interface']}

#About Traffic server at UE side
${IPERF_VM_UL_IPADDRESS}=		${custom['iPerf_VM_UL_ipaddress']}
${IPERF_VM_UL_LOGIN}=			${custom['iPerf_VM_UL_login']}
${IPERF_VM_UL_PASSWD}=			${custom['iPerf_VM_UL_passwd']}
${IPERF_VM_UL_IPERF_PATH}=		${custom['iPerf_VM_UL_iPerf_Path']}

#About Traffic server at Core side
${IPERF_VM_DL_IPADDRESS}=		${custom['iPerf_VM_DL_ipaddress']}
${IPERF_VM_DL_LOGIN}=			${custom['iPerf_VM_DL_login']}
${IPERF_VM_DL_PASSWD}=			${custom['iPerf_VM_DL_passwd']}
${COREIPTRAFFICSERVER}=			${custom['iPerf_VM_DL_Network_Interface_Address']}

# About traffic duration in seconds for feature 1070 tests
${TRAFFIC_DURATION}				460

# About X2 IP addresses
${X2_IP_ADDR[0]} 				${custom['x2_ip_address']}
#${X2_IP_ADDR[1]}               ${custom['x2_ip_address_gNB1']}

# About LUA shark
${LUA_PATH}						${custom['lua_path']}
