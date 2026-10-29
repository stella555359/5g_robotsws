*** Settings ***
Documentation     [PURPOSE]
Library    taf.sbts.oam.coam.admin	    WITH NAME	admin
library    taf.hw.pdu	    WITH NAME	pdu
library    SSHLibrary
Library    OperatingSystem
Library     ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Library     ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/SSHExecutor.py
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot

*** Variables ***
@{allowed_faultd}     4779    61524    4654    4655    61649    61652    4592    49    10    8000

&{defaultNetconfAccount}=    defaultNetconfAccountName=oranuser    defaultNetconfAccountPwd=o-ran-password
&{authentifierSshServer}=    publicKeySshServerFormat=xxx    publicKeySshServerValue=yyy
&{account}=    id=1    targetDN=MRBTS-5344/EQM-1/APEQM-1/RMOD-5    defaultNetconfAccount=&{defaultNetconfAccount}
...    authentifierSshServer=&{authentifierSshServer}
@{accounts}=    ${account}

*** Keywords ***
CB014455 setup
    [Documentation]    Short description.
    Clear SYSLOG
    Set Test Variable    ${TESTLINE_NAME}    10_5_UTESRAN37517
    Set Test Variable   ${release}    SBTS25R3
    Set Test Variable   ${newBTSID}    37517
    Import Variables    /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Import Variables
        ...     /home/ute/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/T05/OAM_SRAN/Variables/${TESTLINE_NAME}.py
    admin.connect to	bts_host=${mplane_IP}
    ${bts_info}=    taf.sbts.oam.coam.admin.get_bts_info
    Set Test Variable    ${nrbts_id}    ${bts_info}[nrBtsId]
    Set Test Variable    ${mrbts_id}    ${bts_info}[mrbtsID]
    ${active_version}=    admin.get_sw_version
    Set Test Variable    ${active_version}
    All Cells Onair
    Log To Console    ${EMPTY}

Clear SYSLOG
    ${output}=    OperatingSystem.Run    ls -l /tmp/btslog2/SYSLOG*|wc -l
    Return From Keyword If    ${output}<=2
    OperatingSystem.Run     ls -t /tmp/btslog2/*|tail -n +3|xargs -r rm --

Site Reset Loop
    FOR    ${index}    IN RANGE    0    200
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        Site Reset via Admin
    END

Site Reset via Admin
    admin.reset_site
    Wait Until Keyword Succeeds  10 min  5 sec    Not All Cells Onair
    Wait Until Keyword Succeeds  10 min  10 sec    All Cells Onair
    ${sleep_in_sec}=    Evaluate    random.randint(0,600)    random
    Verify alarms
    Sleep    ${sleep_in_sec}s
    All Cells Onair
    Verify alarms

Setup for NMS
    taf.nms.netact.Add Node    cmwas    ${tl.nms.ssh_connections_info.addr}    ${tl.nms.ssh_connections_info.username}
    ...    ${tl.nms.ssh_connections_info.password}
    taf.nms.netact.Add Web Url    ${tl.nms.https_main_info.addr}    ${tl.nms.ssh_connections_info.username}
    ...    ${tl.nms.ssh_connections_info.password}
    ${obj}=    admin.Get Managed Objects    MPLANE_L
    ${mplane_ip}=    set variable    ${obj}[0][parameters][ipv4Addr]
    taf.nms.netact.integrate_mrbts_with_netact    release=25R3VDU    mr=MRC-COMMON/MR-COMMON
    ...    mrbts_address=${mplane_ip}    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}
    ...    security_mode=no TLS
    ${output}=    taf.nms.netact.upload_configuration    PLMN-PLMN/MRBTS-${mrbts_id}
    Log    ${output}
    Should Contain    ${output}    Status received: Finished
    Should Not Contain    ${output}    Content mismatch with metadata detected.

CB014455 Teardown
    Crash Check In SYSLOG
#    Kill MabaXterm Process on ORU PC
    Run Keyword If    '${TEST STATUS}' == 'FAIL'
    ...    Collect Snapshot via Admin
    Verify alarms
    admin.teardown

Cell reconfiguration from 64QAM to 256 QAM
    Log To Console    Update actDl256Qam
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCELL_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRCELL_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   actDl256Qam   update  true
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   actDl256Qam   update  false

Collect Snapshot via Admin
    ${date}    DateTime.Get current date
    ${date_str}  Convert date  ${date}  result_format=%Y%m%d%-H%M%S
    ${snapshot_file_name}=    set variable    Snapshot_MRBTS-${mrbts_id}_${active_version}_${date_str}.zip
    Run Keyword and Ignore Error    admin.collect_snapshot    ${snapshot_file_name}

O-RU SW Upgrade and Rollback via WebEM
    O-RU SW Update via WebEM    sw_package=pkg_1    version=1    timeout=600
    O-RU SW Update via WebEM    sw_package=pkg_2    version=2    timeout=600

O-RU SW Update via WebEM
    [arguments]    ${sw_package}   ${version}    ${timeout}
    admin.wait_sw_update_possible
    admin.update_software    sw_package=${sw_package}    timeout=${timeout}
    Wait Until Keyword Succeeds  5 min  5 sec    Radio Is Offline
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair
    Radio Running SW Version Verification    ${version}

Verify O-RU shall support frequency and time recovery
    log    TBD

Verification of Fault 9 Transmission quality deteriorated
    ${output}=    Execute Command On RU via SSH over FH    dt fpga rd 3 2
#    exit
    Append To List    ${allowed_faultd}    9
    Trigger fault 9 in ORU
    Get Fault 9 on ODU WebEM
    Fault 9 Is Cleared on ODU WebEM

Verification of Fault 2 Unit dangerously overheating
    Append To List    ${allowed_faultd}    2
    Trigger fault 2 in ORU
    Get Fault 2 on ODU WebEM
    Cancel fault 2 in ORU
    Fault 2 Is Cleared on ODU WebEM

Verification of Fault 4 Transmission quality deteriorated
    Append To List    ${allowed_faultd}    4
    Trigger fault 4 in ORU
    Get Fault 4 on ODU WebEM
    Cancel fault 4 in ORU
    Fault 4 Is Cleared on ODU WebEM

Verify Fault 2 on WebEM
    ${fault_2}=    Wait Until Keyword Succeeds  5 min  5 sec    Get Fault 2 on WebEM
    log    TBD

Get Fault ${fault_id} on ODU WebEM
    ${alarms}=    admin.get_active_alarms
    ${expected_alarm}=    Set Variable    ${EMPTY}
    FOR    ${alarm}    IN    @{alarms}
        Continue FOR Loop If    ${alarm}[faultId]!=${fault_id}
        Log    ${alarm}
        ${expected_alarm}=    Set Variable    ${alarm}
    END
    Should not be Empty    ${expected_alarm}
    [return]    ${expected_alarm}

Vlan id Check
    [arguments]    ${vlan_id}
    ${exclude_vlans}=    Create List    ${2}    ${295}
    ${allowed_vlan}=    Run Keyword and Return Status    Should Not Contain    ${exclude_vlans}    ${vlan_id}
    ${new_vlan_id_tmp}=    Evaluate    ${vlan_id}+1
    ${new_vlan_id}=    Set Variable If    ${allowed_vlan}    ${vlan_id}    ${new_vlan_id_tmp}
    [return]    ${new_vlan_id}

Update FH vlans
    [arguments]    ${vlan_id}=1
    ${vlan_id_1}=    Evaluate    ${vlan_id}+0
    ${vlan_id_2}=    Evaluate    ${vlan_id}+1
    ${vlan_id_3}=    Evaluate    ${vlan_id}+2
    ${vlan_id_4}=    Evaluate    ${vlan_id}+3
    ${vlan_id_1}=    Vlan id Check    ${vlan_id_1}
    ${vlan_id_2}=    Vlan id Check    ${vlan_id_2}
    ${vlan_id_3}=    Vlan id Check    ${vlan_id_3}
    ${vlan_id_4}=    Vlan id Check    ${vlan_id_4}
    Log To Console      FH vlans: ${vlan_id_1}, ${vlan_id_2}, ${vlan_id_3}, ${vlan_id_4}
    ${date}    DateTime.Get current date
    taf.sbts.oam.coam.admin.create_delta     ${date}

    # ETHIF-1/VLANIF-1, RF9, RMOD-32767, NRCELL-2147483647, LCELNR-5
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1/VLANIF-1    vlanId    ${vlan_id_1}   ${date}
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5  vlanId    ${vlan_id_1}   ${date}

    # ETHIF-2/VLANIF-1, RF1, RMOD-32766, NRCELL-1, LCELNR-16383
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2/VLANIF-1   vlanId    ${vlan_id_2}   ${date}
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16383  vlanId    ${vlan_id_2}   ${date}

    # ETHIF-3/VLANIF-1, RF8, RMOD-4, NRCELL-2, LCELNR-1
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3/VLANIF-1   vlanId    ${vlan_id_3}   ${date}
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1  vlanId    ${vlan_id_3}   ${date}

    # ETHIF-4/VLANIF-1, RF2, RMOD-3, NRCELL-0, LCELNR-0
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-4/VLANIF-1   vlanId    ${vlan_id_4}   ${date}
    taf.sbts.oam.coam.admin.append_parameter_update_to_delta
    ...    MRBTS-37517/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-0  vlanId    ${vlan_id_4}   ${date}

    ${delta_json}    taf.sbts.oam.coam.admin.get_delta    delta_id=${date}
    ${result}    taf.sbts.oam.coam.admin.perform_delta_recommissioning    ${delta_json}
    Wait Until Keyword Succeeds  15 min  5 sec    All cells onair

Update FH Vlans Loop
    ${vlans}=    Get used vlans
    ${start_vlan_id}=    Evaluate    ${vlans}[-1]+1
    FOR    ${vlan_id}    IN RANGE    ${start_vlan_id}    4095
        Clear SYSLOG
        ${date}    DateTime.Get current date
        Log To Console    Count: ${vlan_id}, ${date}
        ${vlans}=    Get used vlans
        ${vlan_in_use}=     Run Keyword And Return Status    Should Contain    ${vlans}    ${vlan_id}
        Continue FOR Loop If    ${vlan_in_use}
        Continue FOR Loop If    '${vlan_id}'=='2'
        Update FH vlans    ${vlan_id}
    END

Get used vlans
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     LCELNR_A
    ${vlans}=    Create List
    FOR    ${obj}    IN    @{objs}
        Append To List    ${vlans}    ${obj}[parameters][vlanId]
    END
    Sort List    ${vlans}
    [return]    ${vlans}

BTS is Offline
    ${output}=    OperatingSystem.Run    ping 192.168.255.129 -c 1 1> /dev/null;echo $?
    Should Not Be True    '${output}==0'

BTS is Online
    ${output}=    OperatingSystem.Run    ping 192.168.255.129 -c 1 1> /dev/null;echo $?
    Should Be True    '${output}==0'

Fault ${fault_id} Is Cleared on ODU WebEM
    Wait Until Keyword Succeeds  5 min  5 sec    Fault ${fault_id} Is Not Active

Fault ${fault_id} Is Not Active
    ${alarms}=    admin.get_active_alarms
    ${expected_alarm}=    Set Variable    ${EMPTY}
    FOR    ${alarm}    IN    @{alarms}
        Should Be True    ${alarm}[faultId]!=${fault_id}
    END

Trigger fault 9 in ORU
    return from keyword
    execute command on ru via ssh over fh    dt dpd exit_dcl

Cancel fault 9-Transmission quality deteriorated in ORU
    log    Fault 9 will be cleared atuomatically after 3 mins
    execute command on ru via ssh over fh

Trigger fault 2 in ORU
    log    TBD

Cancel fault 2 in ORU
    log    TBD

Trigger fault 4 in ORU
    log    TBD

Cancel fault 4 in ORU
    log    TBD

Verification of sFTP client suppot in O-RU and its Authentication Process
    Log    ${accounts}
    admin.configure_netconf_accounts    unsecure_ciphering=${FALSE}    authentication_method=NoAuthentication
    ...    accounts=${accounts}
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair

Verification of default and additional sudo account on one O-DU via WebEM
    Log    TBD

Clear Netconf Account
    ${account_empty}=    Create list
    ${reslut}=    admin.configure_netconf_accounts    unsecure_ciphering=${TRUE}
    ...    authentication_method=NoAuthentication
    ...    accounts=${account_empty}
    Log    ${reslut}

Configure Default Netconf Account
    [arguments]    ${unsecure_ciphering}=${FALSE}    ${authentication_method}=PublicKeyBased
    ...    ${default_netconf_account_name}=oranuser
    ...    ${default_netconf_account_pwd}=o-ran-password
    ${default_account}=    Create Dictionary    defaultNetconfAccountName=${default_netconf_account_name}
    ...    defaultNetconfAccountPwd=${default_netconf_account_pwd}
    ${public_key}=    Catenate    SEPARATOR=${EMPTY}    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqj6rBHtMjXndjZyA
    ...    piMZv4B5TL8KJy6mY1w9AFcsBNybZ2hJZk6Vrnyd291dngS7N/8lIDMs8EE6Zmniho6He3BhfqsJWpaQ4NQxUH3TfVtU8nP6BCV
    ...    hZ6NEueNvPbGuYtDUPOW2CO1vlUAH/zW2VVVjtQsjd3bg8UyxoGuGxsvJXucGB7APfac+c9afhPedcRfaYqMR
    ...    eGYAl0CAdcc3IRbMCEWVB8OXeL1zvTQ82gDWXnPSrpqaWiSsIhpbkzBpCAHkHKHtnp4AqNubd3HSRIczBr5X411v6l
    ...    cswO0yBujgXlOB/A0l28CiIoL1utL8N3/51d9ZU7i2PKnbRWrwV
    ${authentifier_Ssh_Server}=    Create Dictionary    publicKeySshServerFormat=ssh-rsa
    ...    publicKeySshServerValue=${public_key}
    ${additional_Netconf_Account}=    Create Dictionary    additionalNetconfAccountName=xranuser
    ...    additionalNetconfAccountPwd=azAZ09~!    additionalNetconfAccountType=sudo
    ${account}=    Create Dictionary    defaultNetconfAccount=${default_account}
    ...    authentifierSshServer=${authentifier_Ssh_Server}
    ...    additionalNetconfAccount=${additional_Netconf_Account}
    ${accounts}=    Create List    ${account}
    ${reslut}=    admin.configure_netconf_accounts
    ...    unsecure_ciphering=${unsecure_ciphering}
    ...    authentication_method=${authentication_method}
    ...    accounts=${accounts}
    Log    ${reslut}

Verification of runtime changes of different Tx Power of the cell
    Random Update Pmax To Allowed Value
    Update Pmax To Border Value
    Update Pmax to Invalid Value
    Random Update Pmax To Allowed Value

Radio Running SW Version Verification
    [arguments]    ${version}
    ${rmods}=    admin.get_radio_list
    FOR    ${radio}    IN    @{radios}[radioModules][rmod]
        Should Be True    '${radio}[swInfo][runningSwVersion]'=='${version}'
    END

Radio Is Offline
    ${radios}=    admin.get_radio_list
    FOR    ${radio}    IN    @{radios}[radioModules][rmod]
        Should Be True    '${radio}[availabilityStatus]=='Offline'
        Return From Keyword
    END

Random Update Pmax To Allowed Value
    [arguments]    ${min}=13    ${max}=20
    ${pmax_random}=    Evaluate    random.randint(10*${min},10*${max})    random
    Update Pmax of NRCELL    ${pmax_random}
    Wait Until Keyword Succeeds  5 min  5 sec    Not All cells onair
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair

Update Pmax To Border Value
    [arguments]    ${min}=13    ${max}=20
    ${pmax_min}=    Evaluate    10*${min}
    ${pmax_max}=    Evaluate    10*${max}
    Update Pmax of NRCELL    ${pmax_min}
    Wait Until Keyword Succeeds  5 min  5 sec    Not All cells onair
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair
    Update Pmax of NRCELL    ${pmax_max}
    Wait Until Keyword Succeeds  5 min  5 sec    Not All cells onair
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair

Update Pmax to Invalid Value
    [arguments]    ${min}=13    ${max}=20
    ${delta_pmax_random}=    Evaluate    random.randint(1, 150)    random
    ${invalid_pmax}=    Evaluate    10*${max}+${delta_pmax_random}
    ${status}=    Run keyword And Return Status    Update Pmax of NRCELL    ${invalid_pmax}
    Should Be True    ${status}==${FALSE}
    ${invalid_pmax}=    Evaluate    10*${min}-${delta_pmax_random}
    ${status}=    Run keyword And Return Status    Update Pmax of NRCELL    ${invalid_pmax}
    Run keyword if    ${invalid_pmax}>=0    Append to List    ${allowed_faultd}    4008
    Run keyword if    ${invalid_pmax}>=0    Should Be True    ${status}
    ...    ELSE    Should Not Be True    ${status}
    Random Update Pmax To Allowed Value
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair

Update Pmax of NRCELL
    [arguments]    ${pmax}
    Log To Console    Update pmax to ${pmax}
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCELL_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    ${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRCELL_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   pMax   update  ${pmax}

Verification of NETCONF user account management according to O-RAN specification
    clear netconf account
    Configure Default Netconf Account

Verification of NETCONF user account management
    Log    TBD

Verification of HW specificaitons in 3rd Party ORU
    ${radios}=    admin.get_radio_list
    FOR    ${radio}    IN    @{radios}[radioModules][rmod]
        Log Dictionary    ${radio}
        Length Should Be    ${radio}[antenaUsageInfo]    4
    END

Update Pmax Loop
    FOR    ${index}    IN RANGE    0    200
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        Random Update Pmax To Allowed Value
        Wait Until Keyword Succeeds  10 min  5 sec    Not All Cells Onair
        Wait Until Keyword Succeeds  10 min  10 sec    All Cells Onair
        Verify alarms
    END

Cell reset Loop
    FOR    ${index}    IN RANGE    0    200
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        Reset all cells
    END

Reset all cells
    admin.reset_all_cells    technology=NR    timeout=300
    Wait Until Keyword Succeeds  10 min  5 sec    Not All Cells Onair
    Wait Until Keyword Succeeds  10 min  10 sec    All Cells Onair
    Verify alarms

Radio Reset Loop
    FOR    ${index}    IN RANGE    0    300
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        Radio Reset via Admin
    END

Cell Block Unblock Loop
    FOR    ${index}    IN RANGE    0    100
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        Cell block and unblock
    END

ORU Power Reset Loop
    FOR    ${index}    IN RANGE    0    100
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        ORU Power Reset
    END

ORU Power Reset
    Power Reset    FPFH    10.106.205.140    1
	Power Reset    FPFH    10.108.151.81    4
    Wait Until Keyword Succeeds  10 min  5 sec    Not All cells onair
    Wait Until Keyword Succeeds  10 min  5 sec    All cells onair
    Verify alarms

Power Reset
    [Arguments]    ${model}=FPFH    ${host}=10.106.205.140    ${port}=1
    pdu.setup_pdu    model=${model}    host=${host}
    ${power_state}=    pdu.get_port_status    ${port}
    ${result}=    pdu.power_off    ${port}
    ${power_state}=    pdu.get_port_status    ${port}
    Should Be True    '${power_state}'=='off'
    ${sleep_in_sec}=    Evaluate    random.randint(0,600)    random
    Sleep   ${sleep_in_sec}s
    ${result}=    pdu.power_on    ${port}
    ${power_state}=    pdu.get_port_status    ${port}
    Should Be True    '${power_state}'=='on'
    pdu.teardown_pdu

RAT Reset via Admin
    admin.rat_reset    rat_type=NR    timeout=300
    Wait Until Keyword Succeeds  5 min  5 sec    Not All cells onair
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair
    Verify alarms

BBMOD Reset via Admin
    ${bbmods}=    admin.get_fbb_info
    FOR    ${bbmod}    IN    @{bbmods}
        admin.reset_unit    dist_name=${bbmod}[id][configuration]    reset_type=Warm    timeout=300
    END
    Wait Until Keyword Succeeds  5 min  5 sec    Not All cells onair
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair
    Verify alarms

Cell Lock Unlock Cell block unblock Loop
    ${kw_list}    Create List
    ...    Cell block and unblock
    ...    Cell Lock and Unlock
    FOR    ${index}    IN RANGE    0    30
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        ${kw}=    Evaluate    random.choice(${kw_list})    modules=random
        Log To Console    ${kw}
        Run keyword    ${kw}
        Verify alarms
    END

Robustness Test
    [Documentation]    Random execute kw_list
    ${kw_list}    Create List
    ...    Cell block and unblock
    ...    Cell Lock and Unlock
    ...    Reset all cells
    ...    Radio Reset via Admin
    ...    Site Reset via Admin
    ...    RAT Reset via Admin
    ...    BBMOD Reset via Admin
    ...    ORU Power Reset
    ...    collect snapshot via admin
    FOR    ${index}    IN RANGE    0    100
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        ${kw}=    Evaluate    random.choice(${kw_list})    modules=random
        Log To Console    ${kw}
        Run keyword    ${kw}
    END

Cell block and unblock
    ${cell_list}=    admin.get_cell_list
    Log    ${cell_list}
    FOR    ${cell}    IN    @{cell_list}[cells][nr]
        admin.block_cell   ${cell}[id][configuration]
        admin.unblock_cell   ${cell}[id][configuration]
    END
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair
    Verify alarms

Cell Lock Unlock Loop
    FOR    ${index}    IN RANGE    0    100
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        Cell Lock and Unlock
    END

BBMOD reset Loop
    FOR    ${index}    IN RANGE    0    200
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        BBMOD Reset via Admin
    END

Snapshot collection Loop
    FOR    ${index}    IN RANGE    0    100
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        collect snapshot via admin
    END

Cell Lock and Unlock
    ${cell_list}=    admin.get_cell_list
    Log    ${cell_list}
    FOR    ${cell}    IN    @{cell_list}[cells][nr]
        admin.lock   ${cell}[id][configuration]    timeout=60
        admin.unlock   ${cell}[id][configuration]    timeout=60
    END
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair
    Verify alarms

Radio Reset via Admin
    ${radio_list}=    admin.get_radio_list
    LOG    ${radio_list}
#    ${rmods}=    Create List
    FOR    ${rmod}    IN    @{radio_list}[radioModules][rmod]
        Log    ${rmod}
        #Append to List    ${rmods}    ${rmod}[id][configuration]
        admin.reset_unit    dist_name=${rmod}[id][configuration]   reset_type=Hard    timeout=300
    END
#    admin.reset_unit    dist_name=${rmods}   reset_type=Hard    timeout=300
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair
    Verify alarms

Cell Lock Unlock Loop From NMS
    Setup for NMS
    FOR    ${index}    IN RANGE    0    10
        ${date}    DateTime.Get current date
        Log To Console    Count: ${index}, ${date}
        Cell Lock and Unlock from NMS
    END

Cell Lock and Unlock from NMS
    ${cell_list}=    admin.get_cell_list
    Log    ${cell_list}
    Update Parameter From NMS    ${mrbts_id}    NRCELL    administrativeState    0
    Wait Until Keyword Succeeds  5 min  5 sec    NRCELL is Locked
    Wait Until Keyword Succeeds  5 min  5 sec    Not All cells onair
    Update Parameter From NMS    ${mrbts_id}    NRCELL    administrativeState    2
    Wait Until Keyword Succeeds  5 min  5 sec    NRCELL is Unlocked
    Wait Until Keyword Succeeds  5 min  5 sec    All cells onair

NRCELL is ${state}
    ${cells_info}=    admin.get_cells_info
    FOR    ${cell}    IN    @{cells_info}
        Log    ${cell}
        Should Be True    '${cell}[status][administrativeState]'=='${state}'
    END

Update Parameter From NMS
    [arguments]    ${mrbts_id}    ${mo_class}    ${parameter}    ${value}
    ${date}    DateTime.Get current date
    ${date_str}  Convert date  ${date}  result_format=%Y%m%d%H%M%S
    ${file_name}=    Set Variable    scf_${mrbts_id}_exported_${date_str}.xml
    ${local_dir}=    Set Variable    /home/ute/
    ${export_paras}=    Create Dictionary    -useQualifiedClassAbbreviation=${TRUE}
    ${file}=    taf.nms.netact.Export Configuration    file_name=${file_name}    local_dir=${local_dir}
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    operation_type=actual    file_format=RAML2
    ...    parameters=${export_paras}
    ${xml_content}=    Get File    ${file_name}
    ${txts}=    Get Elements Texts    ${xml_content}    //*[@name="${parameter}"]
    Should Not Be Empty    ${txts}
#    ${txts}=    Remove Duplicates    ${txts}
#    Length Should Be    ${txts}    1
#    Should Be True    '${txts}[0]'=='${valid_value}'
    ${eles}=    Get Elements    ${xml_content}    //*[contains(@class, "${mo_class}")]
    Should Not Be Empty    ${eles}
    ${dist_names}=    Create List
    FOR    ${ele}    IN    @{eles}
        Log Element    ${ele}
        ${meta_class}=    Get Element Attribute    ${ele}    class
        ${status}=    Run Keyword And Return Status    Should Match Regexp    ${meta_class}    :${mo_class}$
        CONTINUE FOR LOOP IF    ${status}==${FALSE}
        ${meta_version}=    Get Element Attribute    ${ele}    version
        ${dist_name}=    Get Element Attribute    ${ele}    distName
        Append To List    ${dist_names}    ${dist_name}
        EXIT FOR LOOP
    END
    ${plan_name}=    Set Variable    CB014455-test-${date_str}
    ${plan}=    Run Keyword And Ignore Error    taf.nms.netact.get_plan_configuration    ${plan_name}
    Run Keyword And Ignore Error    taf.nms.netact.delete_plan_configuration    ${plan}
    ${plan}=    taf.nms.netact.create_plan_configuration    ${plan_name}
    FOR    ${dn}    IN    @{dist_names}
        ${obj}=    taf.nms.netact.create_managed_object    ${plan}    meta_class=${meta_class}
        ...    meta_version=${meta_version}    mo_id=${dn}    operation=update    ${parameter}=${value}
    END
    taf.nms.netact.provision_plan    plan_name=${plan_name}
    Run Keyword And Ignore Error    taf.nms.netact.delete_plan_configuration    ${plan}

All Cells Onair
    ${cells_info}=    admin.get_cells_info    nr
    Should Not Be Empty    ${cells_info}
    FOR    ${cell}    IN    @{cells_info}
        Log    ${cell}
        Should Be True    '${cell}[status][operationalState]'=='enabled'
    END

Not All Cells Onair
    ${cells_info}=    admin.get_cells_info    nr
    FOR    ${cell}    IN    @{cells_info}
        Log    ${cell}
        Return From Keyword If    '${cell}[status][operationalState]'!='enabled'
    END
    Fail    All cells onair

Verify alarms
    ${alarms}=    admin.get_active_alarms
    Log List    ${alarms}
    Log List    ${allowed_faultd}
    FOR    ${alarm}    IN    @{alarms}
        Log    ${alarm}[faultId]
        ${expected_fault}=    Run Keyword And Return status
        ...    Should Contain    '${allowed_faultd}'    '${alarm}[faultId]'
#        Run keyword If    ${expected_fault}==${FALSE}
#        ...    Log To Console    Unexpected active fault: ${alarm}[faultId]
        Run keyword If    ${expected_fault}==${FALSE}
        ...    Fail    Unexpected active fault: ${alarm}[faultId]
    END
    ${alarms}=    admin.get_historic_alarms  timeout=300    load_history=True
    Log List    ${alarms}
    FOR    ${alarm}    IN    @{alarms}
        Log    ${alarm}[faultId]
        ${expected_fault}=    Run Keyword And Return status
        ...    Should Contain    '${allowed_faultd}'    '${alarm}[faultId]'
#        Run keyword If    ${expected_fault}==${FALSE}
#        ...    Log To Console    Unexpected historic fault: ${alarm}[faultId]
        Run keyword If    ${expected_fault}==${FALSE}
        ...    Fail    Unexpected historic fault: ${alarm}[faultId]
    END

Kill MabaXterm Process on ORU PC
    SSHLibrary.Open Connection    host=10.106.205.144
    SSHLibrary.Login    t05-tester    Nokia123!
    ${stdout}=	SSHLibrary.Execute Command    taskkill /F /IM MobaXterm_Personal_11.1.exe
    ${stdout}=	SSHLibrary.Execute Command    tasklist |grep -i moba
    Should Not Contain    ${stdout}    MobaXterm_Personal_11.1.exe
    SSHLibrary.Close Connection

Collect ORU Logs
    Execute Command On RU via SSH over FH

Crash Check In SYSLOG
    ${output}=    OperatingSystem.Run    grep -i 'eu name' /tmp/btslog2/SYSLOG_*
    ${crash_observed}=    Run Keyword and return status
    ...    should contain  ${output}    EU name    ignore_case=${TRUE}
    Return From Keyword If    ${crash_observed}==${FALSE}
#    ${matchs}=    Get Regexp Matches    ${output}    EU name\s*:\s*(\w+)
    Log     Crash observed in syslog.    level=WARN     console=${TRUE}

Execute Command with ORU-CLI
    [arguments]    ${test_pc_ip}=10.106.205.144    ${test_pc_username}=T05-tester    ${test_pc_password}=Nokia123!
    ...    ${command}=get hw    ${oru_cli_path}=C:Tools/oru-cli/
    ${test_pc_prompt}=    set variable    $
    ${test_ps_prompt}=    set variable    >
    ${oru_cli_prompt}=    set variable    >
    SSHLibrary.Open Connection    host=${test_pc_ip}    prompt=${test_pc_prompt}
    ${output}=     SSHLibrary.Login    ${test_pc_username}    ${test_pc_password}
    SSHLibrary.Write    cd ${oru_cli_path}
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    ls
#    SSHLibrary.Write    dir
    ${output}=    SSHLibrary.Read Until Prompt
    Should Contain    ${output}    oru-cli.exe
    SSHLibrary.Set Client Configuration    prompt=${oru_cli_prompt}    timeout=30
#    SSHLibrary.Write    powershell -NonInteractive -Command ./oru-cli
    SSHLibrary.Write    ./oru-cli.exe
#    SSHLibrary.Write    C:\\Tools\\oru-cli\\oru-cli.exe
#    ${output}=    SSHLibrary.Read Until Prompt
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    connect -u root -p root
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    ${command}
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    [return]    ${output}

Execute Command On RU via SSH over FH
    [arguments]    ${command}
    ${prompt_fct}=    Set Variable    root@fct-0a:~ >
    ${prompt_fhnet}=    Set Variable    root@FHNET00:~ >
    SSHLibrary.Open Connection    host=${mplane_IP}    prompt=${prompt_fct}
    ${output}=     SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    Should Contain	${output}    ${prompt_fct}
    SSHLibrary.Set Client Configuration    prompt=${prompt_fhnet}
    SSHLibrary.Write    lxc-attach -n0x1018
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    cat /rom/config/FRIps.txt
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Set Client Configuration    prompt=~#
    SSHLibrary.Write    ssh root@172.22.0.6 -o StrictHostKeyChecking=no
    SSHLibrary.Read Until    password:
    SSHLibrary.Write    root
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    ${command}
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Close Connection
    [return]    ${output}




