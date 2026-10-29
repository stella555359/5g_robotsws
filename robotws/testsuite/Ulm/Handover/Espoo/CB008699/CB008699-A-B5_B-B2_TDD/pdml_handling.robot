*** Settings ***
Documentation    Test keyword resource file for CB008699-A-B5_B-B2_TDD

Library    pdml_handling.py

*** Keywords ***
Check Fields Exist Under Element In PDML Message Path
     [Arguments]    ${msgpath}=msg  ${searchfields}=1

    ${PDML}=  Set Variable  ${OUTPUT_DIR}/${TEST_NAME}.pdml
    #${PDML}=  Set Variable  ${OUTPUT_DIR}/${PDML}

    ${cmdstring}=  Build PDML Xpath  ${msgpath}
    ${searchfieldlist}=  Get Search Parameter List  searchfields=${searchfields}

    ${ret1}=  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${cmdstring}  searchfields=${searchfieldlist}
    IF  ${ret1}!=1  Log To Console  All Parameters Found

    IF   "${ret1}"!="1"  Log to console  ERROR: Expected one ${searchfields}, found: ${ret1}!
    SHOULD BE TRUE    ${ret1} == 1

Check Fields Exist Under Element n Times In PDML Message Path
     [Arguments]    ${msgpath}=msg  ${searchfields}=1  ${times}=1

    ${PDML}=  Set Variable  ${OUTPUT_DIR}/${TEST_NAME}.pdml
    #${PDML}=  Set Variable  ${OUTPUT_DIR}/${PDML}

    ${cmdstring}=  Build PDML Xpath  ${msgpath}
    ${searchfieldlist}=  Get Search Parameter List  searchfields=${searchfields}

    ${ret1}=  Find Msgpath With Searchfields From Pdml  PDML=${PDML}  msgpath=${cmdstring}  searchfields=${searchfieldlist}
    IF  ${ret1}!=1  Log To Console  All Parameters Found

    IF   "${ret1}"!="${times}"  Log to console  ERROR: Expected ${times} ${searchfields}, found: ${ret1}!
    SHOULD BE TRUE    ${ret1} == ${times}

Get Message List
    [Arguments]  ${msgpath}
    ${msglist}=  Split String  ${msgpath}  ::

    RETURN  ${msglist}

Build PDML Xpath
    [Arguments]  ${msgpath}

    ${msglist}=  Get Message List  msgpath=${msgpath}
    # build search command
    @{cmdlist}        Create List  .
    FOR  ${msg}  IN  @{msglist}

      ${cmd}=  Set Variable  //field[@name="${msg}"]
      Append To List  ${cmdlist}  ${cmd}
    END
    ${cmdstring}=  Evaluate  "".join(${cmdlist})

    RETURN  ${cmdstring}

Get Search Parameter List
    [Arguments]    ${searchfields}
    ${msglist}=  Get Message List  msgpath=${searchfields}
    @{cmdlist}       create list

    FOR  ${msg}  IN   @{msglist}
      ${cmd}=  Get Search Parameter Sub List  ${msg}
      Append To List   ${cmdlist}  ${cmd}
    END

    RETURN  ${cmdlist}

Get Search Parameter Sub List
    [Arguments]    ${searchfields}

    ${msglist}=  Split String  ${searchfields}  &&
    @{cmdlist}       create list

    FOR  ${msg}  IN   @{msglist}
      ${msgparameters}=  Split String  ${msg}  =
      ${msgparameterslength}=    Get Length   ${msgparameters}
      ${cmd}=  Set Variable If
      ...  "${msgparameterslength}"=="${1}"  ${msg}
      ...  "${msgparameterslength}"=="${2}"  ${msgparameters}[0]: ${msgparameters}[1]
      Append To List   ${cmdlist}  ${cmd}
    END
    ${cmdstring}=  Evaluate  "&&".join(${cmdlist})
    RETURN  ${cmdstring}
