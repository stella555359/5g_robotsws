*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Nandini P"
...     [Function_Hash_Tags]            "L2_QOS"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown
#Suite Setup                    Setup Oamops
#Suite Teardown    Teardown oamops
***Test Cases***
[1][1.0] TRS_5GC000519C_Flush_forwarding_database_on_LOS
        Perform Commissioning       scf_file=${519_comm_flush_db}   verify_bts_status=False     timeout=400     alias=default
        Sleep    400
        ${gw_157}=      Get Parameter   param_path=IPNO-1/IPRT-1:staticRoutes:gateway
        Set Suite variable      ${gw_157}
        Test Scenario for eif ports     14  1
        Perform Recommissioning     type=param      rat=5g     param_path=${eif2_moc}  operation=update    value=${unlock}     timeout=300
        Sleep   10
        Test Scenario for eif ports     15  2
        Perform Recommissioning     type=param      rat=5g     param_path=${eif1_moc}  operation=update    value=${unlock}     timeout=300
        Check for fdb entries '${DU_eif1_port}'
        Delete ETHLK-1 moc
        Check for fdb entries '${DU_eif1_port}'
        [Teardown]      Keywords to run at end

***Keywords***
Keywords to run at end
        Bring up interface_1
        Bring up interface_2
        Change Ethernet port security       enable=${False}   timeout=120

Bring up interface_1
    Configure switch        DTOR_switch      shutdown_port
    Sleep  40
Bring up interface_2
    Configure switch        DTOR_switch      shutdown_port
    Sleep  40

fdb entries should be cleared '${internal_port}'
        Setup Remote Access    remote_device=bts
        ${stdout}       Remote Command Execute      command=dbgrrc show mac | awk '$2=="${internal_port}" && $2=="Dynamic" {print $1}'

        Should Be Empty     ${stdout}
        Teardown remote Access

Check for fdb entries '${internal_port}'
        Setup Remote Access    remote_device=bts
        ${stdout}       Remote Command Execute      command=dbgrrc show mac | awk '{ if($4 =="'${internal_port}'" && $2=="Dynamic") { print $1}}'
        Should not Be Empty     ${stdout}
        Teardown remote Access

Delete ETHLK-1 moc
        Perform Recommissioning     type=delta      rat=lte    delta_file=delete_ethlk_1.xml     timeout=30
verify LOS alarm
        verify alarm        faultid=61029
verify LOS alarm is cleared
        verify alarm        faultid=61029     should_exist=${False}

Bring up interface
        Configure switch        DTOR_switch      bringup_port
        Sleep  40

Shutdown eif
#        [Arguments]     ${port_no}  ${bh_interface}
        Configure switch        DTOR_switch      shutdown_port
        Sleep  40

Perform ping test
        Setup Remote Access    remote_device=bts
       ${stdout}       Remote Command Execute      command=ping -c 5 ${gw_157}
       Teardown remote Access
       Should contain       ${stdout}    5 packets transmitted, 5 received


Test Scenario for eif ports
        [Arguments]     ${internal_port}    ${port_no}
        Check for fdb entries '${internal_port}'
        Shutdown eif
        verify LOS alarm
        Check for fdb entries '${internal_port}'
        Sleep   15
        Perform ping test
        Perform Recommissioning     type=param      rat=5g     param_path=${eif${port_no}_moc}  operation=update    value=${lock}     timeout=300
        Check for fdb entries '${internal_port}'
        Perform Recommissioning     type=param      rat=5g    param_path=${flushdb_flag}  operation=update    value=true     timeout=300
        fdb entries should be cleared '${internal_port}'
        Perform Recommissioning     type=param      rat=l5g     param_path=${eif${port_no}_moc}  operation=update    value=${unlock}     timeout=300
        Sleep   10
        Check for fdb entries '${internal_port}'
        Sleep   60
        Perform ping test
        Shutdown eif
        verify LOS alarm
        fdb entries should be cleared '${internal_port}'
        Bring up interface
        verify LOS alarm is cleared
        Sleep   15
        Perform ping test
        Check for fdb entries '${internal_port}'
        Perform Recommissioning     type=param      rat=5g     param_path=${eif${port_no}_moc}  operation=update    value=${lock}     timeout=300
        fdb entries should be cleared '${internal_port}'
        Perform Recommissioning     type=param      rat=5g     param_path=${flush_db_flag}  operation=update    value=false     timeout=300
        Sleep  20
