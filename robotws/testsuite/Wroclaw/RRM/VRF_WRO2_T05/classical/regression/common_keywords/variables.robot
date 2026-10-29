*** Settings ***
Documentation
...   author: PZ_2_WRO_5


*** Variables ***


${common_path}               testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/
${labpcname}=                wro5grrm
${labpcpass}=                5gpass!1

${atten_ip}                  ${tl.attenuators[0].ip_addr}
${att_api_port}              ${tl.attenuators[0].port}
${atten_ports}               ${tl.attenuators[0].attenuator_ports}
${atten_model}               ${tl.attenuators[0].model}
${atten_vendor}              JFW
${max_attenuation_value}     ${90}

${success_num}               0

${RUDE_TWAMP_ALARM_ID}=         61610
${RUDE_ENGINE_IP}=           10.44.72.108
${RUDE_VM_IP}=               10.44.72.183
${RUDE_VM_USERNAME}=         wro5grrm
${RUDE_VM_PASSWORD}=         5gpass!1
${RUDE_EXEC_PATH}=           Rude

@{lines_gNB_157_AHCA_1}        5   6   7   8
@{lines_gNB_157_AHCA_2}        1   2   3   4
@{lines_gNB_157_AHCA_3}        9   10   11   12
@{lines_LTE_157}               13    14

@{lines_gNB_159_AHCA_1}        13   14   15   16
@{lines_gNB_159_AHCA_2}        17   18
@{lines_gNB_159_AHCA_3}        19   20
@{lines_LTE_159}               23    24

@{lines_gNB_154_AHLOA_1}        9   10   11   12
@{lines_gNB_154_AHLOA_2}        1   2   3   4
@{lines_gNB_154_AHLOA_3}        5   6   7   8
@{lines_LTE_156}                23    24

@{lines_gNB_153_AHLOA_1}        3  4
@{lines_gNB_153_AHLOA_2}        1   2
@{lines_gNB_153_AHLOA_3}        7   8
@{lines_LTE_155}                5    6

@{lines_gNB_186_AHLOA_1}        1   2   3   4    #AHLOA PCI:60
@{lines_gNB_186_AHLOA_2}        5   6            #AHLOA PCI:61
@{lines_gNB_186_AHLOA_3}        7   8            #AHLOA PCI:62
@{lines_gNB_186_AEHC_1}         9   10  11  12   #AHLOA PCI:62
@{lines_LTE_187}                13    14         #FRIJ PCI:163

@{lines_gNB_184_AHLOA_1}        3    4            #AHLOA PCI:258
@{lines_gNB_184_AHLOA_2}        1    2            #AHLOA PCI:158
@{lines_gNB_184_AHLOA_3}        7    8            #AHLOA PCI:358
@{lines_LTE_185}                11    12           #FRIJ PCI:153


#7_16_UTE5GCLOUDT190
@{lines_gNB_190_AHLOA_1_FDD}        1   2   3   4      #AHLOA-2  PCI:101 att3
@{lines_gNB_190_AHLOA_2_FDD}        5   6   7   8      #AHLOA-3  PCI:102 att_3
@{lines_gNB_190_AHLOA_3_FDD}        9   10  11  12     #AHLOA-1  PCI:103 att_3
@{lines_gNB_190_AHLOA_11_FDD}       13  14  15  16     #AHLOA-11 PCI:100 att_3
@{lines_gNB_190_AHFIB_7_FDD}        17  18  19  20     #AHFIB-7  PCI:107 att_3
@{lines_gNB_190_AHFIB_8_FDD}        21  22  23  24     #AHFIB-8  PCI:108 att_3

@{lines_gNB_190_AHFIB_9_FDD}        1   2   3   4      #AHFIB-9  PCI:109 att_4
@{lines_gNB_190_AHFIB_10_FDD}       5   6   7   8      #AHFIB-10 PCI:110 att_4
@{lines_gNB_190_AEHC_4_TDD}         9   10  11  12     #AEHC-4   PCI:104 att_4
@{lines_gNB_190_AEHC_5_TDD}         13  14  15  16     #AEHC-5   PCI:105 att_4
@{lines_gNB_190_AEHC_6_TDD}         17  18  19  20     #AEHC-6   PCI:106 att_4


#7_16_UTE5GCLOUD310
#Att 1
@{lines_gNB_310_AHLOB_1_FDD_n71}            1   2   3   4      #PCI: NR: 100, 11, LTE: 101
@{lines_gNB_310_AHLOB_2_FDD_n71}            5   6   7   8      #PCI: NR: 101, 201, LTE: 12, 102
@{lines_gNB_310_AHLOB_3_FDD_n71}            9   10  11  12     #PCI: NR: 102, 202, LTE: 13, 103
@{lines_gNB_310_AVHA_1_TDD_n41}             13  14  15  16     #PCI: NR: 108, 208, 308
@{lines_gNB_310_AVHA_2_TDD_n41}             17  18  19  20     #PCI: NR: 109, 209, 309
@{lines_gNB_310_AVHA_3_TDD_n41}             21  22  23  24     #PCI: NR: 110, 210, 310

#Att 2
@{lines_gNB_310_AHFII_1_FDD_n25_n66}        1   2   3   4      #PCI: NR: 104, 114, LTE: 204, 214, 224
@{lines_gNB_310_AHFII_2_FDD_n25_n66}        5   6   7   8      #PCI: NR: 105, 115, LTE: 205, 215, 225
@{lines_gNB_310_AHFII_3_FDD_n25_n66}        9   10  11  12     #PCI: NR: 106, 116, LTE: 206, 216, 226
@{lines_gNB_310_AVQQA_1_TDD_n77}            13  14  15  16     #PCI: NR: 1001
@{lines_gNB_310_AVQQA_2_TDD_n77}            17  18  19  20     #PCI: NR: 1002
@{lines_gNB_310_AVQQA_3_TDD_n77}            21  22  23  24     #PCI: NR: 1003


# 7_16_UTE5GCLOUD410
@{lines_gNB_154_AEHC_4_TDD_HO}      7   8              #AEHC_HO  PCI:6 Att1
@{lines_gNB_410_AHLOA_1_FDD}        5   6              #AHLOA PCI:304 Att1
@{lines_gNB_410_AHLOA_2_FDD}        1   2   3   4      #AHLOA PCI:110 Att1
@{lines_gNB_410_AHLOA_3_FDD}        1   2   7   8      #AHLOA PCI:285 Att2

@{lines_gNB_410_AEHC_4_TDD}        17  18  19  20     #AEHC PCI:301-311   Att1
@{lines_gNB_410_AEHC_5_TDD}        21  22  23  24     #AEHC PCI:302-312   Att1
@{lines_gNB_410_AEHC_6_TDD}         5   6  11  12     #AEHC PCI:303-313   Att2

@{lines_gNB_410_AHFIB_7_FDD}       13  14  15  16     #AHLOA PCI:16-145 Att1
@{lines_gNB_410_AHFIB_8_FDD}        9  10  11  12     #AHFIB PCI:74-428 Att1
@{lines_gNB_410_AHFIB_9_FDD}        3   4   9  10     #AHFIB PCI:21-834 Att2

@{lines_gNB_205_AHFIB_1}             5   6   7   8

@{lines_gNB_210_AZQS_1_FDD}               1  2  3  4        # AZQS PCI 1
@{lines_gNB_210_AZQS_2_FDD}               5  6  7  8        # AZQS PCI 2
@{lines_gNB_210_AZQS_1_FDD_25R1}          3  4  7  8       # AZQS PCI 1
@{lines_gNB_210_AZQS_2_FDD_25R1}          1  2  5  6       # AZQS PCI 2

@{lines_gNB_210_AHEC_1_LTE}               9  10  11  12       # AHEC LTE PCI 4
@{lines_gNB_210_AZQS_1_FDD_port_3}        3
@{lines_gNB_210_AZQS_1_FDD_port_4}        4
@{lines_gNB_210_AZQS_1_FDD_port_7_8}      7  8

@{lines_gNB_215_AHLOA_8}              1   2   3   4   # AHLOA 800
@{lines_gNB_215_AHFIB_1}              5   6   7   8   # AHFIB 100/110
@{lines_gNB_215_AVHA_4}               9  10  11  12   # AVHA  400/410
@{lines_gNB_215_AHFIB_2}             13  14  15  16   # AHFIB 200/215
@{lines_gNB_215_AHLOA_7}             17  18  19  20   # AHLOA 700
# @{lines_gNB_215_AEHC_1}              21  22  23  24   # AEHC  500/510
@{lines_gNB_215_AHSA}                 21  22  #AHSA
@{lines_gNB_215_AHEGC}                23  24  #AHEGC
