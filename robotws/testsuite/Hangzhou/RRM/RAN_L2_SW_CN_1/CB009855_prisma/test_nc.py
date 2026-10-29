from taf.transport.ssh import ssh

csn = ssh()

ip_addrs = ['10.64.55.98', '10.64.55.99',
            '10.64.55.100', '10.64.55.101', '10.64.55.102']
for ip_addr in ip_addrs:
    print("test IP {}:".format(ip_addr))
    csn.connect_to(hostname=ip_addr,
                   username="mn5gran",
                   password='nokia123@',
                   alias='cygwin')  # installed nc and ssh service
    print(csn.execute('pwd', connection='cygwin'))

    csn.connect_to(hostname=ip_addr,
                   username="mn5gran",
                   password="nokia123@",
                   proxy='cygwin',
                   alias='linux_host')  # installed ssh service
    print(csn.execute('ls', connection='linux_host'))
