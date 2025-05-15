-- Test script for Pears configuration
-- This script validates the Pears configuration and checks for common issues

local function test_config()
  print("🔍 Testing Pears configuration...")
  
  -- Check if Lua is available
  local lua_version = _VERSION
  print(string.format("✅ Lua version: %s", lua_version))
  
  -- Check if required Lua modules are available
  local required_modules = {
    "lpeg",
    "lfs",
    "socket",
    "cjson",
    "yaml"
  }
  
  print("\n🔍 Checking required Lua modules:")
  local all_modules_available = true
  for _, module in ipairs(required_modules) do
    local status, _ = pcall(require, module)
    if status then
      print(string.format("✅ %s: available", module))
    else
      print(string.format("❌ %s: NOT available", module))
      all_modules_available = false
    end
  end
  
  -- Check if required commands are available
  local required_commands = {
    "git",
    "curl",
    "wget",
    "unzip"
  }
  
  print("\n🔍 Checking required system commands:")
  local all_commands_available = true
  for _, cmd in ipairs(required_commands) do
    local handle = io.popen(string.format("command -v %s", cmd))
    local result = handle:read("*a")
    handle:close()
    
    if result and result ~= "" then
      print(string.format("✅ %s: found at %s", cmd, result:gsub("\n", "")))
    else
      print(string.format("❌ %s: NOT found", cmd))
      all_commands_available = false
    end
  end
  
  -- Check if Pears configuration file exists
  print("\n🔍 Checking Pears configuration:")
  local config_file = "pears.lua"
  local config_exists = io.open(config_file, "r") ~= nil
  
  if config_exists then
    print(string.format("✅ Configuration file found: %s", config_file))
    
    -- Try to load the configuration
    local success, config = pcall(dofile, config_file)
    if success then
      print("✅ Configuration is valid Lua code")
      
      -- Check for required fields
      local required_fields = {"name", "description"}
      local missing_fields = {}
      
      for _, field in ipairs(required_fields) do
        if not config[field] then
          table.insert(missing_fields, field)
        end
      end
      
      if #missing_fields == 0 then
        print("✅ All required fields are present")
        print(string.format("   Name: %s", config.name))
        print(string.format("   Description: %s", config.description))
      else
        print(string.format("❌ Missing required fields: %s", table.concat(missing_fields, ", ")))
      end
      
    else
      print(string.format("❌ Error loading configuration: %s", tostring(config)))
    end
  else
    print(string.format("❌ Configuration file not found: %s", config_file))
    print("   Please create a 'pears.lua' file in the current directory")
  end
  
  -- Print summary
  print("\n📊 Test Summary:")
  print(string.format("✅ Lua version: %s", lua_version))
  print(string.format("✅ Required Lua modules: %s", all_modules_available and "All available" or "Some missing"))
  print(string.format("✅ Required system commands: %s", all_commands_available and "All available" or "Some missing"))
  print(string.format("✅ Configuration: %s", config_exists and "Found" or "Not found"))
  
  if config_exists then
    local success, _ = pcall(dofile, config_file)
    print(string.format("✅ Configuration is %s", success and "valid" or "invalid"))
  end
  
  print("\n✨ Test completed!")
  
  if not all_modules_available or not all_commands_available or not config_exists then
    print("\n⚠️  Some checks failed. Please address the issues above.")
    os.exit(1)
  end
end

-- Run the tests
test_config()
