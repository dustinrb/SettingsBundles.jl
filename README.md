# SettingsBundles

[![Build Status](https://travis-ci.org/dustinrb/SettingsBundles.jl.svg?branch=master)](https://travis-ci.org/dustinrb/SettingsBundles.jl)

Settings bundles provides a unified key-value store for querying information from multiple sources (i.g. configuration files or dictionaries).

## Installation

Simply run `Pkg.add(“SettingsBundles”)` in the Julia REPL

## Usage

### `SettingsBundle(settings_sources...)`

A `SettingsBundle` acts as a unified interface to access all settings sources as if they were in a single dictionary. The last settings source added to the SettingsBundle has the highest priority, so its values take precedence if there are duplicate keys in the bundle. A settings source is any Associative type that accepts strings as keys.

`SettingsBundle`s are read only. They do note have a `setindex!` method defined.

### `add!(bundle, associative)`

`bundle` is a SettingsBundle. `associative` is any Associative object that accepts strings as keys. After executing this function, `associative` has the highest priority in the bundle.

### `flatten(bundle)`

`flatten` takes a settings bundle and copies it into a dictionary. This is useful for passing a SettingsBundle to a PyCall.

### Included Settings Sources

#### `SettingsYAMLFile(path, watched=true)`

`path` points to a YAML file which is then read in as a SettingsYAMLFile type compatible with SettingsBundles. If `watched` is `true`, an asynchronous process is spawned which will update the values in the SettingsYAMLFile (and subsequently the SettingsBundle) when changes are detected to the file specified with `path`.

#### `SettingsJSONFile(path, watched=true)`

`path` points to a JSON file which is then read in as a SettingsJSONFile type compatible with SettingsBundles. If `watched` is `true`, an asynchronous process is spawned which will update the values in the SettingsJSONFile (and subsequently the SettingsBundle) when changes are detected to the file specified with `path`.

#### Additional Settings Sources

Additional sources can easily be defined by creating a subtype of Associative that accepts keys as strings. See `src/sources/SettingsYAMLFile.jl` for an example. Pull requests specifying additional settings sources are appreciated.

## Example

Say you have an application that has a default config file and a user specified config, plus a few settings that must be configure at runtime.

```YAML
# defaults.yaml
plugins_dir: ~/.myapp/plugins
format: yaml
color: red
```

```YAML
# user_settings.yaml
username: user
email: user@example.com
color: blue
```

```julia
# Create out settings bundles
using SettingsBundles

settings = SettingsBundle(
    SettingsYAMLFile("defaults.yaml"),
    SettingsYAMLFile("user_settings.yaml"),
    Dict("working_dir" => pwd()) # Runtime settings
)

# Now `settings` contains all values form the settings sources
settings["plugins_dir"] # Returns `~/.myapp/plugins`
settings["username"] # Returns `user`
settings["working_dir"] # Returns `/Users/user/`

# Now what about the `color` setting? It's listed in both
#    defaults.yaml and user_settings.yaml.
settings["color"] # Returns `blue`

# Settings bundles prioritize the last settings source added
#   to the SettingsBundle

# Need to add another source after constructing `settings`?
add!(settings, Dict("color" => "yellow")) # Just call the add function
settings["color"] # Returns `yellow`

# To create a snapshot of the settings bundle, use `flatten`
flatten(settings) # Returns:
# Dict(
#     "plugins_dir" => "~/.myapp/plugins",
#     "format" => "yaml",
#     "color" => "yellow",
#     "username" => "user",
#     "email" => "user@example.com",
#     "working_dir" => "~/.myapp/plugins"
# )
```