*** Settings ***
Documentation    Suite description

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/Emil_processing_keywords.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

*** Variables ***
${Emil_keywords}=    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/Emil_processing_keywords.py
${tes_emil}=         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/2640_emil.robot
${tes_emil_2}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/2640_emil_AC.robot

*** Keywords ***
Check if 5GC002640 is disabled
    ${cASupportList_before}    Create list    ca_Fdd_Fr1Tdd_Sa  ca_Fdd_Fr1Tdd_Nsa  ca_Fdd_Fdd
    Log to console  Check if 5GC002640 is disabled
    coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...                                       parameter=carrierAggregationSupportList
    ...                                       operation=update
    ...                                       value=${cASupportList_before}
    ...                                       connection=cOAM
    Log to console  Feature 5GC002640 is disabled

Check if feature 5GC002640 is successfully activated
    ${cASupportList_active2640}    Create list    ca_Fdd_Fr1Tdd_Sa  ca_Fdd_Fr1Tdd_Nsa  ca_Fdd_Fdd  ca_Fdd_Any_Sa
    Log to console  Activate feature 5GC002640
    ${response_ca}  coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRDU-1
    ...                                       parameter=carrierAggregationSupportList
    ...                                       operation=update
    ...                                       value=${cASupportList_active2640}
    ...                                       connection=cOAM
    Log to console  Feature 5GC002640 is enabled
    Should Be Equal As Strings  ${response_ca}[commissioningResult][isGoingToTriggerReset]   False

Set attenuation for 2640-AC_03
    Log to Console    Attenuation set to 0dB for RMODs: 1-AHLOA. Others: -90dB
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_6_TDD}    value=90
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_2_FDD}   value=90
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=90
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=90
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}   value=90
    Log to Console  >Attenuators have been set for 2640-AC_03.<

Set attenuation for 2640-E
    Log to Console    Attenuation set
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_2_FDD}   value=0  #PCI 102  PCell  weight: 50
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=0  # PCI 101  SCell  weight: 1
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0  #PCI 104    SCell  weight: 50
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_5_TDD}    value=0  #PCI 105    SCell  weight: 1
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}   value=0   #PCI 107   SCell  weight: 60
    Log to Console  >Attenuators have been set for 2640-E.<

Perform inter-frequency handover from Scell to PCell+CA
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_7_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_2_FDD}   value=0
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=8
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=10
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=20
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=25
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=30
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=35
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=40
    Sleep  10s
    Log to Console   >Handover completed.<

Release SCell TDD for 2640-AC_06
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=10
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=20
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=40
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=60
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=80
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AEHC_4_TDD}    value=90
    Log to Console  >SCell has been released.<

Verify CSI-RS for Channel Acquisition
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap  ${cells}=${subcells}
    ${msgs_CSI-RS}    check_CSI_RS  ${dir}    ${cells}
    should be true    ${msgs_CSI-RS}

Verify CQI Measurements
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    ${msgs_CQI}    check_CQI  ${dir}
    should be true    ${msgs_CQI}

Verify PM Counters 2640-AA
    log to console      Verify PM counters values
    ${counters}                 Read Counters Value 2640
    ${GNB_SCELL_2_ADMI_REQ_SA}    Get Counter Value From Single Cell      ${counters}     102    M55138C02501
    ${GNB_SCELL_2_ADMI_SUCC_SA}   Get Counter Value From Single Cell      ${counters}     102    M55138C02502
    ${GNB_DU_SCELL_2_ADMI_REQ_SA}    Get Counter Value From Single Cell    ${counters}    102    M55139C01501
    Should Be True      1<=${GNB_SCELL_2_ADMI_REQ_SA}
    Should Be True      1<=${GNB_SCELL_2_ADMI_SUCC_SA}
    Should Be True      1<=${GNB_DU_SCELL_2_ADMI_REQ_SA}

Read counters value 2640
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55138C02501  M55138C02502  M55139C01501
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   4  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify DT DL Flows through all cells
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap   ${cells}=${subcells}
    ${msgs_dl}    check_DL_flow  ${dir}  ${cells}
    should be true    ${msgs_dl}

Verify DT UL Flows through FDD Pcell
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    ${msgs_ul}    check_UL_flow  ${dir}
    should be true    ${msgs_ul}

Verify slots on Pcell
    [Arguments]  ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    ${slots_absence}    check_Pcell_slots  ${dir}
    should be true    ${slots_absence}

Check emil log 2640_AA
    [Arguments]  ${end_file}
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    set test variable  ${emil_out}  ${FALSE}
    ssh.execute   unzip C:/robot_script/*.zip -d C:/robot_script/           connection=LabPC
    Log to Console    Unzipped files.
    ${5gm_file_path}=  ssh.execute   find C:/robot_script/ | grep 5gm          connection=LabPC
    Log to Console    ${5gm_file_path}
    @{fivegm_files}    get_fivegm_files    ${5gm_file_path}
    Log to Console    @{fivegm_files}
    FOR    ${5gmfile}    IN    @{fivegm_files}
        Log to Console   Moving files.
        ssh.execute   mv ${5gmfile} C:/robot_script          connection=LabPC
    END
    ${execute}=  ssh.execute    robot -L trace -t Emil_decode_output_containing_msg_id_with_message_names_as_NA
    ...  -v end_file:*.${end_file} C:/robot_script/2640_emil.robot  connection=LabPC
    ${emil_out}=  Run keyword and return status  Should Contain  ${execute}   PASS
    run keyword if   ${emil_out}
    ...   Log to console   RRC_Reconfiguration contains 2SCell
    ...   ELSE
    ...   Log to console  RRC_Reconfiguration does NOT contain 2SCell
    set suite variable   ${emil_out}
    [Teardown]  ssh.Disconnect    connection=LabPC

Check emil log 2640_AC
    [Arguments]  ${end_file}
    ssh.connect to      hostname=${labpcip}    username=${labpcname}     password=${labpcpass}    alias=LabPC
    set test variable  ${emil_out}  ${FALSE}
    ssh.execute   unzip C:/robot_script/*.zip -d C:/robot_script/           connection=LabPC
    Log to Console    Unzipped files.
    ${5gm_file_path}=  ssh.execute   find C:/robot_script/ | grep 5gm          connection=LabPC
    Log to Console    ${5gm_file_path}
    @{fivegm_files}    get_fivegm_files    ${5gm_file_path}
    Log to Console    @{fivegm_files}
    FOR    ${5gmfile}    IN    @{fivegm_files}
        Log to Console   Moving files.
        ssh.execute   mv ${5gmfile} C:/robot_script          connection=LabPC
    END
    ${execute}=  ssh.execute    robot -L trace -v end_file:*.${end_file} C:/robot_script/2640_emil_AC.robot             connection=LabPC
    ${emil_out}=  Run keyword and return status  Should Contain  ${execute}   PASS
    run keyword if   ${emil_out}
    ...   Log to console   RRC_Reconfiguration contains SCellToReleaseList
    ...   ELSE
    ...   Log to console  RRC_Reconfiguration does NOT contain SCellToReleaseList
    set suite variable   ${emil_out}
    [Teardown]  ssh.Disconnect    connection=LabPC

# Send Emil script
#     [Arguments]    ${dcap_filepath}
#     Run   sshpass -p '${labpcpass}' scp ${dcap_filepath} ${labpcname}@${labpcip}:C:/robot_script
#     Run   sshpass -p '${labpcpass}' scp ${Emil_keywords} ${labpcname}@${labpcip}:C:/robot_script
#     Run   sshpass -p '${labpcpass}' scp ${tes_emil} ${labpcname}@${labpcip}:C:/robot_script
#     Run   sshpass -p '${labpcpass}' scp ${tes_emil_2} ${labpcname}@${labpcip}:C:/robot_script
