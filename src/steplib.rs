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

/// get the first sh codeblock from a file
pub fn get_sh_codeblock(fname: &str) -> io::Result<String> {
    let path = format!("{}/{}", REPO_PATH, fname);
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    let mut inside_codeblock = false;
    let mut codeblock = String::new();

    for line in reader.lines() {
        let line = line?;
        if line.starts_with("```sh") {
            inside_codeblock = true;
            continue;
        }

        if inside_codeblock {
            if line.starts_with("```") {
                break;
            }
            codeblock.push_str(&line); // Append the current line to the code block
            codeblock.push('\n'); // Add a newline for better formatting
            return Ok(codeblock.trim().to_string());
        }
    }

    Err(io::Error::new(
        io::ErrorKind::NotFound,
        "No code block found",
    ))
}

pub fn test_exec(cmd: &str, contains: &str, in_stderr: bool) -> io::Result<bool> {
    let shell = Command::new("sh")
        .args(["-c", &format!("cd {REPO_PATH} && {cmd}")])
        .output()?;
    let out = String::from_utf8_lossy(if in_stderr {
        &shell.stderr
    } else {
        &shell.stdout
    });
    Ok(out.contains(contains))
}
