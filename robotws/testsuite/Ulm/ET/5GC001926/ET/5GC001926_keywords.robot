*** Settings ***
Documentation
...    author: Jing Liang, Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Common Keywords for 5GC001926

Library     taf.config.scf        WITH NAME    scf
Library     taf.config.wts        WITH NAME    wts_conf
Library     Collections
Library     OperatingSystem


Resource    ../../resources/SQD65/sqd65_keywords.robot
Resource    ../../resources/SQD65/sqd65_commissioning.robot

Resource    ./wts_ue_1926.robot

*** Variables ***
@{RD_FLAGS}          0x580017=1    0x580011=0    0x580012=0    0x580013=0    0x580014=0

*** Keywords ***
Suite Setup for 5GC001926
    [Documentation]    Collect all needed configuration to bring TL back to status
    ...    AirphoneConfig.xml, basic.cfg, ap_swconfig, gnb_swconfig, SCF
    ...    Upload needed config file to TL
    Sqd65 Common Setup
    Update SW Config file on System Module    param_list=${RD_FLAGS}
    Set MRBTS/NRBTS ID as Suite Variable
    Set MRBTS/MNL ID as Suite Variable
    ${cellTechnology}=    Get cellTechnology Info
    Set Suite Variable    ${FDD_TDD}    ${cellTechnology}

Suite Teardown for 5GC001926
    [Documentation]    Bring TL back to original configuration
    ...    bring back config files, do full commissioning
    Reload stored swconfig
    Sqd65 Common Teardown

Perform Precondition for 5GC001926 testcase
    [Documentation]    prepare testcase log folder, bring TL to pre-condition
    [Arguments]      ${cfg_file}
    Create testcase log directory
    IF    '${PREV_TEST_STATUS}'=='FAIL'
        Teardown Egate Connection for Airphone
        Teardown Edaemon Connection for Airphone
        Bring Airphone TL to on Air status    cfg_file=${cfg_file}
    END
    Start Logging    ${False}

Perform Postconditions for 5GC001926 testcase
    [Documentation]    collect SCF and Snapshot
    Stop Logging
    ${tc_log_dir}=   Get testcase log directory
    Run Keyword and Ignore Error    Get SCF from gNB    target_dir=${tc_log_dir}  scf_name=scf_teardown.xml
    Run Keyword and Ignore Error    Collect AP Sos Report and Snapshots
    Reset Ue Info for Common Keyword

Store Current SCF from gNB
    [Documentation]    [PRIVATE]
    ${ORIG_SCF}=    Get SCF from gNB
    Run    mv ${ORIG_SCF} ${ORIG_SCF}.orig
    Set Suite Variable    ${P_ORIG_SCF}    ${ORIG_SCF}.orig

Store Current swconfig from gNB
    [Documentation]    [PRIVATE]
    [Arguments]    ${target_dir}=None
    ${target_dir}=    IF    '${target_dir}'=='None'    Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ssh_alias}=    connect.Connect to Node Common Unit
    ssh.Download File    remote_path=/ffs/run/swconfig.txt    local_path=${target_dir}/gnb_swconfig.txt    connection=${ssh_alias}
    Set Suite Variable    ${P_ORIG_GNB_SWCONFIG}    ${target_dir}/gnb_swconfig.txt

Reload stored swconfig
    [Documentation]    [PRIVATE]
    ${ssh_alias}=    connect.Connect to Node Common Unit
    ssh.Upload File    local_path=${P_ORIG_GNB_SWCONFIG}    remote_path=/ffs/run/swconfig.txt    connection=${ssh_alias}
    Reload stored swconfig to Airphone

Reload stored SCF
    [Documentation]    [PRIVATE]
    ...    gnb only supports xml file
    Run    cp ${P_ORIG_SCF} /tmp/gnb_tmp.xml
    Execute full commissioning    gnb_id=0    scf_path=/tmp/gnb_tmp.xml

# SCF handling

Activate Multiple Network Slices
    [Documentation]    add SNSSAI-2 to 5 into SCF
    scf.Load Scf    ${P_ORIG_SCF}
    FOR    ${index}    IN RANGE    2  6
         Add Slice into SCF    ${index}
    END
    @{trackingareas}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+/TRACKINGAREA-\\d+
    ${snssaiList}    Create Dictionary    snssaiDN=${distName_BTS_ID}/SNSSAI-1    snssaiDNLast=${distName_BTS_ID}/SNSSAI-5
    Set New List              dist_name=${trackingareas}[0]    list_name=snssaiList
    scf.add_item_to_list      dist_name=${trackingareas}[0]    list_name=snssaiList    elements=${snssaiList}
    scf.modify_scf_element    value=true  dist_name=${distName_BTS_ID}/NRCELL-1  p_name=actIncreasedFdmUsersPerSlot
    ${config_dir}=    Get test suite config directory
    scf.save_scf    ${config_dir}/scf_1926_SA.xml
    Execute full commissioning    ${config_dir}/scf_1926_SA.xml
    Wait until all DUs up

Add Slice into SCF
    [Documentation]    Add network slice into scf
    [Arguments]    ${index}
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${distName_BTS_ID}/SNSSAI-${index}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=SNSSAI  dist_name=${distName_BTS_ID}/SNSSAI-${index}  version=NRBTSCL5G20A_2003_200
    scf.add_element_to_scf    dist_name=${distName_BTS_ID}/SNSSAI-${index}    p_name=sd    value=1371434${index}
    scf.add_element_to_scf    dist_name=${distName_BTS_ID}/SNSSAI-${index}    p_name=sst    value=1
    scf.add_element_to_scf    dist_name=${distName_BTS_ID}/SNSSAI-${index}    p_name=administrativeState    value=Unlocked
    scf.add_list_to_scf    dist_name=${distName_BTS_ID}/SNSSAI-${index}  list_name=nrPlmnDNList
    ${param_list}=    Create List    ${distName_BTS_ID}/NRPLMN-1
    scf.add_elements_to_list    dist_name=${distName_BTS_ID}/SNSSAI-${index}  list_name=nrPlmnDNList  elements=${param_list}

Set MRBTS/NRBTS ID as Suite Variable
    [Documentation]    :Author: Jing Liang
    ...    keyword to get MRBTS/NRBTS ID from GNB and set as suite variable
    ...
    ...    :param variable_name: (String, default distName_BTS_ID), varialbe name in scf template
    ...
    [Arguments]    ${variable_name}=distName_BTS_ID
    @{dist_list}=    gnb.Get distNames from gNB DU    regex=MRBTS-\\d+/NRBTS-\\d+
    Set Suite Variable    ${${variable_name}}    ${dist_list}[0]

Set MRBTS/MNL ID as Suite Variable
    [Documentation]    :Author: Jing Liang
    ...    keyword to get MRBTS/MNL ID from GNB and set as suite variable
    ...
    ...    :param variable_name: (String, default distName_BTS_ID), varialbe name in scf template
    ...
    [Arguments]    ${variable_name}=distName_MNL_ID
    @{dist_list}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/MNL-\\d+
    Set Suite Variable    ${${variable_name}}    ${dist_list}[0]

# PM Counters

Generate QoS Group list
    [Documentation]    To generate list with [01, 02, 03, ..., ${group_num}]
    [Arguments]    ${group_num}=${20}
    ${qos_list}=    evaluate    ["%.2d" % i for i in range(1, ${group_num}+1)]
    Set Test Variable    ${P_QOS_LIST}    ${qos_list}

Get QoS Group Counters
    [Documentation]    Get all counters value from pm file
    ...    M55310C010xx    DL RLC data PDU volume transmitted by Low RLC - QoS Group 01 (M55310C01001)    CELLS/NRCELL-1/
    ...    M55310C030xx    UL RLC data PDU volume received by Low RLC - QoS Group 01 (M55310C03001)       CELLS/NRCELL-1/
    ...    M55323C010xx    Downlink data volume sent over F1-U - QoS Group 1 (M55323C01001)               BTS/NRBTS-2003/
    ...    M55323C030xx    Uplink data volume received over F1-U - QoS Group 1 (M55323C03001)             BTS/NRBTS-2003/
    [Arguments]    ${pm_path}
    Generate QoS Group list
    FOR    ${group_id}    IN     @{P_QOS_LIST}
         ${dl_rlc}=    Get PM counter value    pm_files_location=${pm_path}    pi_id=M55310C010${group_id}    moc=NRCELL-1
         ${ul_rlc}=    Get PM counter value    pm_files_location=${pm_path}    pi_id=M55310C030${group_id}    moc=NRCELL-1
         ${dl_data}=    Get PM counter value    pm_files_location=${pm_path}    pi_id=M55323C010${group_id}    moc=NRBTS-1
         ${ul_data}=    Get PM counter value    pm_files_location=${pm_path}    pi_id=M55323C030${group_id}    moc=NRBTS-1
         ${qos_group}=    Create Dictionary    dl_rlc=${dl_rlc}  ul_rlc=${ul_rlc}  dl_data=${dl_data}  ul_data=${ul_data}
         Set Test Variable    ${P_GROUP_${group_id}}    ${qos_group}
    END

Verify 1926-G Counters
    [Documentation]    Verify all used QoS Groups counters
    ...    used are bigger than 0, unused are equal to 0
    [Arguments]    ${dir}    ${used_groups}
    FOR    ${qos_id}    IN    @{used_groups}
         should be true    ${P_GROUP_${qos_id}.${dir}_rlc} > 0
         should be true    ${P_GROUP_${qos_id}.${dir}_data} > 0
    END
    Remove Values from List    ${P_QOS_LIST}    @{used_groups}
    FOR    ${qos_id}    IN    @{P_QOS_LIST}
         should be equal    ${P_GROUP_${qos_id}.${dir}_rlc}  0
         should be equal    ${P_GROUP_${qos_id}.${dir}_data}  0
    END
