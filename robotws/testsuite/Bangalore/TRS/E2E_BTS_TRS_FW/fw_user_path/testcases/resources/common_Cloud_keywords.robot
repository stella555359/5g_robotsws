*** Settings ***
Documentation
	...		[Procedure]				"Ths script has common keywords for 5G network sclicing (5GC000988) feature "
	...		[Date]					"07-10-2024"
	...		[Author]				""
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"COMMON CLOUD"
	...  	[Validation_status]  	"Partially Validated"


*** Keywords ***
Check vmAllocated
    [Arguments]     ${pod_name}     ${clouddut_type}
    Setup Oamops    dut=${clouddut_type}    alias=con80
    Get TnlTemplate     ${pod_name}     ${clouddut_type}
    Teardown Oamops     dut=${clouddut_type}     alias=con80

Get TnlTemplate
    [Arguments]     ${pod_name}     ${clouddut_type}
    Log      ${pod_name}
    Setup Oamops    dut=${clouddut_type}    alias=con81
    ${oam_tnl}=     Run Keyword and Ignore Error    Get Parameter   param_path=${oam_template}      dut=${clouddut_type}     alias=con81
    ${status_oam}=  Run Keyword And Return Status      Should Contain  ${oam_tnl}  OAM
    ${cpif_tnl}=    Run Keyword and Ignore Error    Get Parameter   param_path=${cpif_template}      dut=${clouddut_type}     alias=con81
    ${status_cpif}=  Run Keyword And Return Status      Should Contain  ${cpif_tnl}  5GControlPlane
    ${upue_tnl}=    Run Keyword and Ignore Error    Get Parameter   param_path=${upue_template}      dut=${clouddut_type}     alias=con81
    ${status_upue}=  Run Keyword And Return Status      Should Contain  ${upue_tnl}  5GUserPlane
    ${twamp_tnl}=   Run Keyword and Ignore Error    Get Parameter   param_path=${twamp_template}      dut=${clouddut_type}     alias=con81
    ${status_twamp}=  Run Keyword And Return Status      Should Contain  ${twamp_tnl}  TWAMP
    ${oamfh_tnl}=   Run Keyword and Ignore Error    Get Parameter   param_path=${oamfh_template}      dut=${clouddut_type}     alias=con81
    ${status_oamfh}=  Run Keyword And Return Status      Should Contain  ${oamfh_tnl}  OAMFH
    Run Keyword If  ${status_twamp} == ${False} and ${status_oamfh} == ${False}      Has only three tnl      ${clouddut_type}
    Run Keyword If  ${status_twamp} == ${True}  and ${status_oamfh} == ${False}  Has Four tnl    ${clouddut_type}
    Run Keyword If  ${status_twamp} == ${False} and ${status_oamfh} == ${True}     Has Four tnl with oamfh     ${clouddut_type}
    [Teardown]  Run Keyword And Ignore Error    Teardown Oamops     dut=${clouddut_type}     alias=con81

Has only three tnl
    [Arguments]     ${clouddut_type}
     ${pod_1}=   Get Parameter   param_path=${tln4_moc}   dut=${clouddut_type}     alias=con81
     ${pod_2}=   Get Parameter   param_path=${tln5_moc}   dut=${clouddut_type}     alias=con81
     ${pod_3}=   Get Parameter   param_path=${tln6_moc}   dut=${clouddut_type}     alias=con81
     Set Suite Variable  ${pod_1}    ${pod_1}
     Set Suite Variable  ${pod_2}    ${pod_2}
     Set Suite Variable  ${pod_3}    ${pod_3}
     Comment    You can pass these three values to ${which_pod} po-trs-cran1-oamext-0,po-trs-cran1-cpif-0
     Comment    po-trs-cran1-upue-0
     ${TNL_ID}=     Check for pod when three tnl      ${which_pod}
     Set Global Variable     ${TNL_ID}


Has Four tnl
    [Arguments]     ${clouddut_type}
    ${pod_1}=   Get Parameter   param_path=${tln5_moc}   dut=${clouddut_type}     alias=con81
    ${pod_2}=   Get Parameter   param_path=${tln6_moc}   dut=${clouddut_type}     alias=con81
    ${pod_3}=   Get Parameter   param_path=${tln7_moc}   dut=${clouddut_type}     alias=con81
    ${pod_4}=   Get Parameter   param_path=${tln8_moc}   dut=${clouddut_type}     alias=con81
    Set Suite Variable     ${pod_1}    ${pod_1}
    Set Suite Variable  ${pod_2}    ${pod_2}
    Set Suite Variable  ${pod_3}    ${pod_3}
    Set Suite Variable  ${pod_4}    ${pod_4}
    Comment    You can pass these three values to ${which_pod} po-trs-cran1-oamext-0,po-trs-cran1-cpif-0
    Comment    po-trs-cran1-upue-0, po-trs-cran1-twamp-0
    Check for pod when four tnl       ${which_pod}

Has Four tnl with oamfh
    [Arguments]     ${clouddut_type}
    ${pod_1}=   Get Parameter   param_path=${tln6_moc}   dut=${clouddut_type}     alias=con81
    ${pod_2}=   Get Parameter   param_path=${tln7_moc}   dut=${clouddut_type}     alias=con81
    ${pod_3}=   Get Parameter   param_path=${tln8_moc}   dut=${clouddut_type}     alias=con81
    ${pod_4_status}=    Run Keyword and Return Status   Get Parameter   param_path=${tln9_moc}  dut=${clouddut_type}     alias=con81

    ${pod_4}=   Run Keyword If  ${pod_4_status} == ${True}  Get Parameter   param_path=${tln9_moc}  dut=${clouddut_type}     alias=con81
    Set Suite Variable     ${pod_1}    ${pod_1}
    Set Suite Variable  ${pod_2}    ${pod_2}
    Set Suite Variable  ${pod_3}    ${pod_3}
    Set Suite Variable  ${pod_4}    ${pod_4}
    Run Keyword If  '${pod_4}' == 'None'    Has Four tnl    ${clouddut_type}
    Comment    You can pass these three values to ${which_pod} po-trs-cran1-oamext-0,po-trs-cran1-cpif-0
    Comment    po-trs-cran1-upue-0, po-trs-cran1-twamp-0, po-trs-cran1-oamfh-0 ,po-trs-cran1-l2nrt-0 ,po-trs-cran1-cprt-0
    Run Keyword If  '${pod_4}' != 'None'    Check for pod when four tnl       ${which_pod}

Check for pod when four tnl
    [Arguments]     ${pod_type}
    FOR     ${id}   IN RANGE    1   5
        Run Keyword If      '${pod_${id}}' == '${pod_type}'     Set Suite Variable  ${TNL_ID}     TNL-${id+4}
        RETURN    ${TNL_ID}
    END

Check for pod when three tnl
    [Arguments]     ${pod_type}
    FOR     ${id}   IN RANGE    1   4
        Run Keyword If      '${pod_${id}}' == '${pod_type}'     Set Suite Variable  ${TNL_ID}     TNL-${id+3}
        RETURN    ${TNL_ID}
    END
