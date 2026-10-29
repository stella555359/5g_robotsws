*** Settings ***
Documentation
...		[Author]     		        "Aravind Reddy"
...		[Maintenance]		        "TRS I&V Tools Bangalore Team"
...		[Date] 			            "16:09:2025"


***Keywords***
Verify SOE is enabled
    ${output}=       Run  ping -c 5 ${enb_internal_ip}
    Should contain      ${output}       5 packets transmitted, 0 received, 100% packet loss

Check snapshot collection and IM snapshot is successful
    ${snapshot_file}=       Collect snapshot
    FIle should not be empty        ${snapshot_file}
    ${im_snapshot_file}=    Collect IM snapshot
    FIle should not be empty        ${im_snapshot_file}

Verify SOE is disabled
      ${output}=       Run  ping -c 5 ${enb_internal_ip}
      Should contain    ${output}  5 packets transmitted, 5 received, 0% packet loss

SSH and R&D should not have any impact
    ${ssh_status}=      Get Parameter      param_path=${SSH_parameter}
    Should Be True     '${ssh_status}'=='True'

    ${rd_status}=      Get Parameter      param_path=${R&D_parameter}
    Should Be True     '${rd_status}'=='False'

    Setup Remote Access    remote_device=bts
    ${stdout}       Remote Command Execute      command=ls /ffs/run
    Should not Be Empty     ${stdout}
    Teardown remote Access

Check nmap when SOE is enabled
    ${rc}  ${output}=    Run and Return Rc And Output   ${NMAP_COMMAND} ${enb_lmp_ip}
    FOR    ${i}    IN RANGE   15001       15007
        Should Match Regexp   '${output}'   ${i}\\/tcp\\s*filtered
        Should Match Regexp   '${output}'   6000\\/tcp\\s*filtered\\s*X11[\\w\\W]*12000\\/tcp\\s*filtered\\s*cce4x
        Should Match Regexp   '${output}'   22\\/tcp\\s*open\\s*ssh[\\w\\W]*443\\/tcp\\s*open\\s*https
    END

Check nmap when SOE is disabled
    ${rc}  ${output}=    Run and Return Rc And Output   ${NMAP_COMMAND} ${enb_lmp_ip}
    FOR    ${i}    IN RANGE   15001       15007
        Should Match Regexp   '${output}'   ${i}\\/tcp\\s*filtered
        Should Match Regexp   '${output}'   6000\\/tcp\\s*closed\\s*X11[\\w\\W]*12000\\/tcp\\s*closed\\s*cce4x
        Should Match Regexp   '${output}'   22\\/tcp\\s*open\\s*ssh[\\w\\W]*443\\/tcp\\s*open\\s*https
    END


Read mplane IP
        ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
        Set Suite Variable          ${mplane_ipv4}

'${state}' Ethernet port security via '${mplane_ip}'
    setup oamops    bts_host=${mplane_ip}      alias=mplane
    Run Keyword if     '${state}'=='Disable'         Change Ethernet port security       enable=${False}   timeout=120
    Run Keyword if     '${state}'=='Enable'         Change Ethernet port security       enable=${True}   timeout=120
    [Teardown]      Teardown oamops     alias=mplane

Check nmap status for '${mplane_ip}' '${nmap_comm}'
    ${rc}  ${output}=    Run and Return Rc And Output   ${nmap_comm} ${mplane_ip}
    FOR    ${i}    IN RANGE   15001       15005
        Should Match Regexp   '${output}'   ${i}\\/tcp\\s*filtered
        Should Match Regexp   '${output}'   15006\\/tcp\\s*filtered
        Should Match Regexp   '${output}'   22\\/tcp\\s*open\\s*ssh[\\w\\W]*443\\/tcp\\s*open\\s*https
    END