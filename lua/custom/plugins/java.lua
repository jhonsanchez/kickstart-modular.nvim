-- Java LSP Configuration using nvim-jdtls
return {
  'mfussenegger/nvim-jdtls',
  ft = 'java', -- Only load for Java files
  config = function()
    -- Function to find the root directory of a Java project
    local function get_project_root()
      return vim.fs.root(0, { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
    end

    -- Get the Mason installation path for jdtls
    local jdtls_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

    -- Determine OS-specific configuration
    local os_config
    if vim.fn.has 'win32' == 1 then
      os_config = 'config_win'
    elseif vim.fn.has 'mac' == 1 then
      os_config = 'config_mac'
    else
      os_config = 'config_linux'
    end

    -- Configure jdtls when a Java file is opened
    local function setup_jdtls()
      local project_root = get_project_root()
      if not project_root then
        vim.notify('Java project root not found', vim.log.levels.WARN)
        return
      end

      -- Workspace directory (project-specific to avoid conflicts)
      local project_name = vim.fn.fnamemodify(project_root, ':p:h:t')
      local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

      -- Get capabilities from blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local config = {
        cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-Xmx1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens',
          'java.base/java.util=ALL-UNNAMED',
          '--add-opens',
          'java.base/java.lang=ALL-UNNAMED',
          '-jar',
          vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
          '-configuration',
          jdtls_path .. '/' .. os_config,
          '-data',
          workspace_dir,
        },
        root_dir = project_root,
        capabilities = capabilities,
        settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = 'interactive',
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = true,
            },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              'org.hamcrest.MatcherAssert.assertThat',
              'org.hamcrest.Matchers.*',
              'org.hamcrest.CoreMatchers.*',
              'org.junit.jupiter.api.Assertions.*',
              'java.util.Objects.requireNonNull',
              'java.util.Objects.requireNonNullElse',
              'org.mockito.Mockito.*',
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
        },
        init_options = {
          bundles = {},
        },
        -- Key mappings will be set up via LspAttach autocmd from lspconfig.lua
        -- This ensures consistency with other LSPs
      }

      -- Start jdtls
      require('jdtls').start_or_attach(config)
    end

    -- Auto-setup jdtls when opening Java files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = setup_jdtls,
      group = vim.api.nvim_create_augroup('jdtls-setup', { clear = true }),
    })
  end,
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'saghen/blink.cmp',
  },
}
