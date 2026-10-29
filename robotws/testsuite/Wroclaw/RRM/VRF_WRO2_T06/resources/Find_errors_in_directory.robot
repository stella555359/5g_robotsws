*** Settings ***

Documentation   :copyright: Nokia
...             :authors: Joanna Kutrowska-Girzycka
...             :contact: joanna.kutrowska-girzycka@nokia.com

...     Replace below line with path to file with your logs
...     ${base_directory}=      /home/ute/logs
...     Then run this robot file using command eg.
...     robot -d /home/ute/Desktop -L TRACE /home/ute/test_repository/testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Find_errors_in_directory.robot

Resource    ../../resources/airphone/scripts/libraries_instances.robot
Resource    Error_finder.robot


*** Variables ***
${base_directory}=      /home/ute/logs
${output_directory}=    ${OUTPUT DIR}

*** Test Cases ***
Execute error finder
        Find Errors    ${base_directory}    ${output_directory}


