*** Settings ***
Documentation
...     [Procedure]     "BTS reset scenario"
...     [Date]          "13-03-2022"
...     [Author]        "Shweta"
...     [Feature_ID]    "EDA_SMTRS-2679135"
...     [Validated_TestLine]"2202"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0] Dual core iterative RAT reset

      BTS RESET1

*** Keywords ***

BTS RESET1
     FOR    ${index}    IN RANGE  10

#Step1
         Perform Commissioning       scf_file=${Full_Configuration}      verify_bts_status=True   rat=all   timeout=400     alias=default
         Sleep   60

#Step2  Verify BTS  is onAir after RAT Reset
        Reset                           operation=reset_rat            rat=NR
        Sleep    300
        Continue Keyword Execution On Failure       ${true}
		Verify Alarm        expected_alarms=${expected_alarms}      check_unexpected_alarms=True
		Verify Bts Status   req_rat=nr             should_be_onair=${True}
        Reset                           operation=reset_rat            rat=lte
        Sleep    300
		Verify Alarm        expected_alarms=${expected_alarms}      check_unexpected_alarms=True
		Verify Bts Status   req_rat=lte             should_be_onair=${True}
		Reset                           operation=reset_rat            rat=wcdma
         Sleep    240
         Verify Alarm        expected_alarms=${expected_alarms}      check_unexpected_alarms=True
         Verify Bts Status   req_rat=wcdma             should_be_onair=${True}
         Reset                           operation=reset_rat            rat=gsm
         Sleep    300
         Verify Alarm        expected_alarms=${expected_alarms}      check_unexpected_alarms=True
         Verify Bts Status   req_rat=gsm             should_be_onair=${True}

      END

