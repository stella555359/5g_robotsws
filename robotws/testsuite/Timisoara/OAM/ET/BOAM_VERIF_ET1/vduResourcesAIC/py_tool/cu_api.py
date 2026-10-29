import requests
import json
import time


class cu_api():
    def __init__(self):
        self.session_dict = {}
        self.session = requests.session()

    def get_trace_status(self, ipaddr, user="Nemuadmin", passwd="nemuuser"):
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
                                passwd="nemuuser"):
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
