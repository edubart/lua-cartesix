LUAEXE=lua
ROCKSPEC=rocks/cartesix-0.1.0-1.rockspec

test:
	lua5.4 test.lua

install:
	luarocks make --lua-version=5.4 --local $(ROCKSPEC)

upload-rocks:
	luarocks upload --api-key=$(LUAROCKS_APIKEY) $(ROCKSPEC)

.PHONY: test test-all test-rocks upload-rocks
