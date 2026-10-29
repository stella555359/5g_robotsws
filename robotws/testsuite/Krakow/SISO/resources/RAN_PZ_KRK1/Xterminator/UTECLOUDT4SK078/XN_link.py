#!/usr/bin/env python3
from ta_emss import ta_emss
import time

if __name__ == "__main__":
    emss1 = ta_emss()
    emss1.setup_emss(bts_id=1, bts_ip="10.84.190.78")
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
    emss1.configure_bts(configure_mocs_command)
    print("Sleeping")
    time.sleep(15)

    # --- START XNAP SIMULATION ---
    print("Starting...")
    emss1.xterm_start(xnap=True)
    time.sleep(5)
    # emss2.xterm_start(xnap=True)
    print("After start XNAP")

    #
    # --- BREAK SIMULATION ---
    while (k := input("Press 'q' to stop...")) != 'q':
        pass
    #
    # # --- DELETE PREVIOUSLY ADDED MOCS ---
    # print("Deleting previously added SERVEDAMF MOC")
    # emss1.configure_bts({'DEL': 'SERVEDAMF', 'ID': amf_params['AMF_SET_ID']})
    #
    print("Deleting previously added XNLINK and NRADJGNB mocs")
    delete_moc_command = []
    for i in range(1, 257):
        delete_moc_command.append({'DEL': 'XNLINK', 'ID': str(i)})
        delete_moc_command.append({'DEL': 'NRADJGNB', 'ID': str(i)})
    emss1.configure_bts(delete_moc_command)

    # --- STOP XTERM ---
    print("Stopping xterm")
    emss1.xterm_teardown()
    # emss2.xterm_teardown()
