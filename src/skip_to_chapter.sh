#!/usr/bin/env bash

# Format: <chapter name><SPACE><command to get to that chapter>
chapters=(
    "branches git switch -f branches-explained"
    "push/pull git switch -f working-with-others"
    "log git reset --hard @ && git fetch -q && git switch -f history"
    "cherry-pick git switch -f --detach CHAPTER_INTERACTIVE_REBASE_FOLLOW"
)

while true; do
    printf "Chapters you can jump to (you won't be collecting nuggits ;)):\n"
    for i in "${!chapters[@]}"; do
        chapter_name="$(echo "${chapters["$i"]}" | cut -d " " -f 1)"
        printf "%s)\t%s\n" "$i" "$chapter_name"
    done
    printf "q)\tquit\n\n"
    read -r -p "Enter chapter to jump to: " c
    if [ "$c" = q ]; then
        exit
    fi
    if [ "$c" -lt "${#chapters[@]}" ] && [ "$c" -ge 0 ]; then
        goto_chapter="$(echo "${chapters["$c"]}" | cut -d " " -f 2-)"
        break
    fi
    printf "\n\nInvalid input!\n"
done

eval "$goto_chapter"
