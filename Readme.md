The purpose of this repository is to make someone more efficient in using git by explaining it inside out.

This repository WILL:
- give an intro to scm in general and git specifically
- explain the internal model of git (commit, tree, blob etc)
- help you match git commands to ways you want to manipulating your repository

This repository WILL NOT:
- take over the decision on what is the correct branching strategy for you
- explain how to interact with Github, Gitlab, tfs, PullRequests etc.
- explain SourceTree, GitExtensions, GitKraken, Fork or any GUI tool for that matter 


# preconditions to follow along
- git cli
- pigz
- cat, cd, cp
- editor
- config
  - lg1 = log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' -n 30
  - lg = !"git lg1 --all"
  - graphviz = "!f() { echo 'digraph git {' ; git log --pretty='format:  %h -> { %p };' \"$@\" | sed 's/[0-9a-f][0-9a-f]*/\"&\"/g' ; echo ; git log --pretty='format:  \"%h\" [label=\"%h: %s\"];' \"$@\" ; echo '}'; }; f"
git graphviz | dot -Tpng -o a.png


# intro

## source control management
- structured versioning for code (or content in general)
- supports development by making it possible to:
  - annotate changes with text (eg. commit)
  - have multiple concurrent versions (eg. branches)
  - work together on a version (eg. branches / PullRequests etc)
- not actually a backup

## git
- started by Linus Torvalds for the Linux kernel
- <show iamge git README>
- git is a distributed vcs => NO "master server", everyone has the full repository with the whole history (up to the last fetch)

## if interactive
- everyone can now `git clone https://github.com/wtjerry/gitShowAndTell_playgroundRepo.git`


# git internals

## git is just a DAG
- Directed Acyclic Graph
- <explain graph & DAG>
- git just manipulates a DAG: each commit is one node
- <show image commit graph & `git lg` for branch names>
- <ref https://learngitbranching.js.org/>

## what is a commit?
- multiple commits make up a commit graph, but what actually is a commit?
- a commit is just a compressed file
- <show
  1. current commit id (hash)
  2. .git/objects dir
  3. cd to first 2 chars of hash
  4. `cat hash | pigz -d` OR `git cat-file -p hash`> OR `printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" | cat - GIT_OBJECT_HERE | gzip -d`
- commit contains:
  - tree hash
  - parent (can be multiple eg merge)
  - author
  - commiter (differs eg in rebases or patches via email)
  - commit message (header and rest of lines)
- tag objects work mostly the same

## what is a tree?
- a tree is just a compressed file
- <show
  1. tree id in current commit
  2. `git cat-file -d tree-id`>
- tree contains:
  - permissions
  - type of content
  - hash of content
  - name
- trees are recursive, eg trees can contain trees
- if a commit has the same content (or partially eg the same folder content) as another commit it will reference the same tree

## what is a blob?
- a blob is just a compressed file containing the a "real" files content
- <show
  1. blob id in tree in current commit
  2. `git cat-file -d blob-id`>

## what is a branch / HEAD?
- a branch is just a file pointing to a commit
- the HEAD is basically your current location on the graph. if you create a commit it has HEAD as it's parent
- <show
  1. `cd .git/`
  2. `git lg`
  3. `cat HEAD` # our current location
  4. `git branch`
  5. `ls -l refs/heads` # all local branches
  6. `cp refs/heads/master refs/heads/myFancyBranch` # you just created a branch
  7. `git branch`
  8. edit refs/heads/myFancyBranch
  9. `git branch` # see it now points somewhere else>
- normal tags works mostly the same
- <show `git checkout other-branch`>
- <show
  1. edit .git/HEAD
  2. we just changed the branch
  3. at least almost: we didnt update the working directory>
  
## what is the staging area / index?
- this time it is not just a file, jk it is, but it isnt as easily readable
- <show image "working dir, staging area, repository & commands">
- <show
  1. `git add aFile`
  2. `git status` # file is in staging area, btw file is also under .git/objects
  3. `git reset aFile`
  4. `git status` # file is no longer in staging area
  5. `git add aFile`
  6. `git lg`
  7. `git commit`
  8. `git lg`
- can also partially add files via git add -p

## what is a remote?
- a remote is just a link to another repository
- it is mostly used to emulate a central / master repository
- you interact with it via fetch / push / pull
- in you repository you have remote tracking branches. those change when doing a fetch / push.
- those track the remote branches
- you can then merge / rebase them into your "normal" branches


# most used git commands

**status**

prints the current branch, changes in working dir and changes in index

**add**

add files / hunks of files from working dir to index / staging area

**commit**

create a commit with content of index and parent HEAD, then move head to new commit

**branch**

list create or delete branches

**log**

lists commits
can be configured to produce nice graphs

**stash**

stashes your working dir changes away. basically a "dirty commit".
can be pop (-ped to appy and delete stash) or apply (-ed to just apply) later onto another commit

**checkout**

change working dir, eg checkout a branch / a tag / a file
eg can be used to overwrite a single file with one in a branch / different version

**reset**

either copy content of other version to index
or move branch pointer to different commit

**rebase**

modify the commit graph by re-basing / changing the parent commit of a branch
code wont change (if there are no conflicts) but hash will (bc of diff parent commit)

**merge**

merge 2 branches back into one. creates a new commit with the merged content and **2** parents

**fetch**

fetches changes from a remote repository
new commits in branch, new / deleted branches, new / deleted tags
will not change any local branch (only remote tracking)

**pull**

will first do a fetch and then (based on configuration, default merge) a merge or rebase with your local branch

**push**

pushes changes to a remote repository
new commits in branch, new / deleted branches, new / deleted tags

**reflog**

a log containing all changes to references.
eg branch was moved / updated


# some more things to check out:
- https://git-scm.com/book/en/v2
- https://learngitbranching.js.org/
- how to write a good commit message: https://chris.beams.io/posts/git-commit/
- configs:
  1. aliases
  2. merge / diff tool
  3. author
  4. remotes
  5. etc
- branching workflows : https://www.atlassian.com/git/tutorials/comparing-workflows
- PullRequest: try it out with github
- religious discussion merge vs rebase: just duckduckgo it
- lfs (large file storage): introduced by Microsoft to be able to work with large files
- git-kraken: nice looking git gui which does a great job of not hiding functionality
- git cat-file: print content of hash
- git ls-files: print conent of tree (also works recursively)
- https://www.youtube.com/watch?v=3a2x1iJFJWc&index=1&list=WL&t=4s explains working dir & index
