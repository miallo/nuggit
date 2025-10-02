# Success! 🥳

nuggit: ThisWasATriumph

You played through all the available chapters that are available right now. Did you also collect all the nuggits?

Now you might look through the `.git` folder and take a look at how this "game" was created. E.g. here are a few starting points:
- the `git nuggit` is an alias set in `.git/config` to a script in `.git/nuggit.sh`
- `git log nuggits` refers to a pseudo "branch" that this script updates in `.git/nuggits`. Usually `git log` would look for branches in `refs/heads/nuggits`, but it also checks the toplevel git folder, probably to avoid special casing things like `HEAD` 😅 This "game" just abuses this 😁
- Where did you push your changes? Easy: `.git/my-origin` is a "bare" repo!
