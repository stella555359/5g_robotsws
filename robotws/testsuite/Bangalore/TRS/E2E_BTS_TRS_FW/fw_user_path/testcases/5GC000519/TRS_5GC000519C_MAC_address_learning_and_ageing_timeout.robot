*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Nandini P"
...     [Function_Hash_Tags]            "IPV6_Mplane"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown
#Suite Setup                    Setup Oamops
#Suite Teardown    Teardown oamops
***Test Cases***
[1]TRS_5GC000519C_MAC_address_learning_and_ageing_timeout
        Initial configuration
        ${gw_mac}=      Get Parameter   param_path=IPNO-1/IPRT-1:staticRoutes:gateway
        Set Suite variable      ${gw_mac}
        FDB entry for vlan '${vlan_id}' is added on '${DU_eif1_port}'
        Check for fdb entries '${DU_eif1_port}'
        Shutdown vlan on BH interface of switch
        Sleep   600
        FDB entry for vlan '${vlan_id}' is cleared on '${DU_eif1_port}'
        Bringup vlan on BH interface of switch
        Sleep   600
        FDB entry for vlan '${vlan_id}' is added on '${DU_eif1_port}'
        Sleep   30
        Perform ping test
        Shutdown vlan on BH interface of switch
        Bringup vlan on BH interface of switch
        Perform Recommissioning     type=param      rat=5g     param_path=${eif2_moc}  operation=update    value=${unlock}     timeout=300
        Sleep   100
        FDB entry for vlan '${vlan_id}' is added on '${DU_eif2_port}'
        FDB entry for vlan '${vlan_id}' is cleared on '${DU_eif1_port}'
        Sleep   200
        Perform ping test
       [Teardown]      Keywords to run at end

***Keywords***
Keywords to run at end
        Bringup vlan on BH interface of switch
        Shutdown vlan on BH interface of switch

Initial configuration
        Perform Commissioning       scf_file=${519_comm_flush_db}   verify_bts_status=False     timeout=400     alias=default
        Sleep    900
        Shutdown vlan on BH interface of switch

Shutdown vlan on BH interface of switch
        Configure switch        DTOR_switch      shutdown_vlan

Bringup vlan on BH interface of switch
        Configure switch        DTOR_switch      bringup_vlan

FDB entry for vlan '${vlan}' is cleared on '${internal_port}'
        Execute command on gNB      dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic" && $3=="${vlan}") { print $1}}'
        Should Be Empty     ${stdout}
        Execute command on gNB      dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic" && $3=="${vlan}") { print $1}}'|wc -l
        Should Be equal   ${stdout}   0

FDB entry for vlan '${vlan}' is added on '${internal_port}'
        Execute command on gNB      dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic" && $3=="${vlan}") { print $1}}'
#`        Execute command on gNB      dbgrrc show mac | grep  Dynamic | grep 2202
        Should not Be Empty     ${stdout}
        Execute command on gNB     dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic" && $3=="${vlan}") { print $1}}'|wc -l
        Should Be equal   ${stdout}   1

fdb entries should be cleared '${internal_port}'
        Execute command on gNB       dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic") { print $1}}'
        Should Be Empty     ${stdout}
        Execute command on gNB       dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic") { print $1}}' |wc -l
        Should Be Equal    ${stdout}      0

Check for fdb entries '${internal_port}'
        Execute command on gNB      dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic") { print $1}}'
        Should not Be Empty     ${stdout}
        Execute command on gNB      dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic") { print $1}}'|wc -l
        Should Be True      ${stdout}>1

Delete ETHLK-1 moc
        Perform Recommissioning     type=delta      rat=lte    delta_file=delete_ethlk_1.xml     timeout=30

verify LOS alarm
        verify alarm        faultid=61029

verify LOS alarm is cleared
        verify alarm        faultid=61029     should_exist=${False}

Bring up interface
        Configure switch        DTOR_switch      bringup_port

Shutdown eif port
        Configure switch        DTOR_switch      shutdown_port

Perform ping test
#        Setup Remote Access    remote_device=bts
#       ${stdout}       Remote Command Execute      command=ping -c 5 ${gw}
#       Teardown remote Access
        ${stdout}=        Run     ping -c 5 ${gw_mac}
        Should contain       ${stdout}    5 packets transmitted, 5 received
