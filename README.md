# StatusBarRun

StatusBarRun allows you to run shell scripts, apple script or execute any other file with argument directly from your status bar.

## Installation

1. Download the app from [here](https://github.com/simonmeusel/StatusBarRun/releases)
2. Execute the app once
3. Click on the R on the top left and select the menu item `Edit items` to edit your [config](https://github.com/simonmeusel/StatusBarRun#configuration)
4. To add this app to the startup simply drag it into your login items (System Preferences -> Users & Groups -> Current User -> Login Items) and tick the checkbox

## Configuration

Once started this app will create a config file located at ~/.status-bar-run

You can register different command there.
The key in the json object is the name which appears in the status bar item.
The value must be a json object too. It must have the attributes `launchPath` (string) and `arguments` (array of strings).
The `launchPath` is the path to the program to start with the given `arguments`.

Example:

![Greet](http://i.imgur.com/5dylGW2.png)

```json
{
  "Greet": {
    "launchPath": "/bin/sh",
    "arguments": [
      "-c",
      "say hi"
    ]
  }
}
```

This Example registers a item named `Greet` which run the command `say hi` in `/bin/sh`.

After modifying the config you have to either restart the program or reload the config (StatusBarRun -> Reload Config).
