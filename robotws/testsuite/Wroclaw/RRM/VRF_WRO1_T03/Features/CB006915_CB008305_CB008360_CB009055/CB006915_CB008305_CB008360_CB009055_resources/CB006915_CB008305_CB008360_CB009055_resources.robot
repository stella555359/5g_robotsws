*** Settings ***
Documentation
...     Set of keywords using in CB006915_CB008305_CB008360_CB009055 regression

Library    Collections
Library    SSHLibrary
Resource    ../../../Resources/cm_operations/cm_operations.robot
Resource    ../../../Resources/logs_collecting/logs_collecting.robot
Resource    ../../../Resources/phase_shifter/phase_shifter.robot
Resource    ../../../Resources/pm_counters/pm_counters.robot
Resource    ../../../Resources/ue_keywords/ue_keywords.robot
Library    ../../../Resources/tti/TtiAnalysing.py

*** Variables ***
&{UE_1}=    REAL_UE_1=UE_1
&{UE_2}=    REAL_UE_2=UE_2
&{UE_3}=    REAL_UE_3=UE_3
&{UE_4}=    REAL_UE_4=UE_4
&{UE_5}=    REAL_UE_5=UE_5
&{UE_6}=    REAL_UE_6=UE_6
&{UE_7}=    REAL_UE_7=UE_7
&{UE_8}=    REAL_UE_8=UE_8

&{UE_1_2}=    REAL_UE_1=UE_1    REAL_UE_2=UE_2
&{UE_5_6}=    REAL_UE_5=UE_5    REAL_UE_6=UE_6
&{MULTI_capabilities}=  &{UE_1}  &{UE_2}  &{UE_6}  &{UE_8}
&{MULTI_capabilities_TTC}=   &{UE_2}  &{UE_5}    &{UE_6}

*** Keywords ***
CB006915_CB008305_CB008360_CB009055 Test Case Scenario
    Prepare Environment
    Activate Tti Collecting
    Rapid Pairing Status Check
    Test Step 1 Tput On Askey UEs
    Test Step 2 Tput On Askey UEs And UE On Cell 2
    Test Step 3 Tput On Askey UEs And UE On Cell 3
    Test Step 4 Tput On Askey UEs And UE On Cell 2 And UE On Cell 6
    [Teardown]    Run Keywords    Stop Syslog    AND    Collect Snapshot    ${LOG_PATH}/nonGbrPrbDemand_test

Prepare Environment
    ${timestamp}  OperatingSystem.Run    date +%F_%H-%M-%S
    ${LOG_PATH}   OperatingSystem.Join Path    ${OUTPUT DIR}    ${timestamp}_${TEST NAME}
    Create Directory     ${LOG_PATH}
    Set Test Variable    ${LOG_PATH}
    Create Directory     ${LOG_PATH}/PMs/rpsc
    Prepare And Upload Vendor File    ${True}
    Setup PS    ${CURDIR}/CB006915_CB008305_CB008360_CB009055_ps_settings.csv
    Prepare Ues    ${MULTI_capabilities}
    Start Syslog    ${LOG_PATH}

Rapid Pairing Status Check
    [Arguments]    ${check_counter}=${True}
    [Documentation]
    ...    Move this keyword to logs decoding and analysing
    ...    Modify 'Decode Collected TTI Logs' with path to logs as argument
    ...    Modify 'Check Pairing Status On Cell 1' to return result of logs analysing
    Run    cd /home/ute/test_tti/ && rm *csv
    Remove Old Logs From Tmp    pairing_status
    Run Keyword If    ${check_counter}    adjust time to new pm interval
    Start Tput    UE_1  UE_1_DL    tput_dl=1500    tput_ul=250    duration=120s    apn=5gwrowpt1
    Start Tput    UE_2  UE_2_DL    tput_dl=1500    tput_ul=250    duration=120s    apn=5gwrowpt1
    Sleep    10s
    Collect TTI    tcpdump_name=pairing_status
    Check Counter Condition    ${LOG_PATH}/PMs/rpsc      M55308C35002/NRCELL-1>=1
    ${cell_1}=    Create Dictionary    lcrId=1
    Check Rapid Pairing Status    pairing_status
    [Teardown]    Stop Data Transfer For All Ues

Test Step 1 Tput On Askey UEs
    [Arguments]    ${logs_name}=cell_1
    Remove Old Logs From Tmp    ${logs_name}
#    Rapid Pairing Status Check
    Log To Console    --- Step 1: tput on askey UEs, collecting logs to check pairing status ---
    Start Tput    UE_1  UE_1_DL    tput_dl=1500    tput_ul=250    duration=120s    apn=5gwrowpt1
    Start Tput    UE_2  UE_2_DL    tput_dl=1500    tput_ul=250    duration=120s    apn=5gwrowpt1
    sleep    30s
    Collect TTI   ${logs_name}
    TTI Analysing Step 1    ${logs_name}
#    Check Pairing Status On Cell 1    ${logs_name}
    [Teardown]    Run Keyword And Ignore Error    Stop Data Transfer For All Ues

Test Step 2 Tput On Askey UEs And UE On Cell 2
    [Arguments]    ${logs_name}=cell_1_2
    Remove Old Logs From Tmp    ${logs_name}
#    Rapid Pairing Status Check    check_counter=${False}
    Log To Console    --- Step 2: tput on askey UEs, and UE on cell 2, collecting tti logs ---
    Start Tput    UE_1  UE_1_DL    tput_dl=1500    tput_ul=250    duration=240s    apn=5gwrowpt1
    Start Tput    UE_2  UE_2_DL    tput_dl=1500    tput_ul=250    duration=240s    apn=5gwrowpt1
    sleep    30s
    Start Tput    UE_6  UE_6_DL    tput_dl=300    tput_ul=20    duration=80s    apn=5gwrowpt1
    sleep    20s
    Collect TTI    tcpdump_name=${logs_name}
    TTI Analysing Step 2    ${logs_name}
#    Check Pairing Status On Cell 1    ${logs_name}
    [Teardown]    Run Keyword And Ignore Error    Stop Data Transfer For All Ues

Test Step 3 Tput On Askey UEs And UE On Cell 3
    [Arguments]    ${logs_name}=cell_1_3
    Remove Old Logs From Tmp    ${logs_name}
#    Rapid Pairing Status Check    check_counter=${False}
    Log To Console    --- Step 3: tput on askey UEs, and UE on cell 3, collecting tti logs ---
    Start Tput    UE_1  UE_1_DL    tput_dl=1500    tput_ul=250    duration=240s    apn=5gwrowpt1
    Start Tput    UE_2  UE_2_DL    tput_dl=1500    tput_ul=250    duration=240s    apn=5gwrowpt1
    sleep    30s
    Start Tput    UE_8  UE_8_DL    tput_dl=300    tput_ul=20    duration=80s    apn=5gwrowpt1
    sleep    20s
    Collect TTI    tcpdump_name=${logs_name}
    TTI Analysing Step 3    ${logs_name}
#    Check Pairing Status On Cell 1    ${logs_name}
    [Teardown]    Run Keyword And Ignore Error    Stop Data Transfer For All Ues

Test Step 4 Tput On Askey UEs And UE On Cell 2 And UE On Cell 6
    [Arguments]    ${logs_name}=cell_1_2_3
    Remove Old Logs From Tmp    ${logs_name}
#    Rapid Pairing Status Check    check_counter=${False}
    Log To Console    --- Step 4: tput on askey UEs, and UE on cell 2 and UE in cell 3, collecting tti logs ---
    Start Tput    UE_1  UE_1_DL    tput_dl=1500    tput_ul=250    duration=240s    apn=5gwrowpt1
    Start Tput    UE_2  UE_2_DL    tput_dl=1500    tput_ul=250    duration=240s    apn=5gwrowpt1
    Sleep    30s
    Start Tput    UE_6  UE_6_DL    tput_dl=300    tput_ul=20    duration=80s    apn=5gwrowpt1
    Start Tput    UE_8  UE_8_DL    tput_dl=300    tput_ul=20    duration=80s    apn=5gwrowpt1
    Sleep    20s
    Collect TTI    tcpdump_name=${logs_name}
    TTI Analysing Step 4    ${logs_name}
#    Check Pairing Status On Cell 1    ${logs_name}
    [Teardown]    Run Keyword And Ignore Error    Stop Data Transfer For All Ues

TTI Analysing Step 1
    [Arguments]    ${logs}
    ${cell_1}=    Create Dictionary    lcrId=1
    ${cell_2}=    Create Dictionary    lcrId=2
    ${cell_3}=    Create Dictionary    lcrId=3
    ${sw}=  admin.get_sw_version
    setup tti    input_file=/tmp/${logs}.pcap    output_folder=/home/ute/${TEST_NAME}
    ...    output_format=legacyCsv    sw_version=${sw}
    ...    message_filter=dlMetricIndData|ulMetricIndData|ulAllocatedPooledResourcesData|dlFdSchedData    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>300    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData=0/1    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData=0/0    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>600    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData=0/1    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData=0/1    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>400    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData=40    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData=40    ${cell_3}  tolerance=80%    alias=${logs}
    Check Pairing Status    tolerance=80%    group_by=${cell_1}    alias=${logs}
    [Teardown]    delete_alias    ${logs}

TTI Analysing Step 2
    [Arguments]    ${logs}
    ${cell_1}=    Create Dictionary    lcrId=1
    ${cell_2}=    Create Dictionary    lcrId=2
    ${cell_3}=    Create Dictionary    lcrId=3
    ${sw}=  admin.get_sw_version
    setup tti    input_file=/tmp/${logs}.pcap    output_folder=/home/ute/${TEST_NAME}
    ...    output_format=legacyCsv    sw_version=${sw}
    ...    message_filter=dlMetricIndData|ulMetricIndData|ulAllocatedPooledResourcesData|dlFdSchedData    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>300    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>40    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData=0/1    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>600    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>25    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData=0/1    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>400    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>55    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData=40    ${cell_3}  tolerance=80%    alias=${logs}
    Check Pairing Status    tolerance=80%    group_by=${cell_1}    alias=${logs}
    [Teardown]    delete_alias    ${logs}

TTI Analysing Step 3
    [Arguments]    ${logs}
    ${cell_1}=    Create Dictionary    lcrId=1
    ${cell_2}=    Create Dictionary    lcrId=2
    ${cell_3}=    Create Dictionary    lcrId=3
    ${sw}=  admin.get_sw_version
    setup tti    input_file=/tmp/${logs}.pcap    output_folder=/home/ute/${TEST_NAME}
    ...    output_format=legacyCsv    sw_version=${sw}
    ...    message_filter=dlMetricIndData|ulMetricIndData|ulAllocatedPooledResourcesData|dlFdSchedData    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>300    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData=0/1    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>25    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>600    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData=0/1    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>22    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>400    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData=40    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>52    ${cell_3}  tolerance=80%    alias=${logs}
    Check Pairing Status    tolerance=80%    group_by=${cell_1}    alias=${logs}
    [Teardown]    delete_alias    ${logs}

TTI Analysing Step 4
    [Arguments]    ${logs}
    ${cell_1}=    Create Dictionary    lcrId=1
    ${cell_2}=    Create Dictionary    lcrId=2
    ${cell_3}=    Create Dictionary    lcrId=3
    ${sw}=  admin.get_sw_version
    setup tti    input_file=/tmp/${logs}.pcap    output_folder=/home/ute/${TEST_NAME}
    ...    output_format=legacyCsv    sw_version=${sw}
    ...    message_filter=dlMetricIndData|ulMetricIndData|ulAllocatedPooledResourcesData|dlFdSchedData    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>300    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>50    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:dlMetricIndData>50    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>300    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>20    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    nonGbrPrbDemand:ulMetricIndData>20    ${cell_3}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>250    ${cell_1}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>20    ${cell_2}  tolerance=80%    alias=${logs}
    Check Parameter Value Is Expected    numAllocCellPrbUl:ulAllocatedPooledResourcesData>20    ${cell_3}  tolerance=80%    alias=${logs}
    Check Pairing Status    tolerance=80%    group_by=${cell_1}    alias=${logs}
    [Teardown]    delete_alias    ${logs}


Check Rapid Pairing Status
    [Arguments]    ${logs}=UE_1_2
    ${cell_1}=    Create Dictionary    lcrId=1
    ${sw}=  admin.get_sw_version
    setup tti    input_file=/tmp/${logs}.pcap    output_folder=/home/ute/${TEST_NAME}
    ...    output_format=legacyCsv    sw_version=${sw}
    ...    message_filter=dlMetricIndData|ulMetricIndData|ulAllocatedPooledResourcesData|dlFdSchedData    alias=${logs}
    Check Pairing Status    tolerance=80%    group_by=${cell_1}    alias=${logs}
    [Teardown]    delete_alias    ${logs}
