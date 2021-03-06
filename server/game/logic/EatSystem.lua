local util = require("util")
local entitas = require("entitas")
local Components = require("Components")
local vector2 = require("vector2")
local ReactiveSystem = entitas.ReactiveSystem
local Matcher = entitas.Matcher
local GroupEvent = entitas.GroupEvent

local class = util.class

local M = class("EatSystem", ReactiveSystem)

function M:ctor(contexts, helper)
    M.super.ctor(self, contexts.game)
    self.context = contexts.game
    self.net = helper.net
    self.movers = self.context:get_group(Matcher({Components.Mover}))
end

function M:get_trigger()
    return {
        {
            Matcher({Components.Eat}),
            GroupEvent.ADDED | GroupEvent.UPDATE
        }
    }
end

function M:filter(entity)
    return entity:has(Components.Eat)
end

function M:execute(entites)
    local num = 0
    entites:foreach(function(e)
        local weight = e:get(Components.Eat).weight
        local radius = e:get(Components.Radius).value
        local newradius =radius + weight
        e:replace(Components.Radius,newradius)
    end)
end

return M
