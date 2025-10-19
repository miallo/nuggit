use crate::{DOCDIR, REPO_PATH};
use git2;
use std::fs::{self, File};
use std::io::prelude::*;
use std::io::{self, BufReader};
use std::{path::Path, process::Command};

pub fn file_exists(fname: &str) -> bool {
    let path = format!("{}/{}", REPO_PATH, fname);
    let path = Path::new(&path);
    path.exists()
}

pub fn file_contains(fname: &str, substring: &str) -> io::Result<bool> {
    let path = format!("{}/{}", REPO_PATH, fname);
    let file = File::open(path)?;
    let reader = BufReader::new(file);

    for line in reader.lines() {
        let line = line?;
        if line.contains(substring) {
            println!("sub: {}", line);
            return Ok(true);
        } else {
            println!("not: {}", line);
        }
    }

    Ok(false)
}

pub fn redeem_nuggit(nuggit: &str) -> bool {
    let mut git = Command::new("git");
    git.args(["-C", REPO_PATH]);
    let cmd = git.args(["nuggit", "redeem", nuggit]).output();
    match cmd {
        Err(_) => false,
        Ok(cmd) => {
            let out = String::from_utf8_lossy(&cmd.stdout);
            return out.contains("Success");
        }
    }
}

pub fn create_branch(repo: &git2::Repository, name: &str) {
    let tree = repo
        .head()
        .expect("create_branch could not find HEAD")
        .peel_to_commit()
        .expect("create_branch could not find commit of HEAD");
    repo.branch(name, &tree, false)
        .expect(&format!("could not create branch {name}"));
    repo.set_head(&format!("refs/heads/{name}"))
        .expect(&format!("Failed to switch to branch {name}"));
}
pub fn copy_file(src: &str, dst: &str) {
    fs::copy(&format!("{DOCDIR}/{src}"), &format!("{REPO_PATH}/{dst}"))
        .expect(&format!("could not copy {src} to {dst}"));
}
