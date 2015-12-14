using YAML

type SettingsYAMLFile <: Associative
    data::Dict
    filename::AbstractString
    watched::Bool
    file_watcher::Task

    function SettingsYAMLFile(filename::AbstractString, watched::Bool=true)
        data = YAML.load(open(filename))

        # Now get our settings source object so we can update the data
        # asynchroniously if desired
        settings_source = new(data, filename, watched, @async begin end)

        # Now set up the real watcher
        if watched
            settings_source.file_watcher = @async begin
                while settings_source.watched
                    name, status = watch_file(settings_source.filename)
                    if status.changed
                        settings_source.data = YAML.load(open(settings_source.filename))
                    end
                end
            end
        end

        return settings_source
    end
end

Base.getindex(item::SettingsYAMLFile, key) = item.data[key]

Base.keys(item::SettingsYAMLFile) = keys(item.data)
