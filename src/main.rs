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
