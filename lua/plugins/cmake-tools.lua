-- Civitasv/cmake-tools.nvim — CMake integration.
--
-- <leader>rr builds the project and runs the selected target. cmake-tools
-- resolves the project from Neovim's cwd, so the keybind first walks up from
-- the current buffer to find CMakeLists.txt, cd's there, then runs :CMakeRun.
-- If no CMake project is found it shows a clean message instead of a stack trace.
local function build_and_run()
  local buf = vim.api.nvim_buf_get_name(0)
  local start = buf ~= "" and vim.fs.dirname(buf) or vim.fn.getcwd()
  local found = vim.fs.find("CMakeLists.txt", { path = start, upward = true })[1]
  if not found then
    vim.notify("No CMakeLists.txt found above " .. start, vim.log.levels.WARN, { title = "CMake" })
    return
  end
  vim.cmd.cd(vim.fs.dirname(found))
  vim.cmd.CMakeRun()
end

return {
  "Civitasv/cmake-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = { "c", "cpp", "cmake" },
  cmd = {
    "CMakeGenerate",
    "CMakeBuild",
    "CMakeRun",
    "CMakeDebug",
    "CMakeSelectBuildTarget",
    "CMakeSelectLaunchTarget",
    "CMakeSelectBuildType",
  },
  keys = {
    { "<leader>rr", build_and_run, desc = "CMake build & run" },
  },
  opts = {
    cmake_command = "cmake",
    cmake_build_directory = "build",
    cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    cmake_compile_commands_options = {
      -- "lsp": hand compile_commands.json to clangd directly. Avoids the default
      -- "soft_link" action, which shells out to `cmake -E create_symlink` and
      -- needs symlink privileges (Developer Mode/admin) on Windows.
      action = "lsp",
    },
  },
}
