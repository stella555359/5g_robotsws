*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Variables ***
${pod_List}
${pods}

*** Keywords ***

Load scf

        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
        Perform Commissioning       dut=vdu_1       scf_file=${scf}        alias=vdu
        BuiltIn.Sleep         200


List each containers in each pods

        Setup Remote Access    remote_device=vdu_1.ocp              alias=vdu
        ${output}=      Remote Command Execute     command=oc get pods -n cran33     continue_on_failure=${False}
        ...    alias=vdu
        @{pods}=     Split String     ${output}
        Should Be True     len(${pods})>=1
        Set Suite Variable    @{pods}
        Should Be Equal    ${output}     ${pod_List}
         Teardown Remote Access

Check there is no service binding to the zero address

      ${pass_results}=    Create List
         ${pod_list}  Create List  oamasm  oamfh  oamfm  oampm  oamcm  oamconfig  oamext  cprt  l2nrt
    FOR  ${pod_abbr}  IN  @{pod_list}
    Setup Remote Access    remote_device=vdu_1.ocp              alias=vdu
    ${output}=          Remote Command Execute          command=oc get pod -n cran33 po-${pod_abbr}-0 -o
    ...         jsonpath={.spec.containers[*].name} | tr " " "\n" && echo             alias=vdu
    Log        ${output}
    @{containers}=    Split String    ${output}
       FOR   ${element}   IN   @{containers}
     Setup Remote Access    remote_device=vdu_1.ocp              alias=vdu
     Execute Interactive Remote Command
     ...     command=kubectl exec -it -n cran33 po-${pod_abbr}-0 -c ${element} -- bash       alias=vdu
     ${out}=          Execute Interactive Remote Command          command=ss -tlnp        alias=vdu
     Run Keyword And Return Status     Should Not Contain     ${out}     '0 0.0.0.0'
    Teardown Remote Access          alias=vdu
       END
    END

Check there is no path traversal to outside of container
          ${pass_results}=    Create List
      ${pod_list}  Create List  oamasm  oamfh  oamfm  oampm  oamcm  oamconfig  oamext  cprt  l2nrt
    FOR  ${pod_abbr}  IN  @{pod_list}
    Setup Remote Access    remote_device=vdu_1.ocp              alias=vdu
    ${output}=          Remote Command Execute
    ...    command=oc get pod -n cran33 po-${pod_abbr}-0 -o jsonpath={.spec.containers[*].name} | tr " " "\n" && echo
    ...   alias=vdu
    Log        ${output}
    @{containers}=    Split String    ${output}
       FOR   ${element}   IN   @{containers}
     Setup Remote Access    remote_device=vdu_1.ocp              alias=vdu
     Execute Interactive Remote Command
     ...     command=kubectl exec -it -n cran33 po-${pod_abbr}-0 -c ${element} -- bash       alias=vdu
     Execute Interactive Remote Command
     ...     command=chmod 777 /tmp/output.txt       alias=vdu
     Execute Interactive Remote Command
     ...     command=ls ./ >/tmp/output.txt       alias=vdu
     Execute Interactive Remote Command
     ...     command=chmod 777 /tmp/output_2.txt       alias=vdu
     Execute Interactive Remote Command
     ...     command=chmod 777 /tmp/output.txt       alias=vdu
     Setup Remote Access        remote_device=vdu_1.ocp       alias=co
     Execute Interactive Remote Command
     ...     command=kubectl exec -it -n cran33 po-${pod_abbr}-0 -c ${element} -- bash      alias=vdu
     Execute Interactive Remote Command
     ...     command=/tmp/output.txt > /var/home/core/output.txt       alias=co
     Execute Interactive Remote Command
     ...     command=kubectl exec -n cran33 po-${pod_abbr}-0 -c ${element} -- cat
     Execute Interactive Remote Command
     ...     command=/tmp/output_2.txt > /var/home/core/output_2.txt       alias=co
     ${act_op}=   Remote Command Execute     command=sort /var/home/core/output.txt     alias=co
     ${exp_op}=   Remote Command Execute     command=sort /var/home/core/output_2.txt     alias=co
     Should Match        ${act_op}            ${exp_op}
     Teardown Remote Access          alias=vdu
       END
     END

Logout vDU
    Teardown Oamops    dut=vdu_1      timeout=100    alias=vdu

