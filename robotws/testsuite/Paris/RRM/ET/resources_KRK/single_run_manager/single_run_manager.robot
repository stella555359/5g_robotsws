*** Settings ***
Documentation
...    Author: Michal Gorski
...    Contact: michal.gorski@nokia.com
...    Description: run test suite ${suite_path} on branch ${branch_name}

Library    single_run_manager.py


*** Test Cases ***
Single_run_manager
    Update repository and checkout branch    ${branch_name}
    Run test suite    ${suite_path}