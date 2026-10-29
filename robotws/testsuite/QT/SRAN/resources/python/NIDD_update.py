import os
try:
    import gitlab
except ImportError:
    os.system('pip install python-gitlab')
    import gitlab
import time


def update_topologyconfig_repo(**kwargs):
    gl = gitlab.Gitlab(url=kwargs.get("URL"), private_token=kwargs.get("private_token"))
    project = gl.projects.get(kwargs.get("project_id"))
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
        if not mr_status_obj.rebase_in_progress or mr_obj.attributes['merge_status'] == 'can_be_merged':
            try:
                mr_obj.merge(merge_when_pipeline_succeeds=True)
                print("Details of the MR :", mr_obj.attributes)
            except Exception as e:
                print(repr(e))
                if "404 Branch Not Found" in repr(e):
                    print("Branch already deleted")
            break
        else:
            print("Still rebase in progress")
        time.sleep(10)
