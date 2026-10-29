*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Test Plan (QC):  /VRF_WRO3_T04/25R1/CB009484/
...    Description:
...        Split F:    Verify configuration of HTTP Security Response Headers

*** Variables ***
${cross_policy}=       referrer-policy: strict-origin-when-cross-origin
${perm_policy}=        x-permitted-cross-domain-policies: none
${embedder_policy}=    cross-origin-embedder-policy: require-corp
${opener_policy}=      cross-origin-opener-policy: same-origin
${resource_policy}=    cross-origin-resource-policy: same-site
${service_username}    serviceuser
${service_password}    Pl(FzaYj5~c5;q

*** Keywords ***
Verify_All_Cross_Origin_Policies
    Log                Step 2: Verify Referrer-Policy    console=True
    ${output}=         Run    curl -H "Referer: https://nokia.com" -I -k https://${MPLANE_IPV4}
    ${cross}=          Convert to Lower Case    ${output}
    Should Contain     ${cross}    ${cross_policy}
    Log                Step 4: Verify X-Permitted-Cross-Domain-Policies    console=True
    ${output}=         Run    curl -k -H "X-Correlation-ID: correlation123456789" https://${MPLANE_IPV4} -I
    ${perm}=           Convert to Lower Case    ${output}
    Should Contain     ${perm}    ${perm_policy}
    Log                Step 5: Verify X-Permitted-Cross-Domain-Policies    console=True
    ${command}=        Catenate     curl -k -H "User-Agent:
    ...                             Mozilla/5.0 (Windows NT 10.0; Win64; x64)
    ...                             AppleWebKit/537.36 (KHTML, like Gecko)
    ...                             Chrome/91.0.4472.124 Safari/537.36
    ...                             Edge/91.0.864.59" https://${MPLANE_IPV4} -I
    ${output}=         Run          ${command}
    ${perm}=           Convert to Lower Case    ${output}
    Should Contain     ${perm}    ${perm_policy}
    Log                Step 7: Verify Cross-Origin-Embedder-Policy    console=True
    ${command}=        Catenate     curl -k -H "Cross-Origin-Embedder-Policy: require-corp;
    ...                             report-to=\"default\"" -I https://${MPLANE_IPV4}
    ${output}=         Run          ${command}
    ${embedder}=       Convert to Lower Case    ${output}
    Should Contain     ${embedder}    ${embedder_policy}
    Log                Step 8: Verify Cross-Origin-Opener-Policy    console=True
    ${command}=        Catenate     curl -k -I -X GET https://${MPLANE_IPV4} -H 'Origin: https://attacker.com'
    ...                             -H 'Cross-Origin-Opener-Policy: same-origin'
    ${output}=         Run          ${command}
    ${resource}=       Convert to Lower Case    ${output}
    Should Contain     ${resource}    ${opener_policy}
    Log                Step 9: Verify Cross-Origin-Resource-Policy    console=True
    ${output}=         Run          curl -k -I -X GET https://${MPLANE_IPV4} /resource.js -H 'Origin: https://attacker.com'
    ${resource}=       Convert to Lower Case    ${output}
    Should Contain     ${resource}    ${resource_policy}
    Log                Step 10: Verify Referrer-Policy using command with malformed referer    console=True
    FOR    ${i}    IN RANGE    1000
        ${output}=        Run    curl -H "Referer: invalid_url" -I -k https://${MPLANE_IPV4}
        ${cross}=         Convert to Lower Case    ${output}
        Should Contain    ${cross}    ${cross_policy}
    END
    Check if BTS status is Configured or OnAir
    Log                Step 11: Verify Referrer-Policy using command without referer    console=True
    FOR    ${i}    IN RANGE    1000
        ${output}=        Run    curl -I -k https://${MPLANE_IPV4}
        ${cross}=         Convert to Lower Case    ${output}
        Should Contain    ${cross}    ${cross_policy}
    END
    Check if BTS status is Configured or OnAir
    Log                Step 12: Verify X-Permitted-Cross-Domain-Policies using invalid X-Correlation    console=True
    FOR    ${i}    IN RANGE    1000
        ${output}=         Run    curl -k -H "X-Correlation-ID: invalid_id" https://${MPLANE_IPV4} -I
        ${perm}=           Convert to Lower Case    ${output}
        Should Contain     ${perm}    ${perm_policy}
    END
    Check if BTS status is Configured or OnAir
    Log                Step 13: Verify X-Permitted-Cross-Domain-Policies using invalid User-Agent    console=True
    FOR    ${i}    IN RANGE    1000
        ${output}=         Run    curl -k -H "User-Agent: InvalidUserAgent" https://${MPLANE_IPV4} -I
        ${perm}=           Convert to Lower Case    ${output}
        Should Contain     ${perm}    ${perm_policy}
    END
    Check if BTS status is Configured or OnAir
    Log                Step 14: Verify Cross-Origin-Embedder-Policy using invalid Cross-Origin    console=True
    FOR    ${i}    IN RANGE    1000
        ${output}=         Run    curl -k -H "Cross-Origin-Embedder-Policy: invalid_policy" -I https://${MPLANE_IPV4}
        ${embedder}=       Convert to Lower Case    ${output}
        Should Contain     ${embedder}    ${embedder_policy}
    END
    Check if BTS status is Configured or OnAir
    Log                Step 15: Verify Cross-Origin-Opener-Policy using invalid Origin    console=True
    ${command}=        Catenate     curl -k -I -X GET https://${MPLANE_IPV4} -H 'Origin: invalid-origin'
    ...                             -H 'Cross-Origin-Opener-Policy: same-origin'
    FOR    ${i}    IN RANGE    1000
        ${output}=         Run          ${command}
        ${resource}=       Convert to Lower Case    ${output}
        Should Contain     ${resource}    ${opener_policy}
    END
    Check if BTS status is Configured or OnAir
    Log                Step 16: Verify Cross-Origin-Resource-Policy using invalid resource path    console=True
    ${command}=        Catenate     curl -k -I -X GET https://${MPLANE_IPV4} /invalid-bad-resource.js
    ...                             -H 'Origin: https://attacker.com'
    FOR    ${i}    IN RANGE    1000
        ${output}=         Run          ${command}
        ${resource}=       Convert to Lower Case    ${output}
        Should Contain     ${resource}    ${resource_policy}
    END
    Check if BTS status is Configured or OnAir

More_Restrictive_Permission_Settings_in_BTS_internal_file_system
    Log    Step 0: Log in as toor4nsn    console=true
    SSHLibrary.Open Connection                              host=${LMP_IP}
    SSHLibrary.Login         username=${SSH_USERNAME}      password=${SSH_PASSWORD}
    Log    Step 1: Check file permissions for /etc/shadow   console=true
    ${output}=               SSHLibrary.Execute Command     ls -l /etc/shadow
    Should Contain           ${output}                      ----------
    Log    Step 2: Check if passwords are hashed with SHA512   console=true
    ${output}=               SSHLibrary.Execute Command     grep -r pam_unix.so /etc/pam.d/
    ${output_lines}          Split String    ${output}    \n
    @{password_lines}    Create List
    FOR    ${i}    IN    @{output_lines}
        ${if_contains_password}    Run Keyword And Return Status    Should Contain    ${i}    :password
        IF    ${if_contains_password}
            Append to List    ${password_lines}    ${i}
        END
    END
    FOR    ${i}    IN    @{password_lines}
        Should Contain    ${i}    shadow sha512
    END
    Log    Step 3: Relog as serviceuser and check file permissions for /etc/shadow   console=true
    SSHLibrary.Close Connection
    SSHLibrary.Open Connection                              host=${LMP_IP}
    SSHLibrary.Login         username=${service_username}   password=${service_password}
    ${output}=               SSHLibrary.Execute Command     whoami
    Should Contain           ${output}                      serviceuser
    SSHLibrary.Write         cat /etc/shadow
    SSHLibrary.Read Until    Permission denied
    Log    Step 4: Check if reloging as toor4nsn works
    SSHLibrary.Login         username=${SSH_USERNAME}      password=${SSH_PASSWORD}
    ${output}=               SSHLibrary.Execute Command     whoami
    Should Contain           ${output}                      root
    [Teardown]    SSHLibrary.Close Connection
