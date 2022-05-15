# ----------------- Logic for gathering the list of files modified -----------------
# command to get list of files which are modified
str=$(git diff --name-only $(git merge-base master HEAD))
echo 'List of modified files: ------------------>> '
separator=" "
modifiedFilesList=(${str//${separator}/ })
for mf in "${modifiedFilesList[@]}"
do
    printf "$mf\n"
done
printf "\n------------------------------------------\n"

# command to get list of files which are untracked
str1=$(git ls-files --others --exclude-standard)
echo 'List of untracked files: ------------------>> '
untrackedFilesList=(${str1//${separator}/ })
for utf in "${untrackedFilesList[@]}"
do
    printf "$utf\n"
done
printf "\n------------------------------------------\n"

# command to get list of staged files
str3=$(git diff --name-only --cached)
echo 'List of stagged files: ------>> '
stagedFilesList=(${str3//${separator}/ })
for stg in "${stagedFilesList[@]}"
do
    printf "$stg\n"
done

# ----------------- Filter out files as per their extension and run checks -----------------
################## JAVA ##################
PREV_IFS=$IFS
prevLineWasDash=true
prevLineAnnotationPresent=false

echo 'List of modifed Java files: ------------------>> '
for mf in "${modifiedFilesList[@]}"
do
    if [[ "$mf" == *java ]];
        then
            printf "$mf\n"
            # Read the file content in a variable and print
            #value=`cat $mf`
            #echo "$value"
            IFS=$'\n'
            # grep -nB 1 "public.*[\(]" "$mf"

            # Find matching lines in the file using grep command and a pattern
            methodLists=($(grep -nB 1 "public.*[\(]" "$mf"))

            for mLine in ${methodLists[@]}
            do
                #printf $mLine
                if [[ $mLine == '--'* ]];
                then
                    prevLineWasDash=true
                    prevLineAnnotationPresent=false
                    continue
                fi
                if [[ $prevLineWasDash == true ]]
                then
                    printf 'inside prevLineWasDash == false block\n'
                    if [[ $mLine == *'@Test'* ]];
                    then
                        printf "line starts with @Test\n"
                        prevLineAnnotationPresent=true
                    else
                        printf "line does not starts with @Test\n"
                        prevLineAnnotationPresent=false
                    fi
                    prevLineWasDash=false
                    continue
                fi
                if [[ $prevLineWasDash == false && $prevLineAnnotationPresent == false ]];
                then
                    printf "[WARNING] >> $mLine\n"
                fi
            done
    fi
done
printf "\n------------------------------------------\n"

IFS=$PREV_IFS
