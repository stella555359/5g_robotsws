#!/usr/bin/env python3
from ta_emss import ta_emss
import time

if __name__ == "__main__":
    emss1 = ta_emss()
    emss1.setup_emss(bts_id=1, bts_ip="10.84.190.78")
    mrbts_id = emss1.get_object_id('MRBTS')
    nrbts_id = emss1.get_object_id('NRBTS')  #
    emss2 = ta_emss()

    # # --- SETUP XTERM PARAMS ---
    print("Setting up...")
    emss1.xterm_setup(
        # --- XNAP PARAMS ---
        bts_xnap_ip_addr="172.16.4.1",
        gnbsim_ip_addr_begin="172.16.5.1",
        gnbsim_ip_addr_end="172.16.5.128",
        gnbsim_ip_addr_mask=16,
        gnbsim_eth_if="eth3",
        init_gnb_gnb_id=6003,
        init_gnb_mcc="311",
        init_gnb_mnc="489",
        # --- IPSEC PARAMS ---
        # bts_oam_ip_addr="10.84.190.78",
        ipsec_xn=True,
        ipsec_policy_order_num_begin=2,
        # --- NGAP PARAMS ---
        amf_ip_addr="172.16.4.2",
        amf_mcc="001",
        amf_mnc="01",
        amf_eth_if="eth3",
        amf_ip_addr_mask="16",
        amf_pointer=1,
        amf_set_id=1,
        # --- XTERM OPTIONS ---
        verbose=True,
        debug=True
    )

    print("Setting up...")
    emss2.xterm_setup(
        # --- XNAP PARAMS ---
        bts_xnap_ip_addr="172.16.4.1",
        gnbsim_ip_addr_begin="172.16.6.1",
        gnbsim_ip_addr_end="172.16.6.128",
        gnbsim_ip_addr_mask=16,
        gnbsim_eth_if="eth3",
        init_gnb_gnb_id=6131,
        init_gnb_mcc="311",
        init_gnb_mnc="489",
        # --- XTERM OPTIONS ---
        verbose=True,
        debug=True
    )
    #
    # # --- CONFIGURE AMF MOCS ---
    # amf_params = emss1.xterm_get("AMF")
    # emss1.configure_bts({'MOC': 'SERVEDAMF', 'ID': amf_params['AMF_SET_ID'],
    #                      'amfIPAddress': amf_params['AMF_IP_ADDR']},
    #                     skip_np=False)
    # time.sleep(5)
    #
    # # --- START NGAP SIMULATION ---
    print("Starting NGAP...")
    emss1.xterm_start(ngap=True)
    time.sleep(5)

    configure_mocs_command = []
    for gnb in emss1.xterm_get("gnbs"):
        if gnb['IP_ADDR'].split('.')[-2] == '6':
            moc_id = str(int(gnb['IP_ADDR'].split('.')[-1]) + 128)
        else:
            moc_id = gnb['IP_ADDR'].split('.')[-1]
        configure_mocs_command.append({'MOC': 'XNLINK', 'ID': moc_id, 'cPlaneIpAddr': gnb['IP_ADDR']})
        configure_mocs_command.append(
            {'MOC': 'NRADJGNB', 'ID': moc_id, 'gNodeBId': str(gnb['GNB_ID']), "administrativeState": "Unlocked",
             'gnbPlmn': [{"mcc": gnb['MCC'], "mnc": gnb['MNC'], "mncLength": str(len(gnb['MNC']))}]})
    # emss1.configure_bts(configure_mocs_command)
    print("Sleeping")
    time.sleep(15)

    # --- START XNAP SIMULATION ---
    print("Starting...")
    emss1.xterm_start(xnap=True)

    print("SLEEP")
    time.sleep(200)  # zamienic na ficzer sprawdzaj?cy stan xn
    print("SLEEP END")

    print("CONFIGURE IPSEC")
    # --- ADD IPSEC CONFIG ---
    xnc_vcu_ip_addr = emss1.xterm_get("all")['BTS_XNAP_IP_ADDR']
    policy_order_number = emss1.xterm_get("all")['IPSEC_POLICY_ORDER_NUM_BEGIN']

    configure_ipsec_mocs_command = []

    configure_ipsec_mocs_command.append({'MOC': 'IPAPP', 'ID': '1-2-1'})
    configure_ipsec_mocs_command.append({'MOC': 'IPSECC', 'ID': '1-2-1-1',
                                         'authenticationScheme': 'PSK',
                                         'ipSecEnabled': 'true'})
    configure_ipsec_mocs_command.append({'MOC': 'IPSECP', 'ID': '1-2-1-1-1',
                                         'antiReplayWindowSize': 'SIZE_128',
                                         })

    for moc_id, gnb in enumerate(emss1.xterm_get("gnbs"), start=1):
        configure_ipsec_mocs_command.append({
            'MOC': 'IKEP', 'ID': f'1-2-1-1-{moc_id}',
            'localTunnelEndpointDN': f'MRBTS-{mrbts_id}/TNLSVC-1/TNL-2/IPNO-1/IPIF-3/IPADDRESSV4-1',
            'remoteTunnelEndpoint': gnb['IP_ADDR']
        })
        configure_ipsec_mocs_command.append({
            'MOC': 'SECPOL', 'ID': f'1-2-1-1-{moc_id}',
            'ikePDN': f'MRBTS-{mrbts_id}/TNLSVC-1/TNL-2/IPAPP-1/IPSECC-1/IKEP-{moc_id}',
            'ipSecPDN': f'MRBTS-{mrbts_id}/TNLSVC-1/TNL-2/IPAPP-1/IPSECC-1/IPSECP-1',
            'policyOrderNumber': policy_order_number,
            'trafficSelectorList': [{'localIpAddress': xnc_vcu_ip_addr,
                                     'localIpPrefixLength': '32',
                                     'remoteIpAddress': gnb['IP_ADDR'],
                                     'remoteIpPrefixLength': '32'
                                     }]
        })
        policy_order_number += 1
    emss1.configure_bts(configure_ipsec_mocs_command, skip_np=False)
    time.sleep(5)

    # --- BREAK SIMULATION ---
    while (k := input("Press 'q' to stop...")) != 'q':
        pass
    #
    # # --- DELETE PREVIOUSLY ADDED MOCS ---
    # print("Deleting previously added SERVEDAMF MOC")
    # emss1.configure_bts({'DEL': 'SERVEDAMF', 'ID': amf_params['AMF_SET_ID']})
    #
    print("Deleting previously added XNLINK and NRADJGNB mocs")
    print("DELETE IPSEC MOCS")
    delete_moc_command = []
    delete_moc_command.append({'DEL': 'IPAPP', 'ID': '1-2-1'})

    for i in range(1, 257):
        delete_moc_command.append({'DEL': 'XNLINK', 'ID': str(i)})
        delete_moc_command.append({'DEL': 'NRADJGNB', 'ID': str(i)})
    emss1.configure_bts(delete_moc_command)

    # --- STOP XTERM ---
    print("Stopping xterm")
    emss1.xterm_teardown()
    # emss2.xterm_teardown()
