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
            return Ok(true);
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

pub fn switch_detach(repo: &git2::Repository, name: &str) {
    let commit = repo
        .find_branch(name, git2::BranchType::Local)
        .expect(&format!("could not find branch {name}"));
    let tree = commit
        .get()
        .peel_to_tree()
        .expect(&format!("could not find commit for branch {name}"))
        .into_object();
    repo.checkout_tree(&tree, None)
        .expect(&format!("Could not check out tree of {name}"));
    repo.set_head_detached(commit.get().target().expect("could not find target"))
        .expect(&format!("Could not set detached head of {name}"));
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

pub fn replace_hook(folder: &str, hook_name: &str, search_replace: Vec<(&str, &str)>) {
    let mut content = String::new();
    fs::File::open(&format!("{DOCDIR}/{folder}/{hook_name}"))
        .expect(&format!("could not open {hook_name}"))
        .read_to_string(&mut content)
        .expect(&format!("could not read content of {hook_name}"));

    for (search, replace) in search_replace {
        content = content.replace(search, replace);
    }

    let mut file = fs::File::create(&format!("{DOCDIR}/hooks_processed/{hook_name}"))
        .expect(&format!("could not create hook {hook_name}"));
    file.write_all(content.as_bytes())
        .expect(&format!("could not write hook {hook_name}"));
}

pub fn replace_copy(src: &str, dst: &str, search: &str, replace: &str) {
    let mut content = String::new();
    fs::File::open(&format!("{DOCDIR}/{src}"))
        .expect(&format!("could not open {src}"))
        .read_to_string(&mut content)
        .expect(&format!("could not read content of {src}"));

    let modified_content = content.replace(search, replace);

    let mut file =
        fs::File::create(&format!("{REPO_PATH}/{dst}")).expect(&format!("could not create {dst}"));
    file.write_all(modified_content.as_bytes())
        .expect(&format!("could not write {dst}"));
}

/// get the first sh codeblock from string
pub fn get_sh_codeblock_str(string: &str) -> io::Result<String> {
    let mut inside_codeblock = false;
    let mut codeblock = String::new();

    for line in string.lines() {
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

pub fn exec(cmd: &str) -> bool {
    Command::new("sh")
        .args(["-c", &format!("cd {REPO_PATH} && {cmd}")])
        .status()
        .expect("status error")
        .success()
}

pub fn exec_out(cmd: &str, in_stderr: bool) -> String {
    let out = Command::new("sh")
        .args(["-c", &format!("cd {REPO_PATH} && {cmd}")])
        .output()
        .unwrap();
    let out = match in_stderr {
        false => out.stdout,
        true => out.stderr,
    };
    let str = String::from_utf8_lossy(&out);
    str.to_string()
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

pub fn strip_first_char_of_line(str: &str, num_of_chars: usize) -> String {
    str.lines()
        .map(|line| {
            if line.len() > 0 {
                &line[num_of_chars..] // Remove the first character
            } else {
                line // Return the line unchanged if empty
            }
        })
        .collect::<Vec<&str>>()
        .join("\n")
}
