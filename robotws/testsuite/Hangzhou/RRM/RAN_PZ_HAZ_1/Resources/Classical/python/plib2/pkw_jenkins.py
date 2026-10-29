# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

from taf.internal.aliasing import aliasing_scope
import logging

from petbase import gv
logger = gv.logger
kw = gv.kw


class pkw_jenkins(object):

    """

    =  基本说明  =

    本库主要提供针对 ``Jenkins`` 的 kw

    我们可以通过这里的kw对我们的130的jenkins进行操作，从而可以在jenkins上完成一些动作，比如装包，上电等；

    通过jenkins的pipeline，我们甚至可以并发地完成多个基站的准备工作；

    =  基本说明  =

    定义：在 jenkins 里面创建的 project 我们叫 job， 每一次点击 Build 或者 Build with Parameter，会产生一次build，每个build 有一个 buildid
    这里的 kw 就是围绕 job, build, buildid来进行的；

    = 本库的引入方法: =

    Library  ../../Resources/python/plib2/pkw_jenkins.py

    = 主要的 keyword : =
    开始 build 一个 job
    开始 build 一个带参数的 job
    判断/等待 build 是否完成
    判断 build 是否成功
    判断某个资源是否有空
    申请某个资源
    释放某个资源

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'
    lookup_handler, store = aliasing_scope(lookup_arg='name')

    def __init__(self, logger=None):
        from lib_devices.pet_jenkins import jenkins
        self.logger = logger or logging.getLogger('PetTA')
        self.jenkins = jenkins

    def jenkins_start_job(self, jobname, params):
        """
        启动 jenkins 的某个project；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | jobname | 字符串 | 是 |  | jenkins 中你的 job 的名称 |
        | params | 字符串 | 否 |  | 多个可选参数，跟你的 job 有关 |

        特别说明一些这里的 params是你job的多个参数，格式是：paramter1=xxx,paramter2=xxx

        *返回值:* 返回启动的 build 的 buildid

        *示例1 对于不需要参数的project:*
        | Jenkins Start Job | TA_Change_pa_signal |

        *示例2 对于需要参数的project:*
        | Jenkins Start Job | TA_Change_pa_signal | BTSID=1698,FileName=CNI_106933_PA92.xml |

        """
        kwargs = dict()
        for pair in [x for x in params.replace('"', '').split(',') if x.strip()]:
            kwargs.update({pair.split('=')[0].strip(): pair.split('=')[1].strip()})
        return self.jenkins.start_job_for_project(jobname, **kwargs)

    def jenkins_is_job_done(self, jobname, buildid):
        """
        判断 jenkins 中的 名字为jobname, id是buildid的 构建是否已经跑完；

        结合 Wait Until Keyword Succeed 可以持续监控以等待job跑完；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | jobname | 字符串 | 是 |  | job 的名称 |
        | buildid | 数字 | 是 |  | build 的id |

        *返回值:* 如果跑完了，为 True ，否则 为 False

        *示例:*
        | ${result}= | Jenkins Is Job Done | jobname=test | buildid=65 |
        | Wait until keyword succeeds | 20min | 5s | Jenkins Is Job Done | jobname=test | buildid=65 |

        """
        if self.jenkins.get_job_status(jobname, buildid) is None:
            raise Exception(f'Job {jobname} - {buildid} has not been done.')

    def jenkins_is_job_succeed(self, jobname, buildid):
        """
        判断 jenkins 中的 名字为jobname, id是buildid的构建是否跑成功；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | jobname | 字符串 | 是 |  | job 的名称 |
        | buildid | 数字 | 是 |  | build 的id |

        *返回值:* 如果跑完了，为 True ，否则 为 False

        *示例:*
        | ${result}= | Jenkins Is Job Succeed | jobname=test | buildid=65 |

        """
        return self.jenkins.get_job_status(jobname, buildid) == 'SUCCESS'

    def jenkins_lock_resource(self, resource_name):
        """
        占用 Jenkins 的资源，通过这个来保护多人共享的测试环境

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | resource_name | 字符串 | 是 |  | jenkins 中资源的名称 |

        *返回值:* 无

        *示例:*
        | Jenkins Lock Resource | resource_name=BTS1123 |

        """

        self.jenkins.lock_resource(resource_name)

    def jenkins_unlock_resource(self, resource_name):
        """
        是否 Jenkins 的资源，通过这个来保护多人共享的测试环境

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | resource_name | 字符串 | 是 |  | jenkins 中资源的名称 |

        *返回值:* 无

        *示例:*
        | Jenkins Unlock Resource | resource_name=BTS1123 |

        """

        self.jenkins.unlock_resource(resource_name)

    def jenkins_is_resource_free(self, resource_name):
        """
        判断 jenkins 中的resource是否有空，

        结合 Wait until keyword succeed 可以进入等待状态，知道资源可用；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | resource_name | 字符串 | 是 |  | jenkins 中资源的名称 |

        *返回值:* 如果资源有空，返回 True， 否则返回：False

        *示例:*
        | ${is_free}= | Jenkins Is Resource Free | resource_name=BTS1123 |
        | Wait until keyword succeeds | 120min | 5s | Jenkins Is Resource Free | resource_name=BTS1123 |

        """

        if not self.jenkins.resource_is_free(resource_name):
            raise Exception(f'Resource {resource_name} is not free.')

    def jenkins_get_latest_build_id(self, jobname):
        """
        获取 jenkins 中的 名字为jobname的最后一次build的id；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | jobname | 字符串 | 是 |  | job 的名称 |

        *返回值:* 如果跑完了，为 True ，否则 为 False

        *示例:*
        | ${buildid}= | Jenkins Get Latest Build ID | jobname=test |

        """
        result = self.jenkins.get_project_status(jobname)
        return result.get('lastBuild', 0)
