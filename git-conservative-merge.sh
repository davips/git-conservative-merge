if [[ $# -ne 3 ]]; then
    echo "Forces all their changes to the common ancestor commit to appear as conflicts."
    echo "Usage:    git-conservative-merge.sh <file> <our branch> <their branch>"
    echo "Example:  git-conservative-merge.sh main origin/main"
    exit
fi

echo;echo;echo
echo "======================================"
echo "Check if you need to resolve your current index before proceeding..."
echo "Check command: file [$1] will be subject to changes from [$3] into [$2]..."
echo "======================================"
git status
echo
read -p "[Press Enter to next step]"

echo;echo;echo
echo "======================================"
echo "Creating a branch from the common ancestor commit between [$2] and [$3]..."
echo "======================================"
echo
# read -p "[Press Enter to start]"
git checkout $(git merge-base $2 $3)
git checkout -b temporary-branch_for-conservative-merge

echo;echo;echo
echo "======================================"
echo "Creating diff [$2]x[$2] -> [$1]; to commit a file with holes for both editors..."
echo "======================================"
echo
# read -p "[Press Enter to start]"
git diff --unified=999999999 --word-diff=porcelain $2 $3 -- $1 | tail -n +6 | grep -v "^--git " | grep -v "^[\+-]" | perl -pe "s/\n//g" | perl -pe "s/~/\n/g" | cut -d" " -f2- > a
git add $1
git commit -m "Put common content"



echo;echo;echo
echo "======================================"
echo "Creating/populate branch their-temporary-branch_for-conservative-merge..."
echo "======================================"
echo
# read -p "[Press Enter to start]"
git checkout -b their-temporary-branch_for-conservative-merge
git checkout $3 $1
git commit -m "Put their content"

echo;echo;echo
echo "======================================"
echo "Creating/populate branch our-temporary-branch_for-conservative-merge..."
echo "======================================"
echo
# read -p "[Press Enter to start]"
git checkout temporary-branch_for-conservative-merge
git checkout -b our-temporary-branch_for-conservative-merge
git checkout $2 $1
git commit -m "Put our content"


echo;echo;echo
echo "======================================"
echo "Start merging their branch [$3]..."
echo "======================================"
echo
# read -p "[Press Enter to start.]"
git merge their-temporary-branch_for-conservative-merge

echo;echo;echo
echo "======================================"
echo "Please solve conflicts (if any) in your favorite tool and press Enter to commit the changes reviewed by you."
echo "======================================"
echo
read -p "[Press Enter when done.]"
git add $1
git commit -m "Accept/edit changes"



echo;echo;echo
echo "======================================"
echo "Merging their authorship in history..."
echo "======================================"
echo
# read -p "[Press Enter to start]"
git checkout $(git merge-base $2 $3)
git checkout -b review_for_conservative-merge
git merge -X theirs $3  # To keep their authorship, before anything else.

echo;echo;echo
echo "======================================"
echo "Putting our review atop..."
echo "======================================"
echo
read -p "[Press Enter to start and write a commit message]"
git checkout our-temporary-branch_for-conservative-merge $1 # Recover our review.
git commit


echo;echo;echo
echo "======================================"
echo "Merging revision into our original branch [$2]..."
echo "======================================"
echo
# read -p "[Press Enter to start]"
git merge -s ours $2
git checkout $2
git merge review_for_conservative-merge
git branch -D review_for_conservative-merge our-temporary-branch_for-conservative-merge temporary-branch_for-conservative-merge their-temporary-branch_for-conservative-merge
