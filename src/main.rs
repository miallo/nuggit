use git2::{self, Error, Repository, RepositoryInitOptions};
use std::{self, fs::remove_dir_all, path::Path};

mod nuggits;
use nuggits::{NUGGITS, write_nuggits_to_tsv};

fn reproducibility_setup(repo: &Repository, suffix: Option<&str>) -> Result<(), Error> {
    let mut config = repo.config()?;

    let name_suffix = suffix.unwrap_or("");
    let email_devider = if name_suffix.is_empty() { "" } else { "+" };
    let user_name = format!("Nuggit{} Challenge", name_suffix);
    let user_email = format!("nuggit{}{}@lohmann.sh", email_devider, name_suffix);

    config.set_str("user.name", user_name.as_str())?;
    config.set_str("user.email", user_email.as_str())?;
    Ok(())
}

fn create_origin(repo: &Repository, repo_path: &str) -> Result<Repository, Error> {
    let origin_path_str = ".git/my-origin";
    let origin_path = format!("{}/{}", &repo_path, &origin_path_str);
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

fn create_nuggits_ref(repo: &Repository) -> Result<git2::Oid, Error> {
    let mut index = repo.index()?;
    let tree_oid = index.write_tree()?;
    let tree = repo.find_tree(tree_oid)?;
    let signature = git2::Signature::new(
        "Nuggit Challenge",
        "nuggit@lohmann.sh",
        &git2::Time::new(1112911993, 0),
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

fn store_nuggits(_repo: &Repository) -> Result<(), Error> {
    for nuggit in NUGGITS {
        print!("{} ", nuggit.name);
        // println!("{}: {} => {}", nuggit.name, nuggit.description, nuggit.success_message);
    }
    Ok(())
}

fn main() {
    let repo_path = "./tutorial";
    let _ = remove_dir_all(repo_path);
    let repo = match Repository::init(repo_path) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to initialize: {}", e),
    };

    reproducibility_setup(&repo, None).unwrap();
    let _remote_repo = create_origin(&repo, repo_path).unwrap();
    write_nuggits_to_tsv().unwrap();
    let _nuggits_ref_oid = create_nuggits_ref(&repo).unwrap();
    store_nuggits(&repo).unwrap();
}
