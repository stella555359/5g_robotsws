***Settings ***
Documentation
    ...     [Procedure]             "EDA_27971"
    ...     [Date]                  "06-05-21"
    ...     [Author]                "Sahana"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "FIREWALL, COUNTERS, NETACT"
    ...     [Feature_ID]            "RP000366,5G000265,CNI40152-A,CB007135"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2011"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Variables ***

${index}                    1
${length}                   20

${mplaneIP}               	10.63.87.125

*** Test Cases ***

[1][1.0] SMTRS-27870 TRS IP is lost occassionally when cancel collect snapshot and reset BBMOD

    Perform Commissioning       scf_file=${ONAIR_IPSEC}   verify_bts_status=False     timeout=400     alias=default
    Sleep    700
     Verify Bts Status   should_be_onair=${True}
     BBMOD Reset

*** Keywords ***

BBMOD Reset
   FOR    ${index}    IN RANGE    ${length}
       Run Keywords In Parallel     Run Keyword And Ignore Error    Collect Snapshot     timeout=60    AND
       ...     Run keyword And Ignore Error   Reset      operation=reset_unit
       ...     dist_name=MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1      reset_type=Warm      timeout=80
       ...     verify_bts=${False}

               Execute command on gNB   ping -I '${mplaneIP}' -c 200
               Sleep     200

       Snapshot Cancel
       Sleep     400
       Verify Bts Status   should_be_onair=${True}
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
    END

