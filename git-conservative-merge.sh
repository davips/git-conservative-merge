if [[ $# -ne 2 ]]; then
    echo "Usage: git-conservative-merge.sh <our branch> <their branch>"
    read -p "Press Ctrl+C to try again..."
fi

git checkout $1 
git checkout -b temporary-branch_for-conservative-merge
git rm -r .
git commit -m "Simulating an empty common ancestor"
git checkout -b ours-from-empty_for-conservative-merge

git checkout $1 .
git commit -m "Recovering old content as new content"
git checkout temporary-branch_for-conservative-merge 
git checkout -b theirs-from-empty_for-conservative-merge

git checkout $2 .
git commit -m "Recovering friend's content as ex nihilo"
git checkout ours-from-empty_for-conservative-merge


# this doens't do anything:
# echo
# echo "======================================"
# echo "Merging our changes into their branch."
# echo "======================================"
# git merge $1
# read -p "Fix conflicts (if any) and press Enter to commit accepted/edited changes"
# git add .
# git commit


echo
echo "======================================"
echo "Starting merge to force conflict on every difference..."
echo "======================================"
echo "git merge theirs-from-empty_for-conservative-merge"
read -p "Press Enter"
git merge theirs-from-empty_for-conservative-merge

read -p "Fix conflicts (if any) and press Enter to commit accepted/edited changes"
git add .
git commit -m "Accept/edit changes"
git checkout $1

git merge -X theirs $2  # To keep their authorship, before anything else.
git checkout ours-from-empty_for-conservative-merge  . # Recover our edits.
git commit
git branch -D temporary-branch_for-conservative-merge ours-from-empty_for-conservative-merge theirs-from-empty_for-conservative-merge
