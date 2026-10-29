*** Settings ***
Documentation
...    Author:            Patryk Tatarek
...    Contact:           patryk.tatarek@nokia.com
...    Test Plan (QC):    /VRF_WRO3_T04/24R3/CB009857/
...    Description:
...        Split A:    Verify proper behaviour of CMP/CMPECDSA objects and
...                    ability to initialize certificate using them.
...        Split B:    Verify usability of secondary CMP settings and
...                    alternative subject names.
...        Split C:    Verify limitations and usability of CRDLPConfig objects,
...                    visibility of different certificate related alarms and
...                    proper functionality of certificate revocation list.
...        Split D:    Verify ability or limitations of certificate depending on
...                    their SHA and key length.


Resource    ../Resources/CB009857_Keywords.robot

*** Keywords ***
CMP_kur_failure-vDU
    Configure CMP                   ca_subject_name=CN=CB007672    ca_server_host=10.42.5.5    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    ${status}=                      Run Keyword and Return Status    Initialize Certificate    hw_type=vDU
    Should not be True              ${status}
    Alarm Should be Active          alarm=61510    hw_type=vDU
    [Teardown]                      Configure CMP    ca_subject_name=CN=CB007672    hw_type=vDU

CMP_kur_failure-vCU
    Configure CMP                   ca_subject_name=CN=CB007672    ca_server_host=10.42.5.5    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    ${status}=                      Run Keyword and Return Status    Initialize Certificate    hw_type=vCU
    Should not be True              ${status}
    Alarm Should be Active          alarm=61510    hw_type=vCU
    [Teardown]                      Configure CMP    ca_subject_name=CN=CB007672    hw_type=vCU

Max_polling_timeout_for_RSA_and_ECDSA-vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=cmpPollingTimeout    param_value=120    hw_type=vDU
    Configure CMP                   ca_subject_name=${CMP_POLLING_SUBJECT_NAME}    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    ${status}=                      Run Keyword and Return Status    Initialize Certificate    hw_type=vDU
    Should not be True              ${status}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMPECDSA-1
    ...                             param_name=cmpPollingTimeout    param_value=120    hw_type=vDU
    Configure CMP                   ca_subject_name=${ECDSA_POLLING_SUBJECT_NAME}    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    ${status}=                      Run Keyword and Return Status    Initialize Certificate
    ...                             key_pool_type=ECDSA    hw_type=vDU
    Should not be True              ${status}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=cmpPollingTimeout    param_value=3600    hw_type=vDU
    ...    AND                      Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMPECDSA-1
    ...                             param_name=cmpPollingTimeout    param_value=3600    hw_type=vDU

Max_polling_timeout_for_RSA_and_ECDSA-vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=cmpPollingTimeout    param_value=120    hw_type=vCU
    Configure CMP                   ca_subject_name=${CMP_POLLING_SUBJECT_NAME}    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    ${status}=                      Run Keyword and Return Status    Initialize Certificate    hw_type=vCU
    Should not be True              ${status}
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMPECDSA-1
    ...                             param_name=cmpPollingTimeout    param_value=120    hw_type=vCU
    Configure CMP                   ca_subject_name=${ECDSA_POLLING_SUBJECT_NAME}    server_type=ECDSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    ${status}=                      Run Keyword and Return Status    Initialize Certificate
    ...                             key_pool_type=ECDSA    hw_type=vCU
    Should not be True              ${status}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=cmpPollingTimeout    param_value=3600    hw_type=vCU
    ...    AND                      Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMPECDSA-1
    ...                             param_name=cmpPollingTimeout    param_value=3600    hw_type=vCU

RSA_and_ECDSA_Operator_certificate_initial_enrollment-vDU
    #RSA Primary
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB007672
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Restore Default Certificates on BTS          hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB010265_First    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB010265_First
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    #Setup for RSA Secondary
    Configure CMP                          ca_subject_name=CN=CB010265_First    ca_server_host=10.42.5.5    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    #RSA Secondary
    Configure Secondary CMP         ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB007672
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Restore Default Certificates on BTS          hw_type=vDU
    Configure Both CMP              primary_ca_subject_name=CN=CB007672    primary_ca_server_host=10.42.5.5
    ...                             secondary_ca_subject_name=CN=CB010265_First    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB010265_First
    ${false_cert}=                  Convert to String      CN=CB007672
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Should not Contain              ${cert_list_string}    ${false_cert}
    #Setup for ECDSA Primary
    Restore Default Certificates on BTS    hw_type=vDU
    #ECDSA Primary
    Configure CMP                   ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB005999_test
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    state=onAir   hw_type=vDU
    Restore Default Certificates on BTS          hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB010265_First_ECDSA    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB010265_First_ECDSA
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    #Setup for ECDSA Secondary
    Configure CMP                          ca_subject_name=CN=CB010265_First_ECDSA    ca_server_host=10.42.5.5
    ...                                    server_type=ECDSA    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    #ECDSA Secondary
    Configure Secondary CMP         ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB005999_test
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Restore Default Certificates on BTS          hw_type=vDU
    Configure Both CMP              primary_ca_subject_name=CN=CB005999_test    server_type=ECDSA
    ...                             primary_ca_server_host=10.42.5.5
    ...                             secondary_ca_subject_name=CN=CB010265_First_ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB010265_First_ECDSA
    ${false_cert}=                  Convert to String      CN=CB005999_test
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Should not Contain              ${cert_list_string}    ${false_cert}
    #Teardown
    [Teardown]    Run Keywords    Restore Default Certificates on BTS    hw_type=vDU
    ...    AND    Delete Secondary CMP    hw_type=vDU
    ...    AND    Delete Secondary CMP    server_type=ECDSA    hw_type=vDU
    ...    AND    Configure CMP           ca_subject_name=CN=CB007672    hw_type=vDU
    ...    AND    Configure CMP           ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vDU

RSA_and_ECDSA_Operator_certificate_initial_enrollment-vCU
    #RSA Primary
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB007672
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    hw_type=vCU
    Sleep    300                                 reason=Wait until reset ends
    Restore Default Certificates on BTS          hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB010265_First    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB010265_First
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    #Setup for RSA Secondary
    Configure CMP                          ca_subject_name=CN=CB010265_First    ca_server_host=10.42.5.5    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    #RSA Secondary
    Configure Secondary CMP         ca_subject_name=CN=CB007672    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB007672
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    hw_type=vCU
    Sleep    300                                 reason=Wait until reset ends
    Restore Default Certificates on BTS          hw_type=vCU
    Configure Both CMP              primary_ca_subject_name=CN=CB007672    primary_ca_server_host=10.42.5.5
    ...                             secondary_ca_subject_name=CN=CB010265_First    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB010265_First
    ${false_cert}=                  Convert to String      CN=CB007672
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Should not Contain              ${cert_list_string}    ${false_cert}
    #Setup for ECDSA Primary
    Restore Default Certificates on BTS    hw_type=vCU
    #ECDSA Primary
    Configure CMP                   ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB005999_test
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    hw_type=vCU
    Sleep    300                                 reason=Wait until reset ends
    Restore Default Certificates on BTS          hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB010265_First_ECDSA    server_type=ECDSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB010265_First_ECDSA
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    #Setup for ECDSA Secondary
    Configure CMP                          ca_subject_name=CN=CB010265_First_ECDSA    ca_server_host=10.42.5.5
    ...                                    server_type=ECDSA    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    #ECDSA Secondary
    Configure Secondary CMP         ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB005999_test
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Perform Reset and Wait for Expected State    hw_type=vCU
    Sleep    300                                 reason=Wait until reset ends
    Restore Default Certificates on BTS          hw_type=vCU
    Configure Both CMP              primary_ca_subject_name=CN=CB005999_test    server_type=ECDSA
    ...                             primary_ca_server_host=10.42.5.5
    ...                             secondary_ca_subject_name=CN=CB010265_First_ECDSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB010265_First_ECDSA
    ${false_cert}=                  Convert to String      CN=CB005999_test
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Should not Contain              ${cert_list_string}    ${false_cert}
    #Teardown
    [Teardown]    Run Keywords    Restore Default Certificates on BTS    hw_type=vCU
    ...    AND    Delete Secondary CMP    hw_type=vCU
    ...    AND    Delete Secondary CMP    server_type=ECDSA    hw_type=vCU
    ...    AND    Configure CMP           ca_subject_name=CN=CB007672    hw_type=vCU
    ...    AND    Configure CMP           ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vCU

Elliptic_curve_primary_and_secondary_RA_CA_support-vDU
    Configure CMP                   ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vDU
    Configure Secondary CMP         ca_subject_name=CN=CB010265_First_ECDSA    server_type=ECDSA    hw_type=vDU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert1}=                       Convert to String      CN=CB005999_test
    ${cert2}=                       Convert to String      CN=CB010265_First_ECDSA
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert1}
    Should not Contain              ${cert_list_string}    ${cert2}
    Restore Default Certificates on BTS    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB010265_First_ECDSA    ca_server_host=10.42.5.5
    ...                             server_type=ECDSA      hw_type=vDU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert2}
    Should not Contain              ${cert_list_string}    ${cert1}
    [Teardown]                      Run Keywords    Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Delete Secondary CMP    server_type=ECDSA    hw_type=vDU

Elliptic_curve_primary_and_secondary_RA_CA_support-vCU
    Configure CMP                   ca_subject_name=CN=CB005999_test    server_type=ECDSA    hw_type=vCU
    Configure Secondary CMP         ca_subject_name=CN=CB010265_First_ECDSA    server_type=ECDSA    hw_type=vCU
    Update CMP Server Settings      key_pool_type=ECDSA    hw_type=vCU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert1}=                       Convert to String      CN=CB005999_test
    ${cert2}=                       Convert to String      CN=CB010265_First_ECDSA
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert1}
    Should not Contain              ${cert_list_string}    ${cert2}
    Restore Default Certificates on BTS    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB010265_First_ECDSA    ca_server_host=10.42.5.5
    ...                             server_type=ECDSA      hw_type=vCU
    Initialize Certificate          key_pool_type=ECDSA    hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert2}
    Should not Contain              ${cert_list_string}    ${cert1}
    [Teardown]                      Run Keywords    Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Delete Secondary CMP    server_type=ECDSA    hw_type=vCU

CRL_Operations_vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=usageEnabled
    ...                             param_value=Enabled    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672          hw_type=vDU
    Configure Secondary CMP         ca_subject_name=CN=CB010265_First    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=secondaryCRLDP
    ...                             param_value=${secondary_param_value}    hw_type=vDU
    ${pValues}=    Create List      pValue2     pValue3     pValue4     pValue5     pValue6     pValue7    pValue8
    ...                             pValue9     pValue10    pValue11    pValue12    pValue13    pValue14
    ...                             pValue15    pValue16    pValue17    pValue18    pValue19    pValue20
    ${sValues}=    Create List      sValue2     sValue3     sValue4     sValue5     sValue6     sValue7    sValue8
    ...                             sValue9     sValue10    sValue11    sValue12    sValue13    sValue14
    ...                             sValue15    sValue16    sValue17    sValue18    sValue19    sValue20
    Create Mutliple CRLDP Objects with PrimaryCRLDP and SecondaryCRLDP    start=2    stop=21
    ...                             primary_values=${pValues}    secondary_values=${sValues}    hw_type=vDU
    Wait Until Keyword Succeeds     15min    10s        Search for certificate in revocation list on vDU
    ...                                                 cert=Primary_manual
    Wait Until Keyword Succeeds     15min    10s        Search for certificate in revocation list on vDU
    ...                                                 cert=Secondary_manual
    Alarm Should be Active                              alarm=${crl_update_alarm}    hw_type=vDU
    Perform Reset and Wait for Expected State           state=onAir   hw_type=vDU
    Restore Default Certificates on BTS                 hw_type=vDU
    Initialize Certificate           hw_type=vDU
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=distributionPointSource
    ...                              param_value=Certificate_extension    hw_type=vDU
    Wait Until Keyword Succeeds      15min    10s    Alarm Should not be Active
    ...                              alarm=${crl_update_alarm}    hw_type=vDU
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=distributionPointSource
    ...                              param_value=Configuration_parameter    hw_type=vDU
    Wait Until Keyword Succeeds      15min    10s    Alarm Should be Active
    ...                              alarm=${crl_update_alarm}    hw_type=vDU
    Wait Until Keyword Succeeds      3x    10s    Delete Object on BTS
    ...                              dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20
    ...                              hw_type=vDU
    Wait Until Keyword Succeeds      15min    10s    Check if cert is not present in revocation list on vDU    Value20
    Check if cert is not present in revocation list on vDU    sValue20
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=usageEnabled
    ...                              param_value=Disabled    hw_type=vDU
    Wait Until Keyword Succeeds      15min    10s    CRL should be empty on vDU
    Delete Mutliple CRLDP Objects    start=2    stop=20    hw_type=vDU
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=usageEnabled
    ...                              param_value=Enabled    hw_type=vDU
    Wait Until Keyword Succeeds      15min    10s    Alarm Should not be Active
    ...                              alarm=${crl_update_alarm}    hw_type=vDU
    [Teardown]    Run Keywords       Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                       Change Parameter on BTS
    ...                              dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=distributionPointSource
    ...                              param_value=Certificate_extension    hw_type=vDU
    ...    AND                       Run Keyword and Ignore Error    Delete Parameter on BTS
    ...                              dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                              param_name=secondaryCRLDP    hw_type=vDU

CRL_Operations_vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=usageEnabled
    ...                             param_value=Enabled    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672          hw_type=vCU
    Configure Secondary CMP         ca_subject_name=CN=CB010265_First    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=secondaryCRLDP
    ...                             param_value=${secondary_param_value}    hw_type=vCU
    ${pValues}=    Create List      pValue2     pValue3     pValue4     pValue5     pValue6     pValue7    pValue8
    ...                             pValue9     pValue10    pValue11    pValue12    pValue13    pValue14
    ...                             pValue15    pValue16    pValue17    pValue18    pValue19    pValue20
    ${sValues}=    Create List      sValue2     sValue3     sValue4     sValue5     sValue6     sValue7    sValue8
    ...                             sValue9     sValue10    sValue11    sValue12    sValue13    sValue14
    ...                             sValue15    sValue16    sValue17    sValue18    sValue19    sValue20
    Create Mutliple CRLDP Objects with PrimaryCRLDP and SecondaryCRLDP    start=2    stop=21
    ...                             primary_values=${pValues}    secondary_values=${sValues}    hw_type=vCU
    Wait Until Keyword Succeeds     15min    10s        Search for certificate in revocation list on vCU
    ...                                                 cert=Primary_manual
    Wait Until Keyword Succeeds     15min    10s        Search for certificate in revocation list on vCU
    ...                                                 cert=Secondary_manual
    Alarm Should be Active                              alarm=${crl_update_alarm}    hw_type=vCU
    Perform Reset and Wait for Expected State           hw_type=vCU
    Restore Default Certificates on BTS                 hw_type=vCU
    Initialize Certificate           hw_type=vCU
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=distributionPointSource
    ...                              param_value=Certificate_extension    hw_type=vCU
    Wait Until Keyword Succeeds      15min    10s    Alarm Should not be Active
    ...                              alarm=${crl_update_alarm}    hw_type=vCU
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=distributionPointSource
    ...                              param_value=Configuration_parameter    hw_type=vCU
    Wait Until Keyword Succeeds      15min    10s    Alarm Should be Active
    ...                              alarm=${crl_update_alarm}    hw_type=vCU
    Wait Until Keyword Succeeds      3x    10s    Delete Object on BTS
    ...                              dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-20
    ...                              hw_type=vCU
    Wait Until Keyword Succeeds      15min    10s    Check if cert is not present in revocation list on vCU    Value20
    Check if cert is not present in revocation list on vCU    sValue20
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=usageEnabled
    ...                              param_value=Disabled    hw_type=vCU
    Wait Until Keyword Succeeds      15min    10s    CRL should be empty on vCU
    Delete Mutliple CRLDP Objects    start=2    stop=20    hw_type=vCU
    Change Parameter on BTS          dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=usageEnabled
    ...                              param_value=Enabled    hw_type=vCU
    Wait Until Keyword Succeeds      15min    10s    Alarm Should not be Active
    ...                              alarm=${crl_update_alarm}    hw_type=vCU
    [Teardown]    Run Keywords       Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                       Change Parameter on BTS
    ...                              dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                              param_name=distributionPointSource
    ...                              param_value=Certificate_extension    hw_type=vCU
    ...    AND                       Run Keyword and Ignore Error    Delete Parameter on BTS
    ...                              dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                              param_name=secondaryCRLDP    hw_type=vCU

Check_updateFailureReason_parameter_vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${crldp_wrong_format}    hw_type=vDU
    Wait Until Keyword Succeeds     15min    10s    Search for certificate in revocation list on vDU
    ...                                             Uri Format Error
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${crldp_weak_hash}    hw_type=vDU
    Wait Until Keyword Succeeds     15min    10s    Search for certificate in revocation list on vDU
    ...                                             Weak Hash Algorithm Used In CRL Signature
    [Teardown]    Run Keywords      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${primary_param_value}    hw_type=vDU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vDU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vDU

Check_updateFailureReason_parameter_vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${crldp_wrong_format}    hw_type=vCU
    Wait Until Keyword Succeeds     15min    10s    Search for certificate in revocation list on vCU
    ...                                             Uri Format Error
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${crldp_weak_hash}    hw_type=vCU
    Wait Until Keyword Succeeds     15min    10s    Search for certificate in revocation list on vCU
    ...                                             Weak Hash Algorithm Used In CRL Signature
    [Teardown]    Run Keywords      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${primary_param_value}    hw_type=vCU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vCU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vCU

CRL_download_from_primaryCRLDP_is_not_successful_but_from_secondaryCRLDP_is_successful_vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=crlDownloadProtocol
    ...                             param_value=LDAP_OR_HTTP    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${http_crldp_fake}    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=secondaryCRLDP
    ...                             param_value=${http_crldp}    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
#    Start TCPdump                   capture_type=pod    pod_names=ute-cran1-oamext-0    hw_type=vDU
#    Sleep    3s                     reason=TCPdump
    ${conn}=                        Connect to ADMIN    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was correct    hw_type=vDU
#    Sleep    3s                     reason=TCPdump
#    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran1-oamext-0    hw_type=vDU
    Run Keyword and Expect Error    *    Search for certificate in revocation list on vDU    cert=Primary_manual
    Search for certificate in revocation list on vDU    cert=Secondary_manual
#    PCAP Should Contain Message     tshark_filter=ip.addr == 8.8.8.8   pcap_file=${pcap_path}
#    PCAP Should Contain Message     tshark_filter=ip.addr == 10.42.54.13 && http  pcap_file=${pcap_path}
    [Teardown]    Run Keywords      Disconnect from ADMIN    connection=${conn}    hw_type=vDU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vDU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vDU
    ...    AND                      Delete Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=secondaryCRLDP    hw_type=vDU
#    ...    AND                      TCPdump Teardown    hw_type=vDU

CRL_download_is_not_successful_neither_from_primaryCRLDP_nor_from_secondaryCRLDP_vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=crlDownloadProtocol
    ...                             param_value=LDAP_OR_HTTP    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${ftp_crldp}    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=secondaryCRLDP
    ...                             param_value=${ftp_crldp_google}    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Wait Until Keyword Succeeds     15min    10s    Check if last CRL Update was incorrect    hw_type=vCU
    Wait Until Keyword Succeeds     5min     10s    Alarm Should be Active
    ...                             alarm=${crl_update_alarm}    hw_type=vCU
    [Teardown]    Run Keywords      Run Keyword and Ignore Error
    ...                             Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vCU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vCU
    ...    AND                      Delete Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=secondaryCRLDP    hw_type=vCU

Protocol_for_CRL_download_is_LDAP_OR_HTTP_vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=crlDownloadProtocol
    ...                             param_value=LDAP_OR_HTTP    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${conn}=                        Connect to ADMIN    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672_blank    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672_HTTP    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672_FTP    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was incorrect    hw_type=vDU
    Alarm Should not be Active      alarm=${crl_update_alarm}    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${ldap_crldp}    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${http_crldp}    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vDU
    Restore Default Certificates on BTS    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${ftp_crldp}    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    vdu_admin.update_CRL_info       vdu_connection=${conn}
    Wait Until Keyword Succeeds     5min     10s    Check if last CRL Update was incorrect    hw_type=vDU
    Wait Until Keyword Succeeds     15min    10s    Alarm Should be Active
    ...                             alarm=${crl_update_alarm}    hw_type=vDU
    [Teardown]    Run Keywords      Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                             connection=${conn}    hw_type=vDU
    ...    AND                      Configure CMP    ca_subject_name=CN=CB007672    hw_type=vDU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vDU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vDU

Protocol_for_CRL_download_is_LDAP_OR_HTTP_vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=crlDownloadProtocol
    ...                             param_value=LDAP_OR_HTTP    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672_blank    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672_HTTP    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672_FTP    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Disconnect from ADMIN           connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was incorrect    hw_type=vCU
    Alarm Should not be Active      alarm=${crl_update_alarm}    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Configuration_parameter    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${ldap_crldp}    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${http_crldp}    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Check if last CRL Update was correct    hw_type=vCU
    Restore Default Certificates on BTS    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${ftp_crldp}    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${conn}=                        Connect to ADMIN    hw_type=vCU
    vcu_admin.trigger_crl_information_update    timeout=300    connection=${conn}
    Wait Until Keyword Succeeds     5min     10s    Check if last CRL Update was incorrect    hw_type=vCU
    Wait Until Keyword Succeeds     15min    10s    Alarm Should be Active
    ...                             alarm=${crl_update_alarm}    hw_type=vCU
    [Teardown]    Run Keywords      Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                             connection=${conn}    hw_type=vCU
    ...    AND                      Configure CMP    ca_subject_name=CN=CB007672    hw_type=vCU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                             param_name=distributionPointSource
    ...                             param_value=Certificate_extension    hw_type=vCU
    ...    AND                      Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP
    ...                             param_value=${primary_param_value}    hw_type=vCU

Automatically_trigger_CRL_download_from_WebEM_to_Cloud_BTS_vCU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                            param_name=distributionPointSource
    ...                            param_value=Configuration_parameter    hw_type=vCU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                            param_name=crlDownloadProtocol
    ...                            param_value=LDAP_OR_HTTP    hw_type=vCU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                            param_name=primaryCRLDP
    ...                            param_value=${primary_param_value}    hw_type=vCU
    Configure CMP                  ca_subject_name=CN=CB007672    hw_type=vCU
    Update CMP Server Settings     hw_type=vCU
    Initialize Certificate         hw_type=vCU
    Wait Until Keyword Succeeds    15min    10s    Search for certificate in revocation list on vCU
    ...                                            cert=CB007672
    Wait Until Keyword Succeeds    5min     10s    Check if last CRL Update was correct    hw_type=vCU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                            param_name=primaryCRLDP
    ...                            param_value=${secondary_param_value}    hw_type=vCU
    Initialize Certificate         hw_type=vCU
    Wait Until Keyword Succeeds    15min    10s    Check if last CRL Update was incorrect    hw_type=vCU
    Wait Until Keyword Succeeds    5min     10s    Alarm Should be Active    alarm=7220    hw_type=vCU
    [Teardown]    Run Keywords     Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                            param_name=distributionPointSource
    ...                            param_value=Certificate_extension    hw_type=vCU
    ...    AND                     Change Parameter on BTS
    ...                            dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                            param_name=primaryCRLDP    param_value=${primary_param_value}    hw_type=vCU
    ...    AND                     Restore Default Certificates on BTS    hw_type=vCU

Unsuccessfully_manually_trigger_CRL_download_from_WebEM_to_Cloud_BTS_vDU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                            param_name=distributionPointSource
    ...                            param_value=Configuration_parameter    hw_type=vDU
    Configure CMP                  ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings     hw_type=vDU
    Initialize Certificate         hw_type=vDU
    Change Parameter on BTS        dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                            param_name=primaryCRLDP
    ...                            param_value=${secondary_param_value}    hw_type=vDU
    ${conn}=                       Connect to ADMIN    hw_type=vDU
    vdu_admin.update_CRL_info      vdu_connection=${conn}
    Wait Until Keyword Succeeds    5min     5s     Check if CRL Update is ongoing    hw_type=vDU
    Wait Until Keyword Succeeds    15min    10s    Check if last CRL Update was incorrect    hw_type=vDU
    Wait Until Keyword Succeeds    5min     10s    Alarm Should be Active    alarm=7220    hw_type=vDU
    [Teardown]    Run Keywords     Disconnect from ADMIN    connection=${conn}    hw_type=vDU
    ...    AND                     Change Parameter on BTS
    ...                            dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                            param_name=primaryCRLDP    param_value=${primary_param_value}    hw_type=vDU
    ...    AND                     Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1
    ...                            param_name=distributionPointSource
    ...                            param_value=Certificate_extension    hw_type=vDU
    ...    AND                     Restore Default Certificates on BTS    hw_type=vDU

CMP_init_and kur_re-attempts-vCU
    Update CMP Server Settings      hw_type=vCU
    Configure Both CMP              primary_ca_subject_name=CN=9857_4k    secondary_ca_subject_name=CN=CB007672
    ...                             primary_ca_server_host=10.42.158.226    primary_ca_server_port=4444    hw_type=vCU
    Start TCPdump                   capture_type=pod    pod_names=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Sleep    3s                     reason=TCPdump
    Run Keyword and Ignore Error    Initialize Certificate    hw_type=vCU
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Run                             tshark -r ${pcap_path} -T pdml > ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=                 OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    ${fail1}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemUnavail: True
    ${fail2}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemFailure: True
#    Should not be True              ${fail1}==${fail2}
    Start TCPdump                   capture_type=pod    pod_names=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Sleep    3s                     reason=TCPdump
    Run Keyword and Ignore Error    Update CMP Key    hw_type=vCU
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Run                             tshark -r ${pcap_path} -T pdml > ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=                 OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    ${fail1}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemUnavail: True
    ${fail2}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemFailure: True
#    Should not be True              ${fail1}==${fail2}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      TCPdump Teardown    hw_type=vCU
    ...    AND                      Delete Secondary CMP    hw_type=vCU
    ...    AND                      Configure CMP    ca_subject_name=CN=CB007672    hw_type=vCU
    ...    AND                      Run    rm ${CURDIR}/pcap_to_check.txt

CMP_init_and kur_re-attempts-vDU
    Update CMP Server Settings      hw_type=vDU
    Configure Both CMP              primary_ca_subject_name=CN=9857_4k    secondary_ca_subject_name=CN=CB007672
    ...                             primary_ca_server_host=10.42.158.226    primary_ca_server_port=4444    hw_type=vDU
    Start TCPdump                   capture_type=pod    pod_names=ute-cran1-oamext-0    hw_type=vDU
    Sleep    3s                     reason=TCPdump
    Run Keyword and Ignore Error    Initialize Certificate    hw_type=vDU
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran1-oamext-0    hw_type=vDU
    Run                             tshark -r ${pcap_path} -T pdml > ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=                 OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    ${fail1}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemUnavail: True
    ${fail2}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemFailure: True
#    Should not be True              ${fail1}==${fail2}
    Start TCPdump                   capture_type=pod    pod_names=ute-cran1-oamext-0    hw_type=vDU
    Sleep    3s                     reason=TCPdump
    Run Keyword and Ignore Error    Update CMP Key    hw_type=vDU
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran1-oamext-0    hw_type=vDU
    Run                             tshark -r ${pcap_path} -T pdml > ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=                 OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    ${fail1}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemUnavail: True
    ${fail2}=                       Run Keyword and Return Status    Should Contain
    ...                             ${inside_pcap}    systemFailure: True
#    Should not be True              ${fail1}==${fail2}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      TCPdump Teardown    hw_type=vDU
    ...    AND                      Delete Secondary CMP    hw_type=vDU
    ...    AND                      Configure CMP    ca_subject_name=CN=CB007672    hw_type=vDU
    ...    AND                      Run    rm ${CURDIR}/pcap_to_check.txt

Generation_of_alternative_name-vCU
    ${cert}=                        Convert to String    CN=CB007672
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Change Parameters on BTS Using XML File    xml=${CURDIR}/../Resources/Delta_files/Alt1_vCU.xml    hw_type=vCU
    Start TCPdump                   capture_type=pod    pod_names=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Sleep    3s                     reason=TCPdump
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates    hw_type=vCU
    ${cert_list_string}=            Convert to String    ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Convert pcap to XML             ${pcap_path}    http    ${CURDIR}/str1.txt
    ${inside_pcap}=                 OperatingSystem.Get File    ${CURDIR}/str1.txt
    Should Contain Any              ${inside_pcap}    IP Address:1.1.1.1    iPAddress: 1.1.1.1
    Change Parameters on BTS Using XML File    xml=${CURDIR}/../Resources/Delta_files/Alt4_vCU.xml    hw_type=vCU
    Run Keyword and Expect Error    *    Change Parameters on BTS Using XML File
    ...                             xml=${CURDIR}/../Resources/Delta_files/Alt5_vCU.xml    hw_type=vCU
    [Teardown]    Run Keywords      Remove all eeSubjectAltNames structures from vCU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      TCPdump Teardown    hw_type=vCU
    ...    AND                      Run    rm ${CURDIR}/str1.txt
    ...    AND                      Run    rm ${pcap_path}
    ...    AND                      Run    rm ${CURDIR}/scf_vcu.xml

Generation_of_alternative_name-vDU
    ${cert}=                        Convert to String    CN=CB007672
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Change Parameters on BTS Using XML File    xml=${CURDIR}/../Resources/Delta_files/Alt1_vDU.xml    hw_type=vDU
    Start TCPdump                   capture_type=pod    pod_names=ute-cran1-oamext-0    hw_type=vDU
    Sleep    3s                     reason=TCPdump
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates    hw_type=vDU
    ${cert_list_string}=            Convert to String    ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran1-oamext-0    hw_type=vDU
    Convert pcap to XML             ${pcap_path}    http    ${CURDIR}/str1.txt
    ${inside_pcap}=                 OperatingSystem.Get File    ${CURDIR}/str1.txt
    Should Contain Any              ${inside_pcap}    IP Address:1.1.1.1    iPAddress: 1.1.1.1
    Change Parameters on BTS Using XML File    xml=${CURDIR}/../Resources/Delta_files/Alt4_vDU.xml    hw_type=vDU
    Run Keyword and Expect Error    *    Change Parameters on BTS Using XML File
    ...                             xml=${CURDIR}/../Resources/Delta_files/Alt5_vDU.xml    hw_type=vDU
    [Teardown]    Run Keywords      Remove all eeSubjectAltNames structures from vDU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      TCPdump Teardown    hw_type=vDU
    ...    AND                      Run    rm ${CURDIR}/str1.txt
    ...    AND                      Run    rm ${pcap_path}
    ...    AND                      Run    rm ${CURDIR}/scf_vdu.xml

Old_rootCA_removal_and_retention-vCU
    Log       Step 1, 2, 3: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS_CU}/MNL-1/CERTH-1              MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    autoCertDelete    keyLength
    ${pv}=    Create List    true    true    true    4096
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CN=CB009857_4k_384
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Log       Step 4: Initialize new certificate and check if old one was deleted   console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${new_cert}=                    Convert to String      CN=CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should not Contain              ${cert_list_string}    ${cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 5, 6: Try to initialize certificate with SHA1 signature and expect error   console=True
    Configure CMP                   ca_subject_name=CN=SHA1_cloud    hw_type=vCU
    Wait Until Keyword Succeeds     3x    5s    Try to Initialize Certificate and Expect Error
    ...                                         expected_error=${cert_fail_sha1}    hw_type=vCU
    Log       Step 5, 6: Try to initialize certificate with key less then 2k and expect error   console=True
    Configure CMP                   ca_subject_name=CN=9857_less_2k    hw_type=vCU
    Wait Until Keyword Succeeds     3x    5s    Try to Initialize Certificate and Expect Error
    ...                                         expected_error=${cert_fail_sha_2k}    hw_type=vCU
    Log       Step 7: Turn off autoCertDelete   console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=false    hw_type=vCU
    Log       Step 8: Initialize new certificate and check if old one was retained    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 9: Turn on autoCertDelete   console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=true    hw_type=vCU
    Log       Step 10: Initialize new certificate and check if old one was retained    console=True
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert_list_string}=            Convert to String      ${cert_list}
    ${last_cert}=                   Convert to String      CN=CB007672
    Should Contain                  ${cert_list_string}    ${new_cert}
    Should Contain                  ${cert_list_string}    ${last_cert}
    Should not Contain              ${cert_list_string}    ${cert}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Delete All Certificates    hw_type=vCU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=keyLength    param_value=2048    hw_type=vCU

Old_rootCA_removal_and_retention-vDU
    Log       Step 1, 2, 3: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS}/MNL-1/CERTH-1              MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    autoCertDelete    keyLength
    ${pv}=    Create List    true    true    true    4096
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CN=CB009857_4k_384
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Log       Step 4: Initialize new certificate and check if old one was deleted   console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${new_cert}=                    Convert to String      CN=CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should not Contain              ${cert_list_string}    ${cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 5, 6: Try to initialize certificate with SHA1 signature and expect error   console=True
    Configure CMP                   ca_subject_name=CN=SHA1_cloud    hw_type=vDU
    Try to Initialize Certificate and Expect Error    expected_error=${cert_fail_sha1}    hw_type=vDU
    Log       Step 5, 6: Try to initialize certificate with key less then 2k and expect error   console=True
    Configure CMP                   ca_subject_name=CN=9857_less_2k    hw_type=vDU
    Try to Initialize Certificate and Expect Error    expected_error=${cert_fail_sha_2k}    hw_type=vDU
    Log       Step 7: Turn off autoCertDelete   console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=false    hw_type=vDU
    Log       Step 8: Initialize new certificate and check if old one was retained    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 9: Turn on autoCertDelete   console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=true    hw_type=vDU
    Log       Step 10: Initialize new certificate and check if old one was retained    console=True
    Configure CMP                   ca_subject_name=CN=CB007672    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert_list_string}=            Convert to String      ${cert_list}
    ${last_cert}=                   Convert to String      CN=CB007672
    Should Contain                  ${cert_list_string}    ${new_cert}
    Should Contain                  ${cert_list_string}    ${last_cert}
    Should not Contain              ${cert_list_string}    ${cert}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Delete All Certificates    hw_type=vDU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete    param_value=false    hw_type=vDU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=keyLength    param_value=2048    hw_type=vDU

Operator_4K_Certificate_initial_enrollment_CMP_init_and_KUR_failure-vCU
    Log       Step 1, 2: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048
    ${pv}=    Create List    true    true
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Log       Step 3, 4, 5, 6: Try to initialize certificate with key less then 2k and check error    console=True
    Configure CMP                   ca_subject_name=CN=9857_less_2k    hw_type=vCU
    Wait Until Keyword Succeeds     3x    5s    Try to Initialize Certificate and Expect Error
    ...                                         expected_error=${cert_fail_sha_2k}    hw_type=vCU
    Log       Step 7, 8, 9: Try to update CMP key with key less then 2k and check error    console=True
    Wait Until Keyword Succeeds     3x    5s    Try to Update CMP Key and Expect Error
    ...                                         expected_error=${cert_fail_sha_2k}    hw_type=vCU
    Log       Step 3, 4, 5, 6: Try to initialize certificate with SHA1 signature and check error    console=True
    Configure CMP                   ca_subject_name=CN=SHA1_cloud    hw_type=vCU
    Wait Until Keyword Succeeds     3x    5s    Try to Initialize Certificate and Expect Error
    ...                                         expected_error=${cert_fail_sha1}    hw_type=vCU
    Log       Step 7, 8, 9: Try to update CMP key with SHA1 signature and check error    console=True
    Wait Until Keyword Succeeds     3x    5s    Try to Update CMP Key and Expect Error
    ...                                         expected_error=${cert_fail_sha1}    hw_type=vCU
    [Teardown]    Restore Default Certificates on BTS    hw_type=vCU

Operator_4K_Certificate_initial_enrollment_CMP_init_and_KUR_failure-vDU
    Log       Step 1, 2: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048
    ${pv}=    Create List    true    true
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Log       Step 3, 4, 5, 6: Try to initialize certificate with key less then 2k and check error    console=True
    Configure CMP                   ca_subject_name=CN=9857_less_2k    hw_type=vDU
    Try to Initialize Certificate and Expect Error    expected_error=${cert_fail_sha_2k}    hw_type=vDU
    Log       Step 7, 8, 9: Try to update CMP key with key less then 2k and check error    console=True
    Try to Update CMP Key and Expect Error    expected_error=${cert_fail_sha_2k}    hw_type=vDU
    Log       Step 3, 4, 5, 6: Try to initialize certificate with SHA1 signature and check error    console=True
    Configure CMP                   ca_subject_name=CN=SHA1_cloud    hw_type=vDU
    Try to Initialize Certificate and Expect Error    expected_error=${cert_fail_sha1}    hw_type=vDU
    Log       Step 7, 8, 9: Try to update CMP key with SHA1 signature and check error    console=True
    Try to Update CMP Key and Expect Error    expected_error=${cert_fail_sha1}    hw_type=vDU
    [Teardown]    Restore Default Certificates on BTS    hw_type=vDU

Network_Element_Certificate_Profile_and_key_size-vCU
    Log       Step 1, 2, 5: Adjust parameters    console=True
    ${dn}=    Create List    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    keyLength
    ${pv}=    Create List    true    true    4096
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Log       Step 3: Configure CMP with SHA256 certificate    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Log       Step 4: Create first subjectAltName   console=True
    Change Parameters on BTS Using XML File    xml=${CURDIR}/../Resources/Delta_files/Alt1_vCU.xml    hw_type=vCU
    Log       Step 6, 7: Initialize SHA256 certificate and check if it ends with success   console=True
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert_256}=                    Convert to String      CN=CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert_256}
    Log       Step 8: Configure CMP with SHA384 certificate    console=True
    Configure CMP                   ca_subject_name=CN=Cloud_SHA384    hw_type=vCU
    Log       Step 9, 10: Initialize SHA384 certificate and check if it ends with success   console=True
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert_384}=                    Convert to String      CN=Cloud_SHA384
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert_384}
    [Teardown]    Run Keywords      Remove all eeSubjectAltNames structures from vCU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Delete All Certificates    hw_type=vCU

Network_Element_Certificate_Profile_and_key_size-vDU
    Log       Step 1, 2, 5: Adjust parameters    console=True
    ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    keyLength
    ${pv}=    Create List    true    true    4096
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
    Log       Step 3: Configure CMP with SHA256 certificate    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Log       Step 4: Create first subjectAltName   console=True
    Change Parameters on BTS Using XML File    xml=${CURDIR}/../Resources/Delta_files/Alt1_vDU.xml    hw_type=vDU
    Log       Step 6, 7: Initialize SHA256 certificate and check if it ends with success   console=True
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert_256}=                    Convert to String      CN=CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert_256}
    Log       Step 8: Configure CMP with SHA384 certificate    console=True
    Configure CMP                   ca_subject_name=CN=Cloud_SHA384    hw_type=vDU
    Log       Step 9, 10: Initialize SHA384 certificate and check if it ends with success   console=True
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert_384}=                    Convert to String      CN=Cloud_SHA384
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert_384}
    [Teardown]    Run Keywords      Remove all eeSubjectAltNames structures from vDU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Delete All Certificates    hw_type=vDU

Cert_Storage-vCU
    Log       Step 1, 2, 3: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS_CU}/MNL-1/CERTH-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    autoCertDelete
    ${pv}=    Create List    true    true    true
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Log       Step 4: Initialize new certificate    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Log       Step 5: Check if old Root CA was deleted    console=True
    ${old_cert}=                    Convert to String      CN=CB009857_4k_384
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${new_cert}=                    Convert to String      CN=CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should not Contain              ${cert_list_string}    ${old_cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 6: Disable autoCertDelete parameter     console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=false    hw_type=vCU
    Log       Step 7: Initialize new certificate and check if old Root CA wasn't deleted    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${old_cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 8: Try to initialize certificate with key less then 2k     console=True
    Configure CMP                   ca_subject_name=CN=9857_less_2k    hw_type=vCU
    Wait Until Keyword Succeeds     3x    5s    Try to Initialize Certificate and Expect Error
    ...                                         expected_error=${cert_fail_sha_2k}    hw_type=vCU
    Log       Step 9: Try to initialize certificate with SHA1 signature     console=True
    Configure CMP                   ca_subject_name=CN=SHA1_cloud    hw_type=vCU
    Wait Until Keyword Succeeds     3x    5s    Try to Initialize Certificate and Expect Error
    ...                                         expected_error=${cert_fail_sha1}    hw_type=vCU
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Delete All Certificates    hw_type=vCU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete    param_value=false    hw_type=vCU

Cert_Storage-vDU
    Log       Step 1, 2, 3: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS}/MNL-1/CERTH-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    autoCertDelete
    ${pv}=    Create List    true    true    true
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Log       Step 4: Initialize new certificate    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Log       Step 5:. Check if old Root CA was deleted    console=True
    ${old_cert}=                    Convert to String      CN=CB009857_4k_384
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${new_cert}=                    Convert to String      CN=CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should not Contain              ${cert_list_string}    ${old_cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 6: Disable autoCertDelete parameter     console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete
    ...                             param_value=false    hw_type=vDU
    Log       Step 7: Initialize new certificate and check if old Root CA wasn't deleted    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${old_cert}
    Should Contain                  ${cert_list_string}    ${new_cert}
    Log       Step 8: Try to initialize certificate with key less then 2k     console=True
    Configure CMP                   ca_subject_name=CN=9857_less_2k    hw_type=vDU
    Try to Initialize Certificate and Expect Error    expected_error=${cert_fail_sha_2k}    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=SHA1_cloud    hw_type=vDU
    Log       Step 9: Try to initialize certificate with SHA1 signature     console=True
    Try to Initialize Certificate and Expect Error    expected_error=${cert_fail_sha1}    hw_type=vDU
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Delete All Certificates    hw_type=vDU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1
    ...                             param_name=autoCertDelete    param_value=false    hw_type=vDU

Manual_install_additional_CA_Certificate_with_4K_key-vCU
    Log       Step 1, 2, 5: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List   MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ${pn}=    Create List   blockSha1CertChain    blockRsaKeyLengthBelow2048
    ${pv}=    Create List   true    true
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Log       Step 3: Try to install certificate with key less then 2k    console=True
    Log       Step 4: Verify displayed error message    console=True
    Try to Install Certificate and Look For Given Fail on vCU
    ...                             cert_path=${CURDIR}/../Resources/Certs/9857_less_2k.pem
    ...                             cert_type=CA    fail_reason=${cert_fail_sha_2k}
    Log       Step 6: Try to install certificate with SHA1 signature    console=True
    Log       Step 7: Verify displayed error message    console=True
    Try to Install Certificate and Look For Given Fail on vCU
    ...                             cert_path=${CURDIR}/../Resources/Certs/SHA1_cloud.pem
    ...                             cert_type=CA    fail_reason=${cert_fail_sha1}
    Log       Step 8, 9: Install proper certificate    console=True
    Install Certificate             cert_path=${CURDIR}/../Resources/Certs/9857_4k_256.pem
    ...                             cert_type=CA    hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      9857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Delete All Certificates    hw_type=vCU

Manual_install_additional_CA_Certificate_with_4K_key-vDU
    Log       Step 1, 2, 5: Adjust parameters and install first certificate    console=True
    ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048
    ${pv}=    Create List    true    true
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
    Configure CMP                   ca_subject_name=CN=CB009857_4k_384    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    Log       Step 3: Try to install certificate with key less then 2k    console=True
    Log       Step 4: Verify displayed error message    console=True
    Try to Install Certificate and Look For Given Fail on vDU
    ...                             cert_path=${CURDIR}/../Resources/Certs/9857_less_2k.pem
    ...                             cert_type=CA    fail_reason=${cert_fail_sha_2k}
    Log       Step 6: Try to install certificate with SHA1 signature    console=True
    Log       Step 7: Verify displayed error message    console=True
    Try to Install Certificate and Look For Given Fail on vDU
    ...                             cert_path=${CURDIR}/../Resources/Certs/SHA1_cloud.pem
    ...                             cert_type=CA    fail_reason=${cert_fail_sha1}
    Log       Step 8, 9: Install proper certificate    console=True
    Install Certificate             cert_path=${CURDIR}/../Resources/Certs/9857_4k_256.pem
    ...                             cert_type=CA    hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      9857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    [Teardown]    Run Keywords      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Delete All Certificates    hw_type=vDU

Operator_4K_Certificate_initial_enrollment_CMP_init_and_KUR-vCU
    Log       Step 1, 2, 3: Adjust parameters    console=True
    ${dn}=    Create List    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    keyLength
    ${pv}=    Create List    true    true    4096
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Log       Step 4, 5, 6, 7, 8: Initialize certificate and check if it ends with success    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${cert_list}=                   Check Certificates     hw_type=vCU
    ${cert}=                        Convert to String      CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Log       Step 9, 10, 11, 12: Send CMP key update request and check if it ends with success    console=True
    Update CMP Key                  hw_type=vCU
    [Teardown]    Restore Default Certificates on BTS    hw_type=vCU

Operator_4K_Certificate_initial_enrollment_CMP_init_and_KUR-vDU
    Log       Step 1, 2, 3: Adjust parameters    console=True
    ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    keyLength
    ${pv}=    Create List    true    true    4096
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
    Log       Step 4, 5, 6, 7, 8: Initialize certificate and check if it ends with success    console=True
    Configure CMP                   ca_subject_name=CN=CB009857_4k_256    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${cert_list}=                   Check Certificates     hw_type=vDU
    ${cert}=                        Convert to String      CB009857_4k_256
    ${cert_list_string}=            Convert to String      ${cert_list}
    Should Contain                  ${cert_list_string}    ${cert}
    Log       Step 9, 10, 11, 12: Send CMP key update request and check if it ends with success    console=True
    Update CMP Key                  hw_type=vDU
    [Teardown]    Restore Default Certificates on BTS    hw_type=vDU

Trigger_CMP_init_and kur_sequence_from_NMS-vCU
    Log       Step 2: Adjust parameters    console=True
    Configure CMP                   ca_subject_name=C=PL, O=Common, CN=IPSEC    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    ${dn}=    Create List    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    oamTls
    ${pv}=    Create List    true    true    off
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Log       Step 1: Connect to EMSsim    console=True
    Setup environment for EMSSIM    enable_tls=0    hw_type=vCU
    ${emssim_connection}=           Connect and Activate EMSSIM    enable_tls=0    cert_type=RSA    hw_type=vCU
    Start TCPdump                   capture_type=pod    pod_names=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Sleep    3s                     reason=TCPdump
    Wait until keyword succeeds     3x    3min    execute_command_on_emssim
    ...                             command=edit CMP-1-1-1 caSubjectName CN=CB009857_4k_384
    ...                             connection=${emssim_connection}
    ${value}=                       Check Parameter Value    param_name=caSubjectName
    ...                                                      dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ...                                                      hw_type=vCU
    ${value_string}=                Convert to String        ${value}
    ${cert_string}=                 Convert to String        CN=CB009857_4k_384
    Should Contain                  ${value_string}          ${cert_string}
    Log       Step 3, 4: Initialize certificate    console=True
    Wait until keyword succeeds     3x    3min    execute_command_on_emssim
    ...                             command=cert_cmp_init
    ...                             connection=${emssim_connection}
    Log       Step 5: Check if certificate was installed    console=True
    Wait Until Keyword Succeeds     5min    15s    Check if Certificate is present on vCU    CN=CB009857_4k_384
    Log       Step 6, 7: Update CMP key    console=True
    Wait until keyword succeeds     3x    3min    execute_command_on_emssim
    ...                             command=cert_cmp_key_update
    ...                             connection=${emssim_connection}
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran${MRBTS}-oamext-0    hw_type=vCU
    Log       Step 8, 9: Check communication with NE3S    console=True
    Convert pcap to XML             ${pcap_path}    http && ip.src==${LMP_VCU_IP}    ${CURDIR}/ne3s_1_vcu.txt
    Convert pcap to XML             ${pcap_path}    http && ip.dst==${LMP_VCU_IP}    ${CURDIR}/ne3s_2_vcu.txt
    ${inside_pcap1}=                OperatingSystem.Get File    ${CURDIR}/ne3s_1_vcu.txt
    ${inside_pcap2}=                OperatingSystem.Get File    ${CURDIR}/ne3s_2_vcu.txt
    Should Contain                  ${inside_pcap1}    NE3SBasicNotificationsService
    Should Contain                  ${inside_pcap2}    200 OK
    [Return]                        ${pcap_path}
    [Teardown]    Run Keywords      Disconnect From EMSSIM    ${emssim_connection}
    ...    AND                      TCPdump Teardown    hw_type=vCU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Delete All Certificates    hw_type=vCU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=oamtls   param_value=forced    hw_type=vCU
    ...    AND                      Run    rm ${CURDIR}/ne3s_1_vcu.txt
    ...    AND                      Run    rm ${CURDIR}/ne3s_2_vcu.txt

Trigger_CMP_init_and kur_sequence_from_NMS-vDU
    Log       Step 2: Adjust parameters    console=True
    Configure CMP                   ca_subject_name=C=PL, O=Common, CN=IPSEC    hw_type=vDU
    Update CMP Server Settings      hw_type=vDU
    Initialize Certificate          hw_type=vDU
    ${dn}=    Create List    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...                      MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ${pn}=    Create List    blockSha1CertChain    blockRsaKeyLengthBelow2048    oamTls
    ${pv}=    Create List    true    true    off
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU
    Log       Step 1: Connect to EMSsim    console=True
    Setup environment for EMSSIM    enable_tls=0    hw_type=vDU
    ${emssim_connection}=           Connect and Activate EMSSIM    enable_tls=0    cert_type=RSA    hw_type=vDU
    Start TCPdump                   capture_type=pod    pod_names=ute-cran1-oamext-0    hw_type=vDU
    Sleep    3s                     reason=TCPdump
    Wait until keyword succeeds     3x    3min    execute_command_on_emssim
    ...                             command=edit CMP-1-1-1 caSubjectName CN=CB009857_4k_384
    ...                             connection=${emssim_connection}
    ${value}=                       Check Parameter Value    param_name=caSubjectName
    ...                                                      dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CMP-1
    ...                                                      hw_type=vDU
    ${value_string}=                Convert to String        ${value}
    ${cert_string}=                 Convert to String        CN=CB009857_4k
    Should Contain                  ${value_string}          ${cert_string}
    Log       Step 3, 4: Initialize certificate    console=True
    Wait until keyword succeeds     3x    3min    execute_command_on_emssim
    ...                             command=cert_cmp_init
    ...                             connection=${emssim_connection}
    Log       Step 5: Check if certificate was installed    console=True
    Wait Until Keyword Succeeds     5min    15s    Check if Certificate is present on vDU    CN=CB009857_4k_384
    Log       Step 6, 7: Update CMP key    console=True
    Wait until keyword succeeds     3x    3min    execute_command_on_emssim
    ...                             command=cert_cmp_key_update
    ...                             connection=${emssim_connection}
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=ute-cran1-oamext-0    hw_type=vDU
    Log       Step 8, 9: Check communication with NE3S    console=True
    Convert pcap to XML             ${pcap_path}    http && ip.src==${LMP_VDU_IP}    ${CURDIR}/ne3s_1_vdu.txt
    Convert pcap to XML             ${pcap_path}    http && ip.dst==${LMP_VDU_IP}    ${CURDIR}/ne3s_2_vdu.txt
    ${inside_pcap1}=                OperatingSystem.Get File    ${CURDIR}/ne3s_1_vdu.txt
    ${inside_pcap2}=                OperatingSystem.Get File    ${CURDIR}/ne3s_2_vdu.txt
    Should Contain                  ${inside_pcap1}    NE3SBasicNotificationsService
    Should Contain                  ${inside_pcap2}    200 OK
    [Return]                        ${pcap_path}
    [Teardown]    Run Keywords      Disconnect From EMSSIM    ${emssim_connection}
    ...    AND                      TCPdump Teardown    hw_type=vDU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vDU
    ...    AND                      Delete All Certificates    hw_type=vDU
    ...    AND                      Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
    ...                             param_name=oamtls   param_value=forced    hw_type=vDU
    ...    AND                      Run    rm ${CURDIR}/ne3s_1_vdu.txt
    ...    AND                      Run    rm ${CURDIR}/ne3s_2_vdu.txt
