module SettingsBundles

export
    # Types
    SettingsBundle, SettingsYAMLFile, SettingsJSONFile,
    # Functions
    add!

include("sources/SettingsYAMLFile.jl")
include("sources/SettingsJSONFile.jl")

"""
The SettingsBundle type; a dictionary on staroids

Also, it only accepts symbols as inputs to make searching
for things more uniform. So I guess I should say sources
must be Associative objects with symbol based keys.
"""
type SettingsBundle
    sources::Array{Associative}

    SettingsBundle() = new(Array(Associative, 0))
end

"""
Addes a settings source to a SettingsBundle. The most recently
added source is the highest priority
"""
add!(item::SettingsBundle, source::Associative) = insert!(item.sources, 1, source)

"""
getindex for a Settings object involve going through the `sources`
array and going until we find a settings object that has the desired
key. Once found, it returns the objects. If non of the sources has
the key, throws an error
"""
function Base.getindex(item::SettingsBundle, key)
    for source in item.sources
        try
            return source[key]
        catch
            # Do nothing. We still have more sources to check :)
        end
    end
    # Not in any of our sources. Shame.
    throw(KeyError(key))
end

"You connot set items in a SettingsBundle by direct assigment"
function Base.setindex!(item::SettingsBundle, key, value)
    throw(error("Elements in SettingsBundles cannot be modified directly"))
end

"Compiles a list of available keys"
function Base.keys(item::SettingsBundle)
    source_keys = map(keys, item.sources)
    return union(source_keys...)
end

end # module
