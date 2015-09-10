# Description:
#   Toot toots
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   toot - Receive a toot


toots = [
  "http://i.imgur.com/QXCfHbg.jpg",
  "http://i.imgur.com/wFXLWhB.jpg", 
  "http://i.imgur.com/lMUJl7H.jpg", 
  "http://i.imgur.com/dAGscRH.jpg",
  "http://i.imgur.com/A0ar3cc.jpg",
  "http://i.imgur.com/WbHVjlN.jpg",
  "http://i.imgur.com/sAiB5Vc.jpg",
  "http://i.imgur.com/MFBtdDC.jpg",
  "http://i.imgur.com/HxvCgyK.jpg", 
  "http://cdn.meme.am/instances/500x/55272718.jpg"
]

module.exports = (robot) ->
  regex = /^(toot|oops)$/i
  robot.hear regex, (msg) ->
    msg.send msg.random toots