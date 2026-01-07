namespace EchoAPI.Core.Entities
{
    public class PodcastProgress
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }
        public Guid PodcastId { get; set; }

        public float CurrentPosition { get; set; }
        public bool Completed { get; set; }

        public User User { get; set; } = null!;
        public Podcast Podcast { get; set; } = null!;
    }
}
