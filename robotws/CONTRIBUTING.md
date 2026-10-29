Thank you for contributing to this repository. We greatly appreciate your
involvement and help.

Below you will find some guidelines, which, in the long run, should benefit
everyone working on this code. Please familiarize yourself with them.

We acknowledge that these guidelines are by no means the only correct way to do
things. They are meant to introduce a balance between the effort required to
maintain the repository vs contribute to it. Any feedback about this document
will be greatly appreciated.

This guide aims to:
* Reduce the overhead and complexity related to the review process.
* Improve the maintainability of the repository.
* Reduce the clutter in the repository history.
* Make it easier to use git utilities that depend on the repository log, such
  as rebase, cherry-pick, diff, blame, etc.
* Remove the guess work required from newcomers.

## Way of work

The overall way of work with the repository can be defined by following steps:

* Checkout a repository (clone)
* Create your branch
* \<Change the code that you want to change\>
* Stage - add your changes to the commit
* Commit
* Push
* Open change request 
* Review
* Merge

## Repository checkout

### Recursive clone 

```
git clone --recursive git@wrgitlab.ext.net.nokia.com:RAN/robotws.git
```

### How to get your submodules updated:
```
git submodule update --recursive --remote
```

## Configuring local git client 

Please make sure that you have set the following:

```
git config --global user.name "Mona Lisa"
git config --global user.email "Mona.Lisa@nokia.com"
git config --global pull.rebase true
```

[Config documentation] (https://git-scm.com/docs/git-config)


## Branches
* Documentation on branching features from git

[Branching documentation](https://git-scm.com/docs/git-branch)


* To create new branch you can use 

    ```
    git checkout -b '<NAME OF YOUR BRANCH>'
    ```

* Use the following name qualifiers as a prefix to the branch name, whenever
  they fit the intended change that the branch is meant to introduce:
  * `fix/` - test case or resource fixes, changes that make the code behave as documented when it
    doesn't
  * `feature/` - implementations of requested features
  * `refactor/` - improvements in readability of the code without changes to
    its overall behavior (e.g. splitting one class to two separate ones)
  * `junk/` - repository test branches that should never be merged to master
    (e.g. tests of .gitlab-ci.yml or git hooks)
  * `other/` - when none of the above is appropriate.

    Use the first prefix from that list that fits your intent. In rare cases
    where no prefix seems appropriate, use `other/`. Do not invent your own.
	
	
* A branch should represent a single goal that you wish to accomplish. A goal
  may be a task, improvement, bugfix, etc. An exception to this rule are
  branches that start with `junk/` prefix.

    Remember, that it doesn't mean that you should create _only one_ branch for
    your goal - quite the contrary: branching early and often is considered a
    good habit.

    However, you should never mix unrelated contributions into one branch.

    If you happen to do it by mistake, you can use `git cherry-pick` and
    `git rebase -i` to fix it.

* Try to make your branch name short but meaningful. Make sure, that a person
  seeing it for the first time will have a concrete idea of what changes to
  expect:

    ```
    # Bad:
    git checkout -b 'fix/tests`

    # Good:
    git checkout -b 'fix/get_scf_keyword_tests'
    ```

* Use no more than 35 characters in the name of the branch.

* Use underscores to separate parts of the branch name. e.g. fix/get_scf_keyword_tests

* Keep in mind, that your branch will be removed from the remote repository
  if it becomes stale.

    Note: git marks branches as "stale" if they weren't used in the last 3
    months.

	
## Stage

After changing your code after runnning `git status` you will see that your changes are `untracked`. 

```
$ git status
On branch master

Initial commit

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        new_file

nothing added to commit but untracked files present (use "git add" to track)

```

To track them you have to `add` them. For an elaborate way of modifying your staging please see:

https://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging


### Adding all working files to staging

```
$ git add new_file
$ git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

        new file:   new_file

```

https://git-scm.com/docs/git-add

## Committing

After you stage the changes you can commit them. This can be done with:

```
$ git commit -m "Add new_file with functionality xyz"
[master (root-commit) 8552be9] Add new_file with functionality xyz
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 new_file

$ git status
On branch master
nothing to commit, working tree clean

```

https://git-scm.com/docs/git-commit

When you are committing please try to adhere to the following rules:

### Commit - basic rules

* A commit should represent a single, cohesive contribution, that is in a
  usable state.

    Remember, that you can always experiment and commit your changes locally to
    your hearts content. It is fine, as long as the history on the remote will
    never have a breaking commit introduced. You can use `git rebase`
    afterwards to make the history clean, and then push your changes.

    For example, you should never push out changes that result in syntax
    errors.

    Note on the meaning of "contribution": this can be anything from a single
    class, bugfix, function, cosmetic change, etc. Whether the granularity of
    your commits stay at the level of a single method or a whole class is up to
    you, as long as you follow other guidelines in this document.

* Make your commits as small, as is comfortable for you to manage. Make your
  work available to others in a swift manner.

* Make your commit as reversible as possible.

    Avoid squashing different improvements into a single commit. If one of them
    introduces a bug, it will be hard to revert the offending changes with a
    single command, without discarding the ones that should stay.

* Do not mix cosmetic changes with actual improvements. Do not mix unrelated
  cosmetic changes together.

    Just because there is a small cosmetic change right next to that big chunk
    of deletions and additions, does not mean that these two belong together.
    Just because changes are relatively small and similar in size, does not
    mean that they belong in one commit.

    There is a simple command that will help you with adhering to this
    guideline: `git add -p` (patch mode).
	
### Commit messages
* Limit the subject line to 50 characters.

* Separate subject from body with a blank line.

    Note: not every commit requires a message with both subject and a body.

* Use the imperative mood in the subject line.

    Bad:
    * `Fixed foo in bar function`
    * `Added documentation for xyz`

    Good:
    * `Fix foo in bar function`
    * `Add documentation for xyz`

* Wrap the body at 72 characters.

* Use the body to explain what and why vs. how.

    Provide information about what is changed and the context in which the
    changes are made. Summarize the rationale for the changes. Don't explain
    what you've done in terms of text editing of the code to achieve the
    change. This is what the role of the diff, not the message.

    Good:
    ```
    Add exception guards to disconnect()

    In order to shield disconnect() from unpleasant surprises, and to
    prepare for implementing a state-asured is_connected, this commit adds
    exception catching to subroutines that disconnect SFTP and SSH
    client.

    This means, that ConnectionCache.close_connection_instance() is now
    redundant. It is therefore removed, and its usage is replaced with a
    simple connection.disconnect().

    The unittest that tested the shielding from the standpoint of
    ConnectionCache was therefore removed.
    ```

    Good:
    ```
    Fix attribute errors in key_paths module

    Connection classes don't have 'sftp' property anymore - 'files' is the
    new way to go.
    ```

    Bad:
    ```
    Add exception guards to disconnect()

    Added try..except clauses to _disconnect_sftp() and
    _disconnect_client().
    Changed cls.close_connection_instance to connection.disconnect,
    removed the former.
    Fixed test_cache.py.
    ```

This list has been stolen from https://chris.beams.io/posts/git-commit/.
If you want to dive deeper into this topic, the above blog post from Chris
Beams is a must-read.

## Merge requests
* Merge request should contain changes that aim to fulfill only one goal.
  Mixing together multiple fixes, feature implementations, etc., disqualifies
  the request from being reviewed.

    Aim to place as few hurdles for the reviewer of your MR as possible. Move
    out unrelated changes to separate branches. Keep your merge request clean
    and easy to understand. Using `git rebase -i` makes moving out irrelevant
    changes easy - learn to use it.

* If the repository has a branch named "develop", make it the target branch of
  your merge request.

* If there is a Jira issue that the branch aims to fulfill, start the MR name
  with issue ID inside brackets, e.g.: `[WROCAUTOCV-1166] Rest of the name`

* Merge requests must pass a review by a person appointed in accordance to the
  maintaining team's policy.

* In order to qualify for review, the changes under merge request must at the
  very least pass all of the pipeline stages. If you think your branch should
  be an exception to this rule, tell the reviewer why in the description of the
  merge request.

    Note: jobs that end with a warning (a yellow dot in Gitlab UI), does not
    count as passed.

* Please take into consideration, that the review process takes time. It can
  take a few days, depending on the workload.

* Upon submitting your merge request to the review, please make sure, that your
  changes does not come with merge conflicts.

## Review process 

There is only one major rule conerning the review: all of the changes should be reviewed. 
The exact process of the review is not imposed on the repository level and is a convention established
by the user community.
  
## Quality gates (pipelines)

Pipelines represent requirements that are enforced on the repository level. Current version of the pipeline is always available
to check in .gitlab-ci.yaml. Their purpose is to ensure that master branch is clean and does not contain easily preventable mistakes. 

There are very few simple rules wrt to how to interpret their outputs:

* Pipeline failed disqualifies an MR from being merged to master
* A pipeline may fail due to a bug in pipeline SW - it has to be corrected by repository maintainers,
  the branch has to be rebased after fix is available
* For a pipeline only the most recent job runs are taken into account. If one job failed and later its re-run and succeeded
  from the pipeline POV - it passed
* A pipeline job that is allowed to fail and fails should be treated as a warning. It does not disqualify a merge but discourages it.

---

**This version is based on general TAF guidelines with "rationale" paragraphs removed (for brevity). The original
version with justification for each item can be seen
[here](https://wrgitlab.int.net.nokia.com/michalik/CONTRIBUTING.md/blob/master/CONTRIBUTING.md)**

Some of the propositions below may seem nit-picky and arbitrary. They might be,
but the general rationale for this is that any convention is better than no
convention. It is easier to handle consistency than chaos. Let's be consistent.

Author: Artur Tabaka, based on CONTRIBUTING.md by Błażej Michalik et al.  
Year: 2020 
Version: 1.0.0
