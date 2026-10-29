*** Settings ***
Documentation     [PURPOSE] New added General keywords from HZ
...               CA-SWM/CA-HW


*** Keywords ***
Create MPLANEONAP object
    [Documentation]
    ...  This keyword creates MPLANEONAP object, with it's parameters
    ${mplane_onap}=    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${dict_heartBeatSendingInterval}=    create dictionary    parameterName=heartBeatSendingInterval
    ...                               operation=update
    ...                               value=0
    ${dict_mPlaneAddressDN}=    create dictionary    parameterName=mPlaneAddressDN
    ...                               operation=update
    ...                               value=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ${dict_activateOranO1NetconfService}=    create dictionary    parameterName=activateOranO1NetconfService
    ...                               operation=update
    ...                               value=false
    ${dict_activateSendingBulkPmEvents}=    create dictionary    parameterName=activateSendingBulkPmEvents
    ...                               operation=update
    ...                               value=false
    ${dict_activateSendingFmEvents}=    create dictionary    parameterName=activateSendingFmEvents
    ...                               operation=update
    ...                               value=false
    ${dict_activateSendingPnfRegistration}=    create dictionary    parameterName=activateSendingPnfRegistration
    ...                               operation=update
    ...                               value=false
    ${dict_pnfRegistrationEventSendingInterval}=    create dictionary    parameterName=pnfRegistrationEventSendingInterval
    ...                               operation=update
    ...                               value=300
    ${dict_pnfRegistrationScenarioTimeout}=    create dictionary    parameterName=pnfRegistrationScenarioTimeout
    ...                               operation=update
    ...                               value=1440
    ${dict_vesAckTimeout}=    create dictionary    parameterName=vesAckTimeout
    ...                               operation=update
    ...                               value=5
    @{parameter_list}=    Create List  ${dict_heartBeatSendingInterval}  ${dict_mPlaneAddressDN}
    ...    ${dict_activateOranO1NetconfService}  ${dict_activateSendingBulkPmEvents}
    ...  ${dict_activateSendingFmEvents}  ${dict_activateSendingPnfRegistration}
    ...    ${dict_pnfRegistrationEventSendingInterval}  ${dict_pnfRegistrationScenarioTimeout}  ${dict_vesAckTimeout}
    Perform Object Recommissioning        dist_name=${mplane_onap}  operation=create  parameter=@{parameter_list}

Delete MPLANEONAP object
    [Documentation]
    ...  This keyword deletes MPLANEONAP object
    ${parameter_list}  Create list
    ${mplane_onap}=    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    Perform Object Recommissioning        dist_name=${mplane_onap}  operation=delete  parameter=${parameter_list}

Add certificates to CMP object
    [Documentation]
    ...  This keyword adds certificates to CMP object
    ...  CMP object is used for ONAP object creation
    ${cmp_dn}  Set variable  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ${delta_id}  Set variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  ${cmp_dn}  update  ${delta_id}
    Append Parameter Update To Delta  ${cmp_dn}  caSubjectName  C=PL, O=Common, CN=IPSEC  ${delta_id}
    Append Parameter Update To Delta  ${cmp_dn}  serverHost  10.42.54.13  ${delta_id}
    Append Parameter Update To Delta  ${cmp_dn}  serverPort  8080  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  delta_file.json  delta_id=${delta_id}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning        delta_file.json  skip_parameter_relation_errors=True

Add VESENDPOINT-ID
    [Documentation]
    ...  This keyword adds VESENDPOINT ids to ONAP object
    [Arguments]    ${vesend_no}
    ${vesend}=    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-${vesend_no}
    ${dict_enableHostnameValidation}=    create dictionary    parameterName=enableHostnameValidation
    ...                               operation=update
    ...                               value=False
    ${dict_vesEndpointId}=    create dictionary    parameterName=vesEndpointId
    ...                               operation=update
    ...                               value=${vesend_no}
    ${dict_vesEndpointIpAddress}=    create dictionary    parameterName=vesEndpointIpAddress
    ...                               operation=update
    ...                               value=${WORKER_IP}
    ${dict_vesEndpointPortNumber}=    create dictionary    parameterName=vesEndpointPortNumber
    ...                               operation=update
    ...                               value=30420
    @{parameter_list}=    create list    ${dict_enableHostnameValidation}  ${dict_vesEndpointId}
    ...    ${dict_vesEndpointIpAddress}  ${dict_vesEndpointPortNumber}
    Perform Object Recommissioning        dist_name=${vesend}  operation=create  parameter=@{parameter_list}

VES Endpoint reference change
    [Documentation]
    ...  This keyword changes VESENDPOINT reference in ONAP object
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]    ${vesend_ref}    ${vesend_no}
    ${vesend}=    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-${vesend_no}
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1  parameter=${vesend_ref}
    ...    operation=update  value=${vesend}  skip_parameter_relation_errors=${True}  timeout=180

ONAP parameter change
    [Documentation]
    ...  This keyword changes parameters value in ONAP
    [Arguments]  ${parameter}    ${value}
    Wait until keyword succeeds    4 min    10 sec    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    parameter=${parameter}
    ...    operation=update
    ...    value=${value}
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${True}
    ...    timeout=180
    Log  Parameter ${parameter} changed to ${value}.  console=true

ONAP Simulater installation for NetConf
    [Documentation]    Short description.
    Run Local Linux Command     sshpass -p ute scp -r ute@10.108.184.40:/home/ute/HZOAM/Tool/ONAP_simulater/ /home/ute/
    taf.sbts.oam.coam.admin.Install Certificate         /home/ute/ONAP_simulater/netconf/CMPHZ.p12      BtsTrustChain      P12      ute
    Run Local Linux Command     sudo sed -i '$a ${BTS_INFO.IP} IPSEC' /etc/hosts
    Run Local Linux Command     sudo apt autoclean
    Run Local Linux Command     sudo apt update --fix-missing
    Run Local Linux Command     sudo apt-get install netopeer2 -y

ONAP Simulater installation for Vespoint
    [Documentation]    Short description.
    Run Local Linux Command     sshpass -p ute scp -r ute@10.108.184.40:/home/ute/HZOAM/Tool/ONAP_simulater/ /home/ute/
    taf.sbts.oam.coam.admin.Install Certificate         /home/ute/ONAP_simulater/netconf/CMPHZ.p12      BtsTrustChain      P12      ute
    Run Local Linux Command     sudo sed -i 's/ipv4 = "10.0.1.1"/ipv4 = "${BTS_PC_INFO.IP}"/g' /home/ute/ONAP_simulater/ves/VES_simulator_5339.py
    Run Local Linux Command     sudo iptables -F
    ${process}=        Start Process	    python     /home/ute/ONAP_simulater/ves/VES_simulator_5339.py     stdout=/home/ute/process_result.txt
    Sleep     30s
    ${return_status}=     Run Local Linux Command     netstat -na | grep 30510
    ${status}=     Fetch From Left     ${return_status}      ${SPACE}${SPACE}
    Should Be Equal As Strings      ${status}     tcp
    Log     ${process}
