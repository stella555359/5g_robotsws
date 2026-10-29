*** Settings ***
Documentation
...     description:    Variables for test cases for the 5GC001049 feature.

*** Variables ***
${cPlaneIPv4_1}=    1.1.1.2
${cPlaneIPv4_2}=    1.1.1.1
${amfIPv4_1}=       10.94.232.6
${amfIPv4_2}=       2.1.1.2

${cPlaneIPv6_1}=    2a00:8a00:6000:607c::13
${cPlaneIPv6_2}=    2a00:8a00:6000:607c::14
${amfIPv6_1}=       2a00:8a00:6000:607c::23
${amfIPv6_2}=       2a00:8a00:6000:607c::24

${xnc_ipv4_1}=      ${tl.gnbs[0].cu.xnc.v4}
${xnc_ipv4_2}=      10.44.64.99
${xnc_ipv6_1}=      ${tl.gnbs[0].cu.xnc.v6}
${xnc_ipv6_2}=      2a00:8a00:6000:607c::5650

${xnu_ipv4_1}=      ${tl.gnbs[0].cu.xnu.v4}
${xnu_ipv4_2}=      10.44.64.135
${xnu_ipv6_1}=      ${tl.gnbs[0].cu.xnu.v6}
${xnu_ipv6_2}=      2a00:8a00:6000:607c::5750

${x2c_ipv4_1}=      ${tl.gnbs[0].cu.x2c.v4}
${x2c_ipv4_2}=      10.44.64.99
${x2c_ipv6_1}=      ${tl.gnbs[0].cu.x2c.v6}
${x2c_ipv6_2}=      2a00:8a00:6000:607c::5650

${x2u_ipv4_1}=      ${tl.gnbs[0].cu.x2u.v4}
${x2u_ipv4_2}=      10.44.64.135
${x2u_ipv6_1}=      ${tl.gnbs[0].cu.x2u.v6}
${x2u_ipv6_2}=      2a00:8a00:6000:607c::5750

${ngc_ipv4_1}=      ${tl.gnbs[0].cu.ngc.v4}
${ngc_ipv4_2}=      10.44.84.69
${ngc_ipv6_1}=      ${tl.gnbs[0].cu.ngc.v6}
${ngc_ipv6_2}=      2a00:8a00:6000:607c::1:6650

${ngu_ipv4_1}=      ${tl.gnbs[0].cu.ngu.v4}
${ngu_ipv4_2}=      10.44.64.199
${ngu_ipv6_1}=      ${tl.gnbs[0].cu.ngu.v6}
${ngu_ipv6_2}=      2a00:8a00:6000:607c::5850

${rem_xnu_ipv4_1}=    3.1.1.1
${rem_xnu_ipv4_2}=    3.1.1.2
${rem_xnu_ipv4_3}=    3.1.1.3
${rem_xnu_ipv4_4}=    3.1.1.4
${rem_xnu_ipv6_1}=    2a00:8a00:6000:607c::31
${rem_xnu_ipv6_2}=    2a00:8a00:6000:607c::32
${rem_xnu_ipv6_3}=    2a00:8a00:6000:607c::33
${rem_xnu_ipv6_4}=    2a00:8a00:6000:607c::34
