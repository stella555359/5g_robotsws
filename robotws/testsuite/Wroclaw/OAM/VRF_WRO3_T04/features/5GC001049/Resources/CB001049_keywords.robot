*** Settings ***
Documentation
...     description:    Keywords for test cases for the 5GC001049 feature.

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Resource    ../../../common_resources/ip_traffic/ip_traffic.robot
Resource    ../../../common_resources/pcap_analysis/pcap_analysis.robot
Resource    ../../../common_resources/ue_operations/ue_operations.robot
Resource    1049_IP_Table.robot

Library    Collections
Library    taf.sbts.oam.coam.admin                        WITH NAME    coam_admin
Library    CB001049_functions.py                          WITH NAME    func
Library    CB001049_NmapHandler.py                        WITH NAME    nmap
Library    CB001049_NftHandler.py                         WITH NAME    nft
Library    CB001049_UEHandler.py                          WITH NAME    ues

*** Variables ***
${ue_pdu_model}=        ${tl.pdus[1]}
${ue_pdu_host}=         ${tl.pdus[1].addr}
${ue_pdu_port}=         ${tl.pdus[1].port_numbers}

*** Keywords ***
Commission BTS And Wait Until Given State
    [Arguments]    ${scf_file}    ${state}
    Log    Commissioning SCF    console=True
    Commission SCF    scf_file=${scf_file}
    Log    Waiting Until ${state}    console=True
    Wait Until Keyword Succeeds    30x    1min    Check if BTS in given state    state=${state}
    Log    BTS is ${state}    console=True

Manage Object
    [Arguments]    ${object_name}    ${parameter}    ${operation}
    ${conn}=    Connect to ADMIN
    Perform Object Recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/${object_name}
    ...                               parameter=${parameter}
    ...                               operation=${operation}
    ...                               connection=${conn}
    [Teardown]    Disconnect from ADMIN    connection=${conn}

Delete SERVEDAMF Objects
    ${empty_list}=    Create List
    Manage Object    object_name=SERVEDAMF-2    parameter=${empty_list}    operation=delete
    Manage Object    object_name=SERVEDAMF-3    parameter=${empty_list}    operation=delete
    Manage Object    object_name=SERVEDAMF-4    parameter=${empty_list}    operation=delete

Delete XNLINK Objects
    ${empty_list}=    Create List
    Manage Object    object_name=XNLINK-1    parameter=${empty_list}    operation=delete
    Manage Object    object_name=XNLINK-2    parameter=${empty_list}    operation=delete
    Manage Object    object_name=XNLINK-3    parameter=${empty_list}    operation=delete
    Manage Object    object_name=XNLINK-4    parameter=${empty_list}    operation=delete

Create Proper XNLINKs On BTS
    ${ipsv4}=    func.Get Ipv4 Addresses XnCPlane
    ${ipsv6}=    func.Get Ipv6 Addresses XnCPlane
    @{xncplane}=    Combine Lists    ${ipsv4}    ${ipsv6}
    ${index}=    Set Variable    0

    FOR    ${address}    IN    @{xncplane}
        ${xnlink}=    func.Create XNLINK    ${address}    ${index}
        ${index} =    Evaluate    ${index} + 1
        Manage Object   object_name=XNLINK-${index}    parameter=${xnlink}    operation=create
    END

Create Proper NRADJGNBs On BTS
    ${localnradjgnb}=    func.Get NRADJGNB Address
    &{gnbPlmn_dict}=    Create Dictionary    mcc=244    mnc=8    mncLength=2
    @{gnbPlmn_list}=    Create List    ${gnbPlmn_dict}

    &{nradjgnb1_uPlaneIpAddrList_item1_dict}=    Create Dictionary
    ...                                ipV4Address=@{localnradjgnb}[0]
    ...                                ipV6Address=@{localnradjgnb}[4]
    ...                                nrPlmnDN=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPLMN-1
    &{nradjgnb1_uPlaneIpAddrList_item2_dict}=    Create Dictionary
    ...                                ipV4Address=@{localnradjgnb}[1]
    ...                                ipV6Address=@{localnradjgnb}[5]
    ...                                nrPlmnDN=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPLMN-2
    @{nradjgnb1_uPlaneIpAddrList_list}=    Create List    ${nradjgnb1_uPlaneIpAddrList_item1_dict}    ${nradjgnb1_uPlaneIpAddrList_item2_dict}

    &{nradjgnb2_uPlaneIpAddrList_item1_dict}=    Create Dictionary
    ...                                ipV4Address=@{localnradjgnb}[2]
    ...                                ipV6Address=@{localnradjgnb}[6]
    ...                                nrPlmnDN=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPLMN-2
    &{nradjgnb2_uPlaneIpAddrList_item2_dict}=    Create Dictionary
    ...                                ipV4Address=@{localnradjgnb}[3]
    ...                                ipV6Address=@{localnradjgnb}[7]
    ...                                nrPlmnDN=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPLMN-1
    @{nradjgnb2_uPlaneIpAddrList_list}=    Create List    ${nradjgnb2_uPlaneIpAddrList_item1_dict}    ${nradjgnb2_uPlaneIpAddrList_item2_dict}

    &{nradjgnb_1_dict}=    Create Dictionary    administrativeState=Unlocked     gNbIdLength=22    gnbPlmn=@{gnbPlmn_list}
    ...                    gNodeBId=50276     gNodeBIdCtrl=oamControlled      weightForIgnbCaSelection=1       nrAdjGnbId=1      xnLinkRef=1
    ...                    xnLinkRef2=3         uPlaneIpAddrList=@{nradjgnb1_uPlaneIpAddrList_list}
    &{nradjgnb_2_dict}=    Create Dictionary    administrativeState=Unlocked     gNbIdLength=22    gnbPlmn=@{gnbPlmn_list}
    ...                    gNodeBId=50276     gNodeBIdCtrl=oamControlled      weightForIgnbCaSelection=1       nrAdjGnbId=2      xnLinkRef=2
    ...                    xnLinkRef2=4         uPlaneIpAddrList=@{nradjgnb2_uPlaneIpAddrList_list}

    ${nradjgnb_1_list}=    Get Formatted Parameters    &{nradjgnb_1_dict}
    ${nradjgnb_2_list}=    Get Formatted Parameters    &{nradjgnb_2_dict}

    Manage Object		object_name=NRADJGNB-1
    ...					parameter=@{nradjgnb_1_list}    operation=create
    Manage Object	    object_name=NRADJGNB-2
    ...					parameter=@{nradjgnb_2_list}    operation=create


Create Proper SERVEDAMFs On BTS
    ${servedamf}=    func.Get Servedamf Addresses
    ${amf_1}=    Create AMF Object
    ...        administrativeState=Unlocked
    ...        defaultAMF=false
    ...        amfIPAddress=${servedamf}[1]
    ...        ngTnlId=2
    ${amf_2}=    Create AMF Object
    ...        administrativeState=Unlocked
    ...        defaultAMF=false
    ...        amfIPAddress=${servedamf}[2]
    ...        ngTnlId=1
    ${amf_3}=    Create AMF Object
    ...        administrativeState=Unlocked
    ...        defaultAMF=false
    ...        amfIPAddress=${servedamf}[3]
    ...        ngTnlId=2
    Manage Object   object_name=SERVEDAMF-2    parameter=${amf_1}    operation=create
    Manage Object   object_name=SERVEDAMF-3    parameter=${amf_2}    operation=create
    Manage Object   object_name=SERVEDAMF-4    parameter=${amf_3}    operation=create

Change SERVEDAMFs To Fake IPS
    ${delta}=    func.Change SERVEDAMFS Fake IPS    ${BTS_ID}
    Recommission Parameters By Delta    delta=${delta}

Change xnLinkRef Parameters
    &{nradjgnb_1_xnLinkRef_param_dict}=     Create Dictionary    parameterName=xnLinkRef     operation=update    value=2
    &{nradjgnb_1_xnLinkRef2_param_dict}=    Create Dictionary    parameterName=xnLinkRef2    operation=update    value=4

    &{nradjgnb_2_xnLinkRef_param_dict}=     Create Dictionary    parameterName=xnLinkRef     operation=update    value=1
    &{nradjgnb_2_xnLinkRef2_param_dict}=    Create Dictionary    parameterName=xnLinkRef2    operation=update    value=3

    @{nradjgnb_1_param_list}=    Create List    ${nradjgnb_1_xnLinkRef_param_dict}   ${nradjgnb_1_xnLinkRef2_param_dict}
    &{nradjgnb_1_dict}=    Create Dictionary    distName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-1
    ...                                         operation=update
    ...                                         parameters=@{nradjgnb_1_param_list}

    @{nradjgnb_2_param_list}=    Create List    ${nradjgnb_2_xnLinkRef_param_dict}   ${nradjgnb_2_xnLinkRef2_param_dict}
    &{nradjgnb_2_dict}=    Create Dictionary    distName=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-2
    ...                                         operation=update
    ...                                         parameters=@{nradjgnb_2_param_list}

    @{nradjgnb_delta}=    Create List    ${nradjgnb_1_dict}    ${nradjgnb_2_dict}

    ${conn}=    Connect To ADMIN
    Recommission Parameters By Delta                  delta=${nradjgnb_delta}
    ...                                               connection=${conn}
    Wait until BTS reach Configured or OnAir state    connection=${conn}
    [Teardown]    Disconnect from ADMIN    connection=${conn}

Get Object XNLINK AMF Params
    [Arguments]    ${object_name}   ${object_number}    ${param_name}
    ${value}=    Check Current Parameter Value
    ...          dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/${object_name}-${object_number}
    ...          param_name=${param_name}
    [Return]    ${value}

Check Addresses Nft After Handover Not Exist
    ${addresses}=    nft.Get Addresses From Nft List Ruleset Output File    pattern=all_remote
    ${xlink_ip}=    Get Object XNLINK AMF Params    object_name=XNLINK    object_number=0    param_name=cPlaneIpAddr
    ${chain}=    nft.Get Section From Output    section_name=chain NGXN_CHAIN    section_lines_count=3
    func.Get Ipv4 Addresses XnCPlane
    func.Get Ipv6 Addresses XnCPlane

Download Nft Ruleset
    [Arguments]    ${ip_addr}=${SSH_IP}

    Log    Downloading nft_list_ruleset    console=True
    nft.Execute SSH Command
    ...      ip=${ip_addr}
    ...      command=nft list ruleset > /user/toor4nsn/nft_list_ruleset.txt
    nft.Execute Command
    ...     command=sshpass -p "oZPS0POrRieRtu" scp toor4nsn@${ip_addr}:/user/toor4nsn/nft_list_ruleset.txt ${EXECDIR}/nft_list_ruleset.txt

    Log    Downloading classifier_table_ipv4    console=True
    nft.Execute SSH Command
    ...     ip=${ip_addr}
    ...     command=/opt/trs/bin/vtc l4clfr ipv4 show
    nft.Execute Command
    ...     command=sshpass -p "oZPS0POrRieRtu" scp toor4nsn@${ip_addr}:/tmp/l3l4_classifier_table.txt ${EXECDIR}/l3l4_classifier_table.txt

    Log    Downloading classifier_table_ipv6    console=True
    nft.Execute SSH Command
    ...     ip=${ip_addr}
    ...     command=/opt/trs/bin/vtc l4clfr ipv6 show
    nft.Execute Command
    ...     command=sshpass -p "oZPS0POrRieRtu" scp toor4nsn@${ip_addr}:/tmp/l3l4_classifier_table_ipv6.txt ${EXECDIR}/l3l4_classifier_table_ipv6.txt

Check Nft Ruleset
    Download Nft Ruleset
    Log    Checking If Correct Addresses Are Present    console=True
    nft.Supplement Address v6    nft_list_ruleset
    nft.Check Classifier Table v4
    nft.Check Classifier Table v6
    Log    Correct Addresses Are Present    console=True

Check Nft Ruleset T1
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login      toor4nsn  oZPS0POrRieRtu
    Sleep    5            reason=Wait until terminal execute the command

    SSHLibrary.Write      nft list table "ip filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP4}=           SSHLibrary.Read
    Should Contain        ${setsIP4}    ${cPlaneIPv4_1}
    Should Contain        ${setsIP4}    ${cPlaneIPv4_2}
    Should Contain        ${setsIP4}    ${amfIPv4_1}
    Should Contain        ${setsIP4}    ${amfIPv4_2}

    SSHLibrary.Write      nft list table "ip6 filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP6}=           SSHLibrary.Read
    Should Contain        ${setsIP6}    ${cPlaneIPv6_1}
    Should Contain        ${setsIP6}    ${cPlaneIPv6_2}
    Should Contain        ${setsIP6}    ${amfIPv6_1}
    Should Contain        ${setsIP6}    ${amfIPv6_2}

    SSHLibrary.Write      nft list chain "ip filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip4}=            SSHLibrary.Read
    Should Contain        ${cpTip4}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip4}=          SSHLibrary.Read
    Should Contain        ${ngxnCip4}    ${xnc_ipv4_1}
    Should Contain        ${ngxnCip4}    ${xnc_ipv4_2}
    Should Contain        ${ngxnCip4}    ${ngc_ipv4_1}
    Should Contain        ${ngxnCip4}    ${ngc_ipv4_2}
    Should Contain Any    ${ngxnCip4}    counter packets 1    counter packets 2    counter packets 3
    ...                                  counter packets 4    counter packets 5    counter packets 6
    ...                                  counter packets 7    counter packets 8    counter packets 9

    SSHLibrary.Write      nft list chain "ip6 filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip6}=            SSHLibrary.Read
    Should Contain        ${cpTip6}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip6 filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip6}=          SSHLibrary.Read
    Should Contain        ${ngxnCip6}    ${xnc_ipv6_1}
    Should Contain        ${ngxnCip6}    ${xnc_ipv6_2}
    Should Contain        ${ngxnCip6}    ${ngc_ipv6_1}
    Should Contain        ${ngxnCip6}    ${ngc_ipv6_2}
    [Teardown]            SSHLibrary.Close Connection

Check Classifier Table T1
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login      toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Write      /opt/trs/bin/vtc l4clfr ipv4 show
    Sleep    2            reason=Wait until terminal execute the command
    SSHLibrary.Write      /opt/trs/bin/vtc l4clfr ipv6 show
    Sleep    2            reason=Wait until terminal execute the command

    SSHLibrary.Write      cat /tmp/l3l4_classifier_table.txt
    Sleep    2            reason=Wait until terminal execute the command
    ${ctable_ipv4}=       SSHLibrary.Read
    Should Contain        ${ctable_ipv4}    ${rem_xnu_ipv4_1}
    Should Contain        ${ctable_ipv4}    ${rem_xnu_ipv4_2}
    Should Contain        ${ctable_ipv4}    ${rem_xnu_ipv4_3}
    Should Contain        ${ctable_ipv4}    ${rem_xnu_ipv4_4}
    Should Contain        ${ctable_ipv4}    ${xnu_ipv4_1}
    Should Contain        ${ctable_ipv4}    ${xnu_ipv4_2}

    SSHLibrary.Write      cat /tmp/l3l4_classifier_table_ipv6.txt
    Sleep    2            reason=Wait until terminal execute the command
    ${ctable_ipv6}=       SSHLibrary.Read
    Should Contain        ${ctable_ipv6}    ${rem_xnu_ipv6_1}
    Should Contain        ${ctable_ipv6}    ${rem_xnu_ipv6_2}
    Should Contain        ${ctable_ipv6}    ${rem_xnu_ipv6_3}
    Should Contain        ${ctable_ipv6}    ${rem_xnu_ipv6_4}
    Should Contain        ${ctable_ipv6}    ${xnu_ipv6_1}
    Should Contain        ${ctable_ipv6}    ${xnu_ipv6_2}
    [Teardown]            SSHLibrary.Close Connection

Check Classifier Table T12
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login      toor4nsn  oZPS0POrRieRtu
    SSHLibrary.Write      /opt/trs/bin/vtc l4clfr ipv4 show
    Sleep    2            reason=Wait until terminal execute the command
    SSHLibrary.Write      /opt/trs/bin/vtc l4clfr ipv6 show
    Sleep    2            reason=Wait until terminal execute the command

    SSHLibrary.Write      cat /tmp/l3l4_classifier_table.txt
    Sleep    2            reason=Wait until terminal execute the command
    ${ctable_ipv4}=       SSHLibrary.Read
    Should Not Contain    ${ctable_ipv4}    sys_teid

    SSHLibrary.Write      cat /tmp/l3l4_classifier_table_ipv6.txt
    Sleep    2            reason=Wait until terminal execute the command
    ${ctable_ipv6}=       SSHLibrary.Read
    Should Not Contain    ${ctable_ipv6}    sys_teid
    [Teardown]            SSHLibrary.Close Connection

Check Nft Ruleset T5
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login      toor4nsn  oZPS0POrRieRtu
    Sleep    5            reason=Wait until terminal execute the command

    SSHLibrary.Write      nft list table "ip filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP4}=           SSHLibrary.Read

    Should Contain        ${setsIP4}    ${xnc_ipv4_1}
    Should Contain        ${setsIP4}    ${xnc_ipv4_2}
    Should Contain        ${setsIP4}    ${amfIPv4_1}
    Should Contain        ${setsIP4}    ${amfIPv4_2}

    SSHLibrary.Write      nft list table "ip6 filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP6}=           SSHLibrary.Read
    Should Contain        ${setsIP6}    ${xnc_ipv6_1}
    Should Contain        ${setsIP6}    ${xnc_ipv6_2}
    Should Contain        ${setsIP6}    ${amfIPv6_1}
    Should Contain        ${setsIP6}    ${amfIPv6_2}

    SSHLibrary.Write      nft list chain "ip filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip4}=            SSHLibrary.Read
    Should Contain        ${cpTip4}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip4}=          SSHLibrary.Read
    Should Contain        ${ngxnCip4}    ${xnc_ipv4_1}
    Should Contain        ${ngxnCip4}    ${xnc_ipv4_2}
    Should Contain Any    ${ngxnCip4}    counter packets 1    counter packets 2    counter packets 3
    ...                                  counter packets 4    counter packets 5    counter packets 6
    ...                                  counter packets 7    counter packets 8    counter packets 9

    SSHLibrary.Write      nft list chain "ip6 filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip6}=            SSHLibrary.Read
    Should Contain        ${cpTip6}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip6 filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip6}=          SSHLibrary.Read
    Should Contain        ${ngxnCip6}    ${xnc_ipv6_1}
    Should Contain        ${ngxnCip6}    ${xnc_ipv6_2}
    [Teardown]            SSHLibrary.Close Connection

Check Nft Ruleset T6
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login      toor4nsn  oZPS0POrRieRtu
    Sleep    5            reason=Wait until terminal execute the command

    SSHLibrary.Write      nft list table "ip filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP4}=           SSHLibrary.Read

#    Should Contain        ${setsIP4}    ${ngc_ipv4_1}
#    Should Contain        ${setsIP4}    ${ngc_ipv4_2}
    Should Contain        ${setsIP4}    ${amfIPv4_1}
    Should Contain        ${setsIP4}    2.1.1.3

    SSHLibrary.Write      nft list table "ip6 filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP6}=           SSHLibrary.Read
#    Should Contain        ${setsIP6}    ${ngc_ipv6_1}
#    Should Contain        ${setsIP6}    ${ngc_ipv6_2}
    Should Contain        ${setsIP6}    2a00:8a00:6000:607c::24
    Should Contain        ${setsIP6}    2a00:8a00:6000:607c::25

    SSHLibrary.Write      nft list chain "ip filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip4}=            SSHLibrary.Read
    Should Contain        ${cpTip4}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip4}=          SSHLibrary.Read
    Should Contain        ${ngxnCip4}    ${ngc_ipv4_1}
    Should Contain        ${ngxnCip4}    ${ngc_ipv4_2}
    Should Contain Any    ${ngxnCip4}    counter packets 1    counter packets 2    counter packets 3
    ...                                  counter packets 4    counter packets 5    counter packets 6
    ...                                  counter packets 7    counter packets 8    counter packets 9

    SSHLibrary.Write      nft list chain "ip6 filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip6}=            SSHLibrary.Read
    Should Contain        ${cpTip6}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip6 filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip6}=          SSHLibrary.Read
    Should Contain        ${ngxnCip6}    ${ngc_ipv6_1}
    Should Contain        ${ngxnCip6}    ${ngc_ipv6_2}
    [Teardown]            SSHLibrary.Close Connection

Check Nft Ruleset T7
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login      toor4nsn  oZPS0POrRieRtu
    Sleep    5            reason=Wait until terminal execute the command

    SSHLibrary.Write      nft list table "ip filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP4}=           SSHLibrary.Read

    Should Not Contain        ${setsIP4}    ${xnc_ipv4_1}
    Should Not Contain        ${setsIP4}    ${xnc_ipv4_2}
    Should Not Contain        ${setsIP4}    ${amfIPv4_2}

    SSHLibrary.Write      nft list table "ip6 filter" | grep elements
    Sleep    2            reason=Wait until terminal execute the command
    ${setsIP6}=           SSHLibrary.Read
    Should Not Contain        ${setsIP6}    ${xnc_ipv6_1}
    Should Not Contain        ${setsIP6}    ${xnc_ipv6_2}
    Should Not Contain        ${setsIP6}    ${amfIPv6_1}
    Should Not Contain        ${setsIP6}    ${amfIPv6_2}

    SSHLibrary.Write      nft list chain "ip filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip4}=            SSHLibrary.Read
    Should Contain        ${cpTip4}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip4}=          SSHLibrary.Read
#    Should Not Contain        ${ngxnCip4}    ${xnc_ipv4_1}  comment=Commented due to diff between SW. Will be checked in preinv if bug or feature
#    Should Not Contain        ${ngxnCip4}    ${xnc_ipv4_2}  comment=Commented due to diff between SW. Will be checked in preinv if bug or feature
    Should Contain Any    ${ngxnCip4}    counter packets 1    counter packets 2    counter packets 3
    ...                                  counter packets 4    counter packets 5    counter packets 6
    ...                                  counter packets 7    counter packets 8    counter packets 9

    SSHLibrary.Write      nft list chain "ip6 filter" CP_TRAFFIC_5G
    Sleep    2            reason=Wait until terminal execute the command
    ${cpTip6}=            SSHLibrary.Read
    Should Contain        ${cpTip6}    NGXN_CHAIN
    SSHLibrary.Write      nft list chain "ip6 filter" NGXN_CHAIN
    Sleep    2            reason=Wait until terminal execute the command
    ${ngxnCip6}=          SSHLibrary.Read
#    Should Not Contain        ${ngxnCip6}    ${xnc_ipv6_1}   comment=Commented due to diff between SW. Will be checked in preinv if bug or feature
#    Should Not Contain        ${ngxnCip6}    ${xnc_ipv6_2}   comment=Commented due to diff between SW. Will be checked in preinv if bug or feature
    [Teardown]            SSHLibrary.Close Connection

Check Fake Nft Ruleset
    Download Nft Ruleset
    Log    Checking If Correct Addresses Are Present    console=True
    nft.Supplement Address v6    nft_list_ruleset
    nft.Check Classifier Table v4
    nft.Check Classifier Table v6
    Log    Correct Addresses Are Not Present    console=True

Perform Nmap Scan
    Log    Perform Nmap Scan For Addresses    console=True
    ${ipsv4}=    func.Get All Ipv4 Addresses
    ${ipsv6}=    func.Get All Ipv6 Addresses
    ${nmap_list}=    nmap.Gather Nmaps    ${ipsv4}    ${ipsv6}
    nmap.Check Nmap Results    ${nmap_list}

Perform Robustness Test
    [Arguments]    ${locXnCTnl1v4}    ${locNgCTnl1v6}    ${remXnCTnl1v4}    ${remNgCTnl1v6}
    Wait Until Keyword Succeeds    3x    1min   Insert nft Rule
    ...    ip_ver=ipv4    remote_addr=${remXnCTnl1v4}    local_addr=${locXnCTnl1v4}    sport=38422    dport=38422
    Wait Until Keyword Succeeds    3x    1min   Insert nft Rule
    ...    ip_ver=ipv6    remote_addr=${remNgCTnl1v6}    local_addr=${locNgCTnl1v6}    sport=38412    dport=38412
    ${rule_v4_id}=    Get Firewall Rule Handle ID Number    ip_ver=ipv4    remote_addr=${remXnCTnl1v4}    local_addr=${locXnCTnl1v4}
    ${rule_v6_id}=    Get Firewall Rule Handle ID Number    ip_ver=ipv6    remote_addr=${remNgCTnl1v6}    local_addr=${locNgCTnl1v6}
    Wait Until Keyword Succeeds    3x    1min    Delete Firewall Rule By Handle ID Number
    ...   ip_ver=ipv4    rule_id=${rule_v4_id}
    Wait Until Keyword Succeeds    3x    1min    Delete Firewall Rule By Handle ID Number
    ...   ip_ver=ipv6    rule_id=${rule_v6_id}

Verify Robustness Test
    Verify If Firewall Process Is Running
    Verify If XNLINK And NRADJGNB Objects Exists On BTS

Get Pcap Output
    [Arguments]    ${pcap_file}    ${tshark_filter}
    func.Get Pcap Packets    pcap_file=${pcap_file}    tshark_filter=${tshark_filter}

Prepare And Attach UEs
    [Arguments]    ${pdu_number}    ${ue_alias}    ${ue_operator}
    Power Reset UE    pdu_number=${ue_pdu_port}
    Power Reset UE    pdu_number=${ue_pdu_port}

    Wait Until keyword Succeeds    5x    30 s    Prepare And Attach UE
    ...    pdu_number=${pdu_number}    ue_alias=${ue_alias}=   capabilities=${ue_operator}

Get iptables Output
    ${iptables_output}=   nft.Execute SSH Command
    ...     ip=${SSH_IP}
    ...     command=iptables -nvL CP_TRAFFIC_5G | grep ACCEPT
    @{output_list}=    Split String    ${iptables_output}
    @{contain_list}=    Create List    ACCEPT  sctp  --  *  *  0.0.0.0/0  0.0.0.0/0  sctp  spt:36422  dpt:36422
    Should Contain    ${output_list}    ${contain_list}

Get ip6tables Output
    ${iptables_output}=   nft.Execute SSH Command
    ...     ip=${SSH_IP}
    ...     command=ip6tables -nvL CP_TRAFFIC_5G | grep ACCEPT
    @{output_list}=    Split String    ${iptables_output}
    @{contain_list}=    Create List    ACCEPT  sctp  *  *  ::/0  ::/0  sctp  spt:36422  dpt:36422
    Should Contain    ${output_list}    ${contain_list}

Pretty Log Dict
    [Arguments]    ${data}
    Log Dictionary    ${data}

Pretty Log List
    [Arguments]    ${data}
    Log List    ${data}

Adjust NRADJGB objects
    ${connection}=                       Connect To Admin
    ${state}=                            Get current BTS state    ${connection}
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-1
    ...                                  xnLinkRef=2
    ...                                  xnLinkRef2=4
    ...                                  skip_parameter_relation_errors=${TRUE}
    ...                                  connection=${connection}
    Wait Until Keyword Succeeds          10 min  20sec     Check if BTS in given state
    ...                                  state=${state}    connection=${connection}
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRADJGNB-2
    ...                                  xnLinkRef=1
    ...                                  xnLinkRef2=3
    ...                                  skip_parameter_relation_errors=${TRUE}
    ...                                  connection=${connection}
    Wait Until Keyword Succeeds          10 min  20sec     Check if BTS in given state
    ...                                  state=${state}    connection=${connection}
    [Teardown]                           Disconnect from ADMIN    ${connection}

Delete NRADJGNB Objects
    ${empty_list}=    Create List
    Manage Object     object_name=NRADJGNB-1    parameter=${empty_list}    operation=delete
    Manage Object     object_name=NRADJGNB-2    parameter=${empty_list}    operation=delete

Check if LTEENB object exists
    ${status}=         Check if Object Exists in Scf File
    ...                dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                object_name=LTEENB
    Should be True    '${status}' == 'True'

Check if firewall filters are correct
    [Arguments]       ${NGC_addr}    ${XNC_addr}    ${X2C_addr}
    ${ssh_conn}=      Connect to BTS
    ${elements}=      ssh.execute    command=nft list table "ip filter" | grep elements    connection=${ssh_conn}
    Should Contain    ${elements}    ${NGC_addr}
    Should Contain    ${elements}    ${XNC_addr}
    Should Contain    ${elements}    ${X2C_addr}
    ${ngxn}=          ssh.execute    command=nft list chain ip filter NGXN_CHAIN    connection=${ssh_conn}
    Should Contain    ${ngxn}    ngCplaneRemoteIpAddrList
    Should Contain    ${ngxn}    xnCplaneRemoteIpAddrList
    Should Contain    ${ngxn}    x2Cplane5gRemoteIpAddrList
    [Teardown]        Disconnect from BTS    ${ssh_conn}

Check if firewall filters contain NGC address
    [Arguments]       ${NGC_addr}
    ${ssh_conn}=      Connect to BTS
    ${elements}=      ssh.execute    command=nft list table "ip filter" | grep elements    connection=${ssh_conn}
    Should Contain    ${elements}    ${NGC_addr}
    [Teardown]        Disconnect from BTS    ${ssh_conn}
