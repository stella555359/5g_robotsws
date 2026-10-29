def get_load_id(my_af):
    config = {
        'AirFrameVirtualized': 'qcow',
        'AirScale': 'zip'
    }

    for pkg, ext in config.items():
        if pkg in my_af:
            return my_af.split("{}-".format(pkg))[1].split(".{}".format(ext))[0]

    if 'SBTS' in my_af:
        return my_af.split('/')[-1].split('.zip')[0]

    print(('Could not extract module version from path: {}.'.format(my_af)))
    return False
