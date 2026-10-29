*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

*** Keywords ***
Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Present For UE${ue:\d+}
    Verify In Message That Field Is Present
    ...    procedure=${message}   device=UE_${ue}   protocol=NR-RRC    message=${message}
    ...    n=${n}    all=${all}    field=${field}

Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Not Present For UE${ue:\d+}
    Verify In Message That Field Is Not Present
    ...    procedure=${message}   device=UE_${ue}   protocol=NR-RRC    message=${message}
    ...    n=${n}    all=${all}    field=${field}

Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} Set To ${value:\S+} For UE${ue:\d+}
   Verify In Message That Field_1 Is Present And Has Field_2 Set To Specific Value
    ...    procedure=${message}    device=UE_${ue}   protocol=NR-RRC    message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    value=${value}

Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That List ${list:\S+} Has ${x:\d+} Element/s For UE${ue:\d+}
    Verify Length Of List In Message
    ...    procedure=${message}    device=UE_${ue}   protocol=NR-RRC    message=${message}
    ...    n=${n}    all=${all}    list=${list}    length=${x}

Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} For UE${ue:\d+}
    Verify In Message That Field_1 Is Present And Has Field_2
    ...    procedure=${message}    device=UE_${ue}   protocol=NR-RRC    message=${message}
    ...    n=${n}    all=${all}   field_1=${field_1}    field_2=${field_2}

Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That ${field_1:\S+} Contains ${field_2:\S+} And ${field_3:\S+} For UE${ue:\d+}
   Verify In Message That Field_1 Is Present And Contains Field_2 And Field_3
    ...    procedure=${message}    device=UE_${ue}    protocol=NR-RRC     message=${message}
    ...    n=${n}    all=${all}    field_1=${field_1}    field_2=${field_2}    field_3=${field_3}

Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That ${field:\S+} Has ${value:\S+} For UE${ue:\d+}
   Verify That Field In Message Has Value
   ...    procedure=${message}    device=UE_${ue}    protocol=NR-RRC     message=${message}
   ...    n=${n}    all=${all}    field=${field}    value=${value}

Verify In RRC ${message}_${n:\d+} Out Of ${all:\d+} That ${field} Is Set To ${value:\S+} For UE${ue:\d+}
   Verify That Field In Message Is Set To Specific Value
    ...    procedure=${message}    device=UE_${ue}    protocol=NR-RRC    message=${message}
    ...    n=${n}    all=${all}    field=${field}    value=${value}
