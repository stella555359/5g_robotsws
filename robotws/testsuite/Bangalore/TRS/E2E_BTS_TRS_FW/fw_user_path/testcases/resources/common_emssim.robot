*** Settings ***
Documentation
...     [Author]        "Jansi Rani"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot


*** Keywords ***

Start emssim configuration
    Setup Ems   config_device=emssim1
    Sleep   180s
    Enb Configuration Should Be Discovered      config_device=emssim1

Create the object via Emssim
	[Arguments]		${operation}	${object}
	Configuration Manage    config_device=emssim1   operation=${operation}  config=${object}    skip_ro=True    skip_np=True    wait=180
    sleep   60s

Kill the fbox
    ${output}=  Run     ps -aef | grep fbox
    Log     ${output}
    @{first}=   Split To Lines   ${output}
    FOR    ${ELEMENT}    IN    @{first}
           @{words}=       Split string    ${ELEMENT}
           ${pid}=     Get from list        ${words}     1
           Run     sudo kill -9 ${pid}
    END

Kill the flexi1
    ${output}=  Run     ps -aef | grep flexi1
    Log     ${output}
    @{first}=   Split To Lines   ${output}
    FOR    ${ELEMENT}    IN    @{first}
           @{words}=       Split string    ${ELEMENT}
           ${pid}=     Get from list        ${words}     1
           Run     sudo kill -9 ${pid}
    END

Kill the emssim
    ${output}=  Run     ps -aef | grep emssim
    Log     ${output}
    @{first}=   Split To Lines   ${output}
    FOR    ${ELEMENT}    IN    @{first}
           @{words}=       Split string    ${ELEMENT}
           ${pid}=     Get from list        ${words}     1
           Run     sudo kill -9 ${pid}
    END

teardown Emssim
	Kill the fbox
	Kill the flexi1
	Kill the emssim
    Teardown Ems    config_device=emssim1
