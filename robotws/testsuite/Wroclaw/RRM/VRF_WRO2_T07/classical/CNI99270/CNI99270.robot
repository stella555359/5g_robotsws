*** Settings ***
Documentation
...   author: Lukasz Adamski
...   contact: lukasz.adamski@nokia.com
...   This is the TESTSUITE file for CNI-99270



Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI99270/resources/keywords_99270.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


Suite Setup     Run Keywords
...             testline_preparation.Prepare Testline

Test Teardown   Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

*** Test Cases ***

CNI-99270_03_SA_2CC_DLCA_Supercell_Intraband_covBasedA1
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell
    ...               and intra band DL CA 2CC TDD in SA mode can be
    ...               set up with sCellAdditionMethod set to covBasedA1.
    CNI-99270_03_SA_2CC_DLCA_Supercell_Intraband_covBasedA1


CNI-99270_05_NSA_2CC_DLCA_Supercell_Interband_covBasedA1
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell (NSA)
    ...               and inter band DL CA 2CC TDD in SA mode can be
    ...               set up with sCellAdditionMethod set to covBasedA1.
    CNI-99270_05_NSA_2CC_DLCA_Supercell_Interband_covBasedA1
