*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com
...   TEST STEPS
...   1. Change gNbCuName parameter and lock/unlock ng link and verify related counters
...   2. Verify that only one AMF is running after NGC Flex SA Mode parameter deactivation
...   3. Verify AMF is not shutdown when all cells are locked and Enhanced NG RAN support (feat CB008083) is deactivated
...   4. Verify AMF is  shutdown when all cells are locked and Enhanced NG RAN support (feat 8083) is activated
...   5. Verify all AMFs are up after cells are unlocked and NGC Flex SA Mode parameter is activated again


Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/regression_keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008083/specific_keywords_8083.py


*** Variables ***
${AMF_1}       cmm-nala
${AMF_2}       amf-jill
${gNbCuName}   MUTANT1
&{counters_expected_val}   M55119C00501=1  M55121C00009=1  M55121C00010=1  M55121C00011=0  M55121C00012=1  M55121C00013=1  M55121C00014=0


*** Keywords ***
CB008083_C_block_nglink
    add_amf   ip_address=10.94.232.6
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_2}   expected_status=Active
    Show Text on Console   [Set gNB CU Name and verify E1AP Congiguration Update message]
    wro4_pm.sync_to_next_reporting_interval   offset=0
    Tcpdump.Start Tcpdump On SMOD    filename=gnbcuname
    common_keywords.Update Parameter   param=gNbCuName   value=${gNbCuName}
    ${pcap_file}  Tcpdump.Stop tcpdump and download logs from SMOD
    Verify gNB CU Name   ${pcap_file}  ${gNbCuName}

    Show Text on Console   [Lock NG Link and verify status]
    change_ng_link_status   action=lock
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_1}   expected_status=Inactive
    Show Text on Console   [Unlock NG Link and verify status]
    change_ng_link_status   action=unlock
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_1}   expected_status=Active

    Show Text on Console   [Wait for counters verification]
    wro4_pm.sync_to_next_reporting_interval
    ${pm_counters}   Get Dictionary Keys   ${counters_expected_val}
    FOR  ${pm}  IN  @{pm_counters}
        Run Keyword And Continue On Failure    Verify Counter Value   ${pm}  expected_value=${counters_expected_val}[${pm}]
    END

    Show Text on Console   [Verify AMFs status]
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_1}   expected_status=Active
    Verify AMF status   ${current_status}  amf=${AMF_2}   expected_status=Active

    Show Text on Console   [Deactivate NGC Flex SA Mode and verify only one AMF is active]
    common_keywords.Update Parameter   param=actAmfPlannedRemoval   value=false
    common_keywords.Update Parameter   param=actNgcFlexSaMode   value=false
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_1}   expected_status=Active
    Verify AMF status   ${current_status}  amf=${AMF_2}   expected_status=Inactive

    Show Text on Console   [Deactivate Enhanced NG RAN support (feat 8083) and lock ALL cells]
    common_keywords.Update Parameter   param=actEnhancedNgRanSupport   value=false
    block_all_nr_cells
    Show Text on Console   [Verify AMF is still ACTIVE]
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_1}   expected_status=Active
    Show Text on Console   [Unlock ALL cells]
    unblock_all_nr_cells
    Wait For On Air

    Show Text on Console   [Activate Enhanced NG RAN support (feat 8083) and lock ALL cells]
    common_keywords.Update Parameter   param=actEnhancedNgRanSupport   value=true
    block_all_nr_cells
    Show Text on Console   [Verify AMF is DOWN]
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_1}   expected_status=Inactive

    Show Text on Console   [Activate NGC Flex SA Mode and unlock ALL cells]
    common_keywords.Update Parameter   param=actNgcFlexSaMode   value=true
    unblock_all_nr_cells
    Wait For On Air
    Show Text on Console   [Verify AMFs status]
    ${current_status}   get_amf_status
    Verify AMF status   ${current_status}  amf=${AMF_1}   expected_status=Active
    Verify AMF status   ${current_status}  amf=${AMF_2}   expected_status=Active

    [Teardown]    Run Keywords
    ...   common_keywords.Update Parameter   param=actNgcFlexSaMode  value=true
    ...   AND  common_keywords.Update Parameter   param=actAmfPlannedRemoval   value=true
    ...   AND  delete_gNbCuName
    ...   AND  Tcpdump.teardown_tcpdump_on_smod
    ...   AND  delete_amf


Verify AMF status
    [Arguments]   ${current_status}   ${amf}   ${expected_status}
    Should Be Equal As Strings   ${expected_status}  ${current_status}[${amf}]
    Log To Console   ${SPACE}AMF: ${amf} is ${expected_status}
