# Description:
#   Just calm down
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   sad - Receive a calming manatee


randomManatee = () ->
  manatee = Math.floor(Math.random() * 33) + 1
  return "http://calmingmanatee.com/img/manatee#{manatee}.jpg"

module.exports = (robot) ->
  robot.hear /sad|calm down|calm it down|stay calm|chill|manatee/i, (msg) ->
    manatee = Math.floor(Math.random() * 33) + 1
    msg.send randomManatee()
