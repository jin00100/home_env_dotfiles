local utils = {}

-- 안전한 설정을 위한 헬퍼 함수
utils.safe_require = function(module, config_fn)
  local ok, mod = pcall(require, module)
  if ok then config_fn(mod) end
end

return utils
