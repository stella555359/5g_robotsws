*** Settings ***
Documentation   This is a Robot Test Suite for feature 'CB012656' testing
...             Team: 'MN ECE ULM R&D L3NRT 07 SqdGp62'
...             Email: 'I_ECE_RD_ULM_SQD_62_GMS@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                         taf.ue
Resource                        CB012656_keywords.robot

Suite Setup                     CB012656_keywords.Prepare TL for Testing
Suite Teardown                  CB012656_keywords.Save all Logs and Teardown TL

Test Setup                      CB012656_keywords.Setup test
Test Template                   Setup of inter-band CA with alternative bands


*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=200 Mbits/sec
...                             UL_THROUGHPUT=50 Mbits/sec
...                             TPUT_DEVIATION=10%
...                             DURATION=10s
...                             PROTOCOL=udp
${WITH_PMCOUNTER_CHECK}         true
${INITIAL_SCF_FILE_ACTIVATION}  true
${UE_ALIAS_1}                   UE_1


*** Test Cases ***
CB012656-A-004_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_gNBinitiatedRRCRelease
    ...             gnb_id=${0}
    ...             cell=9
    ...             capabilities=UE1
    ...             repeat_rrc_release=${12}
    ...             wrr_frequency=125330,635712,425790
    ...             non_wrr_frequency=176410,648672
    ...             enb_id=${0}
   [Template]       NR UL CA aware Idle mode mobility
   [TAGS]           CB0012656  CB012656-A-004
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_25168 USCB012656-A#B01
   ...              current implementation:
   ...              -  all given frequencies are working combination for cell reselection
   ...              -  frequencies with configurated cellReselectionPriority are in the correct order
   ...              --> it needs to be checked if it makes sense to change this limitations (e.g. get frequencies etc from scf)


CB012656-A-026_NR_UL_CA_aware_Idle_mode_mobility_steering_Weight_based_gNBinitiatedRRCRelease
    ...             gnb_id=${0}
    ...             cell=9
    ...             capabilities=UE1
    ...             repeat_rrc_release=${5}
    ...             wrr_frequency=425790,125330,635712
    ...             non_wrr_frequency=176410,648672
    ...             enb_id=${0}
   [Template]       NR UL CA aware Idle mode mobility
   [TAGS]           CB0012656  CB012656-A-026
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_25168 USCB012656-A#B01-ALT4
   ...              current implementation:


CB012656-B-006_NR_UL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_with_MobProfile
    ...             gnb_id=${0}
    ...             cell=1
    ...             capabilities=UE1
    ...             repeat_rrc_release=${12}
    ...             wrr_frequency=426030,389790,635712
    ...             non_wrr_frequency=176410,648672,425790
    ...             enb_id=${0}
   [Template]       NR UL CA aware Idle mode mobility
   [TAGS]           CB0012656  CB012656-B-006
   [Documentation]  this TC covers user scenario 5G_RAN_USR_RRM_26014 USCB012656-B#B04-ALT3


CB012656-D-006_NR_DL_CA_aware_Idle_mode_mobility_steering_WRR_Prim_Sec_RRC_Inactive_CB012656_enabled_withMob_Profile
    ...             gnb_id=${0}
    ...             cell=1
    ...             capabilities=UE1
    ...             repeat_rrc_release=${12}
    ...             wrr_frequency=426030,389790,635712
    ...             non_wrr_frequency=176410,648672,425790
    ...             enb_id=${0}
   [Template]       NR UL CA aware Idle mode mobility
   [TAGS]           CB0012656  CB012656-D-006
   [Documentation]  this TC covers user scenario :  5G_RAN_USR_RRM_26028 USCB012656-D#B02-ALT4


*** Keywords ***
NR UL CA aware Idle mode mobility
    [Documentation]    Attach ue to pcell
    ...                Start traffic
    ...                setup scell
    ...                verify tc
    [Arguments]        ${gnb_id}  ${cell}  ${repeat_rrc_release}  ${wrr_frequency}  ${non_wrr_frequency}
    ...            	   ${enb_id}  ${capabilities}=REAL_MTK

    CB012656_keywords.Perform Preconditions of Test Scenario  gnb_id=${gnb_id}  cell=${cell}  wrr_frequency=${wrr_frequency}  enb_id=${enb_id}
    ...  non_wrr_frequency=${non_wrr_frequency}  capabilities=${capabilities}  repeat_rrc_release=${repeat_rrc_release}
    IF  '${WITH_PMCOUNTER_CHECK}'=='true'
        pmcounters.Wait Until The Next Measurement Period Starts  gnb_id=${gnb_id}
    END
    CB012656_keywords.Start neccessary traces
    attenuator_scenario.Set cell attenuation  globalcellid=${cell}   value=${10}   node_id=${gnb_id}
    taf.ue.Attach Ue   ${UE_ALIAS_1}  timeout=180
    Repeat Keyword    ${repeat_rrc_release} times    Start traffic and wait for RRC release
    taf.ue.Detach Ue  ${UE_ALIAS_1}
    CB012656_keywords.Stop all traces

#    possible add steps: 1. NRCELL.idleMMSteeringPercentageOfUes=0 --> no reselection list
#                        2. UE-NR-Capability supportedBandCombinationList --> change one object to a non supported capabilities
#                        3. WRR configured in NRFIM but not matching correct NRCAMP object --> cell reselection prio used

    CB012656_keywords.Verify qc test case

    [Teardown]    Run Keywords
    ...           CB012656_keywords.Perform Postconditions of Test Scenario
    ...  AND      syve_testline.CCRT Test Cases Teardown
