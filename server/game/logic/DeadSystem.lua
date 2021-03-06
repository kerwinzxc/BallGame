local util = require("util")
local entitas = require("entitas")
local Components = require("Components")
local vector2 = require("vector2")
local ReactiveSystem = entitas.ReactiveSystem
local Matcher = entitas.Matcher
local GroupEvent = entitas.GroupEvent

local class = util.class

local M = class("DeadSystem", ReactiveSystem)

function M:ctor(contexts, helper)
    M.super.ctor(self, contexts.game)
    self.context = contexts.game
    self.input_entity = contexts.input.input_entity
    self.aoi = helper.aoi
    self.net = helper.net
end

function M:get_trigger()
    return {
        {
            Matcher({Components.Dead}),
            GroupEvent.ADDED | GroupEvent.UPDATE
        }
    }
end

function M:filter(entity)
    return entity:has(Components.Dead)
end

local fooduuid = 200000

function M:execute(entites)
    local num = 0
    entites:foreach(function( ne )
        local p =  ne:get(Components.BaseData)
        local isfood = ne:has(Components.Food)

        if not isfood then
            self.net.send(p.id,"S2CLeaveView",{id=p.id}) 
        end
        self.aoi.update_pos(p.id, "d", 0, 0)
        self.context:destroy_entity(ne)
        if isfood then
            num = num +1
        end
    end)
    self.input_entity:replace(Components.InputCreateFood,num)
    self.aoi.update_message()
end

return M
