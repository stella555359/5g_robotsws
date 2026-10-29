*** Settings ***
Documentation            An example about how to install McShark and check the installation

Library                             ../../../../RRM/ET/resources/python/luashark_tools.py
Library                             luashark_tools.analyzer       WITH NAME       analyzer

Resource                            ../Setup.robot

Suite Setup                         Suite setup     keepAllUeDataInCfgFile=${True}    # listBackupFiles=${FD_ALL}

*** Test Cases ***
My Test
    Dated Log New Line              ===== HELLO: Hope McShark installation Was Correctly Done ...
    Check McShark Install
    Dated Log                       ===== BYE-BYE

*** Keywords ***
Check McShark Install
    ${analyzer_build}=              analyzer.getBuild
    ${analyzer_file_path}=          analyzer.get_analyzer_path
    ${analyzer_size}=               run     stat -c "%s" ${analyzer_file_path}

    Dated Log New Line              >>>RDH DEBUG: analyzer build is: ${analyzer_build}
    Dated Log                       >>>RDH DEBUG: analyzer file path is: ${analyzer_file_path}
    Dated Log                       >>>RDH DEBUG: analyzer file size is: ${analyzer_size}

