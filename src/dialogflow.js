// Description
//

const dialogflow = require('dialogflow')
const util = require('util')

const sessionClient = new dialogflow.SessionsClient()

module.exports = (robot) => {
  let getSession = (res) => {
    return `session-${res.message.user["id"]}`
  }
  
  let askAI = (query, res, session) => {
    if (!process.env.DIALOGFLOW_PROJECT_ID) {
      res.send('I need a token to be smart :grin:')
      robot.logger.error('DIALOGFLOW_PROJECT_ID not set')
      return
    }
    
    robot.logger.debug(`Calling dialogflow.ai with '${query}' and session '${session}'`)
    let sessionPath = sessionClient.sessionPath(process.env.DIALOGFLOW_PROJECT_ID, session)
    let request = {
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
      .then((responses) => {
        let response = responses[0]
        let result = response.queryResult
        robot.logger.debug(`From dialogflow.ai: ${util.inspect(response)}`)
        if (result.allRequiredParamsPresent) {
          // TODO more
          res.send(result.fulfillmentText)
        } else if (result.intent && result.intent.name && result.action!=='input.unknown') {
          res.send(result.fulfillmentText)
          robot.logger.info(`Emitting robot action: ${result.intent.displayName}, ${util.inspect(result.parameters)}`)
          robot.emit(result.intent.displayName, msg, result, parameters)
        } else {
          if (result.fulfillmentText) {
            res.send(result.fulfillmentText)
          }
        }
      })
      .catch((e) => {
        robot.logger.error(e)
      })
  }

  robot.respond(/(.*)/i, (res) => {
    let query = res.match[1]
    askAI(query, res, getSession(res))
  })
}