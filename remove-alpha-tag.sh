alphaNumber="$(sed -n 's/\("version": "[0-9]\+\.[0-9]\+\.[0-9]\+\-alpha\.\)\([0-9]\+\)\("\)\(,\)/\2/p' package.json)"

previousCommit="$(git log -1 --pretty=%B)"

if [ "$alphaNumber" != "" ]; 
    then
        sed -i 's/\("version": "[0-9]\+\.[0-9]\+\.[0-9]\+\)\(-alpha\.\)\([0-9]\+\)\("\)/\1\4/' package.json
fi

if [[ "$previousCommit" == *"autobump"* ]];
    then
        git add package.json
        git commit --amend --no-edit
        git push
fi