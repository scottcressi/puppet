branches=( dev ldn ldr nyc qa uat uxt corp management )
for i in "${branches[@]}"
do
    git branch -d $i
    git push origin --delete $i
    git checkout test
    git pull
    git checkout -b $i
    git push origin $i
    git checkout test
done
