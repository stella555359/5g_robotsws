*** Settings ***
Library     BuiltIn
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME   csn

Resource    taf_cu.robot
Library     Utils.py
Variables   Variables.py

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
@{counter_id_list}   M40002C3


*** Keywords ***
