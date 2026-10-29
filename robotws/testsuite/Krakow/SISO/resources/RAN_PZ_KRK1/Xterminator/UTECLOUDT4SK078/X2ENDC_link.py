#!/usr/bin/env python3
from ta_emss import ta_emss
import time

if __name__ == "__main__":
    emss1 = ta_emss()
    emss1.setup_emss(bts_id=1, bts_ip="10.84.190.78")

    # emss2 = ta_emss()

    # # --- SETUP XTERM PARAMS ---
    print("Setting xterminator up...")
    emss1.xterm_setup(
        # BTS section
        bts_ip_addr="10.84.190.78",
        bts_x2ap_ip_addr="172.16.4.1",
        # ENBsim local IP section
        enbsim_ip_addr_begin="172.16.7.0",
        enbsim_ip_addr_end="172.16.7.254",
        enbsim_ip_addr_mask=16,
        enbsim_eth_if="eth3",
        # mme_ip_addr="172.16.4.3",
        # mme_ip_addr_mask=16,
        # mme_eth_if="eth3",
        # mme_mcc="001",
        # mme_mnc="01",
        # mme_code=15,
        # mme_group_id=12,
        # ENBsim configuration
        init_enb_pci_max=503,
        init_enb_enb_id=1,
        init_enb_mcc="001",
        init_enb_mnc="01",
        init_enb_tac=1,
        init_enb_dl_earfcn=4900,
        init_enb_dl_bandwidth=10,
        # X2AP setup configuration
        x2ap_setup_period=15,
        x2ap_setup_retries=3,
        x2ap_reset_period=15,
        x2ap_reset_retries=3,
        # X2AP scenario configuration
        enb_configuration_update_min=60,
        enb_configuration_update_max=300,
        x2_reset_min=300,
        x2_reset_max=360,
        # General params
        verbose=True,
        debug=False
    )

    # --- START X2AP SIMULATION ---
    print("Starting X2ENDC simulation...")
    emss1.xterm_start(endcx2ap=True)

    # --- BREAK SIMULATION ---
    while (k := input("Press 'q' to stop...")) != 'q':
        pass

    print("Stopping Xterm")
    emss1.xterm_teardown()
