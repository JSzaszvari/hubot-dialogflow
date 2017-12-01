# Add smartness to hubot with API.AI

A hubot script that adds  conversational user experience with [dialogflow](https://dialogflow.com)
as back-end.

When you talk to Hubot, this script sends the text to dialogflow, which 
in turns handles the dialog and detects intents and parameters.
Finally, the script [emits an event (robot.emit)](https://github.com/hubotio/hubot/blob/master/docs/scripting.md#events)
so that it can be consumed by other scripts.

![example](https://raw.githubusercontent.com/ojacques/hubot-apiai/HEAD/img/hubot-api-ai.gif)

See [`src/dialogflow.coffee`](https://github.com/TMAers/hubot-dialogflow/blob/master/src/dialogflow.coffee) 
for full documentation.

## Installation

Clone or copy the dialogflow.coffee into your bot script folder.

install dialogflow

`yarn add dialogflow`
or
`npm install dialogflow --save`

## Configuration variable

`DIALOGFLOW_PROJECT_ID`: dialogflow project id which you get from https://console.dialogflow.com/api-client/

`GOOGLE_APPLICATION_CREDENTIALS`: path to the google sevice account key json file

## Create listener scripts

hubot-dialogflow will [emit events](https://github.com/hubotio/hubot/blob/master/docs/scripting.md#events)
which correspond to intents that you describe in API.AI.

Let's say that you have an intent called `help-me` in dialogflow. You can create
an hubot script which will act on `help-me` intents:

```
module.exports = (robot) ->
  robot.on "help-me", (msg, params) ->
    # Your code here
```

The parameters from the intent are passed as part of Hubot's event.

## TODO

- Add tests
- put this to NPM