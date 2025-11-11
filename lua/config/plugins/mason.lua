return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- PHP Language Server
        "intelephense",
        -- PHP Formatter (already configured in conform.nvim)
        "phpcbf",
      },
    },
  }
}
