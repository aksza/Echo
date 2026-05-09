using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EchoAPI.Migrations
{
    /// <inheritdoc />
    public partial class UpdateLanguageAssessmentUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "PlacementScore",
                table: "Users",
                newName: "WritingScore");

            migrationBuilder.RenameColumn(
                name: "PlacementConfidence",
                table: "Users",
                newName: "WritingConfidence");

            migrationBuilder.AddColumn<float>(
                name: "SpeakingConfidence",
                table: "Users",
                type: "real",
                nullable: false,
                defaultValue: 0f);

            migrationBuilder.AddColumn<int>(
                name: "SpeakingLevel",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "SpeakingScore",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "WritingLevel",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SpeakingConfidence",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SpeakingLevel",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SpeakingScore",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "WritingLevel",
                table: "Users");

            migrationBuilder.RenameColumn(
                name: "WritingScore",
                table: "Users",
                newName: "PlacementScore");

            migrationBuilder.RenameColumn(
                name: "WritingConfidence",
                table: "Users",
                newName: "PlacementConfidence");
        }
    }
}
