/// The name of the application will be appended to the path in the
/// standardized format for the target operating system. When not provided, the
/// base path will be returned as per your request. 
app_name: ?[]const u8 = null,

/// The author of the application (which may also be a company name) will be
/// appended to the path in the standardized format for the target operating
/// system. When not provided, the base path will be returned as per your
/// request.
app_author: ?[]const u8 = null,

/// The application version will be appended to the path in the standardized
/// format for the target operating system. When not provided,`version` will be
/// omitted from the returned path. On unix systems, `app_name` is required for
/// `version` to be appended.
version: ?[]const u8 = null,

/// Windows-specific. Roaming path will be returned if set to true. Consider if
/// you would like application files to sync to the user's other devices.
roaming: bool = false,

/// Will return all file paths that match your request if there are more than
/// one. File paths will be concatenated by your operating system's path
/// delimiter. If only one path is available, setting `multipath` to true will
/// have no impact on behavior.
///
/// See Also: `dirs.multiPathIterator`, `std.fs.path.delimiter`
multipath: bool = false,

/// Will apply informed opinions to path structure. Opinions are documented on
/// structs that implement the `Locator` interface.
opinion: bool = false,

