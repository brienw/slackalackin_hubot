# Description:
#   Lists trucks from Off The Grid
#
# Dependencies:
#   "htmlparser": "1.7.6"
#   "soupselect": "0.2.0"
#   "underscore": "1.3.3"
#   "underscore.string": "2.3.0"
#
# Commands:
#   hubot otg - alias for `hubot otg list` (default market ID only)
#   hubot otg list <id?> - returns the truck list for the supplied market ID, or the default ID if none provided
#   hubot otg set_market <id> - sets the default market ID
#   hubot otg get_market - gets the default market ID
#   hubot otg markets - list all the markets for the next week with IDs
#   :foodtruck: - alias for `hubot otg list` (default market ID only)

_          = require("underscore")
_s         = require("underscore.string")
Select     = require("soupselect").select
HTMLParser = require "htmlparser"


module.exports = (robot) ->

  robot.respond /otg( list( \d+)?)?$/i, (msg) ->
    if msg.match[2]
      market_id = parseInt(msg.match[2])
    handleVendorListRequest(robot, msg, market_id)

  robot.hear /^:foodtruck:$/, (msg) ->
    handleVendorListRequest(robot, msg)

  robot.respond /otg set_market (\d+)$/i, (msg) ->
    market_id = parseInt(msg.match[1])
    callback = (msg, body) ->
      setMarketId(robot, market_id)
      msg.send 'OTG Market ID set to: ' + market_id + ' (' + parseMarketName(body) + ')'
    getMarketDetails(msg, market_id, callback)

  robot.respond /otg get_market$/i, (msg) ->
    market_id = getMarketId(robot)
    callback = (msg, body) ->
      msg.send 'OTG Market ID is currently set to: ' + getMarketId(robot) + ' (' + parseMarketName(body) + ')'
    getMarketDetails(msg, market_id, callback)

  robot.respond /otg markets$/i, (msg) ->
    msg.http("http://offthegridsf.com/markets")
      .get() (err, res, body) ->
        dom = parseHTML(body)
        event_trees = Select dom, '.otg-markets-event'
        events = for tree in event_trees
          id = tree.attribs['data-otg-market-id']
          name = Select tree, '.otg-markets-event-name'
          {name: treeToText(name[0]), market_id: id}

        events.sort (a, b) ->
          if a.name > b.name
            1
          else if b.name > a.name
            -1
          else
            0
        markets = _.uniq events, true, (obj) ->
          obj.name

        msg.send (market.name + ': ' + market.market_id for market in markets).join '\n'

handleVendorListRequest = (robot, msg, market_id=null) ->
  if not market_id
    market_id = getMarketId(robot)
  callback = (msg, body) ->
    dom = parseHTML(body)
    market_name = parseMarketName(dom)
    response = for details in parseVendors(dom)
        details.date + ': ' + details.vendors.join ', '
      msg.send '*' + market_name + '*:\n' + response.join '\n'
  getMarketDetails(msg, market_id, callback)  

getMarketDetails = (msg, market_id, callback) ->
  msg.http("http://offthegridsf.com/wp-admin/admin-ajax.php?action=otg_market&delta=0&market=" + market_id)
      .get() (err, res, body) ->
        callback(msg, body)

parseVendors = (html) ->
  if typeof html is 'string'
    dom = parseHTML(html)
  else
    dom = html
  vendor_list = Select dom, '.otg-market-data-vendors'
  date_list = Select dom, '.otg-market-data-events-pagination'
  for vendor_root, i in vendor_list
    market_date = _s.trim(treeToText(date_list[i]))
    vendors = for tree in Select vendor_root, '.otg-markets-data-vendor-name'
      treeToText(tree)
    {date: market_date, vendors: vendors}

parseMarketName = (html) ->
  if typeof html is 'string'
    dom = parseHTML(html)
  else
    dom = html
  market_nodes = Select dom, '.otg-market-data-name'
  treeToText(market_nodes[0])

childrenOfType = (root, nodeType) ->
  return [root] if root?.type is nodeType

  if root?.children?.length > 0
    return (childrenOfType(child, nodeType) for child in root.children)

  []

treeToText = (tree) ->
  children = _.flatten childrenOfType(tree, 'text')
  _s.unescapeHTML((textNode.data for textNode in children).join '')

parseHTML = (html) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser  = new HTMLParser.Parser handler
  parser.parseComplete html
  handler.dom

getMarketId = (robot) ->
  market_id = robot.brain.get('otg_market_id')
  if not market_id
    market_id = 2
    setMarketId robot, market_id
  market_id

setMarketId = (robot, market_id) ->
  robot.brain.set('otg_market_id', market_id)
  robot.brain.save