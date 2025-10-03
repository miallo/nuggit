use std::{fs::remove_dir_all, path::Path};
use git2::{Error, Repository, RepositoryInitOptions };

mod nuggits;
use nuggits::{write_nuggits_to_tsv};

fn reproducibility_setup(repo: &Repository, suffix: Option<&str>) -> Result<(), Error> {
    let mut config = repo.config()?;

    let name_suffix = suffix.unwrap_or("");
    let email_devider = if name_suffix.is_empty() {
        ""
    } else {
        "+"
    };
    let user_name = format!("Nuggit{} Challenge", name_suffix);
    let user_email = format!("nuggit{}{}@lohmann.sh", email_devider, name_suffix);

    config.set_str("user.name", user_name.as_str())?;
    config.set_str("user.email", user_email.as_str())?;
    Ok(())
}

fn create_origin(repo: &Repository, repo_path: &str) -> Result<Repository, Error> {
    let origin_path_str = ".git/my-origin";
    let origin_path = format!("{}/{}",&repo_path, &origin_path_str);
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
}
