*** Settings ***
Resource          ./Resources/5GC001726_keywords.robot

Documentation    Suite description
...   author: Ren Biyao
...   contact: biyao.ren@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature 5GC001726-GA in 5G19B program
...   migrated to krk by klaudia.horyn@nokia.com

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               prefix_tag=5GC001726
...               increase_time_for_checking_radios=3600
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions     collect_syslog=${False}
Test Teardown     Common Postconditions    collect_syslog=${False}

*** Variables ***
${local_modid_cell_1}     PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-51
${local_modid_cell_2}     PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-52
${local_modid_cell_3}     PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-53
${local_modid_cell_4}     PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-54
&{rrc_reconf_att_cell_1}        id=M55118C02008    name=RRC_RECONF_5_SCELL_DL_ATT      mo_id=${local_modid_cell_1}    value=1
&{rrc_reconf_att_cell_2}        id=M55118C02008    name=RRC_RECONF_5_SCELL_DL_ATT      mo_id=${local_modid_cell_2}    value=0
&{rrc_reconf_att_cell_3}        id=M55118C02008    name=RRC_RECONF_5_SCELL_DL_ATT      mo_id=${local_modid_cell_3}    value=0
&{rrc_reconf_att_cell_4}        id=M55118C02008    name=RRC_RECONF_5_SCELL_DL_ATT      mo_id=${local_modid_cell_4}    value=0
&{rrc_reconf_succ_cell_1}       id=M55118C03008    name=RRC_RECONF_5_SCELL_DL_SUCC     mo_id=${local_modid_cell_1}    value=1
&{rrc_reconf_succ_cell_2}       id=M55118C03008    name=RRC_RECONF_5_SCELL_DL_SUCC     mo_id=${local_modid_cell_2}    value=0
&{rrc_reconf_succ_cell_3}       id=M55118C03008    name=RRC_RECONF_5_SCELL_DL_SUCC     mo_id=${local_modid_cell_3}    value=0
&{rrc_reconf_succ_cell_4}       id=M55118C03008    name=RRC_RECONF_5_SCELL_DL_SUCC     mo_id=${local_modid_cell_4}    value=0
@{counters_list}    &{rrc_reconf_att_cell_1}     &{rrc_reconf_att_cell_2}     &{rrc_reconf_att_cell_3}      &{rrc_reconf_att_cell_4}
...                &{rrc_reconf_succ_cell_1}    &{rrc_reconf_succ_cell_2}    &{rrc_reconf_succ_cell_3}     &{rrc_reconf_succ_cell_4}

*** Test Cases ***
[1][1.0] 5GC001726_GA_122_M55118C02008_M55118C03008
    [Documentation]    Author: Ren Biyao
    ...    Terminal is qcom ue. Verify the PM counters M55118C02008 and M55118C03008 can work correctly.
    Wait For Next Full Pm Interval
    ue.Require UE   UE_1    capabilities=REAL_ANDROID_UE
    ue.Attach UE   UE_1    48
    Start Streams For DL And UL Data Transmission For Specified Time For UDP    data_transfer_time=15
    ...    ul_throughput=50 Mbits/sec    dl_throughput=100 Mbits/sec
    Await DL And UL Data Transmission Finish
    Verify DL And UL Data Transmission Loss For UDP     deviation=5
    ue.Detach Ue    UE_1
    Wait For Next Full Pm Interval
    ${pm_counters_file}=    pmcounter.Get Latest Unpacked Full PM Counters File
    Verify PM Counters Have Exact Values    filepath=${pm_counters_file}    counters=${counters_list}

*** Keywords ***
Verify PM Counters Have Exact Values
    [Documentation]    Verifies if PM counters have exactly specified values.
    ...                KW expects counters as dictionaries with ``id``, ``name``, ``mo_id`` and ``value`` fields.
    ...                Additional fields will be ignored. Continues execution even if verification fails.
    ...                - ``filepath``: Path to XML file with counters
    ...                - ``counters``: List of counter dictionaries with ``id``, ``name``, ``mo_id`` and ``value`` fields
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | $\{MO_ID\} | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    ...                | &\{CNT_1\} | id=M55335C03001 | name=UL_GRANT_AL1_CBWP1 | mo_id=$\{MO_ID\} | value=2500 |
    ...                | &\{CNT_2\} | id=M55335C03002 | name=UL_GRANT_AL2_CBWP1 | mo_id=$\{MO_ID\} | value=3000 |
    ...                | @\{COUNTERS\} | &\{CNT_1\} | &\{CNT_2\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | Verify PM Counters Have Exact Values | filepath=counters.xml | counters=$\{COUNTERS\} |
    [Arguments]    ${filepath}    ${counters}
    File Should Exist    ${filepath}
    Log to Console    Verifying that PM Counters have exact values
    FOR    ${counter}    IN     @{counters}
      ${out_values}    pmcounter.Get Pm Counter Value
      ...    counter=${counter.id}    localmoid=${counter.mo_id}    filepath=${filepath}
      Run Keyword And Continue On Failure    Should Not Be Empty    ${out_values}
      ...    msg=PM Counter ${counter.name} (${counter.id}) does not exist in ${filepath} under ${counter.mo_id}
      Run Keyword And Continue On Failure    Run Keyword If    ${out_values} != []
      ...    Should Be True    ${out_values}[0] == int(${counter.value})
      ...    msg=PM Counter ${counter.name} (${counter.id}) value: ${out_values}[0] is not expected ${counter.value}
    END

