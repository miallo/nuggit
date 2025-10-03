use std::{
    self,
    fs::File,
    io::{BufWriter, Write},
};

#[derive(Debug)]
pub struct Nuggit<'a> {
    pub name: &'a str,
    pub desc: &'a str,
    pub succ_msg: &'a str,
}

pub const NUGGITS: &[Nuggit] = &[
    Nuggit {
        name: "ReadTheDocs",
        desc: "Up to a great start! Let's goooooooo!",
        succ_msg: "Ready, steady, go! 🏁",
    },
    Nuggit {
        name: "LocalCodeExecution",
        desc: "Hooks under .git/hooks can be used to do lots of things, like running a code formatter before committing, or executing arbitrary code.",
        succ_msg: "Not bad! You must be a little bit paranoid and at the same time know a lot about git 😜",
    },
    Nuggit {
        name: "TheStageIsYours",
        desc: "`git diff --staged` shows the changes that would be included if you run `git commit` right now.",
        succ_msg: "The stage is yours! 🎤",
    },
    Nuggit {
        name: "BigCommitment",
        desc: "`git commit` creates a new 'save point' including the changes mentioned in `git diff --staged`.",
        succ_msg: "Creating a check point... 🧾",
    },
    Nuggit {
        name: "ShortMessageService",
        desc: "`git commit -am 'My second feature'` commits all unstaged changes with a short message",
        succ_msg: "HDGDL 📲",
    },
    Nuggit {
        name: "DifferenceEngine",
        desc: "`git diff` shows the unstaged changes, so the ones you currently would not include in the next commit.",
        succ_msg: "Small things can make the _diff_erence 🔬",
    },
    Nuggit {
        name: "AbsoluteDifferentiable",
        desc: "`git diff <COMMIT/BRANCH NAME>` shows the diff compared to that commit. For 'diff' you can always add `-- some/path` to limit the diff.",
        succ_msg: "Big or small differences 💯",
    },
    Nuggit {
        name: "AddTheTopOfYourGame",
        desc: "`git add <file>` stages a file for a following commit",
        succ_msg: "Do you want to add me to your friendlist? ➕",
    },
    Nuggit {
        name: "Switcheridoo",
        desc: "`git switch <BRANCH NAME>` allows you to switch to a specific branch.",
        succ_msg: "Please dont switch off! 🔌",
    },
    Nuggit {
        name: "ShowMeMore",
        desc: "`git show <COMMIT HASH>` shows you the changes of a specific commit.",
        succ_msg: "Show me what else you can do! 🤓",
    },
    Nuggit {
        name: "MyFirstBranch",
        desc: "`git switch -c <NEW BRANCH NAME>` creates a new branch.",
        succ_msg: "Can't see the tree for all the branches... 🌳",
    },
    Nuggit {
        name: "LogIcOfGit",
        desc: "`git log <COMMIT HASH>` shows the commit history (by default of the current commit).",
        succ_msg: "Don't we all have a long history?! 🏛️",
    },
    Nuggit {
        name: "LogCat",
        desc: "`git log -p <COMMIT HASH>` shows the commit history including the patches.",
        succ_msg: "Let's dig into the past 🪏",
    },
    Nuggit {
        name: "AnnotateMeIfYouCan",
        desc: "`git tag -a <TAG NAME> -m 'My annotation'` will create an annotated tag.",
        succ_msg: "Let's play tag! 🏷️",
    },
    Nuggit {
        name: "CuriosityKilledTheCat",
        desc: "You can use git as a data base to store arbitrary things in. If that is a good idea is a different question...",
        succ_msg: "Didn't I explicitly tell you not to look there? 😸",
    },
    Nuggit {
        name: "ItsAllAboutTheRebase",
        desc: "`git rebase <COMMIT/BRANCH NAME>` will pretend you did your commits based on the referenced commit/branch to achieve a clean history.",
        succ_msg: "Doesn't cleaning up feel good? 🧹",
    },
    Nuggit {
        name: "SatisfactionThroughInteraction",
        desc: "`git rebase -i <COMMIT/BRANCH NAME>` will allow you to reorder commits or modify them",
        succ_msg: "Let's pretend the past didn't happen! 🏛️",
    },
    Nuggit {
        name: "YoureACherryBlossom",
        desc: "`git cherry-pick <COMMIT>` allows to get the changes from a single commit of a different branch into yours.",
        succ_msg: "I like cherries! 🍒",
    },
    Nuggit {
        name: "MineBrokeTheirsDidnt",
        desc: "`git restore --theirs` restores the files as they are in the commit to be applied.",
        succ_msg: "It's all theirs 👉",
    },
    Nuggit {
        name: "AllAbortTheCherryPickTrain",
        desc: "`git cherry-pick --abort` will abort the cherry pick if it failed.",
        succ_msg: "ABORT! ABORT! 🛑",
    },
    Nuggit {
        name: "MountainCherryRange",
        desc: "`git cherry-pick` can take a list/range of commits too.",
        succ_msg: "A range of emotions 🏔️",
    },
    Nuggit {
        name: "WhereIsTheLiveStream",
        desc: "`git diff @{u}` shows the diff compared to what your repo thinks the 'upstream' branch is like",
        succ_msg: "Let's go swimming upstream! 🦦",
    },
    Nuggit {
        name: "ToDoOrToUndo",
        desc: "`git revert <COMMIT>` undoes what a previous commit introduced",
        succ_msg: "You never did any mistake! ↩️",
    },
    Nuggit {
        name: "PushItToTheLimits",
        desc: "`git push` uploads the commits from your current branch to the server.",
        succ_msg: "Uploading your mind... 🆙",
    },
    Nuggit {
        name: "PullMeUnder",
        desc: "`git pull` downloads the latest commits from the server and will apply them to the branch you are currently on.",
        succ_msg: "Don't feel down for downloading things... You are doing great! 📈",
    },
    Nuggit {
        name: "HardBreakHotel",
        desc: "`git reset --hard <COMMIT/BRANCH>` will remove all your changes and point the current branch to the new commit",
        succ_msg: "When things don’t go as planned, just hit the reset button on your hopes! 🔙",
    },
    Nuggit {
        name: "SoftSkills",
        desc: "`git reset --soft <COMMIT/BRANCH>` keeps your changes, but removes commits from the history (or depending on what you call it with it can actually add them, too…)",
        succ_msg: "I’m working on my soft skills - like making people laugh with puns! 🤪",
    },
    Nuggit {
        name: "StagingAReputationRestoration",
        desc: "`git restore --staged <FILE>` allows you to unstage changes",
        succ_msg: "Do you feel unsure about commitment? ♻️",
    },
    Nuggit {
        name: "SourceOfAllEvil",
        desc: "`git restore --source <FILE>` allows you to get the content of a file as it is in a different commit",
        succ_msg: "Now this is Source Code! ♨️",
    },
    Nuggit {
        name: "PretendYouDidntDoIt",
        desc: "`git restore <FILE>` undoes all the uncommitted changes to this file",
        succ_msg: "No traces left of your change now! 👣",
    },
    Nuggit {
        name: "MergersAndAcquisitions",
        desc: "`git merge <COMMIT/BRANCH>` combines two branches in a different way than rebase",
        succ_msg: "Merge-Party! 🔗",
    },
    Nuggit {
        name: "ThisWasATriumph",
        desc: "You made it through to the end!",
        succ_msg: "This might not even have been 1/1000th of all of the things git can do, but now you know the basics and one can always learn more... Here is the crown you deserve: 👑 Wear it with pride!",
    },
];

// for legacy code
pub fn write_nuggits_to_tsv() -> Result<(), Box<dyn std::error::Error>> {
    let file = File::create("./src/nuggits.tsv")?;
    let mut writer = BufWriter::new(file);
    for nuggit in NUGGITS {
        writeln!(
            writer,
            "{}\t{}\t{}",
            nuggit.name, nuggit.desc, nuggit.succ_msg
        )?;
    }
    writer.flush()?;
    Ok(())
}
