*** Settings ***
Documentation
...   Max tput tests

Resource   max_tput_keywords.robot


*** Variables ***

${bts_id}          50078
${nrbts_id}        50078


*** Keywords ***
### tests ###
# udp scg
Bi_directional_21B_noDss_Nsa_TputNsaScgUDP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=udp     split_or_scg=scg    sektor_number=1


Bi_directional_21B_noDss_Nsa_TputNsaScgUDP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=udp     split_or_scg=scg    sektor_number=2


Bi_directional_21B_noDss_Nsa_TputNsaScgUDP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=udp     split_or_scg=scg    sektor_number=3


# udp split
Bi_directional_21B_noDss_Nsa_TputNsaSplitUDP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=udp     split_or_scg=split    sektor_number=1


Bi_directional_21B_noDss_Nsa_TputNsaSplitUDP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=udp     split_or_scg=split    sektor_number=2


Bi_directional_21B_noDss_Nsa_TputNsaSplitUDP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=udp     split_or_scg=split    sektor_number=3


# tcp scg
Bi_directional_21B_noDss_Nsa_TputNsaScgTCP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=tcp     split_or_scg=scg    sektor_number=1


Bi_directional_21B_noDss_Nsa_TputNsaScgTCP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=tcp     split_or_scg=scg    sektor_number=2


Bi_directional_21B_noDss_Nsa_TputNsaScgTCP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=tcp     split_or_scg=scg    sektor_number=3


# tcp split
Bi_directional_21B_noDss_Nsa_TputNsaSplitTCP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=tcp     split_or_scg=split    sektor_number=1


Bi_directional_21B_noDss_Nsa_TputNsaSplitTCP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=tcp     split_or_scg=split    sektor_number=2


Bi_directional_21B_noDss_Nsa_TputNsaSplitTCP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    max tput core test    protocol=tcp     split_or_scg=split    sektor_number=3


### keywords ###
max tput core test
    [Arguments]    ${protocol}    ${split_or_scg}    ${sektor_number}
    # protocol 'udp' or 'tcp'
    # split_or_scg 'scg' or 'split'
    # sektor_number cell number to use
    Run Keyword If   '${split_or_scg}' == 'split'
    ...              set tput mode to split    ${protocol}    ${sektor_number}
    Run Keyword If   '${split_or_scg}' == 'scg'
    ...              set tput mode to 5g       ${protocol}    ${sektor_number}
    [Teardown]         run keywords
    ...                unlock three cells    ${bts_id}    ${nrbts_id}    AND
    ...                Verify gNB is onAir
