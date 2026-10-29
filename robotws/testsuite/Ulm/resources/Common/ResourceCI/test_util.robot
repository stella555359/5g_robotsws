*** Settings ***
Documentation   This Test case is for verifying the functionality
...             of the common keywords in util.robot


Library     OperatingSystem
Resource    ../util.robot
Resource    ../connect.robot
Resource    ../testline.robot

*** Test Cases ***

Test Get File Path on Target
    [TAGS]      UTIL
    ${ssh_alias}=    connect.Connect To Node Common Unit
    ${file_path}=    Get File Path On Target    file_pattern=/ffs/run/TargetBD*.xml    connection=${ssh_alias}
    Log To Console   \nTargetBD path is: ${file_path}


Test Convert PCAP to PDML
    [TAGS]      UTIL
    # overcome pipeline restriction with creating .pcap
    ${tc_result_dir}    testline.Get Testcase Log Directory
    ${INPUT_FILE}    Set Variable   ${CURDIR}/sample.pcap.txt
    ${OUTPUT_FILE}   Set Variable   ${tc_result_dir}/sample.pcap
    ${hexdata}=    Get File    ${INPUT_FILE}
    Evaluate    open(r'''${OUTPUT_FILE}''', 'wb').write(bytes.fromhex('''${hexdata.strip()}'''))    modules=builtins
    Convert PCAP To PDML  source=${OUTPUT_FILE}  target=${tc_result_dir}/sample.pdml
    File Should Not Be Empty  path=${tc_result_dir}/sample.pdml
    # this keyword should be obsolete.
    # taf.converters.pcaptopdml should be used instead.
    Log To Console    \ntaf.converters.pcaptopdml should be used instead of this common keyword


Test Get latest modified file with defined pattern
    [TAGS]      UTIL
    # file_with_defined_pattern_1.txt existing in ${CURDIR}
    ${latestModifiedFileWithDefinedPattern}=  Get Latest Modified File With Defined Pattern  path=${CURDIR}  pattern=file_with_defined_pattern*.txt
    Should Be True  "${latestModifiedFileWithDefinedPattern}" == "file_with_defined_pattern_1.txt"
    ...  msg=got: ${latestModifiedFileWithDefinedPattern} expected: file_with_defined_pattern_1.txt
    Create File   path=${CURDIR}/file_with_defined_pattern_2.txt  content=just created file should be the latest modified file
    ${latestModifiedFileWithDefinedPattern}=  Get Latest Modified File With Defined Pattern  path=${CURDIR}  pattern=file_with_defined_pattern*.txt
    Should Be True  "${latestModifiedFileWithDefinedPattern}" == "file_with_defined_pattern_2.txt"
    ...  msg=got: ${latestModifiedFileWithDefinedPattern} expected: file_with_defined_pattern_2.txt
    Remove File  path=${CURDIR}/file_with_defined_pattern_2.txt


Test Modify XML Content
    [TAGS]      UTIL
    Copy File  ${CURDIR}/sample.xml  /tmp/sample.xml
    Modify XML Content  /tmp/sample.xml  .//physCellId  60
    ${physCellId}=  Get XML Content  /tmp/sample.xml  .//physCellId
    Should Be True   ${physCellId} == 60  msg=got physCellId ${physCellId}; expected 60


Test get XML Content
    [TAGS]      UTIL
    ${physCellId}=  Get XML Content  ${CURDIR}/sample.xml  .//physCellId
    Should Be True   ${physCellId} == 50  msg=got physCellId ${physCellId}; expected 50
