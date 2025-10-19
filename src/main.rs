use git2;
use std::process::Command;

mod buildsetup;
mod nuggits;
use buildsetup::{BuildStepper, commit, g_add};
mod steplib;
use steplib::{copy_file, create_branch, file_contains, file_exists, redeem_nuggit};

const REPO_PATH: &str = "tutorial";
const DOCDIR: &str = "./src";

fn create_build_steps() -> BuildStepper {
    let mut build_stepper = BuildStepper::new();

    build_stepper.add_step(
        "branches",
        |repo: &git2::Repository, _prev: git2::Reference| {
            create_branch(repo, "branches-explained");
            copy_file("04_branch/branch.md", "branch.md");
            g_add(&repo, "branch.md").expect("could not add branch.md");
            commit(
                &repo,
                "WIP: add description on branches\n\nnuggit: ShowMeMore",
            )
            .expect("could not commit branches");
            Ok(repo.head()?)
        },
        |_git: &mut Command| {
            // expect "\$(get_sh_codeblock merge.md)" error to contain "nuggit: MergersAndAcquisitions"
            assert!(redeem_nuggit("MergersAndAcquisitions"));
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
    let build_stepper = create_build_steps();
    build_stepper.execute();
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
