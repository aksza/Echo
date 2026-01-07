namespace EchoAPI.Core.Entities
{
    public class ProgressStats
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }

        public DateTime WeekStart { get; set; }
        public int NewWords { get; set; }
        public int MistakesFixed { get; set; }
        public int StudyMinutes { get; set; }

        public User User { get; set; } = null!;
    }
}
