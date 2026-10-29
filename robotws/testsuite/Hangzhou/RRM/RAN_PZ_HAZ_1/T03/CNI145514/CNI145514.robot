*** Settings ***
Documentation
...   author: alps.ge
...   contact: alps.ge@nokia-sbell.com
...   this is a robot case about CNI145514
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDROIDX3_ASIB_ABIO2_AEHC_AHLOA_AHFIB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_TC03_ST_RRM
...                     TA_LEVEL_22
#*** Variables ***
#${DEBUG_MODE}              ${True}



*** Test Cases ***
CNI-145514-A-TC13_CVR001_Redirect to 5G N41 based on B1-NR measurement fulfilling RSRP threshold_UE in LTE without EN-DC and user inactivity detected
    [Documentation]    author:alps.ge
    [Tags]    10_5_UTE5GTL5393    SCF_10_5_UTE5GTL5393_CNI_145514_CVR001    SWCONFIG_10_5_UTE5GTL5393
    AT.UE Detach
    Block all NR cell
    sleep    30s
    Start Multi Bts Log
    sleep    10s
    AT.UE attach
    sleep    5s
    AT.UE Detach
    sleep    5s
    Unblock NR cell
    sleep    30s
    AT.UE attach
    sleep    180s
    Stop All Bts Log
    sleep    30s
    Check redirectInformationSent For BTS0
    Check b1ThresholdRsrp For BTS0



CNI-145514-A-TC14_CVR002_Redirect to 5G N25 based on B1-NR measurement fulfilling RSRP threshold check failed for N41
    [Documentation]    author:alps.ge
    [Tags]    10_5_UTE5GTL5393    SCF_10_5_UTE5GTL5393_CNI_145514_CVR002    SWCONFIG_10_5_UTE5GTL5393
    AT.UE Detach
    Block all NR cell
    sleep    30s
    Start Multi Bts Log
    sleep    10s
    AT.UE attach
    sleep    5s
    AT.UE Detach
    sleep    5s
    Unblock NR cell
    sleep    30s
    AT.UE attach
    sleep    180s
    Stop All Bts Log
    sleep    30s
    Check redirectInformationSent For BTS0
    Check b1ThresholdRsrpbelow For BTS0


*** Keywords ***
Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    #Run Keyword And Ignore Error    Change Commission To Unlock cell
    #Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

PA_Source_List_Only_Increase_Value
    [Tags]    CRT    TC01
    ${source_pa_port_list}     Create List     37    39    46    48    53    55    62    64
    ${source_pa_value_list}    Create List     10    10    10    10    10    10    10    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${10}    pa_type=16*8
    PA Operation    source=&{source}    target=none

AT.UE Detach
    AT Operation    detach    ue_index=0

AT.UE Attach
    AT Operation    attach    ue_index=0

Block all NR cell
    BTS Operation    operation=cell_lock            product_type=gnb    bts_index=0    distname_id=NRCELL-ALL     need_verify=True

Unblock NR cell
    BTS Operation    operation=cell_unlock          product_type=gnb    bts_index=0    distname_id=NRCELL-ALL       need_verify=True


Stop All Bts Log
    Stop All BTSLog And Download to Local



Check redirectInformationSent For BTS${i}
    Log To Console    Check redirectInformationSent
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'redirectInformationSent= true' | grep -av grep
    Should Contain    ${ret}    redirectInformationSent= true


Check b1ThresholdRsrp For BTS${i}
    Log To Console    Check b1ThresholdRsrp
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'carrierFreqNr: 520110, is above LnHoN configured threshold' | grep -av grep
    Should Contain    ${ret}    carrierFreqNr: 520110, is above LnHoN configured threshold


Check b1ThresholdRsrpbelow For BTS${i}
    Log To Console    Check b1ThresholdRsrpbelow
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a 'is below configured LnHon threshold' | grep -av grep
    Should Contain    ${ret}    below configured LnHon threshold

