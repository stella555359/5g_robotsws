*** Settings ***
Documentation
...   author:

# Library         testsuite/RRM/Wroclaw/FGCR-8741/resources/DeltaStore.py
# Library         testsuite/RRM/Wroclaw/FGCR-8741/resources/AdminHelper.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-8741/resources/keywords_fgcr.py

*** Variables ***

${UE_1} =  SA_[1]FGCR-8741_SA_FDD_5MHz_One_UE_Attach_In_Good_Radio_Conditions_UL_Traffic_MPR_Enabled.pcap
${UE_2} =  SA_[1]FGCR-8741_SA_FDD_15MHz_Two_UE_Attach_In_Good_Radio_Conditions_UL_Traffic_MPR_Enabled.pcap

${fgcr_path}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-8741/resources

*** Keywords ***
Decreasing Radio Conditions
    FOR    ${index}   IN RANGE    1   11
       ${attenuate}=   Evaluate    ${index} * 8
	   Set attenuation and check  lines=${lines_gNB_157_AHCA_1}    value=${attenuate}
	   Sleep  1s
    END
