local Environment = require("magento.dto.environment")

---@class magento.core.env
---@field _root string|nil Cached Magento root path
---@field _environment magento.dto.environment|nil Cached environment
local M = {}

---Find the Magento root directory by looking for bin/magento
---@param start_path? string Starting directory (defaults to cwd)
---@return string|nil root_path
function M.find_root(start_path)
    start_path = start_path or vim.fn.getcwd()

    -- Check if bin/magento exists in current directory
    local magento_bin = start_path .. "/bin/magento"
    if vim.fn.filereadable(magento_bin) == 1 then
        return start_path
    end

    -- Walk up the directory tree looking for bin/magento
    local path = start_path
    for _ = 1, 10 do -- Max 10 levels up
        local parent = vim.fn.fnamemodify(path, ":h")
        if parent == path then
            break -- Reached filesystem root
        end
        path = parent

        magento_bin = path .. "/bin/magento"
        if vim.fn.filereadable(magento_bin) == 1 then
            return path
        end
    end

    return nil
end

---Check if Warden is being used by looking for .env with WARDEN_ENV_NAME
---@param root string Magento root path
---@return boolean
function M.is_warden(root)
    local env_file = root .. "/.env"
    if vim.fn.filereadable(env_file) == 0 then
        return false
    end

    -- Read .env and check for WARDEN_ENV_NAME
    local lines = vim.fn.readfile(env_file)
    for _, line in ipairs(lines) do
        if line:match("^WARDEN_ENV_NAME=") then
            return true
        end
    end

    return false
end

---Check if Docker Compose is being used
---@param root string Magento root path
---@return boolean
function M.is_docker(root)
    local docker_compose_files = {
        root .. "/docker-compose.yml",
        root .. "/docker-compose.yaml",
    }

    for _, file in ipairs(docker_compose_files) do
        if vim.fn.filereadable(file) == 1 then
            return true
        end
    end

    return false
end

---Detect the environment and create an Environment DTO
---@param root? string Magento root path (auto-detected if not provided)
---@return magento.dto.environment|nil, string|nil environment, error
function M.detect(root)
    root = root or M.find_root()

    if not root then
        return nil, "Not in a Magento project (bin/magento not found)"
    end

    -- Check for Warden first (uses php-fpm container)
    if M.is_warden(root) then
        return Environment:new("warden", {
            magento = { "warden", "env", "exec", "-T", "php-fpm", "bin/magento" },
            php = { "warden", "env", "exec", "-T", "php-fpm", "php" },
        })
    end

    -- Check for Docker Compose
    if M.is_docker(root) then
        return Environment:new("docker", {
            magento = { "docker-compose", "exec", "-T", "php", "bin/magento" },
            php = { "docker-compose", "exec", "-T", "php", "php" },
        })
    end

    -- Native/local environment
    return Environment:new("native", {
        magento = { "bin/magento" },
        php = { "php" },
    })
end

---Get the current environment (cached)
---@return magento.dto.environment|nil, string|nil
function M.get()
    if M._environment then
        return M._environment
    end

    local env, err = M.detect()
    if env then
        M._environment = env
        M._root = M.find_root()
    end

    return env, err
end

---Get the Magento root directory (cached)
---@return string|nil
function M.root()
    if M._root then
        return M._root
    end

    M._root = M.find_root()
    return M._root
end

---Check if currently in a Magento project
---@return boolean
function M.is_magento_project()
    return M.find_root() ~= nil
end

---Clear cached environment (useful for testing or project switching)
function M.clear_cache()
    M._environment = nil
    M._root = nil
end

return M
