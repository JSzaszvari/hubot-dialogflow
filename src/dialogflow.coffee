# Description
#   Talks with dialogflow back-end to create smart bots with
#   conversational user experience
#
# Configuration:
#   DIALOGFLOW_PROJECT_ID
#
# Commands:
#   None
#
# Notes:
#   This script responds to everything and get a dialog
#   going with api.ai. Once the intent is fully resolved,
#   it uses robot.emit to trigger additional logic to handle the intent.
#   It essentially act as an intelligent router for your scripts.
#   NOTE: this script may have to be the only one listening to
#         chat conversations or you may get conflicts / double answers
#
# Author:
#   Olivier Jacques

dialogflow = require('dialogflow')
util = require('util')

sessionClient = new dialogflow.SessionsClient()

module.exports = (robot) ->
  robot.respond /(.*)/i, (msg) ->
    query = msg.match[1]
    askAI(query, msg, getSession(msg))

  getSession = (msg) ->
    # Get session context from a thread, or create a user specific session
    if robot.adapterName == 'flowdock'
      return msg.message.metadata.thread_id
    else if robot.adapterName == 'slack'
      return msg.message.rawMessage.thread_ts
    else
      # We can't rely on threading mechanism: fallback to one session per user
      session_id = "session-" + msg.message.user["id"];
      return session_id

  askAI = (query, msg, session) ->
    # Process conversation with AI back-end
    unless process.env.DIALOGFLOW_PROJECT_ID?
      msg.send "I need a token to be smart :grin:"
      robot.logger.error "DIALOGFLOW_PROJECT_ID not set"
      return

    robot.logger.debug("Calling DialogFlow with '#{query}' and session #{session}")
    sessionPath = sessionClient.sessionPath(process.env.DIALOGFLOW_PROJECT_ID, session)
    request = {
      session: sessionPath,
      queryInput: {
        text: {
          text: query,
          languageCode: 'en-US'
        }
      }
    }
    sessionClient
      .detectIntent(request)
      .then((responses) ->
        response = responses[0]
        result = response.queryResult
        robot.logger.debug("From API.AI: " + util.inspect(response))
        if (result.allRequiredParamsPresent is true)
          # Still refining...
          msg.send(result.fulfillmentText)
        else if (result.intent? &&
                result.intent.name? &&
                result.action isnt "input.unknown")

          # API.AI has determined the intent
          msg.send(result.fulfillmentText)
          robot.logger.info("Emitting robot action: " +
                      result.intent.displayName + ", " +
                      util.inspect(result.parameters))
          # Emit event with message context and parameters
          robot.emit result.intent.displayName, msg, result.parameters
        else
          # Default or small talk
          if (result.fulfillmentText?)
            msg.send(result.fulfillmentText)
      )
      .catch((error) -> 
        robot.logger.error(error)
      )
