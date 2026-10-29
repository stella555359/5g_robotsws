*** Settings ***
Documentation   covers the verifcation of the TCs for CB012656
...             2 parts - verification for each TC
...                     - keywords to verify the trace
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
#Resource    ../../resources/Common/gnb.robot
#Resource    ../resources/pcap_analysis.robot
#Library     taf.sbts.oam.coam.admin          WITH NAME   admin


*** Keywords ***

Verify test case
   [Arguments]   ${test_name}

   run keyword  Verify test case ${test_name}

Verify test case CB012656-A-004_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_gNBinitiatedRRCRelease
    log to console    \nStarting TC Verification
    Log to Console    \n Verify TC checks on gNB${gnb_id}

    Run Keyword And Continue On Failure
    ...  Check for cellReselectionPriority and cellReselectionSubPriority  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure
    ...  Check cellReselection list order for cell without wrr configuration  tcp_file=${tcp_file}

Verify test case CB012656-A-026_NR_UL_CA_aware_Idle_mode_mobility_steering_Weight_based_gNBinitiatedRRCRelease
    log to console    \nStarting TC Verification
    Log to Console    \n Verify TC checks on gNB1

    Run Keyword And Continue On Failure
    ...  Check cellReselection list order for cell without wrr configuration  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure
    ...  Check for cellReselectionPriority and cellReselectionSubPriority for weight based  tcp_file=${tcp_file}

Verify test case CB012656-B-006_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_with_MobProfile
    log to console    \nStarting TC Verification
    Log to Console    \n Verify TC checks on gNB1

    Run Keyword And Continue On Failure
    ...  Check for cellReselectionPriority and cellReselectionSubPriority  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure
    ...  Check cellReselection list order for cell without wrr configuration  tcp_file=${tcp_file}

Verify test case CB012656-D-006_NR_DL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_CB012656_enabled_withMob_Profile
    log to console    \nStarting TC Verification
    Log to Console    \n Verify TC checks on gNB1

    Run Keyword And Continue On Failure
    ...  Check for cellReselectionPriority and cellReselectionSubPriority  tcp_file=${tcp_file}
    Run Keyword And Continue On Failure
    ...  Check cellReselection list order for cell without wrr configuration  tcp_file=${tcp_file}


#keywords section


Check cellReselection list order for cell without wrr configuration
    [Arguments]   ${tcp_file}

    ${output}    ute_tshark.read pcap    packet_filter=${PROTOCOL_NAME}.procedureCode == 6  output_type=pdml  pcap_file_path=${tcp_file}
    set test variable      ${list_entry}  ${0}
    FOR  ${i}  IN RANGE  ${number_of_WRR_frequencies}  ${number_of_cells_with_reselection}
        ${carrierFreq}  Get Elements
        ...  ${output}  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item ${i}']//field[@name="nr-rrc.carrierFreq"]
        set test variable      ${carrierFreq_${i}}  ${carrierFreq}
            FOR  ${j}  IN   @{carrierFreq_${i}}
                ${showname}  Get element attribute  ${j}  showname
                Should Contain    	${showname}  ${non_wrr_frequency_list[${list_entry}]}  msg=wrong order in cellReselection
            END
        log to console  \nfrequency ${i} in correct order in cellReselection
        ${list_entry}  Evaluate  ${list_entry}+1
    END

Check for cellReselectionPriority and cellReselectionSubPriority
    [Arguments]        ${tcp_file}
    [Documentation]    check is only  done for 3 cell configured with WRR at the moment

    ${output}    ute_tshark.read pcap    packet_filter=${PROTOCOL_NAME}.procedureCode == 6  output_type=pdml  pcap_file_path=${tcp_file}
    FOR  ${i}  IN   @{wrr_frequency_list}
        ${bandcombinationindex1}  Get Element Count
        ...  ${output}  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item 0']//field[@showname="carrierFreq: ${i}"]
        ${bandcombinationindex2}  Get Element Count
        ...  ${output}  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item 1']//field[@showname="carrierFreq: ${i}"]
        ${bandcombinationindex3}  Get Element Count
        ...  ${output}  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item 2']//field[@showname="carrierFreq: ${i}"]
        log to console  \nfrequency of cell configured with WRR=${i}
        log to console  \nused as primary/secondary/third target in reselection message
        log to console  ${bandcombinationindex1}/${bandcombinationindex2}/${bandcombinationindex3}
        Run Keyword And Continue On Failure
        ...  Should Not Be Equal As Integers  ${bandcombinationindex1}  0  msg=frequency was not used a primary target cell in reselection message
        Run Keyword And Continue On Failure
        ...  Should Not Be Equal As Integers  ${bandcombinationindex2}  0  msg=frequency was not used a secondary target cell in reselection message
        Run Keyword And Continue On Failure
        ...  Should Not Be Equal As Integers  ${bandcombinationindex3}  0  msg=frequency was not used a secondary target cell in reselection message
    END

    FOR  ${i}  IN RANGE  ${number_of_WRR_frequencies}
        ${cellReselectionPriority}  Get Elements  ${output}
        ...  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item ${i}']//field[@name="nr-rrc.cellReselectionPriority"]
        set test variable      ${cellReselectionPriority_${i}}  ${cellReselectionPriority}
    END

    FOR  ${i}  IN RANGE  1  ${number_of_WRR_frequencies}
        ${cellReselectionSubPriority}  Get Elements  ${output}
        ...  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item ${i}']//field[@name="nr-rrc.cellReselectionSubPriority"]
        set test variable      ${cellReselectionSubPriority_${i}}  ${cellReselectionSubPriority}
    END

    FOR  ${i}  IN   @{cellReselectionPriority_0}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  7
    END

    FOR  ${i}  IN   @{cellReselectionPriority_1}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  6
    END

    FOR  ${i}  IN   @{cellReselectionPriority_2}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  6
    END

    FOR  ${i}  IN   @{cellReselectionSubPriority_1}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  8
    END

    FOR  ${i}  IN   @{cellReselectionSubPriority_2}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  6
    END

Check for cellReselectionPriority and cellReselectionSubPriority for weight based
    [Arguments]        ${tcp_file}
    [Documentation]    check is only  done for 3 cell configured with WRR at the moment

    ${output}    ute_tshark.read pcap    packet_filter=${PROTOCOL_NAME}.procedureCode == 6  output_type=pdml  pcap_file_path=${tcp_file}
    ${index}  set variable  ${1}
    FOR  ${i}  IN   @{wrr_frequency_list}
        ${bandcombinationindex1}  Get Element Count
        ...  ${output}  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item 0']//field[@showname="carrierFreq: ${i}"]
        ${bandcombinationindex2}  Get Element Count
        ...  ${output}  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item 1']//field[@showname="carrierFreq: ${i}"]
        ${bandcombinationindex3}  Get Element Count
        ...  ${output}  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item 2']//field[@showname="carrierFreq: ${i}"]
        log to console  \nfrequency of cell configured with weight=${i}
        log to console  \nused as primary/secondary/third target in reselection message
        log to console  ${bandcombinationindex1}/${bandcombinationindex2}/${bandcombinationindex3}
        Run Keyword And Continue On Failure
        ...  Should Be Equal As Integers  ${bandcombinationindex${index}}  ${repeat_rrc_release}
        ...  msg=frequency was not used a primary target cell in reselection message
        ${index}  Evaluate  ${index}+1
    END

    FOR  ${i}  IN RANGE  ${number_of_WRR_frequencies}
        ${cellReselectionPriority}  Get Elements  ${output}
        ...  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item ${i}']//field[@name="nr-rrc.cellReselectionPriority"]
        set test variable      ${cellReselectionPriority_${i}}  ${cellReselectionPriority}
    END

    FOR  ${i}  IN RANGE  1  ${number_of_WRR_frequencies}
        ${cellReselectionSubPriority}  Get Elements  ${output}
        ...  .//field[@name='nr-rrc.cellReselectionPriorities_element']//field[@show='Item ${i}']//field[@name="nr-rrc.cellReselectionSubPriority"]
        set test variable      ${cellReselectionSubPriority_${i}}  ${cellReselectionSubPriority}
    END

    FOR  ${i}  IN   @{cellReselectionPriority_0}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  7
    END

    FOR  ${i}  IN   @{cellReselectionPriority_1}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  6
    END

    FOR  ${i}  IN   @{cellReselectionPriority_2}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  6
    END

    FOR  ${i}  IN   @{cellReselectionSubPriority_1}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  8
    END

    FOR  ${i}  IN   @{cellReselectionSubPriority_2}
        ${showname}  Get element attribute  ${i}  showname
        Should Contain    ${showname}  6
    END
