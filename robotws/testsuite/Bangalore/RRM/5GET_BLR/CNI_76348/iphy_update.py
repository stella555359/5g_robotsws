import os

iphy_paswd = "oZPS0POrRieRtu"
iphy_ip = "192.168.200.1"
iphy_username = "toor4nsn"
iphy_name = "/home/ute/iphy_AEQK.xml"
iphy_name1 = "iphy_AEQK.xml"


def update_iphy():
    cmd = "sshpass -p " + iphy_paswd + " ssh " + iphy_username + "@" \
        + iphy_ip + " ls -lrt /ffs/run/simmode/*"
    os.system(cmd)
    cmd = "sshpass -p " + iphy_paswd + " ssh " + iphy_username + "@" \
        + iphy_ip + \
        " cp  /ffs/run/simmode/iphy.xml /ffs/run/simmode/iphy_default.xml"
    os.system(cmd)
    cmd = "sshpass -p " + iphy_paswd + " scp " + iphy_username + "@" \
        + iphy_ip + ":/ffs/run/simmode/iphy.xml " \
        + iphy_name
    os.system(cmd)
    cmd = "sed -i 's/AEQP/AEQK/g' " + iphy_name
    os.system(cmd)
    cmd = r"sed -i 's/<GSCN>7842<\/GSCN>/<GSCN>8019<\/GSCN>/g' " + iphy_name
    os.system(cmd)
    cmd = r"sed -i 's/<GSCN>7841<\/GSCN>/<GSCN>8020<\/GSCN>/g' " + iphy_name
    os.system(cmd)
    cmd = r"sed -i 's/<productCode>475238A<\/productCode>/" + \
          r"<productCode>475589A<\/productCode>/g' " + iphy_name
    os.system(cmd)
    cmd = "sshpass -p " + iphy_paswd + " scp  " + iphy_name + " " \
        + iphy_username + "@" + iphy_ip + ":/ffs/run/simmode/"
    os.system(cmd)
    cmd = "sshpass -p " + iphy_paswd + " ssh " + iphy_username \
        + "@" + iphy_ip + " rm -rf /ffs/run/simmode/iphy.xml"
    os.system(cmd)
    cmd = "sshpass -p " + iphy_paswd + " ssh " + iphy_username \
        + "@" + iphy_ip + " ln -s /ffs/run/simmode/" + \
        iphy_name1 + " /ffs/run/simmode/iphy.xml"
    print("cmd ==>", cmd)
    os.system(cmd)

# if __name__ == "__main__":
#    update_iphy()
