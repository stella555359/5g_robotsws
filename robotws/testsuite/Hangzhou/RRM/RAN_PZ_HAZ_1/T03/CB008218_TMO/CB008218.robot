*** Settings ***
Documentation
...   author: fan-andy.yu
...   contact: fan-andy.yu@nokia-sbell.com
...   this is a robot case about CB008242TMO
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${60}
${PA_NormalValue}        ${30}
${PA_HoValue}            ${50}
${PA_MinValue}           ${0}

&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_6327}              faultId=${6327}
&{fault_6915}              faultId=${6915}
&{fault_61618}             faultId=${61618}
&{fault_4001}              faultId=${4001}
&{fault_6331}              faultId=${6331}
&{fault_4153}              faultId=${4153}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
...    &{fault_6327}    &{fault_6915}    &{fault_4001}    &{fault_6331}    &{fault_4153}

# ${DEBUG_MODE}         ${True}

*** Test Cases ***
# Upgrade
    # [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    # Run Feature Case
    # [Teardown]    TL Suite Teardown

CB008218_04_B1-NR measurements can be periodically configured when waiting for DL buffer overflow
    [Documentation]    author: Fan-andy.yu
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008218_TMO_Case4
    Start Multi Bts Log
    Unblock LNCell_21 and NRCell_5
    sleep    5s
    AT.Prepare UE
    sleep    5s
    AT.UE Attach
    sleep    40s

    # Check B1NR activate
    # Check B1NR deactivate

    # Log To Console    senddata
    # ${dl_server1}    Connect To IperfServer From Appservers
    # #5QI7
    # Start DL traffic By Iperf    time=3600    traffic=200.00M    dl_server=${dl_server1}
    # ...    DL_port=${50001}

    ${ueip}=    AT Operation    get    ue_index=0  item=ueip

    AT Operation    start_traffic    ueip=${ueip}    IperfOptions=-u -l 1024 -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.198.158    remote_username=ute    remote_password=UTE.debian12

    sleep    40s

    Stop All Bts Log
    sleep    40s
    Check EN-DC State
    Check B1NR activate
    # Check B1NR deactivate
    # Check B1NR activate
    # Check B1NR deactivate
    # Check B1NR no activate
    Check B1NR no activate_2

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

Unblock BTS0_LTECell_2 and BTS3_NRCell_28
    Log To Console    Unblock BTS0_LTECell_2 and BTS3_NRCell_28
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_MinValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_MinValue}

Decrease BTS3_NRCell_28
    Log To Console    Decrease BTS3_NRCell_28
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${3}    value=${PA_Cell28}

Unblock BTS0_LTECell_2 and BTS2_NRCell_30
    Log To Console    Unblock BTS0_LTECell_2 and BTS2_NRCell_30
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_MinValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${2}    value=${PA_MinValue}\

Check LNADJGNB1 Not Exist
    Log To Console    Check LNADJGNB1 Not Exist
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    connection=commission
    ${lnadjgnb_1}=   Catenate    SEPARATOR=   ${value}[currentNp]    /SCF-1/MRBTS_A-2298/LNBTS_A-2298/LNADJGNB_A-1
    Log   ${lnadjgnb_1}
    ${ret2}    ${value2}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=${lnadjgnb_1}
    ...    connection=commission
    Run Keyword If   '${ret2}'=='PASS'    Fail    LNADJGNB_A-1 doesn't deleted
    Sleep    2s
    [Teardown]    COAM_Admin.Logout        connection=commission

Check LNRELGNBCELL1 Not Exist
    Log To Console    Check LNRELGNBCELL1 Not Exist
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    connection=commission
    ${lnadjgnb_1}=   Catenate    SEPARATOR=   ${value}[currentNp]    /SCF-1/MRBTS_A-2298/LNBTS_A-2298/LNCEL_A-2/LNRELGNBCELL_A-1
    Log   ${lnadjgnb_1}
    ${ret2}    ${value2}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=${lnadjgnb_1}
    ...    connection=commission
    Run Keyword If   '${ret2}'=='PASS'    Fail    LNRELGNBCELL_A-1 doesn't deleted
    Sleep    2s
    [Teardown]    COAM_Admin.Logout        connection=commission

Check LNRELGNBCELL2 Not Exist
    Log To Console    Check LNRELGNBCELL2 Not Exist
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    connection=commission
    ${lnadjgnb_1}=   Catenate    SEPARATOR=   ${value}[currentNp]    /SCF-1/MRBTS_A-2298/LNBTS_A-2298/LNCEL_A-2/LNRELGNBCELL_A-2
    Log   ${lnadjgnb_1}
    ${ret2}    ${value2}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=${lnadjgnb_1}
    ...    connection=commission
    Run Keyword If   '${ret2}'=='PASS'    Fail    LNRELGNBCELL_A-2 doesn't deleted
    Sleep    2s
    [Teardown]    COAM_Admin.Logout        connection=commission

Check LNRELGNBCELL3 dss Exist
    Log To Console    Check LNRELGNBCELL3 dss Exist
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    &{value}
    ...    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    connection=commission
    ${lnadjgnb_1}=   Catenate    SEPARATOR=   ${value}[currentNp]    /SCF-1/MRBTS_A-2298/LNBTS_A-2298/LNCEL_A-2/LNRELGNBCELL_A-3
    Log   ${lnadjgnb_1}
    coam.get_parameters   dist_name=${lnadjgnb_1}
    ...    connection=commission
    Sleep    2s
    [Teardown]    COAM_Admin.Logout        connection=commission

Check LNRELGNBCELL-255 Exist
    Log To Console    Check LNRELGNBCELL-255 Exist
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    &{value}
    ...    coam.get_parameters   dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    connection=commission
    ${lnadjgnb_1}    Catenate    SEPARATOR=   ${value}[currentNp]    /SCF-1/MRBTS_A-2298/LNBTS_A-2298/LNCEL_A-2/LNRELGNBCELL_A-255
    Log   ${lnadjgnb_1}
    coam.get_parameters   dist_name=${lnadjgnb_1}
    ...    connection=commission
    Sleep    2s
    [Teardown]    COAM_Admin.Logout        connection=commission


Check LNRELGNBCELL-255 State
    Log To Console    Check LNRELGNBCELL-255 State
    Sleep    5s
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Create : LNBTS-2298/LNCEL-2/LNRELGNBCELL-255" | grep -av grep
    Should Contain    ${ret}    Create : Create : LNBTS-2298/LNCEL-2/LNRELGNBCELL-255
    # ${ret}    OperatingSystem.Run
    # ...    command=cat ${BTS0_LOG_PATH} |grep -a "sourceOfData = UE" | grep -av grep
    # Should Contain    ${ret}    sourceOfData = UE
    # ${ret}    OperatingSystem.Run
    # ...    command=cat ${BTS0_LOG_PATH} |grep -a "nrStatus = available" | grep -av grep
    # Should Contain    ${ret}    nrStatus = available

Activate actAutoNrNeighRemoval actUeBasedAnrNr
    @{para_list}      Create List    actAutoNrNeighRemoval    actUeBasedAnrNr
    @{mo_list}        Create List    MRBTS-2298/LNBTS-2298/ANR-0    MRBTS-2298/LNBTS-2298
    @{value_list}     Create List    true    true
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Activate actLteNrFastNbrRelAdd actUeBasedAnrNr
    @{para_list}      Create List    actLteNrFastNbrRelAdd    actUeBasedAnrNr
    @{mo_list}        Create List    MRBTS-2298/LNBTS-2298    MRBTS-2298/LNBTS-2298
    @{value_list}     Create List    true    true
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Check B1NR activate
    Log To Console    Check B1NR activate
    ${ret}    csn.execute
    ...    cat ${BTS1_LOG_PATH} |grep -a 'activating B1NR meas due to RetryTimer expiration' | grep -av grep
    ...    connection=BTS0_VM
    Should Contain    ${ret}    activating B1NR meas due to RetryTimer expiration

Check B1NR deactivate
    Log To Console    Check B1NR deactivate
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS1_LOG_PATH} |grep -a 'deactivating B1NR meas due to supervisionTimerB1NR expiration' | grep -av grep
    Should Contain    ${ret}    deactivating B1NR meas due to supervisionTimerB1NR expiration

Check EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS1_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check B1NR no activate
    Log To Console    Check B1NR no activate
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS1_LOG_PATH} |grep -a 'B1NR cannot be activated when RetryTimer expired' | grep -av grep
    Should Contain    ${ret}    B1NR cannot be activated when RetryTimer expired

Check B1NR no activate_2
    Log To Console    Check B1NR no activate_2
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS1_LOG_PATH} |grep -a "B1NR meas wasn't active when supervisionTimerB1NR expired" | grep -av grep
    Should Contain    ${ret}    B1NR meas wasn't active when supervisionTimerB1NR expired


Unblock LNCell_21 and NRCell_5
    Log To Console    Unblock LNCell_21 and NRCell_5
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${10}    gnb_id=${0}    value=${PA_MinValue}