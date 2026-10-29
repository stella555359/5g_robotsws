*** Settings ***
Documentation   This Test case is for verifying the functionality
...             of the common keywords in util.robot

Library     OperatingSystem
Resource    ../util.robot
Resource    ../connect.robot

*** Test Cases ***

Test Extract tar file to tmp
    [TAGS]      UTIL
    # Extract tar file to tmp
    # this keyword is used only in Ulm/SyVe/resources/installation.robot
    # in unused keyword 'Enable L1bypass on COAM'
    # and this is only for documentation how instalation was done in era before UTE
    Log To Console   \n"Extract tar file to tmp" is old obsolete keyword; delete it and delete this test!


Test Compress files into package and install
    [TAGS]      UTIL
    # Compress files into package and install
    # this keyword is used only in Ulm/SyVe/resources/installation.robot
    # in unused keyword 'Enable L1bypass on COAM'
    # and this is only for documentation how instalation was done in era before UTE
    Log To Console    \n"Compress files into package and install" is old obsolete keyword; delete it and delete this test!


Test Get File Path on Target
    [TAGS]      UTIL
    ${asik_alias}=    connect.Connect to Node Common Unit
    ${file_path}=    Get File Path on Target    file_pattern=/ffs/run/TargetBD*.xml    connection=${asik_alias}
    Log To Console   \nTargetBD path is: ${file_path}


Test Convert PCAP to PDML
    [TAGS]      UTIL
    # overcome pipeline restriction with creating .pcap with xxd
    run  xxd -r -p ${CURDIR}/sample.pcap.txt > ${CURDIR}/sample.pcap
    Convert PCAP to PDML  source=${CURDIR}/sample.pcap  target=${CURDIR}/sample.pdml
    file should not be empty  path=${CURDIR}/sample.pdml
    remove file  path=${CURDIR}/sample.pdml
    # this keyword should be obsolete.
    # taf.converters.pcaptopdml should be used instead.
    Log To Console    \ntaf.converters.pcaptopdml should be used instead of this common keyword


Test Get latest modified file with defined pattern
    [TAGS]      UTIL
    # file_with_defined_pattern_1.txt existing in ${CURDIR}
    ${latestModifiedFileWithDefinedPattern}=  Get latest modified file with defined pattern  path=${CURDIR}  pattern=file_with_defined_pattern*.txt
    Should be True  "${latestModifiedFileWithDefinedPattern}" == "file_with_defined_pattern_1.txt"
    ...  msg=got: ${latestModifiedFileWithDefinedPattern} expected: file_with_defined_pattern_1.txt
    create file   path=${CURDIR}/file_with_defined_pattern_2.txt  content=just created file should be the latest modified file
    ${latestModifiedFileWithDefinedPattern}=  Get latest modified file with defined pattern  path=${CURDIR}  pattern=file_with_defined_pattern*.txt
    Should be True  "${latestModifiedFileWithDefinedPattern}" == "file_with_defined_pattern_2.txt"
    ...  msg=got: ${latestModifiedFileWithDefinedPattern} expected: file_with_defined_pattern_2.txt
    remove file  path=${CURDIR}/file_with_defined_pattern_2.txt


Test Modify XML Content
    [TAGS]      UTIL
    Copy File  ${CURDIR}/sample.xml  /tmp/sample.xml
    Modify XML Content  /tmp/sample.xml  .//physCellId  60
    ${physCellId}=  get XML Content  /tmp/sample.xml  .//physCellId
    Should Be True   ${physCellId} == 60  msg=got physCellId ${physCellId}; expected 60


Test get XML Content
    [TAGS]      UTIL
    ${physCellId}=  get XML Content  ${CURDIR}/sample.xml  .//physCellId
    Should Be True   ${physCellId} == 50  msg=got physCellId ${physCellId}; expected 50


*** Keywords ***



