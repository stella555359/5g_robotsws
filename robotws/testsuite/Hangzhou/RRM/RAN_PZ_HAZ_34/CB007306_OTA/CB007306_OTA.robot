*** Settings ***
Suite Setup      Suite Setup 7306
Suite Teardown    robot_common_operations.Common Suite Teardown

Documentation    author：Shanshan Zhang
...              contact: shanshan.zhang@nokia-sbell.com
...              squad group: mmw_SG_04


Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          ./Resources/CB007306_common_keyword.robot
Library           ./Resources/CB007306_common.py
Library           ./Resources/hbtePositioner/positionerDemo.py
Library           ute_syslog
Library           taf.hw.rf_attenuator    WITH NAME    att
Variables         ./Resources/CB007306_modify_para.py

*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${enb_id}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eventA3}                    eventA3
${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${ul_port}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
${dl_port}                   ${tl.ues[0].iperf_details.port}
${luashark_path}              /opt/ute/luashark/luashark_script/generated_luashark
${filter}                    x2ap
${filter2}                   x2ap || s1ap
${att_ipaddr}                ${tl.attenuator.ip_addr}
${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_api_port}              ${tl.attenuator.port}
${att_port_5}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${PositionMotion_ip1}          10.71.206.245
${PositionMotion_ip2}          10.71.206.243



*** Test Cases ***
[1]CB007608-B_5GC000573_011_Counters_X2_SGNB_CHG_ADD_REQ_RECONF
    [Documentation]       verify Counters_X2_SGNB CHG and ADD_REQ and RECONF
    [Tags]    CRT_TRUNK     CRT_22R3     CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    Modify ENB and GNB parameter for 573
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Start tcpdump and send DL or UL traffic for 573    NUM=${0}   if_ul=${False}
    Start tcpdump and send DL or UL traffic for 573    NUM=${1}   if_dl=${False}
    Wait for counter to be gathered after guard peroid
    run keyword and continue on failure     Check DL and UL counter for 573
    run keyword and continue on failure     Check sum counter for 573
    run keyword and continue on failure     Check counter number on gNB1 and gNB2 for 573
    Check wiresgark log and btslog for 573
    [Teardown]       Case Teardown for 573

[1]CB007306-SR-A_5GC000710_A_008_Successful_removal_of_inter-frequency_A3A5_and_configuration_A2_after_receipt_A1_RSRPCombine_Measurement_report
    [Tags]    CRT_TRUNK       CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    Modify ENB and GNB parameter for 710 008
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    Start tcpdump log attach UE and send DL traffic for 710_008
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    Check wiresgark log and btslog for 710_008
    Check counter number on gNB1 for 710     value1=${M55157C00002_1}    value2=${M55157C00002_2}
    [Teardown]       Case Teardown for 710 008

[1]CB007608-B_5GC000710_A_011_online_deletion_of_mobility_profile_between_A2_configuration_and_A2_Report
    [Tags]     CRT_TRUNK      CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    Modify ENB and GNB parameter for 710
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    Start tcpdump log attach UE and send DL traffic for 710_011
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    Check wiresgark log and btslog for 710_011
    Check counter number on gNB1 for 710     value1=${M55157C00002_1}    value2=${M55157C00002_2}
    [Teardown]       Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_710}

[1]CB007608-5G-B-5GC001094_PSCell_change_with_initial_Blacklisting_configuration
    [Tags]    CRT_TRUNK      CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Modify ENB and GNB parameter for 1094
    Start tcpdump log attach UE and send DL traffic for 1094
    Check wiresgark log and btslog for 1094
    [Teardown]       Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_1094}

[1]CB007539-5G-B-5GC001094_002_PSCell_change_with_initial_Blacklisting_configuration
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]    robot_common_operations.Common case Setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]       robot_common_operations.Common case Teardown

[1]CB007608-5G-A-5GC001416_BA_1_Verification_of_EN-DC_X2_link_activation_initiated_with_MFBI_cells_setup_successfully_in_FR2
    [Tags]    CRT_TRUNK     CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    Modify SCF file create new and Commission for 1416
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Run Keyword And Continue On Failure     check cell band       cell_id=${GNB1_NRCELL_1}
    Start tcpdump log attach UE for 1416
    Check case 1416 wireshark log data contain attach message
    [Teardown]       Case Teardown for 1416

[1]CB007564_C_001_CFRA_counters_for_Ue_inital_access
    [Tags]    CRT_TRUNK      CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_actB1Ext_Parameter_7564}      gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_7564_CFRA}      gNB_ip=${gNB_ip}
    ${counter_value_sum1}    ${counter_value_sum2}   ${counter_value_sum3}   ${counter_value_sum4}
    ...    Get counter number on gNB1 for 7564_001
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Start tcpdump log attach UE for 7564 001
    ${counter_value_sum5}    ${counter_value_sum6}   ${counter_value_sum7}   ${counter_value_sum8}
    ...    Get counter number on gNB1 for 7564_001
    run keyword and continue on failure    should be true    ${counter_value_sum5}-${counter_value_sum1}==2
    run keyword and continue on failure    should be true    ${counter_value_sum6}-${counter_value_sum2}==2
    run keyword and continue on failure    should be true    ${counter_value_sum7}-${counter_value_sum3}==2
    run keyword and continue on failure    should be true    ${counter_value_sum8}-${counter_value_sum4}==2
    [Teardown]       Case Teardown and Reconver_Parameter     Reconver_Parameter=${ENB_Reconver_Parameter_7564}

[1]CB007564_C_002_CFRA_counters_for_Ue_access_due_to_successful_HO
    [Tags]    CRT_TRUNK     CRT_22R3    CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter_573}      gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_573}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_7564_CFRA}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_7564_CFRA}     gNB_ip=${gNB2_ip}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ${counter_value_sum1}    ${counter_value_sum2}   ${counter_value_sum3}         Get counter number on gNB1 for 7564_002
    ${counter_value_sum11}    ${counter_value_sum21}   ${counter_value_sum31}      Get counter number on gNB2 for 7564_002
    Start tcpdump log attach UE for 7564 002
    Wait for counter to be gathered after guard peroid
    ${counter_value_sum5}    ${counter_value_sum6}   ${counter_value_sum7}       Get counter number on gNB1 for 7564_002
    ${counter_value_sum51}    ${counter_value_sum61}   ${counter_value_sum71}    Get counter number on gNB2 for 7564_002
    run keyword and continue on failure    should be true    ${counter_value_sum5}-${counter_value_sum1}==2
    run keyword and continue on failure    should be true    ${counter_value_sum6}-${counter_value_sum2}==2
    run keyword and continue on failure    should be true    ${counter_value_sum7}-${counter_value_sum3}==2
    run keyword and continue on failure    should be true    ${counter_value_sum51}-${counter_value_sum11}==2
    run keyword and continue on failure    should be true    ${counter_value_sum61}-${counter_value_sum21}==2
    run keyword and continue on failure    should be true    ${counter_value_sum71}-${counter_value_sum31}==2
    [Teardown]       Case Teardown for 573

[1]CB007564_C_003_CBRA_counters_for_Ue_initial_access
    [Tags]    CRT_TRUNK      CRT_22R3    CRT_22R4
    [Setup]    Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_Reconver_Parameter_7564}      gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_7564_CBRA}      gNB_ip=${gNB_ip}
    ${result2}    Check PM counter result    counter_object=NRACH    counter_id=M55306C09006
    ${counter_value_sum2}    Get sum counter value    ${result2}
    ${result3}    Check PM counter result    counter_object=NRACH    counter_id=M55306C09008
    ${counter_value_sum3}    Get sum counter value    ${result3}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Start tcpdump log attach UE for 7564 003
    Wait for counter to be gathered after guard peroid
    ${result6}    Check PM counter result    counter_object=NRACH    counter_id=M55306C09006
    ${counter_value_sum6}    Get sum counter value    ${result6}
    ${result7}    Check PM counter result    counter_object=NRACH    counter_id=M55306C09008
    ${counter_value_sum7}    Get sum counter value    ${result7}
    run keyword and continue on failure    should be true    ${counter_value_sum6}-${counter_value_sum2}==2
    run keyword and continue on failure    should be true    ${counter_value_sum7}-${counter_value_sum3}==2
    [Teardown]       Case Teardown

[1]CB007564_C_004_CBRA_counters_for_Ue_access_due_to_successful_HO
    [Tags]    CRT_TRUNK       CRT_22R4
    [Setup]      Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter_573}      gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_573}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_7564_CBRA}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_7564_CBRA}     gNB_ip=${gNB2_ip}
    ${M55306C09007_gnb1}     Get counter number on gNB1 for 7564_004
    ${M55306C09007_gnb2}     Get counter number on gNB2 for 7564_004
    Start tcpdump log attach UE for 7564 004
    Wait for counter to be gathered after guard peroid
    ${M55306C09007_gnb1_1}     Get counter number on gNB1 for 7564_004
    ${M55306C09007_gnb2_1}     Get counter number on gNB2 for 7564_004
    run keyword and continue on failure    should be true    ${M55306C09007_gnb1_1}-${M55306C09007_gnb1}==2
    run keyword and continue on failure    should be true    ${M55306C09007_gnb2_1}-${M55306C09007_gnb2}==2
    [Teardown]       robot_common_operations.Common case Teardown

[1]CNI_107623_001_ENDC_setup_via_LTE4088_when_NRrestrictedinEPSasSecondaryRAT
    [Tags]    CRT_TRUNK    CRT_24R1
    [Setup]      Case setup for CNI 107623
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Modify Common parameter via Coam      input_list=${ENB_4088_enable}     gNB_ip=${gNB_ip}    sleep_time=10s
    Modify Common parameter via Coam      input_list=${ENB_CNI107623_disable}     gNB_ip=${gNB_ip}    sleep_time=10s
    Start and check tcpdump log attach UE for CNI_107623    case_type=none
    Modify Common parameter via Coam      input_list=${ENB_CNI107623_enable}     gNB_ip=${gNB_ip}    sleep_time=10s
    Modify Common parameter via Coam      input_list=${ENB_default_FR1}     gNB_ip=${gNB_ip}    sleep_time=10s
    Start and check tcpdump log attach UE for CNI_107623    case_type=fr1
    Modify Common parameter via Coam      input_list=${ENB_default_FR2}     gNB_ip=${gNB_ip}    sleep_time=10s
    Start and check tcpdump log attach UE for CNI_107623    case_type=fr2
    [Teardown]    Case teardown for CNI 107623

[1]CNI_107623_004_ENDC_setup_via_LTE4193_and_B1_setup_when_NRrestrictedinEPSasSecondaryRAT_and_UE_in_FR1_FR2_cross_signal_area
    [Tags]    CRT_TRUNK    CRT_24R1
    [Setup]      Case setup for CNI 107623
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    Modify Common parameter via Coam      input_list=${ENB_CNI107623_enable}     gNB_ip=${gNB_ip}    sleep_time=10s
    Modify Common parameter via Coam      input_list=${ENB_4193_enable}     gNB_ip=${gNB_ip}    sleep_time=10s
    Modify Common parameter via Coam      input_list=${freq_2071387_nrCarPrio_1}     gNB_ip=${gNB_ip}    sleep_time=10s
    Start and check tcpdump log attach UE for CNI_107623    case_type=b1_fr2
    # HO Steps
    Modify Common parameter via Coam      input_list=${GNB2_CNI107623_HO_precondition}     gNB_ip=${gNB2_ip}    sleep_time=5s
    Start and check tcpdump log for CNI_107623 HO SUCC Case
    Modify Common parameter via Coam      input_list=${ENB_CNI107623_only_FR2_enable}     gNB_ip=${gNB_ip}    sleep_time=10s
    Start and check tcpdump log for CNI_107623 HO FAIL Case
    [Teardown]    Case teardown for CNI 107623

*** Keywords ***
Suite Setup 7306
    CB007306_common_keyword.Setup Commission SCF     gnbnumber=${1}    BTS_Host=${gNB_ip}
    CB007306_common_keyword.Setup Commission SCF     gnbnumber=${2}    BTS_Host=${gNB2_ip}
    Iptables UDP destination port ACCEPT
    robot_common_operations.Common Suite Setup

Modify ENB and GNB parameter for 573
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter_573}      gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_573}     gNB_ip=${gNB2_ip}
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    Connect gnb and Check cell on air     BTS_Host=${gNB2_ip}

Modify ENB and GNB parameter for 710
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_MODIFY_Parameter_710}      gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_710}     gNB_ip=${gNB_ip}
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}

Modify ENB and GNB parameter for 710 008
    Modify ENB and GNB parameter for 710
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_710_008}
    ...    gNB_ip=${gNB_ip}
    sleep     30s

Recover ENB and GNB parameter for 710 008
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_710_008_recovery}
    ...    gNB_ip=${gNB_ip}
    sleep     30s

Modify ENB and GNB parameter for 1094
    Modify SCF file create new and Commission for 1094
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_1094}      gNB_ip=${gNB_ip}
    Connect gnb and Check cell on air     BTS_Host=${gNB_ip}

Modify SCF file create new and Commission for 1094
    [Arguments]     ${gnbnumber}=${1}     ${BTS_Host}=${gNB_ip}
    ${default_scf}    CB007306_common_keyword.Get BTS Version And Perare SCF
    ...    gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
    scf.load_scf       file_path=${default_scf}
    modify_scf_element     dist_name=${GNB1_NRCELL_11}    p_name=gscnOrSsPbchArfcn     value=22446
    modify_scf_element     dist_name=${GNB1_NRCELL_12}    p_name=gscnOrSsPbchArfcn     value=22452
    modify_scf_element     dist_name=${GNB1_NRCELL_13}    p_name=gscnOrSsPbchArfcn     value=22458
    modify_scf_element     dist_name=${GNB1_NRCELL_14}    p_name=gscnOrSsPbchArfcn     value=22464
    modify_scf_element     dist_name=${GNB1_NRCELL_11}    p_name=nrarfcn     value=2071665
    modify_scf_element     dist_name=${GNB1_NRCELL_12}    p_name=nrarfcn     value=2073331
    modify_scf_element     dist_name=${GNB1_NRCELL_13}    p_name=nrarfcn     value=2074997
    modify_scf_element     dist_name=${GNB1_NRCELL_14}    p_name=nrarfcn     value=2076663
    modify_scf_element     dist_name=${GNB1_NRCELL_14}    p_name=type0CoresetConfigurationIndex     value=0
    scf.save_scf        file_path=${OUTPUT_DIR}/new_scf_1094.xml
    log to console      modify successful,${OUTPUT_DIR}/new_scf_1094.xml will be commissioned.
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
    COAM Commission with scf file    scf_file_path=${OUTPUT_DIR}/new_scf_1094.xml
    Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Modify SCF file create new and Commission for 1416
    [Arguments]     ${value1}=true    ${value2}=257    ${gnbnumber}=${1}     ${BTS_Host}=${gNB_ip}
    ${default_scf}    CB007306_common_keyword.Get BTS Version And Perare SCF     gnbnumber=${gnbnumber}
    ...    gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
    scf.load_scf       file_path=${default_scf}
    modify_scf_element     dist_name=${MR_NR_BTS_NAME}    p_name=actMultiFrequencyBandIndicatorNRSupport      value=${value1}
    modify_scf_element     dist_name=${GNB1_NRCELL_1}    p_name=freqBandIndicatorNR     value=${value2}
    scf.save_scf        file_path=${OUTPUT_DIR}/new_scf_1416.xml
    log to console      modify successful,${OUTPUT_DIR}/new_scf_1416.xml will be commissioned.
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
    COAM Commission with scf file    scf_file_path=${OUTPUT_DIR}/new_scf_1416.xml
    Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Get Initial Tput Two GNB
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${90}       end_Y=${90}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}     end_Y=${90}
    ${dl_average_TP_GNB1}     ${ul_average_TP_GNB1}    Change LTE DefaultLnRelGnbCellId and Return UL and DL Tput    gnb=${gNB_ip}
    ...    MODIFY_Parameter=${ENB_defaultLnRelGnbCellId_GNB1}     filename=gnb1    attached_pci=${attached_pci_50}
    ${dl_average_TP_GNB2}     ${ul_average_TP_GNB2}    Change LTE DefaultLnRelGnbCellId and Return UL and DL Tput    gnb=${gNB2_ip}
    ...    MODIFY_Parameter=${ENB_defaultLnRelGnbCellId_GNB2}     filename=gnb2    attached_pci=${attached_pci_80}
    [Return]  ${dl_average_TP_GNB1}     ${ul_average_TP_GNB1}    ${dl_average_TP_GNB2}     ${ul_average_TP_GNB1}

Get Initial Tput One GNB
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${90}       end_Y=${90}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}     end_Y=${90}
    ${dl_average_TP_GNB1}     ${ul_average_TP_GNB1}    Change LTE DefaultLnRelGnbCellId and Return UL and DL Tput    gnb=${gNB_ip}
    ...    MODIFY_Parameter=${ENB_defaultLnRelGnbCellId_GNB1}     filename=gnb1    attached_pci=${attached_pci_50}
    [Return]  ${dl_average_TP_GNB1}     ${ul_average_TP_GNB1}

Delete NRMOPRMA_NSA-2 AND NRMOPR_NSA-2
    [Arguments]      ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${bts_host}    connection=${connection}
    ${NRMOPRMA_NSA}    coam.get_managed_objects    class_name=NRMOPRMA_NSA_A   connection=${connection}
    ${NRMOPR_NSA}      coam.get_managed_objects    class_name=NRMOPR_NSA_A     connection=${connection}
    log to console    delete NRMOPRMA_NSA-2
    @{emptyList}     create list
    coam.perform_object_recommissioning        dist_name=${MR_NR_BTS_NAME}/NRMOPRMA_NSA-2
    ...                                        parameter=@{emptyList}
    ...                                        operation=delete
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}

    log to console    delete NRMOPR_NSA-2
    coam.perform_object_recommissioning        dist_name=${MR_NR_BTS_NAME}/NRMOPR_NSA-2
    ...                                        parameter=@{emptyList}
    ...                                        operation=delete
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}
    [Teardown]    COAM Teardown gnb connections

Case Teardown for 573
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_Reconver_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_Reconver_Parameter_573}     gNB_ip=${gNB2_ip}
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown for 710 008
    Recover ENB and GNB parameter for 710 008
    Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_710}
    robot_common_operations.Common case Teardown

Case Teardown and Reconver_Parameter
    [Arguments]     ${Reconver_Parameter}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${Reconver_Parameter}     gNB_ip=${gNB_ip}
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown for 1416
    Modify SCF file create new and Commission for 1416     value1=false     value2=261
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown
