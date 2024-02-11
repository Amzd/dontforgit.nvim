local M = {}

M.default_config = {
    -- If you often work in projects without git then turn this off to stop this plugin pestering you
    notify_git_failed = true,
    git_command = "git",
    -- If you always do `:!git <something>` then you can set this to "!git " to save typing
    prompt_prefix = "",
    -- Wether to add `-s` to `git status` command
    compact = false,
    -- Disable the hint with
    disable_hint = false,
}

M.setup = function (opts)
    local config = vim.tbl_extend("force", M.default_config, opts or {})

    local function has_pending_changes()
        local ok, ret = pcall(vim.fn.systemlist, { config.git_command, "status", "-s", "-b" })
        ok = ok and vim.v.shell_error == 0
        if not ok and config.notify_git_failed then
            vim.ui.input({ prompt = "Failed to get git status" }, function() end)
        end

        -- filter out "## <branch>...<remote>" that are missing "[<ahead/behind>]"
        -- so our result does not contain the print of current branch by git status
        ret = vim.tbl_filter(function (v)
            return not v:find("## .*%.%.%.") or v:find("%[.*%]")
        end, ret)

        return ok and #ret > 0
    end

    vim.api.nvim_create_autocmd({"VimLeavePre"}, {
        group = vim.api.nvim_create_augroup('amzd/dontforgit', {}),
        pattern = "*",
        callback = function ()
            if not has_pending_changes() then return end

            if not config.disable_hint then
                print("Press <Esc>/:q/<C-c> or commit everything to exit | <Enter> without changing command to show git status again")
            end

            local git_status = "!" .. config.git_command .. " status" .. (config.compact and " -s" or "")
            local input = git_status
            while input ~= nil do
                pcall(vim.cmd, input)

                if not has_pending_changes() then
                    input = nil
                    return
                end

                vim.ui.input({ prompt = ":", default = config.prompt_prefix }, function (new_input)
                    if new_input == "" then
                        -- I don't like how it prints as "::!<command>" but it's better than ":\n:!<command>"
                        input = git_status
                    elseif new_input == config.prompt_prefix then
                        print("\n")
                        input = git_status
                    else
                        print("\n")
                        input = new_input
                    end
                end)
            end
        end
    })
end

return M
