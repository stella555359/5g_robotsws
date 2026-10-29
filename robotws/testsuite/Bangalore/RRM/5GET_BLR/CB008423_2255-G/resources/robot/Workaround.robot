*** Settings ***
Documentation
...            == Purpose ==
...            Library to implement temporary Workaround
...
...            == Description ==
...            The principle is to propose workaround to solve temporary issues
...
...            *Main keywords are:*
...            | WorkAround for CloudBTS X2AP link issue  | no parameter  |
...            | WorkAround for CloudBTS traffic issues   | no parameter  |
...
...            *X2AP Link Issue:*
...            | Issue          | When a Krakow or Ulm CloudBTS TL is used for the *first time*, the X2C is not UP |
...            | Solution       | Via the OAM_CU, do connection to cpif I/F and ping X2-C and F1-C I/F             |
...            | Implementation | Workaround is called in Setup.robot                                              |
...
...            * Traffic Issues:*
...            | Issue          | When a Krakow or Ulm CloudBTS TL is used, sometimes, traffic I/F are sleeping |
...            | Solution       | via the OAM_CU, do connection to cpue I/F and ping S1-U and F1-U I/F          |
...            | Implementation | Workaround is called in Setup.robot                                           |

Resource                            Connect.robot

*** Variables ***
${cpif_wts_ip}                      10.0.1.1
${cpif_du_ip}                       10.0.3.60
${upue_wts_ip}                      10.0.1.133
${upue_du_ip}                       10.0.3.60
*** Keywords ***
#===================================
# WorkAround for X2AP Link Issue
#===================================
WorkAround for CloudBTS X2AP link issue
    [Documentation]                 INTERNAL USAGE
    ...                             KW to be removed as soon as Krakow and Ulm sites solve their issues
    ${cpif_vm}                      OAM Get VM
    ...                             oam=${GNB_CU.oam}                       name=CPIF
    Do Ping On Interfaces           host=${cpif_vm}
    ...                             wts_ip=${cpif_wts_ip}
    ...                             du_ip=${cpif_du_ip}
    ...                             issue=X2AP Link Issues

#===================================
# WorkAround for Traffic Issue
#===================================
WorkAround for CloudBTS Traffic issue
    [Documentation]                 INTERNAL USAGE
    ...                             KW to be removed as soon as Krakow and Ulm sites solve their issues
    ${upue_vm}                      OAM Get VM
    ...                             oam=${GNB_CU.oam}                       name=UPUE
    Do Ping On Interfaces           host=${upue_vm}
    ...                             wts_ip=${upue_wts_ip}
    ...                             du_ip=${upue_du_ip}
    ...                             issue=Traffic Issues

#===================================
# PING Tool
#===================================
Do Ping On Interfaces
    [Documentation]                 INTERNAL USAGE
    ...                             Will be removed as soon as Krakow and Ulm sites solve their issues
    ...                             Do ping between CPIF VM and WTS then ping between CPIF VM and DU
    [Arguments]                     ${host}    ${wts_ip}    ${du_ip}    ${issue}
    Dated Log                       WorkAround for CloudBTS ${issue}
    Dated Log                       \tWA: Connection to ${host.sshId}
    SSH Connect                     host=${host}
    Dated Log                       \tWA: Start the ping sequence to ${wts_ip}
    ${output}                       csn.Execute
    ...                             command=ping ${wts_ip} -c 5
    ...                             connection=${host.alias}
    ...                             timeout=10
    Dated Log                       \tWA: Start the ping sequence to ${du_ip}
    ${output}                       csn.Execute
    ...                             command=ping ${du_ip} -c 5
    ...                             connection=${host.alias}
    ...                             timeout=10
    Dated Log                       \tWA: Disconnection from ${host.sshId}
    csn.Disconnect                  connection=${host.alias}

#===================================
# WA WTS Clear
#===================================
WorkAround WTS Clear
    [Documentation]                 INTERNAL USAGE
    ${cmd}                          Set variable                            mkdir -p /home/ute/robotlte/config
    Dated Log                       WA ${SPACE}${SPACE}${SPACE}: WorkAround WTS Clear (${cmd})
    Run                             ${cmd}
