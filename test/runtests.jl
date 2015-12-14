using SettingsBundles
using Base.Test

# write your own tests here
@test 1 == 1

settings = SettingsBundle()
add!(settings, SettingsYAMLFile("/Users/dustinrb/.julia/v0.4/SettingsBundles/test/test.yaml"))
add!(settings, SettingsYAMLFile("/Users/dustinrb/.julia/v0.4/SettingsBundles/test/test.json"))
settings["something"]
