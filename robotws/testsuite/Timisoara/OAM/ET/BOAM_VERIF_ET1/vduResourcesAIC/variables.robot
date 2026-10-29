*** Settings ***
Documentation    author: wang calla
...              contact: calla.wang@nokia-sbell.com
...              This file is used to put the common variables

#Library           ./py_tool/global_variables.py

Resource           kw_to_be_optimized.robot


*** Variables ***
# ----------  CU part -----------------


# ----------  vDU part -----------------
&{EXPECTED_MEMORY}    oam=4224Mi  oamfh=4224Mi  nwmgmt=128Mi  cprt=4224Mi  rcpsdl=2Gi  l2rt=16.5Gi  l2hi=8Gi  l1hi=1.24Gi
&{OAM_CONTAINER_APP}  CPCONFIG=ESTABLISHED  IMS=LISTENING  TRSCONFIG=ESTABLISHED
...    NTS=LISTENING  OAMAGENT=ESTABLISHED  oamcm=ESTABLISHED  TAS=LISTENING
&{OAMFH_CONTAINER_APP}  OAMFH=LISTEN  IMS=LISTENING
&{CPRT_CONTAINER_APP}
&{L1HI_CONTAINER_APP}
&{L2RT_CONTAIENR_APP}
&{L2HI_CONTAINER_APP}
&{ALL_CONTAINER_APP}    oam=&{OAM_CONTAINER_APP}  oamfh=&{OAMFH_CONTAINER_APP}  cprt=&{CPRT_CONTAINER_APP}
...    l1hi=&{L1HI_CONTAINER_APP}  l2rt=&{L2RT_CONTAIENR_APP}  l2hi=&{L2HI_CONTAINER_APP}


# ----------- Package information --------------
#${PACKAGE_LINK}    https://hzisoj70.china.nsn-net.net/artifactory/vran-aic-helm-local
${PACKAGE_LINK}    https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
#${PACKAGE_LINK}     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release


${BUILD_CU}         reserved_for_if_to_be_setting_by_agent
${BUILD_VDU}         reserved_for_if_to_be_setting_by_agent
${BUILD_FHGW}       reserved_for_if_to_be_setting_by_agent

${BUILD_CU_PRE}     reserved_for_if_to_be_setting_by_agent
${BUILD_VDU_PRE}     reserved_for_if_to_be_setting_by_agent
${BUILD_FHGW_PRE}   reserved_for_if_to_be_setting_by_agent

#<SCF_FILE_SERVER> stores all historical SCF files which are put by UTE agent
${SCF_FILE_SERVER_IP}  10.108.229.150
${SCF_FILE_SERVER_USERNAME}  ute
${SCF_FILE_SERVER_PASSWORD}   ute
${SCF_FILE_SERVER_FOLDER}     /mnt/s3-scf-backup/AGENT_AIC_VDU_SCF_BACKUP


# ----------- Others --------------
@{IGNORED_ALARM_LIST}


# ----------  LSS server part -----------------
${LSS_IP_ADDRESS}    10.108.229.57
${LSS_PORT_NO}    22
${LSS_USERNAME}  coam
${LSS_PASSWORD}   zO&n1W*ktp7

# ----------  TTI Decoder server part -----------------
${ttitrace_server_ip}    10.108.229.50
${TTI_username}    ute
${TTI_password}    ute

# ----------  FTP server part -----------------
${OAM_KPI_FTP_SERVER}   10.97.122.173
${OAM_KPI_FTP_USERNAME}     ciftp
${OAM_KPI_FTP_PASSWORD}     ciftp
${OAM_KPI_FTP_ROOT_PATH}    /CloudBTS/oam_kpi_data


# ----------  IPSL server part -----------------
${IPSL_SERVER}   10.97.120.109
${IPSL_USERNAME}     aic
${IPSL_PASSWORD}     Nokia123!

# ----------  Dcap server part -----------------
${DCAP_IP}   10.110.95.16
${DCAP_IPv6}   2a00:8a00:8000:5809::106
${DCAP_PORT}     49151
${DCAP_USER}     dcapuser
${DCAP_PASSWORD}     dcapadmin
${DCAP_LOG_DIR}     /sharedvolume/ntracer/_data/
${DCAP_CP_LOG_DIR}     /sharedvolume/flowtracer5g/tmp/5G
${DCAP_UP_LOG_DIR}     /sharedvolume/udptracer/_data/

# ----------  CMP1 server Setting -----------------
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


# ----------  Default certificate Info -----------------
${Default_Certificate_SN}  0x1209FFF948FDC9C88DF0DC63B5B613970687405A

#-----------------CRLDP Setting------------
${CRLDP1}   ldap://10.97.120.186:389/CN=IPsecCA10,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP2}   ldap://10.97.120.186:389/CN=IPsecCA1,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP3}   ldap://10.97.120.186:389/CN=IPsecCA2,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP4}   ldap://10.97.120.186:389/CN=IPsecCA3,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary
${CRLDP5}   ldap://ca2.ivtrans.nokia.com:389/CN=IPsecbackup,OU=ivtrans,O=nokia,DC=cmp?certificateRevocationList;binary

# ----------  Emil server part -----------------
${EMIL_HOST}   10.97.120.118
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

############### TRANS related specific configuration ###########
${TRANS_PARA}                   ${NONE}

&{TOOLS_INFO}    work_folder_root=/tmp/opt/
    ...    work_folder_tool=/tmp/opt/tools/trans_test/
    ...    work_folder_data=/tmp/opt/tools/trans_data/
    ...    work_folder_simu4trs=/tmp/opt/tools/trans_simu4trs/
    ...    arp_test_m=arp_test_m
    ...    icmp_test=icmp_test
    ...    pmtu=pmtu
    ...    send_ether_frame=send_ether_frame
    ...    TrafficGen_vDU=TrafficGen_vDU
    ...    process_guard=process_guard.sh
    ...    ifstats=ifstats
    ...    tcpdump_guard=tcpdump_guard.sh
    ...    tcpdump_guard_cnf=tcpdump_guard_cnf.sh
    ...    tcpdump_guard_vdu_ocp=tcpdump_guard_vdu_ocp.sh
    ...    dep_simu4trs=dep_simu4trs.sh
    ...    load_simu4trs_img=load_simu4trs_img.sh
    ...    fragment=fragment
    ...    pktplayer=pktplayer
    ...    unbinding_dpdk_driver=unbinding_dpdk_driver.sh
    ...    ru_checksum=ru_checksum.py
    ...    openssl_cnf=openssl.cnf
    ...    aic_vtk=aic_runvtk.sh
