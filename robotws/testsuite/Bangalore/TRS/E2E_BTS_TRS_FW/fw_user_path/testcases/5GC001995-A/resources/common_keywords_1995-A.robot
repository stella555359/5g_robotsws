*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Variables ***
${TNLs}
${pods}
${pass_results}
${active_pods}
***Keywords***

Login_vDU
    Setup Oamops    dut=vdu_1        timeout=100   alias=default

Logout vDU
    Teardown Oamops    dut=vdu_1      timeout=100    alias=default


Load scf
    Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
    Perform Commissioning      scf_file=${scf}      timeout=300      dut=vdu_1            alias=vdu


Check PODs IPv4 main static route info via CLI

        Setup Remote Access    remote_device=vdu_1.ocp              alias=vdu

        Execute Interactive Remote Command          command=kubectl exec -it -n cran33 po-cprt-0 -c ctr-nwmgmt -- bash
        ...     alias=vdu
        ${via}=        Execute Interactive Remote Command          command=ip route | grep via > /tmp/route.txt
        ...     alias=vdu
        Log         ${via}
        Execute Interactive Remote Command     command=chmod 777 /tmp/route.txt      alias=vdu
        Setup Remote Access        remote_device=vdu_1.ocp       alias=co
        ${check}=           Execute Interactive Remote Command
        ...     command=kubectl exec -n cran33 po-cprt-0 -c ctr-nwmgmt -- cat /tmp/route.txt > /var/home/core/route.txt
        ...     alias=co
        Log         ${check}
        ${act_op}=   Remote Command Execute     command=cat /var/home/core/route.txt     alias=co

        Should Contain      ${act_op}      10.44.69.64
        Should Contain      ${act_op}       10.44.147.33

       Teardown Remote Access          alias=vdu

Execute IPv4 Packets Engress Testing
    Setup Remote Access    remote_device=vdu_1.ocp              alias=vdu
    Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
    Execute Interactive Remote Command          command=kubectl exec -it -n cran33 po-cprt-0 -c ctr-nwmgmt -- bash
    ...      alias=vdu
    ${ping}=      Execute Interactive Remote Command      command=ping -c 10 ${ip}     alias=vdu
       BuiltIn.Sleep    10
       Should Contain    ${ping}    ${packet_loss}
