*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout         60min

Resource      Resource/CB007807_commonKW.robot

Documentation
...    Author:annie.hu
...    contact:annie.hu@nokia-sbell.com
...    squad group:SG_05
...    Feature Owner: Jin, Ming-Jim
...    Feature CB007807 in SBT22R3 program
...    This test case to verify activation micro-DTX feature on mRRH.
...    This feature will bring 5GC000430 feature support for following radios and
...    the HW revisions where from the functionality is supported:
...    AWHHD A103   AWHHF A103  AWHQE A103  AWHQF A103  AWHQG A103  AWHQM A102  AWHHI A102  AWHQV A101  AWHTA A101
...    And uDTX will not be support when below the above HW version.

Force Tags            RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
[1]CB007807-A_01_02_MicroDTX_activate_on_mRRH_ScRMTDr6.1_4T4R_Radio
   [Tags]     CRT_TRUNK   CRT_20B    CRT_21B    master_classicalbts_all
   [Setup]   SISO Coam Test Setup
    #General_Feature_Micro-DTX_activate_microDtxEnabled_true
    log to console   \n disable then enable Power Saving mode when cell on air
    Modify RMOD Power Parameter    power_status=false
    sleep  120
    selenium login and disable screen lock
    ${rmod_power_meassure_1}    Get RMOD Power Measurement via Webem    interval=1min
    #${smod_power_meassure_1}    Get SMOD Power Measurement via Webem    interval=1min
    General_Feature_Micro-DTX_activate_microDtxEnabled_true
    selenium login and disable screen lock
    ${rmod_power_meassure_2}    Get RMOD Power Measurement via Webem    interval=1min
    #${smod_power_meassure_2}    Get SMOD Power Measurement via Webem    interval=1min
    ${rmod_p_value}    Evaluate
    ...    "%.2f" % ((${rmod_power_meassure_1}-${rmod_power_meassure_2})/${rmod_power_meassure_1})
     ${rmod_per_value}    Evaluate    ${rmod_p_value}*100
     log to console   \n RMOD Power Saving Percent when cell on air:${rmod_per_value}%
     should be true      ${rmod_per_value} > 20
   [Teardown]   SISO Coam Test Teardown
