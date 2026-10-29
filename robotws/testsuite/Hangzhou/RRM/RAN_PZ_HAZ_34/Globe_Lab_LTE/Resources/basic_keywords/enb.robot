# @Time    : 2021/10/25 16:35
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : enb.robot
# @Software: PyCharm
# @Doc     : Enb Common Keywords
*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/bts/robot/enb.robot

*** Keywords ***
Unlock Parameter
    [Arguments]  ${dist_name}
    Connect to eNB via ssl
    Modify the parameter on enblte  dist_name=${dist_name}  parameter_name=administrativeState  value=unlocked
    [Teardown]  Enblte close down

Lock Parameter
    [Arguments]  ${dist_name}
    Connect to eNB via ssl
    Modify the parameter on enblte  dist_name=${dist_name}  parameter_name=administrativeState  value=locked
    [Teardown]  Enblte close down

Verify No Critical Alarms
    Connect to eNB via ssl
    Check enb status is in cell on air status
    ${active_alarm_list}   enblte.get_active_alarms  connection=enblte
    FOR     ${active_alarm}     IN  @{active_alarm_list}
        ${alarm_severity}	Get From Dictionary     ${active_alarm}	    severity
        Should Not Be Equal     ${alarm_severity}     Critical
    END
    Enblte close down

Verify S1 Link Enabled
    [Arguments]  ${dist_name}
    Connect to eNB via ssl
    @{ret1}  enblte.get_managed_objects    class_name=LNADJ255    connection=enblte
    #${ret}  enblte.get_parameters  dist_name=${dist_name}  connection=enblte
    #${ret}  enblte.get_parameters  dist_name=${dist_name}  pattern=administrativeState  connection=enblte
    [Teardown]  Enblte close down

Verify X2 Link Available
    [Arguments]    ${enb_index}    ${id_num}
    Connect to eNB via ssl    enb_index=${enb_index}
    ${ret}  enblte.get_parameters_for    class_name=LNADJ    id_num=${id_num}    connection=enblte
    ${status}    Get From Dictionary    ${ret}    x2LinkStatus
    Should Be Equal    ${status}    available
    [Teardown]    Enblte close down

Verify Current Scf Info
    [Arguments]    ${enb_index}
    Connect to eNB via ssl    enb_index=${enb_index}
    ${path}    enblte.get_current_scf_content    connection=enblte
	Run    echo \'${path}\'>/tmp/tempscf.xml
	${GNB2XNLINK}    Run     awk -F "\\"" '/distName=\\"MRBTS-[0-9]+\\/LNBTS-[0-9]+\\/LNADJ-[0-9]+\\LNADJL-255||"/{print $4}' /tmp/tempscf.xml
