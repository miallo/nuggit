#!/usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

RESET='\033[0m'
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"

set_up_game() {
  {
    local first_file="$SCRIPT_DIR/../first-steps-with-git.md"
    local nuggit_src="$SCRIPT_DIR/nuggit-src"
    cp "$nuggit_src/first-steps-with-git.md" "$first_file"
    # uncommitted changes/status
    # Needs to be second to last (only before hooks), so that the uncommitted changes are available initially
    cat "$nuggit_src/status.md" >> "$first_file"
    {
      cat "$nuggit_src/add.md"
      echo # newline for readability
      cat "$nuggit_src/commit.md"
    } >> "$first_file"
    git add "$first_file"
    git commit -m 'first-steps-with-git: add explanation on status and diff'
    # tmp file, because gnused and MacOS/FreeBSD sed handle "-i" differently
    sed -e "/$(head -n 1 "$nuggit_src/commit.md")/,+$(wc -l < "$nuggit_src/commit.md")d" "$first_file" > tmp
    mv tmp "$first_file"
    git add "$first_file"
    num_of_diff_commit_lines="$(( $(wc -l < "$first_file") - $(wc -l < "$nuggit_src/add.md")))"
    sed "$num_of_diff_commit_lines,$ d" "$first_file" > tmp
    mv tmp "$first_file"

    # hooks (should be installed last, since they are self-mutating and would be called e.g. by `git commit`)
    mv "$nuggit_src/hooks/"* "$SCRIPT_DIR/hooks/"
    chmod +x "$SCRIPT_DIR/hooks/"*
  } 1>/dev/null 2>&1

  echo "The game is on!"
  echo
  echo "A new file has just appeared in this directory... What does it contain? 🤔"
}

opt="$1"; shift
case "$opt" in
  redeem)
    "$SCRIPT_DIR/redeem.nuggit" "$@"
    # first redeem nuggit and only afterwards set up game, because of hooks
    if [[ "$1" == ReadTheDocs ]]; then
      set_up_game
    fi
    ;;
  log)
    git log nuggits
    exit 0
    ;;
  progress)
    if [[ "$(git rev-list --count nuggits)" == 1 ]]; then
      printf "You didn't start yet - call \`%bgit nuggit redeem ReadTheDocs%b\` first\n" "$BLUE" "$RESET"
      exit 0
    fi
    echo "You have found $(( $(git rev-list --count nuggits) - 1)) of NUMBER_OF_NUGGITS nuggits"
    printf "You started %s 😃\n" "$(git log --pretty="%cr" --reverse nuggits | sed -n '2{p;q;}')"
    exit 0
    ;;
  skip-to-chapter)
    # Format: <chapter name><SPACE><command to get to that chapter>
    chapters=(
        "branches git switch -f branches-explained"
        "push/pull git switch -f working-with-others"
        "log git reset --hard @ && git fetch -q && git switch -f history"
        "cherry-pick git switch -f --detach CHAPTER_INTERACTIVE_REBASE_FOLLOW"
        "reset git switch -f --detach CHAPTER_CHERRY_PICK_FOLLOW"
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
    exit 0
    ;;
  --help|help)
    printf "Options:\n"
    printf "\`%bgit nuggit start%b\` - starts the game\n" "$BLUE" "$RESET"
    printf "\`%bgit nuggit redeem <nuggit>%b\` - redeem a nuggit\n" "$BLUE" "$RESET"
    printf "\`%bgit nuggit log%b\` - alias for \`%bgit log nuggits%b\`\n" "$BLUE" "$RESET" "$GREEN" "$RESET"
    printf "\`%bgit nuggit progress%b\` - shows how much progress you have made so far\n" "$BLUE" "$RESET"
    printf "\`%bgit nuggit skip-to-chapter%b\` - skip to a particular point of this game. WARNING: you will not get any nuggits you skipped\n" "$BLUE" "$RESET"
    ;;
  *)
    printf "%bERROR!%b Unknown option '%b$opt%b'.\n\n" "$RED" "$RESET" "$YELLOW" "$RESET" >&2
    # call script with help:
    "$0" help
    exit 1
    ;;
esac

