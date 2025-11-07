use git2;
use std::{fs, process::Command};

mod buildsetup;
mod nuggits;
use buildsetup::{BuildStepper, MyError::NotImplemented, commit, g_add, get_hash_str};
mod steplib;
use steplib::{
    copy_file, create_branch, exec, file_contains, file_exists, get_sh_codeblock, redeem_nuggit,
    replace_copy, replace_hook, switch_detach, test_exec,
};

use crate::steplib::{exec_out, get_sh_codeblock_str, strip_first_char_of_line};

const REPO_PATH: &str = "tutorial";
const DOCDIR: &str = "./src";

fn create_build_steps() -> BuildStepper {
    let mut build_stepper = BuildStepper::new();

    // build_stepper.add_step(
    //     "show",
    //     |repo: &git2::Repository, next: String| {
    //         switch_detach(&repo, "main");
    //         replace_copy(
    //             "03_commit/show.md",
    //             "show.md",
    //             "CHAPTER_COMMIT_FOLLOW",
    //             &next,
    //         );
    //         g_add(&repo, "show.md").expect("could not add show.md");
    //         commit(&repo, "Add description on `git show`").expect("could not commit branches");
    //         Ok(get_hash_str(&repo.head()?))
    //     },
    //     |_git: &mut Command| {
    //         assert!(exec("GIT_EDITOR=cat git commit"), "commit failed");
    //         assert!(
    //             test_exec("git show", "nuggit: BigCommitment", false)
    //                 .expect("could not run git show"),
    //             "did not find BigCommitment"
    //         );
    //         assert!(
    //             redeem_nuggit("BigCommitment"),
    //             "could not redeem BigCommitment"
    //         );
    //     },
    // );

    //build_stepper.add_step(
    //    "switch",
    //    |repo: &git2::Repository, next: String| {
    //        switch_detach(&repo, "main");
    //        create_branch(repo, "branches-explained");
    //        copy_file("04_branch/branch.md", "branch.md");
    //        g_add(&repo, "branch.md").expect("could not add branch.md");
    //        commit(
    //            &repo,
    //            "WIP: add description on branches\n\nnuggit: ShowMeMore",
    //        )
    //        .expect("could not commit branches");

    //        Ok("branches-explained".to_string())
    //    },
    //    |_git: &mut Command| {
    //        //TODO
    //        assert!(
    //            test_exec(
    //                "git switch branches-explained",
    //                "nuggit: Switcheridoo",
    //                true
    //            )
    //            .expect("could not switch to branches-explained"),
    //            "switch branches-explained did not contain nuggit"
    //        );
    //        assert!(
    //            redeem_nuggit("Switcheridoo"),
    //            "could not redeem Switcheridoo"
    //        );
    //    },
    //);

    //build_stepper.add_step(
    //    "branches",
    //    |repo: &git2::Repository, next: String| {
    //        println!("branches next {next}");
    //        switch_detach(&repo, "main");
    //        create_branch(repo, "branches-explained");
    //        copy_file("04_branch/branch.md", "branch.md");
    //        g_add(&repo, "branch.md").expect("could not add branch.md");
    //        commit(
    //            &repo,
    //            "WIP: add description on branches\n\nnuggit: ShowMeMore",
    //        )
    //        .expect("could not commit branches");

    //        Ok("branches-explained".to_string())
    //    },
    //    |_git: &mut Command| {
    //        //TODO
    //        assert!(
    //            test_exec(
    //                "git switch branches-explained",
    //                "nuggit: Switcheridoo",
    //                true
    //            )
    //            .expect("could not switch to branches-explained"),
    //            "switch branches-explained did not contain nuggit"
    //        );
    //        assert!(
    //            redeem_nuggit("Switcheridoo"),
    //            "could not redeem Switcheridoo"
    //        );
    //    },
    //);
    build_stepper
        .add_step(
            "create branch",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                assert!(
                    exec_out("git switch -c my-new-branch", true).contains("nuggit: MyFirstBranch")
                );
                assert!(redeem_nuggit("MyFirstBranch"));
                None
            },
        )
        .add_step(
            "upstream",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                assert!(exec("git switch -q working-with-others"));
                let diffu_cmd = get_sh_codeblock("working-with-others.md").unwrap();
                assert!(diffu_cmd == "git diff @{u}");
                let diffu_out = exec_out(&diffu_cmd, false);
                assert!(diffu_out.contains("nuggit: WhereIsTheLiveStream"));
                assert!(redeem_nuggit("WhereIsTheLiveStream"));
                Some(diffu_out)
            },
        )
        .add_step(
            "push",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |prev_out| {
                let prev_out = prev_out
                    .clone()
                    .expect("Required previous step output for `push`");
                let prev_out = strip_first_char_of_line(&prev_out, 1);
                let push_cmd = get_sh_codeblock_str(&prev_out).unwrap();
                assert!(push_cmd == "git push");
                assert!(exec_out(&push_cmd, true).contains("nuggit: PushItToTheLimits"));
                assert!(redeem_nuggit("PushItToTheLimits"));
                None
            },
        )
        .add_step(
            "pull",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                assert!(
                    !exec("git switch history -q"),
                    "history branch should only exist after pull"
                );
                assert!(exec("git pull"));
                assert!(file_contains(&"working-with-others.md", "PullMeUnder").unwrap());
                assert!(redeem_nuggit("PullMeUnder"));
                None
            },
        )
        .add_step(
            "log",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                assert!(exec("git switch history -q"));
                let log_cmd = get_sh_codeblock("log.md").unwrap();
                assert!(log_cmd.starts_with("git log"));
                let log_out = exec_out(&log_cmd, false);
                assert!(log_out.contains("nuggit: LogIcOfGit"),);
                assert!(redeem_nuggit("LogIcOfGit"));
                Some(log_out)
            },
        )
        .add_step(
            "log -p",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |prev_out| {
                let prev_out = prev_out
                    .clone()
                    .expect("Required previous step output for `log -p`");
                let prev_out = strip_first_char_of_line(&prev_out, 4);
                let log_p_cmd = get_sh_codeblock_str(&prev_out).unwrap();
                assert!(log_p_cmd.starts_with("git log -p"));
                assert!(exec_out(&log_p_cmd, false).contains("nuggit: LogCat"),);
                assert!(redeem_nuggit("LogCat"));
                None
            },
        )
        .add_step(
            "tag",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                assert!(
                    exec_out("git show the-first-tag", false)
                        .contains("nuggit: AnnotateMeIfYouCan"),
                    "tag must contain nuggit"
                );
                assert!(redeem_nuggit("AnnotateMeIfYouCan"));
                assert!(exec("git switch --detach -q the-first-tag"));
                None
            },
        )
        .add_step(
            "rebase",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                let rb_cmd = get_sh_codeblock("combine_history.md").unwrap();
                assert!(rb_cmd.starts_with("git rebase"));
                let out = exec_out(&rb_cmd, true);
                assert!(
                    out.contains("nuggit: ItsAllAboutTheRebase"),
                    "rebase must contain nuggit"
                );
                assert!(!out.contains("nuggit: AddTheTopOfYourGame"));
                assert!(redeem_nuggit("ItsAllAboutTheRebase"));
                None
            },
        )
        .add_step(
            "rebase -i",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                let ri_cmd = get_sh_codeblock("interactive-rebase.md").unwrap();
                assert!(ri_cmd.starts_with("git rebase -i"));
                let seq_editor =
                    "GIT_SEQUENCE_EDITOR='../test_helpers/interactive-rebase-sequence-editor.sh'";
                assert!(
                    exec(&format!("{seq_editor} {ri_cmd}")),
                    "interactive rebase should succeed"
                );
                assert!(
                    file_contains("cherry-pick.md", "nuggit: SatisfactionThroughInteraction")
                        .unwrap(),
                    "interactive-rebase should show nuggit"
                );
                assert!(redeem_nuggit("SatisfactionThroughInteraction"));
                None
            },
        )
        .add_step(
            "cherry-pick",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                let cp_cmd = get_sh_codeblock("cherry-pick.md").unwrap();
                assert!(cp_cmd.starts_with("git cherry-pick"));
                assert!(!exec(&cp_cmd), "cherry-pick should fail");
                assert!(
                    file_contains("cherry-pick.md", "nuggit: YoureACherryBlossom").unwrap(),
                    "cherry-pick should show nuggit"
                );
                assert!(redeem_nuggit("YoureACherryBlossom"));
                None
            },
        )
        .add_step(
            "restore --theirs",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                let cmd = "git restore --theirs cherry-pick.md";
                assert!(file_contains("cherry-pick.md", &cmd).unwrap());
                let out = exec_out(cmd, true);
                assert!(
                    out.contains("nuggit: MineBrokeTheirsDidnt"),
                    "restore --theirs should show nuggit"
                );
                assert!(redeem_nuggit("MineBrokeTheirsDidnt"));
                Some(out)
            },
        )
        .add_step(
            "cherry-pick --abort",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |prev_out| {
                let prev_out = prev_out
                    .clone()
                    .expect("Required previous step output for cherry-pick abort");
                let cp_abort_cmd = get_sh_codeblock_str(&prev_out).unwrap();
                assert!(cp_abort_cmd == "git cherry-pick --abort");
                let out = exec_out(&cp_abort_cmd, true);
                assert!(out.contains("nuggit: AllAbortTheCherryPickTrain"),);
                assert!(redeem_nuggit("AllAbortTheCherryPickTrain"));
                Some(out)
            },
        )
        .add_step(
            "cherry-pick range",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |prev_out| {
                let prev_out = prev_out
                    .clone()
                    .expect("Required previous step output for cherry-pick range");
                let cp_range_cmd = get_sh_codeblock_str(&prev_out).unwrap();
                assert!(cp_range_cmd.starts_with("git cherry-pick"));
                assert!(exec(&cp_range_cmd), "cherry-pick range should succeed");
                assert!(
                    file_contains("reset-hard.md", "nuggit: MountainCherryRange").unwrap(),
                    "cherry-pick <range> should show nuggit"
                );
                assert!(redeem_nuggit("MountainCherryRange"));
                None
            },
        )
        .add_step(
            "reset --hard",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                let reset_hard_command = get_sh_codeblock("reset-hard.md").unwrap();
                assert!(reset_hard_command.starts_with("git reset --hard"));
                let out = exec_out(&reset_hard_command, true);
                assert!(
                    out.contains("nuggit: HardBreakHotel"),
                    "reset --hard should show nuggit"
                );
                assert!(redeem_nuggit("HardBreakHotel"));
                Some(out)
            },
        )
        .add_step(
            "reset --soft",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                let reset_soft_command = get_sh_codeblock("reset-soft.md").unwrap();
                assert!(reset_soft_command.starts_with("git reset --soft"));
                let out = exec_out(&reset_soft_command, true);
                assert!(
                    out.contains("nuggit: SoftSkills"),
                    "reset --soft should show nuggit"
                );
                assert!(redeem_nuggit("SoftSkills"));
                Some(out)
            },
        )
        .add_step(
            "restore --staged",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |_| {
                let diff_staged_out = exec_out("git diff --staged -- restore-staged.md", false);
                let filtered_diff_staged_out = strip_first_char_of_line(&diff_staged_out, 1);
                let restore_staged_command =
                    get_sh_codeblock_str(&filtered_diff_staged_out).unwrap();
                assert!(restore_staged_command.starts_with("git restore --staged"));
                let out = exec_out(&restore_staged_command, true);
                assert!(
                    out.contains("nuggit: StagingAReputationRestoration"),
                    "restore --staged should show nuggit"
                );
                assert!(redeem_nuggit("StagingAReputationRestoration"));
                Some(out)
            },
        )
        .add_step(
            "restore",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |prev_out| {
                let prev_out = prev_out
                    .clone()
                    .expect("Required previous step output for restore");
                let restore_command = get_sh_codeblock_str(&prev_out).unwrap();
                assert!(restore_command.starts_with("git restore"));
                let out = exec_out(&restore_command, true);
                assert!(
                    out.contains("nuggit: PretendYouDidntDoIt"),
                    "restore should show nuggit"
                );
                assert!(redeem_nuggit("PretendYouDidntDoIt"));
                Some(out)
            },
        )
        .add_step(
            "restore --source",
            |_repo: &git2::Repository, _next: String| Err(NotImplemented),
            |prev_out| {
                let prev_out = prev_out
                    .clone()
                    .expect("Required previous step output for restore --source");
                let restore_source_command = get_sh_codeblock_str(&prev_out).unwrap();
                assert!(restore_source_command.starts_with("git restore --source"));
                let out = exec_out(&restore_source_command, true);
                assert!(
                    out.contains("nuggit: SourceOfAllEvil"),
                    "restore --source should show nuggit"
                );
                assert!(redeem_nuggit("SourceOfAllEvil"));
                None
            },
        )
        .add_step(
            "revert",
            |repo: &git2::Repository, next: String| {
                println!("revert next {next}");
                switch_detach(&repo, "main");
                replace_copy(
                    "14_revert/revert.md",
                    "revert.md",
                    "CHAPTER_REVERT_FOLLOW",
                    &next,
                );
                g_add(&repo, "revert.md").expect("could not add revert.md");
                commit(&repo, "Add description on `git revert`")
                    .expect("could not commit branches");
                let hash = get_hash_str(&repo.head()?);
                replace_hook(
                    "rhooks",
                    "post-checkout",
                    vec![
                        ("CHAPTER_RESTORE_SOURCE_FOLLOW", &hash),
                        ("CHAPTER_RESTORE_SOURCE_FILE", "revert.md"),
                    ],
                );

                Ok(hash)
            },
            |_| {
                println!("revert test");
                let revert_cmd = get_sh_codeblock("revert.md").unwrap();
                assert!(
                    test_exec(&revert_cmd, "nuggit: ToDoOrToUndo", true)
                        .expect("could not execute revert"),
                    "revert should show nuggit"
                );
                assert!(redeem_nuggit("ToDoOrToUndo"));
                None
            },
        )
        .add_step(
            "merge",
            |repo: &git2::Repository, next: String| {
                //TODO
                switch_detach(&repo, "main");
                replace_copy(
                    "13_merge/merge.md",
                    "merge.md",
                    "CHAPTER_MERGE_FOLLOW",
                    &format!("--allow-unrelated-histories {next}"),
                );
                g_add(&repo, "merge.md").expect("Could not add merge.md");
                commit(&repo, "Add description on `git merge`").expect("could not commit merge");
                fs::remove_file(&format!("{REPO_PATH}/merge.md"))
                    .expect("could not delete merge.md");
                repo.index()
                    .unwrap()
                    .remove_path(format!("{REPO_PATH}/merge.md").as_ref())
                    .unwrap();
                commit(&repo, "Remove description on `git merge`")
                    .expect("could not commit removed merge");

                Ok(get_hash_str(&repo.head()?))
            },
            |_| {
                println!("merge test");
                let mergecmd = get_sh_codeblock("merge.md").unwrap();
                assert!(
                    test_exec(&mergecmd, "nuggit: MergersAndAcquisitions", true)
                        .expect("could not execute merge"),
                    "Merge should show nuggit"
                );
                assert!(redeem_nuggit("MergersAndAcquisitions"));
                None
            },
        )
        .add_step(
            "success",
            |repo: &git2::Repository, _next: String| {
                let head = repo.head().unwrap().peel_to_commit().unwrap().id();
                repo.set_head_detached(head).unwrap();

                let empty_tree_oid = repo
                    .treebuilder(None)
                    .expect("could not create a root tree")
                    .write()
                    .expect("could not write a root tree");
                let empty_tree = repo
                    .find_tree(empty_tree_oid)
                    .expect("could not find root tree")
                    .into_object();
                repo.checkout_tree(&empty_tree, None)
                    .expect("could not checkout empty_tree");

                copy_file("credits/the-end.md", "success.md");
                g_add(&repo, "success.md").expect("could not add success.md");
                commit(&repo, "Success!").expect("could not commit success");

                Ok(get_hash_str(&repo.head()?))
            },
            |_| {
                assert!(
                    test_exec("cat success.md", "nuggit: ThisWasATriumph", false)
                        .expect("could not read success.md"),
                    "success.md did not contain ThisWasATriumph"
                );
                assert!(
                    redeem_nuggit("ThisWasATriumph"),
                    "could not redeem ThisWasATriumph"
                );
                None
            },
        );
    //build_stepper.add_step(
    //    "ReadTheDocs should start the game",
    //    |_repo: &git2::Repository, _prev: git2::Reference| {
    //        //TODO: move setup here
    //        Ok(_prev)
    //    },
    //    |_git: &mut Command| {
    //        assert!(
    //            !file_exists("first-steps-with-git.md"),
    //            "first-steps-with-git.md should only be created on first nuggit redemption"
    //        );
    //        assert!(
    //            file_contains("README.md", "nuggit: ReadTheDocs").expect("README not found"),
    //            "README should contain ReadTheDocs nuggit"
    //        );
    //        assert!(
    //            redeem_nuggit("ReadTheDocs"),
    //            "ReadTheDocs should be redeamable"
    //        );
    //        assert!(
    //            file_exists("first-steps-with-git.md"),
    //            "first-steps-with-git.md should be created after first nuggit redemption"
    //        );
    //    },
    // );

    build_stepper
}

fn main() {
    let _build_stepper = create_build_steps();
    // build_stepper.execute();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn main() {
        let build_steps = create_build_steps();
        build_steps.test();
    }
    // #[test]
    // fn redeem_without_code_exec() {
    //     let build_steps = create_build_steps();
    //     build_steps.execute();
    //     let repo = Repository::open(REPO_PATH).unwrap();
    //     // for nuggit in NUGGITS {
    //     //     repo.ex
    //     // }
    // }
}
