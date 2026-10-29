*** Settings ***
Documentation
...	    [Procedure]	 "The test case is planned to validate for continuous cell lock/unlock scenario and bbmod reset"
...	    [Date]		"03-06-2023"
...	    [Author]		"Pooja"
...	    [Feature_ID] 	"SMTRS-29429"
...	    [Validated_TestLine]"2205"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops



*** Variables ***

${index}                    1
${length}                   10

***Test Cases***
[1][1.0] SMTRS-29429 -Cell lock,unlock and BBmod reset with snapshot collection

       Log     Step1  Make gNB on-air
      Perform Commissioning       scf_file=${Full_Configuration}      verify_bts_status=True      timeout=400
      ...     alias=default
      Sleep   80
      NRCell Ops
      BBMOD Reset


***Keywords***
NRCell Ops

         Log     Step2  Verify BTS is on-air
        Verify Bts Status           should_be_onair=${True}         req_rat=LTE

            Log   Lock/Unlock NRCell
        Perform Recommissioning     type=param    param_path=${cell-1}   operation=update      value=locked
        ...     timeout=400
        Sleep    30
        Verify Bts Status           should_be_onair=${TRUE}         req_rat=LTE
        Perform Recommissioning     type=param    param_path=${cell-1}    operation=update      value=unlocked
        ...     timeout=300
        Sleep    80
        Run Keyword     Collect Snapshot    coverage=Full   file_extension=zip   timeout=300    alias=default

BBMOD Reset
     FOR    ${index}    IN RANGE    ${length}
        Reset      operation=reset_unit  dist_name=MRBTS-${2223}/EQM-1/APEQM-1/CABINET-1/BBMOD-2      reset_type=Warm
        ...     timeout=200    verify_bts=${True}

        Verify Bts Status           should_be_onair=${True}         req_rat=LTE

        Sleep    80

         Reset      operation=reset_unit  dist_name=MRBTS-${2223}/EQM-1/APEQM-1/RMOD-1      reset_type=Warm
         ...    timeout=300    verify_bts=${True}

        Run Keyword     Collect Snapshot    coverage=Full   file_extension=zip	  timeout=300    alias=default
     END
