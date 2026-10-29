*** Settings ***
Force Tags    PY36
Documentation
...    Author:linjiangjing
...    Contact:jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8
...    Feature: CNI-124756

Suite Setup         run keywords    Setup Suite For Cloud    AND    Prepare scf for cases
...    AND    Slove ocp l2nrt container garbled code
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud
Resource          Resource/124756_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0

*** Test Cases ***
[1][1.0] CNI124756_09_PS function verification_IWK with 5GC001991 inCB010683_cloud_RF6.1_nonVET
    CNI124756_09_PS function verification_IWK with 5GC001991 inCB010683_cloud_RF6.1_nonVET
