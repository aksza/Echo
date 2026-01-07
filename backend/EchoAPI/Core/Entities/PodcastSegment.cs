namespace EchoAPI.Core.Entities
{
    public class PodcastSegment
    {
        public Guid Id { get; set; }

        public Guid PodcastId { get; set; }

        public float StartTime { get; set; }
        public float EndTime { get; set; }
        public string Text { get; set; } = null!;

        public Podcast Podcast { get; set; } = null!;
    }
}
