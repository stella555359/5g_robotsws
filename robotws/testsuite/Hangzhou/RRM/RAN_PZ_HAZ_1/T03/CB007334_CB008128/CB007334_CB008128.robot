*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB007332
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${PA_NormalValue}        ${1}
${PA_Cell28}             ${15}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
${PA_33db}               ${33}
${PA_38db}               ${38}
${PA_42db}               ${42}
&{fault_7300}              faultId=${7300}
&{fault_7523}              faultId=${7523}
&{fault_7107}              faultId=${7107}
&{fault_7311}              faultId=${7311}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_7523}    &{fault_7107}
# ${DEBUGMODE}               ${True}

*** Test Cases ***
# Upgrade
    # [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    # Run Feature Case
    # [Teardown]    TL Suite Teardown

CB007334_01_LNRELGNBCELL removal due to insufficient frequency of B1-NR MR
    [Documentation]    Author:Chen jiahao
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007334_case01
    ...    SWCONFIG_10_5_UTESRAN001T2298
    Start Multi Bts Log
    Unblock BTS0_LTECell_2 and BTS3_NRCell_28
    Activate actAutoNrNeighRemoval actUeBasedAnrNr
    sleep    5s
    AT.Prepare UE
    FOR    ${x}    IN RANGE    ${4}
      AT.UE Attach
      sleep    5s
      AT.UE Detach
      sleep    5s
    END
    sleep    300s
    Check LNADJGNB1 Not Exist
    Check LNRELGNBCELL1 Not Exist
    Check LNRELGNBCELL2 Not Exist
    Check LNRELGNBCELL3 dss Exist

CB007334_05_LNRELGNBCELL creation for unknown NR-PCI or NR-carrier pair
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB007334_case05
    ...    SWCONFIG_10_5_UTESRAN001T2298
    Start Multi Bts Log
    Activate actLteNrFastNbrRelAdd actUeBasedAnrNr
    Unblock BTS0_LTECell_2 and BTS3_NRCell_28
    sleep    5s
    AT.Prepare UE
    FOR    ${x}    IN RANGE    ${4}
      AT.UE Attach
      sleep    5s
      AT.UE Detach
      sleep    5s
    END
    # Decrease BTS3_NRCell_28
    # Unblock BTS0_LTECell_2 and BTS2_NRCell_30
    AT.UE Attach
    sleep    800s
    Check LNRELGNBCELL-255 Exist

CB008218_04_B1-NR measurements can be periodically configured when waiting for DL buffer overflow
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB008218_case04
    Start Multi Bts Log
    Unblock BTS0_LTECell_2 and BTS3_NRCell_28
    sleep    5s
    AT.Prepare UE
    sleep    5s
    AT.UE Attach
    sleep    60s
    Check B1NR activate
    Check B1NR deactivate
    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI7
    Start DL traffic By Iperf    time=3600    traffic=200.00M    dl_server=${dl_server1}
    ...    DL_port=${50001}
    sleep    20s
    Check EN-DC State
    sleep    60s
    Check B1NR no activate
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
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'activating B1NR meas due to RetryTimer expiration' | grep -av grep
    Should Contain    ${ret}    activating B1NR meas due to RetryTimer expiration

Check B1NR deactivate
    Log To Console    Check B1NR deactivate
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'deactivating B1NR meas due to supervisionTimerB1NR expiration' | grep -av grep
    Should Contain    ${ret}    deactivating B1NR meas due to supervisionTimerB1NR expiration

Check EN-DC State
    Log To Console    Check EN-DC State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check B1NR no activate
    Log To Console    Check B1NR no activate
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'B1NR cannot be activated when RetryTimer expired' | grep -av grep
    Should Contain    ${ret}    B1NR cannot be activated when RetryTimer expired

Check B1NR no activate_2
    Log To Console    Check B1NR no activate_2
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "B1NR meas wasn't active when supervisionTimerB1NR expired" | grep -av grep
    Should Contain    ${ret}    B1NR meas wasn't active when supervisionTimerB1NR expired