local M = {}

M.default_config = {
    notify_git_failed = true,
    git_command = "git",
}

M.setup = function (opts)
    local config = vim.tbl_extend("force", M.default_config, opts or {})

    vim.api.nvim_create_autocmd({"VimLeavePre"}, {
        group = vim.api.nvim_create_augroup('amzd/dontforgit', {}),
        pattern = "*",
        callback = function ()
            local ok, ret = pcall(vim.fn.systemlist, { config.git_command, "status", "-s" })
            ok = ok and vim.v.shell_error == 0
            if not ok and config.notify_git_failed then
                vim.ui.input({ prompt = "Failed to get git status" }, function() end)
            end
            -- there's nothing to commit: skip
            if not ok or #ret == 0 then return end

            local git_status = "!" .. config.git_command .. " status"
            local input = git_status
            while input ~= nil do
                pcall(vim.cmd, input)

                vim.ui.input({ prompt = ":" }, function (new_input)
                    if new_input == "" then
                        -- I don't like how it prints as "::!<command>" but it's better than ":\n:!<command>"
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
