*** Settings ***
Documentation
...     [Procedure]             "Link Aggregation Support for Backhaul"
...     [Author]                "Sahana TC Santhosh KG"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab For Reporting"
...     [Feature_ID]            "CB006666"
...     [Requirement ID]        "TT_NCONF.2336; TT_L2.2720;TT_NCONF.1979;TT_NCONF.1999;TT_NCONF.2342;TT_NCONF.2360;
...     TT_L2.2735; TT_L2.2710; TT_L2.2812; TT_L2.2893 ;LTE_OPR_REQ_33492"
...     [Funtion_Hash_Tags]     "Link Aggregation Support For Backhaul"
...     [Domain_Hash_Tags]      "Backhaul L2"
...     [Validated_TestLine]    "2213"
...     [Config]                "LAGRP under MRBTS-id/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1"
...     [Runtime param]         "bts_id is provided at run time."

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_LAG.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1][1.0] CB006666-SR-B_Verification of 2 LAG group creation_A_A

   Perform Commissioning       scf_file=${base_scf}   verify_bts_status=${False}     timeout=900     alias=default
   Alarms before LAG
   Configure LAG on Switch and BTS 	 	dynamic_lag		 ${CreateLAGActiveStandby}
   Configure LAG on Switch and BTS	 	dynamic_lag_e_2lag		 ${CreateLAGActiveStandbyE1}
   Verify LAG Parameters in LAPCDUs      bts1     bts2     lag_a    lag_s    lag_active    lag_standby
   Run Keyword And Ignore Error          Check LAG and Port Status        enabled		    ACTIVE_ENABLED  		STANDBY_ENABLED
   Reload BTS And Switch
   Remove LAG Configuration From BTS and Switch       remove_lag_e       ${DeleteLAGActiveStandbyE1}
   Alarms after LAG
