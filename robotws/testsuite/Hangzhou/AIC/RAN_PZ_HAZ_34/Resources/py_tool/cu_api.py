import requests
import json
import time


class cu_api():
    def __init__(self):
        self.session_dict = {}
        self.session = requests.session()

    def up_trace_prefix(self, string):
        return ".".join(string[0].split(".")[:-1])

    def get_trace_status(self, ipaddr, user="Nemuadmin", passwd="Nokia@123"):
        """This function is used to fetch the up trace status by restful api.

        *AUTHOR* shouxiang.jiao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |
        | user | No | vcu login user  |
        | passwd | No | vcu login password  |

        *RETURN VALUE*
        user plance trace function status

        Example
            status = get_trace_status("10.107.89.86","Nemuadmin","nemuuser" )
            status = "0"  # user plane tracing status : 0
        """
        url = "https://"+ipaddr+"/api/cp-config/v1/traces/activation-status"
        # url for cu user plane tracing

        self.check_session_and_token(ipaddr, user, passwd)

        # put the bear_token to header
        result = self.session.get(
            url=url,
            verify=False,
            headers=self.session_dict[ipaddr])

        print(result.json()["value"])
        return result.json()["value"]

    def check_session_and_token(self,
                                ipaddr,
                                user="Nemuadmin",
                                passwd="Nokia@123"):
        """This function is used to check if the token was timeout.

        *AUTHOR* shouxiang.jiao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |
        | user | No |  |
        | passwd | No |  |
        *RETURN VALUE*
        Get a key pair the ipaddress and its token
        None

        Example
            check_session_and_token("10.107.89.86","Nemuadmin","nemuuser" )
        """
        if ipaddr not in self.session_dict:
            # check there
            self.get_login_session_and_token(ipaddr, user, passwd)
        time.sleep(3)
        code = self.session.get(url="https://" + ipaddr + "/dashboard",
                                headers=self.session_dict[ipaddr],
                                verify=False).status_code
        print(str(code) + "_____________________")
        if code != 200:
            self.get_login_session_and_token(ipaddr, user, passwd)

    def get_login_session_and_token(self,
                                    ipaddr,
                                    user="Nemuadmin",
                                    passwd="nemuuser"):
        """This function is used to create a token.

        *AUTHOR* shouxiang.jiao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |
        | user | No |  |
        | passwd | No |  |
        *RETURN VALUE*
        Get a key pair the ipaddress and its token
        None

        Example
            get_login_session_and_token("10.107.89.86","Nemuadmin","nemuuser" )
        """
        user_info = (user, passwd)
        # auth info
        login_url = "https://" + ipaddr + "/api/sec/v1/login"
        # url for cu login in
        # create a https session
        result = self.session.post(url=login_url, auth=user_info, verify=False)
        # using post method to get Bearer token
        bear_token = "Bearer " + result.json()["Token"]
        header = {"Authorization": bear_token}
        self.session_dict[ipaddr] = header

    def start_trace_component(self, ipaddr):
        """This function is used start the component through restful.

        *AUTHOR* nate_lee.li@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |

        *RETURN VALUE*
        None

        Example
            start_trace_component("10.107.89.86")
        """
        self.check_session_and_token(ipaddr)
        # session, header = get_login_session_and_token(ipaddr)
        url = "https://" + ipaddr + "/api/cp-config/v1/traces/u-plane"
        data = {"targetComponent": "l2hiPdcp",
                "traceType": "Component"}
        self.session.post(
            url=url,
            json=data,
            headers=self.session_dict[ipaddr],
            verify=False)

    def start_trace_sherpa(self, ipaddr):
        """This function is used start the sherpa through restful.

        *AUTHOR* nate_lee.li@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |

        *RETURN VALUE*
        None

        Example
            start_trace_sherpa("10.107.89.86")
        """
        self.check_session_and_token(ipaddr)
        # get the token and seesion
        url = "https://" + ipaddr + "/api/cp-config/v1/traces/u-plane"
        # make the url
        data = {"targetComponent": "l2hiPdcp",
                "traceType": "Sherpa"}
        # create a post method payload
        self.session.post(
            url=url,
            json=data,
            headers=self.session_dict[ipaddr],
            verify=False)

    def set_ipaddr_and_port(self,
                            ipaddr,
                            dcapip="10.110.95.16",
                            port="55900"):
        """This function is used to set the ipaddress and port to Dcap server.

        *AUTHOR* nate_lee.li@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |
        | destip | Yes |  the ip address of Dcap |
        | port | Yes | the port of Dcap |
        *RETURN VALUE*
        Update the Dcap Server Message
        None

        Example
            set_ipaddr_and_port("10.107.89.86","10.110.95.16",5590 )
        """
        self.check_session_and_token(ipaddr)
        url = "https://" + ipaddr + "/api/trs/v1/traces/common-configuration"
        data = {"dscp": 0,
                "uplaneIpAddress": dcapip,
                "uplanePort": port,
                "traceType": "UPlane"}
        result1 = self.session.put(
            url=url,
            json=data,
            headers=self.session_dict[ipaddr],
            verify=False)
        print(result1.status_code)
        status_check = "https://" + ipaddr + "/api/trs/v1/operations/11"
        status = " "
        counter = 0
        while status != "Successful" and counter < 5:
            time.sleep(5)
            result2 = self.session.get(
                url=status_check,
                headers=self.session_dict[ipaddr],
                verify=False)
            status = result2.json()["status"]
            print(status)
            counter += 1
        result3 = self.session.get(
            url=url,
            verify=False,
            headers=self.session_dict[ipaddr])
        print(result3.json())

    def save_snapshot_to_lss_server(self, ipaddr):
        """This function is used start the sherpa through restful.

        *AUTHOR* nate_lee.li@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |

        *RETURN VALUE*
        remote_name

        Example
            save_snapshot_to_lss_server("10.107.89.86")
        """

        url = "https://" + ipaddr + "/api/asm/v1/snapshot/operations/remotes"
        data = {"coverage": "full",
                "filterRegx": "",
                "originator": "EM",
                "reason": ""}
        self.check_session_and_token(ipaddr)
        result1 = self.session.post(
            url=url,
            json=data,
            headers=self.session_dict[ipaddr],
            verify=False)
        result2 = self.session.get(
            url=url,
            headers=self.session_dict[ipaddr],
            verify=False)
        remote_name = result2.json()[0]["remoteName"]
        return remote_name

    def stop_trace_component(self, ipaddr):
        """This function is used stop the component through restful.

        *AUTHOR* nate_lee.li@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |

        *RETURN VALUE*
        None

        Example
            start_trace_component("10.107.89.86")
        """
        self.check_session_and_token(ipaddr)
        # session, header = get_login_session_and_token(ipaddr)
        url = "https://"+ipaddr+"/api/cp-config/v1/traces/u-plane/0300"
        self.session.delete(
            url=url,
            headers=self.session_dict[ipaddr],
            verify=False)

    def stop_trace_sherpa(self, ipaddr):
        """This function is used start the sherpa through restful.

        *AUTHOR* nate_lee.li@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of vcu |

        *RETURN VALUE*
        None

        Example
            start_trace_sherpa("10.107.89.86")
        """
        self.check_session_and_token(ipaddr)
        # get the token and seesion
        url = "https://"+ipaddr+"/api/cp-config/v1/traces/u-plane/0301"
        # create a post method payload
        self.session.delete(
            url=url,
            headers=self.session_dict[ipaddr],
            verify=False)

    def cmp_config(self, ipaddr, rf_num="3102", pre_key="gC7u-fa4T-4K2S-dnbw"):
        """This function is used config the cmp config through restful API .

        *AUTHOR* shouxiang.jiao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ipaddr | Yes |  the ip address of site |

        *RETURN VALUE*
        cmp config result

        Example
            cmp_config("10.107.89.86")
        """
        self.check_session_and_token(ipaddr)
        url = "https://"+ipaddr+"/api/trs/v1/cmp/server/settings"
        # send config message
        data = {"refNumber": rf_num, "pskKey": pre_key}
        self.session.put(
            url=url,
            data=json.dumps(data),
            headers=self.session_dict[ipaddr],
            verify=False
        )
        time.sleep(30)
        it_url = "https://"+ipaddr+"/api/trs/v1/cmp/certificate-initialization"
        self.session.post(
            url=it_url,
            headers=self.session_dict[ipaddr]
        )
        keep_alive = "https://"+ipaddr+"/api/trs/v1/cmp/server/status"
        config_status = False
        while config_status != "InitializationOK":
            time.sleep(3)
            result = self.session.get(
                url=keep_alive,
                headers=self.session_dict[ipaddr])
            print(result.json())
            config_status = result.json()["status"]
            if config_status == "InitializationFailed":
                return False
        return True

    def cu_cell_lock(self, ip, cell_id):
        """This function is used locked the target cell.

        *AUTHOR* shouxiang.jiao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ip | Yes |  the ip address of oam|
        | cell_id | Yes |  the cell_id you want locked|

        *RETURN VALUE*
        None

        Example
            cu_cell_lock("10.107.89.86",1)
        """
        self.check_session_and_token(ip)
        data = {"ids": [str(cell_id)]}
        url = "https://"+ip+"/api/asm/v1/cells/operations/locks"
        res = self.session.post(
            url=url,
            json=data,
            headers=self.session_dict[ip])
        id = res.json()["id"]
        s = "https://"+ip+"/api/asm/v1/cells/operations/locks/"+id
        counter = 0
        while res.json()["status"] != "success" and counter < 5:
            res = self.session.get(
                url=s,
                headers=self.session_dict[ip])
            counter += 1
            time.sleep(10)
        if counter == 20:
            return False
        return True

    def cu_cell_unlock(self, ip, cell_id):
        """This function is used unlock the target cell.

        *AUTHOR* shouxiang.jiao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ip | Yes |  the ip address of oam|
        | cell_id | Yes |  the cell_id you want locked|

        *RETURN VALUE*
        None

        Example
            cu_cell_unlock("10.107.89.86",1)
        """
        self.check_session_and_token(ip)
        data = {"ids": [str(cell_id)]}
        url = "https://"+ip+"/api/asm/v1/cells/operations/unlocks"
        res = self.session.post(
            url=url,
            json=data,
            headers=self.session_dict[ip])
        id = res.json()["id"]
        s = "https://"+ip+"/api/asm/v1/cells/operations/unlocks/"+id
        print(res.status_code)
        counter = 0
        while res.json()["status"] != "success" and counter < 5:
            res = self.session.get(
                url=s,
                headers=self.session_dict[ip])
            counter += 1
            time.sleep(10)
        if counter == 20:
            return False
        return True

    def cu_cell_check(self, ipaddr):
        """This function is to check the active cell.

        *AUTHOR* shouxiang.jiao@nokia-sbell.com
        | Input Parameters | Man. | Description |
        | ip | Yes |  the ip address of oam|
        | cell_id | Yes |  the cell_id you want locked|

        *RETURN VALUE*
        None

        Example
            cu_cell_check("10.107.89.86",1)
        """
        self.check_session_and_token(ipaddr)
        url = "https://"+ipaddr+"/api/asm/v1/cu-cells/summary"
        res = self.session.get(url=url, headers=self.session_dict[ipaddr])
        counter = 0
        en = ""
        while not isinstance(en, int):
            en = res.json()["basicCellsSummary"]["operationalState"]["enabled"]
            time.sleep(10)
            en = int(en)
        while en == 0 and counter < 5:
            res = self.session.get(url=url, headers=self.session_dict[ipaddr])
            en = res.json()["basicCellsSummary"]["operationalState"]["enabled"]
            en = int(en)
            time.sleep(60)
            counter += 1
        else:
            return False
        return True

    def cnf_role_check(self, ipaddr, pods_name):
        self.check_session_and_token(ipaddr)
        url = "https://"+ipaddr+"/api/asm/v1/vnfcs"
        res = self.session.get(url=url, headers=self.session_dict[ipaddr])
        cnf_list = res.json()
        for cnf in cnf_list:
            if cnf["availabilityStatus"] != "on line":
                break
            if cnf["name"] == pods_name:
                return cnf["role"]

    def cnf_link_check(self, ipaddr, link_name):
        self.check_session_and_token(ipaddr)
        link_check_list = []
        link_check_result = []
        if isinstance(link_name, str):
            link_check_list.append(link_name)
        elif isinstance(link_name, list):
            link_check_list.extend(link_name)
        else:
            return
        for link in link_check_list:
            if link == "f1":
                f1 = "https://"+ipaddr+"/api/asm/v1/dus/summary"
                r = self.session.get(url=f1, headers=self.session_dict[ipaddr])
                link_check_result.append(r.json()["f1LinkStatus"]["available"])
            elif link == "x2":
                x2 = "https://"+ipaddr+"/api/asm/v1/x2links/summary"
                r = self.session.get(url=x2, headers=self.session_dict[ipaddr])
                link_check_result.append(r.json()["x2LinkStatus"]["available"])
            elif link == "xn":
                xn = "https://"+ipaddr+"/api/asm/v1/xnlinks/summary"
                r = self.session.get(url=xn, headers=self.session_dict[ipaddr])
                link_check_result.append(r.json()["xnLinkStatus"]["available"])
            elif link == "ng":
                ng = "https://"+ipaddr+"/api/asm/v1/nglinks/summary"
                r = self.session.get(url=ng, headers=self.session_dict[ipaddr])
                link_check_result.append(r.json()["ngLinkStatus"]["Active"])
        print(link_check_result)
        if 0 in link_check_result:
            print("aaaa")
            return False
        return True
