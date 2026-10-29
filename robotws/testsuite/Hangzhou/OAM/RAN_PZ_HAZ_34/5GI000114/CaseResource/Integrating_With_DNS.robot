*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot
Resource   Integrating_NE_to_NetAct.robot

*** Variables ***
${dot}   .

*** Keywords ***
Integrating With DNS
    Step0: Get All DNS Needed Variables
    Step1: Check DNS Configuration
    Step: Log ALL Variables
    Step2: Configure Forward DNS Lookup
    Step3: Configure Reverse DNS Lookup
    Step4: Check DNS Lookup Correct
    Set Suite Variable   ${IP}   ${GNB_URL}
    Set Suite Variable   ${Dns_flag}   True
    Integrating_NE_to_NetAct.Integrating NE To NetAct

Step0: Get All DNS Needed Variables
    ${compressed_cu_addr}   Get_Compressed_IPv6_Address   ${cu_addr}
    ${exploded_cu_addr}   Get_Exploded_IPv6_Address   ${cu_addr}
    Set Suite Variable   ${COMPRESSED_CU_ADDR}
    Set Suite Variable   ${EXPLODED_CU_ADDR}

    @{domain_list}   Split String   ${START_PAGE}   .
    ${NetAct_domain}   Fetch From Right   ${START_PAGE}   ${domain_list[0]}.
    Set Suite Variable   ${NETACT_DOMAIN_LAST}   ${NetAct_domain}

    ${NetAct_domain}   Fetch From Left   ${NetAct_domain}   .${domain_list[-1]}
    Set Suite Variable   ${FORWARD_FILE_PATH}   /var/named/db.${NetAct_domain}

    ${new_addr}   Run Keyword If   '${NE3SWS_IPversion}'=='IPv6'   Replace String   ${EXPLODED_CU_ADDR}   :   .
    ...   ELSE   Set Variable   ${EXPLODED_CU_ADDR}
    @{gnb_list}   Split String   ${new_addr}   .
    ${gnb_domain}   Fetch From Left   ${new_addr}   .${gnb_list[-1]}

    Set Suite Variable   ${REVERSE_FILE}   db.${gnb_domain}
    Set Suite Variable   ${REVERSE_FILE_PATH}   /var/named/${REVERSE_FILE}

    Run Keyword If   '${NE3SWS_IPversion}'=='IPv6'   Set Suite Variable   ${GNB_LAST}   ${dot.join(reversed('${gnb_list[-1]}'))}
    ...   ELSE   Set Suite Variable   ${GNB_LAST}   ${gnb_list[-1]}

    Run Keyword If   '${NE3SWS_IPversion}'=='IPv4'   Set IPv4 Reverse GNB ZONE NAME   ${gnb_domain}
    ...   ELSE   Set IPv6 Reverse GNB ZONE NAME   ${gnb_domain}

    Set Suite Variable   ${DNS_MASTER_URL}   ${DNS_MASTER_HOSTS[0]}.${NETACT_DOMAIN_LAST}
    Set Suite Variable   ${DNS_MASTER_IP}   ${HOST_IP['${DNS_MASTER_HOSTS[0]}']}

    Set Suite Variable   ${DNS_SLAVE_URL}   ${DNS_SLAVE_HOSTS[0]}.${NETACT_DOMAIN_LAST}
    # Set Suite Variable   ${DNS_SLAVE_IP}   ${HOST_IP['${DNS_SLAVE_HOSTS[0]}']}

    Set Suite Variable   ${GNB_URL}   ${MO_NAME}.${NETACT_DOMAIN_LAST}

Step1: Check DNS Configuration
    csn.Connect To   hostname=${DNS_MASTER_IP}   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   alias=DNS_MASTER   timeout=60
    ${forward_output}   csn.Execute   command=nslookup ${MO_NAME}   connection=DNS_MASTER  timeout=60
    ${FORWARD_FLAG}   Run Keyword And Return Status   Should Not Contain   ${forward_output}   server can't find
    ${reverse_output}   csn.Execute   command=nslookup ${EXPLODED_CU_ADDR}   connection=DNS_MASTER  timeout=60
    ${REVERSE_FLAG}   Run Keyword And Return Status   Should Not Contain   ${reverse_output}   server can't find
    Set Suite Variable   ${FORWARD_FLAG}
    Set Suite Variable   ${REVERSE_FLAG}

    ${REVERSE_FILE_FLAG}   csn.File Exists   remote_path=${REVERSE_FILE_PATH}   connection=DNS_MASTER   timeout=60
    Set Suite Variable   ${REVERSE_FILE_FLAG}

    [Teardown]   csn.Reset Cache

Step: Log ALL Variables
    Log To Console   COMPRESSED_CU_ADDR: ${COMPRESSED_CU_ADDR}
    Log To Console   EXPLODED_CU_ADDR: ${EXPLODED_CU_ADDR}
    Log To Console   GNB_LAST: ${GNB_LAST}

    Log To Console   NETACT_DOMAIN_LAST: ${NETACT_DOMAIN_LAST}

    Log To Console   FORWARD_FILE_PATH: ${FORWARD_FILE_PATH}

    Log To Console   REVERSE_FILE: ${REVERSE_FILE}
    Log To Console   REVERSE_FILE_PATH: ${REVERSE_FILE_PATH}
    Log To Console   ZONE_NAME: ${ZONE_NAME}

    Log To Console   DNS_MASTER_IP: ${DNS_MASTER_IP}
    Log To Console   DNS_MASTER_URL: ${DNS_MASTER_URL}
    Log To Console   DNS_SLAVE_URL: ${DNS_SLAVE_URL}
    Log To Console   GNB_URL: ${GNB_URL}

    Log To Console   FORWARD_FLAG: ${FORWARD_FLAG}
    Log To Console   REVERSE_FLAG: ${REVERSE_FLAG}
    Log To Console   REVERSE_FILE_FLAG: ${REVERSE_FILE_FLAG}


Step2: Configure Forward DNS Lookup
    Return From Keyword If   ${FORWARD_FLAG}
    csn.Connect To   hostname=${DNS_MASTER_IP}   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   alias=DNS_MASTER   timeout=60
    ${forward_output}   csn.Execute   command=cat ${FORWARD_FILE_PATH} | grep ${EXPLODED_CU_ADDR}   connection=DNS_MASTER   timeout=60
    ${median}   Set Variable If
    ...   '${NE3SWS_IPversion}'=='IPv4'   A
    ...   '${NE3SWS_IPversion}'=='IPv6'   AAAA

    csn.Execute   command=sed -i '$a${MO_NAME}${SPACE*4}${median}${SPACE*4}${EXPLODED_CU_ADDR}' ${FORWARD_FILE_PATH}
    ...   connection=DNS_MASTER   timeout=60

    [Teardown]   csn.Reset Cache


Step3: Configure Reverse DNS Lookup
    Return From Keyword If   ${REVERSE_FLAG}
    csn.Connect To   hostname=${DNS_MASTER_IP}   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   alias=DNS_MASTER   timeout=60

    Run Keyword If   not ${REVERSE_FILE_FLAG}   Create Reverse DNS Lookup File
    ...   ELSE   ADD Reverse DNS Lookup File

    csn.Execute   command=chown named:named ${REVERSE_FILE_PATH}   connection=DNS_MASTER   timeout=60
    csn.Execute   command=chmod 640 ${REVERSE_FILE_PATH}   connection=DNS_MASTER   timeout=60
    ${named_cfg}   Set Variable   /var/named/chroot/etc/named.conf

    ${reverse_output}   csn.Execute   command=cat ${named_cfg} | grep ${REVERSE_FILE}   connection=DNS_MASTER   timeout=60
    ${Not_Add_Zone}   Run Keyword And Return Status   Should Be Empty   ${reverse_output}
    Run Keyword If   ${Not_Add_Zone}   csn.Execute
    ...   command=sed -i '$a\\\\nzone "${ZONE_NAME}" {\\n\\ttype master;\\n\\tfile "${REVERSE_FILE}";\\n};' ${named_cfg}
    ...   connection=DNS_MASTER   timeout=60

    csn.Execute   command=service named reload   connection=DNS_MASTER   timeout=60
    [Teardown]   csn.Reset Cache

Step4: Check DNS Lookup Correct
    csn.Connect To   hostname=${DNS_MASTER_IP}   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   alias=DNS_MASTER   timeout=60
    ${output}   csn.Execute   command=nslookup ${EXPLODED_CU_ADDR}   connection=DNS_MASTER   timeout=60
    Should Contain   ${output}   ${GNB_URL}
    ${output}   csn.Execute   command=nslookup ${GNB_URL}   connection=DNS_MASTER   timeout=60
    Should Contain   ${output}   ${COMPRESSED_CU_ADDR}
    [Teardown]   csn.Reset Cache

Set IPv4 Reverse GNB ZONE NAME
    [Arguments]   ${gnb_domain}
    @{gnb_domain_list}   Split String   ${gnb_domain}   .
    Reverse List   ${gnb_domain_list}
    ${reverse_gnb_domain}   Set Variable   ${gnb_domain_list[0]}
    FOR   ${i}   IN   @{gnb_domain_list[1:]}
       ${reverse_gnb_domain}   Set Variable   ${reverse_gnb_domain}.${i}
    END
    Set Suite Variable   ${ZONE_NAME}   ${REVERSE_GNB_DOMAIN}.in-addr.arpa.

Set IPv6 Reverse GNB ZONE NAME
    [Arguments]   ${gnb_domain}
    ${gnb_str}   Replace String   ${gnb_domain}   .   ${EMPTY}
    ${reverse_gnb_domain}   Set Variable   ${dot.join(reversed('${gnb_str}'))}
    Set Suite Variable   ${ZONE_NAME}   ${REVERSE_GNB_DOMAIN}.ip6.arpa.

Create Reverse DNS Lookup File
    ${l1}   Set Variable   $ORIGIN ${ZONE_NAME}\n
    ${l2}   Set Variable   $TTL 3600\n
    ${l3}   Set Variable   ${ZONE_NAME} IN SOA ${DNS_MASTER_URL}.
    ${l33}  Set Variable   ${SPACE}root.${DNS_MASTER_URL}. (\n
    ${l4}   Set Variable   ${SPACE*4}2018110702${SPACE*4}; Serial\n
    ${l5}   Set Variable   ${SPACE*4}28800${SPACE*4}; Refresh\n
    ${l6}   Set Variable   ${SPACE*4}1200${SPACE*4}; Retry\n
    ${l7}   Set Variable   ${SPACE*4}604800${SPACE*4}; Expire\n
    ${l8}   Set Variable   ${SPACE*4}3600 )${SPACE*4}; Minimum TTL\n
    ${l9}   Set Variable   ${SPACE*4}NS${SPACE*4}${DNS_MASTER_URL}.\n
    ${l10}  Set Variable   ${SPACE*4}NS${SPACE*4}${DNS_SLAVE_URL}.\n
    ${l11}  Set Variable   ${GNB_LAST}${SPACE*4}PTR${SPACE*4}${GNB_URL}.\n
    OperatingSystem.Create File
    ...   path=${OUTPUT_DIR}/${REVERSE_FILE}
    ...   content=${l1}${l2}${l3}${l33}${l4}${l5}${l6}${l7}${l8}${l9}${l10}${l11}

    csn.Upload File   local_path=${OUTPUT_DIR}/${REVERSE_FILE}   remote_path=${REVERSE_FILE_PATH}   connection=DNS_MASTER   timeout=60

ADD Reverse DNS Lookup File
    csn.Download File   remote_path=${REVERSE_FILE_PATH}   local_path=${OUTPUT_DIR}/${REVERSE_FILE}   connection=DNS_MASTER   timeout=60
    csn.Execute   command=sed -i '$a${GNB_LAST}${SPACE*4}PTR${SPACE*4}${GNB_URL}.' ${REVERSE_FILE_PATH}
    ...   connection=DNS_MASTER   timeout=60

Case Setup: Integrating With DNS
    Login NetAct Start Page and Remove File

Case Teardown: Integrating With DNS
    Run Keyword And Ignore Error   Close Java Application by Remote Port   remote_port=${remote_port}
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout