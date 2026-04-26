namespace EchoAPI.Core.Config
{
    /// <summary>
    /// Configuration settings for file storage
    /// </summary>
    public class StorageSettings
    {
        public const string SectionName = "Storage";

        public string AudioFilesPath { get; set; } = "wwwroot/audio";
        public int MaxAudioFileSizeMB { get; set; } = 10;
        public List<string> AllowedAudioFormats { get; set; } = new() { "wav", "mp3", "ogg", "webm" };
        public int RetentionDays { get; set; } = 30;

        /// <summary>
        /// Get full path for audio storage
        /// </summary>
        public string GetFullPath(string basePath)
        {
            return Path.Combine(basePath, AudioFilesPath);
        }

        /// <summary>
        /// Check if file extension is allowed
        /// </summary>
        public bool IsFormatAllowed(string extension)
        {
            return AllowedAudioFormats.Contains(extension.TrimStart('.').ToLower());
        }
    }
}
