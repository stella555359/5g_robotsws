import mace
import sys
import time

mode = str(sys.argv[1])
i = 1


def change_ue_mode_sa(mode):
    """ 7_16_UTE5TCLOUDT410:
        MTK M70 - COM47
        MTK M80 - COM40"""
    global i
    try:
        device = mace.connect_device(connection_config="portname:COM47", database="portname:COM47")
        if mode == 'SA':
            device.send_at_command("AT+ERAT=15")
            time.sleep(3)
            device.send_at_command("AT+E5GOPT=3")
        elif mode == "NSA":
            device.send_at_command("AT+ERAT=19")
            time.sleep(3)
            device.send_at_command("AT+E5GOPT=5")
        print("UE mode chaneged successfully to: ", mode)
    except Exception as e:
        print("Failed. Attempt: ", i)
        if i <= 2:
            i += 1
            change_ue_mode_sa(mode)
        else:
            raise Exception('Unable to change UE mode!: ', e)


change_ue_mode_sa(mode)
