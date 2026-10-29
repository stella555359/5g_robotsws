*Settings ***
Documentation
    ...     [Procedure]             "CB010846 BB Capacity board improvement in reconfiguration and recovery"
    ...     [Date]                  "09-09-24"
    ...     [Author]                "Nethra"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Operability"
    ...     [Feature_ID]            "CB010846"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2011"
    ...     [Requirements]          "5G_RAN_USR_COM_21094,OM_GEN_SFS_SYSM.9224,5G_RAN_USR_COM_21991,5G_RAN_USR_COM_21997"


Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/Common_keywords_CB010846.robot



Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Variables ***

${index}                    1
${length}                   3


*** Test Cases ***
[1]CB010846-SR-A RU resiliency to BTS-DU L1Soc reset - ST TRS_Controlled reset_ecpri
#Comment : Innitate Rat reset as part of controlled reset operation
     Reset     operation=reset_rat     rat=nr     timeout=300
     Reset     operation=reset_rat     rat=lte     timeout=300
     Read mplane IP
     Ping to Mplane
     Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
     Verify RU1 uptime Cpri
     Verify RU2 uptime Ecpri
     Sleep      200
     Run Keyword And Ignore Error       Verify Bts Status   should_be_onair=${True}    rat=nr
#     #Persistency Check - BTS reset and verify BBMOD reset
     Reset Bts   dut=bts    verify_bts=${False}     timeout=300     alias=default
     Sleep     400
     BBMOD Reset
     Read mplane IP
     Ping to Mplane
     Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
     Verify RU1 uptime Cpri
     Verify RU2 uptime Ecpri
