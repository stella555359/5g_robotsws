# ##########################################################################################
#
#
#
#
#
#
# ##########################################################################################

__maintainer__ = 'Abderrahmane NEZROUK'
__team__ = 'MN 5G&SC Pz 5G I&V x NPS x SG'
__email__ = 'abderrahmane.nezrouk@nokia.com'

# Filters for local mirroring scripts use
# \x26 code ascii of speacial caracter & accepted by sed
filter_5G19B_1 = str(r'ether[0x18:2]\x3d\x3d0x0219')
filter_5G19B_2 = str(r'ether[0x18:2]\x21\x3d0xe101 \x26\x26 ether[0x18:2]\x21\x3d0x131 \x26\x26 ether['
                     r'0x18:2]\x21\x3d0x240 \x26\x26 ether[0x18:2]\x21\x3d0x127 \x26\x26 ether['
                     r'0x18:2]\x21\x3d0x12a \x26\x26 ether[0x18:2]\x21\x3d0x233 \x26\x26 ether['
                     r'0x18:2]\x21\x3d0x122 \x26\x26 ether[0x18:2]\x21\x3d0x12b')
filter_5G19B_3 = str(r'ether[0x18:2]\x21\x3d0xe101 \x26\x26 ether[0x18:2]\x21\x3d0x131 \x26\x26 ether['
                     r'0x18:2]\x21\x3d0x240 \x26\x26 ether[0x18:2]\x21\x3d0x127 \x26\x26 ether['
                     r'0x18:2]\x21\x3d0x12a \x26\x26 ether[0x18:2]\x21\x3d0x233 \x26\x26 ether['
                     r'0x18:2]\x21\x3d0x108')

# Filters for manual mirroring scripts use
bip_filter_5G19B_1 = str(r'ether[0x18:2]==0x0219')
bip_filter_5G19B_2 = str(r'ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x240 && ether[0x18:2'
                         r']!=0x127 && ether[0x18:2]!=0x12a && ether[0x18:2]!=0x233 && ether[0x18:2'
                         r']!=0x122 && ether[0x18:2]!=0x12b')
bip_filter_5G19B_3 = str(r'ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x240 && ether[0x18:2'
                         r']!=0x127 && ether[0x18:2]!=0x12a && ether[0x18:2]!=0x233 && ether[0x18:2]!=0x108')
bip_filter_5G19B_manual_4 = str(r'ether[0x18:2]==0x24e || ether[0x18:2]==0x24c || ether[0x18:2]==0x133')

###############################################################################

# FILTER message IDs
# By default, periodic control messages are filtered out
# https://gitlabe1.ext.net.nokia.com/high-five/3gpp-interfaces-5g-layer-1/-/wikis/5G-3GPP-Interface-Message-IDs
# Some common message IDs
# 5G19A
#   - PatternConfigReq 0x12b
#   - SlotTypeReq 0x122
#   - PrachReceiveReq 0x233
#   - CsiRsSendReq 0x12a
#   - SsBlocSendReq 0x127
#   - pdschPayloadTbSendReq 0x108
#   - puschReceiveRespLo 0x23a
#  Changes in 5G19B
#   - PrachReceiveReq 0x240
#   - CsiRsSendReq 0x131
#  Changes in 5G20A
#   - PatternConfigReq 0xe101
#
