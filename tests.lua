local cartesix_rolling_machine = require("cartesix.rollingmachine")
local cartesix_encoder = require("cartesix.encoder")
local lester = require("lester")
local describe, it, expect = lester.describe, lester.it, lester.expect

describe("tests", function()
    it("create and destroy machine", function()
        local machine <close> = cartesix_rolling_machine({ram={length=64*1024*1024}}, {}, 'local')
    end)
end)
