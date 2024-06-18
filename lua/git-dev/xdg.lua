--- @class XDG_Handler
--- @field name string used for the filename
--- @field scheme string the actuall schem like: nvim-gitdev
--- @field wrapper string a wrapper script

local M = {}

---@param handler XDG_Handler
---@return boolean was_sucessfull
M.generate_xdg_handler_desktop_entry = function(handler)
    local file_name = string.format("~/.local/share/applications/%s.desktop")
    local file_content = string.format([[
        [Desktop Entry]
        NoDisplay=true
        Exec=%snvim -c "GitDevOpen %%u"
        Terminal=true
        Type=Application
        MimeType=x-scheme-handler/%s
        ]],
        handler.wrapper,
        handler.scheme
    )

    local file = io.open(vim.fn.expand(file_name), "w")
    if file then
        file:write(file_content)
        file:close()
    end
    return file ~= nil
end

---@param handler XDG_Handler
---@param callback function(job_id: number, exit_code: number):void
---@return number job_id
M.register_xdg_handler = function(handler, callback)
    local cmd = {
        "xdg-mime",
        "default",
        string.format("%s.desktop", handler.name),
        string.format("x-scheme-handler/%s", handler.scheme),
    }

    local job_id = vim.fn.jobstart(cmd, { on_exit = callback })
    return job_id
end

return M