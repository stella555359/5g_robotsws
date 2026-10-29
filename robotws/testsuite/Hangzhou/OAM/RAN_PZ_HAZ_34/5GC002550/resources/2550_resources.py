def proper_scf_mapping(bts_id):
    mrbtsID = {
        "1976": "/home/ute/Projects/robotws5g/testsuite/OAM/Hangzhou/5GC002550/resources/SCF_Directory/TL1976.xml",
        "50352": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL52.xml",
        "50355": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL55.xml",
        "50300": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL56.xml",
        "50301": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL57.xml",
        "50302": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL58.xml",
        "50303": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL59.xml",
        "50320": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL60.xml",
        "50304": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL145.xml",
        "50305": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL146.xml",
        "50306": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL147.xml",
        "50307": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL148.xml",
        "50308": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL149.xml",
        "50309": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL150.xml",
        "50319": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL192.xml",
        "50321": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL190.xml",
        "50326": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL191.xml",
        "50322": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL193.xml",
        "50323": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL194.xml",
        "50324": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL195.xml",
        "50325": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL196.xml",
        "50327": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL601.xml",
        "50328": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL602.xml",
        "50329": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL603.xml",
        "50333": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL608.xml",
        "1998": "testsuite/OAM/Wroclaw/cOAM1/scfs/TL1998.xml"}

    try:
        scf_path = mrbtsID[bts_id]
    except KeyError:
        raise AssertionError("No SCF file found")
    else:
        return scf_path


def get_parameter_value(val_from_scf):
    return val_from_scf if isinstance(val_from_scf, int) else val_from_scf[0]
