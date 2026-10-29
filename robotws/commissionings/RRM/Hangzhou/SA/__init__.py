__maintainer__ = 'Hongyan Yuan'
__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'
__owner_email__ = 'hongyan.1.yuan@nokia-sbell.com'


# SCF parameters to delete, such as managed objects, lists in MO, and elements in MO or list.
# Edit it to suit your TL specific configuration.
_delete_MOs = [
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1/CACERT-1'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1/NECERT-1')
]

_delete_lists_from_MO = [
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngCplane'),  # PR429191
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngUplane')   # PR429191
]

_delete_elements = [
    # dict(dist_name='xxx', list_name='xxx', p_name='xxx' )
    # dict(dist_name='xxx', p_name='xxx' )
]

PARAMS_TO_DELETE_FOR_FEATURE = [
    _delete_MOs,
    _delete_lists_from_MO,
    _delete_elements
]

# SCF parameters to delete, such as MOs, elements, lists, items of list, and elements of list.
# Edit it to suit your TL specific configuration.

_add_MOs = [
    dict(class_name='com.nokia.srbts.nrbts:SNSSAI', dist_name='MRBTS-1900/NRBTS-1/SNSSAI-1',
         version='NRBTS5G19A_1903_010')
]

_add_elements_to_MO = [
    dict(value='128', dist_name='MRBTS-1900/NRBTS-1/SNSSAI-1', p_name='sd'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/SNSSAI-1', p_name='sst')
]

_add_lists_to_MO = [
    dict(dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1', list_name='snssaiDNList'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngCplane'),  # PR429191
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngUplane')   # PR429191
]

_add_items_to_list = [
    # dict(dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', list_name='guAMI',
    #      elements=dict(amfPointer='1', amfRegionID='1', amfSetID='1', mcc='460', mnc='30') )  # set by system
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngCplane',
         elements=dict(ipV4AddressDN1='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2')),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngUplane',
         elements=dict(ipV4AddressDN1='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4'))
]

_add_elements_to_list = [
    dict(dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1', list_name='snssaiDNList',
         elements=['MRBTS-1900/NRBTS-1/SNSSAI-1']),
]

PARAMS_TO_ADD_FOR_FEATURE = [
    _add_MOs,
    _add_elements_to_MO,
    _add_lists_to_MO,
    _add_items_to_list,
    _add_elements_to_list
]

# SCF parameters to modify, such as elements. Edit it to suit your TL specific configuration.
_modify_MO_attributes = [

]

_modify_elements = [

]

PARAMS_TO_MODIFY_FOR_FEATURE = [
    _modify_MO_attributes,
    _modify_elements
]
