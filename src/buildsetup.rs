use crate::nuggits::{NUGGITS, write_nuggits_to_tsv};
use crate::steplib::create_branch;
use crate::{DOCDIR, REPO_PATH};
use git2::{self, Reference, Repository, RepositoryInitOptions};
use std::{self, fmt, fs, path::Path, process::Command};

static mut COMMIT_TIME: i64 = 1112911992;

fn get_inc_commit_time() -> git2::Time {
    // Only single thread, so should be fine…
    unsafe {
        COMMIT_TIME += 1;
        git2::Time::new(COMMIT_TIME, 0)
    }
}

fn create_nuggits_ref(repo: &Repository) -> Result<git2::Oid, git2::Error> {
    let mut index = repo.index()?;
    let tree_oid = index.write_tree()?;
    let tree = repo.find_tree(tree_oid)?;
    let signature = git2::Signature::new(
        "Nuggit Challenge",
        "nuggit@lohmann.sh",
        &get_inc_commit_time(),
    )?;
    let commit_oid = repo.commit(
        None,       // no ref to update
        &signature, // Author
        &signature, // Committer
        "RootOfAllNuggits

Have a free nuggit!",
        &tree,
        &[], // No parents for the commit
    )?;
    Ok(commit_oid)
}

pub fn reproducibility_setup(repo: &Repository, suffix: Option<&str>) -> Result<(), git2::Error> {
    let mut config = repo.config()?;

    let name_suffix = suffix.unwrap_or("");
    let email_devider = if name_suffix.is_empty() { "" } else { "+" };
    let user_name = format!("Nuggit{} Challenge", name_suffix);
    let user_email = format!("nuggit{}{}@lohmann.sh", email_devider, name_suffix);

    config.set_str("user.name", user_name.as_str())?;
    config.set_str("user.email", user_email.as_str())?;
    Ok(())
}

fn create_origin(repo: &Repository) -> Result<Repository, git2::Error> {
    let origin_path_str = ".git/my-origin";
    let origin_path = format!("{}/{}", &REPO_PATH, &origin_path_str);
    let origin_path = Path::new(&origin_path);

    let mut init_options = RepositoryInitOptions::new();
    init_options.initial_head("main");
    init_options.bare(true);

    let remote_repo = match Repository::init_opts(origin_path, &init_options) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to initialize bare repo: {}", e),
    };
    repo.remote("origin", origin_path_str)?;
    Ok(remote_repo)
}

pub fn g_add(repo: &Repository, fname: &str) -> Result<(), git2::Error> {
    let mut index = repo.index()?;
    index.add_path(fname.as_ref())?;
    Ok(())
}

pub fn commit(repo: &Repository, msg: &str) -> Result<(), git2::Error> {
    let mut index = repo.index()?;
    index.write()?;
    let tree_oid = index.write_tree()?;
    let tree = repo.find_tree(tree_oid)?;
    let head = repo.head();
    let parent_commits: Option<git2::Commit> = match head {
        Ok(head) => {
            let commit = head.peel_to_commit()?;
            Some(commit)
        }
        Err(_) => None,
    };
    let signature = git2::Signature::new(
        "Nuggit Challenge",
        "nuggit@lohmann.sh",
        &get_inc_commit_time(),
    )?;
    match parent_commits {
        Some(p) => {
            repo.commit(
                Some("HEAD"), // the reference to update
                &signature,   // author signature
                &signature,   // committer signature
                msg,          // commit message
                &tree,        // tree
                &[&p],        // parents
            )?;
        }
        None => {
            repo.commit(
                Some("HEAD"), // the reference to update
                &signature,   // author signature
                &signature,   // committer signature
                msg,          // commit message
                &tree,        // tree
                &[],          // parents
            )?;
        }
    };
    Ok(())
}

fn store_nuggits(_repo: &Repository) -> Result<(), git2::Error> {
    for nuggit in NUGGITS {
        print!("{} ", nuggit.name);
        // println!("{}: {} => {}", nuggit.name, nuggit.description, nuggit.success_message);
    }
    println!("\n");
    Ok(())
}

#[derive(Debug)]
pub enum MyError {
    FsError(std::io::Error),
    GitError(git2::Error),
}

impl From<std::io::Error> for MyError {
    fn from(err: std::io::Error) -> MyError {
        MyError::FsError(err)
    }
}

impl From<git2::Error> for MyError {
    fn from(err: git2::Error) -> MyError {
        MyError::GitError(err)
    }
}

impl fmt::Display for MyError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            MyError::FsError(err) => write!(f, "Filesystem error: {}", err),
            MyError::GitError(err) => write!(f, "Git error: {}", err),
        }
    }
}

pub struct BuildStepper {
    steps:
        Vec<Box<dyn for<'a> Fn(&'a Repository, Reference<'a>) -> Result<Reference<'a>, MyError>>>,
    tests: Vec<Box<dyn for<'a> Fn(&'a mut Command)>>,
}

impl BuildStepper {
    pub fn new() -> Self {
        BuildStepper {
            steps: Vec::new(),
            tests: Vec::new(),
        }
    }

    pub fn add_step<F, G>(&mut self, name: &str, step: F, test: G)
    where
        F: for<'a> Fn(&'a Repository, Reference<'a>) -> Result<Reference<'a>, MyError> + 'static,
        G: for<'a> Fn(&'a mut Command) + 'static,
        // F: Fn(&Repository, Reference) -> Reference + 'static,
        // G: Fn(&Repository, Reference) -> Reference + 'static,
    {
        println!("Building chapter {name}");
        self.steps.push(Box::new(step));
        self.tests.push(Box::new(test));
    }

    pub fn execute(&self) {
        let _ = fs::remove_dir_all(REPO_PATH);

        let repo = match Repository::init(REPO_PATH) {
            Ok(repo) => repo,
            Err(e) => panic!("failed to initialize: {}", e),
        };

        reproducibility_setup(&repo, None).unwrap();
        let _remote_repo = create_origin(&repo).unwrap();
        write_nuggits_to_tsv().unwrap();
        let _nuggits_ref_oid = create_nuggits_ref(&repo).unwrap();
        store_nuggits(&repo).unwrap();

        let source_path = Path::new(DOCDIR).join("01_init/README.md");
        let target_path = Path::new(REPO_PATH).join("README.md");
        fs::copy(&source_path, &target_path).unwrap();
        g_add(&repo, "README.md").expect("could not add README");
        commit(&repo, "Initial Commit").unwrap();
        let commit = repo
            .head()
            .expect("create_branch could not find HEAD")
            .peel_to_commit()
            .expect("create_branch could not find commit of HEAD");
        let _ = repo.branch("main", &commit, true);
        let _ = repo.set_head(&format!("refs/heads/main"));

        let mut prev: Reference = repo.find_reference("HEAD").unwrap();
        for step in self.steps.iter() {
            prev = match step(&repo, prev) {
                Ok(next) => next,
                Err(err) => panic!("Error: {err}"),
            };
        }
    }

    #[allow(unused)]
    pub fn test(self) {
        // Execute the tests in reverse order from build
        for step in self.tests.iter().rev() {
            let mut git = Command::new("git");
            git.args(["-C", REPO_PATH]);
            step(&mut git);
        }
    }
}
