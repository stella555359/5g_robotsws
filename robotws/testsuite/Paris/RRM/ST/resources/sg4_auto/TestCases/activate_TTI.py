from taf.sbts.oam.coam.admin import admin


def activate_traces():
    coam = admin()
    coam.connect_to(bts_host='10.14.49.20', name='coam_admin')
    status = coam.get_debug_trace_streaming_status(connection='coam_admin')
    print(status['uplaneComponent'])
    if status['uplaneComponent'] == {}:
        nrcellsAllParam = coam.get_cell_list(connection='coam_admin')
        nrcells = sorted([x['id']['configuration'] for x in nrcellsAllParam['cells']['nr'] if
                         x['status']['operationalState'] == 'enabled'])
        print('Starting L1 trace on the following cells...')
        print(nrcells)
        coam.start_uplane_l2_trace(
            source_ip='10.14.49.20', dscp=15, destination_ip='10.14.39.217', destination_port=5678,
            nr_cell_dns=nrcells, up_sw='L2Ps', connection='coam_admin')
    else:
        print('L1 trace is already activated')

    coam.teardown(connection='coam_admin')


def main():
    activate_traces()


if __name__ == "__main__":
    main()
