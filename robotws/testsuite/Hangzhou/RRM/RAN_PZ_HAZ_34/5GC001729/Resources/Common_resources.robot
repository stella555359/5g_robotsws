*** Settings ***
Documentation    This is for two gnb connections in case of gnbs inter handover
...              Please do not modify the file without notification to author
...              Author: Chen Jun
...              Squard: HZ SG6
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Library     taf.analyzer.pcap    WITH NAME   cap
Resource    ../../common/BIP.robot
