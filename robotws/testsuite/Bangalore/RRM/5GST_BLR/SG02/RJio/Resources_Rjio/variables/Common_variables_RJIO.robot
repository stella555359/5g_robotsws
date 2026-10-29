*** Settings ***
Documentation   Author: Arunkumar A
...    Contact: arunkumar.a@nokia.com
...    robot file contains All common variables which can used for RJIO Testing.

*** Variables ***
@{all_ports}
${attenuator_device}                 _attenuator1  
${Attenuator_ip_addr}                10.45.153.215
${Attenuator_com_port}               3001
@{Attenuation_port_numbers}          1  2  3  4  5  6  7
${Attenuator_vendor}                 TopYoung
${Attenuator_model}                  TAS16T16-51-120-1N-DEJS
&{UEaliasandCapabilitiesdict_465}=   _android1=REAL_UE 

