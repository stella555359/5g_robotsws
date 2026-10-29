*** Settings ***
Documentation
...  AUTHOR          :   Prasanta Kumar Nayak
...  MAINTAINER      :   Prasanta Kumar Nayak
...  INTRODUCTION    :  CB014134 Feature which interacts LTE 928 and LTE 3544
...                    above the thershold value with the configured powerr backoff.
...  TEST SET NAME   :   [1]CB012719_C#IWK_2_ CB012719 feature interworking with EIRP functionality
...  TESTING SPLIT   :   SPLIT-A
...  CONTACTS        :  Prasanta Kumar Nayak
...  REFERENCES      :   CFAM CB014134
...  REQUIREMENT ID  :    RRM_LTE_SFS_RRMT_15791,OM_LTE_SFS_RNL.30320,RRM_LTE_SFS_RRMT_15792



Library  OperatingSystem
Library  ta_uexgate
Library  taf.ul.ue.sim.env_setup
Library     ute_fsmaccess
#Library     ute_admin
#Library      ute_wtssim
Resource    ./CB014134_resource.robot


*** Test Cases ***
[1][1.0] CB014134_RRMT_LTE928#3_features_interworking_in_case_of_remote_interference_and_verification_of_PM_counters
#     Configure Env for CB014134
#     sleep    60sl
     ${cmd}      set variable     rm -rf pscli *pstools* TtiTracer
     Run Keyword    Run    ${cmd}
     ${moc}     set variable     MRBTS-1/LNBTS-1/LNCEL-1/LNCEL_TDD-0/RIMINFO-0
     CB014134_resource.Make connection
     Enable Macpscli To UTE Customize
     ${ret1}    Verify CM state customize    ${moc}      ${riDetectState}
     Should Contain	    ${ret1}	        FAIL
     ${ret2}    Verify CM state customize    ${moc}      ${riDlMitigationState}
     Should Contain	    ${ret2}	        FAIL
     ${ret3}    Verify CM state customize    ${moc}      ${riDetectEnbInfoList}
     Should Contain	    ${ret3}	        FAIL

     Find Scfc And Send Delta Commissioning    lock_all_except_cell_1.json
     sleep   60s
     Find Scfc And Send Delta Commissioning    riDetectState_cmfm_leg.json
     sleep    60s
     Find Scfc And Send Delta Commissioning    LTE928_rim.json
     sleep    60s
     log to console   set R&D parametere
#     Enable Macpscli To UTE
     Wait For Fault To Be Up     fault_id=6124   timeout=120
     Find Scfc And Send Delta Commissioning    riDetectState_cm_fm_disable.json
     sleep     60s
     ${ret1}    Verify CM state customize    ${moc}      ${riDetectState}
     Should Contain	    ${ret1}	        FAIL
     ${ret2}    Verify CM state customize    ${moc}      ${riDlMitigationState}
     Should Contain	    ${ret2}	        FAIL
     ${ret3}    Verify CM state customize    ${moc}      ${riDetectEnbInfoList}
     Should Contain	    ${ret3}	        FAIL
     Wait For Fault To Be Down     fault_id=6124   timeout=60
     Find Scfc And Send Delta Commissioning    riDetectState_cmfm_leg.json
     sleep    60s

     Wait For Fault To Be Up     fault_id=6124   timeout=120
     Find Scfc And Send Delta Commissioning    riDetectState_cm_enabled.json
     sleep     906s
     ${ret1}    Verify CM state customize    ${moc}      ${riDetectState}
     should contain        ${ret1}      remote interference detected with DHE
     ${ret2}    Verify CM state customize    ${moc}      ${riDlMitigationState}
     Should Contain	    ${ret2}	        FAIL
     ${ret3}    Verify CM state customize    ${moc}      ${riDetectEnbInfoList}
     Should Contain	    ${ret3}	        FAIL

     Wait For Fault To Be Down     fault_id=6124   timeout=60
     Remove ul noise    1
     sleep     905s
     ${ret1}    Verify CM state customize    ${moc}      ${riDetectState}
     should contain        ${ret1}      no remote interference
     ${ret2}    Verify CM state customize    ${moc}      ${riDlMitigationState}
     Should Contain	    ${ret2}	        FAIL
     ${ret3}    Verify CM state customize    ${moc}      ${riDetectEnbInfoList}
     Should Contain	    ${ret3}	        FAIL
#
     Add ul noise   1
     sleep    905s
     ${ret1}    Verify CM state customize    ${moc}      ${riDetectState}
     should contain        ${ret1}      remote interference detected with DHE
     ${ret2}    Verify CM state customize    ${moc}      ${riDlMitigationState}
     Should Contain	    ${ret2}	        FAIL
     ${ret3}    Verify CM state customize    ${moc}      ${riDetectEnbInfoList}
     Should Contain	    ${ret3}	        FAIL
     sleep     1800s
     Run Keyword and Ignore Error    VerIfy LTE RIM Counters with 928
     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB014134_RRMT_LTE3544_1_DwPTS_rollback_triggered_by_RI_sequences_detection
     ${moc}     set variable     MRBTS-1/LNBTS-1/LNCEL-1/LNCEL_TDD-0/RIMINFO-0
     Find Scfc And Send Delta Commissioning    act_ri_avoidance.json
     Add ul noise   1
     Generate RI sequences    1
     sleep    10800s
     ${ret1}    Verify CM state customize    ${moc}      ${riDetectState}
     should contain        ${ret1}      remote interference detected with DHE
     ${ret2}    Verify CM state customize    ${moc}      ${riDlMitigationState}
     should contain        ${ret2}      DL RI mitigation with SSP rollback
     ${ret3}    Verify CM state customize    ${moc}      ${riDetectEnbInfoList}
     Should Be Equal        ${ret3}      ${3}
     Run Keyword and Ignore Error    VerIfy LTE RIM Counters with ssp roll
     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
