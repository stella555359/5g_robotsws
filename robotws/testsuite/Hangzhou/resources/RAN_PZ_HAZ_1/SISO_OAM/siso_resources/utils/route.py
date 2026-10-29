import os


def add_route(target_ip, gw_ip):
    cmd = "sudo  route del -host %s gw %s" % (target_ip, gw_ip)
    print(cmd)
    os.system(cmd)
    cmd = "sudo route add -host %s gw %s" % (target_ip, gw_ip)
    print(cmd)
    os.system(cmd)


def del_route(target_ip, gw_ip):
    cmd = "sudo route del -host %s gw %s" % (target_ip, gw_ip)
    print(cmd)
    os.system(cmd)


def del_all_route(target_ip):
    cmd = "sudo route del -host %s" % target_ip
    print(cmd)
    os.system(cmd)
