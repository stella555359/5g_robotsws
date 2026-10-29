*** Settings ***
Documentation    author: wang calla
...              contact: calla.wang@nokia-sbell.com
...              This file is used to put the common variables


Resource           kw_to_be_optimized.robot
#Resource           aic_common_resources.robot


*** Variables ***
# ----------- VDU part --------------
#${VDU_CONTAINER_PROMPT}          sh-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT_ROOT}     \\[root@\\S+:\\S+\\][\\r\\n]+#\\s
${VDU_OE_SERVER_PROMPT}          \\[core@\\S+\\s\\S+\\]\\$\\s
${VDU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$
@{VDU_REDUNDENCY_POD_LIST}       up  rcpsdl  oamasm  oamcm  oamext  oamconfig  oamfm
@{VDU_REDUNDENCY_OAM_POD_LIST}   oamasm  oamcm  oamext  oamconfig  oamfm


# ----------- VCU part --------------
${VCU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
#${VCU_CONTAINER_PROMPT_ROOT}     #no root for vcu upue pod
#${VCU_OE_SERVER_PROMPT}          \\[core@\\S+\\s\\S+\\]\\$\\s
${VCU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$


# ----------- UTE part --------------
${UTE_SSH_IP}         ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_SSH_USER_NAME}  ${tl.test_pc.default_ssh_connection_details.username}
${UTE_SSH_PASSWORD}   ${tl.test_pc.default_ssh_connection_details.password}
${FHGW_PACKAGE_DOWNLOAD_FOLDER_IN_UTE}       /home/ute/package

# ----------- Package information --------------
${PACKAGE_LINK}    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
${PACKAGE_LINK_ESPOO}     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release


${BUILD_CU}         reserved_for_if_to_be_setting_by_agent
${BUILD_VDU}         reserved_for_if_to_be_setting_by_agent
${BUILD_FHGW}       reserved_for_if_to_be_setting_by_agent

${BUILD_CU_PRE}     reserved_for_if_to_be_setting_by_agent
${BUILD_VDU_PRE}    reserved_for_if_to_be_setting_by_agent
${BUILD_FHGW_PRE}   reserved_for_if_to_be_setting_by_agent


&{PACKAGE_PRE_MAPPING}    0.300=vDUCNF00   0.250=vCUCNF00    14.300=vDUCNF22R2    14.250=vCUCNF22R2   15.250=vCUCNF22R3
                   ...    16.300=vDUCNF22R4   16.250=vCUCNF22R4   17.300=vDUCNF23R1   17.250=vCUCNF23R1
                   ...    18.300=vDUCNF23R2   18.250=vCUCNF23R2   19.300=vDUCNF23R3   19.250=vCUCNF23R3

#for netact
&{NETACT_MO_RELEASE}   0.300=23R4VDU   0.250=23R4VCU    16.300=22R4VDU  16.250=22R4VCU   17.300=23R1VDU   17.250=23R1VCU
...   18.300=23R2VDU   18.250=23R2VCU  19.300=23R3VDU   19.250=23R3VCU  19.300=23R3VDU

# ----------- Others --------------
@{IGNORED_ALARM_LIST}


# ----------  LSS server part -----------------
# Maintainer: lijuan.1.wang@nokia-sbell.com
# 3rd confluence page：https://confluence.ext.net.nokia.com/display/ASAiCBTS/3rd+server+maintainer+info
${LSS_IP_ADDRESS}    10.108.229.57
${LSS_PORT_NO}    22
${LSS_USERNAME}  coam
${LSS_PASSWORD}   zO&n1W*ktp7

# ----------  TTI Decoder server part -----------------
# Maintainer: xianbiao.cheng@nokia-sbell.com
# 3rd confluence page：https://confluence.ext.net.nokia.com/display/ASAiCBTS/3rd+server+maintainer+info
${ttitrace_server_ip}    10.108.229.50
${TTI_username}    ute
${TTI_password}    ute

# ----------  FTP server part -----------------
# The FTP server will not be used
${OAM_KPI_FTP_SERVER}   10.97.122.173
${OAM_KPI_FTP_USERNAME}     ciftp
${OAM_KPI_FTP_PASSWORD}     ciftp
${OAM_KPI_FTP_ROOT_PATH}    /CloudBTS/oam_kpi_data


# ----------  CMP1 server Setting -----------------
# Maintainer: lijuan.1.wang@nokia-sbell.com
# 3rd confluence page：https://confluence.ext.net.nokia.com/display/ASAiCBTS/3rd+server+maintainer+info
${CMP1_Server_IP}   10.97.120.186
${CMP1_Server_IPv6}   2a00:8a00:8000:117:1:17:0:1a
${CMP1_Server_SingleLayer_PORT}     8080
${CMP1_Server_MultiLayer_PORT}     8081
${CMP1_Server_Path}     pkix
${CMP1_EE_SUBJECT_NAME}  CN=MRBTS


# ----------  CA1 Setting -----------------
${CA1_SubjectName}   DC=cmp, O=nokia, OU=ivtrans, CN=IPsecbackup
${CA1_PSK}  gC7u-fa4T-4K2S-dnbw
${CA1_Ref_Num}   3102

# ----------Multi  CA1 Setting -----------------
${Three_layer_CA_SubjectName}   DC=cmp, O=nokia, OU=ivtrans, CN=IPsec_CA23
${Three_layer_CA_PSK}  WEH8-sPEw-xwov-Xt67
${Three_layer_CA_Ref_Num}   3104


# ----------  ldap_failure_CA Setting -----------------
${Ldap_failure_CA_SubjectName}  DC=cmp, O=nokia, OU=ivtrans, CN=CRLfailure
${Ldap_failure_CA_PSK}  bpmh-hJMx-z2ib-g5Hu
${Ldap_failure_CA_Ref_Num}  3097

# ----------  CA2 Setting ECDSA-----------------
${CA2_SubjectName_EC}  DC=cmp, O=nokia, OU=ivtrans, CN=ECcert_SG05
${CA2_PSK_EC}  igWb-9G3r-zKxp-f2ye
${CA2_Ref_Num_EC}  3133

# ----------  Default certificate Info -----------------
${Default_Certificate_SN}  0x1209FFF948FDC9C88DF0DC63B5B613970687405A

#-----------------CRLDP Setting------------
${CRLDP1}   ldap://10.97.120.186:389/CN=IPsecCA10,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP2}   ldap://10.97.120.186:389/CN=IPsecCA1,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP3}   ldap://10.97.120.186:389/CN=IPsecCA2,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP4}   ldap://10.97.120.186:389/CN=IPsecCA3,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP5}   ldap://ca2.ivtrans.nokia.com:389/CN=IPsecbackup,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary

# ----------  Emil server part -----------------
# Maintainer: hongping.rao@nokia-sbell.com
# 3rd confluence page：https://confluence.ext.net.nokia.com/display/ASAiCBTS/3rd+server+maintainer+info
${EMIL_HOST}   10.97.120.109
${EMIL_USER}   aic
${EMIL_PASSWORD}   Nokia123!
${EMIL_PATH}  /cygdrive/c/Program Files/Emil
${EMIL_WIN_PATH}  C:\\\\Program Files\\\\Emil
${EMIL_LOG_DIR}  /cygdrive/c/emil_logs
${EMIL_WIN_LOG_DIR}  C:\\\\emil_logs

# ----------  luashark script part -----------------
${LUA_SCRIPT_PATH}    /home/ute/lua_script
${TSHARK_PATH}    /usr/bin/tshark
${LUA_SCRIPT_LINK}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/

# ----------  PM Counter part -----------------
${PM_RESULT_DIR_IN_PMCORE}   /var/opt/nokia/performancemanagement/storage/results

# ----------  OCP Login part -----------------
${OCP_LOGIN_USERNAME}   nokiaadmin
${OCP_LOGIN_PASSWORD}   nokiaadmin

# ----------  Coredump server part -----------------
${COREDUMP_INSTALL_PROXY}  https_proxy="http://10.158.100.1:8080"
${COREDUMP_REPO_URL}  https://nokia.github.io/koredump/

############### TRANS related specific configuration ###########
# Maintainer: chris.l.cao@nokia-sbell.com
${TRANS_PARA}                   ${NONE}

&{TOOLS_INFO}    work_folder_root=/tmp/opt/
    ...    work_folder_tool=/tmp/opt/tools/trans_test/
    ...    work_folder_data=/tmp/opt/tools/trans_data/
    ...    ruproxy_work_folder_root=/home/_nokfhgwsysruoam/opt/
    ...    ruproxy_work_folder_tool=/home/_nokfhgwsysruoam/opt/tools/trans_test/
    ...    ruproxy_work_folder_data=/home/_nokfhgwsysruoam/opt/tools/trans_data/
    ...    work_folder_simu4trs=/tmp/opt/tools/trans_simu4trs/
    ...    pmtu=pmtu
    ...    TrafficGen_vDU=TrafficGen_vDU
    ...    process_guard=process_guard.sh
    ...    ifstats=ifstats
    ...    tcpdump_guard=tcpdump_guard.sh
    ...    tcpdump_guard_cnf=tcpdump_guard_cnf.sh
    ...    tcpdump_guard_vdu_ocp=tcpdump_guard_vdu_ocp.sh
    ...    fragment=fragment
    ...    pktplayer=pktplayer
    ...    pktplayer_ctr=pktplayer_ctr
    ...    ru_checksum=ru_checksum.py
    ...    openssl_cnf=openssl.cnf
    ...    aic_vtk=aic_runvtk.sh
    ...    icmp_test=icmp_test


###### Internal useage , please do not change it if you do not know it well #############
#@{IGNORED_ALARM_LIST}
@{VDU_REST_TAF_LIB_SUPPORTED_VERSION}   cuoam_19b   cuoam_21b  cuoam_22r2  cuoam_22r4  cuoam_23r1  cuoam_23r2   cuoam_23r3
&{VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}   16.300=cuoam_22r4  15.300=cuoam_22r2  17.300=cuoam_23r1    18.300=cuoam_23r2
                                          ...  0.300=${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}
@{VCU_REST_TAF_LIB_SUPPORTED_VERSION}   cuoam_19b   cuoam_21b   cuoam_22r4  cuoam_23r1  cuoam_23r2   cuoam_25r1   cuoam_25r2
&{VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}   15.250=cuoam_21b    16.250=cuoam_22r4  17.250=cuoam_23r1   18.250=cuoam_23r2
                                          ...   0.250=${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}


######### SCF/yaml Agent Server##########
# Maintainer: jinbo.yu@nokia-sbell.com
# Desciption: use for agent backup scf yaml
${AGENT_LINK}   http://10.109.2.147:8099


######## Mcshark Server#############
${MCSHARK_LINK}     https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/

######## DoS tool Server#############
${VDU_DOS_TOOL_SERVER}     10.97.120.27
${VDU_DOS_TOOL_SERVER_V6}  2a00:8a00:8000:117:1:10:0:1b
${DOS_TOOL_UTE_PASSWORD}   Trans@123456
${DOS_INTERFACE_VDU}       eno1
${DOS_INTERFACE_VCU}       enp3s0


######## DoS tool Server_1#############
${TRAFFIC_SERVER_IP}     10.97.120.3
${TRAFFIC_SERVER_USERNAME}  ute
${TRAFFIC_SERVER_PASSWORD}  Ut3pa5s#ff97
${TRAFFIC_INTERFACE_VDU}       enp1s0
${TRAFFIC_INTERFACE_VCU}      enp3s0

######## TLDA Analyse Server #######
${TLDA_SERVER_IP}    10.108.229.200
${TLDA_SERVER_USERNAME}    ute
${TLDA_SERVER_PASSWORD}    ute


######## DCAP TLS Server #######
${DCAP_IP_TLS}       10.70.34.174
${DCAP_USERNAME_TLS}       dcapuser
${DCAP_PASSWORD_TLS}       dcapadmin!
${DCAP_PORT_TLS}          49148
${DCAP_LOG_DIR_TLS}     /data/ntracer5g_5/

@{COMMON_WHITE_FAULT_ID_LIST}

@{COMMON_WHITE_ALARM_ID_LIST}
