local progress = require("fidget.progress")

local M = {}
M.handles = {}

---Format the LLM adapter and model name for Fidget's LSP client label
---@param adapter table|nil
---@return string
function M.llm_role_title(adapter)
  if not adapter then
    return "CodeCompanion"
  end
  local parts = {}
  table.insert(parts, adapter.formatted_name or adapter.name or "LLM")
  if adapter.model and adapter.model ~= "" then
    table.insert(parts, "(" .. adapter.model .. ")")
  end
  return table.concat(parts, " ")
end

---Set exit status and finish message
---@param handle table
---@param status string|nil
function M.report_exit_status(handle, status)
  if status == "success" then
    handle.message = "Completed"
  elseif status == "error" then
    handle.message = " Error"
  elseif status == "cancelled" or status == "stopped" then
    handle.message = "󰜺 Cancelled"
  else
    handle.message = status or "Finished"
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("CodeCompanionFidgetIntegration", { clear = true })

  -- Listen to all request lifecycle events (Started, Streaming, Finished, Cancelled, Error)
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      local data = request.data or {}
      local id = data.id

      if request.match == "CodeCompanionRequestStarted" then
        -- Dismiss any preliminary connecting handle for this chat/buffer
        if data.bufnr and M.handles["chat_" .. data.bufnr] then
          M.handles["chat_" .. data.bufnr]:finish()
          M.handles["chat_" .. data.bufnr] = nil
        end

        local interaction = data.interaction or data.strategy or "request"
        local handle = progress.handle.create({
          title = " Requesting assistance (" .. interaction .. ")",
          message = "Awaiting response...",
          lsp_client = {
            name = M.llm_role_title(data.adapter),
          },
        })

        if id then
          M.handles[id] = handle
        end
        if data.bufnr then
          M.handles["buf_" .. data.bufnr] = handle
        end

      elseif request.match == "CodeCompanionRequestStreaming" then
        local handle = (id and M.handles[id]) or (data.bufnr and M.handles["buf_" .. data.bufnr])
        if handle then
          handle.message = "Streaming response..."
        end

      elseif request.match == "CodeCompanionRequestFinished" then
        local handle = (id and M.handles[id]) or (data.bufnr and M.handles["buf_" .. data.bufnr])
        if handle then
          M.report_exit_status(handle, data.status)
          handle:finish()
          if id then M.handles[id] = nil end
          if data.bufnr then M.handles["buf_" .. data.bufnr] = nil end
        end

      elseif request.match == "CodeCompanionRequestCancelled" or request.match == "CodeCompanionRequestError" then
        local handle = (id and M.handles[id]) or (data.bufnr and M.handles["buf_" .. data.bufnr])
        if handle then
          M.report_exit_status(handle, request.match == "CodeCompanionRequestError" and "error" or "cancelled")
          handle:finish()
          if id then M.handles[id] = nil end
          if data.bufnr then M.handles["buf_" .. data.bufnr] = nil end
        end
      end
    end,
  })

  -- Show immediate feedback when submitting to chat/agent while connection initializes
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionChatSubmitted",
    group = group,
    callback = function(request)
      local data = request.data or {}
      local key = "chat_" .. (data.bufnr or data.id or "active")
      if not M.handles[key] then
        M.handles[key] = progress.handle.create({
          title = " CodeCompanion (chat)",
          message = "Connecting to agent...",
          lsp_client = { name = "CodeCompanion" },
        })
      end
    end,
  })

  -- Clean up lingering handles when chat is done, stopped, or closed
  vim.api.nvim_create_autocmd("User", {
    pattern = { "CodeCompanionChatDone", "CodeCompanionChatStopped", "CodeCompanionChatClosed" },
    group = group,
    callback = function(request)
      local data = request.data or {}
      local key = "chat_" .. (data.bufnr or data.id or "active")
      local handle = M.handles[key]
      if handle then
        handle:finish()
        M.handles[key] = nil
      end
    end,
  })
end

M.init = M.setup

return M
