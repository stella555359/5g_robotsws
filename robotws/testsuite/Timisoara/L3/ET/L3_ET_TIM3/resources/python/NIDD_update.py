import os
try:
    import gitlab
except ImportError:
    os.system('pip install python-gitlab')
    import gitlab
import time


def update_topologyconfig_repo(**kwargs):
    """
    This is used to create Merge Request for the topology and variant of choice on the branch directories of choice.
    Mainly can be used for the update of SCF files with latest NIDD versions using scripts
    Main parameters required in the kwargs:
    URL : the base URL of your repo like "https://gitlabe2.ext.net.nokia.com"
    private_token : The API token for the user with whose username we are planning to create the merge request
    project_id : Each GITLAB repo will have a project id, topology-config repo the ID is 39803
    nidd_version : This is the version number for which the update is planned
    auto_merge : By Default this value is 'true' and if you want to have a manual review before merge
                 please send this value as 'false'
    topology : This values is the combination of 2 values 'topology' and 'variant' in the format topology_variant
    branch_name : the name with which you wanted to create the branch
    repo_file_path : The directory structure of the file to be updated from the base of the repo
    tl_file_path : Location of the file which we are going to push to the repo
    """
    gl = gitlab.Gitlab(url=kwargs.get("URL"), private_token=kwargs.get("private_token"))
    project = gl.projects.get(kwargs.get("project_id"))
    auto_merge_flag = kwargs.get("auto_merge_flag", "true")
    try:
        branch_obj = project.branches.create({'branch': kwargs.get("branch_name"), 'ref': 'master'})
    except Exception as e:
        print(repr(e))
        if "Branch already exists" in repr(e):
            project.branches.delete(kwargs.get("branch_name"))
            time.sleep(10)
            branch_obj = project.branches.create({'branch': kwargs.get("branch_name"), 'ref': 'master'})
    title_str = "{} version SCF file update for {}".format(kwargs.get("nidd_version"), kwargs.get("topology"))
    data = {'branch': kwargs.get("branch_name"), 'commit_message': title_str,
            'actions': [{'action': 'update', 'file_path': kwargs.get("repo_file_path"),
                         'content': open(kwargs.get("tl_file_path")).read(), }]}

    commit_obj = project.commits.create(data)
    mr_obj = project.mergerequests.create({'source_branch': kwargs.get("branch_name"),
                                           'target_branch': 'master', 'title': title_str,
                                           'squash': True, 'remove_source_branch': True, 'labels': ['NIDD_update']})

    mr_obj.rebase()
    time.sleep(10)
    mr_status_obj = project.mergerequests.get(mr_obj.iid, include_rebase_in_progress=True)
    for _ in range(3):
        print("merge_id:", mr_obj.iid)
        print("status of MR:", mr_status_obj.rebase_in_progress)
        print("Details of the MR :", mr_obj.attributes)
        if auto_merge_flag != "true":
            print("Only MR will be created for manual review. Auto Merge has been set to false")
            return
        if not mr_status_obj.rebase_in_progress or mr_obj.attributes['merge_status'] == 'can_be_merged':
            try:
                mr_obj.merge(merge_when_pipeline_succeeds=True)
                print("Details of the MR Post Merge initiation :", mr_obj.attributes)
                break
            except Exception as e:
                print(repr(e))
                print("Details of the MR Post Merge initiation having Exception :", mr_obj.attributes)
                if "404 Branch Not Found" in repr(e):
                    print("Branch already deleted")
        else:
            print("Still rebase in progress")
        time.sleep(10)
