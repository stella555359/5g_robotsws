*** Settings ***
Documentation    author: wang calla
...              contact: calla.wang@nokia-sbell.com
...              This file is used to put the common variables




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


# ----------- Others --------------
@{IGNORED_ALARM_LIST}


# ----------  TTI Decoder server part -----------------
${ttitrace_server_ip}    10.57.167.107
${TTI_username}    ute
${TTI_password}    iW_K#8.ute%A10h0m0ra

# ----------  Dcap server part -----------------
${DCAP_IP}   10.57.150.41
${DCAP_IPv6}   fe80::cf37:d489:36b:9455
${DCAP_PORT}     55900
${DCAP_USER}    lab5g
${DCAP_PASSWORD}     Noki@pdz123!
#${DCAP_LOG_DIR}     /sharedvolume/ntracer/_data/
${DCAP_LOG_DIR}     /sharedvolume/uptracer/_data/
${DCAP_CP_LOG_DIR}     /sharedvolume/flowtracer5g/tmp/5G
${DCAP_UP_LOG_DIR}     /sharedvolume/udptracer/_data/

# ----------  Emil server part -----------------
${EMIL_HOST}   10.101.47.8
${EMIL_USER}   nokia5G
${EMIL_PASSWORD}   noki@123
${EMIL_PATH}  /cygdrive/c/Program Files/Emil
${EMIL_WIN_PATH}  C:\\\\Program Files\\\\Emil
${EMIL_LOG_DIR}  /cygdrive/c/emil_logs
${EMIL_WIN_LOG_DIR}  C:\\\\emil_logs

# ----------  PM Counter part -----------------
${PM_RESULT_DIR_IN_PMCORE}   /var/opt/nokia/performancemanagement/storage/results

################ TRANS related specific configuration ###########
#${TRANS_PARA}                   ${NONE}
#
#&{TOOLS_INFO}    work_folder_root=/tmp/opt/
#    ...    work_folder_tool=/tmp/opt/tools/trans_test/
#    ...    work_folder_data=/tmp/opt/tools/trans_data/
#    ...    work_folder_simu4trs=/tmp/opt/tools/trans_simu4trs/
#    ...    arp_test_m=arp_test_m
#    ...    icmp_test=icmp_test
#    ...    pmtu=pmtu
#    ...    send_ether_frame=send_ether_frame
#    ...    TrafficGen_vDU=TrafficGen_vDU
#    ...    process_guard=process_guard.sh
#    ...    ifstats=ifstats
#    ...    tcpdump_guard=tcpdump_guard.sh
#    ...    tcpdump_guard_cnf=tcpdump_guard_cnf.sh
#    ...    tcpdump_guard_vdu_ocp=tcpdump_guard_vdu_ocp.sh
#    ...    dep_simu4trs=dep_simu4trs.sh
#    ...    load_simu4trs_img=load_simu4trs_img.sh
#    ...    fragment=fragment
#    ...    pktplayer=pktplayer
#    ...    unbinding_dpdk_driver=unbinding_dpdk_driver.sh
#    ...    ru_checksum=ru_checksum.py
#    ...    openssl_cnf=openssl.cnf
#    ...    aic_vtk=aic_runvtk.sh