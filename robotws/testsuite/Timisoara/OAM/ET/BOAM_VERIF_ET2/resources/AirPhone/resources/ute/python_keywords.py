def parse_sw_to_stream(sw_d):
    """
    Script takes parameter sw_version from coam.admin in format: '5G20B_GNB_0000_000800_000612'
    and parses it to stream number: '0.800'
    If it is a knife it looks like: '5G20B_GNB_0000_000800_000612_0ijup_' (Exceptions below are for knife builds)
    """
    try:
        build = '.'.join([str(int(s)) for s in sw_d.split('_')[-3:-1]])
    except ValueError:
        try:
            build = '.'.join([str(int(s)) for s in sw_d.split('_')[-5:-3]])
        except ValueError:
            build = '.'.join([str(int(s)) for s in sw_d.split('_')[-4:-2]])

    return build
