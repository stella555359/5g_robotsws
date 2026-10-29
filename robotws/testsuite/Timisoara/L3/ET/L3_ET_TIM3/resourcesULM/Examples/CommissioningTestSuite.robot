*** Settings ***
Documentation   This Test Suite shall demonstrate, how the commissioning of managed object
...             lists could be achieved.
...             The Test Suite is using the keyword "Commission Managed Object List"
...             from the file Ulm/Common/gnb.robot
...             This Keyword gives the possibility, to describe all managed objects and
...             their parameters in the test case. By that, it is also possibleto influence
...             the operation of the parameter or managed object. This gives you the freedom
...             to easily create, update and delete items in the configuration of the gNodeB.


Resource        scf_keywords.robot
Resource        ../gnb.robot
Resource        ../commissioning.robot

Test Setup      Prepare Testcase


*** Test Cases ***

Create the MOCS
    [Documentation]  This Testcase assures, that the two managed objects
    ...              NRPLMN1 and NRPLM2 do not exist. If so, a delta commissioning
    ...              will be run, to create the two managed objects.
    ...              After the commissioning it is assured, that the objects have
    ...              been created.

    Distnames For NRPLMN1 and NRPLMN2 Should Not exist
    Create NRPLMN MOs in gNodeB
    Distnames For NRPLMN1 and NRPLMN2 Should exist


Set nrPlmnDn in NRDRB_QCI-1
    [Documentation]  With a fresh UTS cloud test line, the parameter nrPlmnDN
    ...              inside of the managed object NRDRB_QCI_1 is noramlly not
    ...              existing. This testcase respective keyword shows, how a new
    ...              parameter can be created.

    Update nrPlmnDn in managed object NRBDRB_QCI_1

Check Parameter
    [Documentation]  This Test Case only verifies, that one specific parameters
    ...              is existing and filled by processing the scfc file.

    NrPlmnDN should point to NRPLMN-1

Delete nrPlmnDn
    [Documentation]  This test case demonstrates, how a parameter of a managed
    ...              object can be deleted.

    Delete nrPlmnDn in managed object NRBDRB_QCI_1

Delete the MOCS
    [Documentation]  This test case demonstrates, how some managed objects can be
    ...              deleted in the current gNodeB.

    Create Deleting Managed Objects NRPLMN1 and NRPPLMN2
    Distnames For NRPLMN1 and NRPLMN2 Should Not exist


*** Keywords ***
NrPlmnDN should point to NRPLMN-1
    [Documentation]   This Keyword fetches the parameter nrPlmnDN from the SCF
    ...               and verifies its value (by knowing, what the previous test
    ...               case did).

    ${nrPlmnDn}=    Get Parameter Value from SCF
    ...     dist_name=MRBTS-1/NRBTS-1/NRDRB_QCI-1
    ...     param_name=nrPlmnDN
    Should Be Equal    ${nrPlmnDn}    MRBTS-1/NRBTS-1/NRPLMN-1

Prepare Testcase
    ${resultTestDir}=     testline.Get testcase log directory
    Set Test Variable    ${resultTestDir}

Delete nrPlmnDn in managed object NRBDRB_QCI_1

    Get Distnames for NRPLMN1 and NRPLMN2
    ${commission_object}=   Create Commissioning Object To Delete nrPlmnDn in NRDRB_QCI-1
    Commission Managed Object List    ${commission_object}

Update nrPlmnDn in managed object NRBDRB_QCI_1

    Get Distnames for NRPLMN1 and NRPLMN2
    ${commission_object}=   Create Commissioning Object To Update nrPlmnDn in NRDRB_QCI-1
    Commission Managed Object List    ${commission_object}


Get Distnames for NRPLMN1 and NRPLMN2
    ${nrbts_distNames}=         gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+                gnb_id=${0}
    Set test variable    ${nrbts_distName}        @{nrbts_distNames}[0]

    ${nrplmn1_distName}=   Catenate    SEPARATOR=${EMPTY}    ${nrbts_distName}    /NRPLMN-1
    ${nrplmn2_distName}=   Catenate    SEPARATOR=${EMPTY}    ${nrbts_distName}    /NRPLMN-1

    Set test Variable   ${nrplmn1_distName}
    Set test Variable   ${nrplmn2_distName}

Distnames For NRPLMN1 and NRPLMN2 Should Not exist

    ${nrplmn1_distNames}=       gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+/NRPLMN-1       gnb_id=${0}
    Should Be Empty    ${nrplmn1_distNames}

    ${nrplmn2_distNames}=       gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+/NRPLMN-2       gnb_id=${0}
    Should Be Empty    ${nrplmn1_distNames}


Distnames For NRPLMN1 and NRPLMN2 Should exist
    ${nrplmn1_distNames}=       gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+/NRPLMN-1       gnb_id=${0}
    Should Not Be Empty    ${nrplmn1_distNames}

    ${nrplmn2_distNames}=       gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+/NRPLMN-2       gnb_id=${0}
    Should Not Be Empty    ${nrplmn1_distNames}

Create Managed Object NRPLMN
    [Arguments]     ${dist_name}   ${mcc_value}    ${mnc_value}    ${mncLength_value}
    ${nrbts_distNames}=    gnb.Get distNames from gNB SCF    regex=MRBTS-\\d+/NRBTS-\\d+                gnb_id=${0}
    ${nrplmn_distname}=    Catenate    SEPARATOR=/    @{nrbts_distNames}[0]    ${dist_name}

    ${mcc}=          Create Dictionary    parameterName=mcc         value=${mcc_value}          operation=update
    ${mnc}=          Create Dictionary    parameterName=mnc         value=${mnc_value}          operation=update
    ${mncLength}=    Create Dictionary    parameterName=mncLength   value=${mncLength_value}    operation=update

    ${NRPLMN_Parameters}=   Create List     ${mcc}    ${mnc}    ${mncLength}

    ${NRPLMN}=     Create Dictionary
    ...     distName=${nrplmn_distname}
    ...     operation=create
    ...     parameters=${NRPLMN_Parameters}
    [Return]    ${NRPLMN}


Create Deleting Managed Objects NRPLMN1 and NRPPLMN2
    ${NRPLMN_1}=   Create Managed Object NRPLMN    dist_name=NRPLMN-1   mcc_value=555   mnc_value=10    mncLength_value=2
    ${NRPLMN_2}=   Create Managed Object NRPLMN    dist_name=NRPLMN-2   mcc_value=262   mnc_value=731   mncLength_value=3
    ${managed_objects}=   Create List   ${NRPLMN_1}    ${NRPLMN_2}

    FOR    ${object}    IN   @{managed_objects}
            Set To Dictionary     ${object}     operation=delete
    END
    Commission Managed Object List    ${managed_objects}


Create NRPLMN MOs in gNodeB
    ${NRPLMN_1}=   Create Managed Object NRPLMN    dist_name=NRPLMN-1   mcc_value=555   mnc_value=10    mncLength_value=2
    ${NRPLMN_2}=   Create Managed Object NRPLMN    dist_name=NRPLMN-2   mcc_value=262   mnc_value=731   mncLength_value=3
    ${managed_objects}=   Create List   ${NRPLMN_1}    ${NRPLMN_2}

    Commission Managed Object List    ${managed_objects}



Create Commissioning Object To Delete nrPlmnDn in NRDRB_QCI-1

    ${nrPlmnDn}=    Create Dictionary
    ...     parameterName=nrPlmnDN
    ...     value=
    ...     operation=delete

    ${NRPLMNR_1_params}=   Create List   ${nrPlmnDn}

    ${NRPLMNR_1}=    Create Dictionary
    ...     distName=MRBTS-1/NRBTS-1/NRDRB_QCI-1
    ...     operation=update
    ...     parameters=${NRPLMNR_1_params}

    ${managed_objects}=    Create List    ${NRPLMNR_1}

    ${json_object}=     Evaluate    json.dumps(${managed_objects})    json
    [Return]    ${managed_objects}


Create Commissioning Object To Update nrPlmnDn in NRDRB_QCI-1
    ${nrPlmnDn}=    Create Dictionary
    ...     parameterName=nrPlmnDN
    ...     value=MRBTS-1/NRBTS-1/NRPLMN-1
    ...     operation=update

    ${NRPLMNR_1_params}=   Create List   ${nrPlmnDn}

    ${NRPLMNR_1}=    Create Dictionary
    ...     distName=MRBTS-1/NRBTS-1/NRDRB_QCI-1
    ...     operation=update
    ...     parameters=${NRPLMNR_1_params}

    ${managed_objects}=    Create List    ${NRPLMNR_1}

    [Return]    ${managed_objects}

