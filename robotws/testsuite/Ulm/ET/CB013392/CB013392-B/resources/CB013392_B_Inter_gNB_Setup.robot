*** Settings ***
Documentation    Inter-gNB Setup for subfeature CB013392-B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]



*** Keywords ***

#-----------For basic_setup.cfg Changes----------------------------------------------------------------------------------------------[150 characters]

Add simulated gNB
    wts . Insert    set GNB_XN_ADDR="10.0.1.2"      after    set GNB_X2_ADDR="10.0.1.2"
    wts . Insert    set GNB3_NG_ADDR="10.0.1.140"   after    set GNB_XN_ADDR="10.0.1.2"
    wts . Insert    set GNB3_XN_ADDR="10.0.1.141"   after    set GNB3_NG_ADDR="10.0.1.140"
    wts . Insert    set GNB3_XP_ADDR="10.0.1.141"   after    set GNB3_XN_ADDR="10.0.1.141"
    #--- real-gNB -------------------------------------------------------------------------------------------------------------------[150 characters]
    wts . Modify    set_gnb id=2   xn=$GNB_XN_ADDR gnb_id=0x01:22 xp_management=on xp=$GNB_X2_ADDR:32742 xpu=$GNB_X2_ADDR:32742
    #--- sim-gNB --------------------------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}    catenate    set_gnb id=3 type=simulated plmn=311:489 xn=$GNB3_XN_ADDR ng=$GNB3_NG_ADDR gnb_id=0x03:22
    ...                   daemon=$DAEMON_IP:$DAEMON_PORT x2_peers=none amf=1 nssai=0x1:0xd143a5
    ...                   xp=$GNB3_XP_ADDR:32742 xpu=$GNB3_XP_ADDR:32742 xp_management=on
    wts . Insert    ${cmd}     after   set_cell id=12 gnb=2
    wts . Insert    gnb_param id=3 send_xn_setup=false sib1_period=40 xn_listening_socket=on    after   set_gnb id=3
    ${cmd}    catenate    set_cell id=31 gnb=3 pci=20:0 tac=200 nrci=0x1F tdd_cell=off proxy=$GNB3_NG_ADDR:9999
    ...                   nr_arfcn=376500:392500 gscn=4907 nr_scs=15kHz bs_channel_bandwidth=10MHz
    wts . Insert    ${cmd}    after   gnb_param id=3
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts . Modify    set_ue simulated id=1   release=17
    wts . Insert    trace enb=3 protocol=x2 on        after   trace enb=1 protocol=x2 on
    wts . Insert    sim_trace enb=3 protocol=xn on    after   trace enb=3 protocol=x2 on
    wts . Insert    sim_trace enb=3 protocol=ng on    after   sim_trace enb=3 protocol=xn on



#-----------For scf.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Perform FULL Commissioning in order to enable Inter-gNB Functionality
    Create IPs for simulated gNB on VM
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.load_scf    ${original_gnb_scf}
        Create NRADJGNB    gNodeBId=3
        Create NRADJNRCELLs    gNodeBId=3    lcrId=31
        Create XNLINK
        Add NRREL to simulated gNB    pcell_id=11    scell_lcrId=31    dir=dlOnly    nrrel_id=1
        Configure PCell for Inter-gNB CA    pcell_id=11
        Create XPAP
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    Perform Commissioning on Classical BTS    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    log to console  Sleep 5min and "Wait for Cplan to be ready before continuing"
    sleep  10min  reason=Wait for Cplan to be ready before continuing.


Add NRREL to simulated gNB
    [Arguments]  ${pcell_id}  ${scell_lcrId}  ${dir}  ${nrrel_id}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRREL}=  Set variable  ${distName_NRBTS[0]}/NRCELL-${pcell_id}/NRREL-${nrrel_id}
    Set Object    class_name=com.nokia.srbts.nrbts:NRREL
    ...           dist_name=${distName_NRREL}
    ...           version=NRBTSCL23R4_2312_101
    FOR    ${p_name}                                         ${value}    IN
    ...    cellIndividualSsbRsrpOffset                       0dB
    ...    cellIndividualSsbRsrqOffset                       0dB
    ...    gNbId                                             3
    ...    gNbIdLength                                       22
    ...    handoverAllowedSA                                 forbidden
    ...    handoverAllowedSARedCap                           forbidden
    ...    isRplCellForPSCell                                false
    ...    lcrId                                             ${scell_lcrId}
    ...    nrDcAllowed                                       false
    ...    removeNotAllowed                                  false
    ...    sCellAdditionMethod                               blind
    ...    sCellOperationalMode                              ${dir}
        Set Element    dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Configure PCell for Inter-gNB CA
    [Arguments]  ${pcell_id}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRCELL}=  Set variable  ${distName_NRBTS[0]}/NRCELL-${pcell_id}
    FOR    ${p_name}                                         ${value}    IN
    ...    actK1Opt                                          intraAndInter-gNB
        Set Element    dist_name=${distName_NRCELL}    p_name=${p_name}    value=${value}
    END


Create IPs for simulated gNB on VM
    Log To Console    Create IPs 10.0.1.140, 10.0.1.141 and 10.0.1.121 on VM eth3
    Configure IP on VM    ip=10.0.1.140      interface=eth3
    Configure IP on VM    ip=10.0.1.141      interface=eth3
    Configure IP on VM    ip=10.0.1.121      interface=eth3


Perform Commissioning on Classical BTS
    [Arguments]  ${scf_file}
    ${oam_alias}=  connect . Setup OAM http session
    admin . Perform Commissioning    scf_file=${scf_file}
    ...                              connection=${oam_alias}
    ...                              skip_parameter_relation_errors=True
    ...                              timeout=600
    connect . Teardown OAM http session


Create NRADJGNB
    [Arguments]  ${gNodeBId}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRADJGNB}=  Set variable  ${distName_NRBTS[0]}/NRADJGNB-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRADJGNB
    ...           dist_name=${distName_NRADJGNB}
    ...           version=NRBTSCL25R1_2420_110
    FOR    ${p_name}                                         ${value}    IN
    ...    administrativeState                               Unlocked
    ...    gNbIdLength                                       22
    ...    gNodeBId                                          ${gNodeBId}
    ...    gNodeBIdCtrl                                      oamControlled
    ...    weightForIgnbCaSelection                          1
    ...    xnLinkRef                                         1
        Set Element    dist_name=${distName_NRADJGNB}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRADJGNB}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRADJGNB}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Create NRADJNRCELLs
    [Arguments]  ${gNodeBId}  ${lcrId}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRADJNRCELL}=  Set variable  ${distName_NRBTS[0]}/NRADJNRCELL-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRADJNRCELL
    ...           dist_name=${distName_NRADJNRCELL}
    ...           version=NRBTSCL25R1_2420_110
    FOR    ${p_name}                                         ${value}    IN
    ...    cellDepType                                       SA
    ...    cellReservedForOperatorUse                        notReserved
    ...    fiveGsTac                                         200
    ...    freqBandIndicatorNR                               25
    ...    gNbId                                             ${gNodeBId}
    ...    gNbIdLength                                       22
    ...    lcrId                                             ${lcrId}
    ...    nrarfcn                                           392500
    ...    physCellId                                        60
    ...    ssbFrequency                                      392650
        Set Element    dist_name=${distName_NRADJNRCELL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRADJNRCELL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRADJNRCELL}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Create XNLINK
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_XNLINK}=  Set variable  ${distName_NRBTS[0]}/XNLINK-1
    Set Object    class_name=com.nokia.srbts.nrbts:XNLINK
    ...           dist_name=${distName_XNLINK}
    ...           version=NRBTSCL25R1_2420_110
    FOR    ${p_name}                                         ${value}    IN
    ...    cPlaneIpAddr                                      10.0.1.141
    ...    cPlaneIpAddrCtrl                                  oamControlled
        Set Element    dist_name=${distName_XNLINK}    p_name=${p_name}    value=${value}
    END


Create XPAP
    ${distName_MNLENT}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/MNL-[0-9]+/MNLENT-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_XPAP}=  Set variable  ${distName_MNLENT[0]}/XPAP-1
    Set Object    class_name=com.nokia.srbts.mnl:XPAP
    ...           dist_name=${distName_XPAP}
    ...           version=MNL25R1_2420_101
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_XPIF}=  Set variable  ${distName_MNLENT[0]}/XPAP-1/XPIF-1
    Set Object    class_name=com.nokia.srbts.mnl:XPIF
    ...           dist_name=${distName_XPIF}
    ...           version=MNL25R1_2420_101
    FOR    ${p_name}                                         ${value}    IN
    ...    ipV4AddressDN1                                    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
    ...    localNeDN                                         MRBTS-1/NRBTS-1
    ...    sctpAssocMaxRetrans                               7
    ...    sctpDscp                                          46
    ...    sctpHeartbeatInterval                             20
    ...    sctpMaxPayloadSize                                1395
    ...    sctpRtoMax                                        30000
    ...    sctpRtoMin                                        1000
    ...    sctpSackDelay                                     200
    ...    sctpSackFreq                                      2
    ...    sctpWaitTimeInitSeqRetry                          240
    ...    udpDscp                                           18
        Set Element    dist_name=${distName_XPIF}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_XPIFREMOTE}=  Set variable  ${distName_MNLENT[0]}/XPAP-1/XPIF-1/XPIFREMOTE-1
    Set Object    class_name=com.nokia.srbts.mnl:XPIFREMOTE
    ...           dist_name=${distName_XPIFREMOTE}
    ...           version=MNL25R1_2420_101
    FOR    ${p_name}                                         ${value}    IN
    ...    ipAddress                                         10.0.1.141
    ...    remoteNeType                                      GNB
        Set Element    dist_name=${distName_XPIFREMOTE}    p_name=${p_name}    value=${value}
    END
