*** Variables ***
${mrbts_value}=       ${tl.gnbs[0].instance_id}
${sfp_connector}=     ${tl.gnbs[0].dus[0].cablinks[0].source.label}
${qsfp_connector}=    ${tl.gnbs[0].dus[0].cablinks[1].source.label}
${sfp2_connector}=    ${tl.gnbs[0].dus[0].cablinks[2].source.label}
${r_id}=              ${tl.r_id}
