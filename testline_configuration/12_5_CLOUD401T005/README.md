# How to using this heat template

## Create 5G CU VNFCs Step by Step
   <HeatTemplates/NCIR/5G19B>-----This 5G19B heat template can only be used on NCIR19
### Create Flavor：
using below command to create all flavors on the controller.

   openstack stack create -t 5gbts_flavor.yaml -e 5gbts_flavor.env <your-flavor-stack-name>

Note: -e 5gbts_flavor.env is optional, it only needed when you want to set vnf prefix for created flavor.

### Create External Networks for backhaul fronthaul and oam (optional)
before creating the external networks, you should edit the parameters in 5gbts_ext_net.env or 5gbts_ext_net_dedicate.env.

   Create network : openstack stack create -f yaml -t 5gbts_ext_net.yaml -e 5gbts_ext_net_dedicate.env <your-ext-network-stack-name>

you may also use existing networks, or you could manually create all external networks used by VNFC
single_network ：set "dual_stack: disabled"
dual_network ：set "dual_stack: enabled".    the network interface that supports dual stack: fronthaul, backhual, x2

### Create all VNFCs for 5G CU
before create all VNFCs, you should upload your VNFC image via CLI/Dashboard.

     openstack image create --disk-format=qcow2 --container-format=bare --file=AirFrameVirtualized-0.1351.185.qcow2  5g19b_1852

before creating all VNFCs, you should edit the parameters in 5gbts_heat.env corresponding to your environment.

     openstack stack create -f yaml -t 5gbts_heat.yaml -e 5gbts_heat.env <your-vnfc-stack-name>


### Parameters
#### Parameters for 5gbts_ext_net.env
* network_opts:                        the whole json parameter for creating all external networks.
* network_opts.vnf_name:               the vnf name, currently it just using as a name prefix for the created network.
* network_opts.dns_forwarders:         the specified set of DNS name servers to be used by OS:Neutron:Subnet. If you want to configure mixed (IPv4 and IPv6) external networks, this parameter shall be configured as"~". e.g.  "dns_forwarders: ~". Otherwise, it shall be configured as IPv4 or IPv6 by the operator.
* network_opts.number_of_networks:     the number of external networks to create.
* network_opts.networks:               the array of the external networks' parameters.
* network_opts.networks[n].name:       the name of the created network, eg: oam. fronthaul, backhaul. currently, please do not modify these names.
* network_opts.networks[n].cidr:       the cidr address of the created sub-net in the network.
* network_opts.networks[n].gateway:    the gateway address of the created sub-net in the network.
* network_opts.networks[n].start:      the start address of the ip-pool in created sub-net.
* network_opts.networks[n].end:        the end address of the ip-pool in created sub-net.
* network_opts.networks[n].net_type:   the net type for the created tenant network, currently is VLAN. currently, please do not modify the type. the only VLAN is supported.
* network_opts.networks[n].sid:        the segment id of the tenant network.
* network_opts.networks[n].ip_ver:     the tenant network's IP version, 4 or 6.
* network_opts.networks[n].provider:   the provider net's name where the tenant network will create on.
* network_opts.networks[n].cidr_v6:    the cidr address of the created sub-net-v6 in the network.
* network_opts.networks[n].gateway_v6: the gateway address of the created sub-net-v6 in the network.
* network_opts.networks[n].start_v6:   the start address of the ip-pool in created sub-net-v6.
* network_opts.networks[n].end_v6:     the end address of the ip-pool in created sub-net-v6.
* network_opts.networks[n].ip_v6_ver:  the tenant network's IP version 6.
* dual_stack:                          the network format of dual_stack, disabled is single_network, enabled is dual_network

#### Multi-vlan usage

- If you want to configure multi-vlan, for example, to support external tenant network for both F1-C and F1-U. You can copy the original "fronthaul" net definition in 5gbts_ext_net.env file and create new net called "fronthaul_oam", "fronthaul_cp", "fronthaul_up" . Then configure the corresponding parameters for each net. Parameters should be different according to actual environment.  After this, you need to check "uuid" for each net(openstack stack show [stack_net_name]) and configure them in 5gbts_heat.env.

  ```yaml
        - name: fronthaul_oam
          cidr: 172.16.1.0/24
          gateway: 172.16.1.1
          start: 172.16.1.100
          end: 172.16.1.200
          net_type: vlan
          sid: 1000
          ip_ver: 4
          provider: physnet-1
        - name: fronthaul_cp
          cidr: 172.16.2.0/24
          gateway: 172.16.2.1
          start: 172.16.2.100
          end: 172.16.2.200
          net_type: vlan
          sid: 1001
          ip_ver: 4
          provider: physnet-1
        - name: fronthaul_up
          cidr: 172.16.3.0/24
          gateway: 172.16.3.1
          start: 172.16.3.100
          end: 172.16.3.200
          net_type: vlan
          sid: 1002
          ip_ver: 4
          provider: physnet-1
  ```

####  Parameters for 5gbts_heat.env
* image:                                     the image name for creating the VNFCs, you could check the images' name by command "openstack image list".
* ssh_public_key:                            the public key string for generate key-pair.
* vnf_name:                                  the vnf name, currently it just using as a name prefix for the created VNFCs, it is recommended to use the same setting in 5gbts_ext_net.env, default: example-5gbts
* availability_zones:                        availability zone regions for each VM. Empty value is allowed;default value will be used if empty value is set to one VM; For HA, affinity strategies need to be considered if each VM is specified.
* cluster_id:                                the cluster id for identifying the different VNFs with the same vnf_name.
* dns_forwarders:                            the DNS server list if needed, default: []
* flavors:                                   A json dictionary for identifying the flavors name for each VNFC.
* timezone:                                  the default timezone for all created VNFC vm.
* ntp_servers:                               the ntp server value.
* password:                                  the encrypted passwords for fallback accounts 'root' and '_nokfsoperator'. the password is a hash value that generated with SHA256 from a plain_text_passwd.
* internal_segment_ids:                      the segment id of the internal, internal_srv and internal_e1 network.
* internal_subnets:                          the created internal networks
* internal_e1_networks:                      the created internal_e1 networks
* internal_provider_networks:                the provider net's name for internal network will be created on.
* internal_e1_provider_networks:             the provider net's name for internal_e1 network will be created on.
* vnfc_layout:                               the VNFC's layout, "basic" or "redundant" <====> non-HA and HA usage
* number_of_cpue_nodes:                      the number of CPUE VMs. In basic the min cpue configuration is 1 and in redundant the min cpue configuration is 2. The max number for both basic and redundant deployment is 36.
* number_of_upue_nodes:                      the number of UPUE VMs. In basic the min upue configuration is 1 and in redundant the min upue configuration is 2. The max number for both basic and redundant deployment is 36.
* number_of_uvm_nodes:                       the number of Upgrade VMs, 0-1.
* external_networks:                         the external networks setting.
* external_networks. ***.uuid                the network uuid for related network, here *** may oam, f1-c, f1-u, etc.
* external_networks.oam.fixed_ips:           the ip address setting for oam, if in redundant mode this ip is the logical ip. only oam, f1c, x2c are support to specify the ip address.
* external_networks.oam.fixed_ips_0:         the ip address setting for oam in redundant mode only, this ip is physical ip for oam_0.
* external_networks.oam.fixed_ips_1:         the ip address setting for oam in redundant mode only, this ip is physical ip for oam_1.
* external_networks. f1c, x2c.fixed_ips: the ipv4 address setting for f1c/x2c, if in redundant mode this ip is the logical ip.
* external_networks. f1c, x2c.fixed_ips_0: the ipv4 address setting for f1c/x2c in redundant mode only, this ip is the physical ip for node_0.
* external_networks. f1c, x2c.fixed_ips_1: the ipv4 address setting for f1c/x2c in redundant mode only, this ip is the physcial ip for node_1.

* external_networks.f1u/s1u/x2u.fixed_ips:   the ipv4 address setting for uplane interface, If multiple UPUEs are configured, the corresponding ip address should be formatted as follows:
  fixed_ips: [ip_address: 192.168.2.X, ip_address: 192.168.3.X]. Alternatively, the following YAML list notation can be used:
  fixed_ips:
    - ip_address: 192.168.2.X
    - ip_address: 192.168.3.X
* external_networks. f1c, x2c.fixed_v6_ips:   the ipv6 address setting for f1c/x2c, if in redundant mode this ip is the logical ip.
* external_networks. f1c, x2c.fixed_v6_ips_0:   the ipv6 address setting for f1c/x2c in redundant mode only, this ip is the physical ip for Node 0.
* external_networks. f1c, x2c.fixed_v6_ips_1:   the ipv6 address setting for f1c/x2c in redundant mode only, this ip is the physical ip for Node 1.
* external_networks.f1u/s1u/x2u.fixed_v6_ips:     the ipv6 address setting for uplane interface, If multiple UPUEs are configured, the corresponding ip address should be formatted as follows:
  fixed_v6_ips: [ip_address: 'fc00::172:16:2:X', ip_address: 'fc00::172:16:3:X']. Alternatively, the following YAML list notation can be used:
  fixed_v6_ips:
    - ip_address: 'fc00::172:16:2:X'
    - ip_address: 'fc00::172:16:3:X'

  In single_stack fixed_ips and fixed_v6_ips for one interface must be only one ip or block, such as follows:
      fixed_ips: [ip_address: 172.16.2.X]
      fixed_v6_ips: []
      or
      fixed_ips: []
      fixed_v6_ips: [ip_address: 'fc00::172:16:2:X']
      or
      fixed_ips: []
      fixed_v6_ips: []
    ps: single_stack: set "dual_stack: disabled".The uuid need using single_network.

  In dual_stack fixed_ips and fixed_v6_ips for one interface must be both have ips or block, such as follows:
      fixed_ips: [ip_address: 172.16.2.X]
      fixed_v6_ips: [ip_address: 'fc00::172:16:2:X']
      or
      fixed_ips: []
      fixed_v6_ips: []
    ps: dual_stack: set "dual_stack: enabled".The uuid need using dual_network.

* For other parameters,  keep it as default if you don't know how to configure and have a try.


## Internal functionality (no official support)

### robot account

robot account is not created by default. If you still want to using this account, please using the parameter extra_cloud_config_data.

add below content in your heat env file, then create the heat with this env file will create the testing robot account with the specified password.

```yaml
parameters:
  user_info:
    system_info:
      default_user:
        name: robot
    users:
    - default
    - name: robot
      gecos: Robot user for test automation purposes
      primary-group: root
      lock_passwd: false
      plain_text_passwd: 'rastre1'
      home: /home/robot
      shell: /bin/bash
      sudo:
      - ALL=(ALL) NOPASSWD:ALL
    write_files:
    - content: |
        robot
      path: /etc/opt/nokia/setupsshkey.d/testusers
      permissions: '0644'
```
