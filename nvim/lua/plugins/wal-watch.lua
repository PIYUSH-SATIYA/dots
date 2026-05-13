return {
  {
    name = "wal-watch",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    config = function()
      local uv = vim.loop
      local watcher = uv.new_fs_event()
      local timer = nil

      local function reload()
        vim.schedule(function()
          pcall(function()
            vim.cmd("colorscheme pywal16")
            require("config.wal").apply()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf) then
                local ft = vim.bo[buf].filetype
                if ft and ft ~= "" then
                  pcall(vim.treesitter.stop, buf)
                  pcall(vim.treesitter.start, buf, ft)
                end
              end
            end
            for _, client in ipairs(vim.lsp.get_clients()) do
              for buf in pairs(client.attached_buffers or {}) do
                pcall(vim.lsp.semantic_tokens.force_refresh, buf)
              end
            end
            vim.cmd("redraw!")
          end)
        end)
      end

      if watcher then
        watcher:start(vim.fn.expand("~/.cache/wal/"), {}, function(err, filename)
          if err or filename ~= "colors.json" then
            return
          end
          if timer then
            timer:stop()
            timer:close()
          end
          timer = uv.new_timer()
          timer:start(300, 0, vim.schedule_wrap(reload))
        end)
      end

      vim.api.nvim_create_user_command("WalReload", reload, {})

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          if watcher then
            watcher:stop()
          end
          if timer then
            timer:stop()
            timer:close()
          end
        end,
      })
    end,
  },
}

-- return {
--   {
--     name = "wal-watch",
--     dir = vim.fn.stdpath("config"),
--     lazy = false,
--
--     config = function()
--       local wal_dir = vim.fn.expand("~/.cache/wal/")
--       local target = "colors.json"
--
--       local uv = vim.loop
--       local watcher = uv.new_fs_event()
--
--       local timer = nil
--
--       -- local function reload()
--       --   vim.schedule(function()
--       --     pcall(function()
--       --       vim.cmd("colorscheme pywal16")
--       --
--       --       -- require("config.wal").load()
--       --
--       --       vim.cmd("redraw!")
--       --     end)
--       --   end)
--       -- end
--
--       local function reload()
--         vim.schedule(function()
--           pcall(function()
--             vim.cmd("colorscheme pywal16")
--             require("config.wal").load()
--
--             -- Force treesitter to re-apply @-highlights on all loaded buffers
--             for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--               if vim.api.nvim_buf_is_loaded(buf) then
--                 local ft = vim.bo[buf].filetype
--                 if ft and ft ~= "" then
--                   pcall(vim.treesitter.stop, buf)
--                   pcall(vim.treesitter.start, buf, ft)
--                 end
--               end
--             end
--
--             -- Re-apply LSP semantic tokens if active
--             for _, client in ipairs(vim.lsp.get_clients()) do
--               for buf, _ in pairs(client.attached_buffers or {}) do
--                 pcall(vim.lsp.semantic_tokens.force_refresh, buf)
--               end
--             end
--
--             vim.cmd("redraw!")
--           end)
--         end)
--       end
--
--       if watcher then
--         watcher:start(wal_dir, {}, function(err, filename)
--           if err then
--             return
--           end
--
--           if filename ~= target then
--             return
--           end
--
--           -- debounce
--           if timer then
--             timer:stop()
--             timer:close()
--           end
--
--           timer = uv.new_timer()
--
--           timer:start(
--             300,
--             0,
--             vim.schedule_wrap(function()
--               reload()
--             end)
--           )
--         end)
--       end
--
--       vim.api.nvim_create_user_command("WalReload", reload, {})
--
--       -- reload()
--       vim.api.nvim_create_autocmd("VimLeavePre", {
--         callback = function()
--           if watcher then
--             watcher:stop()
--           end
--
--           if timer then
--             timer:stop()
--             timer:close()
--           end
--         end,
--       })
--
--       vim.api.nvim_create_autocmd("ColorScheme", {
--         group = vim.api.nvim_create_augroup("WalFixed", { clear = true }),
--         callback = function()
--           vim.api.nvim_set_hl(0, "Visual", { bg = "#44475a", nocombine = true })
--         end,
--       })
--     end,
--   },
-- }
