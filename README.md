# conservative git merge
All incoming changes from other branch are marked as a "conflict" to be solved.
Ideal for collaboration on text like `tex` files or even code if one prefer to perform a hot review
of changes locally in their favorite merging tool, instead of resorting to the limited options given
by on-line tools.
I wonder why there is no such merging strategy in git yet.

# simulating a repository
```shell
mkdir force-conflict
cd force-conflict
git init .
echo -e "a\nb\nc\n" > file.txt
cat file.txt
```
```python
# output:
a
b
c

```

```shell
git add .
git commit -m "First message"
```

# Simulating friend's contribution:
```shell
git checkout -b friend
```
```python
# output:
Switched to a new branch 'friend'
```

```shell
echo -e "d\n" >> file.txt
cat file.txt 
```
```python
# output:
a
b
c
d

```

```shell
git add .
git commit -m "Contributions from friend"
```

Ok, my friend contributed. Going back to my code (master or main)...
```shell
git checkout master
```
```python
# output:
Switched to branch 'master'
```


# Performing the merge as conservative as possible

We recreate the two branches (`friend` and `master`) from a zeroed one (called here `temporary-branch-for-conservative-merge`), so every change will be a conflict, effectively nullifying **temporarily** the common ancestor used by the 3-diff algorithm. In the end, just the external contribution and our changes will appear in the history, as expected.

```shell
git checkout master 
```
```python
# output:
Switched to branch 'master'
```

```shell
git checkout -b temporary-branch-for-conservative-merge
```
```python
# output:
Switched to a new branch 'temporary-branch-for-conservative-merge'
```

```shell
git rm -r .
```
```python
# output:
rm 'file.txt'
```


```shell
git commit -m "Simulating an empty common ancestor"
git checkout -b master-from-empty
```
```python
# output:
Switched to a new branch 'master-from-empty'
```

```shell
git checkout master .
git commit -m "Recovering old content as new content"
git checkout temporary-branch-for-conservative-merge 
git checkout -b friend-from-empty
```
```python
# output:
Switched to a new branch 'friend-from-empty'
```


```shell
git checkout friend  .
git commit -m "Recovering friend's content as ex nihilo"
git checkout master-from-empty
```
```python
# output:
Switched to branch 'master-from-empty'
```

After `master-from-empty` receives changes from `friend-from-empty`, the merging process will result in a conflict as expected:
```shell
git merge friend-from-empty 
```
```bash
# output:
Auto-merging file.txt
CONFLICT (add/add): Merge conflict in file.txt
Automatic merge failed; fix conflicts and then commit the result.
```
```shell
cat file.txt 
```
```python
# output:
a
b
c
<<<<<<< HEAD
=======
d

>>>>>>> friend-from-empty

```

We can edit the conflict as we wish...
```bash
echo -e "a\nb\nc\nd reviewed by me\n" > file.txt 
cat file.txt
```
```python
# output:
a
b
c
d reviewed by me

```


... commit, and go back to master.
```bash
git add .
git commit -m "Accept/edit changes"
git checkout master
```
```python
# output:
Switched to branch 'master'
```

We must take care of preserving friend's commit(s) and adding our changes on top of that.
```bash
git merge -X theirs friend           # To keep their authorship, before anything else.
git checkout master-from-empty  .    # Recover my edits.
git commit -m "Edit friend's contribution"
cat file.txt
```
```python
# output:
a
b
c
d reviewed by me

```

```bash
git log
```
```python
# output:
commit bbb62c91c72d880d65e330f1812d0685df6ea211 (HEAD -> master)
Author: xxx
Date:   Mon Dec 28 11:39:05 2020 -0300
    "Edit friend's contribution"

commit 724e67e1dc5befe85ee8e4371cb5ef415c774b5a (friend)
Author: xxx
Date:   Mon Dec 28 10:12:31 2020 -0300
    "Contributions from friend"

commit d06a87a4319d865ebbf352507021d74355a85d07
Author: xxx
Date:   Mon Dec 28 10:05:44 2020 -0300
    "First message"
```

Some clean up...
```bash
git branch -D temporary-branch-for-conservative-merge master-from-empty friend-from-empty
```
```python
# output:
Deleted branch temporary-branch-for-conservative-merge (was 0e892f6).
Deleted branch master-from-empty (was 5677380).
Deleted branch friend-from-empty (was 0c7bc17).
```

**Yet to be put in a script, or replaced by a shorter list of git commands.**
