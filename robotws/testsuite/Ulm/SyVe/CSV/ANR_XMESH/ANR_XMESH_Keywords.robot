*** Settings ***
Documentation
...    author: Yasaman and Kushagra

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts     WITH NAME    wts

Resource   ../../../../Ulm/resources/Common/connect.robot
Resource   ../../../../Ulm/resources/Common/ute_workarounds.robot



*** Variables ***

${XMESH_IP_LIST1}          10.0.1.      # [INFO] fisrt part of IP address (e.g. 10.0.1.) or NONE
${XMESH_IP_LIST1_FIRST}    50           # [INFO] number or ${EMPTY}
${XMESH_IP_LIST1_LAST}     52           # [INFO] number or ${EMPTY}
${XMESH_IP_LIST2}          NONE         # [INFO] fisrt part of IP address (e.g. 10.0.1.) or NONE
${XMESH_IP_LIST2_FIRST}                 # [INFO] number or ${EMPTY}
${XMESH_IP_LIST2_LAST}                  # [INFO] number or ${EMPTY}



*** Keywords ***

Prepare TL for Data Transfer Testing
    Log Variables
    Log To Console    ${\n}Wait that gNBs are Onair...
    testline.Set Console Output
    testline.Create Test Suite Log Folders
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=gnb    node_id=${0}    timeout=30s
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=enb    node_id=${0}    timeout=30s
    ${gnb_sw_version}=    Get gNB SW version    gnb_id=${0}
    Log to console    ${\n}INFO: GNB SW Version is: ${gnb_sw_version}
    ${enb_sw_version}=    Get eNB SW version    enb_id=${0}
    Log to console    ${\n}INFO: eNB SW Version is: ${enb_sw_version}
    testline.Check TL Infos
    syve_testline.Save current loads
    IF    ('syslog' in ${ENABLED_LOGS})
        Start syslog collection for CCRTS
    END
    git_handling.Save Current Workspace Info
    ${capacityUnitType}=     testline.Get Capacity Unit Type    gnb_id=${0}
    Set Suite Variable    ${capacityUnitType}
    Log To Console    ${\n}Identified Capacity Unit Type: ${capacityUnitType}
    #scf_info.Collect and Validate the Current SCF file
    scf_info.Store original config files
    Log Variables


Save all Logs and Teardown TL for Data Transfer Testing
    Sleep    3sec
    Log To Console    ${\n}Suite Teardown...
    ${target_dir}=    testline.Get test suite log directory
    Log To Console    ${\n}Stored files under: ${\n}${target_dir}

    taf.ue.Stop Data Transfers For All Ues

    IF    ('syslog' in ${ENABLED_LOGS})
        Stop syslog collection for CCRTS
    END
    IF    ('snapshot' in ${ENABLED_LOGS})
        Log To Console    ${\n}Snapshot files under: ${\n}${target_dir}
        snapshot.Get snapshot for node     node_type=gNB    node_id=${0}    target_dir=${target_dir}
    END
    scf_info.Collect and Validate the Current SCF file
    admin.Teardown All Aliases For Admin


Check L3 Call Attach
    Log To Console    ${\n}Test the L3 Call.
    ${_cell_phy_cell_id}    gnb.Get gNB Physical Cell ID
    Log To Console    ${\n}The gNB have the following Cell ID: ${_cell_phy_cell_id}

    Attach_and_Data_Transfer.Stop IPSL and set Scenario Preconditions
    ...   path_to_ipsl_files=${CURDIR}/../../../SyVe/resources/IPSL_with_ONE_QCI_for_2IMSI/

    Attach_and_Data_Transfer.Attach UE to eNB
    Attach_and_Data_Transfer.Perform SgNBAddition

    Attach_and_Data_Transfer.Attach UE to eNB
    Attach_and_Data_Transfer.Perform SgNBAddition    ru_id=1

    Attach_and_Data_Transfer.Attach UE to eNB
    Attach_and_Data_Transfer.Perform SgNBAddition    ru_id=2

    [Teardown]    Run Keywords    Log To Console    ${\n}The status is: ${KEYWORD STATUS} ${\n}Message: ${KEYWORD MESSAGE}
    ...           AND    Attach_and_Data_Transfer.Detach and Attenuate all cells

    RETURN    ${KEYWORD STATUS}


Test Scenario Teardown for ANR
    Log To Console    ${\n}Starting Teardown.
    Log To Console    ${\n}Kill all iperf.
    taf.ue.Stop Data Transfers For All Ues
    Log To Console    ${\n}Wait 5 secs before Unblocking cells
    FOR   ${LNCEL_to_block}    IN    @{LNCEL_TL0_to_block_list}
      admin.unblock_cell    dist_name=${LNCEL_to_block}    connection=${oam_alias}
    END
    FOR   ${LNCEL_to_block}    IN    @{LNCEL_TL1_to_block_list}
      admin.unblock_cell    dist_name=${LNCEL_to_block}    connection=${oam_alias_TL1}
    END
    Log To Console    ${\n}Stop tcpdump and tshark
    ${PathTo_Full_Trace_PCAPfile}=   tcpdump.Stop Tcpdump on TestPc    collector=Full_Trace
    Log To Console    ${\n}Full_Trace saved under: ${PathTo_Full_Trace_PCAPfile}
    teardown_all_aliases_for_tshark


Detach and Attenuate all cells
    [Arguments]    ${ue_id}=1
    [Timeout]    15min
    Run Keyword And Warn On Failure    taf.ue.Detach Ue    UE_${ue_id}
    attenuator.Attenuate all cells in testline    off_value=${127}


Verify SECPOL Object Creation
    ${target_dir}=    testline.Get Test Suite Config Directory
    ${original_gnb_scf}=    gnb.Store Current SCF from gNB    gnb_id=${0}    target_dir=${target_dir}
    scf.load_scf  ${original_gnb_scf}
    ${distName_SECPOL}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=SECPOL-6[0-9]+
    sort list    ${distName_SECPOL}
    ${policyOrderNumber}=   scf.get_value_from_scf   dist_name=MRBTS-452111/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/${distName_SECPOL[-1]}
    ...   p_name=policyOrderNumber
    Should Be Equal    ${policyOrderNumber}    8


Load current SCF
    [Arguments]    ${scf_name}=None    ${gnb_id}=0
    ${var}                  Get Variable Value   ${TEST_NAME}
    IF    "${var}" != "None"
        ${tc_conf_dir}    testline.Get Testcase Log Directory
    ELSE
        ${tc_conf_dir}    testline.Get Test Suite Config Directory
    END
    ${current_scf}          gnb.Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${tc_conf_dir}    scf_name=${scf_name}
    scf.load_scf            ${current_scf}
    RETURN  ${current_scf}


Logging to console and setting bts distnames
    Log To Console    ${\n}Data Transfer Testing on NR FDD cell
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${0}
    ${bts0_distName}=    Get From List    ${bts_distNames}    ${0}
    ${bts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+   gnb_id=${1}
    ${bts1_distName}=    Get From List    ${bts_distNames}    ${0}
    Log To Console      TL0 is ${bts0_distName}
    Set Suite Variable    ${bts0_distName}
    Log To Console      TL1 is ${bts1_distName}
    Set Suite Variable     ${bts1_distName}


Set QC object
    @{customers_list}=   Get CSV TL Customer Mapping From TL Name And Set It As Suite Variable CUSTOMERS_LIST
    ${release_name}=  testline.Get gNB SW Branch
    ${qc_project}  ${qc_id}    Get QC_PROJECT QC_ID And Set QC Tags    customer_name=${customers_list}[0]
    ...                                                                release_name=${release_name}


Set cells to Block
    [Arguments]  ${cell_1}=${None}    ${cell_2}=${None}   ${cell_3}=${None}
    IF    '${bts0_distName}' == 'MRBTS-452111'
        @{LNCEL_TL0_to_block_list} =     Create list         MRBTS-452111/NRBTS-402111/${cell_1}   #NRCELL-111
        Set suite variable     @{LNCEL_TL0_to_block_list}
    END
    IF    '${bts1_distName}' == 'MRBTS-452121'
        @{LNCEL_TL1_to_block_list} =    Create list         MRBTS-452121/NRBTS-402121/${cell_2}    #NRCELL-111
                                        ...                 MRBTS-452121/LNBTS-452121/${cell_3}    #LNCEL-21
        Set suite variable     @{LNCEL_TL1_to_block_list}
    END


Attenuate cells and set ipref3 traffic
    Log To Console    ${\n}Data Transfer Testing
    ${oam_alias}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session    node_type=enb    node_id=${0}
    set test variable  ${oam_alias}
    FOR   ${LNCEL_to_block}    IN    @{LNCEL_TL0_to_block_list}
      admin.block_cell    dist_name=${LNCEL_to_block}    connection=${oam_alias}
    END
    ${oam_alias_TL1}=   wait until keyword succeeds   3 min   20 sec   connect.Setup OAM http session    node_type=enb    node_id=${1}
    set test variable  ${oam_alias_TL1}
    FOR   ${LNCEL_to_block}    IN    @{LNCEL_TL1_to_block_list}
      admin.block_cell    dist_name=${LNCEL_to_block}    connection=${oam_alias_TL1}
    END
    attenuator.Attenuate all cells in testline    off_value=${127}
    Log to console    ${\n}Open attenuation for serving cell
    attenuator.Set gNB all ports attenuation     value_in_db=0   ru_id=${NRRU_TL0}   gnb_id=0   #set to step approach later
    ${FirstUE}    UEs_handler.Init UE with APN and Collect Trace then Start BGD TPut    UE_id=${1}
    Set Test Variable    ${FirstUE}
    UEs_handler.Start iPerf3 TCP Data Transfer UL DL    ue_alias=${FirstUE}
    Log to console    ${\n}Stop the DL Background Traffic...
    taf.ue.Stop Data Transfer    DL_Background_${FirstUE}
    Log to console    ${\n}Open attenuation for target cell and reduce source cell


Attenaution configuration for source and target cells   ##change later into range (0, 31, 3)
    attenuator.Set gNB all ports attenuation     value_in_db=0     ru_id=${NRRU_TL1}   gnb_id=1  #TL212
    FOR  ${value_in_db}  IN  3  6  9  12  15  18  21  24  27  30
      Log to console    ${\n}Setting attenuation to ${value_in_db}
      attenuator.Set gNB all ports attenuation     value_in_db=${value_in_db}   ru_id=${NRRU_TL0}   gnb_id=0
      sleep   1s
    END


Stop data transfer and detach UE
    Await data transfer finish    TCP_${DT_DL}_${FirstUE}
    Await data transfer finish    TCP_${DT_UL}_${FirstUE}
    taf.ue.Stop Data Transfer    TCP_${DT_DL}_${FirstUE}
    taf.ue.Stop Data Transfer    TCP_${DT_UL}_${FirstUE}
    Get Data Transfer Statistics    TCP_${DT_DL}_${FirstUE}
    Get Data Transfer Statistics    TCP_${DT_UL}_${FirstUE}
    Log to console    ${\n}Wait 10s before Detach
    sleep   10s
    Detach and Attenuate all cells


Apply Delta SCF
    [Arguments]  ${current_scf}  ${new_name}  ${skip_relation_errors}=True  ${gnb_id}=0
    ${var}                      Get Variable Value   ${TEST_NAME}
    IF    "${var}" != "None"
        ${tc_conf_dir}     testline.Get Testcase Log Directory
    ELSE
        ${tc_conf_dir}     testline.Get Test Suite Config Directory
    END
    ${new_scf}=                 Set Variable   ${tc_conf_dir}/${new_name}.xml
    ${delta_scf}=               Set Variable   ${tc_conf_dir}/delta_${new_name}.json
    scf.save_scf                ${new_scf}
    scf.calculate_delta_scf     ${new_scf}  ${current_scf}  ${delta_scf}
    Config gNB with delta scf   delta_config=${delta_scf}  skip_relation_errors=${skip_relation_errors}  gnb_id=${gnb_id}


#====================================================================================================================================[150 characters]
AirPhone related Keywords
#====================================================================================================================================[150 characters]

Add IPs For Simulated GNBs If Needed
    IF    '${XMESH_IP_LIST1}' != 'NONE'
        FOR    ${ip}    IN RANGE   ${XMESH_IP_LIST1_FIRST}    ${XMESH_IP_LIST1_LAST}+1
            Run Keyword And Ignore Error    ute_workarounds . Configure IP on VM    ip=${XMESH_IP_LIST1}${ip}    interface=${ETHERNET_IF_FOR_WTS}
        END
    END
    # [INFO] try to add the IPs from the second range if any:
    IF    '${XMESH_IP_LIST2}' != 'NONE'
        FOR    ${ip}    IN RANGE   ${XMESH_IP_LIST2_FIRST}    ${XMESH_IP_LIST2_LAST}+1
            Run Keyword And Ignore Error    ute_workarounds . Configure IP on VM    ip=${XMESH_IP_LIST2}${ip}    interface=${ETHERNET_IF_FOR_WTS}
        END
    END


Update Basic Configuration File
    wts . Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
      #------------------------------------------------------------------------------------------------------------------------------[150 characters]
      #run keyword and ignore error    wts . Delete    set_qosrule id=9
      #------------------------------------------------------------------------------------------------------------------------------[150 characters]
      #wts.Insert    set_qosrule id=1 proto=udp qos_flow=1                                                after    set_qosflow id=9
      #wts.Insert    set_qosrule id=2 proto=udp qos_flow=2                                                after    set_qosrule id=1
      #wts.Insert    set_qosrule id=3 proto=udp qos_flow=3                                                after    set_qosrule id=2
      #------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts . Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
