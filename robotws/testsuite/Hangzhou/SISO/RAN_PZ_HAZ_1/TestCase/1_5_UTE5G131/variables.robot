*** Variables ***
&{5G_CB007262_AEHC_3AHCA_MultiRat}=    HW_ID=CB007262    site_mode=MultiRat    ONAIR_TIME=15 min
...                                    peak_rate_config={"171":[200,10],"172":[200,10]}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${INIT_CONFIG_ID}    5G_CB007262_AEHC_3AHCA_MultiRat

${parameters}    [{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'PRACH configuration index',
...    'para_value':'89','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'Start RB',
...    'para_value':'4','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'Tilt Offset',
...    'para_value':'2','require_reset':False},{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-2','para_name':'Tilt Offset',
...    'para_value':'2','require_reset':False}]

${LCELNR1_DIST_NAME}    MRBTS-10628/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1

${objects_celltype_4DL4UL}    [{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2","operate":"delete"}]
${parameters_celltype_4DL4UL}    [{'dist_name':'MRBTS-10628/NRBTS-10628/NRCELL-1','para_name':'NR Cell type',
...    'para_value':'4DL4UL','require_reset':"rat_reset"}]

${objects_celltype_8DL4UL}    [{"object_name":"${LCELNR1_DIST_NAME}","object_class_name":"CHANNELGROUP",
...    "plan_to_copy_from":${None},"copy_from":${None},"include_subobject":${False},"id_value":"2",
...    "is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"1","is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"2","is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"3","is_load_default_values":False,"operate":"add"},{"object_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2",
...    "object_class_name":"CHANNEL", "plan_to_copy_from":${None},"copy_from":${None}, "include_subobject":${False},
...    "id_value":"4","is_load_default_values":False,"operate":"add"}]
${parameters_celltype_8DL4UL}    [{"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-1",
...    "para_name":"Direction of the channel", "para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-1",
...    "para_name":"Distinguished Name of resource","para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1",
...    "require_reset":"False"},{"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-2",
...    "para_name":"Direction of the channel","para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-2","para_name":"Distinguished Name of resource",
...    "para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-3",
...    "para_name":"Direction of the channel", "para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-3",
...    "para_name":"Distinguished Name of resource","para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1",
...    "require_reset":"False"},{"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-4",
...    "para_name":"Direction of the channel","para_value":"TX","require_reset":"False"},
...    {"dist_name":"${LCELNR1_DIST_NAME}/CHANNELGROUP-2/CHANNEL-4","para_name":"Distinguished Name of resource",
...    "para_value":"MRBTS-10628/EQM-1/APEQM-1/RMOD-1/PHYANT-1","require_reset":"False"},
...    {"dist_name":"MRBTS-10628/NRBTS-10628/NRCELL-1","para_name":"NR Cell type","para_value":"8DL4UL",
...    "require_reset":"False"}]

${GLO_SCOUT_TESTLINE_NAME}    1_5_UTE5G131_1

${GGMAP}    {"L1211508227":{"1": "3.4.1", "2": "3.4.2", "7": "3.4.7"}, "L1204101448":{"7":"3.4.8"},
...         "L1202005438": {"1": "3.4.5", "2": "3.4.6"}, "AS210918787":{"1":"3.4.3","2":"3.4.4"}}

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    No module fan detected    NgGnbInitPartialReset
