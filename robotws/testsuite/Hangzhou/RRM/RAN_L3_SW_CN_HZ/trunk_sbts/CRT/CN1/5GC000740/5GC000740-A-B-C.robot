*** Settings ***
Suite Setup    Suite Setup With IPV6
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC000740
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{5GC000740_flag}    @{MultiAMF}    @{PLMN}    @{SNSSAI}    @{TRACKINGAREA}    @{IPV4_IPV6}    @{timer}

@{5GC000740_flag}
...    NRBTS-1:actNgcFlexSaMode=true

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-3:amfIPAddress=fc00:0:0:0:10:0:1:103
...    SERVEDAMF-3:administrativeState=Unlocked

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{IPV4_IPV6}
...    NRBTS-1:ngCplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS-1:ngCplane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpAddr=10.0.1.2
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1:localIpPrefixLength=24
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpAddr=fc00:0:0:0:10:0:1:2
...    TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpPrefixLength=112

@{timer}
...    NRBTS-1:waitForRecovBeforeCellBarringTimer=10
...    delete:NRBTS-1:ngInducedCellDeactDelayTimer
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=120

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{all_amf_lock}    SERVEDAMF-1:administrativeState=Locked    SERVEDAMF-2:administrativeState=Locked    SERVEDAMF-3:administrativeState=Locked
@{all_amf_unlock}    SERVEDAMF-1:administrativeState=Unlocked    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-3:administrativeState=Unlocked
@{amf2_unlock}    SERVEDAMF-2:administrativeState=Unlocked

@{fault_7304}    fault_id=7304    fault_name=NG SCTP endpoint broken

@{PM_Counters}
...    NRBTS-1:${NG_SHUTDOWN_LOCKED}=3
...    NRBTS-1:${NG_CU_SETUP_REQUEST_SENT}=3
...    NRBTS-1:${NG_CU_SETUP_RESPONSE_RCV}=3
${NG_SHUTDOWN_LOCKED}    M55119C00501    #Number of SCTP shutdown due to lock
${NG_CU_SETUP_REQUEST_SENT}    M55119C00001    #Number of NGAP:NG Setup Request messages sent by gNB-CU
${NG_CU_SETUP_RESPONSE_RCV}    M55119C00002    #Number of NGAP:NG Setup Response messages received by gNB-CU

*** Test Cases ***
5GC000740-ET-C041_Verify_Relative_AMF_Capacity_IE_and_list_of_GUAMIs_are_supported_in_NGAP_NG_Setup_procedure_between_one_gNB_and_several_AMFs
    [Documentation]
    ...    1. This user scenario describes the successful SCTP associations setup between one gNB and several AMFs. The NG-C IP addresses of AMFs
    ...       are configured by OAM system. The IP addresses can be IPv4 or IPv6 based
    ...    2. This case designed to verify the guami list and AMF capacity in NG Setup Response message.
    ...    3. This user scenario describes the locking of a NG-C link by operator and the impacts on gNB Cells state
    ...    4. This user scenario describes the gNB startup with all NG-C links locked
    ...    5. This user scenario describes the unlocking of a locked NG-C link by operator
    ...    6. This user scenario describes the unlocking of all locked NG-C links by operator
    [Tags]    QC_47210    5GC000740-A-ET003    5GC000740-B-ET007    5GC000740-B-ET010    5GC000740-B-ET011    5GC000740-B-ET013    5GC000740-B-ET014
    ...    5GC000740-B-ET018    5GC000740-B-ET019    5GC000740-B-ET023    5GC000740-C-ET041    5GC000740-C-ET042    5GC000740-C-ET044
    ...    5GC000740-C-ET048    EDA-PR633273    EDA-PR636013_EDA-PR772818
    Check ipv4 and ipv6 NG link are up
    SA UE Register
    Change AMF status and Check Nglinks status    amf_status=${all_amf_lock}    amf1=Inactive    amf2=Inactive    amf3=Inactive    cell_barred=barred
    Check Counter and RRC released
    gNB restart with all NGlinks Locked
    Change AMF status and Check Nglinks status    amf_status=${amf2_unlock}    amf1=Inactive    amf2=Active    amf3=Inactive    cell_barred=unbarred
    gNB restart with NGlinks unlocked
    SA UE Register    cmd_regexp=AMF-2:.* now Registered
    Release UEs    ue_type=all
    Change AMF status and Check Nglinks status    amf_status=${all_amf_unlock}
    only one NG assocation is setup to the main AMF
    ErrorIndication when main AMF is Inactive    #EDA-PR636013 -> EDA-PR772818
    main AMF is Active after Lock Unlock    #EDA-PR633273

*** Keywords ***
Modify Cfg
    #ipv6
    Update Cfg Param    set_gnb id=2 ng=10.0.1.2,fc00::10:0:1:2
    # other
    Update Cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_amf_region id=1 tac_list=200 plmn=311:489,311:402
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=1 pointer=1
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=fc00::10:0:1:103.38412 region=3 set_id=1 pointer=1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=50 include_backup_amf_name=off
    Update Cfg    amf_ng_setup_param id=2 relative_capacity=100
    Update Cfg    amf_ng_setup_param id=3 relative_capacity=10
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 ue=all amf=1-3 default=on

Suite Setup With IPV6
    Execute Cmd On Pc    sudo ip addr add fc00::10:0:1:103/112 dev eth3
    Common Suite Setup And Setup Airphone Env

Perform Steps After Onair
    check wireshark log    ${CURDIR}/a2a_C041/a2a.ini    wait_string=NGSetupResponse::6

only one NG assocation is setup to the main AMF
    ${params}    create list    NRBTS-1:actNgcFlexSaMode=false    NRPMRNL-1:miNrNgcFlexInterface=disabled
    delta commission parameters    ${params}
    object should exist    NRCELL-1:barringStatus=unbarred
    object should exist    NRCELL-2:barringStatus=unbarred
    object should exist    SERVEDAMF-1:ngLinkStatus=Active
    object should exist    SERVEDAMF-2:ngLinkStatus=Inactive
    object should exist    SERVEDAMF-3:ngLinkStatus=Inactive

Check ipv4 and ipv6 NG link are up
    object should exist    SERVEDAMF-1:ngLinkStatus=Active
    object should exist    SERVEDAMF-2:ngLinkStatus=Active
    object should exist    SERVEDAMF-3:ngLinkStatus=Active

SA UE Register
    [Arguments]    ${cmd_regexp}=NG RM Register
    Execute Egate Command    ue_register id=1    ${cmd_regexp}

Check Counter and RRC released
    rrc should contain    UE1: detached
    Check Counters    ${PM_Counters}

Change AMF status and Check Nglinks status
    [Arguments]    ${amf_status}=none    ${amf1}=Active    ${amf2}=Active    ${amf3}=Active    ${cell_barred}=unbarred
    delta commission parameters    ${amf_status}
    object should exist    SERVEDAMF-1:ngLinkStatus=${amf1}
    object should exist    SERVEDAMF-2:ngLinkStatus=${amf2}
    object should exist    SERVEDAMF-3:ngLinkStatus=${amf3}
    object should exist    NRCELL-1:barringStatus=${cell_barred}
    object should exist    NRCELL-2:barringStatus=${cell_barred}
    cells should be onair    check_sib=${False}

gNB restart with all NGlinks Locked
    Reset Site
    cells should be onair    check_sib=${False}
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    SERVEDAMF-2:ngLinkStatus=Inactive
    object should exist    SERVEDAMF-3:ngLinkStatus=Inactive
    object should exist    NRCELL-1:barringStatus=barred
    object should exist    NRCELL-2:barringStatus=barred

gNB restart with NGlinks unlocked
    Reset Site
    cells should be onair
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    SERVEDAMF-2:ngLinkStatus=Active
    object should exist    SERVEDAMF-3:ngLinkStatus=Inactive

ErrorIndication when main AMF is Inactive
    # Trigger NG SCTP link broken
    execute command on enb    iptables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
    execute command on enb    ip6tables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
    fm fault should be raised    ${fault_7304}    timeout=180
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive
    # NG SCTP recovery
    execute command on enb    iptables -t filter -F OUTPUT
    execute command on enb    ip6tables -t filter -F OUTPUT
    fm fault should be cleared    ${fault_7304}    timeout=180
    object should exist    SERVEDAMF-1:ngLinkStatus=Active
    rrc should not contain    NgAP:ERROR_INDICATION

main AMF is Active after Lock Unlock
    delta commission parameters    NRBTS-1:actNgcFlexSaMode=true
    ${all_amf_Active}    create list    SERVEDAMF-1:ngLinkStatus=Active    SERVEDAMF-2:ngLinkStatus=Active    SERVEDAMF-3:ngLinkStatus=Active
    ${lock_all_amf}    create list    SERVEDAMF-1:administrativeState=Locked    SERVEDAMF-2:administrativeState=Locked
    ...    SERVEDAMF-3:administrativeState=Locked
    ${unlock_all_amf}    create list    SERVEDAMF-1:administrativeState=Unlocked    SERVEDAMF-2:administrativeState=Unlocked
    ...    SERVEDAMF-3:administrativeState=Unlocked
    object should exist    ${all_amf_Active}
    delta commission parameters    ${lock_all_amf}
    delta commission parameters    ${unlock_all_amf}
    object should exist    ${all_amf_Active}
