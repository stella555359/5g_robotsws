from robot.libraries.BuiltIn import BuiltIn


__maintainer__ = 'shifu.lan'
__team__ = 'I_NSB_MN_RAN_RD_VRF_HAZ4_04_GMS <I_NSB_MN_RAN_RD_VRF_HAZ4_04@internal.nsn.com>'
__email__ = 'shifu.lan@nokia-sbell.com'

tl = BuiltIn().get_variable_value("${tl}")
_gnb_id = str(tl.gnbs[0].instance_id)
_mrbts_name = 'MRBTS-'+_gnb_id
_nrbts_name = _mrbts_name+'/NRBTS-'+_gnb_id

counter_ids_rtp_avg_str = "M55369C00000,M55369C00001,M55369C00002,M55369C00003," +\
                          "M55369C00004,M55369C00005,M55369C00006,M55369C00007"
counter_ids_rtp_avg_list = [
    'M55369C00000', 'M55369C00001', 'M55369C00002', 'M55369C00003',
    'M55369C00004', 'M55369C00005', 'M55369C00006', 'M55369C00007'
]
