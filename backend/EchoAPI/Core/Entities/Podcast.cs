namespace EchoAPI.Core.Entities
{
    public class Podcast
    {
        public Guid Id { get; set; }

        public string Title { get; set; } = null!;
        public string? Description { get; set; }
        public string Language { get; set; } = null!;
        public bool Generated { get; set; }
        public string? AudioUrl { get; set; }

        public ICollection<PodcastSegment> Segments { get; set; } = new List<PodcastSegment>();
        public ICollection<PodcastProgress> ProgressRecords { get; set; } = new List<PodcastProgress>();
    }
}
