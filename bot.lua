-- bot.lua
local discordia = require("discordia")
local client = discordia.Client()
local fs = require("fs")
local obfuscator = require("your_vm_obfuscator") -- the VM obfuscator from earlier

local prefix = "!"

client:on("ready", function()
    print("Logged in as ".. client.user.username)
end)

client:on("messageCreate", function(message)
    if message.author.bot then return end
    if not message.content:lower():start(prefix) then return end

    local cmd, args = message.content:sub(#prefix+1):match("(%S+)%s*(.*)")
    
    if cmd == "obfuscate" then
        if #message.attachments == 0 then
            message.channel:send("Please attach a Lua file to obfuscate!")
            return
        end

        local attachment = message.attachments[1]
        local temp_file = "./temp.lua"

        -- Download the file
        attachment:download(temp_file):next(function()
            -- Obfuscate
            local success, result = pcall(obfuscator.obfuscate_file, temp_file)
            if not success then
                message.channel:send("Error during obfuscation: "..tostring(result))
                return
            end

            -- Save to obfuscated.lua
            local obf_path = "./obfuscated.lua"
            local f = io.open(obf_path,"w")
            f:write(result)
            f:close()

            -- Send file back
            message.channel:send{
                content = "Here is your obfuscated Lua file!",
                file = obf_path
            }

            -- Cleanup
            os.remove(temp_file)
            os.remove(obf_path)
        end, function(err)
            message.channel:send("Failed to download file: "..tostring(err))
        end)
    end
end)

client:run("Bot YOUR_BOT_TOKEN")
