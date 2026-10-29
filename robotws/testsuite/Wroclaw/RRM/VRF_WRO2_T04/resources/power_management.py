import argparse
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import eco_friendly_tl, switch_pdu_port
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl


def power_on_enbs(switch_state='on'):
    if tl.enbs:
        for enb in tl.enbs:
            for cu in enb.system_module.common_units:
                switch_pdu_port(pdu_port=cu.pdu_port, state=switch_state)
            if enb.rms:
                for ru in enb.rms:
                    switch_pdu_port(pdu_port=ru.pdu_port, state=switch_state)


def main(args):
    eco_friendly_tl(switch_state=args.action)
    power_on_enbs(switch_state=args.action)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Testline Power Management')
    parser.add_argument('--action', help='Power OFF all tl devices', choices=['on', 'off'],
                        required=True)
    args = parser.parse_args()
    main(args)
