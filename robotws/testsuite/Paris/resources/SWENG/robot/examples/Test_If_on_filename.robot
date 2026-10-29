*** Settings ***
Documentation                       checking filename

Resource                            ../Tools.robot


*** Variables ***
${pm_latest}   /home/ute/logs/060125_1709/Logs/20250106_171518516996.CB011031-B_master/PM_06012025_1821/pm_files/PM.BTS-1.20250106.182000.ANY.xml.gz


*** Test Cases ***
Test FILENAME
    Dated Log                       START
    ${file_str} =    Convert To String    ${pm_latest}
    ${file_str} =    Strip String    ${file_str}
    IF    '${file_str}'[-7:] == '.xml.gz'
                        Dated Log                       PM file is in xml.gz format
    END
