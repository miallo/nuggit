use git2;
use std::{path::Path, process::Command};

mod buildsetup;
mod nuggits;
use buildsetup::BuildStepper;

const REPO_PATH: &str = "tutorial";
const DOCDIR: &str = "./src";

fn create_build_steps() -> BuildStepper {
    let mut build_stepper = BuildStepper::new();

    build_stepper.add_step(
        "initial commit",
        |_repo: &git2::Repository, _prev: git2::Reference| {
            println!("Example buildstep");
            Ok(_prev)
        },
        |git: &mut Command| {
            println!("Example Test");
            let st = git
                .arg("status")
                .output()
                .expect("could not get git status");
            let stdout = str::from_utf8(&st.stdout).expect("Invalid UTF-8");
            println!("Git Status:\n{}", stdout);
            let first_steps_path = format!("{}/first-steps-with-git.md", REPO_PATH);
            assert!(
                !Path::new(&first_steps_path).exists(),
                "The file {} should only exist after the first command.",
                first_steps_path
            );
            let readme_path = format!("{}/README.md", REPO_PATH);
            assert!(
                Path::new(&readme_path).exists(),
                "The file {} should exist.",
                readme_path
            );
        },
    );

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
