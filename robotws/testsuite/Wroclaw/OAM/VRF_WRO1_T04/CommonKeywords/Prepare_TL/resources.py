def proper_scf_mapping(bts_id):
    mrbtsID = {
        "50352": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL52.xml",
        "50913": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL55.xml",
        "50300": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL56.xml",
        "50301": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL57.xml",
        "50302": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL58.xml",
        "50303": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL59.xml",
        "50320": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL60.xml",
        "50304": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL145.xml",
        "50305": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL146.xml",
        "50306": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL147.xml",
        "50307": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL148.xml",
        "50308": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL149.xml",
        "50309": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL150.xml",
        "50319": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL192.xml",
        "50321": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL190.xml",
        "50326": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL191.xml",
        "50322": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL193.xml",
        "50323": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL194.xml",
        "50324": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL195.xml",
        "50325": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL196.xml",
        "50327": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL601.xml",
        "50328": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL602.xml",
        "50329": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL603.xml",
        "50331": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL606.xml",
        "50333": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL608.xml",
        "50334": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL609.xml",
        "50335": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL611.xml",
        "50336": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL612.xml",
        "50337": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL613.xml",
        "50345": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL614.xml",
        "50340": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL610.xml",
        "50903": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL635.xml",
        "51153": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL637.xml",
        "50910": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL639.xml",
        "51151": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL641.xml",
        "50909": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL642.xml",
        "50911": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL643.xml",
        "51900": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL648.xml",
        "50930": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL603.xml",
        "50928": "testsuite/Wroclaw/OAM/cOAM1/scfs/TL662.xml"
    }

    try:
        scf_path = mrbtsID[bts_id]
    except KeyError:
        raise AssertionError("No SCF file found")
    else:
        return scf_path
