use std::{self, fs::{File}, io::{Write, BufWriter}};

#[derive(Debug)]
pub struct Nuggit<'a> {
    pub name: &'a str,
    pub description: &'a str,
    pub success_message: &'a str,
}

pub const NUGGITS: &[Nuggit] = &[
    Nuggit { name: "ReadTheDocs", description: "Up to a great start! Let's goooooooo!", success_message: "Ready, steady, go! 🏁" },
    Nuggit { name: "LocalCodeExecution", description: "Hooks under .git/hooks can be used to do lots of things, like running a code formatter before committing, or executing arbitrary code.", success_message: "Not bad! You must be a little bit paranoid and at the same time know a lot about git 😜" },
    Nuggit { name: "TheStageIsYours", description: "`git diff --staged` shows the changes that would be included if you run `git commit` right now.", success_message: "The stage is yours! 🎤" },
    Nuggit { name: "BigCommitment", description: "`git commit` creates a new 'save point' including the changes mentioned in `git diff --staged`.", success_message: "Creating a check point... 🧾" },
    Nuggit { name: "ShortMessageService", description: "`git commit -am 'My second feature'` commits all unstaged changes with a short message", success_message: "HDGDL 📲" },
    Nuggit { name: "DifferenceEngine", description: "`git diff` shows the unstaged changes, so the ones you currently would not include in the next commit.", success_message: "Small things can make the _diff_erence 🔬" },
    Nuggit { name: "AbsoluteDifferentiable", description: "`git diff <COMMIT/BRANCH NAME>` shows the diff compared to that commit. For 'diff' you can always add `-- some/path` to limit the diff.", success_message: "Big or small differences 💯" },
    Nuggit { name: "AddTheTopOfYourGame", description: "`git add <file>` stages a file for a following commit", success_message: "Do you want to add me to your friendlist? ➕" },
    Nuggit { name: "Switcheridoo", description: "`git switch <BRANCH NAME>` allows you to switch to a specific branch.", success_message: "Please dont switch off! 🔌" },
    Nuggit { name: "ShowMeMore", description: "`git show <COMMIT HASH>` shows you the changes of a specific commit.", success_message: "Show me what else you can do! 🤓" },
    Nuggit { name: "MyFirstBranch", description: "`git switch -c <NEW BRANCH NAME>` creates a new branch.", success_message: "Can't see the tree for all the branches... 🌳" },
    Nuggit { name: "LogIcOfGit", description: "`git log <COMMIT HASH>` shows the commit history (by default of the current commit).", success_message: "Don't we all have a long history?! 🏛️" },
    Nuggit { name: "LogCat", description: "`git log -p <COMMIT HASH>` shows the commit history including the patches.", success_message: "Let's dig into the past 🪏" },
    Nuggit { name: "AnnotateMeIfYouCan", description: "`git tag -a <TAG NAME> -m 'My annotation'` will create an annotated tag.", success_message: "Let's play tag! 🏷️" },
    Nuggit { name: "CuriosityKilledTheCat", description: "You can use git as a data base to store arbitrary things in. If that is a good idea is a different question...", success_message: "Didn't I explicitly tell you not to look there? 😸" },
    Nuggit { name: "ItsAllAboutTheRebase", description: "`git rebase <COMMIT/BRANCH NAME>` will pretend you did your commits based on the referenced commit/branch to achieve a clean history.", success_message: "Doesn't cleaning up feel good? 🧹" },
    Nuggit { name: "SatisfactionThroughInteraction", description: "`git rebase -i <COMMIT/BRANCH NAME>` will allow you to reorder commits or modify them", success_message: "Let's pretend the past didn't happen! 🏛️" },
    Nuggit { name: "YoureACherryBlossom", description: "`git cherry-pick <COMMIT>` allows to get the changes from a single commit of a different branch into yours.", success_message: "I like cherries! 🍒" },
    Nuggit { name: "MineBrokeTheirsDidnt", description: "`git restore --theirs` restores the files as they are in the commit to be applied.", success_message: "It's all theirs 👉"}, 
    Nuggit { name: "AllAbortTheCherryPickTrain", description: "`git cherry-pick --abort` will abort the cherry pick if it failed.", success_message: "ABORT! ABORT! 🛑" },
    Nuggit { name: "MountainCherryRange", description: "`git cherry-pick` can take a list/range of commits too.", success_message: "A range of emotions 🏔️" },
    Nuggit { name: "WhereIsTheLiveStream", description: "`git diff @{u}` shows the diff compared to what your repo thinks the 'upstream' branch is like", success_message: "Let's go swimming upstream! 🦦" },
    Nuggit { name: "ToDoOrToUndo", description: "`git revert <COMMIT>` undoes what a previous commit introduced", success_message: "You never did any mistake! ↩️" },
    Nuggit { name: "PushItToTheLimits", description: "`git push` uploads the commits from your current branch to the server.", success_message: "Uploading your mind... 🆙" },
    Nuggit { name: "PullMeUnder", description: "`git pull` downloads the latest commits from the server and will apply them to the branch you are currently on.", success_message: "Don't feel down for downloading things... You are doing great! 📈" },
    Nuggit { name: "HardBreakHotel", description: "`git reset --hard <COMMIT/BRANCH>` will remove all your changes and point the current branch to the new commit", success_message: "When things don’t go as planned, just hit the reset button on your hopes! 🔙" },
    Nuggit { name: "SoftSkills", description: "`git reset --soft <COMMIT/BRANCH>` keeps your changes, but removes commits from the history (or depending on what you call it with it can actually add them, too…)", success_message: "I’m working on my soft skills - like making people laugh with puns! 🤪" },
    Nuggit { name: "StagingAReputationRestoration", description: "`git restore --staged <FILE>` allows you to unstage changes", success_message: "Do you feel unsure about commitment? ♻️" },
    Nuggit { name: "SourceOfAllEvil", description: "`git restore --source <FILE>` allows you to get the content of a file as it is in a different commit", success_message: "Now this is Source Code! ♨️" },
    Nuggit { name: "PretendYouDidntDoIt", description: "`git restore <FILE>` undoes all the uncommitted changes to this file", success_message: "No traces left of your change now! 👣" },
    Nuggit { name: "MergersAndAcquisitions", description: "`git merge <COMMIT/BRANCH>` combines two branches in a different way than rebase", success_message: "Merge-Party! 🔗" },
    Nuggit { name: "ThisWasATriumph", description: "You made it through to the end!", success_message: "This might not even have been 1/1000th of all of the things git can do, but now you know the basics and one can always learn more... Here is the crown you deserve: 👑 Wear it with pride!" },
];

// for legacy code
pub fn write_nuggits_to_tsv() -> Result<(), Box<dyn std::error::Error>> {
    let file = File::create("./src/nuggits.tsv")?;
    let mut writer = BufWriter::new(file);
    for nuggit in NUGGITS {
        writeln!(writer, "{}\t{}\t{}", nuggit.name, nuggit.description, nuggit.success_message)?;
    }
    writer.flush()?;
    Ok(())
}
